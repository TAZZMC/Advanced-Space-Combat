-- Hyperdrive Hyperspace Dimension System
-- This file creates a separate hyperspace dimension for ships during transit

-- Ensure HYPERDRIVE table exists first
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Hyperspace = HYPERDRIVE.Hyperspace or {}
HYPERDRIVE.Hyperspace.Version = "2.0.0"

-- Hyperspace configuration
HYPERDRIVE.Hyperspace.Config = {
    -- Dimension settings
    DimensionSize = 50000, -- Size of hyperspace dimension
    DimensionHeight = 10000, -- Height of hyperspace
    DimensionCenter = Vector(0, 0, 5000), -- Center point of hyperspace

    -- Transit settings
    TransitSpeed = 2000, -- Speed through hyperspace
    MinTransitTime = 3, -- Minimum time in hyperspace (seconds)
    MaxTransitTime = 30, -- Maximum time in hyperspace

    -- Physics settings
    AlternatePhysics = true, -- Different physics in hyperspace
    NoGravity = true, -- Zero gravity in hyperspace
    EnergyDrain = 0.1, -- Energy drain per second in hyperspace

    -- Visual settings
    HyperspaceEffects = true, -- Special hyperspace effects
    StarField = true, -- Moving star field
    EnergyStreams = true, -- Energy stream effects
    DistortionField = true, -- Space distortion effects

    -- Safety settings
    EmergencyExit = true, -- Allow emergency exit from hyperspace
    CollisionDetection = true, -- Detect collisions in hyperspace
    SafetyBubble = 500, -- Safety radius around ships

    -- Advanced features
    HyperspaceBeacons = true, -- Navigation beacons in hyperspace
    InterdimensionalComms = true, -- Communication between dimensions
    HyperspacePirates = false, -- Random encounters (disabled by default)
    TemporalEffects = true -- Time dilation effects
}

-- Hyperspace state tracking
HYPERDRIVE.Hyperspace.ActiveTransits = {}
HYPERDRIVE.Hyperspace.HyperspaceEntities = {}
HYPERDRIVE.Hyperspace.Beacons = {}
HYPERDRIVE.Hyperspace.ExitPortals = {}

-- Initialize hyperspace dimension
function HYPERDRIVE.Hyperspace.Initialize()
    if CLIENT then return end

    HYPERDRIVE.Hyperspace.Log("Initializing hyperspace dimension", "INIT")

    -- Create hyperspace beacons if enabled
    if HYPERDRIVE.Hyperspace.Config.HyperspaceBeacons then
        HYPERDRIVE.Hyperspace.CreateBeacons()
    end

    -- Set up hyperspace physics
    HYPERDRIVE.Hyperspace.SetupPhysics()

    HYPERDRIVE.Hyperspace.Log("Hyperspace dimension initialized", "INIT")
end

-- Set up hyperspace physics
function HYPERDRIVE.Hyperspace.SetupPhysics()
    -- Configure hyperspace physics constants
    HYPERDRIVE.Hyperspace.Physics = {
        gravity = HYPERDRIVE.Hyperspace.Config.NoGravity and 0 or 600,
        airResistance = 0.1, -- Reduced air resistance
        friction = 0.05, -- Very low friction
        timeScale = 1.0 -- Normal time flow (can be modified for time dilation)
    }

    HYPERDRIVE.Hyperspace.Log("Hyperspace physics configured", "PHYSICS")
end

