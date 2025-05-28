-- Hyperdrive Hyperspace Window Animations
-- Creates stunning visual effects for entering and leaving hyperspace

if SERVER then return end

-- Initialize hyperspace window system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.HyperspaceWindow = HYPERDRIVE.HyperspaceWindow or {}

-- Animation states
local ANIM_NONE = 0
local ANIM_ENTERING = 1
local ANIM_IN_HYPERSPACE = 2
local ANIM_EXITING = 3

-- Current animation state
local currentAnimation = ANIM_NONE
local animationStartTime = 0
local animationDuration = 0
local hyperspaceStartTime = 0

-- Animation configuration
local config = {
    -- Timing
    enterDuration = 3.0,    -- Time to enter hyperspace
    exitDuration = 2.5,     -- Time to exit hyperspace

    -- Visual effects
    starStretchFactor = 50,  -- How much stars stretch
    tunnelLength = 2000,     -- Length of hyperspace tunnel
    energyIntensity = 1.5,   -- Energy effect intensity

    -- Colors
    hyperspaceColor = Color(100, 150, 255),
    energyColor = Color(150, 200, 255),
    starColor = Color(255, 255, 255),

    -- Performance
    maxStars = 500,
    maxEnergyStreams = 100,
    updateRate = 60
}

-- Star field data
local stars = {}
local energyStreams = {}

-- Initialize star field
local function InitializeStarField()
    stars = {}
    for i = 1, config.maxStars do
        stars[i] = {
            x = math.Rand(-1, 1),
            y = math.Rand(-1, 1),
            z = math.Rand(0.1, 1),
            brightness = math.Rand(0.3, 1),
            size = math.Rand(1, 3)
        }
    end
end

-- Initialize energy streams
local function InitializeEnergyStreams()
    energyStreams = {}
    for i = 1, config.maxEnergyStreams do
        energyStreams[i] = {
            x = math.Rand(-0.8, 0.8),
            y = math.Rand(-0.8, 0.8),
            z = math.Rand(0.1, 1),
            speed = math.Rand(0.5, 2),
            thickness = math.Rand(2, 8),
            energy = math.Rand(0.5, 1)
        }
    end
end

-- Start hyperspace entry animation
function HYPERDRIVE.HyperspaceWindow.StartEntry()
    currentAnimation = ANIM_ENTERING
    animationStartTime = CurTime()
    animationDuration = config.enterDuration

    InitializeStarField()
    InitializeEnergyStreams()

    -- Play enhanced entry sounds
    surface.PlaySound("ambient/energy/whiteflash.wav")
    timer.Simple(0.5, function()
        surface.PlaySound("ambient/energy/zap7.wav")
    end)
    timer.Simple(1.0, function()
        surface.PlaySound("ambient/atmosphere/tone_alley.wav")
    end)

    -- Progressive screen shake
    util.ScreenShake(Vector(0, 0, 0), 8, 5, 1, 1000)
    timer.Simple(0.5, function()
        util.ScreenShake(Vector(0, 0, 0), 12, 3, 1.5, 1000)
    end)

    -- Chat notification
    chat.AddText(Color(100, 150, 255), "[Hyperdrive] ", Color(255, 255, 255), "Entering hyperspace...")
end

-- Start hyperspace travel
function HYPERDRIVE.HyperspaceWindow.StartHyperspace()
    currentAnimation = ANIM_IN_HYPERSPACE
    hyperspaceStartTime = CurTime()

    -- Play hyperspace ambient sound
    surface.PlaySound("ambient/energy/zap7.wav")
end

-- Start hyperspace exit animation
function HYPERDRIVE.HyperspaceWindow.StartExit()
    currentAnimation = ANIM_EXITING
    animationStartTime = CurTime()
    animationDuration = config.exitDuration

    -- Play enhanced exit sounds
    surface.PlaySound("ambient/energy/zap9.wav")
    timer.Simple(0.3, function()
        surface.PlaySound("ambient/explosions/explode_4.wav")
    end)
    timer.Simple(0.8, function()
        surface.PlaySound("ambient/energy/newspark04.wav")
    end)

    -- Dramatic screen shake sequence
    util.ScreenShake(Vector(0, 0, 0), 15, 4, 1, 1000)
    timer.Simple(0.5, function()
        util.ScreenShake(Vector(0, 0, 0), 10, 2, 1, 1000)
    end)

    -- Chat notification
    chat.AddText(Color(100, 255, 150), "[Hyperdrive] ", Color(255, 255, 255), "Exiting hyperspace...")
end

