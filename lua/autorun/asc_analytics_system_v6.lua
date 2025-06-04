-- Advanced Space Combat - Analytics & Telemetry System v6.0.0
-- Real-time analytics, user behavior tracking, and performance telemetry
-- Research-based implementation following 2025 analytics best practices

print("[Advanced Space Combat] Analytics & Telemetry System v6.0.0 - Advanced Data Intelligence Loading...")

-- Initialize analytics namespace
ASC = ASC or {}
ASC.Analytics = ASC.Analytics or {}

-- Analytics configuration
ASC.Analytics.Config = {
    Version = "6.0.0",
    Enabled = true,
    
    -- Data collection settings
    Collection = {
        UserBehavior = true,
        Performance = true,
        Errors = true,
        Features = true,
        Sessions = true,
        Interactions = true
    },
    
    -- Privacy settings
    Privacy = {
        AnonymizeData = true,
        LocalStorageOnly = true,
        DataRetentionDays = 30,
        OptOutAvailable = true
    },
    
    -- Reporting intervals
    Intervals = {
        RealTime = 1.0,      -- seconds
        Summary = 60.0,      -- 1 minute
        Detailed = 300.0,    -- 5 minutes
        Session = 1800.0     -- 30 minutes
    }
}

-- Analytics data storage
ASC.Analytics.Data = {
    Sessions = {},
    Events = {},
    Performance = {},
    Errors = {},
    Features = {},
    UserProfiles = {}
}

-- Session management
ASC.Analytics.Session = {
    Current = nil,
    StartTime = 0,
    LastActivity = 0,
    
    -- Start new session
    Start = function(player)
        local sessionId = "session_" .. os.time() .. "_" .. math.random(1000, 9999)
        
        ASC.Analytics.Session.Current = {
            id = sessionId,
            player = player,
            startTime = os.time(),
            lastActivity = os.time(),
            events = {},
            performance = {
                avgFPS = 0,
                minFPS = 999,
                maxFPS = 0,
                memoryUsage = {},
                networkLatency = {}
            },
            features = {},
            errors = {}
        }
        
        -- Ensure Sessions table exists
        ASC.Analytics.Data.Sessions = ASC.Analytics.Data.Sessions or {}
        ASC.Analytics.Data.Sessions[sessionId] = ASC.Analytics.Session.Current
        
        -- Track session start event
        ASC.Analytics.TrackEvent("session_start", {
            sessionId = sessionId,
            playerName = IsValid(player) and player:Name() or "Unknown",
            timestamp = os.time()
        })
        
        print("[ASC Analytics] Session started: " .. sessionId)
        return sessionId
    end,
    
    -- End current session
    End = function()
        if not ASC.Analytics.Session.Current then return end
        
        local session = ASC.Analytics.Session.Current
        session.endTime = os.time()
        session.duration = session.endTime - session.startTime
        
        -- Track session end event
        ASC.Analytics.TrackEvent("session_end", {
            sessionId = session.id,
            duration = session.duration,
            eventCount = #session.events,
            timestamp = os.time()
        })
        
        -- Generate session summary
        ASC.Analytics.GenerateSessionSummary(session)
        
        print("[ASC Analytics] Session ended: " .. session.id .. " (Duration: " .. session.duration .. "s)")
        ASC.Analytics.Session.Current = nil
    end,
    
    -- Update session activity
    UpdateActivity = function()
        if ASC.Analytics.Session.Current then
            ASC.Analytics.Session.Current.lastActivity = os.time()
        end
    end
}

-- Event tracking
ASC.Analytics.TrackEvent = function(eventName, data)
    if not ASC.Analytics.Config.Enabled or not ASC.Analytics.Config.Collection.Features then
        return
    end
    
    local event = {
        name = eventName,
        data = data or {},
        timestamp = os.time(),
        sessionId = ASC.Analytics.Session.Current and ASC.Analytics.Session.Current.id or nil
    }
    
    -- Add to global events
    table.insert(ASC.Analytics.Data.Events, event)
    
    -- Add to current session
    if ASC.Analytics.Session.Current then
        table.insert(ASC.Analytics.Session.Current.events, event)
    end
    
    -- Update activity
    ASC.Analytics.Session.UpdateActivity()
    
    -- Limit event history
    if #ASC.Analytics.Data.Events > 10000 then
        table.remove(ASC.Analytics.Data.Events, 1)
    end
end

