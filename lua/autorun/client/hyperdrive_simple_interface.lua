-- Hyperdrive Simple Interface - Client Side
-- This file provides a simple, clean interface for hyperdrive engines

if SERVER then return end

-- Simple interface system
local simpleInterface = {
    entity = nil,
    visible = false,
    lastUpdate = 0,
    panelWidth = 400,
    panelHeight = 300
}

-- Create simple interface
function simpleInterface:Create(entity)
    if not IsValid(entity) then return end

    self.entity = entity
    self.visible = true
    gui.EnableScreenClicker(true)
end

-- Close simple interface
function simpleInterface:Close()
    self.visible = false
    self.entity = nil
    gui.EnableScreenClicker(false)
end

-- Draw simple interface
function simpleInterface:Draw()
    if not self.visible or not IsValid(self.entity) then return end

    local scrW, scrH = ScrW(), ScrH()
    local x = (scrW - self.panelWidth) / 2
    local y = (scrH - self.panelHeight) / 2

    -- Background
    draw.RoundedBox(8, x, y, self.panelWidth, self.panelHeight, Color(20, 20, 20, 240))
    draw.RoundedBox(8, x + 2, y + 2, self.panelWidth - 4, self.panelHeight - 4, Color(40, 40, 60, 220))

    -- Title
    local title = "Hyperdrive Engine"
    if self.entity.GetClass then
        local class = self.entity:GetClass()
        if class == "hyperdrive_master_engine" then
            title = "Master Hyperdrive Engine"
        elseif class == "hyperdrive_sb_engine" then
            title = "Spacebuild Hyperdrive Engine"
        elseif class == "hyperdrive_sg_engine" then
            title = "Stargate Hyperdrive Engine"
        end
    end

    draw.SimpleText(title, "DermaLarge", x + self.panelWidth/2, y + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER)

    -- Energy status
    local energy = 0
    local maxEnergy = 1000
    local energyPercent = 0

    if self.entity.GetEnergy and self.entity.GetEnergyPercent then
        energy = self.entity:GetEnergy()
        energyPercent = self.entity:GetEnergyPercent()
    end

    draw.SimpleText("Energy: " .. math.floor(energy) .. " EU (" .. math.floor(energyPercent) .. "%)",
                   "DermaDefault", x + 20, y + 60, Color(255, 255, 255))

    -- Energy bar
    local barX = x + 20
    local barY = y + 80
    local barW = self.panelWidth - 40
    local barH = 20

    draw.RoundedBox(4, barX, barY, barW, barH, Color(50, 50, 50))
    if energyPercent > 0 then
        local fillW = (barW - 4) * (energyPercent / 100)
        local barColor = Color(0, 255, 0)
        if energyPercent < 25 then
            barColor = Color(255, 0, 0)
        elseif energyPercent < 50 then
            barColor = Color(255, 255, 0)
        end
        draw.RoundedBox(2, barX + 2, barY + 2, fillW, barH - 4, barColor)
    end

    -- Status
    local status = "Ready"
    local statusColor = Color(0, 255, 0)

    if self.entity.GetCharging and self.entity:GetCharging() then
        status = "CHARGING..."
        statusColor = Color(255, 255, 0)
    elseif self.entity.IsOnCooldown and self.entity:IsOnCooldown() then
        local remaining = 0
        if self.entity.GetCooldownRemaining then
            remaining = self.entity:GetCooldownRemaining()
        end
        status = "Cooldown: " .. string.format("%.1fs", remaining)
        statusColor = Color(255, 100, 0)
    elseif self.entity.GetDestination and self.entity:GetDestination() == Vector(0, 0, 0) then
        status = "No Destination Set"
        statusColor = Color(255, 0, 0)
    elseif energyPercent < 10 then
        status = "Low Energy"
        statusColor = Color(255, 0, 0)
    end

    draw.SimpleText("Status: " .. status, "DermaDefault", x + 20, y + 110, statusColor)

    -- Destination
    local destination = Vector(0, 0, 0)
    if self.entity.GetDestination then
        destination = self.entity:GetDestination()
    end

    if destination ~= Vector(0, 0, 0) then
        local destText = string.format("Destination: %.0f, %.0f, %.0f", destination.x, destination.y, destination.z)
        draw.SimpleText(destText, "DermaDefault", x + 20, y + 130, Color(200, 200, 255))

        -- Distance
        local distance = self.entity:GetPos():Distance(destination)
        draw.SimpleText("Distance: " .. string.format("%.0f units", distance), "DermaDefault", x + 20, y + 150, Color(200, 200, 200))
    else
        draw.SimpleText("No destination set", "DermaDefault", x + 20, y + 130, Color(255, 100, 100))
    end

    -- Instructions
    draw.SimpleText("Instructions:", "DermaDefaultBold", x + 20, y + 180, Color(255, 255, 255))
    draw.SimpleText("• Look at destination and press 'Set Dest'", "DermaDefault", x + 20, y + 200, Color(200, 200, 200))
    draw.SimpleText("• Press 'Jump' when ready", "DermaDefault", x + 20, y + 215, Color(200, 200, 200))
    draw.SimpleText("• Energy recharges automatically", "DermaDefault", x + 20, y + 230, Color(200, 200, 200))

    -- Buttons
    self:DrawButton("Set Dest", x + 20, y + 250, 80, 25, function()
        self:SetDestination()
    end)

    self:DrawButton("Jump", x + 110, y + 250, 80, 25, function()
        self:StartJump()
    end)

    self:DrawButton("Close", x + self.panelWidth - 80, y + 250, 60, 25, function()
        self:Close()
    end)
