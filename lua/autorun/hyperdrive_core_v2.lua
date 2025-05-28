-- Hyperdrive Core System V2 - Enhanced Architecture
-- This file provides the improved core functionality for the hyperdrive system

-- Ensure HYPERDRIVE table exists first
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Core = HYPERDRIVE.Core or {}
HYPERDRIVE.Core.Version = "2.0.0"

-- Enhanced configuration with more options
HYPERDRIVE.Core.Config = {
    -- Performance settings
    MaxActiveEngines = 100,
    UpdateRate = 0.1, -- Faster updates for smoother experience
    EffectQuality = 1.0,
    NetworkOptimization = true,

    -- Advanced physics
    RelativisticEffects = true,
    GravitationalLensing = true,
    QuantumTunneling = false, -- Experimental feature

    -- Energy system improvements
    EnergyDecay = 0.001, -- Energy slowly decays over time
    CapacitorCharging = true, -- Gradual energy buildup
    PowerSurges = true, -- Random power fluctuations

    -- Safety systems
    CollisionAvoidance = true,
    EmergencyShutdown = true,
    RedundantSystems = true,

    -- Visual enhancements
    DynamicLighting = true,
    ParticleComplexity = 2.0,
    ScreenDistortion = true,
    CameraShake = true,

    -- Audio improvements
    DopplerEffect = true,
    SpatialAudio = true,
    DynamicVolume = true,

    -- Network features
    CrossServerJumps = false, -- Future feature
    CloudSave = false, -- Future feature
    Telemetry = true
}

-- Enhanced distance calculation with relativistic effects
function HYPERDRIVE.Core.CalculateDistance(pos1, pos2, velocity)
    local baseDistance = pos1:Distance(pos2)

    if not HYPERDRIVE.Core.Config.RelativisticEffects then
        return baseDistance
    end

    -- Apply relativistic length contraction at high velocities
    local speedOfLight = 299792458 -- m/s (scaled for game)
    local relativeVelocity = velocity or 0
    local gamma = 1 / math.sqrt(1 - (relativeVelocity / speedOfLight)^2)

    return baseDistance / gamma
end

-- Advanced energy calculation with multiple factors
function HYPERDRIVE.Core.CalculateEnergyCost(distance, mass, efficiency, environmental)
    local baseCost = distance * (HYPERDRIVE.Config.EnergyPerUnit or 0.1)

    -- Mass factor (heavier objects cost more energy)
    local massFactor = math.sqrt(mass / 1000) -- Normalized to 1000kg baseline

    -- Efficiency factor (better engines use less energy)
    local efficiencyFactor = 1 / (efficiency or 1.0)

    -- Environmental factors
    local envFactor = environmental or 1.0

    -- Quantum tunneling discount (experimental)
    local quantumDiscount = HYPERDRIVE.Core.Config.QuantumTunneling and 0.8 or 1.0

    local totalCost = baseCost * massFactor * efficiencyFactor * envFactor * quantumDiscount

    -- Apply energy decay over time
    if HYPERDRIVE.Core.Config.EnergyDecay > 0 then
        totalCost = totalCost * (1 + HYPERDRIVE.Core.Config.EnergyDecay)
    end

    return math.max(1, totalCost) -- Minimum cost of 1 EU
end

-- Enhanced destination validation with safety checks
function HYPERDRIVE.Core.IsValidDestination(pos, origin, engine)
    if not isvector(pos) then return false, "Invalid position vector" end
    if not isvector(origin) then return false, "Invalid origin vector" end

    local distance = HYPERDRIVE.Core.CalculateDistance(origin, pos)

    -- Distance checks
    local minDist = HYPERDRIVE.Config.MinJumpDistance or 1000
    local maxDist = HYPERDRIVE.Config.MaxJumpDistance or 50000

    if distance < minDist then
        return false, "Destination too close (min: " .. minDist .. " units)"
    end

    if distance > maxDist then
        return false, "Destination too far (max: " .. maxDist .. " units)"
    end

    -- Collision avoidance
    if HYPERDRIVE.Core.Config.CollisionAvoidance then
        local trace = util.TraceLine({
            start = origin,
            endpos = pos,
            filter = engine
        })

        if trace.Hit and trace.Fraction < 0.9 then
            return false, "Obstruction detected in jump path"
        end
    end

    -- Check for dangerous areas
    local dangerousEnts = ents.FindInSphere(pos, 200)
    for _, ent in ipairs(dangerousEnts) do
        if IsValid(ent) and (ent:GetClass() == "env_explosion" or ent:GetClass() == "env_fire") then
            return false, "Destination area is hazardous"
        end
    end

    -- Check map boundaries
    if pos.z < -16000 or pos.z > 16000 then
        return false, "Destination outside map boundaries"
    end

    return true, "Destination valid"
