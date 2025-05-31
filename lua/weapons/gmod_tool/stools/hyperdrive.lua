-- Advanced Space Combat - Comprehensive Spawn Tool v2.2.1
-- Integrated tool for spawning ships, weapons, and space combat components

TOOL.Category = "Advanced Space Combat"
TOOL.Name = "Advanced Space Combat Tool"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.Information = {
    { name = "left", text = "Spawn Selected Entity" },
    { name = "right", text = "Configure Entity" },
    { name = "reload", text = "Remove Entity" }
}

if CLIENT then
    language.Add("tool.hyperdrive.name", "Enhanced Hyperdrive Tool")
    language.Add("tool.hyperdrive.desc", "Comprehensive tool for spawning and configuring hyperdrive systems")
    language.Add("tool.hyperdrive.0", "Left click to spawn, right click to configure, reload to remove")

    -- Tool ConVars for entity selection
    TOOL.ClientConVar["entity_type"] = "ship_core"
    TOOL.ClientConVar["entity_mode"] = "spawn"

    -- Ship Core ConVars
    TOOL.ClientConVar["ship_name"] = "USS Enterprise"
    TOOL.ClientConVar["ship_type"] = "Battlecruiser"
    TOOL.ClientConVar["auto_detect"] = "1"
    TOOL.ClientConVar["enable_hull"] = "1"
    TOOL.ClientConVar["enable_shields"] = "1"
    TOOL.ClientConVar["enable_resources"] = "1"
    TOOL.ClientConVar["enable_cap"] = "1"
    TOOL.ClientConVar["detection_radius"] = "2000"
    TOOL.ClientConVar["max_entities"] = "500"

    -- Shield ConVars
    TOOL.ClientConVar["shield_type"] = "cap_bubble_shield"
    TOOL.ClientConVar["shield_strength"] = "100"
    TOOL.ClientConVar["shield_radius"] = "500"
    TOOL.ClientConVar["shield_frequency"] = "1234"
    TOOL.ClientConVar["auto_activate"] = "1"
    TOOL.ClientConVar["link_to_core"] = "1"
    TOOL.ClientConVar["energy_consumption"] = "10"
    TOOL.ClientConVar["recharge_rate"] = "5"
    TOOL.ClientConVar["bubble_shield"] = "1"
    TOOL.ClientConVar["frequency_based"] = "1"

    -- Engine ConVars
    TOOL.ClientConVar["engine_type"] = "standard"
    TOOL.ClientConVar["max_energy"] = "1000"
    TOOL.ClientConVar["charge_rate"] = "10"
    TOOL.ClientConVar["cooldown_time"] = "30"
    TOOL.ClientConVar["jump_range"] = "10000"
    TOOL.ClientConVar["energy_per_jump"] = "500"
    TOOL.ClientConVar["auto_charge"] = "1"
    TOOL.ClientConVar["stargate_mode"] = "0"
    TOOL.ClientConVar["precision_mode"] = "0"
end

-- Available entity types and configurations
local entityTypes = {
    ship_core = { class = "ship_core", name = "Ship Core" },
    hyperdrive_engine = { class = "hyperdrive_engine", name = "Hyperdrive Engine" },
    hyperdrive_master_engine = { class = "hyperdrive_master_engine", name = "Master Engine" },
    hyperdrive_computer = { class = "hyperdrive_computer", name = "Hyperdrive Computer" },

    -- v2.2.1 Weapon entities
    hyperdrive_pulse_cannon = { class = "hyperdrive_pulse_cannon", name = "Pulse Cannon" },
    hyperdrive_beam_weapon = { class = "hyperdrive_beam_weapon", name = "Beam Weapon" },
    hyperdrive_torpedo_launcher = { class = "hyperdrive_torpedo_launcher", name = "Torpedo Launcher" },
    hyperdrive_railgun = { class = "hyperdrive_railgun", name = "Railgun" },
    hyperdrive_plasma_cannon = { class = "hyperdrive_plasma_cannon", name = "Plasma Cannon" },

    -- v2.2.1 Flight & Navigation entities
    hyperdrive_flight_console = { class = "hyperdrive_flight_console", name = "Flight Console" },

    -- v2.2.1 Docking & Transport entities
    hyperdrive_docking_pad = { class = "hyperdrive_docking_pad", name = "Docking Pad" },
    hyperdrive_shuttle = { class = "hyperdrive_shuttle", name = "Shuttle" }
}

