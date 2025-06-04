-- Advanced Space Combat - Menu Organization v3.1.0
-- Complete spawn menu and tool menu organization

print("[Advanced Space Combat] Menu Organization v3.1.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.MenuOrganization = ASC.MenuOrganization or {}

-- Configuration
ASC.MenuOrganization.Config = {
    MainCategory = "Advanced Space Combat",
    CategoryIcon = "icon16/world.png",
    
    -- Tool categories
    ToolCategories = {
        {name = "Core Tools", icon = "icon16/cog.png"},
        {name = "Ship Building", icon = "icon16/brick.png"},
        {name = "Weapons", icon = "icon16/bomb.png"},
        {name = "Defense", icon = "icon16/shield.png"},
        {name = "Transport", icon = "icon16/car.png"},
        {name = "Configuration", icon = "icon16/wrench.png"},
        {name = "Help", icon = "icon16/help.png"}
    },
    
    -- Entity categories for spawn menu
    EntityCategories = {
        {name = "Ship Cores", icon = "icon16/cog.png"},
        {name = "Engines", icon = "icon16/lightning.png"},
        {name = "Weapons", icon = "icon16/bomb.png"},
        {name = "Shields", icon = "icon16/shield.png"},
        {name = "Transport", icon = "icon16/car.png"},
        {name = "Utilities", icon = "icon16/wrench.png"}
    }
}

-- Entity definitions for spawn menu
ASC.MenuOrganization.Entities = {
    ["Ship Cores"] = {
        {
            class = "ship_core",
            name = "Ship Core",
            description = "Central ship command and control system",
            icon = "entities/ship_core.png",
            category = "Ship Cores"
        },
        {
            class = "hyperdrive_computer",
            name = "Hyperdrive Computer",
            description = "Advanced navigation and control computer",
            icon = "entities/hyperdrive_computer.png",
            category = "Ship Cores"
        }
    },
    
    ["Engines"] = {
        {
            class = "hyperdrive_engine",
            name = "Hyperdrive Engine",
            description = "Standard faster-than-light propulsion system",
            icon = "entities/hyperdrive_engine.png",
            category = "Engines"
        },
        {
            class = "hyperdrive_master_engine",
            name = "Master Engine",
            description = "Advanced hyperdrive with enhanced capabilities",
            icon = "entities/hyperdrive_master_engine.png",
            category = "Engines"
        }
    },
    
    ["Weapons"] = {
        {
            class = "asc_pulse_cannon",
            name = "Pulse Cannon",
            description = "Fast-firing energy weapon system",
            icon = "entities/asc_pulse_cannon.png",
            category = "Weapons"
        },
        {
            class = "asc_plasma_cannon",
            name = "Plasma Cannon",
            description = "High-damage area effect weapon",
            icon = "entities/asc_plasma_cannon.png",
            category = "Weapons"
        },
        {
            class = "asc_railgun",
            name = "Railgun",
            description = "Long-range kinetic projectile weapon",
            icon = "entities/asc_railgun.png",
            category = "Weapons"
        },
        {
            class = "hyperdrive_beam_weapon",
            name = "Beam Weapon",
            description = "Continuous energy beam weapon",
            icon = "entities/hyperdrive_beam_weapon.png",
            category = "Weapons"
        },
        {
            class = "hyperdrive_torpedo_launcher",
            name = "Torpedo Launcher",
            description = "Guided missile launcher system",
            icon = "entities/hyperdrive_torpedo_launcher.png",
            category = "Weapons"
        }
    },
    
    ["Shields"] = {
        {
            class = "asc_shield_generator",
            name = "Shield Generator",
            description = "CAP-integrated bubble shield system",
            icon = "entities/asc_shield_generator.png",
            category = "Shields"
        },
        {
            class = "hyperdrive_shield_generator",
            name = "Hyperdrive Shield",
            description = "Basic energy shield generator",
            icon = "entities/hyperdrive_shield_generator.png",
            category = "Shields"
        }
    },
    
    ["Transport"] = {
        {
            class = "hyperdrive_docking_pad",
            name = "Docking Pad",
            description = "Ship docking and landing platform",
            icon = "entities/hyperdrive_docking_pad.png",
            category = "Transport"
        },
        {
            class = "hyperdrive_docking_bay",
            name = "Docking Bay",
            description = "Large ship hangar and maintenance bay",
            icon = "entities/hyperdrive_docking_bay.png",
            category = "Transport"
        },
        {
            class = "hyperdrive_shuttle",
            name = "Shuttle",
            description = "Small transport and utility craft",
            icon = "entities/hyperdrive_shuttle.png",
            category = "Transport"
        },
        {
            class = "hyperdrive_flight_console",
            name = "Flight Console",
            description = "Pilot control and navigation interface",
            icon = "entities/hyperdrive_flight_console.png",
            category = "Transport"
        }
    },
    
    ["Utilities"] = {
        {
            class = "hyperdrive_beacon",
            name = "Navigation Beacon",
            description = "Hyperspace navigation and communication beacon",
            icon = "entities/hyperdrive_beacon.png",
            category = "Utilities"
        },
        {
            class = "asc_ancient_zpm",
            name = "Ancient ZPM",
            description = "Zero Point Module power source",
            icon = "entities/asc_ancient_zpm.png",
            category = "Utilities"
        },
        {
            class = "asc_ancient_drone",
            name = "Ancient Drone",
            description = "Automated defense and patrol drone",
            icon = "entities/asc_ancient_drone.png",
            category = "Utilities"
        },
        {
            class = "hyperdrive_wire_controller",
            name = "Wire Controller",
            description = "Wiremod integration and control interface",
            icon = "entities/hyperdrive_wire_controller.png",
            category = "Utilities"
        }
    }
}

-- Tool definitions
ASC.MenuOrganization.Tools = {
    {
        class = "asc_main_tool",
        name = "ASC Main Tool",
        description = "Primary entity spawning and configuration tool",
        icon = "gui/silkicons/wrench",
        category = "Core Tools"
    },
    {
        class = "asc_ship_builder",
        name = "Ship Builder",
        description = "Advanced ship construction and template system",
        icon = "gui/silkicons/brick",
        category = "Ship Building"
    },
    {
        class = "asc_weapon_config",
        name = "Weapon Config",
        description = "Weapon configuration and targeting tool",
        icon = "gui/silkicons/bomb",
        category = "Weapons"
    }
}

-- Register entities in spawn menu
function ASC.MenuOrganization.RegisterEntities()
    local registered = 0
    print("[ASC] Starting entity registration...")

    -- Register entities by category
    for categoryName, entities in pairs(ASC.MenuOrganization.Entities) do
        print("[ASC] Registering category: " .. categoryName)
        
        for _, entityData in ipairs(entities) do
            -- Check if entity file exists
            if file.Exists("lua/entities/" .. entityData.class .. "/init.lua", "GAME") or
               file.Exists("lua/entities/" .. entityData.class .. ".lua", "GAME") then
                
                -- Register in spawn menu
                list.Set("SpawnableEntities", entityData.class, {
                    PrintName = entityData.name,
                    ClassName = entityData.class,
                    Category = ASC.MenuOrganization.Config.MainCategory .. " - " .. categoryName,
                    KeyValues = {},
                    SpawnFunction = function(ply, tr, class)
                        if not tr.Hit then return end
                        
                        local ent = ents.Create(class)
                        if not IsValid(ent) then return end
                        
                        ent:SetPos(tr.HitPos + tr.HitNormal * 10)
                        ent:SetAngles(ply:EyeAngles())
                        ent:Spawn()
                        ent:Activate()
                        
                        -- Set ownership
                        if ent.CPPISetOwner then
                            ent:CPPISetOwner(ply)
                        elseif ent.SetOwner then
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

-- Create Q menu tabs and categories
function ASC.MenuOrganization.CreateQMenuTabs()
    -- Add main tab
    hook.Add("AddToolMenuTabs", "ASC_AddToolMenuTabs", function()
        spawnmenu.AddToolTab(ASC.MenuOrganization.Config.MainCategory, ASC.MenuOrganization.Config.MainCategory, ASC.MenuOrganization.Config.CategoryIcon)
    end)
    
    -- Add categories
    hook.Add("AddToolMenuCategories", "ASC_AddToolMenuCategories", function()
        for _, category in ipairs(ASC.MenuOrganization.Config.ToolCategories) do
            spawnmenu.AddToolCategory(ASC.MenuOrganization.Config.MainCategory, category.name, category.name)
        end
    end)
    
    -- Populate tool menu
    hook.Add("PopulateToolMenu", "ASC_PopulateToolMenu", function()
        ASC.MenuOrganization.PopulateToolMenus()
    end)
end

-- Populate all tool menus
function ASC.MenuOrganization.PopulateToolMenus()
    ASC.MenuOrganization.PopulateCoreTools()
    ASC.MenuOrganization.PopulateShipBuilding()
    ASC.MenuOrganization.PopulateWeapons()
    ASC.MenuOrganization.PopulateDefense()
    ASC.MenuOrganization.PopulateTransport()
    ASC.MenuOrganization.PopulateConfiguration()
    ASC.MenuOrganization.PopulateHelp()
end

-- Populate Core Tools menu
function ASC.MenuOrganization.PopulateCoreTools()
    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Core Tools", "asc_main_tool", "ASC Main Tool", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Primary entity spawning and configuration tool")
        panel:Help("Use this tool to spawn ship cores, engines, weapons, and other components")
        panel:Button("Select ASC Main Tool", "gmod_tool asc_main_tool")
    end)
    
    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Core Tools", "entity_spawner", "Entity Spawner", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Quick Entity Spawning",
            Description = "Spawn common entities quickly"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Ship Core",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type ship_core"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Enhanced Master Engine",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type hyperdrive_master_engine"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Pulse Cannon",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type asc_pulse_cannon"
        })
    end)
