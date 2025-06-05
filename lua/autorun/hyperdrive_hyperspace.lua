-- Hyperdrive Hyperspace Dimension System
-- This file creates a separate hyperspace dimension for ships during transit

-- Ensure HYPERDRIVE table exists first
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Hyperspace = HYPERDRIVE.Hyperspace or {}
HYPERDRIVE.Hyperspace.Version = "2.0.0"

-- Enhanced Stargate-Themed Hyperspace System v3.0
-- Implements authentic 4-stage Stargate hyperdrive mechanics
HYPERDRIVE.Hyperspace.Config = {
    -- Core Stargate Hyperspace Settings
    EnableStargateHyperspace = true, -- Enable 4-stage Stargate mechanics
    DimensionSize = 150000, -- Expanded hyperspace dimension
    DimensionHeight = 30000, -- Increased height for 3D navigation
    DimensionCenter = Vector(0, 0, 15000), -- Higher center point
    DimensionLayers = 7, -- Multiple hyperspace layers (subspace depths)

    -- Stage 1: Initiation/Charging Configuration
    InitiationTime = 3.0, -- Time for energy buildup and coordinate calculation
    EnergyBuildupEffects = true, -- Visible energy surges during charging
    CoordinateCalculation = true, -- Display navigation path calculation
    GravitationalScanRange = 50000, -- Range to scan for gravitational anomalies

    -- Stage 2: Hyperspace Window Configuration
    WindowOpenTime = 2.0, -- Time to open hyperspace window
    WindowColor = Color(100, 150, 255), -- Blue/purple swirling energy
    WindowSize = 500, -- Base window size
    WindowRippleEffects = true, -- Rippling energy effects
    WindowStabilization = true, -- Window stabilization phase

    -- Stage 3: Hyperspace Travel Configuration
    TravelEffectsIntensity = 1.0, -- Intensity of travel effects
    StretchedStarlines = true, -- Stretched starlines effect
    DimensionalVisuals = true, -- Abstract dimensional tunnel visuals
    HyperspaceTurbulence = true, -- Turbulence effects during travel
    NavigationHazards = true, -- Gravitational wells and hazards

    -- Stage 4: Exit Configuration
    ExitFlashIntensity = 0.8, -- Flash of light intensity on exit
    SystemStabilization = true, -- System stabilization after exit
    ExitShockwave = true, -- Energy shockwave on exit

    -- Stargate-themed hyperspace mechanics
    HyperspaceWindow = true, -- Blue swirling energy window entry/exit
    StargateResonance = true, -- Hyperspace resonates with stargate frequencies
    AncientTechnology = true, -- Ancient tech provides bonuses in hyperspace
    ZPMPowerBoost = true, -- ZPMs provide enhanced hyperspace capabilities

    -- Enhanced transit settings
    TransitSpeed = 5000, -- Faster hyperspace travel
    MinTransitTime = 2, -- Faster minimum time
    MaxTransitTime = 60, -- Longer maximum for distant jumps
    VariableSpeed = true, -- Speed varies based on distance and power

    -- Advanced physics (TARDIS-inspired)
    AlternatePhysics = true, -- Different physics in hyperspace
    NoGravity = true, -- Zero gravity in hyperspace
    TimeDistortion = true, -- Time flows differently in hyperspace
    SpatialFolding = true, -- Space-time folding mechanics
    DimensionalStability = 0.95, -- Stability of hyperspace dimension

    -- Enhanced energy system
    EnergyDrain = 0.05, -- Reduced energy drain
    EnergyRegeneration = true, -- Energy slowly regenerates in hyperspace
    PowerFluctuations = true, -- Random power fluctuations
    ZPMEfficiency = 2.0, -- ZPMs are twice as efficient in hyperspace

    -- Advanced visual effects
    HyperspaceEffects = true, -- Special hyperspace effects
    StarField = true, -- Moving star field with parallax
    EnergyStreams = true, -- Blue energy stream effects (Stargate-themed)
    DistortionField = true, -- Space-time distortion effects
    HyperspaceWindow = true, -- Blue swirling entry/exit portals
    AncientSymbols = true, -- Ancient symbols appear during travel

    -- Enhanced safety systems
    EmergencyExit = true, -- Emergency exit from hyperspace
    CollisionDetection = true, -- Advanced collision detection
    SafetyBubble = 1000, -- Larger safety radius
    AutoStabilization = true, -- Automatic stability correction
    FailsafeProtocols = true, -- Multiple failsafe systems

    -- Stargate-themed features
    HyperspaceBeacons = true, -- Ancient navigation beacons
    InterdimensionalComms = true, -- Communication across dimensions
    AncientDatabase = true, -- Access to Ancient knowledge in hyperspace
    StargateNetwork = true, -- Integration with stargate network

    -- Advanced encounters and events
    HyperspacePirates = false, -- Hostile encounters (disabled by default)
    AncientSentinels = true, -- Ancient automated defenses
    TemporalAnomalies = true, -- Time distortion events
    DimensionalRifts = true, -- Rifts to other dimensions

    -- TARDIS-inspired mechanics
    DimensionalPockets = true, -- Create pocket dimensions
    InteriorExpansion = true, -- Ships can be bigger inside
    TemporalShielding = true, -- Protection from time effects
    RealityAnchor = true, -- Maintain connection to origin dimension

    -- Performance and optimization
    LODSystem = true, -- Level of detail for distant objects
    CullingDistance = 50000, -- Distance for object culling
    EffectQuality = 1.0, -- Effect quality multiplier
    NetworkOptimization = true -- Optimized networking
}

