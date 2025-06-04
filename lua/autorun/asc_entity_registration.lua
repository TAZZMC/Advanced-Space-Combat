-- Advanced Space Combat - Entity Registration System
-- Ensures all entities are properly registered in spawn menu

print("[Advanced Space Combat] Entity Registration System - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.EntityRegistration = ASC.EntityRegistration or {}

-- Entity definitions for registration
ASC.EntityRegistration.Entities = {
    -- Core Systems
    {
        class = "ship_core",
        name = "Ship Core",
        category = "Advanced Space Combat - Core Systems",
        description = "Central ship management and control system",
        spawnable = true
    },

    {
        class = "hyperdrive_master_engine",
        name = "Master Hyperdrive Engine",
        category = "Advanced Space Combat - Core Systems",
        description = "Advanced FTL propulsion with enhanced capabilities",
        spawnable = true
    },
    {
        class = "hyperdrive_computer",
        name = "Navigation Computer",
        category = "Advanced Space Combat - Core Systems",
        description = "Ship navigation and control computer",
        spawnable = true
    },
    {
        class = "hyperdrive_beacon",
        name = "Navigation Beacon",
        category = "Advanced Space Combat - Core Systems",
        description = "Hyperspace navigation beacon",
        spawnable = true
    },
    
    -- Weapon Systems
    {
        class = "hyperdrive_pulse_cannon",
        name = "Pulse Cannon",
        category = "Advanced Space Combat - Weapons",
        description = "Rapid-fire energy weapon",
        spawnable = true
    },
    {
        class = "hyperdrive_beam_weapon",
        name = "Beam Weapon",
        category = "Advanced Space Combat - Weapons",
        description = "Continuous energy beam weapon",
        spawnable = true
    },
    {
        class = "hyperdrive_torpedo_launcher",
        name = "Torpedo Launcher",
        category = "Advanced Space Combat - Weapons",
        description = "Guided missile launcher system",
        spawnable = true
    },
    {
        class = "hyperdrive_railgun",
        name = "Railgun",
        category = "Advanced Space Combat - Weapons",
        description = "Electromagnetic kinetic weapon",
        spawnable = true
    },
    {
        class = "hyperdrive_plasma_cannon",
        name = "Plasma Cannon",
        category = "Advanced Space Combat - Weapons",
        description = "High-energy plasma weapon",
        spawnable = true
    },
    {
        class = "hyperdrive_shield_generator",
        name = "Shield Generator",
        category = "Advanced Space Combat - Defense",
        description = "Energy barrier defense system",
        spawnable = true
    },
    
    -- Flight Systems
    {
        class = "hyperdrive_flight_console",
        name = "Flight Console",
        category = "Advanced Space Combat - Flight",
        description = "Ship movement and navigation control",
        spawnable = true
    },
    {
        class = "hyperdrive_wire_controller",
        name = "Wiremod Controller",
        category = "Advanced Space Combat - Flight",
        description = "Wiremod integration and control interface",
        spawnable = true
    },
    
    -- Transport Systems
    {
        class = "hyperdrive_docking_pad",
        name = "Docking Pad",
        category = "Advanced Space Combat - Transport",
        description = "Ship landing and service facility",
        spawnable = true
    },
    {
        class = "hyperdrive_docking_bay",
        name = "Docking Bay",
        category = "Advanced Space Combat - Transport",
        description = "Large ship docking facility",
        spawnable = true
    },
    {
        class = "hyperdrive_shuttle",
        name = "Transport Shuttle",
        category = "Advanced Space Combat - Transport",
        description = "Automated passenger and cargo transport",
        spawnable = true
    },
    
    -- Ancient Technology
    {
        class = "asc_ancient_zpm",
        name = "Zero Point Module (ZPM)",
        category = "Advanced Space Combat - Ancient",
        description = "Ancient zero-point energy source",
        spawnable = true
    },
    {
        class = "asc_ancient_drone",
        name = "Ancient Drone",
        category = "Advanced Space Combat - Ancient",
        description = "Autonomous Ancient defense drone",
        spawnable = true
    }
}

-- Registration function
ASC.EntityRegistration.RegisterAll = function()
    local registered = 0
    local skipped = 0
    
    for _, entityData in ipairs(ASC.EntityRegistration.Entities) do
        if entityData.spawnable then
            -- Check if entity file exists
            local entityExists = file.Exists("lua/entities/" .. entityData.class .. "/init.lua", "GAME") or
                               file.Exists("lua/entities/" .. entityData.class .. ".lua", "GAME")
            
            if entityExists then
                list.Set("SpawnableEntities", entityData.class, {
                    PrintName = entityData.name,
                    ClassName = entityData.class,
                    Category = entityData.category,
                    Spawnable = true,
                    AdminSpawnable = true,
                    Description = entityData.description,
                    KeyValues = {},
                    SpawnFunction = function(ply, tr, class)
                        if not tr.Hit then return end
                        
                        local ent = ents.Create(class)
                        if IsValid(ent) then
                            ent:SetPos(tr.HitPos + tr.HitNormal * 10)
                            ent:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
                            ent:Spawn()
                            ent:Activate()
                            
                            -- Set owner
                            if ent.SetOwner then
                                ent:SetOwner(ply)
                            end
                            
                            -- Undo support
                            undo.Create(entityData.name)
                                undo.AddEntity(ent)
                                undo.SetPlayer(ply)
                            undo.Finish()
                            
                            return ent
                        end
                    end
                })
                registered = registered + 1
            else
                skipped = skipped + 1
                if ASC.Organization and ASC.Organization.Config and ASC.Organization.Config.DebugMode then
                    print("[ASC Entity Registration] Skipped " .. entityData.class .. " (file not found)")
                end
            end
        end
    end
    
    print("[ASC Entity Registration] Registered " .. registered .. " entities, skipped " .. skipped)
end

-- Server-side registration
if SERVER then
    -- Register entities on server start
    hook.Add("Initialize", "ASC_EntityRegistration", function()
        timer.Simple(1, function()
            ASC.EntityRegistration.RegisterAll()
        end)
    end)
    
    -- Console command for manual registration
    concommand.Add("asc_register_entities", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        
        ASC.EntityRegistration.RegisterAll()
        
        local msg = "[ASC] Entities registered"
        print(msg)
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTTALK, msg)
        end
    end)
end

-- Client-side registration
if CLIENT then
    -- Register entities on client
    hook.Add("Initialize", "ASC_EntityRegistrationClient", function()
        timer.Simple(2, function()
            ASC.EntityRegistration.RegisterAll()
        end)
    end)
    
    -- Register when spawn menu opens
    hook.Add("SpawnMenuOpen", "ASC_EntityRegistrationSpawnMenu", function()
        timer.Simple(0.1, function()
            ASC.EntityRegistration.RegisterAll()
        end)
    end)
    
    -- Console command for client
    concommand.Add("asc_register_entities_client", function()
        ASC.EntityRegistration.RegisterAll()
        print("[ASC] Client entities registered")
    end)
end

-- Status function
ASC.EntityRegistration.GetStatus = function()
    local total = #ASC.EntityRegistration.Entities
    local existing = 0
    
    for _, entityData in ipairs(ASC.EntityRegistration.Entities) do
        local entityExists = file.Exists("lua/entities/" .. entityData.class .. "/init.lua", "GAME") or
                           file.Exists("lua/entities/" .. entityData.class .. ".lua", "GAME")
        if entityExists then
            existing = existing + 1
        end
    end
    
    return {
        total = total,
        existing = existing,
        missing = total - existing
    }
end

print("[Advanced Space Combat] Entity Registration System - Loaded successfully!")