-- Stop all animations
function HYPERDRIVE.HyperspaceWindow.Stop()
    currentAnimation = ANIM_NONE
    animationStartTime = 0
    animationDuration = 0
    hyperspaceStartTime = 0
end

-- Check if any animation is active
function HYPERDRIVE.HyperspaceWindow.IsActive()
    return currentAnimation ~= ANIM_NONE
end

-- Update star positions for hyperspace effect
local function UpdateStars(progress, speed)
    for i, star in ipairs(stars) do
        -- Move stars toward camera
        star.z = star.z - speed * FrameTime()

        -- Reset star when it gets too close
        if star.z <= 0 then
            star.z = 1
            star.x = math.Rand(-1, 1)
            star.y = math.Rand(-1, 1)
            star.brightness = math.Rand(0.3, 1)
        end

        -- Stretch stars based on speed
        star.stretch = math.max(1, speed * config.starStretchFactor * (1 - star.z))
    end
end

-- Update energy streams
local function UpdateEnergyStreams(progress, speed)
    for i, stream in ipairs(energyStreams) do
        -- Move streams toward camera
        stream.z = stream.z - speed * stream.speed * FrameTime()

        -- Reset stream when it gets too close
        if stream.z <= 0 then
            stream.z = 1
            stream.x = math.Rand(-0.8, 0.8)
            stream.y = math.Rand(-0.8, 0.8)
            stream.speed = math.Rand(0.5, 2)
            stream.energy = math.Rand(0.5, 1)
        end
    end
end

-- Render star field
local function RenderStars(progress, intensity)
    local scrW, scrH = ScrW(), ScrH()
    local centerX, centerY = scrW * 0.5, scrH * 0.5

    for i, star in ipairs(stars) do
        -- Convert 3D position to screen coordinates
        local screenX = centerX + (star.x / star.z) * centerX
        local screenY = centerY + (star.y / star.z) * centerY

        -- Skip stars outside screen
        if screenX < 0 or screenX > scrW or screenY < 0 or screenY > scrH then
            continue
        end

        -- Calculate star properties
        local alpha = math.min(255, star.brightness * intensity * 255 * (1 - star.z))
        local size = star.size * (1 - star.z * 0.5)
        local stretch = star.stretch or 1

        -- Draw stretched star
        local color = Color(config.starColor.r, config.starColor.g, config.starColor.b, alpha)

        if stretch > 1 then
            -- Draw stretched star as line
            local stretchLength = stretch * 2
            draw.RoundedBox(0, screenX - stretchLength/2, screenY - size/2, stretchLength, size, color)
        else
            -- Draw normal star as circle
            draw.RoundedBox(0, screenX - size/2, screenY - size/2, size, size, color)
        end
    end
end

-- Render energy streams
local function RenderEnergyStreams(progress, intensity)
    local scrW, scrH = ScrW(), ScrH()
    local centerX, centerY = scrW * 0.5, scrH * 0.5

    for i, stream in ipairs(energyStreams) do
        -- Convert 3D position to screen coordinates
        local screenX = centerX + (stream.x / stream.z) * centerX
        local screenY = centerY + (stream.y / stream.z) * centerY

        -- Skip streams outside screen
        if screenX < 0 or screenX > scrW or screenY < 0 or screenY > scrH then
            continue
        end

        -- Calculate stream properties
        local alpha = math.min(255, stream.energy * intensity * 255 * (1 - stream.z))
        local thickness = stream.thickness * (1 - stream.z * 0.3)
        local length = 50 * (1 - stream.z)

        -- Draw energy stream
        local color = Color(config.energyColor.r, config.energyColor.g, config.energyColor.b, alpha)
        draw.RoundedBox(0, screenX - thickness/2, screenY - length/2, thickness, length, color)

        -- Add glow effect
        local glowColor = Color(config.energyColor.r, config.energyColor.g, config.energyColor.b, alpha * 0.3)
        draw.RoundedBox(0, screenX - thickness, screenY - length, thickness * 2, length * 2, glowColor)
    end
end

