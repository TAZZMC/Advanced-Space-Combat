-- Advanced Space Combat - Ancient Drone Projectile Client
-- Client-side rendering and effects for Ancient drone projectiles

include("shared.lua")

-- Client-side variables
ENT.TrailEffect = nil
ENT.EngineGlow = 0
ENT.LockOnEffect = 0
ENT.LastEffectTime = 0
ENT.SoundLoop = nil

-- Initialize client-side systems
function ENT:Initialize()
    self:SetRenderBounds(Vector(-20, -20, -20), Vector(20, 20, 20))
    
    -- Create trail effect
    self.TrailEffect = util.SpriteTrail(self, 0, Color(100, 150, 255, 150), false, 8, 1, 0.5, 1/9*0.5, "trails/laser")
    
    -- Start engine sound
    self.SoundLoop = CreateSound(self, "asc/ancient/drone_engine.wav")
    if self.SoundLoop then
        self.SoundLoop:Play()
    end
    
    self.LastEffectTime = CurTime()
end

-- Main drawing function
function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000000 then return end -- 1000 unit distance
    
    self:DrawEngineEffects()
    self:DrawTargetingEffects()
    self:DrawEnergyField()
end

-- Draw engine glow and particles
function ENT:DrawEngineEffects()
    local thrustLevel = self:GetThrustLevel()
    local effectColor = self:GetEffectColor()
    
    -- Update engine glow
    self.EngineGlow = Lerp(FrameTime() * 8, self.EngineGlow, thrustLevel)
    
    if self.EngineGlow > 0.1 then
        -- Engine position (rear of drone)
        local enginePos = self:GetPos() - self:GetForward() * 15
        
        -- Engine glow light
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = enginePos
            dlight.r = effectColor.r
            dlight.g = effectColor.g
            dlight.b = effectColor.b
            dlight.brightness = self.EngineGlow * 1.5
            dlight.decay = 1000
            dlight.size = 60
            dlight.dietime = CurTime() + 0.1
        end
        
        -- Engine sprite
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(enginePos, 20 * self.EngineGlow, 20 * self.EngineGlow, 
            Color(effectColor.r, effectColor.g, effectColor.b, 255 * self.EngineGlow))
        
        -- Engine particles
        if self.EngineGlow > 0.3 and CurTime() > self.LastEffectTime + 0.05 then
            self.LastEffectTime = CurTime()
            
            local emitter = ParticleEmitter(enginePos)
            if emitter then
                local particle = emitter:Add("effects/energyball", enginePos + VectorRand() * 5)
                if particle then
                    particle:SetVelocity(-self:GetForward() * 150 + VectorRand() * 30)
                    particle:SetLifeTime(0)
                    particle:SetDieTime(0.3)
                    particle:SetStartAlpha(255 * self.EngineGlow)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(3)
                    particle:SetEndSize(1)
                    particle:SetColor(effectColor.r, effectColor.g, effectColor.b)
                    particle:SetGravity(Vector(0, 0, 0))
                end
                emitter:Finish()
            end
        end
    end
end

-- Draw targeting and lock-on effects
function ENT:DrawTargetingEffects()
    local target = self:GetTarget()
    local lockProgress = self:GetLockOnProgress()
    local isTracking = self:GetIsTracking()
    
    if IsValid(target) and isTracking then
        -- Update lock-on effect
        self.LockOnEffect = Lerp(FrameTime() * 5, self.LockOnEffect, lockProgress)
        
        if self.LockOnEffect > 0.1 then
            local targetPos = target:GetPos()
            local dronePos = self:GetPos()
            
            -- Draw targeting beam
            render.SetMaterial(Material("cable/rope"))
            render.DrawBeam(dronePos, targetPos, 2 * self.LockOnEffect, 0, 1, 
                Color(255, 100, 100, 100 * self.LockOnEffect))
            
            -- Draw lock-on indicator at target
            local lockColor = Color(255, 255 * (1 - lockProgress), 0, 200 * self.LockOnEffect)
            
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(targetPos, 30 * self.LockOnEffect, 30 * self.LockOnEffect, lockColor)
            
            -- Draw targeting reticle
            local time = CurTime()
            local reticleSize = 40 + math.sin(time * 10) * 10
            
            cam.Start3D2D(targetPos, (dronePos - targetPos):GetNormalized():Angle(), 0.5)
                surface.SetDrawColor(lockColor.r, lockColor.g, lockColor.b, lockColor.a)
                
                -- Outer circle
                surface.DrawOutlinedRect(-reticleSize/2, -reticleSize/2, reticleSize, reticleSize, 2)
                
                -- Cross hairs
                surface.DrawRect(-2, -reticleSize/2, 4, reticleSize)
                surface.DrawRect(-reticleSize/2, -2, reticleSize, 4)
                
                -- Lock progress arc
                if lockProgress > 0 then
                    local arcSegments = math.floor(lockProgress * 32)
                    for i = 1, arcSegments do
                        local angle = (i / 32) * math.pi * 2
                        local x = math.cos(angle) * reticleSize * 0.6
                        local y = math.sin(angle) * reticleSize * 0.6
                        surface.DrawRect(x - 1, y - 1, 2, 2)
                    end
                end
            cam.End3D2D()
        end
    else
        self.LockOnEffect = Lerp(FrameTime() * 8, self.LockOnEffect, 0)
    end
