-- Advanced Space Combat - Ancient Drone Fire Effect
-- Visual effect for Ancient drone weapon firing

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local entity = data:GetEntity()
    
    self.StartPos = pos
    self.Entity = entity
    self.StartTime = CurTime()
    self.LifeTime = 2.0
    
    -- Create firing particles
    self:CreateFiringParticles()
    
    -- Create energy discharge
    self:CreateEnergyDischarge()
    
    -- Create holographic effects
    self:CreateHolographicEffects()
end

function EFFECT:CreateFiringParticles()
    local emitter = ParticleEmitter(self.StartPos)
    if not emitter then return end
    
    -- Energy buildup particles
    for i = 1, 20 do
        local particle = emitter:Add("effects/energyball", self.StartPos + VectorRand() * 30)
        if particle then
            particle:SetVelocity(VectorRand() * 50)
            particle:SetLifeTime(0)
            particle:SetDieTime(1.5)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(2)
            particle:SetEndSize(8)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-2, 2))
            particle:SetColor(100, 150, 255)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(50)
        end
    end
    
    -- Drone launch trails
    for i = 1, 8 do
        local angle = (i / 8) * 360
        local dir = Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0)
        local startPos = self.StartPos + dir * 20
        
        for j = 1, 10 do
            local particle = emitter:Add("effects/energyball", startPos + dir * j * 5)
            if particle then
                particle:SetVelocity(dir * 200 + VectorRand() * 20)
                particle:SetLifeTime(0)
                particle:SetDieTime(0.8)
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)
                particle:SetStartSize(3)
                particle:SetEndSize(1)
                particle:SetColor(120, 180, 255)
                particle:SetGravity(Vector(0, 0, 0))
            end
        end
    end
    
    emitter:Finish()
end

function EFFECT:CreateEnergyDischarge()
    -- Create energy rings
    for i = 1, 3 do
        local emitter = ParticleEmitter(self.StartPos)
        if emitter then
            for j = 1, 16 do
                local angle = (j / 16) * 360
                local dir = Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0)
                local pos = self.StartPos + dir * (i * 15)
                
                local particle = emitter:Add("effects/energyball", pos)
                if particle then
                    particle:SetVelocity(dir * (50 + i * 20))
                    particle:SetLifeTime(0)
                    particle:SetDieTime(1.0 + i * 0.2)
                    particle:SetStartAlpha(200)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(4)
                    particle:SetEndSize(12)
                    particle:SetColor(80, 120, 255)
                    particle:SetGravity(Vector(0, 0, 0))
                end
            end
            emitter:Finish()
        end
    end
end

function EFFECT:CreateHolographicEffects()
    -- Create holographic data streams
    local emitter = ParticleEmitter(self.StartPos)
    if not emitter then return end
    
    for i = 1, 30 do
        local particle = emitter:Add("effects/spark", self.StartPos + VectorRand() * 40)
        if particle then
            particle:SetVelocity(VectorRand() * 100)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.5, 1.5))
            particle:SetStartAlpha(150)
            particle:SetEndAlpha(0)
            particle:SetStartSize(1)
            particle:SetEndSize(3)
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    local elapsed = CurTime() - self.StartTime
    return elapsed < self.LifeTime
end

function EFFECT:Render()
    local elapsed = CurTime() - self.StartTime
    local alpha = 1 - (elapsed / self.LifeTime)
    
    if alpha <= 0 then return end
    
    -- Render energy core
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.StartPos, 60 * alpha, 60 * alpha, Color(100, 150, 255, 255 * alpha))
    
    -- Render expanding energy rings
    for i = 1, 3 do
        local ringSize = (elapsed * 200 + i * 30) % 150
        local ringAlpha = alpha * (1 - ringSize / 150)
        
        if ringAlpha > 0 then
            render.DrawSprite(self.StartPos, ringSize, ringSize, Color(120, 180, 255, 100 * ringAlpha))
        end
    end
    
    -- Render holographic grid
    if IsValid(self.Entity) then
        local up = self.Entity:GetUp()
        local right = self.Entity:GetRight()
        
        render.SetMaterial(Material("effects/select_ring"))
        
        for i = -2, 2 do
            for j = -2, 2 do
                local pos = self.StartPos + up * (i * 20) + right * (j * 20)
                local gridAlpha = alpha * 0.3 * (1 - math.abs(i) * 0.2) * (1 - math.abs(j) * 0.2)
                
                if gridAlpha > 0 then
                    render.DrawSprite(pos, 10, 10, Color(150, 200, 255, 255 * gridAlpha))
                end
            end
        end
    end
end
