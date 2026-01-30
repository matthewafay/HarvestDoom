# Arcade FPS Farming Game

A rapid prototype combining Harvest Moon farming gameplay with Doom-style FPS combat. Built entirely with procedurally generated graphics - no external art assets required.

## What Is This?

An experimental game testing whether cozy farming mechanics can blend with fast-paced shooter action. Plant crops, harvest buffs, then blast through enemy waves in procedurally generated arenas.

## Requirements

- **Godot 4.6** or later (standard version, not .NET/Mono required)
- Download from: https://godotengine.org/download

## How to Run

1. Download and install Godot 4.6+
2. Clone this repository
3. Open the project in Godot (open `project.godot`)
4. Press F5 or click the Play button

## Features

- **Farming Phase**: Plant and harvest crops on a grid-based farm
- **Combat Phase**: First-person shooter combat with waves of enemies
- **Procedural Art**: All visuals generated at runtime - no sprite sheets or textures
- **Buff System**: Crops provide temporary combat bonuses
- **Save/Load**: Progress persists between sessions

## Controls

| Key | Action |
|-----|--------|
| WASD | Move |
| Mouse | Look |
| Space | Jump |
| Shift | Dash |
| E | Interact / Plant / Harvest |
| Left Click | Shoot |
| 1, 2 | Switch Weapons |
| ESC | Pause Menu |

## How to Play

1. Start in the farm hub
2. Walk to brown plots and press E to plant seeds
3. Wait for crops to grow (they turn golden when ready)
4. Press E to harvest
5. Walk into the glowing red portal to enter combat
6. Survive enemy waves
7. Return to farm, repeat

## Tech Stack

- Godot 4.6
- GDScript
- GdUnit4 for testing

## Status

This is a rough prototype / proof of concept. Expect bugs and placeholder everything.

## License

MIT
