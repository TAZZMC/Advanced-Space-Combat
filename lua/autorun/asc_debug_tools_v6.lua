-- Advanced Space Combat - Debug & Development Tools v6.0.0
-- Advanced debugging, profiling, and development assistance tools
-- Research-based implementation following 2025 debugging best practices

print("[Advanced Space Combat] Debug & Development Tools v6.0.0 - Advanced Developer Suite Loading...")

-- Initialize debug namespace
ASC = ASC or {}
ASC.Debug = ASC.Debug or {}

-- Debug configuration
ASC.Debug.Config = {
    Version = "6.0.0",
    Enabled = GetConVar("developer"):GetInt() > 0,
    
    -- Debug levels
    Levels = {
        ERROR = 1,
        WARNING = 2,
        INFO = 3,
        DEBUG = 4,
        TRACE = 5
    },
    
    -- Features
    Features = {
        Profiling = true,
        MemoryTracking = true,
        PerformanceMonitoring = true,
        ErrorTracking = true,
        NetworkDebugging = true,
        EntityDebugging = true,
        AIDebugging = true,
        VisualDebugging = true
    },
    
    -- Visual debugging
    Visual = {
        ShowEntityBounds = false,
        ShowNetworkTraffic = false,
        ShowPerformanceOverlay = false,
        ShowMemoryUsage = false,
        ShowFPSGraph = false,
        ShowAIThoughts = false
    },
    
    -- Profiling
    Profiling = {
        Enabled = false,
        SampleRate = 0.1,  -- seconds
        MaxSamples = 1000,
        AutoSave = true
    }
}

-- Debug state
ASC.Debug.State = {
    CurrentLevel = ASC.Debug.Config.Levels.INFO,
    LogHistory = {},
    ProfileData = {},
    PerformanceHistory = {},
    ErrorCount = 0,
    WarningCount = 0,
    StartTime = SysTime()
}

