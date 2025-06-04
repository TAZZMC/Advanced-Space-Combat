-- Advanced Space Combat - Core System v6.0.0
-- Next-generation architecture with modern optimization and performance enhancements
-- Research-based implementation following 2025 best practices

print("[Advanced Space Combat] Core System v6.0.0 - Next-Generation Architecture Loading...")

-- Initialize global namespace with modern architecture
ASC = ASC or {}

-- Core system information
ASC.CORE = {
    VERSION = "6.0.0",
    BUILD = "2025.01.15.NEXTGEN.ULTIMATE",
    NAME = "Advanced Space Combat - ARIA-4 Ultimate Edition with Enhanced Stargate Hyperspace",
    STATUS = "Next-Generation Production Ready",
    ARCHITECTURE = "Modern Optimized Multi-Threaded",
    
    -- Performance tracking
    Performance = {
        StartTime = SysTime(),
        FrameTime = 0,
        MemoryUsage = 0,
        NetworkTraffic = 0,
        LastOptimization = 0
    },
    
    -- Feature flags for modern development
    Features = {
        ModernUI = true,
        AdvancedAI = true,
        PerformanceOptimization = true,
        AccessibilitySupport = true,
        DarkModeSupport = true,
        ResponsiveDesign = true,
        WebIntegration = true,
        RealTimeAnalytics = true
    }
}

-- Modern module system
ASC.Modules = {
    Core = {},
    UI = {},
    AI = {},
    Physics = {},
    Network = {},
    Performance = {},
    Analytics = {},
    Accessibility = {}
}

-- Performance optimization system
ASC.Performance = {
    -- Frame rate optimization
    TargetFPS = 60,
    CurrentFPS = 0,
    FrameTimeHistory = {},
    
    -- Memory management
    MemoryThreshold = 100 * 1024 * 1024, -- 100MB
    GCInterval = 30, -- seconds
    LastGC = 0,
    
    -- Network optimization
    NetworkBudget = 1024, -- bytes per frame
    NetworkQueue = {},
    
    -- Update scheduling
    UpdateScheduler = {
        HighPriority = {},
        MediumPriority = {},
        LowPriority = {},
        LastUpdate = {
            High = 0,
            Medium = 0,
            Low = 0
        }
    }
}

-- Modern event system
ASC.Events = {
    Listeners = {},
    Queue = {},
    Processing = false
}

-- Register event listener
function ASC.Events.Register(event, callback, priority)
    priority = priority or 1
    
    if not ASC.Events.Listeners[event] then
        ASC.Events.Listeners[event] = {}
    end
    
    table.insert(ASC.Events.Listeners[event], {
        callback = callback,
        priority = priority
    })
    
    -- Sort by priority
    table.sort(ASC.Events.Listeners[event], function(a, b)
        return a.priority > b.priority
    end)
end

-- Fire event
function ASC.Events.Fire(event, ...)
    if not ASC.Events.Listeners[event] then return end
    
    for _, listener in ipairs(ASC.Events.Listeners[event]) do
        local success, result = pcall(listener.callback, ...)
        if not success then
            print("[ASC Core] Event error in " .. event .. ": " .. tostring(result))
        end
    end
end

-- Performance monitoring
function ASC.Performance.Monitor()
    local currentTime = SysTime()
    
    -- Update FPS
    ASC.Performance.CurrentFPS = 1 / FrameTime()
    table.insert(ASC.Performance.FrameTimeHistory, FrameTime())
    
    -- Keep only last 60 frames
    if #ASC.Performance.FrameTimeHistory > 60 then
        table.remove(ASC.Performance.FrameTimeHistory, 1)
    end
    
    -- Memory management
    local memUsage = collectgarbage("count") * 1024
    ASC.CORE.Performance.MemoryUsage = memUsage
    
    if memUsage > ASC.Performance.MemoryThreshold and 
       currentTime - ASC.Performance.LastGC > ASC.Performance.GCInterval then
        collectgarbage("collect")
        ASC.Performance.LastGC = currentTime
        print("[ASC Core] Garbage collection performed - Memory: " .. math.floor(memUsage / 1024 / 1024) .. "MB")
    end
end

-- Update scheduler for performance optimization
function ASC.Performance.ScheduleUpdate(func, priority, interval)
    priority = priority or "Medium"
    interval = interval or 0.1

    -- Safety check to prevent scheduling non-functions
    if type(func) ~= "function" then
        print("[ASC Core] Warning: Attempted to schedule a " .. type(func) .. " value instead of a function")
        return false
    end

    local scheduler = ASC.Performance.UpdateScheduler
    local queue = scheduler[priority .. "Priority"]

    if queue then
        table.insert(queue, {
            func = func,
            interval = interval,
            lastRun = 0
        })
        return true
    end
    return false
