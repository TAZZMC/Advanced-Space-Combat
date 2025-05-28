-- Hyperdrive Hyperspace Visual Effects
-- This file provides client-side visual effects for the hyperspace dimension

if SERVER then return end

-- Ensure HYPERDRIVE table exists first
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Hyperspace = HYPERDRIVE.Hyperspace or {}
HYPERDRIVE.Hyperspace.Effects = HYPERDRIVE.Hyperspace.Effects or {}

-- Hyperspace effects configuration
HYPERDRIVE.Hyperspace.Effects.Config = {
    -- Star field settings
    StarCount = 1000,
    StarSpeed = 500,
    StarSize = 2,
    StarBrightness = 200,

    -- Energy stream settings
    StreamCount = 50,
    StreamSpeed = 1000,
    StreamLength = 500,
    StreamWidth = 10,

    -- Distortion settings
    DistortionStrength = 0.3,
    DistortionSpeed = 2,
    DistortionRadius = 1000,

    -- Portal effects
    PortalSize = 200,
    PortalRotationSpeed = 90,
    PortalPulseSpeed = 2,

    -- Screen effects
    HyperspaceHue = 240, -- Blue-purple hue
    HyperspaceSaturation = 0.8,
    HyperspaceContrast = 1.2,
    HyperspaceBrightness = 0.9
}

-- Hyperspace state
HYPERDRIVE.Hyperspace.Effects.InHyperspace = false
HYPERDRIVE.Hyperspace.Effects.TransitTime = 0
HYPERDRIVE.Hyperspace.Effects.TransitStart = 0
HYPERDRIVE.Hyperspace.Effects.Stars = {}
HYPERDRIVE.Hyperspace.Effects.EnergyStreams = {}

-- Initialize hyperspace effects
function HYPERDRIVE.Hyperspace.Effects.Initialize()
    HYPERDRIVE.Hyperspace.Effects.CreateStarField()
    HYPERDRIVE.Hyperspace.Effects.CreateEnergyStreams()
end

-- Create star field
function HYPERDRIVE.Hyperspace.Effects.CreateStarField()
    HYPERDRIVE.Hyperspace.Effects.Stars = {}

    for i = 1, HYPERDRIVE.Hyperspace.Effects.Config.StarCount do
        local star = {
            pos = Vector(
                math.random(-10000, 10000),
                math.random(-10000, 10000),
                math.random(-5000, 5000)
            ),
            velocity = VectorRand() * HYPERDRIVE.Hyperspace.Effects.Config.StarSpeed,
            size = math.random(1, HYPERDRIVE.Hyperspace.Effects.Config.StarSize),
            brightness = math.random(100, HYPERDRIVE.Hyperspace.Effects.Config.StarBrightness),
            color = HSVtoRGB(math.random(200, 280), 0.8, 1) -- Blue to purple stars
        }

        table.insert(HYPERDRIVE.Hyperspace.Effects.Stars, star)
    end
end

-- Create energy streams
function HYPERDRIVE.Hyperspace.Effects.CreateEnergyStreams()
    HYPERDRIVE.Hyperspace.Effects.EnergyStreams = {}

    for i = 1, HYPERDRIVE.Hyperspace.Effects.Config.StreamCount do
        local stream = {
            startPos = Vector(
                math.random(-5000, 5000),
                math.random(-5000, 5000),
                math.random(-2000, 2000)
            ),
            direction = VectorRand():GetNormalized(),
            speed = math.random(500, HYPERDRIVE.Hyperspace.Effects.Config.StreamSpeed),
            length = math.random(200, HYPERDRIVE.Hyperspace.Effects.Config.StreamLength),
            width = math.random(5, HYPERDRIVE.Hyperspace.Effects.Config.StreamWidth),
            color = HSVtoRGB(math.random(180, 300), 1, 1),
            life = math.random(5, 15)
        }

        stream.endPos = stream.startPos + stream.direction * stream.length

        table.insert(HYPERDRIVE.Hyperspace.Effects.EnergyStreams, stream)
    end
