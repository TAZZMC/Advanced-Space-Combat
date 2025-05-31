-- Enhanced Hyperdrive Ship Flight System v2.2.1
-- Advanced ship movement, navigation, and autopilot system

print("[Hyperdrive Flight] Ship Flight System v2.2.1 - Initializing...")

-- Initialize flight namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Flight = HYPERDRIVE.Flight or {}

-- Flight system configuration
HYPERDRIVE.Flight.Config = {
    -- Movement Settings
    MaxThrust = 5000, -- Maximum thrust force
    MaxSpeed = 2000, -- Maximum velocity
    ThrustEfficiency = 0.8, -- Thrust efficiency factor
    DragCoefficient = 0.1, -- Space drag simulation
    RotationSpeed = 2.0, -- Rotation speed multiplier
    
    -- Energy Consumption
    ThrustEnergyCost = 5, -- Energy per thrust unit per second
    RotationEnergyCost = 2, -- Energy per rotation unit per second
    IdleEnergyCost = 1, -- Energy consumption when idle
    
    -- Autopilot Settings
    AutopilotAccuracy = 50, -- Distance tolerance for waypoints
    AutopilotSpeed = 0.8, -- Speed multiplier for autopilot
    CollisionAvoidance = true, -- Enable collision avoidance
    AvoidanceDistance = 500, -- Distance to avoid obstacles
    
    -- Navigation
    WaypointSystem = true, -- Enable waypoint navigation
    MaxWaypoints = 20, -- Maximum waypoints per ship
    NavigationRange = 10000, -- Maximum navigation range
    
    -- Flight Modes
    FlightModes = {
        manual = {
            name = "Manual",
            description = "Direct player control",
            autopilot = false,
            stabilization = true
        },
        autopilot = {
            name = "Autopilot",
            description = "Automated navigation to waypoints",
            autopilot = true,
            stabilization = true
        },
        formation = {
            name = "Formation",
            description = "Maintain formation with other ships",
            autopilot = true,
            stabilization = true
        },
        combat = {
            name = "Combat",
            description = "Combat maneuvering mode",
            autopilot = false,
            stabilization = false
        }
    }
}

-- Flight system registry
HYPERDRIVE.Flight.Ships = {} -- Active flight systems
HYPERDRIVE.Flight.Waypoints = {} -- Global waypoint system
HYPERDRIVE.Flight.Formations = {} -- Formation definitions

-- Ship flight system class
local ShipFlight = {}
ShipFlight.__index = ShipFlight

function ShipFlight:New(shipCore)
    local flight = setmetatable({}, ShipFlight)
    
    flight.shipCore = shipCore
    flight.ship = nil
    flight.active = false
    flight.flightMode = "manual"
    
    -- Movement properties
    flight.thrust = Vector(0, 0, 0)
    flight.rotation = Angle(0, 0, 0)
    flight.velocity = Vector(0, 0, 0)
    flight.angularVelocity = Angle(0, 0, 0)
    flight.mass = 1000 -- Default ship mass
    
    -- Navigation
    flight.waypoints = {}
    flight.currentWaypoint = 1
    flight.destination = nil
    flight.autopilotActive = false
    flight.stabilizationActive = true
    
    -- Formation flying
    flight.formation = nil
    flight.formationPosition = Vector(0, 0, 0)
    flight.formationLeader = nil
    
    -- Energy management
    flight.energyConsumption = 0
    flight.lastEnergyUpdate = 0
    
    -- Performance tracking
    flight.stats = {
        distanceTraveled = 0,
        energyConsumed = 0,
        flightTime = 0,
        waypointsReached = 0
    }
    
    return flight
end

function ShipFlight:Initialize()
    -- Get ship data
    if HYPERDRIVE.ShipCore then
        self.ship = HYPERDRIVE.ShipCore.GetShip(self.shipCore)
    end
    
    if self.ship then
        self.mass = self:CalculateShipMass()
        self.active = true
        print("[Flight System] Initialized for ship: " .. (self.ship:GetShipType() or "Unknown"))
    else
        print("[Flight System] Failed to initialize - no ship found")
    end
end

function ShipFlight:CalculateShipMass()
    local baseMass = 1000
    local entityCount = 0
    
    if self.ship and self.ship.entities then
        entityCount = #self.ship.entities
    end
    
    -- Mass scales with ship size
    return baseMass + (entityCount * 50)
