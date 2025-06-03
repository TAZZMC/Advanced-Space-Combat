-- Advanced Space Combat - Complete Spawn Menu Organization v5.1.0 - ARIA-4 Ultimate Edition
-- Comprehensive spawn menu and tool organization system with ARIA-4 AI integration
-- PHASE 3 ENHANCED - Ship Core Visual Indicators and Sound System Improvements

print("[Advanced Space Combat] Complete Spawn Menu Organization v5.1.0 - ARIA-4 Ultimate Edition - Loading...")

-- Initialize client-side namespace
ASC = ASC or {}
ASC.SpawnMenu = ASC.SpawnMenu or {}

-- Configuration
ASC.SpawnMenu.Config = {
    MainCategory = "Advanced Space Combat",
    CategoryIcon = "icon16/world.png",
    
    -- Entity categories
    EntityCategories = {
        {
            name = "Ship Cores",
            icon = "icon16/cog.png",
            description = "Central ship command and control systems"
        },
        {
            name = "Hyperdrive Engines",
            icon = "icon16/lightning.png",
            description = "Propulsion and hyperdrive systems"
        },
        {
            name = "Weapons",
            icon = "icon16/bomb.png",
            description = "Combat weapons and targeting systems"
        },
        {
            name = "Shields & Defense",
            icon = "icon16/shield.png",
            description = "Defensive systems and CAP shields"
        },
        {
            name = "Flight Systems",
            icon = "icon16/arrow_up.png",
            description = "Navigation and flight control"
        },
        {
            name = "Transport",
            icon = "icon16/car.png",
            description = "Docking and shuttle systems"
        }
    },
    
    -- Tool categories
    ToolCategories = {
        {
            name = "Core Systems",
            icon = "icon16/cog.png",
            description = "Ship cores and basic systems"
        },
        {
            name = "Propulsion",
            icon = "icon16/lightning.png",
            description = "Hyperdrive and engine tools"
        },
        {
            name = "Combat",
            icon = "icon16/bomb.png",
            description = "Weapons and tactical systems"
        },
        {
            name = "Defense",
            icon = "icon16/shield.png",
            description = "Shields and defensive systems"
        },
        {
            name = "Utilities",
            icon = "icon16/wrench.png",
            description = "Configuration and utility tools"
        }
    }
}

-- Entity definitions
ASC.SpawnMenu.Entities = {
    ["Ship Cores"] = {
        {
            class = "ship_core",
            name = "Ship Core",
            description = "Central command and control system with advanced features",
            icon = "entities/ship_core.png",
            model = "models/hunter/blocks/cube025x025x025.mdl"
        }
    },
    
    ["Hyperdrive Engines"] = {
        {
            class = "hyperdrive_master_engine",
            name = "Ultimate Hyperdrive Engine",
            description = "All engine types unified - Master, Heavy, Light, Enhanced, Quantum, Dimensional",
            icon = "entities/hyperdrive_master_engine.png",
            model = "models/props_phx/construct/metal_plate_curve360x2.mdl"
        }
    },
    
    ["Weapons"] = {
        {
            class = "asc_pulse_cannon",
            name = "Pulse Cannon",
            description = "Fast-firing energy weapon",
            icon = "entities/asc_pulse_cannon.png",
            model = "models/props_c17/oildrum001_explosive.mdl" -- Fallback model
        },
        {
            class = "asc_beam_weapon",
            name = "Beam Weapon",
            description = "Continuous beam energy weapon",
            icon = "entities/asc_beam_weapon.png",
            model = "models/props_combine/combine_mine01.mdl" -- Fallback model
        },
        {
            class = "asc_torpedo_launcher",
            name = "Torpedo Launcher",
            description = "Guided projectile weapon system",
            icon = "entities/asc_torpedo_launcher.png",
            model = "models/props_combine/combine_barricade_short01a.mdl" -- Fallback model
        },
        {
            class = "asc_railgun",
            name = "Railgun",
            description = "High-velocity kinetic weapon",
            icon = "entities/asc_railgun.png",
            model = "models/props_combine/combine_barricade_med02a.mdl" -- Fallback model
        },
        {
            class = "asc_plasma_cannon",
            name = "Plasma Cannon",
            description = "Area-effect plasma weapon",
            icon = "entities/asc_plasma_cannon.png",
            model = "models/props_combine/combine_barricade_short02a.mdl" -- Fallback model
        }
    },
    
    ["Shields & Defense"] = {
        {
            class = "asc_shield_generator",
            name = "Shield Generator",
            description = "CAP-integrated bubble shield system",
            icon = "entities/asc_shield_generator.png",
            model = "models/asc/shield_generator.mdl"
        },
        {
            class = "asc_iris_shield",
            name = "Iris Shield",
            description = "Stargate-style iris defense system",
            icon = "entities/asc_iris_shield.png",
            model = "models/asc/iris_shield.mdl"
        }
    },
    
    ["Flight Systems"] = {
        {
            class = "asc_flight_console",
            name = "Flight Console",
            description = "Ship navigation and flight control",
            icon = "entities/asc_flight_console.png",
            model = "models/asc/flight_console.mdl"
        },
        {
            class = "asc_navigation_computer",
            name = "Navigation Computer",
            description = "Advanced navigation and autopilot",
            icon = "entities/asc_navigation_computer.png",
            model = "models/asc/navigation_computer.mdl"
        }
    },
    
    ["Transport"] = {
        {
            class = "asc_docking_pad",
            name = "Docking Pad",
            description = "Ship docking and landing platform",
            icon = "entities/asc_docking_pad.png",
            model = "models/asc/docking_pad.mdl"
        },
        {
            class = "asc_shuttle",
            name = "Shuttle",
            description = "Small transport vessel",
            icon = "entities/asc_shuttle.png",
            model = "models/asc/shuttle.mdl"
        }
    }
}

