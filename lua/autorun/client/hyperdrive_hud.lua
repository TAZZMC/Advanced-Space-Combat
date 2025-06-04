-- Enhanced Hyperdrive HUD System v2.2.1
-- COMPLETE CODE UPDATE v2.2.1 - ALL SYSTEMS INTEGRATED WITH STEAM WORKSHOP
-- Real-time monitoring with comprehensive alerts, CAP Steam Workshop, and SB3 Steam Workshop features
if SERVER then return end

print("[Hyperdrive HUD] COMPLETE CODE UPDATE v2.2.1 - HUD System being updated")
print("[Hyperdrive HUD] Steam Workshop CAP and SB3 HUD integration active")

local hyperdriveHUD = {
    enabled = true,
    nearbyEngines = {},
    nearbyShipCores = {},
    lastScan = 0,
    scanInterval = 0.5, -- Scan every half second for better responsiveness
    animations = {},
    notifications = {},
    hudElements = {
        engineStatus = true,
        shipCoreStatus = true,
        jumpProgress = true,
        resourceLevels = true,
        capIntegration = true,
        shieldStatus = true,
        hullDamage = true,
        energyLevels = true,
        stargateStatus = true,
        systemAlerts = true,
        realTimeData = true
    },

    -- Real-time HUD enhancements
    realTimeConfig = {
        updateRate = 0.05, -- 20 FPS updates for real-time feel
        smoothTransitions = true,
        animatedBars = true,
        colorCoding = true,
        alertFlashing = true,
        soundAlerts = true,
        modernStyle = true,
        glassmorphism = true
    },

    -- Alert thresholds
    alertThresholds = {
        hull_critical = 25,
        hull_emergency = 10,
        energy_low = 20,
        shield_low = 30,
        resource_low = 15
    },

    -- Real-time data cache
    realTimeData = {
        lastUpdate = 0,
        shipStatus = {},
        engineStatus = {},
        shieldStatus = {},
        resourceStatus = {},
        capStatus = {},
        alerts = {}
    }
}

-- Use modern UI theme system
local function GetHUDColor(colorName, alpha)
    if HYPERDRIVE.UI and HYPERDRIVE.UI.GetColor then
        return HYPERDRIVE.UI.GetColor(colorName, alpha)
    end
    -- Fallback colors
    local fallbackColors = {
        Primary = Color(20, 30, 50, alpha or 200),
        Accent = Color(100, 150, 255, alpha or 255),
        Success = Color(100, 255, 100, alpha or 255),
        Warning = Color(255, 200, 100, alpha or 255),
        Error = Color(255, 100, 100, alpha or 255),
        Text = Color(255, 255, 255, alpha or 255),
        TextSecondary = Color(200, 200, 200, alpha or 200)
    }
    return fallbackColors[colorName] or Color(255, 255, 255, alpha or 255)
end

local function GetHUDFont(fontName)
    if HYPERDRIVE.UI and HYPERDRIVE.UI.GetFont then
        return HYPERDRIVE.UI.GetFont(fontName)
    end
    return "DermaDefault"
end

local function GetHUDScale(size)
    if HYPERDRIVE.UI and HYPERDRIVE.UI.Scale then
        return HYPERDRIVE.UI.Scale(size)
    end
    return size
end

local function IsUIEnabled()
    if HYPERDRIVE.UI and HYPERDRIVE.UI.Config then
        return HYPERDRIVE.UI.Config.ModernUIEnabled
    end
    return true
