# CropData Resources

This directory contains the `CropData` resource class and crop resource files that define plantable crops in the game.

## Overview

`CropData` is a Godot Resource that defines a crop type with:
- Growth parameters (time/runs to maturity)
- Buff rewards (what the player gets when harvesting)
- Visual generation data (for procedural sprite creation)
- Planting costs

## CropData Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `crop_id` | String | Unique identifier | "health_berry" |
| `display_name` | String | Player-facing name | "Health Berry" |
| `growth_time` | float | Time/runs to maturity | 30.0 |
| `buff_provided` | Buff | Buff given on harvest | health_buff_20.tres |
| `seed_cost` | int | Cost to plant | 10 |
| `base_color` | Color | For sprite generation | Color(0.8, 0.2, 0.2) |
| `shape_type` | String | "round", "tall", or "leafy" | "round" |
| `growth_mode` | String | "time" or "runs" | "time" |

## Shape Types

- **"round"**: Berry/fruit-like shapes (circular, compact)
  - Best for: Health crops, small consumables
  - Example: Health Berry

- **"tall"**: Grain/stalk-like shapes (vertical, elongated)
  - Best for: Ammo crops, resource crops
  - Example: Ammo Grain

- **"leafy"**: Flower/spread-like shapes (wide, organic)
  - Best for: Weapon mod crops, special effects
  - Example: Weapon Flower

## Growth Modes

- **"time"**: Crop grows based on real-time seconds
  - Use for: Fast-growing crops, immediate buffs
  - Example: 30 seconds = quick health boost

- **"runs"**: Crop grows based on completed combat runs
  - Use for: Slow-growing crops, powerful buffs
  - Example: 3 runs = rare weapon mod

## Creating a New Crop

### Method 1: In Godot Editor (Recommended)

1. Right-click in FileSystem panel → New Resource
2. Search for "CropData" and select it
3. Fill in all fields in the Inspector
4. Save as `.tres` file in `resources/crops/`

### Method 2: In Code

```gdscript
var new_crop = CropData.new()
new_crop.crop_id = "speed_root"
new_crop.display_name = "Speed Root"
new_crop.growth_time = 40.0
new_crop.buff_provided = preload("res://resources/buffs/speed_buff.tres")
new_crop.seed_cost = 12
new_crop.base_color = Color(0.3, 0.8, 0.4)
new_crop.shape_type = "round"
new_crop.growth_mode = "time"

# Always validate before use
if new_crop.is_valid():
    ResourceSaver.save(new_crop, "res://resources/crops/speed_root.tres")
```

## Example Crops

### Health Berry
- **Type**: Health buff
- **Growth**: 30 seconds (time-based)
- **Buff**: +20 Max Health
- **Shape**: Round (berry-like)
- **Color**: Red
- **Cost**: 10 seeds

### Ammo Grain
- **Type**: Ammo buff
- **Growth**: 35 seconds (time-based)
- **Buff**: +50 Ammo
- **Shape**: Tall (grain-like)
- **Color**: Yellow-gold
- **Cost**: 15 seeds

### Weapon Flower
- **Type**: Weapon mod
- **Growth**: 40 seconds (time-based)
- **Buff**: Fire Rate Boost
- **Shape**: Leafy (flower-like)
- **Color**: Purple
- **Cost**: 20 seeds

### Vitality Herb
- **Type**: Health buff
- **Growth**: 25 seconds (time-based)
- **Buff**: +40 Max Health
- **Shape**: Leafy (herb-like)
- **Color**: Bright green
- **Cost**: 18 seeds

### Power Root
- **Type**: Weapon mod
- **Growth**: 3 runs (run-based)
- **Buff**: Damage Boost
- **Shape**: Round (root-like)
- **Color**: Orange-red
- **Cost**: 25 seeds

## Using CropData in Code

### Loading a Crop
```gdscript
var crop = preload("res://resources/crops/health_berry.tres")
print(crop.display_name)  # "Health Berry"
```

### Validating a Crop
```gdscript
if crop.is_valid():
    print("Crop is valid!")
else:
    print("Crop has errors - check console warnings")
```

### Getting Description
```gdscript
var desc = crop.get_description()
# Output: "Health Berry - +20 Max Health (Growth: 30 seconds)"
```

### Planting (Future - Plot System)
```gdscript
func plant_crop(plot: Plot, crop: CropData) -> bool:
    if not crop.is_valid():
        return false
    
    if GameManager.get_inventory("seeds") < crop.seed_cost:
        return false
    
    GameManager.remove_from_inventory("seeds", crop.seed_cost)
    plot.plant(crop)
    return true
```

## Validation Rules

CropData validates the following:
- ✅ `crop_id` is not empty
- ✅ `display_name` is not empty
- ✅ `growth_time` is positive (> 0)
- ✅ `buff_provided` is not null
- ✅ `seed_cost` is non-negative (≥ 0)
- ✅ `shape_type` is "round", "tall", or "leafy"
- ✅ `growth_mode` is "time" or "runs"

Invalid crops will log warnings to the console.

## Integration with Other Systems

### Buff System
- Each crop references a `Buff` resource
- Buffs are applied when the crop is harvested
- See `resources/buffs/` for buff resources

### Plot System (Future)
- Plots will use CropData to track planted crops
- Growth progress tracked based on `growth_mode`
- Harvest returns the `buff_provided`

### ProceduralArtGenerator (Future)
- Uses `base_color` and `shape_type` to generate sprites
- Generates 4 growth stages (0-3)
- Deterministic based on seed value

### UI System (Future)
- Uses `get_description()` for crop tooltips
- Displays `display_name` in inventory
- Shows `seed_cost` in planting UI

## Best Practices

1. **Unique IDs**: Always use unique `crop_id` values
2. **Descriptive Names**: Use clear `display_name` values
3. **Balanced Growth**: Consider game pacing when setting `growth_time`
4. **Appropriate Buffs**: Match buff strength to growth time
5. **Visual Variety**: Use different `shape_type` and `base_color` combinations
6. **Validate Early**: Always call `is_valid()` before using crops

## Testing

Unit tests are located in `tests/unit/test_crop_data.gd`.

Run tests in Godot Editor:
1. Open GdUnit Inspector panel
2. Navigate to test file
3. Click "Run Tests"

All 20 tests should pass ✅

## See Also

- `resources/buffs/buff.gd` - Buff resource class
- `tests/unit/test_crop_data.gd` - CropData unit tests
- `.kiro/specs/arcade-fps-farming-game/design.md` - Design document
- `TASK_1.3.2_COMPLETION_SUMMARY.md` - Implementation details

