-- Advanced Space Combat - Railgun Client

include("shared.lua")

function ENT:Draw()
    self:DrawModel()
    
    -- Draw charging indicator
    if self:GetNWBool("Charging") then
        local pos = self:GetPos() + self:GetUp() * 25
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang.Forward, 90)
        ang:RotateAroundAxis(ang.Right, 90)
        
        cam.Start3D2D(pos, ang, 0.1)
            draw.SimpleText("CHARGING", "DermaDefault", 0, 0, Color(255, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    elseif self:GetNWBool("AutoFire") then
        local pos = self:GetPos() + self:GetUp() * 25
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang.Forward, 90)
        ang:RotateAroundAxis(ang.Right, 90)
        
        cam.Start3D2D(pos, ang, 0.1)
            draw.SimpleText("AUTO", "DermaDefault", 0, 0, Color(0, 255, 0), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end

function ENT:GetOverlayText()
    local text = "ASC Railgun\n"
    text = text .. "Health: " .. self:Health() .. "/250\n"
    text = text .. "Auto-fire: " .. (self:GetNWBool("AutoFire") and "ON" or "OFF") .. "\n"
    text = text .. "Status: " .. (self:GetNWBool("Charging") and "CHARGING" or "READY")
    return text
end
