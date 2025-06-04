-- Advanced Space Combat - Enhanced Hyperspace System v3.0
-- Research-based improvements with Stargate theme preservation
-- Based on web research and Stargate universe mechanics

print("[Advanced Space Combat] Enhanced Hyperspace System v3.0 Loading...")

ASC = ASC or {}
ASC.EnhancedHyperspace = ASC.EnhancedHyperspace or {}

-- Enhanced configuration based on research
ASC.EnhancedHyperspace.Config = {
    -- Stargate-themed 4-stage system improvements (Web Research Enhanced)
    StageSystem = {
        EnableAdvancedStages = true,
        EnableWebResearchEnhancements = true,  -- Research-based improvements

        -- Optimized stage durations based on research
        Stage1Duration = 4.0,  -- Extended initiation for better energy buildup
        Stage2Duration = 3.5,  -- Enhanced window opening with progressive vortex
        Stage3Duration = 6.0,  -- Longer hyperspace for immersive dimensional travel
        Stage4Duration = 2.5,  -- Extended exit with proper stabilization

        -- Enhanced stage mechanics (Research-Based)
        EnergyBuildupRate = 2.0,           -- Increased buildup intensity
        WindowStabilityTime = 3.0,         -- Longer stabilization
        DimensionalTransitSpeed = 1.5,     -- Smoother transit
        ExitSequenceIntensity = 1.8,       -- More dramatic exit

        -- New research-based features
        EnableProgressiveVortex = true,     -- Progressive vortex formation
        EnableEnergyHarmonics = true,       -- Energy frequency synchronization
        EnableSpatialDistortion = true,     -- Space-time distortion effects
        EnableParticleStreams = true,       -- Advanced particle systems
        EnableTimeDialation = true,         -- Time distortion during travel
        EnableQuantumResonance = true       -- Quantum field resonance
    },
    
    -- Advanced hyperspace mechanics (TARDIS-Inspired + Web Research)
    HyperspacePhysics = {
        EnableSpatialFolding = true,      -- TARDIS-inspired space folding
        EnableDimensionalLayers = true,   -- Multiple hyperspace layers
        EnableQuantumTunneling = true,    -- Quantum mechanics integration
        EnableTimeDistortion = true,      -- Time dilation effects
        EnableVortexDynamics = true,      -- Swirling vortex mechanics
        EnableEnergyResonance = true,     -- Energy field resonance
        EnableSpaceTimeRifts = true,      -- Dimensional tear effects
        EnableHyperspaceStreams = true,   -- Energy stream corridors

        -- Enhanced physics parameters (Research-Optimized)
        FoldingEfficiency = 0.90,         -- 90% distance reduction (improved)
        LayerSeparation = 8000,           -- Closer layers for better navigation
        QuantumStability = 0.98,          -- Higher tunnel stability
        TimeDistortionFactor = 0.15,      -- More noticeable time effects
        VortexRotationSpeed = 2.5,        -- Vortex rotation rate
        EnergyResonanceFreq = 304.8,      -- Stargate frequency reference
        RiftStabilityTime = 5.0,          -- Dimensional rift duration
        StreamDensity = 200               -- Energy stream count
    },
    
    -- Enhanced visual effects (Web Research Enhanced)
    VisualEffects = {
        EnableAdvancedParticles = true,
        EnableEnergyStreams = true,
        EnableDimensionalRifts = true,
        EnableStargateGlow = true,
        EnableProgressiveBuildup = true,   -- Progressive effect buildup
        EnableSwirlingVortex = true,       -- Swirling vortex dynamics
        EnableEnergyArcs = true,           -- Electrical arc effects
        EnableSpatialDistortion = true,    -- Space distortion visuals
        EnableQuantumFluctuations = true,  -- Quantum field fluctuations
        EnableHyperspaceStreaks = true,    -- Hyperspace streak effects

        -- Enhanced effect intensities (Research-Optimized)
        ParticleCount = 3000,              -- Increased particle density
        StreamDensity = 250,               -- More energy streams
        RiftComplexity = 12,               -- More complex rifts
        GlowIntensity = 2.0,               -- Brighter glow
        VortexComplexity = 16,             -- Vortex detail level
        ArcFrequency = 8,                  -- Energy arc frequency
        DistortionStrength = 1.5,          -- Distortion intensity
        QuantumFluctuation = 0.3,          -- Quantum noise level

        -- Enhanced Stargate-specific colors (Research-Based)
        InitiationColor = Color(80, 120, 255, 255),   -- Deep blue energy
        WindowColor = Color(120, 180, 255, 255),      -- Bright blue vortex
        TravelColor = Color(160, 200, 255, 255),      -- Light blue tunnel
        ExitColor = Color(255, 255, 255, 255),        -- Brilliant white flash
        VortexColor = Color(100, 150, 255, 200),      -- Swirling vortex
        ArcColor = Color(150, 200, 255, 180),         -- Energy arcs
        QuantumColor = Color(200, 220, 255, 100)      -- Quantum fluctuations
    },
    
    -- Master engine coordination
    MasterEngineSystem = {
        EnableMultiEngineSync = true,
        EnableLoadBalancing = true,
        EnableRedundancy = true,
        EnableEfficiencyBonus = true,
        
        -- Coordination parameters
        SyncTolerance = 0.1,              -- 100ms sync tolerance
        LoadBalanceThreshold = 0.8,       // 80% load threshold
        RedundancyFactor = 2,             // Backup engine count
        EfficiencyBonus = 0.25            // 25% bonus per additional engine
    }
}