-- Render hyperspace tunnel effect
local function RenderHyperspaceTunnel(progress, intensity)
    local scrW, scrH = ScrW(), ScrH()
    local centerX, centerY = scrW * 0.5, scrH * 0.5

    -- Draw tunnel rings
    for i = 1, 20 do
        local ringZ = (i / 20) + (CurTime() * 2) % 1
        if ringZ > 1 then ringZ = ringZ - 1 end

        local ringRadius = (1 - ringZ) * math.min(scrW, scrH) * 0.6
        local ringAlpha = math.min(255, intensity * 100 * (1 - ringZ))

        if ringRadius > 10 and ringAlpha > 5 then
            local color = Color(config.hyperspaceColor.r, config.hyperspaceColor.g, config.hyperspaceColor.b, ringAlpha)

            -- Draw ring outline
            draw.NoTexture()
            surface.SetDrawColor(color)
            -- Draw circle using line segments (DrawOutlinedCircle doesn't exist)
            local segments = 24
            local angleStep = (math.pi * 2) / segments
            local lastX, lastY = centerX + ringRadius, centerY

            for i = 1, segments do
                local angle = i * angleStep
                local x = centerX + math.cos(angle) * ringRadius
                local y = centerY + math.sin(angle) * ringRadius
                surface.DrawLine(lastX, lastY, x, y)
                lastX, lastY = x, y
            end
        end
    end
end

-- Render hyperspace flash effect
local function RenderHyperspaceFlash(progress, intensity)
    local scrW, scrH = ScrW(), ScrH()
    local time = CurTime()

    -- Central flash (reduced intensity to prevent white screen)
    local flashAlpha = math.sin(time * 8) * 30 + 60  -- Reduced from 50+100 to 30+60
    flashAlpha = flashAlpha * intensity * 0.6  -- Additional 40% reduction

    local flashColor = Color(100, 150, 200, flashAlpha)  -- Reduced RGB values
    draw.RoundedBox(0, scrW * 0.35, scrH * 0.35, scrW * 0.3, scrH * 0.3, flashColor)  -- Smaller flash area

    -- Radial pulses
    for i = 1, 5 do
        local pulseRadius = (time * 200 + i * 100) % (scrW * 0.8)
        local pulseAlpha = math.max(0, 100 - (pulseRadius / 10)) * intensity

        if pulseAlpha > 5 then
            local pulseColor = Color(100, 150, 255, pulseAlpha)
            surface.SetDrawColor(pulseColor)
            -- Draw circle using line segments
            local segments = 20
            local angleStep = (math.pi * 2) / segments
            local centerX, centerY = scrW/2, scrH/2
            local lastX, lastY = centerX + pulseRadius, centerY

            for i = 1, segments do
                local angle = i * angleStep
                local x = centerX + math.cos(angle) * pulseRadius
                local y = centerY + math.sin(angle) * pulseRadius
                surface.DrawLine(lastX, lastY, x, y)
                lastX, lastY = x, y
            end
        end
    end
end

-- Render transition effects
local function RenderTransitionEffects(progress, intensity)
    local scrW, scrH = ScrW(), ScrH()

    if currentAnimation == ANIM_ENTERING then
        -- Vortex effect during entry
        local vortexSize = progress * math.min(scrW, scrH) * 0.8
        local vortexAlpha = (1 - progress) * 255

        for i = 1, 10 do
            local ringRadius = vortexSize * (i / 10)
            local ringAlpha = vortexAlpha * (1 - i/10)

            if ringAlpha > 5 then
                local ringColor = Color(100, 150, 255, ringAlpha)
                surface.SetDrawColor(ringColor)
                -- Draw circle using line segments
                local segments = 24
                local angleStep = (math.pi * 2) / segments
                local centerX, centerY = scrW/2, scrH/2
                local lastX, lastY = centerX + ringRadius, centerY

                for i = 1, segments do
                    local angle = i * angleStep
                    local x = centerX + math.cos(angle) * ringRadius
                    local y = centerY + math.sin(angle) * ringRadius
                    surface.DrawLine(lastX, lastY, x, y)
                    lastX, lastY = x, y
                end
            end
        end

    elseif currentAnimation == ANIM_EXITING then
        -- Explosion effect during exit
        local explosionSize = progress * math.min(scrW, scrH) * 1.2
        local explosionAlpha = intensity * 200

        -- Central bright flash
        local flashSize = explosionSize * 0.3
        local flashColor = Color(255, 255, 255, explosionAlpha)
        draw.RoundedBox(0, scrW/2 - flashSize/2, scrH/2 - flashSize/2, flashSize, flashSize, flashColor)

        -- Expanding rings
        for i = 1, 8 do
            local ringRadius = explosionSize * (i / 8)
            local ringAlpha = explosionAlpha * (1 - progress) * (1 - i/8)

            if ringAlpha > 5 then
                local ringColor = Color(255, 200, 100, ringAlpha)
                surface.SetDrawColor(ringColor)
                -- Draw circle using line segments
                local segments = 24
                local angleStep = (math.pi * 2) / segments
                local centerX, centerY = scrW/2, scrH/2
                local lastX, lastY = centerX + ringRadius, centerY

                for i = 1, segments do
                    local angle = i * angleStep
                    local x = centerX + math.cos(angle) * ringRadius
                    local y = centerY + math.sin(angle) * ringRadius
                    surface.DrawLine(lastX, lastY, x, y)
                    lastX, lastY = x, y
                end
            end
        end
    end
end

-- Main render function
local function RenderHyperspaceWindow()
    if currentAnimation == ANIM_NONE then return end

    -- Prevent conflicts with other hyperspace effects
    if HYPERDRIVE.Hyperspace and HYPERDRIVE.Hyperspace.Effects and HYPERDRIVE.Hyperspace.Effects.InHyperspace then
        -- Let the hyperspace effects system handle rendering instead
        return
    end

    local scrW, scrH = ScrW(), ScrH()
    local time = CurTime()
    local progress = 0
    local intensity = 1
    local speed = 1

    -- Calculate animation progress
    if currentAnimation == ANIM_ENTERING then
        progress = math.min(1, (time - animationStartTime) / animationDuration)
        intensity = progress
        speed = progress * 3

        -- Transition to hyperspace when entry complete
        if progress >= 1 then
            HYPERDRIVE.HyperspaceWindow.StartHyperspace()
        end

    elseif currentAnimation == ANIM_IN_HYPERSPACE then
        progress = 1
        intensity = 0.8  -- Reduce intensity to prevent white screen
        speed = 2

    elseif currentAnimation == ANIM_EXITING then
        progress = math.min(1, (time - animationStartTime) / animationDuration)
        intensity = 1 - progress
        speed = (1 - progress) * 3

        -- Stop animation when exit complete
        if progress >= 1 then
            HYPERDRIVE.HyperspaceWindow.Stop()
        end
    end

    -- Update effects
    UpdateStars(progress, speed)
    UpdateEnergyStreams(progress, speed)

    -- Render background (reduced opacity to prevent white screen)
    local bgAlpha = math.min(100, intensity * 80)  -- Reduced from 150 to 80
    local bgColor = Color(0, 10, 30, bgAlpha)
    draw.RoundedBox(0, 0, 0, scrW, scrH, bgColor)

    -- Render effects
    RenderStars(progress, intensity)
    RenderEnergyStreams(progress, intensity)
    RenderHyperspaceTunnel(progress, intensity)

    -- Additional visual effects
    if intensity > 0.5 then
        RenderHyperspaceFlash(progress, intensity)
    end

    if currentAnimation == ANIM_ENTERING or currentAnimation == ANIM_EXITING then
        RenderTransitionEffects(progress, intensity)
    end

    -- Screen effects (reduced intensity to prevent white screen)
    if intensity > 0 and intensity < 0.8 then  -- Limit maximum intensity
        -- Color modification for hyperspace look (reduced values)
        local colorMod = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0.05 * intensity,  -- Reduced from 0.1
            ["$pp_colour_brightness"] = 0.95 + (0.05 * intensity),  -- Reduced from 0.9 + 0.2
            ["$pp_colour_contrast"] = 1 + (0.1 * intensity),  -- Reduced from 0.3
            ["$pp_colour_colour"] = 1 - (0.1 * intensity),  -- Reduced from 0.2
            ["$pp_colour_mulr"] = 0.9 + (0.1 * intensity),  -- Reduced from 0.8 + 0.2
            ["$pp_colour_mulg"] = 0.95 + (0.05 * intensity),  -- Reduced from 0.9 + 0.1
            ["$pp_colour_mulb"] = 1.0 + (0.1 * intensity)  -- Reduced from 0.3
        }
        DrawColorModify(colorMod)

        -- Motion blur during transition (reduced intensity)
        if currentAnimation == ANIM_ENTERING or currentAnimation == ANIM_EXITING then
            DrawMotionBlur(0.05 * intensity, 0.6, 0.005)  -- Reduced values
        end
    end
