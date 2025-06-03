-- Enhanced Hyperdrive Docking Pad System v5.1.0
-- Advanced ship docking pads, shuttle operations, and automated landing
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Hyperdrive Docking] Docking Pad System v5.1.0 - Ultimate Edition Initializing...")

-- Initialize docking pad namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.DockingPad = HYPERDRIVE.DockingPad or {}

-- Docking pad system configuration
HYPERDRIVE.DockingPad.Config = {
    -- Docking Parameters
    LandingRange = 300, -- Maximum landing distance
    LandingSpeed = 100, -- Maximum approach speed
    LandingAccuracy = 50, -- Position accuracy required
    LandingTimeout = 45, -- Landing timeout in seconds
    
    -- Pad Types
    PadTypes = {
        small = {
            name = "Small Landing Pad",
            maxShipSize = 800, -- Maximum ship mass
            landingRadius = 150, -- Landing area radius
            energyCost = 5, -- Energy per second while docked
            services = {"refuel", "repair"},
            capacity = 1
        },
        medium = {
            name = "Medium Landing Pad",
            maxShipSize = 2500,
            landingRadius = 250,
            energyCost = 15,
            services = {"refuel", "repair", "resupply"},
            capacity = 1
        },
        large = {
            name = "Large Landing Pad",
            maxShipSize = 6000,
            landingRadius = 400,
            energyCost = 30,
            services = {"refuel", "repair", "resupply", "upgrade"},
            capacity = 1
        },
        shuttle = {
            name = "Shuttle Landing Pad",
            maxShipSize = 500,
            landingRadius = 100,
            energyCost = 3,
            services = {"refuel", "passenger_transfer"},
            capacity = 2
        },
        cargo = {
            name = "Cargo Landing Pad",
            maxShipSize = 3000,
            landingRadius = 300,
            energyCost = 20,
            services = {"refuel", "cargo_transfer", "resupply"},
            capacity = 1
        }
    },
    
    -- Landing Services
    Services = {
        refuel = {
            name = "Refueling",
            rate = 150, -- Energy per second
            cost = 1 -- Cost per energy unit
        },
        repair = {
            name = "Repair",
            rate = 75, -- Health per second
            cost = 3 -- Cost per health unit
        },
        resupply = {
            name = "Resupply",
            rate = 15, -- Ammo per second
            cost = 8 -- Cost per ammo unit
        },
        passenger_transfer = {
            name = "Passenger Transfer",
            rate = 2, -- Passengers per second
            cost = 5 -- Cost per passenger
        },
        cargo_transfer = {
            name = "Cargo Transfer",
            rate = 50, -- Cargo units per second
            cost = 2 -- Cost per cargo unit
        }
    },
    
    -- Landing Guidance
    GuidanceBeacons = true,
    AutoLanding = true,
    TrafficControl = true,
    WeatherEffects = false,
    
    -- Safety Systems
    CollisionAvoidance = true,
    EmergencyLanding = true,
    LandingLights = true,
    ForceFields = false
}

-- Docking pad registry
HYPERDRIVE.DockingPad.LandingPads = {} -- Active landing pads
HYPERDRIVE.DockingPad.LandedShips = {} -- Currently landed ships
HYPERDRIVE.DockingPad.LandingQueue = {} -- Ships waiting to land
HYPERDRIVE.DockingPad.TrafficControl = {} -- Traffic control systems

-- Landing pad class
local LandingPad = {}
LandingPad.__index = LandingPad

function LandingPad:New(entity, padType)
    local pad = setmetatable({}, LandingPad)
    
    pad.entity = entity
    pad.padType = padType or "medium"
    pad.config = HYPERDRIVE.DockingPad.Config.PadTypes[padType]
    pad.active = true
    pad.occupied = false
    pad.landedShip = nil
    pad.landingQueue = {}
    pad.services = {}
    pad.energyConsumption = 0
    pad.lastUpdate = 0
    
    -- Landing guidance
    pad.guidanceBeacon = true
    pad.landingLights = true
    pad.trafficControl = true
    
    -- Landing position (center of pad)
    pad.landingPosition = entity:GetPos() + Vector(0, 0, 50)
    pad.landingAngles = entity:GetAngles()
    
    -- Initialize services
    for _, service in ipairs(pad.config.services) do
        pad.services[service] = {
            active = true,
            queue = {},
            processing = nil
        }
    end
    
    return pad
end