-- Enhanced hyperspace state tracking
HYPERDRIVE.Hyperspace.ActiveTransits = {}
HYPERDRIVE.Hyperspace.HyperspaceEntities = {}
HYPERDRIVE.Hyperspace.Beacons = {}
HYPERDRIVE.Hyperspace.ExitPortals = {}
HYPERDRIVE.Hyperspace.DimensionalPockets = {}
HYPERDRIVE.Hyperspace.TemporalAnomalies = {}
HYPERDRIVE.Hyperspace.AncientSentinels = {}
HYPERDRIVE.Hyperspace.DimensionalRifts = {}

-- Stargate-themed hyperspace layers
HYPERDRIVE.Hyperspace.Layers = {
    {name = "Subspace", depth = 0, stability = 0.99, energy_cost = 1.0},
    {name = "Hyperspace", depth = 1, stability = 0.95, energy_cost = 0.8},
    {name = "Ancient Conduit", depth = 2, stability = 0.90, energy_cost = 0.6},
    {name = "Void Between", depth = 3, stability = 0.80, energy_cost = 0.4},
    {name = "Ascended Realm", depth = 4, stability = 0.70, energy_cost = 0.2}
}

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

-- Enhanced hyperspace position calculation with layer support
function HYPERDRIVE.Hyperspace.GetHyperspacePosition(origin, destination, layer)
    local center = HYPERDRIVE.Hyperspace.Config.DimensionCenter
    local size = HYPERDRIVE.Hyperspace.Config.DimensionSize
    layer = layer or 1 -- Default to standard hyperspace layer

    -- Create a unique position in hyperspace based on origin and destination
    local hash = util.CRC(tostring(origin) .. tostring(destination))
    local normalizedHash = (hash % 10000) / 10000 -- Normalize to 0-1

    -- Layer-specific positioning
    local layerData = HYPERDRIVE.Hyperspace.Layers[layer + 1] or HYPERDRIVE.Hyperspace.Layers[2]
    local layerOffset = layerData.depth * 10000 -- Vertical separation between layers

    -- Generate position within hyperspace bounds with layer offset
    local x = center.x + (normalizedHash - 0.5) * size * 0.8
    local y = center.y + (math.sin(normalizedHash * math.pi * 2) * size * 0.4)
    local z = center.z + layerOffset + (math.cos(normalizedHash * math.pi * 4) * 1000)

    return Vector(x, y, z), layerData
end

-- Create Stargate-themed hyperspace window (inspired by TARDIS materialization)
function HYPERDRIVE.Hyperspace.CreateHyperspaceWindow(position, size, isEntry)
    if CLIENT then return end

    local window = ents.Create("prop_physics")
    if not IsValid(window) then return nil end

    window:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    window:SetPos(position)
    window:SetMaterial("effects/asc_hyperspace_portal")
    window:SetColor(Color(100, 150, 255, 200)) -- Blue Stargate-like color
    window:SetCollisionGroup(COLLISION_GROUP_WORLD)
    window:Spawn()

    -- Make it non-solid but visible
    window:SetSolid(SOLID_NONE)
    window:SetMoveType(MOVETYPE_NONE)

    -- Add swirling effect
    if isEntry then
        window:SetAngularVelocity(Vector(0, 0, 180)) -- Rotate like stargate event horizon
    end

    -- Add particle effects
    local effectData = EffectData()
    effectData:SetOrigin(position)
    effectData:SetScale(size)
    effectData:SetMagnitude(isEntry and 1 or 2)
    util.Effect("asc_hyperspace_portal", effectData)

    -- Add sound effects
    window:EmitSound("hyperdrive/hyperspace_window_open.wav", 75, 100)

    -- Schedule removal
    timer.Simple(isEntry and 5 or 3, function()
        if IsValid(window) then
            window:EmitSound("hyperdrive/hyperspace_window_close.wav", 75, 100)
            window:Remove()
        end
    end)

    return window
end