end

-- Populate Ship Building menu
function ASC.MenuOrganization.PopulateShipBuilding()
    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Ship Building", "asc_ship_builder", "Ship Builder Tool", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Advanced ship construction and template system")
        panel:Help("Build complete ships using templates or custom designs")
        panel:Button("Select Ship Builder", "gmod_tool asc_ship_builder")
    end)

    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Ship Building", "ship_templates", "Ship Templates", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Ship Templates",
            Description = "Pre-designed ship configurations"
        })

        panel:AddControl("Button", {
            Label = "Build Fighter",
            Command = "gmod_tool asc_ship_builder; asc_ship_builder_template_name Fighter; asc_ship_builder_build_mode template"
        })

        panel:AddControl("Button", {
            Label = "Build Cruiser",
            Command = "gmod_tool asc_ship_builder; asc_ship_builder_template_name Cruiser; asc_ship_builder_build_mode template"
        })

        panel:AddControl("Button", {
            Label = "Build Carrier",
            Command = "gmod_tool asc_ship_builder; asc_ship_builder_template_name Carrier; asc_ship_builder_build_mode template"
        })
    end)
end

-- Populate Weapons menu
function ASC.MenuOrganization.PopulateWeapons()
    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Weapons", "asc_weapon_config", "Weapon Config Tool", "", "", function(panel)
        panel:ClearControls()
        panel:Help("Configure and control space combat weapons")
        panel:Help("Set targeting, fire rates, and weapon modes")
        panel:Button("Select Weapon Config", "gmod_tool asc_weapon_config")
    end)

    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Weapons", "weapon_spawner", "Weapon Spawner", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Weapon Systems",
            Description = "Spawn and configure combat weapons"
        })

        local weaponTypes = {
            {"Pulse Cannon", "asc_pulse_cannon"},
            {"Plasma Cannon", "asc_plasma_cannon"},
            {"Railgun", "asc_railgun"},
            {"Beam Weapon", "hyperdrive_beam_weapon"},
            {"Torpedo Launcher", "hyperdrive_torpedo_launcher"}
        }

        for _, weapon in ipairs(weaponTypes) do
            panel:AddControl("Button", {
                Label = "Spawn " .. weapon[1],
                Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type " .. weapon[2]
            })
        end
    end)
