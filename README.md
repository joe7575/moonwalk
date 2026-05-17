# Moon Walk Mod [moonwalk]

A Luanti (formerly Minetest) mod that allows players to experience moon-like gravity with reduced gravitational force.

## Compatibility

✅ **Luanti 5.x compatible** - Uses only stable, non-deprecated APIs from the current Luanti engine.

## Features

- **Low Gravity Zone**: Activate a 50-block radius area with 16% normal gravity (moon-like conditions)
- **Glowing Block**: The Moon Walk block emits light (light level 10) for easy visibility in darkness
- **Physics Locking System**: Uses the Player Physics Design Pattern to prevent conflicts with other mods
- **Automatic Timeout**: Moon Walk effect automatically disables after 2 minutes
- **Boundary Control**: Players are kept within the effect radius and returned to the last valid position if they try to leave

## Installation

1. Download or clone this repository
2. Place the `moonwalk` folder in your Luanti `mods` directory
3. Enable the mod in your world configuration

## Crafting Recipe

```
Steel Ingot    Mese Crystal    Steel Ingot
Copper Ingot   Mese Block      Copper Ingot
Steel Ingot    Mese Crystal    Steel Ingot
```

## Usage

1. **Craft** the Moon Walk block using the recipe above
2. **Place** the Moon Walk block anywhere in your world
3. **Right-click** the block to activate moon gravity
   - Your gravity will be reduced to 16% of normal
   - You can jump much higher and fall much slower
   - The block will display "Moon Walk busy" while active
4. **Right-click again** to deactivate and return to normal gravity
   - You will be teleported 1.5 blocks above the Moon Walk block
   - The block will display "Moon Walk free"

**Note:** The effect automatically deactivates after 2 minutes (120 seconds) for safety.

## Technical Details

### Player Physics Locking Pattern

This mod implements the [Player Physics Design Pattern](https://github.com/joe7575/techage_modpack/blob/master/player_physics_design_pattern.md) by joe7575 to prevent conflicts with other mods that modify player physics.

**How it works:**
- Before modifying player physics, the mod checks if `player_physics_locked` is set to 0
- If available, it sets the lock to 1, saves the current gravity value, and applies moon gravity
- When deactivated, it restores the original gravity value and releases the lock
- If another mod has the lock, players receive the message: "Moon Walk is blocked by another mod!"

### Event Handlers

The mod automatically restores normal physics when:
- A player joins the game (`on_joinplayer`)
- A player respawns (`on_respawnplayer`)
- A player leaves the game (`on_leaveplayer`)
- A player dies (`on_dieplayer`)

### Configuration

You can modify these values in `init.lua`:
- `TIMEOUT = 120` - Duration in seconds (default: 2 minutes)
- `RADIUS = 50` - Effect radius in blocks (default: 50 blocks)

## Version History

- **v0.02** (2026-05-17)
  - Updated to modern Luanti API
  - Added Player Physics Locking Pattern
  - Added glowing effect (light_source = 10)
  - Added crafting recipe
  - Fixed deprecated function calls
  - Improved LBM efficiency

- **v0.01** (2017-11-25)
  - Initial release

## License

Code: LGPLv2.1+
Textures: CC BY-SA 3.0

## Author

Copyright (C) 2017-2026 Joachim Stolberg

## Credits

- Player Physics Design Pattern by [joe7575](https://github.com/joe7575/techage_modpack)