function LandingPad:CanLand(ship)
    -- Check if pad is active
    if not self.active then
        return false, "Landing pad offline"
    end
    
    -- Check if pad is occupied
    if self.occupied then
        return false, "Landing pad occupied"
    end
    
    -- Check ship size
    local shipMass = self:GetShipMass(ship)
    if shipMass > self.config.maxShipSize then
        return false, "Ship too large for landing pad"
    end
    
    -- Check distance
    local distance = self.entity:GetPos():Distance(ship:GetPos())
    if distance > HYPERDRIVE.DockingPad.Config.LandingRange then
        return false, "Ship too far from landing pad"
    end
    
    return true
end

function LandingPad:GetShipMass(ship)
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        return flight.mass
    end
    return 1000 -- Default mass
end

function LandingPad:RequestLanding(ship)
    local canLand, reason = self:CanLand(ship)
    if not canLand then
        return false, reason
    end
    
    -- Add to landing queue
    local landingRequest = {
        ship = ship,
        requestTime = CurTime(),
        priority = 1, -- Normal priority
        status = "queued"
    }
    
    table.insert(self.landingQueue, landingRequest)
    
    print("[Docking Pad] Ship " .. ship:EntIndex() .. " requested landing at pad " .. self.entity:EntIndex())
    return true, "Landing request accepted"
end

function LandingPad:ProcessLandingQueue()
    if #self.landingQueue == 0 or self.occupied then return end
    
    -- Sort queue by priority and time
    table.sort(self.landingQueue, function(a, b)
        if a.priority == b.priority then
            return a.requestTime < b.requestTime
        end
        return a.priority > b.priority
    end)
    
    -- Process next ship in queue
    local request = self.landingQueue[1]
    if IsValid(request.ship) then
        local success = self:InitiateLanding(request.ship)
        if success then
            table.remove(self.landingQueue, 1)
        end
    else
        table.remove(self.landingQueue, 1)
    end
end

function LandingPad:InitiateLanding(ship)
    if self.occupied then
        return false, "Landing pad occupied"
    end
    
    -- Start automated landing procedure
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        flight:ClearWaypoints()
        flight:AddWaypoint(self.landingPosition)
        flight:SetFlightMode("autopilot")
        flight.autopilotActive = true
        
        -- Create landing procedure
        self:StartLandingProcedure(ship)
        
        print("[Docking Pad] Initiated landing for ship " .. ship:EntIndex())
        return true
    end
    
    return false, "Ship flight system not available"
end

function LandingPad:StartLandingProcedure(ship)
    local procedure = {
        ship = ship,
        phase = "approach", -- approach, descent, touchdown, complete
        startTime = CurTime(),
        timeout = HYPERDRIVE.DockingPad.Config.LandingTimeout,
        approachAltitude = 200,
        descentRate = 50
    }
    
    -- Monitor landing procedure
    timer.Create("LandingProcedure_" .. ship:EntIndex(), 0.2, 0, function()
        if not IsValid(ship) or not IsValid(self.entity) then
            timer.Remove("LandingProcedure_" .. ship:EntIndex())
            return
        end
        
        self:UpdateLandingProcedure(procedure)
    end)
end

function LandingPad:UpdateLandingProcedure(procedure)
    local ship = procedure.ship
    local shipPos = ship:GetPos()
    local targetPos = self.landingPosition
    local horizontalDistance = Vector(shipPos.x - targetPos.x, shipPos.y - targetPos.y, 0):Length()
    local verticalDistance = shipPos.z - targetPos.z
    
    -- Check timeout
    if CurTime() - procedure.startTime > procedure.timeout then
        self:AbortLanding(procedure, "Landing timeout")
        return
    end
    
    if procedure.phase == "approach" then
        -- Check if ship is in approach position
        if horizontalDistance < self.config.landingRadius and verticalDistance > procedure.approachAltitude then
            procedure.phase = "descent"
            print("[Docking Pad] Ship " .. ship:EntIndex() .. " beginning descent")
            
            -- Update flight system for descent
            local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
            if flight then
                flight:ClearWaypoints()
                flight:AddWaypoint(targetPos)
            end
        end
        
    elseif procedure.phase == "descent" then
        -- Check descent progress
        if verticalDistance < 100 and horizontalDistance < HYPERDRIVE.DockingPad.Config.LandingAccuracy then
            procedure.phase = "touchdown"
            print("[Docking Pad] Ship " .. ship:EntIndex() .. " touching down")
        end
        
    elseif procedure.phase == "touchdown" then
        -- Check if landed
        if verticalDistance < 20 and horizontalDistance < HYPERDRIVE.DockingPad.Config.LandingAccuracy then
            self:CompleteLanding(procedure)
        end
    end
