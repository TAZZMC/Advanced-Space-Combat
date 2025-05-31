-- Enhanced Hyperdrive Flight Console v2.2.1
-- Ship flight control interface with navigation and autopilot

print("[Hyperdrive Flight] Flight Console v2.2.1 - Entity loading...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_interface001.mdl")
    self:PhysicsInit(SOLID_VBBOX)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VBBOX)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Console properties
    self:SetMaxHealth(300)
    self:SetHealth(300)
    
    -- Initialize flight system
    self.flightSystem = nil
    self.lastUpdate = 0
    self.updateRate = 0.1 -- 10 FPS updates
    self.controlMode = "manual" -- manual, autopilot, formation
    
    -- Player control
    self.pilot = nil
    self.controlInputs = {
        forward = false,
        backward = false,
        left = false,
        right = false,
        up = false,
        down = false,
        pitch_up = false,
        pitch_down = false,
        yaw_left = false,
        yaw_right = false,
        roll_left = false,
        roll_right = false
    }
    
    -- Initialize network variables
    self:SetFlightActive(false)
    self:SetAutopilotActive(false)
    self:SetStabilizationActive(true)
    self:SetThrustX(0)
    self:SetThrustY(0)
    self:SetThrustZ(0)
    self:SetRotationPitch(0)
    self:SetRotationYaw(0)
    self:SetRotationRoll(0)
    self:SetCurrentSpeed(0)
    self:SetMaxSpeed(2000)
    self:SetWaypointCount(0)
    self:SetCurrentWaypoint(0)
    self:SetFlightMode("manual")
    self:SetFlightStatus("Initializing...")

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "ThrustForward",
            "ThrustRight",
            "ThrustUp",
            "RotationPitch",
            "RotationYaw",
            "RotationRoll",
            "Autopilot",
            "AddWaypoint",
            "ClearWaypoints",
            "FlightMode"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "FlightActive",
            "AutopilotActive",
            "CurrentSpeed",
            "MaxSpeed",
            "WaypointCount",
            "EnergyLevel",
            "DistanceTraveled",
            "FlightTime"
        })
    end

    -- Initialize flight system after short delay
    timer.Simple(1, function()
        if IsValid(self) then
            self:InitializeFlightSystem()
        end
    end)

    print("[Hyperdrive Flight] Flight Console initialized")
end

function ENT:InitializeFlightSystem()
    -- Find nearby ship core
    local nearbyEnts = ents.FindInSphere(self:GetPos(), 2000)
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            self:SetShipCore(ent)
            
            -- Get or create flight system
            self.flightSystem = HYPERDRIVE.Flight.GetFlightSystem(ent)
            if not self.flightSystem then
                self.flightSystem = HYPERDRIVE.Flight.CreateFlightSystem(ent)
            end
            
            if self.flightSystem then
                self:SetFlightActive(true)
                self:SetFlightStatus("Flight system online")
                print("[Flight Console] Connected to ship core: " .. ent:EntIndex())
            else
                self:SetFlightStatus("Failed to initialize flight system")
            end
            return
        end
    end
    
    self:SetFlightStatus("No ship core detected")
end

function ENT:Think()
    if not self.flightSystem then
        self:NextThink(CurTime() + 1)
        return true
    end
    
    -- Update flight controls
    if CurTime() - self.lastUpdate >= self.updateRate then
        self:UpdateFlightControls()
        self:UpdateNetworkVariables()
        self:UpdateWireOutputs()
        self.lastUpdate = CurTime()
    end
    
    self:NextThink(CurTime() + self.updateRate)
    return true
end

function ENT:UpdateFlightControls()
    if not self.flightSystem or not self.flightSystem.active then return end
    
    -- Calculate thrust vector
    local thrust = Vector(0, 0, 0)
    local rotation = Angle(0, 0, 0)
    
    if self.controlMode == "manual" and IsValid(self.pilot) then
        -- Manual control from player inputs
        thrust, rotation = self:CalculateManualControls()
    elseif self.controlMode == "wire" then
        -- Wire-controlled inputs
        thrust, rotation = self:CalculateWireControls()
    end
    
    -- Apply controls to flight system
    self.flightSystem:SetThrust(thrust)
    self.flightSystem:SetRotation(rotation)
end

function ENT:CalculateManualControls()
    local thrust = Vector(0, 0, 0)
    local rotation = Angle(0, 0, 0)
    
    -- Thrust controls
    if self.controlInputs.forward then thrust.x = thrust.x + 1 end
    if self.controlInputs.backward then thrust.x = thrust.x - 1 end
    if self.controlInputs.right then thrust.y = thrust.y + 1 end
    if self.controlInputs.left then thrust.y = thrust.y - 1 end
    if self.controlInputs.up then thrust.z = thrust.z + 1 end
    if self.controlInputs.down then thrust.z = thrust.z - 1 end
    
    -- Rotation controls
    if self.controlInputs.pitch_up then rotation.p = rotation.p + 1 end
    if self.controlInputs.pitch_down then rotation.p = rotation.p - 1 end
    if self.controlInputs.yaw_left then rotation.y = rotation.y - 1 end
    if self.controlInputs.yaw_right then rotation.y = rotation.y + 1 end
    if self.controlInputs.roll_left then rotation.r = rotation.r - 1 end
    if self.controlInputs.roll_right then rotation.r = rotation.r + 1 end
    
    return thrust, rotation