-- Tool definitions
ASC.SpawnMenu.Tools = {
    {
        class = "asc_ship_core_tool",
        name = "Ship Core Tool",
        description = "Spawn and configure ship cores",
        icon = "gui/silkicons/cog",
        category = "Core Systems"
    },
    {
        class = "asc_hyperdrive_tool",
        name = "Hyperdrive Tool",
        description = "Spawn and configure hyperdrive engines",
        icon = "gui/silkicons/lightning",
        category = "Propulsion"
    },
    {
        class = "asc_weapon_tool",
        name = "Weapon Tool",
        description = "Spawn and configure ship weapons",
        icon = "gui/silkicons/bomb",
        category = "Combat"
    },
    {
        class = "asc_shield_tool",
        name = "Shield Tool",
        description = "Spawn and configure shield systems",
        icon = "gui/silkicons/shield",
        category = "Defense"
    }
}

-- Register entities in spawn menu
function ASC.SpawnMenu.RegisterEntities()
    local registered = 0
    print("[ASC] Starting entity registration...")
    
    -- Register entities by category
    for categoryName, entities in pairs(ASC.SpawnMenu.Entities) do
        print("[ASC] Registering category: " .. categoryName)
        
        for _, entityData in ipairs(entities) do
            -- Check if entity file exists
            if file.Exists("lua/entities/" .. entityData.class .. "/init.lua", "GAME") or
               file.Exists("lua/entities/" .. entityData.class .. ".lua", "GAME") then
                
                -- Add to spawn menu
                list.Set("SpawnableEntities", entityData.class, {
                    PrintName = entityData.name,
                    ClassName = entityData.class,
                    Category = ASC.SpawnMenu.Config.MainCategory .. " - " .. categoryName,
                    KeyValues = {},
                    SpawnFunction = function(ply, tr)
                        if not tr.Hit then return end
                        
                        local ent = ents.Create(entityData.class)
                        if not IsValid(ent) then return end
                        
                        ent:SetPos(tr.HitPos + tr.HitNormal * 50)
                        ent:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
                        ent:Spawn()
                        ent:Activate()
                        
                        if ent.CPPISetOwner then
                            ent:CPPISetOwner(ply)
                        else
                            ent:SetOwner(ply)
                        end
                        
                        return ent
                    end
                })
                
                registered = registered + 1
                print("[ASC] Registered: " .. entityData.name)
            else
                print("[ASC] Skipped " .. entityData.class .. " (file not found)")
            end
        end
    end
    
    print("[ASC] Entity registration complete: " .. registered .. " entities registered")
end

-- Create Q Menu tabs and organization
function ASC.SpawnMenu.CreateQMenuTabs()
    -- Add main Advanced Space Combat tab
    hook.Add("AddToolMenuTabs", "ASC_AddToolMenuTabs", function()
        spawnmenu.AddToolTab("Advanced Space Combat", "Advanced Space Combat", ASC.SpawnMenu.Config.CategoryIcon)
    end)

    -- Add tool menu categories
    hook.Add("AddToolMenuCategories", "ASC_AddToolMenuCategories", function()
        for _, category in ipairs(ASC.SpawnMenu.Config.ToolCategories) do
            spawnmenu.AddToolCategory("Advanced Space Combat", category.name, category.name)
        end

        -- Add additional categories
        spawnmenu.AddToolCategory("Advanced Space Combat", "Configuration", "Configuration")
        spawnmenu.AddToolCategory("Advanced Space Combat", "Help", "Help & Information")
    end)

    -- Populate tool menu
    hook.Add("PopulateToolMenu", "ASC_PopulateToolMenu", function()
        ASC.SpawnMenu.PopulateToolMenus()
    end)
end

