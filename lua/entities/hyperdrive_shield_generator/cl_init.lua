include("shared.lua")

-- Client-side shield generator
function ENT:Initialize()
    -- Visual effects
    self.NextEffectTime = 0
    self.ShieldActive = false
end

function ENT:Draw()
    self:DrawModel()

    -- Draw shield status indicator
    if self.ShieldActive then
        self:DrawShieldIndicator()
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
end

function ENT:CreateShieldEffects()
    local pos = self:GetPos()

    -- Energy particles
    local effectData = EffectData()
    effectData:SetOrigin(pos + Vector(0, 0, 10))
    effectData:SetScale(1)
    util.Effect("BlueFlash", effectData)
end

-- Network message handling
net.Receive("HyperdriveShieldStatus", function()
    local ent = net.ReadEntity()
    local active = net.ReadBool()

    if IsValid(ent) and ent.SetShieldActive then
        ent.ShieldActive = active
    end
end)
