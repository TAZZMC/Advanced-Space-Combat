-- Hyperdrive Backup and Migration System
-- Comprehensive data backup, restoration, and migration capabilities

if CLIENT then return end

-- Initialize backup system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Backup = HYPERDRIVE.Backup or {}

print("[Hyperdrive] Backup and migration system loading...")

-- Backup configuration
HYPERDRIVE.Backup.Config = {
    EnableAutoBackup = true,        -- Enable automatic backups
    BackupInterval = 3600,          -- Backup interval (1 hour)
    MaxBackups = 24,                -- Maximum backup files to keep
    BackupPath = "data/hyperdrive/backups/", -- Backup directory
    CompressionEnabled = true,      -- Enable backup compression
    IncludeAnalytics = false,       -- Include analytics data in backups
    IncludeErrorLogs = true,        -- Include error logs in backups
    EncryptionEnabled = false,      -- Enable backup encryption
    MigrationEnabled = true,        -- Enable migration features
}

-- Backup state
HYPERDRIVE.Backup.State = {
    lastBackup = 0,
    backupQueue = {},
    migrationTasks = {},
    backupHistory = {},
    restoreOperations = {},
}

-- Function to get backup configuration
local function GetBackupConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("Backup", key, HYPERDRIVE.Backup.Config[key] or default)
    end
    return HYPERDRIVE.Backup.Config[key] or default
end

-- Create comprehensive system backup
function HYPERDRIVE.Backup.CreateSystemBackup(backupName)
    if not GetBackupConfig("EnableAutoBackup", true) then
        return false, "Auto backup is disabled"
    end
    
    backupName = backupName or ("auto_" .. os.date("%Y%m%d_%H%M%S"))
    
    local backupData = {
        metadata = {
            name = backupName,
            timestamp = os.time(),
            serverTime = CurTime(),
            version = "2.0.0",
            serverName = GetHostName(),
            playerCount = #player.GetAll(),
            mapName = game.GetMap(),
        },
        configuration = {},
        engines = {},
        analytics = {},
        errorLogs = {},
        monitoring = {},
        performance = {},
    }
    
    -- Backup configuration data
    if HYPERDRIVE.EnhancedConfig then
        backupData.configuration = table.Copy(HYPERDRIVE.EnhancedConfig)
    end
    
    -- Backup engine data
    local engines = ents.FindByClass("hyperdrive_*")
    for _, engine in ipairs(engines) do
        if IsValid(engine) and string.find(engine:GetClass(), "engine") then
            local engineData = {
                entIndex = engine:EntIndex(),
                class = engine:GetClass(),
                position = engine:GetPos(),
                angles = engine:GetAngles(),
                energy = engine.GetEnergy and engine:GetEnergy() or 0,
                destination = engine.GetDestination and engine:GetDestination() or Vector(0,0,0),
                owner = engine.GetOwner and IsValid(engine:GetOwner()) and engine:GetOwner():SteamID() or nil,
                customData = engine.BackupData or {}
            }
            
            table.insert(backupData.engines, engineData)
        end
    end
    
    -- Backup analytics data (if enabled)
    if GetBackupConfig("IncludeAnalytics", false) and HYPERDRIVE.Analytics then
        backupData.analytics = table.Copy(HYPERDRIVE.Analytics.Data)
    end
    
    -- Backup error logs (if enabled)
    if GetBackupConfig("IncludeErrorLogs", true) and HYPERDRIVE.ErrorRecovery then
        backupData.errorLogs = table.Copy(HYPERDRIVE.ErrorRecovery.State.errorLog)
    end
    
    -- Backup monitoring data
    if HYPERDRIVE.Monitoring then
        backupData.monitoring = {
            systemHealth = HYPERDRIVE.Monitoring.State.systemHealth,
            alertHistory = table.Copy(HYPERDRIVE.Monitoring.State.alertHistory),
            monitoredEngines = table.Count(HYPERDRIVE.Monitoring.State.monitoredEngines)
        }
    end
    
    -- Backup performance data
    if HYPERDRIVE.Performance then
        backupData.performance = table.Copy(HYPERDRIVE.Performance.Metrics)
    end
    
    -- Save backup to file
    local success, error = HYPERDRIVE.Backup.SaveBackupToFile(backupName, backupData)
    
    if success then
        -- Update backup history
        table.insert(HYPERDRIVE.Backup.State.backupHistory, {
            name = backupName,
            timestamp = os.time(),
            size = string.len(util.TableToJSON(backupData)),
            engineCount = #backupData.engines
        })
        
        HYPERDRIVE.Backup.State.lastBackup = CurTime()
        
        -- Cleanup old backups
        HYPERDRIVE.Backup.CleanupOldBackups()
        
        return true, "Backup created successfully: " .. backupName
    else
        return false, "Failed to save backup: " .. error
    end
