# Implementation Tasks: Arcade FPS Farming Game

## Phase 1: Project Setup and Core Systems

### 1.1 Project Initialization
- [x] 1.1.1 Create new Godot 4.x project with proper directory structure
- [x] 1.1.2 Configure project settings (display, input maps, physics layers)
- [x] 1.1.3 Set up input action mappings (WASD, mouse, fire, dash, interact)
- [x] 1.1.4 Configure collision layers (LAYER_PLAYER=1, LAYER_ENEMY=2, LAYER_PROJECTILE=4, LAYER_ENVIRONMENT=8, LAYER_INTERACTIVE=16)
- [x] 1.1.5 Install and configure GdUnit4 testing framework

**Validates**: Requirements 15.1, 15.3, 15.4

### 1.2 GameManager Singleton
- [x] 1.2.1 Create GameManager autoload script with state variables (player_health, player_max_health, inventory, active_buffs, permanent_upgrades)
- [x] 1.2.2 Implement buff management methods (apply_buff, clear_temporary_buffs)
- [x] 1.2.3 Implement scene transition methods (transition_to_combat, transition_to_farm)
- [x] 1.2.4 Add signals for state changes (health_changed, buff_applied, buff_cleared, upgrade_unlocked)
- [x] 1.2.5 Write unit tests for GameManager state management

**Validates**: Requirements 7.5, 11.2

### 1.3 Data Models
- [x] 1.3.1 Create Buff resource class with BuffType enum and apply_to_player method
- [x] 1.3.2 Create CropData resource class with growth parameters and visual generation data
- [x] 1.3.3 Create SaveData resource class with to_dict and from_dict methods
- [x] 1.3.4 Write unit tests for data model serialization

**Validates**: Requirements 5.1, 5.2, 5.3, 16.3

### 1.4 ProceduralArtGenerator
- [x] 1.4.1 Create ProceduralArtGenerator class with color palette constants (FARM_PALETTE, COMBAT_PALETTE)
- [x] 1.4.2 Implement _create_shape_from_primitives helper (rectangles, circles, triangles)
- [x] 1.4.3 Implement generate_tileset method with seeded RNG
- [x] 1.4.4 Implement generate_crop_sprite method with growth stages
- [x] 1.4.5 Implement generate_enemy_sprite method with enemy type variants
- [x] 1.4.6 Implement generate_weapon_sprite method
- [x] 1.4.7 Implement generate_ui_element method
- [x] 1.4.8 Write property tests for generation determinism (same seed = same output)

**Validates**: Requirements 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7, 12.8, 12.9

### 1.5 Basic Scene Structure
- [x] 1.5.1 Create Farm_Hub scene with basic 3D environment
- [x] 1.5.2 Create Combat_Zone scene with basic 3D arena
- [x] 1.5.3 Apply procedurally generated tilesets to both scenes
- [x] 1.5.4 Set up scene lighting and camera positioning
- [x] 1.5.5 Implement SceneTransitionManager in GameManager

**Validates**: Requirements 11.1, 13.1, 13.2

## Phase 2: Player Movement and Camera

### 2.1 PlayerController Base
- [x] 2.1.1 Create PlayerController class extending CharacterBody3D
- [x] 2.1.2 Add Camera3D child node with proper positioning
- [x] 2.1.3 Implement mouse look with sensitivity control
- [x] 2.1.4 Set up collision shape and collision layer/mask
- [x] 2.1.5 Add died and dash_performed signals

**Validates**: Requirements 1.2, 1.5

### 2.2 Movement Implementation
- [x] 2.2.1 Implement _physics_process for WASD movement with immediate acceleration
- [x] 2.2.2 Implement dash mechanic with dash_speed, dash_duration, and dash_cooldown
- [x] 2.2.3 Add dash cooldown timer management
- [x] 2.2.4 Ensure consistent move_speed across both scenes
- [x] 2.2.5 Write property tests for movement responsiveness (Property 1)

**Validates**: Requirements 1.1, 1.3, 1.4

### 2.3 Player Health System
- [x] 2.3.1 Implement take_damage method with health reduction
- [x] 2.3.2 Implement death detection (health <= 0)
- [x] 2.3.3 Emit died signal and trigger death state
- [x] 2.3.4 Connect health changes to GameManager signals
- [x] 2.3.5 Write property tests for health bounds and death mechanics (Property 9)

