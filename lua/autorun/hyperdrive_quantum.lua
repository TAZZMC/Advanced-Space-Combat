-- Hyperdrive Quantum Mechanics System
-- This file provides advanced quantum physics simulation for the hyperdrive system

-- Ensure HYPERDRIVE table exists first
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Quantum = HYPERDRIVE.Quantum or {}
HYPERDRIVE.Quantum.Version = "2.0.0"

-- Quantum configuration
HYPERDRIVE.Quantum.Config = {
    -- Quantum effects
    EnableQuantumTunneling = true,
    EnableSuperposition = true,
    EnableEntanglement = true,
    EnableUncertainty = true,

    -- Physics constants (scaled for game)
    PlancksConstant = 6.626e-34 * 1e30, -- Scaled up for game visibility
    SpeedOfLight = 299792458,
    QuantumFluctuationRate = 0.1,

    -- Quantum tunneling
    TunnelingProbability = 0.15, -- 15% chance
    TunnelingEnergyDiscount = 0.3, -- 30% energy reduction
    TunnelingRiskIncrease = 0.1, -- 10% risk increase

    -- Superposition
    SuperpositionStates = 3, -- Number of simultaneous states
    SuperpositionDecayTime = 5, -- Seconds before collapse

    -- Entanglement
    MaxEntangledPairs = 10,
    EntanglementRange = 10000, -- Units
    EntanglementSyncDelay = 0.1, -- Seconds

    -- Uncertainty principle
    PositionUncertainty = 50, -- Units
    MomentumUncertainty = 100, -- Units/second
    EnergyTimeUncertainty = 10 -- Energy units * seconds
}

-- Quantum state management
HYPERDRIVE.Quantum.States = {}
HYPERDRIVE.Quantum.EntangledPairs = {}
HYPERDRIVE.Quantum.SuperpositionStates = {}

-- Quantum tunneling calculation
function HYPERDRIVE.Quantum.CalculateTunnelingProbability(barrier, energy, mass)
    if not HYPERDRIVE.Quantum.Config.EnableQuantumTunneling then return 0 end

    -- Simplified quantum tunneling probability
    local barrierHeight = barrier or 1000 -- Energy barrier
    local particleEnergy = energy or 500
    local particleMass = mass or 1000

    -- Transmission coefficient approximation
    local kappa = math.sqrt(2 * particleMass * (barrierHeight - particleEnergy)) / HYPERDRIVE.Quantum.Config.PlancksConstant
    local barrierWidth = 100 -- Simplified barrier width

    local transmissionCoeff = math.exp(-2 * kappa * barrierWidth)

    return math.min(HYPERDRIVE.Quantum.Config.TunnelingProbability, transmissionCoeff)
end

-- Attempt quantum tunneling
function HYPERDRIVE.Quantum.AttemptTunneling(engine, destination)
    if not IsValid(engine) then return false end

    local origin = engine:GetPos()
    local distance = origin:Distance(destination)
    local mass = HYPERDRIVE.Core and HYPERDRIVE.Core.CalculateEntityMass(engine) or 1000
    local energy = engine.GetEnergy and engine:GetEnergy() or 500

    -- Check for barriers (walls, obstacles)
    local trace = util.TraceLine({
        start = origin,
        endpos = destination,
        filter = engine
    })

    if not trace.Hit then return false end -- No barrier to tunnel through

    local barrier = trace.Entity
    local barrierEnergy = IsValid(barrier) and (barrier:Health() * 10) or 1000

    local tunnelingProb = HYPERDRIVE.Quantum.CalculateTunnelingProbability(barrierEnergy, energy, mass)

    if math.random() < tunnelingProb then
        -- Successful tunneling
        HYPERDRIVE.Quantum.Log("Quantum tunneling successful", engine)

        -- Apply energy discount
        local energyCost = HYPERDRIVE.CalculateEnergyCost(distance)
        energyCost = energyCost * (1 - HYPERDRIVE.Quantum.Config.TunnelingEnergyDiscount)

        return true, energyCost
    end

    return false
end