end

function ENT:CalculateWireControls()
    local thrust = Vector(
        self:GetThrustX(),
        self:GetThrustY(),
        self:GetThrustZ()
    )
    
    local rotation = Angle(
        self:GetRotationPitch(),
        self:GetRotationYaw(),
        self:GetRotationRoll()
    )
    
    return thrust, rotation
end

function ENT:UpdateNetworkVariables()
    if not self.flightSystem then return end
    
    local status = self.flightSystem:GetStatus()
    
    self:SetFlightActive(status.active)
    self:SetAutopilotActive(status.autopilot)
    self:SetCurrentSpeed(status.velocity)
    self:SetMaxSpeed(status.maxSpeed)
    self:SetWaypointCount(status.waypoints)
    self:SetCurrentWaypoint(status.currentWaypoint)
    self:SetFlightMode(status.flightMode)
    
    -- Update thrust and rotation display
    local thrust = self.flightSystem.thrust
    local rotation = self.flightSystem.rotation
    
    self:SetThrustX(thrust.x)
    self:SetThrustY(thrust.y)
    self:SetThrustZ(thrust.z)
    self:SetRotationPitch(rotation.p)
    self:SetRotationYaw(rotation.y)
    self:SetRotationRoll(rotation.r)
end

function ENT:TriggerInput(iname, value)
    if not self.flightSystem then return end
    
    if iname == "ThrustForward" then
        self:SetThrustX(value)
        self.controlMode = "wire"
    elseif iname == "ThrustRight" then
        self:SetThrustY(value)
        self.controlMode = "wire"
    elseif iname == "ThrustUp" then
        self:SetThrustZ(value)
        self.controlMode = "wire"
    elseif iname == "RotationPitch" then
        self:SetRotationPitch(value)
        self.controlMode = "wire"
    elseif iname == "RotationYaw" then
        self:SetRotationYaw(value)
        self.controlMode = "wire"
    elseif iname == "RotationRoll" then
        self:SetRotationRoll(value)
        self.controlMode = "wire"
    elseif iname == "Autopilot" and value > 0 then
        self:ToggleAutopilot()
    elseif iname == "AddWaypoint" and value > 0 then
        -- Add waypoint at current aim position (if player is using console)
        if IsValid(self.pilot) then
            local aimPos = self.pilot:GetEyeTrace().HitPos
            self:AddWaypoint(aimPos)
        end
    elseif iname == "ClearWaypoints" and value > 0 then
        self:ClearWaypoints()
    elseif iname == "FlightMode" and value > 0 then
        self:CycleFlightMode()
    end
    
    self:UpdateWireOutputs()
end

function ENT:UpdateWireOutputs()
    if not WireLib or not self.flightSystem then return end
    
    local status = self.flightSystem:GetStatus()
    local energyLevel = 100 -- Default
    
    if self.flightSystem.shipCore and HYPERDRIVE.SB3Resources then
        energyLevel = HYPERDRIVE.SB3Resources.GetResourcePercent(self.flightSystem.shipCore, "energy")
    end
    
    WireLib.TriggerOutput(self, "FlightActive", status.active and 1 or 0)
    WireLib.TriggerOutput(self, "AutopilotActive", status.autopilot and 1 or 0)
    WireLib.TriggerOutput(self, "CurrentSpeed", status.velocity)
    WireLib.TriggerOutput(self, "MaxSpeed", status.maxSpeed)
    WireLib.TriggerOutput(self, "WaypointCount", status.waypoints)
    WireLib.TriggerOutput(self, "EnergyLevel", energyLevel)
    WireLib.TriggerOutput(self, "DistanceTraveled", status.stats.distanceTraveled)
    WireLib.TriggerOutput(self, "FlightTime", status.stats.flightTime)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Flight Console] Too far away to access controls")
        return
    end
    
    if not self.flightSystem then
        activator:ChatPrint("[Flight Console] No flight system connected")
        return
    end
    
    -- Toggle pilot control
    if self.pilot == activator then
        self:ReleasePilotControl()
        activator:ChatPrint("[Flight Console] Released flight controls")
    else
        self:TakePilotControl(activator)
        activator:ChatPrint("[Flight Console] Took flight controls")
        self:ShowFlightInterface(activator)
    end
end

function ENT:TakePilotControl(player)
    if IsValid(self.pilot) and self.pilot ~= player then
        self.pilot:ChatPrint("[Flight Console] Flight controls taken by " .. player:Name())
    end
    
    self.pilot = player
    self.controlMode = "manual"
    
    -- Send control interface to client
    net.Start("HyperdriveFlightControl")
    net.WriteEntity(self)
    net.WriteBool(true) -- Take control
    net.Send(player)
