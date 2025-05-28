-- Hyperdrive Charging Effect

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local intensity = data:GetMagnitude()
    
    self.Position = pos
    self.Intensity = intensity
    self.LifeTime = 0.5
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create charging particles
    self:CreateChargingParticles()
end

function EFFECT:CreateChargingParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Electric arcs
    for i = 1, 10 do
        local particle = emitter:Add("effects/spark", self.Position + VectorRand() * 30)
        if particle then
            particle:SetVelocity(VectorRand() * 100)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.3, 0.8))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(1, 3))
            particle:SetEndSize(0)
            particle:SetColor(255, 255, 100)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    -- Energy buildup
    for i = 1, 5 do
        local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 20)
        if particle then
            particle:SetVelocity((self.Position - particle:GetPos()):GetNormalized() * 50)
            particle:SetLifeTime(0)
            particle:SetDieTime(0.5)
            particle:SetStartAlpha(150)
            particle:SetEndAlpha(0)
            particle:SetStartSize(3)
            particle:SetEndSize(8)
            particle:SetColor(100, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    return self.DieTime > CurTime()
end

function EFFECT:Render()
    local timeLeft = self.DieTime - CurTime()
    local alpha = math.max(0, timeLeft / self.LifeTime)
    
    if alpha <= 0 then return end
    
    -- Draw charging glow
    local size = 30 * self.Intensity
    local color = Color(255, 255 * self.Intensity, 0, 150 * alpha)
    
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.Position, size, size, color)
end
