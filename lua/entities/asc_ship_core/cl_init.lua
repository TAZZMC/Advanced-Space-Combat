-- ASC Ship Core Entity - Client v2.2.0
-- Mandatory ship core for Advanced Space Combat with real-time features

include("shared.lua")

-- Enhanced UI variables with modern design and v2.2.0 features
local shipCoreUI = {
    visible = false,
    entity = nil,
    data = {},
    panelWidth = 1200,
    panelHeight = 900,
    lastUpdate = 0,
    currentTab = "overview", -- overview, resources, systems, cap, fleet, admin, stargate, realtime
    animationTime = 0,
    fadeAlpha = 0,
    targetAlpha = 0,
    tabAnimations = {},

    -- v2.2.0 enhancements
    realTimeMode = true,
    updateRate = 0.05, -- 20 FPS real-time updates
    lastRealTimeUpdate = 0,
    alertSystem = {},
    fleetData = {},
    adminData = {},
    stargateData = {},
    performanceData = {},
    notifications = {},
    lastNotificationTime = 0,
    theme = {
        primary = Color(20, 30, 50, 240),
        secondary = Color(40, 60, 90, 220),
        accent = Color(100, 150, 255),
        success = Color(100, 255, 100),
        warning = Color(255, 200, 100),
        error = Color(255, 100, 100),
        text = Color(255, 255, 255),
        textSecondary = Color(200, 200, 200),
        textMuted = Color(150, 150, 150)
    }
}

function ENT:Initialize()
    self.nextParticle = 0
    self.glowIntensity = 0
    self.pulseTime = 0
    self.lastEffectTime = 0
end

function ENT:Draw()
    self:DrawModel()

    -- Draw status text above core
    self:DrawStatusText()

    -- Draw model selection info if close enough
    local ply = LocalPlayer()
    if IsValid(ply) then
        local distance = ply:GetPos():Distance(self:GetPos())
        if distance < 200 then
            self:DrawModelInfo()
        end
    end
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
        draw.SimpleText("ASC SHIP CORE", "DermaDefaultBold", 0, textY, Color(255, 255, 255), TEXT_ALIGN_CENTER)
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

-- Enhanced UI Functions with animations
function shipCoreUI:Open(entity, data)
    self.visible = true
    self.entity = entity
    self.data = data or {}
    self.targetAlpha = 255
    self.animationTime = CurTime()
    self.currentTab = "overview"

    -- Initialize tab animations
    self.tabAnimations = {}
    for _, tab in ipairs({"overview", "resources", "systems", "cap"}) do
        self.tabAnimations[tab] = {
            scale = 1.0,
            targetScale = 1.0,
            lastClick = 0
        }
    end

    gui.EnableScreenClicker(true)

    -- Play opening sound using sound system
    if HYPERDRIVE.Sounds and HYPERDRIVE.Sounds.UI then
        HYPERDRIVE.Sounds.UI.PlayOpen()
    else
        surface.PlaySound("buttons/button15.wav")
    end

    -- Add opening notification
    self:AddNotification("ASC Ship Core Interface Activated", "success")

    print("[ASC Ship Core UI] Enhanced interface opened")
end

function shipCoreUI:Close()
    self.targetAlpha = 0

    -- Animate close
    timer.Simple(0.3, function()
        if not self.visible then return end

        self.visible = false
        self.entity = nil
        self.data = {}
        self.notifications = {}
        gui.EnableScreenClicker(false)

        -- Send close command to server
        if IsValid(self.entity) then
            net.Start("asc_ship_core_command")
            net.WriteEntity(self.entity)
            net.WriteString("close_ui")
            net.WriteTable({})
            net.SendToServer()
        end
    end)

    -- Play closing sound using sound system
    if HYPERDRIVE.Sounds and HYPERDRIVE.Sounds.UI then
        HYPERDRIVE.Sounds.UI.PlayClose()
    else
        surface.PlaySound("buttons/button10.wav")
    end

    print("[ASC Ship Core UI] Enhanced interface closed")
end

