-- Advanced Space Combat - Ship Core Optimization System v1.0
-- High-performance ship detection and entity management inspired by SpaceCombat2
-- Implements spatial partitioning, constraint caching, and adaptive algorithms

print("[ASC Ship Core] Advanced Optimization System v1.0 Loading...")

-- Initialize optimization namespace
ASC = ASC or {}
ASC.ShipCore = ASC.ShipCore or {}
ASC.ShipCore.Optimization = {}

-- Get optimization configuration from ConVars
function ASC.ShipCore.Optimization.GetConfig()
    return {
        -- Spatial partitioning
        EnableSpatialPartitioning = GetConVar("asc_enable_spatial_partitioning"):GetBool(),
        SpatialGridSize = 1000,
        MaxEntitiesPerCell = 100,

        -- Constraint caching
        EnableConstraintCaching = GetConVar("asc_enable_constraint_caching"):GetBool(),
        ConstraintCacheLifetime = 30, -- seconds
        MaxConstraintCacheSize = 1000,

        -- Incremental detection
        EnableIncrementalDetection = GetConVar("asc_enable_incremental_detection"):GetBool(),
        IncrementalBatchSize = 10, -- entities per frame
        IncrementalUpdateRate = 0.1, -- 10 FPS

        -- Adaptive scheduling
        EnableAdaptiveScheduling = GetConVar("asc_enable_adaptive_scheduling"):GetBool(),
        PerformanceThreshold = GetConVar("asc_performance_threshold"):GetFloat(),
        AdaptiveScaling = 0.5, -- Scale factor when performance is low

        -- Entity relationship mapping
        EnableRelationshipMapping = true,
        RelationshipCacheSize = 500,
        RelationshipUpdateRate = 1.0, -- 1 FPS

        -- Debug and monitoring
        EnableDebugMode = GetConVar("asc_optimization_debug"):GetBool(),
        EnablePerformanceMonitoring = true,
        LogPerformanceData = GetConVar("asc_optimization_debug"):GetBool()
    }
end

-- Optimization configuration (updated dynamically)
ASC.ShipCore.Optimization.Config = ASC.ShipCore.Optimization.GetConfig()

-- Spatial partitioning system
ASC.ShipCore.Optimization.SpatialGrid = {
    cells = {},
    entityToCell = {},
    lastUpdate = 0,
    updateRate = 2.0 -- Update grid every 2 seconds
}

-- Constraint cache system
ASC.ShipCore.Optimization.ConstraintCache = {
    cache = {},
    timestamps = {},
    accessCount = {},
    lastCleanup = 0,
    cleanupInterval = 60 -- Clean cache every minute
}

-- Incremental detection system
ASC.ShipCore.Optimization.IncrementalDetection = {
    queues = {}, -- Per ship core detection queues
    currentBatch = {},
    lastUpdate = 0,
    processingIndex = 1
}

-- Entity relationship mapping
ASC.ShipCore.Optimization.RelationshipMap = {
    constraints = {}, -- entity -> {connected entities}
    parents = {},     -- entity -> parent
    children = {},    -- entity -> {children}
    lastUpdate = 0,
    dirtyEntities = {} -- Entities that need relationship updates
}

-- Performance monitoring
ASC.ShipCore.Optimization.Performance = {
    metrics = {
        spatialQueries = 0,
        constraintLookups = 0,
        cacheHits = 0,
        cacheMisses = 0,
        incrementalUpdates = 0,
        totalDetectionTime = 0,
        averageDetectionTime = 0
    },
    lastReset = 0,
    resetInterval = 300 -- Reset metrics every 5 minutes
}

-- Initialize spatial partitioning grid
function ASC.ShipCore.Optimization.InitializeSpatialGrid()
    local config = ASC.ShipCore.Optimization.GetConfig()
    if not config.EnableSpatialPartitioning then return end
    
    ASC.ShipCore.Optimization.SpatialGrid.cells = {}
    ASC.ShipCore.Optimization.SpatialGrid.entityToCell = {}
    
    print("[ASC Ship Core] Spatial partitioning grid initialized (Grid Size: " .. config.SpatialGridSize .. ")")
end

-- Get spatial grid cell for position
function ASC.ShipCore.Optimization.GetGridCell(pos)
    local gridSize = ASC.ShipCore.Optimization.Config.SpatialGridSize
    local x = math.floor(pos.x / gridSize)
    local y = math.floor(pos.y / gridSize)
    local z = math.floor(pos.z / gridSize)
    return x .. "," .. y .. "," .. z
