-- Ship Core Glow Effect
-- Enhanced visual effect for ship core entity

function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    self.Position = data:GetOrigin()
    self.Scale = data:GetScale() or 1
    self.Magnitude = data:GetMagnitude() or 1
    
    self.StartTime = CurTime()
    self.LifeTime = 2.0
    
    -- Core glow properties
    self.GlowSize = 32 * self.Scale
    self.PulseSpeed = 2.0
    self.BaseAlpha = 150
    
    -- Particle system
    self.Emitter = ParticleEmitter(self.Position, false)
    
    -- Create initial glow particles
    self:CreateGlowParticles()
    
    -- Create energy wisps
    self:CreateEnergyWisps()
end

function EFFECT:CreateGlowParticles()
    if not self.Emitter then return end
    
    for i = 1, 8 do
        local particle = self.Emitter:Add("hyperdrive/ship_core_glow", self.Position)
        if particle then
            particle:SetVelocity(VectorRand() * 10)
            particle:SetLifeTime(0)
            particle:SetDieTime(self.LifeTime)
            particle:SetStartAlpha(self.BaseAlpha)
            particle:SetEndAlpha(0)
            particle:SetStartSize(self.GlowSize * 0.5)
            particle:SetEndSize(self.GlowSize * 1.5)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))
            particle:SetColor(100, 150, 255)
            particle:SetAirResistance(50)
            particle:SetGravity(Vector(0, 0, -10))
            particle:SetCollide(false)
            particle:SetBounce(0)
        end
    end
end

function EFFECT:CreateEnergyWisps()
    if not self.Emitter then return end
    
    for i = 1, 12 do
        local angle = (i / 12) * 360
        local radius = math.Rand(20, 40) * self.Scale
        local pos = self.Position + Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            math.Rand(-10, 10)
        )
        
        local particle = self.Emitter:Add("effects/spark", pos)
        if particle then
            local vel = (self.Position - pos):GetNormalized() * math.Rand(30, 60)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1.0, 2.0))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(2)
            particle:SetEndSize(0)
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetCollide(false)
        end
    end
end

function EFFECT:Think()
    local age = CurTime() - self.StartTime
    
    if age >= self.LifeTime then
        if self.Emitter then
            self.Emitter:Finish()
        end
        return false
    end
    
    -- Create continuous energy particles
    if self.Emitter and math.random() < 0.3 then
        local particle = self.Emitter:Add("effects/spark", self.Position + VectorRand() * 20)
        if particle then
            particle:SetVelocity(VectorRand() * 50)
            particle:SetLifeTime(0)
            particle:SetDieTime(0.5)
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(1)
            particle:SetEndSize(0)
            particle:SetColor(100, 180, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    return true
end

function EFFECT:Render()
    local age = CurTime() - self.StartTime
    local alpha = math.max(0, 1 - (age / self.LifeTime))
    
    -- Pulsing glow effect
    local pulse = math.sin(CurTime() * self.PulseSpeed) * 0.3 + 0.7
    local glowAlpha = alpha * pulse * self.BaseAlpha
    
    -- Main core glow
    render.SetMaterial(Material("hyperdrive/ship_core_glow"))
    render.DrawSprite(self.Position, self.GlowSize * pulse, self.GlowSize * pulse, Color(100, 150, 255, glowAlpha))
    
    -- Outer glow ring
    render.DrawSprite(self.Position, self.GlowSize * 1.5 * pulse, self.GlowSize * 1.5 * pulse, Color(50, 100, 200, glowAlpha * 0.5))
    
    -- Energy field effect
    local fieldSize = self.GlowSize * 2 * pulse
    render.DrawSprite(self.Position, fieldSize, fieldSize, Color(30, 80, 150, glowAlpha * 0.3))
end
