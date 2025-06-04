-- Advanced Space Combat - Enhanced Stargate Visual Effects v3.0
-- Research-based Stargate hyperspace effects with improved mechanics
-- Based on Stargate universe visual design and game development research

if SERVER then return end

print("[Advanced Space Combat] Enhanced Stargate Effects v3.0 Loading...")

ASC = ASC or {}
ASC.StargateEffects = ASC.StargateEffects or {}

-- Enhanced effect configuration based on research
ASC.StargateEffects.Config = {
    -- Stargate-themed visual parameters
    StargateVisuals = {
        -- Stage 1: Energy buildup
        InitiationGlow = {
            color = Color(100, 150, 255, 255),
            intensity = 1.5,
            pulseRate = 2.0,
            expansionRate = 50,
            duration = 3.0
        },
        
        -- Stage 2: Window opening
        WindowOpening = {
            color = Color(150, 200, 255, 255),
            vortexSpeed = 180, -- degrees per second
            rippleCount = 8,
            stabilizationTime = 2.0,
            maxRadius = 300
        },
        
        -- Stage 3: Hyperspace travel
        HyperspaceTravel = {
            starlinesColor = Color(200, 220, 255, 255),
            starlinesCount = 200,
            starlinesSpeed = 2000,
            tunnelColor = Color(180, 210, 255, 100),
            distortionIntensity = 0.4
        },
        
        -- Stage 4: Exit sequence
        ExitSequence = {
            flashColor = Color(255, 255, 255, 255),
            flashIntensity = 2.0,
            stabilizationGlow = Color(100, 150, 255, 150),
            fadeOutTime = 1.5
        }
    },
    
    -- Advanced particle systems
    ParticleEffects = {
        EnableAdvancedParticles = true,
        ParticleCount = 1500,
        EnergyStreamCount = 100,
        QuantumFluctuations = 50,
        
        -- Stargate-specific particles
        ChevronGlow = true,
        EnergyRipples = true,
        DimensionalSparks = true,
        SubspaceDistortion = true
    },
    
    -- Screen effects and post-processing
    ScreenEffects = {
        EnableColorModification = true,
        EnableMotionBlur = true,
        EnableScreenDistortion = true,
        EnableLensFlares = true,
        
        -- Effect intensities
        ColorModIntensity = 0.6,
        MotionBlurIntensity = 0.3,
        DistortionIntensity = 0.2,
        LensFlareIntensity = 0.8
    },
    
    // Audio-visual synchronization
    AudioSync = {
        EnableAudioReactiveEffects = true,
        BeatDetection = true,
        FrequencyAnalysis = true,
        SoundVisualization = true
    }
}

-- Enhanced hyperspace state tracking
local hyperspaceState = {
    active = false,
    stage = 0,
    startTime = 0,
    stageStartTime = 0,
    intensity = 0,
    
    -- Advanced state data
    quantumCoherence = 1.0,
    dimensionalStability = 1.0,
    energyHarmonics = {},
    visualEffects = {}
}

-- Stage 1: Enhanced energy buildup effect
function ASC.StargateEffects.CreateAdvancedEnergyBuildup(engine)
    local config = ASC.StargateEffects.Config.StargateVisuals.InitiationGlow
    local pos = engine:GetPos()
    
    -- Primary energy glow
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetScale(config.intensity * 200)
    effectData:SetMagnitude(config.duration)
    effectData:SetRadius(config.expansionRate)
    util.Effect("asc_stargate_energy_buildup", effectData)
    
    -- Pulsing energy rings
    for i = 1, 5 do
        timer.Simple(i * 0.5, function()
            if IsValid(engine) then
                local ringEffect = EffectData()
                ringEffect:SetOrigin(pos)
                ringEffect:SetScale(i * 50)
                ringEffect:SetMagnitude(1.0)
                util.Effect("asc_energy_ring", ringEffect)
            end
        end)
    end
    
    -- Quantum fluctuation particles
    ASC.StargateEffects.CreateQuantumFluctuations(pos, config.duration)
    
    print("[Stargate Effects] Advanced energy buildup initiated")
end

