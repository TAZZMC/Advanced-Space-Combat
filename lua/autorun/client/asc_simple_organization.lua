-- Advanced Space Combat - Simple Organization System
-- Basic working implementation for Q menu and spawn menu

if SERVER then return end

print("[ASC] Simple Organization System - Loading...")

-- Simple entity registration
local function RegisterEntities()
    print("[ASC] Registering entities...")
    
    -- Core entities
    local entities = {
        {class = "ship_core", name = "Ship Core", category = "Advanced Space Combat"},
        {class = "hyperdrive_engine", name = "Hyperdrive Engine", category = "Advanced Space Combat"},
        {class = "hyperdrive_master_engine", name = "Master Hyperdrive Engine", category = "Advanced Space Combat"},
        {class = "hyperdrive_computer", name = "Navigation Computer", category = "Advanced Space Combat"},
        {class = "hyperdrive_pulse_cannon", name = "Pulse Cannon", category = "Advanced Space Combat"},
        {class = "hyperdrive_beam_weapon", name = "Beam Weapon", category = "Advanced Space Combat"},
        {class = "hyperdrive_torpedo_launcher", name = "Torpedo Launcher", category = "Advanced Space Combat"},
        {class = "hyperdrive_railgun", name = "Railgun", category = "Advanced Space Combat"},
        {class = "hyperdrive_plasma_cannon", name = "Plasma Cannon", category = "Advanced Space Combat"},
        {class = "hyperdrive_shield_generator", name = "Shield Generator", category = "Advanced Space Combat"},
        {class = "hyperdrive_flight_console", name = "Flight Console", category = "Advanced Space Combat"},
        {class = "hyperdrive_docking_pad", name = "Docking Pad", category = "Advanced Space Combat"},
        {class = "hyperdrive_shuttle", name = "Transport Shuttle", category = "Advanced Space Combat"},
        {class = "asc_ancient_zpm", name = "Zero Point Module", category = "Advanced Space Combat"},
        {class = "asc_ancient_drone", name = "Ancient Drone", category = "Advanced Space Combat"}
    }
    
    local registered = 0
    for _, ent in ipairs(entities) do
        -- Check if entity exists
        if file.Exists("lua/entities/" .. ent.class .. "/init.lua", "GAME") or 
           file.Exists("lua/entities/" .. ent.class .. ".lua", "GAME") then
            
            list.Set("SpawnableEntities", ent.class, {
                PrintName = ent.name,
                ClassName = ent.class,
                Category = ent.category,
                Spawnable = true,
                AdminSpawnable = true
            })
            registered = registered + 1
            print("[ASC] Registered: " .. ent.name)
        end
    end
    
    print("[ASC] Registered " .. registered .. " entities")
end

