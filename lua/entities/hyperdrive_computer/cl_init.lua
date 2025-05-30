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
                destination = net.ReadVector(),
                shieldActive = net.ReadBool(),
                shieldStrength = net.ReadFloat(),
                shieldPercent = net.ReadFloat(),
                shieldRecharging = net.ReadBool(),
                shieldOverloaded = net.ReadBool(),
                capIntegrated = net.ReadBool()
            }
        end
    end

    -- Read ship information with core validation and hull damage
    local shipDetected = net.ReadBool()
    local shipInfo = {}
    if shipDetected then
        shipInfo = {
            shipType = net.ReadString(),
            entityCount = net.ReadInt(16),
            playerCount = net.ReadInt(8),
            mass = net.ReadFloat(),
            center = net.ReadVector(),
            frontDirection = net.ReadVector(),
            frontIndicatorVisible = net.ReadBool(),
            coreValid = net.ReadBool(),
            coreMessage = net.ReadString(),
            hullAvailable = net.ReadBool(),
            hullIntegrity = net.ReadFloat(),
            hullCritical = net.ReadBool(),
            hullEmergency = net.ReadBool(),
            hullBreaches = net.ReadInt(8),
            hullSystemFailures = net.ReadInt(8),
            hullAutoRepair = net.ReadBool(),
            shipCoreUIAvailable = net.ReadBool()
        }
    end

    computerInterface.shipInfo = shipInfo
    computerInterface.shipDetected = shipDetected

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
    draw.SimpleText("NAVIGATION & SHIP STATUS", "DermaDefaultBold", x, y, Color(100, 255, 100))

    local engines = computerInterface.engines
    local yOffset = 30

    -- Ship Information Panel
    if computerInterface.shipDetected and computerInterface.shipInfo then
        local shipInfo = computerInterface.shipInfo

        -- Check core validation status
        local coreValid = shipInfo.coreValid ~= false -- Default to true if not specified
        local panelColor = coreValid and Color(20, 40, 60, 150) or Color(60, 40, 20, 150)
        local titleColor = coreValid and Color(0, 255, 0) or Color(255, 200, 0)
        local titleText = coreValid and "SHIP DETECTED (SHIP CORE ACTIVE)" or "SHIP DETECTED (CORE CONFLICT)"

        draw.RoundedBox(4, x, y + yOffset, w - 20, coreValid and 80 or 100, panelColor)
        draw.SimpleText(titleText, "DermaDefaultBold", x + 10, y + yOffset + 5, titleColor)

        draw.SimpleText("Type: " .. shipInfo.shipType, "DermaDefault", x + 10, y + yOffset + 25, Color(255, 255, 255))
        draw.SimpleText("Entities: " .. shipInfo.entityCount, "DermaDefault", x + 200, y + yOffset + 25, Color(200, 200, 255))
        draw.SimpleText("Players: " .. shipInfo.playerCount, "DermaDefault", x + 320, y + yOffset + 25, Color(200, 255, 200))

        draw.SimpleText("Mass: " .. string.format("%.1f", shipInfo.mass), "DermaDefault", x + 10, y + yOffset + 45, Color(255, 200, 100))
        draw.SimpleText("Front Indicator: " .. (shipInfo.frontIndicatorVisible and "VISIBLE" or "HIDDEN"), "DermaDefault", x + 200, y + yOffset + 45, shipInfo.frontIndicatorVisible and Color(0, 255, 0) or Color(200, 200, 200))

        -- Show core validation message if there's an issue
        if not coreValid and shipInfo.coreMessage then
            draw.SimpleText("Core Status: " .. shipInfo.coreMessage, "DermaDefault", x + 10, y + yOffset + 65, Color(255, 150, 150))
            draw.SimpleText("Remove duplicate ship cores to resolve", "DermaDefault", x + 10, y + yOffset + 80, Color(255, 200, 100))
        end

        -- Hull damage information
        if shipInfo.hullAvailable then
            yOffset = yOffset + (coreValid and 90 or 110)

            local hullColor = Color(20, 60, 20, 150)
            local hullTextColor = Color(0, 255, 0)
            local hullHeight = 80

            if shipInfo.hullEmergency then
                hullColor = Color(80, 20, 20, 150)
                hullTextColor = Color(255, 100, 100)
                hullHeight = 100
            elseif shipInfo.hullCritical then
                hullColor = Color(60, 40, 20, 150)
                hullTextColor = Color(255, 200, 100)
                hullHeight = 90
            elseif shipInfo.hullIntegrity < 75 then
                hullColor = Color(40, 40, 20, 150)
                hullTextColor = Color(255, 255, 100)
            end

            draw.RoundedBox(4, x, y + yOffset, w - 20, hullHeight, hullColor)

            local hullTitle = "HULL INTEGRITY: " .. string.format("%.1f", shipInfo.hullIntegrity) .. "%"
            if shipInfo.hullEmergency then
                hullTitle = "HULL EMERGENCY: " .. string.format("%.1f", shipInfo.hullIntegrity) .. "%"
            elseif shipInfo.hullCritical then
                hullTitle = "HULL CRITICAL: " .. string.format("%.1f", shipInfo.hullIntegrity) .. "%"
            end

            draw.SimpleText(hullTitle, "DermaDefaultBold", x + 10, y + yOffset + 5, hullTextColor)

            local statusLine1 = "Breaches: " .. shipInfo.hullBreaches .. " | System Failures: " .. shipInfo.hullSystemFailures
            draw.SimpleText(statusLine1, "DermaDefault", x + 10, y + yOffset + 25, Color(255, 255, 255))

            local statusLine2 = "Auto-Repair: " .. (shipInfo.hullAutoRepair and "ACTIVE" or "INACTIVE")
            draw.SimpleText(statusLine2, "DermaDefault", x + 10, y + yOffset + 45, shipInfo.hullAutoRepair and Color(0, 255, 0) or Color(255, 100, 100))

            if shipInfo.hullEmergency then
                draw.SimpleText("EMERGENCY PROTOCOLS ACTIVE", "DermaDefault", x + 10, y + yOffset + 65, Color(255, 150, 150))
                draw.SimpleText("Immediate repair required!", "DermaDefault", x + 10, y + yOffset + 80, Color(255, 200, 100))
            elseif shipInfo.hullCritical then
                draw.SimpleText("Critical hull damage detected", "DermaDefault", x + 10, y + yOffset + 65, Color(255, 200, 100))
            end
        end

        -- Ship Core UI Button
        if shipInfo.shipCoreUIAvailable then
            yOffset = yOffset + (shipInfo.hullAvailable and 120 or 100)

            local buttonColor = Color(50, 100, 150, 150)
            local buttonHeight = 40

            draw.RoundedBox(4, x, y + yOffset, w - 20, buttonHeight, buttonColor)
            draw.SimpleText("OPEN SHIP CORE MANAGEMENT", "DermaDefaultBold", x + (w - 20)/2, y + yOffset + 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText("Advanced ship systems control", "DermaDefault", x + (w - 20)/2, y + yOffset + 30, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

            -- Handle click
            local mouseX, mouseY = gui.MouseX(), gui.MouseY()
            if mouseX >= x and mouseX <= x + w - 20 and mouseY >= y + yOffset and mouseY <= y + yOffset + buttonHeight then
                if input.IsMouseDown(MOUSE_LEFT) and CurTime() - computerInterface.lastClick > 0.5 then
                    computerInterface.lastClick = CurTime()
                    -- Send request to open ship core UI
                    net.Start("hyperdrive_computer_command")
                    net.WriteEntity(computerInterface.entity)
                    net.WriteString("open_ship_core_ui")
                    net.SendToServer()
                end
            end
        end

        yOffset = yOffset + 90
    else
        draw.RoundedBox(4, x, y + yOffset, w - 20, 80, Color(60, 20, 20, 150))
        draw.SimpleText("SHIP CORE REQUIRED", "DermaDefaultBold", x + 10, y + yOffset + 5, Color(255, 100, 100))
        draw.SimpleText("Build a ship with ship core around the computer or engines", "DermaDefault", x + 10, y + yOffset + 20, Color(200, 200, 200))
        draw.SimpleText("Ship core is MANDATORY for hyperdrive operation", "DermaDefault", x + 10, y + yOffset + 35, Color(255, 150, 150))
        draw.SimpleText("Only ONE ship core per ship is allowed", "DermaDefault", x + 10, y + yOffset + 50, Color(255, 200, 100))
        yOffset = yOffset + 50
    end

    -- Engine status with enhanced shield info
    local readyEngines = 0
    local shieldedEngines = 0
    local rechargingShields = 0
    local overloadedShields = 0

    for _, engineData in ipairs(engines) do
        if IsValid(engineData.entity) and not engineData.charging and engineData.cooldown <= CurTime() then
            readyEngines = readyEngines + 1
        end
        if engineData.shieldActive then
            shieldedEngines = shieldedEngines + 1
            if engineData.shieldRecharging then
                rechargingShields = rechargingShields + 1
            end
            if engineData.shieldOverloaded then
                overloadedShields = overloadedShields + 1
            end
        end
    end

    draw.SimpleText(string.format("Master Engines Ready: %d", readyEngines),
                   "DermaLarge", x, y + yOffset, Color(255, 255, 255))
    yOffset = yOffset + 25

    -- Enhanced shield status
    local shieldColor = Color(200, 200, 200)
    if overloadedShields > 0 then
        shieldColor = Color(255, 100, 100)
    elseif rechargingShields > 0 then
        shieldColor = Color(255, 255, 100)
    elseif shieldedEngines > 0 then
        shieldColor = Color(0, 255, 255)
    end

    draw.SimpleText(string.format("Shields Active: %d", shieldedEngines), "DermaDefault", x, y + yOffset, shieldColor)
    if rechargingShields > 0 then
        draw.SimpleText(string.format("(%d recharging)", rechargingShields), "DermaDefault", x + 150, y + yOffset, Color(255, 255, 100))
    end
    if overloadedShields > 0 then
        draw.SimpleText(string.format("(%d overloaded)", overloadedShields), "DermaDefault", x + 250, y + yOffset, Color(255, 100, 100))
    end
    yOffset = yOffset + 30

    -- Shield control buttons
    local shieldActivateColor = Color(0, 120, 120)
    local shieldActivateX, shieldActivateY = x, y + yOffset

    if input.IsMouseDown(MOUSE_LEFT) and
       gui.MouseX() >= shieldActivateX and gui.MouseX() <= shieldActivateX + 120 and
       gui.MouseY() >= shieldActivateY and gui.MouseY() <= shieldActivateY + 25 then
        shieldActivateColor = Color(0, 180, 180)

        if CurTime() - computerInterface.lastUpdate > 0.2 then
            computerInterface.lastUpdate = CurTime()
            net.Start("hyperdrive_fleet_shields")
            net.WriteEntity(computerInterface.entity)
            net.WriteBool(true)
            net.SendToServer()
        end
    end

    draw.RoundedBox(4, shieldActivateX, shieldActivateY, 120, 25, shieldActivateColor)
    draw.SimpleText("SHIELDS UP", "DermaDefault", shieldActivateX + 60, shieldActivateY + 12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    local shieldDeactivateColor = Color(120, 0, 0)
    local shieldDeactivateX, shieldDeactivateY = x + 140, y + yOffset

    if input.IsMouseDown(MOUSE_LEFT) and
       gui.MouseX() >= shieldDeactivateX and gui.MouseX() <= shieldDeactivateX + 120 and
       gui.MouseY() >= shieldDeactivateY and gui.MouseY() <= shieldDeactivateY + 25 then
        shieldDeactivateColor = Color(180, 0, 0)

        if CurTime() - computerInterface.lastUpdate > 0.2 then
            computerInterface.lastUpdate = CurTime()
            net.Start("hyperdrive_fleet_shields")
            net.WriteEntity(computerInterface.entity)
            net.WriteBool(false)
            net.SendToServer()
        end
    end

    draw.RoundedBox(4, shieldDeactivateX, shieldDeactivateY, 120, 25, shieldDeactivateColor)
    draw.SimpleText("SHIELDS DOWN", "DermaDefault", shieldDeactivateX + 60, shieldDeactivateY + 12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Ship control buttons
    if computerInterface.shipDetected then
        local frontIndicatorColor = Color(100, 100, 0)
        local frontIndicatorX, frontIndicatorY = x + 280, y + yOffset

        if input.IsMouseDown(MOUSE_LEFT) and
           gui.MouseX() >= frontIndicatorX and gui.MouseX() <= frontIndicatorX + 120 and
           gui.MouseY() >= frontIndicatorY and gui.MouseY() <= frontIndicatorY + 25 then
            frontIndicatorColor = Color(150, 150, 0)

            if CurTime() - computerInterface.lastUpdate > 0.2 then
                computerInterface.lastUpdate = CurTime()
                net.Start("hyperdrive_toggle_front_indicator")
                net.WriteEntity(computerInterface.entity)
                net.SendToServer()
            end
        end

        draw.RoundedBox(4, frontIndicatorX, frontIndicatorY, 120, 25, frontIndicatorColor)
        draw.SimpleText("FRONT ARROW", "DermaDefault", frontIndicatorX + 60, frontIndicatorY + 12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        local autoDetectColor = Color(0, 100, 100)
        local autoDetectX, autoDetectY = x + 420, y + yOffset

        if input.IsMouseDown(MOUSE_LEFT) and
           gui.MouseX() >= autoDetectX and gui.MouseX() <= autoDetectX + 120 and
           gui.MouseY() >= autoDetectY and gui.MouseY() <= autoDetectY + 25 then
            autoDetectColor = Color(0, 150, 150)

            if CurTime() - computerInterface.lastUpdate > 0.2 then
                computerInterface.lastUpdate = CurTime()
                net.Start("hyperdrive_auto_detect_front")
                net.WriteEntity(computerInterface.entity)
                net.SendToServer()
            end
        end

        draw.RoundedBox(4, autoDetectX, autoDetectY, 120, 25, autoDetectColor)
        draw.SimpleText("AUTO FRONT", "DermaDefault", autoDetectX + 60, autoDetectY + 12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    yOffset = yOffset + 40

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

-- Simple Status Mode (combines engineering + diagnostics + shields)
function DrawSimpleStatusMode(x, y, w, h)
    draw.SimpleText("SYSTEM & SHIELD STATUS", "DermaDefaultBold", x, y, Color(255, 200, 100))

    local engines = computerInterface.engines
    local yOffset = 30

    -- Ship status panel
    if computerInterface.shipDetected and computerInterface.shipInfo then
        local shipInfo = computerInterface.shipInfo

        draw.RoundedBox(4, x, y + yOffset, w - 20, 100, Color(20, 40, 60, 150))
        draw.SimpleText("SHIP ANALYSIS", "DermaDefaultBold", x + 10, y + yOffset + 5, Color(100, 255, 100))

        draw.SimpleText("Ship Type: " .. shipInfo.shipType, "DermaDefault", x + 10, y + yOffset + 25, Color(255, 255, 255))
        draw.SimpleText("Total Entities: " .. shipInfo.entityCount, "DermaDefault", x + 250, y + yOffset + 25, Color(200, 200, 255))
        draw.SimpleText("Players Aboard: " .. shipInfo.playerCount, "DermaDefault", x + 400, y + yOffset + 25, Color(200, 255, 200))

        draw.SimpleText("Ship Mass: " .. string.format("%.1f", shipInfo.mass), "DermaDefault", x + 10, y + yOffset + 45, Color(255, 200, 100))
        draw.SimpleText("Front Indicator: " .. (shipInfo.frontIndicatorVisible and "VISIBLE" or "HIDDEN"), "DermaDefault", x + 250, y + yOffset + 45, shipInfo.frontIndicatorVisible and Color(0, 255, 0) or Color(200, 200, 200))

        local frontDir = shipInfo.frontDirection
        draw.SimpleText(string.format("Front Vector: %.2f, %.2f, %.2f", frontDir.x, frontDir.y, frontDir.z), "DermaDefault", x + 10, y + yOffset + 65, Color(200, 200, 255))

        yOffset = yOffset + 110
    else
        draw.RoundedBox(4, x, y + yOffset, w - 20, 80, Color(60, 20, 20, 150))
        draw.SimpleText("SHIP CORE REQUIRED", "DermaDefaultBold", x + 10, y + yOffset + 5, Color(255, 100, 100))
        draw.SimpleText("Build a ship with ship core around the computer or engines", "DermaDefault", x + 10, y + yOffset + 20, Color(200, 200, 200))
        draw.SimpleText("Ship core is MANDATORY for hyperdrive operation", "DermaDefault", x + 10, y + yOffset + 35, Color(255, 150, 150))
        draw.SimpleText("Only ONE ship core per ship is allowed", "DermaDefault", x + 10, y + yOffset + 50, Color(255, 200, 100))
        yOffset = yOffset + 50
    end

    -- Enhanced engine status
    local totalEngines = #engines
    local readyEngines = 0
    local chargingEngines = 0
    local shieldedEngines = 0
    local rechargingShields = 0
    local overloadedShields = 0
    local capShields = 0

    for _, engineData in ipairs(engines) do
        if IsValid(engineData.entity) then
            if engineData.charging then
                chargingEngines = chargingEngines + 1
            elseif engineData.cooldown <= CurTime() then
                readyEngines = readyEngines + 1
            end

            -- Enhanced shield status tracking
            if engineData.shieldActive then
                shieldedEngines = shieldedEngines + 1
                if engineData.shieldRecharging then
                    rechargingShields = rechargingShields + 1
                end
                if engineData.shieldOverloaded then
                    overloadedShields = overloadedShields + 1
                end
                if engineData.capIntegrated then
                    capShields = capShields + 1
                end
            end
        end
    end

    draw.SimpleText("Master Engine Status:", "DermaDefault", x, y + yOffset, Color(255, 255, 255))
    yOffset = yOffset + 25

    draw.SimpleText("• Total Engines: " .. totalEngines, "DermaDefault", x + 20, y + yOffset, Color(200, 200, 200))
    yOffset = yOffset + 20
    draw.SimpleText("• Ready to Jump: " .. readyEngines, "DermaDefault", x + 20, y + yOffset, readyEngines > 0 and Color(0, 255, 0) or Color(255, 100, 100))
    yOffset = yOffset + 20
    draw.SimpleText("• Currently Charging: " .. chargingEngines, "DermaDefault", x + 20, y + yOffset, chargingEngines > 0 and Color(255, 255, 0) or Color(200, 200, 200))
    yOffset = yOffset + 25

    -- Enhanced shield status display
    draw.SimpleText("Shield System Status:", "DermaDefault", x, y + yOffset, Color(100, 255, 255))
    yOffset = yOffset + 25

    local shieldStatusColor = Color(200, 200, 200)
    if overloadedShields > 0 then
        shieldStatusColor = Color(255, 100, 100)
    elseif rechargingShields > 0 then
        shieldStatusColor = Color(255, 255, 100)
    elseif shieldedEngines > 0 then
        shieldStatusColor = Color(0, 255, 255)
    end

    draw.SimpleText("• Shields Active: " .. shieldedEngines .. "/" .. totalEngines, "DermaDefault", x + 20, y + yOffset, shieldStatusColor)
    yOffset = yOffset + 20

    if rechargingShields > 0 then
        draw.SimpleText("• Recharging: " .. rechargingShields, "DermaDefault", x + 20, y + yOffset, Color(255, 255, 100))
        yOffset = yOffset + 20
    end

    if overloadedShields > 0 then
        draw.SimpleText("• Overloaded: " .. overloadedShields, "DermaDefault", x + 20, y + yOffset, Color(255, 100, 100))
        yOffset = yOffset + 20
    end

    if capShields > 0 then
        draw.SimpleText("• CAP Integration: " .. capShields .. " shields", "DermaDefault", x + 20, y + yOffset, Color(100, 255, 100))
        yOffset = yOffset + 20
    end

    local customShields = shieldedEngines - capShields
    if customShields > 0 then
        draw.SimpleText("• Custom Shields: " .. customShields .. " shields", "DermaDefault", x + 20, y + yOffset, Color(200, 200, 100))
        yOffset = yOffset + 20
    end

    yOffset = yOffset + 50

    -- Shield Control Panel
    draw.SimpleText("Shield Control:", "DermaDefault", x, y + yOffset, Color(100, 255, 255))
    yOffset = yOffset + 30

    -- Fleet Shield Activate Button
    local activateColor = Color(0, 150, 0)
    local activateX, activateY = x + 20, y + yOffset

    if input.IsMouseDown(MOUSE_LEFT) and
       gui.MouseX() >= activateX and gui.MouseX() <= activateX + 150 and
       gui.MouseY() >= activateY and gui.MouseY() <= activateY + 25 then
        activateColor = Color(0, 200, 0)

        if CurTime() - computerInterface.lastUpdate > 0.2 then
            computerInterface.lastUpdate = CurTime()
            net.Start("hyperdrive_fleet_shields")
            net.WriteEntity(computerInterface.entity)
            net.WriteBool(true) -- Activate
            net.SendToServer()
        end
    end

    draw.RoundedBox(4, activateX, activateY, 150, 25, activateColor)
    draw.SimpleText("ACTIVATE FLEET", "DermaDefault", activateX + 75, activateY + 12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    -- Fleet Shield Deactivate Button
    local deactivateColor = Color(150, 0, 0)
    local deactivateX, deactivateY = x + 190, y + yOffset

    if input.IsMouseDown(MOUSE_LEFT) and
       gui.MouseX() >= deactivateX and gui.MouseX() <= deactivateX + 150 and
       gui.MouseY() >= deactivateY and gui.MouseY() <= deactivateY + 25 then
        deactivateColor = Color(200, 0, 0)

        if CurTime() - computerInterface.lastUpdate > 0.2 then
            computerInterface.lastUpdate = CurTime()
            net.Start("hyperdrive_fleet_shields")
            net.WriteEntity(computerInterface.entity)
            net.WriteBool(false) -- Deactivate
            net.SendToServer()
        end
    end

    draw.RoundedBox(4, deactivateX, deactivateY, 150, 25, deactivateColor)
    draw.SimpleText("DEACTIVATE FLEET", "DermaDefault", deactivateX + 75, deactivateY + 12, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    yOffset = yOffset + 40

    -- Simple system status
    draw.SimpleText("Computer Status:", "DermaDefault", x, y + yOffset, Color(255, 255, 255))
    yOffset = yOffset + 30

    draw.SimpleText("• System: ONLINE", "DermaDefault", x + 20, y + yOffset, Color(0, 255, 0))
    yOffset = yOffset + 25
    draw.SimpleText("• Planet Detection: AUTO", "DermaDefault", x + 20, y + yOffset, Color(0, 255, 0))
    yOffset = yOffset + 25
    draw.SimpleText("• Auto-Link: ENABLED", "DermaDefault", x + 20, y + yOffset, Color(0, 255, 0))
    yOffset = yOffset + 25
    draw.SimpleText("• Shield System: " .. (shieldedEngines > 0 and "ACTIVE" or "STANDBY"), "DermaDefault", x + 20, y + yOffset, shieldedEngines > 0 and Color(0, 255, 255) or Color(200, 200, 200))

    yOffset = yOffset + 40

    -- Performance info
    local fps = math.floor(1 / FrameTime())
    local fpsColor = fps >= 60 and Color(0, 255, 0) or fps >= 30 and Color(255, 255, 0) or Color(255, 0, 0)

    draw.SimpleText("Performance: " .. fps .. " FPS", "DermaDefault", x, y + yOffset, fpsColor)
end

-- All old complex functions have been replaced by the simple 3-mode system above