**Validates**: Requirements 9.1, 9.2, 9.3

## Phase 3: Combat System

### 3.1 WeaponSystem Base
- [x] 3.1.1 Create WeaponSystem class extending Node3D
- [x] 3.1.2 Define WeaponType enum (PISTOL, SHOTGUN, PLANT_WEAPON)
- [x] 3.1.3 Implement ammo dictionary and fire_rate dictionary
- [x] 3.1.4 Add weapon_fired, weapon_switched, and ammo_changed signals
- [x] 3.1.5 Attach WeaponSystem to PlayerController

**Validates**: Requirements 2.1, 2.6

### 3.2 Weapon Firing Mechanics
- [x] 3.2.1 Implement fire_weapon method with fire rate limiting
- [x] 3.2.2 Implement Pistol firing (infinite ammo, single shot)
- [x] 3.2.3 Implement Shotgun firing (ammo consumption, spread projectiles)
- [x] 3.2.4 Create projectile scene with Area3D collision
- [x] 3.2.5 Implement projectile movement and lifetime
- [x] 3.2.6 Write property tests for weapon firing consistency (Property 2)

**Validates**: Requirements 2.1, 2.2, 2.4, 2.5

### 3.3 Weapon Switching and Mods
- [x] 3.3.1 Implement switch_weapon method with instant switching
- [x] 3.3.2 Implement add_ammo method for ammo pickups/buffs
- [x] 3.3.3 Implement apply_weapon_mod method for temporary modifications
- [x] 3.3.4 Update weapon visuals on switch using ProceduralArtGenerator
- [x] 3.3.5 Write unit tests for weapon switching

**Validates**: Requirements 2.6, 5.3

### 3.4 CollisionManager
- [x] 3.4.1 Create CollisionManager singleton with layer constants
- [x] 3.4.2 Implement setup_player_collision method
- [x] 3.4.3 Implement setup_enemy_collision method
- [x] 3.4.4 Implement setup_projectile_collision method
- [x] 3.4.5 Implement check_line_of_sight method for ranged enemies
- [x] 3.4.6 Write property tests for collision detection correctness (Property 12)

**Validates**: Requirements 1.5, 2.3, 3.5

## Phase 4: Enemy System

### 4.1 EnemyBase Class
- [x] 4.1.1 Create EnemyBase class extending CharacterBody3D
- [x] 4.1.2 Implement health system (max_health, current_health)
- [x] 4.1.3 Implement take_damage method with visual feedback
- [x] 4.1.4 Implement die method with loot spawning
- [x] 4.1.5 Add died and attacked_player signals
- [x] 4.1.6 Apply procedurally generated enemy sprites

**Validates**: Requirements 3.3, 3.4

### 4.2 Enemy Variants
- [x] 4.2.1 Create MeleeCharger class with charge_speed and direct movement AI
- [x] 4.2.2 Create RangedShooter class with projectile firing and line-of-sight checks
- [x] 4.2.3 Create TankEnemy class with armor and slow movement
- [x] 4.2.4 Implement collision damage for all enemy types
- [x] 4.2.5 Write property tests for enemy behavior determinism (Property 3)

**Validates**: Requirements 3.1, 3.2, 3.3, 3.5

### 4.3 FeedbackSystem
- [x] 4.3.1 Create FeedbackSystem singleton
- [x] 4.3.2 Implement spawn_damage_number for damage display
- [x] 4.3.3 Implement spawn_hit_effect for projectile impacts
- [x] 4.3.4 Implement create_death_explosion for enemy deaths
- [x] 4.3.5 Implement flash_screen and shake_camera for player damage
- [x] 4.3.6 Generate all effects procedurally using shape primitives

**Validates**: Requirements 2.3, 9.2, 12.8

## Phase 5: Arena and Enemy Management

### 5.1 ArenaGenerator
- [x] 5.1.1 Create ArenaGenerator class with arena_templates array
- [x] 5.1.2 Implement generate_arena method with seeded layout generation
- [x] 5.1.3 Implement spawn_wave method with enemy placement
- [x] 5.1.4 Implement get_random_spawn_point method
- [x] 5.1.5 Implement is_wave_complete method
- [x] 5.1.6 Add wave_completed and arena_completed signals
- [x] 5.1.7 Generate arena boundaries and cover elements procedurally