end

-- Hook into render system
hook.Add("HUDPaint", "HyperdriveHyperspaceWindow", RenderHyperspaceWindow)

-- Network message handlers
net.Receive("hyperdrive_hyperspace_window", function()
    local action = net.ReadString()

    if action == "enter" then
        HYPERDRIVE.HyperspaceWindow.StartEntry()
    elseif action == "exit" then
        HYPERDRIVE.HyperspaceWindow.StartExit()
    elseif action == "stop" then
        HYPERDRIVE.HyperspaceWindow.Stop()
    end
end)

-- Hyperspace dimension network handlers
net.Receive("hyperdrive_hyperspace_enter", function()
    local hyperspacePos = net.ReadVector()
    local travelTime = net.ReadFloat()

    -- Player is now in hyperspace dimension
    HYPERDRIVE.HyperspaceWindow.inHyperspaceDimension = true
    HYPERDRIVE.HyperspaceWindow.hyperspacePos = hyperspacePos
    HYPERDRIVE.HyperspaceWindow.travelTime = travelTime
    HYPERDRIVE.HyperspaceWindow.travelStartTime = CurTime()

    -- Start hyperspace window effects
    HYPERDRIVE.HyperspaceWindow.StartEntry()

    -- Show hyperspace HUD
    HYPERDRIVE.HyperspaceWindow.showHyperspaceHUD = true

    chat.AddText(Color(100, 150, 255), "[Hyperdrive] ", Color(255, 255, 255), "Entered hyperspace dimension - you can move around!")
end)

