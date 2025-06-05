-- Advanced Space Combat - Memory Optimizer
-- Optimizes memory usage and prevents memory leaks

if not ASC then ASC = {} end

ASC.MemoryOptimizer = {
    Version = "1.0.0",
    Initialized = false,
    
    -- Configuration
    Config = {
        Enabled = true,
        GCInterval = 30, -- Garbage collection interval in seconds
        MemoryThreshold = 200, -- MB threshold for forced GC
        CleanupInterval = 60, -- General cleanup interval
        MaxCacheSize = 100, -- Maximum cache entries
        DebugMode = false
    },
    
    -- Memory tracking
    State = {
        LastGC = 0,
        LastCleanup = 0,
        MemoryUsage = 0,
        PeakMemoryUsage = 0,
        GCCount = 0,
        CleanupCount = 0
    },
    
    -- Cache management
    Caches = {
        EntityCache = {},
        MaterialCache = {},
        SoundCache = {},
        EffectCache = {},
        NetworkCache = {}
    },
    
    -- Memory pools for frequently created objects
    Pools = {
        Vectors = {},
        Angles = {},
        Tables = {}
    }
}

-- Get current memory usage in MB
function ASC.MemoryOptimizer.GetMemoryUsage()
    return collectgarbage("count") / 1024
end

-- Perform garbage collection
function ASC.MemoryOptimizer.PerformGC()
    local beforeMem = ASC.MemoryOptimizer.GetMemoryUsage()
    collectgarbage("collect")
    local afterMem = ASC.MemoryOptimizer.GetMemoryUsage()
    
    ASC.MemoryOptimizer.State.GCCount = ASC.MemoryOptimizer.State.GCCount + 1
    ASC.MemoryOptimizer.State.LastGC = CurTime()
    
    local freed = beforeMem - afterMem
    if ASC.MemoryOptimizer.Config.DebugMode then
        print("[ASC Memory] GC freed " .. string.format("%.2f", freed) .. "MB (Before: " .. 
              string.format("%.2f", beforeMem) .. "MB, After: " .. string.format("%.2f", afterMem) .. "MB)")
    end
    
    return freed
end

-- Clean up caches
function ASC.MemoryOptimizer.CleanupCaches()
    local cleaned = 0
    
    for cacheName, cache in pairs(ASC.MemoryOptimizer.Caches) do
        local count = 0
        for k, v in pairs(cache) do
            -- Remove invalid entities from cache
            if type(v) == "Entity" and not IsValid(v) then
                cache[k] = nil
                count = count + 1
            -- Remove old entries (simple LRU)
            elseif type(v) == "table" and v.lastAccess and 
                   (CurTime() - v.lastAccess) > 300 then -- 5 minutes
                cache[k] = nil
                count = count + 1
            end
        end
        
        -- Limit cache size
        local cacheSize = table.Count(cache)
        if cacheSize > ASC.MemoryOptimizer.Config.MaxCacheSize then
            local toRemove = cacheSize - ASC.MemoryOptimizer.Config.MaxCacheSize
            local removed = 0
            for k, v in pairs(cache) do
                if removed >= toRemove then break end
                cache[k] = nil
                removed = removed + 1
                count = count + 1
            end
        end
        
        cleaned = cleaned + count
    end
    
    ASC.MemoryOptimizer.State.CleanupCount = ASC.MemoryOptimizer.State.CleanupCount + 1
    ASC.MemoryOptimizer.State.LastCleanup = CurTime()
    
    if ASC.MemoryOptimizer.Config.DebugMode and cleaned > 0 then
        print("[ASC Memory] Cleaned " .. cleaned .. " cache entries")
    end
    
    return cleaned
end

-- Memory pool management
function ASC.MemoryOptimizer.GetPooledVector(x, y, z)
    local pool = ASC.MemoryOptimizer.Pools.Vectors
    if #pool > 0 then
        local vec = table.remove(pool)
        vec:Set(x or 0, y or 0, z or 0)
        return vec
    else
        return Vector(x or 0, y or 0, z or 0)
    end
end

function ASC.MemoryOptimizer.ReturnPooledVector(vec)
    if #ASC.MemoryOptimizer.Pools.Vectors < 50 then -- Limit pool size
        table.insert(ASC.MemoryOptimizer.Pools.Vectors, vec)
    end
end

function ASC.MemoryOptimizer.GetPooledAngle(p, y, r)
    local pool = ASC.MemoryOptimizer.Pools.Angles
    if #pool > 0 then
        local ang = table.remove(pool)
        ang:Set(p or 0, y or 0, r or 0)
        return ang
    else
        return Angle(p or 0, y or 0, r or 0)
    end
end

function ASC.MemoryOptimizer.ReturnPooledAngle(ang)
    if #ASC.MemoryOptimizer.Pools.Angles < 50 then -- Limit pool size
        table.insert(ASC.MemoryOptimizer.Pools.Angles, ang)
    end
end

function ASC.MemoryOptimizer.GetPooledTable()
    local pool = ASC.MemoryOptimizer.Pools.Tables
    if #pool > 0 then
        local tbl = table.remove(pool)
        table.Empty(tbl)
        return tbl
    else
        return {}
    end
