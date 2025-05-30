-- Hyperdrive Stargate Carter Addon Pack Integration
-- This file adds comprehensive Stargate CAP support to the hyperdrive system
-- Enhanced with 4-stage Stargate hyperdrive travel system

if not StarGate then return end -- Exit if Stargate CAP is not installed

HYPERDRIVE.Stargate = HYPERDRIVE.Stargate or {}

-- Stargate integration settings
HYPERDRIVE.Stargate.Config = {
    RequireNaquadah = true,             -- Require naquadah for enhanced jumps
    NaquadahConsumption = 10,           -- Naquadah per jump
    ZPMBonus = 2.0,                     -- Energy bonus with ZPM power
    IrisProtection = true,              -- Respect iris/shield protection
    DHDIntegration = true,              -- Integrate with DHD systems
    GateNetworkAccess = true,           -- Access gate network coordinates
    AncientTechBonus = 1.5,            -- Bonus for Ancient technology
    GoauldTechPenalty = 0.8,           -- Penalty for Goa'uld technology
    AsgardTechBonus = 1.3,             -- Bonus for Asgard technology
    OriTechBonus = 1.8,                -- Bonus for Ori technology

    -- 4-Stage Travel System Configuration (Based on Stargate Lore)
    StageSystem = {
        EnableFourStageTravel = true,   -- Enable enhanced 4-stage travel

        -- Stage 1: Initiation/Charging the Hyperdrive
        InitiationDuration = 4.0,       -- Duration of charging phase (seconds)
        InitiationEffects = true,       -- Enable energy surge and vibration effects
        InitiationSounds = true,        -- Enable charging sound effects
        ShowCoordinateCalculation = true, -- Display coordinate calculation process
        EnergyBuildupSteps = 5,         -- Number of energy buildup steps
        SpatialChartCheck = true,       -- Check for gravitational anomalies

        -- Stage 2: Opening a Hyperspace Window
        WindowOpenDuration = 3.0,       -- Duration of window opening (seconds)
        WindowEffects = true,           -- Enable blue/purple swirling energy tunnel
        WindowSounds = true,            -- Enable dimensional tear sounds
        RipplingEffects = true,         -- Enable rippling energy effects
        DimensionalTearVisuals = true,  -- Show tearing of normal space
        HigherDimensionalRealm = true,  -- Access to higher-dimensional hyperspace

        -- Stage 3: Travel Through Hyperspace
        TravelEffects = true,           -- Enable hyperspace dimension effects
        TravelSounds = true,            -- Enable ambient hyperspace sounds
        StarlineEffects = true,         -- Enable stretched starlines (relativistic effects)
        DimensionalVisuals = true,      -- Enable abstract dimensional tunnel visuals
        NoRelativisticEffects = true,   -- Ships don't experience time dilation
        NavigationPrecision = true,     -- Precise navigation to avoid gravitational wells
        IntergalacticCapable = true,    -- Allow intergalactic journeys

        -- Stage 4: Exiting Hyperspace
        ExitDuration = 2.0,             -- Duration of exit phase (seconds)
        ExitEffects = true,             -- Enable bright flash and shimmer effects
        ExitSounds = true,              -- Enable exit sound effects
        StabilizationTime = 3.0,        -- Time for system stabilization
        HyperspaceWindowCollapse = true, -- Show hyperspace window collapsing
        NormalPhysicsResume = true,     -- Resume normal space physics
    }
}

-- Stargate technology types
HYPERDRIVE.Stargate.TechTypes = {
    Ancient = "ancient",
    Goauld = "goauld",
    Asgard = "asgard",
    Ori = "ori",
    Tau_ri = "tau_ri",
    Wraith = "wraith"
}

-- 4-Stage Travel System State Tracking
HYPERDRIVE.Stargate.ActiveTravels = {}
HYPERDRIVE.Stargate.TravelStages = {
    INITIATION = 1,
    WINDOW_OPENING = 2,
    HYPERSPACE_TRAVEL = 3,
    EXIT_STABILIZATION = 4
}

-- Enhanced 4-Stage Stargate Hyperdrive Travel System
function HYPERDRIVE.Stargate.StartFourStageTravel(engine, destination, entities)
    if not IsValid(engine) then return false end
    if not HYPERDRIVE.Stargate.Config.StageSystem.EnableFourStageTravel then
        -- Fall back to standard travel
        return HYPERDRIVE.Hyperspace.EnterHyperspace(engine, destination, entities)
    end

    -- Get Stargate data (optional - provides bonuses if available)
    local stargateData = HYPERDRIVE.Stargate.HasStargateTech(engine)
    if not stargateData.hasGate then
        -- Create default data for non-Stargate engines
        stargateData = {
            hasGate = false,
            hasDHD = false,
            hasZPM = false,
            hasNaquadah = false,
            techLevel = "tau_ri", -- Basic technology level
            powerLevel = 0
        }

        if GetConVar("developer"):GetInt() > 0 then
            print("[Stargate 4-Stage] No Stargate technology detected, using standard 4-stage travel")
        end
    else
        -- Check resource requirements only if Stargate tech is available
        local success, message = HYPERDRIVE.Stargate.ConsumeResources(engine, "jump")
        if not success then
            return false, message
        end

        if GetConVar("developer"):GetInt() > 0 then
            print("[Stargate 4-Stage] Stargate technology detected, using enhanced 4-stage travel")
        end
    end

    -- Check destination protection (only if Stargate tech is available)
    if stargateData.hasGate then
        local protected, reason = HYPERDRIVE.Stargate.IsDestinationProtected(destination)
        if protected then
            return false, reason
        end
    end

    -- Create travel data
    local travelData = {
        engine = engine,
        entities = entities or {},
        origin = engine:GetPos(),
        destination = destination,
        stargateData = stargateData,
        currentStage = HYPERDRIVE.Stargate.TravelStages.INITIATION,
        startTime = CurTime(),
        stageStartTime = CurTime(),
        techBonus = HYPERDRIVE.Stargate.GetTechBonus(stargateData.techLevel),
        distance = engine:GetPos():Distance(destination)
    }

    -- Store travel data
    HYPERDRIVE.Stargate.ActiveTravels[engine:EntIndex()] = travelData

    -- Start Stage 1: Initiation/Charging
    HYPERDRIVE.Stargate.StartInitiationStage(travelData)

    HYPERDRIVE.Stargate.Log("Started 4-stage Stargate hyperdrive travel", "TRAVEL")
    return true
