-- Advanced Space Combat - Initialization Order Manager
-- Ensures proper loading order of client-side systems

print("[Advanced Space Combat] Initialization Order Manager Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.InitManager = ASC.InitManager or {}

-- Initialization state tracking
ASC.InitManager.State = {
    UISystemReady = false,
    HUDSystemReady = false,
    ThemeSystemReady = false,
    NetworkingReady = false
}

-- Initialization queue
ASC.InitManager.Queue = {}

-- Add system to initialization queue
function ASC.InitManager.RegisterSystem(name, initFunc, dependencies)
    dependencies = dependencies or {}
    
    ASC.InitManager.Queue[name] = {
        name = name,
        initFunc = initFunc,
        dependencies = dependencies,
        initialized = false,
        retryCount = 0,
        maxRetries = 5
    }
    
    print("[ASC Init] Registered system: " .. name)
end

-- Check if dependencies are met
function ASC.InitManager.CheckDependencies(systemName)
    local system = ASC.InitManager.Queue[systemName]
    if not system then return false end
    
    for _, dep in ipairs(system.dependencies) do
        local depSystem = ASC.InitManager.Queue[dep]
        if not depSystem or not depSystem.initialized then
            return false
        end
    end
    
    return true
end

-- Initialize a specific system
function ASC.InitManager.InitializeSystem(systemName)
    local system = ASC.InitManager.Queue[systemName]
    if not system or system.initialized then return true end
    
    -- Check dependencies
    if not ASC.InitManager.CheckDependencies(systemName) then
        return false
    end
    
    -- Try to initialize
    local success, err = pcall(system.initFunc)
    if success then
        system.initialized = true
        ASC.InitManager.State[systemName .. "Ready"] = true
        print("[ASC Init] Successfully initialized: " .. systemName)
        return true
    else
        system.retryCount = system.retryCount + 1
        print("[ASC Init] Failed to initialize " .. systemName .. " (attempt " .. system.retryCount .. "): " .. tostring(err))
        
        if system.retryCount >= system.maxRetries then
            print("[ASC Init] Max retries reached for: " .. systemName)
            return false
        end
    end
    
    return false
end

-- Process initialization queue
function ASC.InitManager.ProcessQueue()
    local anyInitialized = false
    
    for name, system in pairs(ASC.InitManager.Queue) do
        if not system.initialized then
            if ASC.InitManager.InitializeSystem(name) then
                anyInitialized = true
            end
        end
    end
    
    -- Check if all systems are initialized
    local allReady = true
    for name, system in pairs(ASC.InitManager.Queue) do
        if not system.initialized then
            allReady = false
            break
        end
    end
    
    if allReady then
        print("[ASC Init] All systems initialized successfully!")
        timer.Remove("ASC_InitManager_Process")
    elseif anyInitialized then
        -- Continue processing if we made progress
        timer.Simple(0.1, ASC.InitManager.ProcessQueue)
    end
end

-- Start initialization process
function ASC.InitManager.Start()
    print("[ASC Init] Starting initialization process...")
    
    -- Register core systems with dependencies
    ASC.InitManager.RegisterSystem("ConVarManager", function()
        if ASC.ConVarManager and ASC.ConVarManager.InitializeAllConVars then
            ASC.ConVarManager.InitializeAllConVars()
            return true
        end
        return true -- ConVar manager might already be initialized
    end, {})

    ASC.InitManager.RegisterSystem("UISystem", function()
        if ASC.UI and ASC.UI.Initialize then
            ASC.UI.Initialize()
            return true
        end
        return false
    end, {"ConVarManager"})


    
    -- Start processing
    timer.Simple(0.1, ASC.InitManager.ProcessQueue)
end

-- Initialize when client is ready
hook.Add("InitPostEntity", "ASC_InitManager_Start", function()
    timer.Simple(0.1, ASC.InitManager.Start)
end)

print("[Advanced Space Combat] Initialization Order Manager Loaded Successfully!")
