-- Ship Core Activation Effect
-- Dramatic activation sequence for ship core

function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    self.Position = data:GetOrigin()
    self.Scale = data:GetScale() or 1
    self.Magnitude = data:GetMagnitude() or 1
    
    self.StartTime = CurTime()
    self.LifeTime = 3.0
    
    -- Activation properties
    self.MaxRadius = 100 * self.Scale
    self.RingCount = 5
    self.PulseSpeed = 3.0
    
    -- Particle system
    self.Emitter = ParticleEmitter(self.Position, false)
    
    -- Create activation burst
    self:CreateActivationBurst()
    
    -- Create energy rings
    self:CreateEnergyRings()
    
    -- Create holographic display
    self:CreateHolographicDisplay()
    
    -- Sound effect
    if IsValid(self.Entity) and HYPERDRIVE.Sounds then
        HYPERDRIVE.Sounds.PlayEffect("power_up", self.Entity, {
            volume = 0.8,
            pitch = 100,
            soundLevel = 80
        })
    end
end

function EFFECT:CreateActivationBurst()
    if not self.Emitter then return end
    
    -- Central energy burst
    for i = 1, 20 do
        local particle = self.Emitter:Add("hyperdrive/ship_core_glow", self.Position)
        if particle then
            local vel = VectorRand() * math.Rand(50, 150)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1.5, 2.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(8, 16))
            particle:SetEndSize(math.Rand(20, 40))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-5, 5))
            particle:SetColor(100, 200, 255)
            particle:SetAirResistance(100)
            particle:SetGravity(Vector(0, 0, -20))
            particle:SetCollide(false)
        end
    end
    
    -- Sparks and energy bolts
    for i = 1, 30 do
        local particle = self.Emitter:Add("effects/spark", self.Position + VectorRand() * 10)
        if particle then
            local vel = VectorRand() * math.Rand(100, 300)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.5, 1.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(2, 4))
            particle:SetEndSize(0)
            particle:SetColor(150, 220, 255)
            particle:SetGravity(Vector(0, 0, -50))
            particle:SetCollide(true)
            particle:SetBounce(0.3)
        end
    end
end

function EFFECT:CreateEnergyRings()
    if not self.Emitter then return end
    
    for ring = 1, self.RingCount do
        local ringRadius = (ring / self.RingCount) * self.MaxRadius
        local particleCount = math.floor(ringRadius / 5)
        
        for i = 1, particleCount do
            local angle = (i / particleCount) * 360
            local pos = self.Position + Vector(
                math.cos(math.rad(angle)) * ringRadius,
                math.sin(math.rad(angle)) * ringRadius,
                math.Rand(-5, 5)
            )
            
            local particle = self.Emitter:Add("hyperdrive/ship_core_glow", pos)
            if particle then
                particle:SetVelocity(Vector(0, 0, math.Rand(10, 30)))
                particle:SetLifeTime(0)
                particle:SetDieTime(self.LifeTime * 0.8)
                particle:SetStartAlpha(200)
                particle:SetEndAlpha(0)
                particle:SetStartSize(4)
                particle:SetEndSize(12)
                particle:SetColor(80, 160, 255)
                particle:SetGravity(Vector(0, 0, 0))
                particle:SetCollide(false)
            end
        end
    end
end

function EFFECT:CreateHolographicDisplay()
    if not self.Emitter then return end
    
    -- Holographic data streams
    for i = 1, 15 do
        local height = math.Rand(20, 60)
        local pos = self.Position + Vector(
            math.Rand(-30, 30),
            math.Rand(-30, 30),
            height
        )
        
        local particle = self.Emitter:Add("hyperdrive/ship_core_hologram", pos)
        if particle then
            particle:SetVelocity(Vector(0, 0, math.Rand(5, 15)))
            particle:SetLifeTime(0)
            particle:SetDieTime(self.LifeTime)
            particle:SetStartAlpha(150)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(6, 12))
            particle:SetEndSize(math.Rand(2, 6))
            particle:SetColor(100, 255, 200)
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
    
    -- Create continuous energy effects
    if self.Emitter and math.random() < 0.2 then
        local particle = self.Emitter:Add("effects/spark", self.Position + VectorRand() * 30)
        if particle then
            particle:SetVelocity(VectorRand() * 80)
            particle:SetLifeTime(0)
            particle:SetDieTime(0.8)
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(2)
            particle:SetEndSize(0)
            particle:SetColor(120, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    return true
end

function EFFECT:Render()
    local age = CurTime() - self.StartTime
    local alpha = math.max(0, 1 - (age / self.LifeTime))
    
    -- Expanding energy wave
    local waveRadius = (age / self.LifeTime) * self.MaxRadius
    local waveAlpha = alpha * 100
    
    render.SetMaterial(Material("hyperdrive/ship_core_glow"))
    render.DrawSprite(self.Position, waveRadius * 2, waveRadius * 2, Color(50, 150, 255, waveAlpha * 0.3))
    
    -- Central core glow
    local pulse = math.sin(CurTime() * self.PulseSpeed) * 0.4 + 0.6
    local coreSize = 40 * pulse * self.Scale
    render.DrawSprite(self.Position, coreSize, coreSize, Color(100, 200, 255, alpha * 200))
    
    -- Energy field
    local fieldSize = 80 * pulse * self.Scale
    render.DrawSprite(self.Position, fieldSize, fieldSize, Color(80, 180, 255, alpha * 100))
end