end

function ASC.MemoryOptimizer.ReturnPooledTable(tbl)
    if #ASC.MemoryOptimizer.Pools.Tables < 20 then -- Limit pool size
        table.insert(ASC.MemoryOptimizer.Pools.Tables, tbl)
    end
end

-- Main memory optimization update
function ASC.MemoryOptimizer.Update()
    if not ASC.MemoryOptimizer.Config.Enabled then return end
    
    local currentTime = CurTime()
    local memUsage = ASC.MemoryOptimizer.GetMemoryUsage()
    
    ASC.MemoryOptimizer.State.MemoryUsage = memUsage
    if memUsage > ASC.MemoryOptimizer.State.PeakMemoryUsage then
        ASC.MemoryOptimizer.State.PeakMemoryUsage = memUsage
    end
    
    -- Forced GC if memory usage is too high
    if memUsage > ASC.MemoryOptimizer.Config.MemoryThreshold then
        ASC.MemoryOptimizer.PerformGC()
        if ASC.MemoryOptimizer.Config.DebugMode then
            print("[ASC Memory] Forced GC due to high memory usage: " .. string.format("%.2f", memUsage) .. "MB")
        end
    end
    
    -- Regular GC
    if currentTime - ASC.MemoryOptimizer.State.LastGC > ASC.MemoryOptimizer.Config.GCInterval then
        ASC.MemoryOptimizer.PerformGC()
    end
    
    -- Regular cleanup
    if currentTime - ASC.MemoryOptimizer.State.LastCleanup > ASC.MemoryOptimizer.Config.CleanupInterval then
        ASC.MemoryOptimizer.CleanupCaches()
    end
end

-- Get memory statistics
function ASC.MemoryOptimizer.GetStats()
    return {
        CurrentMemoryMB = ASC.MemoryOptimizer.State.MemoryUsage,
        PeakMemoryMB = ASC.MemoryOptimizer.State.PeakMemoryUsage,
        GCCount = ASC.MemoryOptimizer.State.GCCount,
        CleanupCount = ASC.MemoryOptimizer.State.CleanupCount,
        CacheSizes = {
            Entity = table.Count(ASC.MemoryOptimizer.Caches.EntityCache),
            Material = table.Count(ASC.MemoryOptimizer.Caches.MaterialCache),
            Sound = table.Count(ASC.MemoryOptimizer.Caches.SoundCache),
            Effect = table.Count(ASC.MemoryOptimizer.Caches.EffectCache),
            Network = table.Count(ASC.MemoryOptimizer.Caches.NetworkCache)
        },
        PoolSizes = {
            Vectors = #ASC.MemoryOptimizer.Pools.Vectors,
            Angles = #ASC.MemoryOptimizer.Pools.Angles,
            Tables = #ASC.MemoryOptimizer.Pools.Tables
        }
    }
end

-- Initialize memory optimizer
function ASC.MemoryOptimizer.Initialize()
    if ASC.MemoryOptimizer.Initialized then return end
    
    print("[ASC Memory] Initializing Memory Optimizer...")
    
    -- Register with master scheduler
    timer.Simple(10, function()
        if ASC and ASC.MasterScheduler then
            ASC.MasterScheduler.RegisterTask("ASC_MemoryOptimizer", "Low", function()
                ASC.MemoryOptimizer.Update()
            end, 5.0) -- 0.2 FPS for memory management
        else
            -- Fallback timer if master scheduler not available
            timer.Create("ASC_MemoryOptimizer", 5, 0, function()
                ASC.MemoryOptimizer.Update()
            end)
        end
    end)
    
    ASC.MemoryOptimizer.Initialized = true
    print("[ASC Memory] Memory Optimizer initialized successfully!")
end

-- Console command for memory stats
concommand.Add("asc_memory_stats", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then return end
    
    local stats = ASC.MemoryOptimizer.GetStats()
    print("[ASC Memory] Memory Statistics:")
    print("  Current Memory: " .. string.format("%.2f", stats.CurrentMemoryMB) .. "MB")
    print("  Peak Memory: " .. string.format("%.2f", stats.PeakMemoryMB) .. "MB")
    print("  GC Count: " .. stats.GCCount)
    print("  Cleanup Count: " .. stats.CleanupCount)
    print("  Cache Sizes: Entity=" .. stats.CacheSizes.Entity .. 
          ", Material=" .. stats.CacheSizes.Material .. 
          ", Sound=" .. stats.CacheSizes.Sound .. 
          ", Effect=" .. stats.CacheSizes.Effect .. 
          ", Network=" .. stats.CacheSizes.Network)
    print("  Pool Sizes: Vectors=" .. stats.PoolSizes.Vectors .. 
          ", Angles=" .. stats.PoolSizes.Angles .. 
          ", Tables=" .. stats.PoolSizes.Tables)
end)

-- Initialize when ready
timer.Simple(2, function()
    ASC.MemoryOptimizer.Initialize()
end)

print("[Advanced Space Combat] Memory Optimizer loaded successfully!")
