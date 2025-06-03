--[[
    Advanced Space Combat - Flight System v3.0.0
    
    Comprehensive flight control system with autopilot, formation flying,
    and intelligent navigation for Advanced Space Combat ships.
]]

-- Initialize Flight System namespace
ASC = ASC or {}
ASC.Flight = ASC.Flight or {}
ASC.Flight.Core = ASC.Flight.Core or {}

-- Flight System Configuration
ASC.Flight.Config = {
    -- Core Settings
    Enabled = true,
    UpdateRate = 0.1,
    MaxThrust = 8000,
    MaxSpeed = 3000,
    RotationSpeed = 3.0,

    -- Vehicle Control Settings
    VehicleControl = true,
    DirectControl = true,
    MouseSteering = true,
    WASDMovement = true,
    SpacebarBoost = true,
    ShiftBrake = true,

    -- Control Sensitivity
    MouseSensitivity = 2.0,
    MovementSensitivity = 1.5,
    BoostMultiplier = 2.0,
    BrakeMultiplier = 0.3,

    -- Vehicle Physics
    Acceleration = 4000,
    Deceleration = 2000,
    TurnRate = 2.5,
    StabilityAssist = true,
    InertialDamping = 0.95,
    
    -- Autopilot Settings
    AutopilotEnabled = true,
    AutopilotAccuracy = 75,
    AutopilotSpeed = 0.85,
    CollisionAvoidance = true,
    AvoidanceDistance = 400,
    
    -- Formation Flying
    FormationFlying = true,
    FormationSpacing = 250,
    FormationTypes = {
        WEDGE = "Wedge Formation",
        LINE = "Line Formation", 
        DIAMOND = "Diamond Formation",
        CIRCLE = "Circle Formation",
        CUSTOM = "Custom Formation"
    },
    
    -- Navigation
    WaypointSystem = true,
    MaxWaypoints = 25,
    WaypointRadius = 100,
    RouteOptimization = true,
    
    -- Energy Management
    ThrustEnergyCost = 8,
    RotationEnergyCost = 3,
    AutopilotEnergyCost = 5,
    IdleEnergyCost = 1,
    
    -- Safety Systems
    EmergencyProtocols = true,
    CollisionWarning = true,
    AutomaticBraking = true,
    SafetyRadius = 200
}

