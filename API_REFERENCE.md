# Hyperdrive API Reference

This document provides a comprehensive API reference for developers who want to extend or integrate with the enhanced hyperdrive addon system.

## Core API

### HYPERDRIVE Global Table
The main namespace for all hyperdrive functionality.

```lua
HYPERDRIVE = {
    SpaceCombat2 = {},      -- SC2 integration functions
    Spacebuild = {},        -- SB3 integration functions
    Performance = {},       -- Performance optimization
    ShipDetection = {},     -- Ship classification
    Network = {},           -- Network optimization
    ErrorRecovery = {},     -- Error handling
    Monitoring = {},        -- Health monitoring
    Analytics = {},         -- Usage analytics
    Backup = {},            -- Backup system
    AdminPanel = {},        -- Administration
    UI = {},               -- User interface
    EnhancedConfig = {}     -- Configuration system
}
```

## Configuration API

### HYPERDRIVE.EnhancedConfig

#### Get Configuration Value
```lua
HYPERDRIVE.EnhancedConfig.Get(category, key, default)
```
- **category**: Configuration category (string)
- **key**: Configuration key (string)
- **default**: Default value if not found
- **Returns**: Configuration value

#### Set Configuration Value
```lua
HYPERDRIVE.EnhancedConfig.Set(category, key, value)
```
- **category**: Configuration category (string)
- **key**: Configuration key (string)
- **value**: Value to set

#### Check Integrations
```lua
local status = HYPERDRIVE.EnhancedConfig.CheckIntegrations()
```
- **Returns**: Table with integration status

## Space Combat 2 API

### HYPERDRIVE.SpaceCombat2

#### Find Ship Core
```lua
local shipCore = HYPERDRIVE.SpaceCombat2.FindShipCore(engine)
```
- **engine**: Hyperdrive engine entity
- **Returns**: Ship core entity or nil

#### Get Attached Entities
```lua
local entities = HYPERDRIVE.SpaceCombat2.GetAttachedEntities(engine)
```
- **engine**: Hyperdrive engine entity
- **Returns**: Table of attached entities

#### Move Ship
```lua
local success = HYPERDRIVE.SpaceCombat2.MoveShip(engine, destination)
```
- **engine**: Hyperdrive engine entity
- **destination**: Target position (Vector)
- **Returns**: Boolean success status

#### Override Gravity
```lua
HYPERDRIVE.SpaceCombat2.OverrideGravity(player, override)
```
- **player**: Player entity
- **override**: Boolean (true to override, false to restore)

#### Validate Ship Configuration
```lua
local isValid, issues = HYPERDRIVE.SpaceCombat2.ValidateShipConfiguration(engine)
```
- **engine**: Hyperdrive engine entity
- **Returns**: Boolean validity, table of issues

## Ship Detection API

### HYPERDRIVE.ShipDetection

#### Detect and Classify Ship
```lua
local detection = HYPERDRIVE.ShipDetection.DetectAndClassifyShip(engine, searchRadius)
```
- **engine**: Hyperdrive engine entity
- **searchRadius**: Search radius (optional)
- **Returns**: Detection table with entities, shipType, composition, movementStrategy

#### Calculate Optimized Energy Cost
```lua
local cost = HYPERDRIVE.ShipDetection.CalculateOptimizedEnergyCost(engine, destination, entities)
```
- **engine**: Hyperdrive engine entity
- **destination**: Target position (Vector)
- **entities**: Table of entities
- **Returns**: Calculated energy cost

#### Generate Ship Report
```lua
local report = HYPERDRIVE.ShipDetection.GenerateShipReport(engine)
```
- **engine**: Hyperdrive engine entity
- **Returns**: Detailed ship analysis report (string)

## Performance API

### HYPERDRIVE.Performance

#### Batch Move Entities
```lua
local success = HYPERDRIVE.Performance.BatchMoveEntities(entities, destination, enginePos)
```
- **entities**: Table of entities to move
- **destination**: Target position (Vector)
- **enginePos**: Engine position (Vector)
- **Returns**: Boolean success status