local shieldTypes = {
    cap_bubble_shield = { class = "cap_bubble_shield", name = "CAP Bubble Shield", cap = true },
    cap_shield_generator = { class = "cap_shield_generator", name = "CAP Shield Generator", cap = true },
    cap_asgard_shield = { class = "cap_asgard_shield", name = "CAP Asgard Shield", cap = true },
    cap_ancient_shield = { class = "cap_ancient_shield", name = "CAP Ancient Shield", cap = true },
    shield = { class = "shield", name = "Standard Shield", cap = true },
    shield_core_buble = { class = "shield_core_buble", name = "Bubble Shield Core", cap = true }
}

local engineTypes = {
    standard = { name = "Standard Hyperdrive", energy = 1000, range = 10000 },
    advanced = { name = "Advanced Hyperdrive", energy = 2000, range = 20000 },
    military = { name = "Military Hyperdrive", energy = 3000, range = 30000 },
    stargate = { name = "Stargate Hyperdrive", energy = 5000, range = 50000 },
    asgard = { name = "Asgard Hyperdrive", energy = 10000, range = 100000 },
    ancient = { name = "Ancient Hyperdrive", energy = 20000, range = 200000 }
}

function TOOL:LeftClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end

    -- Check permissions
    if not ply:IsSuperAdmin() and not ply:IsAdmin() then
        ply:ChatPrint("[Enhanced Hyperdrive] Admin privileges required to spawn entities")
        return false
    end

    local entityType = self:GetClientInfo("entity_type")
    local pos = trace.HitPos
    local ang = ply:GetAngles()
    ang.pitch = 0
    ang.roll = 0

    -- Route to appropriate spawn function
    if entityType == "ship_core" then
        return self:SpawnShipCore(pos, ang, ply)
    elseif entityType == "hyperdrive_engine" or entityType == "hyperdrive_master_engine" then
        return self:SpawnHyperdriveEngine(pos, ang, ply, entityType)
    elseif entityType == "hyperdrive_computer" then
        return self:SpawnHyperdriveComputer(pos, ang, ply)
    elseif shieldTypes[entityType] then
        return self:SpawnShieldGenerator(pos, ang, ply, entityType)
    elseif entityTypes[entityType] then
        return self:SpawnGenericEntity(pos, ang, ply, entityType)
    else
        ply:ChatPrint("[Advanced Space Combat] Unknown entity type: " .. entityType)
        return false
    end
end

-- Ship Core spawning function
function TOOL:SpawnShipCore(pos, ang, ply)
    -- Check for nearby ship cores
    local nearbyCore = nil
    for _, ent in ipairs(ents.FindInSphere(pos, 500)) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            nearbyCore = ent
            break
        end
    end

    if nearbyCore then
        ply:ChatPrint("[Ship Core] Another ship core is too close! Minimum distance: 500 units")
        return false
    end

    -- Create ship core
    local core = ents.Create("ship_core")
    if not IsValid(core) then
        ply:ChatPrint("[Ship Core] Failed to create ship core entity")
        return false
    end

    -- Set position and spawn
    core:SetPos(pos + Vector(0, 0, 10))
    core:SetAngles(ang)
    core:Spawn()
    core:Activate()

    -- Configure with tool settings
    local shipName = self:GetClientInfo("ship_name")
    local shipType = self:GetClientInfo("ship_type")
    local autoDetect = self:GetClientNumber("auto_detect") == 1
    local enableHull = self:GetClientNumber("enable_hull") == 1
    local enableShields = self:GetClientNumber("enable_shields") == 1
    local enableResources = self:GetClientNumber("enable_resources") == 1
    local enableCAP = self:GetClientNumber("enable_cap") == 1
    local detectionRadius = math.Clamp(self:GetClientNumber("detection_radius"), 500, 5000)
    local maxEntities = math.Clamp(self:GetClientNumber("max_entities"), 50, 1000)

    -- Apply configuration
    core:SetNWString("ShipName", shipName)
    core:SetNWString("ShipType", shipType)
    core:SetNWString("Owner", ply:SteamID())
    core:SetNWString("OwnerName", ply:Name())
    core:SetNWBool("AutoDetectEntities", autoDetect)
    core:SetNWBool("HullSystemEnabled", enableHull)
    core:SetNWBool("ShieldSystemEnabled", enableShields)
    core:SetNWBool("ResourceSystemEnabled", enableResources)
    core:SetNWBool("CAPIntegrationEnabled", enableCAP)
    core:SetNWFloat("DetectionRadius", detectionRadius)
    core:SetNWInt("MaxEntities", maxEntities)

    -- Initialize systems
    if core.InitializeSystems then
        core:InitializeSystems()
    end

    -- Auto-detect if enabled
    if autoDetect then
        timer.Simple(1, function()
            if IsValid(core) and core.DetectShipEntities then
                core:DetectShipEntities()
            end
        end)
    end

    ply:ChatPrint("[Ship Core] Ship core '" .. shipName .. "' spawned successfully!")

    -- Add to undo with enhanced information
    undo.Create("Hyperdrive Ship Core")
    undo.AddEntity(core)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText("Ship Core: " .. shipName)
    undo.Finish("Ship Core '" .. shipName .. "' spawned")

    -- Enhanced undo system integration
    if HYPERDRIVE.Undo then
        HYPERDRIVE.Undo.CreateUndoEntry(ply, core, "Ship Core: " .. shipName, "Ship core with " .. shipType .. " configuration")
    end

    return true