end

-- Update hyperspace effects
function HYPERDRIVE.Hyperspace.Effects.Update()
    if not HYPERDRIVE.Hyperspace.Effects.InHyperspace then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local frameTime = FrameTime()
    local playerPos = ply:GetPos()

    -- Update stars
    HYPERDRIVE.Hyperspace.Effects.UpdateStars(frameTime, playerPos)

    -- Update energy streams
    HYPERDRIVE.Hyperspace.Effects.UpdateEnergyStreams(frameTime, playerPos)
end

-- Update star field
function HYPERDRIVE.Hyperspace.Effects.UpdateStars(frameTime, playerPos)
    for _, star in ipairs(HYPERDRIVE.Hyperspace.Effects.Stars) do
        -- Move stars relative to player
        star.pos = star.pos + star.velocity * frameTime

        -- Wrap stars around
        if star.pos:Distance(playerPos) > 15000 then
            star.pos = playerPos + VectorRand() * 10000
            star.velocity = VectorRand() * HYPERDRIVE.Hyperspace.Effects.Config.StarSpeed
        end
    end
end

-- Update energy streams
function HYPERDRIVE.Hyperspace.Effects.UpdateEnergyStreams(frameTime, playerPos)
    for i = #HYPERDRIVE.Hyperspace.Effects.EnergyStreams, 1, -1 do
        local stream = HYPERDRIVE.Hyperspace.Effects.EnergyStreams[i]

        -- Move stream
        stream.startPos = stream.startPos + stream.direction * stream.speed * frameTime
        stream.endPos = stream.endPos + stream.direction * stream.speed * frameTime

        -- Decrease life
        stream.life = stream.life - frameTime

        -- Remove dead streams
        if stream.life <= 0 or stream.startPos:Distance(playerPos) > 10000 then
            table.remove(HYPERDRIVE.Hyperspace.Effects.EnergyStreams, i)

            -- Create new stream
            local newStream = {
                startPos = playerPos + VectorRand() * 5000,
                direction = VectorRand():GetNormalized(),
                speed = math.random(500, HYPERDRIVE.Hyperspace.Effects.Config.StreamSpeed),
                length = math.random(200, HYPERDRIVE.Hyperspace.Effects.Config.StreamLength),
                width = math.random(5, HYPERDRIVE.Hyperspace.Effects.Config.StreamWidth),
                color = HSVtoRGB(math.random(180, 300), 1, 1),
                life = math.random(5, 15)
            }
            newStream.endPos = newStream.startPos + newStream.direction * newStream.length

            table.insert(HYPERDRIVE.Hyperspace.Effects.EnergyStreams, newStream)
        end
    end
end

-- Render hyperspace effects
function HYPERDRIVE.Hyperspace.Effects.Render()
    if not HYPERDRIVE.Hyperspace.Effects.InHyperspace then return end

    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    -- Render star field
    HYPERDRIVE.Hyperspace.Effects.RenderStars()

    -- Render energy streams
    HYPERDRIVE.Hyperspace.Effects.RenderEnergyStreams()

    -- Render distortion field
    HYPERDRIVE.Hyperspace.Effects.RenderDistortionField()
end

-- Render star field
function HYPERDRIVE.Hyperspace.Effects.RenderStars()
    render.SetMaterial(Material("sprites/light_glow02_add"))

    for _, star in ipairs(HYPERDRIVE.Hyperspace.Effects.Stars) do
        local screenPos = star.pos:ToScreen()
        if screenPos.visible then
            local distance = LocalPlayer():GetPos():Distance(star.pos)
            local alpha = math.Clamp(star.brightness * (5000 / distance), 0, 255)

            render.DrawSprite(star.pos, star.size, star.size, ColorAlpha(star.color, alpha))
        end
    end
end