end

function ShipFlight:Update(deltaTime)
    if not self.active or not IsValid(self.shipCore) then return end
    
    -- Update energy consumption
    self:UpdateEnergyConsumption(deltaTime)
    
    -- Update movement
    self:UpdateMovement(deltaTime)
    
    -- Update autopilot
    if self.autopilotActive then
        self:UpdateAutopilot(deltaTime)
    end
    
    -- Update formation flying
    if self.formation then
        self:UpdateFormation(deltaTime)
    end
    
    -- Update stabilization
    if self.stabilizationActive then
        self:UpdateStabilization(deltaTime)
    end
    
    -- Update statistics
    self:UpdateStatistics(deltaTime)
end

function ShipFlight:UpdateMovement(deltaTime)
    if not self.ship or not self.ship.entities then return end
    
    -- Calculate thrust force
    local thrustForce = self.thrust * HYPERDRIVE.Flight.Config.MaxThrust
    
    -- Apply mass scaling
    local acceleration = thrustForce / self.mass
    
    -- Update velocity
    self.velocity = self.velocity + acceleration * deltaTime
    
    -- Apply drag
    local drag = self.velocity * HYPERDRIVE.Flight.Config.DragCoefficient
    self.velocity = self.velocity - drag * deltaTime
    
    -- Limit maximum speed
    local speed = self.velocity:Length()
    if speed > HYPERDRIVE.Flight.Config.MaxSpeed then
        self.velocity = self.velocity:GetNormalized() * HYPERDRIVE.Flight.Config.MaxSpeed
    end
    
    -- Apply movement to ship entities
    self:ApplyMovementToShip(deltaTime)
    
    -- Update rotation
    self:UpdateRotation(deltaTime)
end

function ShipFlight:ApplyMovementToShip(deltaTime)
    if not self.ship or not self.ship.entities then return end
    
    local movement = self.velocity * deltaTime
    local shipCenter = self.shipCore:GetPos()
    
    -- Move all ship entities
    for _, entity in ipairs(self.ship.entities) do
        if IsValid(entity) then
            local currentPos = entity:GetPos()
            local newPos = currentPos + movement
            
            -- Use safe positioning
            if entity:GetPhysicsObject() and IsValid(entity:GetPhysicsObject()) then
                entity:GetPhysicsObject():SetPos(newPos)
            else
                entity:SetPos(newPos)
            end
        end
    end
end

function ShipFlight:UpdateRotation(deltaTime)
    if not self.ship or not self.ship.entities then return end
    
    -- Apply angular velocity
    self.angularVelocity = self.angularVelocity + self.rotation * HYPERDRIVE.Flight.Config.RotationSpeed * deltaTime
    
    -- Apply angular drag
    self.angularVelocity = self.angularVelocity * 0.95
    
    -- Get ship center
    local shipCenter = self.shipCore:GetPos()
    local rotationAngle = self.angularVelocity * deltaTime
    
    -- Rotate ship entities around center
    for _, entity in ipairs(self.ship.entities) do
        if IsValid(entity) and entity ~= self.shipCore then
            local relativePos = entity:GetPos() - shipCenter
            local rotatedPos = self:RotateVector(relativePos, rotationAngle)
            local newPos = shipCenter + rotatedPos
            
            -- Apply rotation
            if entity:GetPhysicsObject() and IsValid(entity:GetPhysicsObject()) then
                entity:GetPhysicsObject():SetPos(newPos)
                entity:GetPhysicsObject():SetAngles(entity:GetAngles() + rotationAngle)
            else
                entity:SetPos(newPos)
                entity:SetAngles(entity:GetAngles() + rotationAngle)
            end
        end
    end
    
    -- Update ship core rotation
    if IsValid(self.shipCore) then
        local newAngles = self.shipCore:GetAngles() + rotationAngle
        if self.shipCore:GetPhysicsObject() and IsValid(self.shipCore:GetPhysicsObject()) then
            self.shipCore:GetPhysicsObject():SetAngles(newAngles)
        else
            self.shipCore:SetAngles(newAngles)
        end
    end
end

function ShipFlight:RotateVector(vector, angle)
    -- Simple 3D rotation around Y axis (yaw)
    local cos_yaw = math.cos(math.rad(angle.y))
    local sin_yaw = math.sin(math.rad(angle.y))
    
    local x = vector.x * cos_yaw - vector.z * sin_yaw
    local z = vector.x * sin_yaw + vector.z * cos_yaw
    
    return Vector(x, vector.y, z)