-- Enhanced 4-Stage Stargate Hyperspace Entry System
function HYPERDRIVE.Hyperspace.EnterHyperspace(engine, destination, travelTime)
    if not IsValid(engine) then return false end
    if CLIENT then return false end
    if not HYPERDRIVE.Hyperspace.Config.EnableStargateHyperspace then
        return HYPERDRIVE.Hyperspace.EnterHyperspaceClassic(engine, destination, travelTime)
    end

    local shipPos = engine:GetPos()
    local shipAng = engine:GetAngles()
    local distance = shipPos:Distance(destination)

    HYPERDRIVE.Hyperspace.Log("Initiating 4-stage Stargate hyperspace entry", "STARGATE_ENTRY")

    -- Calculate total travel time based on distance and Stargate mechanics
    local calculatedTravelTime = math.max(
        HYPERDRIVE.Hyperspace.Config.InitiationTime +
        HYPERDRIVE.Hyperspace.Config.WindowOpenTime +
        (distance / 50000) + 2, -- Base travel time
        travelTime or 5
    )

    -- Create hyperspace travel data
    local hyperspaceData = {
        engine = engine,
        destination = destination,
        startPos = shipPos,
        startAng = shipAng,
        travelTime = calculatedTravelTime,
        stage = 1,
        stageStartTime = CurTime(),
        totalStartTime = CurTime(),
        entities = {},
        players = {}
    }

    -- Store hyperspace data
    local travelId = engine:EntIndex()
    HYPERDRIVE.Hyperspace.ActiveTravels = HYPERDRIVE.Hyperspace.ActiveTravels or {}
    HYPERDRIVE.Hyperspace.ActiveTravels[travelId] = hyperspaceData

    -- Stage 1: Initiation and Energy Buildup (Stargate-themed)
    HYPERDRIVE.Hyperspace.StageInitiation(hyperspaceData)

    -- Stage 2: Window Opening (after initiation time)
    timer.Simple(HYPERDRIVE.Hyperspace.Config.InitiationTime, function()
        if not IsValid(engine) then return end
        hyperspaceData.stage = 2
        hyperspaceData.stageStartTime = CurTime()

        HYPERDRIVE.Hyperspace.StageWindowOpening(hyperspaceData)

        -- Stage 3: Hyperspace Travel (after window opening time)
        timer.Simple(HYPERDRIVE.Hyperspace.Config.WindowOpenTime, function()
            if not IsValid(engine) then return end
            hyperspaceData.stage = 3
            hyperspaceData.stageStartTime = CurTime()

            HYPERDRIVE.Hyperspace.StageHyperspaceTravel(hyperspaceData)

            -- Stage 4: Exit and System Stabilization (after travel time)
            local actualTravelTime = calculatedTravelTime -
                HYPERDRIVE.Hyperspace.Config.InitiationTime -
                HYPERDRIVE.Hyperspace.Config.WindowOpenTime

            timer.Simple(actualTravelTime, function()
                if not IsValid(engine) then return end
                hyperspaceData.stage = 4
                hyperspaceData.stageStartTime = CurTime()

                HYPERDRIVE.Hyperspace.StageExit(hyperspaceData)
            end)
        end)
    end)

    return true
end

-- Stage 1: Initiation with energy surges and coordinate calculation (Stargate-authentic)
function HYPERDRIVE.Hyperspace.StageInitiation(hyperspaceData)
    local engine = hyperspaceData.engine
    local destination = hyperspaceData.destination

    HYPERDRIVE.Hyperspace.Log("Stage 1: Initiation - Energy buildup and coordinate calculation", "STARGATE_STAGE1")

    -- Stargate-style energy buildup with visible surges
    local shipPos = engine:GetPos()

    -- Multiple energy surge effects building up
    for i = 1, 3 do
        timer.Simple(i * 0.5, function()
            if IsValid(engine) then
                local effectData = EffectData()
                effectData:SetOrigin(shipPos)
                effectData:SetScale(30 + (i * 20))
                effectData:SetMagnitude(i)
                util.Effect("asc_stargate_energy_surge", effectData)

                -- Increasing intensity sound
                engine:EmitSound("asc/hyperspace/energy_buildup_" .. i .. ".wav", 70 + (i * 10), 90 + (i * 5))
            end
        end)
    end

    -- Coordinate calculation with gravitational anomaly scanning
    if engine.SetStatus then
        engine:SetStatus("Scanning for gravitational anomalies...")

        timer.Simple(1, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Calculating hyperspace coordinates...")
            end
        end)

        timer.Simple(2, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Hyperdrive charging...")
            end
        end)
    end

    -- Stargate-style energy buildup with ship vibrations
    if engine.GetPhysicsObject and IsValid(engine:GetPhysicsObject()) then
        local phys = engine:GetPhysicsObject()
        for i = 1, 6 do
            timer.Simple(i * 0.5, function()
                if IsValid(phys) then
                    local vibration = VectorRand() * (5 + i * 2)
                    phys:ApplyForceCenter(vibration)
                end
            end)
        end
    end

    -- Energy consumption for charging
    if HYPERDRIVE.SB3Resources then
        local energyCost = 200 + (hyperspaceData.startPos:Distance(destination) / 100)
        HYPERDRIVE.SB3Resources.ConsumeResource(engine, "energy", energyCost)
    end

    -- Notify nearby players
    HYPERDRIVE.Hyperspace.NotifyNearbyPlayers(engine, "Hyperdrive charging - stand clear!", 1000)