-- Enhanced 4-stage travel system
function ASC.EnhancedHyperspace.StartAdvanced4StageTravel(engine, destination, entities)
    if not IsValid(engine) then return false, "Invalid engine" end
    
    local config = ASC.EnhancedHyperspace.Config.StageSystem
    local travelData = {
        engine = engine,
        destination = destination,
        entities = entities,
        startTime = CurTime(),
        currentStage = 1,
        stageStartTime = CurTime(),
        totalDuration = config.Stage1Duration + config.Stage2Duration + 
                       config.Stage3Duration + config.Stage4Duration
    }
    
    -- Store travel data
    engine.EnhancedHyperspaceData = travelData
    
    -- Start stage 1: Enhanced initiation
    ASC.EnhancedHyperspace.ExecuteStage1(travelData)
    
    return true, "Enhanced 4-stage travel initiated"
end

-- Stage 1: Enhanced Initiation with Energy Surge
function ASC.EnhancedHyperspace.ExecuteStage1(travelData)
    local engine = travelData.engine
    local config = ASC.EnhancedHyperspace.Config
    
    print("[Enhanced Hyperspace] Stage 1: Advanced Initiation")
    
    -- Enhanced energy buildup
    ASC.EnhancedHyperspace.CreateEnergyBuildupEffect(engine)
    
    -- Coordinate calculation with quantum mechanics
    ASC.EnhancedHyperspace.CalculateQuantumCoordinates(engine, travelData.destination)
    
    -- Spatial folding preparation
    if config.HyperspacePhysics.EnableSpatialFolding then
        ASC.EnhancedHyperspace.PrepareSpatialFolding(engine, travelData.destination)
    end
    
    -- Advanced to stage 2
    timer.Simple(config.StageSystem.Stage1Duration, function()
        if IsValid(engine) and engine.EnhancedHyperspaceData then
            ASC.EnhancedHyperspace.ExecuteStage2(travelData)
        end
    end)
end

