-- Advanced Space Combat - Tool Restoration System
-- Ensures ASC tools are always available and properly registered

if not CLIENT then return end

ASC = ASC or {}
ASC.ToolRestoration = ASC.ToolRestoration or {}

-- Configuration
ASC.ToolRestoration.Config = {
    CheckInterval = 5, -- Check every 5 seconds
    MaxRetries = 3,
    DebugMode = false
}

-- State tracking
ASC.ToolRestoration.State = {
    LastCheck = 0,
    RetryCount = 0,
    ToolsRegistered = false,
    MissingTools = {}
}

-- List of ASC tools that should always be available
ASC.ToolRestoration.RequiredTools = {
    {
        class = "asc_ship_core_tool",
        name = "ASC Ship Core Tool",
        category = "Advanced Space Combat",
        file = "lua/weapons/gmod_tool/stools/asc_ship_core_tool.lua"
    },
    {
        class = "asc_main_tool", 
        name = "ASC Main Tool",
        category = "Advanced Space Combat",
        file = "lua/weapons/gmod_tool/stools/asc_main_tool.lua"
    },
    {
        class = "asc_hyperdrive_tool",
        name = "ASC Hyperdrive Tool", 
        category = "Advanced Space Combat",
        file = "lua/weapons/gmod_tool/stools/asc_hyperdrive_tool.lua"
    },
    {
        class = "asc_weapon_tool",
        name = "ASC Weapon Tool",
        category = "Advanced Space Combat", 
        file = "lua/weapons/gmod_tool/stools/asc_weapon_tool.lua"
    },
    {
        class = "asc_shield_tool",
        name = "ASC Shield Tool",
        category = "Advanced Space Combat",
        file = "lua/weapons/gmod_tool/stools/asc_shield_tool.lua"
    },
    {
        class = "asc_ship_builder",
        name = "ASC Ship Builder",
        category = "Advanced Space Combat",
        file = "lua/weapons/gmod_tool/stools/asc_ship_builder.lua"
    },
    {
        class = "asc_weapon_config",
        name = "ASC Weapon Config",
        category = "Advanced Space Combat",
        file = "lua/weapons/gmod_tool/stools/asc_weapon_config.lua"
    }
}

-- Debug print function
local function DebugPrint(msg)
    if ASC.ToolRestoration.Config.DebugMode then
        print("[ASC Tool Restoration] " .. msg)
    end
end

-- Check if a tool is properly registered
function ASC.ToolRestoration.IsToolRegistered(toolClass)
    -- Check if tool exists in spawnmenu
    local tools = spawnmenu.GetTools()
    if not tools then return false end
    
    for category, categoryTools in pairs(tools) do
        if categoryTools[toolClass] then
            return true
        end
    end
    
    return false
end

-- Check if tool file exists
function ASC.ToolRestoration.ToolFileExists(toolData)
    return file.Exists(toolData.file, "LUA")
end

-- Force register a tool
function ASC.ToolRestoration.ForceRegisterTool(toolData)
    DebugPrint("Force registering tool: " .. toolData.class)

    -- Ensure the tool file is included
    if ASC.ToolRestoration.ToolFileExists(toolData) then
        local success, err = pcall(include, toolData.file)
        if success then
            DebugPrint("Included tool file: " .. toolData.file)
        else
            DebugPrint("Error including tool file " .. toolData.file .. ": " .. tostring(err))
            return false
        end
    else
        DebugPrint("Tool file not found: " .. toolData.file)
        return false
    end

    -- Ensure spawnmenu categories exist
    spawnmenu.AddToolTab(toolData.category, toolData.category, "icon16/cog.png")
    spawnmenu.AddToolCategory(toolData.category, "Tools", "Tools")

    -- Add to spawnmenu
    local success, err = pcall(function()
        spawnmenu.AddToolMenuOption(toolData.category, "Tools", toolData.class, toolData.name, "", "", function(panel)
            panel:ClearControls()
            panel:Help(toolData.name .. " - Advanced Space Combat tool")
            panel:Button("Select " .. toolData.name, "gmod_tool " .. toolData.class)

            -- Add additional tool info
            panel:Help("Category: " .. toolData.category)
            panel:Help("File: " .. toolData.file)
        end)
    end)

    if success then
        DebugPrint("Added tool to spawnmenu: " .. toolData.class)
        return true
    else
        DebugPrint("Error adding tool to spawnmenu: " .. tostring(err))
        return false
    end
end

-- Check all required tools
function ASC.ToolRestoration.CheckAllTools()
    local currentTime = CurTime()
    
    -- Rate limiting
    if currentTime - ASC.ToolRestoration.State.LastCheck < ASC.ToolRestoration.Config.CheckInterval then
        return
    end
    
    ASC.ToolRestoration.State.LastCheck = currentTime
    ASC.ToolRestoration.State.MissingTools = {}
    
    DebugPrint("Checking all ASC tools...")
    
    local allToolsPresent = true
    
    for _, toolData in ipairs(ASC.ToolRestoration.RequiredTools) do
        if not ASC.ToolRestoration.IsToolRegistered(toolData.class) then
            table.insert(ASC.ToolRestoration.State.MissingTools, toolData)
            allToolsPresent = false
            DebugPrint("Missing tool: " .. toolData.class)
        end
    end
    
    if not allToolsPresent then
        ASC.ToolRestoration.RestoreMissingTools()
    else
        ASC.ToolRestoration.State.ToolsRegistered = true
        DebugPrint("All tools are properly registered")
    end