end

-- Hyperdrive Engine spawning function
function TOOL:SpawnHyperdriveEngine(pos, ang, ply, entityClass)
    -- Create engine
    local engine = ents.Create(entityClass)
    if not IsValid(engine) then
        ply:ChatPrint("[Hyperdrive Engine] Failed to create engine entity")
        return false
    end

    -- Set position and spawn
    engine:SetPos(pos + Vector(0, 0, 10))
    engine:SetAngles(ang)
    engine:Spawn()
    engine:Activate()

    -- Configure with tool settings
    local engineType = self:GetClientInfo("engine_type")
    local maxEnergy = math.Clamp(self:GetClientNumber("max_energy"), 100, 50000)
    local chargeRate = math.Clamp(self:GetClientNumber("charge_rate"), 1, 200)
    local cooldownTime = math.Clamp(self:GetClientNumber("cooldown_time"), 5, 300)
    local jumpRange = math.Clamp(self:GetClientNumber("jump_range"), 1000, 500000)
    local energyPerJump = math.Clamp(self:GetClientNumber("energy_per_jump"), 50, 10000)
    local autoCharge = self:GetClientNumber("auto_charge") == 1
    local linkToCore = self:GetClientNumber("link_to_core") == 1
    local stargateMode = self:GetClientNumber("stargate_mode") == 1
    local precisionMode = self:GetClientNumber("precision_mode") == 1

    -- Apply engine type defaults
    if engineTypes[engineType] then
        local preset = engineTypes[engineType]
        if maxEnergy == 1000 then maxEnergy = preset.energy end
        if jumpRange == 10000 then jumpRange = preset.range end
    end

    -- Set engine properties
    if engine.MaxEnergy then engine.MaxEnergy = maxEnergy end
    if engine.ChargeRate then engine.ChargeRate = chargeRate end
    if engine.CooldownTime then engine.CooldownTime = cooldownTime end
    if engine.JumpRange then engine.JumpRange = jumpRange end
    if engine.EnergyPerJump then engine.EnergyPerJump = energyPerJump end

    -- Set network variables
    engine:SetNWString("Owner", ply:SteamID())
    engine:SetNWString("OwnerName", ply:Name())
    engine:SetNWString("EngineType", engineType)
    engine:SetNWFloat("MaxEnergy", maxEnergy)
    engine:SetNWFloat("ChargeRate", chargeRate)
    engine:SetNWFloat("CooldownTime", cooldownTime)
    engine:SetNWFloat("JumpRange", jumpRange)
    engine:SetNWFloat("EnergyPerJump", energyPerJump)
    engine:SetNWBool("AutoCharge", autoCharge)
    engine:SetNWBool("LinkToCore", linkToCore)
    engine:SetNWBool("StargateMode", stargateMode)
    engine:SetNWBool("PrecisionMode", precisionMode)

    -- Set creator for legacy compatibility
    engine:SetCreator(ply)

    -- Initialize engine
    if engine.InitializeEngine then
        engine:InitializeEngine()
    end

    -- Set initial energy
    if engine.SetEnergy then
        engine:SetEnergy(maxEnergy)
    end

    -- Link to nearby ship core
    if linkToCore then
        local nearbyCore = nil
        for _, ent in ipairs(ents.FindInSphere(pos, 2000)) do
            if IsValid(ent) and ent:GetClass() == "ship_core" then
                nearbyCore = ent
                break
            end
        end

        if nearbyCore then
            engine:SetNWEntity("LinkedShipCore", nearbyCore)
            engine.ShipCore = nearbyCore
            if nearbyCore.AddEngine then
                nearbyCore:AddEngine(engine)
            end
            ply:ChatPrint("[Hyperdrive Engine] Linked to ship core: " .. nearbyCore:GetNWString("ShipName", "Unknown Ship"))
        end
    end

    local engineName = engineTypes[engineType] and engineTypes[engineType].name or "Hyperdrive Engine"
    ply:ChatPrint("[Hyperdrive Engine] " .. engineName .. " spawned successfully!")

    -- Add to undo with enhanced information
    undo.Create("Hyperdrive Engine")
    undo.AddEntity(engine)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText(engineName .. " (" .. engineType .. ")")
    undo.Finish(engineName .. " spawned")

    -- Enhanced undo system integration
    if HYPERDRIVE.Undo then
        HYPERDRIVE.Undo.CreateUndoEntry(ply, engine, engineName, "Hyperdrive engine with " .. engineType .. " configuration")
    end

    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end

    local ent = trace.Entity
    if not IsValid(ent) then
        ply:ChatPrint("[Enhanced Hyperdrive] Aim at an entity to configure it")
        return false
    end

    -- Check ownership
    local owner = ent:GetNWString("Owner", "")
    if owner ~= "" and owner ~= ply:SteamID() and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Hyperdrive] You don't own this entity!")
        return false
    end

    -- Route to appropriate configuration function
    local class = ent:GetClass()
    if class == "ship_core" then
        return self:ConfigureShipCore(ent, ply)
    elseif class == "hyperdrive_engine" or class == "hyperdrive_master_engine" then
        return self:ConfigureHyperdriveEngine(ent, ply)
    elseif shieldTypes[class] then
        return self:ConfigureShieldGenerator(ent, ply)
    elseif class == "hyperdrive_computer" then
        return self:ConfigureHyperdriveComputer(ent, ply)
    else
        ply:ChatPrint("[Enhanced Hyperdrive] This entity cannot be configured with this tool")
        return false
    end
