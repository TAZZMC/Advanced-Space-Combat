-- Advanced Hyperdrive Effects System
if SERVER then return end

HYPERDRIVE.Effects = HYPERDRIVE.Effects or {}

-- Effect presets
HYPERDRIVE.Effects.Presets = {
    engine_idle = {
        particles = 5,
        lifetime = 2,
        size = {2, 6},
        velocity = 50,
        color = Color(100, 150, 255),
        material = "effects/energyball"
    },
    
    engine_charging = {
        particles = 20,
        lifetime = 1,
        size = {1, 4},
        velocity = 100,
        color = Color(255, 255, 100),
        material = "effects/spark"
    },
    
    jump_portal = {
        particles = 100,
        lifetime = 3,
        size = {5, 20},
        velocity = 200,
        color = Color(0, 200, 255),
        material = "effects/energyball"
    },
    
    energy_stream = {
        particles = 30,
        lifetime = 1.5,
        size = {3, 8},
        velocity = 150,
        color = Color(150, 200, 255),
        material = "effects/laser1"
    }
}

-- Create particle emitter
function HYPERDRIVE.Effects.CreateEmitter(position, maxParticles)
    local emitter = ParticleEmitter(position, false)
    if emitter then
        emitter:SetNearClip(24, 32)
        emitter:SetFarClip(1000, 1200)
    end
    return emitter
end

-- Create particle with preset
function HYPERDRIVE.Effects.CreateParticle(emitter, preset, position, customVelocity)
    if not emitter or not preset then return end
    
    local particle = emitter:Add(preset.material, position)
    if not particle then return end
    
    -- Set basic properties
    particle:SetLifeTime(0)
    particle:SetDieTime(preset.lifetime * math.Rand(0.8, 1.2))
    particle:SetStartAlpha(255)
    particle:SetEndAlpha(0)
    
    -- Size
    local startSize = math.Rand(preset.size[1], preset.size[2])
    particle:SetStartSize(startSize)
    particle:SetEndSize(startSize * 0.1)
    
    -- Color
    particle:SetColor(preset.color.r, preset.color.g, preset.color.b)
    
    -- Velocity
    local velocity = customVelocity or VectorRand() * preset.velocity
    particle:SetVelocity(velocity)
    
    -- Physics
    particle:SetGravity(Vector(0, 0, -50))
    particle:SetAirResistance(20)
    particle:SetRoll(math.Rand(0, 360))
    particle:SetRollDelta(math.Rand(-5, 5))
    
    return particle
end

-- Engine idle effect
function HYPERDRIVE.Effects.EngineIdle(entity)
    if not IsValid(entity) then return end
    
    local pos = entity:GetPos() + entity:GetUp() * 10
    local emitter = HYPERDRIVE.Effects.CreateEmitter(pos)
    if not emitter then return end
    
    local preset = HYPERDRIVE.Effects.Presets.engine_idle
    
    for i = 1, preset.particles do
        local particlePos = pos + VectorRand() * 20
        HYPERDRIVE.Effects.CreateParticle(emitter, preset, particlePos)
    end
    
    emitter:Finish()
end

-- Engine charging effect
function HYPERDRIVE.Effects.EngineCharging(entity, intensity)
    if not IsValid(entity) then return end
    
    intensity = intensity or 1
    local pos = entity:GetPos()
    local emitter = HYPERDRIVE.Effects.CreateEmitter(pos)
    if not emitter then return end
    
    local preset = HYPERDRIVE.Effects.Presets.engine_charging
    
    -- Electric arcs
    for i = 1, preset.particles * intensity do
        local particlePos = pos + VectorRand() * 30
        local velocity = (pos - particlePos):GetNormalized() * preset.velocity
        HYPERDRIVE.Effects.CreateParticle(emitter, preset, particlePos, velocity)
    end
    
    -- Energy buildup
    local energyPreset = HYPERDRIVE.Effects.Presets.energy_stream
    for i = 1, 10 * intensity do
        local particlePos = pos + VectorRand() * 50
        local velocity = (pos - particlePos):GetNormalized() * energyPreset.velocity
        HYPERDRIVE.Effects.CreateParticle(emitter, energyPreset, particlePos, velocity)
    end
    
    emitter:Finish()
end

-- Jump portal effect
function HYPERDRIVE.Effects.JumpPortal(position, isDestination)
    local emitter = HYPERDRIVE.Effects.CreateEmitter(position)
    if not emitter then return end
    
    local preset = HYPERDRIVE.Effects.Presets.jump_portal
    
    -- Portal ring
    for i = 1, 50 do
        local angle = (i / 50) * 360
        local radius = math.Rand(50, 100)
        local dir = Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0)
        local particlePos = position + dir * radius
        
        local velocity = isDestination and (dir * -200) or (dir * 200 + Vector(0, 0, 100))
        HYPERDRIVE.Effects.CreateParticle(emitter, preset, particlePos, velocity)
    end
    
    -- Central explosion
    for i = 1, preset.particles do
        local particlePos = position + VectorRand() * 20
        HYPERDRIVE.Effects.CreateParticle(emitter, preset, particlePos)
    end
    
    -- Energy streams
    local streamPreset = HYPERDRIVE.Effects.Presets.energy_stream
    for i = 1, 40 do
        local particlePos = position + VectorRand() * 30
        local velocity = VectorRand() * streamPreset.velocity
        if isDestination then
            velocity = velocity + Vector(0, 0, -200)
        else
            velocity = velocity + Vector(0, 0, 300)
        end
        HYPERDRIVE.Effects.CreateParticle(emitter, streamPreset, particlePos, velocity)
    end
    
    emitter:Finish()
