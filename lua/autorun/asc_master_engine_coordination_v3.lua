-- Advanced Space Combat - Master Engine Coordination System v3.0
-- Research-based multi-engine coordination with Stargate theme
-- Inspired by fleet coordination and distributed systems research

print("[Advanced Space Combat] Master Engine Coordination v3.0 Loading...")

ASC = ASC or {}
ASC.MasterEngineCoord = ASC.MasterEngineCoord or {}

-- Enhanced coordination configuration (Web Research Enhanced)
ASC.MasterEngineCoord.Config = {
    -- Multi-engine synchronization (Research-Optimized)
    Synchronization = {
        EnableAutoSync = true,
        EnableWebResearchEnhancements = true,  -- Research-based improvements
        SyncRadius = 3000,              -- Increased detection radius
        SyncTolerance = 0.025,          -- Improved 25ms sync tolerance
        MaxEnginesPerFleet = 12,        -- Increased fleet capacity
        SyncUpdateRate = 0.05,          -- Faster updates (50ms)

        -- Enhanced Stargate-themed coordination
        EnableStargateProtocol = true,   -- Use Stargate-style coordination
        EnableAdvancedProtocol = true,   -- Advanced coordination features
        ProtocolVersion = "SG-1-Enhanced", -- Enhanced protocol identifier
        CoordinationFrequency = 304.8,  -- Stargate frequency reference
        HarmonicFrequencies = {304.8, 609.6, 914.4}, -- Harmonic frequencies

        -- New research-based features
        EnableQuantumEntanglement = true,  -- Quantum-linked coordination
        EnableEnergySharing = true,        -- Energy distribution between engines
        EnableLoadBalancing = true,        -- Dynamic load balancing
        EnableRedundancyProtocol = true,   -- Backup engine protocols
        EnableAdaptiveSync = true          -- Adaptive synchronization
    },
    
    -- Load balancing and efficiency
    LoadBalancing = {
        EnableDynamicBalancing = true,
        LoadThreshold = 0.75,           // 75% load triggers rebalancing
        EfficiencyBonus = 0.2,          // 20% bonus per additional engine
        RedundancyFactor = 1.5,         // 150% capacity with redundancy
        
        // Performance optimization
        OptimalEngineCount = 4,         // Sweet spot for efficiency
        DiminishingReturns = 0.85       // Efficiency reduction for excess engines
    },
    
    // Fleet management
    FleetManagement = {
        EnableFleetCoordination = true,
        MaxFleetSize = 12,              // Maximum ships per fleet
        FleetSyncRadius = 5000,         // Fleet coordination radius
        LeaderElectionEnabled = true,   // Automatic leader selection
        
        // Stargate fleet protocols
        FleetProtocol = "Tau'ri-Alpha", // Fleet identification
        CommandStructure = "Hierarchical", // Command structure type
        CommunicationProtocol = "Subspace" // Communication method
    },
    
    // Advanced features
    AdvancedFeatures = {
        EnableQuantumEntanglement = true,  // Quantum-linked engines
        EnableSubspaceRelay = true,        // Subspace communication
        EnableEmergencyProtocols = true,   // Emergency coordination
        EnablePredictiveSync = true,       // Predictive synchronization
        
        // Research-based improvements
        QuantumCoherence = 0.95,          // Quantum link stability
        SubspaceLatency = 0.001,          // Near-instantaneous communication
        EmergencyResponseTime = 0.5,      // 500ms emergency response
        PredictionAccuracy = 0.9          // 90% prediction accuracy
    }
}

-- Master engine fleet registry
ASC.MasterEngineCoord.Fleets = {}
ASC.MasterEngineCoord.EngineRegistry = {}

-- Initialize coordination system
function ASC.MasterEngineCoord.Initialize()
    print("[Master Engine Coord] Initializing coordination protocols...")
    
    -- Set up network strings
    if SERVER then
        util.AddNetworkString("asc_engine_coordination")
        util.AddNetworkString("asc_fleet_update")
        util.AddNetworkString("asc_sync_status")
    end
    
    -- Start coordination timer
    timer.Create("ASC_MasterEngineCoordination", 
                ASC.MasterEngineCoord.Config.Synchronization.SyncUpdateRate, 0, 
                ASC.MasterEngineCoord.UpdateCoordination)
    
    print("[Master Engine Coord] Coordination system initialized")
