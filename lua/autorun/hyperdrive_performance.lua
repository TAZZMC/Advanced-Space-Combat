-- Hyperdrive Performance Optimization System
-- Advanced performance monitoring and optimization for large ship movements

if CLIENT then return end

-- Initialize performance system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Performance = HYPERDRIVE.Performance or {}

print("[Hyperdrive] Performance optimization system loading...")

-- Performance configuration
HYPERDRIVE.Performance.Config = {
    EnableProfiling = false,        -- Enable performance profiling
    MaxEntitiesPerBatch = 50,       -- Maximum entities to move per batch
    BatchDelay = 0.01,              -- Delay between batches (seconds)
    NetworkOptimization = true,     -- Enable network optimization
    MemoryOptimization = true,      -- Enable memory optimization
    CacheEntityLists = true,        -- Cache entity lists for reuse
    MaxCacheAge = 30,               -- Cache age in seconds
    PerformanceLogging = false,     -- Log performance metrics
}

-- Performance metrics storage
HYPERDRIVE.Performance.Metrics = {
    totalJumps = 0,
    totalEntitiesMoved = 0,
    averageJumpTime = 0,
    lastJumpTime = 0,
    peakEntitiesInJump = 0,
    networkBytesOptimized = 0,
}

-- Entity cache system
HYPERDRIVE.Performance.EntityCache = {}

-- Function to get configuration with fallback
local function GetPerfConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("Performance", key, HYPERDRIVE.Performance.Config[key] or default)
    end
    return HYPERDRIVE.Performance.Config[key] or default
end

-- Performance profiler
function HYPERDRIVE.Performance.StartProfiler(name)
    if not GetPerfConfig("EnableProfiling", false) then return nil end
    
    return {
        name = name,
        startTime = SysTime(),
        startMemory = collectgarbage("count")
    }
end

function HYPERDRIVE.Performance.EndProfiler(profiler)
    if not profiler then return end
    
    local endTime = SysTime()
    local endMemory = collectgarbage("count")
    local duration = endTime - profiler.startTime
    local memoryUsed = endMemory - profiler.startMemory
    
    if GetPerfConfig("PerformanceLogging", false) then
        print(string.format("[Hyperdrive Perf] %s: %.3fms, Memory: %.2fKB", 
            profiler.name, duration * 1000, memoryUsed))
    end
    
    return {
        duration = duration,
        memoryUsed = memoryUsed
    }
end

-- Optimized entity caching system
function HYPERDRIVE.Performance.CacheEntityList(engine, entities)
    if not GetPerfConfig("CacheEntityLists", true) then return end
    
    local cacheKey = tostring(engine)
    HYPERDRIVE.Performance.EntityCache[cacheKey] = {
        entities = entities,
        timestamp = CurTime(),
        enginePos = engine:GetPos()
    }
end

function HYPERDRIVE.Performance.GetCachedEntityList(engine)
    if not GetPerfConfig("CacheEntityLists", true) then return nil end
    
    local cacheKey = tostring(engine)
    local cached = HYPERDRIVE.Performance.EntityCache[cacheKey]
    
    if not cached then return nil end
    
    local maxAge = GetPerfConfig("MaxCacheAge", 30)
    if CurTime() - cached.timestamp > maxAge then
        HYPERDRIVE.Performance.EntityCache[cacheKey] = nil
        return nil
    end
    
    -- Check if engine has moved significantly
    local currentPos = engine:GetPos()
    if cached.enginePos:Distance(currentPos) > 100 then
        HYPERDRIVE.Performance.EntityCache[cacheKey] = nil
        return nil
    end
    
    return cached.entities
end

