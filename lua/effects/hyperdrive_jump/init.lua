-- Hyperdrive Jump Effect

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local magnitude = data:GetMagnitude() -- 1 for origin, 2 for destination
    
    self.Position = pos
    self.IsOrigin = magnitude == 1
    self.LifeTime = 2
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create initial flash
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = 100
        dlight.g = 150
        dlight.b = 255
        dlight.brightness = 5
        dlight.decay = 1000
        dlight.size = 500
        dlight.dietime = CurTime() + 1
    end
    
    -- Create particle effects
    self:CreateParticles()
    
    -- Screen shake for nearby players
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():Distance(pos) < 1000 then
            local intensity = math.max(0.1, 1 - (ply:GetPos():Distance(pos) / 1000))
            util.ScreenShake(pos, intensity * 10, 5, 2, 1000)
        end
    end
    
    -- Sound effect
    if self.IsOrigin then
        sound.Play("ambient/energy/whiteflash.wav", pos, 100, 80)
        timer.Simple(0.5, function()
            sound.Play("ambient/energy/zap7.wav", pos, 100, 60)
        end)
    else
        sound.Play("ambient/energy/zap9.wav", pos, 100, 120)
        sound.Play("ambient/explosions/explode_4.wav", pos, 80, 150)
    end
end

function EFFECT:CreateParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Energy burst particles
    for i = 1, 50 do
        local particle = emitter:Add("effects/spark", self.Position)
        if particle then
            particle:SetVelocity(VectorRand() * 300)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 2))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(2, 8))
            particle:SetEndSize(0)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-5, 5))
            particle:SetColor(100, 150, 255)
            particle:SetGravity(Vector(0, 0, -100))
            particle:SetAirResistance(50)
        end
    end
    
    -- Energy ring
    for i = 1, 30 do
        local angle = (i / 30) * 360
        local dir = Vector(math.cos(math.rad(angle)), math.sin(math.rad(angle)), 0)
        local particle = emitter:Add("effects/energyball", self.Position + dir * 50)
        if particle then
            particle:SetVelocity(dir * 200)
            particle:SetLifeTime(0)
            particle:SetDieTime(1.5)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(10)
            particle:SetEndSize(20)
            particle:SetColor(0, 100, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    -- Upward energy stream
    for i = 1, 20 do
        local particle = emitter:Add("effects/energyball", self.Position)
        if particle then
            particle:SetVelocity(Vector(math.Rand(-50, 50), math.Rand(-50, 50), math.Rand(200, 400)))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(2, 3))
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(15)
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, -50))
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
    
    -- Draw energy portal effect
    local size = 100 * (1 - alpha) + 50
    local color = Color(100, 150, 255, 255 * alpha)
    
    render.SetMaterial(Material("effects/energyball"))
    render.DrawSprite(self.Position, size, size, color)
    
    -- Draw secondary glow
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.Position, size * 2, size * 2, Color(50, 100, 255, 100 * alpha))
    
    -- Draw energy distortion rings
    for i = 1, 3 do
        local ringSize = size * (1 + i * 0.5) * (1 - alpha * 0.5)
        local ringAlpha = alpha * (1 - i * 0.2)
        render.DrawSprite(self.Position + Vector(0, 0, i * 20), ringSize, ringSize, Color(0, 150, 255, 50 * ringAlpha))
    end
end
