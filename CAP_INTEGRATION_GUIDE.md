# Advanced Space Combat - CAP Integration Guide v3.0

## Overview

The Advanced Space Combat addon now features comprehensive integration with the Carter Addon Pack (CAP), providing seamless interoperability between ASC systems and CAP entities. This integration includes automatic detection, resource bridging, communication protocols, and fallback systems.

## Features

### 🔍 Enhanced Detection System
- **Comprehensive Entity Detection**: Automatically detects all CAP entities including stargates, shields, energy systems, transportation, weapons, and sensors
- **Real-time Monitoring**: Continuously monitors CAP entities and updates ship systems accordingly
- **Technology Classification**: Automatically determines technology level (Ancient, Asgard, Ori, Wraith, Goa'uld, Tau'ri)
- **Performance Optimization**: Cached detection system with configurable update intervals

### 🛡️ Advanced Shield Integration
- **Automatic Shield Detection**: Finds and integrates with all CAP shield types
- **Unified Control**: Control CAP shields through ASC ship core interface
- **Auto-activation**: Shields automatically activate during hyperdrive operations
- **Technology-based Configuration**: Shield parameters adjust based on detected technology level

### ⚡ Resource Bridging System
- **SB3 Integration**: Bridges CAP energy systems to Spacebuild 3 resource network
- **Automatic Distribution**: CAP energy sources automatically provide power to ship systems
- **Conversion Rates**: Technology-specific conversion rates for optimal efficiency
- **Real-time Monitoring**: Live energy level monitoring and distribution

### 📡 Communication Protocols
- **Universal API**: Unified interface for controlling different CAP entity types
- **Batch Operations**: Control multiple CAP entities simultaneously
- **Protocol Abstraction**: Handles different CAP entity interfaces transparently
- **Error Handling**: Robust error handling with fallback methods

### 🔄 Fallback Systems
- **No-CAP Operation**: Full functionality even when CAP is not installed
- **Virtual Entities**: Creates virtual CAP entities for testing and compatibility
- **Fallback Resources**: Alternative sounds, materials, and effects
- **Seamless Integration**: Transparent fallback that maintains all features

## Installation and Setup

### Requirements
- Advanced Space Combat addon (this addon)
- Optional: Carter Addon Pack (Steam Workshop Collection)
- Optional: Spacebuild 3 for resource integration

### Automatic Setup
The CAP integration system automatically:
1. Detects available CAP installations
2. Configures appropriate integration level
3. Initializes all subsystems
4. Validates functionality

### Manual Configuration
Edit `lua/autorun/asc_cap_integration_enhanced.lua` to customize:

```lua
ASC.CAP.Enhanced.Config = {
    EnableEnhancedIntegration = true,
    EnableFallbackSystems = true,
    EnablePerformanceOptimization = true,
    DetectionInterval = 5.0,
    EnableResourceBridging = true,
    EnableAdvancedShieldIntegration = true
}
```

## Usage Guide

### Ship Core Integration
1. **Spawn ASC Ship Core**: Place an ASC ship core on your ship
2. **Automatic Detection**: CAP entities are automatically detected and integrated
3. **Status Monitoring**: Check ship core UI for CAP integration status
4. **Manual Control**: Use ship core commands to control CAP entities

### CAP Entity Control
```lua
-- Control individual CAP entity
ASC.CAP.Communication.ControlEntity(entity, "activate", {})

-- Batch control multiple entities
ASC.CAP.Communication.BatchControl(entities, "set_strength", {strength = 100})

-- Get entity properties
local strength = ASC.CAP.Communication.GetProperty(shield, "strength")
```

### Console Commands
- `asc_cap_validate` - Run comprehensive CAP integration validation
- `aria_cap_status` - Display current CAP integration status
- `aria_cap_detect` - Force CAP entity detection update

## Supported CAP Entities

### Stargates
- **Classes**: stargate_sg1, stargate_movie, stargate_infinity, stargate_tollan, stargate_atlantis, stargate_milkyway, stargate_universe, stargate_destiny
- **Features**: Automatic dialing, address management, status monitoring
- **Integration**: Full hyperdrive system integration

### Shields
- **Classes**: shield_core_buble, shield_core_goauld, shield_core_asgard, shield_core_ancient, shield_core_wraith, shield_core_ori
- **Features**: Auto-activation, strength control, frequency management
- **Integration**: Power dependency, automatic configuration

