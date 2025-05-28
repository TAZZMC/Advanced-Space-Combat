-- Hyperdrive Error Handling and Recovery System
-- Advanced error detection, logging, and automatic recovery mechanisms

if CLIENT then return end

-- Initialize error recovery system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.ErrorRecovery = HYPERDRIVE.ErrorRecovery or {}

print("[Hyperdrive] Error handling and recovery system loading...")

-- Error recovery configuration
HYPERDRIVE.ErrorRecovery.Config = {
    EnableRecovery = true,          -- Enable automatic error recovery
    MaxRetryAttempts = 3,           -- Maximum retry attempts
    RetryDelay = 2.0,               -- Delay between retries (seconds)
    AutoBackup = true,              -- Enable automatic state backup
    DetailedLogging = true,         -- Enable detailed error logging
    NotifyAdmins = true,            -- Notify admins of critical errors
    RecoveryTimeout = 30,           -- Recovery operation timeout (seconds)
    BackupInterval = 300,           -- Backup interval (seconds)
}

-- Error tracking state
HYPERDRIVE.ErrorRecovery.State = {
    errorLog = {},
    retryQueue = {},
    backupStates = {},
    recoveryOperations = {},
    lastBackup = 0,
    totalErrors = 0,
    recoveredErrors = 0,
    criticalErrors = 0,
}

-- Error severity levels
HYPERDRIVE.ErrorRecovery.Severity = {
    LOW = {level = 1, name = "Low", color = Color(100, 255, 100)},
    MEDIUM = {level = 2, name = "Medium", color = Color(255, 255, 100)},
    HIGH = {level = 3, name = "High", color = Color(255, 150, 100)},
    CRITICAL = {level = 4, name = "Critical", color = Color(255, 100, 100)},
}

-- Network strings for error reporting
util.AddNetworkString("hyperdrive_error_notification")
util.AddNetworkString("hyperdrive_recovery_status")

-- Function to get error recovery configuration
local function GetErrorConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("ErrorRecovery", key, HYPERDRIVE.ErrorRecovery.Config[key] or default)
    end
    return HYPERDRIVE.ErrorRecovery.Config[key] or default
end

-- Log error with context information
function HYPERDRIVE.ErrorRecovery.LogError(message, severity, context, stackTrace)
    local errorEntry = {
        message = message,
        severity = severity or HYPERDRIVE.ErrorRecovery.Severity.MEDIUM,
        context = context or {},
        stackTrace = stackTrace or debug.traceback(),
        timestamp = CurTime(),
        id = HYPERDRIVE.ErrorRecovery.State.totalErrors + 1
    }
    
    -- Add to error log
    table.insert(HYPERDRIVE.ErrorRecovery.State.errorLog, errorEntry)
    HYPERDRIVE.ErrorRecovery.State.totalErrors = HYPERDRIVE.ErrorRecovery.State.totalErrors + 1
    
    -- Update severity counters
    if severity.level >= HYPERDRIVE.ErrorRecovery.Severity.CRITICAL.level then
        HYPERDRIVE.ErrorRecovery.State.criticalErrors = HYPERDRIVE.ErrorRecovery.State.criticalErrors + 1
    end
    
    -- Limit log size
    local maxLogEntries = 1000
    while #HYPERDRIVE.ErrorRecovery.State.errorLog > maxLogEntries do
        table.remove(HYPERDRIVE.ErrorRecovery.State.errorLog, 1)
    end
    
    -- Console output
    if GetErrorConfig("DetailedLogging", true) then
        local severityName = severity.name:upper()
        print(string.format("[Hyperdrive Error] [%s] %s", severityName, message))
        
        if context and table.Count(context) > 0 then
            print("[Hyperdrive Error] Context:")
            for key, value in pairs(context) do
                print(string.format("  • %s: %s", key, tostring(value)))
            end
        end
    end
    
    -- Notify admins of critical errors
    if GetErrorConfig("NotifyAdmins", true) and severity.level >= HYPERDRIVE.ErrorRecovery.Severity.HIGH.level then
        HYPERDRIVE.ErrorRecovery.NotifyAdmins(errorEntry)
    end
    
    -- Add to monitoring system if available
    if HYPERDRIVE.Monitoring and HYPERDRIVE.Monitoring.SendAlert then
        local alertLevel = HYPERDRIVE.Monitoring.AlertLevels.ERROR
        if severity.level >= HYPERDRIVE.ErrorRecovery.Severity.CRITICAL.level then
            alertLevel = HYPERDRIVE.Monitoring.AlertLevels.CRITICAL
        end
        
        HYPERDRIVE.Monitoring.SendAlert(message, alertLevel, context.engineId, context)
    end
    
    return errorEntry.id