function shipCoreUI:Update(data)
    self.data = data or {}
    self.lastUpdate = CurTime()

    -- Add update notification for critical changes
    -- Define states locally to avoid ENT context issues
    local States = {
        INACTIVE = 0,
        ACTIVE = 1,
        INVALID = 2,
        CRITICAL = 3,
        EMERGENCY = 4
    }

    if data.coreState == States.EMERGENCY and self.data.coreState ~= States.EMERGENCY then
        self:AddNotification("EMERGENCY: Core System Critical!", "error")
    elseif data.resourceEmergencyMode and not self.data.resourceEmergencyMode then
        self:AddNotification("WARNING: Resource Emergency Detected", "warning")
    end
end

-- Animation and notification system
function shipCoreUI:AddNotification(text, type)
    local notification = {
        text = text,
        type = type or "info",
        time = CurTime(),
        alpha = 255,
        y = 0
    }

    table.insert(self.notifications, notification)
    self.lastNotificationTime = CurTime()

    -- Limit notifications
    if #self.notifications > 5 then
        table.remove(self.notifications, 1)
    end

    -- Notification sounds removed per user request
end

-- UI Drawing Function
function shipCoreUI:Draw()
    if not self.visible or not IsValid(self.entity) then return end

    -- Update fade animation
    local timeDiff = CurTime() - self.animationTime
    if timeDiff < 0.3 then
        local progress = timeDiff / 0.3
        self.fadeAlpha = Lerp(progress, 0, self.targetAlpha)
    else
        self.fadeAlpha = self.targetAlpha
    end

    if self.fadeAlpha <= 0 then return end

    local scrW, scrH = ScrW(), ScrH()
    local panelX = (scrW - self.panelWidth) / 2
    local panelY = (scrH - self.panelHeight) / 2

    -- Main panel background
    surface.SetDrawColor(self.theme.primary.r, self.theme.primary.g, self.theme.primary.b, self.fadeAlpha * 0.9)
    surface.DrawRect(panelX, panelY, self.panelWidth, self.panelHeight)

    -- Panel border
    surface.SetDrawColor(self.theme.accent.r, self.theme.accent.g, self.theme.accent.b, self.fadeAlpha)
    surface.DrawOutlinedRect(panelX, panelY, self.panelWidth, self.panelHeight, 2)

    -- Title bar
    surface.SetDrawColor(self.theme.secondary.r, self.theme.secondary.g, self.theme.secondary.b, self.fadeAlpha)
    surface.DrawRect(panelX, panelY, self.panelWidth, 60)

    -- Title text
    draw.SimpleText("ASC Ship Core Interface v2.2.0", "DermaLarge", panelX + 20, panelY + 20, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    -- Close button
    local closeX = panelX + self.panelWidth - 40
    local closeY = panelY + 10
    surface.SetDrawColor(self.theme.error.r, self.theme.error.g, self.theme.error.b, self.fadeAlpha * 0.8)
    surface.DrawRect(closeX, closeY, 30, 30)
    draw.SimpleText("X", "DermaDefault", closeX + 15, closeY + 15, Color(255, 255, 255, self.fadeAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Check for close button click
    local mx, my = gui.MousePos()
    if input.IsMouseDown(MOUSE_LEFT) and mx >= closeX and mx <= closeX + 30 and my >= closeY and my <= closeY + 30 then
        self:Close()
        return
    end

    -- Tab buttons
    local tabs = {"Overview", "Resources", "Systems", "Model"}
    local tabWidth = self.panelWidth / #tabs
    local tabY = panelY + 60

    for i, tab in ipairs(tabs) do
        local tabX = panelX + (i - 1) * tabWidth
        local isActive = string.lower(tab) == self.currentTab

        -- Tab background
        if isActive then
            surface.SetDrawColor(self.theme.accent.r, self.theme.accent.g, self.theme.accent.b, self.fadeAlpha)
        else
            surface.SetDrawColor(self.theme.secondary.r, self.theme.secondary.g, self.theme.secondary.b, self.fadeAlpha * 0.7)
        end
        surface.DrawRect(tabX, tabY, tabWidth, 40)

        -- Tab text
        local textColor = isActive and self.theme.text or self.theme.textSecondary
        draw.SimpleText(tab, "DermaDefault", tabX + tabWidth / 2, tabY + 20, Color(textColor.r, textColor.g, textColor.b, self.fadeAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Check for tab click
        if input.IsMouseDown(MOUSE_LEFT) and mx >= tabX and mx <= tabX + tabWidth and my >= tabY and my <= tabY + 40 then
            self.currentTab = string.lower(tab)
        end
    end

    -- Content area
    local contentY = tabY + 40
    local contentHeight = self.panelHeight - 100 - 40

    -- Draw content based on current tab
    if self.currentTab == "overview" then
        self:DrawOverviewTab(panelX + 20, contentY + 20, self.panelWidth - 40, contentHeight - 40)
    elseif self.currentTab == "resources" then
        self:DrawResourcesTab(panelX + 20, contentY + 20, self.panelWidth - 40, contentHeight - 40)
    elseif self.currentTab == "systems" then
        self:DrawSystemsTab(panelX + 20, contentY + 20, self.panelWidth - 40, contentHeight - 40)
    elseif self.currentTab == "model" then
        self:DrawModelTab(panelX + 20, contentY + 20, self.panelWidth - 40, contentHeight - 40)
    end

    -- Draw notifications
    self:DrawNotifications()
end

function shipCoreUI:DrawOverviewTab(x, y, w, h)
    local data = self.data
    if not data then return end

    local lineHeight = 20
    local currentY = y
    local columnWidth = w / 2

    -- Left Column - Ship Core Status
    draw.SimpleText("Ship Core Status:", "DermaDefaultBold", x, currentY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))
    currentY = currentY + lineHeight

    draw.SimpleText("State: " .. (data.coreStateName or "Unknown"), "DermaDefault", x + 10, currentY, Color(self.theme.textSecondary.r, self.theme.textSecondary.g, self.theme.textSecondary.b, self.fadeAlpha))
    currentY = currentY + lineHeight

    draw.SimpleText("Ship: " .. (data.shipName or "Unnamed Ship"), "DermaDefault", x + 10, currentY, Color(self.theme.textSecondary.r, self.theme.textSecondary.g, self.theme.textSecondary.b, self.fadeAlpha))
    currentY = currentY + lineHeight

    draw.SimpleText("Type: " .. (data.shipType or "Unknown"), "DermaDefault", x + 10, currentY, Color(self.theme.textSecondary.r, self.theme.textSecondary.g, self.theme.textSecondary.b, self.fadeAlpha))
    currentY = currentY + lineHeight * 1.5

    -- Power Management
    if data.powerManagement then
        local pm = data.powerManagement
        draw.SimpleText("Power Management:", "DermaDefaultBold", x, currentY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))
        currentY = currentY + lineHeight

        local powerPercent = (pm.availablePower / pm.totalPower) * 100
        local powerColor = powerPercent > 75 and self.theme.success or (powerPercent > 25 and self.theme.warning or self.theme.error)
        draw.SimpleText("Power: " .. math.floor(pm.availablePower) .. "/" .. pm.totalPower .. " (" .. math.floor(powerPercent) .. "%)", "DermaDefault", x + 10, currentY, Color(powerColor.r, powerColor.g, powerColor.b, self.fadeAlpha))
        currentY = currentY + lineHeight

        local efficiencyColor = pm.powerEfficiency > 0.8 and self.theme.success or (pm.powerEfficiency > 0.5 and self.theme.warning or self.theme.error)
        draw.SimpleText("Efficiency: " .. math.floor(pm.powerEfficiency * 100) .. "%", "DermaDefault", x + 10, currentY, Color(efficiencyColor.r, efficiencyColor.g, efficiencyColor.b, self.fadeAlpha))
        currentY = currentY + lineHeight

        if pm.emergencyMode then
            draw.SimpleText("EMERGENCY MODE ACTIVE", "DermaDefault", x + 10, currentY, Color(self.theme.error.r, self.theme.error.g, self.theme.error.b, self.fadeAlpha))
            currentY = currentY + lineHeight
        end
    end

    -- Right Column - System Status
    local rightX = x + columnWidth
    local rightY = y

    draw.SimpleText("System Status:", "DermaDefaultBold", rightX, rightY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))
    rightY = rightY + lineHeight

    local hullColor = data.hullIntegrity and (data.hullIntegrity > 75 and self.theme.success or (data.hullIntegrity > 25 and self.theme.warning or self.theme.error)) or self.theme.textMuted
    draw.SimpleText("Hull: " .. (data.hullIntegrity or 0) .. "%", "DermaDefault", rightX + 10, rightY, Color(hullColor.r, hullColor.g, hullColor.b, self.fadeAlpha))
    rightY = rightY + lineHeight

    local shieldColor = data.shieldStrength and (data.shieldStrength > 50 and self.theme.success or (data.shieldStrength > 0 and self.theme.warning or self.theme.error)) or self.theme.textMuted
    draw.SimpleText("Shields: " .. (data.shieldStrength or 0) .. "%", "DermaDefault", rightX + 10, rightY, Color(shieldColor.r, shieldColor.g, shieldColor.b, self.fadeAlpha))
    rightY = rightY + lineHeight * 1.5

    -- Thermal Management
    if data.thermalManagement then
        local tm = data.thermalManagement
        draw.SimpleText("Thermal Status:", "DermaDefaultBold", rightX, rightY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))
        rightY = rightY + lineHeight

        local tempColor = tm.coreTemperature < tm.maxTemperature and self.theme.success or self.theme.error
        draw.SimpleText("Core Temp: " .. math.floor(tm.coreTemperature) .. "°C", "DermaDefault", rightX + 10, rightY, Color(tempColor.r, tempColor.g, tempColor.b, self.fadeAlpha))
        rightY = rightY + lineHeight

        if tm.overheating then
            draw.SimpleText("OVERHEATING!", "DermaDefault", rightX + 10, rightY, Color(self.theme.error.r, self.theme.error.g, self.theme.error.b, self.fadeAlpha))
            rightY = rightY + lineHeight
        end
    end

    -- Crew Efficiency
    if data.crewEfficiency then
        local ce = data.crewEfficiency
        draw.SimpleText("Crew Status:", "DermaDefaultBold", rightX, rightY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))
        rightY = rightY + lineHeight

        draw.SimpleText("Crew: " .. ce.totalCrew .. " aboard", "DermaDefault", rightX + 10, rightY, Color(self.theme.textSecondary.r, self.theme.textSecondary.g, self.theme.textSecondary.b, self.fadeAlpha))
        rightY = rightY + lineHeight

        local effColor = ce.overallEfficiency > 0.8 and self.theme.success or (ce.overallEfficiency > 0.5 and self.theme.warning or self.theme.error)
        draw.SimpleText("Efficiency: " .. math.floor(ce.overallEfficiency * 100) .. "%", "DermaDefault", rightX + 10, rightY, Color(effColor.r, effColor.g, effColor.b, self.fadeAlpha))
    end
