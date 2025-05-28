-- Stargate Hyperdrive Jump Effect

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local magnitude = data:GetMagnitude() -- 1 for origin, 2 for destination
    local scale = data:GetScale() -- Technology enhancement factor
    
    self.Position = pos
    self.IsOrigin = magnitude == 1
    self.TechScale = scale or 1
    self.LifeTime = 3
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create enhanced flash for Stargate tech
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = 150
        dlight.g = 200
        dlight.b = 255
        dlight.brightness = 8 * self.TechScale
        dlight.decay = 1500
        dlight.size = 800 * self.TechScale
        dlight.dietime = CurTime() + 1.5
    end
    
    -- Create Stargate-style particle effects
    self:CreateStargateParticles()
    
    -- Screen shake for nearby players
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():Distance(pos) < 1500 then
            local intensity = math.max(0.1, 1 - (ply:GetPos():Distance(pos) / 1500))
            util.ScreenShake(pos, intensity * 15 * self.TechScale, 8, 3, 1500)
        end
    end
    
    -- Enhanced sound effects
    if self.IsOrigin then
        sound.Play("ambient/energy/whiteflash.wav", pos, 100, 70)
        timer.Simple(0.3, function()
            sound.Play("ambient/energy/spark6.wav", pos, 100, 50)
        end)
        timer.Simple(0.8, function()
            sound.Play("ambient/energy/zap7.wav", pos, 100, 40)
        end)
    else
        sound.Play("ambient/energy/zap9.wav", pos, 100, 140)
        sound.Play("ambient/explosions/explode_4.wav", pos, 90, 180)
        timer.Simple(0.2, function()
            sound.Play("ambient/energy/spark6.wav", pos, 80, 120)
        end)
    end
end

function EFFECT:CreateStargateParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Enhanced energy burst particles
    for i = 1, 80 * self.TechScale do
        local particle = emitter:Add("effects/spark", self.Position)
        if particle then
            particle:SetVelocity(VectorRand() * 400 * self.TechScale)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1.5, 3))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(3, 12) * self.TechScale)
            particle:SetEndSize(0)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-8, 8))
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, -80))
            particle:SetAirResistance(30)
        end
    end
    
    -- Stargate-style energy vortex
    for i = 1, 60 * self.TechScale do
        local angle = (i / 60) * 360 * 3 -- Multiple spirals
        local radius = math.Rand(20, 100) * self.TechScale
        local height = math.Rand(-50, 50) * self.TechScale
        
        local dir = Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            height
        ):GetNormalized()
        
        local particle = emitter:Add("effects/energyball", self.Position + dir * 30)
        if particle then
            particle:SetVelocity(dir * 300 * self.TechScale)
            particle:SetLifeTime(0)
            particle:SetDieTime(2)
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(8 * self.TechScale)
            particle:SetEndSize(20 * self.TechScale)
            particle:SetColor(100, 180, 255)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(20)
        end
    end
    
    -- Ancient technology golden particles (if enhanced)
    if self.TechScale > 1 then
        for i = 1, 40 do
            local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 50)
            if particle then
                particle:SetVelocity(VectorRand() * 200)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(2, 4))
                particle:SetStartAlpha(180)
                particle:SetEndAlpha(0)
                particle:SetStartSize(5)
                particle:SetEndSize(15)
                particle:SetColor(255, 215, 0) -- Ancient gold
                particle:SetGravity(Vector(0, 0, -30))
                particle:SetAirResistance(40)
            end
        end
    end
    
    -- Upward energy column
    for i = 1, 30 * self.TechScale do
        local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 20)
        if particle then
            particle:SetVelocity(Vector(
                math.Rand(-30, 30),
                math.Rand(-30, 30),
                math.Rand(300, 600) * self.TechScale
            ))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(2.5, 4))
            particle:SetStartAlpha(220)
            particle:SetEndAlpha(0)
            particle:SetStartSize(6 * self.TechScale)
            particle:SetEndSize(18 * self.TechScale)
            particle:SetColor(120, 180, 255)
            particle:SetGravity(Vector(0, 0, -40))
            particle:SetAirResistance(25)
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
    
    -- Draw enhanced energy portal effect
    local size = (150 * (1 - progress) + 80) * self.TechScale
    local color = Color(150, 200, 255, 255 * alpha)
    
    render.SetMaterial(Material("effects/energyball"))
    render.DrawSprite(self.Position, size, size, color)
    
    -- Draw Stargate-style event horizon
    local horizonSize = size * 1.5
    local horizonColor = Color(100, 150, 255, 150 * alpha)
    render.SetMaterial(Material("hyperdrive/jump_portal"))
    render.DrawSprite(self.Position, horizonSize, horizonSize, horizonColor)
    
    -- Draw secondary glow layers
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.Position, size * 2.5, size * 2.5, Color(80, 120, 255, 80 * alpha))
    
    -- Draw energy distortion rings
    for i = 1, 5 do
        local ringSize = size * (1 + i * 0.4) * (1 - alpha * 0.3)
        local ringAlpha = alpha * (1 - i * 0.15)
        local ringColor = Color(100, 180, 255, 40 * ringAlpha)
        render.DrawSprite(self.Position + Vector(0, 0, i * 25), ringSize, ringSize, ringColor)
    end
    
    -- Ancient technology enhancement
    if self.TechScale > 1 then
        -- Golden energy spirals
        local time = CurTime()
        for i = 1, 4 do
            local angle = (time * 100 + i * 90) % 360
            local spiralRadius = size * 0.8
            local spiralPos = self.Position + Vector(
                math.cos(math.rad(angle)) * spiralRadius,
                math.sin(math.rad(angle)) * spiralRadius,
                math.sin(time * 2 + i) * 20
            )
            local spiralColor = Color(255, 215, 0, 200 * alpha)
            render.DrawSprite(spiralPos, 25, 25, spiralColor)
        end
        
        -- Central Ancient symbol effect
        local symbolSize = size * 0.6
        local symbolColor = Color(255, 215, 0, 180 * alpha)
        render.SetMaterial(Material("hyperdrive/engine_glow"))
        render.DrawSprite(self.Position, symbolSize, symbolSize, symbolColor)
    end
end