end

-- Create backup of entity state
function HYPERDRIVE.ErrorRecovery.CreateBackup(engine, entities)
    if not GetErrorConfig("AutoBackup", true) or not IsValid(engine) then return nil end
    
    local backup = {
        engineId = engine:EntIndex(),
        enginePos = engine:GetPos(),
        engineAngles = engine:GetAngles(),
        entities = {},
        timestamp = CurTime()
    }
    
    for _, ent in ipairs(entities or {}) do
        if IsValid(ent) then
            local entBackup = {
                entIndex = ent:EntIndex(),
                class = ent:GetClass(),
                position = ent:GetPos(),
                angles = ent:GetAngles(),
                velocity = Vector(0, 0, 0),
                angularVelocity = Vector(0, 0, 0)
            }
            
            if ent:GetPhysicsObject():IsValid() then
                entBackup.velocity = ent:GetPhysicsObject():GetVelocity()
                entBackup.angularVelocity = ent:GetPhysicsObject():GetAngularVelocity()
            end
            
            table.insert(backup.entities, entBackup)
        end
    end
    
    -- Store backup
    local backupId = "backup_" .. engine:EntIndex() .. "_" .. CurTime()
    HYPERDRIVE.ErrorRecovery.State.backupStates[backupId] = backup
    
    -- Limit backup count
    local maxBackups = 50
    local backupCount = table.Count(HYPERDRIVE.ErrorRecovery.State.backupStates)
    if backupCount > maxBackups then
        -- Remove oldest backup
        local oldestTime = math.huge
        local oldestId = nil
        
        for id, backupData in pairs(HYPERDRIVE.ErrorRecovery.State.backupStates) do
            if backupData.timestamp < oldestTime then
                oldestTime = backupData.timestamp
                oldestId = id
            end
        end
        
        if oldestId then
            HYPERDRIVE.ErrorRecovery.State.backupStates[oldestId] = nil
        end
    end
    
    HYPERDRIVE.ErrorRecovery.State.lastBackup = CurTime()
    return backupId
end

-- Restore from backup
function HYPERDRIVE.ErrorRecovery.RestoreFromBackup(backupId)
    local backup = HYPERDRIVE.ErrorRecovery.State.backupStates[backupId]
    if not backup then return false, "Backup not found" end
    
    local engine = Entity(backup.engineId)
    if not IsValid(engine) then return false, "Engine no longer exists" end
    
    local restoredCount = 0
    local failedCount = 0
    
    -- Restore engine
    engine:SetPos(backup.enginePos)
    engine:SetAngles(backup.engineAngles)
    restoredCount = restoredCount + 1
    
    -- Restore entities
    for _, entData in ipairs(backup.entities) do
        local ent = Entity(entData.entIndex)
        if IsValid(ent) then
            ent:SetPos(entData.position)
            ent:SetAngles(entData.angles)
            
            if ent:GetPhysicsObject():IsValid() then
                ent:GetPhysicsObject():SetVelocity(entData.velocity)
                ent:GetPhysicsObject():SetAngularVelocity(entData.angularVelocity)
            end
            
            restoredCount = restoredCount + 1
        else
            failedCount = failedCount + 1
        end
    end
    
    local message = string.format("Restored %d entities, %d failed", restoredCount, failedCount)
    HYPERDRIVE.ErrorRecovery.LogError("Backup restoration completed: " .. message, 
        HYPERDRIVE.ErrorRecovery.Severity.LOW, {backupId = backupId, restored = restoredCount, failed = failedCount})
    
    return true, message