end

-- Save backup data to file
function HYPERDRIVE.Backup.SaveBackupToFile(backupName, backupData)
    local backupPath = GetBackupConfig("BackupPath", "data/hyperdrive/backups/")
    
    -- Ensure backup directory exists
    if not file.Exists(backupPath, "GAME") then
        file.CreateDir(string.sub(backupPath, 1, -2)) -- Remove trailing slash
    end
    
    local fileName = backupPath .. backupName .. ".json"
    local jsonData = util.TableToJSON(backupData)
    
    -- Compress data if enabled
    if GetBackupConfig("CompressionEnabled", true) then
        jsonData = util.Compress(jsonData) or jsonData
        fileName = backupPath .. backupName .. ".json.gz"
    end
    
    -- Write to file
    file.Write(fileName, jsonData)
    
    -- Verify file was written
    if file.Exists(fileName, "GAME") then
        return true, fileName
    else
        return false, "Failed to write backup file"
    end
end

-- Load backup data from file
function HYPERDRIVE.Backup.LoadBackupFromFile(backupName)
    local backupPath = GetBackupConfig("BackupPath", "data/hyperdrive/backups/")
    
    -- Try compressed file first
    local fileName = backupPath .. backupName .. ".json.gz"
    if not file.Exists(fileName, "GAME") then
        fileName = backupPath .. backupName .. ".json"
    end
    
    if not file.Exists(fileName, "GAME") then
        return nil, "Backup file not found: " .. backupName
    end
    
    local fileData = file.Read(fileName, "GAME")
    if not fileData then
        return nil, "Failed to read backup file"
    end
    
    -- Decompress if needed
    if string.sub(fileName, -3) == ".gz" then
        fileData = util.Decompress(fileData) or fileData
    end
    
    -- Parse JSON
    local backupData = util.JSONToTable(fileData)
    if not backupData then
        return nil, "Failed to parse backup data"
    end
    
    return backupData, "Backup loaded successfully"
end