-- Stage 2: Enhanced hyperspace window opening
function ASC.StargateEffects.CreateAdvancedHyperspaceWindow(engine, destination)
    local config = ASC.StargateEffects.Config.StargateVisuals.WindowOpening
    local pos = engine:GetPos()
    
    -- Create swirling vortex effect
    local vortexData = EffectData()
    vortexData:SetOrigin(pos)
    vortexData:SetStart(destination)
    vortexData:SetScale(config.maxRadius)
    vortexData:SetMagnitude(config.vortexSpeed)
    vortexData:SetRadius(config.rippleCount)
    util.Effect("asc_stargate_vortex", vortexData)
    
    -- Energy ripples expanding outward
    for i = 1, config.rippleCount do
        timer.Simple(i * 0.2, function()
            if IsValid(engine) then
                ASC.StargateEffects.CreateEnergyRipple(pos, i * 30, config.color)
            end
        end)
    end
    
    -- Dimensional gateway stabilization
    timer.Simple(config.stabilizationTime * 0.5, function()
        if IsValid(engine) then
            ASC.StargateEffects.StabilizeHyperspaceWindow(pos, config.maxRadius)
        end
    end)
    
    print("[Stargate Effects] Advanced hyperspace window opening")
end

-- Stage 3: Enhanced hyperspace travel effects
function ASC.StargateEffects.CreateAdvancedHyperspaceTravel(engine, destination)
    local config = ASC.StargateEffects.Config.StargateVisuals.HyperspaceTravel
    local pos = engine:GetPos()
    
    -- Stretched starlines effect (Stargate signature)
    ASC.StargateEffects.CreateStargateStarlines(pos, destination, config)
    
    -- Dimensional tunnel visualization
    ASC.StargateEffects.CreateDimensionalTunnel(pos, destination, config)
    
    -- Quantum energy streams
    ASC.StargateEffects.CreateQuantumEnergyStreams(pos, destination, config)
    
    -- Apply hyperspace screen effects
    ASC.StargateEffects.ApplyHyperspaceScreenEffects()
    
    print("[Stargate Effects] Advanced hyperspace travel effects active")
end

-- Create Stargate-style stretched starlines
function ASC.StargateEffects.CreateStargateStarlines(origin, destination, config)
    local direction = (destination - origin):GetNormalized()
    
    -- Create multiple starline layers for depth
    for layer = 1, 3 do
        for i = 1, config.starlinesCount / 3 do
            local offset = Vector(
                math.random(-500, 500),
                math.random(-500, 500),
                math.random(-200, 200)
            ) * layer
            
            local startPos = origin + offset
            local endPos = startPos + direction * config.starlinesSpeed * layer
            
            -- Create starline effect
            local starlineData = EffectData()
            starlineData:SetOrigin(startPos)
            starlineData:SetStart(endPos)
            starlineData:SetScale(layer * 2)
            starlineData:SetMagnitude(config.starlinesSpeed)
            util.Effect("asc_stargate_starline", starlineData)
        end
    end
end

-- Create dimensional tunnel effect
function ASC.StargateEffects.CreateDimensionalTunnel(origin, destination, config)
    local tunnelLength = origin:Distance(destination)
    local segments = math.ceil(tunnelLength / 100)
    
    for i = 1, segments do
        local progress = i / segments
        local segmentPos = LerpVector(progress, origin, destination)
        
        -- Create tunnel segment
        local tunnelData = EffectData()
        tunnelData:SetOrigin(segmentPos)
        tunnelData:SetScale(200 * (1 - progress * 0.3)) -- Tapering tunnel
        tunnelData:SetMagnitude(progress)
        tunnelData:SetRadius(config.distortionIntensity * 100)
        util.Effect("asc_dimensional_tunnel_segment", tunnelData)
    end
end

-- Apply hyperspace screen effects
function ASC.StargateEffects.ApplyHyperspaceScreenEffects()
    local config = ASC.StargateEffects.Config.ScreenEffects
    if not config.EnableColorModification then return end
    
    -- Stargate-themed color modification
    local colorMod = {
        ["$pp_colour_addr"] = 0.05,
        ["$pp_colour_addg"] = 0.1,
        ["$pp_colour_addb"] = 0.25 * config.ColorModIntensity,
        ["$pp_colour_brightness"] = 0.1,
        ["$pp_colour_contrast"] = 1.2,
        ["$pp_colour_colour"] = 0.8,
        ["$pp_colour_mulr"] = 0.8,
        ["$pp_colour_mulg"] = 0.9,
        ["$pp_colour_mulb"] = 1.3
    }
    
    DrawColorModify(colorMod)
    
    -- Motion blur for speed effect
    if config.EnableMotionBlur then
        DrawMotionBlur(config.MotionBlurIntensity, 0.8, 0.01)
    end