#### Get Statistics
```lua
local stats = HYPERDRIVE.Performance.GetStatistics()
```
- **Returns**: Performance statistics table

#### Optimized Entity Detection
```lua
local entities = HYPERDRIVE.Performance.OptimizedEntityDetection(engine, searchRadius)
```
- **engine**: Hyperdrive engine entity
- **searchRadius**: Search radius
- **Returns**: Table of detected entities

## Error Recovery API

### HYPERDRIVE.ErrorRecovery

#### Log Error
```lua
local errorId = HYPERDRIVE.ErrorRecovery.LogError(message, severity, context, stackTrace)
```
- **message**: Error message (string)
- **severity**: Error severity level
- **context**: Context information (table, optional)
- **stackTrace**: Stack trace (string, optional)
- **Returns**: Error ID

#### Create Backup
```lua
local backupId = HYPERDRIVE.ErrorRecovery.CreateBackup(engine, entities)
```
- **engine**: Hyperdrive engine entity
- **entities**: Table of entities to backup
- **Returns**: Backup ID or nil

#### Safe Execute
```lua
local success, result, errorId = HYPERDRIVE.ErrorRecovery.SafeExecute(func, context, operationName)
```
- **func**: Function to execute
- **context**: Context data for function
- **operationName**: Operation name for logging
- **Returns**: Success status, result, error ID

## Monitoring API

### HYPERDRIVE.Monitoring

#### Register Engine
```lua
HYPERDRIVE.Monitoring.RegisterEngine(engine)
```
- **engine**: Hyperdrive engine entity

#### Send Alert
```lua
HYPERDRIVE.Monitoring.SendAlert(message, level, engineId, data)
```
- **message**: Alert message (string)
- **level**: Alert level
- **engineId**: Engine ID (optional)
- **data**: Additional data (table, optional)

#### Record Jump Attempt
```lua
HYPERDRIVE.Monitoring.RecordJumpAttempt(engine, success, duration)
```
- **engine**: Hyperdrive engine entity
- **success**: Boolean success status
- **duration**: Jump duration in seconds (optional)

## Analytics API

### HYPERDRIVE.Analytics

#### Record Metric
```lua
HYPERDRIVE.Analytics.RecordMetric(metricType, value, metadata)
```
- **metricType**: Type of metric (string)
- **value**: Metric value
- **metadata**: Additional metadata (table, optional)

#### Generate Report
```lua
local report = HYPERDRIVE.Analytics.GenerateReport(timeframe)
```
- **timeframe**: Time window in seconds (optional)
- **Returns**: Analytics report table

#### Export Data
```lua
local data, contentType = HYPERDRIVE.Analytics.ExportData(format)
```
- **format**: Export format ("json" or "csv")
- **Returns**: Exported data string, content type

## Network API

### HYPERDRIVE.Network

#### Batch Move Entities
```lua
local success = HYPERDRIVE.Network.BatchMoveEntities(entities, destination, enginePos, players)
```
- **entities**: Table of entities to move
- **destination**: Target position (Vector)
- **enginePos**: Engine position (Vector)
- **players**: Table of players to update (optional)
- **Returns**: Boolean success status

#### Get Statistics
```lua
local stats = HYPERDRIVE.Network.GetStatistics()
```
- **Returns**: Network statistics table

## Backup API

### HYPERDRIVE.Backup

#### Create System Backup
```lua
local success, message = HYPERDRIVE.Backup.CreateSystemBackup(backupName)
```
- **backupName**: Backup name (optional)
- **Returns**: Success status, message

#### Restore From Backup
```lua
local success, result = HYPERDRIVE.Backup.RestoreFromBackup(backupName, options)
```
- **backupName**: Name of backup to restore
- **options**: Restore options table
- **Returns**: Success status, restore results

#### List Backups
```lua
local backups = HYPERDRIVE.Backup.ListBackups()
```
- **Returns**: Table of available backups

## Events and Hooks

### Custom Hooks
The system provides several custom hooks for integration:

