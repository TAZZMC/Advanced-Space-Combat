# Hyperdrive Addon Deployment Guide

This comprehensive guide covers installation, configuration, and deployment of the enhanced hyperdrive addon system for production servers.

## Prerequisites

### Server Requirements
- **Garry's Mod**: Version 13+ (latest recommended)
- **Operating System**: Windows/Linux server
- **RAM**: Minimum 4GB (8GB+ recommended for large servers)
- **Storage**: 500MB free space for addon and data
- **Network**: Stable connection with adequate bandwidth

### Optional Dependencies
- **Space Combat 2**: For enhanced SC2 integration
- **Spacebuild 3**: For enhanced SB3 integration
- **Wiremod**: For advanced control interfaces
- **Stargate**: For cross-addon compatibility

## Installation

### Method 1: Workshop Installation (Recommended)
1. Subscribe to the addon on Steam Workshop
2. Server will automatically download on restart
3. Configure via console commands or config files

### Method 2: Manual Installation
1. Download addon files from repository
2. Extract to `garrysmod/addons/hyperdrive_enhanced/`
3. Ensure proper file structure:
```
garrysmod/addons/hyperdrive_enhanced/
├── lua/
│   ├── autorun/
│   │   ├── hyperdrive_*.lua
│   │   └── server/
│   └── entities/
├── materials/
├── models/
└── addon.json
```

### Method 3: Git Deployment
```bash
cd garrysmod/addons/
git clone <repository_url> hyperdrive_enhanced
```

## Initial Configuration

### 1. Basic Setup
Run these commands on first installation:
```lua
# Enable all integrations
hyperdrive_config_set SpaceCombat2 Enabled true
hyperdrive_config_set Spacebuild3 Enabled true

# Configure performance settings
hyperdrive_config_set Performance EnableProfiling true
hyperdrive_config_set Performance MaxEntitiesPerBatch 32

# Enable monitoring
hyperdrive_config_set Monitoring EnableMonitoring true
hyperdrive_config_set Monitoring EnableAlerts true
```

### 2. Integration Detection
Check which integrations are available:
```lua
hyperdrive_integration_status
hyperdrive_sc2_status
hyperdrive_test_all
```

### 3. Performance Optimization
Configure for your server size:

**Small Server (1-20 players):**
```lua
hyperdrive_config_set Performance MaxEntitiesPerBatch 16
hyperdrive_config_set Network BatchSize 16
hyperdrive_config_set ErrorRecovery MaxRetryAttempts 2
```

**Medium Server (20-50 players):**
```lua
hyperdrive_config_set Performance MaxEntitiesPerBatch 32
hyperdrive_config_set Network BatchSize 32
hyperdrive_config_set ErrorRecovery MaxRetryAttempts 3
```

**Large Server (50+ players):**
```lua
hyperdrive_config_set Performance MaxEntitiesPerBatch 64
hyperdrive_config_set Network BatchSize 64
hyperdrive_config_set ErrorRecovery MaxRetryAttempts 5
hyperdrive_config_set Network MaxBandwidth 2000000
```

## Configuration Files

### Server Configuration (server.cfg)
Add these convars to your server.cfg:
```
# Hyperdrive performance settings
hyperdrive_enable_analytics 1
hyperdrive_enable_monitoring 1
hyperdrive_auto_backup 1

# Network optimization
hyperdrive_network_optimization 1
hyperdrive_batch_movement 1

# Error recovery
hyperdrive_error_recovery 1
hyperdrive_auto_retry 1
```

### Addon Configuration (data/hyperdrive/config.json)
Create custom configuration file:
```json
{
  "SpaceCombat2": {
    "UseGyropodMovement": true,
    "UseShipCore": true,
    "OverrideGravity": true
  },
  "Performance": {
    "EnableProfiling": true,
    "MaxEntitiesPerBatch": 32,
    "CacheEntityLists": true
  },
  "Monitoring": {
    "EnableMonitoring": true,
    "EnableAlerts": true,
    "HealthCheckInterval": 10
  }
}
```

## Production Deployment

### 1. Pre-Deployment Testing
Before deploying to production:

```lua
# Run comprehensive tests
hyperdrive_test_all

# Check system status
hyperdrive_monitoring_status
hyperdrive_admin_status

# Validate integrations
hyperdrive_sc2_status
hyperdrive_integration_status
```

### 2. Gradual Rollout
1. **Test Server**: Deploy and test with small group
2. **Staging**: Test with larger group and full features
3. **Production**: Deploy with monitoring enabled

### 3. Monitoring Setup
Enable comprehensive monitoring:
```lua
# Enable all monitoring features
hyperdrive_config_set Monitoring EnableMonitoring true
hyperdrive_config_set Monitoring EnableAlerts true
hyperdrive_config_set Analytics EnableAnalytics true

# Configure alert thresholds
hyperdrive_config_set Monitoring CriticalEnergyThreshold 10
hyperdrive_config_set Monitoring WarningEnergyThreshold 25
hyperdrive_config_set Monitoring MaxJumpFailures 3
```

