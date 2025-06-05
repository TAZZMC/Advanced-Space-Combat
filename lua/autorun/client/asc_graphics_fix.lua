-- Advanced Space Combat - Graphics Problem Fix System
-- Comprehensive solution for graphical issues and rendering problems

if not CLIENT then return end

ASC = ASC or {}
ASC.GraphicsFix = ASC.GraphicsFix or {}

-- Configuration
ASC.GraphicsFix.Config = {
    -- Auto-fix settings
    EnableAutoFix = true,
    EnableSafeMode = true,
    EnableDiagnostics = true,
    
    -- Performance settings
    MaxEffectIntensity = 0.5,
    FPSThreshold = 30,
    MemoryThreshold = 512, -- MB
    
    -- Fix intervals
    CheckInterval = 2.0,
    CleanupInterval = 30.0,
    
    -- Debug settings
    EnableDebugOutput = false,
    LogGraphicsErrors = true
}

-- State tracking
ASC.GraphicsFix.State = {
    LastCheck = 0,
    LastCleanup = 0,
    ProblemsDetected = {},
    SafeModeActive = false,
    FixesApplied = 0,
    CurrentFPS = 60
}

-- Common graphics problems and their fixes
ASC.GraphicsFix.Problems = {
    {
        name = "Theme System Overload",
        check = function()
            return ASC.MasterTheme and ASC.MasterTheme.State and ASC.MasterTheme.State.PerformanceMode == false and ASC.GraphicsFix.State.CurrentFPS < 30
        end,
        fix = function()
            if ASC.MasterTheme and ASC.MasterTheme.SetPerformanceMode then
                ASC.MasterTheme.SetPerformanceMode(true)
                return "Enabled theme performance mode"
            end
            return "Theme system not available"
        end
    },
    {
        name = "Advanced Effects Overload", 
        check = function()
            return ASC.AdvancedEffects and GetConVar("asc_effects_enabled") and GetConVar("asc_effects_enabled"):GetBool() and ASC.GraphicsFix.State.CurrentFPS < 25
        end,
        fix = function()
            RunConsoleCommand("asc_effects_enabled", "0")
            return "Disabled advanced effects for performance"
        end
    },
    {
        name = "VGUI Theme Conflicts",
        check = function()
            return ASC.VGUITheme and ASC.VGUITheme.State and ASC.VGUITheme.State.ErrorCount and ASC.VGUITheme.State.ErrorCount > 5
        end,
        fix = function()
            if ASC.VGUITheme and ASC.VGUITheme.DisableTheming then
                ASC.VGUITheme.DisableTheming()
                return "Disabled VGUI theming due to errors"
            end
            return "VGUI theme system not available"
        end
    },
    {
        name = "Material Loading Errors",
        check = function()
            return ASC.Assets and ASC.Assets.State and ASC.Assets.State.FailedMaterials and #ASC.Assets.State.FailedMaterials > 0
        end,
        fix = function()
            if ASC.Assets and ASC.Assets.CreateFallbackMaterials then
                ASC.Assets.CreateFallbackMaterials()
                return "Created fallback materials"
            end
            return "Asset system not available"
        end
    },
    {
        name = "Screen Effect Overload",
        check = function()
            return ASC.StargateEffects and ASC.StargateEffects.State and ASC.StargateEffects.State.ActiveEffects > 10
        end,
        fix = function()
            if ASC.StargateEffects and ASC.StargateEffects.ClearAllEffects then
                ASC.StargateEffects.ClearAllEffects()
                return "Cleared excessive screen effects"
            end
            return "Screen effects system not available"
        end
    }
}

-- Debug print function
local function DebugPrint(msg)
    if ASC.GraphicsFix.Config.EnableDebugOutput then
        print("[ASC Graphics Fix] " .. msg)
    end
end

-- Update FPS tracking
function ASC.GraphicsFix.UpdateFPS()
    ASC.GraphicsFix.State.CurrentFPS = math.floor(1 / FrameTime())
end