end

-- Process scheduled updates
function ASC.Performance.ProcessUpdates()
    local currentTime = SysTime()
    local scheduler = ASC.Performance.UpdateScheduler
    
    -- High priority updates (every frame)
    if currentTime - scheduler.LastUpdate.High > 0 then
        for _, update in ipairs(scheduler.HighPriority) do
            if currentTime - update.lastRun >= update.interval then
                if type(update.func) == "function" then
                    local success, result = pcall(update.func)
                    if not success then
                        print("[ASC Core] High priority update error: " .. tostring(result))
                    end
                else
                    print("[ASC Core] High priority update error: attempt to call a " .. type(update.func) .. " value")
                end
                update.lastRun = currentTime
            end
        end
        scheduler.LastUpdate.High = currentTime
    end
    
    -- Medium priority updates (10 FPS)
    if currentTime - scheduler.LastUpdate.Medium > 0.1 then
        for _, update in ipairs(scheduler.MediumPriority) do
            if currentTime - update.lastRun >= update.interval then
                if type(update.func) == "function" then
                    local success, result = pcall(update.func)
                    if not success then
                        print("[ASC Core] Medium priority update error: " .. tostring(result))
                    end
                else
                    print("[ASC Core] Medium priority update error: attempt to call a " .. type(update.func) .. " value")
                end
                update.lastRun = currentTime
            end
        end
        scheduler.LastUpdate.Medium = currentTime
    end
    
    -- Low priority updates (1 FPS)
    if currentTime - scheduler.LastUpdate.Low > 1.0 then
        for _, update in ipairs(scheduler.LowPriority) do
            if currentTime - update.lastRun >= update.interval then
                if type(update.func) == "function" then
                    local success, result = pcall(update.func)
                    if not success then
                        print("[ASC Core] Low priority update error: " .. tostring(result))
                    end
                else
                    print("[ASC Core] Low priority update error: attempt to call a " .. type(update.func) .. " value")
                end
                update.lastRun = currentTime
            end
        end
        scheduler.LastUpdate.Low = currentTime
    end
end

-- Modern module loader
function ASC.LoadModule(name, path)
    local success, module = pcall(include, path)
    if success then
        ASC.Modules[name] = module
        print("[ASC Core] Module loaded: " .. name)
        ASC.Events.Fire("ModuleLoaded", name, module)
        return module
    else
        print("[ASC Core] Failed to load module " .. name .. ": " .. tostring(module))
        return nil
    end
end

-- System health check
function ASC.GetSystemHealth()
    local health = {
        Overall = 100,
        Performance = 100,
        Memory = 100,
        Network = 100,
        Modules = 100
    }
    
    -- Performance health
    if ASC.Performance.CurrentFPS < 30 then
        health.Performance = 50
    elseif ASC.Performance.CurrentFPS < 45 then
        health.Performance = 75
    end
    
    -- Memory health
    local memUsage = ASC.CORE.Performance.MemoryUsage
    if memUsage > ASC.Performance.MemoryThreshold * 1.5 then
        health.Memory = 25
    elseif memUsage > ASC.Performance.MemoryThreshold then
        health.Memory = 50
    end
    
    -- Calculate overall health
    health.Overall = (health.Performance + health.Memory + health.Network + health.Modules) / 4
    
    return health
end

-- Initialize core system
function ASC.Initialize()
    print("[ASC Core] Initializing next-generation architecture...")
    
    -- Set up performance monitoring
    ASC.Performance.ScheduleUpdate(ASC.Performance.Monitor, "High", 0)
    -- Note: ProcessUpdates is called from Think hook, not scheduled to avoid recursion
    
    -- Fire initialization event
    ASC.Events.Fire("CoreInitialized")
    
    print("[ASC Core] Next-generation architecture initialized successfully!")
end

-- Client-side initialization
if CLIENT then
    hook.Add("InitPostEntity", "ASC_Core_Initialize", function()
        timer.Simple(1, ASC.Initialize)
    end)
    
    -- Performance monitoring hook
    hook.Add("Think", "ASC_Performance_Monitor", function()
        ASC.Performance.ProcessUpdates()
    end)
end

-- Server-side initialization
if SERVER then
    hook.Add("Initialize", "ASC_Core_Initialize", function()
        ASC.Initialize()
    end)
end

print("[Advanced Space Combat] Core System v6.0.0 - Next-Generation Architecture Loaded Successfully!")