end

function ShipFlight:UpdateAutopilot(deltaTime)
    if not self.destination and #self.waypoints > 0 then
        self.destination = self.waypoints[self.currentWaypoint]
    end
    
    if not self.destination then return end
    
    local shipPos = self.shipCore:GetPos()
    local targetPos = self.destination
    local distance = shipPos:Distance(targetPos)
    
    -- Check if we've reached the waypoint
    if distance < HYPERDRIVE.Flight.Config.AutopilotAccuracy then
        self:ReachWaypoint()
        return
    end
    
    -- Calculate direction to target
    local direction = (targetPos - shipPos):GetNormalized()
    
    -- Apply autopilot thrust
    local autopilotSpeed = HYPERDRIVE.Flight.Config.AutopilotSpeed
    self.thrust = direction * autopilotSpeed
    
    -- Face the target
    local targetAngle = direction:Angle()
    local currentAngle = self.shipCore:GetAngles()
    local angleDiff = self:AngleDifference(targetAngle, currentAngle)
    
    self.rotation = angleDiff * 0.1 -- Smooth rotation
    
    -- Collision avoidance
    if HYPERDRIVE.Flight.Config.CollisionAvoidance then
        self:ApplyCollisionAvoidance()
    end
end

function ShipFlight:ApplyCollisionAvoidance()
    local shipPos = self.shipCore:GetPos()
    local avoidanceDistance = HYPERDRIVE.Flight.Config.AvoidanceDistance
    
    -- Scan for obstacles
    local obstacles = ents.FindInSphere(shipPos, avoidanceDistance)
    local avoidanceVector = Vector(0, 0, 0)
    
    for _, obstacle in ipairs(obstacles) do
        if IsValid(obstacle) and obstacle ~= self.shipCore then
            -- Check if it's part of our ship
            local isOurShip = false
            if self.ship and self.ship.entities then
                for _, entity in ipairs(self.ship.entities) do
                    if entity == obstacle then
                        isOurShip = true
                        break
                    end
                end
            end
            
            if not isOurShip then
                local obstaclePos = obstacle:GetPos()
                local direction = shipPos - obstaclePos
                local distance = direction:Length()
                
                if distance > 0 and distance < avoidanceDistance then
                    local avoidanceStrength = (avoidanceDistance - distance) / avoidanceDistance
                    avoidanceVector = avoidanceVector + direction:GetNormalized() * avoidanceStrength
                end
            end
        end
    end
    
    -- Apply avoidance to thrust
    if avoidanceVector:Length() > 0 then
        self.thrust = self.thrust + avoidanceVector * 0.5
    end
end

function ShipFlight:UpdateFormation(deltaTime)
    if not self.formationLeader or not IsValid(self.formationLeader) then return end
    
    local leaderPos = self.formationLeader:GetPos()
    local targetPos = leaderPos + self.formationPosition
    
    -- Set formation position as destination
    self.destination = targetPos
    
    -- Use autopilot to maintain formation
    self:UpdateAutopilot(deltaTime)
end

function ShipFlight:UpdateStabilization(deltaTime)
    -- Reduce unwanted rotation
    self.angularVelocity = self.angularVelocity * 0.9
    
    -- Reduce drift
    if self.thrust:Length() < 0.1 then
        self.velocity = self.velocity * 0.98
    end
end

function ShipFlight:UpdateEnergyConsumption(deltaTime)
    local currentTime = CurTime()
    if currentTime - self.lastEnergyUpdate < 1.0 then return end
    
    local energyCost = HYPERDRIVE.Flight.Config.IdleEnergyCost
    
    -- Add thrust energy cost
    energyCost = energyCost + (self.thrust:Length() * HYPERDRIVE.Flight.Config.ThrustEnergyCost)
    
    -- Add rotation energy cost
    energyCost = energyCost + (self.rotation:Length() * HYPERDRIVE.Flight.Config.RotationEnergyCost)
    
    -- Consume energy from ship
    if HYPERDRIVE.SB3Resources then
        HYPERDRIVE.SB3Resources.ConsumeResource(self.shipCore, "energy", energyCost)
    end
    
    self.energyConsumption = energyCost
    self.stats.energyConsumed = self.stats.energyConsumed + energyCost
    self.lastEnergyUpdate = currentTime
