-- Enhanced Hyperdrive HUD System v2.1.0
if SERVER then return end

local hyperdriveHUD = {
    enabled = true,
    nearbyEngines = {},
    nearbyShipCores = {},
    lastScan = 0,
    scanInterval = 0.5, -- Scan every half second for better responsiveness
    animations = {},
    notifications = {},
    theme = {
        primary = Color(20, 30, 50, 200),
        accent = Color(100, 150, 255, 255),
        success = Color(100, 255, 100, 255),
        warning = Color(255, 200, 100, 255),
        error = Color(255, 100, 100, 255),
        text = Color(255, 255, 255, 255),
        textSecondary = Color(200, 200, 200, 200)
    },
    hudElements = {
        engineStatus = true,
        shipCoreStatus = true,
        jumpProgress = true,
        resourceLevels = true,
        capIntegration = true
    }
}

-- ConVar for enabling/disabling HUD
CreateClientConVar("hyperdrive_hud_enabled", "1", true, false, "Enable/disable hyperdrive HUD")

-- Scan for nearby hyperdrive engines
local function ScanForEngines()
    if CurTime() - hyperdriveHUD.lastScan < hyperdriveHUD.scanInterval then return end
    hyperdriveHUD.lastScan = CurTime()

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    hyperdriveHUD.nearbyEngines = {}

    -- Find all hyperdrive engines
    for _, ent in ipairs(ents.FindByClass("hyperdrive_engine")) do
        if IsValid(ent) and ent:GetPos():Distance(ply:GetPos()) < 1000 then
            table.insert(hyperdriveHUD.nearbyEngines, ent)
        end
    end
end

-- Enhanced HUD drawing function with modern styling
local function DrawHyperdriveHUD()
    if not GetConVar("hyperdrive_hud_enabled"):GetBool() then return end
    if not hyperdriveHUD.enabled then return end

    -- Scan for nearby engines and ship cores periodically
    if CurTime() - hyperdriveHUD.lastScan > hyperdriveHUD.scanInterval then
        hyperdriveHUD:ScanNearbyEntities()
        hyperdriveHUD.lastScan = CurTime()
    end

    -- Draw different HUD elements based on what's nearby
    local scrW, scrH = ScrW(), ScrH()

    -- Draw ship core HUD if on a ship
    if #hyperdriveHUD.nearbyShipCores > 0 and hyperdriveHUD.hudElements.shipCoreStatus then
        hyperdriveHUD:DrawShipCoreHUD(scrW, scrH)
    end

    -- Draw engine status if near engines
    if #hyperdriveHUD.nearbyEngines > 0 and hyperdriveHUD.hudElements.engineStatus then
        hyperdriveHUD:DrawEngineStatusHUD(scrW, scrH)
    end

    -- Draw notifications
    hyperdriveHUD:DrawNotifications(scrW, scrH)
end

-- Enhanced entity scanning
function hyperdriveHUD:ScanNearbyEntities()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    self.nearbyEngines = {}
    self.nearbyShipCores = {}

    -- Find all hyperdrive engines
    for _, ent in ipairs(ents.FindByClass("hyperdrive_engine")) do
        if IsValid(ent) and ent:GetPos():Distance(ply:GetPos()) < 1000 then
            table.insert(self.nearbyEngines, ent)
        end
    end

    -- Find all ship cores
    for _, ent in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(ent) and ent:GetPos():Distance(ply:GetPos()) < 500 then
            table.insert(self.nearbyShipCores, ent)
        end
    end
end