end

-- Shield Generator spawning function
function TOOL:SpawnShieldGenerator(pos, ang, ply, shieldType)
    -- Check for CAP integration if needed
    local shieldConfig = shieldTypes[shieldType]
    if shieldConfig.cap and HYPERDRIVE.CAP and not HYPERDRIVE.CAP.Available then
        ply:ChatPrint("[Shield Generator] CAP integration required for " .. shieldConfig.name)
        return false
    end

    -- Create shield
    local shield = ents.Create(shieldConfig.class)
    if not IsValid(shield) then
        ply:ChatPrint("[Shield Generator] Failed to create shield entity: " .. shieldType)
        return false
    end

    -- Set position and spawn
    shield:SetPos(pos + Vector(0, 0, 10))
    shield:SetAngles(ang)
    shield:Spawn()
    shield:Activate()

    -- Configure with tool settings
    local shieldStrength = math.Clamp(self:GetClientNumber("shield_strength"), 10, 1000)
    local shieldRadius = math.Clamp(self:GetClientNumber("shield_radius"), 100, 2000)
    local shieldFrequency = math.Clamp(self:GetClientNumber("shield_frequency"), 1000, 9999)
    local autoActivate = self:GetClientNumber("auto_activate") == 1
    local linkToCore = self:GetClientNumber("link_to_core") == 1

    -- Apply shield properties
    if shield.SetShieldStrength then shield:SetShieldStrength(shieldStrength) end
    if shield.SetMaxShieldStrength then shield:SetMaxShieldStrength(shieldStrength) end
    if shield.SetShieldRadius then shield:SetShieldRadius(shieldRadius) end
    if shield.SetFrequency then shield:SetFrequency(shieldFrequency) end

    -- Set network variables
    shield:SetNWString("Owner", ply:SteamID())
    shield:SetNWString("OwnerName", ply:Name())
    shield:SetNWString("ShieldType", shieldType)
    shield:SetNWFloat("ConfiguredStrength", shieldStrength)
    shield:SetNWFloat("ConfiguredRadius", shieldRadius)
    shield:SetNWInt("ConfiguredFrequency", shieldFrequency)
    shield:SetNWBool("AutoActivate", autoActivate)
    shield:SetNWBool("LinkToCore", linkToCore)
    shield:SetNWBool("HyperdriveManaged", true)

    -- Link to nearby ship core
    if linkToCore then
        local nearbyCore = nil
        for _, ent in ipairs(ents.FindInSphere(pos, 2000)) do
            if IsValid(ent) and ent:GetClass() == "ship_core" then
                nearbyCore = ent
                break
            end
        end

        if nearbyCore then
            shield:SetNWEntity("LinkedShipCore", nearbyCore)
            shield.ShipCore = nearbyCore
            ply:ChatPrint("[Shield Generator] Linked to ship core: " .. nearbyCore:GetNWString("ShipName", "Unknown Ship"))
        end
    end

    -- Auto-activate if enabled
    if autoActivate then
        timer.Simple(1, function()
            if IsValid(shield) then
                if shield.Activate then shield:Activate()
                elseif shield.TurnOn then shield:TurnOn()
                elseif shield.SetActive then shield:SetActive(true) end
            end
        end)
    end

    ply:ChatPrint("[Shield Generator] " .. shieldConfig.name .. " spawned successfully!")

    -- Add to undo with enhanced information
    undo.Create("Hyperdrive Shield Generator")
    undo.AddEntity(shield)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText(shieldConfig.name .. " (Strength: " .. shieldStrength .. ")")
    undo.Finish(shieldConfig.name .. " spawned")

    return true