end

function ShipFlight:UpdateStatistics(deltaTime)
    -- Update flight time
    self.stats.flightTime = self.stats.flightTime + deltaTime
    
    -- Update distance traveled
    local distanceThisFrame = self.velocity:Length() * deltaTime
    self.stats.distanceTraveled = self.stats.distanceTraveled + distanceThisFrame
end

function ShipFlight:SetThrust(thrustVector)
    self.thrust = thrustVector
end

function ShipFlight:SetRotation(rotationAngle)
    self.rotation = rotationAngle
end

function ShipFlight:AddWaypoint(position)
    if #self.waypoints >= HYPERDRIVE.Flight.Config.MaxWaypoints then
        return false, "Maximum waypoints reached"
    end
    
    table.insert(self.waypoints, position)
    print("[Flight System] Added waypoint: " .. tostring(position))
    return true
end

function ShipFlight:ClearWaypoints()
    self.waypoints = {}
    self.currentWaypoint = 1
    self.destination = nil
    print("[Flight System] Cleared all waypoints")
end

function ShipFlight:ReachWaypoint()
    self.stats.waypointsReached = self.stats.waypointsReached + 1
    print("[Flight System] Reached waypoint " .. self.currentWaypoint)
    
    self.currentWaypoint = self.currentWaypoint + 1
    if self.currentWaypoint > #self.waypoints then
        -- All waypoints reached
        self.currentWaypoint = 1
        self.destination = nil
        self.autopilotActive = false
        print("[Flight System] All waypoints reached - autopilot disabled")
    else
        self.destination = self.waypoints[self.currentWaypoint]
    end
end

function ShipFlight:SetFlightMode(mode)
    local modeConfig = HYPERDRIVE.Flight.Config.FlightModes[mode]
    if not modeConfig then return false, "Invalid flight mode" end
    
    self.flightMode = mode
    self.autopilotActive = modeConfig.autopilot
    self.stabilizationActive = modeConfig.stabilization
    
    print("[Flight System] Flight mode set to: " .. modeConfig.name)
    return true
end

function ShipFlight:AngleDifference(target, current)
    local diff = Angle(
        math.NormalizeAngle(target.p - current.p),
        math.NormalizeAngle(target.y - current.y),
        math.NormalizeAngle(target.r - current.r)
    )
    return diff
end

function ShipFlight:GetStatus()
    return {
        active = self.active,
        flightMode = self.flightMode,
        velocity = self.velocity:Length(),
        maxSpeed = HYPERDRIVE.Flight.Config.MaxSpeed,
        thrust = self.thrust:Length(),
        autopilot = self.autopilotActive,
        waypoints = #self.waypoints,
        currentWaypoint = self.currentWaypoint,
        energyConsumption = self.energyConsumption,
        mass = self.mass,
        stats = table.Copy(self.stats)
    }
end

-- Main flight system functions
function HYPERDRIVE.Flight.CreateFlightSystem(shipCore)
    if not IsValid(shipCore) then return nil end
    
    local coreId = shipCore:EntIndex()
    local flight = ShipFlight:New(shipCore)
    flight:Initialize()
    
    HYPERDRIVE.Flight.Ships[coreId] = flight
    
    print("[Flight System] Created flight system for ship core " .. coreId)
    return flight
end

function HYPERDRIVE.Flight.GetFlightSystem(shipCore)
    if not IsValid(shipCore) then return nil end
    
    local coreId = shipCore:EntIndex()
    return HYPERDRIVE.Flight.Ships[coreId]
end

function HYPERDRIVE.Flight.RemoveFlightSystem(shipCore)
    if not IsValid(shipCore) then return end
    
    local coreId = shipCore:EntIndex()
    HYPERDRIVE.Flight.Ships[coreId] = nil
    print("[Flight System] Removed flight system for ship core " .. coreId)
end

-- Think function for flight system
timer.Create("HyperdriveFlightSystemThink", 0.05, 0, function() -- 20 FPS
    local deltaTime = 0.05
    
    for coreId, flight in pairs(HYPERDRIVE.Flight.Ships) do
        if IsValid(flight.shipCore) then
            flight:Update(deltaTime)
        else
            HYPERDRIVE.Flight.Ships[coreId] = nil
        end
    end
end)

print("[Hyperdrive Flight] Ship Flight System loaded successfully!")
