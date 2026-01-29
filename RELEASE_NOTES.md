# Arcade FPS Farming Game - Release Notes

## Version 1.0 - Initial Release

**Release Date**: 2024

### Overview

A prototype game blending fast-paced arcade FPS combat with cozy farming mechanics. Players alternate between peaceful farming sessions and intense combat runs in short 10-15 minute gameplay loops.

### Core Features

#### Dual Gameplay Loop
- **Farm Hub**: Peaceful farming area with 6-12 plots for growing crops
- **Combat Zone**: Intense FPS arena with procedurally generated waves
- Seamless transitions between both modes via interactive portal

#### Combat System
- **Three Weapon Types**:
  - Pistol: Infinite ammo, reliable damage
  - Shotgun: Limited ammo, spread pattern, high damage
  - Plant Weapon: Special weapon unlocked through progression
- **First-Person Controls**: Smooth WASD movement with mouse look
- **Dash Mechanic**: Quick dodge with 1.5s cooldown
- **Three Enemy Types**:
  - Melee Charger: Fast, aggressive close-range
  - Ranged Shooter: Projectile attacks from distance
  - Tank Enemy: High health, slow but dangerous

#### Farming System
- **Five Crop Types**:
  - Health Berry (45s): +20 max health buff
  - Vitality Herb: Enhanced health regeneration
  - Ammo Grain (60s): +50 shotgun ammo
  - Power Root: Damage boost
  - Weapon Flower (75s): Fire rate increase
- **Time-Based Growth**: Crops grow in real-time (45-75 seconds)
- **Persistent Growth**: Crops continue growing during combat runs

#### Progression System
- **Permanent Upgrades**:
  - Health Boost I/II/III: Increase max health
  - Quick Dash I/II: Reduce dash cooldown
  - Rapid Fire I/II: Increase weapon fire rate
  - Swift Movement I/II: Increase movement speed
- **Temporary Buffs**: Harvested crops provide single-run bonuses
- **Currency System**: Earn credits from defeating enemies
- **Upgrade Costs**: Balanced for 3-5 successful runs per upgrade

#### Visual Design
- **Procedural Generation**: All visuals generated at runtime
- **Dual Atmosphere**:
  - Farm Hub: Bright, warm colors with organic shapes
  - Combat Zone: Dark, aggressive colors with angular geometry
- **No Asset Files**: Entire game under 50MB

#### Save System
- **Automatic Saving**: Saves on scene transitions and upgrades
- **Retry Logic**: Exponential backoff for failed saves
- **Persistent Data**:
  - Permanent upgrades
  - Inventory resources
  - Crop growth states
- **Save Location**: `%APPDATA%/Godot/app_userdata/Arcade FPS Farming Game/`

### Balance & Pacing

#### Combat Sessions (5-10 minutes)
- 5 waves of increasing difficulty
- Wave 1: 3 melee enemies
- Wave 2: 2 melee + 2 ranged
- Wave 3: 3 melee + 2 ranged + 1 tank
- Wave 4: 4 melee + 3 ranged + 2 tanks
- Wave 5: 5 melee + 4 ranged + 3 tanks
- 3-second delay between waves

#### Farming Sessions (2-5 minutes)
- Quick crop growth times (45-75 seconds)
- Multiple plots allow parallel farming
- Strategic buff selection for combat

#### Progression Curve
- First upgrade: ~3 successful runs (240 credits)
- Mid-tier upgrades: ~5 runs (400-500 credits)
- High-tier upgrades: ~8 runs (750+ credits)
- Total progression: 15-20 hours to unlock all upgrades

### Technical Specifications

#### Engine & Platform
- **Engine**: Godot 4.6
- **Language**: GDScript
- **Platform**: Windows Desktop (x86_64)
- **Architecture**: Scene-based with autoload singletons

#### Performance
- **Target**: 60 FPS stable
- **Tested**: 10+ enemies on screen simultaneously
- **Optimization**: Cached procedural generation, efficient collision detection

#### File Size
- **Target**: Under 50MB
- **Achieved**: ~30-40MB (no external assets)
- **Compression**: ZSTD embedded PCK

### Controls

- **WASD**: Movement
- **Mouse**: Camera look
- **Left Click**: Fire weapon
- **Shift**: Dash
- **E**: Interact (plant/harvest/enter portal)
- **1**: Switch to Pistol
- **2**: Switch to Shotgun

### Known Limitations

1. **Single Player Only**: No multiplayer support
2. **Windows Only**: Not tested on other platforms
3. **No Audio**: Visual-only experience (audio system not implemented)
4. **Fixed Resolution**: 1920x1080 (scales to window)
5. **No Rebindable Controls**: Fixed input mappings

### Future Enhancements (Not Implemented)

- Audio system (music, sound effects)
- Additional crop types
- More enemy variants
- Boss encounters
- Multiple arena layouts
- Customizable controls
- Linux/Mac support

### Credits

**Development**: Built with Godot Engine
**Testing Framework**: GdUnit4
**Architecture**: Property-based testing approach

### System Requirements

**Minimum**:
- OS: Windows 10 (64-bit)
- Processor: Dual-core 2.0 GHz
- Memory: 2 GB RAM
- Graphics: OpenGL 3.3 compatible
- Storage: 50 MB

**Recommended**:
- OS: Windows 10/11 (64-bit)
- Processor: Quad-core 2.5 GHz
- Memory: 4 GB RAM
- Graphics: Dedicated GPU with OpenGL 3.3+
- Storage: 50 MB

### Installation

1. Download `ArcadeFPSFarming.exe`
2. Double-click to run (no installation required)
3. Save data automatically created on first run

### Uninstallation

1. Delete `ArcadeFPSFarming.exe`
2. (Optional) Delete save data from `%APPDATA%/Godot/app_userdata/Arcade FPS Farming Game/`

### Support

For issues or questions, refer to:
- `README.md` - Project overview and structure
- `QUICKSTART.md` - Quick start guide
- `ARCHITECTURE.md` - Technical architecture details

### License

[To be determined]

---

**Thank you for playing!**