end

-- Stage 2: Window opening with blue/purple swirling energy tunnel (Stargate-authentic)
function HYPERDRIVE.Hyperspace.StageWindowOpening(hyperspaceData)
    local engine = hyperspaceData.engine
    local shipPos = hyperspaceData.startPos

    HYPERDRIVE.Hyperspace.Log("Stage 2: Opening hyperspace window", "STARGATE_STAGE2")

    -- Calculate window position in front of ship
    local windowPos = shipPos + engine:GetForward() * 300
    local windowSize = HYPERDRIVE.Hyperspace.Config.WindowSize

    -- Create Stargate-style hyperspace window with progressive opening
    local window = HYPERDRIVE.Hyperspace.CreateStargateHyperspaceWindow(windowPos, windowSize)
    hyperspaceData.hyperspaceWindow = window

    -- Progressive window opening with multiple stages
    for i = 1, 4 do
        timer.Simple(i * 0.5, function()
            if IsValid(engine) then
                local effectData = EffectData()
                effectData:SetOrigin(windowPos)
                effectData:SetScale(windowSize * (i * 0.25))
                effectData:SetMagnitude(i)
                effectData:SetRadius(windowSize)

                -- Blue/purple swirling energy with ripple effects
                util.Effect("asc_stargate_hyperspace_window", effectData)

                -- Ripple effects expanding outward
                if HYPERDRIVE.Hyperspace.Config.WindowRippleEffects then
                    local rippleData = EffectData()
                    rippleData:SetOrigin(windowPos)
                    rippleData:SetScale(windowSize * i * 0.5)
                    rippleData:SetMagnitude(4 - i) -- Decreasing intensity
                    util.Effect("asc_hyperspace_ripple", rippleData)
                end
            end
        end)
    end

    -- Stargate-style window opening sound sequence
    engine:EmitSound("asc/hyperspace/window_opening.wav", 100, 90)

    timer.Simple(1, function()
        if IsValid(engine) then
            engine:EmitSound("asc/hyperspace/window_stabilizing.wav", 90, 95)
        end
    end)

    -- Status updates during window opening
    if engine.SetStatus then
        engine:SetStatus("Tearing hyperspace window...")

        timer.Simple(1, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Hyperspace window stabilizing...")
            end
        end)

        timer.Simple(1.8, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Hyperspace window open - initiating transit")
            end
        end)
    end

    -- Window stabilization effects
    if HYPERDRIVE.Hyperspace.Config.WindowStabilization then
        timer.Simple(1.5, function()
            if IsValid(engine) then
                local stabilizeData = EffectData()
                stabilizeData:SetOrigin(windowPos)
                stabilizeData:SetScale(windowSize)
                stabilizeData:SetMagnitude(2)
                util.Effect("asc_hyperspace_stabilize", stabilizeData)
            end
        end)
    end

    -- Notify nearby players of window opening
    HYPERDRIVE.Hyperspace.NotifyNearbyPlayers(engine, "Hyperspace window opening - do not approach!", 1500)
end

