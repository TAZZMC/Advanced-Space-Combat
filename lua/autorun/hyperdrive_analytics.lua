-- Hyperdrive Analytics and Telemetry System
-- Advanced analytics for usage patterns, performance optimization, and predictive maintenance

if CLIENT then return end

-- Initialize analytics system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Analytics = HYPERDRIVE.Analytics or {}

print("[Hyperdrive] Analytics and telemetry system loading...")

-- Analytics configuration
HYPERDRIVE.Analytics.Config = {
    EnableAnalytics = true,         -- Enable analytics collection
    EnableTelemetry = true,         -- Enable telemetry reporting
    DataRetention = 604800,         -- Data retention period (7 days)
    SamplingRate = 1.0,             -- Data sampling rate (0.0-1.0)
    AggregationInterval = 300,      -- Data aggregation interval (5 minutes)
    PredictiveAnalysis = true,      -- Enable predictive analysis
    PrivacyMode = false,            -- Enable privacy mode (anonymize data)
    ExportEnabled = true,           -- Enable data export
}

-- Analytics data storage
HYPERDRIVE.Analytics.Data = {
    jumpMetrics = {},
    performanceMetrics = {},
    errorMetrics = {},
    usagePatterns = {},
    playerBehavior = {},
    systemHealth = {},
    predictions = {},
    aggregatedData = {},
}

-- Metric types
HYPERDRIVE.Analytics.MetricTypes = {
    JUMP_SUCCESS = "jump_success",
    JUMP_FAILURE = "jump_failure",
    JUMP_DURATION = "jump_duration",
    ENTITY_COUNT = "entity_count",
    ENERGY_CONSUMPTION = "energy_consumption",
    NETWORK_USAGE = "network_usage",
    MEMORY_USAGE = "memory_usage",
    ERROR_RATE = "error_rate",
    PLAYER_ACTIVITY = "player_activity",
    SYSTEM_LOAD = "system_load",
}

-- Function to get analytics configuration
local function GetAnalyticsConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("Analytics", key, HYPERDRIVE.Analytics.Config[key] or default)
    end
    return HYPERDRIVE.Analytics.Config[key] or default
end

-- Record metric data point
function HYPERDRIVE.Analytics.RecordMetric(metricType, value, metadata)
    if not GetAnalyticsConfig("EnableAnalytics", true) then return end
    
    -- Apply sampling rate
    local samplingRate = GetAnalyticsConfig("SamplingRate", 1.0)
    if math.random() > samplingRate then return end
    
    local dataPoint = {
        type = metricType,
        value = value,
        metadata = metadata or {},
        timestamp = CurTime(),
        serverTime = os.time(),
        id = #HYPERDRIVE.Analytics.Data.jumpMetrics + 1
    }
    
    -- Anonymize data if privacy mode is enabled
    if GetAnalyticsConfig("PrivacyMode", false) then
        dataPoint = HYPERDRIVE.Analytics.AnonymizeData(dataPoint)
    end
    
    -- Store in appropriate category
    if metricType == HYPERDRIVE.Analytics.MetricTypes.JUMP_SUCCESS or 
       metricType == HYPERDRIVE.Analytics.MetricTypes.JUMP_FAILURE or
       metricType == HYPERDRIVE.Analytics.MetricTypes.JUMP_DURATION then
        table.insert(HYPERDRIVE.Analytics.Data.jumpMetrics, dataPoint)
    elseif metricType == HYPERDRIVE.Analytics.MetricTypes.NETWORK_USAGE or
           metricType == HYPERDRIVE.Analytics.MetricTypes.MEMORY_USAGE or
           metricType == HYPERDRIVE.Analytics.MetricTypes.SYSTEM_LOAD then
        table.insert(HYPERDRIVE.Analytics.Data.performanceMetrics, dataPoint)
    elseif metricType == HYPERDRIVE.Analytics.MetricTypes.ERROR_RATE then
        table.insert(HYPERDRIVE.Analytics.Data.errorMetrics, dataPoint)
    elseif metricType == HYPERDRIVE.Analytics.MetricTypes.PLAYER_ACTIVITY then
        table.insert(HYPERDRIVE.Analytics.Data.playerBehavior, dataPoint)
    end
    
    -- Cleanup old data
    HYPERDRIVE.Analytics.CleanupOldData()
end