-- Check for graphics problems
function ASC.GraphicsFix.CheckProblems()
    local currentTime = CurTime()
    
    -- Rate limiting
    if currentTime - ASC.GraphicsFix.State.LastCheck < ASC.GraphicsFix.Config.CheckInterval then
        return
    end
    
    ASC.GraphicsFix.State.LastCheck = currentTime
    ASC.GraphicsFix.UpdateFPS()
    
    -- Clear previous problems
    ASC.GraphicsFix.State.ProblemsDetected = {}
    
    -- Check each problem type
    for _, problem in ipairs(ASC.GraphicsFix.Problems) do
        if problem.check() then
            table.insert(ASC.GraphicsFix.State.ProblemsDetected, problem)
            DebugPrint("Detected problem: " .. problem.name)
        end
    end
    
    -- Auto-fix if enabled
    if ASC.GraphicsFix.Config.EnableAutoFix and #ASC.GraphicsFix.State.ProblemsDetected > 0 then
        ASC.GraphicsFix.AutoFixProblems()
    end
end

-- Auto-fix detected problems
function ASC.GraphicsFix.AutoFixProblems()
    local fixed = 0
    
    for _, problem in ipairs(ASC.GraphicsFix.State.ProblemsDetected) do
        local result = problem.fix()
        if result then
            print("[ASC Graphics Fix] " .. result)
            fixed = fixed + 1
            ASC.GraphicsFix.State.FixesApplied = ASC.GraphicsFix.State.FixesApplied + 1
        end
    end
    
    if fixed > 0 then
        print("[ASC Graphics Fix] Applied " .. fixed .. " automatic fixes")
    end
end

-- Enable safe mode
function ASC.GraphicsFix.EnableSafeMode()
    if ASC.GraphicsFix.State.SafeModeActive then return end
    
    print("[ASC Graphics Fix] Enabling safe mode...")
    ASC.GraphicsFix.State.SafeModeActive = true
    
    -- Disable resource-intensive features
    RunConsoleCommand("asc_effects_enabled", "0")
    RunConsoleCommand("asc_theme_performance_mode", "1")
    RunConsoleCommand("asc_vgui_theme_enabled", "0")
    
    -- Reduce effect quality
    if ASC.MasterTheme and ASC.MasterTheme.SetPreset then
        ASC.MasterTheme.SetPreset("Performance")
    end
    
    print("[ASC Graphics Fix] Safe mode enabled - graphics features reduced")
end

-- Disable safe mode
function ASC.GraphicsFix.DisableSafeMode()
    if not ASC.GraphicsFix.State.SafeModeActive then return end
    
    print("[ASC Graphics Fix] Disabling safe mode...")
    ASC.GraphicsFix.State.SafeModeActive = false
    
    -- Re-enable features
    RunConsoleCommand("asc_effects_enabled", "1")
    RunConsoleCommand("asc_theme_performance_mode", "0")
    RunConsoleCommand("asc_vgui_theme_enabled", "1")
    
    -- Restore normal quality
    if ASC.MasterTheme and ASC.MasterTheme.SetPreset then
        ASC.MasterTheme.SetPreset("Standard")
    end
    
    print("[ASC Graphics Fix] Safe mode disabled - graphics features restored")
end

-- Cleanup graphics resources
function ASC.GraphicsFix.CleanupResources()
    local currentTime = CurTime()

    -- Rate limiting
    if currentTime - ASC.GraphicsFix.State.LastCleanup < ASC.GraphicsFix.Config.CleanupInterval then
        return
    end

    ASC.GraphicsFix.State.LastCleanup = currentTime

    DebugPrint("Performing graphics cleanup...")

    local memoryBefore = collectgarbage("count")

    -- Force garbage collection multiple times for better cleanup
    collectgarbage("collect")
    collectgarbage("collect")

    local memoryAfter = collectgarbage("count")
    local memoryFreed = memoryBefore - memoryAfter

    -- Clear material cache if available
    if ASC.Assets and ASC.Assets.ClearMaterialCache then
        ASC.Assets.ClearMaterialCache()
    end

    -- Clear effect cache if available
    if ASC.AdvancedEffects and ASC.AdvancedEffects.ClearCache then
        ASC.AdvancedEffects.ClearCache()
    end

    -- Clear theme cache if available
    if ASC.MasterTheme and ASC.MasterTheme.ClearCache then
        ASC.MasterTheme.ClearCache()
    end

    -- Clear VGUI theme cache
    if ASC.VGUITheme and ASC.VGUITheme.State then
        -- Clear themed elements cache periodically
        local count = 0
        for element, _ in pairs(ASC.VGUITheme.State.ThemedElements or {}) do
            if not IsValid(element) then
                ASC.VGUITheme.State.ThemedElements[element] = nil
                count = count + 1
            end
        end
        if count > 0 then
            DebugPrint("Cleared " .. count .. " invalid VGUI elements from cache")
        end
    end

    if memoryFreed > 1 then
        print("[Advanced Space Combat] Memory cleanup freed " .. math.floor(memoryFreed) .. " MB")
    end

    DebugPrint("Graphics cleanup completed")