-- Quantum superposition system
function HYPERDRIVE.Quantum.CreateSuperposition(engine, destinations)
    if not HYPERDRIVE.Quantum.Config.EnableSuperposition then return false end
    if not IsValid(engine) then return false end

    destinations = destinations or {}
    if #destinations < 2 then return false end

    -- Limit to maximum states
    local maxStates = HYPERDRIVE.Quantum.Config.SuperpositionStates
    if #destinations > maxStates then
        for i = maxStates + 1, #destinations do
            destinations[i] = nil
        end
    end

    local superposition = {
        engine = engine,
        states = {},
        created = CurTime(),
        collapsed = false
    }

    -- Create quantum states
    for i, dest in ipairs(destinations) do
        local state = {
            destination = dest,
            probability = 1 / #destinations, -- Equal probability initially
            amplitude = math.sqrt(1 / #destinations),
            phase = math.random() * 2 * math.pi
        }
        table.insert(superposition.states, state)
    end

    HYPERDRIVE.Quantum.SuperpositionStates[engine:EntIndex()] = superposition

    -- Schedule collapse
    timer.Create("QuantumCollapse_" .. engine:EntIndex(), HYPERDRIVE.Quantum.Config.SuperpositionDecayTime, 1, function()
        HYPERDRIVE.Quantum.CollapseSuperposition(engine)
    end)

    HYPERDRIVE.Quantum.Log("Quantum superposition created with " .. #destinations .. " states", engine)
    return true
end

-- Collapse quantum superposition
function HYPERDRIVE.Quantum.CollapseSuperposition(engine)
    if not IsValid(engine) then return end

    local superposition = HYPERDRIVE.Quantum.SuperpositionStates[engine:EntIndex()]
    if not superposition or superposition.collapsed then return end

    -- Calculate probabilities
    local totalProbability = 0
    for _, state in ipairs(superposition.states) do
        totalProbability = totalProbability + state.probability
    end

    -- Normalize probabilities
    for _, state in ipairs(superposition.states) do
        state.probability = state.probability / totalProbability
    end

    -- Collapse to single state
    local random = math.random()
    local cumulative = 0
    local selectedState = nil

    for _, state in ipairs(superposition.states) do
        cumulative = cumulative + state.probability
        if random <= cumulative then
            selectedState = state
            break
        end
    end

    if selectedState then
        superposition.collapsed = true
        superposition.finalState = selectedState

        -- Set engine destination to collapsed state
        if engine.SetDestinationPos then
            engine:SetDestinationPos(selectedState.destination)
        end

        HYPERDRIVE.Quantum.Log("Quantum superposition collapsed", engine)

        -- Create collapse effect
        if CLIENT then
            HYPERDRIVE.Effects.CreateAdvancedParticles(engine:GetPos(), "quantum_collapse", 1.0, {
                destination = selectedState.destination
            })
        end
    end
end

-- Quantum entanglement system
function HYPERDRIVE.Quantum.CreateEntanglement(engine1, engine2)
    if not HYPERDRIVE.Quantum.Config.EnableEntanglement then return false end
    if not IsValid(engine1) or not IsValid(engine2) then return false end

    local distance = engine1:GetPos():Distance(engine2:GetPos())
    if distance > HYPERDRIVE.Quantum.Config.EntanglementRange then
        return false, "Engines too far apart for entanglement"
    end

    -- Check if already entangled
    for _, pair in ipairs(HYPERDRIVE.Quantum.EntangledPairs) do
        if (pair.engine1 == engine1 and pair.engine2 == engine2) or
           (pair.engine1 == engine2 and pair.engine2 == engine1) then
            return false, "Engines already entangled"
        end
    end

    -- Limit entangled pairs
    if #HYPERDRIVE.Quantum.EntangledPairs >= HYPERDRIVE.Quantum.Config.MaxEntangledPairs then
        return false, "Maximum entangled pairs reached"
    end

    local entanglement = {
        engine1 = engine1,
        engine2 = engine2,
        created = CurTime(),
        syncCount = 0,
        lastSync = 0
    }

    table.insert(HYPERDRIVE.Quantum.EntangledPairs, entanglement)

    HYPERDRIVE.Quantum.Log("Quantum entanglement created", engine1)
    return true
end

-- Update entangled engines
function HYPERDRIVE.Quantum.UpdateEntanglement()
    for i = #HYPERDRIVE.Quantum.EntangledPairs, 1, -1 do
        local pair = HYPERDRIVE.Quantum.EntangledPairs[i]

        -- Check if engines still exist
        if not IsValid(pair.engine1) or not IsValid(pair.engine2) then
            table.remove(HYPERDRIVE.Quantum.EntangledPairs, i)
            continue
        end

        -- Check distance
        local distance = pair.engine1:GetPos():Distance(pair.engine2:GetPos())
        if distance > HYPERDRIVE.Quantum.Config.EntanglementRange then
            table.remove(HYPERDRIVE.Quantum.EntangledPairs, i)
            HYPERDRIVE.Quantum.Log("Entanglement broken due to distance", pair.engine1)
            continue
        end

        -- Synchronize states
        if CurTime() - pair.lastSync > HYPERDRIVE.Quantum.Config.EntanglementSyncDelay then
            HYPERDRIVE.Quantum.SynchronizeEntangledEngines(pair)
            pair.lastSync = CurTime()
            pair.syncCount = pair.syncCount + 1
        end
    end
end

-- Synchronize entangled engines
function HYPERDRIVE.Quantum.SynchronizeEntangledEngines(pair)
    local engine1 = pair.engine1
    local engine2 = pair.engine2

    -- Synchronize energy levels
    if engine1.GetEnergy and engine2.GetEnergy and engine1.SetEnergy and engine2.SetEnergy then
        local avgEnergy = (engine1:GetEnergy() + engine2:GetEnergy()) / 2
        engine1:SetEnergy(avgEnergy)
        engine2:SetEnergy(avgEnergy)
    end

    -- Synchronize charging states
    if engine1.GetCharging and engine2.GetCharging and engine1.SetCharging and engine2.SetCharging then
        local charging = engine1:GetCharging() or engine2:GetCharging()
        engine1:SetCharging(charging)
        engine2:SetCharging(charging)
    end

    -- Synchronize destinations (with uncertainty)
    if engine1.GetDestination and engine2.GetDestination and engine1.SetDestinationPos and engine2.SetDestinationPos then
        local dest1 = engine1:GetDestination()
        local dest2 = engine2:GetDestination()

        if dest1 ~= Vector(0, 0, 0) and dest2 == Vector(0, 0, 0) then
            -- Apply uncertainty to destination
            local uncertainty = VectorRand() * HYPERDRIVE.Quantum.Config.PositionUncertainty
            engine2:SetDestinationPos(dest1 + uncertainty)
        elseif dest2 ~= Vector(0, 0, 0) and dest1 == Vector(0, 0, 0) then
            local uncertainty = VectorRand() * HYPERDRIVE.Quantum.Config.PositionUncertainty
            engine1:SetDestinationPos(dest2 + uncertainty)
        end
    end
end

-- Quantum uncertainty principle
function HYPERDRIVE.Quantum.ApplyUncertainty(position, momentum)
    if not HYPERDRIVE.Quantum.Config.EnableUncertainty then return position, momentum end

    -- Heisenberg uncertainty principle: Δx * Δp >= ℏ/2
    local hbar = HYPERDRIVE.Quantum.Config.PlancksConstant / (2 * math.pi)

    -- Calculate minimum uncertainty product
    local minUncertaintyProduct = hbar / 2

    -- Apply position uncertainty
    local positionUncertainty = VectorRand() * HYPERDRIVE.Quantum.Config.PositionUncertainty
    local uncertainPosition = position + positionUncertainty

    -- Apply momentum uncertainty (affects velocity)
    local momentumUncertainty = VectorRand() * HYPERDRIVE.Quantum.Config.MomentumUncertainty
    local uncertainMomentum = momentum + momentumUncertainty

    return uncertainPosition, uncertainMomentum
end

-- Quantum fluctuation effects
function HYPERDRIVE.Quantum.ApplyQuantumFluctuations(engine)
    if not IsValid(engine) then return end
    if math.random() > HYPERDRIVE.Quantum.Config.QuantumFluctuationRate then return end

    -- Random energy fluctuation
    if engine.GetEnergy and engine.SetEnergy then
        local currentEnergy = engine:GetEnergy()
        local fluctuation = (math.random() - 0.5) * 20 -- ±10 energy units
        local newEnergy = math.max(0, currentEnergy + fluctuation)
        engine:SetEnergy(newEnergy)
    end

    -- Random position fluctuation (very small)
    local currentPos = engine:GetPos()
    local fluctuation = VectorRand() * 5 -- ±5 units
    engine:SetPos(currentPos + fluctuation)

    HYPERDRIVE.Quantum.Log("Quantum fluctuation applied", engine)
end

-- Quantum measurement collapse
function HYPERDRIVE.Quantum.MeasureQuantumState(engine)
    if not IsValid(engine) then return end

    -- Collapse any active superposition
    local superposition = HYPERDRIVE.Quantum.SuperpositionStates[engine:EntIndex()]
    if superposition and not superposition.collapsed then
        HYPERDRIVE.Quantum.CollapseSuperposition(engine)
    end

    -- Apply measurement uncertainty
    if engine.GetDestination and engine.SetDestinationPos then
        local destination = engine:GetDestination()
        if destination ~= Vector(0, 0, 0) then
            local uncertainty = VectorRand() * HYPERDRIVE.Quantum.Config.PositionUncertainty * 0.1
            engine:SetDestinationPos(destination + uncertainty)
        end
    end
end

-- Quantum logging
function HYPERDRIVE.Quantum.Log(message, engine)
    local engineInfo = IsValid(engine) and (" [" .. engine:GetClass() .. ":" .. engine:EntIndex() .. "]") or ""
    if HYPERDRIVE.Debug then
        HYPERDRIVE.Debug.Info("QUANTUM: " .. message .. engineInfo, "QUANTUM")
    else
        print("[Hyperdrive Quantum] " .. message .. engineInfo)
    end
end

-- Update quantum systems
function HYPERDRIVE.Quantum.Think()
    -- Update entanglement
    HYPERDRIVE.Quantum.UpdateEntanglement()

    -- Apply quantum fluctuations to all engines
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive") and string.find(ent:GetClass(), "engine") then
            HYPERDRIVE.Quantum.ApplyQuantumFluctuations(ent)
        end
    end
end

-- Hook quantum updates
hook.Add("Think", "HyperdriveQuantumThink", function()
    if math.random() < 0.01 then -- 1% chance per frame to reduce performance impact
        HYPERDRIVE.Quantum.Think()
    end
end)

-- Console commands for quantum mechanics
concommand.Add("hyperdrive_quantum_entangle", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or not string.find(trace.Entity:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive Quantum] Look at a hyperdrive engine")
        return
    end

    local engine1 = trace.Entity

    -- Find another engine nearby
    local nearbyEngines = ents.FindInSphere(engine1:GetPos(), 1000)
    local engine2 = nil

    for _, ent in ipairs(nearbyEngines) do
        if IsValid(ent) and ent ~= engine1 and string.find(ent:GetClass(), "hyperdrive") then
            engine2 = ent
            break
        end
    end

    if not engine2 then
        ply:ChatPrint("[Hyperdrive Quantum] No other hyperdrive engine found nearby")
        return
    end

    local success, message = HYPERDRIVE.Quantum.CreateEntanglement(engine1, engine2)
    ply:ChatPrint("[Hyperdrive Quantum] " .. (message or (success and "Entanglement created" or "Entanglement failed")))
end)

concommand.Add("hyperdrive_quantum_superposition", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or not string.find(trace.Entity:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive Quantum] Look at a hyperdrive engine")
        return
    end

    local engine = trace.Entity
    local destinations = {}

    -- Create random destinations around the player
    for i = 1, 3 do
        local dest = ply:GetPos() + VectorRand() * 2000
        dest.z = dest.z + 100 -- Ensure above ground
        table.insert(destinations, dest)
    end

    local success = HYPERDRIVE.Quantum.CreateSuperposition(engine, destinations)
    ply:ChatPrint("[Hyperdrive Quantum] " .. (success and "Superposition created" or "Superposition failed"))
end)

print("[Hyperdrive] Quantum mechanics system loaded")