-- Render energy streams
function HYPERDRIVE.Hyperspace.Effects.RenderEnergyStreams()
    render.SetMaterial(Material("cable/cable2"))

    for _, stream in ipairs(HYPERDRIVE.Hyperspace.Effects.EnergyStreams) do
        local alpha = math.Clamp((stream.life / 10) * 255, 0, 255)
        render.DrawBeam(stream.startPos, stream.endPos, stream.width, 0, 1, ColorAlpha(stream.color, alpha))
    end
end

-- Render distortion field
function HYPERDRIVE.Hyperspace.Effects.RenderDistortionField()
    local ply = LocalPlayer()
    local time = CurTime()

    -- Create ripple effects around the player
    for i = 1, 5 do
        local angle = (time * HYPERDRIVE.Hyperspace.Effects.Config.DistortionSpeed + i * 72) % 360
        local radius = HYPERDRIVE.Hyperspace.Effects.Config.DistortionRadius + math.sin(time + i) * 200

        local pos = ply:GetPos() + Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            math.sin(time * 2 + i) * 100
        )

        local alpha = math.Clamp(100 - (radius / 20), 0, 100)
        render.DrawSprite(pos, 50, 50, ColorAlpha(Color(100, 150, 255), alpha))
    end
end

-- Create hyperspace portal effect
function HYPERDRIVE.Hyperspace.Effects.CreatePortalEffect(pos, portalType)
    local emitter = ParticleEmitter(pos)
    if not emitter then return end

    local particleCount = portalType == "entry" and 100 or 150
    local color = portalType == "entry" and Color(100, 150, 255) or Color(255, 150, 100)

    -- Portal ring particles
    for i = 1, particleCount do
        local angle = (i / particleCount) * 360
        local radius = HYPERDRIVE.Hyperspace.Effects.Config.PortalSize

        local particlePos = pos + Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            math.random(-50, 50)
        )

        local particle = emitter:Add("effects/energyball", particlePos)
        if particle then
            particle:SetVelocity(VectorRand() * 100)
            particle:SetLifeTime(0)
            particle:SetDieTime(3)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(10)
            particle:SetEndSize(30)
            particle:SetColor(color.r, color.g, color.b)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end

    -- Portal center vortex
    for i = 1, 50 do
        local particle = emitter:Add("effects/spark", pos + VectorRand() * 50)
        if particle then
            local velocity = (pos - particle:GetPos()):GetNormalized() * 200
            particle:SetVelocity(velocity)
            particle:SetLifeTime(0)
            particle:SetDieTime(2)
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(5)
            particle:SetEndSize(1)
            particle:SetColor(255, 255, 255)
            particle:SetGravity(Vector(0, 0, 0))
        end
    end

    emitter:Finish()
end

-- Apply hyperspace screen effects (disabled to prevent conflicts with window system)
function HYPERDRIVE.Hyperspace.Effects.ApplyScreenEffects()
    if not HYPERDRIVE.Hyperspace.Effects.InHyperspace then return end

    -- Disable screen effects to prevent white screen conflicts
    -- The hyperspace window system handles all visual effects
    return

    --[[
    local progress = 0
    if HYPERDRIVE.Hyperspace.Effects.TransitTime > 0 then
        progress = (CurTime() - HYPERDRIVE.Hyperspace.Effects.TransitStart) / HYPERDRIVE.Hyperspace.Effects.TransitTime
        progress = math.Clamp(progress, 0, 1)
    end

    -- Hyperspace color modification (disabled)
    local colorMod = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0.05 * progress,  -- Reduced
        ["$pp_colour_brightness"] = 0.98,  -- Reduced
        ["$pp_colour_contrast"] = 1.05,  -- Reduced
        ["$pp_colour_colour"] = 1 - (0.1 * progress),  -- Reduced
        ["$pp_colour_mulr"] = 0.9,
        ["$pp_colour_mulg"] = 0.95,
        ["$pp_colour_mulb"] = 1.1
    }

    DrawColorModify(colorMod)

    -- Motion blur effect (reduced)
    DrawMotionBlur(0.05 * progress, 0.6, 0.005)

    -- Screen distortion (reduced)
    local distortion = math.sin(CurTime() * 5) * 0.01 * progress
    util.ScreenShake(Vector(0, 0, 0), distortion * 5, 5, 0.05, 500)
    --]]
