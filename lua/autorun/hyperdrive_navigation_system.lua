-- Enhanced Hyperdrive Navigation System v2.2.1
-- Advanced navigation, waypoints, and formation flying

print("[Hyperdrive Flight] Navigation System v2.2.1 - Initializing...")

-- Initialize navigation namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Navigation = HYPERDRIVE.Navigation or {}

-- Navigation system configuration
HYPERDRIVE.Navigation.Config = {
    -- Waypoint System
    MaxWaypoints = 50,
    WaypointRadius = 100,
    WaypointTimeout = 300, -- 5 minutes
    GlobalWaypoints = true,
    
    -- Formation Flying
    FormationTypes = {
        line = {
            name = "Line Formation",
            positions = {
                Vector(0, -200, 0),
                Vector(0, -400, 0),
                Vector(0, -600, 0),
                Vector(0, -800, 0)
            }
        },
        wedge = {
            name = "Wedge Formation",
            positions = {
                Vector(-200, -200, 0),
                Vector(200, -200, 0),
                Vector(-400, -400, 0),
                Vector(400, -400, 0)
            }
        },
        diamond = {
            name = "Diamond Formation",
            positions = {
                Vector(0, -300, 0),
                Vector(-200, -150, 0),
                Vector(200, -150, 0),
                Vector(0, 0, 0)
            }
        },
        box = {
            name = "Box Formation",
            positions = {
                Vector(-200, -200, 0),
                Vector(200, -200, 0),
                Vector(-200, -200, 100),
                Vector(200, -200, 100)
            }
        }
    },
    
    -- Navigation Aids
    BeaconRange = 5000,
    JumpGateRange = 1000,
    HyperspaceRoutes = true,
    
    -- Collision Avoidance
    AvoidanceRange = 800,
    AvoidanceStrength = 2.0,
    PredictionTime = 3.0 -- Seconds ahead to predict
}

-- Navigation registry
HYPERDRIVE.Navigation.Waypoints = {} -- Global waypoints
HYPERDRIVE.Navigation.Formations = {} -- Active formations
HYPERDRIVE.Navigation.Beacons = {} -- Navigation beacons
HYPERDRIVE.Navigation.Routes = {} -- Hyperspace routes

-- Waypoint class
local Waypoint = {}
Waypoint.__index = Waypoint

function Waypoint:New(position, name, type)
    local waypoint = setmetatable({}, Waypoint)
    
    waypoint.position = position
    waypoint.name = name or "Waypoint"
    waypoint.type = type or "standard" -- standard, beacon, jumpgate, station
    waypoint.id = #HYPERDRIVE.Navigation.Waypoints + 1
    waypoint.created = CurTime()
    waypoint.owner = nil
    waypoint.public = true
    waypoint.radius = HYPERDRIVE.Navigation.Config.WaypointRadius
    
    return waypoint
end

function Waypoint:IsInRange(position, range)
    range = range or self.radius
    return self.position:Distance(position) <= range
end

function Waypoint:GetInfo()
    return {
        id = self.id,
        position = self.position,
        name = self.name,
        type = self.type,
        created = self.created,
        owner = self.owner,
        public = self.public,
        radius = self.radius
    }
end

-- Formation class
local Formation = {}
Formation.__index = Formation

function Formation:New(leader, formationType)
    local formation = setmetatable({}, Formation)
    
    formation.leader = leader
    formation.type = formationType or "line"
    formation.ships = {leader}
    formation.positions = {}
    formation.active = true
    formation.spacing = 1.0
    formation.id = #HYPERDRIVE.Navigation.Formations + 1
    
    formation:UpdatePositions()
    
    return formation
end

function Formation:AddShip(ship)
    if #self.ships >= #HYPERDRIVE.Navigation.Config.FormationTypes[self.type].positions + 1 then
        return false, "Formation full"
    end
    
    table.insert(self.ships, ship)
    self:UpdatePositions()
    
    print("[Navigation] Ship added to formation " .. self.id)
    return true
end

function Formation:RemoveShip(ship)
    for i, formationShip in ipairs(self.ships) do
        if formationShip == ship then
            table.remove(self.ships, i)
            self:UpdatePositions()
            print("[Navigation] Ship removed from formation " .. self.id)
            return true
        end
    end
    return false
end

function Formation:UpdatePositions()
    local formationConfig = HYPERDRIVE.Navigation.Config.FormationTypes[self.type]
    if not formationConfig then return end
    
    self.positions = {}
    
    for i, ship in ipairs(self.ships) do
        if i == 1 then
            -- Leader stays at origin
            self.positions[ship] = Vector(0, 0, 0)
        else
            -- Assign formation position
            local posIndex = i - 1
            if posIndex <= #formationConfig.positions then
                self.positions[ship] = formationConfig.positions[posIndex] * self.spacing
            end
        end
    end
end