-- Enter hyperspace
function HYPERDRIVE.Hyperspace.EnterHyperspace(engine, destination, entities)
    if CLIENT then return false end
    if not IsValid(engine) then return false end

    entities = entities or {}
    local origin = engine:GetPos()
    local distance = origin:Distance(destination)

    -- Calculate transit time based on distance
    local transitTime = math.Clamp(
        distance / HYPERDRIVE.Hyperspace.Config.TransitSpeed,
        HYPERDRIVE.Hyperspace.Config.MinTransitTime,
        HYPERDRIVE.Hyperspace.Config.MaxTransitTime
    )

    -- Create hyperspace entry portal
    local entryPortal = HYPERDRIVE.Hyperspace.CreatePortal(origin, "entry")

    -- Calculate hyperspace position
    local hyperspacePos = HYPERDRIVE.Hyperspace.GetHyperspacePosition(origin, destination)

    -- Create transit data
    local transitData = {
        engine = engine,
        entities = entities,
        origin = origin,
        destination = destination,
        hyperspacePos = hyperspacePos,
        transitTime = transitTime,
        startTime = CurTime(),
        endTime = CurTime() + transitTime,
        entryPortal = entryPortal,
        exitPortal = nil,
        phase = "entering" -- entering, transit, exiting
    }

    -- Store transit data
    HYPERDRIVE.Hyperspace.ActiveTransits[engine:EntIndex()] = transitData

    -- Move entities to hyperspace
    HYPERDRIVE.Hyperspace.TransportToHyperspace(transitData)

    -- Create hyperspace effects
    HYPERDRIVE.Hyperspace.CreateHyperspaceEffects(origin, "entry")

    -- Start transit timer
    timer.Create("HyperspaceTransit_" .. engine:EntIndex(), transitTime, 1, function()
        HYPERDRIVE.Hyperspace.ExitHyperspace(engine)
    end)

    HYPERDRIVE.Hyperspace.Log("Entered hyperspace: " .. engine:GetClass(), "TRANSIT")
    return true
end

-- Transport entities to hyperspace
function HYPERDRIVE.Hyperspace.TransportToHyperspace(transitData)
    local engine = transitData.engine
    local entities = transitData.entities
    local hyperspacePos = transitData.hyperspacePos

    -- Always include the engine
    table.insert(entities, engine)

    -- Transport each entity
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            -- Store original position
            ent.HyperspaceOriginalPos = ent:GetPos()
            ent.HyperspaceOriginalAng = ent:GetAngles()

            -- Calculate offset from engine
            local offset = ent:GetPos() - engine:GetPos()
            local newPos = hyperspacePos + offset

            -- Move to hyperspace
            ent:SetPos(newPos)

            -- Apply hyperspace physics
            HYPERDRIVE.Hyperspace.ApplyHyperspacePhysics(ent)

            -- Mark as in hyperspace
            ent.InHyperspace = true
            ent.HyperspaceTransitData = transitData

            -- Add to hyperspace entity list
            HYPERDRIVE.Hyperspace.HyperspaceEntities[ent:EntIndex()] = ent

            -- Notify clients
            if ent:IsPlayer() then
                HYPERDRIVE.Hyperspace.NotifyPlayerEnterHyperspace(ent, transitData)
            end
        end
    end
end

-- Apply hyperspace physics
function HYPERDRIVE.Hyperspace.ApplyHyperspacePhysics(ent)
    if not IsValid(ent) then return end

    -- Zero gravity
    if HYPERDRIVE.Hyperspace.Config.NoGravity then
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableGravity(false)
            phys:SetVelocity(Vector(0, 0, 0))
        end

        if ent:IsPlayer() then
            ent:SetGravity(0)
        end
    end

    -- Alternate physics effects
    if HYPERDRIVE.Hyperspace.Config.AlternatePhysics then
        -- Reduced friction
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetMaterial("ice")
        end
    end
end

-- Get hyperspace position
function HYPERDRIVE.Hyperspace.GetHyperspacePosition(origin, destination)
    local center = HYPERDRIVE.Hyperspace.Config.DimensionCenter
    local size = HYPERDRIVE.Hyperspace.Config.DimensionSize

    -- Create a unique position in hyperspace based on origin and destination
    local hash = util.CRC(tostring(origin) .. tostring(destination))
    local normalizedHash = (hash % 10000) / 10000 -- Normalize to 0-1

    -- Generate position within hyperspace bounds
    local x = center.x + (normalizedHash - 0.5) * size * 0.8
    local y = center.y + (math.sin(normalizedHash * math.pi * 2) * size * 0.4)
    local z = center.z + (math.cos(normalizedHash * math.pi * 4) * 1000)

    return Vector(x, y, z)
