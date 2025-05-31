-- Advanced Space Combat - Energy Transfer Effect

function EFFECT:Init(data)
    local startPos = data:GetStart()
    local endPos = data:GetOrigin()
    local magnitude = data:GetMagnitude()
    
    self.StartPos = startPos
    self.EndPos = endPos
    self.Magnitude = magnitude
    self.LifeTime = 1.0
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create energy beam particles
    self:CreateEnergyBeam()
    self:CreateEnergyParticles()
end

function EFFECT:CreateEnergyBeam()
    local emitter = ParticleEmitter(self.StartPos)
    if not emitter then return end
    
    local direction = (self.EndPos - self.StartPos):GetNormalized()
    local distance = self.StartPos:Distance(self.EndPos)
    local segments = math.min(20, math.max(5, distance / 100))
    
    for i = 0, segments do
        local pos = self.StartPos + direction * (distance * i / segments)
        
        local particle = emitter:Add("effects/spark", pos)
        if particle then
            particle:SetVelocity(VectorRand() * 20)
            particle:SetLifeTime(0)
            particle:SetDieTime(self.LifeTime)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(2)
            particle:SetColor(100, 150, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    emitter:Finish()
end

function EFFECT:CreateEnergyParticles()
    local emitter = ParticleEmitter(self.StartPos)
    if not emitter then return end
    
    -- Source particles
    for i = 1, 10 do
        local particle = emitter:Add("effects/energyball", self.StartPos + VectorRand() * 20)
        if particle then
            particle:SetVelocity((self.EndPos - self.StartPos):GetNormalized() * 500 + VectorRand() * 50)
            particle:SetLifeTime(0)
            particle:SetDieTime(self.LifeTime * 0.8)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(3)
            particle:SetEndSize(1)
            particle:SetColor(100, 150, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    -- Destination particles
    for i = 1, 5 do
        local particle = emitter:Add("effects/energyball", self.EndPos + VectorRand() * 30)
        if particle then
            particle:SetVelocity(VectorRand() * 100)
            particle:SetLifeTime(0)
            particle:SetDieTime(self.LifeTime)
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(4)
            particle:SetEndSize(0)
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    if CurTime() > self.DieTime then return end
    
    local alpha = math.max(0, (self.DieTime - CurTime()) / self.LifeTime)
    
    -- Draw energy beam
    render.SetMaterial(Material("hyperdrive/energy_beam"))
    render.DrawBeam(self.StartPos, self.EndPos, 8 * alpha, 0, 1, Color(100, 150, 255, 255 * alpha))
    
    -- Draw core beam
    render.DrawBeam(self.StartPos, self.EndPos, 3 * alpha, 0, 1, Color(200, 220, 255, 255 * alpha))
end