end

-- Stage 1: Initiation/Charging the Hyperdrive (Enhanced with Stargate Lore)
function HYPERDRIVE.Stargate.StartInitiationStage(travelData)
    local config = HYPERDRIVE.Stargate.Config.StageSystem
    local engine = travelData.engine
    local pos = travelData.origin

    travelData.currentStage = HYPERDRIVE.Stargate.TravelStages.INITIATION
    travelData.stageStartTime = CurTime()

    -- Send stage update to nearby players
    HYPERDRIVE.Stargate.SendStageUpdate(pos, 1, config.InitiationDuration, travelData.stargateData.techLevel, travelData.techBonus)

    -- Enhanced notification with coordinate calculation
    if config.ShowCoordinateCalculation then
        HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Hyperdrive powering up... Onboard computers calculating navigation paths.", 1500)
        timer.Simple(1.0, function()
            HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Building energy to rip open hyperspace window...", 1500)
        end)
        timer.Simple(2.5, function()
            HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Checking spatial charts for gravitational anomalies...", 1500)
        end)
    else
        HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Hyperdrive charging... Calculating hyperspace coordinates.", 1500)
    end

    -- Create enhanced charging effects with energy buildup steps
    if config.InitiationEffects then
        HYPERDRIVE.Stargate.CreateEnhancedInitiationEffects(pos, travelData.techBonus, config)
    end

    -- Create world effects using our new system
    if HYPERDRIVE.WorldEffects and HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShip(engine) or HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
        if ship then
            HYPERDRIVE.WorldEffects.CreateStargateEffects(engine, ship, "initiation")
        end
    end

    -- Play charging sounds with energy surge effects
    if config.InitiationSounds then
        HYPERDRIVE.Stargate.PlayEnhancedInitiationSounds(pos, travelData.techBonus, config)
    end

    -- Perform spatial chart check for gravitational anomalies
    if config.SpatialChartCheck then
        timer.Simple(config.InitiationDuration * 0.7, function()
            HYPERDRIVE.Stargate.PerformSpatialChartCheck(travelData)
        end)
    end

    -- Set timer for next stage
    timer.Create("StargateTravel_" .. engine:EntIndex() .. "_Stage1", config.InitiationDuration, 1, function()
        if HYPERDRIVE.Stargate.ActiveTravels[engine:EntIndex()] then
            HYPERDRIVE.Stargate.StartWindowOpeningStage(travelData)
        end
    end)

    HYPERDRIVE.Stargate.Log("Stage 1: Hyperdrive initiation and energy buildup started", "TRAVEL")
end

-- Stage 2: Opening a Hyperspace Window (Enhanced with Stargate Lore)
function HYPERDRIVE.Stargate.StartWindowOpeningStage(travelData)
    local config = HYPERDRIVE.Stargate.Config.StageSystem
    local engine = travelData.engine
    local pos = travelData.origin

    travelData.currentStage = HYPERDRIVE.Stargate.TravelStages.WINDOW_OPENING
    travelData.stageStartTime = CurTime()

    -- Send stage update to nearby players
    HYPERDRIVE.Stargate.SendStageUpdate(pos, 2, config.WindowOpenDuration, travelData.stargateData.techLevel, travelData.techBonus)

    -- Enhanced notification with dimensional tearing description
    if config.DimensionalTearVisuals then
        HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Hyperdrive tearing a hole in normal space...", 1500)
        timer.Simple(1.0, function()
            HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Accessing higher-dimensional hyperspace realm...", 1500)
        end)
        timer.Simple(2.0, function()
            HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Hyperspace window stabilizing...", 1500)
        end)
    else
        HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Opening hyperspace window...", 1500)
    end

    -- Create enhanced window opening effects with blue/purple swirling energy
    if config.WindowEffects then
        HYPERDRIVE.Stargate.CreateEnhancedWindowEffects(pos, travelData.techBonus, config)
    end

    -- Create world effects using our new system
    if HYPERDRIVE.WorldEffects and HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShip(engine) or HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
        if ship then
            HYPERDRIVE.WorldEffects.CreateStargateEffects(engine, ship, "window")
        end
    end

    -- Play dimensional tear sounds
    if config.WindowSounds then
        HYPERDRIVE.Stargate.PlayDimensionalTearSounds(pos, travelData.techBonus, config)
    end

    -- Create rippling energy effects around the window
    if config.RipplingEffects then
        timer.Simple(0.5, function()
            HYPERDRIVE.Stargate.CreateRipplingEnergyEffects(pos, travelData.techBonus)
        end)
    end

    -- Set timer for next stage
    timer.Create("StargateTravel_" .. engine:EntIndex() .. "_Stage2", config.WindowOpenDuration, 1, function()
        if HYPERDRIVE.Stargate.ActiveTravels[engine:EntIndex()] then
            HYPERDRIVE.Stargate.StartHyperspaceTravel(travelData)
        end
    end)

    HYPERDRIVE.Stargate.Log("Stage 2: Hyperspace window opening and dimensional tear initiated", "TRAVEL")
end

