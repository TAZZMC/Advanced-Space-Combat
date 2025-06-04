-- Advanced Space Combat - HUD Overlay System v1.0.0
-- Enhanced HUD overlays, targeting systems, and space combat interfaces

print("[Advanced Space Combat] HUD Overlay System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.HUDOverlay = ASC.HUDOverlay or {}

-- HUD overlay configuration
ASC.HUDOverlay.Config = {
    -- Enable/Disable Features
    EnableTargetingSystem = true,
    EnableRadarOverlay = true,
    EnableThreatIndicators = true,
    EnableNavigationOverlay = true,
    EnableStatusOverlays = true,
    EnableCrosshairEnhancement = true,
    EnableDamageIndicators = true,
    EnableShieldVisualizer = true,
    
    -- Visual Settings
    OverlayAlpha = 0.8,
    AnimationSpeed = 2.0,
    TargetingRange = 2000,
    RadarRange = 5000,
    
    -- Layout Settings
    CrosshairSize = 32,
    TargetBoxSize = 64,
    RadarSize = 200,
    StatusBarHeight = 20,
    
    -- Colors
    Colors = {
        Friendly = Color(100, 255, 100, 200),
        Enemy = Color(255, 100, 100, 200),
        Neutral = Color(255, 255, 100, 200),
        Target = Color(255, 150, 0, 255),
        Crosshair = Color(0, 255, 255, 200),
        Radar = Color(100, 200, 255, 150),
        Shield = Color(100, 150, 255, 180),
        Hull = Color(255, 100, 100, 180),
        Energy = Color(255, 255, 100, 180),
        Warning = Color(255, 200, 0, 200),
        Critical = Color(255, 0, 0, 255)
    }
}

-- HUD overlay state
ASC.HUDOverlay.State = {
    CurrentTarget = nil,
    NearbyEntities = {},
    ThreatLevel = 0,
    LastScan = 0,
    ScanInterval = 0.1,
    
    -- Player status
    PlayerShip = nil,
    ShipCore = nil,
    ShieldLevel = 100,
    HullLevel = 100,
    EnergyLevel = 100,
    
    -- Animations
    Animations = {
        TargetPulse = 0,
        RadarSweep = 0,
        CrosshairRotation = 0,
        ThreatFlash = 0
    }
}

-- Custom function to draw outlined circle (since surface.DrawOutlinedCircle doesn't exist)
local function DrawOutlinedCircle(x, y, radius, segments)
    segments = segments or 32
    local angleStep = (2 * math.pi) / segments

    local points = {}
    for i = 0, segments do
        local angle = i * angleStep
        local px = x + math.cos(angle) * radius
        local py = y + math.sin(angle) * radius
        table.insert(points, {x = px, y = py})
    end

    -- Draw lines between consecutive points
    for i = 1, #points - 1 do
        surface.DrawLine(points[i].x, points[i].y, points[i + 1].x, points[i + 1].y)
    end
end

-- Initialize HUD overlay system
function ASC.HUDOverlay.Initialize()
    print("[Advanced Space Combat] HUD overlay system initialized")

    -- ConVars are now managed centrally by ASC.ConVarManager
    
    -- Initialize hooks
    ASC.HUDOverlay.InitializeHooks()
end

-- Initialize hooks
function ASC.HUDOverlay.InitializeHooks()
    -- Main HUD painting
    hook.Add("HUDPaint", "ASC_HUDOverlay_Paint", function()
        ASC.HUDOverlay.DrawHUDOverlays()
    end)
    
    -- Think hook for updates
    hook.Add("Think", "ASC_HUDOverlay_Think", function()
        ASC.HUDOverlay.UpdateHUDData()
    end)
    
    -- Player spawn hook
    hook.Add("PlayerSpawn", "ASC_HUDOverlay_PlayerSpawn", function(ply)
        if ply == LocalPlayer() then
            ASC.HUDOverlay.ResetPlayerData()
        end
    end)
end

-- Draw all HUD overlays
function ASC.HUDOverlay.DrawHUDOverlays()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    -- Protect against errors in HUD drawing
    local success, err = pcall(function()
        -- Update animations
        ASC.HUDOverlay.UpdateAnimations()

        -- Draw targeting system
        local targetingConVar = GetConVar("asc_hud_targeting")
        if targetingConVar and targetingConVar:GetBool() then
            ASC.HUDOverlay.DrawTargetingSystem()
        end

        -- Draw radar overlay
        local radarConVar = GetConVar("asc_hud_radar")
        if radarConVar and radarConVar:GetBool() then
            ASC.HUDOverlay.DrawRadarOverlay()
        end

        -- Draw threat indicators
        local threatsConVar = GetConVar("asc_hud_threats")
        if threatsConVar and threatsConVar:GetBool() then
            ASC.HUDOverlay.DrawThreatIndicators()
        end

        -- Draw enhanced crosshair
        local crosshairConVar = GetConVar("asc_hud_crosshair")
        if crosshairConVar and crosshairConVar:GetBool() then
            ASC.HUDOverlay.DrawEnhancedCrosshair()
        end

        -- Draw shield visualizer
        local shieldsConVar = GetConVar("asc_hud_shields")
        if shieldsConVar and shieldsConVar:GetBool() then
            ASC.HUDOverlay.DrawShieldVisualizer()
        end

        -- Draw status overlays
        ASC.HUDOverlay.DrawStatusOverlays()
    end)

    if not success then
        -- Log error but don't crash
        if ASC and ASC.ErrorRecovery then
            ASC.ErrorRecovery.HandleError("HUD overlay drawing failed: " .. tostring(err))
        end
    end
end

-- Draw targeting system
function ASC.HUDOverlay.DrawTargetingSystem()
    local ply = LocalPlayer()
    local trace = ply:GetEyeTrace()
    local target = trace.Entity
    
    if IsValid(target) and target:GetPos():Distance(ply:GetPos()) <= ASC.HUDOverlay.Config.TargetingRange then
        ASC.HUDOverlay.State.CurrentTarget = target
        ASC.HUDOverlay.DrawTargetBox(target)
        ASC.HUDOverlay.DrawTargetInfo(target)
    else
        ASC.HUDOverlay.State.CurrentTarget = nil
    end
end

-- Draw target box
function ASC.HUDOverlay.DrawTargetBox(target)
    local config = ASC.HUDOverlay.Config
    local state = ASC.HUDOverlay.State
    
    local pos = target:GetPos()
    local screenPos = pos:ToScreen()
    
    if not screenPos.visible then return end
    
    local size = config.TargetBoxSize
    local x, y = screenPos.x - size/2, screenPos.y - size/2
    
    -- Determine target color
    local color = config.Colors.Neutral
    if target:IsPlayer() then
        color = config.Colors.Friendly
    elseif target:GetClass():find("weapon") or target:GetClass():find("npc") then
        color = config.Colors.Enemy
    end
    
    -- Animated pulse effect
    local pulse = math.sin(CurTime() * 4) * 0.3 + 0.7
    color.a = color.a * pulse
    
    -- Draw targeting box
    surface.SetDrawColor(color)
    surface.DrawOutlinedRect(x, y, size, size, 2)
    
    -- Draw corner brackets
    local bracketSize = 8
    surface.DrawRect(x, y, bracketSize, 2)
    surface.DrawRect(x, y, 2, bracketSize)
    surface.DrawRect(x + size - bracketSize, y, bracketSize, 2)
    surface.DrawRect(x + size - 2, y, 2, bracketSize)
    surface.DrawRect(x, y + size - 2, bracketSize, 2)
    surface.DrawRect(x, y + size - bracketSize, 2, bracketSize)
    surface.DrawRect(x + size - bracketSize, y + size - 2, bracketSize, 2)
    surface.DrawRect(x + size - 2, y + size - bracketSize, 2, bracketSize)
end

-- Draw target information
function ASC.HUDOverlay.DrawTargetInfo(target)
    local config = ASC.HUDOverlay.Config
    local pos = target:GetPos()
    local screenPos = pos:ToScreen()
    
    if not screenPos.visible then return end
    
    local x, y = screenPos.x + 40, screenPos.y - 20
    
    -- Target name
    local targetName = target:GetClass()
    if target:IsPlayer() then
        targetName = target:Name()
    end
    
    surface.SetFont("DermaDefaultBold")
    surface.SetTextColor(config.Colors.Target)
    surface.SetTextPos(x, y)
    surface.DrawText("TARGET: " .. targetName)
    
    -- Distance
    local distance = LocalPlayer():GetPos():Distance(pos)
    surface.SetTextPos(x, y + 15)
    surface.DrawText(string.format("DISTANCE: %.0f units", distance))
    
    -- Health (if applicable)
    if target.Health and target:Health() > 0 then
        surface.SetTextPos(x, y + 30)
        surface.DrawText(string.format("HEALTH: %d", target:Health()))
    end
end

-- Draw radar overlay
function ASC.HUDOverlay.DrawRadarOverlay()
    local success, err = pcall(function()
        local config = ASC.HUDOverlay.Config
        local state = ASC.HUDOverlay.State

        local radarX = ScrW() - config.RadarSize - 20
        local radarY = 20
        local radarSize = config.RadarSize
        local centerX, centerY = radarX + radarSize/2, radarY + radarSize/2

        -- Radar background
        draw.RoundedBox(8, radarX, radarY, radarSize, radarSize, Color(0, 0, 0, 150))
        surface.SetDrawColor(config.Colors.Radar)
        surface.DrawOutlinedRect(radarX, radarY, radarSize, radarSize, 2)

        -- Radar grid
        surface.SetDrawColor(Color(config.Colors.Radar.r, config.Colors.Radar.g, config.Colors.Radar.b, 50))
        for i = 1, 4 do
            local radius = (radarSize/2) * (i/4)
            DrawOutlinedCircle(centerX, centerY, radius, 24) -- Use custom function with 24 segments
        end

        -- Center cross
        surface.SetDrawColor(config.Colors.Radar)
        surface.DrawLine(centerX - 10, centerY, centerX + 10, centerY)
        surface.DrawLine(centerX, centerY - 10, centerX, centerY + 10)

        -- Radar sweep
        local sweepAngle = (CurTime() * 90) % 360
        local sweepX = centerX + math.cos(math.rad(sweepAngle)) * (radarSize/2 - 10)
        local sweepY = centerY + math.sin(math.rad(sweepAngle)) * (radarSize/2 - 10)

        surface.SetDrawColor(Color(config.Colors.Radar.r, config.Colors.Radar.g, config.Colors.Radar.b, 100))
        surface.DrawLine(centerX, centerY, sweepX, sweepY)

        -- Draw entities on radar
        ASC.HUDOverlay.DrawRadarEntities(centerX, centerY, radarSize/2)
    end)

    if not success then
        -- Fallback: draw simple radar background
        local radarX = ScrW() - 200 - 20
        local radarY = 20
        draw.RoundedBox(8, radarX, radarY, 200, 200, Color(0, 0, 0, 150))
        surface.SetDrawColor(Color(100, 200, 255, 150))
        surface.DrawOutlinedRect(radarX, radarY, 200, 200, 2)

        if ASC and ASC.ErrorRecovery then
            ASC.ErrorRecovery.HandleError("Radar overlay drawing failed: " .. tostring(err))
        end
    end
end

-- Draw entities on radar
function ASC.HUDOverlay.DrawRadarEntities(centerX, centerY, maxRadius)
    local config = ASC.HUDOverlay.Config
    local ply = LocalPlayer()
    local playerPos = ply:GetPos()
    
    for _, ent in pairs(ents.FindInSphere(playerPos, config.RadarRange)) do
        if IsValid(ent) and ent ~= ply then
            local entPos = ent:GetPos()
            local distance = playerPos:Distance(entPos)
            local direction = (entPos - playerPos):GetNormalized()
            
            -- Convert to radar coordinates
            local radarDist = (distance / config.RadarRange) * maxRadius
            if radarDist <= maxRadius then
                local radarX = centerX + direction.x * radarDist
                local radarY = centerY + direction.y * radarDist
                
                -- Determine entity color
                local color = config.Colors.Neutral
                if ent:IsPlayer() then
                    color = config.Colors.Friendly
                elseif ent:GetClass():find("weapon") or ent:GetClass():find("npc") then
                    color = config.Colors.Enemy
                end
                
                -- Draw entity dot
                surface.SetDrawColor(color)
                surface.DrawRect(radarX - 2, radarY - 2, 4, 4)
            end
        end
    end
end

-- Draw enhanced crosshair
function ASC.HUDOverlay.DrawEnhancedCrosshair()
    local config = ASC.HUDOverlay.Config
    local state = ASC.HUDOverlay.State
    
    local centerX, centerY = ScrW()/2, ScrH()/2
    local size = config.CrosshairSize
    
    -- Rotating outer ring
    local rotation = CurTime() * 30
    local segments = 8
    
    for i = 0, segments - 1 do
        local angle = math.rad((360/segments) * i + rotation)
        local x1 = centerX + math.cos(angle) * (size/2 - 5)
        local y1 = centerY + math.sin(angle) * (size/2 - 5)
        local x2 = centerX + math.cos(angle) * (size/2)
        local y2 = centerY + math.sin(angle) * (size/2)
        
        surface.SetDrawColor(config.Colors.Crosshair)
        surface.DrawLine(x1, y1, x2, y2)
    end
    
    -- Center dot
    surface.SetDrawColor(config.Colors.Crosshair)
    surface.DrawRect(centerX - 1, centerY - 1, 2, 2)
    
    -- Dynamic crosshair based on target
    if ASC.HUDOverlay.State.CurrentTarget then
        surface.SetDrawColor(config.Colors.Target)
        surface.DrawOutlinedRect(centerX - size/4, centerY - size/4, size/2, size/2, 1)
    end
end

-- Draw shield visualizer
function ASC.HUDOverlay.DrawShieldVisualizer()
    local config = ASC.HUDOverlay.Config
    local state = ASC.HUDOverlay.State
    
    -- Find player's ship core
    local shipCore = ASC.HUDOverlay.FindPlayerShipCore()
    if not IsValid(shipCore) then return end
    
    local shieldLevel = shipCore:GetNWFloat("ShieldLevel", 100)
    if shieldLevel <= 0 then return end
    
    -- Draw shield effect around screen edges
    local alpha = (shieldLevel / 100) * 100
    local pulseAlpha = math.sin(CurTime() * 3) * 30 + alpha
    
    surface.SetDrawColor(Color(config.Colors.Shield.r, config.Colors.Shield.g, config.Colors.Shield.b, pulseAlpha))
    
    -- Shield border effect
    local borderWidth = 3
    surface.DrawRect(0, 0, ScrW(), borderWidth) -- Top
    surface.DrawRect(0, ScrH() - borderWidth, ScrW(), borderWidth) -- Bottom
    surface.DrawRect(0, 0, borderWidth, ScrH()) -- Left
    surface.DrawRect(ScrW() - borderWidth, 0, borderWidth, ScrH()) -- Right
end

-- Draw status overlays
function ASC.HUDOverlay.DrawStatusOverlays()
    -- Draw ship status if in ship
    local shipCore = ASC.HUDOverlay.FindPlayerShipCore()
    if IsValid(shipCore) then
        ASC.HUDOverlay.DrawShipStatus(shipCore)
    end
end

-- Draw ship status
function ASC.HUDOverlay.DrawShipStatus(shipCore)
    local config = ASC.HUDOverlay.Config
    
    local x, y = 20, ScrH() - 100
    local barWidth, barHeight = 200, 15
    
    -- Shield bar
    local shieldLevel = shipCore:GetNWFloat("ShieldLevel", 100)
    draw.RoundedBox(4, x, y, barWidth, barHeight, Color(0, 0, 0, 150))
    draw.RoundedBox(2, x + 2, y + 2, (barWidth - 4) * (shieldLevel/100), barHeight - 4, config.Colors.Shield)
    
    surface.SetFont("DermaDefaultBold")
    surface.SetTextColor(Color(255, 255, 255))
    surface.SetTextPos(x, y - 15)
    surface.DrawText("SHIELDS")
    
    -- Hull bar
    y = y + 25
    local hullLevel = shipCore:GetNWFloat("HullLevel", 100)
    draw.RoundedBox(4, x, y, barWidth, barHeight, Color(0, 0, 0, 150))
    draw.RoundedBox(2, x + 2, y + 2, (barWidth - 4) * (hullLevel/100), barHeight - 4, config.Colors.Hull)
    
    surface.SetTextPos(x, y - 15)
    surface.DrawText("HULL")
    
    -- Energy bar
    y = y + 25
    local energyLevel = shipCore:GetNWFloat("EnergyLevel", 100)
    draw.RoundedBox(4, x, y, barWidth, barHeight, Color(0, 0, 0, 150))
    draw.RoundedBox(2, x + 2, y + 2, (barWidth - 4) * (energyLevel/100), barHeight - 4, config.Colors.Energy)
    
    surface.SetTextPos(x, y - 15)
    surface.DrawText("ENERGY")
end

-- Update HUD data
function ASC.HUDOverlay.UpdateHUDData()
    local currentTime = CurTime()
    local state = ASC.HUDOverlay.State
    
    if currentTime - state.LastScan < state.ScanInterval then return end
    
    -- Update nearby entities
    local ply = LocalPlayer()
    if IsValid(ply) then
        state.NearbyEntities = ents.FindInSphere(ply:GetPos(), ASC.HUDOverlay.Config.TargetingRange)
    end
    
    state.LastScan = currentTime
end

-- Update animations
function ASC.HUDOverlay.UpdateAnimations()
    local state = ASC.HUDOverlay.State
    
    state.Animations.TargetPulse = math.sin(CurTime() * 4) * 0.5 + 0.5
    state.Animations.RadarSweep = (CurTime() * 90) % 360
    state.Animations.CrosshairRotation = CurTime() * 30
    state.Animations.ThreatFlash = math.sin(CurTime() * 6) * 0.5 + 0.5
end

-- Find player's ship core
function ASC.HUDOverlay.FindPlayerShipCore()
    local ply = LocalPlayer()
    if not IsValid(ply) then return nil end
    
    -- Look for nearby ship cores
    for _, ent in pairs(ents.FindByClass("ship_core")) do
        if IsValid(ent) and ent:GetPos():Distance(ply:GetPos()) <= 500 then
            return ent
        end
    end
    
    return nil
end

-- Reset player data
function ASC.HUDOverlay.ResetPlayerData()
    local state = ASC.HUDOverlay.State
    state.CurrentTarget = nil
    state.PlayerShip = nil
    state.ShipCore = nil
    state.ShieldLevel = 100
    state.HullLevel = 100
    state.EnergyLevel = 100
end

-- Draw threat indicators
function ASC.HUDOverlay.DrawThreatIndicators()
    -- Implementation for threat indicators
    -- This would show incoming missiles, enemy locks, etc.
end

-- Console commands
concommand.Add("asc_hud_reload", function()
    ASC.HUDOverlay.Initialize()
    print("[Advanced Space Combat] HUD overlay system reloaded")
end)

-- Initialize on client
hook.Add("Initialize", "ASC_HUDOverlay_Init", function()
    ASC.HUDOverlay.Initialize()
end)

print("[Advanced Space Combat] HUD Overlay System loaded successfully!")