-- Stage 3: Hyperspace travel with stretched starlines and dimensional visuals (Stargate-authentic)
function HYPERDRIVE.Hyperspace.StageHyperspaceTravel(hyperspaceData)
    local engine = hyperspaceData.engine
    local destination = hyperspaceData.destination
    local travelTime = hyperspaceData.travelTime

    HYPERDRIVE.Hyperspace.Log("Stage 3: Hyperspace travel - Dimensional transit", "STARGATE_STAGE3")

    local shipPos = hyperspaceData.startPos
    local hyperspacePos, layerData = HYPERDRIVE.Hyperspace.GetHyperspacePosition(shipPos, destination, 1)

    -- Move ship and all attached entities to hyperspace dimension
    HYPERDRIVE.Hyperspace.MoveToHyperspace(hyperspaceData, hyperspacePos, layerData)

    -- Stargate-style stretched starlines effect (continuous during travel)
    local starlinesTimer = timer.Create("starlines_" .. engine:EntIndex(), 0.1, 0, function()
        if IsValid(engine) and hyperspaceData.stage == 3 then
            local effectData = EffectData()
            effectData:SetOrigin(engine:GetPos())
            effectData:SetStart(destination)
            effectData:SetScale(300)
            effectData:SetMagnitude(travelTime)
            effectData:SetRadius(100)
            util.Effect("asc_stargate_starlines", effectData)
        else
            timer.Remove("starlines_" .. engine:EntIndex())
        end
    end)

    -- Dimensional tunnel visuals (abstract hyperspace environment)
    if HYPERDRIVE.Hyperspace.Config.DimensionalVisuals then
        HYPERDRIVE.Hyperspace.CreateStargateDimensionalTunnel(engine, hyperspacePos, travelTime)
    end

    -- Hyperspace turbulence effects
    if HYPERDRIVE.Hyperspace.Config.HyperspaceTurbulence then
        HYPERDRIVE.Hyperspace.ApplyHyperspaceTurbulence(engine, travelTime)
    end

    -- Continuous hyperspace travel sound
    engine:EmitSound("asc/hyperspace/travel_loop.wav", 75, 100)

    -- Status updates during travel
    if engine.SetStatus then
        local layerName = layerData and layerData.name or "Hyperspace"
        engine:SetStatus("Traveling through " .. layerName .. "...")

        -- Periodic status updates
        timer.Simple(travelTime * 0.3, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Hyperspace transit 30% complete...")
            end
        end)

        timer.Simple(travelTime * 0.6, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Hyperspace transit 60% complete...")
            end
        end)

        timer.Simple(travelTime * 0.9, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Preparing for hyperspace exit...")
            end
        end)
    end

    -- Navigation hazard detection (gravitational wells)
    if HYPERDRIVE.Hyperspace.Config.NavigationHazards then
        HYPERDRIVE.Hyperspace.CheckNavigationHazards(hyperspaceData)
    end

    -- Apply enhanced dimensional effects
    HYPERDRIVE.Hyperspace.ApplyStargateHyperspaceEffects(hyperspaceData)
end

-- Stage 4: Exit with light flash and system stabilization (Stargate-authentic)
function HYPERDRIVE.Hyperspace.StageExit(hyperspaceData)
    local engine = hyperspaceData.engine
    local destination = hyperspaceData.destination

    HYPERDRIVE.Hyperspace.Log("Stage 4: Exit - Light flash and system stabilization", "STARGATE_STAGE4")

    -- Stop travel effects
    timer.Remove("starlines_" .. engine:EntIndex())

    -- Create Stargate-style exit window at destination
    local exitWindow = HYPERDRIVE.Hyperspace.CreateStargateHyperspaceWindow(destination,
        HYPERDRIVE.Hyperspace.Config.WindowSize * 1.2, false)

    -- Intense light flash effect on exit (signature Stargate exit)
    local flashIntensity = HYPERDRIVE.Hyperspace.Config.ExitFlashIntensity
    local effectData = EffectData()
    effectData:SetOrigin(destination)
    effectData:SetScale(200 * flashIntensity)
    effectData:SetMagnitude(5)
    effectData:SetRadius(300)
    util.Effect("asc_stargate_exit_flash", effectData)

    -- Energy shockwave expanding from exit point
    if HYPERDRIVE.Hyperspace.Config.ExitShockwave then
        timer.Simple(0.2, function()
            local shockwaveData = EffectData()
            shockwaveData:SetOrigin(destination)
            shockwaveData:SetScale(500)
            shockwaveData:SetMagnitude(3)
            util.Effect("asc_hyperspace_shockwave", shockwaveData)
        end)
    end

    -- Move ship and all entities from hyperspace to destination
    HYPERDRIVE.Hyperspace.MoveFromHyperspace(hyperspaceData, destination)

    -- Stargate-style exit sound sequence
    engine:EmitSound("asc/hyperspace/exit_flash.wav", 100, 95)

    timer.Simple(0.5, function()
        if IsValid(engine) then
            engine:EmitSound("asc/hyperspace/systems_stabilizing.wav", 90, 100)
        end
    end)

    -- Progressive system stabilization
    if HYPERDRIVE.Hyperspace.Config.SystemStabilization then
        timer.Simple(1, function()
            if IsValid(engine) then
                HYPERDRIVE.Hyperspace.StabilizeStargateSystems(hyperspaceData)
            end
        end)
    end

    -- Status updates during exit and stabilization
    if engine.SetStatus then
        engine:SetStatus("Exiting hyperspace...")

        timer.Simple(1, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Systems stabilizing...")
            end
        end)

        timer.Simple(3, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Hyperspace travel complete - all systems nominal")
            end
        end)

        timer.Simple(5, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus("Ready for next jump")
            end
        end)
    end

    -- Clean up hyperspace data
    timer.Simple(5, function()
        HYPERDRIVE.Hyperspace.CleanupHyperspaceTravel(engine:EntIndex())
    end)

    -- Notify nearby players of successful exit
    HYPERDRIVE.Hyperspace.NotifyNearbyPlayers(engine, "Ship has exited hyperspace", 2000)