-- Flight System Core
ASC.Flight.Core = {
    -- Active flight systems
    ActiveFlights = {},
    
    -- Formation groups
    Formations = {},
    
    -- Global waypoints
    Waypoints = {},
    
    -- Initialize flight system for a ship
    Initialize = function(shipCore, flightType)
        if not IsValid(shipCore) then
            return false, "Invalid ship core"
        end
        
        local shipID = shipCore:EntIndex()
        flightType = flightType or "STANDARD"
        
        -- Create flight system
        ASC.Flight.Core.ActiveFlights[shipID] = {
            shipCore = shipCore,
            flightType = flightType,
            
            -- Flight status
            active = false,
            autopilotActive = false,
            formationActive = false,
            vehicleControlActive = false,

            -- Movement properties
            thrust = Vector(0, 0, 0),
            velocity = Vector(0, 0, 0),
            angularVelocity = Angle(0, 0, 0),
            mass = 1000,

            -- Vehicle control properties
            pilot = nil,
            controlMode = "AUTOPILOT", -- AUTOPILOT, VEHICLE, MANUAL
            inputVector = Vector(0, 0, 0),
            mouseInput = Angle(0, 0, 0),
            boostActive = false,
            brakeActive = false,
            stabilityAssist = true,
            
            -- Navigation
            waypoints = {},
            currentWaypoint = 1,
            destination = nil,
            route = {},
            
            -- Formation flying
            formation = nil,
            formationPosition = 1,
            leader = nil,
            followers = {},
            
            -- Autopilot
            autopilotTarget = nil,
            autopilotMode = "DIRECT", -- DIRECT, WAYPOINT, FORMATION, PATROL
            autopilotSpeed = ASC.Flight.Config.AutopilotSpeed,
            
            -- Performance tracking
            distanceTraveled = 0,
            energyConsumed = 0,
            flightTime = 0,
            waypointsReached = 0,
            
            -- Safety systems
            collisionWarning = false,
            emergencyBraking = false,
            lastCollisionCheck = 0
        }
        
        -- Calculate ship mass
        ASC.Flight.Core.CalculateShipMass(shipID)
        
        -- Initialize flight systems
        ASC.Flight.Core.ActivateFlight(shipID)
        
        print("[Flight System] Initialized for ship " .. shipID .. " - Type: " .. flightType)
        return true, "Flight system initialized"
    end,
    
    -- Calculate ship mass based on entities
    CalculateShipMass = function(shipID)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight or not IsValid(flight.shipCore) then return end
        
        local baseMass = 1000
        local entityCount = 0
        
        -- Count ship entities
        if flight.shipCore.GetEntities then
            entityCount = #flight.shipCore:GetEntities()
        end
        
        -- Mass scales with ship size and complexity
        flight.mass = baseMass + (entityCount * 75)
        
        print("[Flight System] Calculated mass for ship " .. shipID .. ": " .. flight.mass)
    end,
    
    -- Activate flight system
    ActivateFlight = function(shipID)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return false end
        
        flight.active = true
        
        -- Update ship core
        if IsValid(flight.shipCore) then
            flight.shipCore:SetNWBool("FlightSystemActive", true)
            flight.shipCore:SetNWString("FlightType", flight.flightType)
            flight.shipCore:SetNWBool("AutopilotActive", false)
            flight.shipCore:SetNWBool("FormationActive", false)
        end
        
        print("[Flight System] Activated flight for ship " .. shipID)
        return true
    end,
    
    -- Update flight system
    Update = function(shipID, deltaTime)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight or not IsValid(flight.shipCore) then
            ASC.Flight.Core.ActiveFlights[shipID] = nil
            return
        end

        if not flight.active then return end

        -- Ensure deltaTime is valid
        deltaTime = deltaTime or 0.05 -- Default to 50ms if nil
        if deltaTime <= 0 then deltaTime = 0.05 end
        
        -- Update vehicle control
        if flight.vehicleControlActive then
            ASC.Flight.Core.UpdateVehicleControl(shipID, deltaTime)
        end

        -- Update autopilot
        if flight.autopilotActive then
            ASC.Flight.Core.UpdateAutopilot(shipID, deltaTime)
        end

        -- Update formation flying
        if flight.formationActive then
            ASC.Flight.Core.UpdateFormation(shipID, deltaTime)
        end
        
        -- Update safety systems
        ASC.Flight.Core.UpdateSafetySystems(shipID, deltaTime)
        
        -- Update performance tracking
        ASC.Flight.Core.UpdatePerformanceTracking(shipID, deltaTime)
        
        -- Apply physics
        ASC.Flight.Core.ApplyPhysics(shipID, deltaTime)
    end,
    
    -- Update autopilot system
    UpdateAutopilot = function(shipID, deltaTime)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight or not flight.autopilotActive then return end

        -- Ensure deltaTime is valid
        deltaTime = deltaTime or 0.05 -- Default to 50ms if nil
        if deltaTime <= 0 then deltaTime = 0.05 end

        local shipPos = flight.shipCore:GetPos()
        local target = flight.autopilotTarget
        
        if not target then
            -- Check for waypoints
            if #flight.waypoints > 0 and flight.currentWaypoint <= #flight.waypoints then
                target = flight.waypoints[flight.currentWaypoint]
                flight.autopilotTarget = target
            else
                -- No target, disable autopilot
                ASC.Flight.Core.DisableAutopilot(shipID)
                return
            end
        end
        
        -- Calculate direction to target
        local direction = (target - shipPos):GetNormalized()
        local distance = shipPos:Distance(target)
        
        -- Check if reached target
        if distance <= ASC.Flight.Config.AutopilotAccuracy then
            ASC.Flight.Core.ReachedWaypoint(shipID)
            return
        end
        
        -- Calculate thrust
        local thrustPower = math.min(ASC.Flight.Config.MaxThrust, distance * 2)
        flight.thrust = direction * thrustPower * flight.autopilotSpeed
        
        -- Collision avoidance
        if ASC.Flight.Config.CollisionAvoidance then
            ASC.Flight.Core.ApplyCollisionAvoidance(shipID, direction)
        end
    end,

    -- Update vehicle control system
    UpdateVehicleControl = function(shipID, deltaTime)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight or not flight.vehicleControlActive or not IsValid(flight.pilot) then return end

        -- Ensure deltaTime is valid
        deltaTime = deltaTime or 0.05 -- Default to 50ms if nil
        if deltaTime <= 0 then deltaTime = 0.05 end

        local pilot = flight.pilot
        local pilotSeat = flight.pilotSeat

        -- Check if pilot is still in the seat
        if not IsValid(pilotSeat) or pilot:GetVehicle() ~= pilotSeat then
            -- Pilot left the seat, disable vehicle control
            ASC.Flight.Core.DisableVehicleControl(shipID)
            return
        end

        local shipPos = flight.shipCore:GetPos()
        local shipAng = flight.shipCore:GetAngles()

        -- Get player input
        local inputVector = Vector(0, 0, 0)
        local mouseInput = Angle(0, 0, 0)

        -- WASD Movement
        if ASC.Flight.Config.WASDMovement then
            if pilot:KeyDown(IN_FORWARD) then inputVector.x = inputVector.x + 1 end
            if pilot:KeyDown(IN_BACK) then inputVector.x = inputVector.x - 1 end
            if pilot:KeyDown(IN_MOVELEFT) then inputVector.y = inputVector.y + 1 end
            if pilot:KeyDown(IN_MOVERIGHT) then inputVector.y = inputVector.y - 1 end
            if pilot:KeyDown(IN_JUMP) then inputVector.z = inputVector.z + 1 end
            if pilot:KeyDown(IN_DUCK) then inputVector.z = inputVector.z - 1 end
        end

        -- Mouse steering
        if ASC.Flight.Config.MouseSteering then
            local eyeAngles = pilot:EyeAngles()
            mouseInput = eyeAngles - flight.lastEyeAngles or Angle(0, 0, 0)
            flight.lastEyeAngles = eyeAngles
        end

        -- Boost and brake
        flight.boostActive = pilot:KeyDown(IN_SPEED) and ASC.Flight.Config.SpacebarBoost
        flight.brakeActive = pilot:KeyDown(IN_WALK) and ASC.Flight.Config.ShiftBrake

        -- Calculate thrust based on input
        local thrustPower = ASC.Flight.Config.Acceleration
        if flight.boostActive then
            thrustPower = thrustPower * ASC.Flight.Config.BoostMultiplier
        elseif flight.brakeActive then
            thrustPower = thrustPower * ASC.Flight.Config.BrakeMultiplier
        end

        -- Apply movement sensitivity
        inputVector = inputVector * ASC.Flight.Config.MovementSensitivity

        -- Convert input to world space thrust
        local forward = shipAng:Forward()
        local right = shipAng:Right()
        local up = shipAng:Up()

        local worldThrust = Vector(0, 0, 0)
        worldThrust = worldThrust + (forward * inputVector.x * thrustPower)
        worldThrust = worldThrust + (right * inputVector.y * thrustPower)
        worldThrust = worldThrust + (up * inputVector.z * thrustPower)

        -- Apply braking if brake is active
        if flight.brakeActive then
            local brakeForce = -flight.velocity * ASC.Flight.Config.Deceleration
            worldThrust = worldThrust + brakeForce
        end

        flight.thrust = worldThrust
        flight.inputVector = inputVector
        flight.mouseInput = mouseInput

        -- Apply mouse steering to angular velocity
        if ASC.Flight.Config.MouseSteering and mouseInput:Length() > 0 then
            local turnRate = ASC.Flight.Config.TurnRate * ASC.Flight.Config.MouseSensitivity
            flight.angularVelocity.p = flight.angularVelocity.p + (mouseInput.p * turnRate)
            flight.angularVelocity.y = flight.angularVelocity.y + (mouseInput.y * turnRate)
            flight.angularVelocity.r = flight.angularVelocity.r + (mouseInput.r * turnRate * 0.5)
        end

        -- Stability assist
        if ASC.Flight.Config.StabilityAssist and flight.stabilityAssist then
            flight.angularVelocity = flight.angularVelocity * ASC.Flight.Config.InertialDamping
        end
    end,

    -- Enable vehicle control
    EnableVehicleControl = function(shipID, pilot)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight or not IsValid(pilot) then return false end

        -- Check if pilot is in a seat on the ship
        local pilotSeat = ASC.Flight.Core.FindPilotSeat(shipID, pilot)
        if not pilotSeat then
            return false, "You must be sitting in a seat welded to the ship to enable vehicle control!"
        end

        -- Disable autopilot if active
        if flight.autopilotActive then
            ASC.Flight.Core.DisableAutopilot(shipID)
        end

        flight.vehicleControlActive = true
        flight.pilot = pilot
        flight.pilotSeat = pilotSeat
        flight.controlMode = "VEHICLE"
        flight.lastEyeAngles = pilot:EyeAngles()

        -- Update ship core
        if IsValid(flight.shipCore) then
            flight.shipCore:SetNWBool("VehicleControlActive", true)
            flight.shipCore:SetNWString("ControlMode", "VEHICLE")
            flight.shipCore:SetNWEntity("Pilot", pilot)
            flight.shipCore:SetNWEntity("PilotSeat", pilotSeat)
        end

        -- Configure seat for ship control
        ASC.Flight.Core.ConfigurePilotSeat(pilotSeat, pilot)

        -- Notify pilot
        pilot:ChatPrint("🚁 Cockpit control enabled with external camera!")
        pilot:ChatPrint("🎮 Use WASD to fly, mouse to steer, SHIFT to brake, SPACE to boost")
        pilot:ChatPrint("📷 Camera: Mouse wheel = zoom, R = reset camera")
        pilot:ChatPrint("💡 Use 'aria vehicle off' to disable cockpit control")

        print("[Flight System] Vehicle control enabled for ship " .. shipID .. " - Pilot: " .. pilot:Name() .. " in seat: " .. pilotSeat:EntIndex())
        return true
    end,

    -- Find pilot seat on ship
    FindPilotSeat = function(shipID, pilot)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight or not IsValid(pilot) then return nil end

        -- Check if pilot is in a vehicle (seat)
        local vehicle = pilot:GetVehicle()
        if not IsValid(vehicle) then return nil end

        -- Check if the seat is part of the ship
        if flight.shipCore.GetEntities then
            for _, ent in ipairs(flight.shipCore:GetEntities()) do
                if ent == vehicle then
                    -- Found the seat on the ship
                    return vehicle
                end
            end
        end

        -- Alternative check: look for seats near the ship core
        local shipPos = flight.shipCore:GetPos()
        local seatPos = vehicle:GetPos()
        local distance = shipPos:Distance(seatPos)

        -- If seat is within reasonable distance and same owner, consider it part of ship
        if distance < 2000 then
            local seatOwner = vehicle:CPPIGetOwner()
            local shipOwner = flight.shipCore:CPPIGetOwner()
            if IsValid(seatOwner) and IsValid(shipOwner) and seatOwner == shipOwner then
                return vehicle
            end
        end

        return nil
    end,

    -- Configure pilot seat for ship control
    ConfigurePilotSeat = function(seat, pilot)
        if not IsValid(seat) or not IsValid(pilot) then return end

        -- Store original seat settings
        seat.ASC_OriginalThirdPerson = seat:GetNWBool("ASC_ThirdPerson", false)
        seat.ASC_OriginalExitPos = seat.ExitPos or Vector(0, 0, 0)
        seat.ASC_OriginalCameraDistance = seat:GetNWFloat("ASC_CameraDistance", 0)
        seat.ASC_OriginalCameraHeight = seat:GetNWFloat("ASC_CameraHeight", 0)

        -- Configure seat for ship flying with external camera
        seat:SetNWBool("ASC_ShipControl", true)
        seat:SetNWBool("ASC_ThirdPerson", true) -- Enable third person for ship view
        seat:SetNWFloat("ASC_CameraDistance", 400) -- Camera distance behind ship
        seat:SetNWFloat("ASC_CameraHeight", 100) -- Camera height above ship
        seat:SetNWBool("ASC_ExternalCamera", true) -- Enable external camera mode
        seat:SetNWEntity("ASC_ControlledShip", pilot:GetVehicle())

        -- Prevent accidental exit during flight
        seat.ASC_FlightMode = true

        -- Set up camera positioning
        ASC.Flight.Core.SetupShipCamera(seat, pilot)

        print("[Flight System] Configured pilot seat " .. seat:EntIndex() .. " for ship control with external camera")
    end,

    -- Setup ship camera positioning
    SetupShipCamera = function(seat, pilot)
        if not IsValid(seat) or not IsValid(pilot) then return end

        -- Find the ship core for camera reference
        local shipCore = nil
        for shipID, flight in pairs(ASC.Flight.Core.ActiveFlights) do
            if flight.pilot == pilot then
                shipCore = flight.shipCore
                break
            end
        end

        if not IsValid(shipCore) then return end

        -- Store ship core reference for camera calculations
        seat:SetNWEntity("ASC_ShipCore", shipCore)
        seat:SetNWVector("ASC_ShipCoreOffset", seat:GetPos() - shipCore:GetPos())

        -- Configure camera settings for ship flying
        seat:SetNWBool("ASC_CameraFollowShip", true)
        seat:SetNWFloat("ASC_CameraSmoothness", 0.1) -- Camera smoothing
        seat:SetNWBool("ASC_CameraCollision", true) -- Camera collision detection

        print("[Flight System] Setup external camera for ship " .. shipCore:EntIndex())
    end,

    -- Restore pilot seat to normal
    RestorePilotSeat = function(seat)
        if not IsValid(seat) then return end

        -- Restore original settings
        seat:SetNWBool("ASC_ShipControl", false)
        seat:SetNWBool("ASC_ThirdPerson", seat.ASC_OriginalThirdPerson or false)
        seat:SetNWFloat("ASC_CameraDistance", seat.ASC_OriginalCameraDistance or 0)
        seat:SetNWFloat("ASC_CameraHeight", seat.ASC_OriginalCameraHeight or 0)
        seat:SetNWBool("ASC_ExternalCamera", false)
        seat:SetNWEntity("ASC_ControlledShip", NULL)
        seat:SetNWEntity("ASC_ShipCore", NULL)

        -- Clear camera settings
        seat:SetNWBool("ASC_CameraFollowShip", false)
        seat:SetNWFloat("ASC_CameraSmoothness", 0)
        seat:SetNWBool("ASC_CameraCollision", false)
        seat:SetNWVector("ASC_ShipCoreOffset", Vector(0, 0, 0))

        -- Restore exit behavior
        seat.ASC_FlightMode = false

        print("[Flight System] Restored pilot seat " .. seat:EntIndex() .. " to normal with camera reset")
    end,

    -- Disable vehicle control
    DisableVehicleControl = function(shipID, shutdownFlight)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return false end

        local pilot = flight.pilot
        local pilotSeat = flight.pilotSeat

        -- Restore pilot seat to normal
        if IsValid(pilotSeat) then
            ASC.Flight.Core.RestorePilotSeat(pilotSeat)
        end

        -- Clear vehicle control state
        flight.vehicleControlActive = false
        flight.pilot = nil
        flight.pilotSeat = nil
        flight.controlMode = "AUTOPILOT"
        flight.inputVector = Vector(0, 0, 0)
        flight.mouseInput = Angle(0, 0, 0)
        flight.thrust = Vector(0, 0, 0)
        flight.angularVelocity = Angle(0, 0, 0)
        flight.boostActive = false
        flight.brakeActive = false

        -- Optionally shutdown entire flight system when player leaves
        if shutdownFlight then
            -- Auto-level ship before shutdown
            ASC.Flight.Core.AutoLevelShip(shipID)

            flight.active = false
            flight.autopilotActive = false
            flight.formationActive = false

            -- Clear ship core status
            if IsValid(flight.shipCore) then
                flight.shipCore:SetNWBool("FlightSystemActive", false)
                flight.shipCore:SetNWBool("VehicleControlActive", false)
                flight.shipCore:SetNWBool("AutopilotActive", false)
                flight.shipCore:SetNWEntity("Pilot", NULL)
                flight.shipCore:SetNWEntity("PilotSeat", NULL)
                flight.shipCore:SetNWString("ControlMode", "MANUAL")
            end

            print("[Flight System] Auto-leveled and shut down flight system for ship " .. shipID)
        else
            -- Keep flight system active but switch to autopilot mode
            flight.controlMode = "AUTOPILOT"

            -- Update ship core status
            if IsValid(flight.shipCore) then
                flight.shipCore:SetNWBool("VehicleControlActive", false)
                flight.shipCore:SetNWEntity("Pilot", NULL)
                flight.shipCore:SetNWEntity("PilotSeat", NULL)
                flight.shipCore:SetNWString("ControlMode", "AUTOPILOT")
            end
        end

        -- Update ship core
        if IsValid(flight.shipCore) then
            flight.shipCore:SetNWBool("VehicleControlActive", false)
            flight.shipCore:SetNWString("ControlMode", "AUTOPILOT")
            flight.shipCore:SetNWEntity("Pilot", NULL)
            flight.shipCore:SetNWEntity("PilotSeat", NULL)
        end

        -- Notify pilot
        if IsValid(pilot) then
            pilot:ChatPrint("🚁 Vehicle control disabled - Seat restored to normal")
        end

        print("[Flight System] Vehicle control disabled for ship " .. shipID)
        return true
    end,

    -- Apply collision avoidance
    ApplyCollisionAvoidance = function(shipID, direction)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return end
        
        local shipPos = flight.shipCore:GetPos()
        local avoidanceVector = Vector(0, 0, 0)
        
        -- Check for nearby entities
        local nearbyEnts = ents.FindInSphere(shipPos, ASC.Flight.Config.AvoidanceDistance)
        for _, ent in ipairs(nearbyEnts) do
            if IsValid(ent) and ent ~= flight.shipCore and ent:GetClass() ~= "player" then
                local entPos = ent:GetPos()
                local distance = shipPos:Distance(entPos)
                
                if distance < ASC.Flight.Config.AvoidanceDistance then
                    -- Calculate avoidance vector
                    local avoidDir = (shipPos - entPos):GetNormalized()
                    local avoidStrength = (ASC.Flight.Config.AvoidanceDistance - distance) / ASC.Flight.Config.AvoidanceDistance
                    avoidanceVector = avoidanceVector + (avoidDir * avoidStrength * 1000)
                end
            end
        end
        
        -- Apply avoidance to thrust
        if avoidanceVector:Length() > 0 then
            flight.thrust = flight.thrust + avoidanceVector
            flight.collisionWarning = true
        else
            flight.collisionWarning = false
        end
    end,
    
    -- Reached waypoint
    ReachedWaypoint = function(shipID)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return end
        
        flight.waypointsReached = flight.waypointsReached + 1
        
        -- Move to next waypoint
        if flight.currentWaypoint < #flight.waypoints then
            flight.currentWaypoint = flight.currentWaypoint + 1
            flight.autopilotTarget = flight.waypoints[flight.currentWaypoint]
            print("[Flight System] Ship " .. shipID .. " reached waypoint, moving to next")
        else
            -- All waypoints reached
            ASC.Flight.Core.DisableAutopilot(shipID)
            print("[Flight System] Ship " .. shipID .. " reached final waypoint")
        end
    end,
    
    -- Enable autopilot
    EnableAutopilot = function(shipID, target, mode)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return false end
        
        flight.autopilotActive = true
        flight.autopilotTarget = target
        flight.autopilotMode = mode or "DIRECT"
        
        -- Update ship core
        if IsValid(flight.shipCore) then
            flight.shipCore:SetNWBool("AutopilotActive", true)
            flight.shipCore:SetNWString("AutopilotMode", flight.autopilotMode)
        end
        
        print("[Flight System] Autopilot enabled for ship " .. shipID .. " - Mode: " .. flight.autopilotMode)
        return true
    end,
    
    -- Disable autopilot
    DisableAutopilot = function(shipID)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return false end
        
        flight.autopilotActive = false
        flight.autopilotTarget = nil
        flight.thrust = Vector(0, 0, 0)
        
        -- Update ship core
        if IsValid(flight.shipCore) then
            flight.shipCore:SetNWBool("AutopilotActive", false)
        end
        
        print("[Flight System] Autopilot disabled for ship " .. shipID)
        return true
    end,
    
    -- Add waypoint
    AddWaypoint = function(shipID, position, name)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return false end
        
        if #flight.waypoints >= ASC.Flight.Config.MaxWaypoints then
            return false, "Maximum waypoints reached"
        end
        
        table.insert(flight.waypoints, position)
        
        print("[Flight System] Added waypoint for ship " .. shipID .. " at " .. tostring(position))
        return true
    end,
    
    -- Clear waypoints
    ClearWaypoints = function(shipID)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return false end
        
        flight.waypoints = {}
        flight.currentWaypoint = 1
        flight.autopilotTarget = nil
        
        print("[Flight System] Cleared waypoints for ship " .. shipID)
        return true
    end,

    -- Update formation flying (placeholder)
    UpdateFormation = function(shipID, deltaTime)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight or not flight.formationActive then return end

        -- Ensure deltaTime is valid
        deltaTime = deltaTime or 0.05 -- Default to 50ms if nil
        if deltaTime <= 0 then deltaTime = 0.05 end

        -- TODO: Implement formation flying logic
        -- For now, just maintain current position
    end,

    -- Update safety systems
    UpdateSafetySystems = function(shipID, deltaTime)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return end

        -- Ensure deltaTime is valid (for consistency, even though not used)
        deltaTime = deltaTime or 0.05 -- Default to 50ms if nil
        if deltaTime <= 0 then deltaTime = 0.05 end

        local currentTime = CurTime()
        
        -- Collision warning system
        if currentTime - flight.lastCollisionCheck > 0.5 then
            flight.lastCollisionCheck = currentTime
            
            local shipPos = flight.shipCore:GetPos()
            local velocity = flight.velocity
            
            -- Check for potential collisions
            if velocity:Length() > 100 then
                local trace = util.TraceLine({
                    start = shipPos,
                    endpos = shipPos + velocity:GetNormalized() * ASC.Flight.Config.SafetyRadius,
                    filter = flight.shipCore
                })
                
                if trace.Hit then
                    flight.collisionWarning = true
                    
                    -- Emergency braking
                    if ASC.Flight.Config.AutomaticBraking then
                        flight.emergencyBraking = true
                        flight.thrust = -velocity * 0.5
                    end
                else
                    flight.collisionWarning = false
                    flight.emergencyBraking = false
                end
            end
        end
    end,
    
    -- Update performance tracking
    UpdatePerformanceTracking = function(shipID, deltaTime)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return end

        -- Ensure deltaTime is valid
        deltaTime = deltaTime or 0.05 -- Default to 50ms if nil
        if deltaTime <= 0 then deltaTime = 0.05 end

        -- Track distance traveled
        local distance = flight.velocity:Length() * deltaTime
        flight.distanceTraveled = flight.distanceTraveled + distance

        -- Track energy consumption
        local energyCost = ASC.Flight.Config.IdleEnergyCost
        if flight.thrust:Length() > 0 then
            energyCost = energyCost + (flight.thrust:Length() / ASC.Flight.Config.MaxThrust) * ASC.Flight.Config.ThrustEnergyCost
        end
        if flight.autopilotActive then
            energyCost = energyCost + ASC.Flight.Config.AutopilotEnergyCost
        end

        flight.energyConsumed = flight.energyConsumed + (energyCost * deltaTime)
        flight.flightTime = flight.flightTime + deltaTime
    end,
    
    -- Apply physics
    ApplyPhysics = function(shipID, deltaTime)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight or not IsValid(flight.shipCore) then return end

        -- Ensure deltaTime is valid
        deltaTime = deltaTime or 0.05 -- Default to 50ms if nil
        if deltaTime <= 0 then deltaTime = 0.05 end

        -- Apply thrust to velocity
        local acceleration = flight.thrust / flight.mass
        flight.velocity = flight.velocity + (acceleration * deltaTime)

        -- Apply drag
        local drag = flight.velocity * ASC.Flight.Config.MaxSpeed * 0.01
        flight.velocity = flight.velocity - (drag * deltaTime)

        -- Limit maximum speed
        if flight.velocity:Length() > ASC.Flight.Config.MaxSpeed then
            flight.velocity = flight.velocity:GetNormalized() * ASC.Flight.Config.MaxSpeed
        end

        -- Apply rotation for vehicle control
        if flight.vehicleControlActive and flight.angularVelocity:Length() > 0 then
            ASC.Flight.Core.ApplyRotation(shipID, deltaTime)
        end

        -- Apply movement to ship entities
        if flight.shipCore.GetEntities then
            local movement = flight.velocity * deltaTime
            local rotation = flight.angularVelocity * deltaTime

            for _, ent in ipairs(flight.shipCore:GetEntities()) do
                if IsValid(ent) and ent:GetPhysicsObject():IsValid() then
                    local phys = ent:GetPhysicsObject()

                    -- Apply velocity
                    phys:SetVelocity(flight.velocity)

                    -- Apply rotation for vehicle control
                    if flight.vehicleControlActive then
                        local currentAngles = ent:GetAngles()
                        local newAngles = currentAngles + rotation
                        ent:SetAngles(newAngles)
                    end
                end
            end
        end
    end,

    -- Apply rotation physics
    ApplyRotation = function(shipID, deltaTime)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then return end

        -- Ensure deltaTime is valid
        deltaTime = deltaTime or 0.05 -- Default to 50ms if nil
        if deltaTime <= 0 then deltaTime = 0.05 end

        -- Apply angular drag
        local angularDrag = flight.angularVelocity * 0.1
        flight.angularVelocity = flight.angularVelocity - (angularDrag * deltaTime)

        -- Limit angular velocity
        local maxAngularVel = 45 -- degrees per second
        if flight.angularVelocity.p > maxAngularVel then flight.angularVelocity.p = maxAngularVel end
        if flight.angularVelocity.p < -maxAngularVel then flight.angularVelocity.p = -maxAngularVel end
        if flight.angularVelocity.y > maxAngularVel then flight.angularVelocity.y = maxAngularVel end
        if flight.angularVelocity.y < -maxAngularVel then flight.angularVelocity.y = -maxAngularVel end
        if flight.angularVelocity.r > maxAngularVel then flight.angularVelocity.r = maxAngularVel end
        if flight.angularVelocity.r < -maxAngularVel then flight.angularVelocity.r = -maxAngularVel end
    end,

    -- Auto-level ship (stabilize rotation and stop movement)
    AutoLevelShip = function(shipID)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight or not IsValid(flight.shipCore) then return false end

        print("[Flight System] Auto-leveling ship " .. shipID)

        -- Stop all movement and rotation
        flight.thrust = Vector(0, 0, 0)
        flight.velocity = flight.velocity * 0.1 -- Gradual deceleration
        flight.angularVelocity = Angle(0, 0, 0)
        flight.inputVector = Vector(0, 0, 0)
        flight.mouseInput = Angle(0, 0, 0)
        flight.boostActive = false
        flight.brakeActive = false

        -- Apply leveling to all ship entities
        if flight.shipCore.GetEntities then
            local shipEntities = flight.shipCore:GetEntities()
            local shipCorePos = flight.shipCore:GetPos()
            local shipCoreAngles = flight.shipCore:GetAngles()

            -- Calculate level angles (remove pitch and roll, keep yaw)
            local levelAngles = Angle(0, shipCoreAngles.y, 0)

            for _, ent in ipairs(shipEntities) do
                if IsValid(ent) and ent:GetPhysicsObject():IsValid() then
                    local phys = ent:GetPhysicsObject()

                    -- Stop entity movement
                    phys:SetVelocity(Vector(0, 0, 0))
                    phys:SetAngularVelocity(Vector(0, 0, 0))

                    -- Level the entity (smooth transition)
                    local currentAngles = ent:GetAngles()
                    local targetAngles = Angle(0, currentAngles.y, 0) -- Keep yaw, level pitch and roll

                    -- Smooth angle transition
                    local lerpedAngles = LerpAngle(0.3, currentAngles, targetAngles)
                    ent:SetAngles(lerpedAngles)

                    -- Apply gentle downward force to settle the ship
                    local mass = phys:GetMass()
                    phys:ApplyForceCenter(Vector(0, 0, -mass * 50))
                end
            end
        end

        -- Update ship core status
        if IsValid(flight.shipCore) then
            flight.shipCore:SetNWBool("AutoLeveling", true)

            -- Remove auto-leveling flag after a short time
            timer.Simple(2, function()
                if IsValid(flight.shipCore) then
                    flight.shipCore:SetNWBool("AutoLeveling", false)
                end
            end)
        end

        print("[Flight System] Ship " .. shipID .. " auto-leveled and stabilized")
        return true
    end,
    
    -- Get flight status
    GetFlightStatus = function(shipID)
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        if not flight then
            return {
                available = false,
                status = "OFFLINE"
            }
        end
        
        local status = "IDLE"
        if flight.vehicleControlActive then
            status = "VEHICLE_CONTROL"
        elseif flight.autopilotActive then
            status = "AUTOPILOT"
        elseif flight.formationActive then
            status = "FORMATION"
        elseif flight.thrust:Length() > 100 then
            status = "MANUAL"
        end

        return {
            available = flight.active,
            status = status,
            controlMode = flight.controlMode,
            autopilotActive = flight.autopilotActive,
            vehicleControlActive = flight.vehicleControlActive,
            formationActive = flight.formationActive,
            pilot = flight.pilot,
            velocity = flight.velocity:Length(),
            waypoints = #flight.waypoints,
            distanceTraveled = flight.distanceTraveled,
            energyConsumed = flight.energyConsumed,
            collisionWarning = flight.collisionWarning,
            emergencyBraking = flight.emergencyBraking,
            boostActive = flight.boostActive,
            brakeActive = flight.brakeActive,
            stabilityAssist = flight.stabilityAssist
        }
    end
}