end

-- Restore missing tools
function ASC.ToolRestoration.RestoreMissingTools()
    if ASC.ToolRestoration.State.RetryCount >= ASC.ToolRestoration.Config.MaxRetries then
        print("[ASC Tool Restoration] Max retries reached, some tools may be unavailable")
        return
    end
    
    ASC.ToolRestoration.State.RetryCount = ASC.ToolRestoration.State.RetryCount + 1
    
    print("[ASC Tool Restoration] Restoring " .. #ASC.ToolRestoration.State.MissingTools .. " missing tools (Attempt " .. ASC.ToolRestoration.State.RetryCount .. ")")
    
    local restored = 0
    
    for _, toolData in ipairs(ASC.ToolRestoration.State.MissingTools) do
        if ASC.ToolRestoration.ForceRegisterTool(toolData) then
            restored = restored + 1
        end
    end
    
    print("[ASC Tool Restoration] Restored " .. restored .. " tools")
    
    -- Force refresh spawnmenu
    timer.Simple(0.1, function()
        hook.Run("PopulateToolMenu")
    end)
end

-- Manual tool restoration command
function ASC.ToolRestoration.ManualRestore()
    print("[ASC Tool Restoration] Manual restoration initiated...")
    
    ASC.ToolRestoration.State.RetryCount = 0
    ASC.ToolRestoration.State.LastCheck = 0
    
    -- Force check all tools
    ASC.ToolRestoration.CheckAllTools()
    
    -- Also ensure spawnmenu categories exist
    timer.Simple(0.5, function()
        ASC.ToolRestoration.EnsureSpawnMenuCategories()
    end)
end

-- Ensure spawnmenu categories exist
function ASC.ToolRestoration.EnsureSpawnMenuCategories()
    -- Add Advanced Space Combat category if it doesn't exist
    spawnmenu.AddToolTab("Advanced Space Combat", "Advanced Space Combat", "icon16/cog.png")
    
    -- Add subcategories
    spawnmenu.AddToolCategory("Advanced Space Combat", "Tools", "Tools")
    spawnmenu.AddToolCategory("Advanced Space Combat", "Ship Systems", "Ship Systems")
    spawnmenu.AddToolCategory("Advanced Space Combat", "Combat", "Combat")
    spawnmenu.AddToolCategory("Advanced Space Combat", "Configuration", "Configuration")
    
    DebugPrint("Ensured spawnmenu categories exist")
end

-- Initialize tool restoration system
function ASC.ToolRestoration.Initialize()
    DebugPrint("Initializing tool restoration system...")
    
    -- Initial check after a delay to ensure everything is loaded
    timer.Simple(2, function()
        ASC.ToolRestoration.EnsureSpawnMenuCategories()
        ASC.ToolRestoration.CheckAllTools()
    end)
    
    -- Set up periodic checking
    timer.Create("ASC_ToolRestoration_Check", ASC.ToolRestoration.Config.CheckInterval, 0, function()
        ASC.ToolRestoration.CheckAllTools()
    end)
    
    DebugPrint("Tool restoration system initialized")
end

-- Console commands
concommand.Add("asc_restore_tools", function()
    ASC.ToolRestoration.ManualRestore()
end, nil, "Manually restore ASC tools")

concommand.Add("asc_check_tools", function()
    print("[ASC Tool Restoration] Checking tool status...")
    
    for _, toolData in ipairs(ASC.ToolRestoration.RequiredTools) do
        local registered = ASC.ToolRestoration.IsToolRegistered(toolData.class)
        local fileExists = ASC.ToolRestoration.ToolFileExists(toolData)
        
        local status = "❓"
        if registered and fileExists then
            status = "✅"
        elseif not registered and fileExists then
            status = "⚠️ "
        elseif not fileExists then
            status = "❌"
        end
        
        print(status .. " " .. toolData.class .. " - Registered: " .. tostring(registered) .. ", File: " .. tostring(fileExists))
    end
end, nil, "Check ASC tool status")

concommand.Add("asc_tool_debug", function()
    ASC.ToolRestoration.Config.DebugMode = not ASC.ToolRestoration.Config.DebugMode
    print("[ASC Tool Restoration] Debug mode: " .. (ASC.ToolRestoration.Config.DebugMode and "ON" or "OFF"))
end, nil, "Toggle ASC tool restoration debug mode")

-- Hook into spawnmenu population
hook.Add("PopulateToolMenu", "ASC_ToolRestoration_PopulateToolMenu", function()
    timer.Simple(0.1, function()
        ASC.ToolRestoration.CheckAllTools()
    end)
end)

-- Initialize when ready
timer.Simple(1, function()
    ASC.ToolRestoration.Initialize()
end)

print("[Advanced Space Combat] Tool Restoration System loaded successfully!")