## Backup and Recovery

### 1. Automatic Backups
Configure automatic backups:
```lua
hyperdrive_config_set Backup EnableAutoBackup true
hyperdrive_config_set Backup BackupInterval 3600
hyperdrive_config_set Backup MaxBackups 24
```

### 2. Manual Backup
Create manual backup before major changes:
```lua
hyperdrive_backup_create pre_update_backup
```

### 3. Recovery Procedures
In case of issues:
```lua
# List available backups
hyperdrive_backup_list

# Restore from backup
hyperdrive_backup_restore backup_name

# Emergency stop all operations
hyperdrive_admin_emergency_stop
```

## Performance Tuning

### 1. Entity Detection Optimization
```lua
# Use ship core detection for accuracy
hyperdrive_config_set SpaceCombat2 UseShipCore true
hyperdrive_config_set Spacebuild3 UseShipCore true

# Enable entity caching
hyperdrive_config_set Performance CacheEntityLists true
hyperdrive_config_set Performance MaxCacheAge 30
```

### 2. Network Optimization
```lua
# Enable network optimizations
hyperdrive_config_set Network EnableOptimization true
hyperdrive_config_set Network DeltaCompression true
hyperdrive_config_set Network AdaptiveBatching true

# Adjust batch sizes based on server load
hyperdrive_config_set Network BatchSize 32
hyperdrive_config_set Network BatchDelay 0.005
```

### 3. Memory Management
```lua
# Enable memory optimization
hyperdrive_config_set Performance MemoryOptimization true
hyperdrive_config_set Performance EnableProfiling true

# Configure cleanup intervals
hyperdrive_config_set Performance MaxCacheAge 30
```

## Security Considerations

### 1. Admin Access Control
```lua
# Require admin access for sensitive commands
hyperdrive_config_set AdminPanel RequireAdmin true
hyperdrive_config_set AdminPanel RequireSuperAdmin false

# Enable action logging
hyperdrive_config_set AdminPanel LogAdminActions true
```

### 2. Data Privacy
```lua
# Enable privacy mode for analytics
hyperdrive_config_set Analytics PrivacyMode true

# Disable telemetry if required
hyperdrive_config_set Analytics EnableTelemetry false
```

### 3. Backup Security
```lua
# Enable backup encryption (if available)
hyperdrive_config_set Backup EncryptionEnabled true

# Limit backup data
hyperdrive_config_set Backup IncludeAnalytics false
```

## Troubleshooting

### Common Issues and Solutions

#### High Memory Usage
```lua
# Check memory statistics
hyperdrive_perf_stats

# Clear caches
hyperdrive_perf_clear

# Reduce cache size
hyperdrive_config_set Performance MaxCacheAge 15
```

#### Network Lag During Jumps
```lua
# Check network statistics
hyperdrive_network_stats

# Reduce batch size
hyperdrive_config_set Network BatchSize 16

# Increase batch delay
hyperdrive_config_set Network BatchDelay 0.01
```

#### Entity Detection Issues
```lua
# Validate ship configuration
hyperdrive_sc2_validate
hyperdrive_sb3_validate

# Check integration status
hyperdrive_integration_status

# Test entity detection
hyperdrive_test_single Entity_Detection
```

### Diagnostic Commands
```lua
# System health check
hyperdrive_monitoring_status
hyperdrive_admin_status

# Performance analysis
hyperdrive_perf_stats
hyperdrive_analytics_report 3600

# Error analysis
hyperdrive_error_stats
hyperdrive_error_log 20

# Integration testing
hyperdrive_test_all
hyperdrive_sc2_status
```

## Maintenance

### Daily Tasks
- Check system health: `hyperdrive_monitoring_status`
- Review error logs: `hyperdrive_error_log 50`
- Monitor performance: `hyperdrive_perf_stats`

### Weekly Tasks
- Review analytics: `hyperdrive_analytics_report 604800`
- Clean up old data: `hyperdrive_perf_clear`
- Verify backups: `hyperdrive_backup_list`

### Monthly Tasks
- Update configuration based on usage patterns
- Review and optimize performance settings
- Test backup restoration procedures
- Update documentation and procedures

## Support and Updates

### Getting Help
1. Check error logs: `hyperdrive_error_log`
2. Run diagnostics: `hyperdrive_test_all`
3. Review system status: `hyperdrive_admin_status`
4. Check documentation files

### Update Procedures
1. Create backup: `hyperdrive_backup_create pre_update`
2. Test on staging server
3. Deploy during low-traffic period
4. Monitor for issues post-deployment
5. Rollback if necessary: `hyperdrive_backup_restore pre_update`

### Version Migration
The system includes automatic migration capabilities:
- Backups are created before migrations
- Configuration is automatically updated
- Data structures are migrated as needed
- Rollback procedures are available

For additional support, refer to the comprehensive documentation files included with the addon.