-- Restore system from backup
function HYPERDRIVE.Backup.RestoreFromBackup(backupName, options)
    options = options or {}
    
    local backupData, error = HYPERDRIVE.Backup.LoadBackupFromFile(backupName)
    if not backupData then
        return false, error
    end
    
    local restoreResults = {
        configuration = false,
        engines = 0,
        analytics = false,
        errorLogs = false,
        monitoring = false,
        performance = false,
    }
    
    -- Restore configuration
    if options.restoreConfiguration ~= false and backupData.configuration then
        if HYPERDRIVE.EnhancedConfig then
            for category, settings in pairs(backupData.configuration) do
                if type(settings) == "table" then
                    HYPERDRIVE.EnhancedConfig[category] = table.Copy(settings)
                end
            end
            restoreResults.configuration = true
        end
    end
    
    -- Restore engine data (positions, energy, etc.)
    if options.restoreEngines ~= false and backupData.engines then
        for _, engineData in ipairs(backupData.engines) do
            local engine = Entity(engineData.entIndex)
            if IsValid(engine) then
                -- Restore basic properties
                if options.restorePositions then
                    engine:SetPos(engineData.position)
                    engine:SetAngles(engineData.angles)
                end
                
                if options.restoreEnergy and engine.SetEnergy then
                    engine:SetEnergy(engineData.energy)
                end
                
                if options.restoreDestinations and engine.SetDestination then
                    engine:SetDestination(engineData.destination)
                end
                
                -- Restore custom data
                if engineData.customData and engine.RestoreBackupData then
                    engine:RestoreBackupData(engineData.customData)
                end
                
                restoreResults.engines = restoreResults.engines + 1
            end
        end
    end
    
    -- Restore analytics data
    if options.restoreAnalytics and backupData.analytics and HYPERDRIVE.Analytics then
        HYPERDRIVE.Analytics.Data = table.Copy(backupData.analytics)
        restoreResults.analytics = true
    end
    
    -- Restore error logs
    if options.restoreErrorLogs and backupData.errorLogs and HYPERDRIVE.ErrorRecovery then
        HYPERDRIVE.ErrorRecovery.State.errorLog = table.Copy(backupData.errorLogs)
        restoreResults.errorLogs = true
    end
    
    -- Restore monitoring data
    if options.restoreMonitoring and backupData.monitoring and HYPERDRIVE.Monitoring then
        if backupData.monitoring.alertHistory then
            HYPERDRIVE.Monitoring.State.alertHistory = table.Copy(backupData.monitoring.alertHistory)
        end
        restoreResults.monitoring = true
    end
    
    -- Restore performance data
    if options.restorePerformance and backupData.performance and HYPERDRIVE.Performance then
        HYPERDRIVE.Performance.Metrics = table.Copy(backupData.performance)
        restoreResults.performance = true
    end
    
    return true, restoreResults
end

-- List available backups
function HYPERDRIVE.Backup.ListBackups()
    local backupPath = GetBackupConfig("BackupPath", "data/hyperdrive/backups/")
    local backups = {}
    
    -- Get all backup files
    local files, directories = file.Find(backupPath .. "*", "GAME")
    
    for _, fileName in ipairs(files) do
        if string.EndsWith(fileName, ".json") or string.EndsWith(fileName, ".json.gz") then
            local backupName = string.gsub(fileName, "%.json%.gz$", "")
            backupName = string.gsub(backupName, "%.json$", "")
            
            local filePath = backupPath .. fileName
            local fileSize = file.Size(filePath, "GAME")
            local fileTime = file.Time(filePath, "GAME")
            
            table.insert(backups, {
                name = backupName,
                fileName = fileName,
                size = fileSize,
                timestamp = fileTime,
                compressed = string.EndsWith(fileName, ".gz")
            })
        end
    end
    
    -- Sort by timestamp (newest first)
    table.sort(backups, function(a, b) return a.timestamp > b.timestamp end)
    
    return backups
end

-- Cleanup old backups
function HYPERDRIVE.Backup.CleanupOldBackups()
    local maxBackups = GetBackupConfig("MaxBackups", 24)
    local backups = HYPERDRIVE.Backup.ListBackups()
    
    -- Remove excess backups
    for i = maxBackups + 1, #backups do
        local backup = backups[i]
        local backupPath = GetBackupConfig("BackupPath", "data/hyperdrive/backups/")
        local filePath = backupPath .. backup.fileName
        
        file.Delete(filePath)
        print("[Hyperdrive Backup] Deleted old backup: " .. backup.name)
    end
end