end

-- Add entity to spatial grid
function ASC.ShipCore.Optimization.AddEntityToGrid(entity)
    if not IsValid(entity) then return end
    
    local cellKey = ASC.ShipCore.Optimization.GetGridCell(entity:GetPos())
    local grid = ASC.ShipCore.Optimization.SpatialGrid
    
    -- Remove from old cell if exists
    local oldCell = grid.entityToCell[entity:EntIndex()]
    if oldCell and grid.cells[oldCell] then
        for i, ent in ipairs(grid.cells[oldCell]) do
            if ent == entity then
                table.remove(grid.cells[oldCell], i)
                break
            end
        end
    end
    
    -- Add to new cell
    if not grid.cells[cellKey] then
        grid.cells[cellKey] = {}
    end
    
    table.insert(grid.cells[cellKey], entity)
    grid.entityToCell[entity:EntIndex()] = cellKey
end

-- Optimized entity detection using spatial partitioning
function ASC.ShipCore.Optimization.FindEntitiesInRadius(center, radius)
    local config = ASC.ShipCore.Optimization.GetConfig()
    
    if not config.EnableSpatialPartitioning then
        -- Fallback to standard detection
        ASC.ShipCore.Optimization.Performance.metrics.spatialQueries = 
            ASC.ShipCore.Optimization.Performance.metrics.spatialQueries + 1
        return ents.FindInSphere(center, radius)
    end
    
    local startTime = SysTime()
    local results = {}
    local grid = ASC.ShipCore.Optimization.SpatialGrid
    local gridSize = config.SpatialGridSize
    
    -- Calculate grid cells to check
    local cellsToCheck = {}
    local cellRadius = math.ceil(radius / gridSize)
    local centerCell = ASC.ShipCore.Optimization.GetGridCell(center)
    local centerX, centerY, centerZ = centerCell:match("([^,]+),([^,]+),([^,]+)")
    centerX, centerY, centerZ = tonumber(centerX), tonumber(centerY), tonumber(centerZ)
    
    for x = centerX - cellRadius, centerX + cellRadius do
        for y = centerY - cellRadius, centerY + cellRadius do
            for z = centerZ - cellRadius, centerZ + cellRadius do
                local cellKey = x .. "," .. y .. "," .. z
                if grid.cells[cellKey] then
                    table.insert(cellsToCheck, cellKey)
                end
            end
        end
    end
    
    -- Check entities in relevant cells
    for _, cellKey in ipairs(cellsToCheck) do
        for _, entity in ipairs(grid.cells[cellKey]) do
            if IsValid(entity) and center:Distance(entity:GetPos()) <= radius then
                table.insert(results, entity)
            end
        end
    end
    
    -- Update performance metrics
    local detectionTime = SysTime() - startTime
    local metrics = ASC.ShipCore.Optimization.Performance.metrics
    metrics.spatialQueries = metrics.spatialQueries + 1
    metrics.totalDetectionTime = metrics.totalDetectionTime + detectionTime
    metrics.averageDetectionTime = metrics.totalDetectionTime / metrics.spatialQueries
    
    if config.EnableDebugMode then
        print("[ASC Ship Core] Spatial query: " .. #results .. " entities found in " .. 
              string.format("%.3f", detectionTime * 1000) .. "ms")
    end
    
    return results
end

-- Constraint caching system
function ASC.ShipCore.Optimization.GetConstrainedEntities(entity)
    if not IsValid(entity) then return {} end
    
    local config = ASC.ShipCore.Optimization.Config
    local cache = ASC.ShipCore.Optimization.ConstraintCache
    local entIndex = entity:EntIndex()
    
    if not config.EnableConstraintCaching then
        -- Direct lookup without caching
        ASC.ShipCore.Optimization.Performance.metrics.constraintLookups = 
            ASC.ShipCore.Optimization.Performance.metrics.constraintLookups + 1
        return constraint.GetAllConstrainedEntities(entity) or {}
    end
    
    -- Check cache first
    local currentTime = CurTime()
    if cache.cache[entIndex] and 
       currentTime - cache.timestamps[entIndex] < config.ConstraintCacheLifetime then
        cache.accessCount[entIndex] = (cache.accessCount[entIndex] or 0) + 1
        ASC.ShipCore.Optimization.Performance.metrics.cacheHits = 
            ASC.ShipCore.Optimization.Performance.metrics.cacheHits + 1
        return cache.cache[entIndex]
    end
    
    -- Cache miss - perform lookup
    local constraints = constraint.GetAllConstrainedEntities(entity) or {}
    
    -- Store in cache
    cache.cache[entIndex] = constraints
    cache.timestamps[entIndex] = currentTime
    cache.accessCount[entIndex] = 1
    
    -- Update performance metrics
    ASC.ShipCore.Optimization.Performance.metrics.cacheMisses = 
        ASC.ShipCore.Optimization.Performance.metrics.cacheMisses + 1
    ASC.ShipCore.Optimization.Performance.metrics.constraintLookups = 
        ASC.ShipCore.Optimization.Performance.metrics.constraintLookups + 1
    
    return constraints