-- Stage 3: Travel Through Hyperspace (Enhanced with Stargate Lore)
function HYPERDRIVE.Stargate.StartHyperspaceTravel(travelData)
    local config = HYPERDRIVE.Stargate.Config.StageSystem
    local engine = travelData.engine
    local entities = travelData.entities
    local destination = travelData.destination

    travelData.currentStage = HYPERDRIVE.Stargate.TravelStages.HYPERSPACE_TRAVEL
    travelData.stageStartTime = CurTime()

    -- Calculate travel time with enhanced mechanics
    local baseTime = travelData.distance / 2000 -- Base speed
    local travelTime = math.Clamp(baseTime / travelData.techBonus, 3, 30)

    -- Intergalactic capability check
    if config.IntergalacticCapable and travelData.distance > 100000 then
        travelTime = math.Clamp(travelTime * 0.5, 5, 60) -- Faster for intergalactic journeys
        HYPERDRIVE.Stargate.NotifyPlayersInRange(travelData.origin, "Initiating intergalactic hyperspace jump...", 1500)
    end

    travelData.hyperspaceTime = travelTime

    -- Send stage update to nearby players
    HYPERDRIVE.Stargate.SendStageUpdate(travelData.origin, 3, travelTime, travelData.stargateData.techLevel, travelData.techBonus)

    -- Enhanced notifications for hyperspace travel
    if config.NoRelativisticEffects then
        HYPERDRIVE.Stargate.NotifyPlayersInRange(travelData.origin, "Entering hyperspace... No relativistic effects experienced.", 1500)
        timer.Simple(1.0, function()
            HYPERDRIVE.Stargate.NotifyPlayersInRange(travelData.origin, "Traveling at incredible speeds through higher dimensions...", 1500)
        end)
    else
        HYPERDRIVE.Stargate.NotifyPlayersInRange(travelData.origin, "Entering hyperspace...", 1500)
    end

    -- Enter hyperspace using existing system but with enhanced effects
    HYPERDRIVE.Hyperspace.EnterHyperspace(engine, destination, entities)

    -- Apply enhanced Stargate-specific hyperspace effects
    if config.TravelEffects then
        HYPERDRIVE.Stargate.CreateEnhancedHyperspaceEffects(travelData, config)
    end

    -- Create stretched starline effects (relativistic visuals)
    if config.StarlineEffects then
        HYPERDRIVE.Stargate.CreateStarlineEffects(travelData)
    end

    -- Create world effects using our new system
    if HYPERDRIVE.WorldEffects and HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShip(engine) or HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
        if ship then
            HYPERDRIVE.WorldEffects.CreateStargateEffects(engine, ship, "travel")
        end
    end

    -- Create abstract dimensional tunnel visuals
    if config.DimensionalVisuals then
        HYPERDRIVE.Stargate.CreateDimensionalTunnelEffects(travelData)
    end

    -- Play ambient hyperspace sounds
    if config.TravelSounds then
        HYPERDRIVE.Stargate.PlayAmbientHyperspaceSounds(travelData, config)
    end

    -- Navigation precision check for gravitational wells
    if config.NavigationPrecision then
        timer.Simple(travelTime * 0.3, function()
            HYPERDRIVE.Stargate.PerformNavigationCheck(travelData)
        end)
    end

    -- Set timer for exit stage
    timer.Create("StargateTravel_" .. engine:EntIndex() .. "_Stage3", travelTime, 1, function()
        if HYPERDRIVE.Stargate.ActiveTravels[engine:EntIndex()] then
            HYPERDRIVE.Stargate.StartExitStage(travelData)
        end
    end)

    HYPERDRIVE.Stargate.Log("Stage 3: Hyperspace travel initiated (" .. math.Round(travelTime, 1) .. "s)", "TRAVEL")
end

-- Stage 4: Exiting Hyperspace (Enhanced with Stargate Lore)
function HYPERDRIVE.Stargate.StartExitStage(travelData)
    local config = HYPERDRIVE.Stargate.Config.StageSystem
    local engine = travelData.engine
    local destination = travelData.destination

    travelData.currentStage = HYPERDRIVE.Stargate.TravelStages.EXIT_STABILIZATION
    travelData.stageStartTime = CurTime()

    -- Send stage update to nearby players
    HYPERDRIVE.Stargate.SendStageUpdate(destination, 4, config.ExitDuration + config.StabilizationTime, travelData.stargateData.techLevel, travelData.techBonus)

    -- Exit hyperspace using existing system
    HYPERDRIVE.Hyperspace.ExitHyperspace(engine)

    -- Enhanced notifications for hyperspace exit
    if config.HyperspaceWindowCollapse then
        HYPERDRIVE.Stargate.NotifyPlayersInRange(destination, "Emerging from hyperspace... Flash of light detected.", 1500)
        timer.Simple(0.5, function()
            HYPERDRIVE.Stargate.NotifyPlayersInRange(destination, "Hyperspace window collapsing behind ship...", 1500)
        end)
        timer.Simple(1.5, function()
            HYPERDRIVE.Stargate.NotifyPlayersInRange(destination, "Normal space physics resuming... Systems stabilizing.", 1500)
        end)
    else
        HYPERDRIVE.Stargate.NotifyPlayersInRange(destination, "Exiting hyperspace... Systems stabilizing.", 1500)
    end

    -- Create enhanced exit effects with bright flash and shimmer
    if config.ExitEffects then
        HYPERDRIVE.Stargate.CreateEnhancedExitEffects(destination, travelData.techBonus, config)
    end

    -- Create world effects using our new system
    if HYPERDRIVE.WorldEffects and HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShip(engine) or HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
        if ship then
            -- Update ship position for exit effect
            ship.center = destination
            HYPERDRIVE.WorldEffects.CreateStargateEffects(engine, ship, "exit")
        end
    end

    -- Show hyperspace window collapse
    if config.HyperspaceWindowCollapse then
        timer.Simple(0.3, function()
            HYPERDRIVE.Stargate.CreateWindowCollapseEffects(destination, travelData.techBonus)
        end)
    end

    -- Play exit sounds with dimensional closure
    if config.ExitSounds then
        HYPERDRIVE.Stargate.PlayEnhancedExitSounds(destination, travelData.techBonus, config)
    end

    -- Resume normal physics effects
    if config.NormalPhysicsResume then
        timer.Simple(config.ExitDuration, function()
            HYPERDRIVE.Stargate.ResumeNormalPhysics(travelData)
        end)
    end

    -- Set timer for stabilization completion
    timer.Create("StargateTravel_" .. engine:EntIndex() .. "_Stage4", config.ExitDuration + config.StabilizationTime, 1, function()
        if HYPERDRIVE.Stargate.ActiveTravels[engine:EntIndex()] then
            HYPERDRIVE.Stargate.CompleteFourStageTravel(travelData)
        end
    end)

    HYPERDRIVE.Stargate.Log("Stage 4: Hyperspace exit and system stabilization initiated", "TRAVEL")