-- Populate all tool menus
function ASC.SpawnMenu.PopulateToolMenus()
    -- Core Systems
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Core Systems", "ship_core_tool", "Ship Core Tool", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Ship Core Tool - Spawn and configure ship cores")
        panel:Button("Select Ship Core Tool", "gmod_tool asc_ship_core_tool")
        panel:Help("Ship cores are the central command systems for your vessels.")
    end)

    -- Propulsion
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Propulsion", "hyperdrive_tool", "Hyperdrive Tool", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Hyperdrive Tool - Spawn and configure hyperdrive engines")
        panel:Button("Select Hyperdrive Tool", "gmod_tool asc_hyperdrive_tool")
        panel:Help("Hyperdrive engines provide faster-than-light travel capabilities.")
    end)

    -- Combat
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Combat", "weapon_tool", "Weapon Tool", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Weapon Tool - Spawn and configure ship weapons")
        panel:Button("Select Weapon Tool", "gmod_tool asc_weapon_tool")
        panel:Help("Deploy various weapon systems for ship-to-ship combat.")
    end)

    -- Defense
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Defense", "shield_tool", "Shield Tool", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Shield Tool - Spawn and configure shield systems")
        panel:Button("Select Shield Tool", "gmod_tool asc_shield_tool")
        panel:Help("CAP-integrated shield systems for ship protection.")
    end)

    -- Configuration
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Configuration", "asc_config", "ASC Configuration", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Advanced Space Combat Configuration",
            Description = "Configure addon settings and preferences"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable Auto-linking",
            Command = "asc_enable_auto_linking"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable CAP Integration",
            Command = "asc_enable_cap_integration"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable AI System",
            Command = "asc_enable_ai_system"
        })

        panel:AddControl("Slider", {
            Label = "Default Ship Range",
            Command = "asc_default_ship_range",
            Type = "Integer",
            Min = 500,
            Max = 5000
        })

        -- Phase 2 Enhanced Features
        panel:AddControl("Header", {
            Text = "Ship Core Visual Settings",
            Description = "Configure ship core visual indicators and feedback"
        })

        panel:AddControl("CheckBox", {
            Label = "Show Front Indicators",
            Command = "asc_show_front_indicators"
        })

        panel:AddControl("CheckBox", {
            Label = "Auto-Show Front Arrows",
            Command = "asc_auto_show_arrows"
        })

        panel:AddControl("Slider", {
            Label = "Indicator Distance",
            Command = "asc_indicator_distance",
            Type = "Integer",
            Min = 50,
            Max = 300
        })

        panel:AddControl("Header", {
            Text = "Ship Core Audio Settings",
            Description = "Configure ship core sound system"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable Ship Core Sounds",
            Command = "asc_enable_ship_sounds"
        })

        panel:AddControl("Slider", {
            Label = "Ship Core Volume",
            Command = "asc_ship_core_volume",
            Type = "Float",
            Min = 0.0,
            Max = 1.0
        })

        panel:AddControl("ComboBox", {
            Label = "Default Ship Sound",
            MenuButton = 1,
            Folder = "asc_ship_sounds",
            Options = {
                ["ambient/atmosphere/ambience_base.wav"] = {asc_default_ship_sound = "ambient/atmosphere/ambience_base.wav"},
                ["ambient/atmosphere/tone_quiet.wav"] = {asc_default_ship_sound = "ambient/atmosphere/tone_quiet.wav"},
                ["ambient/water/water_flow_loop1.wav"] = {asc_default_ship_sound = "ambient/water/water_flow_loop1.wav"},
                ["ambient/atmosphere/wind_quiet.wav"] = {asc_default_ship_sound = "ambient/atmosphere/wind_quiet.wav"}
            }
        })

        panel:AddControl("Button", {
            Label = "Reset to Defaults",
            Command = "asc_reset_config"
        })
    end)

    -- Help
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Help", "asc_help", "Help & Information", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Advanced Space Combat Help",
            Description = "Get help and information about the addon"
        })

        panel:Help("ARIA-4 AI Commands:")
        panel:Help("aria help - Get AI assistance")
        panel:Help("aria ship status - Check ship systems")
        panel:Help("aria dial <address> - Dial stargate")
        panel:Help("aria save ship <name> - Save ship design")
        panel:Help("aria load ship <name> - Load ship design")
        panel:Help("Legacy: !ai commands still supported")

        panel:Help("")
        panel:Help("Console Commands:")
        panel:Help("asc_help - Show help system")
        panel:Help("asc_status - System status")
        panel:Help("asc_config - Configuration menu")

        panel:Help("")
        panel:Help("Building Tips:")
        panel:Help("1. Always spawn ship core first")
        panel:Help("2. Keep components within 2000 units")
        panel:Help("3. Use auto-linking for easy setup")
        panel:Help("4. Connect with Wiremod for automation")
    end)
end

-- Initialize spawn menu system
hook.Add("Initialize", "ASC_InitializeSpawnMenu", function()
    ASC.SpawnMenu.RegisterEntities()
    ASC.SpawnMenu.CreateQMenuTabs()
end)

-- Also register on PopulateContent for spawn menu
hook.Add("PopulateContent", "ASC_PopulateContent", function(pnlContent, tree, node)
    if node then return end -- Only populate root
    ASC.SpawnMenu.RegisterEntities()
end)

print("[Advanced Space Combat] Complete Spawn Menu Organization v5.1.0 - ARIA-4 Ultimate Edition - Phase 3 Enhanced - Loaded!")
