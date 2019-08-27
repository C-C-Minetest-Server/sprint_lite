# sprint_lite
Configurable and easy-to use sprinting mod that supports hudbars and hbhunger. Designed after [hbsprint](https://github.com/minetest-mods/hbsprint/) by Tacotexmex.  
hbsprint is great, however there's a few bugs, so I decided to write my own "vision" of this mod.

## Requirements

- Minetest 5.0.0 (Wasn't tested on previous versions but might work)
- [player_monoids](https://github.com/minetest-mods/player_monoids)
- [hudbars](https://repo.or.cz/w/minetest_hudbars.git) (optional, but strongly recommended. You won't have a hud indicator without it)
- [hbhunger](https://repo.or.cz/w/minetest_hbhunger.git) (optional)

## How to use
Hold "special" key to sprint (by default it's assigned to E).  
While sprinting, your stamina will decrease, until it hits 0 and you'll no longer be able to sprint.  
If your stamina is lower than a threshold (specified in settingtypes), then you can't start sprinting.  

## Settingtypes
Mod can be configured by changing settings in Settings->All Settings->Mods->sprint_lite, or by putting them directly to your minetest.conf:

```
sprint_lite_max_stamina = 20
Maximum stamina of every player

sprint_lite_speed_multiplier = 1.75
Speed multiplier when sprinting

sprint_lite_jump_multiplier = 1.25
Jump multiplier when sprinting

sprint_lite_step_interval = 0.15
Server step interval in seconds, when performing sprint-related checks

sprint_lite_drain_hunger = true
Sprinting drains hunger, if hbhunger is installed

sprint_lite_hunger_amount = 0.03
Amount of hunger to drain per step

sprint_lite_stamina_drain = 0.5
Amount of stamina to drain per step

sprint_lite_stamina_regen = 0.1
Amount of stamina to regenerate per step, when not running

sprint_lite_stamina_threshold = 8
Amount of stamina below which you can't start running

sprint_lite_spawn_particles = true
Spawn particles under sprinting players
```

## Integration with other mods
Mod provides a public list, sprint_lite.player_info, which holds information of every connected player and their sprint-related variables, as key-value pairs, where key is player's name:
```
{ref, --Reference to the player object
stamina, --float, actual stamina of the player. Can be altered freely.
previous_stamina, --float, internal field for hudbars updating. Not supposed to be changed.
sprinting, --bool, status variable, if player is sprinting or not. Not supposed to be changed.
grounded, --bool, variable, indicating if player is standing on the ground. Not supposed to be changed.
}
```

## License
All code is licensed under GPLv3 [link to the license](https://www.gnu.org/licenses/gpl-3.0.en.html)  
All resources are licensed under CC BY 4.0 [link to the license](https://creativecommons.org/licenses/by/4.0/legalcode)  
