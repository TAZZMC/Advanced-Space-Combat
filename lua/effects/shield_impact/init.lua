-- Shield Impact Effect
-- Visual effect when shields take damage

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self.Normal = data:GetNormal()
    self.Scale = data:GetScale() or 1
    self.Magnitude = data:GetMagnitude() or 1
    
    self.StartTime = CurTime()
    self.LifeTime = 1.5
    
    -- Impact properties
    self.ImpactRadius = 50 * self.Scale
    self.RippleCount = 3
    
    -- Particle system
    self.Emitter = ParticleEmitter(self.Position, false)
    
    -- Create impact burst
    self:CreateImpactBurst()
    
    -- Create shield ripples
    self:CreateShieldRipples()
    
    -- Create energy discharge
    self:CreateEnergyDischarge()
    
    -- Sound effect
    if HYPERDRIVE.Sounds then
        HYPERDRIVE.Sounds.PlayShield("hit", nil, {
            volume = 0.7,
            pitch = math.Rand(90, 110),
            soundLevel = 70
        })
    end
end

function EFFECT:CreateImpactBurst()
    if not self.Emitter then return end
    
    -- Central impact explosion
    for i = 1, 12 do
        local particle = self.Emitter:Add("hyperdrive/shield_impact", self.Position)
        if particle then
            local vel = (self.Normal + VectorRand() * 0.5):GetNormalized() * math.Rand(50, 150)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.8, 1.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(8, 16))
            particle:SetEndSize(math.Rand(20, 35))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-5, 5))
            particle:SetColor(255, 150, 100)
            particle:SetAirResistance(100)
            particle:SetGravity(Vector(0, 0, -20))
            particle:SetCollide(false)
        end
    end
    
    -- Impact sparks
    for i = 1, 20 do
        local particle = self.Emitter:Add("effects/spark", self.Position + VectorRand() * 5)
        if particle then
            local vel = (self.Normal + VectorRand() * 0.8):GetNormalized() * math.Rand(100, 300)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.3, 0.8))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(2, 4))
            particle:SetEndSize(0)
            particle:SetColor(255, 200, 100)
            particle:SetGravity(Vector(0, 0, -100))
            particle:SetCollide(true)
            particle:SetBounce(0.5)
        end
    end
end

function EFFECT:CreateShieldRipples()
    if not self.Emitter then return end
    
    -- Calculate tangent vectors for shield surface
    local up = Vector(0, 0, 1)
    if math.abs(self.Normal:Dot(up)) > 0.9 then
        up = Vector(1, 0, 0)
    end
    
    local right = self.Normal:Cross(up):GetNormalized()
    local forward = right:Cross(self.Normal):GetNormalized()
    
    -- Create ripple rings
    for ring = 1, self.RippleCount do
        local ringRadius = (ring / self.RippleCount) * self.ImpactRadius
        local particleCount = math.floor(ringRadius / 3)
        
        for i = 1, particleCount do
            local angle = (i / particleCount) * 360
            local offset = right * math.cos(math.rad(angle)) * ringRadius + 
                          forward * math.sin(math.rad(angle)) * ringRadius
            local pos = self.Position + offset
            
            local particle = self.Emitter:Add("hyperdrive/shield_bubble", pos)
            if particle then
                local vel = offset:GetNormalized() * math.Rand(20, 40)
                particle:SetVelocity(vel)
                particle:SetLifeTime(0)
                particle:SetDieTime(self.LifeTime * 0.8)
                particle:SetStartAlpha(200)
                particle:SetEndAlpha(0)
                particle:SetStartSize(4)
                particle:SetEndSize(12)
                particle:SetColor(100, 150, 255)
                particle:SetGravity(Vector(0, 0, 0))
                particle:SetCollide(false)
            end
        end
    end
end

function EFFECT:CreateEnergyDischarge()
    if not self.Emitter then return end
    
    -- Energy discharge particles
    for i = 1, 15 do
        local particle = self.Emitter:Add("effects/spark", self.Position + VectorRand() * 10)
        if particle then
            local vel = VectorRand() * math.Rand(80, 200)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.5, 1.2))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(1, 3))
            particle:SetEndSize(0)
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, -50))
            particle:SetCollide(false)
        end
    end
    
    -- Shield energy feedback
    for i = 1, 8 do
        local particle = self.Emitter:Add("hyperdrive/shield_impact", self.Position)
        if particle then
            local vel = VectorRand() * math.Rand(30, 80)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1.0, 1.8))
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(6, 12))
            particle:SetEndSize(math.Rand(15, 25))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-3, 3))
            particle:SetColor(120, 180, 255)
            particle:SetAirResistance(120)
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
    
    -- Create residual energy effects
    if self.Emitter and math.random() < 0.4 then
        local particle = self.Emitter:Add("effects/spark", self.Position + VectorRand() * 20)
        if particle then
            particle:SetVelocity(VectorRand() * 60)
            particle:SetLifeTime(0)
            particle:SetDieTime(0.4)
            particle:SetStartAlpha(150)
            particle:SetEndAlpha(0)
            particle:SetStartSize(1)
            particle:SetEndSize(0)
            particle:SetColor(140, 190, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    return true
end

function EFFECT:Render()
    local age = CurTime() - self.StartTime
    local alpha = math.max(0, 1 - (age / self.LifeTime))
    
    -- Impact flash
    local flashSize = (1 - age / self.LifeTime) * self.ImpactRadius
    local flashAlpha = alpha * 200
    
    render.SetMaterial(Material("hyperdrive/shield_impact"))
    render.DrawSprite(self.Position, flashSize, flashSize, Color(255, 200, 100, flashAlpha))
    
    -- Shield distortion effect
    local distortSize = flashSize * 1.5
    render.DrawSprite(self.Position, distortSize, distortSize, Color(100, 150, 255, flashAlpha * 0.5))
    
    -- Energy ripple
    local rippleSize = (age / self.LifeTime) * self.ImpactRadius * 2
    render.DrawSprite(self.Position, rippleSize, rippleSize, Color(120, 180, 255, alpha * 80))
end