end

function LandingPad:CompleteLanding(procedure)
    local ship = procedure.ship
    
    -- Stop ship movement
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        flight.autopilotActive = false
        flight:SetFlightMode("manual")
        flight:SetThrust(Vector(0, 0, 0))
        flight:SetRotation(Angle(0, 0, 0))
    end
    
    -- Position ship precisely on pad
    ship:SetPos(self.landingPosition)
    ship:SetAngles(self.landingAngles)
    
    -- Mark pad as occupied
    self.occupied = true
    self.landedShip = ship
    
    -- Clean up landing procedure
    timer.Remove("LandingProcedure_" .. ship:EntIndex())
    
    print("[Docking Pad] Ship " .. ship:EntIndex() .. " successfully landed")
    
    -- Start automatic services
    self:StartAutomaticServices(ship)
end

function LandingPad:AbortLanding(procedure, reason)
    local ship = procedure.ship
    
    -- Stop ship autopilot
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        flight.autopilotActive = false
        flight:ClearWaypoints()
    end
    
    -- Clean up
    timer.Remove("LandingProcedure_" .. ship:EntIndex())
    
    print("[Docking Pad] Landing aborted for ship " .. ship:EntIndex() .. ": " .. reason)
end

function LandingPad:StartAutomaticServices(ship)
    -- Start refueling
    if self.services.refuel and self.services.refuel.active then
        self:StartService(ship, "refuel")
    end
    
    -- Start repair if needed
    if self.services.repair and self.services.repair.active then
        if ship:Health() < ship:GetMaxHealth() then
            self:StartService(ship, "repair")
        end
    end
    
    -- Start resupply
    if self.services.resupply and self.services.resupply.active then
        self:StartService(ship, "resupply")
    end
end

function LandingPad:StartService(ship, serviceType)
    local service = self.services[serviceType]
    if not service or not service.active then return false end
    
    local serviceConfig = HYPERDRIVE.DockingPad.Config.Services[serviceType]
    if not serviceConfig then return false end
    
    -- Add to service queue
    table.insert(service.queue, {
        ship = ship,
        startTime = CurTime(),
        progress = 0,
        completed = false
    })
    
    print("[Docking Pad] Started " .. serviceConfig.name .. " for ship " .. ship:EntIndex())
    return true
end

function LandingPad:UpdateServices()
    for serviceType, service in pairs(self.services) do
        if service.active and #service.queue > 0 then
            self:ProcessService(serviceType, service)
        end
    end
end

function LandingPad:ProcessService(serviceType, service)
    local serviceConfig = HYPERDRIVE.DockingPad.Config.Services[serviceType]
    if not serviceConfig then return end
    
    -- Process first ship in queue
    local serviceRequest = service.queue[1]
    if not serviceRequest or not IsValid(serviceRequest.ship) then
        table.remove(service.queue, 1)
        return
    end
    
    local ship = serviceRequest.ship
    
    if serviceType == "refuel" then
        self:ProcessRefueling(ship, serviceRequest, serviceConfig)
    elseif serviceType == "repair" then
        self:ProcessRepair(ship, serviceRequest, serviceConfig)
    elseif serviceType == "resupply" then
        self:ProcessResupply(ship, serviceRequest, serviceConfig)
    end
    
    -- Remove completed services
    if serviceRequest.completed then
        table.remove(service.queue, 1)
        print("[Docking Pad] Completed " .. serviceConfig.name .. " for ship " .. ship:EntIndex())
    end
end

function LandingPad:ProcessRefueling(ship, request, config)
    if HYPERDRIVE.SB3Resources then
        local currentEnergy = HYPERDRIVE.SB3Resources.GetResource(ship, "energy")
        local maxEnergy = HYPERDRIVE.SB3Resources.GetMaxResource(ship, "energy")
        
        if currentEnergy < maxEnergy then
            local refuelAmount = config.rate * 0.2 -- Per update
            HYPERDRIVE.SB3Resources.AddResource(ship, "energy", refuelAmount)
        else
            request.completed = true
        end
    else
        request.completed = true
    end
end

function LandingPad:ProcessRepair(ship, request, config)
    local currentHealth = ship:Health()
    local maxHealth = ship:GetMaxHealth()
    
    if currentHealth < maxHealth then
        local repairAmount = config.rate * 0.2 -- Per update
        ship:SetHealth(math.min(maxHealth, currentHealth + repairAmount))
    else
        request.completed = true
    end
