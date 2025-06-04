-- Advanced Space Combat - Analytics and Monitoring System v1.0.0
-- Comprehensive system monitoring and user analytics

print("[Advanced Space Combat] Analytics and Monitoring System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.Analytics = ASC.Analytics or {}

-- Analytics configuration
ASC.Analytics.Config = {
    EnableUserTracking = true,
    EnablePerformanceTracking = true,
    EnableFeatureUsageTracking = true,
    EnableErrorTracking = true,
    
    -- Data retention
    DataRetentionDays = 30,
    MaxEventsPerUser = 1000,
    MaxErrorLogs = 500,
    
    -- Reporting
    ReportInterval = 300, -- 5 minutes
    DetailedReportInterval = 3600, -- 1 hour
    
    -- Privacy settings
    AnonymizeUserData = false,
    EnableDataExport = true
}

-- Analytics data storage
ASC.Analytics.Data = {
    UserEvents = {},
    PerformanceMetrics = {},
    FeatureUsage = {},
    ErrorLogs = {},
    SystemMetrics = {}
}

-- Event types
ASC.Analytics.EventTypes = {
    USER_ACTION = "user_action",
    SYSTEM_EVENT = "system_event",
    PERFORMANCE = "performance",
    ERROR = "error",
    FEATURE_USE = "feature_use"
}

-- Initialize analytics system
function ASC.Analytics.Initialize()
    print("[Advanced Space Combat] Initializing analytics system...")
    
    -- Set up data collection
    ASC.Analytics.SetupDataCollection()
    
    -- Set up reporting
    ASC.Analytics.SetupReporting()
    
    -- Set up cleanup
    ASC.Analytics.SetupCleanup()
    
    print("[Advanced Space Combat] Analytics system initialized")
end

-- Set up data collection
function ASC.Analytics.SetupDataCollection()
    -- Track user events
    hook.Add("PlayerSay", "ASC_Analytics_PlayerSay", function(ply, text)
        if text:find("aria") or text:find("asc_") then
            ASC.Analytics.TrackEvent(ply, ASC.Analytics.EventTypes.USER_ACTION, "command_usage", {
                command = text,
                timestamp = CurTime()
            })
        end
    end)
    
    -- Track entity spawning
    hook.Add("PlayerSpawnedSENT", "ASC_Analytics_EntitySpawn", function(ply, ent)
        if ent:GetClass():find("asc_") or ent:GetClass():find("ship_core") then
            ASC.Analytics.TrackEvent(ply, ASC.Analytics.EventTypes.FEATURE_USE, "entity_spawn", {
                entity_class = ent:GetClass(),
                timestamp = CurTime()
            })
        end
    end)
    
    -- Track tool usage
    hook.Add("CanTool", "ASC_Analytics_ToolUse", function(ply, tr, tool)
        if tool:find("asc_") then
            ASC.Analytics.TrackEvent(ply, ASC.Analytics.EventTypes.FEATURE_USE, "tool_usage", {
                tool = tool,
                timestamp = CurTime()
            })
        end
    end)
    
    -- Track errors
    hook.Add("OnLuaError", "ASC_Analytics_LuaError", function(err, realm, stack, name, id)
        if err:find("asc") or err:find("ASC") or err:find("aria") then
            ASC.Analytics.TrackError(err, realm, stack, name)
        end
    end)
end

-- Track an event
function ASC.Analytics.TrackEvent(player, eventType, action, data)
    if not ASC.Analytics.Config.EnableUserTracking then return end
    
    local playerID = IsValid(player) and player:SteamID() or "system"
    
    if not ASC.Analytics.Data.UserEvents[playerID] then
        ASC.Analytics.Data.UserEvents[playerID] = {}
    end
    
    local event = {
        type = eventType,
        action = action,
        data = data or {},
        timestamp = CurTime(),
        session_id = ASC.Analytics.GetSessionID(player)
    }
    
    table.insert(ASC.Analytics.Data.UserEvents[playerID], event)
    
    -- Limit events per user
    if #ASC.Analytics.Data.UserEvents[playerID] > ASC.Analytics.Config.MaxEventsPerUser then
        table.remove(ASC.Analytics.Data.UserEvents[playerID], 1)
    end
    
    -- Update feature usage statistics
    ASC.Analytics.UpdateFeatureUsage(action)
end

-- Track performance metrics
function ASC.Analytics.TrackPerformance(metric, value, context)
    if not ASC.Analytics.Config.EnablePerformanceTracking then return end
    
    if not ASC.Analytics.Data.PerformanceMetrics[metric] then
        ASC.Analytics.Data.PerformanceMetrics[metric] = {}
    end
    
    table.insert(ASC.Analytics.Data.PerformanceMetrics[metric], {
        value = value,
        context = context or {},
        timestamp = CurTime()
    })
    
    -- Keep only recent data
    if #ASC.Analytics.Data.PerformanceMetrics[metric] > 1000 then
        table.remove(ASC.Analytics.Data.PerformanceMetrics[metric], 1)
    end
end

-- Track errors
function ASC.Analytics.TrackError(error, realm, stack, name)
    if not ASC.Analytics.Config.EnableErrorTracking then return end
    
    local errorData = {
        error = error,
        realm = realm,
        stack = stack,
        name = name,
        timestamp = CurTime(),
        server_info = {
            map = game.GetMap(),
            players = #player.GetAll(),
            uptime = CurTime()
        }
    }
    
    table.insert(ASC.Analytics.Data.ErrorLogs, errorData)
    
    -- Limit error logs
    if #ASC.Analytics.Data.ErrorLogs > ASC.Analytics.Config.MaxErrorLogs then
        table.remove(ASC.Analytics.Data.ErrorLogs, 1)
    end
    
    print("[Advanced Space Combat] Error tracked: " .. error)
end

-- Update feature usage statistics
function ASC.Analytics.UpdateFeatureUsage(feature)
    if not ASC.Analytics.Config.EnableFeatureUsageTracking then return end
    
    if not ASC.Analytics.Data.FeatureUsage[feature] then
        ASC.Analytics.Data.FeatureUsage[feature] = {
            count = 0,
            first_used = CurTime(),
            last_used = CurTime(),
            unique_users = {}
        }
    end
    
    ASC.Analytics.Data.FeatureUsage[feature].count = ASC.Analytics.Data.FeatureUsage[feature].count + 1
    ASC.Analytics.Data.FeatureUsage[feature].last_used = CurTime()
end

-- Get session ID for a player
function ASC.Analytics.GetSessionID(player)
    if not IsValid(player) then return "system" end
    
    local playerID = player:SteamID()
    if not player.ASC_SessionID then
        player.ASC_SessionID = playerID .. "_" .. CurTime()
    end
    
    return player.ASC_SessionID
end

-- Set up reporting
function ASC.Analytics.SetupReporting()
    -- Regular reports
    timer.Create("ASC_Analytics_Report", ASC.Analytics.Config.ReportInterval, 0, function()
        ASC.Analytics.GenerateReport()
    end)
    
    -- Detailed reports
    timer.Create("ASC_Analytics_DetailedReport", ASC.Analytics.Config.DetailedReportInterval, 0, function()
        ASC.Analytics.GenerateDetailedReport()
    end)
end

-- Generate basic report
function ASC.Analytics.GenerateReport()
    local totalUsers = table.Count(ASC.Analytics.Data.UserEvents)
    local totalEvents = 0
    
    for _, events in pairs(ASC.Analytics.Data.UserEvents) do
        totalEvents = totalEvents + #events
    end
    
    local totalErrors = #ASC.Analytics.Data.ErrorLogs
    local topFeatures = ASC.Analytics.GetTopFeatures(5)
    
    print("[Advanced Space Combat] Analytics Report:")
    print("• Active Users: " .. totalUsers)
    print("• Total Events: " .. totalEvents)
    print("• Total Errors: " .. totalErrors)
    print("• Top Features: " .. table.concat(topFeatures, ", "))
end

-- Generate detailed report
function ASC.Analytics.GenerateDetailedReport()
    print("[Advanced Space Combat] Detailed Analytics Report:")
    
    -- User engagement
    local engagement = ASC.Analytics.CalculateUserEngagement()
    print("• Average Session Length: " .. math.floor(engagement.avgSessionLength) .. " seconds")
    print("• Average Events per User: " .. math.floor(engagement.avgEventsPerUser))
    
    -- Performance metrics
    local performance = ASC.Analytics.GetPerformanceSummary()
    print("• Performance Summary:")
    for metric, data in pairs(performance) do
        print("  - " .. metric .. ": avg=" .. math.floor(data.average) .. ", max=" .. math.floor(data.max))
    end
    
    -- Error analysis
    local errorAnalysis = ASC.Analytics.AnalyzeErrors()
    print("• Error Analysis:")
    print("  - Total Errors: " .. errorAnalysis.total)
    print("  - Error Rate: " .. math.floor(errorAnalysis.rate * 100) .. "%")
    print("  - Most Common: " .. (errorAnalysis.mostCommon or "None"))
end

-- Calculate user engagement metrics
function ASC.Analytics.CalculateUserEngagement()
    local totalSessionLength = 0
    local totalEvents = 0
    local userCount = 0
    
    for playerID, events in pairs(ASC.Analytics.Data.UserEvents) do
        if #events > 0 then
            userCount = userCount + 1
            totalEvents = totalEvents + #events
            
            -- Calculate session length
            local firstEvent = events[1].timestamp
            local lastEvent = events[#events].timestamp
            totalSessionLength = totalSessionLength + (lastEvent - firstEvent)
        end
    end
    
    return {
        avgSessionLength = userCount > 0 and (totalSessionLength / userCount) or 0,
        avgEventsPerUser = userCount > 0 and (totalEvents / userCount) or 0
    }
end

-- Get performance summary
function ASC.Analytics.GetPerformanceSummary()
    local summary = {}
    
    for metric, data in pairs(ASC.Analytics.Data.PerformanceMetrics) do
        if #data > 0 then
            local total = 0
            local max = 0
            
            for _, entry in ipairs(data) do
                total = total + entry.value
                max = math.max(max, entry.value)
            end
            
            summary[metric] = {
                average = total / #data,
                max = max,
                count = #data
            }
        end
    end
    
    return summary
end

-- Analyze errors
function ASC.Analytics.AnalyzeErrors()
    local total = #ASC.Analytics.Data.ErrorLogs
    local errorCounts = {}
    
    for _, errorData in ipairs(ASC.Analytics.Data.ErrorLogs) do
        local errorType = errorData.error:match("^[^:]+") or "Unknown"
        errorCounts[errorType] = (errorCounts[errorType] or 0) + 1
    end
    
    local mostCommon = nil
    local maxCount = 0
    for errorType, count in pairs(errorCounts) do
        if count > maxCount then
            maxCount = count
            mostCommon = errorType
        end
    end
    
    return {
        total = total,
        rate = total / math.max(1, CurTime()),
        mostCommon = mostCommon,
        types = errorCounts
    }
end

-- Get top features
function ASC.Analytics.GetTopFeatures(limit)
    local features = {}
    
    for feature, data in pairs(ASC.Analytics.Data.FeatureUsage) do
        table.insert(features, {name = feature, count = data.count})
    end
    
    table.sort(features, function(a, b) return a.count > b.count end)
    
    local topFeatures = {}
    for i = 1, math.min(limit, #features) do
        table.insert(topFeatures, features[i].name)
    end
    
    return topFeatures
end

-- Set up cleanup
function ASC.Analytics.SetupCleanup()
    timer.Create("ASC_Analytics_Cleanup", 3600, 0, function() -- Every hour
        ASC.Analytics.CleanupOldData()
    end)
end

-- Clean up old data
function ASC.Analytics.CleanupOldData()
    local cutoffTime = CurTime() - (ASC.Analytics.Config.DataRetentionDays * 24 * 3600)
    local cleaned = 0
    
    -- Clean user events
    for playerID, events in pairs(ASC.Analytics.Data.UserEvents) do
        for i = #events, 1, -1 do
            if events[i].timestamp < cutoffTime then
                table.remove(events, i)
                cleaned = cleaned + 1
            end
        end
    end
    
    -- Clean performance metrics
    for metric, data in pairs(ASC.Analytics.Data.PerformanceMetrics) do
        for i = #data, 1, -1 do
            if data[i].timestamp < cutoffTime then
                table.remove(data, i)
                cleaned = cleaned + 1
            end
        end
    end
    
    -- Clean error logs
    for i = #ASC.Analytics.Data.ErrorLogs, 1, -1 do
        if ASC.Analytics.Data.ErrorLogs[i].timestamp < cutoffTime then
            table.remove(ASC.Analytics.Data.ErrorLogs, i)
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        print("[Advanced Space Combat] Cleaned " .. cleaned .. " old analytics entries")
    end
end

-- Console commands
concommand.Add("asc_analytics_report", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Advanced Space Combat] Admin only command")
        return
    end
    
    ASC.Analytics.GenerateDetailedReport()
    
    local msg = "[Advanced Space Combat] Analytics report generated"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end, nil, "Generate detailed analytics report (Admin only)")

-- Initialize analytics
hook.Add("Initialize", "ASC_Analytics_Init", function()
    timer.Simple(2, function()
        ASC.Analytics.Initialize()
    end)
end)

print("[Advanced Space Combat] Analytics and Monitoring System loaded successfully!")
