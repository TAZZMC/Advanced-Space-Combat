-- Stargate Hyperdrive Charging Effect

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local intensity = data:GetMagnitude()
    local scale = data:GetScale() or 1
    
    self.Position = pos
    self.Intensity = intensity
    self.TechScale = scale
    self.LifeTime = 0.8
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create Stargate-style charging particles
    self:CreateStargateChargingParticles()
end

function EFFECT:CreateStargateChargingParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Enhanced electric arcs
    for i = 1, 15 * self.TechScale do
        local particle = emitter:Add("effects/spark", self.Position + VectorRand() * 40)
        if particle then
            particle:SetVelocity(VectorRand() * 150)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.4, 1.2))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(2, 6))
            particle:SetEndSize(0)
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    -- Stargate-style energy convergence
    for i = 1, 12 * self.TechScale do
        local startPos = self.Position + VectorRand() * 80
        local particle = emitter:Add("effects/energyball", startPos)
        if particle then
            particle:SetVelocity((self.Position - startPos):GetNormalized() * 100)
            particle:SetLifeTime(0)
            particle:SetDieTime(0.8)
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(4)
            particle:SetEndSize(12)
            particle:SetColor(100, 180, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    -- Ancient technology enhancement
    if self.TechScale > 1 then
        for i = 1, 8 do
            local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 30)
            if particle then
                particle:SetVelocity(VectorRand() * 80)
                particle:SetLifeTime(0)
                particle:SetDieTime(1.0)
                particle:SetStartAlpha(200)
                particle:SetEndAlpha(0)
                particle:SetStartSize(3)
                particle:SetEndSize(10)
                particle:SetColor(255, 215, 0) -- Ancient gold
                particle:SetGravity(Vector(0, 0, 0))
            end
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
    
    -- Draw Stargate-style charging glow
    local size = 40 * self.Intensity * self.TechScale
    local color = Color(150, 200, 255, 200 * alpha)
    
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.Position, size, size, color)
    
    -- Ancient technology golden glow
    if self.TechScale > 1 then
        local ancientColor = Color(255, 215, 0, 150 * alpha)
        render.DrawSprite(self.Position, size * 0.7, size * 0.7, ancientColor)
    end
end