end

-- TARDIS-inspired dimensional pocket creation
function HYPERDRIVE.Hyperspace.CreateDimensionalPocket(engine, size)
    if not HYPERDRIVE.Hyperspace.Config.DimensionalPockets then return nil end
    if CLIENT then return nil end

    local pocketId = engine:EntIndex() .. "_pocket_" .. CurTime()
    local pocketCenter = engine:GetPos() + Vector(0, 0, 50000) -- High above normal space

    local pocket = {
        id = pocketId,
        center = pocketCenter,
        size = size or 1000,
        engine = engine,
        created = CurTime(),
        entities = {},
        stability = 1.0
    }

    HYPERDRIVE.Hyperspace.DimensionalPockets[pocketId] = pocket

    -- Create pocket boundaries
    HYPERDRIVE.Hyperspace.CreatePocketBoundaries(pocket)

    HYPERDRIVE.Hyperspace.Log("Created dimensional pocket: " .. pocketId, "POCKET")
    return pocket
end

-- Apply time distortion effects (TARDIS-inspired)
function HYPERDRIVE.Hyperspace.ApplyTimeDistortion(engine, travelTime)
    if not HYPERDRIVE.Hyperspace.Config.TimeDistortion then return end

    -- Time flows differently in hyperspace
    local timeScale = 0.8 -- Time moves 20% slower in hyperspace

    -- Apply to all entities in the ship
    local shipEntities = HYPERDRIVE.Hyperspace.GetShipEntities(engine)
    for _, ent in ipairs(shipEntities) do
        if IsValid(ent) and ent:IsPlayer() then
            -- Notify player of time distortion
            ent:ChatPrint("[Hyperspace] Time distortion detected - temporal shielding active")

            -- Apply temporal shielding effect
            if HYPERDRIVE.Hyperspace.Config.TemporalShielding then
                ent:SetLagCompensated(false) -- Protect from time effects
                timer.Simple(travelTime, function()
                    if IsValid(ent) then
                        ent:SetLagCompensated(true)
                    end
                end)
            end
        end
    end
end

-- Apply spatial folding mechanics (TARDIS-inspired)
function HYPERDRIVE.Hyperspace.ApplySpatialFolding(engine, destination)
    if not HYPERDRIVE.Hyperspace.Config.SpatialFolding then return end

    -- Space-time folding reduces effective travel distance
    local currentPos = engine:GetPos()
    local actualDistance = currentPos:Distance(destination)
    local foldedDistance = actualDistance * 0.1 -- 90% distance reduction through folding

    HYPERDRIVE.Hyperspace.Log("Spatial folding: " .. math.floor(actualDistance) .. " -> " .. math.floor(foldedDistance), "FOLD")

    -- Visual representation of space folding
    local effectData = EffectData()
    effectData:SetOrigin(currentPos)
    effectData:SetStart(destination)
    effectData:SetScale(foldedDistance / actualDistance)
    util.Effect("asc_spatial_fold", effectData)
end

-- Enhanced system stabilization
function HYPERDRIVE.Hyperspace.StabilizeSystems(engine)
    HYPERDRIVE.Hyperspace.Log("Stabilizing ship systems after hyperspace travel", "STABILIZE")

    -- Restore normal physics
    local shipEntities = HYPERDRIVE.Hyperspace.GetShipEntities(engine)
    for _, ent in ipairs(shipEntities) do
        if IsValid(ent) then
            -- Restore normal gravity
            if ent:IsPlayer() then
                ent:SetGravity(1.0)
                ent:SetLagCompensated(true)
                ent:ChatPrint("[Hyperspace] Systems stabilized - welcome to normal space")
            end

            -- Clear hyperspace markers
            ent.InHyperspace = nil
            ent.HyperspaceLayer = nil
            ent.TemporalShielding = nil
        end
    end

    -- Restore engine systems
    if engine.SetStatus then
        engine:SetStatus("All systems nominal")
    end

    -- Apply post-hyperspace effects
    local effectData = EffectData()
    effectData:SetOrigin(engine:GetPos())
    effectData:SetScale(100)
    util.Effect("asc_system_stabilization", effectData)
end

-- Exit hyperspace (enhanced)
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

    player:ChatPrint("[Advanced Space Combat] Entering hyperspace...")
end

-- Notify player exiting hyperspace
function HYPERDRIVE.Hyperspace.NotifyPlayerExitHyperspace(player)
    if not IsValid(player) then return end

    net.Start("hyperdrive_hyperspace_exit")
    net.Send(player)

    player:ChatPrint("[Advanced Space Combat] Exiting hyperspace...")
