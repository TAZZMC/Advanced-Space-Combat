-- Enhanced Hyperdrive System - Spawn Menu Integration v2.2.1
-- Spawn menu entity registration and organization

if not CLIENT then return end

print("[Hyperdrive] Loading Spawn Menu Integration v2.2.1...")

-- Initialize spawn menu system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.SpawnMenu = HYPERDRIVE.SpawnMenu or {}

-- Spawn menu configuration
HYPERDRIVE.SpawnMenu.Config = {
    MainCategory = "Enhanced Hyperdrive",
    EnableSpawnMenu = true,
    AutoRegister = true
}

-- Entity definitions for spawn menu
HYPERDRIVE.SpawnMenu.Entities = {
    ["Ship Cores"] = {
        {
            class = "ship_core",
            name = "Ship Core",
            description = "Central ship command and control system",
            icon = "entities/ship_core.png"
        },
        {
            class = "hyperdrive_computer",
            name = "Hyperdrive Computer",
            description = "Advanced navigation and control computer",
            icon = "entities/hyperdrive_computer.png"
        }
    },
    
    ["Engines"] = {
        {
            class = "hyperdrive_engine",
            name = "Hyperdrive Engine",
            description = "Standard faster-than-light propulsion system",
            icon = "entities/hyperdrive_engine.png"
        },
        {
            class = "hyperdrive_master_engine",
            name = "Master Engine",
            description = "Advanced hyperdrive with enhanced capabilities",
            icon = "entities/hyperdrive_master_engine.png"
        }
    },
    
    ["Weapons"] = {
        {
            class = "asc_pulse_cannon",
            name = "Pulse Cannon",
            description = "Fast-firing energy weapon system",
            icon = "entities/asc_pulse_cannon.png"
        },
        {
            class = "asc_plasma_cannon",
            name = "Plasma Cannon",
            description = "High-damage area effect weapon",
            icon = "entities/asc_plasma_cannon.png"
        },
        {
            class = "asc_railgun",
            name = "Railgun",
            description = "Long-range kinetic projectile weapon",
            icon = "entities/asc_railgun.png"
        },
        {
            class = "hyperdrive_beam_weapon",
            name = "Beam Weapon",
            description = "Continuous energy beam weapon",
            icon = "entities/hyperdrive_beam_weapon.png"
        },
        {
            class = "hyperdrive_torpedo_launcher",
            name = "Torpedo Launcher",
            description = "Guided missile launcher system",
            icon = "entities/hyperdrive_torpedo_launcher.png"
        }
    },
    
    ["Shields"] = {
        {
            class = "asc_shield_generator",
            name = "Shield Generator",
            description = "CAP-integrated bubble shield system",
            icon = "entities/asc_shield_generator.png"
        },
        {
            class = "hyperdrive_shield_generator",
            name = "Hyperdrive Shield",
            description = "Basic energy shield generator",
            icon = "entities/hyperdrive_shield_generator.png"
        }
    },
    
    ["Transport"] = {
        {
            class = "hyperdrive_docking_pad",
            name = "Docking Pad",
            description = "Ship docking and landing platform",
            icon = "entities/hyperdrive_docking_pad.png"
        },
        {
            class = "hyperdrive_docking_bay",
            name = "Docking Bay",
            description = "Large ship hangar and maintenance bay",
            icon = "entities/hyperdrive_docking_bay.png"
        },
        {
            class = "hyperdrive_shuttle",
            name = "Shuttle",
            description = "Small transport and utility craft",
            icon = "entities/hyperdrive_shuttle.png"
        },
        {
            class = "hyperdrive_flight_console",
            name = "Flight Console",
            description = "Pilot control and navigation interface",
            icon = "entities/hyperdrive_flight_console.png"
        }
    },
    
    ["Utilities"] = {
        {
            class = "hyperdrive_beacon",
            name = "Navigation Beacon",
            description = "Hyperspace navigation and communication beacon",
            icon = "entities/hyperdrive_beacon.png"
        },
        {
            class = "asc_ancient_zpm",
            name = "Ancient ZPM",
            description = "Zero Point Module power source",
            icon = "entities/asc_ancient_zpm.png"
        },
        {
            class = "asc_ancient_drone",
            name = "Ancient Drone",
            description = "Automated defense and patrol drone",
            icon = "entities/asc_ancient_drone.png"
        },
        {
            class = "hyperdrive_wire_controller",
            name = "Wire Controller",
            description = "Wiremod integration and control interface",
            icon = "entities/hyperdrive_wire_controller.png"
        }
    }
}

-- Register entities in spawn menu
function HYPERDRIVE.SpawnMenu.RegisterEntities()
    if not HYPERDRIVE.SpawnMenu.Config.EnableSpawnMenu then return end
    
    local registered = 0
    print("[Hyperdrive] Registering entities in spawn menu...")
    
    for categoryName, entities in pairs(HYPERDRIVE.SpawnMenu.Entities) do
        print("[Hyperdrive] Registering category: " .. categoryName)
        
        for _, entityData in ipairs(entities) do
            -- Check if entity file exists
            if file.Exists("lua/entities/" .. entityData.class .. "/init.lua", "GAME") or
               file.Exists("lua/entities/" .. entityData.class .. ".lua", "GAME") then
                
                -- Register in spawn menu
                list.Set("SpawnableEntities", entityData.class, {
                    PrintName = entityData.name,
                    ClassName = entityData.class,
                    Category = HYPERDRIVE.SpawnMenu.Config.MainCategory .. " - " .. categoryName,
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
                print("[Hyperdrive] Registered: " .. entityData.name)
            else
                print("[Hyperdrive] Skipped " .. entityData.class .. " (file not found)")
            end
        end
    end
    
    print("[Hyperdrive] Spawn menu registration complete: " .. registered .. " entities registered")
end

-- Auto-register entities when spawn menu is populated
hook.Add("PopulateContent", "HyperdrivePopulateContent", function(pnlContent, tree, node)
    if HYPERDRIVE.SpawnMenu.Config.AutoRegister then
        HYPERDRIVE.SpawnMenu.RegisterEntities()
    end
end)

-- Manual registration function
function HYPERDRIVE.SpawnMenu.ForceRegister()
    HYPERDRIVE.SpawnMenu.RegisterEntities()
end

-- Console command to manually register entities
concommand.Add("hyperdrive_register_entities", function()
    HYPERDRIVE.SpawnMenu.ForceRegister()
    chat.AddText(Color(100, 200, 255), "[Hyperdrive] ", Color(255, 255, 255), "Entities registered in spawn menu")
end)

-- Console command to toggle spawn menu integration
concommand.Add("hyperdrive_spawn_menu_toggle", function()
    HYPERDRIVE.SpawnMenu.Config.EnableSpawnMenu = not HYPERDRIVE.SpawnMenu.Config.EnableSpawnMenu
    local status = HYPERDRIVE.SpawnMenu.Config.EnableSpawnMenu and "enabled" or "disabled"
    chat.AddText(Color(100, 200, 255), "[Hyperdrive] ", Color(255, 255, 255), "Spawn menu integration " .. status)
end)

-- Initialize spawn menu integration
timer.Simple(1, function()
    if HYPERDRIVE.SpawnMenu.Config.AutoRegister then
        HYPERDRIVE.SpawnMenu.RegisterEntities()
    end
end)

print("[Hyperdrive] Spawn Menu Integration v2.2.1 loaded successfully!")
