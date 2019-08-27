sprint_lite = {}
sprint_lite.player_info = {}

local max_stamina = minetest.settings:get("sprint_lite_max_stamina") or 20
local speed_multiplier = minetest.settings:get("sprint_lite_speed_multiplier") or 1.75
local jump_multiplier = minetest.settings:get("sprint_lite_jump_multiplier") or 1.25
local step_interval = minetest.settings:get("sprint_lite_step_interval") or 0.15
local drain_hunger = minetest.settings:get("sprint_lite_drain_hunger") ~= false
local drain_hunger_amount = minetest.settings:get("sprint_lite_hunger_amount") or 0.03
local stamina_drain = minetest.settings:get("sprint_lite_stamina_drain") or 0.5
local stamina_regen = minetest.settings:get("sprint_lite_stamina_regen") or 0.1
local stamina_threshold = minetest.settings:get("sprint_lite_stamina_threshold") or 8
local spawn_particles = minetest.settings:get("sprint_lite_spawn_particles") ~= false

local hudbars_enabled = false

if minetest.get_modpath("hudbars") then
    hb.register_hudbar(
        "stamina",
        0xFFFFFF,
        "Stamina",
        {
            bar = "sprint_lite_bar.png",
            icon = "sprint_lite_icon.png",
            bgicon = "sprint_lite_bg.png"
        },
        0,
        max_stamina,
        false)
    hudbars_enabled = true
end

if not minetest.get_modpath("hbhunger") and drain_hunger then
    minetest.log("error", "[sprint_lite] hbhunger is not enabled/installed! Hunger drain is disabled")
    drain_hunger = false
end

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    sprint_lite.player_info[name] = {ref = player, stamina = max_stamina, previous_stamina = 0, sprinting = false, grounded = false}
    if hudbars_enabled then hb.init_hudbar(player, "stamina", sprint_lite.player_info[name].stamina, max_stamina) end
end)

minetest.register_on_leaveplayer(function(player)
    local name = player:get_player_name()
    sprint_lite.player_info[name] = nil
end)

local sprint_timer = 0

minetest.register_globalstep(function(dtime)

    sprint_timer = sprint_timer + dtime
    if sprint_timer < step_interval then return end

    for playername,playerstats in pairs(sprint_lite.player_info) do

        local pos = playerstats.ref:get_pos()
        local keys = playerstats.ref:get_player_control()
        local node = minetest.get_node_or_nil({x = pos.x, y = pos.y - 1, z = pos.z})

        if node and (minetest.registered_nodes[node.name].walkable or minetest.registered_nodes[node.name].liquidtype ~= "none") then
            playerstats.grounded = true
        else
            playerstats.grounded = false
        end

        if keys.aux1 and keys.up and not keys.left and not keys.right and not keys.down and not keys.sneak then
            if playerstats.grounded and ((not playerstats.sprinting and playerstats.stamina > stamina_threshold) or (playerstats.sprinting and playerstats.stamina > 0)) then
                if not playerstats.sprinting then
                    playerstats.sprinting = true
                    player_monoids.speed:add_change(playerstats.ref, speed_multiplier, "sprint_lite_sprinting")
                    player_monoids.jump:add_change(playerstats.ref, jump_multiplier, "sprint_lite_jumping")
                end
            else
                playerstats.sprinting = false
                player_monoids.speed:del_change(playerstats.ref, "sprint_lite_sprinting")
                player_monoids.jump:del_change(playerstats.ref, "sprint_lite_jumping")
            end
        else
            if playerstats.sprinting then
                playerstats.sprinting = false
                player_monoids.speed:del_change(playerstats.ref, "sprint_lite_sprinting")
                player_monoids.jump:del_change(playerstats.ref, "sprint_lite_jumping")
            end
        end

        if playerstats.sprinting and playerstats.stamina > 0 then

            playerstats.stamina = playerstats.stamina - stamina_drain
            if playerstats.stamina < 0 then playerstats.stamina = 0 end

            if drain_hunger then
                local hunger = hbhunger.hunger[playername]
                hunger = hunger - drain_hunger_amount
                if hunger < 0 then hunger = 0 end
                hbhunger.hunger[playername] = hunger
                hbhunger.set_hunger_raw(playerstats.ref)
            end

            if spawn_particles then
                local texture = minetest.registered_nodes[node.name].tiles[1]
                if not texture or texture and type(texture) ~= "string" then
                    texture = "tnt_smoke.png"
                end
                local glow = minetest.registered_nodes[node.name].light_source or 0
                minetest.add_particlespawner({
                    amount = math.random(4, 8),
                    time = 0.05,
                    minpos = {x=-0.35, y=-0.4, z=-0.35},
                    maxpos = {x=0.35, y=-0.4, z=0.35},
                    minvel = {x=-0.25, y=1, z=-0.25},
                    maxvel = {x=0.25, y=3, z=0.25},
                    minacc = {x=0, y=-9.8, z=0},
                    maxacc = {x=0, y=-9.8, z=0},
                    minexptime = 1.5,
                    maxexptime = 2.5,
                    minsize = 0.3,
                    maxsize = 1.25,
                    collisiondetection = true,
                    collision_removal = false,
                    attached = playerstats.ref,
                    texture = texture,
                    glow = glow
                })
            end

        elseif playerstats.stamina < max_stamina then
            playerstats.stamina = playerstats.stamina + stamina_regen
            if playerstats.stamina > max_stamina then playerstats.stamina = max_stamina end
        end

        if playerstats.stamina ~= playerstats.previous_stamina then
            playerstats.previous_stamina = playerstats.stamina
            if hudbars_enabled then hb.change_hudbar(playerstats.ref, "stamina", playerstats.stamina) end
        end

    end
    sprint_timer = 0
end)