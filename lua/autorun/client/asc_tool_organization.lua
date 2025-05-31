-- Advanced Space Combat - Tool Organization v2.2.1
-- Comprehensive tool tab and category organization

print("[Advanced Space Combat] Tool Organization v2.2.1 - Loading...")

-- Initialize tool organization namespace
ASC = ASC or {}
ASC.Tools = ASC.Tools or {}

-- Tool organization configuration
ASC.Tools.Config = {
    -- Main tool category
    MainCategory = "Advanced Space Combat",
    
    -- Tool categories
    Categories = {
        {
            name = "Ship Building",
            icon = "icon16/cog.png",
            description = "Ship construction and core systems"
        },
        {
            name = "Weapons & Combat",
            icon = "icon16/bomb.png",
            description = "Combat systems and weapons"
        },
        {
            name = "Flight & Navigation",
            icon = "icon16/arrow_up.png",
            description = "Flight control and navigation systems"
        },
        {
            name = "Transport & Docking",
            icon = "icon16/car.png",
            description = "Docking and shuttle systems"
        },
        {
            name = "Utilities",
            icon = "icon16/wrench.png",
            description = "Tools and utilities"
        },
        {
            name = "Configuration",
            icon = "icon16/cog_edit.png",
            description = "System configuration and settings"
        }
    }
}

-- Register tool categories
function ASC.Tools.RegisterCategories()
    -- Add main Advanced Space Combat tab
    hook.Add("AddToolMenuTabs", "ASC_AddToolMenuTabs", function()
        spawnmenu.AddToolTab("ASC", "Advanced Space Combat", "icon16/world.png")
    end)
    
    -- Add tool categories
    hook.Add("AddToolMenuCategories", "ASC_AddToolMenuCategories", function()
        for _, category in ipairs(ASC.Tools.Config.Categories) do
            spawnmenu.AddToolCategory("ASC", category.name, category.name)
        end
    end)
end

-- Populate tool menus
function ASC.Tools.PopulateMenus()
    hook.Add("PopulateToolMenu", "ASC_PopulateToolMenu", function()
        ASC.Tools.PopulateShipBuilding()
        ASC.Tools.PopulateWeaponsCombat()
        ASC.Tools.PopulateFlightNavigation()
        ASC.Tools.PopulateTransportDocking()
        ASC.Tools.PopulateUtilities()
        ASC.Tools.PopulateConfiguration()
    end)
end

-- Ship Building tools
function ASC.Tools.PopulateShipBuilding()
    -- Ship Core Management
    spawnmenu.AddToolMenuOption("ASC", "Ship Building", "ship_core_manager", "Ship Core Manager", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Ship Core Management",
            Description = "Manage ship cores and basic ship systems"
        })
        
        -- Ship Core Spawning
        panel:AddControl("Button", {
            Label = "Spawn Ship Core",
            Command = "gmod_tool advanced_space_combat; asc_entity_type ship_core"
        })
        
        -- Ship Core Settings
        panel:AddControl("TextBox", {
            Label = "Default Ship Name",
            Command = "asc_default_ship_name",
            Text = "New Ship"
        })
        
        panel:AddControl("Slider", {
            Label = "Ship Core Health",
            Type = "Integer",
            Min = "500",
            Max = "2000",
            Command = "asc_ship_core_health"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Auto-detect Ship Structure",
            Command = "asc_auto_detect_ships"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Require Ship Core for Operations",
            Command = "asc_require_ship_core"
        })
    end)
    
    -- Engine Systems
    spawnmenu.AddToolMenuOption("ASC", "Ship Building", "engine_systems", "Engine Systems", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Hyperdrive Engine Systems",
            Description = "Configure and spawn hyperdrive engines"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Standard Engine",
            Command = "gmod_tool advanced_space_combat; asc_entity_type hyperdrive_engine"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Master Engine",
            Command = "gmod_tool advanced_space_combat; asc_entity_type hyperdrive_master_engine"
        })
        
        panel:AddControl("Slider", {
            Label = "Max Jump Range",
            Type = "Integer",
            Min = "10000",
            Max = "100000",
            Command = "asc_max_range"
        })
        
        panel:AddControl("Slider", {
            Label = "Energy Cost per Jump",
            Type = "Integer",
            Min = "100",
            Max = "2000",
            Command = "asc_energy_cost"
        })
    end)
end

