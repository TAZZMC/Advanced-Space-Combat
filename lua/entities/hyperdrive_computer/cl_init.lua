-- Hyperdrive Computer Entity - Client Side
include("shared.lua")

function ENT:Initialize()
    self.ScreenMaterial = Material("models/props_lab/monitor_lab")
    self.NextScreenUpdate = 0
    self.ScreenData = {}
end

function ENT:Draw()
    self:DrawModel()

    -- Draw computer screen
    if self:GetPowered() then
        self:DrawScreen()
    end
end

function ENT:DrawScreen()
    local pos = self:GetPos() + self:GetForward() * 8 + self:GetUp() * 15
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    ang:RotateAroundAxis(ang:Forward(), 90)

    cam.Start3D2D(pos, ang, 0.1)
        -- Screen background
        draw.RoundedBox(0, -100, -80, 200, 160, Color(0, 20, 40, 200))
        draw.RoundedBox(0, -98, -78, 196, 156, Color(0, 40, 80, 255))

        -- Title bar
        draw.RoundedBox(0, -98, -78, 196, 20, Color(0, 100, 200, 255))
        draw.SimpleText("HYPERDRIVE COMPUTER", "DermaDefault", 0, -68, Color(255, 255, 255), TEXT_ALIGN_CENTER)

        -- Mode indicator
        local modeColor = self:GetPowered() and Color(0, 255, 0) or Color(255, 0, 0)
        draw.SimpleText("MODE: " .. self:GetModeString(), "DermaDefault", 0, -45, modeColor, TEXT_ALIGN_CENTER)

        -- Status display
        if self:GetPowered() then
            draw.SimpleText("SYSTEM ONLINE", "DermaDefault", 0, -25, Color(0, 255, 0), TEXT_ALIGN_CENTER)
            draw.SimpleText("ENGINES LINKED", "DermaDefault", 0, -5, Color(100, 200, 255), TEXT_ALIGN_CENTER)
            draw.SimpleText("READY FOR OPERATIONS", "DermaDefault", 0, 15, Color(255, 255, 100), TEXT_ALIGN_CENTER)

            -- Pulsing "Press E" message
            local time = CurTime()
            local alpha = math.sin(time * 4) * 127 + 128
            draw.SimpleText("PRESS E TO OPEN", "DermaDefault", 0, 35, Color(255, 255, 255, alpha), TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("SYSTEM OFFLINE", "DermaDefault", 0, -25, Color(255, 0, 0), TEXT_ALIGN_CENTER)
            draw.SimpleText("NO POWER", "DermaDefault", 0, -5, Color(255, 100, 0), TEXT_ALIGN_CENTER)
        end

        -- Animated elements
        local time = CurTime()
        local pulse = math.sin(time * 3) * 0.5 + 0.5

        if self:GetPowered() then
            -- Power indicator
            local powerColor = Color(0, 255 * pulse, 0, 255)
            draw.RoundedBox(0, 80, -70, 10, 10, powerColor)

            -- Data streams
            for i = 1, 5 do
                local y = -30 + i * 15
                local width = 150 * (math.sin(time * 2 + i) * 0.5 + 0.5)
                draw.RoundedBox(0, -75, y, width, 2, Color(0, 150, 255, 100))
            end
        end
    cam.End3D2D()
end

function ENT:GetModeString()
    local mode = self:GetComputerMode()
    if mode == 1 then return "NAVIGATION"
    elseif mode == 2 then return "PLANETS"
    elseif mode == 3 then return "STATUS"
    else return "NAVIGATION" end
end

-- Computer Interface
local computerInterface = {
    entity = nil,
    visible = false,
    mode = 1,
    engines = {},
    lastUpdate = 0,
    selectedEngine = nil,
    currentCoords = Vector(0, 0, 0),
    waypoints = {}
}

function ENT:OpenInterface(mode, engines)
    computerInterface.entity = self
    computerInterface.visible = true
    computerInterface.mode = mode or 1
    computerInterface.engines = engines or {}
    gui.EnableScreenClicker(true)
end

function ENT:CloseInterface()
    computerInterface.visible = false
    gui.EnableScreenClicker(false)
end

-- Network message handlers
net.Receive("hyperdrive_computer", function()
    local computer = net.ReadEntity()
    local mode = net.ReadInt(8)
    local engineCount = net.ReadInt(8)

    local engines = {}
    for i = 1, engineCount do
        local engine = net.ReadEntity()
        if IsValid(engine) then
            engines[i] = {
                entity = engine,
                energy = net.ReadFloat(),
                cooldown = net.ReadFloat(),
                charging = net.ReadBool(),
                destination = net.ReadVector()
            }
        end
    end

    if IsValid(computer) then
        computer:OpenInterface(mode, engines)
    end
end)

-- Advanced Computer Interface HUD
hook.Add("HUDPaint", "HyperdriveComputerInterface", function()
    if not computerInterface.visible or not IsValid(computerInterface.entity) then return end

    local scrW, scrH = ScrW(), ScrH()
    local panelW, panelH = 800, 600
    local x, y = (scrW - panelW) / 2, (scrH - panelH) / 2

    -- Main background
    draw.RoundedBox(8, x, y, panelW, panelH, Color(10, 20, 40, 240))
    draw.RoundedBox(8, x + 4, y + 4, panelW - 8, panelH - 8, Color(20, 40, 80, 220))

    -- Title bar
    draw.RoundedBox(8, x + 4, y + 4, panelW - 8, 40, Color(0, 100, 200, 255))
    draw.SimpleText("HYPERDRIVE FLEET COMMAND", "DermaLarge", x + panelW/2, y + 24, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Mode tabs
    local tabW = (panelW - 40) / 3
    local tabY = y + 50

    local tabNames = {"NAVIGATION", "PLANETS", "STATUS"}

    for i = 1, 3 do
        local tabX = x + 20 + (i - 1) * tabW
        local tabColor = (computerInterface.mode == i) and Color(0, 150, 255, 255) or Color(50, 50, 100, 255)
        local tabText = tabNames[i]

        draw.RoundedBox(4, tabX, tabY, tabW - 5, 30, tabColor)
        draw.SimpleText(tabText, "DermaDefault", tabX + tabW/2 - 2.5, tabY + 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Tab click detection
        if input.IsMouseDown(MOUSE_LEFT) and
           gui.MouseX() >= tabX and gui.MouseX() <= tabX + tabW - 5 and
           gui.MouseY() >= tabY and gui.MouseY() <= tabY + 30 then
            if CurTime() - computerInterface.lastUpdate > 0.2 then
                computerInterface.lastUpdate = CurTime()
                computerInterface.mode = i

                net.Start("hyperdrive_computer_mode")
                net.WriteEntity(computerInterface.entity)
                net.WriteInt(i, 8)
                net.SendToServer()
            end
        end
    end

    -- Content area
    local contentY = tabY + 40
    local contentH = panelH - 140

    if computerInterface.mode == 1 then
        -- Navigation mode (combines old navigation + manual control)
        DrawSimpleNavigationMode(x + 20, contentY, panelW - 40, contentH)
    elseif computerInterface.mode == 2 then
        -- Planets mode (combines waypoints + planet detection)
        DrawSimplePlanetsMode(x + 20, contentY, panelW - 40, contentH)
    elseif computerInterface.mode == 3 then
        -- Status mode (combines engineering + diagnostics)
        DrawSimpleStatusMode(x + 20, contentY, panelW - 40, contentH)
    end

    -- Close button
    local closeX, closeY = x + panelW - 80, y + panelH - 40
    local closeColor = Color(200, 0, 0)

    if input.IsMouseDown(MOUSE_LEFT) and
       gui.MouseX() >= closeX and gui.MouseX() <= closeX + 60 and
       gui.MouseY() >= closeY and gui.MouseY() <= closeY + 25 then
        closeColor = Color(255, 0, 0)

        if CurTime() - computerInterface.lastUpdate > 0.2 then
            computerInterface.lastUpdate = CurTime()
            computerInterface.entity:CloseInterface()
        end
    end

    draw.RoundedBox(4, closeX, closeY, 60, 25, closeColor)
    draw.SimpleText("CLOSE", "DermaDefault", closeX + 30, closeY + 12.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

-- Simple Navigation Mode
function DrawSimpleNavigationMode(x, y, w, h)
    draw.SimpleText("EASY NAVIGATION", "DermaDefaultBold", x, y, Color(100, 255, 100))

    local engines = computerInterface.engines
    local yOffset = 40

    -- Simple status
    local readyEngines = 0
    for _, engineData in ipairs(engines) do
        if IsValid(engineData.entity) and not engineData.charging and engineData.cooldown <= CurTime() then
            readyEngines = readyEngines + 1
        end
    end

    draw.SimpleText(string.format("Master Engines Ready: %d", readyEngines),
                   "DermaLarge", x, y + yOffset, Color(255, 255, 255))
    yOffset = yOffset + 60

    -- Simple instructions
    draw.SimpleText("How to Jump:", "DermaDefault", x, y + yOffset, Color(255, 255, 100))
    yOffset = yOffset + 30

    draw.SimpleText("1. Point your crosshair where you want to go", "DermaDefault", x + 20, y + yOffset, Color(200, 200, 200))
    yOffset = yOffset + 25

    draw.SimpleText("2. Click the big JUMP button below", "DermaDefault", x + 20, y + yOffset, Color(200, 200, 200))
    yOffset = yOffset + 50

    -- Big simple jump button
    local jumpColor = readyEngines > 0 and Color(0, 200, 0) or Color(100, 100, 100)
    local jumpX, jumpY = x + w/2 - 150, y + yOffset

    if readyEngines > 0 and input.IsMouseDown(MOUSE_LEFT) and
       gui.MouseX() >= jumpX and gui.MouseX() <= jumpX + 300 and
       gui.MouseY() >= jumpY and gui.MouseY() <= jumpY + 60 then
        jumpColor = Color(0, 255, 0)

        if CurTime() - computerInterface.lastUpdate > 0.2 then
            computerInterface.lastUpdate = CurTime()
            local ply = LocalPlayer()
            local trace = ply:GetEyeTrace()
            if trace.Hit then
                net.Start("hyperdrive_fleet_jump")
                net.WriteEntity(computerInterface.entity)
                net.WriteVector(trace.HitPos + Vector(0, 0, 50))
                net.SendToServer()
            end
        end
    end

    draw.RoundedBox(8, jumpX, jumpY, 300, 60, jumpColor)
    draw.SimpleText("JUMP TO CROSSHAIR", "DermaLarge", jumpX + 150, jumpY + 30, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if readyEngines == 0 then
        draw.SimpleText("No Master Engines Ready", "DermaDefault", jumpX + 150, jumpY + 70, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

-- Simple Planets Mode (combines waypoints + planet detection)
function DrawSimplePlanetsMode(x, y, w, h)
    draw.SimpleText("PLANETS & WAYPOINTS", "DermaDefaultBold", x, y, Color(100, 255, 100))

    local yOffset = 40

    -- Simple planet scan button
    local scanColor = Color(100, 0, 200)
    local scanX, scanY = x, y + yOffset

    if input.IsMouseDown(MOUSE_LEFT) and
       gui.MouseX() >= scanX and gui.MouseX() <= scanX + 200 and
       gui.MouseY() >= scanY and gui.MouseY() <= scanY + 30 then
        scanColor = Color(150, 0, 255)

        if CurTime() - computerInterface.lastUpdate > 0.2 then
            computerInterface.lastUpdate = CurTime()

            net.Start("hyperdrive_scan_planets")
            net.WriteEntity(computerInterface.entity)
            net.SendToServer()
        end
    end

    draw.RoundedBox(4, scanX, scanY, 200, 30, scanColor)
    draw.SimpleText("FIND PLANETS", "DermaDefault", scanX + 100, scanY + 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Save location button
    local saveColor = Color(0, 150, 100)
    local saveX, saveY = x + 220, y + yOffset

    if input.IsMouseDown(MOUSE_LEFT) and
       gui.MouseX() >= saveX and gui.MouseX() <= saveX + 200 and
       gui.MouseY() >= saveY and gui.MouseY() <= saveY + 30 then
        saveColor = Color(0, 200, 150)

        if CurTime() - computerInterface.lastUpdate > 0.2 then
            computerInterface.lastUpdate = CurTime()

            local waypointName = "Location_" .. os.date("%H%M%S")
            local ply = LocalPlayer()
            local trace = ply:GetEyeTrace()

            if trace.Hit then
                net.Start("hyperdrive_save_waypoint")
                net.WriteEntity(computerInterface.entity)
                net.WriteString(waypointName)
                net.WriteVector(trace.HitPos + Vector(0, 0, 50))
                net.SendToServer()
            end
        end
    end

    draw.RoundedBox(4, saveX, saveY, 200, 30, saveColor)
    draw.SimpleText("SAVE LOCATION", "DermaDefault", saveX + 100, saveY + 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    yOffset = yOffset + 50

    -- Simple waypoint list
    draw.SimpleText("Saved Locations:", "DermaDefault", x, y + yOffset, Color(255, 255, 255))
    yOffset = yOffset + 25

    -- Sample waypoints for display
    local sampleWaypoints = {
        {name = "🌍 Earth-like Planet", distance = 15670, isPlanet = true},
        {name = "🌍 Gas Giant", distance = 28400, isPlanet = true},
        {name = "Home Base", distance = 1250, isPlanet = false},
        {name = "🌍 Desert Moon", distance = 8900, isPlanet = true},
        {name = "Mining Station", distance = 3400, isPlanet = false}
    }

    for i, waypoint in ipairs(sampleWaypoints) do
        if i > 6 then break end

        local waypointY = y + yOffset + (i - 1) * 35
        local bgColor = waypoint.isPlanet and Color(50, 30, 80, 150) or Color(30, 50, 30, 150)
        local textColor = waypoint.isPlanet and Color(255, 200, 255) or Color(200, 255, 200)

        draw.RoundedBox(4, x, waypointY, w - 20, 30, bgColor)
        draw.SimpleText(waypoint.name, "DermaDefault", x + 10, waypointY + 8, textColor)
        draw.SimpleText(string.format("%.0f units", waypoint.distance), "DermaDefault", x + 250, waypointY + 8, Color(150, 150, 255))

        -- Simple jump button for planets
        if waypoint.isPlanet then
            local jumpColor = Color(200, 100, 0)
            local jumpX = x + w - 120

            if input.IsMouseDown(MOUSE_LEFT) and
               gui.MouseX() >= jumpX and gui.MouseX() <= jumpX + 100 and
               gui.MouseY() >= waypointY + 2 and gui.MouseY() <= waypointY + 28 then
                jumpColor = Color(255, 150, 0)

                if CurTime() - computerInterface.lastUpdate > 0.2 then
                    computerInterface.lastUpdate = CurTime()

                    -- Extract planet name from waypoint name (remove "[PLANET] " prefix)
                    local planetName = waypoint.name
                    if string.find(planetName, "%[PLANET%] ") then
                        planetName = string.gsub(planetName, "%[PLANET%] ", "")
                    end

                    net.Start("hyperdrive_quick_jump_planet")
                    net.WriteEntity(computerInterface.entity)
                    net.WriteString(planetName)
                    net.SendToServer()
                end
            end

            draw.RoundedBox(4, jumpX, waypointY + 2, 100, 26, jumpColor)
            draw.SimpleText("QUICK JUMP", "DermaDefault", jumpX + 50, waypointY + 15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
end

-- Simple Status Mode (combines engineering + diagnostics)
function DrawSimpleStatusMode(x, y, w, h)
    draw.SimpleText("SYSTEM STATUS", "DermaDefaultBold", x, y, Color(255, 200, 100))

    local engines = computerInterface.engines
    local yOffset = 40

    -- Simple engine status
    local totalEngines = #engines
    local readyEngines = 0
    local chargingEngines = 0

    for _, engineData in ipairs(engines) do
        if IsValid(engineData.entity) then
            if engineData.charging then
                chargingEngines = chargingEngines + 1
            elseif engineData.cooldown <= CurTime() then
                readyEngines = readyEngines + 1
            end
        end
    end

    draw.SimpleText("Master Engine Status:", "DermaDefault", x, y + yOffset, Color(255, 255, 255))
    yOffset = yOffset + 30

    draw.SimpleText("• Total Engines: " .. totalEngines, "DermaLarge", x + 20, y + yOffset, Color(200, 200, 200))
    yOffset = yOffset + 30
    draw.SimpleText("• Ready to Jump: " .. readyEngines, "DermaLarge", x + 20, y + yOffset, readyEngines > 0 and Color(0, 255, 0) or Color(255, 100, 100))
    yOffset = yOffset + 30
    draw.SimpleText("• Currently Charging: " .. chargingEngines, "DermaLarge", x + 20, y + yOffset, chargingEngines > 0 and Color(255, 255, 0) or Color(200, 200, 200))

    yOffset = yOffset + 60

    -- Simple system status
    draw.SimpleText("Computer Status:", "DermaDefault", x, y + yOffset, Color(255, 255, 255))
    yOffset = yOffset + 30

    draw.SimpleText("• System: ONLINE", "DermaDefault", x + 20, y + yOffset, Color(0, 255, 0))
    yOffset = yOffset + 25
    draw.SimpleText("• Planet Detection: AUTO", "DermaDefault", x + 20, y + yOffset, Color(0, 255, 0))
    yOffset = yOffset + 25
    draw.SimpleText("• Auto-Link: ENABLED", "DermaDefault", x + 20, y + yOffset, Color(0, 255, 0))

    yOffset = yOffset + 50

    -- Performance info
    local fps = math.floor(1 / FrameTime())
    local fpsColor = fps >= 60 and Color(0, 255, 0) or fps >= 30 and Color(255, 255, 0) or Color(255, 0, 0)

    draw.SimpleText("Performance: " .. fps .. " FPS", "DermaDefault", x, y + yOffset, fpsColor)
end

-- All old complex functions have been replaced by the simple 3-mode system above