end

function shipCoreUI:DrawResourcesTab(x, y, w, h)
    local data = self.data
    if not data then return end

    local lineHeight = 25
    local currentY = y
    local barHeight = 15
    local barWidth = w - 100

    draw.SimpleText("Resource Management", "DermaDefaultBold", x, currentY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))
    currentY = currentY + lineHeight * 1.5

    if data.resources then
        -- Sort resources by priority
        local sortedResources = {}
        for resourceType, resource in pairs(data.resources) do
            table.insert(sortedResources, {type = resourceType, data = resource})
        end
        table.sort(sortedResources, function(a, b) return a.data.priority < b.data.priority end)

        for _, resourceInfo in ipairs(sortedResources) do
            local resourceType = resourceInfo.type
            local resource = resourceInfo.data

            -- Resource name
            local displayName = string.upper(string.sub(resourceType, 1, 1)) .. string.sub(resourceType, 2)
            draw.SimpleText(displayName .. ":", "DermaDefault", x, currentY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))

            -- Resource bar background
            surface.SetDrawColor(50, 50, 50, self.fadeAlpha)
            surface.DrawRect(x + 80, currentY, barWidth, barHeight)

            -- Resource bar fill
            local fillWidth = (resource.percentage / 100) * barWidth
            local barColor = resource.percentage > 75 and self.theme.success or (resource.percentage > 25 and self.theme.warning or self.theme.error)
            if resource.critical and resource.percentage < 25 then
                barColor = self.theme.error
            end

            surface.SetDrawColor(barColor.r, barColor.g, barColor.b, self.fadeAlpha)
            surface.DrawRect(x + 80, currentY, fillWidth, barHeight)

            -- Resource text
            local resourceText = math.floor(resource.amount) .. "/" .. resource.capacity .. " (" .. math.floor(resource.percentage) .. "%)"
            draw.SimpleText(resourceText, "DermaDefault", x + 80 + barWidth + 10, currentY + 2, Color(self.theme.textSecondary.r, self.theme.textSecondary.g, self.theme.textSecondary.b, self.fadeAlpha))

            -- Regeneration rate
            if resource.regenRate > 0 then
                draw.SimpleText("+" .. resource.regenRate .. "/s", "DermaDefault", x + 80 + barWidth + 150, currentY + 2, Color(self.theme.success.r, self.theme.success.g, self.theme.success.b, self.fadeAlpha))
            end

            currentY = currentY + lineHeight
        end
    else
        draw.SimpleText("No resource data available", "DermaDefault", x, currentY, Color(self.theme.textMuted.r, self.theme.textMuted.g, self.theme.textMuted.b, self.fadeAlpha))
    end
