-- Advanced Space Combat - Theme System Optimization v1.0.0
-- Optimizes theme system for better performance and memory usage

print("[Advanced Space Combat] Theme System Optimization v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.ThemeOptimization = ASC.ThemeOptimization or {}

-- Theme optimization configuration
ASC.ThemeOptimization.Config = {
    -- Material caching
    MaxCachedMaterials = 50,
    MaterialCacheTimeout = 300, -- 5 minutes
    EnableMaterialCompression = true,
    
    -- VGUI optimization
    MaxThemedPanels = 100,
    PanelUpdateInterval = 0.1,
    EnablePanelCulling = true,
    CullDistance = 2000,
    
    -- Effect optimization
    MaxParticleEffects = 25,
    EffectLODEnabled = true,
    EffectCullingEnabled = true,
    
    -- Performance thresholds
    FPSThresholds = {
        DisableEffects = 30,
        ReduceQuality = 45,
        FullQuality = 60
    },
    
    -- Memory management
    CleanupInterval = 60,
    MaxMemoryUsage = 100, -- MB for theme system
    ForceGCThreshold = 150 -- MB
}

-- Theme optimization state
ASC.ThemeOptimization.State = {
    CachedMaterials = {},
    ThemedPanels = {},
    ActiveEffects = {},
    LastCleanup = 0,
    CurrentQuality = "High",
    MemoryUsage = 0,
    
    -- Statistics
    MaterialsGenerated = 0,
    PanelsThemed = 0,
    EffectsCreated = 0,
    MemoryFreed = 0
}

-- Initialize theme optimization
function ASC.ThemeOptimization.Initialize()
    print("[Advanced Space Combat] Initializing theme optimization...")
    
    -- Set up optimization hooks
    ASC.ThemeOptimization.SetupOptimizationHooks()
    
    -- Set up cleanup timers
    ASC.ThemeOptimization.SetupCleanupTimers()
    
    -- Optimize existing theme functions
    ASC.ThemeOptimization.OptimizeThemeFunctions()
    
    print("[Advanced Space Combat] Theme optimization initialized")
end

-- Set up optimization hooks with master scheduler
function ASC.ThemeOptimization.SetupOptimizationHooks()
    timer.Simple(6, function()
        if ASC and ASC.MasterScheduler then
            -- Register with master scheduler
            ASC.MasterScheduler.RegisterTask("ASC_ThemeQualityMonitor", "Low", function()
                ASC.ThemeOptimization.MonitorPerformance()
            end, 1.0)

            ASC.MasterScheduler.RegisterTask("ASC_ThemeCleanup", "Low", function()
                ASC.ThemeOptimization.CleanupResources()
            end, ASC.ThemeOptimization.Config.CleanupInterval)
        else
            -- Fallback timers if master scheduler not available
            timer.Create("ASC_ThemeQualityMonitor", 1, 0, function()
                ASC.ThemeOptimization.MonitorPerformance()
            end)

            timer.Create("ASC_ThemeCleanup", ASC.ThemeOptimization.Config.CleanupInterval, 0, function()
                ASC.ThemeOptimization.CleanupResources()
            end)
        end
    end)
end

-- Set up cleanup timers with master scheduler
function ASC.ThemeOptimization.SetupCleanupTimers()
    timer.Simple(7, function()
        if ASC and ASC.MasterScheduler then
            -- Register with master scheduler
            ASC.MasterScheduler.RegisterTask("ASC_MaterialCleanup", "Low", function()
                ASC.ThemeOptimization.CleanupMaterials()
            end, 300)

            ASC.MasterScheduler.RegisterTask("ASC_PanelCleanup", "Low", function()
                ASC.ThemeOptimization.CleanupPanels()
            end, 120)
        else
            -- Fallback timers if master scheduler not available
            timer.Create("ASC_MaterialCleanup", 300, 0, function()
                ASC.ThemeOptimization.CleanupMaterials()
            end)

            timer.Create("ASC_PanelCleanup", 120, 0, function()
                ASC.ThemeOptimization.CleanupPanels()
            end)
        end
    end)
end

-- Monitor performance and adjust quality
function ASC.ThemeOptimization.MonitorPerformance()
    local fps = math.floor(1 / FrameTime())
    local config = ASC.ThemeOptimization.Config
    local state = ASC.ThemeOptimization.State
    
    -- Update memory usage
    state.MemoryUsage = math.floor(collectgarbage("count") / 1024)
    
    -- Adjust quality based on FPS
    if fps < config.FPSThresholds.DisableEffects and state.CurrentQuality ~= "Disabled" then
        ASC.ThemeOptimization.SetQuality("Disabled")
    elseif fps < config.FPSThresholds.ReduceQuality and state.CurrentQuality == "High" then
        ASC.ThemeOptimization.SetQuality("Low")
    elseif fps > config.FPSThresholds.FullQuality and state.CurrentQuality ~= "High" then
        ASC.ThemeOptimization.SetQuality("High")
    end
    
    -- Force garbage collection if memory usage is high
    if state.MemoryUsage > config.ForceGCThreshold then
        ASC.ThemeOptimization.ForceCleanup()
    end
end

-- Set theme quality level
function ASC.ThemeOptimization.SetQuality(quality)
    local state = ASC.ThemeOptimization.State
    
    if state.CurrentQuality == quality then return end
    
    state.CurrentQuality = quality
    
    -- Apply quality settings
    if ASC.ComprehensiveTheme then
        if quality == "Disabled" then
            ASC.ComprehensiveTheme.Config.EnableParticleEffects = false
            ASC.ComprehensiveTheme.Config.EnableAnimations = false
            ASC.ComprehensiveTheme.Config.EnableEnhancedEffects = false
        elseif quality == "Low" then
            ASC.ComprehensiveTheme.Config.EnableParticleEffects = false
            ASC.ComprehensiveTheme.Config.EnableAnimations = true
            ASC.ComprehensiveTheme.Config.EnableEnhancedEffects = false
        else -- High quality
            ASC.ComprehensiveTheme.Config.EnableParticleEffects = true
            ASC.ComprehensiveTheme.Config.EnableAnimations = true
            ASC.ComprehensiveTheme.Config.EnableEnhancedEffects = true
        end
    end
    
    print("[Advanced Space Combat] Theme quality set to: " .. quality)
end

-- Clean up resources
function ASC.ThemeOptimization.CleanupResources()
    local memoryBefore = collectgarbage("count")
    
    ASC.ThemeOptimization.CleanupMaterials()
    ASC.ThemeOptimization.CleanupPanels()
    ASC.ThemeOptimization.CleanupEffects()
    
    collectgarbage("collect")
    
    local memoryAfter = collectgarbage("count")
    local memoryFreed = memoryBefore - memoryAfter
    
    ASC.ThemeOptimization.State.MemoryFreed = ASC.ThemeOptimization.State.MemoryFreed + memoryFreed
    ASC.ThemeOptimization.State.LastCleanup = CurTime()
    
    if memoryFreed > 100 then -- Only log if significant memory was freed
        print("[Advanced Space Combat] Theme cleanup freed " .. string.format("%.2f", memoryFreed) .. " KB")
    end
end

-- Clean up cached materials
function ASC.ThemeOptimization.CleanupMaterials()
    local currentTime = CurTime()
    local config = ASC.ThemeOptimization.Config
    local state = ASC.ThemeOptimization.State
    local cleaned = 0
    
    -- Remove old cached materials
    for name, data in pairs(state.CachedMaterials) do
        if currentTime - data.timestamp > config.MaterialCacheTimeout then
            state.CachedMaterials[name] = nil
            cleaned = cleaned + 1
        end
    end
    
    -- Limit cache size
    local cacheSize = table.Count(state.CachedMaterials)
    if cacheSize > config.MaxCachedMaterials then
        -- Remove oldest materials
        local materials = {}
        for name, data in pairs(state.CachedMaterials) do
            table.insert(materials, {name = name, timestamp = data.timestamp})
        end
        
        table.sort(materials, function(a, b) return a.timestamp < b.timestamp end)
        
        local toRemove = cacheSize - config.MaxCachedMaterials
        for i = 1, toRemove do
            state.CachedMaterials[materials[i].name] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        print("[Advanced Space Combat] Material cleanup: " .. cleaned .. " materials removed")
    end
end

-- Clean up themed panels
function ASC.ThemeOptimization.CleanupPanels()
    local state = ASC.ThemeOptimization.State
    local cleaned = 0
    
    -- Remove invalid panels
    for i = #state.ThemedPanels, 1, -1 do
        local panel = state.ThemedPanels[i]
        if not IsValid(panel) then
            table.remove(state.ThemedPanels, i)
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        print("[Advanced Space Combat] Panel cleanup: " .. cleaned .. " invalid panels removed")
    end
end

-- Clean up effects
function ASC.ThemeOptimization.CleanupEffects()
    local state = ASC.ThemeOptimization.State
    local cleaned = 0
    
    -- Remove old effects
    for i = #state.ActiveEffects, 1, -1 do
        local effect = state.ActiveEffects[i]
        if not effect or not effect.IsValid or not effect:IsValid() then
            table.remove(state.ActiveEffects, i)
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        print("[Advanced Space Combat] Effect cleanup: " .. cleaned .. " effects removed")
    end
end

-- Force cleanup when memory is high
function ASC.ThemeOptimization.ForceCleanup()
    print("[Advanced Space Combat] Force cleanup triggered - high memory usage")
    
    -- Aggressive cleanup
    ASC.ThemeOptimization.State.CachedMaterials = {}
    ASC.ThemeOptimization.CleanupPanels()
    ASC.ThemeOptimization.CleanupEffects()
    
    -- Force garbage collection
    collectgarbage("collect")
    collectgarbage("collect") -- Run twice for better cleanup
    
    -- Temporarily reduce quality
    ASC.ThemeOptimization.SetQuality("Low")
    
    -- Restore quality after delay
    timer.Simple(10, function()
        if ASC.ThemeOptimization.State.MemoryUsage < ASC.ThemeOptimization.Config.MaxMemoryUsage then
            ASC.ThemeOptimization.SetQuality("High")
        end
    end)
end

-- Optimize theme functions
function ASC.ThemeOptimization.OptimizeThemeFunctions()
    if not ASC.ComprehensiveTheme then return end
    
    -- Optimize material generation
    if ASC.WebResources and ASC.WebResources.GenerateSpaceBackground then
        local originalGenerate = ASC.WebResources.GenerateSpaceBackground
        
        ASC.WebResources.GenerateSpaceBackground = function()
            -- Check if already cached
            local cached = ASC.ThemeOptimization.State.CachedMaterials["space_background"]
            if cached and CurTime() - cached.timestamp < ASC.ThemeOptimization.Config.MaterialCacheTimeout then
                return cached.material
            end
            
            -- Generate new material
            local material = originalGenerate()
            
            -- Cache it
            ASC.ThemeOptimization.State.CachedMaterials["space_background"] = {
                material = material,
                timestamp = CurTime()
            }
            
            ASC.ThemeOptimization.State.MaterialsGenerated = ASC.ThemeOptimization.State.MaterialsGenerated + 1
            
            return material
        end
    end
    
    print("[Advanced Space Combat] Theme functions optimized")
end

-- Get optimization statistics
function ASC.ThemeOptimization.GetStatistics()
    local state = ASC.ThemeOptimization.State
    
    local stats = {
        "=== Theme Optimization Statistics ===",
        "Current Quality: " .. state.CurrentQuality,
        "Memory Usage: " .. state.MemoryUsage .. " MB",
        "Cached Materials: " .. table.Count(state.CachedMaterials),
        "Themed Panels: " .. #state.ThemedPanels,
        "Active Effects: " .. #state.ActiveEffects,
        "Materials Generated: " .. state.MaterialsGenerated,
        "Panels Themed: " .. state.PanelsThemed,
        "Effects Created: " .. state.EffectsCreated,
        "Memory Freed: " .. string.format("%.2f", state.MemoryFreed) .. " KB"
    }
    
    return stats
end

-- Console commands
concommand.Add("asc_theme_optimization_stats", function()
    local stats = ASC.ThemeOptimization.GetStatistics()
    for _, line in ipairs(stats) do
        print(line)
    end
end, nil, "Show theme optimization statistics")

concommand.Add("asc_theme_force_cleanup", function()
    ASC.ThemeOptimization.ForceCleanup()
    print("[Advanced Space Combat] Theme force cleanup completed")
end, nil, "Force theme system cleanup")

concommand.Add("asc_theme_quality", function(ply, cmd, args)
    if #args < 1 then
        print("[Advanced Space Combat] Current quality: " .. ASC.ThemeOptimization.State.CurrentQuality)
        print("[Advanced Space Combat] Usage: asc_theme_quality <High|Low|Disabled>")
        return
    end
    
    local quality = args[1]
    if quality == "High" or quality == "Low" or quality == "Disabled" then
        ASC.ThemeOptimization.SetQuality(quality)
        print("[Advanced Space Combat] Theme quality set to: " .. quality)
    else
        print("[Advanced Space Combat] Invalid quality. Use: High, Low, or Disabled")
    end
end, nil, "Set theme quality level")

-- Initialize on load
timer.Simple(2, function()
    ASC.ThemeOptimization.Initialize()
end)

print("[Advanced Space Combat] Theme System Optimization loaded successfully!")