**Validates**: Requirements 8.1, 8.2, 8.3, 8.5

### 5.2 Wave Management
- [x] 5.2.1 Implement wave progression logic (spawn next wave when current completes)
- [x] 5.2.2 Implement run completion detection (all waves cleared)
- [x] 5.2.3 Implement loot collection during combat
- [x] 5.2.4 Connect wave completion to scene transition
- [x] 5.2.5 Write property tests for wave completion logic (Property 8)

**Validates**: Requirements 8.4

## Phase 6: Farming System

### 6.1 Plot and FarmGrid
- [x] 6.1.1 Create Plot class with PlotState enum (EMPTY, GROWING, HARVESTABLE)
- [x] 6.1.2 Implement plant method with crop_type assignment
- [x] 6.1.3 Implement update_growth method with dual-mode support (time/runs)
- [x] 6.1.4 Implement harvest method returning crop resources
- [x] 6.1.5 Implement get_visual_stage for sprite generation
- [x] 6.1.6 Add growth_completed signal

**Validates**: Requirements 4.2, 4.3, 4.4, 4.5

### 6.2 FarmGrid Management
- [x] 6.2.1 Create FarmGrid class with grid_size and plot_size configuration
- [x] 6.2.2 Instantiate 6-12 Plot instances in grid layout
- [x] 6.2.3 Implement get_plot_at_position for player interaction
- [x] 6.2.4 Implement plant_crop method with seed inventory check
- [x] 6.2.5 Implement harvest_crop method with inventory addition
- [x] 6.2.6 Implement update_crop_growth called each frame/run
- [x] 6.2.7 Add crop_planted and crop_harvested signals
- [x] 6.2.8 Write property tests for farming state transitions (Property 4)

**Validates**: Requirements 4.1, 4.2, 4.3, 4.4

### 6.3 Crop Visuals and Interaction
- [x] 6.3.1 Create CropData resources for 3-5 crop types (health, ammo, weapon mod)
- [x] 6.3.2 Generate crop sprites for all growth stages using ProceduralArtGenerator
- [x] 6.3.3 Implement interaction prompt display when player near plot
- [x] 6.3.4 Implement player interaction input handling for planting/harvesting
- [x] 6.3.5 Update plot visuals based on growth stage

**Validates**: Requirements 4.5, 12.5

## Phase 7: Buff and Resource System

### 7.1 Buff Application
- [ ] 7.1.1 Implement Buff.apply_to_player for health buffs (max health increase)
- [ ] 7.1.2 Implement Buff.apply_to_player for ammo buffs (bonus ammunition)
- [ ] 7.1.3 Implement Buff.apply_to_player for weapon mod buffs
- [ ] 7.1.4 Add buff consumption UI in Farm_Hub
- [ ] 7.1.5 Connect crop harvesting to buff availability

**Validates**: Requirements 5.1, 5.2, 5.3

### 7.2 Buff Lifecycle
- [ ] 7.2.1 Apply all active buffs when transitioning to Combat_Zone
- [ ] 7.2.2 Clear all temporary buffs when returning to Farm_Hub
- [ ] 7.2.3 Implement buff duration tracking (number of runs)
- [ ] 7.2.4 Display active buffs in combat UI
- [ ] 7.2.5 Write property tests for buff application and clearing (Property 5)

**Validates**: Requirements 5.4, 5.5, 7.3, 7.4

## Phase 8: Progression System

### 8.1 ProgressionManager
- [ ] 8.1.1 Create ProgressionManager class with UPGRADES dictionary
- [ ] 8.1.2 Implement can_afford_upgrade method checking loot resources
- [ ] 8.1.3 Implement purchase_upgrade method with cost deduction
- [ ] 8.1.4 Implement get_total_stat_bonus for cumulative upgrade effects
- [ ] 8.1.5 Add save_failed and save_succeeded signals
- [ ] 8.1.6 Integrate ProgressionManager into GameManager

**Validates**: Requirements 6.1, 6.3

