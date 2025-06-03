-- Advanced Space Combat - Stargate Hyperspace Window Effect
-- Creates the iconic blue/purple swirling energy window for hyperspace entry/exit

EFFECT.Mat = Material("effects/blueflare1")
EFFECT.MatRing = Material("effects/select_ring")
EFFECT.MatBeam = Material("effects/laser1")

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self.Scale = data:GetScale() or 100
    self.Magnitude = data:GetMagnitude() or 1
    self.Radius = data:GetRadius() or 200
    
    self.StartTime = CurTime()
    self.LifeTime = 3.0
    self.Intensity = 1.0
    
    -- Stargate-style window properties
    self.WindowStability = 0.0
    self.RippleIntensity = 1.0
    self.EnergyFlow = 0.0
    
    -- Create swirling particles
    self:CreateSwirlParticles()
    
    -- Create energy ripples
    self:CreateEnergyRipples()
    
    -- Sound effect
    self:EmitSound("asc/hyperspace/window_forming.wav", 75, 100)
end

function EFFECT:CreateSwirlParticles()
    local emitter = ParticleEmitter(self.Position, false)
    if not emitter then return end
    
    -- Blue/purple swirling energy particles
    for i = 1, 20 do
        local particle = emitter:Add("effects/blueflare1", self.Position)
        if particle then
            local angle = (i / 20) * math.pi * 2
            local radius = math.random(50, self.Radius)
            local offset = Vector(
                math.cos(angle) * radius,
                math.sin(angle) * radius,
                math.random(-20, 20)
            )
            
            particle:SetPos(self.Position + offset)
            particle:SetVelocity(Vector(
                -math.sin(angle) * 100,
                math.cos(angle) * 100,
                math.random(-10, 10)
            ))
            particle:SetDieTime(self.LifeTime)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.random(10, 30))
            particle:SetEndSize(0)
            particle:SetRoll(math.random(0, 360))
            particle:SetRollDelta(math.random(-5, 5))
            
            -- Stargate blue/purple colors
            local color = HSVToColor((220 + math.random(-20, 20)) % 360, 0.8, 1.0)
            particle:SetColor(color.r, color.g, color.b)
        end
    end
    
    emitter:Finish()
end

function EFFECT:CreateEnergyRipples()
    local emitter = ParticleEmitter(self.Position, false)
    if not emitter then return end
    
    -- Energy ripples expanding outward
    for i = 1, 5 do
        timer.Simple(i * 0.2, function()
            if IsValid(self) then
                local particle = emitter:Add("effects/select_ring", self.Position)
                if particle then
                    particle:SetPos(self.Position)
                    particle:SetVelocity(Vector(0, 0, 0))
                    particle:SetDieTime(1.5)
                    particle:SetStartAlpha(200)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(10)
                    particle:SetEndSize(self.Radius * 2)
                    particle:SetColor(100, 150, 255)
                end
            end
        end)
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    local age = CurTime() - self.StartTime
    local progress = age / self.LifeTime
    
    if progress >= 1 then
        return false
    end
    
    -- Update window properties
    self.WindowStability = math.min(1.0, progress * 2)
    self.RippleIntensity = 1.0 - (progress * 0.5)
    self.EnergyFlow = math.sin(age * 5) * 0.5 + 0.5
    
    return true
end

function EFFECT:Render()
    local age = CurTime() - self.StartTime
    local progress = age / self.LifeTime
    
    if progress >= 1 then return end
    
    -- Main window glow
    local alpha = (1 - progress) * 255 * self.Intensity
    local size = self.Scale * (0.5 + self.WindowStability * 0.5)
    
    render.SetMaterial(self.Mat)
    render.DrawSprite(self.Position, size, size, Color(100, 150, 255, alpha))
    
    -- Energy ring
    local ringAlpha = alpha * 0.7
    local ringSize = size * 1.2
    render.SetMaterial(self.MatRing)
    render.DrawSprite(self.Position, ringSize, ringSize, Color(150, 200, 255, ringAlpha))
    
    -- Swirling energy beams
    for i = 1, 8 do
        local beamAngle = (age * 2 + i * 45) % 360
        local beamRad = math.rad(beamAngle)
        local beamStart = self.Position
        local beamEnd = self.Position + Vector(
            math.cos(beamRad) * self.Radius,
            math.sin(beamRad) * self.Radius,
            0
        )
        
        render.SetMaterial(self.MatBeam)
        render.DrawBeam(beamStart, beamEnd, 5, 0, 1, Color(120, 180, 255, alpha * 0.5))
    end
    
    -- Center energy core
    local coreSize = size * 0.3 * (0.8 + self.EnergyFlow * 0.4)
    render.DrawSprite(self.Position, coreSize, coreSize, Color(200, 220, 255, alpha))
end