-- Weapons & Combat tools
function ASC.Tools.PopulateWeaponsCombat()
    -- Weapon Spawning
    spawnmenu.AddToolMenuOption("ASC", "Weapons & Combat", "weapon_spawner", "Weapon Spawner", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Combat Weapon Systems",
            Description = "Spawn and configure combat weapons"
        })
        
        local weapons = {
            {"Pulse Cannon", "asc_pulse_cannon", "Fast-firing energy weapon"},
            {"Beam Weapon", "asc_beam_weapon", "Continuous energy beam"},
            {"Torpedo Launcher", "asc_torpedo_launcher", "Guided heavy projectiles"},
            {"Railgun", "asc_railgun", "Electromagnetic kinetic weapon"},
            {"Plasma Cannon", "asc_plasma_cannon", "Area-effect energy weapon"}
        }
        
        for _, weapon in ipairs(weapons) do
            panel:AddControl("Button", {
                Label = "Spawn " .. weapon[1],
                Command = "gmod_tool advanced_space_combat; asc_entity_type " .. weapon[2],
                Text = weapon[3]
            })
        end
        
        panel:AddControl("CheckBox", {
            Label = "Enable Weapon Systems",
            Command = "asc_enable_weapons"
        })
    end)
    
    -- Tactical AI
    spawnmenu.AddToolMenuOption("ASC", "Weapons & Combat", "tactical_ai", "Tactical AI", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Tactical AI Configuration",
            Description = "Configure combat AI behavior and settings"
        })
        
        panel:AddControl("ComboBox", {
            Label = "Default AI Behavior",
            MenuButton = "1",
            Folder = "asc_ai_behavior",
            Options = {
                ["Aggressive"] = {asc_default_ai_mode = "aggressive"},
                ["Defensive"] = {asc_default_ai_mode = "defensive"},
                ["Balanced"] = {asc_default_ai_mode = "balanced"}
            }
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Auto-Targeting",
            Command = "asc_auto_targeting"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Fleet Coordination",
            Command = "asc_fleet_coordination"
        })
        
        panel:AddControl("Slider", {
            Label = "AI Update Rate (seconds)",
            Type = "Float",
            Min = "0.1",
            Max = "2.0",
            Command = "asc_ai_update_rate"
        })
    end)
    
    -- Ammunition Systems
    spawnmenu.AddToolMenuOption("ASC", "Weapons & Combat", "ammunition", "Ammunition Systems", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Ammunition Management",
            Description = "Configure ammunition systems and manufacturing"
        })
        
        panel:AddControl("Slider", {
            Label = "Default Ammo Capacity",
            Type = "Integer",
            Min = "1000",
            Max = "20000",
            Command = "asc_ammo_capacity"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Ammo Manufacturing",
            Command = "asc_enable_ammo_manufacturing"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Auto-Supply Weapons",
            Command = "asc_auto_supply_weapons"
        })
    end)
end

-- Flight & Navigation tools
function ASC.Tools.PopulateFlightNavigation()
    -- Flight Systems
    spawnmenu.AddToolMenuOption("ASC", "Flight & Navigation", "flight_systems", "Flight Systems", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Ship Flight Systems",
            Description = "Configure flight control and movement"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Flight Console",
            Command = "gmod_tool advanced_space_combat; asc_entity_type asc_flight_console"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Flight Systems",
            Command = "asc_enable_flight"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Autopilot",
            Command = "asc_enable_autopilot"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Collision Avoidance",
            Command = "asc_collision_avoidance"
        })
        
        panel:AddControl("Slider", {
            Label = "Flight Update Rate",
            Type = "Float",
            Min = "0.05",
            Max = "0.5",
            Command = "asc_flight_update_rate"
        })
    end)
    
    -- Formation Flying
    spawnmenu.AddToolMenuOption("ASC", "Flight & Navigation", "formations", "Formation Flying", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Formation Flying",
            Description = "Configure formation flight patterns"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Formation Flying",
            Command = "asc_enable_formations"
        })
        
        panel:AddControl("Slider", {
            Label = "Formation Spacing",
            Type = "Integer",
            Min = "100",
            Max = "500",
            Command = "asc_formation_spacing"
        })
        
        panel:AddControl("ComboBox", {
            Label = "Default Formation",
            MenuButton = "1",
            Folder = "asc_formation_type",
            Options = {
                ["Line"] = {asc_default_formation = "line"},
                ["V-Formation"] = {asc_default_formation = "v_formation"},
                ["Diamond"] = {asc_default_formation = "diamond"},
                ["Box"] = {asc_default_formation = "box"}
            }
        })
    end)
end