end

-- Clean constraint cache
function ASC.ShipCore.Optimization.CleanConstraintCache()
    local cache = ASC.ShipCore.Optimization.ConstraintCache
    local config = ASC.ShipCore.Optimization.Config
    local currentTime = CurTime()
    
    local cleaned = 0
    for entIndex, timestamp in pairs(cache.timestamps) do
        if currentTime - timestamp > config.ConstraintCacheLifetime then
            cache.cache[entIndex] = nil
            cache.timestamps[entIndex] = nil
            cache.accessCount[entIndex] = nil
            cleaned = cleaned + 1
        end
    end
    
    -- If cache is still too large, remove least accessed entries
    local cacheSize = table.Count(cache.cache)
    if cacheSize > config.MaxConstraintCacheSize then
        local sortedEntries = {}
        for entIndex, accessCount in pairs(cache.accessCount) do
            table.insert(sortedEntries, {entIndex = entIndex, accessCount = accessCount})
        end
        
        table.sort(sortedEntries, function(a, b) return a.accessCount < b.accessCount end)
        
        local toRemove = cacheSize - config.MaxConstraintCacheSize
        for i = 1, toRemove do
            local entIndex = sortedEntries[i].entIndex
            cache.cache[entIndex] = nil
            cache.timestamps[entIndex] = nil
            cache.accessCount[entIndex] = nil
            cleaned = cleaned + 1
        end
    end
    
    cache.lastCleanup = currentTime
    
    if config.EnableDebugMode and cleaned > 0 then
        print("[ASC Ship Core] Constraint cache cleaned: " .. cleaned .. " entries removed")
    end
end

-- Update spatial grid
function ASC.ShipCore.Optimization.UpdateSpatialGrid()
    local config = ASC.ShipCore.Optimization.Config
    if not config.EnableSpatialPartitioning then return end
    
    local currentTime = CurTime()
    local grid = ASC.ShipCore.Optimization.SpatialGrid
    
    if currentTime - grid.lastUpdate < grid.updateRate then return end
    
    -- Clear and rebuild grid
    grid.cells = {}
    grid.entityToCell = {}
    
    -- Add all valid entities to grid
    for _, entity in ipairs(ents.GetAll()) do
        if IsValid(entity) and not entity:IsPlayer() and not entity:IsWorld() then
            ASC.ShipCore.Optimization.AddEntityToGrid(entity)
        end
    end
    
    grid.lastUpdate = currentTime
    
    if config.EnableDebugMode then
        local cellCount = table.Count(grid.cells)
        local entityCount = table.Count(grid.entityToCell)
        print("[ASC Ship Core] Spatial grid updated: " .. cellCount .. " cells, " .. entityCount .. " entities")
    end
end

-- Initialize optimization system
function ASC.ShipCore.Optimization.Initialize()
    print("[ASC Ship Core] Initializing advanced optimization system...")
    
    ASC.ShipCore.Optimization.InitializeSpatialGrid()
    
    -- Set up update hooks
    hook.Add("Think", "ASC_ShipCore_Optimization", function()
        ASC.ShipCore.Optimization.UpdateSpatialGrid()
        ASC.ShipCore.Optimization.ProcessIncrementalDetection()
        ASC.ShipCore.Optimization.UpdateRelationshipMap()
        ASC.ShipCore.Optimization.MonitorPerformance()
    end)
    
    -- Set up cleanup timer
    timer.Create("ASC_ShipCore_ConstraintCacheCleanup", 60, 0, function()
        ASC.ShipCore.Optimization.CleanConstraintCache()
    end)
    
    print("[ASC Ship Core] Advanced optimization system initialized successfully!")
end

