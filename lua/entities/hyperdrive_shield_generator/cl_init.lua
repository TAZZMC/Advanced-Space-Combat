include("shared.lua")

-- Client-side shield generator
function ENT:Initialize()
    -- Visual effects
    self.NextEffectTime = 0
    self.ShieldActive = false
    self.lastEffectTime = 0
    self.pulseTime = 0
end

function ENT:Draw()
    self:DrawModel()

    -- Apply dynamic material based on shield state
    if self.ShieldActive then
        self:SetMaterial("hyperdrive/shield_generator")
        self:SetColor(Color(100, 150, 255, 255))

        -- Pulsing effect when active
        self.pulseTime = self.pulseTime + FrameTime() * 2
        local pulse = math.sin(self.pulseTime) * 0.3 + 0.7

        -- Enhanced shield generator glow
        local pos = self:GetPos()
        local size = 24 * pulse

        render.SetMaterial(Material("hyperdrive/energy_field"))
        render.DrawSprite(pos + Vector(0, 0, 20), size, size, Color(100, 150, 255, 150 * pulse))

        -- Outer energy field
        render.DrawSprite(pos + Vector(0, 0, 20), size * 1.5, size * 1.5, Color(80, 120, 200, 80 * pulse))

        -- Draw shield status indicator
        self:DrawShieldIndicator()
    else
        self:SetMaterial("")
        self:SetColor(Color(255, 255, 255, 255))
    end
end

function ENT:DrawShieldIndicator()
    local pos = self:GetPos() + self:GetUp() * 20
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang.Forward(), 90)
    ang:RotateAroundAxis(ang.Right(), 90)

    cam.Start3D2D(pos, ang, 0.1)
        draw.SimpleText("SHIELD ACTIVE", "DermaDefault", 0, 0, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:Think()
    -- Add shield energy effects when active
    if self.ShieldActive and CurTime() > self.NextEffectTime then
        self:CreateShieldEffects()
        self.NextEffectTime = CurTime() + 2
    end

    -- Create shield activation effect periodically when active
    if self.ShieldActive and CurTime() - self.lastEffectTime > 8 then
        self.lastEffectTime = CurTime()

        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetEntity(self)
        effectData:SetScale(1)
        effectData:SetMagnitude(1)
        util.Effect("shield_activation", effectData)
    end
end

function ENT:CreateShieldEffects()
    local pos = self:GetPos()

    -- Enhanced energy particles
    local effectData = EffectData()
    effectData:SetOrigin(pos + Vector(0, 0, 10))
    effectData:SetScale(1)
    effectData:SetMagnitude(1)
    util.Effect("BlueFlash", effectData)

    -- Additional shield energy effect
    effectData:SetOrigin(pos + Vector(0, 0, 15))
    effectData:SetScale(0.8)
    util.Effect("ship_core_glow", effectData)
end

-- Network message handling
net.Receive("HyperdriveShieldStatus", function()
    local ent = net.ReadEntity()
    local active = net.ReadBool()

    if IsValid(ent) and ent.SetShieldActive then
        ent.ShieldActive = active
    end
end)
