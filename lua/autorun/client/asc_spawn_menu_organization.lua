-- Advanced Space Combat - Spawn Menu Organization v3.0.0
-- Complete spawn menu and entity organization system

print("[Advanced Space Combat] Spawn Menu Organization v3.0.0 - Loading...")

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
            name = "Weapons - Energy",
            icon = "icon16/lightning.png", 
            description = "Energy-based weapon systems"
        },
        {
            name = "Weapons - Kinetic",
            icon = "icon16/bomb.png",
            description = "Kinetic and projectile weapons"
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
            name = "Ancient Technology",
            icon = "icon16/star.png",
            description = "Ancient Stargate technology"
        },
        {
            name = "Asgard Technology",
            icon = "icon16/wand.png",
            description = "Asgard advanced systems"
        },
        {
            name = "Goa'uld Technology",
            icon = "icon16/ruby.png",
            description = "Goa'uld technology and weapons"
        }
    }
}

-- Entity organization data
ASC.SpawnMenu.Entities = {
    ["Ship Components"] = {
        {
            class = "ship_core",
            name = "Ship Core",
            description = "Central ship management and control system",
            icon = "entities/ship_core.png",
            category = "Ship Components"
        },
        {
            class = "hyperdrive_engine",
            name = "Hyperdrive Engine",
            description = "Standard FTL propulsion system",
            icon = "entities/hyperdrive_engine.png",
            category = "Ship Components"
        },
        {
            class = "hyperdrive_master_engine",
            name = "Master Hyperdrive Engine",
            description = "Advanced FTL propulsion with enhanced capabilities",
            icon = "entities/hyperdrive_master_engine.png",
            category = "Ship Components"
        },
        {
            class = "hyperdrive_computer",
            name = "Hyperdrive Computer",
            description = "Navigation and jump calculation system",
            icon = "entities/hyperdrive_computer.png",
            category = "Ship Components"
        }
    },
    
    ["Weapons - Energy"] = {
        {
            class = "asc_pulse_cannon",
            name = "Pulse Cannon",
            description = "Fast-firing energy weapon system",
            icon = "entities/asc_pulse_cannon.png",
            category = "Weapons - Energy"
        },
        {
            class = "asc_beam_weapon",
            name = "Beam Weapon",
            description = "Continuous energy beam weapon",
            icon = "entities/asc_beam_weapon.png",
            category = "Weapons - Energy"
        },
        {
            class = "asc_plasma_cannon",
            name = "Plasma Cannon",
            description = "Area-effect plasma weapon system",
            icon = "entities/asc_plasma_cannon.png",
            category = "Weapons - Energy"
        }
    },
    
    ["Weapons - Kinetic"] = {
        {
            class = "asc_torpedo_launcher",
            name = "Torpedo Launcher",
            description = "Guided missile weapon system",
            icon = "entities/asc_torpedo_launcher.png",
            category = "Weapons - Kinetic"
        },
        {
            class = "asc_railgun",
            name = "Railgun",
            description = "High-velocity kinetic weapon",
            icon = "entities/asc_railgun.png",
            category = "Weapons - Kinetic"
        }
    },
    
    ["Flight Systems"] = {
        {
            class = "asc_flight_console",
            name = "Flight Console",
            description = "Ship control and navigation interface",
            icon = "entities/asc_flight_console.png",
            category = "Flight Systems"
        }
    },
    
    ["Transport"] = {
        {
            class = "asc_docking_pad",
            name = "Docking Pad",
            description = "Landing and docking system",
            icon = "entities/asc_docking_pad.png",
            category = "Transport"
        },
        {
            class = "asc_shuttle",
            name = "Shuttle",
            description = "Small transport vessel",
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
    },
    
    ["Ancient Technology"] = {
        {
            class = "asc_ancient_zpm",
            name = "Ancient ZPM",
            description = "Zero Point Module power source",
            icon = "entities/asc_ancient_zpm.png",
            category = "Ancient Technology"
        },
        {
            class = "asc_ancient_drone",
            name = "Ancient Drone Weapon",
            description = "Automated defense drone",
            icon = "entities/asc_ancient_drone.png",
            category = "Ancient Technology"
        },
        {
            class = "asc_ancient_satellite",
            name = "Ancient Satellite",
            description = "Orbital defense platform",
            icon = "entities/asc_ancient_satellite.png",
            category = "Ancient Technology"
        }
    },
    
    ["Asgard Technology"] = {
        {
            class = "asc_asgard_ion_cannon",
            name = "Asgard Ion Cannon",
            description = "Advanced ion beam weapon",
            icon = "entities/asc_asgard_ion_cannon.png",
            category = "Asgard Technology"
        },
        {
            class = "asc_asgard_plasma_beam",
            name = "Asgard Plasma Beam",
            description = "High-energy plasma weapon",
            icon = "entities/asc_asgard_plasma_beam.png",
            category = "Asgard Technology"
        }
    },
    
    ["Goa'uld Technology"] = {
        {
            class = "asc_goauld_staff_cannon",
            name = "Goa'uld Staff Cannon",
            description = "Ship-mounted staff weapon",
            icon = "entities/asc_goauld_staff_cannon.png",
            category = "Goa'uld Technology"
        },
        {
            class = "asc_goauld_ribbon_device",
            name = "Goa'uld Ribbon Device",
            description = "Hand device weapon system",
            icon = "entities/asc_goauld_ribbon_device.png",
            category = "Goa'uld Technology"
        }
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
            if file.Exists("lua/entities/" .. entityData.class .. "/init.lua", "LUA") or
               file.Exists("lua/entities/" .. entityData.class .. ".lua", "LUA") then

                -- Register entity in spawn menu
                list.Set("SpawnableEntities", entityData.class, {
                    PrintName = entityData.name,
                    ClassName = entityData.class,
                    Category = ASC.SpawnMenu.Config.MainCategory .. " - " .. categoryName,
                    KeyValues = {},
                    SpawnFunction = function(ply, tr)
                        if not tr.Hit then return end

                        local ent = ents.Create(entityData.class)
                        if not IsValid(ent) then return end

                        ent:SetPos(tr.HitPos + tr.HitNormal * 10)
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
            Text = "Ship Core Management",
            Description = "Central ship management and control"
        })

        panel:AddControl("Button", {
            Label = "Spawn Ship Core",
            Command = "asc_spawn_entity ship_core"
        })

        panel:AddControl("TextBox", {
            Label = "Default Ship Name",
            Command = "asc_default_ship_name",
            Text = "New Ship"
        })

        panel:AddControl("CheckBox", {
            Label = "Auto-Link Components",
            Command = "asc_auto_link"
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
            Command = "asc_spawn_entity hyperdrive_engine"
        })

        panel:AddControl("Button", {
            Label = "Spawn Master Engine",
            Command = "asc_spawn_entity hyperdrive_master_engine"
        })

        panel:AddControl("Button", {
            Label = "Spawn Hyperdrive Computer",
            Command = "asc_spawn_entity hyperdrive_computer"
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
                Command = "asc_spawn_entity " .. weapon[2]
            })
        end

        panel:AddControl("CheckBox", {
            Label = "Auto-Link to Ship Core",
            Command = "asc_auto_link_weapons"
        })
    end)

    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Combat", "shield_spawner", "Shield Spawner", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Shield Systems",
            Description = "Defensive shield generators"
        })

        panel:AddControl("Button", {
            Label = "Spawn Shield Generator",
            Command = "asc_spawn_entity asc_shield_generator"
        })

        panel:AddControl("CheckBox", {
            Label = "CAP Integration",
            Command = "asc_cap_shields"
        })
    end)
