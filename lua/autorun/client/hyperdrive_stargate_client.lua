-- Stargate Hyperdrive Client-Side Effects
-- Handles 4-stage travel visual effects and notifications

HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Stargate = HYPERDRIVE.Stargate or {}
HYPERDRIVE.Stargate.Client = {}

-- Client-side configuration
HYPERDRIVE.Stargate.Client.Config = {
    ShowStageNotifications = true,
    StarlineIntensity = 1.0,
    HyperspaceOverlay = true,
    DimensionalEffects = true,
    ScreenEffects = true
}

-- Stage notification system
HYPERDRIVE.Stargate.Client.CurrentStage = 0
HYPERDRIVE.Stargate.Client.StageStartTime = 0
HYPERDRIVE.Stargate.Client.StageDuration = 0
HYPERDRIVE.Stargate.Client.StageProgress = 0
HYPERDRIVE.Stargate.Client.TotalStages = 4
HYPERDRIVE.Stargate.Client.StageData = {}

-- Enhanced stage tracking
HYPERDRIVE.Stargate.Client.StageNames = {
    [1] = "INITIATION",
    [2] = "WINDOW OPENING",
    [3] = "HYPERSPACE TRAVEL",
    [4] = "EXIT STABILIZATION"
}

HYPERDRIVE.Stargate.Client.StageDescriptions = {
    [1] = "Charging hyperdrive and calculating coordinates...",
    [2] = "Opening hyperspace window...",
    [3] = "Traveling through hyperspace...",
    [4] = "Exiting hyperspace and stabilizing systems..."
}

-- Network message handlers
net.Receive("hyperdrive_sg_starlines", function()
    -- Create starline effects for the local player
    HYPERDRIVE.Stargate.Client.CreateStarlineEffects()
end)

-- Enhanced stage update handler
net.Receive("hyperdrive_sg_stage_update", function()
    local stage = net.ReadInt(8)
    local duration = net.ReadFloat()
    local techLevel = net.ReadString()
    local efficiency = net.ReadFloat()

    HYPERDRIVE.Stargate.Client.CurrentStage = stage
    HYPERDRIVE.Stargate.Client.StageStartTime = CurTime()
    HYPERDRIVE.Stargate.Client.StageDuration = duration
    HYPERDRIVE.Stargate.Client.StageProgress = 0

    HYPERDRIVE.Stargate.Client.StageData = {
        techLevel = techLevel,
        efficiency = efficiency,
        startTime = CurTime()
    }

    -- Play stage notification sound
    if HYPERDRIVE.Stargate.Client.Config.ShowStageNotifications then
        surface.PlaySound("ambient/energy/spark" .. math.random(1, 6) .. ".wav")

        -- Show stage notification
        local stageName = HYPERDRIVE.Stargate.Client.StageNames[stage] or "UNKNOWN"
        local description = HYPERDRIVE.Stargate.Client.StageDescriptions[stage] or ""

        chat.AddText(
            Color(100, 150, 255), "[Stargate Hyperdrive] ",
            Color(255, 255, 0), "Stage " .. stage .. "/4: ",
            Color(255, 255, 255), stageName
        )

        if description ~= "" then
            chat.AddText(Color(200, 200, 200), description)
        end
    end
end)

-- Create starline effects
function HYPERDRIVE.Stargate.Client.CreateStarlineEffects()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- Create starline effect at player position
    local effectData = EffectData()
    effectData:SetOrigin(ply:GetPos())
    effectData:SetMagnitude(HYPERDRIVE.Stargate.Client.Config.StarlineIntensity)
    effectData:SetScale(1.0)
    util.Effect("hyperdrive_sg_starlines", effectData)

    -- Start hyperspace overlay
    if HYPERDRIVE.Stargate.Client.Config.HyperspaceOverlay then
        HYPERDRIVE.Stargate.Client.StartHyperspaceOverlay()
    end
end

-- Start hyperspace overlay effect
function HYPERDRIVE.Stargate.Client.StartHyperspaceOverlay()
    HYPERDRIVE.Stargate.Client.HyperspaceOverlayActive = true
    HYPERDRIVE.Stargate.Client.HyperspaceStartTime = CurTime()

    -- Create screen distortion effect
    if HYPERDRIVE.Stargate.Client.Config.ScreenEffects then
        HYPERDRIVE.Stargate.Client.CreateScreenEffects()
    end
end

-- Stop hyperspace overlay
function HYPERDRIVE.Stargate.Client.StopHyperspaceOverlay()
    HYPERDRIVE.Stargate.Client.HyperspaceOverlayActive = false
end

-- Create screen effects during hyperspace
function HYPERDRIVE.Stargate.Client.CreateScreenEffects()
    -- Screen shake effect
    util.ScreenShake(LocalPlayer():GetPos(), 5, 10, 2, 500)

    -- Color modification
    local colorModify = {
        ["$pp_colour_addr"] = 0.1,
        ["$pp_colour_addg"] = 0.15,
        ["$pp_colour_addb"] = 0.3,
        ["$pp_colour_brightness"] = 0.1,
        ["$pp_colour_contrast"] = 1.2,
        ["$pp_colour_colour"] = 0.8,
        ["$pp_colour_mulr"] = 0.9,
        ["$pp_colour_mulg"] = 0.95,
        ["$pp_colour_mulb"] = 1.1
    }

    HYPERDRIVE.Stargate.Client.HyperspaceColorMod = colorModify
end

