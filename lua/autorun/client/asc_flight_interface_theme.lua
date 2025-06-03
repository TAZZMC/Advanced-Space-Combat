-- Advanced Space Combat - Flight Interface Theme System v1.0.0
-- Professional theming for flight consoles and ship control interfaces

print("[Advanced Space Combat] Flight Interface Theme System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.FlightTheme = ASC.FlightTheme or {}

-- Flight interface theme configuration
ASC.FlightTheme.Config = {
    -- Enable/Disable Features
    EnableFlightHUD = true,
    EnableNavigationDisplay = true,
    EnableAutopilotControls = true,
    EnableWaypointSystem = true,
    EnableFlightMetrics = true,
    
    -- Visual Settings
    UseHolographicStyle = true,
    EnableAnimations = true,
    EnableParticleEffects = true,
    EnableSoundFeedback = true,
    
    -- Flight-specific Colors
    Colors = {
        -- Flight Status Colors
        FlightActive = Color(39, 174, 96, 255),     -- Green
        FlightInactive = Color(231, 76, 60, 255),   -- Red
        AutopilotActive = Color(52, 152, 219, 255), -- Blue
        ManualControl = Color(243, 156, 18, 255),   -- Orange
        Emergency = Color(231, 76, 60, 255),        -- Red
        
        -- Navigation Colors
        Waypoint = Color(255, 200, 100, 255),       -- Orange
        Destination = Color(100, 255, 100, 255),    -- Green
        CurrentPath = Color(100, 150, 255, 255),    -- Blue
        Obstacle = Color(255, 100, 100, 255),       -- Red
        
        -- Speed Colors
        SpeedNormal = Color(100, 255, 100, 255),    -- Green
        SpeedHigh = Color(255, 200, 100, 255),      -- Orange
        SpeedDangerous = Color(255, 100, 100, 255), -- Red
        
        -- Thrust Colors
        ThrustForward = Color(100, 255, 100, 255),  -- Green
        ThrustReverse = Color(255, 100, 100, 255),  -- Red
        ThrustSide = Color(100, 150, 255, 255),     -- Blue
        ThrustVertical = Color(255, 200, 100, 255), -- Orange
        
        -- UI Colors
        Background = Color(23, 32, 42, 240),
        Surface = Color(30, 39, 46, 220),
        Panel = Color(37, 46, 56, 200),
        Text = Color(255, 255, 255, 255),
        TextSecondary = Color(178, 190, 195, 200),
        Border = Color(99, 110, 114, 150),
        Accent = Color(100, 150, 255, 255)
    },
    
    -- HUD Layout
    HUDElements = {
        SpeedIndicator = { x = 50, y = 50, w = 200, h = 80 },
        ThrustDisplay = { x = 50, y = 150, w = 200, h = 120 },
        NavigationPanel = { x = 300, y = 50, w = 250, h = 200 },
        StatusPanel = { x = 50, y = 300, w = 500, h = 100 },
        WaypointList = { x = 600, y = 50, w = 200, h = 300 }
    },
    
    -- Animation Settings
    Animations = {
        FadeSpeed = 3.0,
        PulseSpeed = 2.0,
        RotationSpeed = 45.0,
        ScaleSpeed = 4.0
    }
}

-- Flight interface state
ASC.FlightTheme.State = {
    ActiveFlightConsole = nil,
    FlightHUDVisible = false,
    FlightData = {},
    NavigationData = {},
    WaypointData = {},
    LastUpdate = 0,
    UpdateInterval = 0.05, -- 20 FPS
    Animations = {
        SpeedBar = 0,
        ThrustBars = { x = 0, y = 0, z = 0 },
        CompassRotation = 0,
        StatusPulse = 0
    }
}

-- Initialize flight theme system
function ASC.FlightTheme.Initialize()
    print("[Advanced Space Combat] Flight interface theme initialized")
    
    -- Create ConVars
    CreateClientConVar("asc_flight_hud_enabled", "1", true, false, "Enable flight HUD")
    CreateClientConVar("asc_flight_holo_style", "1", true, false, "Enable holographic flight displays")
    CreateClientConVar("asc_flight_animations", "1", true, false, "Enable flight interface animations")
    CreateClientConVar("asc_flight_sounds", "1", true, false, "Enable flight sound feedback")
    
    -- Initialize hooks
    ASC.FlightTheme.InitializeHooks()
end

-- Initialize hooks for flight interfaces
function ASC.FlightTheme.InitializeHooks()
    -- Hook into flight console activation
    hook.Add("ASC_FlightConsoleActivated", "ASC_FlightTheme", function(console, player)
        if player == LocalPlayer() then
            ASC.FlightTheme.ActivateFlightHUD(console)
        end
    end)
    
    -- Hook into flight console deactivation
    hook.Add("ASC_FlightConsoleDeactivated", "ASC_FlightTheme", function(console, player)
        if player == LocalPlayer() then
            ASC.FlightTheme.DeactivateFlightHUD()
        end
    end)
    
    -- Hook into flight data updates
    hook.Add("ASC_FlightDataUpdate", "ASC_FlightTheme", function(data)
        ASC.FlightTheme.UpdateFlightData(data)
    end)
end

-- Activate flight HUD
function ASC.FlightTheme.ActivateFlightHUD(console)
    if not GetConVar("asc_flight_hud_enabled"):GetBool() then return end
    
    ASC.FlightTheme.State.ActiveFlightConsole = console
    ASC.FlightTheme.State.FlightHUDVisible = true
    
    -- Play activation sound
    if GetConVar("asc_flight_sounds"):GetBool() then
        surface.PlaySound("ambient/machines/machine_whine1.wav")
    end
    
    print("[Advanced Space Combat] Flight HUD activated")
end

-- Deactivate flight HUD
function ASC.FlightTheme.DeactivateFlightHUD()
    ASC.FlightTheme.State.ActiveFlightConsole = nil
    ASC.FlightTheme.State.FlightHUDVisible = false
    
    -- Play deactivation sound
    if GetConVar("asc_flight_sounds"):GetBool() then
        surface.PlaySound("ambient/machines/machine_whine2.wav")
    end
    
    print("[Advanced Space Combat] Flight HUD deactivated")
end

-- Update flight data
function ASC.FlightTheme.UpdateFlightData(data)
    ASC.FlightTheme.State.FlightData = data
    
    -- Update animations
    if GetConVar("asc_flight_animations"):GetBool() then
        ASC.FlightTheme.UpdateAnimations()
    end
end

-- Update animations
function ASC.FlightTheme.UpdateAnimations()
    local frameTime = FrameTime()
    local state = ASC.FlightTheme.State
    local data = state.FlightData
    
    if data then
        -- Speed bar animation
        local targetSpeed = data.speed or 0
        local maxSpeed = data.maxSpeed or 1000
        local speedPercent = targetSpeed / maxSpeed
        state.Animations.SpeedBar = Lerp(frameTime * 3, state.Animations.SpeedBar, speedPercent)
        
        -- Thrust bar animations
        state.Animations.ThrustBars.x = Lerp(frameTime * 4, state.Animations.ThrustBars.x, data.thrustX or 0)
        state.Animations.ThrustBars.y = Lerp(frameTime * 4, state.Animations.ThrustBars.y, data.thrustY or 0)
        state.Animations.ThrustBars.z = Lerp(frameTime * 4, state.Animations.ThrustBars.z, data.thrustZ or 0)
        
        -- Compass rotation
        if data.heading then
            state.Animations.CompassRotation = data.heading
        end
        
        -- Status pulse
        state.Animations.StatusPulse = math.sin(CurTime() * 2) * 0.3 + 0.7
    end
end

-- Draw flight HUD
function ASC.FlightTheme.DrawFlightHUD()
    if not ASC.FlightTheme.State.FlightHUDVisible then return end
    if not GetConVar("asc_flight_hud_enabled"):GetBool() then return end
    
    local config = ASC.FlightTheme.Config
    local state = ASC.FlightTheme.State
    
    -- Update data
    if CurTime() - state.LastUpdate > state.UpdateInterval then
        ASC.FlightTheme.RequestFlightData()
        state.LastUpdate = CurTime()
    end
    
    -- Draw HUD elements
    ASC.FlightTheme.DrawSpeedIndicator()
    ASC.FlightTheme.DrawThrustDisplay()
    ASC.FlightTheme.DrawNavigationPanel()
    ASC.FlightTheme.DrawStatusPanel()
    ASC.FlightTheme.DrawWaypointList()
    
    -- Draw crosshair
    ASC.FlightTheme.DrawFlightCrosshair()
end

-- Draw speed indicator
function ASC.FlightTheme.DrawSpeedIndicator()
    local config = ASC.FlightTheme.Config
    local state = ASC.FlightTheme.State
    local elem = config.HUDElements.SpeedIndicator
    
    -- Background panel
    draw.RoundedBox(8, elem.x, elem.y, elem.w, elem.h, config.Colors.Panel)
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(elem.x, elem.y, elem.w, elem.h, 1)
    
    -- Title
    surface.SetFont("ASC_Body")
    surface.SetTextColor(config.Colors.Text)
    surface.SetTextPos(elem.x + 10, elem.y + 10)
    surface.DrawText("VELOCITY")
    
    -- Speed value
    local speed = state.FlightData.speed or 0
    local speedText = string.format("%.0f", speed)
    surface.SetFont("ASC_Subtitle")
    surface.SetTextPos(elem.x + 10, elem.y + 30)
    surface.DrawText(speedText)
    
    -- Speed bar
    local barY = elem.y + 55
    local barWidth = elem.w - 20
    local barHeight = 15
    
    -- Background
    draw.RoundedBox(4, elem.x + 10, barY, barWidth, barHeight, Color(50, 50, 50, 200))
    
    -- Speed level
    local speedPercent = state.Animations.SpeedBar
    local speedColor = config.Colors.SpeedNormal
    if speedPercent > 0.8 then
        speedColor = config.Colors.SpeedDangerous
    elseif speedPercent > 0.6 then
        speedColor = config.Colors.SpeedHigh
    end
    
    if speedPercent > 0 then
        draw.RoundedBox(3, elem.x + 11, barY + 1, (barWidth - 2) * speedPercent, barHeight - 2, speedColor)
    end
    
    -- Holographic effect
    if GetConVar("asc_flight_holo_style"):GetBool() then
        local glowAlpha = math.sin(CurTime() * 3) * 20 + 30
        draw.RoundedBox(10, elem.x - 2, elem.y - 2, elem.w + 4, elem.h + 4,
            Color(config.Colors.Accent.r, config.Colors.Accent.g, config.Colors.Accent.b, glowAlpha))
    end
end

-- Draw thrust display
function ASC.FlightTheme.DrawThrustDisplay()
    local config = ASC.FlightTheme.Config
    local state = ASC.FlightTheme.State
    local elem = config.HUDElements.ThrustDisplay
    
    -- Background panel
    draw.RoundedBox(8, elem.x, elem.y, elem.w, elem.h, config.Colors.Panel)
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(elem.x, elem.y, elem.w, elem.h, 1)
    
    -- Title
    surface.SetFont("ASC_Body")
    surface.SetTextColor(config.Colors.Text)
    surface.SetTextPos(elem.x + 10, elem.y + 10)
    surface.DrawText("THRUST VECTOR")
    
    local barWidth = 60
    local barHeight = 15
    local startY = elem.y + 35
    
    -- X Thrust (Left/Right)
    surface.SetFont("ASC_Small")
    surface.SetTextPos(elem.x + 10, startY)
    surface.DrawText("X:")
    
    local xThrust = state.Animations.ThrustBars.x
    local xColor = xThrust > 0 and config.Colors.ThrustSide or config.Colors.ThrustReverse
    draw.RoundedBox(3, elem.x + 30, startY, barWidth, barHeight, Color(50, 50, 50, 200))
    if math.abs(xThrust) > 0.01 then
        local thrustWidth = barWidth * math.abs(xThrust)
        local thrustX = xThrust > 0 and (elem.x + 30 + barWidth/2) or (elem.x + 30 + barWidth/2 - thrustWidth)
        draw.RoundedBox(2, thrustX, startY + 1, thrustWidth, barHeight - 2, xColor)
    end
    
    startY = startY + 25
    
    -- Y Thrust (Forward/Backward)
    surface.SetTextPos(elem.x + 10, startY)
    surface.DrawText("Y:")
    
    local yThrust = state.Animations.ThrustBars.y
    local yColor = yThrust > 0 and config.Colors.ThrustForward or config.Colors.ThrustReverse
    draw.RoundedBox(3, elem.x + 30, startY, barWidth, barHeight, Color(50, 50, 50, 200))
    if math.abs(yThrust) > 0.01 then
        local thrustWidth = barWidth * math.abs(yThrust)
        local thrustX = yThrust > 0 and (elem.x + 30 + barWidth/2) or (elem.x + 30 + barWidth/2 - thrustWidth)
        draw.RoundedBox(2, thrustX, startY + 1, thrustWidth, barHeight - 2, yColor)
    end
    
    startY = startY + 25
    
    -- Z Thrust (Up/Down)
    surface.SetTextPos(elem.x + 10, startY)
    surface.DrawText("Z:")
    
    local zThrust = state.Animations.ThrustBars.z
    local zColor = config.Colors.ThrustVertical
    draw.RoundedBox(3, elem.x + 30, startY, barWidth, barHeight, Color(50, 50, 50, 200))
    if math.abs(zThrust) > 0.01 then
        local thrustWidth = barWidth * math.abs(zThrust)
        local thrustX = zThrust > 0 and (elem.x + 30 + barWidth/2) or (elem.x + 30 + barWidth/2 - thrustWidth)
        draw.RoundedBox(2, thrustX, startY + 1, thrustWidth, barHeight - 2, zColor)
    end
end

-- Draw navigation panel
function ASC.FlightTheme.DrawNavigationPanel()
    local config = ASC.FlightTheme.Config
    local state = ASC.FlightTheme.State
    local elem = config.HUDElements.NavigationPanel
    
    -- Background panel
    draw.RoundedBox(8, elem.x, elem.y, elem.w, elem.h, config.Colors.Panel)
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(elem.x, elem.y, elem.w, elem.h, 1)
    
    -- Title
    surface.SetFont("ASC_Body")
    surface.SetTextColor(config.Colors.Text)
    surface.SetTextPos(elem.x + 10, elem.y + 10)
    surface.DrawText("NAVIGATION")
    
    -- Compass
    local compassX = elem.x + elem.w/2
    local compassY = elem.y + 60
    local compassRadius = 40
    
    -- Compass background
    surface.SetDrawColor(Color(50, 50, 50, 200))
    draw.NoTexture()
    surface.DrawCircle(compassX, compassY, compassRadius)
    
    -- Compass needle
    local heading = state.Animations.CompassRotation or 0
    local needleLength = compassRadius - 5
    local needleX = compassX + math.sin(math.rad(heading)) * needleLength
    local needleY = compassY - math.cos(math.rad(heading)) * needleLength
    
    surface.SetDrawColor(config.Colors.Accent)
    surface.DrawLine(compassX, compassY, needleX, needleY)
    
    -- Heading text
    surface.SetFont("ASC_Small")
    surface.SetTextColor(config.Colors.Text)
    local headingText = string.format("HDG: %.0f°", heading)
    local textW, textH = surface.GetTextSize(headingText)
    surface.SetTextPos(compassX - textW/2, compassY + compassRadius + 10)
    surface.DrawText(headingText)
    
    -- Altitude
    local altitude = state.FlightData.altitude or 0
    local altText = string.format("ALT: %.0f", altitude)
    surface.SetTextPos(elem.x + 10, elem.y + 140)
    surface.DrawText(altText)
    
    -- Coordinates
    local pos = state.FlightData.position
    if pos then
        local coordText = string.format("X:%.0f Y:%.0f Z:%.0f", pos.x, pos.y, pos.z)
        surface.SetTextPos(elem.x + 10, elem.y + 160)
        surface.DrawText(coordText)
    end
end

-- Draw status panel
function ASC.FlightTheme.DrawStatusPanel()
    local config = ASC.FlightTheme.Config
    local state = ASC.FlightTheme.State
    local elem = config.HUDElements.StatusPanel
    
    -- Background panel
    draw.RoundedBox(8, elem.x, elem.y, elem.w, elem.h, config.Colors.Panel)
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(elem.x, elem.y, elem.w, elem.h, 1)
    
    -- Title
    surface.SetFont("ASC_Body")
    surface.SetTextColor(config.Colors.Text)
    surface.SetTextPos(elem.x + 10, elem.y + 10)
    surface.DrawText("FLIGHT STATUS")
    
    local statusY = elem.y + 35
    
    -- Flight mode
    local flightMode = state.FlightData.mode or "MANUAL"
    local modeColor = flightMode == "AUTO" and config.Colors.AutopilotActive or config.Colors.ManualControl
    
    surface.SetFont("ASC_Small")
    surface.SetTextColor(modeColor)
    surface.SetTextPos(elem.x + 10, statusY)
    surface.DrawText("MODE: " .. flightMode)
    
    -- Engine status
    local engineStatus = state.FlightData.engineStatus or "OFFLINE"
    local engineColor = engineStatus == "ONLINE" and config.Colors.FlightActive or config.Colors.FlightInactive
    
    surface.SetTextColor(engineColor)
    surface.SetTextPos(elem.x + 150, statusY)
    surface.DrawText("ENGINES: " .. engineStatus)
    
    statusY = statusY + 20
    
    -- Fuel/Energy
    local fuel = state.FlightData.fuel or 100
    local fuelText = string.format("FUEL: %.0f%%", fuel)
    local fuelColor = fuel > 25 and config.Colors.Text or config.Colors.Emergency
    
    surface.SetTextColor(fuelColor)
    surface.SetTextPos(elem.x + 10, statusY)
    surface.DrawText(fuelText)
    
    -- Ship integrity
    local integrity = state.FlightData.integrity or 100
    local integrityText = string.format("INTEGRITY: %.0f%%", integrity)
    local integrityColor = integrity > 50 and config.Colors.Text or config.Colors.Emergency
    
    surface.SetTextColor(integrityColor)
    surface.SetTextPos(elem.x + 150, statusY)
    surface.DrawText(integrityText)
    
    statusY = statusY + 20
    
    -- Warning messages
    if state.FlightData.warnings then
        for _, warning in ipairs(state.FlightData.warnings) do
            surface.SetTextColor(config.Colors.Emergency)
            surface.SetTextPos(elem.x + 10, statusY)
            surface.DrawText("WARNING: " .. warning)
            statusY = statusY + 15
        end
    end
end

-- Draw waypoint list
function ASC.FlightTheme.DrawWaypointList()
    local config = ASC.FlightTheme.Config
    local state = ASC.FlightTheme.State
    local elem = config.HUDElements.WaypointList
    
    -- Background panel
    draw.RoundedBox(8, elem.x, elem.y, elem.w, elem.h, config.Colors.Panel)
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(elem.x, elem.y, elem.w, elem.h, 1)
    
    -- Title
    surface.SetFont("ASC_Body")
    surface.SetTextColor(config.Colors.Text)
    surface.SetTextPos(elem.x + 10, elem.y + 10)
    surface.DrawText("WAYPOINTS")
    
    -- Waypoint list
    local waypointY = elem.y + 35
    local waypoints = state.WaypointData or {}
    
    surface.SetFont("ASC_Small")
    
    for i, waypoint in ipairs(waypoints) do
        if waypointY > elem.y + elem.h - 20 then break end
        
        local waypointText = string.format("%d. %s", i, waypoint.name or "Waypoint")
        local waypointColor = waypoint.active and config.Colors.Destination or config.Colors.Waypoint
        
        surface.SetTextColor(waypointColor)
        surface.SetTextPos(elem.x + 10, waypointY)
        surface.DrawText(waypointText)
        
        -- Distance
        if waypoint.distance then
            local distText = string.format("%.0fm", waypoint.distance)
            surface.SetTextColor(config.Colors.TextSecondary)
            surface.SetTextPos(elem.x + elem.w - 50, waypointY)
            surface.DrawText(distText)
        end
        
        waypointY = waypointY + 18
    end
end

-- Draw flight crosshair
function ASC.FlightTheme.DrawFlightCrosshair()
    local config = ASC.FlightTheme.Config
    local scrW, scrH = ScrW(), ScrH()
    local centerX, centerY = scrW / 2, scrH / 2
    
    -- Flight crosshair
    local size = 20
    local thickness = 2
    local alpha = 200
    
    surface.SetDrawColor(config.Colors.Accent.r, config.Colors.Accent.g, config.Colors.Accent.b, alpha)
    
    -- Horizontal lines
    surface.DrawRect(centerX - size, centerY - thickness/2, size - 5, thickness)
    surface.DrawRect(centerX + 5, centerY - thickness/2, size - 5, thickness)
    
    -- Vertical lines
    surface.DrawRect(centerX - thickness/2, centerY - size, thickness, size - 5)
    surface.DrawRect(centerX - thickness/2, centerY + 5, thickness, size - 5)
    
    -- Center dot
    surface.DrawRect(centerX - 1, centerY - 1, 2, 2)
    
    -- Velocity vector indicator
    local velocity = ASC.FlightTheme.State.FlightData.velocity
    if velocity and velocity:Length() > 10 then
        local velX = centerX + velocity.x * 0.1
        local velY = centerY - velocity.z * 0.1
        
        surface.SetDrawColor(config.Colors.SpeedNormal.r, config.Colors.SpeedNormal.g, config.Colors.SpeedNormal.b, alpha)
        surface.DrawLine(centerX, centerY, velX, velY)
        surface.DrawRect(velX - 2, velY - 2, 4, 4)
    end
end

-- Request flight data from server
function ASC.FlightTheme.RequestFlightData()
    if IsValid(ASC.FlightTheme.State.ActiveFlightConsole) then
        -- This would send a network message to request updated flight data
        -- For now, we'll simulate some data
        ASC.FlightTheme.State.FlightData = {
            speed = math.random(0, 1000),
            maxSpeed = 1000,
            thrustX = math.random(-100, 100) / 100,
            thrustY = math.random(-100, 100) / 100,
            thrustZ = math.random(-100, 100) / 100,
            heading = math.random(0, 360),
            altitude = math.random(0, 5000),
            position = Vector(math.random(-1000, 1000), math.random(-1000, 1000), math.random(0, 1000)),
            mode = math.random() > 0.5 and "AUTO" or "MANUAL",
            engineStatus = "ONLINE",
            fuel = math.random(50, 100),
            integrity = math.random(80, 100),
            velocity = Vector(math.random(-100, 100), math.random(-100, 100), math.random(-50, 50))
        }
    end
end

-- Hook into HUD painting
hook.Add("HUDPaint", "ASC_FlightTheme", function()
    ASC.FlightTheme.DrawFlightHUD()
end)

-- Console commands
concommand.Add("asc_flight_hud_test", function()
    ASC.FlightTheme.ActivateFlightHUD(LocalPlayer())
end)

concommand.Add("asc_flight_hud_hide", function()
    ASC.FlightTheme.DeactivateFlightHUD()
end)

-- Initialize on client
hook.Add("Initialize", "ASC_FlightTheme_Init", function()
    ASC.FlightTheme.Initialize()
end)

print("[Advanced Space Combat] Flight Interface Theme System loaded successfully!")