end

-- Exit hyperspace
function HYPERDRIVE.Hyperspace.ExitHyperspace(engine)
    if CLIENT then return false end
    if not IsValid(engine) then return false end

    local transitData = HYPERDRIVE.Hyperspace.ActiveTransits[engine:EntIndex()]
    if not transitData then return false end

    -- Create exit portal
    local exitPortal = HYPERDRIVE.Hyperspace.CreatePortal(transitData.destination, "exit")
    transitData.exitPortal = exitPortal
    transitData.phase = "exiting"

    -- Transport entities back to normal space
    HYPERDRIVE.Hyperspace.TransportFromHyperspace(transitData)

    -- Create exit effects
    HYPERDRIVE.Hyperspace.CreateHyperspaceEffects(transitData.destination, "exit")

    -- Clean up
    HYPERDRIVE.Hyperspace.CleanupTransit(engine:EntIndex())

    HYPERDRIVE.Hyperspace.Log("Exited hyperspace: " .. engine:GetClass(), "TRANSIT")
    return true
end

-- Transport entities from hyperspace
function HYPERDRIVE.Hyperspace.TransportFromHyperspace(transitData)
    local engine = transitData.engine
    local destination = transitData.destination

    -- Get all entities in this transit
    local transitEntities = {}
    for entIndex, ent in pairs(HYPERDRIVE.Hyperspace.HyperspaceEntities) do
        if IsValid(ent) and ent.HyperspaceTransitData == transitData then
            table.insert(transitEntities, ent)
        end
    end

    -- Transport each entity back
    for _, ent in ipairs(transitEntities) do
        if IsValid(ent) then
            -- Calculate offset from engine
            local currentOffset = ent:GetPos() - transitData.hyperspacePos
            local newPos = destination + currentOffset

            -- Move back to normal space
            ent:SetPos(newPos)

            -- Restore normal physics
            HYPERDRIVE.Hyperspace.RestoreNormalPhysics(ent)

            -- Clear hyperspace flags
            ent.InHyperspace = false
            ent.HyperspaceTransitData = nil
            ent.HyperspaceOriginalPos = nil
            ent.HyperspaceOriginalAng = nil

            -- Remove from hyperspace entity list
            HYPERDRIVE.Hyperspace.HyperspaceEntities[ent:EntIndex()] = nil

            -- Notify clients
            if ent:IsPlayer() then
                HYPERDRIVE.Hyperspace.NotifyPlayerExitHyperspace(ent)
            end
        end
    end
end

-- Restore normal physics
function HYPERDRIVE.Hyperspace.RestoreNormalPhysics(ent)
    if not IsValid(ent) then return end

    -- Restore gravity
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableGravity(true)
        phys:SetMaterial("default")
    end

    if ent:IsPlayer() then
        ent:SetGravity(1)
    end
end

-- Create hyperspace portal
function HYPERDRIVE.Hyperspace.CreatePortal(pos, portalType)
    if CLIENT then return nil end

    local portal = ents.Create("prop_physics")
    if not IsValid(portal) then return nil end

    portal:SetModel("models/hunter/plates/plate2x2.mdl")
    portal:SetPos(pos + Vector(0, 0, 100))
    portal:SetAngles(Angle(0, 0, 0))
    portal:Spawn()

    -- Make it invisible and non-solid
    portal:SetNoDraw(true)
    portal:SetSolid(SOLID_NONE)
    portal:SetCollisionGroup(COLLISION_GROUP_WORLD)

    -- Add portal effects
    portal.IsHyperspacePortal = true
    portal.PortalType = portalType

    -- Remove portal after a short time
    timer.Simple(10, function()
        if IsValid(portal) then
            portal:Remove()
        end
    end)

    return portal
end