end

-- Retry failed operation
function HYPERDRIVE.ErrorRecovery.RetryOperation(operationId, operation, context)
    if not GetErrorConfig("EnableRecovery", true) then return false end
    
    local retryData = HYPERDRIVE.ErrorRecovery.State.retryQueue[operationId]
    if not retryData then
        retryData = {
            operation = operation,
            context = context,
            attempts = 0,
            lastAttempt = 0,
            maxAttempts = GetErrorConfig("MaxRetryAttempts", 3),
            retryDelay = GetErrorConfig("RetryDelay", 2.0)
        }
        HYPERDRIVE.ErrorRecovery.State.retryQueue[operationId] = retryData
    end
    
    local currentTime = CurTime()
    if currentTime - retryData.lastAttempt < retryData.retryDelay then
        return false -- Too soon to retry
    end
    
    if retryData.attempts >= retryData.maxAttempts then
        HYPERDRIVE.ErrorRecovery.LogError("Operation failed after maximum retry attempts", 
            HYPERDRIVE.ErrorRecovery.Severity.HIGH, {operationId = operationId, attempts = retryData.attempts})
        HYPERDRIVE.ErrorRecovery.State.retryQueue[operationId] = nil
        return false
    end
    
    retryData.attempts = retryData.attempts + 1
    retryData.lastAttempt = currentTime
    
    -- Execute operation with error handling
    local success, result = pcall(operation, context)
    
    if success then
        HYPERDRIVE.ErrorRecovery.LogError("Operation recovered successfully", 
            HYPERDRIVE.ErrorRecovery.Severity.LOW, {operationId = operationId, attempts = retryData.attempts})
        HYPERDRIVE.ErrorRecovery.State.recoveredErrors = HYPERDRIVE.ErrorRecovery.State.recoveredErrors + 1
        HYPERDRIVE.ErrorRecovery.State.retryQueue[operationId] = nil
        return true, result
    else
        HYPERDRIVE.ErrorRecovery.LogError("Retry attempt failed: " .. tostring(result), 
            HYPERDRIVE.ErrorRecovery.Severity.MEDIUM, {operationId = operationId, attempts = retryData.attempts})
        return false, result
    end
end

-- Notify admins of errors
function HYPERDRIVE.ErrorRecovery.NotifyAdmins(errorEntry)
    local admins = {}
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:IsAdmin() then
            table.insert(admins, ply)
        end
    end
    
    if #admins > 0 then
        net.Start("hyperdrive_error_notification")
        net.WriteTable(errorEntry)
        net.Send(admins)
    end
end

-- Safe execution wrapper
function HYPERDRIVE.ErrorRecovery.SafeExecute(func, context, operationName)
    local success, result = pcall(func, context)
    
    if not success then
        local errorId = HYPERDRIVE.ErrorRecovery.LogError("Safe execution failed: " .. tostring(result), 
            HYPERDRIVE.ErrorRecovery.Severity.MEDIUM, context, debug.traceback())
        
        -- Queue for retry if recovery is enabled
        if GetErrorConfig("EnableRecovery", true) then
            local operationId = operationName .. "_" .. (context.engineId or "unknown") .. "_" .. CurTime()
            timer.Simple(GetErrorConfig("RetryDelay", 2.0), function()
                HYPERDRIVE.ErrorRecovery.RetryOperation(operationId, func, context)
            end)
        end
        
        return false, result, errorId
    end
    
    return true, result
end