end

-- Complete the 4-stage travel
function HYPERDRIVE.Stargate.CompleteFourStageTravel(travelData)
    local engine = travelData.engine
    local destination = travelData.destination

    -- Send completion update to clear stage display
    HYPERDRIVE.Stargate.SendStageUpdate(destination, 0, 0, travelData.stargateData.techLevel, travelData.techBonus)

    -- Notify completion
    HYPERDRIVE.Stargate.NotifyPlayersInRange(destination, "Hyperdrive travel complete. All systems nominal.", 1500)

    -- Clean up travel data
    HYPERDRIVE.Stargate.ActiveTravels[engine:EntIndex()] = nil

    -- Remove all timers
    for i = 1, 4 do
        timer.Remove("StargateTravel_" .. engine:EntIndex() .. "_Stage" .. i)
    end

    local totalTime = CurTime() - travelData.startTime
    HYPERDRIVE.Stargate.Log("4-stage travel completed in " .. math.Round(totalTime, 1) .. " seconds", "TRAVEL")
end

-- Check if entity has Stargate technology integration
function HYPERDRIVE.Stargate.HasStargateTech(ent)
    if not IsValid(ent) or not StarGate then return false end

    -- Check for nearby Stargate entities
    local nearbyEnts = ents.FindInSphere(ent:GetPos(), 1000)
    local stargateData = {
        hasGate = false,
        hasDHD = false,
        hasZPM = false,
        hasNaquadah = false,
        techLevel = "tau_ri",
        powerLevel = 0
    }

    for _, nearEnt in ipairs(nearbyEnts) do
        if IsValid(nearEnt) then
            local class = nearEnt:GetClass()

            -- Check for Stargate
            if string.find(class, "stargate") then
                stargateData.hasGate = true

                -- Determine technology level
                if string.find(class, "ancient") then
                    stargateData.techLevel = "ancient"
                elseif string.find(class, "ori") then
                    stargateData.techLevel = "ori"
                elseif string.find(class, "asgard") then
                    stargateData.techLevel = "asgard"
                elseif string.find(class, "goauld") then
                    stargateData.techLevel = "goauld"
                end
            end

            -- Check for DHD
            if string.find(class, "dhd") then
                stargateData.hasDHD = true
            end

            -- Check for ZPM
            if string.find(class, "zpm") then
                stargateData.hasZPM = true
                if nearEnt.GetCharge then
                    stargateData.powerLevel = nearEnt:GetCharge() or 0
                end
            end

            -- Check for Naquadah
            if string.find(class, "naquadah") then
                stargateData.hasNaquadah = true
            end
        end
    end

    return stargateData
end

-- Get technology bonus based on Stargate tech level
function HYPERDRIVE.Stargate.GetTechBonus(techLevel)
    local config = HYPERDRIVE.Stargate.Config

    if techLevel == "ancient" then
        return config.AncientTechBonus
    elseif techLevel == "ori" then
        return config.OriTechBonus
    elseif techLevel == "asgard" then
        return config.AsgardTechBonus
    elseif techLevel == "goauld" then
        return config.GoauldTechPenalty
    else
        return 1.0 -- Tau'ri baseline
    end
end

-- Calculate enhanced energy cost with Stargate factors
function HYPERDRIVE.Stargate.CalculateEnergyCost(ent, startPos, endPos, baseDistance)
    local baseCost = HYPERDRIVE.CalculateEnergyCost(baseDistance)
    local stargateData = HYPERDRIVE.Stargate.HasStargateTech(ent)

    if not stargateData.hasGate then
        return baseCost -- No Stargate integration
    end

    local modifier = 1.0

    -- Technology level bonus/penalty
    modifier = modifier * HYPERDRIVE.Stargate.GetTechBonus(stargateData.techLevel)

    -- ZPM power bonus
    if stargateData.hasZPM and stargateData.powerLevel > 50 then
        modifier = modifier * (1 / HYPERDRIVE.Stargate.Config.ZPMBonus)
    end

    -- DHD integration bonus
    if stargateData.hasDHD then
        modifier = modifier * 0.9
    end

    return baseCost * modifier
end

-- Check if destination is protected by iris or shield
function HYPERDRIVE.Stargate.IsDestinationProtected(pos)
    if not HYPERDRIVE.Stargate.Config.IrisProtection then return false end

    local nearbyEnts = ents.FindInSphere(pos, 500)
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            local class = ent:GetClass()

            -- Check for iris or shield
            if string.find(class, "iris") or string.find(class, "shield") then
                if ent.GetActive and ent:GetActive() then
                    return true, "Destination protected by " .. (string.find(class, "iris") and "iris" or "shield")
                end
            end
        end
    end

    return false
end

-- Consume Stargate resources for hyperdrive operation
function HYPERDRIVE.Stargate.ConsumeResources(ent, operation)
    if not IsValid(ent) or not StarGate then return true end

    local stargateData = HYPERDRIVE.Stargate.HasStargateTech(ent)
    if not stargateData.hasGate then return true end

    local config = HYPERDRIVE.Stargate.Config

    if operation == "jump" and config.RequireNaquadah then
        -- Find and consume naquadah
        local nearbyEnts = ents.FindInSphere(ent:GetPos(), 1000)
        local naquadahConsumed = 0

        for _, nearEnt in ipairs(nearbyEnts) do
            if IsValid(nearEnt) and string.find(nearEnt:GetClass(), "naquadah") then
                if nearEnt.GetAmount and nearEnt.SetAmount then
                    local available = nearEnt:GetAmount() or 0
                    local needed = config.NaquadahConsumption - naquadahConsumed
                    local consume = math.min(available, needed)

                    nearEnt:SetAmount(available - consume)
                    naquadahConsumed = naquadahConsumed + consume

                    if naquadahConsumed >= config.NaquadahConsumption then
                        break
                    end
                end
            end
        end

        if naquadahConsumed < config.NaquadahConsumption then
            return false, "Insufficient naquadah (" .. naquadahConsumed .. "/" .. config.NaquadahConsumption .. ")"
        end
    end

    return true