-- Anonymize sensitive data
function HYPERDRIVE.Analytics.AnonymizeData(dataPoint)
    local anonymized = table.Copy(dataPoint)
    
    -- Remove or hash sensitive information
    if anonymized.metadata.playerName then
        anonymized.metadata.playerName = "Player_" .. string.sub(util.SHA1(anonymized.metadata.playerName), 1, 8)
    end
    
    if anonymized.metadata.steamID then
        anonymized.metadata.steamID = "STEAM_" .. string.sub(util.SHA1(anonymized.metadata.steamID), 1, 8)
    end
    
    if anonymized.metadata.serverIP then
        anonymized.metadata.serverIP = nil
    end
    
    return anonymized
end

-- Aggregate data for analysis
function HYPERDRIVE.Analytics.AggregateData()
    local currentTime = CurTime()
    local aggregationInterval = GetAnalyticsConfig("AggregationInterval", 300)
    
    -- Create time buckets
    local timeBucket = math.floor(currentTime / aggregationInterval) * aggregationInterval
    
    if not HYPERDRIVE.Analytics.Data.aggregatedData[timeBucket] then
        HYPERDRIVE.Analytics.Data.aggregatedData[timeBucket] = {
            jumpCount = 0,
            successRate = 0,
            averageDuration = 0,
            averageEntityCount = 0,
            totalEnergyConsumption = 0,
            errorCount = 0,
            playerCount = 0,
            systemLoad = 0,
            networkUsage = 0,
            memoryUsage = 0,
        }
    end
    
    local bucket = HYPERDRIVE.Analytics.Data.aggregatedData[timeBucket]
    
    -- Aggregate jump metrics
    local recentJumps = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.JUMP_SUCCESS, aggregationInterval)
    local recentFailures = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.JUMP_FAILURE, aggregationInterval)
    
    bucket.jumpCount = #recentJumps + #recentFailures
    bucket.successRate = bucket.jumpCount > 0 and (#recentJumps / bucket.jumpCount) or 0
    
    -- Calculate averages
    local totalDuration = 0
    local totalEntityCount = 0
    local totalEnergy = 0
    
    for _, jump in ipairs(recentJumps) do
        if jump.metadata.duration then
            totalDuration = totalDuration + jump.metadata.duration
        end
        if jump.metadata.entityCount then
            totalEntityCount = totalEntityCount + jump.metadata.entityCount
        end
        if jump.metadata.energyUsed then
            totalEnergy = totalEnergy + jump.metadata.energyUsed
        end
    end
    
    if #recentJumps > 0 then
        bucket.averageDuration = totalDuration / #recentJumps
        bucket.averageEntityCount = totalEntityCount / #recentJumps
        bucket.totalEnergyConsumption = totalEnergy
    end
    
    -- Aggregate performance metrics
    local recentPerformance = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.SYSTEM_LOAD, aggregationInterval)
    if #recentPerformance > 0 then
        local totalLoad = 0
        for _, metric in ipairs(recentPerformance) do
            totalLoad = totalLoad + metric.value
        end
        bucket.systemLoad = totalLoad / #recentPerformance
    end
    
    return bucket
end

-- Get recent metrics of specific type
function HYPERDRIVE.Analytics.GetRecentMetrics(metricType, timeWindow)
    local currentTime = CurTime()
    local metrics = {}
    
    -- Search in appropriate data category
    local dataCategory = HYPERDRIVE.Analytics.Data.jumpMetrics
    if metricType == HYPERDRIVE.Analytics.MetricTypes.NETWORK_USAGE or
       metricType == HYPERDRIVE.Analytics.MetricTypes.MEMORY_USAGE or
       metricType == HYPERDRIVE.Analytics.MetricTypes.SYSTEM_LOAD then
        dataCategory = HYPERDRIVE.Analytics.Data.performanceMetrics
    elseif metricType == HYPERDRIVE.Analytics.MetricTypes.ERROR_RATE then
        dataCategory = HYPERDRIVE.Analytics.Data.errorMetrics
    elseif metricType == HYPERDRIVE.Analytics.MetricTypes.PLAYER_ACTIVITY then
        dataCategory = HYPERDRIVE.Analytics.Data.playerBehavior
    end
    
    for _, dataPoint in ipairs(dataCategory) do
        if dataPoint.type == metricType and (currentTime - dataPoint.timestamp) <= timeWindow then
            table.insert(metrics, dataPoint)
        end
    end
    
    return metrics
end