end

-- Hyperdrive Computer spawning function (legacy support)
function TOOL:SpawnHyperdriveComputer(pos, ang, ply)
    local computer = ents.Create("hyperdrive_computer")
    if not IsValid(computer) then
        ply:ChatPrint("[Hyperdrive Computer] Failed to create computer entity")
        return false
    end

    computer:SetPos(pos + Vector(0, 0, 10))
    computer:SetAngles(ang)
    computer:Spawn()
    computer:Activate()
    computer:SetCreator(ply)

    ply:ChatPrint("[Hyperdrive Computer] Computer spawned successfully!")

    -- Add to undo with enhanced information
    undo.Create("Hyperdrive Computer")
    undo.AddEntity(computer)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText("Hyperdrive Computer")
    undo.Finish("Hyperdrive Computer spawned")

    return true
end

-- Generic entity spawning function for v2.2.1 entities
function TOOL:SpawnGenericEntity(pos, ang, ply, entityType)
    local entityConfig = entityTypes[entityType]
    if not entityConfig then
        ply:ChatPrint("[Enhanced Hyperdrive] Invalid entity type: " .. entityType)
        return false
    end

    -- Create entity
    local entity = ents.Create(entityConfig.class)
    if not IsValid(entity) then
        ply:ChatPrint("[Enhanced Hyperdrive] Failed to create " .. entityConfig.name)
        return false
    end

    -- Set position and spawn
    entity:SetPos(pos + Vector(0, 0, 10))
    entity:SetAngles(ang)
    entity:Spawn()
    entity:Activate()

    -- Set basic properties
    entity:SetNWString("Owner", ply:SteamID())
    entity:SetNWString("OwnerName", ply:Name())
    entity:SetCreator(ply)

    -- Auto-link to nearby ship core for weapons and flight systems
    if string.find(entityType, "weapon") or string.find(entityType, "flight") then
        local nearbyCore = nil
        for _, ent in ipairs(ents.FindInSphere(pos, 2000)) do
            if IsValid(ent) and ent:GetClass() == "ship_core" then
                nearbyCore = ent
                break
            end
        end

        if nearbyCore then
            entity:SetNWEntity("LinkedShipCore", nearbyCore)
            entity.ShipCore = nearbyCore
            ply:ChatPrint("[" .. entityConfig.name .. "] Linked to ship core: " .. nearbyCore:GetNWString("ShipName", "Unknown Ship"))
        end
    end

    ply:ChatPrint("[Advanced Space Combat] " .. entityConfig.name .. " spawned successfully!")

    -- Add to undo with enhanced information
    undo.Create("Hyperdrive " .. entityConfig.name)
    undo.AddEntity(entity)
    undo.SetPlayer(ply)
    undo.SetCustomUndoText(entityConfig.name .. " (" .. entityType .. ")")
    undo.Finish(entityConfig.name .. " spawned")

    -- Enhanced undo system integration
    if HYPERDRIVE.Undo then
        HYPERDRIVE.Undo.CreateUndoEntry(ply, entity, entityConfig.name, entityConfig.name .. " (" .. entityType .. ")")
    end

    return true
end

function TOOL:Reload(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end

    local ent = trace.Entity
    if not IsValid(ent) then
        ply:ChatPrint("[Enhanced Hyperdrive] Aim at an entity to remove it")
        return false
    end

    -- Check if it's a hyperdrive-related entity
    local class = ent:GetClass()
    local isHyperdriveEntity = (entityTypes[class] or shieldTypes[class])

    if not isHyperdriveEntity then
        ply:ChatPrint("[Enhanced Hyperdrive] This entity cannot be removed with this tool")
        return false
    end

    -- Check ownership
    local owner = ent:GetNWString("Owner", "")
    local creator = ent:GetCreator()

    if owner ~= "" and owner ~= ply:SteamID() and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Enhanced Hyperdrive] You don't own this entity!")
        return false
    elseif IsValid(creator) and creator ~= ply and not ply:IsAdmin() then
        ply:ChatPrint("[Enhanced Hyperdrive] You don't own this entity!")
        return false
    end

    local entityName = ent.PrintName or ent:GetClass()

    -- Clean up entity
    if ent.OnRemove then
        ent:OnRemove()
    end

    ent:Remove()
    ply:ChatPrint("[Enhanced Hyperdrive] " .. entityName .. " removed!")

    return true