end

function ENT:ReleasePilotControl()
    if IsValid(self.pilot) then
        -- Send release message to client
        net.Start("HyperdriveFlightControl")
        net.WriteEntity(self)
        net.WriteBool(false) -- Release control
        net.Send(self.pilot)
    end
    
    self.pilot = nil
    self.controlMode = "autopilot"
    
    -- Clear all control inputs
    for key, _ in pairs(self.controlInputs) do
        self.controlInputs[key] = false
    end
end

function ENT:ShowFlightInterface(player)
    if not self.flightSystem then return end
    
    local status = self.flightSystem:GetStatus()
    
    player:ChatPrint("[Flight Console] === FLIGHT STATUS ===")
    player:ChatPrint("Flight Mode: " .. status.flightMode)
    player:ChatPrint("Speed: " .. math.floor(status.velocity) .. "/" .. status.maxSpeed)
    player:ChatPrint("Autopilot: " .. (status.autopilot and "ACTIVE" or "INACTIVE"))
    player:ChatPrint("Waypoints: " .. status.waypoints .. " (Current: " .. status.currentWaypoint .. ")")
    player:ChatPrint("Energy Consumption: " .. math.floor(status.energyConsumption) .. "/sec")
    player:ChatPrint("Distance Traveled: " .. math.floor(status.stats.distanceTraveled))
    player:ChatPrint("Flight Time: " .. math.floor(status.stats.flightTime) .. "s")
    player:ChatPrint("")
    player:ChatPrint("Controls: WASD = Move, Mouse = Look, Space/Ctrl = Up/Down")
    player:ChatPrint("R = Toggle Autopilot, T = Add Waypoint, G = Clear Waypoints")
end

function ENT:ToggleAutopilot()
    if not self.flightSystem then return end
    
    if self.flightSystem.autopilotActive then
        self.flightSystem.autopilotActive = false
        self:SetFlightStatus("Autopilot disabled")
    else
        if #self.flightSystem.waypoints > 0 then
            self.flightSystem.autopilotActive = true
            self:SetFlightStatus("Autopilot enabled")
        else
            self:SetFlightStatus("No waypoints set")
        end
    end
end

function ENT:AddWaypoint(position)
    if not self.flightSystem then return false end
    
    local success, reason = self.flightSystem:AddWaypoint(position)
    if success then
        self:SetFlightStatus("Waypoint added")
        
        -- Notify clients
        net.Start("HyperdriveWaypointUpdate")
        net.WriteEntity(self)
        net.WriteVector(position)
        net.WriteBool(true) -- Add waypoint
        net.Broadcast()
    else
        self:SetFlightStatus(reason)
    end
    
    return success
end

function ENT:ClearWaypoints()
    if not self.flightSystem then return end
    
    self.flightSystem:ClearWaypoints()
    self:SetFlightStatus("Waypoints cleared")
    
    -- Notify clients
    net.Start("HyperdriveWaypointUpdate")
    net.WriteEntity(self)
    net.WriteVector(Vector(0,0,0))
    net.WriteBool(false) -- Clear waypoints
    net.Broadcast()
end

function ENT:CycleFlightMode()
    if not self.flightSystem then return end
    
    local modes = {"manual", "autopilot", "formation", "combat"}
    local currentIndex = 1
    
    for i, mode in ipairs(modes) do
        if mode == self.flightSystem.flightMode then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = (currentIndex % #modes) + 1
    local newMode = modes[nextIndex]
    
    local success = self.flightSystem:SetFlightMode(newMode)
    if success then
        self:SetFlightStatus("Flight mode: " .. newMode)
    end
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    
    -- Release pilot control if console is damaged
    if IsValid(self.pilot) then
        self:ReleasePilotControl()
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Create explosion effect
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetScale(2)
        util.Effect("Explosion", effectData)
        
        self:Remove()
    end
end

function ENT:OnRemove()
    -- Release pilot control
    if IsValid(self.pilot) then
        self:ReleasePilotControl()
    end

    -- Clean up flight system
    if self.flightSystem then
        HYPERDRIVE.Flight.RemoveFlightSystem(self)
    end

    -- Unlink from ship core
    if self.shipCore and IsValid(self.shipCore) then
        self.shipCore = nil
    end

    if WireLib then
        Wire_Remove(self)
    end

    -- Support undo system
    if self.UndoID then
        undo.ReplaceEntity(self.UndoID, NULL)
    end

    print("[Hyperdrive Flight] Flight Console removed")
end

-- Network message handling for control inputs
net.Receive("HyperdriveFlightControl", function(len, ply)
    local console = net.ReadEntity()
    local inputType = net.ReadString()
    local inputValue = net.ReadBool()
    
    if IsValid(console) and console.pilot == ply then
        console.controlInputs[inputType] = inputValue
    end
end)