function Formation:GetFormationPosition(ship)
    return self.positions[ship] or Vector(0, 0, 0)
end

function Formation:SetSpacing(spacing)
    self.spacing = spacing
    self:UpdatePositions()
end

function Formation:GetStatus()
    return {
        id = self.id,
        leader = self.leader,
        type = self.type,
        shipCount = #self.ships,
        spacing = self.spacing,
        active = self.active
    }
end

-- Navigation beacon class
local NavigationBeacon = {}
NavigationBeacon.__index = NavigationBeacon

function NavigationBeacon:New(position, name, frequency)
    local beacon = setmetatable({}, NavigationBeacon)
    
    beacon.position = position
    beacon.name = name or "Nav Beacon"
    beacon.frequency = frequency or 1.0
    beacon.range = HYPERDRIVE.Navigation.Config.BeaconRange
    beacon.active = true
    beacon.id = #HYPERDRIVE.Navigation.Beacons + 1
    beacon.lastPing = 0
    
    return beacon
end

function NavigationBeacon:Update()
    if not self.active then return end
    
    local currentTime = CurTime()
    if currentTime - self.lastPing >= self.frequency then
        self:SendPing()
        self.lastPing = currentTime
    end
end

function NavigationBeacon:SendPing()
    -- Find ships in range
    local shipsInRange = {}
    
    for _, flight in pairs(HYPERDRIVE.Flight.Ships) do
        if IsValid(flight.shipCore) then
            local distance = self.position:Distance(flight.shipCore:GetPos())
            if distance <= self.range then
                table.insert(shipsInRange, flight)
            end
        end
    end
    
    -- Send navigation data to ships
    for _, flight in ipairs(shipsInRange) do
        self:SendNavigationData(flight)
    end
end

function NavigationBeacon:SendNavigationData(flight)
    -- This would send navigation data to the ship's navigation system
    -- Implementation depends on how navigation data is handled
    print("[Navigation] Beacon " .. self.name .. " ping to ship " .. flight.shipCore:EntIndex())
end

-- Main navigation functions
function HYPERDRIVE.Navigation.CreateWaypoint(position, name, type, owner)
    local waypoint = Waypoint:New(position, name, type)
    waypoint.owner = owner
    
    table.insert(HYPERDRIVE.Navigation.Waypoints, waypoint)
    
    print("[Navigation] Created waypoint: " .. waypoint.name .. " at " .. tostring(position))
    return waypoint
end

function HYPERDRIVE.Navigation.RemoveWaypoint(waypointId)
    for i, waypoint in ipairs(HYPERDRIVE.Navigation.Waypoints) do
        if waypoint.id == waypointId then
            table.remove(HYPERDRIVE.Navigation.Waypoints, i)
            print("[Navigation] Removed waypoint: " .. waypoint.name)
            return true
        end
    end
    return false
end

function HYPERDRIVE.Navigation.GetNearbyWaypoints(position, range)
    local nearby = {}
    
    for _, waypoint in ipairs(HYPERDRIVE.Navigation.Waypoints) do
        if waypoint:IsInRange(position, range) then
            table.insert(nearby, waypoint)
        end
    end
    
    return nearby
end

function HYPERDRIVE.Navigation.FindWaypointByName(name)
    for _, waypoint in ipairs(HYPERDRIVE.Navigation.Waypoints) do
        if waypoint.name == name then
            return waypoint
        end
    end
    return nil
end

function HYPERDRIVE.Navigation.CreateFormation(leader, formationType)
    local formation = Formation:New(leader, formationType)
    table.insert(HYPERDRIVE.Navigation.Formations, formation)
    
    print("[Navigation] Created formation: " .. formationType .. " with leader " .. leader:EntIndex())
    return formation
end

function HYPERDRIVE.Navigation.JoinFormation(ship, formationId)
    local formation = HYPERDRIVE.Navigation.Formations[formationId]
    if not formation then return false, "Formation not found" end
    
    local success, reason = formation:AddShip(ship)
    if success then
        -- Set ship to formation mode
        local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
        if flight then
            flight:SetFlightMode("formation")
            flight.formation = formation
            flight.formationLeader = formation.leader
        end
    end
    
    return success, reason
end

function HYPERDRIVE.Navigation.LeaveFormation(ship)
    for _, formation in ipairs(HYPERDRIVE.Navigation.Formations) do
        if formation:RemoveShip(ship) then
            -- Remove ship from formation mode
            local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
            if flight then
                flight:SetFlightMode("manual")
                flight.formation = nil
                flight.formationLeader = nil
            end
            return true
        end
    end
    return false
end

function HYPERDRIVE.Navigation.CreateBeacon(position, name, frequency)
    local beacon = NavigationBeacon:New(position, name, frequency)
    table.insert(HYPERDRIVE.Navigation.Beacons, beacon)
    
    print("[Navigation] Created beacon: " .. beacon.name .. " at " .. tostring(position))
    return beacon