end

-- Energy beam between entities
function HYPERDRIVE.Effects.EnergyBeam(startPos, endPos, duration)
    duration = duration or 1
    
    local emitter = HYPERDRIVE.Effects.CreateEmitter(startPos)
    if not emitter then return end
    
    local distance = startPos:Distance(endPos)
    local direction = (endPos - startPos):GetNormalized()
    local segments = math.ceil(distance / 50)
    
    for i = 1, segments do
        local t = i / segments
        local pos = LerpVector(t, startPos, endPos)
        
        local particle = emitter:Add("hyperdrive/energy_beam", pos)
        if particle then
            particle:SetLifeTime(0)
            particle:SetDieTime(duration)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(1)
            particle:SetColor(0, 150, 255)
            particle:SetVelocity(Vector(0, 0, 0))
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    emitter:Finish()
end

-- Screen distortion effect
function HYPERDRIVE.Effects.ScreenDistortion(intensity, duration)
    intensity = intensity or 1
    duration = duration or 2
    
    local distortionData = {
        intensity = intensity,
        startTime = CurTime(),
        duration = duration
    }
    
    hook.Add("RenderScreenspaceEffects", "HyperdriveDistortion", function()
        local timeLeft = distortionData.startTime + distortionData.duration - CurTime()
        if timeLeft <= 0 then
            hook.Remove("RenderScreenspaceEffects", "HyperdriveDistortion")
            return
        end
        
        local alpha = timeLeft / distortionData.duration
        local distortion = distortionData.intensity * alpha
        
        -- Apply distortion effect
        local tab = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = distortion * 0.1,
            ["$pp_colour_addb"] = distortion * 0.2,
            ["$pp_colour_brightness"] = distortion * 0.1,
            ["$pp_colour_contrast"] = 1 + distortion * 0.2,
            ["$pp_colour_colour"] = 1 - distortion * 0.1,
            ["$pp_colour_mulr"] = 1,
            ["$pp_colour_mulg"] = 1,
            ["$pp_colour_mulb"] = 1 + distortion * 0.3
        }
        
        DrawColorModify(tab)
        
        -- Add motion blur
        DrawMotionBlur(distortion * 0.1, distortion * 0.8, 0.01)
    end)
end

-- Continuous effects for entities
local continuousEffects = {}

function HYPERDRIVE.Effects.StartContinuous(entity, effectName, interval)
    if not IsValid(entity) then return end
    
    local entIndex = entity:EntIndex()
    interval = interval or 0.1
    
    -- Stop existing effect
    if continuousEffects[entIndex] then
        timer.Remove("HyperdriveEffect_" .. entIndex)
    end
    
    -- Start new effect
    continuousEffects[entIndex] = effectName
    
    timer.Create("HyperdriveEffect_" .. entIndex, interval, 0, function()
        if not IsValid(entity) then
            timer.Remove("HyperdriveEffect_" .. entIndex)
            continuousEffects[entIndex] = nil
            return
        end
        
        if effectName == "idle" then
            HYPERDRIVE.Effects.EngineIdle(entity)
        elseif effectName == "charging" then
            local intensity = math.sin(CurTime() * 5) * 0.5 + 0.5
            HYPERDRIVE.Effects.EngineCharging(entity, intensity)
        end
    end)
end

function HYPERDRIVE.Effects.StopContinuous(entity)
    if not IsValid(entity) then return end
    
    local entIndex = entity:EntIndex()
    if continuousEffects[entIndex] then
        timer.Remove("HyperdriveEffect_" .. entIndex)
        continuousEffects[entIndex] = nil
    end
end

-- Hook for entity removal
hook.Add("EntityRemoved", "HyperdriveEffectsCleanup", function(ent)
    if ent:GetClass() == "hyperdrive_engine" then
        HYPERDRIVE.Effects.StopContinuous(ent)
    end
end)

-- Network effects
net.Receive("hyperdrive_effect", function()
    local effectType = net.ReadString()
    local position = net.ReadVector()
    local data = net.ReadTable()
    
    if effectType == "jump_portal" then
        HYPERDRIVE.Effects.JumpPortal(position, data.isDestination)
        HYPERDRIVE.Effects.ScreenDistortion(0.5, 1)
    elseif effectType == "energy_beam" then
        HYPERDRIVE.Effects.EnergyBeam(position, data.endPos, data.duration)
    end
end)

-- Console commands for effect testing
concommand.Add("hyperdrive_test_effect", function(ply, cmd, args)
    if #args < 1 then
        ply:ChatPrint("[Hyperdrive] Usage: hyperdrive_test_effect <effect_name>")
        return
    end
    
    local effectName = args[1]
    local pos = ply:GetPos() + ply:GetForward() * 100
    
    if effectName == "portal" then
        HYPERDRIVE.Effects.JumpPortal(pos, false)
    elseif effectName == "charging" then
        HYPERDRIVE.Effects.EngineCharging(ply, 1)
    elseif effectName == "distortion" then
        HYPERDRIVE.Effects.ScreenDistortion(1, 3)
    else
        ply:ChatPrint("[Hyperdrive] Unknown effect: " .. effectName)
    end
end)

print("[Hyperdrive] Advanced effects system loaded")