-- Migration system for version upgrades
function HYPERDRIVE.Backup.MigrateData(fromVersion, toVersion)
    if not GetBackupConfig("MigrationEnabled", true) then
        return false, "Migration is disabled"
    end
    
    print("[Hyperdrive Backup] Migrating data from version " .. fromVersion .. " to " .. toVersion)
    
    -- Create backup before migration
    local backupName = "pre_migration_" .. fromVersion .. "_to_" .. toVersion .. "_" .. os.date("%Y%m%d_%H%M%S")
    local success, error = HYPERDRIVE.Backup.CreateSystemBackup(backupName)
    
    if not success then
        return false, "Failed to create pre-migration backup: " .. error
    end
    
    -- Perform version-specific migrations
    if fromVersion == "1.0.0" and toVersion == "2.0.0" then
        -- Example migration logic
        HYPERDRIVE.Backup.MigrateV1ToV2()
    end
    
    return true, "Migration completed successfully"
end

-- Example migration function
function HYPERDRIVE.Backup.MigrateV1ToV2()
    -- Migrate old configuration format to new format
    -- This is an example - actual migration logic would depend on changes
    print("[Hyperdrive Backup] Performing v1.0.0 to v2.0.0 migration")
    
    -- Update configuration structure
    if HYPERDRIVE.Config then
        -- Convert old config to new enhanced config format
        if not HYPERDRIVE.EnhancedConfig then
            HYPERDRIVE.EnhancedConfig = {}
        end
        
        -- Migrate settings
        HYPERDRIVE.EnhancedConfig.SpaceCombat2 = HYPERDRIVE.EnhancedConfig.SpaceCombat2 or {}
        HYPERDRIVE.EnhancedConfig.Performance = HYPERDRIVE.EnhancedConfig.Performance or {}
        
        -- Clear old config
        HYPERDRIVE.Config = nil
    end
end

-- Automatic backup timer
timer.Create("HyperdriveAutoBackup", GetBackupConfig("BackupInterval", 3600), 0, function()
    if GetBackupConfig("EnableAutoBackup", true) then
        HYPERDRIVE.Backup.CreateSystemBackup()
    end
end)

-- Console commands for backup management
concommand.Add("hyperdrive_backup_create", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local backupName = args[1] or ("manual_" .. os.date("%Y%m%d_%H%M%S"))
    local success, message = HYPERDRIVE.Backup.CreateSystemBackup(backupName)
    
    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive Backup] " .. message)
    else
        print("[Hyperdrive Backup] " .. message)
    end
end)

concommand.Add("hyperdrive_backup_list", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local backups = HYPERDRIVE.Backup.ListBackups()
    
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    sendMessage("[Hyperdrive Backup] Available backups:")
    for i, backup in ipairs(backups) do
        if i <= 10 then -- Show only first 10
            local sizeKB = math.floor(backup.size / 1024)
            local timeAgo = os.time() - backup.timestamp
            local timeStr = timeAgo < 3600 and (math.floor(timeAgo / 60) .. "m ago") or 
                           (math.floor(timeAgo / 3600) .. "h ago")
            sendMessage(string.format("  • %s (%dKB, %s)", backup.name, sizeKB, timeStr))
        end
    end
    
    if #backups > 10 then
        sendMessage("  ... and " .. (#backups - 10) .. " more")
    end
end)

concommand.Add("hyperdrive_backup_restore", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsSuperAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Superadmin access required!")
        end
        return
    end
    
    if #args < 1 then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Usage: hyperdrive_backup_restore <backup_name>")
        end
        return
    end
    
    local backupName = args[1]
    local options = {
        restoreConfiguration = true,
        restoreEngines = true,
        restorePositions = false, -- Don't restore positions by default
        restoreEnergy = true,
        restoreDestinations = true,
    }
    
    local success, result = HYPERDRIVE.Backup.RestoreFromBackup(backupName, options)
    
    if success then
        local message = string.format("Restored: Config=%s, Engines=%d", 
            result.configuration and "Yes" or "No", result.engines)
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Backup] " .. message)
        else
            print("[Hyperdrive Backup] " .. message)
        end
    else
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Backup] Restore failed: " .. result)
        else
            print("[Hyperdrive Backup] Restore failed: " .. result)
        end
    end
end)

print("[Hyperdrive] Backup and migration system loaded")