-- Predictive analysis
function HYPERDRIVE.Analytics.RunPredictiveAnalysis()
    if not GetAnalyticsConfig("PredictiveAnalysis", true) then return end
    
    local predictions = {}
    
    -- Predict system load based on historical patterns
    local loadMetrics = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.SYSTEM_LOAD, 3600) -- Last hour
    if #loadMetrics >= 10 then
        local trend = HYPERDRIVE.Analytics.CalculateTrend(loadMetrics)
        predictions.systemLoadTrend = trend
        
        -- Predict if system load will exceed threshold in next 30 minutes
        local currentLoad = loadMetrics[#loadMetrics].value
        local predictedLoad = currentLoad + (trend * 1800) -- 30 minutes
        predictions.systemLoadPrediction = {
            current = currentLoad,
            predicted = predictedLoad,
            timeframe = 1800,
            riskLevel = predictedLoad > 0.8 and "high" or (predictedLoad > 0.6 and "medium" or "low")
        }
    end
    
    -- Predict jump success rate
    local successMetrics = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.JUMP_SUCCESS, 3600)
    local failureMetrics = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.JUMP_FAILURE, 3600)
    
    if #successMetrics + #failureMetrics >= 5 then
        local successRate = #successMetrics / (#successMetrics + #failureMetrics)
        predictions.jumpSuccessRate = {
            current = successRate,
            trend = HYPERDRIVE.Analytics.CalculateSuccessRateTrend(),
            recommendation = successRate < 0.9 and "investigate" or "normal"
        }
    end
    
    -- Store predictions
    HYPERDRIVE.Analytics.Data.predictions = predictions
    
    return predictions
end

-- Calculate trend from metrics
function HYPERDRIVE.Analytics.CalculateTrend(metrics)
    if #metrics < 2 then return 0 end
    
    -- Simple linear regression
    local n = #metrics
    local sumX, sumY, sumXY, sumX2 = 0, 0, 0, 0
    
    for i, metric in ipairs(metrics) do
        local x = i
        local y = metric.value
        sumX = sumX + x
        sumY = sumY + y
        sumXY = sumXY + (x * y)
        sumX2 = sumX2 + (x * x)
    end
    
    local slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)
    return slope
end