end

-- Stage 4: Enhanced exit sequence
function ASC.StargateEffects.CreateAdvancedExitSequence(engine)
    local config = ASC.StargateEffects.Config.StargateVisuals.ExitSequence
    local pos = engine:GetPos()
    
    -- Bright exit flash
    local flashData = EffectData()
    flashData:SetOrigin(pos)
    flashData:SetScale(config.flashIntensity * 300)
    flashData:SetMagnitude(0.5)
    flashData:SetRadius(200)
    util.Effect("asc_stargate_exit_flash", flashData)
    
    -- System stabilization glow
    timer.Simple(0.5, function()
        if IsValid(engine) then
            local stabilizeData = EffectData()
            stabilizeData:SetOrigin(pos)
            stabilizeData:SetScale(150)
            stabilizeData:SetMagnitude(config.fadeOutTime)
            util.Effect("asc_system_stabilization", stabilizeData)
        end
    end)
    
    -- Gradual effect fade-out
    ASC.StargateEffects.FadeOutEffects(config.fadeOutTime)
    
    print("[Stargate Effects] Advanced exit sequence completed")
end

-- Create quantum fluctuation particles
function ASC.StargateEffects.CreateQuantumFluctuations(pos, duration)
    local config = ASC.StargateEffects.Config.ParticleEffects
    if not config.EnableAdvancedParticles then return end
    
    for i = 1, config.QuantumFluctuations do
        timer.Simple(math.random() * duration, function()
            local fluctuationPos = pos + Vector(
                math.random(-200, 200),
                math.random(-200, 200),
                math.random(-100, 100)
            )
            
            local fluctuationData = EffectData()
            fluctuationData:SetOrigin(fluctuationPos)
            fluctuationData:SetScale(math.random(5, 15))
            fluctuationData:SetMagnitude(math.random(1, 3))
            util.Effect("asc_quantum_fluctuation", fluctuationData)
        end)
    end
end

-- Enhanced hyperspace state management
function ASC.StargateEffects.StartEnhancedHyperspaceSequence(engine, destination)
    hyperspaceState.active = true
    hyperspaceState.stage = 1
    hyperspaceState.startTime = CurTime()
    hyperspaceState.stageStartTime = CurTime()
    
    -- Stage progression with enhanced effects
    ASC.StargateEffects.CreateAdvancedEnergyBuildup(engine)
    
    timer.Simple(3, function()
        if hyperspaceState.active then
            hyperspaceState.stage = 2
            hyperspaceState.stageStartTime = CurTime()
            ASC.StargateEffects.CreateAdvancedHyperspaceWindow(engine, destination)
        end
    end)
    
    timer.Simple(5, function()
        if hyperspaceState.active then
            hyperspaceState.stage = 3
            hyperspaceState.stageStartTime = CurTime()
            ASC.StargateEffects.CreateAdvancedHyperspaceTravel(engine, destination)
        end
    end)
    
    timer.Simple(10, function()
        if hyperspaceState.active then
            hyperspaceState.stage = 4
            hyperspaceState.stageStartTime = CurTime()
            ASC.StargateEffects.CreateAdvancedExitSequence(engine)
        end
    end)
    
    timer.Simple(11.5, function()
        ASC.StargateEffects.EndHyperspaceSequence()
    end)
end

-- End hyperspace sequence
function ASC.StargateEffects.EndHyperspaceSequence()
    hyperspaceState.active = false
    hyperspaceState.stage = 0
    hyperspaceState.intensity = 0
    
    print("[Stargate Effects] Enhanced hyperspace sequence completed")
end

-- Screen effect rendering hook
hook.Add("RenderScreenspaceEffects", "ASC_EnhancedStargateEffects", function()
    if not hyperspaceState.active then return end
    
    local stage = hyperspaceState.stage
    if stage == 3 then -- Only during hyperspace travel
        ASC.StargateEffects.ApplyHyperspaceScreenEffects()
    end
end)

print("[Advanced Space Combat] Enhanced Stargate Effects v3.0 Loaded Successfully!")