-- Create hyperspace beacons
function HYPERDRIVE.Hyperspace.CreateBeacons()
    if CLIENT then return end

    local center = HYPERDRIVE.Hyperspace.Config.DimensionCenter
    local beaconPositions = {
        center + Vector(10000, 0, 0),
        center + Vector(-10000, 0, 0),
        center + Vector(0, 10000, 0),
        center + Vector(0, -10000, 0),
        center + Vector(0, 0, 2000),
        center + Vector(0, 0, -2000)
    }

    for i, pos in ipairs(beaconPositions) do
        local beacon = ents.Create("prop_physics")
        if IsValid(beacon) then
            beacon:SetModel("models/props_combine/combine_mine01.mdl")
            beacon:SetPos(pos)
            beacon:Spawn()
            beacon:SetSolid(SOLID_NONE)
            beacon:SetCollisionGroup(COLLISION_GROUP_WORLD)
            beacon.IsHyperspaceBeacon = true
            beacon.BeaconID = i

            HYPERDRIVE.Hyperspace.Beacons[i] = beacon
        end
    end
end

-- Emergency exit from hyperspace
function HYPERDRIVE.Hyperspace.EmergencyExit(player)
    if CLIENT then return false end
    if not IsValid(player) or not player:IsPlayer() then return false end
    if not player.InHyperspace then return false end

    local transitData = player.HyperspaceTransitData
    if not transitData then return false end

    -- Find safe exit position
    local safePos = HYPERDRIVE.Hyperspace.FindSafeExitPosition(player:GetPos())

    -- Transport player to safe position
    player:SetPos(safePos)
    HYPERDRIVE.Hyperspace.RestoreNormalPhysics(player)

    -- Clear hyperspace flags
    player.InHyperspace = false
    player.HyperspaceTransitData = nil

    -- Notify player
    player:ChatPrint("[Hyperdrive] Emergency exit from hyperspace!")

    HYPERDRIVE.Hyperspace.Log("Emergency exit: " .. player:Name(), "EMERGENCY")
    return true
end

-- Find safe exit position
function HYPERDRIVE.Hyperspace.FindSafeExitPosition(currentPos)
    -- Try to find a safe position near the original destination
    local testPositions = {}

    for i = 1, 10 do
        local testPos = currentPos + VectorRand() * 1000
        testPos.z = math.max(testPos.z, -500) -- Don't go too far underground

        local trace = util.TraceLine({
            start = testPos + Vector(0, 0, 100),
            endpos = testPos - Vector(0, 0, 100),
            mask = MASK_SOLID_BRUSHONLY
        })

        if not trace.Hit or trace.Fraction > 0.5 then
            return testPos
        end
    end

    -- Fallback to spawn position
    return Vector(0, 0, 100)
end

-- Update hyperspace entities
function HYPERDRIVE.Hyperspace.Think()
    if CLIENT then return end

    local currentTime = CurTime()

    -- Update active transits
    for entIndex, transitData in pairs(HYPERDRIVE.Hyperspace.ActiveTransits) do
        if not IsValid(transitData.engine) then
            HYPERDRIVE.Hyperspace.CleanupTransit(entIndex)
            continue
        end

        -- Check for transit completion
        if currentTime >= transitData.endTime and transitData.phase == "transit" then
            HYPERDRIVE.Hyperspace.ExitHyperspace(transitData.engine)
        end

        -- Apply energy drain
        if transitData.engine.GetEnergy and transitData.engine.SetEnergy then
            local currentEnergy = transitData.engine:GetEnergy()
            local energyDrain = HYPERDRIVE.Hyperspace.Config.EnergyDrain
            transitData.engine:SetEnergy(math.max(0, currentEnergy - energyDrain))
        end

        -- Update transit phase
        local progress = (currentTime - transitData.startTime) / transitData.transitTime
        if progress < 0.1 then
            transitData.phase = "entering"
        elseif progress > 0.9 then
            transitData.phase = "exiting"
        else
            transitData.phase = "transit"
        end
    end

    -- Update hyperspace entities
    for entIndex, ent in pairs(HYPERDRIVE.Hyperspace.HyperspaceEntities) do
        if not IsValid(ent) then
            HYPERDRIVE.Hyperspace.HyperspaceEntities[entIndex] = nil
            continue
        end

        -- Apply hyperspace effects
        if ent:IsPlayer() then
            HYPERDRIVE.Hyperspace.ApplyHyperspaceEffectsToPlayer(ent)
        end
    end