### Energy Systems
- **Classes**: zpm, zpm_hub, naquadah_generator, potentia, ancient_power_core
- **Features**: Energy bridging, capacity monitoring, efficiency optimization
- **Integration**: SB3 resource network, automatic distribution

### Transportation
- **Classes**: rings_ancient, rings_goauld, asgard_transporter, ancient_transporter
- **Features**: Transport coordination, range optimization
- **Integration**: Ship system integration

### Weapons
- **Classes**: staff_cannon, drone_weapon, plasma_cannon, rail_gun
- **Features**: Targeting assistance, ammunition management
- **Integration**: Tactical AI coordination

## Technology Levels

### Ancient Technology
- **Priority**: Highest (10)
- **Power Multiplier**: 2.0x
- **Efficiency Bonus**: +50%
- **Examples**: Atlantis systems, ZPMs, Ancient drones

### Asgard Technology
- **Priority**: High (9)
- **Power Multiplier**: 1.8x
- **Efficiency Bonus**: +40%
- **Examples**: Asgard shields, beam weapons

### Ori Technology
- **Priority**: High (8)
- **Power Multiplier**: 1.6x
- **Efficiency Bonus**: +30%
- **Examples**: Ori shields, energy weapons

### Wraith Technology
- **Priority**: Medium (7)
- **Power Multiplier**: 1.4x
- **Efficiency Bonus**: +20%
- **Examples**: Wraith ships, organic technology

### Goa'uld Technology
- **Priority**: Medium (6)
- **Power Multiplier**: 1.2x
- **Efficiency Bonus**: +10%
- **Examples**: Ha'tak vessels, staff weapons

### Tau'ri Technology
- **Priority**: Standard (5)
- **Power Multiplier**: 1.0x
- **Efficiency Bonus**: 0%
- **Examples**: Earth-built systems, human technology

## Performance Optimization

### Caching System
- Entity detection results are cached for improved performance
- Configurable cache update intervals
- Automatic cleanup of expired cache entries

### Batch Operations
- Multiple entities can be controlled simultaneously
- Reduced network traffic through batch commands
- Optimized for large ships with many CAP entities

### Smart Detection
- Only scans for changes when necessary
- Radius-based detection for large maps
- Performance metrics and monitoring

## Troubleshooting

### Common Issues

**CAP Not Detected**
- Ensure CAP is properly installed
- Check console for detection messages
- Run `asc_cap_validate` command

**Shields Not Working**
- Verify shield entities are on the ship
- Check power requirements
- Ensure shields are compatible type

**Resource Bridging Failed**
- Confirm SB3 is installed
- Check energy source compatibility
- Verify ship core configuration

**Performance Issues**
- Reduce detection interval
- Enable performance optimization
- Limit maximum cached entities

### Debug Information
Enable debug logging in configuration:
```lua
ASC.CAP.Enhanced.Config.EnableDebugLogging = true
```

### Validation System
Run comprehensive validation:
```
asc_cap_validate
```

This will test all CAP integration systems and report any issues.

## API Reference

### Core Functions
- `ASC.CAP.Enhanced.DetectCAPEntities(forceUpdate)`
- `ASC.CAP.Enhanced.GetBestAvailableTechnology(player)`
- `ASC.CAP.Communication.ControlEntity(entity, action, parameters)`
- `ASC.CAP.Fallback.CreateVirtualEntity(type, position, owner)`

### Events and Hooks
- `ASC_CAP_EntityDetected` - Fired when new CAP entity is detected
- `ASC_CAP_IntegrationComplete` - Fired when integration is complete
- `ASC_CAP_ResourceBridged` - Fired when resource bridging occurs

## Version History

### v3.0 (Current)
- Complete rewrite of CAP integration system
- Enhanced detection with technology classification
- Advanced communication protocols
- Comprehensive fallback systems
- Performance optimization and caching
- Validation and testing framework

### v2.0
- Basic CAP entity detection
- Simple shield integration
- Resource bridging prototype

### v1.0
- Initial CAP detection
- Basic compatibility layer

## Support

For issues, suggestions, or contributions:
- Check the validation system output
- Enable debug logging for detailed information
- Report issues with full console output
- Include CAP version and installation method

---

*Advanced Space Combat CAP Integration v3.0 - Comprehensive CAP asset integration for enhanced space combat experience*
