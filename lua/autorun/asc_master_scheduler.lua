-- Advanced Space Combat - Master Performance Scheduler
-- Consolidates all timers and optimizes update frequencies

if not ASC then ASC = {} end

ASC.MasterScheduler = {
    Version = "1.0.0",
    Initialized = false,
    
    -- Performance tracking
    Performance = {
        CurrentFPS = 60,
        TargetFPS = 60,
        FrameTime = 0,
        LastPerformanceCheck = 0,
        PerformanceLevel = "Good" -- Good, Fair, Poor
    },
    
    -- Task queues by priority
    Tasks = {
        High = {}, -- Critical systems (10 FPS)
        Medium = {}, -- Normal systems (2 FPS)
        Low = {} -- Background tasks (0.5 FPS)
    },
    
    -- Update tracking
    LastUpdate = {
        High = 0,
        Medium = 0,
        Low = 0
    },
    
    -- Statistics
    Stats = {
        TasksExecuted = 0,
        FramesSkipped = 0,
        PerformanceAdjustments = 0
    }
}

-- Configuration
local config = ASC.Config and ASC.Config.MasterScheduler or {
    Enabled = true,
    HighPriorityRate = 0.1,
    MediumPriorityRate = 0.5,
    LowPriorityRate = 2.0,
    MaxUpdatesPerFrame = 5,
    AdaptiveThrottling = true
}

-- Register a task with the scheduler
function ASC.MasterScheduler.RegisterTask(name, priority, callback, interval)
    if not config.Enabled then return end
    
    priority = priority or "Medium"
    interval = interval or config[priority .. "PriorityRate"]
    
    local task = {
        name = name,
        callback = callback,
        interval = interval,
        lastRun = 0,
        enabled = true,
        errorCount = 0
    }
    
    table.insert(ASC.MasterScheduler.Tasks[priority], task)
    print("[ASC Scheduler] Registered task: " .. name .. " (Priority: " .. priority .. ")")
end

-- Unregister a task
function ASC.MasterScheduler.UnregisterTask(name)
    for priority, tasks in pairs(ASC.MasterScheduler.Tasks) do
        for i = #tasks, 1, -1 do
            if tasks[i].name == name then
                table.remove(tasks, i)
                print("[ASC Scheduler] Unregistered task: " .. name)
                return true
            end
        end
    end
    return false
end

-- Update performance metrics
function ASC.MasterScheduler.UpdatePerformance()
    local currentTime = SysTime()
    local frameTime = FrameTime()
    
    ASC.MasterScheduler.Performance.FrameTime = frameTime
    ASC.MasterScheduler.Performance.CurrentFPS = 1 / frameTime
    
    -- Determine performance level
    local fps = ASC.MasterScheduler.Performance.CurrentFPS
    if fps >= 45 then
        ASC.MasterScheduler.Performance.PerformanceLevel = "Good"
    elseif fps >= 25 then
        ASC.MasterScheduler.Performance.PerformanceLevel = "Fair"
    else
        ASC.MasterScheduler.Performance.PerformanceLevel = "Poor"
    end
end

-- Execute tasks for a priority level
function ASC.MasterScheduler.ExecuteTasks(priority, maxTasks)
    local tasks = ASC.MasterScheduler.Tasks[priority]
    local currentTime = CurTime()
    local executed = 0
    
    for _, task in ipairs(tasks) do
        if executed >= maxTasks then break end
        
        if task.enabled and (currentTime - task.lastRun) >= task.interval then
            local success, err = pcall(task.callback)
            
            if success then
                task.lastRun = currentTime
                task.errorCount = 0
                executed = executed + 1
                ASC.MasterScheduler.Stats.TasksExecuted = ASC.MasterScheduler.Stats.TasksExecuted + 1
            else
                task.errorCount = task.errorCount + 1
                print("[ASC Scheduler] Task error (" .. task.name .. "): " .. tostring(err))
                
                -- Disable task after 5 consecutive errors
                if task.errorCount >= 5 then
                    task.enabled = false
                    print("[ASC Scheduler] Disabled task due to errors: " .. task.name)
                end
            end
        end
    end
    
    return executed
end