end

-- Apply hyperspace effects to player
function HYPERDRIVE.Hyperspace.ApplyHyperspaceEffectsToPlayer(player)
    if not IsValid(player) or not player.InHyperspace then return end

    -- Temporal effects
    if HYPERDRIVE.Hyperspace.Config.TemporalEffects then
        -- Slight time dilation effect (visual only)
        if math.random() < 0.01 then
            player:ChatPrint("[Hyperspace] Time flows differently here...")
        end
    end
end

-- Cleanup transit
function HYPERDRIVE.Hyperspace.CleanupTransit(entIndex)
    local transitData = HYPERDRIVE.Hyperspace.ActiveTransits[entIndex]
    if transitData then
        -- Remove portals
        if IsValid(transitData.entryPortal) then
            transitData.entryPortal:Remove()
        end
        if IsValid(transitData.exitPortal) then
            transitData.exitPortal:Remove()
        end

        -- Remove timer
        timer.Remove("HyperspaceTransit_" .. entIndex)

        -- Clear transit data
        HYPERDRIVE.Hyperspace.ActiveTransits[entIndex] = nil
    end
end

-- Create hyperspace effects
function HYPERDRIVE.Hyperspace.CreateHyperspaceEffects(pos, effectType)
    if CLIENT then return end

    -- Send effect to clients
    net.Start("hyperdrive_hyperspace_effect")
    net.WriteVector(pos)
    net.WriteString(effectType)
    net.Broadcast()
end

-- Notify player entering hyperspace
function HYPERDRIVE.Hyperspace.NotifyPlayerEnterHyperspace(player, transitData)
    if not IsValid(player) then return end

    net.Start("hyperdrive_hyperspace_enter")
    net.WriteFloat(transitData.transitTime)
    net.WriteVector(transitData.destination)
    net.Send(player)

    player:ChatPrint("[Hyperdrive] Entering hyperspace...")
end

-- Notify player exiting hyperspace
function HYPERDRIVE.Hyperspace.NotifyPlayerExitHyperspace(player)
    if not IsValid(player) then return end

    net.Start("hyperdrive_hyperspace_exit")
    net.Send(player)

    player:ChatPrint("[Hyperdrive] Exiting hyperspace...")
end

-- Logging function
function HYPERDRIVE.Hyperspace.Log(message, category)
    if HYPERDRIVE.Debug then
        HYPERDRIVE.Debug.Info("HYPERSPACE: " .. message, category or "HYPERSPACE")
    else
        print("[Hyperdrive Hyperspace] " .. message)
    end
end

-- Hook into think for updates
hook.Add("Think", "HyperdriveHyperspaceThink", function()
    if math.random() < 0.1 then -- 10% chance per frame to reduce performance impact
        HYPERDRIVE.Hyperspace.Think()
    end
end)

-- Console commands
-- Logging function
function HYPERDRIVE.Hyperspace.Log(message, category)
    category = category or "INFO"
    print("[Hyperdrive Hyperspace] [" .. category .. "] " .. message)
end

concommand.Add("hyperdrive_hyperspace_emergency_exit", function(ply)
    if IsValid(ply) and ply.InHyperspace then
        HYPERDRIVE.Hyperspace.EmergencyExit(ply)
    else
        ply:ChatPrint("[Hyperdrive] You are not in hyperspace")
    end
end)

-- Initialize hyperspace on server start
if SERVER then
    timer.Simple(1, function()
        HYPERDRIVE.Hyperspace.Initialize()
    end)

    -- Add Think hook for hyperspace updates
    hook.Add("Think", "HyperdriveHyperspaceThink", function()
        HYPERDRIVE.Hyperspace.Think()
    end)
end

print("[Hyperdrive] Hyperspace dimension system loaded")