net.Receive("hyperdrive_hyperspace_exit", function()
    local newPos = net.ReadVector()

    -- Player has exited hyperspace dimension
    HYPERDRIVE.HyperspaceWindow.inHyperspaceDimension = false
    HYPERDRIVE.HyperspaceWindow.showHyperspaceHUD = false

    -- Start exit effects
    HYPERDRIVE.HyperspaceWindow.StartExit()

    chat.AddText(Color(100, 255, 150), "[Hyperdrive] ", Color(255, 255, 255), "Exited hyperspace dimension!")
end)

-- Render hyperspace dimension HUD
local function RenderHyperspaceDimensionHUD()
    if not HYPERDRIVE.HyperspaceWindow.showHyperspaceHUD then return end
    if not HYPERDRIVE.HyperspaceWindow.inHyperspaceDimension then return end

    local scrW, scrH = ScrW(), ScrH()
    local currentTime = CurTime()
    local travelTime = HYPERDRIVE.HyperspaceWindow.travelTime or 3
    local startTime = HYPERDRIVE.HyperspaceWindow.travelStartTime or currentTime
    local elapsed = currentTime - startTime
    local remaining = math.max(0, travelTime - elapsed)
    local progress = math.min(1, elapsed / travelTime)

    -- Background panel
    local panelW, panelH = 400, 120
    local panelX, panelY = scrW/2 - panelW/2, 50

    draw.RoundedBox(8, panelX, panelY, panelW, panelH, Color(0, 20, 40, 200))
    draw.RoundedBox(8, panelX + 2, panelY + 2, panelW - 4, panelH - 4, Color(20, 40, 80, 100))

    -- Title
    draw.SimpleText("HYPERSPACE DIMENSION", "DermaLarge", panelX + panelW/2, panelY + 15, Color(100, 200, 255), TEXT_ALIGN_CENTER)

    -- Travel progress bar
    local barW, barH = panelW - 40, 20
    local barX, barY = panelX + 20, panelY + 45

    draw.RoundedBox(4, barX, barY, barW, barH, Color(50, 50, 50))
    draw.RoundedBox(4, barX + 2, barY + 2, (barW - 4) * progress, barH - 4, Color(100, 200, 255))

    -- Progress text
    draw.SimpleText(string.format("Travel Progress: %.1f%%", progress * 100), "DermaDefault", panelX + panelW/2, barY + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Time remaining
    draw.SimpleText(string.format("Time Remaining: %.1fs", remaining), "DermaDefault", panelX + panelW/2, panelY + 75, Color(200, 255, 200), TEXT_ALIGN_CENTER)

    -- Instructions
    draw.SimpleText("You can move around inside your ship!", "DermaDefault", panelX + panelW/2, panelY + 95, Color(255, 255, 100), TEXT_ALIGN_CENTER)

    -- Emergency exit button (bottom right)
    local exitW, exitH = 150, 30
    local exitX, exitY = scrW - exitW - 20, scrH - exitH - 20

    local exitColor = Color(150, 50, 50)
    if gui.MouseX() >= exitX and gui.MouseX() <= exitX + exitW and
       gui.MouseY() >= exitY and gui.MouseY() <= exitY + exitH then
        exitColor = Color(200, 70, 70)

        if input.IsMouseDown(MOUSE_LEFT) then
            exitColor = Color(255, 100, 100)

            -- Emergency exit
            RunConsoleCommand("hyperdrive_emergency_exit")
        end
    end

    draw.RoundedBox(4, exitX, exitY, exitW, exitH, exitColor)
    draw.SimpleText("EMERGENCY EXIT", "DermaDefault", exitX + exitW/2, exitY + exitH/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Add hyperspace HUD to main render function
hook.Add("HUDPaint", "HyperdriveHyperspaceDimensionHUD", RenderHyperspaceDimensionHUD)



-- Initialize on load
InitializeStarField()
InitializeEnergyStreams()

print("[Hyperdrive] Hyperspace Window Animations loaded")
