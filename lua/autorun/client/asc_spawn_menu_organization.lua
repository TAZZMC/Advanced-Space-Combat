-- Advanced Space Combat - Spawn Menu Organization v2.2.1
-- Comprehensive Q menu and spawn menu organization system

print("[Advanced Space Combat] Spawn Menu Organization v2.2.1 - Loading...")

-- Initialize client-side namespace
ASC = ASC or {}
ASC.SpawnMenu = ASC.SpawnMenu or {}

-- Spawn menu configuration
ASC.SpawnMenu.Config = {
    -- Main category settings
    MainCategory = "Advanced Space Combat",
    CategoryIcon = "icon16/world.png",
    
    -- Sub-categories
    Categories = {
        {
            name = "Ship Components",
            icon = "icon16/cog.png",
            description = "Core ship systems and components"
        },
        {
            name = "Weapons",
            icon = "icon16/bomb.png", 
            description = "Combat weapons and systems"
        },
        {
            name = "Flight Systems",
            icon = "icon16/arrow_up.png",
            description = "Flight control and navigation"
        },
        {
            name = "Transport",
            icon = "icon16/car.png",
            description = "Docking and shuttle systems"
        },
        {
            name = "Shields & Defense",
            icon = "icon16/shield.png",
            description = "Defensive systems and shields"
        },
        {
            name = "Tools",
            icon = "icon16/wrench.png",
            description = "Spawn tools and utilities"
        }
    }
}

-- Entity organization data
ASC.SpawnMenu.Entities = {
    ["Ship Components"] = {
        {
            class = "ship_core",
            name = "Ship Core",
            description = "Central ship management hub",
            icon = "entities/ship_core.png",
            category = "Ship Components"
        },
        {
            class = "hyperdrive_engine",
            name = "Hyperdrive Engine",
            description = "Standard hyperdrive propulsion",
            icon = "entities/hyperdrive_engine.png",
            category = "Ship Components"
        },
        {
            class = "hyperdrive_master_engine",
            name = "Master Hyperdrive Engine",
            description = "Advanced hyperdrive propulsion",
            icon = "entities/hyperdrive_master_engine.png",
            category = "Ship Components"
        },
        {
            class = "hyperdrive_computer",
            name = "Hyperdrive Computer",
            description = "Navigation and control computer",
            icon = "entities/hyperdrive_computer.png",
            category = "Ship Components"
        }
    },
    
    ["Weapons"] = {
        {
            class = "asc_pulse_cannon",
            name = "Pulse Cannon",
            description = "Fast-firing energy weapon",
            icon = "entities/asc_pulse_cannon.png",
            category = "Weapons"
        },
        {
            class = "asc_beam_weapon",
            name = "Beam Weapon",
            description = "Continuous energy beam",
            icon = "entities/asc_beam_weapon.png",
            category = "Weapons"
        },
        {
            class = "asc_torpedo_launcher",
            name = "Torpedo Launcher",
            description = "Guided heavy projectiles",
            icon = "entities/asc_torpedo_launcher.png",
            category = "Weapons"
        },
        {
            class = "asc_railgun",
            name = "Railgun",
            description = "Electromagnetic kinetic weapon",
            icon = "entities/asc_railgun.png",
            category = "Weapons"
        },
        {
            class = "asc_plasma_cannon",
            name = "Plasma Cannon",
            description = "Area-effect energy weapon",
            icon = "entities/asc_plasma_cannon.png",
            category = "Weapons"
        }
    },
    
    ["Flight Systems"] = {
        {
            class = "asc_flight_console",
            name = "Flight Console",
            description = "Ship flight control interface",
            icon = "entities/asc_flight_console.png",
            category = "Flight Systems"
        }
    },
    
    ["Transport"] = {
        {
            class = "asc_docking_pad",
            name = "Docking Pad",
            description = "Ship landing pad with services",
            icon = "entities/asc_docking_pad.png",
            category = "Transport"
        },
        {
            class = "asc_shuttle",
            name = "Shuttle",
            description = "Automated transport shuttle",
            icon = "entities/asc_shuttle.png",
            category = "Transport"
        }
    },
    
    ["Shields & Defense"] = {
        {
            class = "asc_shield_generator",
            name = "Shield Generator",
            description = "CAP-integrated shield system",
            icon = "entities/asc_shield_generator.png",
            category = "Shields & Defense"
        }
    }
}

