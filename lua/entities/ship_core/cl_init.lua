-- Ship Core Entity - Client v2.2.0
-- Mandatory ship core for Enhanced Hyperdrive System with real-time features

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

    -- Apply dynamic material based on state
    local state = self:GetState()
    local color = self:GetStateColor()

    -- Set material based on state
    if state == 4 or state == 3 then -- EMERGENCY or CRITICAL
        self:SetMaterial("hyperdrive/ship_core_glow")
    else
        self:SetMaterial("hyperdrive/ship_core_base")
    end

    -- Set color based on state
    self:SetColor(Color(color.r, color.g, color.b, 255))

    -- Pulse effect for critical states
    if state == 4 or state == 3 then -- EMERGENCY or CRITICAL
        self.pulseTime = self.pulseTime + FrameTime() * 3
        self.glowIntensity = math.abs(math.sin(self.pulseTime)) * 0.8 + 0.2
    else
        self.glowIntensity = 0.5
    end

    -- Draw enhanced glow effect
    local pos = self:GetPos()
    local size = 32 * self.glowIntensity

    -- Create ship core glow effect periodically
    if CurTime() - self.lastEffectTime > 2 then
        self.lastEffectTime = CurTime()

        local effectData = EffectData()
        effectData:SetOrigin(pos)
        effectData:SetEntity(self)
        effectData:SetScale(1)
        effectData:SetMagnitude(state)
        util.Effect("ship_core_glow", effectData)
    end

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
    self:AddNotification("Ship Core Interface Activated", "success")

    print("[Ship Core UI] Enhanced interface opened")
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
            net.Start("ship_core_command")
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

    print("[Ship Core UI] Enhanced interface closed")
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

    -- Play notification sound using sound system
    if HYPERDRIVE.Sounds and HYPERDRIVE.Sounds.UI then
        if type == "error" then
            HYPERDRIVE.Sounds.UI.PlayError()
        elseif type == "warning" then
            HYPERDRIVE.Sounds.UI.PlayWarning()
        elseif type == "success" then
            HYPERDRIVE.Sounds.UI.PlaySuccess()
        else
            HYPERDRIVE.Sounds.UI.PlayNotification()
        end
    else
        -- Fallback to default sounds
        if type == "error" then
            surface.PlaySound("buttons/button11.wav")
        elseif type == "warning" then
            surface.PlaySound("buttons/button8.wav")
        else
            surface.PlaySound("buttons/button17.wav")
        end
    end
end

function shipCoreUI:UpdateAnimations()
    local currentTime = CurTime()
    local deltaTime = FrameTime()

    -- Update fade animation
    if self.fadeAlpha < self.targetAlpha then
        self.fadeAlpha = math.min(self.targetAlpha, self.fadeAlpha + deltaTime * 800)
    elseif self.fadeAlpha > self.targetAlpha then
        self.fadeAlpha = math.max(self.targetAlpha, self.fadeAlpha - deltaTime * 800)
    end

    -- Update tab animations
    for tab, anim in pairs(self.tabAnimations) do
        if anim.scale < anim.targetScale then
            anim.scale = math.min(anim.targetScale, anim.scale + deltaTime * 8)
        elseif anim.scale > anim.targetScale then
            anim.scale = math.max(anim.targetScale, anim.scale - deltaTime * 8)
        end
    end

    -- Update notifications
    for i = #self.notifications, 1, -1 do
        local notif = self.notifications[i]
        local age = currentTime - notif.time

        if age > 5 then
            notif.alpha = math.max(0, notif.alpha - deltaTime * 400)
            if notif.alpha <= 0 then
                table.remove(self.notifications, i)
            end
        end

        -- Animate notification position
        notif.y = math.Approach(notif.y, (i - 1) * 35, deltaTime * 300)
    end
end