-- Performance tracking
ASC.Analytics.TrackPerformance = function(fps, memory, entities)
    if not ASC.Analytics.Config.Enabled or not ASC.Analytics.Config.Collection.Performance then
        return
    end
    
    local perfData = {
        fps = fps,
        memory = memory,
        entities = entities,
        timestamp = os.time()
    }
    
    -- Add to global performance data
    table.insert(ASC.Analytics.Data.Performance, perfData)
    
    -- Update session performance
    if ASC.Analytics.Session.Current then
        local session = ASC.Analytics.Session.Current
        local perf = session.performance
        
        -- Update FPS statistics
        perf.avgFPS = (perf.avgFPS + fps) / 2
        perf.minFPS = math.min(perf.minFPS, fps)
        perf.maxFPS = math.max(perf.maxFPS, fps)
        
        -- Track memory usage
        table.insert(perf.memoryUsage, memory)
        if #perf.memoryUsage > 100 then
            table.remove(perf.memoryUsage, 1)
        end
    end
    
    -- Limit performance history
    if #ASC.Analytics.Data.Performance > 1000 then
        table.remove(ASC.Analytics.Data.Performance, 1)
    end
end

-- Error tracking
ASC.Analytics.TrackError = function(errorType, errorMessage, stackTrace)
    if not ASC.Analytics.Config.Enabled or not ASC.Analytics.Config.Collection.Errors then
        return
    end
    
    local error = {
        type = errorType,
        message = errorMessage,
        stackTrace = stackTrace,
        timestamp = os.time(),
        sessionId = ASC.Analytics.Session.Current and ASC.Analytics.Session.Current.id or nil
    }
    
    -- Add to global errors
    table.insert(ASC.Analytics.Data.Errors, error)
    
    -- Add to current session
    if ASC.Analytics.Session.Current then
        table.insert(ASC.Analytics.Session.Current.errors, error)
    end
    
    print("[ASC Analytics] Error tracked: " .. errorType .. " - " .. errorMessage)
end

-- Feature usage tracking
ASC.Analytics.TrackFeatureUsage = function(featureName, action, metadata)
    if not ASC.Analytics.Config.Enabled or not ASC.Analytics.Config.Collection.Features then
        return
    end
    
    local usage = {
        feature = featureName,
        action = action,
        metadata = metadata or {},
        timestamp = os.time(),
        sessionId = ASC.Analytics.Session.Current and ASC.Analytics.Session.Current.id or nil
    }
    
    -- Initialize feature tracking
    if not ASC.Analytics.Data.Features[featureName] then
        ASC.Analytics.Data.Features[featureName] = {
            totalUsage = 0,
            actions = {},
            firstUsed = os.time(),
            lastUsed = os.time()
        }
    end
    
    local feature = ASC.Analytics.Data.Features[featureName]
    feature.totalUsage = feature.totalUsage + 1
    feature.lastUsed = os.time()
    
    -- Track action
    if not feature.actions[action] then
        feature.actions[action] = 0
    end
    feature.actions[action] = feature.actions[action] + 1
    
    -- Add to session features
    if ASC.Analytics.Session.Current then
        if not ASC.Analytics.Session.Current.features[featureName] then
            ASC.Analytics.Session.Current.features[featureName] = 0
        end
        ASC.Analytics.Session.Current.features[featureName] = ASC.Analytics.Session.Current.features[featureName] + 1
    end
end

