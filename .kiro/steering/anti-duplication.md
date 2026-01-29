# Anti-Duplication Rules

## Core Principle

**ALWAYS check if functionality already exists before implementing.** Duplication wastes effort, creates bugs, and makes maintenance harder.

## Before Writing Any Code

### 1. Search for Existing Implementation

**Always search first:**
```bash
# Search for method names
grep -r "func method_name" scripts/

# Search for similar functionality
grep -r "keyword" scripts/
```

**In Kiro, use grepSearch tool:**
- Search for method names
- Search for similar logic
- Check related classes

### 2. Check These Locations

**For game logic:**
- `scripts/autoload/game_manager.gd` - Central state management
- `scripts/systems/` - Core game systems
- Related class files

**For save/load:**
- `resources/save_data.gd` - Save data structure (SINGLE SOURCE OF TRUTH)
- `scripts/autoload/game_manager.gd` - Save/load methods
- NO OTHER FILES should implement save/load

**For UI updates:**
- Check if signals already exist
- Look for existing UI update methods
- Don't create duplicate signal handlers

## Save System Rules (CRITICAL)

### Single Source of Truth

**SaveData resource (`resources/save_data.gd`) is the ONLY place for save data structure:**

```gdscript
# CORRECT - One definition in save_data.gd
class_name SaveData extends Resource

@export var player_health: int = 100
@export var inventory: Array[String] = []
@export var unlocked_upgrades: Array[String] = []
```

**NEVER duplicate save data fields in other classes:**

```gdscript
# WRONG - Don't duplicate save structure
class_name GameManager:
    var save_player_health: int  # NO! Use SaveData
    var save_inventory: Array    # NO! Use SaveData
```

### Save/Load Method Rules

**GameManager has ONE save method and ONE load method:**

```gdscript
# CORRECT - Single save/load in GameManager
func save_game() -> void:
    var save_data = SaveData.new()
    save_data.player_health = current_health
    save_data.inventory = inventory.duplicate()
    # ... save to file

func load_game() -> void:
    var save_data = _load_from_file()
    current_health = save_data.player_health
    inventory = save_data.inventory.duplicate()
```

**NEVER create additional save/load methods:**

```gdscript
# WRONG - Don't create duplicate save methods
func save_player_data() -> void:  # NO!
func save_inventory() -> void:    # NO!
func save_upgrades() -> void:     # NO!
```

### Adding New Save Data

**Process:**
1. Check if field already exists in `SaveData`
2. If not, add it to `SaveData` ONLY
3. Update `GameManager.save_game()` to write it
4. Update `GameManager.load_game()` to read it
5. That's it - no other changes needed

**Example:**
```gdscript
# Step 1: Add to SaveData (resources/save_data.gd)
@export var farm_plots: Array[Dictionary] = []

# Step 2: Update GameManager.save_game()
func save_game() -> void:
    var save_data = SaveData.new()
    # ... existing fields
    save_data.farm_plots = farm_grid.serialize_plots()
    # ... save to file

# Step 3: Update GameManager.load_game()
func load_game() -> void:
    var save_data = _load_from_file()
    # ... existing fields
    farm_grid.deserialize_plots(save_data.farm_plots)
```

## Method Duplication Prevention

### Check Before Creating Methods

**Before writing a method, search for:**
- Same method name
- Similar functionality
- Related methods that could be extended

**Example - DON'T duplicate:**
```gdscript
# WRONG - Multiple methods doing the same thing
func apply_health_buff(amount: int) -> void:
    current_health += amount

func increase_health(amount: int) -> void:  # DUPLICATE!
    current_health += amount

func add_health(amount: int) -> void:  # DUPLICATE!
    current_health += amount
```

**CORRECT - One method:**
```gdscript
# CORRECT - Single method
func modify_health(amount: int) -> void:
    current_health = clamp(current_health + amount, 0, max_health)
    health_changed.emit(current_health)
```

### Extend, Don't Duplicate

**If similar functionality exists, extend it:**