end

-- Get graphics status
function ASC.GraphicsFix.GetStatus()
    return {
        fps = ASC.GraphicsFix.State.CurrentFPS,
        safeMode = ASC.GraphicsFix.State.SafeModeActive,
        problemsDetected = #ASC.GraphicsFix.State.ProblemsDetected,
        fixesApplied = ASC.GraphicsFix.State.FixesApplied,
        memoryUsage = math.floor(collectgarbage("count") / 1024)
    }
end

-- Manual diagnostics
function ASC.GraphicsFix.RunDiagnostics()
    print("=== ASC Graphics Diagnostics ===")
    
    local status = ASC.GraphicsFix.GetStatus()
    print("Current FPS: " .. status.fps)
    print("Memory Usage: " .. status.memoryUsage .. " MB")
    print("Safe Mode: " .. (status.safeMode and "ACTIVE" or "INACTIVE"))
    print("Problems Detected: " .. status.problemsDetected)
    print("Fixes Applied: " .. status.fixesApplied)
    
    print("\nSystem Status:")
    print("Theme System: " .. (ASC.MasterTheme and "LOADED" or "NOT LOADED"))
    print("Advanced Effects: " .. (ASC.AdvancedEffects and "LOADED" or "NOT LOADED"))
    print("VGUI Theme: " .. (ASC.VGUITheme and "LOADED" or "NOT LOADED"))
    print("Asset System: " .. (ASC.Assets and "LOADED" or "NOT LOADED"))
    
    print("\nConVar Status:")
    local convars = {
        "asc_effects_enabled",
        "asc_theme_performance_mode", 
        "asc_vgui_theme_enabled",
        "asc_theme_preset"
    }
    
    for _, cvar in ipairs(convars) do
        local convar = GetConVar(cvar)
        if convar then
            print(cvar .. ": " .. convar:GetString())
        else
            print(cvar .. ": NOT FOUND")
        end
    end
end

-- Initialize graphics fix system
function ASC.GraphicsFix.Initialize()
    DebugPrint("Initializing graphics fix system...")
    
    -- Set up periodic checking
    timer.Create("ASC_GraphicsFix_Check", ASC.GraphicsFix.Config.CheckInterval, 0, function()
        ASC.GraphicsFix.CheckProblems()
    end)
    
    -- Set up periodic cleanup
    timer.Create("ASC_GraphicsFix_Cleanup", ASC.GraphicsFix.Config.CleanupInterval, 0, function()
        ASC.GraphicsFix.CleanupResources()
    end)
    
    -- Initial check after delay
    timer.Simple(5, function()
        ASC.GraphicsFix.CheckProblems()
    end)
    
    DebugPrint("Graphics fix system initialized")
end

-- Console commands
concommand.Add("asc_graphics_fix", function()
    ASC.GraphicsFix.AutoFixProblems()
end, nil, "Manually fix graphics problems")

concommand.Add("asc_graphics_safe_mode", function()
    if ASC.GraphicsFix.State.SafeModeActive then
        ASC.GraphicsFix.DisableSafeMode()
    else
        ASC.GraphicsFix.EnableSafeMode()
    end
end, nil, "Toggle graphics safe mode")

concommand.Add("asc_graphics_diagnostics", function()
    ASC.GraphicsFix.RunDiagnostics()
end, nil, "Run graphics diagnostics")

concommand.Add("asc_graphics_cleanup", function()
    ASC.GraphicsFix.CleanupResources()
    print("[ASC Graphics Fix] Manual cleanup completed")
end, nil, "Manually cleanup graphics resources")

-- Initialize when ready
timer.Simple(2, function()
    ASC.GraphicsFix.Initialize()
end)

print("[Advanced Space Combat] Graphics Fix System loaded successfully!")