### 8.2 Permanent Upgrades
- [ ] 8.2.1 Define upgrade data for max_health increase
- [ ] 8.2.2 Define upgrade data for dash_cooldown reduction
- [ ] 8.2.3 Define upgrade data for fire_rate increase
- [ ] 8.2.4 Apply upgrade effects immediately upon unlock
- [ ] 8.2.5 Ensure upgrades persist across runs and sessions
- [ ] 8.2.6 Write property tests for progression persistence (Property 6)

**Validates**: Requirements 6.2, 6.3, 6.4

### 8.3 Save System
- [ ] 8.3.1 Implement save_to_file method using Godot's user:// path
- [ ] 8.3.2 Implement load_from_file method with error handling
- [ ] 8.3.3 Implement _attempt_save_with_retry with exponential backoff
- [ ] 8.3.4 Implement _cache_failed_save for recovery
- [ ] 8.3.5 Save on upgrade unlock and scene transitions
- [ ] 8.3.6 Load on game start
- [ ] 8.3.7 Write integration tests for save/load cycles

**Validates**: Requirements 16.1, 16.2, 16.3, 16.4, 16.5

## Phase 9: Scene Transitions

### 9.1 Transition Logic
- [ ] 9.1.1 Create portal/entrance object in Farm_Hub scene
- [ ] 9.1.2 Implement interaction to trigger transition_to_combat
- [ ] 9.1.3 Load Combat_Zone scene and apply active buffs
- [ ] 9.1.4 Implement run completion transition back to Farm_Hub
- [ ] 9.1.5 Implement death transition back to Farm_Hub (no loot)
- [ ] 9.1.6 Clear temporary buffs on return to Farm_Hub

**Validates**: Requirements 7.1, 7.2, 7.3, 7.4

### 9.2 State Preservation
- [ ] 9.2.1 Preserve inventory across all transitions
- [ ] 9.2.2 Preserve permanent upgrades across all transitions
- [ ] 9.2.3 Reset player health appropriately based on transition type
- [ ] 9.2.4 Preserve crop growth states during combat runs
- [ ] 9.2.5 Write property tests for scene transition state preservation (Property 7)

**Validates**: Requirements 7.5, 9.4

## Phase 10: User Interface

### 10.1 UIManager Structure
- [ ] 10.1.1 Create UIManager class extending CanvasLayer
- [ ] 10.1.2 Create CombatUI subscene with health bar, ammo label, buff container, weapon indicator
- [ ] 10.1.3 Create FarmUI subscene with inventory panel, upgrade panel, crop status panel
- [ ] 10.1.4 Create InteractionPrompt subscene with label and background
- [ ] 10.1.5 Implement show_combat_ui and show_farm_ui methods

**Validates**: Requirements 10.1, 10.2

### 10.2 Combat UI
- [ ] 10.2.1 Implement update_health_display with visual health bar
- [ ] 10.2.2 Implement update_ammo_display showing current ammo count
- [ ] 10.2.3 Implement update_buff_display with buff icons
- [ ] 10.2.4 Implement show_weapon_switch with weapon indicator
- [ ] 10.2.5 Generate all UI elements procedurally using ProceduralArtGenerator
- [ ] 10.2.6 Use high-contrast colors for readability

**Validates**: Requirements 10.1, 10.4, 10.5, 12.8

### 10.3 Farm UI
- [ ] 10.3.1 Implement update_inventory showing resource counts
- [ ] 10.3.2 Implement populate_upgrades with available upgrades list
- [ ] 10.3.3 Implement highlight_affordable_upgrades based on currency
- [ ] 10.3.4 Implement update_crop_status showing growth progress
- [ ] 10.3.5 Add upgrade purchase buttons with signals

**Validates**: Requirements 10.2, 10.5

### 10.4 Interaction Prompts
- [ ] 10.4.1 Implement show_prompt with world-to-screen position conversion
- [ ] 10.4.2 Implement hide_prompt when player moves away
- [ ] 10.4.3 Display prompts for plots (plant/harvest)
- [ ] 10.4.4 Display prompts for portal (enter combat)
- [ ] 10.4.5 Display prompts for NPCs (future expansion)
- [ ] 10.4.6 Write property tests for UI information accuracy (Property 11)

**Validates**: Requirements 10.3

## Phase 11: Visual Atmosphere