```gdscript
# Existing method
func apply_buff(buff: Buff) -> void:
    match buff.buff_type:
        Buff.BuffType.HEALTH:
            modify_health(buff.value)

# CORRECT - Extend existing method
func apply_buff(buff: Buff) -> void:
    match buff.buff_type:
        Buff.BuffType.HEALTH:
            modify_health(buff.value)
        Buff.BuffType.AMMO:  # Add new case
            modify_ammo(buff.value)

# WRONG - Create duplicate method
func apply_ammo_buff(buff: Buff) -> void:  # NO!
    modify_ammo(buff.value)
```

## Signal Duplication Prevention

### Check Existing Signals

**Before creating a signal, check if one exists:**

```gdscript
# WRONG - Duplicate signals
signal health_changed(new_health: int)
signal health_updated(health: int)  # DUPLICATE!
signal on_health_change(hp: int)    # DUPLICATE!

# CORRECT - One signal
signal health_changed(new_health: int)
```

### Reuse Existing Signals

**Connect to existing signals instead of creating new ones:**

```gdscript
# CORRECT - Reuse existing signal
func _ready() -> void:
    player.health_changed.connect(_on_health_changed)

# WRONG - Create duplicate signal
signal player_health_changed(health: int)
func _ready() -> void:
    player.health_changed.connect(func(h): player_health_changed.emit(h))
```

## Data Structure Duplication Prevention

### Single Source for Each Data Type

**Each data type has ONE authoritative source:**

- **Buff data**: `resources/buffs/buff.gd` + `.tres` files
- **Crop data**: `resources/crops/crop_data.gd` + `.tres` files
- **Save data**: `resources/save_data.gd`
- **Game state**: `scripts/autoload/game_manager.gd`

**NEVER duplicate data structures:**

```gdscript
# WRONG - Duplicate buff structure
class_name BuffManager:
    var buff_type: String      # NO! Use Buff resource
    var buff_value: int        # NO! Use Buff resource
    var buff_duration: int     # NO! Use Buff resource

# CORRECT - Use existing Buff resource
class_name BuffManager:
    var active_buffs: Array[Buff] = []
```

## Verification Checklist

Before implementing ANY feature, check:

- [ ] Does this method already exist?
- [ ] Does similar functionality exist that I can extend?
- [ ] Is there already a signal for this event?
- [ ] Does SaveData already have this field?
- [ ] Is there already a save/load method for this?
- [ ] Can I reuse existing code instead of duplicating?

## When You Find Duplication

**If you discover duplicate code:**

1. **Stop immediately**
2. **Identify the original/best version**
3. **Remove duplicates**
4. **Update all references to use the single version**
5. **Add tests to prevent regression**

**Example:**
```gdscript
# Found duplicate methods:
func save_player_data() -> void: ...
func save_game_state() -> void: ...

# Action:
# 1. Keep save_game() in GameManager
# 2. Delete save_player_data() and save_game_state()
# 3. Update all calls to use save_game()
# 4. Test to ensure nothing broke
```

## Search Commands

**Before implementing, always search:**

```bash
# Search for method names
grep -r "func method_name" scripts/

# Search for save/load methods
grep -r "func save" scripts/
grep -r "func load" scripts/

# Search for signals
grep -r "signal signal_name" scripts/

# Search for class definitions
grep -r "class_name ClassName" scripts/
```

**In Kiro, use grepSearch tool with these patterns.**

## Red Flags

**Stop and search if you're about to:**
- Create a method with "save" or "load" in the name
- Add a field to store game state outside GameManager
- Create a signal that sounds similar to existing ones
- Implement logic that "feels like it should already exist"
- Copy-paste code from another file

## Remember

**DRY (Don't Repeat Yourself):**
- One source of truth for each piece of data
- One method for each piece of functionality
- One signal for each type of event
- One save/load system for the entire game

**When in doubt:**
1. Search first
2. Reuse existing code
3. Extend rather than duplicate
4. Ask before creating new save/load logic