end

function shipCoreUI:DrawSystemsTab(x, y, w, h)
    local data = self.data
    if not data then return end

    local lineHeight = 25
    local currentY = y
    local columnWidth = w / 2

    draw.SimpleText("System Configuration", "DermaDefaultBold", x, currentY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))
    currentY = currentY + lineHeight * 1.5

    -- Left Column - Power Distribution
    if data.powerManagement and data.powerManagement.powerDistribution then
        draw.SimpleText("Power Distribution:", "DermaDefaultBold", x, currentY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))
        local powerY = currentY + lineHeight

        for system, powerData in pairs(data.powerManagement.powerDistribution) do
            if powerData.active then
                local displayName = string.upper(string.sub(system, 1, 1)) .. string.sub(system, 2)
                local powerPercent = (powerData.allocated / data.powerManagement.totalPower) * 100

                draw.SimpleText(displayName .. ": " .. powerData.allocated .. "W (" .. math.floor(powerPercent) .. "%)", "DermaDefault", x + 10, powerY, Color(self.theme.textSecondary.r, self.theme.textSecondary.g, self.theme.textSecondary.b, self.fadeAlpha))
                powerY = powerY + lineHeight * 0.8
            end
        end
    end

    -- Right Column - Subsystem Health
    local rightX = x + columnWidth
    local rightY = currentY

    if data.subsystems then
        draw.SimpleText("Subsystem Health:", "DermaDefaultBold", rightX, rightY, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))
        rightY = rightY + lineHeight

        for systemName, subsystem in pairs(data.subsystems) do
            local displayName = string.upper(string.sub(systemName, 1, 1)) .. string.sub(systemName, 2)
            local healthColor = subsystem.health > 75 and self.theme.success or (subsystem.health > 25 and self.theme.warning or self.theme.error)

            local statusText = displayName .. ": " .. math.floor(subsystem.health) .. "%"
            if subsystem.critical and subsystem.health < 50 then
                statusText = statusText .. " [CRITICAL]"
            end

            draw.SimpleText(statusText, "DermaDefault", rightX + 10, rightY, Color(healthColor.r, healthColor.g, healthColor.b, self.fadeAlpha))
            rightY = rightY + lineHeight * 0.8
        end

        if data.autoRepair then
            rightY = rightY + lineHeight * 0.5
            draw.SimpleText("Auto-Repair: ACTIVE", "DermaDefault", rightX + 10, rightY, Color(self.theme.success.r, self.theme.success.g, self.theme.success.b, self.fadeAlpha))
        end
    end
