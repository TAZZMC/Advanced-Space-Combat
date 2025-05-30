-- Hyperdrive Engine - Client-side code

include("shared.lua")

function ENT:Initialize()
    -- Client-side initialization
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw energy indicator
    local energy = self:GetEnergy()
    local maxEnergy = 1000
    local energyPercent = energy / maxEnergy
    
    local pos = self:GetPos() + self:GetUp() * 20
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Background
        draw.RoundedBox(4, -100, -30, 200, 60, Color(0, 0, 0, 200))
        
        -- Energy bar
        local barWidth = 180
        local barHeight = 20
        local barX = -90
        local barY = -10
        
        -- Background bar
        draw.RoundedBox(2, barX, barY, barWidth, barHeight, Color(50, 50, 50, 255))
        
        -- Energy fill
        local fillWidth = barWidth * energyPercent
        local energyColor = Color(0, 255, 0, 255)
        if energyPercent < 0.3 then
            energyColor = Color(255, 0, 0, 255)
        elseif energyPercent < 0.7 then
            energyColor = Color(255, 255, 0, 255)
        end
        
        draw.RoundedBox(2, barX, barY, fillWidth, barHeight, energyColor)
        
        -- Text
        draw.SimpleText("Energy: " .. math.Round(energy) .. "/" .. maxEnergy, "DermaDefault", 0, -25, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
        
        -- Status
        local status = "Idle"
        if self:GetCharging() then
            status = "Charging"
        elseif self:GetJumpReady() then
            status = "Ready"
        elseif self:GetCooldown() > 0 then
            status = "Cooldown: " .. math.Round(self:GetCooldown(), 1) .. "s"
        end
        
        draw.SimpleText(status, "DermaDefault", 0, 15, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:Think()
    -- Client-side thinking
end