-- Stage 2: Enhanced Window Opening with Blue Vortex
function ASC.EnhancedHyperspace.ExecuteStage2(travelData)
    local engine = travelData.engine
    local config = ASC.EnhancedHyperspace.Config
    
    print("[Enhanced Hyperspace] Stage 2: Advanced Window Opening")
    travelData.currentStage = 2
    travelData.stageStartTime = CurTime()
    
    -- Create enhanced hyperspace window
    ASC.EnhancedHyperspace.CreateAdvancedHyperspaceWindow(engine)
    
    -- Blue swirling energy tunnel
    ASC.EnhancedHyperspace.CreateStargateVortex(engine, travelData.destination)
    
    -- Dimensional layer selection
    if config.HyperspacePhysics.EnableDimensionalLayers then
        travelData.selectedLayer = ASC.EnhancedHyperspace.SelectOptimalLayer(engine, travelData.destination)
    end
    
    -- Advance to stage 3
    timer.Simple(config.StageSystem.Stage2Duration, function()
        if IsValid(engine) and engine.EnhancedHyperspaceData then
            ASC.EnhancedHyperspace.ExecuteStage3(travelData)
        end
    end)
end

-- Stage 3: Enhanced Hyperspace Travel with Advanced Mechanics
function ASC.EnhancedHyperspace.ExecuteStage3(travelData)
    local engine = travelData.engine
    local config = ASC.EnhancedHyperspace.Config
    
    print("[Enhanced Hyperspace] Stage 3: Advanced Dimensional Transit")
    travelData.currentStage = 3
    travelData.stageStartTime = CurTime()
    
    -- Move entities to enhanced hyperspace
    ASC.EnhancedHyperspace.TransportToEnhancedHyperspace(travelData)
    
    -- Apply advanced hyperspace physics
    if config.HyperspacePhysics.EnableTimeDistortion then
        ASC.EnhancedHyperspace.ApplyTimeDistortion(travelData.entities)
    end
    
    -- Create stretched starlines effect (Stargate style)
    ASC.EnhancedHyperspace.CreateAdvancedStarlines(engine, travelData.destination)
    
    -- Dimensional visuals with quantum tunneling
    if config.HyperspacePhysics.EnableQuantumTunneling then
        ASC.EnhancedHyperspace.CreateQuantumTunnel(engine, travelData)
    end
    
    -- Advance to stage 4
    timer.Simple(config.StageSystem.Stage3Duration, function()
        if IsValid(engine) and engine.EnhancedHyperspaceData then
            ASC.EnhancedHyperspace.ExecuteStage4(travelData)
        end
    end)
end

-- Stage 4: Enhanced Exit with System Stabilization
function ASC.EnhancedHyperspace.ExecuteStage4(travelData)
    local engine = travelData.engine
    local config = ASC.EnhancedHyperspace.Config
    
    print("[Enhanced Hyperspace] Stage 4: Advanced Exit Sequence")
    travelData.currentStage = 4
    travelData.stageStartTime = CurTime()
    
    -- Create enhanced exit flash
    ASC.EnhancedHyperspace.CreateAdvancedExitFlash(engine)
    
    -- Transport entities to destination
    ASC.EnhancedHyperspace.TransportToDestination(travelData)
    
    -- System stabilization
    ASC.EnhancedHyperspace.StabilizeHyperspaceSystem(engine)
    
    -- Complete travel
    timer.Simple(config.StageSystem.Stage4Duration, function()
        if IsValid(engine) then
            ASC.EnhancedHyperspace.CompleteEnhancedTravel(travelData)
        end
    end)
end

-- Enhanced energy buildup effect
function ASC.EnhancedHyperspace.CreateEnergyBuildupEffect(engine)
    local effectData = EffectData()
    effectData:SetOrigin(engine:GetPos())
    effectData:SetScale(200)
    effectData:SetMagnitude(3.0)
    effectData:SetRadius(150)
    util.Effect("asc_enhanced_energy_buildup", effectData)
    
    -- Screen shake for energy surge
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():Distance(engine:GetPos()) < 2000 then
            util.ScreenShake(ply:GetPos(), 8, 5, 3, 1500)
        end
    end
end

-- Quantum coordinate calculation
function ASC.EnhancedHyperspace.CalculateQuantumCoordinates(engine, destination)
    local distance = engine:GetPos():Distance(destination)
    local quantumFactor = ASC.EnhancedHyperspace.Config.HyperspacePhysics.QuantumStability
    
    -- Calculate quantum-corrected coordinates
    local correctedDestination = destination + Vector(
        math.random(-50, 50) * (1 - quantumFactor),
        math.random(-50, 50) * (1 - quantumFactor),
        math.random(-25, 25) * (1 - quantumFactor)
    )
    
    engine.QuantumDestination = correctedDestination
    print("[Enhanced Hyperspace] Quantum coordinates calculated with " .. 
          math.floor(quantumFactor * 100) .. "% stability")