end

-- Configuration functions
function TOOL:ConfigureShipCore(core, ply)
    -- Apply new configuration from tool settings
    local shipName = self:GetClientInfo("ship_name")
    local shipType = self:GetClientInfo("ship_type")
    local autoDetect = self:GetClientNumber("auto_detect") == 1
    local enableHull = self:GetClientNumber("enable_hull") == 1
    local enableShields = self:GetClientNumber("enable_shields") == 1
    local enableResources = self:GetClientNumber("enable_resources") == 1
    local enableCAP = self:GetClientNumber("enable_cap") == 1
    local detectionRadius = math.Clamp(self:GetClientNumber("detection_radius"), 500, 5000)
    local maxEntities = math.Clamp(self:GetClientNumber("max_entities"), 50, 1000)

    -- Update configuration
    core:SetNWString("ShipName", shipName)
    core:SetNWString("ShipType", shipType)
    core:SetNWBool("AutoDetectEntities", autoDetect)
    core:SetNWBool("HullSystemEnabled", enableHull)
    core:SetNWBool("ShieldSystemEnabled", enableShields)
    core:SetNWBool("ResourceSystemEnabled", enableResources)
    core:SetNWBool("CAPIntegrationEnabled", enableCAP)
    core:SetNWFloat("DetectionRadius", detectionRadius)
    core:SetNWInt("MaxEntities", maxEntities)

    -- Reinitialize systems
    if core.InitializeSystems then
        core:InitializeSystems()
    end

    -- Re-detect entities if auto-detect is enabled
    if autoDetect and core.DetectShipEntities then
        core:DetectShipEntities()
    end

    ply:ChatPrint("[Ship Core] Configuration updated for '" .. shipName .. "'")
    return true
end

function TOOL:ConfigureHyperdriveEngine(engine, ply)
    -- Apply new configuration from tool settings
    local engineType = self:GetClientInfo("engine_type")
    local maxEnergy = math.Clamp(self:GetClientNumber("max_energy"), 100, 50000)
    local chargeRate = math.Clamp(self:GetClientNumber("charge_rate"), 1, 200)
    local cooldownTime = math.Clamp(self:GetClientNumber("cooldown_time"), 5, 300)
    local jumpRange = math.Clamp(self:GetClientNumber("jump_range"), 1000, 500000)
    local energyPerJump = math.Clamp(self:GetClientNumber("energy_per_jump"), 50, 10000)
    local autoCharge = self:GetClientNumber("auto_charge") == 1
    local linkToCore = self:GetClientNumber("link_to_core") == 1
    local stargateMode = self:GetClientNumber("stargate_mode") == 1
    local precisionMode = self:GetClientNumber("precision_mode") == 1

    -- Update engine properties
    if engine.MaxEnergy then engine.MaxEnergy = maxEnergy end
    if engine.ChargeRate then engine.ChargeRate = chargeRate end
    if engine.CooldownTime then engine.CooldownTime = cooldownTime end
    if engine.JumpRange then engine.JumpRange = jumpRange end
    if engine.EnergyPerJump then engine.EnergyPerJump = energyPerJump end

    -- Update network variables
    engine:SetNWString("EngineType", engineType)
    engine:SetNWFloat("MaxEnergy", maxEnergy)
    engine:SetNWFloat("ChargeRate", chargeRate)
    engine:SetNWFloat("CooldownTime", cooldownTime)
    engine:SetNWFloat("JumpRange", jumpRange)
    engine:SetNWFloat("EnergyPerJump", energyPerJump)
    engine:SetNWBool("AutoCharge", autoCharge)
    engine:SetNWBool("LinkToCore", linkToCore)
    engine:SetNWBool("StargateMode", stargateMode)
    engine:SetNWBool("PrecisionMode", precisionMode)

    -- Reinitialize if needed
    if engine.InitializeEngine then
        engine:InitializeEngine()
    end

    ply:ChatPrint("[Hyperdrive Engine] Configuration updated!")
    return true
end