#### HyperdriveJumpStart
```lua
hook.Add("HyperdriveJumpStart", "MyAddon", function(engine, destination, entities)
    -- Called when a hyperdrive jump starts
    -- Return false to cancel the jump
end)
```

#### HyperdriveJumpComplete
```lua
hook.Add("HyperdriveJumpComplete", "MyAddon", function(engine, destination, entities, success)
    -- Called when a hyperdrive jump completes
end)
```

#### HyperdriveEntityDetected
```lua
hook.Add("HyperdriveEntityDetected", "MyAddon", function(engine, entity, detectionMethod)
    -- Called when an entity is detected for hyperdrive transport
    -- Return false to exclude the entity
end)
```

#### HyperdriveErrorOccurred
```lua
hook.Add("HyperdriveErrorOccurred", "MyAddon", function(errorData)
    -- Called when an error occurs in the hyperdrive system
end)
```

## Entity Methods

### Hyperdrive Engine Entities

#### Core Methods
```lua
-- Energy management
engine:GetEnergy()
engine:SetEnergy(amount)
engine:GetMaxEnergy()

-- Destination management
engine:GetDestination()
engine:SetDestination(vector)
engine:SetDestinationPos(vector)

-- Jump control
engine:StartJump()
engine:AbortJump(reason)
engine:GetCooldown()
engine:SetCooldown(time)

-- Status
engine:GetCharging()
engine:IsJumping()
engine:GetOwner()
```

#### Enhanced Methods (if available)
```lua
-- Backup and restore
engine:CreateBackupData()
engine:RestoreBackupData(data)

-- Integration
engine:GetAttachedVehicle()
engine:GetShipClassification()
engine:GetPerformanceMetrics()
```

## Extension Examples

### Creating a Custom Integration
```lua
-- Register custom integration
HYPERDRIVE.MyIntegration = {}

function HYPERDRIVE.MyIntegration.GetAttachedEntities(engine)
    -- Custom entity detection logic
    local entities = {}
    -- ... implementation
    return entities
end

function HYPERDRIVE.MyIntegration.MoveShip(engine, destination)
    -- Custom movement logic
    -- ... implementation
    return true
end

-- Register with the system
hook.Add("HyperdriveEntityDetected", "MyIntegration", function(engine, entity, method)
    if method == "MyIntegration" then
        -- Custom validation logic
        return MyCustomValidation(entity)
    end
end)
```

### Adding Custom Metrics
```lua
-- Record custom metrics
HYPERDRIVE.Analytics.RecordMetric("custom_metric", value, {
    customData = "example",
    timestamp = CurTime()
})

-- Custom analytics processing
hook.Add("HyperdriveJumpComplete", "CustomAnalytics", function(engine, destination, entities, success)
    local distance = engine:GetPos():Distance(destination)
    HYPERDRIVE.Analytics.RecordMetric("jump_distance", distance, {
        entityCount = #entities,
        success = success
    })
end)
```

### Custom Error Handling
```lua
-- Custom error recovery
HYPERDRIVE.ErrorRecovery.RegisterCustomRecovery("MyError", function(context)
    -- Custom recovery logic
    return true, "Recovered successfully"
end)

-- Custom error logging
hook.Add("HyperdriveErrorOccurred", "CustomErrorHandler", function(errorData)
    if errorData.severity.level >= 3 then
        -- Send to external logging system
        MyExternalLogger.LogError(errorData)
    end
end)
```

## Best Practices

### Performance
- Use batch operations for multiple entities
- Cache entity lists when possible
- Implement proper cleanup in custom code
- Use the safe execution wrapper for error-prone operations

### Integration
- Always check for method existence before calling
- Provide fallback implementations
- Use the configuration system for settings
- Register with the monitoring system

### Error Handling
- Use the error recovery system for critical operations
- Provide meaningful error messages and context
- Implement proper cleanup in error scenarios
- Log errors with appropriate severity levels

### Testing
- Use the testing framework for validation
- Implement unit tests for custom functionality
- Test with various ship configurations
- Validate performance under load

This API reference provides the foundation for extending the hyperdrive system. For additional examples and detailed implementation guides, refer to the source code and documentation files.