end

-- Advanced jump trajectory calculation
function HYPERDRIVE.Core.CalculateTrajectory(start, destination, mass, velocity)
    local trajectory = {
        waypoints = {},
        totalTime = 0,
        energyProfile = {},
        riskFactors = {}
    }

    local distance = HYPERDRIVE.Core.CalculateDistance(start, destination, velocity)
    local direction = (destination - start):GetNormalized()

    -- Calculate waypoints for complex jumps
    local numWaypoints = math.min(10, math.floor(distance / 5000))

    for i = 1, numWaypoints do
        local progress = i / numWaypoints
        local waypoint = start + direction * distance * progress

        -- Add some randomness for quantum uncertainty
        if HYPERDRIVE.Core.Config.QuantumTunneling then
            waypoint = waypoint + VectorRand() * 50
        end

        table.insert(trajectory.waypoints, waypoint)

        -- Calculate energy at this point
        local segmentEnergy = HYPERDRIVE.Core.CalculateEnergyCost(distance * progress, mass, 1.0, 1.0)
        table.insert(trajectory.energyProfile, segmentEnergy)
    end

    trajectory.totalTime = distance / (velocity or 1000) -- Time in seconds

    return trajectory
end

-- Enhanced entity mass calculation
function HYPERDRIVE.Core.CalculateEntityMass(ent)
    if not IsValid(ent) then return 0 end

    local mass = 100 -- Base mass

    -- Get physics mass if available
    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        mass = phys:GetMass()
    end

    -- Add mass for passengers
    if ent:IsVehicle() then
        for i = 0, ent:GetPassengerCount() - 1 do
            local passenger = ent:GetPassenger(i)
            if IsValid(passenger) and passenger:IsPlayer() then
                mass = mass + 75 -- Average human mass
            end
        end
    end

    -- Add mass for attached entities
    local constrainedEnts = constraint.GetAllConstrainedEntities(ent)
    if constrainedEnts then
        for _, constrainedEnt in ipairs(constrainedEnts) do
            if IsValid(constrainedEnt) and constrainedEnt ~= ent then
                local constrainedPhys = constrainedEnt:GetPhysicsObject()
                if IsValid(constrainedPhys) then
                    mass = mass + constrainedPhys:GetMass() * 0.5 -- Partial mass transfer
                end
            end
        end
    end

    return mass
end

-- Environmental factor calculation
function HYPERDRIVE.Core.GetEnvironmentalFactor(pos)
    local factor = 1.0

    -- Altitude factor (higher altitude = less atmospheric resistance)
    local altitude = pos.z
    if altitude > 1000 then
        factor = factor * 0.8 -- 20% bonus in space
    elseif altitude < -500 then
        factor = factor * 1.3 -- 30% penalty underground
    end

    -- Water factor
    if util.PointContents(pos) == CONTENTS_WATER then
        factor = factor * 1.2 -- 20% penalty in water
    end

    -- Check for electromagnetic interference
    local nearbyEnts = ents.FindInSphere(pos, 500)
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            local class = ent:GetClass()
            if string.find(class, "wire") or string.find(class, "radio") then
                factor = factor * 1.05 -- 5% penalty per interference source
            end
        end
    end

    return math.max(0.5, math.min(2.0, factor)) -- Clamp between 0.5x and 2.0x
end

