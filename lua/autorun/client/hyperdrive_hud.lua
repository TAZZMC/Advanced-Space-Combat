-- Hyperdrive HUD System
if SERVER then return end

local hyperdriveHUD = {
    enabled = true,
    nearbyEngines = {},
    lastScan = 0,
    scanInterval = 1, -- Scan every second
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

-- Draw hyperdrive status HUD
local function DrawHyperdriveHUD()
    if not GetConVar("hyperdrive_hud_enabled"):GetBool() then return end
    if not hyperdriveHUD.enabled then return end

    ScanForEngines()

    if #hyperdriveHUD.nearbyEngines == 0 then return end

    local ply = LocalPlayer()
    local scrW, scrH = ScrW(), ScrH()
    local hudX, hudY = 20, scrH - 200
    local hudW, hudH = 300, 150

    -- Background
    draw.RoundedBox(8, hudX, hudY, hudW, hudH, Color(0, 0, 0, 150))
    draw.RoundedBox(8, hudX + 2, hudY + 2, hudW - 4, hudH - 4, Color(20, 40, 60, 200))

    -- Title
    draw.SimpleText("HYPERDRIVE STATUS", "DermaDefault", hudX + 10, hudY + 10, Color(100, 200, 255))

    local yOffset = 35

    for i, engine in ipairs(hyperdriveHUD.nearbyEngines) do
        if not IsValid(engine) then continue end
        if i > 3 then break end -- Limit to 3 engines

        local distance = engine:GetPos():Distance(ply:GetPos())
        local energyPercent = engine:GetEnergyPercent()

        -- Engine info
        local engineText = string.format("Engine #%d (%.0fm)", i, distance)
        draw.SimpleText(engineText, "DermaDefaultBold", hudX + 10, hudY + yOffset, Color(255, 255, 255))

        -- Energy bar
        local barW, barH = hudW - 40, 12
        local barX, barY = hudX + 20, hudY + yOffset + 18

        draw.RoundedBox(2, barX, barY, barW, barH, Color(50, 50, 50))

        local energyColor = Color(0, 150, 255)
        if energyPercent < 25 then
            energyColor = Color(255, 100, 0)
        elseif energyPercent < 50 then
            energyColor = Color(255, 200, 0)
        end

        draw.RoundedBox(2, barX + 1, barY + 1, (barW - 2) * (energyPercent / 100), barH - 2, energyColor)

        -- Status text with Stargate integration
        local status = "Ready"
        local statusColor = Color(0, 255, 0)

        -- Check for Stargate 4-stage travel
        if HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.Client and HYPERDRIVE.Stargate.Client.CurrentStage > 0 then
            local stageName = HYPERDRIVE.Stargate.Client.StageNames[HYPERDRIVE.Stargate.Client.CurrentStage] or "UNKNOWN"
            status = "SG: " .. stageName
            statusColor = Color(100, 150, 255)
        elseif engine:GetCharging() then
            status = "CHARGING"
            statusColor = Color(255, 255, 0)
        elseif engine:IsOnCooldown() then
            status = string.format("Cooldown %.1fs", engine:GetCooldownRemaining())
            statusColor = Color(255, 100, 0)
        elseif engine:GetDestination() == Vector(0, 0, 0) then
            status = "No Destination"
            statusColor = Color(255, 0, 0)
        end

        draw.SimpleText(status, "DermaDefault", barX, barY + 15, statusColor)

        -- Draw Stargate stage progress bar if active
        if HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.Client and HYPERDRIVE.Stargate.Client.CurrentStage > 0 then
            local timeSinceStage = CurTime() - HYPERDRIVE.Stargate.Client.StageStartTime
            local progress = math.Clamp(timeSinceStage / (HYPERDRIVE.Stargate.Client.StageDuration or 1), 0, 1)

            local stageBarY = barY + 30
            draw.RoundedBox(2, barX, stageBarY, barW, 8, Color(30, 30, 30))
            draw.RoundedBox(2, barX + 1, stageBarY + 1, (barW - 2) * progress, 6, Color(100, 150, 255))

            -- Stage indicator
            local stageText = string.format("Stage %d/4", HYPERDRIVE.Stargate.Client.CurrentStage)
            draw.SimpleText(stageText, "DermaDefault", barX, stageBarY + 10, Color(100, 150, 255))
        end

        yOffset = yOffset + 45
    end

    -- Instructions
    if #hyperdriveHUD.nearbyEngines > 0 then
        draw.SimpleText("Use engine to access interface", "DermaDefault", hudX + 10, hudY + hudH - 20, Color(200, 200, 200))
    end
end

-- Draw crosshair indicators for hyperdrive engines
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
        local size = 20 * alpha

        -- Draw indicator
        local color = Color(100, 200, 255, 255 * alpha)
        if engine:GetCharging() then
            color = Color(255, 255, 0, 255 * alpha)
        elseif engine:IsOnCooldown() then
            color = Color(255, 100, 0, 255 * alpha)
        end

        draw.RoundedBox(4, screenPos.x - size/2, screenPos.y - size/2, size, size, color)
        draw.SimpleText("H", "DermaDefaultBold", screenPos.x, screenPos.y, Color(255, 255, 255, 255 * alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Distance text
        if distance < 100 then
            draw.SimpleText(string.format("%.0fm", distance), "DermaDefault", screenPos.x, screenPos.y + 15, Color(255, 255, 255, 200 * alpha), TEXT_ALIGN_CENTER)
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