-- Calculate success rate trend
function HYPERDRIVE.Analytics.CalculateSuccessRateTrend()
    local timeWindows = {300, 600, 1200, 1800} -- 5, 10, 20, 30 minutes
    local rates = {}
    
    for _, window in ipairs(timeWindows) do
        local successes = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.JUMP_SUCCESS, window)
        local failures = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.JUMP_FAILURE, window)
        local total = #successes + #failures
        
        if total > 0 then
            table.insert(rates, #successes / total)
        end
    end
    
    if #rates >= 2 then
        return HYPERDRIVE.Analytics.CalculateTrend(rates)
    end
    
    return 0
end

-- Generate analytics report
function HYPERDRIVE.Analytics.GenerateReport(timeframe)
    timeframe = timeframe or 3600 -- Default 1 hour
    
    local report = {
        timeframe = timeframe,
        generatedAt = CurTime(),
        summary = {},
        details = {},
        predictions = HYPERDRIVE.Analytics.Data.predictions,
        recommendations = {}
    }
    
    -- Jump statistics
    local successes = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.JUMP_SUCCESS, timeframe)
    local failures = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.JUMP_FAILURE, timeframe)
    local totalJumps = #successes + #failures
    
    report.summary.totalJumps = totalJumps
    report.summary.successRate = totalJumps > 0 and (#successes / totalJumps) or 0
    report.summary.failureRate = totalJumps > 0 and (#failures / totalJumps) or 0
    
    -- Performance statistics
    local performanceMetrics = HYPERDRIVE.Analytics.GetRecentMetrics(HYPERDRIVE.Analytics.MetricTypes.SYSTEM_LOAD, timeframe)
    if #performanceMetrics > 0 then
        local totalLoad = 0
        local maxLoad = 0
        for _, metric in ipairs(performanceMetrics) do
            totalLoad = totalLoad + metric.value
            maxLoad = math.max(maxLoad, metric.value)
        end
        report.summary.averageSystemLoad = totalLoad / #performanceMetrics
        report.summary.peakSystemLoad = maxLoad
    end
    
    -- Generate recommendations
    if report.summary.successRate < 0.9 then
        table.insert(report.recommendations, "Jump success rate is below 90%. Consider investigating error logs.")
    end
    
    if report.summary.peakSystemLoad and report.summary.peakSystemLoad > 0.8 then
        table.insert(report.recommendations, "Peak system load exceeded 80%. Consider performance optimization.")
    end
    
    return report
end

-- Cleanup old data
function HYPERDRIVE.Analytics.CleanupOldData()
    local currentTime = CurTime()
    local retentionPeriod = GetAnalyticsConfig("DataRetention", 604800) -- 7 days
    
    -- Cleanup function for data arrays
    local function cleanupArray(dataArray)
        for i = #dataArray, 1, -1 do
            if currentTime - dataArray[i].timestamp > retentionPeriod then
                table.remove(dataArray, i)
            end
        end
    end
    
    -- Cleanup all data categories
    cleanupArray(HYPERDRIVE.Analytics.Data.jumpMetrics)
    cleanupArray(HYPERDRIVE.Analytics.Data.performanceMetrics)
    cleanupArray(HYPERDRIVE.Analytics.Data.errorMetrics)
    cleanupArray(HYPERDRIVE.Analytics.Data.playerBehavior)
    
    -- Cleanup aggregated data
    for timeBucket, _ in pairs(HYPERDRIVE.Analytics.Data.aggregatedData) do
        if currentTime - timeBucket > retentionPeriod then
            HYPERDRIVE.Analytics.Data.aggregatedData[timeBucket] = nil
        end
    end
end

-- Export analytics data
function HYPERDRIVE.Analytics.ExportData(format)
    if not GetAnalyticsConfig("ExportEnabled", true) then
        return nil, "Data export is disabled"
    end
    
    format = format or "json"
    
    local exportData = {
        metadata = {
            exportTime = os.time(),
            serverName = GetHostName(),
            version = "2.0.0",
            dataRetention = GetAnalyticsConfig("DataRetention", 604800)
        },
        analytics = HYPERDRIVE.Analytics.Data,
        report = HYPERDRIVE.Analytics.GenerateReport(86400) -- 24 hour report
    }
    
    if format == "json" then
        return util.TableToJSON(exportData), "application/json"
    elseif format == "csv" then
        -- Simple CSV export for jump metrics
        local csv = "timestamp,type,value,duration,entityCount,energyUsed\n"
        for _, metric in ipairs(HYPERDRIVE.Analytics.Data.jumpMetrics) do
            csv = csv .. string.format("%d,%s,%s,%s,%s,%s\n",
                metric.serverTime,
                metric.type,
                tostring(metric.value),
                tostring(metric.metadata.duration or ""),
                tostring(metric.metadata.entityCount or ""),
                tostring(metric.metadata.energyUsed or "")
            )
        end
        return csv, "text/csv"
    end
    
    return nil, "Unsupported format"
end

-- Periodic data aggregation and analysis
timer.Create("HyperdriveAnalyticsAggregation", GetAnalyticsConfig("AggregationInterval", 300), 0, function()
    HYPERDRIVE.Analytics.AggregateData()
    HYPERDRIVE.Analytics.RunPredictiveAnalysis()
end)

-- Periodic cleanup
timer.Create("HyperdriveAnalyticsCleanup", 3600, 0, function() -- Every hour
    HYPERDRIVE.Analytics.CleanupOldData()
end)

-- Console commands for analytics
concommand.Add("hyperdrive_analytics_report", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local timeframe = tonumber(args[1]) or 3600
    local report = HYPERDRIVE.Analytics.GenerateReport(timeframe)
    
    ply:ChatPrint("[Hyperdrive Analytics] Report (last " .. timeframe .. "s):")
    ply:ChatPrint("  • Total Jumps: " .. report.summary.totalJumps)
    ply:ChatPrint("  • Success Rate: " .. string.format("%.1f%%", report.summary.successRate * 100))
    ply:ChatPrint("  • Average Load: " .. string.format("%.2f", report.summary.averageSystemLoad or 0))
    ply:ChatPrint("  • Peak Load: " .. string.format("%.2f", report.summary.peakSystemLoad or 0))
    
    if #report.recommendations > 0 then
        ply:ChatPrint("  • Recommendations:")
        for _, rec in ipairs(report.recommendations) do
            ply:ChatPrint("    - " .. rec)
        end
    end
end)

print("[Hyperdrive] Analytics and telemetry system loaded")