-- Initialize on server
if SERVER then
    hook.Add("Initialize", "ASC_ShipCore_Optimization_Init", function()
        timer.Simple(2, ASC.ShipCore.Optimization.Initialize)
    end)
end

-- Incremental detection system
function ASC.ShipCore.Optimization.ProcessIncrementalDetection()
    local config = ASC.ShipCore.Optimization.Config
    if not config.EnableIncrementalDetection then return end

    local currentTime = CurTime()
    local detection = ASC.ShipCore.Optimization.IncrementalDetection

    if currentTime - detection.lastUpdate < config.IncrementalUpdateRate then return end

    -- Process batches for each ship core
    for coreId, queue in pairs(detection.queues) do
        if #queue > 0 then
            local batchSize = math.min(config.IncrementalBatchSize, #queue)
            local batch = {}

            for i = 1, batchSize do
                table.insert(batch, table.remove(queue, 1))
            end

            -- Process batch
            ASC.ShipCore.Optimization.ProcessDetectionBatch(coreId, batch)
            ASC.ShipCore.Optimization.Performance.metrics.incrementalUpdates =
                ASC.ShipCore.Optimization.Performance.metrics.incrementalUpdates + 1
        end
    end

    detection.lastUpdate = currentTime
end

-- Process detection batch for a ship core
function ASC.ShipCore.Optimization.ProcessDetectionBatch(coreId, batch)
    local core = Entity(coreId)
    if not IsValid(core) or not core.ship then return end

    for _, entity in ipairs(batch) do
        if IsValid(entity) then
            -- Check if entity should be part of ship
            if ASC.ShipCore.Optimization.IsEntityPartOfShip(core, entity) then
                -- Add to ship if not already present
                local found = false
                for _, shipEnt in ipairs(core.ship.entities) do
                    if shipEnt == entity then
                        found = true
                        break
                    end
                end

                if not found then
                    table.insert(core.ship.entities, entity)
                    if HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.EntityToShip then
                        HYPERDRIVE.ShipCore.EntityToShip[entity:EntIndex()] = core.ship
                    end
                end
            end
        end
    end
end

-- Optimized entity relationship checking
function ASC.ShipCore.Optimization.IsEntityPartOfShip(core, entity)
    if not IsValid(core) or not IsValid(entity) then return false end
    if entity == core then return true end

    -- Use cached constraint data
    local constraints = ASC.ShipCore.Optimization.GetConstrainedEntities(entity)

    -- Check if constrained to core or any ship entity
    for constrainedEnt, _ in pairs(constraints) do
        if IsValid(constrainedEnt) then
            if constrainedEnt == core then return true end

            -- Check if constrained to existing ship entity
            if core.ship and core.ship.entities then
                for _, shipEnt in ipairs(core.ship.entities) do
                    if constrainedEnt == shipEnt then return true end
                end
            end
        end
    end

    -- Check parent relationships
    local parent = entity:GetParent()
    if IsValid(parent) then
        if parent == core then return true end
        if core.ship and core.ship.entities then
            for _, shipEnt in ipairs(core.ship.entities) do
                if parent == shipEnt then return true end
            end
        end
    end

    return false
end

-- Update entity relationship map
function ASC.ShipCore.Optimization.UpdateRelationshipMap()
    local config = ASC.ShipCore.Optimization.Config
    if not config.EnableRelationshipMapping then return end

    local currentTime = CurTime()
    local relationMap = ASC.ShipCore.Optimization.RelationshipMap

    if currentTime - relationMap.lastUpdate < config.RelationshipUpdateRate then return end

    -- Process dirty entities
    local processed = 0
    for entIndex, _ in pairs(relationMap.dirtyEntities) do
        local entity = Entity(entIndex)
        if IsValid(entity) then
            ASC.ShipCore.Optimization.UpdateEntityRelationships(entity)
            processed = processed + 1
        end
        relationMap.dirtyEntities[entIndex] = nil

        -- Limit processing per frame
        if processed >= 5 then break end
    end

    relationMap.lastUpdate = currentTime
end

-- Update relationships for a specific entity
function ASC.ShipCore.Optimization.UpdateEntityRelationships(entity)
    if not IsValid(entity) then return end

    local entIndex = entity:EntIndex()
    local relationMap = ASC.ShipCore.Optimization.RelationshipMap

    -- Update constraint relationships
    local constraints = ASC.ShipCore.Optimization.GetConstrainedEntities(entity)
    relationMap.constraints[entIndex] = {}
    for constrainedEnt, _ in pairs(constraints) do
        if IsValid(constrainedEnt) then
            table.insert(relationMap.constraints[entIndex], constrainedEnt:EntIndex())
        end
    end

    -- Update parent relationships
    local parent = entity:GetParent()
    if IsValid(parent) then
        relationMap.parents[entIndex] = parent:EntIndex()
    else
        relationMap.parents[entIndex] = nil
    end

    -- Update child relationships
    local children = entity:GetChildren()
    relationMap.children[entIndex] = {}
    if children then
        for _, child in ipairs(children) do
            if IsValid(child) then
                table.insert(relationMap.children[entIndex], child:EntIndex())
            end
        end
    end
end

-- Performance monitoring
function ASC.ShipCore.Optimization.MonitorPerformance()
    local config = ASC.ShipCore.Optimization.Config
    if not config.EnablePerformanceMonitoring then return end

    local currentTime = CurTime()
    local performance = ASC.ShipCore.Optimization.Performance

    if currentTime - performance.lastReset > performance.resetInterval then
        if config.LogPerformanceData then
            ASC.ShipCore.Optimization.LogPerformanceMetrics()
        end

        -- Reset metrics
        performance.metrics = {
            spatialQueries = 0,
            constraintLookups = 0,
            cacheHits = 0,
            cacheMisses = 0,
            incrementalUpdates = 0,
            totalDetectionTime = 0,
            averageDetectionTime = 0
        }
        performance.lastReset = currentTime
    end

    -- Adaptive performance scaling
    if config.EnableAdaptiveScheduling then
        local fps = 1 / FrameTime()
        if fps < config.PerformanceThreshold then
            ASC.ShipCore.Optimization.EnableAdaptiveMode()
        else
            ASC.ShipCore.Optimization.DisableAdaptiveMode()
        end
    end
end

-- Log performance metrics
function ASC.ShipCore.Optimization.LogPerformanceMetrics()
    local metrics = ASC.ShipCore.Optimization.Performance.metrics
    local cacheHitRate = metrics.cacheHits / math.max(1, metrics.cacheHits + metrics.cacheMisses) * 100

    print("[ASC Ship Core] Performance Metrics:")
    print("  Spatial Queries: " .. metrics.spatialQueries)
    print("  Constraint Lookups: " .. metrics.constraintLookups)
    print("  Cache Hit Rate: " .. string.format("%.1f", cacheHitRate) .. "%")
    print("  Incremental Updates: " .. metrics.incrementalUpdates)
    print("  Avg Detection Time: " .. string.format("%.3f", metrics.averageDetectionTime * 1000) .. "ms")
end

-- Adaptive performance mode
ASC.ShipCore.Optimization.AdaptiveMode = false

function ASC.ShipCore.Optimization.EnableAdaptiveMode()
    if ASC.ShipCore.Optimization.AdaptiveMode then return end

    ASC.ShipCore.Optimization.AdaptiveMode = true
    local config = ASC.ShipCore.Optimization.Config

    -- Scale down update rates
    config.IncrementalUpdateRate = config.IncrementalUpdateRate / config.AdaptiveScaling
    config.RelationshipUpdateRate = config.RelationshipUpdateRate / config.AdaptiveScaling

    print("[ASC Ship Core] Adaptive performance mode enabled - reduced update rates")
end

function ASC.ShipCore.Optimization.DisableAdaptiveMode()
    if not ASC.ShipCore.Optimization.AdaptiveMode then return end

    ASC.ShipCore.Optimization.AdaptiveMode = false
    local config = ASC.ShipCore.Optimization.Config

    -- Restore normal update rates
    config.IncrementalUpdateRate = config.IncrementalUpdateRate * config.AdaptiveScaling
    config.RelationshipUpdateRate = config.RelationshipUpdateRate * config.AdaptiveScaling

    print("[ASC Ship Core] Adaptive performance mode disabled - restored normal rates")
end

-- Hook into entity creation for relationship tracking
hook.Add("OnEntityCreated", "ASC_ShipCore_OptimizationTracking", function(entity)
    if not IsValid(entity) then return end

    timer.Simple(0.1, function()
        if IsValid(entity) then
            local relationMap = ASC.ShipCore.Optimization.RelationshipMap
            relationMap.dirtyEntities[entity:EntIndex()] = true
        end
    end)
end)

print("[ASC Ship Core] Advanced Optimization System v1.0 Loaded!")