function TOOL:ConfigureShieldGenerator(shield, ply)
    -- Apply new configuration from tool settings
    local shieldStrength = math.Clamp(self:GetClientNumber("shield_strength"), 10, 1000)
    local shieldRadius = math.Clamp(self:GetClientNumber("shield_radius"), 100, 2000)
    local shieldFrequency = math.Clamp(self:GetClientNumber("shield_frequency"), 1000, 9999)
    local autoActivate = self:GetClientNumber("auto_activate") == 1
    local linkToCore = self:GetClientNumber("link_to_core") == 1

    -- Update shield properties
    if shield.SetShieldStrength then shield:SetShieldStrength(shieldStrength) end
    if shield.SetMaxShieldStrength then shield:SetMaxShieldStrength(shieldStrength) end
    if shield.SetShieldRadius then shield:SetShieldRadius(shieldRadius) end
    if shield.SetFrequency then shield:SetFrequency(shieldFrequency) end

    -- Update network variables
    shield:SetNWFloat("ConfiguredStrength", shieldStrength)
    shield:SetNWFloat("ConfiguredRadius", shieldRadius)
    shield:SetNWInt("ConfiguredFrequency", shieldFrequency)
    shield:SetNWBool("AutoActivate", autoActivate)
    shield:SetNWBool("LinkToCore", linkToCore)

    ply:ChatPrint("[Shield Generator] Configuration updated!")
    return true
end

function TOOL:ConfigureHyperdriveComputer(computer, ply)
    ply:ChatPrint("[Hyperdrive Computer] Use the computer to access its interface!")
    return true
end