end

-- Populate Defense menu
function ASC.MenuOrganization.PopulateDefense()
    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Defense", "shield_systems", "Shield Systems", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Defensive Systems",
            Description = "Shield generators and defensive equipment"
        })

        panel:AddControl("Button", {
            Label = "Spawn CAP Shield Generator",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type asc_shield_generator"
        })

        panel:AddControl("Button", {
            Label = "Spawn Hyperdrive Shield",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type hyperdrive_shield_generator"
        })

        panel:AddControl("CheckBox", {
            Label = "Auto-activate Shields",
            Command = "asc_auto_shields"
        })
    end)
end

-- Populate Transport menu
function ASC.MenuOrganization.PopulateTransport()
    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Transport", "docking_systems", "Docking Systems", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Transport & Docking",
            Description = "Docking pads, bays, and transport systems"
        })

        panel:AddControl("Button", {
            Label = "Spawn Docking Pad",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type hyperdrive_docking_pad"
        })

        panel:AddControl("Button", {
            Label = "Spawn Docking Bay",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type hyperdrive_docking_bay"
        })

        panel:AddControl("Button", {
            Label = "Spawn Shuttle",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type hyperdrive_shuttle"
        })

        panel:AddControl("Button", {
            Label = "Spawn Flight Console",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type hyperdrive_flight_console"
        })
    end)
