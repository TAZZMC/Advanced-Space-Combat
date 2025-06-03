-- Advanced Space Combat - Shield Impact Effect
-- Professional shield impact visual effect

EFFECT.Mat = Material("effects/asc_shield_bubble")
EFFECT.MatSpark = Material("effects/energysplash")
EFFECT.MatRipple = Material("effects/select_ring")

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self.Normal = data:GetNormal()
    self.Scale = data:GetScale() or 1
    self.Magnitude = data:GetMagnitude() or 50
    
    self.LifeTime = 1.5
    self.DieTime = CurTime() + self.LifeTime
    
    -- Impact properties
    self.ImpactSize = self.Magnitude * self.Scale
    self.MaxSize = self.ImpactSize * 3
    self.CurrentSize = self.ImpactSize * 0.1
    
    -- Ripple effect
    self.RippleSize = 0
    self.MaxRippleSize = self.ImpactSize * 4
    
    -- Color based on impact type
    self.ImpactColor = Color(100, 255, 150, 255)
    
    -- Create impact particles
    self:CreateImpactParticles()
    
    -- Sound effect
    self:EmitSound("ambient/energy/spark" .. math.random(1, 6) .. ".wav", 75, math.random(90, 110))
end

function EFFECT:CreateImpactParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Spark particles
    for i = 1, 15 do
        local particle = emitter:Add("effects/energysplash", self.Position)
        if particle then
            local vel = (self.Normal + VectorRand() * 0.5):GetNormalized() * math.Rand(50, 150)
            particle:SetVelocity(vel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.5, 1.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(3, 8))
            particle:SetEndSize(0)
            particle:SetColor(100, 255, 150)
            particle:SetGravity(Vector(0, 0, -100))
            particle:SetAirResistance(100)
        end
    end
    
    -- Energy wisps
    for i = 1, 8 do
        local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 20)
        if particle then
            particle:SetVelocity(VectorRand() * 80)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.8, 2.0))
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(8, 15))
            particle:SetEndSize(0)
            particle:SetColor(150, 255, 200)
            particle:SetAirResistance(80)
        end
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    if CurTime() > self.DieTime then
        return false
    end
    
    local timeLeft = self.DieTime - CurTime()
    local progress = 1 - (timeLeft / self.LifeTime)
    
    -- Animate impact size
    if progress < 0.2 then
        self.CurrentSize = Lerp(progress / 0.2, self.ImpactSize * 0.1, self.ImpactSize)
    else
        self.CurrentSize = Lerp((progress - 0.2) / 0.8, self.ImpactSize, 0)
    end
    
    -- Animate ripple
    self.RippleSize = Lerp(progress, 0, self.MaxRippleSize)
    
    return true
end

function EFFECT:Render()
    local alpha = math.Clamp((self.DieTime - CurTime()) / self.LifeTime, 0, 1)
    if alpha <= 0 then return end
    
    -- Main impact
    render.SetMaterial(self.Mat)
    render.DrawQuadEasy(
        self.Position,
        self.Normal,
        self.CurrentSize,
        self.CurrentSize,
        Color(self.ImpactColor.r, self.ImpactColor.g, self.ImpactColor.b, alpha * 200)
    )
    
    -- Ripple effect
    if self.RippleSize > 0 then
        render.SetMaterial(self.MatRipple)
        render.DrawQuadEasy(
            self.Position + self.Normal * 1,
            self.Normal,
            self.RippleSize,
            self.RippleSize,
            Color(self.ImpactColor.r, self.ImpactColor.g, self.ImpactColor.b, alpha * 64)
        )
    end
end
