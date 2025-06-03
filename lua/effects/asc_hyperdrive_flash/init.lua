-- Advanced Space Combat - Hyperdrive Flash Effect
-- Visual effect for hyperdrive jumps

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local magnitude = data:GetMagnitude() or 1
    
    self.StartPos = pos
    self.Magnitude = magnitude
    
    self.LifeTime = 1.0
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create particle emitter
    self.Emitter = ParticleEmitter(pos)
    
    if self.Emitter then
        -- Create expanding energy ring
        for i = 1, 20 * magnitude do
            local particle = self.Emitter:Add("effects/energyball", pos)
            
            if particle then
                local vel = VectorRand()
                vel.z = vel.z * 0.3 -- Flatten the effect
                vel = vel * math.Rand(100, 300)
                
                particle:SetVelocity(vel)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(0.5, 1.0))
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.Rand(5, 15))
                particle:SetEndSize(math.Rand(20, 40))
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-5, 5))
                particle:SetColor(100, 200, 255)
                particle:SetGravity(Vector(0, 0, 0))
                particle:SetAirResistance(10)
            end
        end
        
        -- Create bright flash particles
        for i = 1, 10 * magnitude do
            local particle = self.Emitter:Add("effects/spark", pos + VectorRand() * 20)
            
            if particle then
                particle:SetVelocity(VectorRand() * 200)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(0.3, 0.7))
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)
                particle:SetStartSize(math.Rand(8, 20))
                particle:SetEndSize(0)
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(math.Rand(-10, 10))
                particle:SetColor(200, 220, 255)
                particle:SetGravity(Vector(0, 0, 0))
                particle:SetAirResistance(50)
            end
        end
    end
    
    -- Create dynamic light
    local dlight = DynamicLight(0)
    if dlight then
        dlight.pos = pos
        dlight.r = 150
        dlight.g = 200
        dlight.b = 255
        dlight.brightness = 5 * magnitude
        dlight.decay = 1000
        dlight.size = 500 * magnitude
        dlight.dietime = CurTime() + 0.5
    end
end

function EFFECT:Think()
    return CurTime() < self.DieTime
end

function EFFECT:Render()
    -- Effect is handled by particles and dynamic light
end
