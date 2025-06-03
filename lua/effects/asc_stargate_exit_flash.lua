-- Advanced Space Combat - Stargate Hyperspace Exit Flash Effect
-- Creates the intense light flash when exiting hyperspace

EFFECT.Mat = Material("effects/yellowflare")
EFFECT.MatRing = Material("effects/select_ring")
EFFECT.MatBeam = Material("effects/blueflare1")

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self.Scale = data:GetScale() or 200
    self.Magnitude = data:GetMagnitude() or 5
    self.Radius = data:GetRadius() or 300
    
    self.StartTime = CurTime()
    self.LifeTime = 2.0
    self.FlashIntensity = 1.0
    
    -- Create initial flash
    self:CreateFlashParticles()
    
    -- Create shockwave rings
    self:CreateShockwaveRings()
    
    -- Sound effect
    self:EmitSound("asc/hyperspace/exit_flash.wav", 100, 95)
end

function EFFECT:CreateFlashParticles()
    local emitter = ParticleEmitter(self.Position, false)
    if not emitter then return end
    
    -- Intense flash particles
    for i = 1, 30 do
        local particle = emitter:Add("effects/yellowflare", self.Position)
        if particle then
            local velocity = VectorRand() * math.random(100, 300)
            
            particle:SetPos(self.Position)
            particle:SetVelocity(velocity)
            particle:SetDieTime(1.5)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.random(20, 50))
            particle:SetEndSize(0)
            particle:SetRoll(math.random(0, 360))
            particle:SetRollDelta(math.random(-10, 10))
            
            -- Bright white/blue flash colors
            particle:SetColor(255, 255, 255)
        end
    end
    
    -- Energy sparks
    for i = 1, 20 do
        local particle = emitter:Add("effects/blueflare1", self.Position)
        if particle then
            local velocity = VectorRand() * math.random(200, 500)
            
            particle:SetPos(self.Position + VectorRand() * 50)
            particle:SetVelocity(velocity)
            particle:SetDieTime(1.0)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.random(5, 15))
            particle:SetEndSize(0)
            
            particle:SetColor(150, 200, 255)
        end
    end
    
    emitter:Finish()
end

function EFFECT:CreateShockwaveRings()
    -- Create expanding shockwave rings
    for i = 1, 3 do
        timer.Simple(i * 0.1, function()
            if IsValid(self) then
                local emitter = ParticleEmitter(self.Position, false)
                if emitter then
                    local particle = emitter:Add("effects/select_ring", self.Position)
                    if particle then
                        particle:SetPos(self.Position)
                        particle:SetVelocity(Vector(0, 0, 0))
                        particle:SetDieTime(1.5)
                        particle:SetStartAlpha(200)
                        particle:SetEndAlpha(0)
                        particle:SetStartSize(50)
                        particle:SetEndSize(self.Radius * 3)
                        particle:SetColor(255, 255, 255)
                    end
                    emitter:Finish()
                end
            end
        end)
    end
end

function EFFECT:Think()
    local age = CurTime() - self.StartTime
    local progress = age / self.LifeTime
    
    if progress >= 1 then
        return false
    end
    
    -- Flash intensity decreases over time
    self.FlashIntensity = math.max(0, 1 - progress)
    
    return true
end

function EFFECT:Render()
    local age = CurTime() - self.StartTime
    local progress = age / self.LifeTime
    
    if progress >= 1 then return end
    
    -- Main flash effect
    local flashAlpha = self.FlashIntensity * 255
    local flashSize = self.Scale * (1 + progress * 2)
    
    render.SetMaterial(self.Mat)
    
    -- Central bright flash
    render.DrawSprite(
        self.Position,
        flashSize, flashSize,
        Color(255, 255, 255, flashAlpha)
    )
    
    -- Secondary glow
    render.DrawSprite(
        self.Position,
        flashSize * 1.5, flashSize * 1.5,
        Color(200, 220, 255, flashAlpha * 0.5)
    )
    
    -- Outer glow
    render.DrawSprite(
        self.Position,
        flashSize * 2, flashSize * 2,
        Color(150, 180, 255, flashAlpha * 0.3)
    )
    
    -- Energy beams radiating outward
    render.SetMaterial(self.MatBeam)
    
    for i = 1, 12 do
        local beamAngle = (i * 30) % 360
        local beamRad = math.rad(beamAngle)
        local beamLength = self.Radius * (1 + progress)
        
        local beamStart = self.Position
        local beamEnd = self.Position + Vector(
            math.cos(beamRad) * beamLength,
            math.sin(beamRad) * beamLength,
            0
        )
        
        render.DrawBeam(
            beamStart,
            beamEnd,
            10,
            0, 1,
            Color(255, 255, 255, flashAlpha * 0.7)
        )
    end
    
    -- Expanding energy rings
    render.SetMaterial(self.MatRing)
    
    for i = 1, 3 do
        local ringProgress = math.max(0, progress - (i * 0.1))
        local ringSize = self.Radius * ringProgress * 2
        local ringAlpha = flashAlpha * (1 - ringProgress) * 0.6
        
        if ringProgress > 0 then
            render.DrawSprite(
                self.Position,
                ringSize, ringSize,
                Color(200, 220, 255, ringAlpha)
            )
        end
    end
end
