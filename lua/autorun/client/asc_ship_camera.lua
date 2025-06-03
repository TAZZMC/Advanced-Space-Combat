--[[
    Advanced Space Combat - Ship Camera System (Client)
    
    Provides external camera positioning for ship cockpit control,
    placing the camera behind and above the ship for optimal flying view.
]]

if not CLIENT then return end

-- Initialize Camera System
ASC = ASC or {}
ASC.Camera = ASC.Camera or {}

-- Camera Configuration
ASC.Camera.Config = {
    -- Camera positioning
    DefaultDistance = 400,
    DefaultHeight = 100,
    MinDistance = 150,
    MaxDistance = 1000,
    MinHeight = 50,
    MaxHeight = 300,
    
    -- Camera behavior
    Smoothness = 0.1,
    CollisionCheck = true,
    FollowShip = true,
    MouseControl = true,
    
    -- View settings
    FOV = 75,
    NearZ = 1,
    FarZ = 32768,
    
    -- Input settings
    MouseSensitivity = 0.5,
    ScrollSensitivity = 50,
    ResetKey = KEY_R
}

-- Camera state
ASC.Camera.State = {
    Active = false,
    Seat = nil,
    ShipCore = nil,
    Distance = ASC.Camera.Config.DefaultDistance,
    Height = ASC.Camera.Config.DefaultHeight,
    Angles = Angle(0, 0, 0),
    Position = Vector(0, 0, 0),
    TargetPosition = Vector(0, 0, 0),
    LastMousePos = {x = 0, y = 0},
    Smoothing = true
}

-- Camera system functions
ASC.Camera.Core = {
    -- Initialize camera system
    Initialize = function()
        print("[Ship Camera] Client-side camera system initialized")
    end,
    
    -- Check if player is in ship control seat
    IsInShipSeat = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        
        local vehicle = ply:GetVehicle()
        if not IsValid(vehicle) then return false end
        
        return vehicle:GetNWBool("ASC_ShipControl", false) and vehicle:GetNWBool("ASC_ExternalCamera", false)
    end,
    
    -- Get ship core from seat
    GetShipCore = function(seat)
        if not IsValid(seat) then return nil end
        return seat:GetNWEntity("ASC_ShipCore", NULL)
    end,
    
    -- Update camera system
    Update = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        
        local inShipSeat = ASC.Camera.Core.IsInShipSeat()
        
        if inShipSeat and not ASC.Camera.State.Active then
            -- Player entered ship control seat
            ASC.Camera.Core.EnableShipCamera()
        elseif not inShipSeat and ASC.Camera.State.Active then
            -- Player left ship control seat
            ASC.Camera.Core.DisableShipCamera()
        end
        
        if ASC.Camera.State.Active then
            ASC.Camera.Core.UpdateCameraPosition()
        end
    end,
    
    -- Enable ship camera
    EnableShipCamera = function()
        local ply = LocalPlayer()
        local vehicle = ply:GetVehicle()
        
        if not IsValid(vehicle) then return end
        
        ASC.Camera.State.Active = true
        ASC.Camera.State.Seat = vehicle
        ASC.Camera.State.ShipCore = ASC.Camera.Core.GetShipCore(vehicle)
        ASC.Camera.State.Distance = vehicle:GetNWFloat("ASC_CameraDistance", ASC.Camera.Config.DefaultDistance)
        ASC.Camera.State.Height = vehicle:GetNWFloat("ASC_CameraHeight", ASC.Camera.Config.DefaultHeight)
        
        -- Initialize camera angles based on ship orientation
        if IsValid(ASC.Camera.State.ShipCore) then
            ASC.Camera.State.Angles = ASC.Camera.State.ShipCore:GetAngles()
        end
        
        print("[Ship Camera] External camera enabled - Distance: " .. ASC.Camera.State.Distance .. ", Height: " .. ASC.Camera.State.Height)
    end,
    
    -- Disable ship camera
    DisableShipCamera = function()
        ASC.Camera.State.Active = false
        ASC.Camera.State.Seat = nil
        ASC.Camera.State.ShipCore = nil
        
        print("[Ship Camera] External camera disabled")
    end,
    
    -- Update camera position
    UpdateCameraPosition = function()
        if not ASC.Camera.State.Active or not IsValid(ASC.Camera.State.ShipCore) then return end
        
        local shipCore = ASC.Camera.State.ShipCore
        local shipPos = shipCore:GetPos()
        local shipAngles = shipCore:GetAngles()
        
        -- Calculate camera position behind and above ship
        local forward = shipAngles:Forward()
        local up = shipAngles:Up()
        local right = shipAngles:Right()
        
        -- Base position behind ship
        local cameraOffset = -forward * ASC.Camera.State.Distance + up * ASC.Camera.State.Height
        ASC.Camera.State.TargetPosition = shipPos + cameraOffset
        
        -- Smooth camera movement
        if ASC.Camera.State.Smoothing then
            local smoothness = ASC.Camera.Config.Smoothness
            ASC.Camera.State.Position = LerpVector(smoothness, ASC.Camera.State.Position, ASC.Camera.State.TargetPosition)
        else
            ASC.Camera.State.Position = ASC.Camera.State.TargetPosition
        end
        
        -- Collision check
        if ASC.Camera.Config.CollisionCheck then
            ASC.Camera.Core.CheckCameraCollision(shipPos)
        end
        
        -- Update camera angles to look at ship
        local lookDir = (shipPos - ASC.Camera.State.Position):GetNormalized()
        ASC.Camera.State.Angles = lookDir:Angle()
    end,
    
    -- Check camera collision with world
    CheckCameraCollision = function(shipPos)
        local trace = util.TraceLine({
            start = shipPos,
            endpos = ASC.Camera.State.TargetPosition,
            filter = function(ent)
                -- Filter out the ship entities
                if IsValid(ASC.Camera.State.ShipCore) and ASC.Camera.State.ShipCore.GetEntities then
                    for _, shipEnt in ipairs(ASC.Camera.State.ShipCore:GetEntities()) do
                        if ent == shipEnt then return false end
                    end
                end
                return true
            end
        })
        
        if trace.Hit then
            -- Move camera closer to avoid collision
            local safeDistance = trace.Fraction * ASC.Camera.State.Distance * 0.9
            local shipAngles = ASC.Camera.State.ShipCore:GetAngles()
            local forward = shipAngles:Forward()
            local up = shipAngles:Up()
            
            local cameraOffset = -forward * safeDistance + up * ASC.Camera.State.Height
            ASC.Camera.State.Position = shipPos + cameraOffset
        end
    end,
    
    -- Handle mouse input for camera control
    HandleMouseInput = function()
        if not ASC.Camera.State.Active or not ASC.Camera.Config.MouseControl then return end
        
        local mouseX, mouseY = gui.MouseX(), gui.MouseY()
        local deltaX = mouseX - ASC.Camera.State.LastMousePos.x
        local deltaY = mouseY - ASC.Camera.State.LastMousePos.y
        
        -- Only apply if mouse moved significantly
        if math.abs(deltaX) > 2 or math.abs(deltaY) > 2 then
            local sensitivity = ASC.Camera.Config.MouseSensitivity
            
            -- Adjust camera angles based on mouse movement
            ASC.Camera.State.Angles.y = ASC.Camera.State.Angles.y - deltaX * sensitivity
            ASC.Camera.State.Angles.p = math.Clamp(ASC.Camera.State.Angles.p + deltaY * sensitivity, -89, 89)
        end
        
        ASC.Camera.State.LastMousePos.x = mouseX
        ASC.Camera.State.LastMousePos.y = mouseY
    end,
    
    -- Handle scroll wheel for camera distance
    HandleScrollInput = function(delta)
        if not ASC.Camera.State.Active then return end
        
        local scrollSensitivity = ASC.Camera.Config.ScrollSensitivity
        ASC.Camera.State.Distance = math.Clamp(
            ASC.Camera.State.Distance - delta * scrollSensitivity,
            ASC.Camera.Config.MinDistance,
            ASC.Camera.Config.MaxDistance
        )
    end
}

