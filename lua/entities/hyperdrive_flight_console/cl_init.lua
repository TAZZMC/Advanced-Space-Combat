include("shared.lua")

-- Client-side flight console
function ENT:Initialize()
    self.controllingFlight = false
    self.flightHUD = false
    self.waypointMarkers = {}
    self.lastInputTime = 0
    self.inputRate = 0.05 -- 20 FPS input rate
end

function ENT:Draw()
    self:DrawModel()
    
    -- Apply dynamic material based on status
    if self:GetFlightActive() then
        self:SetMaterial("models/props_combine/metal_combinebridge001")
        
        -- Color based on status
        if self:GetAutopilotActive() then
            self:SetColor(Color(100, 255, 100, 255)) -- Green when autopilot active
        else
            self:SetColor(Color(100, 200, 255, 255)) -- Blue when manual
        end
        
        -- Flight status display
        self:DrawFlightStatusDisplay()
        
        -- Waypoint indicators
        self:DrawWaypointIndicators()
    else
        self:SetMaterial("")
        self:SetColor(Color(150, 150, 150, 255)) -- Gray when inactive
    end
end

function ENT:DrawFlightStatusDisplay()
    local pos = self:GetPos() + self:GetUp() * 25
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang.Forward(), 90)
    ang:RotateAroundAxis(ang.Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.08)
        local status = self:GetFlightStatus()
        local color = Color(255, 255, 255)
        
        if self:GetAutopilotActive() then
            color = Color(100, 255, 100)
            status = "AUTOPILOT"
        elseif self:GetFlightActive() then
            color = Color(100, 200, 255)
        end
        
        draw.SimpleText(status, "DermaDefault", 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Flight info
        draw.SimpleText("FLIGHT CONSOLE", "DermaDefault", 0, -20, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Speed display
        local speed = math.floor(self:GetCurrentSpeed())
        local maxSpeed = self:GetMaxSpeed()
        draw.SimpleText("SPEED: " .. speed .. "/" .. maxSpeed, "DermaDefault", 0, 15, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Waypoint info
        if self:GetWaypointCount() > 0 then
            draw.SimpleText("WP: " .. self:GetCurrentWaypoint() .. "/" .. self:GetWaypointCount(), "DermaDefault", 0, 30, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Flight mode
        draw.SimpleText("MODE: " .. string.upper(self:GetFlightMode()), "DermaDefault", 0, 45, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:DrawWaypointIndicators()
    if self:GetWaypointCount() == 0 then return end
    
    -- Draw waypoint markers (this would need waypoint positions from server)
    for i, marker in ipairs(self.waypointMarkers) do
        local screenPos = marker.pos:ToScreen()
        if screenPos.visible then
            local distance = LocalPlayer():GetPos():Distance(marker.pos)
            local alpha = math.Clamp(255 - (distance / 50), 50, 255)
            
            surface.SetDrawColor(100, 255, 100, alpha)
            surface.DrawRect(screenPos.x - 5, screenPos.y - 5, 10, 10)
            
            draw.SimpleText("WP" .. i, "DermaDefault", screenPos.x, screenPos.y + 15, Color(100, 255, 100, alpha), TEXT_ALIGN_CENTER)
        end
    end
end

function ENT:Think()
    -- Handle flight controls
    if self.controllingFlight then
        self:HandleFlightControls()
    end
    
    -- Update flight HUD
    if self.flightHUD then
        self:UpdateFlightHUD()
    end
end

function ENT:HandleFlightControls()
    if CurTime() - self.lastInputTime < self.inputRate then return end
    
    local inputs = {}
    
    -- Movement controls
    if input.IsKeyDown(KEY_W) then inputs.forward = true end
    if input.IsKeyDown(KEY_S) then inputs.backward = true end
    if input.IsKeyDown(KEY_A) then inputs.left = true end
    if input.IsKeyDown(KEY_D) then inputs.right = true end
    if input.IsKeyDown(KEY_SPACE) then inputs.up = true end
    if input.IsKeyDown(KEY_LCONTROL) then inputs.down = true end
    
    -- Rotation controls (mouse look)
    local mouseX, mouseY = input.GetCursorPos()
    if mouseX and mouseY then
        local centerX, centerY = ScrW() / 2, ScrH() / 2
        local deltaX = (mouseX - centerX) / centerX
        local deltaY = (mouseY - centerY) / centerY
        
        if math.abs(deltaX) > 0.1 then inputs.yaw_right = deltaX > 0 end
        if math.abs(deltaX) > 0.1 then inputs.yaw_left = deltaX < 0 end
        if math.abs(deltaY) > 0.1 then inputs.pitch_up = deltaY < 0 end
        if math.abs(deltaY) > 0.1 then inputs.pitch_down = deltaY > 0 end
    end
    
    -- Roll controls
    if input.IsKeyDown(KEY_Q) then inputs.roll_left = true end
    if input.IsKeyDown(KEY_E) then inputs.roll_right = true end
    
    -- Send inputs to server
    for inputType, active in pairs(inputs) do
        net.Start("HyperdriveFlightControl")
        net.WriteEntity(self)
        net.WriteString(inputType)
        net.WriteBool(active)
        net.SendToServer()
    end
    
    self.lastInputTime = CurTime()
end

function ENT:UpdateFlightHUD()
    -- This would draw the flight HUD overlay
    -- Implementation depends on desired HUD design
end

-- Key bindings for flight controls
hook.Add("PlayerButtonDown", "HyperdriveFlightControls", function(ply, button)
    if not IsValid(LocalPlayer()) then return end
    
    -- Find active flight console
    local activeConsole = nil
    for _, ent in ipairs(ents.FindByClass("hyperdrive_flight_console")) do
        if IsValid(ent) and ent.controllingFlight then
            activeConsole = ent
            break
        end
    end
    
    if not activeConsole then return end
    
    -- Special flight controls
    if button == KEY_R then
        -- Toggle autopilot
        net.Start("HyperdriveFlightControl")
        net.WriteEntity(activeConsole)
        net.WriteString("toggle_autopilot")
        net.WriteBool(true)
        net.SendToServer()
    elseif button == KEY_T then
        -- Add waypoint at aim position
        local trace = LocalPlayer():GetEyeTrace()
        if trace.Hit then
            net.Start("HyperdriveFlightControl")
            net.WriteEntity(activeConsole)
            net.WriteString("add_waypoint")
            net.WriteBool(true)
            net.SendToServer()
        end
    elseif button == KEY_G then
        -- Clear waypoints
        net.Start("HyperdriveFlightControl")
        net.WriteEntity(activeConsole)
        net.WriteString("clear_waypoints")
        net.WriteBool(true)
        net.SendToServer()
    elseif button == KEY_F then
        -- Cycle flight mode
        net.Start("HyperdriveFlightControl")
        net.WriteEntity(activeConsole)
        net.WriteString("cycle_mode")
        net.WriteBool(true)
        net.SendToServer()
    end
end)

-- Network message handling
net.Receive("HyperdriveFlightControl", function()
    local console = net.ReadEntity()
    local takeControl = net.ReadBool()
    
    if IsValid(console) then
        console.controllingFlight = takeControl
        console.flightHUD = takeControl
        
        if takeControl then
            LocalPlayer():ChatPrint("[Flight Console] Flight controls active")
            LocalPlayer():ChatPrint("Controls: WASD = Move, Mouse = Look, Space/Ctrl = Up/Down")
            LocalPlayer():ChatPrint("R = Autopilot, T = Add Waypoint, G = Clear Waypoints, F = Flight Mode")
        else
            LocalPlayer():ChatPrint("[Flight Console] Flight controls released")
        end
    end
end)

net.Receive("HyperdriveFlightStatus", function()
    local console = net.ReadEntity()
    local statusData = net.ReadTable()
    
    if IsValid(console) then
        -- Update console status display
        console.flightStatus = statusData
    end
end)

net.Receive("HyperdriveWaypointUpdate", function()
    local console = net.ReadEntity()
    local position = net.ReadVector()
    local isAdd = net.ReadBool()
    
    if IsValid(console) then
        if isAdd then
            table.insert(console.waypointMarkers, {pos = position, time = CurTime()})
        else
            console.waypointMarkers = {}
        end
    end
end)

-- Flight HUD rendering
hook.Add("HUDPaint", "HyperdriveFlightHUD", function()
    -- Find active flight console
    local activeConsole = nil
    for _, ent in ipairs(ents.FindByClass("hyperdrive_flight_console")) do
        if IsValid(ent) and ent.controllingFlight then
            activeConsole = ent
            break
        end
    end
    
    if not activeConsole or not activeConsole.flightHUD then return end
    
    -- Draw flight HUD
    local scrW, scrH = ScrW(), ScrH()
    
    -- Speed indicator
    local speed = activeConsole:GetCurrentSpeed()
    local maxSpeed = activeConsole:GetMaxSpeed()
    local speedPercent = speed / maxSpeed
    
    surface.SetDrawColor(50, 50, 50, 200)
    surface.DrawRect(50, scrH - 100, 200, 20)
    
    surface.SetDrawColor(100, 200, 255, 255)
    surface.DrawRect(52, scrH - 98, 196 * speedPercent, 16)
    
    draw.SimpleText("SPEED: " .. math.floor(speed), "DermaDefault", 60, scrH - 95, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    
    -- Thrust indicators
    local thrustX = activeConsole:GetThrustX()
    local thrustY = activeConsole:GetThrustY()
    local thrustZ = activeConsole:GetThrustZ()
    
    draw.SimpleText("THRUST", "DermaDefault", 60, scrH - 70, Color(200, 200, 200), TEXT_ALIGN_LEFT)
    draw.SimpleText("X: " .. string.format("%.2f", thrustX), "DermaDefault", 60, scrH - 55, Color(255, 100, 100), TEXT_ALIGN_LEFT)
    draw.SimpleText("Y: " .. string.format("%.2f", thrustY), "DermaDefault", 120, scrH - 55, Color(100, 255, 100), TEXT_ALIGN_LEFT)
    draw.SimpleText("Z: " .. string.format("%.2f", thrustZ), "DermaDefault", 180, scrH - 55, Color(100, 100, 255), TEXT_ALIGN_LEFT)
    
    -- Autopilot status
    if activeConsole:GetAutopilotActive() then
        draw.SimpleText("AUTOPILOT ACTIVE", "DermaDefault", scrW - 200, 50, Color(100, 255, 100), TEXT_ALIGN_LEFT)
        
        local waypoints = activeConsole:GetWaypointCount()
        local current = activeConsole:GetCurrentWaypoint()
        if waypoints > 0 then
            draw.SimpleText("WAYPOINT: " .. current .. "/" .. waypoints, "DermaDefault", scrW - 200, 70, Color(200, 200, 200), TEXT_ALIGN_LEFT)
        end
    end
    
    -- Flight mode
    draw.SimpleText("MODE: " .. string.upper(activeConsole:GetFlightMode()), "DermaDefault", scrW - 200, 30, Color(200, 200, 200), TEXT_ALIGN_LEFT)
    
    -- Crosshair
    surface.SetDrawColor(100, 200, 255, 200)
    surface.DrawLine(scrW/2 - 10, scrH/2, scrW/2 + 10, scrH/2)
    surface.DrawLine(scrW/2, scrH/2 - 10, scrW/2, scrH/2 + 10)
end)
