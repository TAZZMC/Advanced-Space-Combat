# Enhanced Hyperdrive System - Troubleshooting Guide

Comprehensive troubleshooting guide for resolving common issues with the Enhanced Hyperdrive System v2.1.0.

## 🔍 Quick Diagnostics

### System Status Check
Run these commands in console to check system status:

```lua
-- Overall system status
hyperdrive_status

-- Integration status
hyperdrive_integration_status

-- CAP integration check
hyperdrive_cap_status

-- Performance metrics
hyperdrive_performance_check

-- Debug information
hyperdrive_debug_info
```

### Log File Locations
Check these files for detailed error information:
```
garrysmod/console.log                    -- General Garry's Mod logs
garrysmod/data/hyperdrive/debug.log      -- Hyperdrive debug logs
garrysmod/data/hyperdrive/errors.log     -- Error-specific logs
garrysmod/data/hyperdrive/performance.log -- Performance metrics
```

## 🚫 Common Issues and Solutions

### 1. Ship Core Not Detecting Ship

#### Symptoms
- Ship core shows "No ship detected"
- Hyperdrive engines won't activate
- Ship core interface shows empty entity list

#### Causes and Solutions

**Cause**: Ship core not properly welded to ship
```lua
Solution:
1. Ensure ship core is welded to ship structure
2. Use Weld tool (not just placed on top)
3. Verify weld connection with Weld Checker tool
```

**Cause**: Ship structure too complex or disconnected
```lua
Solution:
1. Check all ship parts are welded together
2. Remove any floating/unconnected parts
3. Simplify ship structure if too complex (>2000 entities)
4. Use "hyperdrive_debug_ship_detection 1" to see detection process
```

**Cause**: Multiple ship cores on same ship
```lua
Solution:
1. Remove duplicate ship cores (only one per ship allowed)
2. Check for hidden or duplicated cores
3. Use "find ship_core" to locate all cores
```

### 2. CAP Integration Not Working

#### Symptoms
- No CAP tab in ship core interface
- CAP status shows "Not Available"
- CAP entities not detected

#### Causes and Solutions

**Cause**: CAP not properly installed
```lua
Solution:
1. Verify CAP is subscribed and downloaded from Steam Workshop
2. Ensure CAP Resources addon is also installed
3. Check CAP loads before Enhanced Hyperdrive System
4. Restart Garry's Mod after CAP installation
```

**Cause**: CAP version incompatibility
```lua
Solution:
1. Update CAP to latest version (1.5.0+)
2. Update Enhanced Hyperdrive System to latest version
3. Check compatibility matrix in documentation
```

**Cause**: CAP integration disabled in settings
```lua
Solution:
1. Open Q Menu → Options → Enhanced Hyperdrive
2. Enable "CAP Integration"
3. Set "Prefer CAP Systems" to true
4. Restart map or reload addon
```

### 3. Hyperdrive Won't Charge

#### Symptoms
- Engine shows "Cannot charge" message
- Charging starts but immediately stops
- Energy level doesn't increase during charging

#### Causes and Solutions

**Cause**: Insufficient energy
```lua
Solution:
1. Check energy levels in ship core interface
2. Add more energy sources (batteries, generators)
3. Verify energy distribution is working
4. Check for energy leaks or high consumption
```

**Cause**: Hull damage too severe
```lua
Solution:
1. Check hull integrity in ship core interface
2. Repair hull using repair tools or ship core interface
3. Hull must be above 25% for hyperdrive operation
4. Use emergency repair if available
```

**Cause**: Missing ship core
```lua
Solution:
1. Ensure ship has a valid ship core
2. Ship core must show "Operational" status
3. Check ship core is properly welded to ship
```

**Cause**: Cooldown period active
```lua
Solution:
1. Wait for cooldown period to expire
2. Check cooldown timer in engine interface
3. Cooldown time varies based on jump distance and ship size
```

### 4. Visual Effects Not Displaying

