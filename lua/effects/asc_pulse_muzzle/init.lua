-- Advanced Space Combat - Pulse Cannon Muzzle Flash Effect
-- Visual effect for pulse cannon firing

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local normal = data:GetNormal()
    local entity = data:GetEntity()
    
    self.StartPos = pos
    self.Normal = normal
    self.Entity = entity
    
    self.LifeTime = 0.3
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create particle emitter
    self.Emitter = ParticleEmitter(pos)
    
    if self.Emitter then
        -- Muzzle flash particles
        for i = 1, 8 do
            local particle = self.Emitter:Add("effects/energyball", pos + VectorRand() * 5)
            
            if particle then
                particle:SetVelocity(normal * math.Rand(50, 150) + VectorRand() * 30)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(0.1, 0.3))
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.Rand(3, 8))
                particle:SetEndSize(math.Rand(10, 20))
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-20, 20))
                particle:SetColor(255, 100, 100)
                particle:SetGravity(Vector(0, 0, 0))
                particle:SetAirResistance(30)
            end
        end
        
        -- Energy sparks
        for i = 1, 5 do
            local particle = self.Emitter:Add("effects/spark", pos + VectorRand() * 3)
            
            if particle then
                particle:SetVelocity(normal * math.Rand(100, 200) + VectorRand() * 50)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(0.2, 0.4))
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.Rand(1, 3))
                particle:SetEndSize(0)
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-10, 10))
                particle:SetColor(255, 150, 150)
                particle:SetGravity(Vector(0, 0, -50))
                particle:SetAirResistance(20)
            end
        end
    end
    
    -- Create brief dynamic light
    local dlight = DynamicLight(0)
    if dlight then
        dlight.pos = pos
        dlight.r = 255
        dlight.g = 100
        dlight.b = 100
        dlight.brightness = 3
        dlight.decay = 2000
        dlight.size = 100
        dlight.dietime = CurTime() + 0.1
    end
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    -- Effect is handled by particles and dynamic light
end