-- Initialize system
if SERVER then
    -- Update all flight systems
    timer.Create("ASC_Flight_Update", ASC.Flight.Config.UpdateRate, 0, function()
        for shipID, flight in pairs(ASC.Flight.Core.ActiveFlights) do
            ASC.Flight.Core.Update(shipID, ASC.Flight.Config.UpdateRate)
        end
    end)

    -- Hook for when player leaves vehicle (seat)
    hook.Add("PlayerLeaveVehicle", "ASC_Flight_SeatExit", function(player, vehicle)
        -- Check if this player was controlling a ship from this seat
        for shipID, flight in pairs(ASC.Flight.Core.ActiveFlights) do
            if flight.vehicleControlActive and flight.pilot == player and flight.pilotSeat == vehicle then
                -- Player left their pilot seat, automatically disable vehicle control and level ship
                ASC.Flight.Core.DisableVehicleControl(shipID, true) -- true = shutdown flight system completely

                -- Get player language for localized messages
                local playerLang = "en"
                if ASC.Multilingual and ASC.Multilingual.Core then
                    playerLang = ASC.Multilingual.Core.GetPlayerLanguage(player)
                end

                -- Provide multilingual feedback
                if playerLang == "cs" then
                    player:ChatPrint("🚁 Letový systém automaticky deaktivován - Opustili jste pilotní sedadlo")
                    player:ChatPrint("⚖️ Loď se automaticky vyrovnává a stabilizuje")
                    player:ChatPrint("📷 Externí kamera vypnuta")
                    player:ChatPrint("💡 Sedněte si zpět pro opětovnou aktivaci řízení letu")
                elseif playerLang == "de" then
                    player:ChatPrint("🚁 Flugsystem automatisch deaktiviert - Sie haben den Pilotensitz verlassen")
                    player:ChatPrint("⚖️ Schiff wird automatisch nivelliert und stabilisiert")
                    player:ChatPrint("📷 Externe Kamera ausgeschaltet")
                    player:ChatPrint("💡 Setzen Sie sich wieder hin, um die Flugkontrolle zu reaktivieren")
                elseif playerLang == "fr" then
                    player:ChatPrint("🚁 Système de vol automatiquement désactivé - Vous avez quitté le siège pilote")
                    player:ChatPrint("⚖️ Le vaisseau se nivelle et se stabilise automatiquement")
                    player:ChatPrint("📷 Caméra externe désactivée")
                    player:ChatPrint("💡 Rasseyez-vous pour réactiver le contrôle de vol")
                else
                    player:ChatPrint("🚁 Flight system automatically deactivated - You left the pilot seat")
                    player:ChatPrint("⚖️ Ship automatically leveling and stabilizing")
                    player:ChatPrint("📷 External camera disabled")
                    player:ChatPrint("💡 Sit back down to reactivate flight control")
                end

                print("[Flight System] Auto-deactivated flight for " .. player:Name() .. " on ship " .. shipID .. " - Left pilot seat")
                break
            end
        end
    end)

    -- Hook for when player enters vehicle (seat)
    hook.Add("PlayerEnteredVehicle", "ASC_Flight_SeatEnter", function(player, vehicle, role)
        -- First, check if this seat is near any ship core (even without flight system)
        local nearbyShipCore = ASC.Flight.Core.FindNearbyShipCore(vehicle, player)
        if IsValid(nearbyShipCore) then
            local shipID = nearbyShipCore:EntIndex()

            -- Initialize flight system if it doesn't exist
            if not ASC.Flight.Core.ActiveFlights[shipID] then
                print("[Flight System] Auto-initializing flight system for ship " .. shipID .. " when player " .. player:Name() .. " sat down")
                ASC.Flight.Core.Initialize(nearbyShipCore, "STANDARD")
            end
        end

        -- Check if this seat is on a ship with flight system
        for shipID, flight in pairs(ASC.Flight.Core.ActiveFlights) do
            if IsValid(flight.shipCore) then
                -- Check if this seat belongs to this ship
                local seatOnShip = false
                if flight.shipCore.GetEntities then
                    for _, ent in ipairs(flight.shipCore:GetEntities()) do
                        if ent == vehicle then
                            seatOnShip = true
                            break
                        end
                    end
                end

                -- Alternative check: distance and ownership
                if not seatOnShip then
                    local shipPos = flight.shipCore:GetPos()
                    local seatPos = vehicle:GetPos()
                    local distance = shipPos:Distance(seatPos)

                    if distance < 2000 then
                        local seatOwner = vehicle:CPPIGetOwner()
                        local shipOwner = flight.shipCore:CPPIGetOwner()
                        if IsValid(seatOwner) and IsValid(shipOwner) and seatOwner == shipOwner then
                            seatOnShip = true
                        end
                    end
                end

                if seatOnShip then
                    -- Automatically enable vehicle control when player sits down
                    timer.Simple(0.1, function()
                        if IsValid(player) and player:GetVehicle() == vehicle then
                            -- Check if player has permission to control this ship
                            local shipOwner = flight.shipCore:CPPIGetOwner()
                            local hasPermission = (shipOwner == player) or
                                                flight.shipCore:GetNWBool("PublicAccess", false) or
                                                ASC.Flight.Core.HasShipPermission(player, flight.shipCore)

                            if hasPermission then
                                -- Automatically enable vehicle control
                                local success = ASC.Flight.Core.EnableVehicleControl(shipID, player)
                                if success then
                                    -- Get player language for localized messages
                                    local playerLang = "en"
                                    if ASC.Multilingual and ASC.Multilingual.Core then
                                        playerLang = ASC.Multilingual.Core.GetPlayerLanguage(player)
                                    end

                                    if playerLang == "cs" then
                                        player:ChatPrint("🚁 Letový systém automaticky aktivován!")
                                        player:ChatPrint("🎮 Řízení kokpitu aktivováno - Použijte WASD k létání, myš k řízení")
                                        player:ChatPrint("📷 Externí kamera aktivní - Kolečko myši = zoom, R = reset kamery")
                                        player:ChatPrint("💡 Použijte 'aria let vypnout' k deaktivaci řízení letu")
                                    elseif playerLang == "de" then
                                        player:ChatPrint("🚁 Flugsystem automatisch aktiviert!")
                                        player:ChatPrint("🎮 Cockpit-Steuerung aktiviert - WASD zum Fliegen, Maus zum Steuern")
                                        player:ChatPrint("📷 Externe Kamera aktiv - Mausrad = Zoom, R = Kamera zurücksetzen")
                                        player:ChatPrint("💡 Verwenden Sie 'aria flug aus' zum Deaktivieren der Flugkontrolle")
                                    elseif playerLang == "fr" then
                                        player:ChatPrint("🚁 Système de vol automatiquement activé!")
                                        player:ChatPrint("🎮 Contrôle du cockpit activé - WASD pour voler, souris pour diriger")
                                        player:ChatPrint("📷 Caméra externe active - Molette = zoom, R = réinitialiser caméra")
                                        player:ChatPrint("💡 Utilisez 'aria vol désactivé' pour désactiver le contrôle de vol")
                                    else
                                        player:ChatPrint("🚁 Flight system automatically activated!")
                                        player:ChatPrint("🎮 Cockpit control enabled - Use WASD to fly, mouse to steer")
                                        player:ChatPrint("📷 External camera active - Mouse wheel to zoom, R to reset")
                                        player:ChatPrint("💡 Use 'aria flight off' to disable flight control")
                                    end

                                    print("[Flight System] Auto-activated flight for " .. player:Name() .. " on ship " .. shipID)
                                else
                                    if playerLang == "cs" then
                                        player:ChatPrint("🪑 Jste v sedadle kokpitu lodi! Použijte 'aria let zapnout' k aktivaci řízení letu")
                                    elseif playerLang == "de" then
                                        player:ChatPrint("🪑 Sie sind in einem Schiffs-Cockpit-Sitz! Verwenden Sie 'aria flug an' zur Aktivierung der Flugkontrolle")
                                    elseif playerLang == "fr" then
                                        player:ChatPrint("🪑 Vous êtes dans un siège de cockpit de vaisseau! Utilisez 'aria vol activé' pour activer le contrôle de vol")
                                    else
                                        player:ChatPrint("🪑 You're in a ship cockpit seat! Use 'aria flight on' to enable flight control")
                                    end
                                end
                            else
                                player:ChatPrint("❌ You don't have permission to control this ship")
                            end
                        end
                    end)
                    break
                end
            end
        end
    end)

    -- Update system status
    ASC.SystemStatus = ASC.SystemStatus or {}
    ASC.SystemStatus.FlightSystem = true
    ASC.SystemStatus.NavigationSystem = true
    ASC.SystemStatus.CockpitControl = true
    ASC.SystemStatus.AutoFlightActivation = true

    print("[Advanced Space Combat] Flight System v3.0.0 loaded with auto-activation cockpit control")