-- Tool organization data
ASC.SpawnMenu.Tools = {
    {
        class = "advanced_space_combat",
        name = "Advanced Space Combat Tool",
        description = "Comprehensive entity spawning tool",
        icon = "gui/silkicons/wrench",
        category = "Advanced Space Combat"
    }
}

-- Register entities in spawn menu
function ASC.SpawnMenu.RegisterEntities()
    -- Register main category
    list.Set("SpawnableEntities", "asc_category_header", {
        PrintName = "=== ADVANCED SPACE COMBAT ===",
        ClassName = "",
        Category = ASC.SpawnMenu.Config.MainCategory,
        Spawnable = false,
        AdminSpawnable = false
    })
    
    -- Register entities by category
    for categoryName, entities in pairs(ASC.SpawnMenu.Entities) do
        for _, entityData in ipairs(entities) do
            list.Set("SpawnableEntities", entityData.class, {
                PrintName = entityData.name,
                ClassName = entityData.class,
                Category = ASC.SpawnMenu.Config.MainCategory .. " - " .. categoryName,
                Spawnable = true,
                AdminSpawnable = true,
                IconOverride = entityData.icon,
                Description = entityData.description
            })
        end
    end
end

-- Register tools in spawn menu
function ASC.SpawnMenu.RegisterTools()
    for _, toolData in ipairs(ASC.SpawnMenu.Tools) do
        list.Set("DesktopWindows", toolData.class, {
            title = toolData.name,
            icon = toolData.icon,
            width = 960,
            height = 700,
            onewindow = true,
            init = function(icon, window)
                window:Remove()
                RunConsoleCommand("gmod_tool", toolData.class)
            end
        })
    end
end

-- Create custom spawn menu tabs
function ASC.SpawnMenu.CreateTabs()
    -- Add to existing spawn menu
    hook.Add("SpawnMenuOpen", "ASC_SpawnMenuOpen", function()
        -- Custom tab creation would go here
        -- This is a placeholder for future custom tab implementation
    end)
end

-- Q Menu integration
function ASC.SpawnMenu.CreateQMenuTab()
    -- Add Advanced Space Combat tab to Q menu
    hook.Add("AddToolMenuTabs", "ASC_AddToolMenuTabs", function()
        spawnmenu.AddToolTab("Advanced Space Combat", "Advanced Space Combat", "icon16/world.png")
    end)
    
    -- Add tool menu categories
    hook.Add("AddToolMenuCategories", "ASC_AddToolMenuCategories", function()
        spawnmenu.AddToolCategory("Advanced Space Combat", "Ship Systems", "Ship Systems")
        spawnmenu.AddToolCategory("Advanced Space Combat", "Combat", "Combat Systems")
        spawnmenu.AddToolCategory("Advanced Space Combat", "Flight", "Flight & Navigation")
        spawnmenu.AddToolCategory("Advanced Space Combat", "Transport", "Transport Systems")
        spawnmenu.AddToolCategory("Advanced Space Combat", "Configuration", "Configuration")
        spawnmenu.AddToolCategory("Advanced Space Combat", "Help", "Help & Information")
    end)
    
    -- Add tool menu panels
    hook.Add("PopulateToolMenu", "ASC_PopulateToolMenu", function()
        ASC.SpawnMenu.PopulateShipSystems()
        ASC.SpawnMenu.PopulateCombatSystems()
        ASC.SpawnMenu.PopulateFlightSystems()
        ASC.SpawnMenu.PopulateTransportSystems()
        ASC.SpawnMenu.PopulateConfiguration()
        ASC.SpawnMenu.PopulateHelp()
    end)
end

-- Populate Ship Systems tab
function ASC.SpawnMenu.PopulateShipSystems()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Ship Systems", "ship_core_spawner", "Ship Core Spawner", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Ship Core Spawner",
            Description = "Spawn and configure ship cores"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Ship Core",
            Command = "gmod_tool advanced_space_combat; asc_spawn_entity ship_core"
        })
        
        panel:AddControl("Slider", {
            Label = "Ship Core Health",
            Type = "Float",
            Min = "500",
            Max = "2000",
            Command = "asc_ship_core_health"
        })
        
        panel:AddControl("TextBox", {
            Label = "Default Ship Name",
            Command = "asc_default_ship_name"
        })
    end)
    
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Ship Systems", "engine_spawner", "Engine Spawner", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Hyperdrive Engine Spawner",
            Description = "Spawn and configure hyperdrive engines"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Standard Engine",
            Command = "gmod_tool advanced_space_combat; asc_spawn_entity hyperdrive_engine"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Master Engine",
            Command = "gmod_tool advanced_space_combat; asc_spawn_entity hyperdrive_master_engine"
        })
    end)