-- Main scheduler update
function ASC.MasterScheduler.Update()
    if not config.Enabled then return end
    
    ASC.MasterScheduler.UpdatePerformance()
    
    local maxUpdates = config.MaxUpdatesPerFrame
    local performance = ASC.MasterScheduler.Performance.PerformanceLevel
    
    -- Adjust max updates based on performance
    if config.AdaptiveThrottling then
        if performance == "Poor" then
            maxUpdates = math.max(1, maxUpdates - 2)
            ASC.MasterScheduler.Stats.PerformanceAdjustments = ASC.MasterScheduler.Stats.PerformanceAdjustments + 1
        elseif performance == "Fair" then
            maxUpdates = math.max(2, maxUpdates - 1)
        end
    end
    
    local currentTime = CurTime()
    local executed = 0
    
    -- Execute high priority tasks first
    if currentTime - ASC.MasterScheduler.LastUpdate.High >= config.HighPriorityRate then
        executed = executed + ASC.MasterScheduler.ExecuteTasks("High", maxUpdates - executed)
        ASC.MasterScheduler.LastUpdate.High = currentTime
    end
    
    -- Execute medium priority tasks
    if executed < maxUpdates and currentTime - ASC.MasterScheduler.LastUpdate.Medium >= config.MediumPriorityRate then
        executed = executed + ASC.MasterScheduler.ExecuteTasks("Medium", maxUpdates - executed)
        ASC.MasterScheduler.LastUpdate.Medium = currentTime
    end
    
    -- Execute low priority tasks
    if executed < maxUpdates and currentTime - ASC.MasterScheduler.LastUpdate.Low >= config.LowPriorityRate then
        executed = executed + ASC.MasterScheduler.ExecuteTasks("Low", maxUpdates - executed)
        ASC.MasterScheduler.LastUpdate.Low = currentTime
    end
    
    -- Track skipped frames
    if executed == 0 then
        ASC.MasterScheduler.Stats.FramesSkipped = ASC.MasterScheduler.Stats.FramesSkipped + 1
    end
end

-- Initialize the scheduler
function ASC.MasterScheduler.Initialize()
    if ASC.MasterScheduler.Initialized then return end
    
    print("[ASC Scheduler] Initializing Master Performance Scheduler...")
    
    -- Set up main update hook
    hook.Add("Think", "ASC_MasterScheduler", ASC.MasterScheduler.Update)
    
    -- Register cleanup timer
    timer.Create("ASC_MasterScheduler_Cleanup", 300, 0, function()
        ASC.MasterScheduler.Cleanup()
    end)
    
    ASC.MasterScheduler.Initialized = true
    print("[ASC Scheduler] Master Performance Scheduler initialized successfully!")
end

-- Cleanup function
function ASC.MasterScheduler.Cleanup()
    -- Remove disabled tasks
    for priority, tasks in pairs(ASC.MasterScheduler.Tasks) do
        for i = #tasks, 1, -1 do
            if not tasks[i].enabled then
                table.remove(tasks, i)
            end
        end
    end
    
    -- Reset statistics periodically
    ASC.MasterScheduler.Stats.TasksExecuted = 0
    ASC.MasterScheduler.Stats.FramesSkipped = 0
    ASC.MasterScheduler.Stats.PerformanceAdjustments = 0
end

-- Get scheduler statistics
function ASC.MasterScheduler.GetStats()
    local totalTasks = 0
    for _, tasks in pairs(ASC.MasterScheduler.Tasks) do
        totalTasks = totalTasks + #tasks
    end
    
    return {
        TotalTasks = totalTasks,
        Performance = ASC.MasterScheduler.Performance,
        Stats = ASC.MasterScheduler.Stats
    }
end

-- Console command for debugging
concommand.Add("asc_scheduler_stats", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    local stats = ASC.MasterScheduler.GetStats()
    print("[ASC Scheduler] Statistics:")
    print("  Total Tasks: " .. stats.TotalTasks)
    print("  Performance Level: " .. stats.Performance.PerformanceLevel)
    print("  Current FPS: " .. math.floor(stats.Performance.CurrentFPS))
    print("  Tasks Executed: " .. stats.Stats.TasksExecuted)
    print("  Frames Skipped: " .. stats.Stats.FramesSkipped)
    print("  Performance Adjustments: " .. stats.Stats.PerformanceAdjustments)
end)

-- Initialize when ready
timer.Simple(1, function()
    ASC.MasterScheduler.Initialize()
end)

print("[Advanced Space Combat] Master Performance Scheduler loaded successfully!")