end

-- Populate Flight Systems tab
function ASC.SpawnMenu.PopulateFlightSystems()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Flight", "flight_systems", "Flight Systems", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Ship Flight Systems",
            Description = "Configure flight control and movement"
        })

        panel:AddControl("Button", {
            Label = "Spawn Flight Console",
            Command = "asc_spawn_entity asc_flight_console"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable Flight Systems",
            Command = "asc_enable_flight"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable Autopilot",
            Command = "asc_enable_autopilot"
        })
    end)
end

-- Populate Transport Systems tab
function ASC.SpawnMenu.PopulateTransportSystems()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Transport", "docking_systems", "Docking Systems", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Docking & Landing Systems",
            Description = "Configure docking pads and landing operations"
        })

        panel:AddControl("Button", {
            Label = "Spawn Docking Pad",
            Command = "asc_spawn_entity asc_docking_pad"
        })

        panel:AddControl("Button", {
            Label = "Spawn Shuttle",
            Command = "asc_spawn_entity asc_shuttle"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable Docking Systems",
            Command = "asc_enable_docking"
        })
    end)
end

-- Populate Configuration tab
function ASC.SpawnMenu.PopulateConfiguration()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Configuration", "general_config", "General Configuration", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "Advanced Space Combat Configuration",
            Description = "General addon settings and preferences"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable Debug Mode",
            Command = "asc_debug_mode"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable CAP Integration",
            Command = "asc_enable_cap"
        })

        panel:AddControl("CheckBox", {
            Label = "Enable Spacebuild Integration",
            Command = "asc_enable_spacebuild"
        })

        panel:AddControl("Button", {
            Label = "Reset All Settings",
            Command = "asc_reset_config"
        })
    end)
end

-- Populate Help tab
function ASC.SpawnMenu.PopulateHelp()
    spawnmenu.AddToolMenuOption("Advanced Space Combat", "Help", "ai_help", "ARIA-3 AI Assistant", "", "", function(panel)
        panel:ClearControls()

        panel:AddControl("Header", {
            Text = "ARIA-3 AI Assistant",
            Description = "Advanced AI help system for space combat"
        })

        panel:AddControl("Label", {
            Text = "Ask the AI anything about Advanced Space Combat!"
        })

        panel:AddControl("Label", {
            Text = "!ai help - Show all available commands"
        })

        panel:AddControl("Label", {
            Text = "!ai ship building - Learn ship construction"
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
    ASC.SpawnMenu.CreateTabs()
    ASC.SpawnMenu.CreateQMenuTab()
end)

-- Also register on PopulateContent for spawn menu
hook.Add("PopulateContent", "ASC_PopulateContent", function(pnlContent, tree, node)
    if node then return end -- Only populate root
    ASC.SpawnMenu.RegisterEntities()
end)

print("[Advanced Space Combat] Spawn Menu Organization v3.0.0 - Loaded successfully!")