end

-- Populate Combat Systems tab
function ASC.SpawnMenu.PopulateCombatSystems()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Combat", "weapon_spawner", "Weapon Spawner", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Weapon Systems",
            Description = "Spawn and configure combat weapons"
        })
        
        local weaponTypes = {
            {"Pulse Cannon", "asc_pulse_cannon"},
            {"Beam Weapon", "asc_beam_weapon"},
            {"Torpedo Launcher", "asc_torpedo_launcher"},
            {"Railgun", "asc_railgun"},
            {"Plasma Cannon", "asc_plasma_cannon"}
        }
        
        for _, weapon in ipairs(weaponTypes) do
            panel:AddControl("Button", {
                Label = "Spawn " .. weapon[1],
                Command = "gmod_tool advanced_space_combat; asc_spawn_entity " .. weapon[2]
            })
        end
    end)
    
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Combat", "tactical_ai", "Tactical AI", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Tactical AI Configuration",
            Description = "Configure combat AI behavior"
        })
        
        panel:AddControl("ComboBox", {
            Label = "Default AI Mode",
            MenuButton = "1",
            Folder = "asc_ai_mode",
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
    end)
end

-- Populate Flight Systems tab
function ASC.SpawnMenu.PopulateFlightSystems()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Flight", "flight_console", "Flight Console", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Flight Console",
            Description = "Spawn and configure flight systems"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Flight Console",
            Command = "gmod_tool advanced_space_combat; asc_spawn_entity asc_flight_console"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Autopilot",
            Command = "asc_enable_autopilot"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Formation Flying",
            Command = "asc_enable_formations"
        })
    end)
end

-- Populate Transport Systems tab
function ASC.SpawnMenu.PopulateTransportSystems()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Transport", "docking_systems", "Docking Systems", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Docking & Transport",
            Description = "Spawn docking pads and shuttles"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Docking Pad",
            Command = "gmod_tool advanced_space_combat; asc_spawn_entity asc_docking_pad"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Shuttle",
            Command = "gmod_tool advanced_space_combat; asc_spawn_entity asc_shuttle"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Auto-Landing",
            Command = "asc_enable_auto_landing"
        })
    end)
end

-- Populate Configuration tab
function ASC.SpawnMenu.PopulateConfiguration()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Configuration", "general_settings", "General Settings", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Advanced Space Combat Configuration",
            Description = "Configure addon settings"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Advanced Space Combat",
            Command = "asc_enabled"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Debug Mode",
            Command = "asc_debug_mode"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable ARIA Chat AI",
            Command = "asc_enable_chat_ai"
        })
        
        panel:AddControl("Slider", {
            Label = "UI Scale",
            Type = "Float",
            Min = "0.5",
            Max = "2.0",
            Command = "asc_ui_scale"
        })
    end)
    
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Configuration", "integration_settings", "Integration Settings", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Integration Settings",
            Description = "Configure addon integrations"
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
end

-- Populate Help tab
function ASC.SpawnMenu.PopulateHelp()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Help", "help_system", "Help & Information", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Advanced Space Combat Help",
            Description = "Get help and information"
        })
        
        panel:AddControl("Button", {
            Label = "Show Help",
            Command = "asc_help"
        })
        
        panel:AddControl("Button", {
            Label = "Show System Status",
            Command = "asc_status"
        })
        
        panel:AddControl("Button", {
            Label = "Talk to ARIA AI",
            Command = "say !ai help"
        })
        
        panel:AddControl("Label", {
            Text = "ARIA Chat Commands:"
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

-- Initialize spawn menu organization
hook.Add("Initialize", "ASC_InitializeSpawnMenu", function()
    ASC.SpawnMenu.RegisterEntities()
    ASC.SpawnMenu.RegisterTools()
    ASC.SpawnMenu.CreateTabs()
    ASC.SpawnMenu.CreateQMenuTab()
end)

print("[Advanced Space Combat] Spawn Menu Organization loaded successfully!")
