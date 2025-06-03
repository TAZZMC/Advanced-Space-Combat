-- Advanced Space Combat - Engine Thrust Effect
-- Visual effect for hyperdrive engine thrust

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local normal = data:GetNormal()
    local magnitude = data:GetMagnitude() or 1
    local scale = data:GetScale() or 1
    
    self.StartPos = pos
    self.Normal = normal
    self.Magnitude = magnitude
    self.Scale = scale
    
    self.LifeTime = 0.5
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create particle emitter
    self.Emitter = ParticleEmitter(pos)
    
    if self.Emitter then
        for i = 1, 10 * magnitude do
            local particle = self.Emitter:Add("effects/spark", pos + VectorRand() * 10)
            
            if particle then
                particle:SetVelocity(normal * math.Rand(200, 500) + VectorRand() * 50)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(0.3, 0.8))
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.Rand(2, 5) * scale)
                particle:SetEndSize(0)
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-5, 5))
                particle:SetColor(100, 150, 255)
                particle:SetGravity(Vector(0, 0, -100))
                particle:SetAirResistance(50)
            end
        end
        
        -- Add some blue energy particles
        for i = 1, 5 * magnitude do
            local particle = self.Emitter:Add("effects/energyball", pos + VectorRand() * 5)
            
            if particle then
                particle:SetVelocity(normal * math.Rand(100, 300) + VectorRand() * 30)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(0.2, 0.6))
                particle:SetStartAlpha(200)
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.Rand(3, 8) * scale)
                particle:SetEndSize(0)
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-10, 10))
                particle:SetColor(50, 100, 255)
                particle:SetGravity(Vector(0, 0, 0))
                particle:SetAirResistance(20)
            end
        end
    end
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    -- Effect is handled by particles
end
