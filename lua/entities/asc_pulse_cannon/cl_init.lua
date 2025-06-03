-- Advanced Space Combat - Pulse Cannon Client

include("shared.lua")

-- Client-side rendering
function ENT:Draw()
    self:DrawModel()
    
    -- Draw energy indicator
    if self:GetNWBool("AutoFire") then
        local pos = self:GetPos() + self:GetUp() * 20
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang.Forward, 90)
        ang:RotateAroundAxis(ang.Right, 90)
        
        cam.Start3D2D(pos, ang, 0.1)
            draw.SimpleText("AUTO", "DermaDefault", 0, 0, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end

-- HUD information
function ENT:GetOverlayText()
    local text = "ASC Pulse Cannon\n"
    text = text .. "Health: " .. self:Health() .. "/200\n"
    text = text .. "Auto-fire: " .. (self:GetNWBool("AutoFire") and "ON" or "OFF")
    return text
end