end

-- Get gate network coordinates
function HYPERDRIVE.Stargate.GetGateNetworkCoordinates()
    if not StarGate or not HYPERDRIVE.Stargate.Config.GateNetworkAccess then
        return {}
    end

    local coordinates = {}

    -- Find all active Stargates
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and string.find(ent:GetClass(), "stargate") then
            if ent.GetAddress and ent:GetAddress() then
                local address = ent:GetAddress()
                local name = ent.GetName and ent:GetName() or ("Gate " .. address)

                table.insert(coordinates, {
                    name = name,
                    address = address,
                    position = ent:GetPos(),
                    techLevel = HYPERDRIVE.Stargate.GetTechLevel(ent),
                    active = ent.GetActive and ent:GetActive() or false
                })
            end
        end
    end

    return coordinates
end

-- Get technology level of Stargate entity
function HYPERDRIVE.Stargate.GetTechLevel(ent)
    if not IsValid(ent) then return "tau_ri" end

    local class = ent:GetClass()

    if string.find(class, "ancient") then
        return "ancient"
    elseif string.find(class, "ori") then
        return "ori"
    elseif string.find(class, "asgard") then
        return "asgard"
    elseif string.find(class, "goauld") then
        return "goauld"
    elseif string.find(class, "wraith") then
        return "wraith"
    else
        return "tau_ri"
    end
end

-- Create Stargate-enhanced hyperdrive engine
function HYPERDRIVE.Stargate.CreateStargateEngine(pos, ang, ply, techLevel)
    local engine = ents.Create("hyperdrive_sg_engine")
    if not IsValid(engine) then return nil end

    engine:SetPos(pos)
    engine:SetAngles(ang)
    engine:Spawn()
    engine:Activate()

    if IsValid(ply) then
        engine:SetCreator(ply)
    end

    -- Set technology level
    if techLevel then
        engine:SetTechLevel(techLevel)
    end

    return engine
end

-- Hook into hyperdrive engine initialization for Stargate integration
hook.Add("OnEntityCreated", "HyperdriveStargateInit", function(ent)
    if not IsValid(ent) then return end

    local class = ent:GetClass()
    if class == "hyperdrive_engine" or class == "hyperdrive_sb_engine" then
        timer.Simple(0.1, function()
            if IsValid(ent) and StarGate then
                HYPERDRIVE.Stargate.SetupStargateIntegration(ent)
            end
        end)
    end
end)

-- Setup Stargate integration for existing engines
function HYPERDRIVE.Stargate.SetupStargateIntegration(ent)
    if not IsValid(ent) or not StarGate then return end

    -- Store original functions
    ent.OriginalSetDestinationPos = ent.OriginalSetDestinationPos or ent.SetDestinationPos
    ent.OriginalStartJump = ent.OriginalStartJump or ent.StartJump

    -- Override SetDestinationPos with Stargate checks
    ent.SetDestinationPos = function(self, pos)
        -- Check for iris/shield protection
        local protected, reason = HYPERDRIVE.Stargate.IsDestinationProtected(pos)
        if protected then
            return false, reason
        end

        return self:OriginalSetDestinationPos(pos)
    end

    -- Override StartJump with Stargate 4-stage integration
    ent.StartJump = function(self)
        -- Check if destination is set
        if not self.DestinationPos then
            return false, "No destination set"
        end

        -- Get attached entities for travel
        local entities = {}
        if self.GetAttachedEntities then
            entities = self:GetAttachedEntities()
        end

        -- Use 4-stage Stargate travel system
        local success, message = HYPERDRIVE.Stargate.StartFourStageTravel(self, self.DestinationPos, entities)
        if not success then
            -- Fall back to original system if 4-stage fails
            local success2, message2 = HYPERDRIVE.Stargate.ConsumeResources(self, "jump")
            if not success2 then
                return false, message2
            end
            return self:OriginalStartJump()
        end

        return true
    end

    -- Add Stargate status function
    ent.GetStargateStatus = function(self)
        return HYPERDRIVE.Stargate.HasStargateTech(self)
    end
end

-- Enhanced Effects and Sound Functions for 4-Stage Travel

-- Send stage update to nearby players
function HYPERDRIVE.Stargate.SendStageUpdate(pos, stage, duration, techLevel, efficiency)
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():Distance(pos) <= 2000 then -- Larger range for UI updates
            net.Start("hyperdrive_sg_stage_update")
            net.WriteInt(stage, 8)
            net.WriteFloat(duration)
            net.WriteString(techLevel or "tau_ri")
            net.WriteFloat(efficiency or 1.0)
            net.Send(ply)
        end
    end
end

-- Notify players in range
function HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, message, range)
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():Distance(pos) <= range then
            ply:ChatPrint("[Stargate Hyperdrive] " .. message)
        end
    end
end

-- Stage 1: Initiation Effects
function HYPERDRIVE.Stargate.CreateInitiationEffects(pos, techBonus)
    -- Enhanced charging effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetMagnitude(1.0)
    effectData:SetScale(techBonus)
    util.Effect("hyperdrive_sg_charge", effectData)

    -- Create master engine initiation effect if available
    local masterEffectData = EffectData()
    masterEffectData:SetOrigin(pos)
    masterEffectData:SetMagnitude(3) -- Stargate initiation
    masterEffectData:SetScale(techBonus)
    util.Effect("hyperdrive_master_jump", masterEffectData)

    -- Additional energy buildup particles
    if CLIENT then return end

    timer.Create("StargateInitiation_" .. util.CRC(tostring(pos)), 0.3, 10, function()
        local effectData2 = EffectData()
        effectData2:SetOrigin(pos + VectorRand() * 50)
        effectData2:SetMagnitude(0.5)
        effectData2:SetScale(techBonus * 0.7)
        util.Effect("hyperdrive_sg_charge", effectData2)
    end)
end