end

-- Enter hyperspace
function HYPERDRIVE.Hyperspace.Effects.EnterHyperspace(transitTime, destination)
    HYPERDRIVE.Hyperspace.Effects.InHyperspace = true
    HYPERDRIVE.Hyperspace.Effects.TransitTime = transitTime
    HYPERDRIVE.Hyperspace.Effects.TransitStart = CurTime()

    -- Initialize effects
    HYPERDRIVE.Hyperspace.Effects.Initialize()

    -- Play hyperspace sound
    LocalPlayer():EmitSound("ambient/atmosphere/ambience_base.wav", 75, 80)

    -- Screen flash (reduced intensity to prevent white screen)
    local flash = vgui.Create("DPanel")
    flash:SetSize(ScrW(), ScrH())
    flash:SetPos(0, 0)
    flash:SetBackgroundColor(Color(50, 100, 200, 100))  -- Reduced opacity from 200 to 100
    flash:SetZPos(1000)

    timer.Simple(0.3, function()  -- Reduced duration from 0.5 to 0.3
        if IsValid(flash) then
            flash:Remove()
        end
    end)

    chat.AddText(Color(100, 150, 255), "[Hyperspace] ", Color(255, 255, 255), "Entering hyperspace dimension...")
end

-- Exit hyperspace
function HYPERDRIVE.Hyperspace.Effects.ExitHyperspace()
    HYPERDRIVE.Hyperspace.Effects.InHyperspace = false
    HYPERDRIVE.Hyperspace.Effects.TransitTime = 0
    HYPERDRIVE.Hyperspace.Effects.TransitStart = 0

    -- Clear effects
    HYPERDRIVE.Hyperspace.Effects.Stars = {}
    HYPERDRIVE.Hyperspace.Effects.EnergyStreams = {}

    -- Play exit sound
    LocalPlayer():EmitSound("ambient/energy/zap7.wav", 75, 120)

    -- Screen flash (reduced intensity to prevent white screen)
    local flash = vgui.Create("DPanel")
    flash:SetSize(ScrW(), ScrH())
    flash:SetPos(0, 0)
    flash:SetBackgroundColor(Color(200, 220, 255, 80))  -- Reduced white flash intensity
    flash:SetZPos(1000)

    timer.Simple(0.2, function()  -- Reduced duration from 0.3 to 0.2
        if IsValid(flash) then
            flash:Remove()
        end
    end)

    chat.AddText(Color(255, 150, 100), "[Hyperspace] ", Color(255, 255, 255), "Exiting hyperspace dimension...")
end

-- HSV to RGB conversion
function HSVtoRGB(h, s, v)
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    local imod = i % 6
    if imod == 0 then
        r, g, b = v, t, p
    elseif imod == 1 then
        r, g, b = q, v, p
    elseif imod == 2 then
        r, g, b = p, v, t
    elseif imod == 3 then
        r, g, b = p, q, v
    elseif imod == 4 then
        r, g, b = t, p, v
    elseif imod == 5 then
        r, g, b = v, p, q
    end

    return Color(r * 255, g * 255, b * 255)
end

-- Network message handlers
net.Receive("hyperdrive_hyperspace_effect", function()
    local pos = net.ReadVector()
    local effectType = net.ReadString()

    HYPERDRIVE.Hyperspace.Effects.CreatePortalEffect(pos, effectType)
end)

net.Receive("hyperdrive_hyperspace_enter", function()
    local transitTime = net.ReadFloat()
    local destination = net.ReadVector()

    HYPERDRIVE.Hyperspace.Effects.EnterHyperspace(transitTime, destination)
end)

net.Receive("hyperdrive_hyperspace_exit", function()
    HYPERDRIVE.Hyperspace.Effects.ExitHyperspace()
end)