end

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
    if not IsUIEnabled() then return end

    local hudX, hudY = GetHUDScale(50), GetHUDScale(50)
    local hudW, hudH = GetHUDScale(350), GetHUDScale(200)

    -- Modern glassmorphism background
    if HYPERDRIVE.UI and HYPERDRIVE.UI.Config and HYPERDRIVE.UI.Config.GlassmorphismEnabled then
        draw.RoundedBox(12, hudX - 2, hudY - 2, hudW + 4, hudH + 4, Color(0, 0, 0, 100))
        draw.RoundedBox(12, hudX, hudY, hudW, hudH, GetHUDColor("Primary"))
        draw.RoundedBox(12, hudX, hudY, hudW, 3, GetHUDColor("Accent"))
    else
        draw.RoundedBox(8, hudX, hudY, hudW, hudH, GetHUDColor("Primary", 220))
        draw.RoundedBox(8, hudX, hudY, hudW, 2, GetHUDColor("Accent"))
    end

    -- Title with ship name
    local shipName = core:GetNWString("ShipName", "Unknown Ship")
    draw.SimpleText(shipName, GetHUDFont("Title"), hudX + hudW/2, hudY + GetHUDScale(20), GetHUDColor("Text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("SHIP CORE STATUS", GetHUDFont("Subtitle"), hudX + hudW/2, hudY + GetHUDScale(40), GetHUDColor("TextSecondary"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local yPos = hudY + GetHUDScale(60)

    -- Core status
    local coreState = core:GetNWInt("CoreState", 0)
    local stateText = "OPERATIONAL"
    local stateColor = GetHUDColor("Success")

    if coreState == 3 then -- EMERGENCY
        stateText = "EMERGENCY"
        stateColor = GetHUDColor("Error")
    elseif coreState == 2 then -- CRITICAL
        stateText = "CRITICAL"
        stateColor = GetHUDColor("Warning")
    end

    draw.SimpleText("Core Status: " .. stateText, GetHUDFont("Subtitle"), hudX + GetHUDScale(15), yPos, stateColor)
    yPos = yPos + GetHUDScale(20)

    -- Hull integrity
    if core:GetNWBool("HullSystemActive", false) then
        local hullIntegrity = core:GetNWFloat("HullIntegrity", 100)
        local hullColor = GetHUDColor("Success")
        if hullIntegrity < 25 then hullColor = GetHUDColor("Error")
        elseif hullIntegrity < 50 then hullColor = GetHUDColor("Warning")
        end

        draw.SimpleText("Hull Integrity: " .. math.floor(hullIntegrity) .. "%", GetHUDFont("Body"), hudX + GetHUDScale(15), yPos, hullColor)

        -- Hull bar
        self:DrawProgressBar(hudX + GetHUDScale(150), yPos - 2, GetHUDScale(180), GetHUDScale(12), hullIntegrity, 100, hullColor)
        yPos = yPos + GetHUDScale(20)
    end

    -- Shield status
    if core:GetNWBool("ShieldSystemActive", false) then
        local shieldStrength = core:GetNWFloat("ShieldStrength", 0)
        local shieldColor = GetHUDColor("Accent")
        if shieldStrength < 25 then shieldColor = GetHUDColor("Error")
        elseif shieldStrength < 50 then shieldColor = GetHUDColor("Warning")
        end

        draw.SimpleText("Shield Strength: " .. math.floor(shieldStrength) .. "%", GetHUDFont("Body"), hudX + GetHUDScale(15), yPos, shieldColor)

        -- Shield bar
        self:DrawProgressBar(hudX + GetHUDScale(150), yPos - 2, GetHUDScale(180), GetHUDScale(12), shieldStrength, 100, shieldColor)
        yPos = yPos + GetHUDScale(20)
    end

    -- CAP integration status
    if core:GetNWBool("CAPIntegrationActive", false) and self.hudElements.capIntegration then
        local capStatus = core:GetNWString("CAPStatus", "Unknown")
        draw.SimpleText("CAP Status: " .. capStatus, GetHUDFont("Body"), hudX + GetHUDScale(15), yPos, GetHUDColor("Accent"))
        yPos = yPos + GetHUDScale(15)

        -- CAP energy level
        local capEnergy = core:GetNWFloat("CAPEnergyLevel", 0)
        if capEnergy > 0 then
            draw.SimpleText("CAP Energy: " .. math.floor(capEnergy), GetHUDFont("Body"), hudX + GetHUDScale(15), yPos, GetHUDColor("Success"))
        end
    end
end

-- Modern engine status HUD
function hyperdriveHUD:DrawEngineStatusHUD(scrW, scrH)
    local hudX, hudY = scrW - 400, 50
    local hudW, hudH = 350, math.min(250, 80 + #self.nearbyEngines * 60)

    -- Modern background
    draw.RoundedBox(12, hudX - 2, hudY - 2, hudW + 4, hudH + 4, Color(0, 0, 0, 100))
    draw.RoundedBox(12, hudX, hudY, hudW, hudH, GetHUDColor("Primary"))
    draw.RoundedBox(12, hudX, hudY, hudW, 3, GetHUDColor("Accent"))

    -- Title
    draw.SimpleText("HYPERDRIVE ENGINES", GetHUDFont("Title"), hudX + hudW/2, hudY + 20, GetHUDColor("Text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local yPos = hudY + 50

    for i, engine in ipairs(self.nearbyEngines) do
        if not IsValid(engine) then continue end
        if i > 3 then break end -- Limit to 3 engines

        local distance = math.floor(engine:GetPos():Distance(LocalPlayer():GetPos()))
        local energy = engine:GetNWFloat("Energy", 0)
        local maxEnergy = engine:GetNWFloat("MaxEnergy", 1000)
        local energyPercent = (energy / maxEnergy) * 100

        -- Engine status
        local statusText = "READY"
        local statusColor = GetHUDColor("Success")

        if engine:GetNWBool("Charging", false) then
            statusText = "CHARGING"
            statusColor = GetHUDColor("Warning")
        elseif engine:GetNWFloat("Cooldown", 0) > CurTime() then
            statusText = "COOLDOWN"
            statusColor = GetHUDColor("Error")
        elseif energyPercent < 25 then
            statusText = "LOW ENERGY"
            statusColor = GetHUDColor("Error")
        end

        -- Engine info
        draw.SimpleText("Engine #" .. i .. " (" .. distance .. "m)", GetHUDFont("Subtitle"), hudX + 15, yPos, GetHUDColor("Text"))
        draw.SimpleText(statusText, GetHUDFont("Body"), hudX + hudW - 15, yPos, statusColor, TEXT_ALIGN_RIGHT)
        yPos = yPos + 18

        -- Energy bar
        local energyColor = GetHUDColor("Success")
        if energyPercent < 25 then energyColor = GetHUDColor("Error")
        elseif energyPercent < 50 then energyColor = GetHUDColor("Warning")
        end

        self:DrawProgressBar(hudX + 15, yPos, hudW - 30, 12, energyPercent, 100, energyColor)
        yPos = yPos + 25
    end
end

-- Modern progress bar
function hyperdriveHUD:DrawProgressBar(x, y, w, h, value, maxValue, color)
    local percentage = math.Clamp(value / maxValue, 0, 1)

    -- Background
    local bgColor = GetHUDColor("Background", 200)
    if HYPERDRIVE.UI and HYPERDRIVE.UI.Config and HYPERDRIVE.UI.Config.GlassmorphismEnabled then
        draw.RoundedBox(h/2, x, y, w, h, bgColor)
    else
        draw.RoundedBox(4, x, y, w, h, bgColor)
    end

    -- Fill
    if percentage > 0 then
        local fillW = (w - 2) * percentage
        local radius = HYPERDRIVE.UI and HYPERDRIVE.UI.Config and HYPERDRIVE.UI.Config.GlassmorphismEnabled and (h-2)/2 or 2
        draw.RoundedBox(radius, x + 1, y + 1, fillW, h - 2, color)
    end

    -- Percentage text
    local percentText = math.floor(percentage * 100) .. "%"
    draw.SimpleText(percentText, GetHUDFont("Small"), x + w/2, y + h/2, GetHUDColor("Text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
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
        local color = GetHUDColor("Accent")
        if engine:GetNWBool("Charging", false) then
            color = GetHUDColor("Warning")
            -- Add pulsing effect for charging
            local pulse = math.abs(math.sin(CurTime() * 4)) * 0.3 + 0.7
            color = Color(color.r * pulse, color.g * pulse, color.b * pulse, 255 * alpha)
        elseif engine:GetNWFloat("Cooldown", 0) > CurTime() then
            color = GetHUDColor("Error")
        end

        -- Draw modern indicator with glow
        draw.RoundedBox(6, screenPos.x - size/2 - 2, screenPos.y - size/2 - 2, size + 4, size + 4, Color(0, 0, 0, 100 * alpha))
        draw.RoundedBox(6, screenPos.x - size/2, screenPos.y - size/2, size, size, Color(color.r, color.g, color.b, 200 * alpha))
        draw.SimpleText("H", "DermaLarge", screenPos.x, screenPos.y, Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Enhanced distance and status text
        if distance < 100 then
            local statusText = string.format("%.0fm", distance)
            if engine:GetNWBool("Charging", false) then
                statusText = statusText .. " - CHARGING"
            elseif engine:GetNWFloat("Cooldown", 0) > CurTime() then
                statusText = statusText .. " - COOLDOWN"
            end

            draw.SimpleText(statusText, GetHUDFont("Body"), screenPos.x, screenPos.y + 20, Color(255, 255, 255, 200 * alpha), TEXT_ALIGN_CENTER)
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
    ply:ChatPrint("=== ADVANCED SPACE COMBAT HELP ===")
    ply:ChatPrint("• Use hyperdrive_toggle_hud to toggle HUD")
    ply:ChatPrint("• Use the ASC Hyperdrive tool to place engines")
    ply:ChatPrint("• Use placed engines to access interface")
    ply:ChatPrint("• Set destination by looking where you want to go")
    ply:ChatPrint("• Energy recharges automatically")
    ply:ChatPrint("• Longer jumps cost more energy")
    ply:ChatPrint("• Type !close in chat to close interface")
    ply:ChatPrint("• Use 'aria help' for ARIA-4 AI assistance")
end)

-- Real-time data update system
function hyperdriveHUD.UpdateRealTimeData()
    local currentTime = CurTime()

    if currentTime - hyperdriveHUD.realTimeData.lastUpdate < hyperdriveHUD.realTimeConfig.updateRate then
        return
    end

    hyperdriveHUD.realTimeData.lastUpdate = currentTime

    -- Update ship core data
    hyperdriveHUD.UpdateShipCoreData()

    -- Update engine data
    hyperdriveHUD.UpdateEngineData()

    -- Update shield data
    hyperdriveHUD.UpdateShieldData()

    -- Update resource data
    hyperdriveHUD.UpdateResourceData()

    -- Update CAP data
    hyperdriveHUD.UpdateCAPData()

    -- Check for alerts
    hyperdriveHUD.CheckSystemAlerts()
end

-- Update ship core real-time data
function hyperdriveHUD.UpdateShipCoreData()
    local shipCores = ents.FindByClass("ship_core")
    local nearbyCore = nil
    local minDist = 1000

    for _, core in ipairs(shipCores) do
        if IsValid(core) then
            local dist = LocalPlayer():GetPos():Distance(core:GetPos())
            if dist < minDist then
                minDist = dist
                nearbyCore = core
            end
        end
    end

    if IsValid(nearbyCore) then
        hyperdriveHUD.realTimeData.shipStatus = {
            entity = nearbyCore,
            name = nearbyCore:GetNWString("ShipName", "Unnamed Ship"),
            state = nearbyCore:GetNWInt("State", 0),
            hullIntegrity = nearbyCore:GetNWFloat("HullIntegrity", 100),
            energyLevel = nearbyCore:GetNWFloat("EnergyLevel", 100),
            shieldActive = nearbyCore:GetNWBool("ShieldActive", false),
            capActive = nearbyCore:GetNWBool("CAPIntegrationActive", false),
            distance = minDist
        }
    else
        hyperdriveHUD.realTimeData.shipStatus = {}
    end
end

-- Update engine real-time data
function hyperdriveHUD.UpdateEngineData()
    local engines = {}
    table.Add(engines, ents.FindByClass("hyperdrive_engine"))
    table.Add(engines, ents.FindByClass("hyperdrive_master_engine"))

    local nearbyEngine = nil
    local minDist = 1000

    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            local dist = LocalPlayer():GetPos():Distance(engine:GetPos())
            if dist < minDist then
                minDist = dist
                nearbyEngine = engine
            end
        end
    end

    if IsValid(nearbyEngine) then
        hyperdriveHUD.realTimeData.engineStatus = {
            entity = nearbyEngine,
            charging = nearbyEngine:GetNWBool("Charging", false),
            jumpReady = nearbyEngine:GetNWBool("JumpReady", false),
            cooldown = nearbyEngine:GetNWFloat("Cooldown", 0),
            energy = nearbyEngine:GetNWFloat("Energy", 0),
            maxEnergy = nearbyEngine:GetNWFloat("MaxEnergy", 1000),
            jumpProgress = nearbyEngine:GetNWFloat("JumpProgress", 0),
            stargateStage = nearbyEngine:GetNWString("HyperdriveStage", ""),
            stageProgress = nearbyEngine:GetNWFloat("StageProgress", 0),
            systemStatus = nearbyEngine:GetNWString("SystemStatus", "Unknown"),
            distance = minDist
        }
    else
        hyperdriveHUD.realTimeData.engineStatus = {}
    end
end

-- Update shield real-time data
function hyperdriveHUD.UpdateShieldData()
    local shields = ents.FindByClass("hyperdrive_shield_generator")
    local nearbyShield = nil
    local minDist = 1000

    for _, shield in ipairs(shields) do
        if IsValid(shield) then
            local dist = LocalPlayer():GetPos():Distance(shield:GetPos())
            if dist < minDist then
                minDist = dist
                nearbyShield = shield
            end
        end
    end

    if IsValid(nearbyShield) then
        hyperdriveHUD.realTimeData.shieldStatus = {
            entity = nearbyShield,
            active = nearbyShield:GetNWBool("ShieldActive", false),
            strength = nearbyShield:GetNWFloat("ShieldStrength", 0),
            maxStrength = nearbyShield:GetNWFloat("MaxShieldStrength", 100),
            recharging = nearbyShield:GetNWBool("ShieldRecharging", false),
            overloaded = nearbyShield:GetNWBool("ShieldOverloaded", false),
            distance = minDist
        }
    else
        hyperdriveHUD.realTimeData.shieldStatus = {}
    end
end

-- Update resource real-time data
function hyperdriveHUD.UpdateResourceData()
    local shipStatus = hyperdriveHUD.realTimeData.shipStatus

    if shipStatus.entity and IsValid(shipStatus.entity) then
        hyperdriveHUD.realTimeData.resourceStatus = {
            energy = shipStatus.entity:GetNWFloat("ResourceEnergy", 0),
            matter = shipStatus.entity:GetNWFloat("ResourceMatter", 0),
            oxygen = shipStatus.entity:GetNWFloat("ResourceOxygen", 0),
            coolant = shipStatus.entity:GetNWFloat("ResourceCoolant", 0),
            fuel = shipStatus.entity:GetNWFloat("ResourceFuel", 0),
            water = shipStatus.entity:GetNWFloat("ResourceWater", 0),
            nitrogen = shipStatus.entity:GetNWFloat("ResourceNitrogen", 0),
            maxEnergy = shipStatus.entity:GetNWFloat("MaxResourceEnergy", 1000),
            maxMatter = shipStatus.entity:GetNWFloat("MaxResourceMatter", 500),
            maxOxygen = shipStatus.entity:GetNWFloat("MaxResourceOxygen", 100),
            maxCoolant = shipStatus.entity:GetNWFloat("MaxResourceCoolant", 200),
            maxFuel = shipStatus.entity:GetNWFloat("MaxResourceFuel", 300),
            maxWater = shipStatus.entity:GetNWFloat("MaxResourceWater", 150),
            maxNitrogen = shipStatus.entity:GetNWFloat("MaxResourceNitrogen", 80),
            autoProvision = shipStatus.entity:GetNWBool("AutoProvisionEnabled", false),
            weldDetection = shipStatus.entity:GetNWBool("WeldDetectionEnabled", false)
        }
    else
        hyperdriveHUD.realTimeData.resourceStatus = {}
    end
end

-- Update CAP real-time data
function hyperdriveHUD.UpdateCAPData()
    local shipStatus = hyperdriveHUD.realTimeData.shipStatus

    if shipStatus.entity and IsValid(shipStatus.entity) then
        hyperdriveHUD.realTimeData.capStatus = {
            active = shipStatus.entity:GetNWBool("CAPIntegrationActive", false),
            shieldsDetected = shipStatus.entity:GetNWBool("CAPShieldsDetected", false),
            energyDetected = shipStatus.entity:GetNWBool("CAPEnergyDetected", false),
            resourcesDetected = shipStatus.entity:GetNWBool("CAPResourcesDetected", false),
            version = shipStatus.entity:GetNWString("CAPVersion", "Unknown"),
            status = shipStatus.entity:GetNWString("CAPStatus", "Unknown"),
            energyLevel = shipStatus.entity:GetNWFloat("CAPEnergyLevel", 0),
            shieldCount = shipStatus.entity:GetNWInt("CAPShieldCount", 0),
            entityCount = shipStatus.entity:GetNWInt("CAPEntityCount", 0),
            techLevel = shipStatus.entity:GetNWString("CAPTechLevel", "Unknown"),
            naquadahLevel = shipStatus.entity:GetNWFloat("CAPNaquadahLevel", 0),
            zpmPower = shipStatus.entity:GetNWFloat("CAPZPMPower", 0)
        }
    else
        hyperdriveHUD.realTimeData.capStatus = {}
    end
end

-- Check for system alerts
function hyperdriveHUD.CheckSystemAlerts()
    local alerts = {}
    local shipStatus = hyperdriveHUD.realTimeData.shipStatus
    local engineStatus = hyperdriveHUD.realTimeData.engineStatus
    local shieldStatus = hyperdriveHUD.realTimeData.shieldStatus
    local resourceStatus = hyperdriveHUD.realTimeData.resourceStatus

    -- Hull integrity alerts
    if shipStatus.hullIntegrity then
        if shipStatus.hullIntegrity <= hyperdriveHUD.alertThresholds.hull_emergency then
            table.insert(alerts, {type = "emergency", message = "HULL BREACH CRITICAL", color = Color(255, 50, 50)})
        elseif shipStatus.hullIntegrity <= hyperdriveHUD.alertThresholds.hull_critical then
            table.insert(alerts, {type = "critical", message = "Hull Damage Critical", color = Color(255, 150, 50)})
        end
    end

    -- Energy alerts
    if shipStatus.energyLevel then
        if shipStatus.energyLevel <= hyperdriveHUD.alertThresholds.energy_low then
            table.insert(alerts, {type = "warning", message = "Energy Levels Low", color = Color(255, 255, 50)})
        end
    end

    -- Engine alerts
    if engineStatus.entity and IsValid(engineStatus.entity) then
        local energyPercent = (engineStatus.energy / engineStatus.maxEnergy) * 100
        if energyPercent <= 10 then
            table.insert(alerts, {type = "critical", message = "Hyperdrive Energy Critical", color = Color(255, 100, 100)})
        elseif energyPercent <= 25 then
            table.insert(alerts, {type = "warning", message = "Hyperdrive Energy Low", color = Color(255, 200, 100)})
        end

        -- System status alerts
        local systemStatus = engineStatus.systemStatus
        if systemStatus == "Emergency" then
            table.insert(alerts, {type = "emergency", message = "HYPERDRIVE EMERGENCY", color = Color(255, 0, 0)})
        elseif systemStatus == "Critical" then
            table.insert(alerts, {type = "critical", message = "Hyperdrive System Critical", color = Color(255, 100, 100)})
        end
    end

    -- Shield alerts
    if shieldStatus.entity and IsValid(shieldStatus.entity) then
        if shieldStatus.active then
            local shieldPercent = (shieldStatus.strength / shieldStatus.maxStrength) * 100
            if shieldPercent <= hyperdriveHUD.alertThresholds.shield_low then
                table.insert(alerts, {type = "warning", message = "Shield Strength Low", color = Color(100, 150, 255)})
            end

            if shieldStatus.overloaded then
                table.insert(alerts, {type = "critical", message = "Shield System Overloaded", color = Color(255, 100, 100)})
            end
        end
    end

    -- Resource alerts
    if resourceStatus.energy and resourceStatus.maxEnergy then
        local energyPercent = (resourceStatus.energy / resourceStatus.maxEnergy) * 100
        if energyPercent <= hyperdriveHUD.alertThresholds.resource_low then
            table.insert(alerts, {type = "warning", message = "Resource Energy Low", color = Color(255, 200, 50)})
        end
    end

    if resourceStatus.oxygen and resourceStatus.maxOxygen then
        local oxygenPercent = (resourceStatus.oxygen / resourceStatus.maxOxygen) * 100
        if oxygenPercent <= 10 then
            table.insert(alerts, {type = "critical", message = "Oxygen Critical", color = Color(255, 100, 100)})
        elseif oxygenPercent <= 25 then
            table.insert(alerts, {type = "warning", message = "Oxygen Low", color = Color(255, 200, 100)})
        end
    end

    if resourceStatus.coolant and resourceStatus.maxCoolant then
        local coolantPercent = (resourceStatus.coolant / resourceStatus.maxCoolant) * 100
        if coolantPercent <= 10 then
            table.insert(alerts, {type = "warning", message = "Coolant Low", color = Color(100, 200, 255)})
        end
    end

    hyperdriveHUD.realTimeData.alerts = alerts

    -- Play alert sounds if enabled
    if hyperdriveHUD.realTimeConfig.soundAlerts and #alerts > 0 then
        for _, alert in ipairs(alerts) do
            if alert.type == "emergency" and HYPERDRIVE.Sounds then
                HYPERDRIVE.Sounds.PlayAlert("emergency", nil, {volume = 0.5})
            elseif alert.type == "critical" and HYPERDRIVE.Sounds then
                HYPERDRIVE.Sounds.PlayAlert("critical", nil, {volume = 0.4})
            elseif alert.type == "warning" and HYPERDRIVE.Sounds then
                HYPERDRIVE.Sounds.PlayAlert("warning", nil, {volume = 0.3})
            end
        end
    end
end

-- Real-time HUD update hook
hook.Add("Think", "HyperdriveRealTimeHUD", function()
    if hyperdriveHUD.enabled and hyperdriveHUD.hudElements.realTimeData then
        hyperdriveHUD.UpdateRealTimeData()
    end
end)

print("[Hyperdrive] Enhanced Real-time HUD system v2.2.0 loaded with comprehensive monitoring")