-- Profiler
ASC.Debug.Profiler = {
    ActiveProfiles = {},
    Results = {},
    
    -- Start profiling a function
    Start = function(name)
        if not ASC.Debug.Config.Profiling.Enabled then return end
        
        ASC.Debug.Profiler.ActiveProfiles[name] = {
            startTime = SysTime(),
            startMemory = collectgarbage("count")
        }
    end,
    
    -- End profiling
    End = function(name)
        if not ASC.Debug.Config.Profiling.Enabled then return end
        
        local profile = ASC.Debug.Profiler.ActiveProfiles[name]
        if not profile then return end
        
        local endTime = SysTime()
        local endMemory = collectgarbage("count")
        
        local result = {
            name = name,
            duration = endTime - profile.startTime,
            memoryDelta = endMemory - profile.startMemory,
            timestamp = os.time()
        }
        
        -- Add to results
        if not ASC.Debug.Profiler.Results[name] then
            ASC.Debug.Profiler.Results[name] = {}
        end
        
        table.insert(ASC.Debug.Profiler.Results[name], result)
        
        -- Limit history
        if #ASC.Debug.Profiler.Results[name] > ASC.Debug.Config.Profiling.MaxSamples then
            table.remove(ASC.Debug.Profiler.Results[name], 1)
        end
        
        ASC.Debug.Profiler.ActiveProfiles[name] = nil
        
        -- Log if significant
        if result.duration > 0.01 then  -- 10ms threshold
            ASC.Debug.Log("PERFORMANCE", "Function " .. name .. " took " .. math.Round(result.duration * 1000, 2) .. "ms")
        end
    end,
    
    -- Get profiling results
    GetResults = function(name)
        if not ASC.Debug.Profiler.Results[name] then return {} end
        
        local results = ASC.Debug.Profiler.Results[name]
        local totalDuration = 0
        local totalMemory = 0
        local count = #results
        
        for _, result in ipairs(results) do
            totalDuration = totalDuration + result.duration
            totalMemory = totalMemory + result.memoryDelta
        end
        
        return {
            name = name,
            count = count,
            totalDuration = totalDuration,
            averageDuration = count > 0 and totalDuration / count or 0,
            totalMemory = totalMemory,
            averageMemory = count > 0 and totalMemory / count or 0,
            lastRun = results[#results]
        }
    end
}

-- Logging system
ASC.Debug.Log = function(level, message, data)
    local levelNum = ASC.Debug.Config.Levels[level] or ASC.Debug.Config.Levels.INFO
    
    if levelNum > ASC.Debug.State.CurrentLevel then return end
    
    local logEntry = {
        level = level,
        message = message,
        data = data,
        timestamp = os.time(),
        gameTime = CurTime(),
        stackTrace = debug.traceback()
    }
    
    -- Add to history
    table.insert(ASC.Debug.State.LogHistory, logEntry)
    
    -- Limit history size
    if #ASC.Debug.State.LogHistory > 1000 then
        table.remove(ASC.Debug.State.LogHistory, 1)
    end
    
    -- Update counters
    if level == "ERROR" then
        ASC.Debug.State.ErrorCount = ASC.Debug.State.ErrorCount + 1
    elseif level == "WARNING" then
        ASC.Debug.State.WarningCount = ASC.Debug.State.WarningCount + 1
    end
    
    -- Console output
    local prefix = "[ASC Debug " .. level .. "]"
    local output = prefix .. " " .. message
    
    if level == "ERROR" then
        print(output)
        if data then
            PrintTable(data)
        end
    elseif level == "WARNING" then
        print(output)
    elseif ASC.Debug.Config.Enabled then
        print(output)
    end
    
    -- Track in analytics
    if ASC.Analytics and ASC.Debug.Config.Features.ErrorTracking then
        ASC.Analytics.TrackEvent("debug_log", {
            level = level,
            message = message,
            hasData = data ~= nil
        })
    end
end

-- Memory tracking
ASC.Debug.MemoryTracker = {
    Snapshots = {},
    
    -- Take memory snapshot
    TakeSnapshot = function(name)
        if not ASC.Debug.Config.Features.MemoryTracking then return end
        
        local snapshot = {
            name = name or "unnamed",
            timestamp = os.time(),
            gameTime = CurTime(),
            memory = collectgarbage("count"),
            entities = #ents.GetAll(),
            players = #player.GetAll()
        }
        
        table.insert(ASC.Debug.MemoryTracker.Snapshots, snapshot)
        
        -- Limit snapshots
        if #ASC.Debug.MemoryTracker.Snapshots > 100 then
            table.remove(ASC.Debug.MemoryTracker.Snapshots, 1)
        end
        
        ASC.Debug.Log("DEBUG", "Memory snapshot: " .. name .. " - " .. math.Round(snapshot.memory) .. "KB")
        
        return snapshot
    end,
    
    -- Compare snapshots
    Compare = function(snapshot1, snapshot2)
        if not snapshot1 or not snapshot2 then return nil end
        
        return {
            memoryDelta = snapshot2.memory - snapshot1.memory,
            entityDelta = snapshot2.entities - snapshot1.entities,
            playerDelta = snapshot2.players - snapshot1.players,
            timeDelta = snapshot2.gameTime - snapshot1.gameTime
        }
    end,
    
    -- Get memory report
    GetReport = function()
        local current = collectgarbage("count")
        local entities = #ents.GetAll()
        local players = #player.GetAll()
        
        local report = {
            current = {
                memory = current,
                entities = entities,
                players = players
            },
            history = ASC.Debug.MemoryTracker.Snapshots
        }
        
        -- Calculate trends
        if #ASC.Debug.MemoryTracker.Snapshots >= 2 then
            local oldest = ASC.Debug.MemoryTracker.Snapshots[1]
            local newest = ASC.Debug.MemoryTracker.Snapshots[#ASC.Debug.MemoryTracker.Snapshots]
            
            report.trend = {
                memoryPerSecond = (newest.memory - oldest.memory) / (newest.gameTime - oldest.gameTime),
                entitiesPerSecond = (newest.entities - oldest.entities) / (newest.gameTime - oldest.gameTime)
            }
        end
        
        return report
    end
}

-- Performance monitor
ASC.Debug.PerformanceMonitor = {
    -- Monitor function performance
    Monitor = function(func, name)
        return function(...)
            ASC.Debug.Profiler.Start(name)
            local results = {func(...)}
            ASC.Debug.Profiler.End(name)
            return unpack(results)
        end
    end,
    
    -- Monitor table method
    MonitorMethod = function(table, methodName)
        local originalMethod = table[methodName]
        if not originalMethod then return end
        
        table[methodName] = ASC.Debug.PerformanceMonitor.Monitor(originalMethod, table.ClassName or "Unknown" .. ":" .. methodName)
    end,
    
    -- Get performance summary
    GetSummary = function()
        local summary = {
            totalFunctions = 0,
            totalTime = 0,
            slowestFunctions = {},
            memoryHeaviest = {}
        }
        
        local functionList = {}
        
        for name, _ in pairs(ASC.Debug.Profiler.Results) do
            local results = ASC.Debug.Profiler.GetResults(name)
            table.insert(functionList, results)
            summary.totalFunctions = summary.totalFunctions + 1
            summary.totalTime = summary.totalTime + results.totalDuration
        end
        
        -- Sort by duration
        table.sort(functionList, function(a, b) return a.averageDuration > b.averageDuration end)
        summary.slowestFunctions = {}
        for i = 1, math.min(10, #functionList) do
            table.insert(summary.slowestFunctions, functionList[i])
        end
        
        -- Sort by memory
        table.sort(functionList, function(a, b) return a.averageMemory > b.averageMemory end)
        summary.memoryHeaviest = {}
        for i = 1, math.min(10, #functionList) do
            table.insert(summary.memoryHeaviest, functionList[i])
        end
        
        return summary
    end
}

-- Visual debugging
ASC.Debug.Visual = {
    -- Draw entity bounds
    DrawEntityBounds = function()
        if not ASC.Debug.Config.Visual.ShowEntityBounds then return end
        
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) then
                local mins, maxs = ent:GetCollisionBounds()
                local pos = ent:GetPos()
                local ang = ent:GetAngles()
                
                -- Draw bounding box
                debugoverlay.BoxAngles(pos, mins, maxs, ang, 0.1, Color(255, 255, 255, 50))
            end
        end
    end,
    
    -- Draw performance overlay
    DrawPerformanceOverlay = function()
        if not ASC.Debug.Config.Visual.ShowPerformanceOverlay then return end
        
        local x, y = 10, 10
        local lineHeight = 20
        
        -- FPS
        surface.SetFont("DermaDefault")
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x, y)
        surface.DrawText("FPS: " .. math.Round(1 / FrameTime()))
        y = y + lineHeight
        
        -- Memory
        surface.SetTextPos(x, y)
        surface.DrawText("Memory: " .. math.Round(collectgarbage("count")) .. "KB")
        y = y + lineHeight
        
        -- Entities
        surface.SetTextPos(x, y)
        surface.DrawText("Entities: " .. #ents.GetAll())
        y = y + lineHeight
        
        -- Network
        if ASC.Networking then
            surface.SetTextPos(x, y)
            surface.DrawText("Net Queue: " .. #ASC.Networking.State.OutgoingQueue)
            y = y + lineHeight
        end
    end
}

-- Console commands
concommand.Add("asc_debug_level", function(ply, cmd, args)
    if #args == 0 then
        local currentLevel = "UNKNOWN"
        for name, level in pairs(ASC.Debug.Config.Levels) do
            if level == ASC.Debug.State.CurrentLevel then
                currentLevel = name
                break
            end
        end
        
        local msg = "[ASC Debug] Current level: " .. currentLevel
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
        return
    end
    
    local newLevel = string.upper(args[1])
    if ASC.Debug.Config.Levels[newLevel] then
        ASC.Debug.State.CurrentLevel = ASC.Debug.Config.Levels[newLevel]
        local msg = "[ASC Debug] Debug level set to: " .. newLevel
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    else
        local msg = "[ASC Debug] Invalid level. Available: ERROR, WARNING, INFO, DEBUG, TRACE"
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    end
end, nil, "Set debug logging level")

concommand.Add("asc_debug_profile", function(ply, cmd, args)
    local enabled = #args > 0 and args[1] == "1"
    ASC.Debug.Config.Profiling.Enabled = enabled
    
    local msg = "[ASC Debug] Profiling " .. (enabled and "enabled" or "disabled")
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end, nil, "Toggle performance profiling")

concommand.Add("asc_debug_memory", function(ply, cmd, args)
    local report = ASC.Debug.MemoryTracker.GetReport()
    
    local function printMsg(msg)
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    printMsg("[ASC Debug] Memory Report:")
    printMsg("  Current: " .. math.Round(report.current.memory) .. "KB")
    printMsg("  Entities: " .. report.current.entities)
    printMsg("  Players: " .. report.current.players)
    
    if report.trend then
        printMsg("  Memory/sec: " .. math.Round(report.trend.memoryPerSecond, 2) .. "KB")
        printMsg("  Entities/sec: " .. math.Round(report.trend.entitiesPerSecond, 2))
    end
end, nil, "Show memory usage report")

-- Initialize debug system
function ASC.Debug.Initialize()
    ASC.Debug.Log("INFO", "Debug system initialized v" .. ASC.Debug.Config.Version)
    
    -- Take initial memory snapshot
    ASC.Debug.MemoryTracker.TakeSnapshot("initialization")
    
    -- Set up visual debugging hooks
    if CLIENT then
        hook.Add("PostDrawOpaqueRenderables", "ASC_Debug_Visual", function()
            ASC.Debug.Visual.DrawEntityBounds()
        end)
        
        hook.Add("HUDPaint", "ASC_Debug_Overlay", function()
            ASC.Debug.Visual.DrawPerformanceOverlay()
        end)
    end
end

-- Hook into core events
if ASC.Events then
    ASC.Events.Register("CoreInitialized", ASC.Debug.Initialize, 1)
end

-- Client initialization
if CLIENT then
    hook.Add("InitPostEntity", "ASC_Debug_Initialize", function()
        timer.Simple(1, ASC.Debug.Initialize)
    end)
end

print("[Advanced Space Combat] Debug & Development Tools v6.0.0 - Advanced Developer Suite Loaded Successfully!")
