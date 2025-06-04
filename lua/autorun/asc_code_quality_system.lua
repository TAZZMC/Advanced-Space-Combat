-- Advanced Space Combat - Code Quality and Standards System v1.0.0
-- Ensures code quality, performance, and maintainability standards

print("[Advanced Space Combat] Code Quality System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.CodeQuality = ASC.CodeQuality or {}

-- Code quality configuration
ASC.CodeQuality.Config = {
    -- Performance standards
    Performance = {
        MaxFunctionTime = 0.005, -- 5ms max per function call
        MaxMemoryGrowth = 10, -- 10MB max memory growth per minute
        MaxNetworkRate = 100, -- 100 network messages per second
        MaxEntityUpdates = 1000 -- 1000 entity updates per second
    },
    
    -- Code standards
    Standards = {
        MaxFunctionLength = 50, -- lines
        MaxFileLength = 1000, -- lines
        RequireDocumentation = true,
        RequireErrorHandling = true,
        RequireInputValidation = true
    },
    
    -- Monitoring
    EnableMonitoring = true,
    LogLevel = "INFO", -- DEBUG, INFO, WARN, ERROR
    ReportInterval = 300 -- 5 minutes
}

-- Quality metrics tracking
ASC.CodeQuality.Metrics = {
    FunctionCalls = {},
    MemoryUsage = {},
    NetworkActivity = {},
    ErrorCounts = {},
    PerformanceIssues = {}
}

-- Function performance profiler
ASC.CodeQuality.Profiler = {
    ActiveProfiles = {},
    Results = {}
}

-- Start profiling a function
function ASC.CodeQuality.StartProfile(functionName)
    if not ASC.CodeQuality.Config.EnableMonitoring then return end
    
    ASC.CodeQuality.Profiler.ActiveProfiles[functionName] = {
        startTime = SysTime(),
        startMemory = collectgarbage("count")
    }
end

-- End profiling a function
function ASC.CodeQuality.EndProfile(functionName)
    if not ASC.CodeQuality.Config.EnableMonitoring then return end
    if not ASC.CodeQuality.Profiler.ActiveProfiles[functionName] then return end
    
    local profile = ASC.CodeQuality.Profiler.ActiveProfiles[functionName]
    local endTime = SysTime()
    local endMemory = collectgarbage("count")
    
    local result = {
        functionName = functionName,
        executionTime = endTime - profile.startTime,
        memoryUsed = endMemory - profile.startMemory,
        timestamp = CurTime()
    }
    
    -- Store result
    if not ASC.CodeQuality.Profiler.Results[functionName] then
        ASC.CodeQuality.Profiler.Results[functionName] = {}
    end
    
    table.insert(ASC.CodeQuality.Profiler.Results[functionName], result)
    
    -- Keep only last 100 results per function
    if #ASC.CodeQuality.Profiler.Results[functionName] > 100 then
        table.remove(ASC.CodeQuality.Profiler.Results[functionName], 1)
    end
    
    -- Check for performance issues
    if result.executionTime > ASC.CodeQuality.Config.Performance.MaxFunctionTime then
        ASC.CodeQuality.ReportPerformanceIssue("SLOW_FUNCTION", {
            function_name = functionName,
            execution_time = result.executionTime,
            threshold = ASC.CodeQuality.Config.Performance.MaxFunctionTime
        })
    end
    
    ASC.CodeQuality.Profiler.ActiveProfiles[functionName] = nil
end

-- Wrap function with profiling
function ASC.CodeQuality.ProfileFunction(func, functionName)
    return function(...)
        ASC.CodeQuality.StartProfile(functionName)
        local results = {pcall(func, ...)}
        ASC.CodeQuality.EndProfile(functionName)
        
        if not results[1] then
            ASC.CodeQuality.ReportError("FUNCTION_ERROR", {
                function_name = functionName,
                error_message = results[2]
            })
        end
        
        return unpack(results, 2)
    end
end

-- Input validation helper
function ASC.CodeQuality.ValidateInput(value, expectedType, functionName)
    local actualType = type(value)
    
    if actualType ~= expectedType then
        ASC.CodeQuality.ReportError("INPUT_VALIDATION", {
            function_name = functionName or "unknown",
            expected_type = expectedType,
            actual_type = actualType,
            value = tostring(value)
        })
        return false
    end
    
    return true
end

-- Entity validation helper
function ASC.CodeQuality.ValidateEntity(entity, functionName)
    if not IsValid(entity) then
        ASC.CodeQuality.ReportError("INVALID_ENTITY", {
            function_name = functionName or "unknown",
            entity = tostring(entity)
        })
        return false
    end
    
    return true
end

-- Player validation helper
function ASC.CodeQuality.ValidatePlayer(player, functionName)
    if not IsValid(player) or not player:IsPlayer() then
        ASC.CodeQuality.ReportError("INVALID_PLAYER", {
            function_name = functionName or "unknown",
            player = tostring(player)
        })
        return false
    end
    
    return true
end

-- Report performance issue
function ASC.CodeQuality.ReportPerformanceIssue(issueType, data)
    local issue = {
        type = issueType,
        data = data,
        timestamp = CurTime(),
        severity = "WARNING"
    }
    
    table.insert(ASC.CodeQuality.Metrics.PerformanceIssues, issue)
    
    if ASC.CodeQuality.Config.LogLevel == "DEBUG" or ASC.CodeQuality.Config.LogLevel == "INFO" then
        print("[ASC Quality] Performance Issue: " .. issueType .. " - " .. util.TableToJSON(data))
    end
end

-- Report error
function ASC.CodeQuality.ReportError(errorType, data)
    local error = {
        type = errorType,
        data = data,
        timestamp = CurTime(),
        severity = "ERROR"
    }
    
    if not ASC.CodeQuality.Metrics.ErrorCounts[errorType] then
        ASC.CodeQuality.Metrics.ErrorCounts[errorType] = 0
    end
    ASC.CodeQuality.Metrics.ErrorCounts[errorType] = ASC.CodeQuality.Metrics.ErrorCounts[errorType] + 1
    
    print("[ASC Quality] Error: " .. errorType .. " - " .. util.TableToJSON(data))
end

-- Memory monitoring
function ASC.CodeQuality.MonitorMemory()
    local currentMemory = collectgarbage("count")
    
    table.insert(ASC.CodeQuality.Metrics.MemoryUsage, {
        memory = currentMemory,
        timestamp = CurTime()
    })
    
    -- Keep only last 100 measurements
    if #ASC.CodeQuality.Metrics.MemoryUsage > 100 then
        table.remove(ASC.CodeQuality.Metrics.MemoryUsage, 1)
    end
    
    -- Check for memory growth
    if #ASC.CodeQuality.Metrics.MemoryUsage >= 2 then
        local previous = ASC.CodeQuality.Metrics.MemoryUsage[#ASC.CodeQuality.Metrics.MemoryUsage - 1]
        local current = ASC.CodeQuality.Metrics.MemoryUsage[#ASC.CodeQuality.Metrics.MemoryUsage]
        
        local timeDiff = current.timestamp - previous.timestamp
        local memoryDiff = current.memory - previous.memory
        
        if timeDiff > 0 then
            local growthRate = (memoryDiff / timeDiff) * 60 -- MB per minute
            
            if growthRate > ASC.CodeQuality.Config.Performance.MaxMemoryGrowth then
                ASC.CodeQuality.ReportPerformanceIssue("MEMORY_GROWTH", {
                    growth_rate = growthRate,
                    threshold = ASC.CodeQuality.Config.Performance.MaxMemoryGrowth
                })
            end
        end
    end
end

-- Generate quality report
function ASC.CodeQuality.GenerateReport()
    local report = {
        timestamp = CurTime(),
        performance_issues = #ASC.CodeQuality.Metrics.PerformanceIssues,
        error_counts = table.Count(ASC.CodeQuality.Metrics.ErrorCounts),
        memory_usage = collectgarbage("count"),
        profiled_functions = table.Count(ASC.CodeQuality.Profiler.Results)
    }
    
    -- Calculate average function times
    report.function_performance = {}
    for functionName, results in pairs(ASC.CodeQuality.Profiler.Results) do
        local totalTime = 0
        local count = #results
        
        for _, result in ipairs(results) do
            totalTime = totalTime + result.executionTime
        end
        
        report.function_performance[functionName] = {
            average_time = count > 0 and (totalTime / count) or 0,
            call_count = count,
            max_time = 0
        }
        
        -- Find max time
        for _, result in ipairs(results) do
            if result.executionTime > report.function_performance[functionName].max_time then
                report.function_performance[functionName].max_time = result.executionTime
            end
        end
    end
    
    return report
end

-- Enhanced error handling wrapper
function ASC.CodeQuality.SafeCall(func, functionName, ...)
    ASC.CodeQuality.StartProfile(functionName)
    
    local success, result = pcall(func, ...)
    
    ASC.CodeQuality.EndProfile(functionName)
    
    if not success then
        ASC.CodeQuality.ReportError("SAFE_CALL_ERROR", {
            function_name = functionName,
            error_message = result
        })
        return nil, result
    end
    
    return result
end

-- Auto-apply quality standards to ASC functions
function ASC.CodeQuality.ApplyStandards()
    -- Wrap critical ASC functions with profiling
    if ASC.AI and ASC.AI.ProcessQuery then
        ASC.AI.ProcessQuery = ASC.CodeQuality.ProfileFunction(ASC.AI.ProcessQuery, "ASC.AI.ProcessQuery")
    end
    
    if HYPERDRIVE and HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.UpdateShipDetection then
        HYPERDRIVE.ShipCore.UpdateShipDetection = ASC.CodeQuality.ProfileFunction(
            HYPERDRIVE.ShipCore.UpdateShipDetection, 
            "HYPERDRIVE.ShipCore.UpdateShipDetection"
        )
    end
    
    print("[ASC Quality] Applied quality standards to critical functions")
end

-- Start monitoring
if ASC.CodeQuality.Config.EnableMonitoring then
    -- Memory monitoring timer
    timer.Create("ASC_Quality_Memory", 10, 0, function()
        ASC.CodeQuality.MonitorMemory()
    end)
    
    -- Quality report timer
    timer.Create("ASC_Quality_Report", ASC.CodeQuality.Config.ReportInterval, 0, function()
        local report = ASC.CodeQuality.GenerateReport()
        print("[ASC Quality] Quality Report: " .. util.TableToJSON(report))
    end)
    
    -- Apply standards after initialization
    timer.Simple(2, function()
        ASC.CodeQuality.ApplyStandards()
    end)
end

-- Console commands
concommand.Add("asc_quality_report", function(ply, cmd, args)
    local report = ASC.CodeQuality.GenerateReport()
    
    local output = {
        "[Advanced Space Combat] Code Quality Report:",
        "• Performance Issues: " .. report.performance_issues,
        "• Error Types: " .. report.error_counts,
        "• Memory Usage: " .. string.format("%.2f MB", report.memory_usage / 1024),
        "• Profiled Functions: " .. report.profiled_functions
    }
    
    if IsValid(ply) then
        for _, line in ipairs(output) do
            ply:ChatPrint(line)
        end
    else
        for _, line in ipairs(output) do
            print(line)
        end
    end
end, nil, "Show code quality report")

concommand.Add("asc_quality_profile", function(ply, cmd, args)
    if #args < 1 then
        local msg = "Usage: asc_quality_profile <function_name>"
        if IsValid(ply) then
            ply:ChatPrint("[Advanced Space Combat] " .. msg)
        else
            print("[Advanced Space Combat] " .. msg)
        end
        return
    end
    
    local functionName = args[1]
    local results = ASC.CodeQuality.Profiler.Results[functionName]
    
    if not results or #results == 0 then
        local msg = "No profiling data for function: " .. functionName
        if IsValid(ply) then
            ply:ChatPrint("[Advanced Space Combat] " .. msg)
        else
            print("[Advanced Space Combat] " .. msg)
        end
        return
    end
    
    local totalTime = 0
    local maxTime = 0
    local minTime = math.huge
    
    for _, result in ipairs(results) do
        totalTime = totalTime + result.executionTime
        maxTime = math.max(maxTime, result.executionTime)
        minTime = math.min(minTime, result.executionTime)
    end
    
    local avgTime = totalTime / #results
    
    local output = {
        "[Advanced Space Combat] Profile for " .. functionName .. ":",
        "• Call Count: " .. #results,
        "• Average Time: " .. string.format("%.3f ms", avgTime * 1000),
        "• Min Time: " .. string.format("%.3f ms", minTime * 1000),
        "• Max Time: " .. string.format("%.3f ms", maxTime * 1000)
    }
    
    if IsValid(ply) then
        for _, line in ipairs(output) do
            ply:ChatPrint(line)
        end
    else
        for _, line in ipairs(output) do
            print(line)
        end
    end
end, nil, "Show profiling data for a specific function")

print("[Advanced Space Combat] Code Quality System loaded successfully!")