function shipCoreUI:Draw()
    if not self.visible or not IsValid(self.entity) then return end

    -- Update animations
    self:UpdateAnimations()

    -- Update data from network variables
    self:UpdateData()

    local scrW, scrH = ScrW(), ScrH()
    local x = (scrW - self.panelWidth) / 2
    local y = (scrH - self.panelHeight) / 2

    -- Apply fade animation
    local alpha = self.fadeAlpha

    -- Modern glassmorphism background with blur effect
    draw.RoundedBox(12, x - 5, y - 5, self.panelWidth + 10, self.panelHeight + 10, Color(0, 0, 0, alpha * 0.3))
    draw.RoundedBox(12, x, y, self.panelWidth, self.panelHeight, Color(self.theme.primary.r, self.theme.primary.g, self.theme.primary.b, alpha))

    -- Subtle border glow
    draw.RoundedBox(12, x + 2, y + 2, self.panelWidth - 4, self.panelHeight - 4, Color(self.theme.secondary.r, self.theme.secondary.g, self.theme.secondary.b, alpha * 0.9))

    -- Dynamic title bar with status-based coloring
    -- Define states locally to avoid ENT context issues
    local States = {
        INACTIVE = 0,
        ACTIVE = 1,
        INVALID = 2,
        CRITICAL = 3,
        EMERGENCY = 4
    }

    local titleColor = Color(self.theme.accent.r, self.theme.accent.g, self.theme.accent.b, alpha)
    if self.data.coreState == States.EMERGENCY then
        titleColor = Color(255, 80, 80, alpha)
        -- Add pulsing effect for emergency
        local pulse = math.abs(math.sin(CurTime() * 3)) * 0.3 + 0.7
        titleColor = Color(255 * pulse, 80 * pulse, 80 * pulse, alpha)
    elseif self.data.coreState == States.CRITICAL then
        titleColor = Color(255, 150, 80, alpha)
    elseif self.data.coreState == States.INVALID then
        titleColor = Color(255, 255, 80, alpha)
    end

    -- Enhanced title bar with gradient
    draw.RoundedBoxEx(8, x + 15, y + 15, self.panelWidth - 30, 50, titleColor, true, true, false, false)
    draw.RoundedBoxEx(8, x + 15, y + 40, self.panelWidth - 30, 25, Color(titleColor.r * 0.7, titleColor.g * 0.7, titleColor.b * 0.7, alpha), false, false, true, true)

    -- Title text with shadow
    draw.SimpleText("SHIP CORE MANAGEMENT SYSTEM", "DermaLarge", x + self.panelWidth/2 + 1, y + 41, Color(0, 0, 0, alpha * 0.5), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("SHIP CORE MANAGEMENT SYSTEM", "DermaLarge", x + self.panelWidth/2, y + 40, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Version and status info
    local versionText = "v2.1.0 Enhanced"
    draw.SimpleText(versionText, "DermaDefault", x + self.panelWidth - 20, y + 55, Color(200, 200, 200, alpha * 0.8), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    -- Enhanced tab navigation
    self:DrawTabs(x + 15, y + 75)

    -- Content area with smooth transitions
    local contentY = y + 120
    local contentAlpha = alpha

    if self.currentTab == "overview" then
        self:DrawOverviewTab(x + 25, contentY, contentAlpha)
    elseif self.currentTab == "resources" then
        self:DrawResourcesTab(x + 25, contentY, contentAlpha)
    elseif self.currentTab == "systems" then
        self:DrawSystemsTab(x + 25, contentY, contentAlpha)
    elseif self.currentTab == "cap" then
        self:DrawCAPTab(x + 25, contentY, contentAlpha)
    end

    -- Modern close button with hover effect
    local closeButtonColor = Color(200, 80, 80, alpha)
    self:DrawModernButton("✕", x + self.panelWidth - 50, y + 20, 35, 35, closeButtonColor, function()
        self:Close()
    end, "DermaLarge")

    -- Draw notifications
    self:DrawNotifications(scrW - 320, 50)

    -- Draw connection status indicator
    self:DrawConnectionStatus(x + 20, y + self.panelHeight - 30, alpha)
end

function shipCoreUI:DrawTabs(x, y)
    local tabWidth = 140
    local tabHeight = 35
    local tabSpacing = 8
    local tabs = {
        {name = "OVERVIEW", id = "overview", icon = "📊"},
        {name = "RESOURCES", id = "resources", icon = "⚡"},
        {name = "SYSTEMS", id = "systems", icon = "🛡️"}
    }

    -- Add CAP tab if CAP integration is active
    if self.data.capIntegrationActive then
        table.insert(tabs, {name = "CAP", id = "cap", icon = "🌟"})
    end

    for i, tab in ipairs(tabs) do
        local tabX = x + (i - 1) * (tabWidth + tabSpacing)
        local isActive = self.currentTab == tab.id

        -- Get animation data
        local anim = self.tabAnimations[tab.id] or {scale = 1.0, targetScale = 1.0}

        -- Calculate colors with animation
        local bgColor, textColor, borderColor

        if isActive then
            bgColor = Color(self.theme.accent.r, self.theme.accent.g, self.theme.accent.b, 200)
            textColor = Color(255, 255, 255, 255)
            borderColor = Color(255, 255, 255, 100)
        else
            bgColor = Color(60, 80, 120, 150)
            textColor = Color(200, 200, 200, 200)
            borderColor = Color(100, 120, 160, 80)
        end

        -- Special highlighting for emergency states
        if tab.id == "resources" and self.data.resourceEmergencyMode then
            local pulse = math.abs(math.sin(CurTime() * 4)) * 0.4 + 0.6
            bgColor = Color(255 * pulse, 100 * pulse, 100 * pulse, 200)
            textColor = Color(255, 255, 255, 255)
            borderColor = Color(255, 150, 150, 150)
        elseif tab.id == "systems" and (self.data.coreState == 4 or self.data.coreState == 3) then -- EMERGENCY or CRITICAL
            bgColor = Color(255, 150, 100, 180)
            borderColor = Color(255, 200, 150, 120)
        end

        -- Apply scale animation
        local scaledWidth = tabWidth * anim.scale
        local scaledHeight = tabHeight * anim.scale
        local scaleOffsetX = (tabWidth - scaledWidth) / 2
        local scaleOffsetY = (tabHeight - scaledHeight) / 2

        -- Draw tab with modern styling
        self:DrawModernTab(tab.name, tab.icon, tabX + scaleOffsetX, y + scaleOffsetY, scaledWidth, scaledHeight, bgColor, borderColor, textColor, function()
            -- Tab click animation
            anim.targetScale = 0.95
            timer.Simple(0.1, function()
                if self.tabAnimations[tab.id] then
                    self.tabAnimations[tab.id].targetScale = 1.0
                end
            end)

            -- Change tab with sound
            if self.currentTab ~= tab.id then
                if HYPERDRIVE.Sounds and HYPERDRIVE.Sounds.UI then
                    HYPERDRIVE.Sounds.UI.PlayClick()
                else
                    surface.PlaySound("buttons/button14.wav")
                end
                self.currentTab = tab.id

                -- Add notification for tab change
                self:AddNotification("Switched to " .. tab.name .. " tab", "info")
            end
        end, isActive)
    end
end

-- Modern tab drawing function
function shipCoreUI:DrawModernTab(text, icon, x, y, w, h, bgColor, borderColor, textColor, onClick, isActive)
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    local isHovered = mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h

    -- Hover effect
    if isHovered and not isActive then
        bgColor = Color(bgColor.r + 20, bgColor.g + 20, bgColor.b + 20, bgColor.a + 30)
        borderColor = Color(borderColor.r + 30, borderColor.g + 30, borderColor.b + 30, borderColor.a + 50)
    end

    -- Draw tab background with rounded corners
    draw.RoundedBoxEx(6, x, y, w, h, bgColor, true, true, not isActive, not isActive)

    -- Draw border
    if borderColor then
        draw.RoundedBoxEx(6, x, y, w, 2, borderColor, true, true, false, false)
        if not isActive then
            draw.RoundedBoxEx(6, x, y + h - 2, w, 2, borderColor, false, false, true, true)
        end
    end

    -- Draw icon and text
    local iconY = y + h/2 - 8
    local textY = y + h/2

    if icon then
        draw.SimpleText(icon, "DermaDefault", x + 15, iconY, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(text, "DermaDefaultBold", x + 35, textY, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText(text, "DermaDefaultBold", x + w/2, textY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Handle click
    if isHovered and input.IsMouseDown(MOUSE_LEFT) and CurTime() - self.lastUpdate > 0.2 then
        self.lastUpdate = CurTime()
        if onClick then onClick() end
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
    if self.data.coreState == 1 then stateColor = Color(100, 255, 100) -- ACTIVE
    elseif self.data.coreState == 3 then stateColor = Color(255, 150, 100) -- CRITICAL
    elseif self.data.coreState == 4 then stateColor = Color(255, 100, 100) -- EMERGENCY
    elseif self.data.coreState == 2 then stateColor = Color(255, 255, 100) -- INVALID
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
    if self.data.coreState == 4 then coreColor = Color(255, 100, 100) -- EMERGENCY
    elseif self.data.coreState == 3 then coreColor = Color(255, 150, 100) -- CRITICAL
    elseif self.data.coreState == 2 then coreColor = Color(255, 255, 100) -- INVALID
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
    if self.data.coreState == 4 then coreColor = Color(255, 100, 100) -- EMERGENCY
    elseif self.data.coreState == 3 then coreColor = Color(255, 150, 100) -- CRITICAL
    elseif self.data.coreState == 2 then coreColor = Color(255, 255, 100) -- INVALID
    end
    draw.SimpleText("Core: " .. (self.data.coreStateName or "Unknown"), "DermaDefault", x + 200, buttonY3 + 15, coreColor)
end

-- Modern button drawing with enhanced styling
function shipCoreUI:DrawModernButton(text, x, y, w, h, color, onClick, font, icon)
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    local isHovered = mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h

    font = font or "DermaDefault"

    -- Enhanced hover effects
    local bgColor = Color(color.r, color.g, color.b, color.a)
    local borderColor = Color(color.r + 40, color.g + 40, color.b + 40, 150)
    local textColor = Color(255, 255, 255, 255)

    if isHovered then
        bgColor = Color(color.r + 25, color.g + 25, color.b + 25, color.a + 20)
        borderColor = Color(255, 255, 255, 100)

        -- Add subtle glow effect
        draw.RoundedBox(8, x - 2, y - 2, w + 4, h + 4, Color(255, 255, 255, 30))
    end

    -- Draw button with modern styling
    draw.RoundedBox(6, x, y, w, h, bgColor)
    draw.RoundedBox(6, x, y, w, 2, borderColor) -- Top border
    draw.RoundedBox(6, x, y + h - 2, w, 2, Color(0, 0, 0, 100)) -- Bottom shadow

    -- Draw icon and text
    if icon then
        draw.SimpleText(icon, font, x + 10, y + h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(text, font, x + 30, y + h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText(text, font, x + w/2, y + h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Handle click with animation
    if isHovered and input.IsMouseDown(MOUSE_LEFT) and CurTime() - self.lastUpdate > 0.2 then
        self.lastUpdate = CurTime()

        -- Click animation
        draw.RoundedBox(6, x, y, w, h, Color(255, 255, 255, 50))

        -- Play click sound using sound system
        if HYPERDRIVE.Sounds and HYPERDRIVE.Sounds.UI then
            HYPERDRIVE.Sounds.UI.PlayClick()
        else
            surface.PlaySound("buttons/button9.wav")
        end

        if onClick then onClick() end
    end
end

-- Legacy button function for compatibility
function shipCoreUI:DrawButton(text, x, y, w, h, color, onClick, customTextColor)
    self:DrawModernButton(text, x, y, w, h, color, onClick, "DermaDefault")
end

-- Notification drawing system
function shipCoreUI:DrawNotifications(x, y)
    for i, notif in ipairs(self.notifications) do
        local notifY = y + notif.y
        local alpha = notif.alpha

        -- Notification background color based on type
        local bgColor = Color(60, 60, 60, alpha * 0.9)
        local borderColor = Color(100, 100, 100, alpha)
        local textColor = Color(255, 255, 255, alpha)

        if notif.type == "error" then
            bgColor = Color(120, 40, 40, alpha * 0.9)
            borderColor = Color(255, 100, 100, alpha)
        elseif notif.type == "warning" then
            bgColor = Color(120, 80, 40, alpha * 0.9)
            borderColor = Color(255, 200, 100, alpha)
        elseif notif.type == "success" then
            bgColor = Color(40, 120, 40, alpha * 0.9)
            borderColor = Color(100, 255, 100, alpha)
        end

        -- Draw notification
        local notifWidth = 300
        local notifHeight = 30

        draw.RoundedBox(6, x, notifY, notifWidth, notifHeight, bgColor)
        draw.RoundedBox(6, x, notifY, 4, notifHeight, borderColor)

        -- Notification icon
        local icon = "ℹ️"
        if notif.type == "error" then icon = "❌"
        elseif notif.type == "warning" then icon = "⚠️"
        elseif notif.type == "success" then icon = "✅"
        end

        draw.SimpleText(icon, "DermaDefault", x + 15, notifY + notifHeight/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(notif.text, "DermaDefault", x + 35, notifY + notifHeight/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

-- Connection status indicator
function shipCoreUI:DrawConnectionStatus(x, y, alpha)
    local isConnected = IsValid(self.entity)
    local statusText = isConnected and "CONNECTED" or "DISCONNECTED"
    local statusColor = isConnected and Color(100, 255, 100, alpha) or Color(255, 100, 100, alpha)
    local pingTime = math.floor((self.lastUpdate and (CurTime() - self.lastUpdate) * 1000) or 0)

    -- Connection indicator
    draw.RoundedBox(4, x, y, 120, 25, Color(40, 40, 40, alpha * 0.8))
    draw.SimpleText("STATUS: " .. statusText, "DermaDefault", x + 5, y + 12, statusColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

    if isConnected then
        draw.SimpleText("PING: " .. pingTime .. "ms", "DermaDefault", x + 130, y + 12, Color(200, 200, 200, alpha), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
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
    textEntry:RequestFocus()

    -- Character counter
    local counterLabel = vgui.Create("DLabel", frame)
    counterLabel:SetPos(20, 95)
    counterLabel:SetSize(410, 15)
    counterLabel:SetText("Characters: " .. string.len(currentName or "") .. "/" .. maxLength)

    -- Update counter on text change with length validation
    textEntry.OnTextChanged = function()
        local text = textEntry:GetValue()

        -- Enforce maximum length by truncating text
        if string.len(text) > maxLength then
            text = string.sub(text, 1, maxLength)
            textEntry:SetText(text)
            textEntry:SetCaretPos(maxLength)
        end

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

-- v2.2.0 Enhanced tab functions
function shipCoreUI:DrawFleetTab(x, y)
    -- Fleet Management Header
    draw.SimpleText("FLEET MANAGEMENT SYSTEM", "DermaDefaultBold", x, y, Color(100, 255, 150))

    local yPos = y + 30

    -- Fleet status
    local fleetID = self.entity:GetNWInt("FleetID", 0)
    local fleetName = self.entity:GetNWString("FleetName", "")
    local fleetRole = self.entity:GetNWString("FleetRole", "")

    if fleetID > 0 and fleetName ~= "" then
        -- In a fleet
        draw.SimpleText("Fleet: " .. fleetName, "DermaDefaultBold", x, yPos, Color(100, 255, 150))
        yPos = yPos + 20

        draw.SimpleText("Role: " .. fleetRole, "DermaDefault", x, yPos, Color(255, 255, 255))
        yPos = yPos + 20

        draw.SimpleText("Fleet ID: " .. fleetID, "DermaDefault", x, yPos, Color(200, 200, 200))
        yPos = yPos + 30

        -- Fleet commands
        draw.SimpleText("Fleet Commands:", "DermaDefaultBold", x, yPos, Color(100, 255, 150))
        yPos = yPos + 20

        draw.SimpleText("• hyperdrive_fleet_status - View fleet status", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
        yPos = yPos + 15

        draw.SimpleText("• hyperdrive_fleet_formation [type] - Change formation", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
        yPos = yPos + 15

    else
        -- Not in a fleet
        draw.SimpleText("Not in a fleet", "DermaDefaultBold", x, yPos, Color(255, 200, 100))
        yPos = yPos + 20

        draw.SimpleText("Create a fleet:", "DermaDefault", x, yPos, Color(255, 255, 255))
        yPos = yPos + 15

        draw.SimpleText("• hyperdrive_fleet_create [name] - Create new fleet", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
        yPos = yPos + 15
    end
end

function shipCoreUI:DrawAdminTab(x, y)
    -- Admin Panel Header
    draw.SimpleText("ADMIN CONTROL PANEL", "DermaDefaultBold", x, y, Color(255, 100, 100))

    local yPos = y + 30

    -- Check if player is admin
    if not LocalPlayer():IsAdmin() then
        draw.SimpleText("Access Denied - Admin Only", "DermaDefaultBold", x, yPos + 50, Color(255, 100, 100))
        return
    end

    -- System status
    draw.SimpleText("System Status:", "DermaDefaultBold", x, yPos, Color(255, 100, 100))
    yPos = yPos + 20

    -- Performance metrics
    local fps = math.floor(1 / FrameTime())
    local fpsColor = fps > 50 and Color(100, 255, 100) or (fps > 30 and Color(255, 200, 100) or Color(255, 100, 100))

    draw.SimpleText("Client FPS: " .. fps, "DermaDefault", x + 10, yPos, fpsColor)
    yPos = yPos + 15

    -- Entity counts
    local totalEnts = #ents.GetAll()
    draw.SimpleText("Total Entities: " .. totalEnts, "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 15

    local hyperdriveEnts = #ents.FindByClass("ship_core") + #ents.FindByClass("hyperdrive_engine") + #ents.FindByClass("hyperdrive_master_engine")
    draw.SimpleText("Hyperdrive Entities: " .. hyperdriveEnts, "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 25

    -- Admin commands
    draw.SimpleText("Admin Commands:", "DermaDefaultBold", x, yPos, Color(255, 100, 100))
    yPos = yPos + 20

    draw.SimpleText("• hyperdrive_admin status - System status", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 15

    draw.SimpleText("• hyperdrive_admin emergency_stop - Stop all engines", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 15

    draw.SimpleText("• hyperdrive_admin recharge_all - Recharge all engines", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 15

    draw.SimpleText("• hyperdrive_admin repair_all - Repair all systems", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 15

    draw.SimpleText("• hyperdrive_admin diagnostics - Run diagnostics", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 15
end

function shipCoreUI:DrawStargateTab(x, y)
    -- Stargate System Header
    draw.SimpleText("4-STAGE STARGATE SYSTEM", "DermaDefaultBold", x, y, Color(255, 200, 100))

    local yPos = y + 30

    -- Find nearby hyperdrive engine
    local nearbyEngine = nil
    local engines = {}
    table.Add(engines, ents.FindByClass("hyperdrive_engine"))
    table.Add(engines, ents.FindByClass("hyperdrive_master_engine"))

    for _, engine in ipairs(engines) do
        if IsValid(engine) and engine:GetPos():Distance(self.entity:GetPos()) < 500 then
            nearbyEngine = engine
            break
        end
    end

    if nearbyEngine then
        local stage = nearbyEngine:GetNWString("HyperdriveStage", "")
        local stageProgress = nearbyEngine:GetNWFloat("StageProgress", 0)
        local stageDescription = nearbyEngine:GetNWString("StageDescription", "")

        if stage ~= "" then
            -- Active sequence
            draw.SimpleText("Current Stage: " .. stage, "DermaDefaultBold", x, yPos, Color(255, 200, 100))
            yPos = yPos + 20

            if stageDescription ~= "" then
                draw.SimpleText(stageDescription, "DermaDefault", x, yPos, Color(255, 255, 255))
                yPos = yPos + 20
            end

            -- Progress bar
            local barW = 400
            local barH = 20
            draw.RoundedBox(4, x, yPos, barW, barH, Color(50, 50, 50, 200))
            draw.RoundedBox(4, x, yPos, barW * stageProgress, barH, Color(255, 200, 100, 200))

            draw.SimpleText(math.floor(stageProgress * 100) .. "%", "DermaDefault", x + barW/2, yPos + barH/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            yPos = yPos + 35

            -- Stage indicators
            local stages = {"Initiation", "Window Opening", "Hyperspace Travel", "Exit"}
            local currentStageIndex = 1

            for i, stageName in ipairs(stages) do
                if stageName == stage then
                    currentStageIndex = i
                    break
                end
            end

            draw.SimpleText("Sequence Progress:", "DermaDefaultBold", x, yPos, Color(255, 200, 100))
            yPos = yPos + 20

            for i, stageName in ipairs(stages) do
                local stageColor = Color(150, 150, 150)
                local prefix = "○"

                if i < currentStageIndex then
                    stageColor = Color(100, 255, 100)
                    prefix = "●"
                elseif i == currentStageIndex then
                    stageColor = Color(255, 200, 100)
                    prefix = "●"
                end

                draw.SimpleText(prefix .. " " .. stageName, "DermaDefault", x + 10, yPos, stageColor)
                yPos = yPos + 15
            end
        else
            -- No active sequence
            draw.SimpleText("No active sequence", "DermaDefault", x, yPos, Color(200, 200, 200))
            yPos = yPos + 25

            -- Stage descriptions
            draw.SimpleText("4-Stage Sequence:", "DermaDefaultBold", x, yPos, Color(255, 200, 100))
            yPos = yPos + 20

            draw.SimpleText("1. Initiation - Energy buildup and coordinate calculation", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
            yPos = yPos + 15

            draw.SimpleText("2. Window Opening - Blue/purple swirling energy tunnel", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
            yPos = yPos + 15

            draw.SimpleText("3. Hyperspace Travel - Stretched starlines and dimensional visuals", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
            yPos = yPos + 15

            draw.SimpleText("4. Exit - Flash of light and system stabilization", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
            yPos = yPos + 15
        end
    else
        draw.SimpleText("No hyperdrive engine detected", "DermaDefault", x, yPos, Color(255, 200, 100))
        yPos = yPos + 20

        draw.SimpleText("Place a hyperdrive engine within 500 units", "DermaDefault", x, yPos, Color(200, 200, 200))
    end
end

function shipCoreUI:DrawRealTimeTab(x, y)
    -- Real-Time Status Header
    draw.SimpleText("REAL-TIME SYSTEM STATUS", "DermaDefaultBold", x, y, Color(150, 255, 200))

    local yPos = y + 30

    -- Update indicator
    local timeSinceUpdate = CurTime() - self.lastRealTimeUpdate
    local updateColor = timeSinceUpdate < 1 and Color(100, 255, 100) or Color(255, 200, 100)

    draw.SimpleText("Last Update: " .. string.format("%.2fs ago", timeSinceUpdate), "DermaDefault", x, yPos, updateColor)
    yPos = yPos + 20

    -- Real-time metrics
    draw.SimpleText("Performance Metrics:", "DermaDefaultBold", x, yPos, Color(150, 255, 200))
    yPos = yPos + 20

    local fps = math.floor(1 / FrameTime())
    local fpsColor = fps > 50 and Color(100, 255, 100) or (fps > 30 and Color(255, 200, 100) or Color(255, 100, 100))

    draw.SimpleText("• Client FPS: " .. fps, "DermaDefault", x + 10, yPos, fpsColor)
    yPos = yPos + 15

    draw.SimpleText("• Update Rate: " .. math.floor(1 / self.updateRate) .. " FPS", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 25

    -- System alerts
    draw.SimpleText("System Alerts:", "DermaDefaultBold", x, yPos, Color(150, 255, 200))
    yPos = yPos + 20

    -- Check for alerts
    local alerts = {}

    -- Hull integrity alert
    local hullIntegrity = self.entity:GetNWFloat("HullIntegrity", 100)
    if hullIntegrity < 25 then
        table.insert(alerts, {text = "CRITICAL: Hull integrity at " .. math.floor(hullIntegrity) .. "%", color = Color(255, 100, 100)})
    elseif hullIntegrity < 50 then
        table.insert(alerts, {text = "WARNING: Hull integrity at " .. math.floor(hullIntegrity) .. "%", color = Color(255, 200, 100)})
    end

    -- Energy level alert
    local energyLevel = self.entity:GetNWFloat("EnergyLevel", 100)
    if energyLevel < 20 then
        table.insert(alerts, {text = "WARNING: Energy level at " .. math.floor(energyLevel) .. "%", color = Color(255, 200, 100)})
    end

    -- Display alerts
    if #alerts > 0 then
        for _, alert in ipairs(alerts) do
            draw.SimpleText("• " .. alert.text, "DermaDefault", x + 10, yPos, alert.color)
            yPos = yPos + 15
        end
    else
        draw.SimpleText("• All systems nominal", "DermaDefault", x + 10, yPos, Color(100, 255, 100))
        yPos = yPos + 15
    end

    yPos = yPos + 10

    -- Real-time data
    draw.SimpleText("Live Data Stream:", "DermaDefaultBold", x, yPos, Color(150, 255, 200))
    yPos = yPos + 20

    draw.SimpleText("• Hull: " .. math.floor(hullIntegrity) .. "%", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 15

    draw.SimpleText("• Energy: " .. math.floor(energyLevel) .. "%", "DermaDefault", x + 10, yPos, Color(255, 255, 255))
    yPos = yPos + 15

    local state = self.entity:GetNWInt("State", 0)
    local stateText = state == 1 and "ACTIVE" or (state == 2 and "CHARGING" or (state == 3 and "COOLDOWN" or (state == 4 and "EMERGENCY" or "OFFLINE")))
    local stateColor = state == 1 and Color(100, 255, 100) or (state == 4 and Color(255, 100, 100) or Color(255, 200, 100))

    draw.SimpleText("• Status: " .. stateText, "DermaDefault", x + 10, yPos, stateColor)
    yPos = yPos + 15
end

-- Update real-time data
hook.Add("Think", "ShipCoreRealTimeUpdate", function()
    if shipCoreUI.visible and shipCoreUI.realTimeMode then
        local currentTime = CurTime()
        if currentTime - shipCoreUI.lastRealTimeUpdate >= shipCoreUI.updateRate then
            shipCoreUI.lastRealTimeUpdate = currentTime

            -- Update real-time data here
            if IsValid(shipCoreUI.entity) then
                -- Trigger UI refresh for real-time tab
                if shipCoreUI.currentTab == "realtime" then
                    -- Real-time updates are handled in the draw function
                end
            end
        end
    end
end)

print("[Ship Core] Enhanced client-side UI v2.2.0 with Fleet, Admin, Stargate, and Real-Time features loaded")