end

-- Populate Configuration menu
function ASC.MenuOrganization.PopulateConfiguration()
    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Configuration", "asc_settings", "ASC Settings", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Advanced Space Combat Settings",
            Description = "Configure addon behavior and features"
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
            Label = "Enable Wiremod Support",
            Command = "asc_enable_wiremod"
        })

        panel:AddControl("Slider", {
            Label = "Max Ship Components",
            Type = "Integer",
            Min = "10",
            Max = "200",
            Command = "asc_max_ship_components"
        })

        panel:AddControl("Button", {
            Label = "Reset All Settings",
            Command = "asc_reset_settings"
        })
    end)
end

-- Populate Help menu
function ASC.MenuOrganization.PopulateHelp()
    spawnmenu.AddToolMenuOption(ASC.MenuOrganization.Config.MainCategory, "Help", "asc_help", "Help & Information", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Advanced Space Combat Help",
            Description = "Get help and information about the addon"
        })

        panel:AddControl("Label", {
            Text = "AI Assistant Commands:"
        })

        panel:AddControl("Label", {
            Text = "!ai help - Get AI assistance"
        })

        panel:AddControl("Label", {
            Text = "!ai ship building - Ship construction guide"
        })

        panel:AddControl("Label", {
            Text = "!ai weapons - Weapon system help"
        })

        panel:AddControl("Label", {
            Text = "!ai cap info - CAP integration status"
        })

        panel:AddControl("Button", {
            Label = "Open Documentation",
            Command = "asc_open_docs"
        })

        panel:AddControl("Button", {
            Label = "Check System Status",
            Command = "asc_system_status"
        })
    end)
end

-- Initialize menu organization
hook.Add("Initialize", "ASC_InitializeMenus", function()
    ASC.MenuOrganization.RegisterEntities()
    ASC.MenuOrganization.CreateQMenuTabs()
end)

-- Also register on PopulateContent for spawn menu
hook.Add("PopulateContent", "ASC_PopulateContent", function(pnlContent, tree, node)
    if node then return end -- Only populate root
    ASC.MenuOrganization.RegisterEntities()
end)

print("[Advanced Space Combat] Menu Organization v3.1.0 - Loaded successfully!")