end

function LandingPad:ProcessResupply(ship, request, config)
    if HYPERDRIVE.Ammunition then
        local storage = HYPERDRIVE.Ammunition.GetStorage(ship)
        if storage then
            -- Resupply all ammunition types
            for ammoType, ammoConfig in pairs(HYPERDRIVE.Ammunition.Config.AmmoTypes) do
                local currentAmmo = storage:GetAmmo(ammoType)
                local maxAmmo = math.floor(storage.capacity / ammoConfig.weight)
                
                if currentAmmo < maxAmmo then
                    local supplyAmount = config.rate * 0.2
                    storage:AddAmmo(ammoType, supplyAmount)
                end
            end
        end
        request.completed = true
    else
        request.completed = true
    end
end

function LandingPad:LaunchShip(ship)
    if not self.occupied or self.landedShip ~= ship then
        return false, "Ship not landed on this pad"
    end
    
    -- Clear pad
    self.occupied = false
    self.landedShip = nil
    
    -- Move ship to launch position
    local launchPos = self.landingPosition + Vector(0, 0, 300)
    
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        flight:ClearWaypoints()
        flight:AddWaypoint(launchPos)
        flight:SetFlightMode("autopilot")
        flight.autopilotActive = true
    end
    
    print("[Docking Pad] Ship " .. ship:EntIndex() .. " launched")
    return true
end

function LandingPad:Update()
    -- Process landing queue
    self:ProcessLandingQueue()
    
    -- Update services
    self:UpdateServices()
    
    -- Update energy consumption
    if self.occupied then
        self.energyConsumption = self.config.energyCost
        
        -- Consume energy
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.ConsumeResource(self.entity, "energy", self.energyConsumption * 0.2)
        end
    else
        self.energyConsumption = 0
    end
end

function LandingPad:GetStatus()
    return {
        active = self.active,
        padType = self.padType,
        occupied = self.occupied,
        landedShip = self.landedShip,
        queueLength = #self.landingQueue,
        energyConsumption = self.energyConsumption,
        services = self.services,
        landingRadius = self.config.landingRadius
    }
end

-- Main docking pad functions
function HYPERDRIVE.DockingPad.CreateLandingPad(entity, padType)
    if not IsValid(entity) then return nil end
    
    local padId = entity:EntIndex()
    local pad = LandingPad:New(entity, padType)
    HYPERDRIVE.DockingPad.LandingPads[padId] = pad
    
    print("[Docking Pad] Created landing pad: " .. pad.config.name .. " (ID: " .. padId .. ")")
    return pad
end

function HYPERDRIVE.DockingPad.GetLandingPad(entity)
    if not IsValid(entity) then return nil end
    
    local padId = entity:EntIndex()
    return HYPERDRIVE.DockingPad.LandingPads[padId]
end

function HYPERDRIVE.DockingPad.RemoveLandingPad(entity)
    if not IsValid(entity) then return end
    
    local padId = entity:EntIndex()
    HYPERDRIVE.DockingPad.LandingPads[padId] = nil
    print("[Docking Pad] Removed landing pad ID: " .. padId)
end

function HYPERDRIVE.DockingPad.RequestLanding(ship, landingPad)
    local pad = HYPERDRIVE.DockingPad.GetLandingPad(landingPad)
    if not pad then return false, "Landing pad not found" end
    
    return pad:RequestLanding(ship)
end

function HYPERDRIVE.DockingPad.FindNearestLandingPad(ship, padType)
    local shipPos = ship:GetPos()
    local nearestPad = nil
    local nearestDistance = math.huge
    
    for padId, pad in pairs(HYPERDRIVE.DockingPad.LandingPads) do
        if not padType or pad.padType == padType then
            local distance = shipPos:Distance(pad.entity:GetPos())
            if distance < nearestDistance then
                local canLand, _ = pad:CanLand(ship)
                if canLand then
                    nearestPad = pad
                    nearestDistance = distance
                end
            end
        end
    end
    
    return nearestPad, nearestDistance
end

-- Think function for docking pad system
timer.Create("HyperdriveDockingPadThink", 0.2, 0, function()
    for padId, pad in pairs(HYPERDRIVE.DockingPad.LandingPads) do
        if IsValid(pad.entity) then
            pad:Update()
        else
            HYPERDRIVE.DockingPad.LandingPads[padId] = nil
        end
    end
end)

print("[Hyperdrive Docking] Docking Pad System loaded successfully!")