-- Render hyperspace overlay
hook.Add("RenderScreenspaceEffects", "HyperdriveStargateOverlay", function()
    if not HYPERDRIVE.Stargate.Client.HyperspaceOverlayActive then return end

    local ply = LocalPlayer()
    if not IsValid(ply) or not ply.InHyperspace then
        HYPERDRIVE.Stargate.Client.StopHyperspaceOverlay()
        return
    end

    -- Apply color modification
    if HYPERDRIVE.Stargate.Client.HyperspaceColorMod then
        DrawColorModify(HYPERDRIVE.Stargate.Client.HyperspaceColorMod)
    end

    -- Draw hyperspace tunnel effect
    if HYPERDRIVE.Stargate.Client.Config.DimensionalEffects then
        HYPERDRIVE.Stargate.Client.DrawHyperspaceTunnel()
    end
end)

-- Draw hyperspace tunnel effect
function HYPERDRIVE.Stargate.Client.DrawHyperspaceTunnel()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local time = CurTime() - HYPERDRIVE.Stargate.Client.HyperspaceStartTime
    local alpha = math.min(1, time / 2) * 0.3 -- Fade in over 2 seconds

    -- Draw tunnel rings
    for i = 1, 10 do
        local ringProgress = (time * 2 + i * 0.5) % 5
        local ringSize = (1 - ringProgress / 5) * ScrW() * 2
        local ringAlpha = alpha * (1 - ringProgress / 5) * 0.5

        if ringSize > 0 and ringAlpha > 0 then
            surface.SetDrawColor(100, 150, 255, ringAlpha * 255)
            -- Draw circle using line segments since DrawOutlinedCircle doesn't exist
            local segments = math.max(16, ringSize / 10)
            local centerX, centerY = ScrW() / 2, ScrH() / 2

            for i = 0, segments do
                local angle1 = (i / segments) * math.pi * 2
                local angle2 = ((i + 1) / segments) * math.pi * 2

                local x1 = centerX + math.cos(angle1) * ringSize
                local y1 = centerY + math.sin(angle1) * ringSize
                local x2 = centerX + math.cos(angle2) * ringSize
                local y2 = centerY + math.sin(angle2) * ringSize

                surface.DrawLine(x1, y1, x2, y2)
            end
        end
    end

    -- Draw energy streams
    for i = 1, 20 do
        local angle = (time * 100 + i * 18) % 360
        local radius = ScrW() * 0.4
        local x = ScrW() / 2 + math.cos(math.rad(angle)) * radius
        local y = ScrH() / 2 + math.sin(math.rad(angle)) * radius

        surface.SetDrawColor(150, 200, 255, alpha * 100)
        surface.DrawLine(ScrW() / 2, ScrH() / 2, x, y)
    end
end

-- HUD element for stage display
hook.Add("HUDPaint", "HyperdriveStargateStageHUD", function()
    if HYPERDRIVE.Stargate.Client.CurrentStage == 0 then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- Only show during active travel
    local timeSinceStage = CurTime() - HYPERDRIVE.Stargate.Client.StageStartTime
    if timeSinceStage > (HYPERDRIVE.Stargate.Client.StageDuration or 10) then
        HYPERDRIVE.Stargate.Client.CurrentStage = 0
        return
    end

    local stageNames = {
        [1] = "INITIATION",
        [2] = "WINDOW OPENING",
        [3] = "HYPERSPACE TRAVEL",
        [4] = "EXIT STABILIZATION"
    }

    local stageName = stageNames[HYPERDRIVE.Stargate.Client.CurrentStage] or "UNKNOWN"
    local progress = timeSinceStage / (HYPERDRIVE.Stargate.Client.StageDuration or 1)
    progress = math.Clamp(progress, 0, 1)

    -- Draw stage indicator
    local x = ScrW() - 300
    local y = 50
    local w = 250
    local h = 60

    -- Background
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(x, y, w, h)

    -- Border
    surface.SetDrawColor(100, 150, 255, 200)
    surface.DrawOutlinedRect(x, y, w, h)

    -- Title
    surface.SetFont("DermaDefault")
    surface.SetTextColor(100, 200, 255, 255)
    surface.SetTextPos(x + 10, y + 5)
    surface.DrawText("STARGATE HYPERDRIVE")

    -- Stage name
    surface.SetTextColor(255, 255, 255, 255)
    surface.SetTextPos(x + 10, y + 20)
    surface.DrawText("Stage " .. HYPERDRIVE.Stargate.Client.CurrentStage .. ": " .. stageName)

    -- Progress bar
    local barX = x + 10
    local barY = y + 40
    local barW = w - 20
    local barH = 10

    surface.SetDrawColor(50, 50, 50, 200)
    surface.DrawRect(barX, barY, barW, barH)

    surface.SetDrawColor(100, 200, 255, 255)
    surface.DrawRect(barX, barY, barW * progress, barH)
end)

-- Console commands
concommand.Add("hyperdrive_sg_client_config", function(ply, cmd, args)
    print("[Hyperdrive Stargate Client] Configuration:")
    for key, value in pairs(HYPERDRIVE.Stargate.Client.Config) do
        print("  • " .. key .. ": " .. tostring(value))
    end
end)

concommand.Add("hyperdrive_sg_toggle_overlay", function(ply, cmd, args)
    HYPERDRIVE.Stargate.Client.Config.HyperspaceOverlay = not HYPERDRIVE.Stargate.Client.Config.HyperspaceOverlay
    print("[Hyperdrive Stargate Client] Hyperspace overlay: " .. (HYPERDRIVE.Stargate.Client.Config.HyperspaceOverlay and "ON" or "OFF"))
end)

print("[Hyperdrive] Stargate client-side effects loaded")