-- Modern ship core HUD
function hyperdriveHUD:DrawShipCoreHUD(scrW, scrH)
    local core = self.nearbyShipCores[1]
    if not IsValid(core) then return end

    local hudX, hudY = 50, 50
    local hudW, hudH = 350, 200

    -- Modern glassmorphism background
    draw.RoundedBox(12, hudX - 2, hudY - 2, hudW + 4, hudH + 4, Color(0, 0, 0, 100))
    draw.RoundedBox(12, hudX, hudY, hudW, hudH, self.theme.primary)
    draw.RoundedBox(12, hudX, hudY, hudW, 3, self.theme.accent)

    -- Title with ship name
    local shipName = core:GetNWString("ShipName", "Unknown Ship")
    draw.SimpleText(shipName, "DermaLarge", hudX + hudW/2, hudY + 20, self.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("SHIP CORE STATUS", "DermaDefaultBold", hudX + hudW/2, hudY + 40, self.theme.textSecondary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local yPos = hudY + 60

    -- Core status
    local coreState = core:GetNWInt("CoreState", 0)
    local stateText = "OPERATIONAL"
    local stateColor = self.theme.success

    if coreState == 3 then -- EMERGENCY
        stateText = "EMERGENCY"
        stateColor = self.theme.error
    elseif coreState == 2 then -- CRITICAL
        stateText = "CRITICAL"
        stateColor = self.theme.warning
    end

    draw.SimpleText("Core Status: " .. stateText, "DermaDefaultBold", hudX + 15, yPos, stateColor)
    yPos = yPos + 20

    -- Hull integrity
    if core:GetNWBool("HullSystemActive", false) then
        local hullIntegrity = core:GetNWFloat("HullIntegrity", 100)
        local hullColor = self.theme.success
        if hullIntegrity < 25 then hullColor = self.theme.error
        elseif hullIntegrity < 50 then hullColor = self.theme.warning
        end

        draw.SimpleText("Hull Integrity: " .. math.floor(hullIntegrity) .. "%", "DermaDefault", hudX + 15, yPos, hullColor)

        -- Hull bar
        self:DrawProgressBar(hudX + 150, yPos - 2, 180, 12, hullIntegrity, 100, hullColor)
        yPos = yPos + 20
    end

    -- Shield status
    if core:GetNWBool("ShieldSystemActive", false) then
        local shieldStrength = core:GetNWFloat("ShieldStrength", 0)
        local shieldColor = self.theme.accent
        if shieldStrength < 25 then shieldColor = self.theme.error
        elseif shieldStrength < 50 then shieldColor = self.theme.warning
        end

        draw.SimpleText("Shield Strength: " .. math.floor(shieldStrength) .. "%", "DermaDefault", hudX + 15, yPos, shieldColor)

        -- Shield bar
        self:DrawProgressBar(hudX + 150, yPos - 2, 180, 12, shieldStrength, 100, shieldColor)
        yPos = yPos + 20
    end

    -- CAP integration status
    if core:GetNWBool("CAPIntegrationActive", false) and self.hudElements.capIntegration then
        local capStatus = core:GetNWString("CAPStatus", "Unknown")
        draw.SimpleText("CAP Status: " .. capStatus, "DermaDefault", hudX + 15, yPos, self.theme.accent)
        yPos = yPos + 15

        -- CAP energy level
        local capEnergy = core:GetNWFloat("CAPEnergyLevel", 0)
        if capEnergy > 0 then
            draw.SimpleText("CAP Energy: " .. math.floor(capEnergy), "DermaDefault", hudX + 15, yPos, self.theme.success)
        end
    end
end

-- Modern engine status HUD
function hyperdriveHUD:DrawEngineStatusHUD(scrW, scrH)
    local hudX, hudY = scrW - 400, 50
    local hudW, hudH = 350, math.min(250, 80 + #self.nearbyEngines * 60)

    -- Modern background
    draw.RoundedBox(12, hudX - 2, hudY - 2, hudW + 4, hudH + 4, Color(0, 0, 0, 100))
    draw.RoundedBox(12, hudX, hudY, hudW, hudH, self.theme.primary)
    draw.RoundedBox(12, hudX, hudY, hudW, 3, self.theme.accent)

    -- Title
    draw.SimpleText("HYPERDRIVE ENGINES", "DermaLarge", hudX + hudW/2, hudY + 20, self.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local yPos = hudY + 50

    for i, engine in ipairs(self.nearbyEngines) do
        if not IsValid(engine) then continue end
        if i > 3 then break end -- Limit to 3 engines

        local distance = math.floor(engine:GetPos():Distance(LocalPlayer():GetPos()))
        local energy = engine:GetEnergy() or 0
        local maxEnergy = engine:GetMaxEnergy() or 1000
        local energyPercent = (energy / maxEnergy) * 100

        -- Engine status
        local statusText = "READY"
        local statusColor = self.theme.success

        if engine:GetCharging() then
            statusText = "CHARGING"
            statusColor = self.theme.warning
        elseif engine:IsOnCooldown() then
            statusText = "COOLDOWN"
            statusColor = self.theme.error
        elseif energyPercent < 25 then
            statusText = "LOW ENERGY"
            statusColor = self.theme.error
        end

        -- Engine info
        draw.SimpleText("Engine #" .. i .. " (" .. distance .. "m)", "DermaDefaultBold", hudX + 15, yPos, self.theme.text)
        draw.SimpleText(statusText, "DermaDefault", hudX + hudW - 15, yPos, statusColor, TEXT_ALIGN_RIGHT)
        yPos = yPos + 18

        -- Energy bar
        local energyColor = self.theme.success
        if energyPercent < 25 then energyColor = self.theme.error
        elseif energyPercent < 50 then energyColor = self.theme.warning
        end

        self:DrawProgressBar(hudX + 15, yPos, hudW - 30, 12, energyPercent, 100, energyColor)
        yPos = yPos + 25
    end
end

-- Modern progress bar
function hyperdriveHUD:DrawProgressBar(x, y, w, h, value, maxValue, color)
    local percentage = math.Clamp(value / maxValue, 0, 1)

    -- Background
    draw.RoundedBox(h/2, x, y, w, h, Color(40, 40, 40, 200))

    -- Fill
    if percentage > 0 then
        local fillW = (w - 2) * percentage
        draw.RoundedBox((h-2)/2, x + 1, y + 1, fillW, h - 2, color)
    end

    -- Percentage text
    local percentText = math.floor(percentage * 100) .. "%"
    draw.SimpleText(percentText, "DermaDefault", x + w/2, y + h/2, self.theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Notification drawing system
function hyperdriveHUD:DrawNotifications(scrW, scrH)
    for i, notif in ipairs(self.notifications) do
        local notifY = 50 + (i - 1) * 35
        local alpha = notif.alpha or 255

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
        local notifX = scrW - notifWidth - 20

        draw.RoundedBox(6, notifX, notifY, notifWidth, notifHeight, bgColor)
        draw.RoundedBox(6, notifX, notifY, 4, notifHeight, borderColor)

        -- Notification icon
        local icon = "ℹ️"
        if notif.type == "error" then icon = "❌"
        elseif notif.type == "warning" then icon = "⚠️"
        elseif notif.type == "success" then icon = "✅"
        end

        draw.SimpleText(icon, "DermaDefault", notifX + 15, notifY + notifHeight/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(notif.text, "DermaDefault", notifX + 35, notifY + notifHeight/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
end

-- Enhanced crosshair indicators for hyperdrive engines
local function DrawEngineIndicators()
    if not GetConVar("hyperdrive_hud_enabled"):GetBool() then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    for _, engine in ipairs(hyperdriveHUD.nearbyEngines) do
        if not IsValid(engine) then continue end

        local distance = engine:GetPos():Distance(ply:GetPos())
        if distance > 200 then continue end -- Only show for very close engines

        local screenPos = engine:GetPos():ToScreen()
        if not screenPos.visible then continue end

        local alpha = math.max(0, 1 - (distance / 200))
        local size = 25 * alpha

        -- Enhanced indicator with modern styling
        local color = hyperdriveHUD.theme.accent
        if engine:GetCharging() then
            color = hyperdriveHUD.theme.warning
            -- Add pulsing effect for charging
            local pulse = math.abs(math.sin(CurTime() * 4)) * 0.3 + 0.7
            color = Color(color.r * pulse, color.g * pulse, color.b * pulse, 255 * alpha)
        elseif engine:IsOnCooldown() then
            color = hyperdriveHUD.theme.error
        end

        -- Draw modern indicator with glow
        draw.RoundedBox(6, screenPos.x - size/2 - 2, screenPos.y - size/2 - 2, size + 4, size + 4, Color(0, 0, 0, 100 * alpha))
        draw.RoundedBox(6, screenPos.x - size/2, screenPos.y - size/2, size, size, Color(color.r, color.g, color.b, 200 * alpha))
        draw.SimpleText("H", "DermaLarge", screenPos.x, screenPos.y, Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Enhanced distance and status text
        if distance < 100 then
            local statusText = string.format("%.0fm", distance)
            if engine:GetCharging() then
                statusText = statusText .. " - CHARGING"
            elseif engine:IsOnCooldown() then
                statusText = statusText .. " - COOLDOWN"
            end

            draw.SimpleText(statusText, "DermaDefault", screenPos.x, screenPos.y + 20, Color(255, 255, 255, 200 * alpha), TEXT_ALIGN_CENTER)
        end
    end
end

-- Hook into HUD painting
hook.Add("HUDPaint", "HyperdriveHUD", function()
    DrawHyperdriveHUD()
    DrawEngineIndicators()
end)

-- Console command to toggle HUD
concommand.Add("hyperdrive_toggle_hud", function()
    local enabled = GetConVar("hyperdrive_hud_enabled"):GetBool()
    RunConsoleCommand("hyperdrive_hud_enabled", enabled and "0" or "1")
    LocalPlayer():ChatPrint("[Hyperdrive] HUD " .. (enabled and "disabled" or "enabled"))
end)

-- Help command
concommand.Add("hyperdrive_help", function()
    local ply = LocalPlayer()
    ply:ChatPrint("=== HYPERDRIVE HELP ===")
    ply:ChatPrint("• Use hyperdrive_toggle_hud to toggle HUD")
    ply:ChatPrint("• Use the Hyperdrive tool to place engines")
    ply:ChatPrint("• Use placed engines to access interface")
    ply:ChatPrint("• Set destination by looking where you want to go")
    ply:ChatPrint("• Energy recharges automatically")
    ply:ChatPrint("• Longer jumps cost more energy")
    ply:ChatPrint("• Type !close in chat to close interface")
end)
