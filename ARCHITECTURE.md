# Architecture Overview

## High-Level Design

The Arcade FPS Farming Game follows a modular, scene-based architecture with autoload singletons managing persistent state and cross-scene functionality.

## Core Architecture Principles

1. **Scene-Based Organization**: The game is divided into distinct scenes (Farm Hub, Combat Zone) that are loaded and unloaded as needed.

2. **Autoload Singletons**: Persistent managers (GameManager, CollisionManager, FeedbackSystem) handle state management and cross-cutting concerns.

3. **Signal-Based Communication**: Components communicate through Godot's signal system to maintain loose coupling.

4. **Procedural Generation**: All visual content is generated at runtime using deterministic seeded algorithms.

5. **Resource-Based Data**: Game data (buffs, crops, save data) uses Godot's Resource system for serialization and type safety.

## System Components

### GameManager (Autoload)
- **Responsibility**: Central state management and coordination
- **Key Data**: Player health, inventory, active buffs, permanent upgrades
- **Key Methods**: apply_buff(), clear_temporary_buffs(), transition_to_combat(), save_game()

### ProceduralArtGenerator
- **Responsibility**: Generate all visual content at runtime
- **Key Methods**: generate_tileset(), generate_crop_sprite(), generate_enemy_sprite()
- **Design**: Uses seeded RNG for deterministic output

### PlayerController
- **Responsibility**: First-person movement and camera control
- **Key Features**: WASD movement, mouse look, dash mechanic, collision detection

### WeaponSystem
- **Responsibility**: Weapon firing, switching, and ammunition management
- **Weapons**: Pistol (infinite ammo), Shotgun (limited ammo), Plant Weapon (special)

### EnemyBase (and variants)
- **Responsibility**: Enemy AI and behavior
- **Variants**: MeleeCharger, RangedShooter, TankEnemy
- **Design**: Base class with overridable behavior methods

### FarmGrid & Plot
- **Responsibility**: Farming system management
- **Key Features**: Grid-based plot system, crop growth (time/run-based), harvesting

### ArenaGenerator
- **Responsibility**: Procedural combat arena generation
- **Key Features**: Template-based layouts, wave spawning, enemy placement

### ProgressionManager
- **Responsibility**: Permanent upgrades and save/load
- **Key Features**: Upgrade unlocking, stat bonuses, persistent storage

### UIManager
- **Responsibility**: User interface management
- **Components**: CombatUI, FarmUI, InteractionPrompt
- **Design**: Context-aware UI switching between scenes

## Data Flow

### Scene Transition Flow
```
Farm Hub → Player interacts with portal
         → GameManager.transition_to_combat()
         → Apply active buffs
         → Load Combat Zone scene
         → Combat gameplay
         → Run complete or player dies
         → GameManager.transition_to_farm()
         → Clear temporary buffs
         → Load Farm Hub scene
```

### Buff Application Flow
```
Harvest crop → Add crop to inventory
            → Player consumes crop
            → Create Buff resource
            → GameManager.apply_buff()
            → Buff stored in active_buffs
            → On combat transition: Buff.apply_to_player()
            → On farm return: GameManager.clear_temporary_buffs()
```

### Save/Load Flow
```
Game event (upgrade unlock, scene transition)
  → ProgressionManager.save_to_file()
  → Create SaveData resource
  → Serialize to JSON
  → Write to user:// directory
  → On failure: Retry with exponential backoff
  → On success: Emit save_succeeded signal

Game start
  → ProgressionManager.load_from_file()
  → Read from user:// directory
  → Deserialize JSON to SaveData
  → Apply loaded state to GameManager
```

## Collision Layer Architecture

The game uses Godot's collision layers for efficient physics filtering:

- **Layer 1 (Player)**: Player character
  - Collides with: Environment, Enemy, Interactive
  
- **Layer 2 (Enemy)**: Enemy entities
  - Collides with: Environment, Player, Projectile
  - Does NOT collide with: Other enemies (prevents clustering)
  
- **Layer 3 (Projectile)**: Bullets and projectiles
  - Collides with: Environment, Enemy
  
- **Layer 4 (Environment)**: Static world geometry
  - Collides with: Everything
  
- **Layer 5 (Interactive)**: Interactable objects
  - Collides with: Player (for interaction detection)

## Testing Strategy

### Unit Tests
- Test individual classes in isolation
- Mock dependencies where necessary
- Focus on core logic and edge cases

### Integration Tests
- Test system interactions (scene transitions, save/load)
- Verify state preservation across scenes
- Test complete gameplay loops

### Property-Based Tests
- Verify universal properties hold across all inputs
- Generate random input sequences
- Test 100+ iterations per property
- Examples: Movement responsiveness, weapon consistency, farming state transitions

## Performance Considerations

1. **Procedural Generation Caching**: Generated sprites are cached to avoid regeneration
2. **Collision Optimization**: Proper layer/mask configuration reduces unnecessary checks
3. **Enemy Pooling**: Reuse enemy instances rather than constant instantiation
4. **UI Updates**: Only update UI elements when values change (signal-based)

## Extension Points

The architecture is designed for easy extension:

- **New Enemy Types**: Extend EnemyBase class
- **New Weapons**: Add to WeaponType enum and implement firing logic
- **New Crops**: Create CropData resources with associated buffs
- **New Upgrades**: Add to ProgressionManager.UPGRADES dictionary
- **New UI Elements**: Extend UIManager with new components

## Design Decisions

### Why Autoload Singletons?
Godot's autoload system provides persistent state across scene transitions without manual serialization. This is ideal for GameManager, which needs to maintain player state throughout the game.

### Why Signal-Based Communication?
Signals maintain loose coupling between systems. For example, WeaponSystem emits signals that UIManager listens to, without either component knowing about the other's implementation.

### Why Procedural Art?
Generating visuals at runtime eliminates asset files, reducing executable size and ensuring visual consistency through code. Seeded RNG makes generation deterministic for testing.

### Why Resource-Based Data?
Godot's Resource class provides built-in serialization, inspector editing, and type safety. This is perfect for buffs, crops, and save data that need to be saved/loaded.

## File Naming Conventions

- **Scripts**: snake_case (e.g., `player_controller.gd`)
- **Scenes**: snake_case (e.g., `farm_hub.tscn`)
- **Resources**: snake_case (e.g., `health_buff.tres`)
- **Classes**: PascalCase (e.g., `class_name PlayerController`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `const LAYER_PLAYER = 1`)
- **Variables**: snake_case (e.g., `var current_health: int`)
- **Methods**: snake_case (e.g., `func take_damage()`)

## Code Organization Guidelines

1. **Single Responsibility**: Each script should have one clear purpose
2. **Composition Over Inheritance**: Prefer composition and signals over deep inheritance
3. **Type Hints**: Always use type hints for parameters and return values
4. **Documentation**: Document public methods and complex logic
5. **Signals First**: Use signals for inter-component communication
6. **Avoid Circular Dependencies**: Use signals and autoloads to break cycles
