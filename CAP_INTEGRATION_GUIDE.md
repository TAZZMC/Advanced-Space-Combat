# Hyperdrive CAP (Carter Addon Pack) Integration Guide

## Overview

This guide covers the comprehensive integration between the Enhanced Hyperdrive System and Carter Addon Pack (CAP), the premier Stargate-themed addon for Garry's Mod.

**Repository**: https://github.com/RafaelDeJongh/cap

## Features

### 🌟 Core Integration Features

- **Stargate Network Integration** - Use Stargate addresses for navigation
- **Shield System Respect** - Proper interaction with CAP shield systems  
- **Energy System Integration** - Share power between hyperdrive and Stargate systems
- **Conflict Prevention** - Avoid interference with active Stargate operations
- **Transportation Compatibility** - Integration with rings and transporters
- **Advanced Monitoring** - Real-time monitoring and analytics
- **Comprehensive Testing** - Automated testing framework

## Supported CAP Entities

### Stargate Systems
- `stargate_atlantis` - Atlantis-style stargates
- `stargate_milkyway` - Milky Way stargates  
- `stargate_universe` - Universe stargates
- `stargate_supergate` - Supergate systems
- `stargate_orlin` - Orlin's miniature stargate
- `stargate_tollan` - Tollan stargate technology

### Shield Systems
- `shield` - Basic shield generators
- `shield_core_buble` - Bubble shield cores
- `shield_core_goauld` - Goa'uld shield technology
- `shield_core_asgard` - Asgard shield systems
- `shield_core_atlantis` - Ancient/Atlantis shields

### Energy Systems
- `zpm` - Zero Point Modules
- `zpm_hub` - ZPM distribution hubs
- `naquadah_generator` - Naquadah power generators
- `potentia` - Ancient power sources

### Dial Home Devices (DHD)
- `dhd_atlantis` - Atlantis DHD
- `dhd_milkyway` - Milky Way DHD
- `dhd_universe` - Universe DHD
- `dhd_pegasus` - Pegasus galaxy DHD

### Transportation Systems
- `rings_ancient` - Ancient ring transporters
- `rings_goauld` - Goa'uld ring transporters
- `rings_ori` - Ori ring transporters
- `transporter` - Asgard beam transporters

## Configuration

### Basic Configuration
```lua
-- Enable/disable CAP integration
hyperdrive_config_set CAP Enabled true

-- Stargate network integration
hyperdrive_config_set CAP UseStargateNetwork true
hyperdrive_config_set CAP UseStargateAddresses true
hyperdrive_config_set CAP IntegrateWithDHD true

-- Shield system integration
hyperdrive_config_set CAP RespectShields true
hyperdrive_config_set CAP UseStargateProtection true

-- Energy system integration
hyperdrive_config_set CAP ShareEnergyWithStargates true
hyperdrive_config_set CAP RequireStargateEnergy false

-- Conflict prevention
hyperdrive_config_set CAP PreventConflicts true
hyperdrive_config_set CAP CheckStargateStatus true
```

### Advanced Configuration
```lua
-- Monitoring system
hyperdrive_config_set CAP EnableMonitoring true
hyperdrive_config_set CAP MonitoringInterval 30

-- Performance tuning
hyperdrive_config_set CAP EntityScanRadius 2000
hyperdrive_config_set CAP EnergyShareRadius 1500
hyperdrive_config_set CAP ConflictCheckRadius 1000

-- Alert thresholds
hyperdrive_config_set CAP LowEnergyThreshold 1000
hyperdrive_config_set CAP HighConflictThreshold 5
```

## Console Commands

### Validation Commands
```lua
hyperdrive_cap_validate          -- Comprehensive CAP compatibility check
hyperdrive_cap_status            -- CAP framework and integration status
hyperdrive_cap_destinations      -- List available Stargate destinations
```

### Testing Commands
```lua
hyperdrive_cap_test_all          -- Run all CAP integration tests
hyperdrive_cap_test_single <name> -- Run specific test
```

### Monitoring Commands
```lua
hyperdrive_cap_monitoring_start   -- Start monitoring system
hyperdrive_cap_monitoring_stop    -- Stop monitoring system
hyperdrive_cap_monitoring_status  -- Show monitoring status
```

## Integration Features

### 1. Stargate Network Integration

**Address-Based Navigation**
- Use Stargate addresses as hyperdrive destinations
- Automatic network discovery and cataloging
- Real-time address resolution and validation

**Network Management**
```lua
-- Get all available Stargate destinations
local destinations = HYPERDRIVE.CAP.GetStargateDestinations()

-- Resolve specific Stargate address
local stargate = HYPERDRIVE.CAP.ResolveStargateAddress("ABCDEFG")
```

### 2. Shield System Integration

**Shield Detection and Respect**
- Detect CAP shield systems automatically
- Prevent hyperdrive jumps into shielded areas
- Adjust gravity based on shield presence

**Shield Validation**
```lua
-- Check if position is protected by shields
local isShielded = HYPERDRIVE.CAP.IsPositionShielded(position)

-- Validate destination for shield conflicts
local isValid, issues = HYPERDRIVE.CAP.ValidateDestination(destination, engine)
```

### 3. Energy System Integration

