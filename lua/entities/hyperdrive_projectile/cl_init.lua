include("shared.lua")

-- Client-side projectile
function ENT:Initialize()
    self.trailTime = 0
    self.glowTime = 0
    self.projectileType = "energy_pulse"
end

function ENT:Draw()
    -- Don't draw the model, we'll create our own effects
    -- self:DrawModel()
    
    local projectileType = self:GetProjectileType()
    
    if projectileType == "energy_pulse" then
        self:DrawEnergyPulse()
    elseif projectileType == "plasma_bolt" then
        self:DrawPlasmaBolt()
    elseif projectileType == "torpedo" then
        self:DrawTorpedo()
    elseif projectileType == "railgun_slug" then
        self:DrawRailgunSlug()
    else
        self:DrawEnergyPulse() -- Default
    end
end

function ENT:DrawEnergyPulse()
    local pos = self:GetPos()
    
    -- Main energy core
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, 16, 16, Color(100, 200, 255, 255))
    
    -- Outer glow
    render.DrawSprite(pos, 32, 32, Color(150, 220, 255, 100))
    
    -- Pulsing effect
    self.glowTime = self.glowTime + FrameTime() * 10
    local pulse = math.sin(self.glowTime) * 0.3 + 0.7
    render.DrawSprite(pos, 24 * pulse, 24 * pulse, Color(200, 240, 255, 150 * pulse))
end

function ENT:DrawPlasmaBolt()
    local pos = self:GetPos()
    
    -- Main plasma core
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, 20, 20, Color(255, 150, 100, 255))
    
    -- Heat distortion effect
    render.DrawSprite(pos, 40, 40, Color(255, 200, 150, 80))
    
    -- Flickering effect
    self.glowTime = self.glowTime + FrameTime() * 15
    local flicker = math.sin(self.glowTime) * 0.4 + 0.6
    render.DrawSprite(pos, 30 * flicker, 30 * flicker, Color(255, 180, 120, 200 * flicker))
end

function ENT:DrawTorpedo()
    -- Draw the actual model for torpedoes
    self:DrawModel()
    
    local pos = self:GetPos()
    local forward = self:GetForward()
    
    -- Engine trail
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos - forward * 20, 12, 12, Color(255, 255, 100, 200))
    render.DrawSprite(pos - forward * 30, 8, 8, Color(255, 200, 100, 150))
    
    -- Exhaust particles
    if math.random() < 0.7 then
        local particle = EffectData()
        particle:SetOrigin(pos - forward * 25 + VectorRand() * 5)
        particle:SetScale(0.5)
        util.Effect("BlueFlash", particle)
    end
end

function ENT:DrawRailgunSlug()
    local pos = self:GetPos()
    local forward = self:GetForward()
    
    -- Draw as a streak
    render.SetMaterial(Material("cable/blue_elec"))
    render.DrawBeam(pos, pos - forward * 100, 4, 0, 1, Color(200, 200, 255, 255))
    
    -- Core projectile
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, 8, 8, Color(255, 255, 255, 255))
    
    -- Sonic boom effect
    render.DrawSprite(pos, 24, 24, Color(200, 200, 255, 100))
end

function ENT:Think()
    -- Add dynamic lighting
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        local projectileType = self:GetProjectileType()
        
        dlight.pos = self:GetPos()
        dlight.r = 100
        dlight.g = 200
        dlight.b = 255
        dlight.brightness = 2
        dlight.decay = 1000
        dlight.size = 128
        dlight.dietime = CurTime() + 0.1
        
        if projectileType == "plasma_bolt" then
            dlight.r = 255
            dlight.g = 150
            dlight.b = 100
        elseif projectileType == "torpedo" then
            dlight.r = 255
            dlight.g = 255
            dlight.b = 100
        elseif projectileType == "railgun_slug" then
            dlight.r = 200
            dlight.g = 200
            dlight.b = 255
            dlight.brightness = 3
        end
    end
    
    -- Create particle effects
    self:CreateParticleEffects()
end

function ENT:CreateParticleEffects()
    local projectileType = self:GetProjectileType()
    local pos = self:GetPos()
    
    if projectileType == "energy_pulse" then
        -- Energy sparks
        if math.random() < 0.3 then
            local spark = EffectData()
            spark:SetOrigin(pos + VectorRand() * 10)
            spark:SetScale(0.2)
            util.Effect("BlueFlash", spark)
        end
        
    elseif projectileType == "plasma_bolt" then
        -- Plasma particles
        if math.random() < 0.5 then
            local plasma = EffectData()
            plasma:SetOrigin(pos + VectorRand() * 15)
            plasma:SetScale(0.3)
            util.Effect("Explosion", plasma)
        end
        
    elseif projectileType == "torpedo" then
        -- Exhaust trail
        if math.random() < 0.8 then
            local exhaust = EffectData()
            exhaust:SetOrigin(pos - self:GetForward() * 20 + VectorRand() * 8)
            exhaust:SetScale(0.4)
            util.Effect("BlueFlash", exhaust)
        end
        
    elseif projectileType == "railgun_slug" then
        -- Electromagnetic distortion
        if math.random() < 0.4 then
            local distortion = EffectData()
            distortion:SetOrigin(pos + VectorRand() * 20)
            distortion:SetScale(0.1)
            util.Effect("Sparks", distortion)
        end
    end
end
