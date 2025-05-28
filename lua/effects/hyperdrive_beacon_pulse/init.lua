-- Hyperdrive Beacon Pulse Effect

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local range = data:GetMagnitude()
    
    self.Position = pos
    self.Range = range or 1000
    self.LifeTime = 2
    self.DieTime = CurTime() + self.LifeTime
    self.StartTime = CurTime()
    
    -- Create pulse particles
    self:CreatePulseParticles()
    
    -- Sound effect
    sound.Play("ambient/energy/spark6.wav", pos, 60, 120)
end

function EFFECT:CreatePulseParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Expanding ring particles
    for i = 1, 30 do
        local angle = (i / 30) * 360
        local dir = Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0)
        
        local particle = emitter:Add("effects/energyball", self.Position)
        if particle then
            particle:SetVelocity(dir * 200)
            particle:SetLifeTime(0)
            particle:SetDieTime(2)
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(15)
            particle:SetColor(0, 255, 100)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(50)
        end
    end
    
    -- Upward energy streams
    for i = 1, 10 do
        local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 20)
        if particle then
            particle:SetVelocity(Vector(0, 0, math.Rand(100, 200)))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 2))
            particle:SetStartAlpha(150)
            particle:SetEndAlpha(0)
            particle:SetStartSize(3)
            particle:SetEndSize(8)
            particle:SetColor(100, 255, 150)
            particle:SetGravity(Vector(0, 0, -30))
        end
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    return self.DieTime > CurTime()
end

function EFFECT:Render()
    local timeLeft = self.DieTime - CurTime()
    local progress = 1 - (timeLeft / self.LifeTime)
    local alpha = timeLeft / self.LifeTime
    
    if alpha <= 0 then return end
    
    -- Draw expanding pulse ring
    local ringSize = self.Range * progress * 0.01
    local ringColor = Color(0, 255, 100, 100 * alpha)
    
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.Position, ringSize, ringSize, ringColor)
    
    -- Draw central beacon glow
    local centralSize = 50 * (1 - progress * 0.5)
    local centralColor = Color(0, 255, 150, 200 * alpha)
    render.DrawSprite(self.Position + Vector(0, 0, 15), centralSize, centralSize, centralColor)
end
