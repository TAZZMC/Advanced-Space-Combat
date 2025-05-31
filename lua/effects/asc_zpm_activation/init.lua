-- Advanced Space Combat - ZPM Activation Effect

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local active = data:GetMagnitude() > 0
    
    self.Position = pos
    self.Active = active
    self.LifeTime = 2.0
    self.DieTime = CurTime() + self.LifeTime
    
    if active then
        self:CreateActivationEffect()
    else
        self:CreateDeactivationEffect()
    end
end

function EFFECT:CreateActivationEffect()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Energy surge particles
    for i = 1, 30 do
        local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 50)
        if particle then
            particle:SetVelocity(VectorRand() * 200)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 2))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(2, 6))
            particle:SetEndSize(0)
            particle:SetColor(100, 150, 255)
            particle:SetGravity(Vector(0, 0, -100))
        end
    end
    
    -- Expanding energy ring
    for i = 1, 20 do
        local angle = (i / 20) * math.pi * 2
        local radius = 100
        local ringPos = self.Position + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 0)
        
        local particle = emitter:Add("effects/spark", ringPos)
        if particle then
            particle:SetVelocity(Vector(math.cos(angle), math.sin(angle), 0) * 300)
            particle:SetLifeTime(0)
            particle:SetDieTime(1.5)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(4)
            particle:SetEndSize(1)
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    emitter:Finish()
    
    -- Sound effect
    sound.Play("asc/ancient/zmp_activate.wav", self.Position, 75, 100, 1)
end

function EFFECT:CreateDeactivationEffect()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Fading particles
    for i = 1, 15 do
        local particle = emitter:Add("effects/spark", self.Position + VectorRand() * 30)
        if particle then
            particle:SetVelocity(VectorRand() * 50)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.5, 1.5))
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(3)
            particle:SetEndSize(0)
            particle:SetColor(100, 100, 200)
            particle:SetGravity(Vector(0, 0, -50))
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
    
    if self.Active then
        -- Activation glow
        local size = 100 * (1 - alpha) + 50
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(self.Position, size, size, Color(100, 150, 255, 255 * alpha))
    end
end