-- User behavior analysis
ASC.Analytics.AnalyzeBehavior = function(player)
    if not IsValid(player) then return {} end
    
    local playerId = player:SteamID()
    
    if not ASC.Analytics.Data.UserProfiles[playerId] then
        ASC.Analytics.Data.UserProfiles[playerId] = {
            totalSessions = 0,
            totalPlayTime = 0,
            favoriteFeatures = {},
            skillLevel = "beginner",
            preferences = {},
            lastSeen = os.time()
        }
    end
    
    local profile = ASC.Analytics.Data.UserProfiles[playerId]
    
    -- Analyze feature usage patterns
    local featureUsage = {}
    for feature, data in pairs(ASC.Analytics.Data.Features) do
        featureUsage[feature] = data.totalUsage
    end
    
    -- Determine favorite features
    local sortedFeatures = {}
    for feature, usage in pairs(featureUsage) do
        table.insert(sortedFeatures, {feature = feature, usage = usage})
    end
    table.sort(sortedFeatures, function(a, b) return a.usage > b.usage end)
    
    profile.favoriteFeatures = {}
    for i = 1, math.min(5, #sortedFeatures) do
        table.insert(profile.favoriteFeatures, sortedFeatures[i].feature)
    end
    
    -- Determine skill level based on feature usage diversity and session length
    local featureCount = table.Count(featureUsage)
    local avgSessionLength = profile.totalPlayTime / math.max(1, profile.totalSessions)
    
    if featureCount > 10 and avgSessionLength > 1800 then
        profile.skillLevel = "expert"
    elseif featureCount > 5 and avgSessionLength > 900 then
        profile.skillLevel = "intermediate"
    else
        profile.skillLevel = "beginner"
    end
    
    profile.lastSeen = os.time()
    
    return profile
end

-- Generate session summary
ASC.Analytics.GenerateSessionSummary = function(session)
    local summary = {
        sessionId = session.id,
        duration = session.duration,
        eventCount = #session.events,
        errorCount = #session.errors,
        featuresUsed = table.Count(session.features),
        performance = {
            avgFPS = math.Round(session.performance.avgFPS, 1),
            minFPS = session.performance.minFPS,
            maxFPS = session.performance.maxFPS,
            avgMemory = 0
        }
    }
    
    -- Calculate average memory usage
    if #session.performance.memoryUsage > 0 then
        local totalMemory = 0
        for _, mem in ipairs(session.performance.memoryUsage) do
            totalMemory = totalMemory + mem
        end
        summary.performance.avgMemory = math.Round(totalMemory / #session.performance.memoryUsage, 1)
    end
    
    print("[ASC Analytics] Session Summary:")
    print("  Duration: " .. summary.duration .. "s")
    print("  Events: " .. summary.eventCount)
    print("  Features Used: " .. summary.featuresUsed)
    print("  Avg FPS: " .. summary.performance.avgFPS)
    print("  Avg Memory: " .. summary.performance.avgMemory .. "MB")
    
    return summary
end

-- Get analytics dashboard data
ASC.Analytics.GetDashboard = function()
    local dashboard = {
        overview = {
            totalSessions = table.Count(ASC.Analytics.Data.Sessions),
            totalEvents = #ASC.Analytics.Data.Events,
            totalErrors = #ASC.Analytics.Data.Errors,
            activeUsers = table.Count(ASC.Analytics.Data.UserProfiles)
        },
        performance = {
            currentFPS = ASC.Performance and ASC.Performance.State.CurrentFPS or 0,
            currentMemory = ASC.Performance and ASC.Performance.State.CurrentMemoryMB or 0,
            performanceScore = ASC.Performance and ASC.Performance.State.PerformanceScore or 1
        },
        features = {},
        errors = {}
    }
    
    -- Top features by usage
    local featureList = {}
    for feature, data in pairs(ASC.Analytics.Data.Features) do
        table.insert(featureList, {name = feature, usage = data.totalUsage})
    end
    table.sort(featureList, function(a, b) return a.usage > b.usage end)
    dashboard.features = featureList
    
    -- Recent errors
    local recentErrors = {}
    for i = math.max(1, #ASC.Analytics.Data.Errors - 9), #ASC.Analytics.Data.Errors do
        if ASC.Analytics.Data.Errors[i] then
            table.insert(recentErrors, ASC.Analytics.Data.Errors[i])
        end
    end
    dashboard.errors = recentErrors
    
    return dashboard
end

-- Console commands
concommand.Add("asc_analytics_dashboard", function(ply, cmd, args)
    local dashboard = ASC.Analytics.GetDashboard()
    
    local function printMsg(msg)
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    printMsg("[ASC Analytics] Dashboard:")
    printMsg("  Sessions: " .. dashboard.overview.totalSessions)
    printMsg("  Events: " .. dashboard.overview.totalEvents)
    printMsg("  Errors: " .. dashboard.overview.totalErrors)
    printMsg("  Current FPS: " .. math.Round(dashboard.performance.currentFPS, 1))
    printMsg("  Current Memory: " .. math.Round(dashboard.performance.currentMemory, 1) .. "MB")
    
    if #dashboard.features > 0 then
        printMsg("  Top Features:")
        for i = 1, math.min(5, #dashboard.features) do
            local feature = dashboard.features[i]
            printMsg("    " .. feature.name .. ": " .. feature.usage .. " uses")
        end
    end
end, nil, "Show analytics dashboard")

-- Initialize analytics system
function ASC.Analytics.Initialize()
    print("[ASC Analytics] Initializing analytics system...")
    
    -- Start session for local player
    if CLIENT then
        timer.Simple(2, function()
            ASC.Analytics.Session.Start(LocalPlayer())
        end)
        
        -- Performance tracking hook
        local interval = ASC.Analytics.Config.Intervals and ASC.Analytics.Config.Intervals.RealTime or 1.0
        timer.Create("ASC_Analytics_Performance", interval, 0, function()
            if ASC.Performance and ASC.Performance.State then
                ASC.Analytics.TrackPerformance(
                    ASC.Performance.State.CurrentFPS,
                    ASC.Performance.State.CurrentMemoryMB,
                    ASC.Performance.State.CurrentEntityCount
                )
            end
        end)
    end
    
    print("[ASC Analytics] Analytics system initialized")
end

-- Hook into core events
if ASC.Events then
    ASC.Events.Register("CoreInitialized", ASC.Analytics.Initialize, 1)
end

-- Client initialization
if CLIENT then
    hook.Add("InitPostEntity", "ASC_Analytics_Initialize", function()
        timer.Simple(3, ASC.Analytics.Initialize)
    end)
    
    -- Track player disconnect
    hook.Add("ShutDown", "ASC_Analytics_Shutdown", function()
        ASC.Analytics.Session.End()
    end)
end

print("[Advanced Space Combat] Analytics & Telemetry System v6.0.0 - Advanced Data Intelligence Loaded Successfully!")