-- Advanced safety systems
function HYPERDRIVE.Core.SafetyCheck(engine, destination)
    local issues = {}
    local warnings = {}

    if not IsValid(engine) then
        table.insert(issues, "Invalid engine entity")
        return issues, warnings
    end

    local origin = engine:GetPos()

    -- Check engine health
    if engine:Health() < engine:GetMaxHealth() * 0.5 then
        table.insert(warnings, "Engine health below 50%")
    end

    -- Check for overheating
    if engine.GetTemperature and engine:GetTemperature() > 80 then
        table.insert(issues, "Engine overheating")
    end

    -- Check energy levels
    if engine.GetEnergy and engine:GetEnergy() < 100 then
        table.insert(warnings, "Low energy reserves")
    end

    -- Check for nearby hazards
    local hazards = ents.FindInSphere(origin, 300)
    for _, hazard in ipairs(hazards) do
        if IsValid(hazard) then
            local class = hazard:GetClass()
            if string.find(class, "explosive") or string.find(class, "bomb") then
                table.insert(warnings, "Explosive hazard detected nearby")
            end
        end
    end

    -- Check destination safety
    local valid, reason = HYPERDRIVE.Core.IsValidDestination(destination, origin, engine)
    if not valid then
        table.insert(issues, reason)
    end

    return issues, warnings
end

-- Performance monitoring
HYPERDRIVE.Core.Performance = {
    jumpCount = 0,
    totalEnergyUsed = 0,
    averageJumpTime = 0,
    errorCount = 0,
    lastUpdate = 0
}

function HYPERDRIVE.Core.UpdatePerformanceMetrics(jumpTime, energyUsed, success)
    local perf = HYPERDRIVE.Core.Performance

    perf.jumpCount = perf.jumpCount + 1
    perf.totalEnergyUsed = perf.totalEnergyUsed + energyUsed

    -- Calculate rolling average
    perf.averageJumpTime = (perf.averageJumpTime * (perf.jumpCount - 1) + jumpTime) / perf.jumpCount

    if not success then
        perf.errorCount = perf.errorCount + 1
    end

    perf.lastUpdate = CurTime()
end

-- Enhanced logging system
function HYPERDRIVE.Core.Log(level, message, category, data)
    if HYPERDRIVE.Debug then
        HYPERDRIVE.Debug.Log(level, message, category)
    end

    -- Add telemetry if enabled
    if HYPERDRIVE.Core.Config.Telemetry and data then
        -- Store telemetry data for analysis
        HYPERDRIVE.Core.Telemetry = HYPERDRIVE.Core.Telemetry or {}
        table.insert(HYPERDRIVE.Core.Telemetry, {
            timestamp = os.time(),
            level = level,
            message = message,
            category = category,
            data = data
        })

        -- Limit telemetry size
        if #HYPERDRIVE.Core.Telemetry > 1000 then
            table.remove(HYPERDRIVE.Core.Telemetry, 1)
        end
    end
end

-- Initialize enhanced core system
function HYPERDRIVE.Core.Initialize()
    HYPERDRIVE.Core.Log(3, "Initializing Hyperdrive Core V2", "CORE")

    -- Override base functions with enhanced versions
    HYPERDRIVE.GetDistance = HYPERDRIVE.Core.CalculateDistance
    HYPERDRIVE.CalculateEnergyCost = HYPERDRIVE.Core.CalculateEnergyCost
    HYPERDRIVE.IsValidDestination = HYPERDRIVE.Core.IsValidDestination

    -- Set up performance monitoring
    timer.Create("HyperdrivePerformanceMonitor", 60, 0, function()
        local perf = HYPERDRIVE.Core.Performance
        if perf.jumpCount > 0 then
            local errorRate = (perf.errorCount / perf.jumpCount) * 100
            HYPERDRIVE.Core.Log(3, string.format("Performance: %d jumps, %.1f%% error rate, %.2fs avg time",
                perf.jumpCount, errorRate, perf.averageJumpTime), "PERFORMANCE")
        end
    end)

    HYPERDRIVE.Core.Log(3, "Hyperdrive Core V2 initialized successfully", "CORE")
end

-- Auto-initialize
timer.Simple(0.1, function()
    HYPERDRIVE.Core.Initialize()
end)