end

-- Check if player has permission to control ship
ASC.Flight.Core.HasShipPermission = function(player, shipCore)
    if not IsValid(player) or not IsValid(shipCore) then return false end

    -- Owner always has permission
    local owner = shipCore:CPPIGetOwner()
    if IsValid(owner) and owner == player then return true end

    -- Check if ship allows public access
    if shipCore:GetNWBool("PublicAccess", false) then return true end

    -- Check if player is in allowed users list
    local allowedUsers = shipCore:GetNWString("AllowedUsers", "")
    if allowedUsers ~= "" then
        local userList = string.Split(allowedUsers, ",")
        local playerSteamID = player:SteamID()
        for _, steamID in ipairs(userList) do
            if string.Trim(steamID) == playerSteamID then
                return true
            end
        end
    end

    -- Check team/buddy system if available
    if IsValid(owner) and owner:GetUserGroup() == player:GetUserGroup() and player:GetUserGroup() ~= "user" then
        return true
    end

    -- Check if they're friends (if friend system exists)
    if IsValid(owner) and player.IsFriend and player:IsFriend(owner) then
        return true
    end

    return false
end

-- Find nearby ship core for a seat
ASC.Flight.Core.FindNearbyShipCore = function(seat, player)
    if not IsValid(seat) or not IsValid(player) then return nil end

    local seatPos = seat:GetPos()
    local searchRadius = 2000

    -- Look for ship cores near the seat
    for _, ent in ipairs(ents.FindInSphere(seatPos, searchRadius)) do
        if ent:GetClass() == "asc_ship_core" then
            -- Check ownership/permission
            local shipOwner = ent:CPPIGetOwner()
            local seatOwner = seat:CPPIGetOwner()
            local distance = seatPos:Distance(ent:GetPos())

            -- Check if player has permission to use this ship
            local hasPermission = (shipOwner == player) or
                                (IsValid(seatOwner) and seatOwner == player) or
                                ent:GetNWBool("PublicAccess", false) or
                                ASC.Flight.Core.HasShipPermission(player, ent)

            if hasPermission and distance < 1500 then
                -- Check if seat is part of this ship (welded or same owner)
                if ent.GetEntities then
                    for _, shipEnt in ipairs(ent:GetEntities()) do
                        if shipEnt == seat then
                            return ent -- Found the ship core this seat belongs to
                        end
                    end
                end

                -- Alternative check: same owner and reasonable distance
                if IsValid(seatOwner) and IsValid(shipOwner) and seatOwner == shipOwner and distance < 800 then
                    return ent
                end

                -- If seat owner matches player and ship is close, assume it's part of the ship
                if IsValid(seatOwner) and seatOwner == player and distance < 600 then
                    return ent
                end
            end
        end
    end

    return nil
end
