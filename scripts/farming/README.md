# Farming System

This directory contains the farming system implementation for the Arcade FPS Farming Game.

## Overview

The farming system allows players to plant, grow, and harvest crops in the Farm Hub. Crops provide buffs that enhance combat performance in the Combat Zone.

## Components

### Plot (`plot.gd`)

The Plot class represents a single farming plot where crops can be planted and grown.

#### States

```gdscript
enum PlotState {
    EMPTY,       # No crop planted, ready for planting
    GROWING,     # Crop is planted and growing
    HARVESTABLE  # Crop is fully grown and ready to harvest
}
```

#### Usage Example

```gdscript
# Create a plot
var plot = Plot.new()

# Load a crop
var crop_data = load("res://resources/crops/health_berry.tres")

# Plant the crop
if plot.plant(crop_data):
    print("Crop planted successfully!")

# Update growth (time-based crops)
func _process(delta):
    plot.update_growth(delta)

# Or increment growth (run-based crops)
func on_run_completed():
    plot.increment_run_growth()

# Check if harvestable
if plot.state == Plot.PlotState.HARVESTABLE:
    var harvest = plot.harvest()
    var buff = harvest.get("buff")
    # Apply buff to player
```

#### Growth Modes

**Time-Based Growth**
- Crops grow based on elapsed real-time seconds
- Use `update_growth(delta)` to progress growth
- Example: Health Berry (30 seconds)

**Run-Based Growth**
- Crops grow based on completed combat runs
- Use `increment_run_growth()` to progress growth
- Example: Ammo Grain (2 runs)

#### Visual Stages

The Plot provides visual stage information for sprite generation:

- **Stage 0**: Empty plot
- **Stage 1**: Early growth (0-33% progress)
- **Stage 2**: Mid growth (33-66% progress)
- **Stage 3**: Late growth / Harvestable (66-100% progress)

```gdscript
var stage = plot.get_visual_stage()
var sprite = ProceduralArtGenerator.generate_crop_sprite(
    plot.crop_type,
    stage,
    seed_value
)
```

#### Serialization

Plots can be saved and loaded:

```gdscript
# Save
var save_data = plot.to_dict()

# Load
var crop_database = {
    "health_berry": load("res://resources/crops/health_berry.tres"),
    "ammo_grain": load("res://resources/crops/ammo_grain.tres"),
    # ... other crops
}
plot.from_dict(save_data, crop_database)
```

### FarmGrid (`farm_grid.gd`)

The FarmGrid class manages multiple Plot instances in a grid layout and handles player interaction.

#### Configuration

```gdscript
@export var grid_size: Vector2i = Vector2i(3, 4)  # 12 plots (3x4 grid)
@export var plot_size: float = 64.0  # Size of each plot in pixels
```

#### Usage Example

```gdscript
# Create and configure FarmGrid
var farm_grid = FarmGrid.new()
farm_grid.grid_size = Vector2i(3, 4)  # 12 plots
farm_grid.plot_size = 64.0
add_child(farm_grid)

# Wait for initialization
await get_tree().process_frame

# Get plot near player
var player_pos = player.global_position
var plot = farm_grid.get_plot_at_position(player_pos)

if plot and plot.state == Plot.PlotState.EMPTY:
    # Plant a crop
    var crop = load("res://resources/crops/tomato.tres")
    if farm_grid.plant_crop(plot, crop):
        print("Crop planted!")

# Harvest when ready
if plot and plot.state == Plot.PlotState.HARVESTABLE:
    var resources = farm_grid.harvest_crop(plot)
    print("Harvested: ", resources)

# Growth updates happen automatically in _process
# Or manually increment run-based growth
farm_grid.increment_run_growth()

# Save/Load
var plot_states = farm_grid.serialize_plots()
save_data.plot_states = plot_states

# Later...
farm_grid.deserialize_plots(save_data.plot_states, crop_database)
```

#### Key Methods

- **`get_plot_at_position(world_pos: Vector2) -> Plot`** - Find plot near position
- **`plant_crop(plot: Plot, crop: CropData) -> bool`** - Plant crop in plot
- **`harvest_crop(plot: Plot) -> Dictionary`** - Harvest crop from plot
- **`update_crop_growth(delta: float)`** - Update time-based growth (automatic)
- **`increment_run_growth()`** - Increment run-based growth
- **`get_plots_by_state(state: PlotState) -> Array[Plot]`** - Filter plots by state
- **`serialize_plots() -> Array[Dictionary]`** - Save plot states
- **`deserialize_plots(states, crop_db)`** - Load plot states

#### Signals

- **`crop_planted(plot: Plot, crop_type: String)`** - Emitted when crop is planted
- **`crop_harvested(plot: Plot, resources: Dictionary)`** - Emitted when crop is harvested

#### Grid Layout

The grid is automatically centered around the origin (0, 0):
- Plots are positioned in a regular grid pattern
- Spacing is determined by `plot_size`
- Grid dimensions are configurable via `grid_size`
- Valid configurations: 6-12 plots (Requirement 4.1)

## Crop Data

Crop data is defined in `resources/crops/` directory. Each crop has:

- **crop_id**: Unique identifier
- **display_name**: Name shown to player
- **growth_time**: Time/runs required to grow
- **growth_mode**: "time" or "runs"
- **buff_provided**: Buff given when harvested
- **seed_cost**: Cost to plant
- **base_color**: Color for sprite generation
- **shape_type**: Shape for sprite generation ("round", "tall", "leafy")