-- Stage 1: Initiation Sounds
function HYPERDRIVE.Stargate.PlayInitiationSounds(pos, techBonus)
    -- Primary charging sound
    sound.Play("ambient/energy/whiteflash.wav", pos, 75, 60)

    -- Technology-specific sounds
    if techBonus > 1.5 then -- Ancient technology
        timer.Simple(0.5, function()
            sound.Play("ambient/energy/spark6.wav", pos, 70, 40)
        end)
        timer.Simple(1.5, function()
            sound.Play("ambient/energy/zap7.wav", pos, 65, 35)
        end)
    else
        timer.Simple(0.8, function()
            sound.Play("ambient/energy/spark1.wav", pos, 70, 80)
        end)
    end
end

-- Stage 2: Window Opening Effects
function HYPERDRIVE.Stargate.CreateWindowOpeningEffects(pos, techBonus)
    -- Create main window opening effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetMagnitude(1.0)
    effectData:SetScale(techBonus)
    util.Effect("hyperdrive_sg_window", effectData)

    -- Create master engine window opening effect
    local masterEffectData = EffectData()
    masterEffectData:SetOrigin(pos)
    masterEffectData:SetMagnitude(4) -- Stargate window opening
    masterEffectData:SetScale(techBonus)
    util.Effect("hyperdrive_master_jump", masterEffectData)

    -- Create additional portal effects
    local portalEffect = EffectData()
    portalEffect:SetOrigin(pos)
    portalEffect:SetMagnitude(2.0) -- Window opening
    portalEffect:SetScale(techBonus)
    util.Effect("hyperdrive_sg_jump", portalEffect)

    -- Create blue/purple energy tunnel sequence
    if CLIENT then return end

    for i = 1, 8 do
        timer.Simple(i * 0.25, function()
            local tunnelPos = pos + Vector(0, 0, i * 30)
            local tunnelEffect = EffectData()
            tunnelEffect:SetOrigin(tunnelPos)
            tunnelEffect:SetMagnitude(1.5)
            tunnelEffect:SetScale(techBonus * 0.8)
            util.Effect("hyperdrive_sg_charge", tunnelEffect)
        end)
    end
end

-- Stage 2: Window Opening Sounds
function HYPERDRIVE.Stargate.PlayWindowOpeningSounds(pos, techBonus)
    -- Portal opening sound
    sound.Play("ambient/energy/zap9.wav", pos, 85, 120)

    -- Dimensional tear sound
    timer.Simple(0.5, function()
        sound.Play("ambient/explosions/explode_4.wav", pos, 75, 150)
    end)

    -- Energy stabilization
    timer.Simple(1.0, function()
        sound.Play("ambient/energy/spark6.wav", pos, 70, 90)
    end)
end

-- Stage 3: Hyperspace Effects
function HYPERDRIVE.Stargate.CreateHyperspaceEffects(travelData)
    local config = HYPERDRIVE.Stargate.Config.StageSystem

    -- Apply to all entities in hyperspace
    for _, ent in ipairs(travelData.entities) do
        if IsValid(ent) and ent.InHyperspace then
            -- Create starline effects for players
            if ent:IsPlayer() and config.StarlineEffects then
                HYPERDRIVE.Stargate.CreateStarlineEffects(ent)
            end

            -- Create dimensional tunnel visuals
            if config.DimensionalVisuals then
                HYPERDRIVE.Stargate.CreateDimensionalVisuals(ent)
            end
        end
    end
end

-- Stage 3: Hyperspace Sounds
function HYPERDRIVE.Stargate.PlayHyperspaceSounds(travelData)
    local config = HYPERDRIVE.Stargate.Config.StageSystem

    if not config.TravelSounds then return end

    -- Ambient hyperspace sound for all entities
    for _, ent in ipairs(travelData.entities) do
        if IsValid(ent) and ent:IsPlayer() then
            -- Send ambient hyperspace sound to player
            timer.Create("HyperspaceAmbient_" .. ent:EntIndex(), 2, math.ceil(travelData.hyperspaceTime / 2), function()
                if IsValid(ent) and ent.InHyperspace then
                    ent:EmitSound("ambient/wind/wind_snippet1.wav", 50, 30)
                end
            end)
        end
    end
end

-- Stage 4: Exit Effects
function HYPERDRIVE.Stargate.CreateExitEffects(pos, techBonus)
    -- Bright exit flash
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetMagnitude(3.0) -- Exit flash
    effectData:SetScale(techBonus)
    util.Effect("hyperdrive_sg_jump", effectData)

    -- Create master engine exit effect
    local masterEffectData = EffectData()
    masterEffectData:SetOrigin(pos)
    masterEffectData:SetMagnitude(5) -- Stargate exit
    masterEffectData:SetScale(techBonus)
    util.Effect("hyperdrive_master_jump", masterEffectData)

    -- System stabilization effects
    if CLIENT then return end

    for i = 1, 5 do
        timer.Simple(i * 0.3, function()
            local stabilizeEffect = EffectData()
            stabilizeEffect:SetOrigin(pos + VectorRand() * 30)
            stabilizeEffect:SetMagnitude(0.3)
            stabilizeEffect:SetScale(techBonus * 0.5)
            util.Effect("hyperdrive_sg_charge", stabilizeEffect)
        end)
    end
end

-- Stage 4: Exit Sounds
function HYPERDRIVE.Stargate.PlayExitSounds(pos, techBonus)
    -- Exit flash sound
    sound.Play("ambient/energy/whiteflash.wav", pos, 90, 140)

    -- System stabilization
    timer.Simple(0.3, function()
        sound.Play("ambient/energy/spark6.wav", pos, 80, 100)
    end)

    timer.Simple(1.0, function()
        sound.Play("ambient/energy/zap7.wav", pos, 70, 110)
    end)
end

-- Create starline effects for players in hyperspace
function HYPERDRIVE.Stargate.CreateStarlineEffects(player)
    if not IsValid(player) or not player:IsPlayer() then return end

    -- Send starline effect to client
    net.Start("hyperdrive_sg_starlines")
    net.Send(player)
end

-- Create dimensional tunnel visuals
function HYPERDRIVE.Stargate.CreateDimensionalVisuals(ent)
    if not IsValid(ent) then return end

    -- Create swirling energy around entity
    local effectData = EffectData()
    effectData:SetOrigin(ent:GetPos())
    effectData:SetMagnitude(0.5)
    effectData:SetScale(0.8)
    util.Effect("hyperdrive_sg_charge", effectData)