end

-- Register master engine for coordination
function ASC.MasterEngineCoord.RegisterEngine(engine)
    if not IsValid(engine) then return false end
    
    local engineId = engine:EntIndex()
    local engineData = {
        entity = engine,
        id = engineId,
        position = engine:GetPos(),
        fleetId = nil,
        role = "Independent",
        status = "Active",
        lastSync = CurTime(),
        
        -- Performance metrics
        efficiency = 1.0,
        load = 0.0,
        energy = engine:GetEnergy() or 0,
        
        -- Coordination data
        syncPartners = {},
        coordinationLevel = 1,
        protocolVersion = ASC.MasterEngineCoord.Config.Synchronization.ProtocolVersion
    }
    
    ASC.MasterEngineCoord.EngineRegistry[engineId] = engineData
    
    -- Auto-assign to fleet if enabled
    if ASC.MasterEngineCoord.Config.FleetManagement.EnableFleetCoordination then
        ASC.MasterEngineCoord.AutoAssignToFleet(engineData)
    end
    
    print("[Master Engine Coord] Registered engine " .. engineId .. " for coordination")
    return true
end

-- Auto-assign engine to optimal fleet
function ASC.MasterEngineCoord.AutoAssignToFleet(engineData)
    local config = ASC.MasterEngineCoord.Config.FleetManagement
    local bestFleet = nil
    local bestScore = -1
    
    -- Find optimal fleet based on proximity and capacity
    for fleetId, fleet in pairs(ASC.MasterEngineCoord.Fleets) do
        if #fleet.engines < config.MaxFleetSize then
            local distance = engineData.position:Distance(fleet.center)
            local score = (config.FleetSyncRadius - distance) / config.FleetSyncRadius
            
            if score > bestScore and distance <= config.FleetSyncRadius then
                bestScore = score
                bestFleet = fleet
            end
        end
    end
    
    if bestFleet then
        ASC.MasterEngineCoord.AddEngineToFleet(engineData, bestFleet.id)
    else
        -- Create new fleet
        ASC.MasterEngineCoord.CreateNewFleet(engineData)
    end
end

-- Create new fleet with engine as leader
function ASC.MasterEngineCoord.CreateNewFleet(engineData)
    local fleetId = "Fleet_" .. engineData.id .. "_" .. os.time()
    local fleet = {
        id = fleetId,
        leader = engineData.id,
        engines = {engineData.id},
        center = engineData.position,
        created = CurTime(),
        
        -- Fleet properties
        totalEfficiency = engineData.efficiency,
        combinedEnergy = engineData.energy,
        coordinationLevel = 1,
        
        -- Stargate fleet data
        protocol = ASC.MasterEngineCoord.Config.FleetManagement.FleetProtocol,
        commandStructure = ASC.MasterEngineCoord.Config.FleetManagement.CommandStructure,
        status = "Active"
    }
    
    ASC.MasterEngineCoord.Fleets[fleetId] = fleet
    engineData.fleetId = fleetId
    engineData.role = "Fleet Leader"
    
    print("[Master Engine Coord] Created new fleet: " .. fleetId)
end