#### Symptoms
- No visual effects during hyperdrive operations
- Effects appear in wrong location
- Effects are too dim or too bright

#### Causes and Solutions

**Cause**: Effects disabled in settings
```lua
Solution:
1. Open Q Menu → Options → Enhanced Hyperdrive
2. Enable "Visual Effects"
3. Set effect quality to appropriate level
4. Restart map to apply changes
```

**Cause**: Graphics card compatibility
```lua
Solution:
1. Update graphics drivers
2. Reduce effect quality in settings
3. Disable advanced effects if necessary
4. Check DirectX/OpenGL compatibility
```

**Cause**: Effect positioning issues
```lua
Solution:
1. Ensure ship core is centered on ship
2. Check ship orientation is correct
3. Verify ship bounds are calculated properly
4. Use "hyperdrive_debug_effects 1" for debugging
```

### 5. Performance Issues

#### Symptoms
- Low FPS during hyperdrive operations
- Server lag with multiple ships
- Memory usage constantly increasing

#### Causes and Solutions

**Cause**: Too many entities on ship
```lua
Solution:
1. Reduce ship complexity (aim for <1000 entities)
2. Remove unnecessary decorative elements
3. Use fewer, larger props instead of many small ones
4. Enable entity optimization in settings
```

**Cause**: High effect quality settings
```lua
Solution:
1. Reduce effect quality to "Medium" or "Low"
2. Decrease particle count in settings
3. Reduce effect range and duration
4. Disable 3D audio if not needed
```

**Cause**: Inefficient update intervals
```lua
Solution:
1. Increase update intervals in performance settings
2. Enable network optimization for multiplayer
3. Reduce monitoring frequency for non-critical systems
4. Use performance mode configuration preset
```

### 6. Multiplayer Synchronization Issues

#### Symptoms
- Ship appears in different locations for different players
- Hyperdrive effects not synchronized
- Ship core interface shows different data for different players

#### Causes and Solutions

**Cause**: Network optimization disabled
```lua
Solution:
1. Enable network optimization in server settings
2. Increase network update rate
3. Use compressed networking if available
4. Reduce network entity limit if necessary
```

**Cause**: High server latency
```lua
Solution:
1. Check server performance and reduce load
2. Increase network buffer sizes
3. Enable prediction systems
4. Consider server hardware upgrade
```

**Cause**: Addon conflicts
```lua
Solution:
1. Disable other ship/vehicle addons temporarily
2. Check for conflicting network modifications
3. Test with minimal addon set
4. Update all addons to latest versions
```

### 7. Spacebuild 3 Integration Problems

#### Symptoms
- Resources not flowing to ship components
- Auto-provisioning not working
- Resource levels not updating

#### Causes and Solutions

**Cause**: Spacebuild 3 not properly installed
```lua
Solution:
1. Install complete Spacebuild 3 package:
   - Spacebuild 3 Core
   - CAF (Community Addon Framework)
   - Resource Distribution (RD)
   - Life Support 2 (LS2)
2. Verify all components load successfully
```

**Cause**: Resource system not initialized
```lua
Solution:
1. Check ship core shows "Resource System Active"
2. Enable auto-provisioning in ship core settings
3. Manually initialize resource system if needed
4. Verify resource storage is properly configured
```

**Cause**: Weld detection issues
```lua
Solution:
1. Enable weld detection in ship core settings
2. Re-weld problematic entities
3. Check entity ownership and permissions
4. Use manual resource distribution if auto fails
```

### 8. Wiremod Integration Issues

#### Symptoms
- Wire inputs/outputs not appearing
- Wire connections not working
- Incorrect wire output values

#### Causes and Solutions

**Cause**: Wiremod not installed or outdated
```lua
Solution:
1. Install latest Wiremod from Steam Workshop
2. Verify Wiremod loads before Enhanced Hyperdrive
3. Check Wiremod functionality with other entities
```

