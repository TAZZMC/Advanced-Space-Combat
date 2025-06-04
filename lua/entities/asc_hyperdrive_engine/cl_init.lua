-- Advanced Space Combat - Hyperdrive Engine Entity v5.1.0
-- Client-side hyperdrive engine functionality

include("shared.lua")

-- Initialize client
function ENT:Initialize()
    -- Set up rendering
    self:SetRenderBounds(Vector(-50, -50, -50), Vector(50, 50, 50))
    
    -- Initialize effects
    self.NextEffectTime = 0
    self.GlowSprite = nil
end

-- Draw function
function ENT:Draw()
    self:DrawModel()
    
    -- Draw status effects
    if self:GetActive() then
        self:DrawActiveEffects()
    end
    
    if self:GetCharging() then
        self:DrawChargingEffects()
    end
end

-- Draw active effects
function ENT:DrawActiveEffects()
    local pos = self:GetPos()
    local time = CurTime()
    
    -- Glowing effect
    if time > self.NextEffectTime then
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetMagnitude(1)
        effectdata:SetScale(0.5)
        util.Effect("hyperdrive_glow", effectdata)
        
        self.NextEffectTime = time + 0.5
    end
    
    -- Energy particles
    if math.random() < 0.3 then
        local effectdata = EffectData()
        effectdata:SetOrigin(pos + VectorRand() * 20)
        effectdata:SetNormal(Vector(0, 0, 1))
        effectdata:SetMagnitude(2)
        effectdata:SetScale(1)
        util.Effect("hyperdrive_energy", effectdata)
    end
end

-- Draw charging effects
function ENT:DrawChargingEffects()
    local pos = self:GetPos()
    local chargeLevel = self:GetChargeLevel()
    
    -- Charging sparks
    if math.random() < (chargeLevel / 100) then
        local effectdata = EffectData()
        effectdata:SetOrigin(pos + VectorRand() * 30)
        effectdata:SetMagnitude(chargeLevel / 20)
        effectdata:SetScale(0.5)
        util.Effect("hyperdrive_spark", effectdata)
    end
    
    -- Energy buildup
    if chargeLevel > 50 then
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetMagnitude(chargeLevel / 100)
        effectdata:SetScale(2)
        util.Effect("hyperdrive_buildup", effectdata)
    end
end

-- Think function
function ENT:Think()
    -- Update effects based on state
    if self:GetActive() and not self.ActiveSound then
        self.ActiveSound = CreateSound(self, "ambient/energy/weld1.wav")
        if self.ActiveSound then
            self.ActiveSound:Play()
        end
    elseif not self:GetActive() and self.ActiveSound then
        self.ActiveSound:Stop()
        self.ActiveSound = nil
    end
    
    if self:GetCharging() and not self.ChargingSound then
        self.ChargingSound = CreateSound(self, "ambient/energy/electric_loop.wav")
        if self.ChargingSound then
            self.ChargingSound:Play()
        end
    elseif not self:GetCharging() and self.ChargingSound then
        self.ChargingSound:Stop()
        self.ChargingSound = nil
    end
end

-- Remove function
function ENT:OnRemove()
    if self.ActiveSound then
        self.ActiveSound:Stop()
    end
    if self.ChargingSound then
        self.ChargingSound:Stop()
    end
end

-- Get status color
function ENT:GetStatusColor()
    if not self:GetActive() then
        return Color(100, 100, 100)
    elseif self:GetCharging() then
        return Color(255, 255, 0)
    elseif self:GetChargeLevel() >= 100 then
        return Color(0, 255, 0)
    else
        return Color(0, 150, 255)
    end
end