-- Transport & Docking tools
function ASC.Tools.PopulateTransportDocking()
    -- Docking Systems
    spawnmenu.AddToolMenuOption("ASC", "Transport & Docking", "docking_systems", "Docking Systems", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Docking & Landing Systems",
            Description = "Configure docking pads and landing operations"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Docking Pad",
            Command = "gmod_tool advanced_space_combat; asc_entity_type asc_docking_pad"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Docking Systems",
            Command = "asc_enable_docking"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Auto-Landing",
            Command = "asc_enable_auto_landing"
        })
        
        panel:AddControl("Slider", {
            Label = "Landing Range",
            Type = "Integer",
            Min = "1000",
            Max = "5000",
            Command = "asc_landing_range"
        })
    end)
    
    -- Shuttle Systems
    spawnmenu.AddToolMenuOption("ASC", "Transport & Docking", "shuttle_systems", "Shuttle Systems", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Shuttle Transport Systems",
            Description = "Configure automated shuttle operations"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Shuttle",
            Command = "gmod_tool advanced_space_combat; asc_entity_type asc_shuttle"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Shuttle Systems",
            Command = "asc_enable_shuttles"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Auto-Missions",
            Command = "asc_auto_missions"
        })
        
        panel:AddControl("Slider", {
            Label = "Max Active Shuttles",
            Type = "Integer",
            Min = "5",
            Max = "50",
            Command = "asc_max_shuttles"
        })
    end)
end

-- Utilities tools
function ASC.Tools.PopulateUtilities()
    -- Undo System
    spawnmenu.AddToolMenuOption("ASC", "Utilities", "undo_system", "Undo System", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Advanced Undo System",
            Description = "Manage entity undo and cleanup"
        })
        
        panel:AddControl("Button", {
            Label = "Undo Last Entity",
            Command = "asc_undo"
        })
        
        panel:AddControl("Button", {
            Label = "Show Undo List",
            Command = "asc_undo_list"
        })
        
        panel:AddControl("Button", {
            Label = "Clear Undo List",
            Command = "asc_undo_clear"
        })
        
        panel:AddControl("Slider", {
            Label = "Max Undo Entries",
            Type = "Integer",
            Min = "10",
            Max = "100",
            Command = "asc_max_undo_entries"
        })
    end)
    
    -- ARIA Chat AI
    spawnmenu.AddToolMenuOption("ASC", "Utilities", "chat_ai", "ARIA Chat AI", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "ARIA Chat AI Assistant",
            Description = "Configure AI assistant settings"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable ARIA Chat AI",
            Command = "asc_enable_chat_ai"
        })
        
        panel:AddControl("Button", {
            Label = "Talk to ARIA",
            Command = "say !ai help"
        })
        
        panel:AddControl("Label", {
            Text = "Chat Commands:"
        })
        
        panel:AddControl("Label", {
            Text = "!ai help - Show available commands"
        })
        
        panel:AddControl("Label", {
            Text = "!ai weapons - Learn about weapons"
        })
        
        panel:AddControl("Label", {
            Text = "!ai flight - Flight system help"
        })
        
        panel:AddControl("Label", {
            Text = "!ai status - System status"
        })
    end)
end

-- Configuration tools
function ASC.Tools.PopulateConfiguration()
    -- General Settings
    spawnmenu.AddToolMenuOption("ASC", "Configuration", "general", "General Settings", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Advanced Space Combat Configuration",
            Description = "General addon settings and preferences"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Advanced Space Combat",
            Command = "asc_enabled"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Debug Mode",
            Command = "asc_debug_mode"
        })
        
        panel:AddControl("Button", {
            Label = "Show System Status",
            Command = "asc_status"
        })
        
        panel:AddControl("Button", {
            Label = "Show Help",
            Command = "asc_help"
        })
    end)
    
    -- Integration Settings
    spawnmenu.AddToolMenuOption("ASC", "Configuration", "integrations", "Integration Settings", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Addon Integration Settings",
            Description = "Configure integration with other addons"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Spacebuild 3 Integration",
            Command = "asc_enable_sb3"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable CAP Integration",
            Command = "asc_enable_cap"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Wiremod Integration",
            Command = "asc_enable_wiremod"
        })
    end)
    
    -- UI Settings
    spawnmenu.AddToolMenuOption("ASC", "Configuration", "ui_settings", "UI Settings", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "User Interface Settings",
            Description = "Configure UI appearance and behavior"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable UI System",
            Command = "asc_ui_enabled"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable UI Animations",
            Command = "asc_ui_animations"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable UI Sounds",
            Command = "asc_ui_sounds"
        })
        
        panel:AddControl("Slider", {
            Label = "UI Scale",
            Type = "Float",
            Min = "0.5",
            Max = "2.0",
            Command = "asc_ui_scale"
        })
        
        panel:AddControl("CheckBox", {
            Label = "High Contrast Mode",
            Command = "asc_ui_high_contrast"
        })
    end)
end

-- Initialize tool organization
hook.Add("Initialize", "ASC_InitializeTools", function()
    ASC.Tools.RegisterCategories()
    ASC.Tools.PopulateMenus()
end)

print("[Advanced Space Combat] Tool Organization loaded successfully!")