end

-- Draw energy field around drone
function ENT:DrawEnergyField()
    local state = self:GetDroneState()
    local effectColor = self:GetEffectColor()
    local time = CurTime()
    
    -- Energy field intensity based on state
    local fieldIntensity = 0.3
    if state == self.STATE_TRACKING then
        fieldIntensity = 0.5 + math.sin(time * 8) * 0.2
    elseif state == self.STATE_INTERCEPTING then
        fieldIntensity = 0.7 + math.sin(time * 12) * 0.3
    end
    
    -- Draw energy field
    local fieldPos = self:GetPos()
    
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(fieldPos, 25 * fieldIntensity, 25 * fieldIntensity, 
        Color(effectColor.r, effectColor.g, effectColor.b, 100 * fieldIntensity))
    
    -- Draw energy wisps
    if fieldIntensity > 0.4 then
        for i = 1, 3 do
            local wispAngle = time * 2 + i * (math.pi * 2 / 3)
            local wispRadius = 20 + math.sin(time * 4 + i) * 5
            local wispPos = fieldPos + Vector(
                math.cos(wispAngle) * wispRadius,
                math.sin(wispAngle) * wispRadius,
                math.sin(time * 3 + i) * 10
            )
            
            render.DrawSprite(wispPos, 8 * fieldIntensity, 8 * fieldIntensity, 
                Color(effectColor.r, effectColor.g, effectColor.b, 150 * fieldIntensity))
        end
    end
end

-- Update trail effect color
function ENT:Think()
    local effectColor = self:GetEffectColor()
    local thrustLevel = self:GetThrustLevel()
    
    -- Update trail color and intensity
    if self.TrailEffect then
        local trailColor = Color(effectColor.r, effectColor.g, effectColor.b, 150 * thrustLevel)
        -- Trail color would be updated here if the trail system supported it
    end
    
    -- Update engine sound
    if self.SoundLoop then
        local pitch = 80 + thrustLevel * 40
        local volume = 0.3 + thrustLevel * 0.4
        self.SoundLoop:ChangePitch(pitch, 0.1)
        self.SoundLoop:ChangeVolume(volume, 0.1)
    end
    
    self:SetNextClientThink(CurTime() + 0.1)
    return true
end

-- Handle removal
function ENT:OnRemove()
    -- Stop engine sound
    if self.SoundLoop then
        self.SoundLoop:Stop()
        self.SoundLoop = nil
    end
    
    -- Remove trail effect
    if self.TrailEffect then
        SafeRemoveEntity(self.TrailEffect)
        self.TrailEffect = nil
    end
    
    -- Cleanup dynamic light
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.dietime = CurTime()
    end
    
    -- Create explosion effect
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(self.BlastRadius)
    effectdata:SetScale(1)
    util.Effect("asc_ancient_explosion", effectdata)
end

-- Create impact effect
function ENT:CreateImpactEffect(pos, normal)
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    effectdata:SetNormal(normal)
    effectdata:SetMagnitude(self.Damage)
    effectdata:SetScale(1)
    util.Effect("asc_ancient_impact", effectdata)
    
    -- Impact sound
    sound.Play("asc/ancient/drone_impact.wav", pos, 75, 100, 1)
end