if CLIENT then
    function TOOL.BuildCPanel(panel)
        panel:AddControl("Header", { Text = "Enhanced Hyperdrive Tool", Description = "Comprehensive tool for spawning and configuring hyperdrive systems" })

        -- Entity Type Selection
        panel:AddControl("Header", { Text = "Entity Type" })
        local entityOptions = {
            ["Ship Core"] = { hyperdrive_entity_type = "ship_core" },
            ["Hyperdrive Engine"] = { hyperdrive_entity_type = "hyperdrive_engine" },
            ["Master Engine (Legacy)"] = { hyperdrive_entity_type = "hyperdrive_master_engine" },
            ["Hyperdrive Computer"] = { hyperdrive_entity_type = "hyperdrive_computer" },
            ["CAP Bubble Shield"] = { hyperdrive_entity_type = "cap_bubble_shield" },
            ["CAP Shield Generator"] = { hyperdrive_entity_type = "cap_shield_generator" },
            ["CAP Asgard Shield"] = { hyperdrive_entity_type = "cap_asgard_shield" },
            ["CAP Ancient Shield"] = { hyperdrive_entity_type = "cap_ancient_shield" },
            ["Standard Shield"] = { hyperdrive_entity_type = "shield" },
            ["Bubble Shield Core"] = { hyperdrive_entity_type = "shield_core_buble" }
        }
        panel:AddControl("ListBox", {
            Label = "Entity Type",
            Height = 120,
            Options = entityOptions
        })

        -- Ship Core Configuration
        panel:AddControl("Header", { Text = "Ship Core Configuration" })
        panel:AddControl("TextBox", {
            Label = "Ship Name",
            Command = "hyperdrive_ship_name",
            MaxLength = 50
        })
        panel:AddControl("TextBox", {
            Label = "Ship Type",
            Command = "hyperdrive_ship_type",
            MaxLength = 30
        })
        panel:AddControl("CheckBox", {
            Label = "Auto-detect ship entities",
            Command = "hyperdrive_auto_detect"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable hull damage system",
            Command = "hyperdrive_enable_hull"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable shield systems",
            Command = "hyperdrive_enable_shields"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable resource management",
            Command = "hyperdrive_enable_resources"
        })
        panel:AddControl("CheckBox", {
            Label = "Enable CAP integration",
            Command = "hyperdrive_enable_cap"
        })
        panel:AddControl("Slider", {
            Label = "Detection Radius",
            Command = "hyperdrive_detection_radius",
            Type = "Float",
            Min = 500,
            Max = 5000
        })
        panel:AddControl("Slider", {
            Label = "Max Entities",
            Command = "hyperdrive_max_entities",
            Type = "Integer",
            Min = 50,
            Max = 1000
        })

        -- Engine Configuration
        panel:AddControl("Header", { Text = "Engine Configuration" })
        local engineTypeOptions = {
            ["Standard Hyperdrive"] = { hyperdrive_engine_type = "standard" },
            ["Advanced Hyperdrive"] = { hyperdrive_engine_type = "advanced" },
            ["Military Hyperdrive"] = { hyperdrive_engine_type = "military" },
            ["Stargate Hyperdrive"] = { hyperdrive_engine_type = "stargate" },
            ["Asgard Hyperdrive"] = { hyperdrive_engine_type = "asgard" },
            ["Ancient Hyperdrive"] = { hyperdrive_engine_type = "ancient" }
        }
        panel:AddControl("ListBox", {
            Label = "Engine Type",
            Height = 80,
            Options = engineTypeOptions
        })
        panel:AddControl("Slider", {
            Label = "Max Energy",
            Command = "hyperdrive_max_energy",
            Type = "Float",
            Min = 100,
            Max = 50000
        })
        panel:AddControl("Slider", {
            Label = "Charge Rate",
            Command = "hyperdrive_charge_rate",
            Type = "Float",
            Min = 1,
            Max = 200
        })
        panel:AddControl("Slider", {
            Label = "Cooldown Time",
            Command = "hyperdrive_cooldown_time",
            Type = "Float",
            Min = 5,
            Max = 300
        })
        panel:AddControl("Slider", {
            Label = "Jump Range",
            Command = "hyperdrive_jump_range",
            Type = "Float",
            Min = 1000,
            Max = 500000
        })
        panel:AddControl("Slider", {
            Label = "Energy per Jump",
            Command = "hyperdrive_energy_per_jump",
            Type = "Float",
            Min = 50,
            Max = 10000
        })
        panel:AddControl("CheckBox", {
            Label = "Auto-charge when idle",
            Command = "hyperdrive_auto_charge"
        })
        panel:AddControl("CheckBox", {
            Label = "Stargate hyperdrive mode",
            Command = "hyperdrive_stargate_mode"
        })
        panel:AddControl("CheckBox", {
            Label = "Precision jump mode",
            Command = "hyperdrive_precision_mode"
        })

        -- Shield Configuration
        panel:AddControl("Header", { Text = "Shield Configuration" })
        panel:AddControl("Slider", {
            Label = "Shield Strength",
            Command = "hyperdrive_shield_strength",
            Type = "Float",
            Min = 10,
            Max = 1000
        })
        panel:AddControl("Slider", {
            Label = "Shield Radius",
            Command = "hyperdrive_shield_radius",
            Type = "Float",
            Min = 100,
            Max = 2000
        })
        panel:AddControl("Slider", {
            Label = "Shield Frequency",
            Command = "hyperdrive_shield_frequency",
            Type = "Integer",
            Min = 1000,
            Max = 9999
        })
        panel:AddControl("Slider", {
            Label = "Energy Consumption",
            Command = "hyperdrive_energy_consumption",
            Type = "Float",
            Min = 1,
            Max = 50
        })
        panel:AddControl("Slider", {
            Label = "Recharge Rate",
            Command = "hyperdrive_recharge_rate",
            Type = "Float",
            Min = 1,
            Max = 20
        })
        panel:AddControl("CheckBox", {
            Label = "Auto-activate on spawn",
            Command = "hyperdrive_auto_activate"
        })
        panel:AddControl("CheckBox", {
            Label = "Bubble shield mode",
            Command = "hyperdrive_bubble_shield"
        })
        panel:AddControl("CheckBox", {
            Label = "Frequency-based shield",
            Command = "hyperdrive_frequency_based"
        })

        -- System Options
        panel:AddControl("Header", { Text = "System Options" })
        panel:AddControl("CheckBox", {
            Label = "Link to nearby ship core",
            Command = "hyperdrive_link_to_core"
        })

        -- Integration Status
        panel:AddControl("Header", { Text = "Integration Status" })
        if HYPERDRIVE and HYPERDRIVE.CAP and HYPERDRIVE.CAP.Available then
            panel:AddControl("Label", { Text = "✓ CAP (Carter Addon Pack) detected" })
        else
            panel:AddControl("Label", { Text = "⚠ CAP not detected - install for full shield functionality" })
        end

        if HYPERDRIVE and HYPERDRIVE.Stargate then
            panel:AddControl("Label", { Text = "✓ Stargate hyperdrive available" })
        else
            panel:AddControl("Label", { Text = "⚠ Stargate mode requires full system" })
        end

        -- Instructions
        panel:AddControl("Header", { Text = "Instructions" })
        panel:AddControl("Label", { Text = "1. Select entity type from the list above" })
        panel:AddControl("Label", { Text = "2. Configure settings for the selected entity" })
        panel:AddControl("Label", { Text = "3. Left Click: Spawn entity with current settings" })
        panel:AddControl("Label", { Text = "4. Right Click: Configure existing entity" })
        panel:AddControl("Label", { Text = "5. Reload: Remove entity (ownership required)" })
        panel:AddControl("Label", { Text = "" })
        panel:AddControl("Label", { Text = "Note: Admin privileges required for spawning" })
        panel:AddControl("Label", { Text = "Entities automatically link to nearby ship cores" })
    end
end