-- Hooks for rendering
hook.Add("Think", "HyperdriveHyperspaceEffectsUpdate", function()
    HYPERDRIVE.Hyperspace.Effects.Update()
end)

hook.Add("PostDrawOpaqueRenderables", "HyperdriveHyperspaceEffectsRender", function()
    HYPERDRIVE.Hyperspace.Effects.Render()
end)

-- Disabled to prevent white screen conflicts
-- hook.Add("RenderScreenspaceEffects", "HyperdriveHyperspaceScreenEffects", function()
--     HYPERDRIVE.Hyperspace.Effects.ApplyScreenEffects()
-- end)

hook.Add("HUDPaint", "HyperdriveHyperspaceHUD", function()
    HYPERDRIVE.Hyperspace.Effects.DrawHyperspaceHUD()
end)

-- Draw hyperspace HUD
function HYPERDRIVE.Hyperspace.Effects.DrawHyperspaceHUD()
    if not HYPERDRIVE.Hyperspace.Effects.InHyperspace then return end

    local scrW, scrH = ScrW(), ScrH()
    local progress = 0
    local timeRemaining = 0

    if HYPERDRIVE.Hyperspace.Effects.TransitTime > 0 then
        local elapsed = CurTime() - HYPERDRIVE.Hyperspace.Effects.TransitStart
        progress = math.Clamp(elapsed / HYPERDRIVE.Hyperspace.Effects.TransitTime, 0, 1)
        timeRemaining = math.max(0, HYPERDRIVE.Hyperspace.Effects.TransitTime - elapsed)
    end

    -- Background panel
    local panelW, panelH = 400, 120
    local panelX, panelY = scrW - panelW - 20, 20

    draw.RoundedBox(8, panelX, panelY, panelW, panelH, Color(0, 0, 0, 150))
    draw.RoundedBox(8, panelX + 2, panelY + 2, panelW - 4, panelH - 4, Color(20, 30, 50, 200))

    -- Title
    draw.SimpleText("HYPERSPACE TRANSIT", "DermaDefaultBold", panelX + panelW/2, panelY + 15, Color(100, 150, 255), TEXT_ALIGN_CENTER)

    -- Progress bar
    local barW, barH = panelW - 40, 20
    local barX, barY = panelX + 20, panelY + 40

    draw.RoundedBox(4, barX, barY, barW, barH, Color(50, 50, 50))
    draw.RoundedBox(4, barX + 2, barY + 2, (barW - 4) * progress, barH - 4, Color(100, 150, 255))

    -- Progress text
    local progressText = string.format("%.1f%%", progress * 100)
    draw.SimpleText(progressText, "DermaDefault", barX + barW/2, barY + barH/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Time remaining
    local timeText = string.format("Time Remaining: %.1fs", timeRemaining)
    draw.SimpleText(timeText, "DermaDefault", panelX + panelW/2, panelY + 70, Color(200, 200, 200), TEXT_ALIGN_CENTER)

    -- Status
    local status = "TRANSIT"
    if progress < 0.1 then
        status = "ENTERING"
    elseif progress > 0.9 then
        status = "EXITING"
    end

    draw.SimpleText("Status: " .. status, "DermaDefault", panelX + panelW/2, panelY + 90, Color(100, 255, 100), TEXT_ALIGN_CENTER)

    -- Emergency exit hint
    draw.SimpleText("Press F4 for Emergency Exit", "DermaDefault", scrW/2, scrH - 50, Color(255, 100, 100), TEXT_ALIGN_CENTER)
end

-- Emergency exit key binding
hook.Add("PlayerButtonDown", "HyperdriveHyperspaceEmergencyExit", function(ply, button)
    if button == KEY_F4 and HYPERDRIVE.Hyperspace.Effects.InHyperspace then
        RunConsoleCommand("hyperdrive_hyperspace_emergency_exit")
    end
end)

print("[Hyperdrive] Hyperspace effects loaded")