end

-- Draw button helper
function simpleInterface:DrawButton(text, x, y, w, h, onClick)
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    local isHovered = mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h

    local bgColor = isHovered and Color(80, 80, 120) or Color(60, 60, 80)
    local textColor = isHovered and Color(255, 255, 255) or Color(200, 200, 200)

    draw.RoundedBox(4, x, y, w, h, bgColor)
    draw.SimpleText(text, "DermaDefault", x + w/2, y + h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Handle click
    if isHovered and input.IsMouseDown(MOUSE_LEFT) and CurTime() - self.lastUpdate > 0.2 then
        self.lastUpdate = CurTime()
        if onClick then onClick() end
    end
end

-- Set destination function
function simpleInterface:SetDestination()
    if not IsValid(self.entity) then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not trace.Hit or trace.HitSky then
        ply:ChatPrint("[Hyperdrive] Invalid destination - look at a solid surface")
        return
    end

    -- Send destination to server
    net.Start("hyperdrive_set_destination")
    net.WriteEntity(self.entity)
    net.WriteVector(trace.HitPos + trace.HitNormal * 100)
    net.SendToServer()

    ply:ChatPrint("[Hyperdrive] Destination set")
end

-- Start jump function
function simpleInterface:StartJump()
    if not IsValid(self.entity) then return end

    local class = self.entity:GetClass()

    -- Use appropriate jump method based on engine type
    if class == "hyperdrive_master_engine" then
        -- Master engine uses its own jump method
        net.Start("hyperdrive_start_jump")
        net.WriteEntity(self.entity)
        net.SendToServer()
    else
        -- Standard engines use regular jump
        net.Start("hyperdrive_start_jump")
        net.WriteEntity(self.entity)
        net.SendToServer()
    end
end

-- Network message handlers
net.Receive("hyperdrive_open_interface", function()
    local entity = net.ReadEntity()
    if IsValid(entity) then
        simpleInterface:Create(entity)
    end
end)

-- Hook for drawing
hook.Add("HUDPaint", "HyperdriveSimpleInterface", function()
    simpleInterface:Draw()
end)

-- Close interface on escape
hook.Add("OnPlayerChat", "HyperdriveCloseInterface", function(ply, text)
    if ply == LocalPlayer() and string.lower(text) == "!close" then
        simpleInterface:Close()
        return true
    end
end)

-- Close interface when entity is removed
hook.Add("EntityRemoved", "HyperdriveInterfaceCleanup", function(ent)
    if simpleInterface.entity == ent then
        simpleInterface:Close()
    end
end)

print("[Hyperdrive] Simple interface loaded")