### 11.1 Farm Hub Atmosphere
- [ ] 11.1.1 Apply bright, warm FARM_PALETTE to all Farm_Hub visuals
- [ ] 11.1.2 Generate cozy tileset with organic shapes
- [ ] 11.1.3 Arrange environment elements for welcoming layout
- [ ] 11.1.4 Add ambient lighting with warm tones
- [ ] 11.1.5 Ensure visual consistency through generation rules

**Validates**: Requirements 13.1, 13.3, 13.4

### 11.2 Combat Zone Atmosphere
- [ ] 11.2.1 Apply dark, aggressive COMBAT_PALETTE to all Combat_Zone visuals
- [ ] 11.2.2 Generate tense tileset with angular shapes
- [ ] 11.2.3 Arrange environment elements for combat-focused layout
- [ ] 11.2.4 Add dramatic lighting with harsh shadows
- [ ] 11.2.5 Ensure visual consistency through generation rules

**Validates**: Requirements 13.2, 13.3, 13.5

### 11.3 Palette Swaps and Variants
- [ ] 11.3.1 Implement _apply_palette_swap in ProceduralArtGenerator
- [ ] 11.3.2 Create visual variants for enemies using palette swaps
- [ ] 11.3.3 Create visual variants for crops using palette swaps
- [ ] 11.3.4 Test palette consistency across all generated content

**Validates**: Requirements 12.10

## Phase 12: Session Pacing and Balance

### 12.1 Combat Pacing
- [ ] 12.1.1 Balance enemy health and damage for 5-10 minute combat sessions
- [ ] 12.1.2 Balance wave counts and enemy spawns per wave
- [ ] 12.1.3 Tune weapon damage and fire rates for satisfying combat
- [ ] 12.1.4 Test combat session length with playtesting

**Validates**: Requirements 14.1

### 12.2 Farming Pacing
- [ ] 12.2.1 Set crop growth timers for 2-5 minute farming sessions
- [ ] 12.2.2 Balance seed costs and buff values
- [ ] 12.2.3 Tune upgrade costs for meaningful progression
- [ ] 12.2.4 Test farming session length with playtesting

**Validates**: Requirements 14.2, 14.5

### 12.3 Save and Quit
- [ ] 12.3.1 Implement save-on-quit in Farm_Hub
- [ ] 12.3.2 Prevent quitting during combat (or auto-save state)
- [ ] 12.3.3 Display progression feedback after completing full loop
- [ ] 12.3.4 Test save/load at various game states

**Validates**: Requirements 14.3, 14.4

## Phase 13: Performance and Polish

### 13.1 Performance Optimization
- [ ] 13.1.1 Profile frame rate during combat with 10+ enemies
- [ ] 13.1.2 Optimize procedural generation (cache generated sprites)
- [ ] 13.1.3 Optimize collision detection and physics
- [ ] 13.1.4 Ensure stable 60 FPS during intense combat
- [ ] 13.1.5 Test on target hardware specifications

**Validates**: Requirements 15.5

### 13.2 Code Organization
- [ ] 13.2.1 Refactor scripts for single responsibility principle
- [ ] 13.2.2 Add code documentation and comments
- [ ] 13.2.3 Organize scripts into logical directory structure
- [ ] 13.2.4 Review and clean up unused code

**Validates**: Requirements 15.2

### 13.3 Bug Fixes and Edge Cases
- [ ] 13.3.1 Test and fix edge cases in combat (player stuck, enemies stuck)
- [ ] 13.3.2 Test and fix edge cases in farming (invalid plot states)
- [ ] 13.3.3 Test and fix edge cases in UI (overlapping prompts, missing updates)
- [ ] 13.3.4 Test and fix save/load edge cases (corrupted saves, missing data)

**Validates**: All requirements

## Phase 14: Export and Distribution

### 14.1 Export Configuration
- [ ] 14.1.1 Configure Windows export template with embedded PCK mode
- [ ] 14.1.2 Set architecture to x86_64
- [ ] 14.1.3 Enable ZSTD compression for size optimization
- [ ] 14.1.4 Exclude unused engine modules (Movie Maker, Multiplayer, etc.)
- [ ] 14.1.5 Test export settings produce single .exe file

**Validates**: Requirements 17.1, 17.2, 17.5

