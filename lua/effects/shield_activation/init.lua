-- Shield Activation Effect
-- Visual effect for shield generator activation

function EFFECT:Init(data)
    self.Entity = data:GetEntity()
    self.Position = data:GetOrigin()
    self.Scale = data:GetScale() or 1
    self.Magnitude = data:GetMagnitude() or 1
    
    self.StartTime = CurTime()
    self.LifeTime = 2.5
    
    -- Shield properties
    self.ShieldRadius = 150 * self.Scale
    self.GeneratorRadius = 30 * self.Scale
    
    -- Particle system
    self.Emitter = ParticleEmitter(self.Position, false)
    
    -- Create shield formation effect
    self:CreateShieldFormation()
    
    -- Create generator glow
    self:CreateGeneratorGlow()
    
    -- Create energy field
    self:CreateEnergyField()
    
    -- Sound effect
    if IsValid(self.Entity) and HYPERDRIVE.Sounds then
        HYPERDRIVE.Sounds.PlayShield("engage", self.Entity, {
            volume = 0.8,
            pitch = 100,
            soundLevel = 75
        })
    end
end

function EFFECT:CreateShieldFormation()
    if not self.Emitter then return end
    
    -- Shield bubble formation particles
    local particleCount = math.floor(self.ShieldRadius / 8)
    
    for i = 1, particleCount do
        local angle = math.Rand(0, 360)
        local pitch = math.Rand(-90, 90)
        local radius = math.Rand(self.ShieldRadius * 0.8, self.ShieldRadius * 1.2)
        
        local pos = self.Position + Vector(
            math.cos(math.rad(angle)) * math.cos(math.rad(pitch)) * radius,
            math.sin(math.rad(angle)) * math.cos(math.rad(pitch)) * radius,
            math.sin(math.rad(pitch)) * radius
        )
        
        local particle = self.Emitter:Add("hyperdrive/shield_bubble", pos)
        if particle then
            local vel = (pos - self.Position):GetNormalized() * math.Rand(20, 50)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(self.LifeTime)
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(50)
            particle:SetStartSize(math.Rand(8, 16))
            particle:SetEndSize(math.Rand(4, 8))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))
            particle:SetColor(100, 150, 255)
            particle:SetAirResistance(200)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetCollide(false)
        end
    end
    
    -- Energy ripples
    for ring = 1, 5 do
        local ringRadius = (ring / 5) * self.ShieldRadius
        local ringParticles = math.floor(ringRadius / 10)
        
        for i = 1, ringParticles do
            local angle = (i / ringParticles) * 360
            local pos = self.Position + Vector(
                math.cos(math.rad(angle)) * ringRadius,
                math.sin(math.rad(angle)) * ringRadius,
                math.Rand(-10, 10)
            )
            
            local particle = self.Emitter:Add("effects/spark", pos)
            if particle then
                particle:SetVelocity(Vector(0, 0, math.Rand(5, 15)))
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(1.0, 2.0))
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)
                particle:SetStartSize(3)
                particle:SetEndSize(0)
                particle:SetColor(120, 180, 255)
                particle:SetGravity(Vector(0, 0, 0))
                particle:SetCollide(false)
            end
        end
    end
end

function EFFECT:CreateGeneratorGlow()
    if not self.Emitter then return end
    
    -- Generator energy burst
    for i = 1, 15 do
        local particle = self.Emitter:Add("hyperdrive/shield_generator", self.Position + VectorRand() * 10)
        if particle then
            local vel = VectorRand() * math.Rand(30, 80)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1.5, 2.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(6, 12))
            particle:SetEndSize(math.Rand(15, 25))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-3, 3))
            particle:SetColor(80, 120, 255)
            particle:SetAirResistance(150)
            particle:SetGravity(Vector(0, 0, -10))
            particle:SetCollide(false)
        end
    end
end

function EFFECT:CreateEnergyField()
    if not self.Emitter then return end
    
    -- Energy field particles
    for i = 1, 25 do
        local pos = self.Position + VectorRand() * self.ShieldRadius * 0.5
        
        local particle = self.Emitter:Add("effects/spark", pos)
        if particle then
            local vel = (self.Position - pos):GetNormalized() * math.Rand(10, 30)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(2.0, 3.0))
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(2)
            particle:SetEndSize(0)
            particle:SetColor(100, 200, 255)
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
    
    -- Create continuous shield energy
    if self.Emitter and math.random() < 0.3 then
        local angle = math.Rand(0, 360)
        local radius = math.Rand(self.ShieldRadius * 0.7, self.ShieldRadius * 1.1)
        local pos = self.Position + Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            math.Rand(-20, 20)
        )
        
        local particle = self.Emitter:Add("effects/spark", pos)
        if particle then
            particle:SetVelocity(VectorRand() * 20)
            particle:SetLifeTime(0)
            particle:SetDieTime(0.5)
            particle:SetStartAlpha(150)
            particle:SetEndAlpha(0)
            particle:SetStartSize(1)
            particle:SetEndSize(0)
            particle:SetColor(120, 180, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    return true
end

function EFFECT:Render()
    local age = CurTime() - self.StartTime
    local alpha = math.max(0, 1 - (age / self.LifeTime))
    
    -- Expanding shield dome
    local domeRadius = (age / self.LifeTime) * self.ShieldRadius
    local domeAlpha = alpha * 80
    
    render.SetMaterial(Material("hyperdrive/shield_bubble"))
    
    -- Main shield dome
    render.DrawSphere(self.Position, domeRadius, 20, 20, Color(100, 150, 255, domeAlpha * 0.3))
    
    -- Generator glow
    local pulse = math.sin(CurTime() * 4) * 0.3 + 0.7
    local genSize = self.GeneratorRadius * pulse
    render.DrawSprite(self.Position, genSize, genSize, Color(80, 140, 255, alpha * 200))
    
    -- Energy field
    local fieldSize = self.GeneratorRadius * 1.5 * pulse
    render.DrawSprite(self.Position, fieldSize, fieldSize, Color(60, 120, 255, alpha * 100))
end