end

function shipCoreUI:DrawModelTab(x, y, w, h)
    local data = self.data
    if not data or not data.modelInfo then return end

    draw.SimpleText("Model Selection", "DermaDefaultBold", x, y, Color(self.theme.text.r, self.theme.text.g, self.theme.text.b, self.fadeAlpha))

    local modelInfo = data.modelInfo
    draw.SimpleText("Current Model: " .. (modelInfo.currentModelName or "Unknown"), "DermaDefault", x, y + 30, Color(self.theme.textSecondary.r, self.theme.textSecondary.g, self.theme.textSecondary.b, self.fadeAlpha))
    draw.SimpleText("Total Models: " .. (modelInfo.totalModels or 0), "DermaDefault", x, y + 55, Color(self.theme.textSecondary.r, self.theme.textSecondary.g, self.theme.textSecondary.b, self.fadeAlpha))
end

function shipCoreUI:DrawNotifications()
    if not self.notifications or #self.notifications == 0 then return end

    local x = ScrW() - 320
    local y = 100

    for i, notification in ipairs(self.notifications) do
        local age = CurTime() - notification.time
        local alpha = math.max(0, 255 - (age * 50))

        if alpha > 0 then
            local color = self.theme.text
            if notification.type == "error" then
                color = self.theme.error
            elseif notification.type == "warning" then
                color = self.theme.warning
            elseif notification.type == "success" then
                color = self.theme.success
            end

            surface.SetDrawColor(0, 0, 0, alpha * 0.8)
            surface.DrawRect(x, y + (i - 1) * 30, 300, 25)

            draw.SimpleText(notification.text, "DermaDefault", x + 10, y + (i - 1) * 30 + 12, Color(color.r, color.g, color.b, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end
end

-- HUD Paint hook for UI rendering
hook.Add("HUDPaint", "ASC_ShipCore_UI", function()
    shipCoreUI:Draw()
end)

-- Model selection functionality
function ENT:DrawModelInfo()
    local modelName = self:GetNWString("SelectedModelName", "Unknown Model")
    local currentIndex = self:GetNWInt("SelectedModelIndex", 1)
    local totalModels = self:GetNWInt("TotalModels", 1)

    local pos = self:GetPos() + Vector(0, 0, 60)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    cam.Start3D2D(pos, ang, 0.08)
        -- Background
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(-200, -40, 400, 80)

        -- Border
        surface.SetDrawColor(100, 150, 255, 255)
        surface.DrawOutlinedRect(-200, -40, 400, 80)

        -- Text
        draw.SimpleText("Model: " .. modelName, "DermaDefaultBold", 0, -20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(currentIndex .. " / " .. totalModels, "DermaDefault", 0, 0, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("F1: Menu | F2: Next | F3: Previous", "DermaDefault", 0, 20, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

-- Network message handlers for UI system
net.Receive("asc_ship_core_open_ui", function()
    local core = net.ReadEntity()
    local data = net.ReadTable()

    if IsValid(core) then
        shipCoreUI:Open(core, data)
    end
end)

net.Receive("asc_ship_core_close_ui", function()
    shipCoreUI:Close()
end)

net.Receive("asc_ship_core_update_ui", function()
    local data = net.ReadTable()
    shipCoreUI:Update(data)
end)

-- Network message handlers for model selection
net.Receive("asc_ship_core_model_selection", function()
    local core = net.ReadEntity()
    local modelInfo = net.ReadTable()

    if IsValid(core) then
        OpenModelSelectionMenu(core, modelInfo)
    end
end)

-- Model selection menu
function OpenModelSelectionMenu(core, modelInfo)
    if IsValid(ASC_ModelSelectionFrame) then
        ASC_ModelSelectionFrame:Close()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 600)
    frame:Center()
    frame:SetTitle("ASC Ship Core - Model Selection")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()

    ASC_ModelSelectionFrame = frame

    -- Current model info
    local currentLabel = vgui.Create("DLabel", frame)
    currentLabel:SetPos(10, 30)
    currentLabel:SetSize(480, 20)
    currentLabel:SetText("Current Model: " .. (modelInfo.models[modelInfo.currentIndex] and modelInfo.models[modelInfo.currentIndex].name or "Unknown"))
    currentLabel:SetTextColor(Color(255, 255, 255))

    -- Model list
    local modelList = vgui.Create("DListView", frame)
    modelList:SetPos(10, 60)
    modelList:SetSize(480, 450)
    modelList:SetMultiSelect(false)
    modelList:AddColumn("Index"):SetFixedWidth(60)
    modelList:AddColumn("Name"):SetFixedWidth(250)
    modelList:AddColumn("Category"):SetFixedWidth(120)

    -- Populate model list
    for _, modelData in ipairs(modelInfo.models) do
        local line = modelList:AddLine(modelData.index, modelData.name, modelData.category)
        if modelData.selected then
            line:SetSelected(true)
            modelList:SetSelectedItem(line)
        end
    end

    -- Double-click to select model
    modelList.OnRowSelected = function(panel, index, row)
        local modelIndex = tonumber(row:GetColumnText(1))
        if modelIndex then
            net.Start("asc_ship_core_command")
            net.WriteEntity(core)
            net.WriteString("set_model")
            net.WriteTable({index = modelIndex})
            net.SendToServer()

            frame:Close()
        end
    end

    -- Buttons
    local buttonPanel = vgui.Create("DPanel", frame)
    buttonPanel:SetPos(10, 520)
    buttonPanel:SetSize(480, 40)
    buttonPanel:SetBackgroundColor(Color(0, 0, 0, 0))

    local prevButton = vgui.Create("DButton", buttonPanel)
    prevButton:SetPos(0, 0)
    prevButton:SetSize(100, 30)
    prevButton:SetText("Previous")
    prevButton.DoClick = function()
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("previous_model")
        net.WriteTable({})
        net.SendToServer()

        frame:Close()
    end

    local nextButton = vgui.Create("DButton", buttonPanel)
    nextButton:SetPos(110, 0)
    nextButton:SetSize(100, 30)
    nextButton:SetText("Next")
    nextButton.DoClick = function()
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("next_model")
        net.WriteTable({})
        net.SendToServer()

        frame:Close()
    end

    local randomButton = vgui.Create("DButton", buttonPanel)
    randomButton:SetPos(220, 0)
    randomButton:SetSize(100, 30)
    randomButton:SetText("Random")
    randomButton.DoClick = function()
        local randomIndex = math.random(1, modelInfo.totalModels)
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("set_model")
        net.WriteTable({index = randomIndex})
        net.SendToServer()

        frame:Close()
    end

    local closeButton = vgui.Create("DButton", buttonPanel)
    closeButton:SetPos(380, 0)
    closeButton:SetSize(100, 30)
    closeButton:SetText("Close")
    closeButton.DoClick = function()
        frame:Close()
    end
end

-- Console command for opening model selection
concommand.Add("aria_ship_core_model_menu", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local core = ply:GetEyeTrace().Entity
    if IsValid(core) and core:GetClass() == "asc_ship_core" then
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("get_model_info")
        net.WriteTable({})
        net.SendToServer()
    else
        chat.AddText(Color(255, 100, 100), "[ASC Ship Core] Look at a ship core to open model selection")
    end
end, nil, "Open ship core model selection menu")

-- Key bindings help
hook.Add("HUDPaint", "ASC_ShipCore_ModelSelectionHelp", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if IsValid(trace.Entity) and trace.Entity:GetClass() == "asc_ship_core" and trace.HitPos:Distance(ply:GetPos()) < 200 then
        local x, y = ScrW() / 2, ScrH() - 120

        draw.SimpleText("Ship Core Model Selection", "DermaDefaultBold", x, y - 40, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText("E - Open UI  |  F1 - Model Menu  |  F2 - Next Model  |  F3 - Previous Model", "DermaDefault", x, y - 20, Color(200, 200, 200), TEXT_ALIGN_CENTER)
    end
end)

-- Bind keys for quick model switching
hook.Add("PlayerButtonDown", "ASC_ShipCore_ModelKeys", function(ply, button)
    if ply ~= LocalPlayer() then return end

    local core = ply:GetEyeTrace().Entity
    if not IsValid(core) or core:GetClass() ~= "asc_ship_core" then return end
    if ply:GetPos():Distance(core:GetPos()) > 200 then return end

    if button == KEY_F1 then
        -- Open model selection menu
        RunConsoleCommand("aria_ship_core_model_menu")
    elseif button == KEY_F2 then
        -- Next model
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("next_model")
        net.WriteTable({})
        net.SendToServer()
    elseif button == KEY_F3 then
        -- Previous model
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("previous_model")
        net.WriteTable({})
        net.SendToServer()
    end
end)