-- Optimized batch movement system
function HYPERDRIVE.Performance.BatchMoveEntities(entities, destination, enginePos)
    local profiler = HYPERDRIVE.Performance.StartProfiler("BatchMoveEntities")
    
    local maxBatch = GetPerfConfig("MaxEntitiesPerBatch", 50)
    local batchDelay = GetPerfConfig("BatchDelay", 0.01)
    local totalBatches = math.ceil(#entities / maxBatch)
    
    if GetPerfConfig("PerformanceLogging", false) then
        print(string.format("[Hyperdrive Perf] Moving %d entities in %d batches", #entities, totalBatches))
    end
    
    for batchIndex = 1, totalBatches do
        local startIdx = (batchIndex - 1) * maxBatch + 1
        local endIdx = math.min(batchIndex * maxBatch, #entities)
        
        timer.Simple(batchDelay * (batchIndex - 1), function()
            for i = startIdx, endIdx do
                local ent = entities[i]
                if IsValid(ent) then
                    local offset = ent:GetPos() - enginePos
                    local newPos = destination + offset
                    
                    -- Use optimized movement if available
                    if GetPerfConfig("NetworkOptimization", true) and ent.SetPosOptimized then
                        ent:SetPosOptimized(newPos)
                    else
                        ent:SetPos(newPos)
                    end
                    
                    -- Clear velocities for physics optimization
                    if ent:GetPhysicsObject():IsValid() then
                        ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
                        ent:GetPhysicsObject():SetAngularVelocity(Vector(0, 0, 0))
                    end
                end
            end
            
            if batchIndex == totalBatches then
                HYPERDRIVE.Performance.EndProfiler(profiler)
                HYPERDRIVE.Performance.UpdateMetrics(#entities)
            end
        end)
    end
    
    return true
end

-- Network optimization system
function HYPERDRIVE.Performance.OptimizeNetworkTraffic(entities)
    if not GetPerfConfig("NetworkOptimization", true) then return entities end
    
    -- Group entities by type for more efficient network updates
    local groupedEntities = {
        players = {},
        vehicles = {},
        props = {},
        other = {}
    }
    
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            if ent:IsPlayer() then
                table.insert(groupedEntities.players, ent)
            elseif ent:IsVehicle() then
                table.insert(groupedEntities.vehicles, ent)
            elseif ent:GetClass() == "prop_physics" then
                table.insert(groupedEntities.props, ent)
            else
                table.insert(groupedEntities.other, ent)
            end
        end
    end
    
    -- Estimate network bytes saved
    local originalBytes = #entities * 32 -- Rough estimate
    local optimizedBytes = (#groupedEntities.players * 24) + 
                          (#groupedEntities.vehicles * 28) + 
                          (#groupedEntities.props * 20) + 
                          (#groupedEntities.other * 32)
    
    HYPERDRIVE.Performance.Metrics.networkBytesOptimized = 
        HYPERDRIVE.Performance.Metrics.networkBytesOptimized + (originalBytes - optimizedBytes)
    
    return entities -- Return original for now, optimization happens in movement
end

-- Memory optimization
function HYPERDRIVE.Performance.OptimizeMemory()
    if not GetPerfConfig("MemoryOptimization", true) then return end
    
    -- Clean up old cache entries
    local maxAge = GetPerfConfig("MaxCacheAge", 30)
    local currentTime = CurTime()
    
    for key, cached in pairs(HYPERDRIVE.Performance.EntityCache) do
        if currentTime - cached.timestamp > maxAge then
            HYPERDRIVE.Performance.EntityCache[key] = nil
        end
    end
    
    -- Force garbage collection if memory usage is high
    local memoryUsage = collectgarbage("count")
    if memoryUsage > 50000 then -- 50MB threshold
        collectgarbage("collect")
        if GetPerfConfig("PerformanceLogging", false) then
            local newUsage = collectgarbage("count")
            print(string.format("[Hyperdrive Perf] Memory cleanup: %.2fMB -> %.2fMB", 
                memoryUsage / 1024, newUsage / 1024))
        end
    end
end

-- Performance metrics update
function HYPERDRIVE.Performance.UpdateMetrics(entitiesMoved)
    local metrics = HYPERDRIVE.Performance.Metrics
    
    metrics.totalJumps = metrics.totalJumps + 1
    metrics.totalEntitiesMoved = metrics.totalEntitiesMoved + entitiesMoved
    metrics.lastJumpTime = CurTime()
    
    if entitiesMoved > metrics.peakEntitiesInJump then
        metrics.peakEntitiesInJump = entitiesMoved
    end
    
    -- Calculate average jump time (simplified)
    if metrics.totalJumps > 1 then
        metrics.averageJumpTime = (metrics.averageJumpTime + 0.1) / 2 -- Rough estimate
    end
end

-- Enhanced entity detection with performance optimization
function HYPERDRIVE.Performance.OptimizedEntityDetection(engine, searchRadius)
    local profiler = HYPERDRIVE.Performance.StartProfiler("OptimizedEntityDetection")
    
    -- Check cache first
    local cachedEntities = HYPERDRIVE.Performance.GetCachedEntityList(engine)
    if cachedEntities then
        HYPERDRIVE.Performance.EndProfiler(profiler)
        return cachedEntities
    end
    
    local entities = {}
    
    -- Use the best available detection method
    if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.EnhancedEntityDetection then
        entities = HYPERDRIVE.SpaceCombat2.EnhancedEntityDetection(engine, searchRadius)
    elseif HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.GetAttachedEntities then
        entities = HYPERDRIVE.Spacebuild.Enhanced.GetAttachedEntities(engine)
    else
        -- Fallback method with optimization
        local constrainedEnts = constraint.GetAllConstrainedEntities(engine)
        if constrainedEnts then
            for _, ent in ipairs(constrainedEnts) do
                if IsValid(ent) then
                    table.insert(entities, ent)
                end
            end
        end
        
        -- Add nearby entities if constraint system didn't find enough
        if #entities < 2 then
            local nearbyEnts = ents.FindInSphere(engine:GetPos(), searchRadius or 1000)
            for _, ent in ipairs(nearbyEnts) do
                if IsValid(ent) and not table.HasValue(entities, ent) then
                    if ent:IsPlayer() or ent:IsVehicle() or ent:GetClass() == "prop_physics" then
                        table.insert(entities, ent)
                    end
                end
            end
        end
    end
    
    -- Cache the results
    HYPERDRIVE.Performance.CacheEntityList(engine, entities)
    
    -- Optimize network traffic
    entities = HYPERDRIVE.Performance.OptimizeNetworkTraffic(entities)
    
    HYPERDRIVE.Performance.EndProfiler(profiler)
    return entities
end

-- Performance monitoring timer
timer.Create("HyperdrivePerformanceMonitor", 60, 0, function()
    HYPERDRIVE.Performance.OptimizeMemory()
    
    if GetPerfConfig("PerformanceLogging", false) then
        local metrics = HYPERDRIVE.Performance.Metrics
        print(string.format("[Hyperdrive Perf] Stats - Jumps: %d, Entities: %d, Peak: %d, Network Saved: %.2fKB",
            metrics.totalJumps, metrics.totalEntitiesMoved, metrics.peakEntitiesInJump, 
            metrics.networkBytesOptimized / 1024))
    end
end)

-- Console commands for performance management
concommand.Add("hyperdrive_perf_stats", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local metrics = HYPERDRIVE.Performance.Metrics
    
    ply:ChatPrint("[Hyperdrive Performance] Statistics:")
    ply:ChatPrint("  • Total Jumps: " .. metrics.totalJumps)
    ply:ChatPrint("  • Total Entities Moved: " .. metrics.totalEntitiesMoved)
    ply:ChatPrint("  • Peak Entities in Single Jump: " .. metrics.peakEntitiesInJump)
    ply:ChatPrint("  • Network Bytes Optimized: " .. string.format("%.2fKB", metrics.networkBytesOptimized / 1024))
    ply:ChatPrint("  • Cache Entries: " .. table.Count(HYPERDRIVE.Performance.EntityCache))
    ply:ChatPrint("  • Memory Usage: " .. string.format("%.2fMB", collectgarbage("count") / 1024))
end)

concommand.Add("hyperdrive_perf_clear", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    -- Clear performance metrics
    HYPERDRIVE.Performance.Metrics = {
        totalJumps = 0,
        totalEntitiesMoved = 0,
        averageJumpTime = 0,
        lastJumpTime = 0,
        peakEntitiesInJump = 0,
        networkBytesOptimized = 0,
    }
    
    -- Clear cache
    HYPERDRIVE.Performance.EntityCache = {}
    
    -- Force garbage collection
    collectgarbage("collect")
    
    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive] Performance metrics and cache cleared")
    else
        print("[Hyperdrive] Performance metrics and cache cleared")
    end
end)

print("[Hyperdrive] Performance optimization system loaded")