end

-- Console commands for Stargate integration
concommand.Add("hyperdrive_sg_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or
       (trace.Entity:GetClass() ~= "hyperdrive_engine" and
        trace.Entity:GetClass() ~= "hyperdrive_sb_engine" and
        trace.Entity:GetClass() ~= "hyperdrive_sg_engine") then
        ply:ChatPrint("[Hyperdrive] Look at a hyperdrive engine")
        return
    end

    local stargateData = HYPERDRIVE.Stargate.HasStargateTech(trace.Entity)

    ply:ChatPrint("[Hyperdrive] Stargate Integration Status:")
    ply:ChatPrint("  • Stargate Present: " .. (stargateData.hasGate and "Yes" or "No"))
    ply:ChatPrint("  • Technology Level: " .. string.upper(stargateData.techLevel))
    ply:ChatPrint("  • DHD Present: " .. (stargateData.hasDHD and "Yes" or "No"))
    ply:ChatPrint("  • ZPM Present: " .. (stargateData.hasZPM and "Yes" or "No"))
    ply:ChatPrint("  • ZPM Power: " .. math.floor(stargateData.powerLevel) .. "%")
    ply:ChatPrint("  • Naquadah Available: " .. (stargateData.hasNaquadah and "Yes" or "No"))

    local techBonus = HYPERDRIVE.Stargate.GetTechBonus(stargateData.techLevel)
    ply:ChatPrint("  • Technology Bonus: " .. string.format("%.1fx", techBonus))
end)

concommand.Add("hyperdrive_sg_network", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local coordinates = HYPERDRIVE.Stargate.GetGateNetworkCoordinates()

    if #coordinates == 0 then
        ply:ChatPrint("[Hyperdrive] No Stargate network access available")
        return
    end

    ply:ChatPrint("[Hyperdrive] Stargate Network Coordinates:")
    for i, coord in ipairs(coordinates) do
        if i > 10 then break end -- Limit display
        local status = coord.active and "ACTIVE" or "INACTIVE"
        ply:ChatPrint(string.format("  • %s (%s) - %s - %s",
            coord.name, coord.address, string.upper(coord.techLevel), status))
    end
end)

concommand.Add("hyperdrive_sg_config", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end

    ply:ChatPrint("[Hyperdrive] Stargate Configuration:")
    for key, value in pairs(HYPERDRIVE.Stargate.Config) do
        ply:ChatPrint("  • " .. key .. ": " .. tostring(value))
    end
end)

concommand.Add("hyperdrive_sg_test_4stage", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or
       (trace.Entity:GetClass() ~= "hyperdrive_engine" and
        trace.Entity:GetClass() ~= "hyperdrive_sb_engine" and
        trace.Entity:GetClass() ~= "hyperdrive_sg_engine") then
        ply:ChatPrint("[Hyperdrive] Look at a hyperdrive engine")
        return
    end

    local engine = trace.Entity
    local destination = ply:GetPos() + ply:GetForward() * 1000

    ply:ChatPrint("[Hyperdrive] Testing 4-stage Stargate travel...")
    local success, message = HYPERDRIVE.Stargate.StartFourStageTravel(engine, destination, {ply})

    if success then
        ply:ChatPrint("[Hyperdrive] 4-stage travel initiated successfully!")
    else
        ply:ChatPrint("[Hyperdrive] 4-stage travel failed: " .. (message or "Unknown error"))
    end
end)

-- Logging function
function HYPERDRIVE.Stargate.Log(message, category)
    category = category or "INFO"
    print("[Hyperdrive Stargate] [" .. category .. "] " .. message)
end

-- Enhanced Effect Functions for Stargate Lore Implementation

-- Stage 1: Enhanced Initiation Effects (Energy Surges and Vibrations)
function HYPERDRIVE.Stargate.CreateEnhancedInitiationEffects(pos, techBonus, config)
    -- Create energy buildup effects in steps
    for i = 1, config.EnergyBuildupSteps do
        timer.Simple(i * (config.InitiationDuration / config.EnergyBuildupSteps), function()
            local effectdata = EffectData()
            effectdata:SetOrigin(pos)
            effectdata:SetMagnitude(i * techBonus * 10)
            effectdata:SetScale(i * 2)
            util.Effect("hyperdrive_energy_buildup", effectdata)

            -- Send to clients for enhanced effects
            net.Start("hyperdrive_sg_stage_update")
            net.WriteInt(1, 8)
            net.WriteFloat(i / config.EnergyBuildupSteps)
            net.WriteString("energy_buildup")
            net.WriteFloat(techBonus)
            net.Broadcast()
        end)
    end
end

-- Stage 1: Enhanced Initiation Sounds (Energy Surge Effects)
function HYPERDRIVE.Stargate.PlayEnhancedInitiationSounds(pos, techBonus, config)
    -- Play charging sound with increasing intensity
    for i = 1, config.EnergyBuildupSteps do
        timer.Simple(i * (config.InitiationDuration / config.EnergyBuildupSteps), function()
            local sound = Sound("ambient/energy/electric_loop.wav")
            sound:SetSoundLevel(70 + (i * 5))
            sound:Play()
        end)
    end
end

-- Stage 1: Spatial Chart Check for Gravitational Anomalies
function HYPERDRIVE.Stargate.PerformSpatialChartCheck(travelData)
    local pos = travelData.origin
    local destination = travelData.destination

    -- Check for gravitational anomalies (large entities, black holes, etc.)
    local anomalies = 0
    local nearbyEnts = ents.FindInSphere(destination, 2000)

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetPhysicsObject() and ent:GetPhysicsObject():GetMass() > 5000 then
            anomalies = anomalies + 1
        end
    end

    if anomalies > 0 then
        HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Warning: " .. anomalies .. " gravitational anomalies detected near destination.", 1500)
    else
        HYPERDRIVE.Stargate.NotifyPlayersInRange(pos, "Spatial charts clear. No gravitational anomalies detected.", 1500)
    end
end

