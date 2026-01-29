# Crop Reference Guide

Quick reference for all available crops in the game.

## Crop Summary Table

| Crop Name | Type | Growth | Buff | Cost | Shape | Color |
|-----------|------|--------|------|------|-------|-------|
| Health Berry | Health | 30s | +20 HP | 10 | Round | Red |
| Vitality Herb | Health | 25s | +40 HP | 18 | Leafy | Green |
| Ammo Grain | Ammo | 35s | +50 Ammo | 15 | Tall | Gold |
| Weapon Flower | Weapon Mod | 40s | Fire Rate | 20 | Leafy | Purple |
| Power Root | Weapon Mod | 3 runs | Damage | 25 | Round | Orange |

## Crop Details

### Health Berry
```
File: resources/crops/health_berry.tres
Buff: resources/buffs/health_buff_20.tres
Growth Mode: time
Growth Time: 30 seconds
Seed Cost: 10
Base Color: RGB(0.8, 0.2, 0.2)
Shape Type: round
Buff Effect: +20 Max Health for next run
```

### Vitality Herb
```
File: resources/crops/vitality_herb.tres
Buff: resources/buffs/health_buff_40.tres
Growth Mode: time
Growth Time: 25 seconds
Seed Cost: 18
Base Color: RGB(0.2, 0.9, 0.5)
Shape Type: leafy
Buff Effect: +40 Max Health for next run
```

### Ammo Grain
```
File: resources/crops/ammo_grain.tres
Buff: resources/buffs/ammo_buff_50.tres
Growth Mode: time
Growth Time: 35 seconds
Seed Cost: 15
Base Color: RGB(0.8, 0.7, 0.3)
Shape Type: tall
Buff Effect: +50 Ammo for next run
```

### Weapon Flower
```
File: resources/crops/weapon_flower.tres
Buff: resources/buffs/weapon_mod_fire_rate.tres
Growth Mode: time
Growth Time: 40 seconds
Seed Cost: 20
Base Color: RGB(0.6, 0.3, 0.8)
Shape Type: leafy
Buff Effect: Fire Rate Boost for next run
```

### Power Root
```
File: resources/crops/power_root.tres
Buff: resources/buffs/weapon_mod_damage.tres
Growth Mode: runs
Growth Time: 3 runs
Seed Cost: 25
Base Color: RGB(0.9, 0.4, 0.1)
Shape Type: round
Buff Effect: Damage Boost for next run
```

## Usage in Code

### Loading a Crop
```gdscript
# Preload (compile-time)
var health_berry = preload("res://resources/crops/health_berry.tres")

# Load (runtime)
var ammo_grain = load("res://resources/crops/ammo_grain.tres")
```

### Checking Crop Properties
```gdscript
var crop = preload("res://resources/crops/health_berry.tres")
print(crop.display_name)  # "Health Berry"
print(crop.growth_time)   # 30.0
print(crop.growth_mode)   # "time"
print(crop.seed_cost)     # 10
```

### Validating a Crop
```gdscript
var crop = preload("res://resources/crops/health_berry.tres")
if crop.is_valid():
    print("Crop is valid!")
```

### Getting Crop Description
```gdscript
var crop = preload("res://resources/crops/health_berry.tres")
var desc = crop.get_description()
# Output: "Health Berry - +20 Max Health (Growth: 30 seconds)"
```

## Progression Guide

### Early Game Strategy
1. Plant **Health Berry** (10 seeds, 30s) for quick health boost
2. Plant **Ammo Grain** (15 seeds, 35s) for ammo supply
3. Save seeds for **Vitality Herb** (18 seeds, 25s) when affordable

### Mid Game Strategy
1. Plant **Weapon Flower** (20 seeds, 40s) for fire rate boost
2. Start **Power Root** (25 seeds, 3 runs) for long-term investment
3. Mix health and ammo crops based on playstyle

### Late Game Strategy
1. Harvest **Power Root** for damage boost
2. Plant multiple crops for stacked buffs
3. Optimize crop rotation for maximum efficiency

## Balance Notes

### Cost Efficiency
- **Best HP/seed**: Vitality Herb (2.22 HP/seed)
- **Best ammo/seed**: Ammo Grain (3.33 ammo/seed)
- **Cheapest**: Health Berry (10 seeds)
- **Most expensive**: Power Root (25 seeds)

### Growth Speed
- **Fastest**: Vitality Herb (25s)
- **Slowest (time)**: Weapon Flower (40s)
- **Slowest (runs)**: Power Root (3 runs)

### Strategic Value
- **Early game**: Health Berry, Ammo Grain
- **Mid game**: Vitality Herb, Weapon Flower
- **Late game**: Power Root

## See Also
- `resources/crops/README.md` - Detailed crop documentation
- `resources/crops/crop_data.gd` - CropData class definition
- `resources/buffs/buff.gd` - Buff class definition
- `TASK_6.3.1_COMPLETION_SUMMARY.md` - Implementation details