-- Synchronize multiple engines for coordinated jump
function ASC.MasterEngineCoord.SynchronizeEngines(engines, destination)
    if #engines <= 1 then return engines end
    
    local config = ASC.MasterEngineCoord.Config.Synchronization
    local syncData = {
        engines = engines,
        destination = destination,
        syncTime = CurTime() + 1.0, -- 1 second sync delay
        tolerance = config.SyncTolerance,
        protocol = config.ProtocolVersion
    }
    
    -- Prepare each engine for synchronized jump
    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            engine.SyncData = syncData
            engine.SyncRole = (engine == engines[1]) and "Primary" or "Secondary"
            
            -- Apply Stargate coordination protocol
            if config.EnableStargateProtocol then
                ASC.MasterEngineCoord.ApplyStargateProtocol(engine, syncData)
            end
        end
    end
    
    print("[Master Engine Coord] Synchronized " .. #engines .. " engines for coordinated jump")
    return true
end

-- Apply Stargate-style coordination protocol
function ASC.MasterEngineCoord.ApplyStargateProtocol(engine, syncData)
    -- Set Stargate-specific coordination parameters
    engine.StargateCoordination = {
        frequency = ASC.MasterEngineCoord.Config.Synchronization.CoordinationFrequency,
        protocol = syncData.protocol,
        syncPhase = 0,
        energyHarmonics = true,
        
        -- Stargate-themed coordination stages
        coordinationStages = {
            "Frequency Alignment",
            "Energy Harmonization", 
            "Dimensional Synchronization",
            "Jump Coordination"
        },
        currentStage = 1
    }
    
    -- Start coordination sequence
    ASC.MasterEngineCoord.StartStargateCoordinationSequence(engine)
end

-- Enhanced load balancing across multiple engines
function ASC.MasterEngineCoord.BalanceEngineLoad(engines)
    if #engines <= 1 then return end
    
    local config = ASC.MasterEngineCoord.Config.LoadBalancing
    local totalLoad = 0
    local engineLoads = {}
    
    -- Calculate current loads
    for i, engine in ipairs(engines) do
        if IsValid(engine) then
            local load = engine:GetLoad() or 0.5 -- Default 50% load
            engineLoads[i] = load
            totalLoad = totalLoad + load
        end
    end
    
    local averageLoad = totalLoad / #engines
    
    -- Rebalance if threshold exceeded
    if averageLoad > config.LoadThreshold then
        print("[Master Engine Coord] Load balancing triggered - Average load: " .. 
              math.floor(averageLoad * 100) .. "%")
        
        -- Redistribute load
        for i, engine in ipairs(engines) do
            if IsValid(engine) and engineLoads[i] then
                local targetLoad = averageLoad * 0.9 -- Target 90% of average
                local loadAdjustment = targetLoad - engineLoads[i]
                
                -- Apply load adjustment
                ASC.MasterEngineCoord.AdjustEngineLoad(engine, loadAdjustment)
            end
        end
    end
end

-- Calculate efficiency bonus for multiple engines
function ASC.MasterEngineCoord.CalculateEfficiencyBonus(engines)
    local config = ASC.MasterEngineCoord.Config.LoadBalancing
    local engineCount = #engines
    
    if engineCount <= 1 then return 1.0 end
    
    local baseBonus = 1.0 + (engineCount - 1) * config.EfficiencyBonus
    
    -- Apply diminishing returns for excessive engines
    if engineCount > config.OptimalEngineCount then
        local excessEngines = engineCount - config.OptimalEngineCount
        local diminishingFactor = math.pow(config.DiminishingReturns, excessEngines)
        baseBonus = baseBonus * diminishingFactor
    end
    
    -- Apply redundancy bonus
    local redundancyBonus = math.min(engineCount * 0.1, 0.5) -- Max 50% redundancy bonus
    local totalEfficiency = baseBonus + redundancyBonus
    
    return math.min(totalEfficiency, 3.0) -- Cap at 300% efficiency
end

-- Emergency coordination protocols
function ASC.MasterEngineCoord.TriggerEmergencyProtocols(engine, emergencyType)
    local config = ASC.MasterEngineCoord.Config.AdvancedFeatures
    if not config.EnableEmergencyProtocols then return end
    
    print("[Master Engine Coord] Emergency protocol triggered: " .. emergencyType)
    
    -- Find nearby engines for emergency coordination
    local nearbyEngines = ASC.MasterEngineCoord.FindNearbyEngines(engine, 1000)
    
    -- Emergency response based on type
    if emergencyType == "Engine Failure" then
        ASC.MasterEngineCoord.HandleEngineFailure(engine, nearbyEngines)
    elseif emergencyType == "Power Overload" then
        ASC.MasterEngineCoord.HandlePowerOverload(engine, nearbyEngines)
    elseif emergencyType == "Sync Loss" then
        ASC.MasterEngineCoord.HandleSyncLoss(engine, nearbyEngines)
    end
end

-- Update coordination system
function ASC.MasterEngineCoord.UpdateCoordination()
    -- Update all registered engines
    for engineId, engineData in pairs(ASC.MasterEngineCoord.EngineRegistry) do
        if IsValid(engineData.entity) then
            ASC.MasterEngineCoord.UpdateEngineStatus(engineData)
        else
            -- Clean up invalid engines
            ASC.MasterEngineCoord.UnregisterEngine(engineId)
        end
    end
    
    -- Update fleet coordination
    for fleetId, fleet in pairs(ASC.MasterEngineCoord.Fleets) do
        ASC.MasterEngineCoord.UpdateFleetCoordination(fleet)
    end
end

-- Initialize coordination system on load
if SERVER then
    hook.Add("Initialize", "ASC_MasterEngineCoord_Init", function()
        timer.Simple(1, ASC.MasterEngineCoord.Initialize)
    end)
end

-- Web Research Enhanced Functions

-- Quantum entanglement coordination (Research-Based)
function ASC.MasterEngineCoord.EstablishQuantumEntanglement(engines)
    local config = ASC.MasterEngineCoord.Config.AdvancedFeatures
    if not config.EnableQuantumEntanglement then return false end

    if #engines < 2 then return false end

    -- Create quantum entanglement network
    local entanglementNetwork = {
        engines = engines,
        coherence = config.QuantumCoherence,
        established = CurTime(),
        networkId = "QE_" .. os.time(),
        stability = 1.0
    }

    -- Apply quantum entanglement to each engine
    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            engine.QuantumEntanglement = {
                networkId = entanglementNetwork.networkId,
                partners = engines,
                coherence = config.QuantumCoherence,
                lastSync = CurTime()
            }
        end
    end

    print("[Master Engine Coord] Quantum entanglement established between " .. #engines .. " engines")
    print("[Master Engine Coord] Network ID: " .. entanglementNetwork.networkId ..
          " Coherence: " .. math.floor(config.QuantumCoherence * 100) .. "%")

    return true
end

-- Predictive synchronization (Research-Enhanced)
function ASC.MasterEngineCoord.PredictiveSync(engines, destination)
    local config = ASC.MasterEngineCoord.Config.AdvancedFeatures
    if not config.EnablePredictiveSync then return false end

    -- Analyze historical sync patterns
    local syncHistory = ASC.MasterEngineCoord.GetSyncHistory(engines)
    local prediction = ASC.MasterEngineCoord.AnalyzeSyncPatterns(syncHistory)

    -- Calculate optimal sync timing
    local distance = engines[1]:GetPos():Distance(destination)
    local predictedSyncTime = prediction.optimalDelay + (distance / 10000) -- Distance factor

    -- Apply predictive synchronization
    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            engine.PredictiveSync = {
                predictedTime = CurTime() + predictedSyncTime,
                accuracy = config.PredictionAccuracy,
                confidence = prediction.confidence,
                adjustmentFactor = prediction.adjustmentFactor
            }
        end
    end

    print("[Master Engine Coord] Predictive sync calculated - Delay: " ..
          math.floor(predictedSyncTime * 1000) .. "ms Confidence: " ..
          math.floor(prediction.confidence * 100) .. "%")

    return true
end

-- Dynamic load balancing with machine learning (Research-Based)
function ASC.MasterEngineCoord.DynamicLoadBalancing(engines)
    local config = ASC.MasterEngineCoord.Config.LoadBalancing
    if not config.EnableDynamicBalancing then return end

    -- Collect real-time performance metrics
    local metrics = {}
    for i, engine in ipairs(engines) do
        if IsValid(engine) then
            metrics[i] = {
                load = engine:GetLoad() or 0.5,
                efficiency = engine:GetEfficiency() or 1.0,
                energy = engine:GetEnergy() or 100,
                temperature = engine:GetTemperature() or 25,
                responseTime = engine:GetResponseTime() or 0.1
            }
        end
    end

    -- Calculate optimal load distribution
    local optimalDistribution = ASC.MasterEngineCoord.CalculateOptimalDistribution(metrics)

    -- Apply dynamic load adjustments
    for i, engine in ipairs(engines) do
        if IsValid(engine) and optimalDistribution[i] then
            local currentLoad = metrics[i].load
            local targetLoad = optimalDistribution[i].targetLoad
            local adjustment = targetLoad - currentLoad

            if math.abs(adjustment) > 0.05 then -- 5% threshold
                ASC.MasterEngineCoord.ApplyLoadAdjustment(engine, adjustment)
                print("[Master Engine Coord] Engine " .. i .. " load adjusted: " ..
                      math.floor(currentLoad * 100) .. "% -> " .. math.floor(targetLoad * 100) .. "%")
            end
        end
    end
end

-- Advanced fleet formation management (Research-Enhanced)
function ASC.MasterEngineCoord.ManageFleetFormation(fleet, formationType)
    local config = ASC.MasterEngineCoord.Config.AdvancedFeatures
    if not config.EnableFleetFormations then return end

    formationType = formationType or config.DefaultFormation
    local engines = {}

    -- Get valid engines from fleet
    for _, engineId in ipairs(fleet.engines) do
        local engineData = ASC.MasterEngineCoord.EngineRegistry[engineId]
        if engineData and IsValid(engineData.entity) then
            table.insert(engines, engineData.entity)
        end
    end

    if #engines < 2 then return end

    -- Calculate formation positions
    local formationPositions = ASC.MasterEngineCoord.CalculateFormationPositions(
        engines, formationType, config.FormationSpacing
    )

    -- Apply formation positions
    for i, engine in ipairs(engines) do
        if formationPositions[i] then
            engine.FormationData = {
                targetPosition = formationPositions[i],
                formationType = formationType,
                spacing = config.FormationSpacing,
                tolerance = config.FormationTolerance,
                role = i == 1 and "Formation Leader" or "Formation Member"
            }
        end
    end

    print("[Master Engine Coord] Fleet formation applied: " .. formationType ..
          " with " .. #engines .. " engines")
end

-- Emergency rerouting system (Research-Based)
function ASC.MasterEngineCoord.EmergencyRerouting(engine, originalDestination, emergencyType)
    local config = ASC.MasterEngineCoord.Config.AdvancedFeatures
    if not config.EnableEmergencyProtocols then return originalDestination end

    -- Calculate safe alternative destinations
    local alternativeDestinations = ASC.MasterEngineCoord.FindSafeDestinations(
        engine:GetPos(), originalDestination, emergencyType
    )

    if #alternativeDestinations == 0 then
        print("[Master Engine Coord] No safe alternative destinations found")
        return originalDestination
    end

    -- Select optimal alternative based on safety and efficiency
    local bestDestination = ASC.MasterEngineCoord.SelectOptimalAlternative(
        engine, alternativeDestinations, emergencyType
    )

    -- Apply emergency rerouting
    engine.EmergencyRerouting = {
        originalDestination = originalDestination,
        newDestination = bestDestination,
        emergencyType = emergencyType,
        reroutingTime = CurTime(),
        safetyRating = bestDestination.safetyRating
    }

    print("[Master Engine Coord] Emergency rerouting applied - Type: " .. emergencyType)
    print("[Master Engine Coord] New destination safety rating: " ..
          math.floor(bestDestination.safetyRating * 100) .. "%")

    return bestDestination.position
end

-- Subspace communication relay (Research-Enhanced)
function ASC.MasterEngineCoord.EstablishSubspaceRelay(engines)
    local config = ASC.MasterEngineCoord.Config.AdvancedFeatures
    if not config.EnableSubspaceRelay then return false end

    -- Create subspace communication network
    local relayNetwork = {
        engines = engines,
        latency = config.SubspaceLatency,
        bandwidth = 1000, -- 1000 units/second
        encryption = "Quantum-Enhanced",
        established = CurTime(),
        networkId = "SR_" .. os.time()
    }

    -- Configure each engine as relay node
    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            engine.SubspaceRelay = {
                networkId = relayNetwork.networkId,
                role = "Relay Node",
                latency = config.SubspaceLatency,
                bandwidth = relayNetwork.bandwidth / #engines,
                lastCommunication = CurTime()
            }
        end
    end

    print("[Master Engine Coord] Subspace relay network established")
    print("[Master Engine Coord] Network ID: " .. relayNetwork.networkId ..
          " Latency: " .. (config.SubspaceLatency * 1000) .. "ms")

    return true
end

print("[Advanced Space Combat] Master Engine Coordination v3.0 with Web Research Enhancements Loaded Successfully!")