end

-- Logging function
function HYPERDRIVE.Hyperspace.Log(message, category)
    if HYPERDRIVE.Debug then
        HYPERDRIVE.Debug.Info("HYPERSPACE: " .. message, category or "HYPERSPACE")
    else
        print("[Hyperdrive Hyperspace] " .. message)
    end
end

-- Register hyperspace updates with master scheduler
timer.Simple(9, function()
    if ASC and ASC.MasterScheduler then
        ASC.MasterScheduler.RegisterTask("HyperdriveHyperspace", "Medium", function()
            HYPERDRIVE.Hyperspace.Think()
        end, 1.0) -- 1 FPS for hyperspace effects
    else
        -- Fallback hook if master scheduler not available
        hook.Add("Think", "HyperdriveHyperspaceThink", function()
            if math.random() < 0.1 then -- 10% chance per frame to reduce performance impact
                HYPERDRIVE.Hyperspace.Think()
            end
        end)
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

-- ========================================
-- Enhanced Stargate Hyperspace Functions
-- ========================================

-- Create Stargate-style hyperspace window
function HYPERDRIVE.Hyperspace.CreateStargateHyperspaceWindow(pos, size, isEntry)
    if CLIENT then return nil end

    local window = {
        position = pos,
        size = size,
        isEntry = isEntry,
        created = CurTime(),
        stability = 0.0
    }

    -- Progressive window stabilization
    timer.Create("window_stabilize_" .. tostring(pos), 0.1, 20, function()
        window.stability = math.min(1.0, window.stability + 0.05)
    end)

    return window
end

-- Move entities to hyperspace with Stargate mechanics
function HYPERDRIVE.Hyperspace.MoveToHyperspace(hyperspaceData, hyperspacePos, layerData)
    local engine = hyperspaceData.engine

    -- Get all ship entities using ship core system
    local shipEntities = {}
    if HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(engine)
        if ship then
            shipEntities = ship:GetEntities() or {}
        end
    end

    -- Fallback entity detection
    if #shipEntities == 0 then
        shipEntities = ents.FindInSphere(engine:GetPos(), 2000)
    end

    -- Move each entity to hyperspace
    for _, ent in ipairs(shipEntities) do
        if IsValid(ent) then
            -- Store original position and angle
            ent.HyperspaceOriginalPos = ent:GetPos()
            ent.HyperspaceOriginalAng = ent:GetAngles()

            -- Calculate offset from engine
            local offset = ent:GetPos() - engine:GetPos()
            local newPos = hyperspacePos + offset

            -- Move to hyperspace
            ent:SetPos(newPos)
            ent.InHyperspace = true
            ent.HyperspaceLayer = layerData

            -- Apply hyperspace physics
            if ent:IsPlayer() then
                ent:SetGravity(0.3) -- Reduced gravity in hyperspace
                HYPERDRIVE.Hyperspace.NotifyPlayerEnterHyperspace(ent, hyperspaceData)
            end

            table.insert(hyperspaceData.entities, ent)
        end
    end
end

-- Move entities from hyperspace back to normal space
function HYPERDRIVE.Hyperspace.MoveFromHyperspace(hyperspaceData, destination)
    local engine = hyperspaceData.engine

    for _, ent in ipairs(hyperspaceData.entities) do
        if IsValid(ent) then
            -- Calculate offset from engine
            local offset = ent:GetPos() - engine:GetPos()
            local newPos = destination + offset

            -- Move back to normal space
            ent:SetPos(newPos)
            ent.InHyperspace = false
            ent.HyperspaceLayer = nil

            -- Restore normal physics
            if ent:IsPlayer() then
                ent:SetGravity(1.0)
                HYPERDRIVE.Hyperspace.NotifyPlayerExitHyperspace(ent)
            end
        end
    end
end

-- Create Stargate dimensional tunnel effects
function HYPERDRIVE.Hyperspace.CreateStargateDimensionalTunnel(engine, hyperspacePos, travelTime)
    -- Create tunnel walls with energy patterns
    for i = 1, 8 do
        timer.Simple(i * 0.2, function()
            if IsValid(engine) then
                local effectData = EffectData()
                effectData:SetOrigin(hyperspacePos)
                effectData:SetScale(100 + (i * 50))
                effectData:SetMagnitude(travelTime)
                effectData:SetRadius(200)
                util.Effect("asc_dimensional_tunnel", effectData)
            end
        end)
    end
end

-- Apply hyperspace turbulence effects
function HYPERDRIVE.Hyperspace.ApplyHyperspaceTurbulence(engine, travelTime)
    local turbulenceTimer = timer.Create("turbulence_" .. engine:EntIndex(), 0.5, 0, function()
        if IsValid(engine) then
            -- Random ship movement in hyperspace
            local turbulence = VectorRand() * 10
            local phys = engine:GetPhysicsObject()
            if IsValid(phys) then
                phys:ApplyForceCenter(turbulence)
            end

            -- Turbulence effects
            local effectData = EffectData()
            effectData:SetOrigin(engine:GetPos())
            effectData:SetScale(50)
            util.Effect("asc_hyperspace_turbulence", effectData)
        else
            timer.Remove("turbulence_" .. engine:EntIndex())
        end
    end)

    -- Stop turbulence after travel time
    timer.Simple(travelTime, function()
        timer.Remove("turbulence_" .. engine:EntIndex())
    end)
end

-- Check for navigation hazards (gravitational wells)
function HYPERDRIVE.Hyperspace.CheckNavigationHazards(hyperspaceData)
    local engine = hyperspaceData.engine

    -- Simulate gravitational anomaly detection
    if math.random() < 0.1 then -- 10% chance of hazard
        timer.Simple(math.random(1, 3), function()
            if IsValid(engine) then
                -- Create hazard effect
                local effectData = EffectData()
                effectData:SetOrigin(engine:GetPos())
                effectData:SetScale(150)
                effectData:SetMagnitude(3)
                util.Effect("asc_gravitational_anomaly", effectData)

                -- Notify players
                HYPERDRIVE.Hyperspace.NotifyNearbyPlayers(engine,
                    "Warning: Gravitational anomaly detected!", 2000)

                -- Apply course correction
                if engine.SetStatus then
                    engine:SetStatus("Adjusting course to avoid gravitational well...")
                end
            end
        end)
    end
end

-- Apply enhanced Stargate hyperspace effects
function HYPERDRIVE.Hyperspace.ApplyStargateHyperspaceEffects(hyperspaceData)
    local engine = hyperspaceData.engine

    -- Ancient technology bonuses
    if HYPERDRIVE.Hyperspace.Config.AncientTechnology then
        -- Check for Ancient tech integration
        if HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.HasAncientTech and
           HYPERDRIVE.Stargate.HasAncientTech(engine) then
            -- Reduce travel time by 20%
            hyperspaceData.travelTime = hyperspaceData.travelTime * 0.8

            if engine.SetStatus then
                engine:SetStatus("Ancient technology detected - enhanced hyperspace efficiency")
            end
        end
    end

    -- ZPM power boost
    if HYPERDRIVE.Hyperspace.Config.ZPMPowerBoost then
        -- Check for ZPM integration
        if HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.HasZPM and
           HYPERDRIVE.Stargate.HasZPM(engine) then
            -- Increase stability and reduce energy consumption
            if engine.SetStatus then
                engine:SetStatus("ZPM power detected - hyperspace window stabilized")
            end
        end
    end
end

-- Stabilize Stargate systems after hyperspace exit
function HYPERDRIVE.Hyperspace.StabilizeStargateSystems(hyperspaceData)
    local engine = hyperspaceData.engine

    -- Progressive system stabilization
    local stabilizationSteps = {
        "Hyperspace window collapsed",
        "Inertial dampeners online",
        "Navigation systems nominal",
        "Hyperdrive cooling down",
        "All systems stabilized"
    }

    for i, step in ipairs(stabilizationSteps) do
        timer.Simple(i * 0.5, function()
            if IsValid(engine) and engine.SetStatus then
                engine:SetStatus(step)
            end
        end)
    end

    -- System stabilization effects
    for i = 1, 3 do
        timer.Simple(i * 0.8, function()
            if IsValid(engine) then
                local effectData = EffectData()
                effectData:SetOrigin(engine:GetPos())
                effectData:SetScale(80 - (i * 20))
                effectData:SetMagnitude(4 - i)
                util.Effect("asc_system_stabilization", effectData)
            end
        end)
    end
end

-- Notify nearby players
function HYPERDRIVE.Hyperspace.NotifyNearbyPlayers(engine, message, radius)
    local nearbyPlayers = ents.FindInSphere(engine:GetPos(), radius or 1000)

    for _, ent in ipairs(nearbyPlayers) do
        if IsValid(ent) and ent:IsPlayer() then
            ent:ChatPrint("[Hyperspace] " .. message)
        end
    end
end

-- Cleanup hyperspace travel data
function HYPERDRIVE.Hyperspace.CleanupHyperspaceTravel(entIndex)
    if HYPERDRIVE.Hyperspace.ActiveTravels then
        HYPERDRIVE.Hyperspace.ActiveTravels[entIndex] = nil
    end

    -- Remove any remaining timers
    timer.Remove("starlines_" .. entIndex)
    timer.Remove("turbulence_" .. entIndex)
    timer.Remove("window_stabilize_" .. entIndex)
end

print("[Advanced Space Combat] Enhanced Stargate Hyperspace System v3.0 loaded")