**Power Sharing**
- Share energy between hyperdrive and Stargate systems
- Support for ZPMs, Naquadah generators, and other CAP energy sources
- Intelligent energy distribution and management

**Energy Management**
```lua
-- Manage energy sharing for hyperdrive operation
local hasEnergy, consumed = HYPERDRIVE.CAP.ManageEnergySharing(engine, energyRequired)
```

### 4. Conflict Prevention

**Active Stargate Detection**
- Detect active Stargate operations (dialing, open gates)
- Prevent interference with ongoing Stargate activities
- Safe distance calculations and validation

**Conflict Checking**
```lua
-- Check for Stargate conflicts
local hasConflicts, conflicts = HYPERDRIVE.CAP.CheckStargateConflicts(engine, destination)
```

### 5. Advanced Entity Movement

**CAP-Aware Movement**
- Special handling for CAP entities during hyperdrive jumps
- Temporary shield disabling during movement
- Stargate network position updates

**Safe Movement**
```lua
-- Move entities with CAP awareness
local result = HYPERDRIVE.CAP.MoveEntitiesWithCAP_Awareness(entities, destination, engine)
```

## Testing Framework

### Automated Tests

The CAP integration includes a comprehensive testing framework:

1. **CAP Framework Detection** - Verify CAP is loaded and functional
2. **Entity Detection** - Test CAP entity detection and categorization
3. **Shield System** - Validate shield system integration
4. **Energy System** - Test energy sharing and management
5. **Stargate Network** - Verify network discovery and management
6. **Address Resolution** - Test Stargate address resolution
7. **Conflict Detection** - Validate conflict prevention systems
8. **Configuration** - Test configuration system functionality

### Running Tests
```lua
-- Run all tests
hyperdrive_cap_test_all

-- Run specific test
hyperdrive_cap_test_single CAP_Framework_Detection
```

## Monitoring System

### Real-Time Monitoring

The monitoring system provides:
- **Framework Status** - CAP availability and health
- **Entity States** - Real-time entity monitoring
- **Energy Systems** - Power generation and consumption tracking
- **Network Health** - Stargate network status
- **Conflict Detection** - Ongoing conflict monitoring
- **Performance Metrics** - System performance tracking

### Alerts and Notifications

Automatic alerts for:
- CAP framework issues
- Low energy conditions
- High conflict situations
- Network problems
- Performance degradation

### Monitoring Data
```lua
-- Check monitoring status
hyperdrive_cap_monitoring_status

-- View recent alerts
local alerts = HYPERDRIVE.CAP.Monitoring.State.alerts

-- Access performance metrics
local perf = HYPERDRIVE.CAP.Monitoring.State.performance
```

## Best Practices

### 1. Ship Configuration
- Place hyperdrive engines away from active Stargates
- Ensure adequate energy sources (ZPMs, Naquadah generators)
- Consider shield placement for protection without interference

### 2. Energy Management
- Use multiple energy sources for redundancy
- Monitor energy levels before long-distance jumps
- Configure energy sharing thresholds appropriately

### 3. Conflict Avoidance
- Check for active Stargate operations before jumping
- Maintain safe distances from Stargate event horizons
- Use validation commands before critical operations

### 4. Network Integration
- Keep Stargate addresses updated in the network
- Use DHDs for enhanced integration
- Monitor network health regularly

## Troubleshooting

### Common Issues

**CAP Not Detected**
- Ensure CAP is properly installed and loaded
- Check for CAP version compatibility
- Verify StarGate global is available

**Energy Sharing Problems**
- Check energy source proximity (within 1500 units)
- Verify energy sources have sufficient power
- Ensure energy sharing is enabled in configuration

**Shield Conflicts**
- Validate shield detection is working
- Check shield entity classes are recognized
- Verify position checking functions

**Network Issues**
- Ensure Stargates have valid addresses
- Check Stargate entity detection
- Verify network discovery is functioning

### Debug Commands
```lua
-- Check CAP framework status
hyperdrive_cap_status

-- Validate ship configuration
hyperdrive_cap_validate

-- Run diagnostic tests
hyperdrive_cap_test_all
```

## API Reference

### Core Functions
- `HYPERDRIVE.CAP.IsCAP_Loaded()` - Check CAP availability
- `HYPERDRIVE.CAP.DetectCAPEntities(engine, radius)` - Detect CAP entities
- `HYPERDRIVE.CAP.ValidateShipConfiguration(engine)` - Validate ship setup

### Network Functions
- `HYPERDRIVE.CAP.GetStargateDestinations()` - Get network destinations
- `HYPERDRIVE.CAP.ResolveStargateAddress(address)` - Resolve address

### Energy Functions
- `HYPERDRIVE.CAP.ManageEnergySharing(engine, required)` - Manage energy

### Conflict Functions
- `HYPERDRIVE.CAP.CheckStargateConflicts(engine, dest)` - Check conflicts
- `HYPERDRIVE.CAP.IsPositionShielded(position)` - Check shield protection

This comprehensive CAP integration makes the hyperdrive system fully compatible with Carter Addon Pack, providing seamless integration with Stargate-themed gameplay while maintaining the advanced features and reliability of the hyperdrive system.