end

function HYPERDRIVE.Navigation.CalculateRoute(startPos, endPos, avoidObstacles)
    -- Simple pathfinding - can be enhanced with A* or other algorithms
    local route = {startPos}
    
    if avoidObstacles then
        -- Check for obstacles between start and end
        local direction = (endPos - startPos):GetNormalized()
        local distance = startPos:Distance(endPos)
        local stepSize = 500
        
        for i = stepSize, distance, stepSize do
            local checkPos = startPos + direction * i
            
            -- Check for obstacles
            local obstacles = ents.FindInSphere(checkPos, HYPERDRIVE.Navigation.Config.AvoidanceRange)
            local hasObstacle = false
            
            for _, obstacle in ipairs(obstacles) do
                if IsValid(obstacle) and not string.find(obstacle:GetClass(), "hyperdrive_") then
                    hasObstacle = true
                    break
                end
            end
            
            if hasObstacle then
                -- Add avoidance waypoint
                local avoidPos = checkPos + VectorRand() * HYPERDRIVE.Navigation.Config.AvoidanceRange
                table.insert(route, avoidPos)
            end
            
            table.insert(route, checkPos)
        end
    end
    
    table.insert(route, endPos)
    return route
end

function HYPERDRIVE.Navigation.GetNavigationData(position)
    local data = {
        waypoints = HYPERDRIVE.Navigation.GetNearbyWaypoints(position, 2000),
        beacons = {},
        formations = {},
        routes = {}
    }
    
    -- Get nearby beacons
    for _, beacon in ipairs(HYPERDRIVE.Navigation.Beacons) do
        if beacon.active and beacon.position:Distance(position) <= beacon.range then
            table.insert(data.beacons, beacon)
        end
    end
    
    -- Get formation data
    for _, formation in ipairs(HYPERDRIVE.Navigation.Formations) do
        if formation.active then
            table.insert(data.formations, formation:GetStatus())
        end
    end
    
    return data
end

-- Advanced collision avoidance
function HYPERDRIVE.Navigation.CalculateCollisionAvoidance(ship, velocity, deltaTime)
    local shipPos = ship:GetPos()
    local avoidanceVector = Vector(0, 0, 0)
    local predictionTime = HYPERDRIVE.Navigation.Config.PredictionTime
    
    -- Predict future position
    local futurePos = shipPos + velocity * predictionTime
    
    -- Check for potential collisions
    local nearbyObjects = ents.FindInSphere(futurePos, HYPERDRIVE.Navigation.Config.AvoidanceRange)
    
    for _, object in ipairs(nearbyObjects) do
        if IsValid(object) and object ~= ship then
            local objectPos = object:GetPos()
            local objectVel = Vector(0, 0, 0)
            
            -- Get object velocity if available
            if object:GetPhysicsObject() and IsValid(object:GetPhysicsObject()) then
                objectVel = object:GetPhysicsObject():GetVelocity()
            end
            
            -- Predict object future position
            local objectFuturePos = objectPos + objectVel * predictionTime
            
            -- Check if collision is likely
            local distance = futurePos:Distance(objectFuturePos)
            if distance < HYPERDRIVE.Navigation.Config.AvoidanceRange then
                -- Calculate avoidance vector
                local avoidDirection = (shipPos - objectPos):GetNormalized()
                local avoidStrength = (HYPERDRIVE.Navigation.Config.AvoidanceRange - distance) / HYPERDRIVE.Navigation.Config.AvoidanceRange
                avoidanceVector = avoidanceVector + avoidDirection * avoidStrength * HYPERDRIVE.Navigation.Config.AvoidanceStrength
            end
        end
    end
    
    return avoidanceVector
end

-- Think function for navigation system
timer.Create("HyperdriveNavigationThink", 1, 0, function()
    -- Update beacons
    for _, beacon in ipairs(HYPERDRIVE.Navigation.Beacons) do
        beacon:Update()
    end
    
    -- Clean up old waypoints
    local currentTime = CurTime()
    for i = #HYPERDRIVE.Navigation.Waypoints, 1, -1 do
        local waypoint = HYPERDRIVE.Navigation.Waypoints[i]
        if currentTime - waypoint.created > HYPERDRIVE.Navigation.Config.WaypointTimeout then
            table.remove(HYPERDRIVE.Navigation.Waypoints, i)
        end
    end
    
    -- Update formations
    for i = #HYPERDRIVE.Navigation.Formations, 1, -1 do
        local formation = HYPERDRIVE.Navigation.Formations[i]
        if not IsValid(formation.leader) or #formation.ships <= 1 then
            table.remove(HYPERDRIVE.Navigation.Formations, i)
        end
    end
end)

print("[Hyperdrive Flight] Navigation System loaded successfully!")
