-- Stargate Hyperdrive Starline Effects
-- Creates stretched starline visuals during hyperspace travel

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local magnitude = data:GetMagnitude() or 1.0
    local scale = data:GetScale() or 1.0
    
    self.Position = pos
    self.Intensity = magnitude
    self.TechScale = scale
    self.LifeTime = 2.0
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create starline particles
    self:CreateStarlineParticles()
end

function EFFECT:CreateStarlineParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Create stretched starlines
    for i = 1, 50 * self.TechScale do
        -- Random direction for starline
        local direction = VectorRand():GetNormalized()
        local distance = math.Rand(500, 2000) * self.TechScale
        
        -- Create starline particle
        local particle = emitter:Add("effects/spark", self.Position + direction * distance * 0.5)
        if particle then
            particle:SetVelocity(direction * 1000 * self.TechScale)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1.5, 3.0))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(1, 3))
            particle:SetEndSize(math.Rand(8, 15))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(0)
            
            -- Color based on distance (closer = brighter)
            local brightness = math.max(100, 255 - (distance / 10))
            particle:SetColor(brightness, brightness * 0.8, 255)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(0)
        end
    end
    
    -- Create dimensional tunnel effect
    for i = 1, 30 * self.TechScale do
        local angle = (i / 30) * 360 * 2 -- Double spiral
        local radius = math.Rand(100, 300) * self.TechScale
        local forward = math.Rand(200, 800) * self.TechScale
        
        local tunnelPos = self.Position + Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            0
        ) + Vector(0, 0, 1) * forward
        
        local particle = emitter:Add("effects/energyball", tunnelPos)
        if particle then
            particle:SetVelocity(Vector(0, 0, -500 * self.TechScale))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(2, 4))
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5 * self.TechScale)
            particle:SetEndSize(15 * self.TechScale)
            particle:SetColor(100, 150, 255)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(10)
        end
    end
    
    -- Create energy streams
    for i = 1, 20 * self.TechScale do
        local streamDir = VectorRand():GetNormalized()
        streamDir.z = math.abs(streamDir.z) -- Prefer upward direction
        
        local particle = emitter:Add("effects/energyball", self.Position + streamDir * 50)
        if particle then
            particle:SetVelocity(streamDir * 600 * self.TechScale)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(3, 5))
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(3)
            particle:SetEndSize(12)
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(20)
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
    
    -- Draw hyperspace tunnel glow
    local size = 200 * self.Intensity * self.TechScale
    local color = Color(100, 150, 255, 150 * alpha)
    
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.Position, size, size, color)
    
    -- Draw dimensional distortion rings
    local time = CurTime()
    for i = 1, 6 do
        local ringSize = size * (0.5 + i * 0.2) * (1 + math.sin(time * 2 + i) * 0.1)
        local ringAlpha = alpha * (1 - i * 0.12)
        local ringColor = Color(80, 120, 255, 60 * ringAlpha)
        
        local ringPos = self.Position + Vector(0, 0, i * 40 - 120)
        render.DrawSprite(ringPos, ringSize, ringSize, ringColor)
    end
    
    -- Draw energy flow lines
    for i = 1, 8 do
        local angle = (time * 50 + i * 45) % 360
        local lineRadius = size * 0.6
        local linePos = self.Position + Vector(
            math.cos(math.rad(angle)) * lineRadius,
            math.sin(math.rad(angle)) * lineRadius,
            math.sin(time * 3 + i) * 30
        )
        
        local lineColor = Color(150, 200, 255, 120 * alpha)
        render.DrawSprite(linePos, 15, 15, lineColor)
    end
end