end

-- Spatial folding preparation
function ASC.EnhancedHyperspace.PrepareSpatialFolding(engine, destination)
    local foldingEfficiency = ASC.EnhancedHyperspace.Config.HyperspacePhysics.FoldingEfficiency
    local actualDistance = engine:GetPos():Distance(destination)
    local foldedDistance = actualDistance * (1 - foldingEfficiency)
    
    engine.SpatialFoldingData = {
        originalDistance = actualDistance,
        foldedDistance = foldedDistance,
        efficiency = foldingEfficiency,
        energySaved = actualDistance * 0.1 * foldingEfficiency
    }
    
    print("[Enhanced Hyperspace] Spatial folding prepared: " .. 
          math.floor(actualDistance) .. " -> " .. math.floor(foldedDistance) .. " units")
end

-- Enhanced master engine coordination
function ASC.EnhancedHyperspace.CoordinateMasterEngines(primaryEngine, destination)
    local config = ASC.EnhancedHyperspace.Config.MasterEngineSystem
    if not config.EnableMultiEngineSync then return {primaryEngine} end
    
    -- Find nearby master engines
    local nearbyEngines = {}
    for _, ent in ipairs(ents.FindInSphere(primaryEngine:GetPos(), 2000)) do
        if ent:GetClass() == "hyperdrive_master_engine" and ent ~= primaryEngine then
            table.insert(nearbyEngines, ent)
        end
    end
    
    if #nearbyEngines == 0 then return {primaryEngine} end
    
    -- Synchronize engines
    local syncedEngines = {primaryEngine}
    for _, engine in ipairs(nearbyEngines) do
        if ASC.EnhancedHyperspace.SynchronizeEngine(engine, primaryEngine) then
            table.insert(syncedEngines, engine)
        end
    end
    
    print("[Enhanced Hyperspace] Coordinated " .. #syncedEngines .. " master engines")
    return syncedEngines
end

-- Web Research Enhanced Functions

-- Create progressive vortex formation (Research-Based)
function ASC.EnhancedHyperspace.CreateProgressiveVortex(engine, stage)
    local config = ASC.EnhancedHyperspace.Config.VisualEffects
    if not config.EnableProgressiveBuildup then return end

    local intensity = stage / 4.0  -- Progressive intensity based on stage
    local vortexData = {
        position = engine:GetPos(),
        rotation = CurTime() * config.VortexComplexity,
        intensity = intensity,
        radius = 100 + (stage * 50),
        complexity = config.VortexComplexity
    }

    -- Create swirling vortex effect
    local effectData = EffectData()
    effectData:SetOrigin(vortexData.position)
    effectData:SetScale(vortexData.radius)
    effectData:SetMagnitude(vortexData.intensity)
    effectData:SetRadius(vortexData.complexity)
    util.Effect("asc_progressive_vortex", effectData)

    print("[Enhanced Hyperspace] Progressive vortex created - Stage " .. stage ..
          " Intensity: " .. math.floor(intensity * 100) .. "%")
end

-- Create energy harmonics synchronization (Research-Based)
function ASC.EnhancedHyperspace.CreateEnergyHarmonics(engine, frequency)
    local config = ASC.EnhancedHyperspace.Config.HyperspacePhysics
    if not config.EnableEnergyResonance then return end

    frequency = frequency or config.EnergyResonanceFreq

    -- Create harmonic resonance field
    local harmonicData = {
        frequency = frequency,
        amplitude = 1.0,
        phase = CurTime() * frequency / 100,
        resonanceField = 500
    }

    -- Apply harmonic effects to nearby entities
    for _, ent in ipairs(ents.FindInSphere(engine:GetPos(), harmonicData.resonanceField)) do
        if ent:IsPlayer() then
            -- Subtle screen effect for harmonic resonance
            net.Start("asc_harmonic_resonance")
            net.WriteFloat(harmonicData.frequency)
            net.WriteFloat(harmonicData.amplitude)
            net.Send(ent)
        end
    end

    print("[Enhanced Hyperspace] Energy harmonics synchronized at " .. frequency .. " Hz")
end

-- Create spatial distortion effects (TARDIS-Inspired)
function ASC.EnhancedHyperspace.CreateSpatialDistortion(engine, destination)
    local config = ASC.EnhancedHyperspace.Config.VisualEffects
    if not config.EnableSpatialDistortion then return end

    local distance = engine:GetPos():Distance(destination)
    local distortionStrength = config.DistortionStrength

    -- Create space-time distortion field
    local distortionData = {
        origin = engine:GetPos(),
        target = destination,
        strength = distortionStrength,
        radius = math.min(1000, distance * 0.1),
        waveLength = 200,
        frequency = 2.0
    }

    -- Visual distortion effect
    local effectData = EffectData()
    effectData:SetOrigin(distortionData.origin)
    effectData:SetStart(distortionData.target)
    effectData:SetScale(distortionData.strength)
    effectData:SetRadius(distortionData.radius)
    util.Effect("asc_spatial_distortion", effectData)

    print("[Enhanced Hyperspace] Spatial distortion field created - Strength: " ..
          distortionStrength .. " Radius: " .. math.floor(distortionData.radius))
end

-- Create quantum fluctuation effects (Research-Based)
function ASC.EnhancedHyperspace.CreateQuantumFluctuations(engine, entities)
    local config = ASC.EnhancedHyperspace.Config.VisualEffects
    if not config.EnableQuantumFluctuations then return end

    local fluctuationLevel = config.QuantumFluctuation

    -- Apply quantum fluctuations to entities
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            -- Subtle position fluctuations
            local fluctuation = Vector(
                math.random(-10, 10) * fluctuationLevel,
                math.random(-10, 10) * fluctuationLevel,
                math.random(-5, 5) * fluctuationLevel
            )

            -- Store original position for restoration
            if not ent.QuantumOriginalPos then
                ent.QuantumOriginalPos = ent:GetPos()
            end

            -- Apply fluctuation
            ent:SetPos(ent.QuantumOriginalPos + fluctuation)

            -- Restore position after brief fluctuation
            timer.Simple(0.1, function()
                if IsValid(ent) and ent.QuantumOriginalPos then
                    ent:SetPos(ent.QuantumOriginalPos)
                end
            end)
        end
    end

    print("[Enhanced Hyperspace] Quantum fluctuations applied to " .. #entities .. " entities")
end

-- Create advanced hyperspace streaks (Research-Enhanced)
function ASC.EnhancedHyperspace.CreateAdvancedHyperspaceStreaks(engine, destination)
    local config = ASC.EnhancedHyperspace.Config.VisualEffects
    if not config.EnableHyperspaceStreaks then return end

    local direction = (destination - engine:GetPos()):GetNormalized()
    local streakCount = config.StreamDensity

    -- Create hyperspace streak effects
    for i = 1, streakCount do
        local streakData = {
            start = engine:GetPos() + Vector(
                math.random(-200, 200),
                math.random(-200, 200),
                math.random(-100, 100)
            ),
            direction = direction,
            length = math.random(500, 1500),
            speed = math.random(2000, 5000),
            color = config.TravelColor
        }

        -- Create streak effect
        local effectData = EffectData()
        effectData:SetOrigin(streakData.start)
        effectData:SetNormal(streakData.direction)
        effectData:SetScale(streakData.length)
        effectData:SetMagnitude(streakData.speed)
        util.Effect("asc_hyperspace_streak", effectData)
    end

    print("[Enhanced Hyperspace] " .. streakCount .. " hyperspace streaks created")
end

print("[Advanced Space Combat] Enhanced Hyperspace System v3.0 with Web Research Improvements Loaded Successfully!")