-- Hook into game events
hook.Add("Think", "ASC_Camera_Update", function()
    ASC.Camera.Core.Update()
end)

-- Override camera when in ship control
hook.Add("CalcView", "ASC_Ship_Camera", function(ply, pos, angles, fov)
    if not ASC.Camera.State.Active then return end
    
    local view = {}
    view.origin = ASC.Camera.State.Position
    view.angles = ASC.Camera.State.Angles
    view.fov = ASC.Camera.Config.FOV
    view.znear = ASC.Camera.Config.NearZ
    view.zfar = ASC.Camera.Config.FarZ
    
    return view
end)

-- Handle mouse input
hook.Add("InputMouseApply", "ASC_Camera_Mouse", function(cmd, x, y, angle)
    if ASC.Camera.State.Active and ASC.Camera.Config.MouseControl then
        ASC.Camera.Core.HandleMouseInput()
        return true -- Consume mouse input
    end
end)

-- Handle scroll wheel
hook.Add("PlayerBindPress", "ASC_Camera_Scroll", function(ply, bind, pressed)
    if not ASC.Camera.State.Active then return end
    
    if bind == "invnext" and pressed then
        ASC.Camera.Core.HandleScrollInput(1)
        return true
    elseif bind == "invprev" and pressed then
        ASC.Camera.Core.HandleScrollInput(-1)
        return true
    elseif bind == "+reload" and pressed then
        -- Reset camera distance and height
        ASC.Camera.State.Distance = ASC.Camera.Config.DefaultDistance
        ASC.Camera.State.Height = ASC.Camera.Config.DefaultHeight
        LocalPlayer():ChatPrint("📷 Camera reset to default position")
        return true
    end
end)

-- Initialize when loaded
ASC.Camera.Core.Initialize()

print("[Advanced Space Combat] Ship Camera System loaded - External camera for cockpit control")
