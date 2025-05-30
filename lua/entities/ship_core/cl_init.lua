-- Ship Core Entity - Client
-- Mandatory ship core for Enhanced Hyperdrive System v2.0

include("shared.lua")

-- UI variables
local shipCoreUI = {
    visible = false,
    entity = nil,
    data = {},
    panelWidth = 800,
    panelHeight = 700,
    lastUpdate = 0,
    currentTab = "overview" -- overview, resources, systems
}

function ENT:Initialize()
    self.nextParticle = 0
    self.glowIntensity = 0
    self.pulseTime = 0
end

function ENT:Draw()
    self:DrawModel()

    -- Draw glow effect based on state
    local state = self:GetState()
    local color = self:GetStateColor()

    -- Pulse effect for critical states
    if state == self.States.EMERGENCY or state == self.States.CRITICAL then
        self.pulseTime = self.pulseTime + FrameTime() * 3
        self.glowIntensity = math.abs(math.sin(self.pulseTime)) * 0.8 + 0.2
    else
        self.glowIntensity = 0.5
    end

    -- Draw glow
    local pos = self:GetPos()
    local size = 32 * self.glowIntensity

    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, size, size, color)

    -- Draw status text above core
    self:DrawStatusText()
end

function ENT:DrawStatusText()
    local pos = self:GetPos() + Vector(0, 0, 20)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    -- Check if ship name should be shown above core
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.ShipNaming or {}
    local showNameAboveCore = config.ShowNameAboveCore ~= false

    cam.Start3D2D(pos, ang, 0.1)
        -- Background (adjust height based on whether ship name is shown)
        local bgHeight = showNameAboveCore and 90 or 60
        local bgY = showNameAboveCore and -45 or -30
        draw.RoundedBox(8, -120, bgY, 240, bgHeight, Color(0, 0, 0, 150))

        local textY = bgY + 10

        -- Ship name (if enabled)
        if showNameAboveCore then
            local shipName = self:GetShipName() or (config.DefaultShipName or "Unnamed Ship")
            draw.SimpleText(shipName, "DermaDefaultBold", 0, textY, Color(100, 200, 255), TEXT_ALIGN_CENTER)
            textY = textY + 15
        end

        -- Core status
        local stateName = self:GetStateName()
        local stateColor = self:GetStateColor()
        draw.SimpleText("SHIP CORE", "DermaDefaultBold", 0, textY, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        textY = textY + 15
        draw.SimpleText(stateName, "DermaDefault", 0, textY, stateColor, TEXT_ALIGN_CENTER)
        textY = textY + 20

        -- Hull and shield status
        if self:GetHullSystemActive() then
            local hullColor = self:GetHullColor()
            draw.SimpleText("Hull: " .. self:GetHullIntegrity() .. "%", "DermaDefault", -50, textY, hullColor, TEXT_ALIGN_CENTER)
        end

        if self:GetShieldSystemActive() then
            local shieldColor = self:GetShieldColor()
            draw.SimpleText("Shield: " .. self:GetShieldStrength() .. "%", "DermaDefault", 50, textY, shieldColor, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

-- UI Functions
function shipCoreUI:Open(entity, data)
    self.visible = true
    self.entity = entity
    self.data = data or {}
    gui.EnableScreenClicker(true)

    print("[Ship Core UI] Interface opened")
end

function shipCoreUI:Close()
    self.visible = false
    self.entity = nil
    self.data = {}
    gui.EnableScreenClicker(false)

    -- Send close command to server
    if IsValid(self.entity) then
        net.Start("ship_core_command")
        net.WriteEntity(self.entity)
        net.WriteString("close_ui")
        net.WriteTable({})
        net.SendToServer()
    end

    print("[Ship Core UI] Interface closed")
end

function shipCoreUI:Update(data)
    self.data = data or {}
    self.lastUpdate = CurTime()
end

function shipCoreUI:Draw()
    if not self.visible or not IsValid(self.entity) then return end

    -- Update data from network variables
    self:UpdateData()

    local scrW, scrH = ScrW(), ScrH()
    local x = (scrW - self.panelWidth) / 2
    local y = (scrH - self.panelHeight) / 2

    -- Main background
    draw.RoundedBox(8, x, y, self.panelWidth, self.panelHeight, Color(20, 20, 30, 240))
    draw.RoundedBox(8, x + 2, y + 2, self.panelWidth - 4, self.panelHeight - 4, Color(40, 40, 60, 220))

    -- Title bar
    local titleColor = Color(100, 150, 255)
    if self.data.coreState == ENT.States.EMERGENCY then
        titleColor = Color(255, 100, 100)
    elseif self.data.coreState == ENT.States.CRITICAL then
        titleColor = Color(255, 150, 100)
    elseif self.data.coreState == ENT.States.INVALID then
        titleColor = Color(255, 255, 100)
    end

    draw.RoundedBox(8, x + 10, y + 10, self.panelWidth - 20, 40, titleColor)
    draw.SimpleText("SHIP CORE MANAGEMENT SYSTEM", "DermaDefaultBold", x + self.panelWidth/2, y + 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Tab navigation
    self:DrawTabs(x + 10, y + 60)

    -- Content area based on current tab
    local contentY = y + 100
    if self.currentTab == "overview" then
        self:DrawOverviewTab(x + 20, contentY)
    elseif self.currentTab == "resources" then
        self:DrawResourcesTab(x + 20, contentY)
    elseif self.currentTab == "systems" then
        self:DrawSystemsTab(x + 20, contentY)
    elseif self.currentTab == "cap" then
        self:DrawCAPTab(x + 20, contentY)
    end

    -- Close button
    self:DrawButton("CLOSE", x + self.panelWidth - 80, y + 10, 70, 30, Color(150, 50, 50), function()
        self:Close()
    end)
end

function shipCoreUI:DrawTabs(x, y)
    local tabWidth = 120
    local tabHeight = 30
    local tabs = {
        {name = "OVERVIEW", id = "overview"},
        {name = "RESOURCES", id = "resources"},
        {name = "SYSTEMS", id = "systems"}
    }

    -- Add CAP tab if CAP integration is active
    if self.data.capIntegrationActive then
        table.insert(tabs, {name = "CAP", id = "cap"})
    end

    for i, tab in ipairs(tabs) do
        local tabX = x + (i - 1) * (tabWidth + 5)
        local isActive = self.currentTab == tab.id

        local bgColor = isActive and Color(100, 150, 255) or Color(60, 60, 80)
        local textColor = isActive and Color(255, 255, 255) or Color(200, 200, 200)

        -- Highlight resource tab if emergency mode
        if tab.id == "resources" and self.data.resourceEmergencyMode then
            bgColor = Color(255, 100, 100)
            textColor = Color(255, 255, 255)
        end

        self:DrawButton(tab.name, tabX, y, tabWidth, tabHeight, bgColor, function()
            self.currentTab = tab.id
        end, textColor)
    end
end

function shipCoreUI:DrawOverviewTab(x, y)
    -- Core status section
    self:DrawCoreStatus(x, y)

    -- Ship information section
    self:DrawShipInfo(x, y + 120)

    -- Quick status indicators
    self:DrawQuickStatus(x, y + 220)

    -- Control buttons
    self:DrawControlButtons(x, y + 320)
end

function shipCoreUI:DrawResourcesTab(x, y)
    -- Resource system header
    draw.SimpleText("SPACEBUILD 3 RESOURCE MANAGEMENT", "DermaDefaultBold", x, y, Color(255, 255, 255))

    if not self.data.resourceSystemActive then
        draw.SimpleText("Resource system not available", "DermaDefault", x, y + 25, Color(255, 100, 100))
        draw.SimpleText("Spacebuild 3 integration required", "DermaDefault", x, y + 40, Color(200, 200, 200))
        return
    end

    -- Emergency mode warning
    if self.data.resourceEmergencyMode then
        draw.RoundedBox(4, x, y + 25, self.panelWidth - 40, 30, Color(255, 100, 100, 150))
        draw.SimpleText("EMERGENCY MODE ACTIVE - CRITICAL RESOURCE LEVELS", "DermaDefaultBold", x + 10, y + 40, Color(255, 255, 255))
        y = y + 60
    end

    -- Resource displays
    self:DrawResourceBars(x, y + 30)

    -- Resource controls
    self:DrawResourceControls(x, y + 280)

    -- Resource status and alerts
    self:DrawResourceStatus(x, y + 380)
end

function shipCoreUI:DrawSystemsTab(x, y)
    -- Hull damage section
    self:DrawHullStatus(x, y)

    -- Shield system section
    self:DrawShieldStatus(x + 380, y)

    -- System controls
    self:DrawSystemControls(x, y + 200)
end

function shipCoreUI:DrawCoreStatus(x, y)
    -- Core status header
    draw.SimpleText("CORE STATUS", "DermaDefaultBold", x, y, Color(255, 255, 255))

    -- Status information
    local stateColor = Color(100, 100, 100)
    if self.data.coreState == ENT.States.ACTIVE then stateColor = Color(100, 255, 100)
    elseif self.data.coreState == ENT.States.CRITICAL then stateColor = Color(255, 150, 100)
    elseif self.data.coreState == ENT.States.EMERGENCY then stateColor = Color(255, 100, 100)
    elseif self.data.coreState == ENT.States.INVALID then stateColor = Color(255, 255, 100)
    end

    draw.SimpleText("State: " .. (self.data.coreStateName or "Unknown"), "DermaDefault", x, y + 20, stateColor)
    draw.SimpleText("Valid: " .. (self.data.coreValid and "YES" or "NO"), "DermaDefault", x, y + 35, self.data.coreValid and Color(100, 255, 100) or Color(255, 100, 100))
    draw.SimpleText("Status: " .. (self.data.statusMessage or "Unknown"), "DermaDefault", x, y + 50, Color(200, 200, 200))

    -- Position information
    if self.data.corePos then
        local pos = self.data.corePos
        draw.SimpleText("Position: " .. math.floor(pos.x) .. ", " .. math.floor(pos.y) .. ", " .. math.floor(pos.z), "DermaDefault", x, y + 65, Color(150, 150, 150))
    end
end

function shipCoreUI:DrawResourceBars(x, y)
    local resources = {
        {name = "Energy", key = "resourceEnergy", color = Color(100, 255, 100), unit = "kW"},
        {name = "Oxygen", key = "resourceOxygen", color = Color(100, 200, 255), unit = "L"},
        {name = "Coolant", key = "resourceCoolant", color = Color(100, 255, 255), unit = "L"},
        {name = "Fuel", key = "resourceFuel", color = Color(255, 200, 100), unit = "L"},
        {name = "Water", key = "resourceWater", color = Color(150, 150, 255), unit = "L"},
        {name = "Nitrogen", key = "resourceNitrogen", color = Color(200, 100, 255), unit = "L"}
    }

    local barWidth = 350
    local barHeight = 25
    local spacing = 35

    for i, resource in ipairs(resources) do
        local barY = y + (i - 1) * spacing
        local percentage = self.data[resource.key] or 0

        -- Resource name
        draw.SimpleText(resource.name, "DermaDefaultBold", x, barY, Color(255, 255, 255))

        -- Background bar
        draw.RoundedBox(4, x + 80, barY, barWidth, barHeight, Color(40, 40, 40))

        -- Fill bar with color based on percentage
        local fillColor = resource.color
        if percentage < 10 then
            fillColor = Color(255, 100, 100) -- Critical
        elseif percentage < 25 then
            fillColor = Color(255, 150, 100) -- Warning
        elseif percentage < 50 then
            fillColor = Color(255, 255, 100) -- Caution
        end

        local fillWidth = (barWidth - 4) * (percentage / 100)
        if fillWidth > 0 then
            draw.RoundedBox(2, x + 82, barY + 2, fillWidth, barHeight - 4, fillColor)
        end

        -- Percentage text
        local textColor = percentage < 25 and Color(255, 255, 255) or Color(0, 0, 0)
        draw.SimpleText(string.format("%.1f%%", percentage), "DermaDefault", x + 80 + barWidth/2, barY + barHeight/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Status indicator
        local statusText = "NORMAL"
        local statusColor = Color(100, 255, 100)
        if percentage < 10 then
            statusText = "CRITICAL"
            statusColor = Color(255, 100, 100)
        elseif percentage < 25 then
            statusText = "LOW"
            statusColor = Color(255, 150, 100)
        elseif percentage < 50 then
            statusText = "CAUTION"
            statusColor = Color(255, 255, 100)
        end

        draw.SimpleText(statusText, "DermaDefault", x + 450, barY + barHeight/2, statusColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

function shipCoreUI:DrawResourceControls(x, y)
    draw.SimpleText("RESOURCE CONTROLS", "DermaDefaultBold", x, y, Color(255, 255, 255))

    local buttonY = y + 25
    local buttonSpacing = 110

    -- Resource management buttons
    self:DrawButton("DISTRIBUTE", x, buttonY, 100, 25, Color(100, 150, 100), function()
        self:SendCommand("resource_distribute", {})
    end)

    self:DrawButton("COLLECT", x + buttonSpacing, buttonY, 100, 25, Color(100, 100, 150), function()
        self:SendCommand("resource_collect", {})
    end)

    self:DrawButton("BALANCE", x + buttonSpacing * 2, buttonY, 100, 25, Color(150, 100, 150), function()
        self:SendCommand("resource_balance", {})
    end)

    self:DrawButton("STATUS", x + buttonSpacing * 3, buttonY, 100, 25, Color(150, 150, 100), function()
        self:SendCommand("resource_status", {})
    end)

    -- Auto-provision settings
    buttonY = buttonY + 40
    draw.SimpleText("AUTO-PROVISION SETTINGS", "DermaDefault", x, buttonY, Color(200, 200, 200))

    buttonY = buttonY + 20
    local autoProvisionEnabled = self.data.autoProvisionEnabled ~= false -- Default to true
    local autoProvisionColor = autoProvisionEnabled and Color(100, 255, 100) or Color(150, 150, 150)
    local autoProvisionText = autoProvisionEnabled and "AUTO-PROVISION: ON" or "AUTO-PROVISION: OFF"

    self:DrawButton(autoProvisionText, x, buttonY, 180, 25, autoProvisionColor, function()
        self:SendCommand("toggle_auto_provision", {})
    end)

    -- Weld detection settings
    local weldDetectionEnabled = self.data.weldDetectionEnabled ~= false -- Default to true
    local weldDetectionColor = weldDetectionEnabled and Color(100, 255, 100) or Color(150, 150, 150)
    local weldDetectionText = weldDetectionEnabled and "WELD DETECTION: ON" or "WELD DETECTION: OFF"

    self:DrawButton(weldDetectionText, x + 200, buttonY, 180, 25, weldDetectionColor, function()
        self:SendCommand("toggle_weld_detection", {})
    end)
end

function shipCoreUI:DrawResourceStatus(x, y)
    draw.SimpleText("RESOURCE SYSTEM STATUS", "DermaDefaultBold", x, y, Color(255, 255, 255))

    local statusY = y + 25

    -- System status
    local systemStatus = self.data.resourceSystemActive and "ACTIVE" or "INACTIVE"
    local systemColor = self.data.resourceSystemActive and Color(100, 255, 100) or Color(255, 100, 100)
    draw.SimpleText("System Status: " .. systemStatus, "DermaDefault", x, statusY, systemColor)

    -- Emergency mode
    if self.data.resourceEmergencyMode then
        draw.SimpleText("Emergency Mode: ACTIVE", "DermaDefault", x, statusY + 15, Color(255, 100, 100))
    else
        draw.SimpleText("Emergency Mode: INACTIVE", "DermaDefault", x, statusY + 15, Color(100, 255, 100))
    end

    -- Auto-provision status
    local autoProvisionStatus = self.data.autoProvisionEnabled ~= false and "ENABLED" or "DISABLED"
    local autoProvisionColor = self.data.autoProvisionEnabled ~= false and Color(100, 255, 100) or Color(150, 150, 150)
    draw.SimpleText("Auto-Provision: " .. autoProvisionStatus, "DermaDefault", x, statusY + 30, autoProvisionColor)

    -- Weld detection status
    local weldDetectionStatus = self.data.weldDetectionEnabled ~= false and "ENABLED" or "DISABLED"
    local weldDetectionColor = self.data.weldDetectionEnabled ~= false and Color(100, 255, 100) or Color(150, 150, 150)
    draw.SimpleText("Weld Detection: " .. weldDetectionStatus, "DermaDefault", x, statusY + 45, weldDetectionColor)

    -- Recent activity
    if self.data.lastResourceActivity then
        draw.SimpleText("Last Activity: " .. self.data.lastResourceActivity, "DermaDefault", x, statusY + 60, Color(200, 200, 200))
    end
end

function shipCoreUI:DrawQuickStatus(x, y)
    draw.SimpleText("QUICK STATUS", "DermaDefaultBold", x, y, Color(255, 255, 255))

    local statusY = y + 20
    local col1X = x
    local col2X = x + 200
    local col3X = x + 400

    -- Core status
    local coreColor = Color(100, 255, 100)
    if self.data.coreState == ENT.States.EMERGENCY then coreColor = Color(255, 100, 100)
    elseif self.data.coreState == ENT.States.CRITICAL then coreColor = Color(255, 150, 100)
    elseif self.data.coreState == ENT.States.INVALID then coreColor = Color(255, 255, 100)
    end
    draw.SimpleText("Core: " .. (self.data.coreStateName or "Unknown"), "DermaDefault", col1X, statusY, coreColor)

    -- Hull status
    if self.data.hullSystemActive then
        local hullColor = Color(100, 255, 100)
        if self.data.hullIntegrity < 25 then hullColor = Color(255, 100, 100)
        elseif self.data.hullIntegrity < 50 then hullColor = Color(255, 150, 100)
        elseif self.data.hullIntegrity < 75 then hullColor = Color(255, 255, 100)
        end
        draw.SimpleText("Hull: " .. (self.data.hullIntegrity or 100) .. "%", "DermaDefault", col2X, statusY, hullColor)
    else
        draw.SimpleText("Hull: Inactive", "DermaDefault", col2X, statusY, Color(150, 150, 150))
    end

    -- Shield status
    if self.data.shieldSystemActive then
        local shieldColor = Color(100, 255, 100)
        if self.data.shieldStrength < 25 then shieldColor = Color(255, 100, 100)
        elseif self.data.shieldStrength < 50 then shieldColor = Color(255, 150, 100)
        elseif self.data.shieldStrength < 75 then shieldColor = Color(255, 255, 100)
        end
        draw.SimpleText("Shields: " .. (self.data.shieldStrength or 0) .. "%", "DermaDefault", col3X, statusY, shieldColor)
    else
        draw.SimpleText("Shields: Inactive", "DermaDefault", col3X, statusY, Color(150, 150, 150))
    end

    -- Resource status (second row)
    statusY = statusY + 20
    if self.data.resourceSystemActive then
        local resourceStatus = "Resources: "
        local resourceColor = Color(100, 255, 100)

        if self.data.resourceEmergencyMode then
            resourceStatus = resourceStatus .. "EMERGENCY"
            resourceColor = Color(255, 100, 100)
        else
            -- Check for low resources
            local lowResources = 0
            local resources = {"resourceEnergy", "resourceOxygen", "resourceCoolant", "resourceFuel", "resourceWater", "resourceNitrogen"}
            for _, res in ipairs(resources) do
                if (self.data[res] or 0) < 25 then
                    lowResources = lowResources + 1
                end
            end

            if lowResources > 0 then
                resourceStatus = resourceStatus .. lowResources .. " LOW"
                resourceColor = Color(255, 255, 100)
            else
                resourceStatus = resourceStatus .. "NORMAL"
            end
        end

        draw.SimpleText(resourceStatus, "DermaDefault", col1X, statusY, resourceColor)
    else
        draw.SimpleText("Resources: Inactive", "DermaDefault", col1X, statusY, Color(150, 150, 150))
    end

    -- Ship info
    if self.data.shipDetected then
        draw.SimpleText("Ship: " .. (self.data.entityCount or 0) .. " entities", "DermaDefault", col2X, statusY, Color(200, 200, 200))
        draw.SimpleText("Players: " .. (self.data.playerCount or 0), "DermaDefault", col3X, statusY, Color(200, 200, 200))
    else
        draw.SimpleText("Ship: Not detected", "DermaDefault", col2X, statusY, Color(255, 100, 100))
    end
end

function shipCoreUI:DrawSystemControls(x, y)
    draw.SimpleText("SYSTEM CONTROLS", "DermaDefaultBold", x, y, Color(255, 255, 255))

    local buttonY = y + 25
    local buttonSpacing = 110

    -- Hull system controls
    if self.data.hullSystemActive then
        self:DrawButton("REPAIR HULL", x, buttonY, 100, 25, Color(100, 150, 100), function()
            self:SendCommand("repair_hull", {amount = 25})
        end)

        if self.data.hullCriticalMode or self.data.hullEmergencyMode then
            self:DrawButton("EMERGENCY REPAIR", x + buttonSpacing, buttonY, 130, 25, Color(200, 100, 100), function()
                self:SendCommand("emergency_repair", {})
            end)
        end
    end

    -- Shield system controls
    if self.data.shieldSystemActive then
        local shieldButtonY = buttonY + 35
        if self.data.shieldActive then
            self:DrawButton("DEACTIVATE SHIELDS", x, shieldButtonY, 140, 25, Color(150, 100, 100), function()
                self:SendCommand("deactivate_shields", {})
            end)
        else
            self:DrawButton("ACTIVATE SHIELDS", x, shieldButtonY, 140, 25, Color(100, 150, 100), function()
                self:SendCommand("activate_shields", {})
            end)
        end
    end

    -- Ship controls
    if self.data.shipDetected then
        local shipButtonY = buttonY + 70
        self:DrawButton("SHIP INFO", x, shipButtonY, 100, 25, Color(100, 150, 150), function()
            self:SendCommand("ship_info", {})
        end)

        self:DrawButton("TOGGLE FRONT INDICATOR", x + buttonSpacing, shipButtonY, 170, 25, Color(100, 100, 150), function()
            self:SendCommand("toggle_front_indicator", {})
        end)
    end
end

function shipCoreUI:DrawShipInfo(x, y)
    -- Ship information header
    draw.SimpleText("SHIP INFORMATION", "DermaDefaultBold", x, y, Color(255, 255, 255))

    -- Ship name with edit button
    local shipName = self.data.shipName or "Unnamed Ship"
    draw.SimpleText("Name: " .. shipName, "DermaDefault", x, y + 20, Color(100, 200, 255))

    -- Edit name button
    self:DrawButton("EDIT NAME", x + 400, y + 17, 80, 20, Color(100, 100, 150), function()
        self:SendCommand("open_name_dialog", {})
    end)

    if self.data.shipDetected then
        draw.SimpleText("Ship Type: " .. (self.data.shipType or "Unknown"), "DermaDefault", x, y + 40, Color(100, 255, 100))
        draw.SimpleText("Entities: " .. (self.data.entityCount or 0), "DermaDefault", x, y + 55, Color(200, 200, 200))
        draw.SimpleText("Players: " .. (self.data.playerCount or 0), "DermaDefault", x + 150, y + 55, Color(200, 200, 200))
        draw.SimpleText("Mass: " .. math.floor(self.data.mass or 0), "DermaDefault", x + 250, y + 55, Color(200, 200, 200))

        -- Ship center and front direction
        if self.data.shipCenter then
            local center = self.data.shipCenter
            draw.SimpleText("Center: " .. math.floor(center.x) .. ", " .. math.floor(center.y) .. ", " .. math.floor(center.z), "DermaDefault", x, y + 70, Color(150, 150, 150))
        end
    else
        draw.SimpleText("No ship detected", "DermaDefault", x, y + 40, Color(255, 100, 100))
        draw.SimpleText("Place ship core on a ship structure", "DermaDefault", x, y + 55, Color(200, 200, 200))
    end
end

function shipCoreUI:DrawHullStatus(x, y)
    -- Hull status header
    draw.SimpleText("HULL DAMAGE SYSTEM", "DermaDefaultBold", x, y, Color(255, 255, 255))

    if self.data.hullSystemActive then
        local hullColor = Color(100, 255, 100)
        if self.data.hullIntegrity < 25 then hullColor = Color(255, 100, 100)
        elseif self.data.hullIntegrity < 50 then hullColor = Color(255, 150, 100)
        elseif self.data.hullIntegrity < 75 then hullColor = Color(255, 255, 100)
        end

        draw.SimpleText("Hull Integrity: " .. (self.data.hullIntegrity or 100) .. "%", "DermaDefault", x, y + 20, hullColor)
        draw.SimpleText("Breaches: " .. (self.data.hullBreaches or 0), "DermaDefault", x, y + 35, Color(200, 200, 200))
        draw.SimpleText("System Failures: " .. (self.data.hullSystemFailures or 0), "DermaDefault", x, y + 50, Color(200, 200, 200))
        draw.SimpleText("Auto-Repair: " .. (self.data.hullAutoRepair and "ACTIVE" or "INACTIVE"), "DermaDefault", x, y + 65, self.data.hullAutoRepair and Color(100, 255, 100) or Color(255, 100, 100))

        if self.data.hullCriticalMode then
            draw.SimpleText("CRITICAL HULL DAMAGE", "DermaDefaultBold", x, y + 80, Color(255, 100, 100))
        elseif self.data.hullEmergencyMode then
            draw.SimpleText("EMERGENCY HULL STATUS", "DermaDefaultBold", x, y + 80, Color(255, 50, 50))
        end
    else
        draw.SimpleText("Hull system inactive", "DermaDefault", x, y + 20, Color(150, 150, 150))
    end
end

function shipCoreUI:DrawShieldStatus(x, y)
    -- Shield status header
    draw.SimpleText("SHIELD SYSTEM", "DermaDefaultBold", x, y, Color(255, 255, 255))

    if self.data.shieldSystemActive then
        local shieldColor = Color(100, 255, 100)
        if self.data.shieldStrength < 25 then shieldColor = Color(255, 100, 100)
        elseif self.data.shieldStrength < 50 then shieldColor = Color(255, 150, 100)
        elseif self.data.shieldStrength < 75 then shieldColor = Color(255, 255, 100)
        end

        draw.SimpleText("Shield Strength: " .. (self.data.shieldStrength or 0) .. "%", "DermaDefault", x, y + 20, shieldColor)
        draw.SimpleText("Status: " .. (self.data.shieldActive and "ACTIVE" or "INACTIVE"), "DermaDefault", x, y + 35, self.data.shieldActive and Color(100, 255, 100) or Color(255, 100, 100))
        draw.SimpleText("Type: " .. (self.data.shieldType or "None"), "DermaDefault", x, y + 50, Color(200, 200, 200))

        if self.data.shieldRecharging then
            draw.SimpleText("RECHARGING", "DermaDefault", x, y + 65, Color(100, 255, 255))
        elseif self.data.shieldOverloaded then
            draw.SimpleText("OVERLOADED", "DermaDefault", x, y + 65, Color(255, 100, 100))
        end
    else
        draw.SimpleText("Shield system inactive", "DermaDefault", x, y + 20, Color(150, 150, 150))
    end
end

function shipCoreUI:DrawControlButtons(x, y)
    -- Control buttons header
    draw.SimpleText("SHIP CONTROLS", "DermaDefaultBold", x, y, Color(255, 255, 255))

    local buttonY = y + 25
    local buttonY2 = y + 55
    local buttonY3 = y + 85

    -- Hull repair buttons
    if self.data.hullSystemActive then
        self:DrawButton("REPAIR HULL", x, buttonY, 100, 25, Color(100, 150, 100), function()
            self:SendCommand("repair_hull", {amount = 25})
        end)

        -- Emergency repair for critical hull damage
        if self.data.hullCriticalMode or self.data.hullEmergencyMode then
            self:DrawButton("EMERGENCY REPAIR", x + 110, buttonY, 130, 25, Color(200, 100, 100), function()
                self:SendCommand("emergency_repair", {})
            end)
        end

        self:DrawButton("HULL STATUS", x, buttonY2, 100, 25, Color(100, 100, 150), function()
            self:SendCommand("hull_status", {})
        end)
    end

    -- Shield control buttons
    if self.data.shieldSystemActive then
        if self.data.shieldActive then
            self:DrawButton("DEACTIVATE SHIELDS", x + 250, buttonY, 140, 25, Color(150, 100, 100), function()
                self:SendCommand("deactivate_shields", {})
            end)
        else
            self:DrawButton("ACTIVATE SHIELDS", x + 250, buttonY, 140, 25, Color(100, 150, 100), function()
                self:SendCommand("activate_shields", {})
            end)
        end
    end

    -- Ship information and controls
    if self.data.shipDetected then
        self:DrawButton("SHIP INFO", x + 110, buttonY2, 100, 25, Color(100, 150, 150), function()
            self:SendCommand("ship_info", {})
        end)

        self:DrawButton("TOGGLE FRONT INDICATOR", x + 220, buttonY2, 170, 25, Color(100, 100, 150), function()
            self:SendCommand("toggle_front_indicator", {})
        end)
    end

    -- System status indicators
    draw.SimpleText("SYSTEM STATUS", "DermaDefault", x, buttonY3, Color(200, 200, 200))

    -- Hull system status
    if self.data.hullSystemActive then
        local hullColor = Color(100, 255, 100)
        if self.data.hullIntegrity < 25 then hullColor = Color(255, 100, 100)
        elseif self.data.hullIntegrity < 50 then hullColor = Color(255, 150, 100)
        elseif self.data.hullIntegrity < 75 then hullColor = Color(255, 255, 100)
        end
        draw.SimpleText("Hull: " .. (self.data.hullIntegrity or 100) .. "%", "DermaDefault", x, buttonY3 + 15, hullColor)
    end

    -- Shield system status
    if self.data.shieldSystemActive then
        local shieldColor = Color(100, 255, 100)
        if self.data.shieldStrength < 25 then shieldColor = Color(255, 100, 100)
        elseif self.data.shieldStrength < 50 then shieldColor = Color(255, 150, 100)
        elseif self.data.shieldStrength < 75 then shieldColor = Color(255, 255, 100)
        end
        draw.SimpleText("Shields: " .. (self.data.shieldStrength or 0) .. "%", "DermaDefault", x + 100, buttonY3 + 15, shieldColor)
    end

    -- Core status
    local coreColor = Color(100, 255, 100)
    if self.data.coreState == ENT.States.EMERGENCY then coreColor = Color(255, 100, 100)
    elseif self.data.coreState == ENT.States.CRITICAL then coreColor = Color(255, 150, 100)
    elseif self.data.coreState == ENT.States.INVALID then coreColor = Color(255, 255, 100)
    end
    draw.SimpleText("Core: " .. (self.data.coreStateName or "Unknown"), "DermaDefault", x + 200, buttonY3 + 15, coreColor)
end

function shipCoreUI:DrawButton(text, x, y, w, h, color, onClick, customTextColor)
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    local isHovered = mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h

    local bgColor = isHovered and Color(color.r + 30, color.g + 30, color.b + 30) or color
    local textColor = customTextColor or (isHovered and Color(255, 255, 255) or Color(200, 200, 200))

    draw.RoundedBox(4, x, y, w, h, bgColor)
    draw.SimpleText(text, "DermaDefault", x + w/2, y + h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Handle click
    if isHovered and input.IsMouseDown(MOUSE_LEFT) and CurTime() - self.lastUpdate > 0.2 then
        self.lastUpdate = CurTime()
        if onClick then onClick() end
    end
end

function shipCoreUI:SendCommand(command, data)
    if not IsValid(self.entity) then return end

    net.Start("ship_core_command")
    net.WriteEntity(self.entity)
    net.WriteString(command)
    net.WriteTable(data)
    net.SendToServer()
end

-- Update UI data from network variables
function shipCoreUI:UpdateData()
    if not IsValid(self.entity) or not self.data then return end

    -- Update resource system status from network variables
    self.data.resourceSystemActive = self.entity:GetNWBool("ResourceSystemActive", false)
    self.data.resourceEnergy = self.entity:GetNWFloat("ResourceEnergy", 0)
    self.data.resourceOxygen = self.entity:GetNWFloat("ResourceOxygen", 0)
    self.data.resourceCoolant = self.entity:GetNWFloat("ResourceCoolant", 0)
    self.data.resourceFuel = self.entity:GetNWFloat("ResourceFuel", 0)
    self.data.resourceWater = self.entity:GetNWFloat("ResourceWater", 0)
    self.data.resourceNitrogen = self.entity:GetNWFloat("ResourceNitrogen", 0)
    self.data.resourceEmergencyMode = self.entity:GetNWInt("ResourceEmergencyMode", 0) == 1
    self.data.autoProvisionEnabled = self.entity:GetNWBool("AutoProvisionEnabled", true)
    self.data.weldDetectionEnabled = self.entity:GetNWBool("WeldDetectionEnabled", true)
    self.data.lastResourceActivity = self.entity:GetNWString("LastResourceActivity", "")
end

-- Ship name dialog
local function OpenShipNameDialog(entity, currentName)
    -- Get configuration for validation limits
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.ShipNaming or {}
    local maxLength = config.MaxNameLength or 32
    local minLength = config.MinNameLength or 1

    local frame = vgui.Create("DFrame")
    frame:SetSize(450, 220)
    frame:Center()
    frame:SetTitle("Edit Ship Name")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()

    local label = vgui.Create("DLabel", frame)
    label:SetPos(20, 40)
    label:SetSize(410, 20)
    label:SetText("Enter new ship name (" .. minLength .. "-" .. maxLength .. " characters, letters/numbers/spaces/hyphens/underscores only):")

    local textEntry = vgui.Create("DTextEntry", frame)
    textEntry:SetPos(20, 65)
    textEntry:SetSize(410, 25)
    textEntry:SetText(currentName or "")
    textEntry:SetMaxLength(maxLength)
    textEntry:RequestFocus()

    -- Character counter
    local counterLabel = vgui.Create("DLabel", frame)
    counterLabel:SetPos(20, 95)
    counterLabel:SetSize(410, 15)
    counterLabel:SetText("Characters: " .. string.len(currentName or "") .. "/" .. maxLength)

    -- Update counter on text change
    textEntry.OnTextChanged = function()
        local text = textEntry:GetValue()
        counterLabel:SetText("Characters: " .. string.len(text) .. "/" .. maxLength)

        -- Color coding
        if string.len(text) < minLength or string.len(text) > maxLength then
            counterLabel:SetTextColor(Color(255, 100, 100))
        else
            counterLabel:SetTextColor(Color(100, 255, 100))
        end
    end

    local buttonPanel = vgui.Create("DPanel", frame)
    buttonPanel:SetPos(20, 130)
    buttonPanel:SetSize(410, 40)
    buttonPanel:SetPaintBackground(false)

    local saveButton = vgui.Create("DButton", buttonPanel)
    saveButton:SetPos(0, 0)
    saveButton:SetSize(100, 30)
    saveButton:SetText("Save")
    saveButton.DoClick = function()
        local newName = textEntry:GetValue()
        if newName and string.len(string.Trim(newName)) >= minLength and string.len(string.Trim(newName)) <= maxLength then
            net.Start("ship_core_command")
            net.WriteEntity(entity)
            net.WriteString("set_ship_name")
            net.WriteTable({name = newName})
            net.SendToServer()
            frame:Close()
        else
            -- Show validation error
            local errorMsg = "Name must be between " .. minLength .. " and " .. maxLength .. " characters"
            chat.AddText(Color(255, 100, 100), "[Ship Core] " .. errorMsg)
        end
    end

    local cancelButton = vgui.Create("DButton", buttonPanel)
    cancelButton:SetPos(110, 0)
    cancelButton:SetSize(100, 30)
    cancelButton:SetText("Cancel")
    cancelButton.DoClick = function()
        frame:Close()
    end

    -- Handle enter key
    textEntry.OnEnter = function()
        saveButton:DoClick()
    end
end

-- Network message handlers
net.Receive("ship_core_open_ui", function()
    local entity = net.ReadEntity()
    local data = net.ReadTable()

    if IsValid(entity) then
        shipCoreUI:Open(entity, data)
    end
end)

net.Receive("ship_core_update_ui", function()
    local data = net.ReadTable()
    shipCoreUI:Update(data)
end)

net.Receive("ship_core_close_ui", function()
    shipCoreUI:Close()
end)

net.Receive("ship_core_name_dialog", function()
    local entity = net.ReadEntity()
    local currentName = net.ReadString()

    if IsValid(entity) then
        OpenShipNameDialog(entity, currentName)
    end
end)

-- Hook for drawing UI
hook.Add("HUDPaint", "ShipCoreUI", function()
    shipCoreUI:Draw()
end)

-- Close UI on escape
hook.Add("OnPlayerChat", "ShipCoreUIClose", function(ply, text)
    if ply == LocalPlayer() and string.lower(text) == "!close" then
        shipCoreUI:Close()
        return true
    end
end)

-- Close UI when entity is removed
hook.Add("EntityRemoved", "ShipCoreUICleanup", function(ent)
    if shipCoreUI.entity == ent then
        shipCoreUI:Close()
    end
end)

-- CAP Integration Tab
function shipCoreUI:DrawCAPTab(x, y)
    -- CAP integration header
    draw.SimpleText("CAP (CARTER ADDON PACK) INTEGRATION", "DermaDefaultBold", x, y, Color(255, 255, 255))

    if not self.data.capIntegrationActive then
        draw.SimpleText("CAP integration not available", "DermaDefault", x, y + 25, Color(255, 100, 100))
        draw.SimpleText("Carter Addon Pack required", "DermaDefault", x, y + 40, Color(200, 200, 200))
        return
    end

    -- CAP status section
    self:DrawCAPStatus(x, y + 30)

    -- CAP shields section
    self:DrawCAPShields(x, y + 150)

    -- CAP energy section
    self:DrawCAPEnergy(x + 400, y + 150)

    -- CAP controls
    self:DrawCAPControls(x, y + 300)
end

function shipCoreUI:DrawCAPStatus(x, y)
    draw.SimpleText("CAP SYSTEM STATUS", "DermaDefaultBold", x, y, Color(255, 255, 255))

    local statusY = y + 25

    -- Integration status
    local integrationColor = self.data.capIntegrationActive and Color(100, 255, 100) or Color(255, 100, 100)
    draw.SimpleText("Integration: " .. (self.data.capIntegrationActive and "ACTIVE" or "INACTIVE"), "DermaDefault", x, statusY, integrationColor)

    -- CAP version
    draw.SimpleText("CAP Version: " .. (self.data.capVersion or "Unknown"), "DermaDefault", x, statusY + 15, Color(200, 200, 200))

    -- CAP status
    draw.SimpleText("Status: " .. (self.data.capStatus or "Unknown"), "DermaDefault", x, statusY + 30, Color(200, 200, 200))

    -- Detection summary
    local detectedSystems = 0
    if self.data.capShieldsDetected then detectedSystems = detectedSystems + 1 end
    if self.data.capEnergyDetected then detectedSystems = detectedSystems + 1 end
    if self.data.capResourcesDetected then detectedSystems = detectedSystems + 1 end

    local detectionColor = detectedSystems > 0 and Color(100, 255, 100) or Color(255, 100, 100)
    draw.SimpleText("Detected Systems: " .. detectedSystems .. "/3", "DermaDefault", x, statusY + 45, detectionColor)

    -- Entity count
    draw.SimpleText("CAP Entities: " .. (self.data.capEntityCount or 0), "DermaDefault", x, statusY + 60, Color(200, 200, 200))
end

function shipCoreUI:DrawCAPShields(x, y)
    draw.SimpleText("CAP SHIELD SYSTEM", "DermaDefaultBold", x, y, Color(255, 255, 255))

    local statusY = y + 25

    if self.data.capShieldsDetected then
        local shieldColor = Color(100, 255, 100)
        if self.data.shieldStrength < 25 then shieldColor = Color(255, 100, 100)
        elseif self.data.shieldStrength < 50 then shieldColor = Color(255, 150, 100)
        elseif self.data.shieldStrength < 75 then shieldColor = Color(255, 255, 100)
        end

        draw.SimpleText("Shields Detected: YES", "DermaDefault", x, statusY, Color(100, 255, 100))
        draw.SimpleText("Shield Count: " .. (self.data.capShieldCount or 0), "DermaDefault", x, statusY + 15, Color(200, 200, 200))
        draw.SimpleText("Shield Strength: " .. (self.data.shieldStrength or 0) .. "%", "DermaDefault", x, statusY + 30, shieldColor)
        draw.SimpleText("Status: " .. (self.data.shieldSystemActive and "ACTIVE" or "INACTIVE"), "DermaDefault", x, statusY + 45, self.data.shieldSystemActive and Color(100, 255, 100) or Color(255, 100, 100))
    else
        draw.SimpleText("Shields Detected: NO", "DermaDefault", x, statusY, Color(255, 100, 100))
        draw.SimpleText("No CAP shields found on ship", "DermaDefault", x, statusY + 15, Color(200, 200, 200))
    end
end

function shipCoreUI:DrawCAPEnergy(x, y)
    draw.SimpleText("CAP ENERGY SYSTEM", "DermaDefaultBold", x, y, Color(255, 255, 255))

    local statusY = y + 25

    if self.data.capEnergyDetected then
        local energyLevel = self.data.capEnergyLevel or 0
        local energyColor = Color(100, 255, 100)
        if energyLevel < 1000 then energyColor = Color(255, 100, 100)
        elseif energyLevel < 5000 then energyColor = Color(255, 150, 100)
        elseif energyLevel < 10000 then energyColor = Color(255, 255, 100)
        end

        draw.SimpleText("Energy Detected: YES", "DermaDefault", x, statusY, Color(100, 255, 100))
        draw.SimpleText("Energy Level: " .. math.floor(energyLevel), "DermaDefault", x, statusY + 15, energyColor)
        draw.SimpleText("Status: AVAILABLE", "DermaDefault", x, statusY + 30, Color(100, 255, 100))
    else
        draw.SimpleText("Energy Detected: NO", "DermaDefault", x, statusY, Color(255, 100, 100))
        draw.SimpleText("No CAP energy sources found", "DermaDefault", x, statusY + 15, Color(200, 200, 200))
    end
end

function shipCoreUI:DrawCAPControls(x, y)
    draw.SimpleText("CAP SYSTEM CONTROLS", "DermaDefaultBold", x, y, Color(255, 255, 255))

    local buttonY = y + 25
    local buttonSpacing = 120

    -- Shield controls
    if self.data.capShieldsDetected then
        if self.data.shieldSystemActive then
            self:DrawButton("DEACTIVATE CAP SHIELDS", x, buttonY, 160, 25, Color(150, 100, 100), function()
                self:SendCommand("cap_deactivate_shields", {})
            end)
        else
            self:DrawButton("ACTIVATE CAP SHIELDS", x, buttonY, 160, 25, Color(100, 150, 100), function()
                self:SendCommand("cap_activate_shields", {})
            end)
        end
    end

    -- Energy controls
    if self.data.capEnergyDetected then
        self:DrawButton("CAP ENERGY STATUS", x + buttonSpacing + 40, buttonY, 140, 25, Color(100, 100, 150), function()
            self:SendCommand("cap_energy_status", {})
        end)
    end

    -- System controls
    buttonY = buttonY + 35
    self:DrawButton("REFRESH CAP STATUS", x, buttonY, 140, 25, Color(100, 150, 150), function()
        self:SendCommand("cap_refresh", {})
    end)

    self:DrawButton("CAP DIAGNOSTICS", x + buttonSpacing + 20, buttonY, 140, 25, Color(150, 100, 150), function()
        self:SendCommand("cap_diagnostics", {})
    end)
end

print("[Ship Core] Client-side ship core UI with CAP integration loaded")