**Cause**: Wire initialization failed
```lua
Solution:
1. Respawn hyperdrive entities
2. Check console for wire-related errors
3. Verify entity classes are properly registered
4. Use "wire_reload" command if available
```

**Cause**: Incorrect wire usage
```lua
Solution:
1. Check wire input/output names in documentation
2. Verify data types match (NORMAL, VECTOR, STRING)
3. Use correct value ranges for inputs
4. Check wire connections are secure
```

## 🔧 Advanced Troubleshooting

### Debug Mode Activation

Enable comprehensive debugging:
```lua
-- Enable all debug systems
hyperdrive_debug 1
hyperdrive_debug_ship_detection 1
hyperdrive_debug_cap_integration 1
hyperdrive_debug_effects 1
hyperdrive_debug_performance 1
hyperdrive_debug_networking 1

-- View debug information
hyperdrive_debug_dump
```

### Performance Profiling

Monitor system performance:
```lua
-- Start performance monitoring
hyperdrive_performance_start

-- View performance report
hyperdrive_performance_report

-- Reset performance counters
hyperdrive_performance_reset
```

### Network Diagnostics

For multiplayer issues:
```lua
-- Server-side network diagnostics
hyperdrive_network_status
hyperdrive_network_test

-- Client-side network diagnostics
hyperdrive_client_status
hyperdrive_sync_test
```

### Memory Analysis

Check for memory leaks:
```lua
-- Memory usage report
hyperdrive_memory_report

-- Garbage collection
hyperdrive_cleanup

-- Memory optimization
hyperdrive_optimize_memory
```

## 🛠️ Configuration Reset

### Reset to Defaults

If all else fails, reset configuration:
```lua
-- Reset all settings to defaults
hyperdrive_config_reset

-- Reset specific categories
hyperdrive_config_reset core
hyperdrive_config_reset cap
hyperdrive_config_reset performance
```

### Clean Installation

For persistent issues:
1. **Backup saves and configurations**
2. **Unsubscribe from addon**
3. **Delete addon files manually**:
   ```
   garrysmod/addons/enhanced_hyperdrive_system/
   garrysmod/data/hyperdrive/
   ```
4. **Restart Garry's Mod**
5. **Reinstall addon**
6. **Restore configurations if needed**

## 📞 Getting Additional Help

### Before Contacting Support

1. **Check this troubleshooting guide thoroughly**
2. **Review documentation** (README.md, CONFIGURATION.md)
3. **Test with minimal addon set** (disable other addons)
4. **Gather diagnostic information**:
   ```lua
   hyperdrive_generate_support_report
   ```

### Support Channels

1. **GitHub Issues**: For bug reports and feature requests
   - Include full error messages
   - Provide reproduction steps
   - Attach diagnostic reports

2. **Steam Workshop**: For general questions and community support
   - Check existing comments for similar issues
   - Provide system specifications

3. **Discord Community**: For real-time support
   - Join the community server (link in workshop)
   - Use appropriate support channels

### Information to Include

When seeking help, provide:
- **Exact error messages** from console
- **Steps to reproduce** the issue
- **System specifications** (OS, RAM, GPU)
- **Installed addons list**
- **Diagnostic report** output
- **Screenshots/videos** if applicable

## ✅ Prevention Tips

### Best Practices

1. **Regular Updates**: Keep addon and dependencies updated
2. **Clean Builds**: Rebuild ships periodically to prevent corruption
3. **Performance Monitoring**: Monitor system performance regularly
4. **Backup Configurations**: Save working configurations
5. **Test Changes**: Test configuration changes on test ships first

### Maintenance Schedule

**Weekly**:
- Check for addon updates
- Review error logs
- Clean up unused ships

**Monthly**:
- Full configuration backup
- Performance optimization review
- Clean installation if needed

**After Major Updates**:
- Test all ship systems
- Verify integration functionality
- Update configurations as needed

This troubleshooting guide covers the most common issues encountered with the Enhanced Hyperdrive System. For issues not covered here, please consult the support channels listed above.