-- Get error statistics
function HYPERDRIVE.ErrorRecovery.GetStatistics()
    return {
        totalErrors = HYPERDRIVE.ErrorRecovery.State.totalErrors,
        recoveredErrors = HYPERDRIVE.ErrorRecovery.State.recoveredErrors,
        criticalErrors = HYPERDRIVE.ErrorRecovery.State.criticalErrors,
        recoveryRate = HYPERDRIVE.ErrorRecovery.State.totalErrors > 0 and 
                      (HYPERDRIVE.ErrorRecovery.State.recoveredErrors / HYPERDRIVE.ErrorRecovery.State.totalErrors) or 0,
        activeRetries = table.Count(HYPERDRIVE.ErrorRecovery.State.retryQueue),
        backupCount = table.Count(HYPERDRIVE.ErrorRecovery.State.backupStates),
        lastBackup = HYPERDRIVE.ErrorRecovery.State.lastBackup
    }
end

-- Cleanup old data
function HYPERDRIVE.ErrorRecovery.Cleanup()
    local currentTime = CurTime()
    local maxAge = 3600 -- 1 hour
    
    -- Clean up old error log entries
    for i = #HYPERDRIVE.ErrorRecovery.State.errorLog, 1, -1 do
        local entry = HYPERDRIVE.ErrorRecovery.State.errorLog[i]
        if currentTime - entry.timestamp > maxAge then
            table.remove(HYPERDRIVE.ErrorRecovery.State.errorLog, i)
        end
    end
    
    -- Clean up old backups
    for id, backup in pairs(HYPERDRIVE.ErrorRecovery.State.backupStates) do
        if currentTime - backup.timestamp > maxAge then
            HYPERDRIVE.ErrorRecovery.State.backupStates[id] = nil
        end
    end
    
    -- Clean up stale retry operations
    for id, retryData in pairs(HYPERDRIVE.ErrorRecovery.State.retryQueue) do
        if currentTime - retryData.lastAttempt > 300 then -- 5 minutes
            HYPERDRIVE.ErrorRecovery.State.retryQueue[id] = nil
        end
    end
end

-- Automatic backup timer
timer.Create("HyperdriveErrorRecoveryBackup", GetErrorConfig("BackupInterval", 300), 0, function()
    -- This will be called by individual engines when they perform operations
end)

-- Cleanup timer
timer.Create("HyperdriveErrorRecoveryCleanup", 3600, 0, function()
    HYPERDRIVE.ErrorRecovery.Cleanup()
end)

-- Console commands for error management
concommand.Add("hyperdrive_error_stats", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local stats = HYPERDRIVE.ErrorRecovery.GetStatistics()
    
    ply:ChatPrint("[Hyperdrive Error Recovery] Statistics:")
    ply:ChatPrint("  • Total Errors: " .. stats.totalErrors)
    ply:ChatPrint("  • Recovered Errors: " .. stats.recoveredErrors)
    ply:ChatPrint("  • Critical Errors: " .. stats.criticalErrors)
    ply:ChatPrint("  • Recovery Rate: " .. string.format("%.1f%%", stats.recoveryRate * 100))
    ply:ChatPrint("  • Active Retries: " .. stats.activeRetries)
    ply:ChatPrint("  • Backup Count: " .. stats.backupCount)
    ply:ChatPrint("  • Last Backup: " .. string.format("%.1fs ago", CurTime() - stats.lastBackup))
end)

concommand.Add("hyperdrive_error_log", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local count = tonumber(args[1]) or 10
    local errorLog = HYPERDRIVE.ErrorRecovery.State.errorLog
    
    ply:ChatPrint("[Hyperdrive Error Recovery] Recent Errors (last " .. count .. "):")
    
    local startIdx = math.max(1, #errorLog - count + 1)
    for i = startIdx, #errorLog do
        local entry = errorLog[i]
        local timeAgo = string.format("%.1fs ago", CurTime() - entry.timestamp)
        ply:ChatPrint(string.format("  • [%s] %s (%s)", entry.severity.name, entry.message, timeAgo))
    end
end)

print("[Hyperdrive] Error handling and recovery system loaded")