### 14.2 Size Optimization
- [ ] 14.2.1 Verify all visuals are generated at runtime (no texture assets)
- [ ] 14.2.2 Remove or exclude audio if not implemented
- [ ] 14.2.3 Minimize script file sizes
- [ ] 14.2.4 Test final executable size is under 50MB
- [ ] 14.2.5 Document size optimization techniques used

**Validates**: Requirements 17.3, 17.6

### 14.3 Portability Testing
- [ ] 14.3.1 Test executable runs from various directory locations
- [ ] 14.3.2 Test executable runs without installation
- [ ] 14.3.3 Test executable runs without external dependencies
- [ ] 14.3.4 Verify save data uses user:// path correctly
- [ ] 14.3.5 Test on clean Windows installation

**Validates**: Requirements 17.4, 17.7

## Phase 15: Testing and Validation

### 15.1 Unit Test Coverage
- [ ] 15.1.1 Ensure all core classes have unit tests
- [ ] 15.1.2 Achieve >80% code coverage for critical systems
- [ ] 15.1.3 Run all unit tests and fix failures
- [ ] 15.1.4 Document test coverage report

**Validates**: All requirements

### 15.2 Property-Based Test Execution
- [ ] 15.2.1 Run Property 1 tests (Player Movement Responsiveness)
- [ ] 15.2.2 Run Property 2 tests (Weapon Firing Consistency)
- [ ] 15.2.3 Run Property 3 tests (Enemy Behavior Determinism)
- [ ] 15.2.4 Run Property 4 tests (Farming State Transitions)
- [ ] 15.2.5 Run Property 5 tests (Buff Application and Clearing)
- [ ] 15.2.6 Run Property 6 tests (Progression Persistence)
- [ ] 15.2.7 Run Property 7 tests (Scene Transition State Preservation)
- [ ] 15.2.8 Run Property 8 tests (Combat Zone Wave Completion)
- [ ] 15.2.9 Run Property 9 tests (Health and Death Mechanics)
- [ ] 15.2.10 Run Property 10 tests (Procedural Generation Determinism)
- [ ] 15.2.11 Run Property 11 tests (UI Information Accuracy)
- [ ] 15.2.12 Run Property 12 tests (Collision Detection Correctness)

**Validates**: All correctness properties

### 15.3 Integration Testing
- [ ] 15.3.1 Test complete game loop (farm → combat → return)
- [ ] 15.3.2 Test progression over multiple sessions
- [ ] 15.3.3 Test all upgrade paths
- [ ] 15.3.4 Test all crop types and buffs
- [ ] 15.3.5 Test death and loot loss scenarios

**Validates**: All requirements

### 15.4 Playtesting and Feedback
- [ ] 15.4.1 Conduct playtesting sessions for combat feel
- [ ] 15.4.2 Conduct playtesting sessions for farming engagement
- [ ] 15.4.3 Gather feedback on session length and pacing
- [ ] 15.4.4 Gather feedback on visual clarity and atmosphere
- [ ] 15.4.5 Iterate based on feedback

**Validates**: Requirements 14.1, 14.2, 14.5

## Phase 16: Documentation and Delivery

### 16.1 User Documentation
- [ ]* 16.1.1 Write README with game overview and controls
- [ ]* 16.1.2 Document system requirements
- [ ]* 16.1.3 Create quick start guide
- [ ]* 16.1.4 Document known issues and limitations

### 16.2 Developer Documentation
- [ ]* 16.2.1 Document architecture and design decisions
- [ ]* 16.2.2 Document procedural generation algorithms
- [ ]* 16.2.3 Document testing approach and coverage
- [ ]* 16.2.4 Create contribution guidelines for future development

### 16.3 Final Delivery
- [ ] 16.3.1 Create final build with all features complete
- [ ] 16.3.2 Run full test suite and verify all tests pass
- [ ] 16.3.3 Package executable with documentation
- [ ] 16.3.4 Create release notes
- [ ] 16.3.5 Deliver final product

**Validates**: All requirements

---

## Notes

- Tasks marked with `*` are optional enhancements
- Each task should be completed and tested before moving to the next
- Property-based tests should run 100+ iterations per property
- All visual content must be generated procedurally at runtime
- Target executable size: under 50MB
- Target session length: 10-15 minutes per complete loop
- Testing framework: GdUnit4 for Godot 4.x
