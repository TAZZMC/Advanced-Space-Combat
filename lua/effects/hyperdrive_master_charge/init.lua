-- Master Hyperdrive Charging Effect - ALL FEATURES COMBINED

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local intensity = data:GetMagnitude()
    local scale = data:GetScale() or 1
    
    self.Position = pos
    self.Intensity = intensity
    self.EfficiencyScale = scale
    self.LifeTime = 1.0
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create master charging particles
    self:CreateMasterChargingParticles()
end

function EFFECT:CreateMasterChargingParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Enhanced electric arcs (Wiremod style)
    for i = 1, 20 * self.EfficiencyScale do
        local particle = emitter:Add("effects/spark", self.Position + VectorRand() * 50)
        if particle then
            particle:SetVelocity(VectorRand() * 200)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.5, 1.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(3, 8))
            particle:SetEndSize(0)
            particle:SetColor(0, 150, 255) -- Blue electric
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    -- Master energy convergence
    for i = 1, 15 * self.EfficiencyScale do
        local startPos = self.Position + VectorRand() * 100
        local particle = emitter:Add("effects/energyball", startPos)
        if particle then
            particle:SetVelocity((self.Position - startPos):GetNormalized() * 120)
            particle:SetLifeTime(0)
            particle:SetDieTime(1.0)
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(15)
            particle:SetColor(180, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    -- Spacebuild resource particles
    for i = 1, 12 * self.EfficiencyScale do
        local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 40)
        if particle then
            particle:SetVelocity(VectorRand() * 100)
            particle:SetLifeTime(0)
            particle:SetDieTime(1.2)
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(4)
            particle:SetEndSize(12)
            
            -- Resource colors
            if i % 3 == 0 then
                particle:SetColor(255, 255, 0) -- Power
            elseif i % 3 == 1 then
                particle:SetColor(0, 255, 255) -- Oxygen
            else
                particle:SetColor(100, 150, 255) -- Coolant
            end
            
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    -- Ancient/Stargate enhancement (if high efficiency)
    if self.EfficiencyScale > 1.2 then
        for i = 1, 10 do
            local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 35)
            if particle then
                particle:SetVelocity(VectorRand() * 80)
                particle:SetLifeTime(0)
                particle:SetDieTime(1.5)
                particle:SetStartAlpha(220)
                particle:SetEndAlpha(0)
                particle:SetStartSize(4)
                particle:SetEndSize(14)
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
    
    -- Draw master charging glow
    local size = 60 * self.Intensity * self.EfficiencyScale
    local color = Color(180, 200, 255, 220 * alpha)
    
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.Position, size, size, color)
    
    -- Wiremod electric glow
    local electricColor = Color(0, 150, 255, 180 * alpha)
    render.DrawSprite(self.Position, size * 0.8, size * 0.8, electricColor)
    
    -- Spacebuild resource indicators
    if self.EfficiencyScale > 1.0 then
        local resourceSize = size * 0.4
        render.DrawSprite(self.Position + Vector(20, 0, 0), resourceSize, resourceSize, Color(255, 255, 0, 120 * alpha)) -- Power
        render.DrawSprite(self.Position + Vector(-20, 0, 0), resourceSize, resourceSize, Color(0, 255, 255, 120 * alpha)) -- Oxygen
        render.DrawSprite(self.Position + Vector(0, 20, 0), resourceSize, resourceSize, Color(100, 150, 255, 120 * alpha)) -- Coolant
    end
    
    -- Ancient technology golden glow (high efficiency)
    if self.EfficiencyScale > 1.2 then
        local ancientColor = Color(255, 215, 0, 160 * alpha)
        render.DrawSprite(self.Position, size * 0.6, size * 0.6, ancientColor)
    end
end