-- Stage 2: Enhanced Window Effects (Blue/Purple Swirling Energy)
function HYPERDRIVE.Stargate.CreateEnhancedWindowEffects(pos, techBonus, config)
    -- Create swirling energy tunnel effect
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    effectdata:SetMagnitude(techBonus * 50)
    effectdata:SetScale(10)
    util.Effect("hyperdrive_hyperspace_window", effectdata)

    -- Send enhanced window opening to clients
    net.Start("hyperdrive_sg_stage_update")
    net.WriteInt(2, 8)
    net.WriteFloat(config.WindowOpenDuration)
    net.WriteString("dimensional_tear")
    net.WriteFloat(techBonus)
    net.Broadcast()
end

-- Stage 2: Dimensional Tear Sounds
function HYPERDRIVE.Stargate.PlayDimensionalTearSounds(pos, techBonus, config)
    -- Play dimensional tearing sound
    local sound = Sound("ambient/atmosphere/cave_hit1.wav")
    sound:SetSoundLevel(80)
    sound:Play()

    timer.Simple(1.0, function()
        local sound2 = Sound("ambient/wind/wind_rooftop1.wav")
        sound2:SetSoundLevel(60)
        sound2:Play()
    end)
end

-- Stage 2: Rippling Energy Effects
function HYPERDRIVE.Stargate.CreateRipplingEnergyEffects(pos, techBonus)
    for i = 1, 5 do
        timer.Simple(i * 0.2, function()
            local effectdata = EffectData()
            effectdata:SetOrigin(pos + VectorRand() * 100)
            effectdata:SetMagnitude(techBonus * 20)
            effectdata:SetScale(i * 3)
            util.Effect("hyperdrive_energy_ripple", effectdata)
        end)
    end
end

-- Stage 3: Enhanced Hyperspace Effects
function HYPERDRIVE.Stargate.CreateEnhancedHyperspaceEffects(travelData, config)
    -- Send hyperspace travel effects to clients
    net.Start("hyperdrive_sg_stage_update")
    net.WriteInt(3, 8)
    net.WriteFloat(travelData.hyperspaceTime)
    net.WriteString("hyperspace_travel")
    net.WriteFloat(travelData.techBonus)
    net.Broadcast()
end

-- Stage 3: Starline Effects (Stretched Starlines)
function HYPERDRIVE.Stargate.CreateStarlineEffects(travelData)
    -- Send starline effect to clients
    net.Start("hyperdrive_sg_starlines")
    net.WriteVector(travelData.origin)
    net.WriteVector(travelData.destination)
    net.WriteFloat(travelData.techBonus)
    net.Broadcast()
end

-- Stage 3: Dimensional Tunnel Effects
function HYPERDRIVE.Stargate.CreateDimensionalTunnelEffects(travelData)
    -- Create abstract dimensional visuals
    local effectdata = EffectData()
    effectdata:SetOrigin(travelData.origin)
    effectdata:SetStart(travelData.destination)
    effectdata:SetMagnitude(travelData.techBonus * 100)
    util.Effect("hyperdrive_dimensional_tunnel", effectdata)
end

-- Stage 3: Ambient Hyperspace Sounds
function HYPERDRIVE.Stargate.PlayAmbientHyperspaceSounds(travelData, config)
    -- Play ambient hyperspace sound
    local sound = Sound("ambient/atmosphere/ambience_base.wav")
    sound:SetSoundLevel(50)
    sound:Play()
end

-- Stage 3: Navigation Check for Gravitational Wells
function HYPERDRIVE.Stargate.PerformNavigationCheck(travelData)
    local midpoint = (travelData.origin + travelData.destination) / 2
    local nearbyEnts = ents.FindInSphere(midpoint, 5000)
    local wells = 0

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetPhysicsObject() and ent:GetPhysicsObject():GetMass() > 10000 then
            wells = wells + 1
        end
    end

    if wells > 0 then
        HYPERDRIVE.Stargate.Log("Navigation check: " .. wells .. " gravitational wells detected in hyperspace route", "TRAVEL")
    end
end

-- Stage 4: Enhanced Exit Effects (Bright Flash and Shimmer)
function HYPERDRIVE.Stargate.CreateEnhancedExitEffects(pos, techBonus, config)
    -- Create bright flash effect
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    effectdata:SetMagnitude(techBonus * 75)
    effectdata:SetScale(15)
    util.Effect("hyperdrive_hyperspace_exit", effectdata)

    -- Create shimmer effect
    timer.Simple(0.5, function()
        local effectdata2 = EffectData()
        effectdata2:SetOrigin(pos)
        effectdata2:SetMagnitude(techBonus * 30)
        effectdata2:SetScale(8)
        util.Effect("hyperdrive_shimmer", effectdata2)
    end)
end

-- Stage 4: Window Collapse Effects
function HYPERDRIVE.Stargate.CreateWindowCollapseEffects(pos, techBonus)
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    effectdata:SetMagnitude(techBonus * 40)
    effectdata:SetScale(5)
    util.Effect("hyperdrive_window_collapse", effectdata)
end

-- Stage 4: Enhanced Exit Sounds
function HYPERDRIVE.Stargate.PlayEnhancedExitSounds(pos, techBonus, config)
    -- Play exit flash sound
    local sound = Sound("ambient/energy/spark1.wav")
    sound:SetSoundLevel(85)
    sound:Play()

    -- Play stabilization sound
    timer.Simple(1.0, function()
        local sound2 = Sound("ambient/machines/machine1_hit1.wav")
        sound2:SetSoundLevel(60)
        sound2:Play()
    end)
end

-- Stage 4: Resume Normal Physics
function HYPERDRIVE.Stargate.ResumeNormalPhysics(travelData)
    -- Restore normal physics for all entities
    for _, ent in ipairs(travelData.entities) do
        if IsValid(ent) then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:Wake()
                phys:EnableGravity(true)
            end
        end
    end

    HYPERDRIVE.Stargate.NotifyPlayersInRange(travelData.destination, "Normal space physics fully restored.", 1500)
end

-- Network strings are loaded from hyperdrive_network_strings.lua

print("[Hyperdrive] Enhanced Stargate Carter Addon Pack integration loaded with authentic 4-stage travel system")