-- Simple Q menu setup
local function SetupQMenu()
    print("[ASC] Setting up Q menu...")
    
    -- Add main tab
    spawnmenu.AddToolTab("Advanced Space Combat", "Advanced Space Combat", "icon16/world.png")
    
    -- Add categories
    spawnmenu.AddToolCategory("Advanced Space Combat", "Tools", "Tools")
    spawnmenu.AddToolCategory("Advanced Space Combat", "Help", "Help")
    
    -- Add main tool
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Tools", "hyperdrive_tool", "Hyperdrive Tool", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Advanced Space Combat - Hyperdrive System")
        panel:Help("Main tool for spawning and configuring space combat entities")
        
        panel:Button("Select Hyperdrive Tool", "gmod_tool hyperdrive")
        
        panel:Help("\nFeatures:")
        panel:Help("• Ship Core Management")
        panel:Help("• Hyperdrive Engines")
        panel:Help("• Weapon Systems")
        panel:Help("• Shield Generators")
        panel:Help("• Flight Controls")
        panel:Help("• Docking Systems")
        
        panel:Help("\nUsage:")
        panel:Help("1. Select the Hyperdrive tool")
        panel:Help("2. Left-click to spawn ship cores")
        panel:Help("3. Right-click to spawn engines")
        panel:Help("4. Use reload key for options")
    end)
    
    -- Add help section
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Help", "help_main", "Help & Commands", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Advanced Space Combat v2.2.1 - Ultimate Edition")
        panel:Help("Complete space combat system for Garry's Mod")
        
        panel:Help("\n=== Console Commands ===")
        panel:Help("• hyperdrive_help - Show help")
        panel:Help("• hyperdrive_status - System status")
        panel:Help("• hyperdrive_undo - Undo last action")
        
        panel:Help("\n=== Chat Commands ===")
        panel:Help("• !ai <question> - Ask ARIA AI")
        panel:Help("• !help - Show AI help")
        
        panel:Help("\n=== Controls ===")
        panel:Help("• E - Use/interact with entities")
        panel:Help("• Z - Undo last spawn")
        panel:Help("• WASD - Flight movement")
        panel:Help("• Space/Ctrl - Up/Down")
        
        panel:Button("Show Console Help", "hyperdrive_help")
        panel:Button("Show System Status", "hyperdrive_status")
    end)
    
    -- Add configuration
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Help", "config_main", "Configuration", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Advanced Space Combat Configuration")
        
        panel:CheckBox("Enable Hyperdrive System", "hyperdrive_enabled")
        panel:CheckBox("Require Ship Core", "hyperdrive_require_ship_core")
        panel:CheckBox("One Core Per Ship", "hyperdrive_one_core_per_ship")
        panel:CheckBox("Modern UI", "hyperdrive_modern_ui_enabled")
        
        panel:Help("\n=== Audio Settings ===")
        panel:NumSlider("Master Volume", "hyperdrive_sound_volume", 0, 1, 2)
        panel:NumSlider("Engine Volume", "hyperdrive_sound_hyperdrive_volume", 0, 1, 2)
        panel:NumSlider("Shield Volume", "hyperdrive_shield_volume", 0, 1, 2)
        
        panel:Help("\n=== Integration ===")
        panel:CheckBox("Enable CAP Integration", "hyperdrive_enable_cap_integration")
        panel:CheckBox("Enable SB3 Resources", "hyperdrive_enable_sb3_resources")
        panel:CheckBox("Enable Wiremod", "hyperdrive_enable_wiremod")
    end)
    
    print("[ASC] Q menu setup complete")
end

-- Initialize everything
local function Initialize()
    print("[ASC] Initializing organization system...")
    
    -- Register entities
    RegisterEntities()
    
    -- Setup Q menu
    SetupQMenu()
    
    print("[ASC] Organization system initialized")
end

-- Hook registration with multiple fallbacks
hook.Add("AddToolMenuTabs", "ASC_SimpleOrganization_Tabs", function()
    print("[ASC] AddToolMenuTabs called")
    timer.Simple(0.1, function()
        SetupQMenu()
    end)
end)

hook.Add("PopulateToolMenu", "ASC_SimpleOrganization_Populate", function()
    print("[ASC] PopulateToolMenu called")
    timer.Simple(0.1, function()
        SetupQMenu()
    end)
end)

hook.Add("Initialize", "ASC_SimpleOrganization_Init", function()
    print("[ASC] Initialize called")
    timer.Simple(1, function()
        Initialize()
    end)
end)

hook.Add("InitPostEntity", "ASC_SimpleOrganization_PostInit", function()
    print("[ASC] InitPostEntity called")
    timer.Simple(2, function()
        Initialize()
    end)
end)

-- Manual commands
concommand.Add("asc_setup_organization", function()
    Initialize()
    print("[ASC] Organization manually initialized")
end)

concommand.Add("asc_setup_qmenu", function()
    SetupQMenu()
    print("[ASC] Q menu manually setup")
end)

concommand.Add("asc_register_entities", function()
    RegisterEntities()
    print("[ASC] Entities manually registered")
end)

print("[ASC] Simple Organization System - Loaded")