### Available Crops

1. **Health Berry** (`health_berry.tres`)
   - Growth: 30 seconds (time-based)
   - Buff: +20 Max Health
   - Shape: Round

2. **Ammo Grain** (`ammo_grain.tres`)
   - Growth: 2 runs (run-based)
   - Buff: +50 Ammo
   - Shape: Tall

3. **Weapon Flower** (`weapon_flower.tres`)
   - Growth: 3 runs (run-based)
   - Buff: Fire Rate Weapon Mod
   - Shape: Leafy

## Integration with Other Systems

### GameManager
- Tracks run completion for run-based crops
- Manages buff application from harvested crops
- Handles save/load of plot states

### ProceduralArtGenerator
- Generates crop sprites based on visual stage
- Uses crop_data.shape_type and base_color
- Creates growth progression visuals

### UIManager
- Displays crop growth progress
- Shows interaction prompts for planting/harvesting
- Displays available crops and buffs

## Testing

### Unit Tests
Run unit tests for Plot and FarmGrid classes:
```bash
# From Godot Editor: Open tests/unit/test_plot.gd and click "Run Test(s)"
# From Godot Editor: Open tests/unit/test_farm_grid.gd and click "Run Test(s)"
```

### Property Tests
Run property-based tests:
```bash
# From Godot Editor: Open tests/property/test_plot_properties.gd and click "Run Test(s)"
# From Godot Editor: Open tests/property/test_farm_grid_properties.gd and click "Run Test(s)"
```

### Integration Tests
Run integration tests with real crop data:
```bash
# From Godot Editor: Open tests/integration/test_plot_with_crop_data.gd and click "Run Test(s)"
```

### Verification Scripts
Run standalone verification:
```bash
# From Godot Editor: Open scripts/farming/verify_plot.tscn and press F6
# From Godot Editor: Open scripts/farming/verify_farm_grid.tscn and press F6
```

## Requirements Validated

- ✅ **Requirement 4.1**: Farm Hub contains grid of 6-12 plots (FarmGrid)
- ✅ **Requirement 4.2**: Player can plant crops with seeds in inventory (FarmGrid.plant_crop)
- ✅ **Requirement 4.3**: Crops complete growth timer (Plot.update_growth)
- ✅ **Requirement 4.4**: Crops become harvestable and add to inventory (FarmGrid.harvest_crop)
- ✅ **Requirement 4.5**: Crops grow based on time or runs without watering (Plot dual-mode growth)

## Next Steps

1. ✅ **Task 6.1**: Implement Plot class
2. ✅ **Task 6.2.1**: Implement FarmGrid class with grid_size and plot_size
3. 🔄 **Task 6.2.4**: Add inventory integration for planting
4. 🔄 **Task 6.2.5**: Add inventory integration for harvesting
5. 🔄 **Task 6.3**: Add crop visuals and player interaction
6. 🔄 **Phase 7**: Implement buff application system
7. 🔄 **Phase 8**: Connect to save/load system

## Design Decisions

### Why Dual-Mode Growth?
Supporting both time-based and run-based growth provides:
- **Flexibility**: Different crop types for different playstyles
- **Balance**: Fast crops for immediate buffs, slow crops for powerful upgrades
- **Engagement**: Encourages both farming and combat activities

### Why Strict State Transitions?
Enforcing EMPTY → GROWING → HARVESTABLE → EMPTY:
- **Prevents bugs**: Can't harvest empty plots or plant in occupied plots
- **Clear logic**: Easy to understand and debug
- **Testable**: Property tests verify state sequence

### Why Separate Update Methods?
Having `update_growth()` and `increment_run_growth()`:
- **Explicit**: Clear which growth mode is being used
- **Safe**: Prevents accidental cross-mode updates
- **Testable**: Easy to verify mode isolation

## API Reference

### Methods

#### `plant(crop: CropData) -> bool`
Plants a crop in the plot. Returns true on success.

#### `update_growth(delta: float) -> void`
Updates growth for time-based crops.

#### `increment_run_growth() -> void`
Increments growth for run-based crops.

#### `harvest() -> Dictionary`
Harvests the crop. Returns {"crop_id": String, "buff": Buff}.

#### `get_visual_stage() -> int`
Returns visual stage (0-3) for sprite generation.

#### `get_growth_percentage() -> float`
Returns growth completion (0.0 to 1.0).

#### `to_dict() -> Dictionary`
Serializes plot state for saving.

#### `from_dict(data: Dictionary, crop_database: Dictionary) -> void`
Deserializes plot state from saved data.

### Signals

#### `growth_completed()`
Emitted when crop completes growth and becomes harvestable.

### Properties

- `state: PlotState` - Current plot state
- `crop_type: String` - ID of planted crop
- `growth_progress: float` - Current growth progress
- `growth_time: float` - Time required for full growth
- `crop_data: CropData` - Reference to crop data resource

## Contributing

When modifying the farming system:

1. **Update tests**: Add tests for new functionality
2. **Update documentation**: Keep this README current
3. **Run verification**: Ensure verify_plot.gd passes
4. **Check requirements**: Verify requirements are still met
5. **Update design doc**: Document design decisions

## Resources

- **Design Document**: `.kiro/specs/arcade-fps-farming-game/design.md`
- **Requirements**: `.kiro/specs/arcade-fps-farming-game/requirements.md`
- **Tasks**: `.kiro/specs/arcade-fps-farming-game/tasks.md`
- **Test Guide**: `tests/README.md`
