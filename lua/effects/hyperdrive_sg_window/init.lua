-- Stargate Hyperdrive Window Opening Effect
-- Creates the blue/purple swirling energy tunnel effect

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local magnitude = data:GetMagnitude() or 1.0
    local scale = data:GetScale() or 1.0
    
    self.Position = pos
    self.Intensity = magnitude
    self.TechScale = scale
    self.LifeTime = 2.5
    self.DieTime = CurTime() + self.LifeTime
    
    -- Create window opening effects
    self:CreateWindowEffects()
    
    -- Create dynamic light
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = 100
        dlight.g = 150
        dlight.b = 255
        dlight.brightness = 6 * self.TechScale
        dlight.decay = 800
        dlight.size = 600 * self.TechScale
        dlight.dietime = CurTime() + self.LifeTime
    end
end

function EFFECT:CreateWindowEffects()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Create swirling portal vortex
    for i = 1, 100 * self.TechScale do
        local angle = (i / 100) * 360 * 4 -- Multiple spirals
        local radius = math.Rand(10, 120) * self.TechScale
        local height = math.Rand(-80, 80) * self.TechScale
        local time = i * 0.02
        
        -- Spiral calculation
        local spiralAngle = angle + time * 180
        local spiralRadius = radius * (1 - time * 0.3)
        
        local spiralPos = self.Position + Vector(
            math.cos(math.rad(spiralAngle)) * spiralRadius,
            math.sin(math.rad(spiralAngle)) * spiralRadius,
            height
        )
        
        local particle = emitter:Add("effects/energyball", spiralPos)
        if particle then
            -- Velocity towards center with spiral motion
            local centerDir = (self.Position - spiralPos):GetNormalized()
            local spiralVel = Vector(
                -math.sin(math.rad(spiralAngle)) * 100,
                math.cos(math.rad(spiralAngle)) * 100,
                math.Rand(-50, 50)
            )
            
            particle:SetVelocity(centerDir * 150 + spiralVel)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(2, 4))
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(4, 8) * self.TechScale)
            particle:SetEndSize(math.Rand(12, 20) * self.TechScale)
            
            -- Blue to purple gradient based on distance from center
            local distanceRatio = radius / (120 * self.TechScale)
            local r = math.Clamp(100 + distanceRatio * 100, 100, 200)
            local g = math.Clamp(150 - distanceRatio * 50, 100, 150)
            local b = 255
            
            particle:SetColor(r, g, b)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(20)
        end
    end
    
    -- Create energy ripples
    for i = 1, 20 * self.TechScale do
        local rippleAngle = math.Rand(0, 360)
        local rippleRadius = math.Rand(80, 200) * self.TechScale
        
        local ripplePos = self.Position + Vector(
            math.cos(math.rad(rippleAngle)) * rippleRadius,
            math.sin(math.rad(rippleAngle)) * rippleRadius,
            math.Rand(-20, 20)
        )
        
        local particle = emitter:Add("effects/spark", ripplePos)
        if particle then
            particle:SetVelocity((self.Position - ripplePos):GetNormalized() * 200)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1.5, 3))
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(6, 12))
            particle:SetEndSize(math.Rand(2, 6))
            particle:SetColor(120, 180, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end
    
    -- Create dimensional tear effect
    for i = 1, 30 * self.TechScale do
        local tearAngle = math.Rand(0, 360)
        local tearDistance = math.Rand(50, 150) * self.TechScale
        
        local tearPos = self.Position + Vector(
            math.cos(math.rad(tearAngle)) * tearDistance,
            math.sin(math.rad(tearAngle)) * tearDistance,
            math.Rand(-30, 30)
        )
        
        local particle = emitter:Add("effects/energyball", tearPos)
        if particle then
            -- Chaotic movement
            particle:SetVelocity(VectorRand() * 300 * self.TechScale)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 2.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(2, 5))
            particle:SetEndSize(math.Rand(8, 15))
            particle:SetColor(80, 120, 255)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(50)
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
    
    -- Draw main portal effect
    local size = (50 + progress * 150) * self.TechScale
    local portalColor = Color(100, 150, 255, 200 * alpha)
    
    render.SetMaterial(Material("hyperdrive/jump_portal"))
    render.DrawSprite(self.Position, size, size, portalColor)
    
    -- Draw swirling energy layers
    local time = CurTime()
    for i = 1, 5 do
        local layerAngle = (time * 50 * i) % 360
        local layerSize = size * (0.6 + i * 0.1)
        local layerAlpha = alpha * (1 - i * 0.15)
        
        local layerPos = self.Position + Vector(
            math.cos(math.rad(layerAngle)) * 10,
            math.sin(math.rad(layerAngle)) * 10,
            0
        )
        
        local layerColor = Color(80 + i * 20, 120 + i * 10, 255, 150 * layerAlpha)
        render.SetMaterial(Material("effects/energyball"))
        render.DrawSprite(layerPos, layerSize, layerSize, layerColor)
    end
    
    -- Draw energy vortex center
    local vortexSize = size * 0.4 * (1 + math.sin(time * 8) * 0.1)
    local vortexColor = Color(150, 200, 255, 255 * alpha)
    
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.Position, vortexSize, vortexSize, vortexColor)
    
    -- Draw dimensional distortion rings
    for i = 1, 8 do
        local ringAngle = (time * 30 + i * 45) % 360
        local ringRadius = size * (0.8 + i * 0.1)
        local ringAlpha = alpha * (1 - i * 0.1) * 0.6
        
        local ringPos = self.Position + Vector(
            math.cos(math.rad(ringAngle)) * ringRadius * 0.3,
            math.sin(math.rad(ringAngle)) * ringRadius * 0.3,
            math.sin(time * 4 + i) * 20
        )
        
        local ringColor = Color(100, 150, 255, 80 * ringAlpha)
        render.DrawSprite(ringPos, 20, 20, ringColor)
    end
end
