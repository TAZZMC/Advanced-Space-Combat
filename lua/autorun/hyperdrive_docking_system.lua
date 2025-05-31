-- Enhanced Hyperdrive Docking System v2.2.1
-- Advanced ship docking, shuttle operations, and cargo transfer

print("[Hyperdrive Docking] Docking System v2.2.1 - Initializing...")

-- Initialize docking namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Docking = HYPERDRIVE.Docking or {}

-- Docking system configuration
HYPERDRIVE.Docking.Config = {
    -- Docking Parameters
    DockingRange = 200, -- Maximum docking distance
    DockingSpeed = 50, -- Maximum approach speed
    DockingAccuracy = 25, -- Position accuracy required
    DockingTimeout = 60, -- Docking timeout in seconds
    
    -- Docking Bay Types
    BayTypes = {
        small = {
            name = "Small Docking Bay",
            maxShipSize = 500, -- Maximum ship mass
            capacity = 1, -- Number of ships
            energyCost = 10, -- Energy per second while docked
            services = {"refuel", "repair", "resupply"}
        },
        medium = {
            name = "Medium Docking Bay",
            maxShipSize = 2000,
            capacity = 2,
            energyCost = 25,
            services = {"refuel", "repair", "resupply", "upgrade"}
        },
        large = {
            name = "Large Docking Bay",
            maxShipSize = 5000,
            capacity = 4,
            energyCost = 50,
            services = {"refuel", "repair", "resupply", "upgrade", "manufacturing"}
        },
        shuttle = {
            name = "Shuttle Bay",
            maxShipSize = 200,
            capacity = 6,
            energyCost = 5,
            services = {"refuel", "resupply"}
        }
    },
    
    -- Docking Services
    Services = {
        refuel = {
            name = "Refueling",
            energyRate = 100, -- Energy per second
            cost = 1 -- Cost per energy unit
        },
        repair = {
            name = "Repair",
            repairRate = 50, -- Health per second
            cost = 2 -- Cost per health unit
        },
        resupply = {
            name = "Resupply",
            supplyRate = 10, -- Ammo per second
            cost = 5 -- Cost per ammo unit
        },
        upgrade = {
            name = "Upgrades",
            upgradeTime = 30, -- Seconds per upgrade
            cost = 100 -- Base cost per upgrade
        },
        manufacturing = {
            name = "Manufacturing",
            productionRate = 1, -- Items per minute
            cost = 50 -- Cost per item
        }
    },
    
    -- Shuttle System
    ShuttleTypes = {
        transport = {
            name = "Transport Shuttle",
            capacity = 8, -- Passenger capacity
            cargoSpace = 100, -- Cargo weight
            speed = 800,
            range = 5000,
            energyCost = 15
        },
        cargo = {
            name = "Cargo Shuttle",
            capacity = 2,
            cargoSpace = 500,
            speed = 600,
            range = 3000,
            energyCost = 20
        },
        combat = {
            name = "Combat Shuttle",
            capacity = 4,
            cargoSpace = 50,
            speed = 1200,
            range = 2000,
            energyCost = 30
        }
    },
    
    -- Automated Systems
    AutoDocking = true,
    AutoServices = true,
    TrafficControl = true,
    EmergencyProtocols = true
}

-- Docking system registry
HYPERDRIVE.Docking.DockingBays = {} -- Active docking bays
HYPERDRIVE.Docking.DockedShips = {} -- Currently docked ships
HYPERDRIVE.Docking.DockingQueue = {} -- Ships waiting to dock
HYPERDRIVE.Docking.Shuttles = {} -- Active shuttles
HYPERDRIVE.Docking.TrafficControl = {} -- Traffic control systems

-- Docking bay class
local DockingBay = {}
DockingBay.__index = DockingBay

function DockingBay:New(entity, bayType)
    local bay = setmetatable({}, DockingBay)
    
    bay.entity = entity
    bay.bayType = bayType or "medium"
    bay.config = HYPERDRIVE.Docking.Config.BayTypes[bayType]
    bay.active = true
    bay.occupied = 0
    bay.dockedShips = {}
    bay.dockingQueue = {}
    bay.services = {}
    bay.energyConsumption = 0
    bay.lastUpdate = 0
    
    -- Docking positions
    bay.dockingPositions = {}
    bay:GenerateDockingPositions()
    
    -- Initialize services
    for _, service in ipairs(bay.config.services) do
        bay.services[service] = {
            active = true,
            queue = {},
            processing = nil
        }
    end
    
    return bay
end

function DockingBay:GenerateDockingPositions()
    local bayPos = self.entity:GetPos()
    local bayAngles = self.entity:GetAngles()
    local capacity = self.config.capacity
    
    for i = 1, capacity do
        local offset = Vector(0, (i - 1) * 300 - (capacity - 1) * 150, 100)
        local worldPos = bayPos + bayAngles:Forward() * offset.x + bayAngles:Right() * offset.y + bayAngles:Up() * offset.z
        
        table.insert(self.dockingPositions, {
            position = worldPos,
            angles = bayAngles,
            occupied = false,
            ship = nil,
            slot = i
        })
    end
end

function DockingBay:CanDock(ship)
    -- Check if bay is active
    if not self.active then
        return false, "Docking bay offline"
    end
    
    -- Check capacity
    if self.occupied >= self.config.capacity then
        return false, "Docking bay full"
    end
    
    -- Check ship size
    local shipMass = self:GetShipMass(ship)
    if shipMass > self.config.maxShipSize then
        return false, "Ship too large for docking bay"
    end
    
    -- Check distance
    local distance = self.entity:GetPos():Distance(ship:GetPos())
    if distance > HYPERDRIVE.Docking.Config.DockingRange then
        return false, "Ship too far from docking bay"
    end
    
    return true
end

function DockingBay:GetShipMass(ship)
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        return flight.mass
    end
    return 1000 -- Default mass
end

function DockingBay:RequestDocking(ship)
    local canDock, reason = self:CanDock(ship)
    if not canDock then
        return false, reason
    end
    
    -- Add to docking queue
    local dockingRequest = {
        ship = ship,
        requestTime = CurTime(),
        priority = 1, -- Normal priority
        status = "queued"
    }
    
    table.insert(self.dockingQueue, dockingRequest)
    
    print("[Docking] Ship " .. ship:EntIndex() .. " requested docking at bay " .. self.entity:EntIndex())
    return true, "Docking request accepted"
end

function DockingBay:ProcessDockingQueue()
    if #self.dockingQueue == 0 then return end
    
    -- Sort queue by priority and time
    table.sort(self.dockingQueue, function(a, b)
        if a.priority == b.priority then
            return a.requestTime < b.requestTime
        end
        return a.priority > b.priority
    end)
    
    -- Process next ship in queue
    local request = self.dockingQueue[1]
    if IsValid(request.ship) then
        local success = self:InitiateDocking(request.ship)
        if success then
            table.remove(self.dockingQueue, 1)
        end
    else
        table.remove(self.dockingQueue, 1)
    end
end

function DockingBay:InitiateDocking(ship)
    -- Find available docking position
    local dockingPos = nil
    for _, pos in ipairs(self.dockingPositions) do
        if not pos.occupied then
            dockingPos = pos
            break
        end
    end
    
    if not dockingPos then
        return false, "No available docking positions"
    end
    
    -- Start automated docking procedure
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        flight:ClearWaypoints()
        flight:AddWaypoint(dockingPos.position)
        flight:SetFlightMode("autopilot")
        flight.autopilotActive = true
        
        -- Mark position as occupied
        dockingPos.occupied = true
        dockingPos.ship = ship
        
        -- Create docking procedure
        self:StartDockingProcedure(ship, dockingPos)
        
        print("[Docking] Initiated docking for ship " .. ship:EntIndex())
        return true
    end
    
    return false, "Ship flight system not available"
end

function DockingBay:StartDockingProcedure(ship, dockingPos)
    local procedure = {
        ship = ship,
        dockingPos = dockingPos,
        phase = "approach", -- approach, align, dock, complete
        startTime = CurTime(),
        timeout = HYPERDRIVE.Docking.Config.DockingTimeout
    }
    
    -- Monitor docking procedure
    timer.Create("DockingProcedure_" .. ship:EntIndex(), 0.5, 0, function()
        if not IsValid(ship) or not IsValid(self.entity) then
            timer.Remove("DockingProcedure_" .. ship:EntIndex())
            return
        end
        
        self:UpdateDockingProcedure(procedure)
    end)
end

function DockingBay:UpdateDockingProcedure(procedure)
    local ship = procedure.ship
    local dockingPos = procedure.dockingPos
    local shipPos = ship:GetPos()
    local targetPos = dockingPos.position
    local distance = shipPos:Distance(targetPos)
    
    -- Check timeout
    if CurTime() - procedure.startTime > procedure.timeout then
        self:AbortDocking(procedure, "Docking timeout")
        return
    end
    
    if procedure.phase == "approach" then
        -- Check if ship is close enough
        if distance < HYPERDRIVE.Docking.Config.DockingAccuracy then
            procedure.phase = "align"
            print("[Docking] Ship " .. ship:EntIndex() .. " entering alignment phase")
        end
        
    elseif procedure.phase == "align" then
        -- Check alignment
        local shipAngles = ship:GetAngles()
        local targetAngles = dockingPos.angles
        local angleDiff = math.abs(shipAngles.y - targetAngles.y)
        
        if angleDiff < 5 and distance < HYPERDRIVE.Docking.Config.DockingAccuracy then
            procedure.phase = "dock"
            print("[Docking] Ship " .. ship:EntIndex() .. " entering docking phase")
        end
        
    elseif procedure.phase == "dock" then
        -- Complete docking
        self:CompleteDocking(procedure)
        
    end
end

function DockingBay:CompleteDocking(procedure)
    local ship = procedure.ship
    local dockingPos = procedure.dockingPos
    
    -- Stop ship movement
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        flight.autopilotActive = false
        flight:SetFlightMode("manual")
        flight:SetThrust(Vector(0, 0, 0))
        flight:SetRotation(Angle(0, 0, 0))
    end
    
    -- Position ship precisely
    ship:SetPos(dockingPos.position)
    ship:SetAngles(dockingPos.angles)
    
    -- Add to docked ships
    self.dockedShips[ship] = {
        dockingPos = dockingPos,
        dockTime = CurTime(),
        services = {}
    }
    
    self.occupied = self.occupied + 1
    
    -- Clean up docking procedure
    timer.Remove("DockingProcedure_" .. ship:EntIndex())
    
    print("[Docking] Ship " .. ship:EntIndex() .. " successfully docked")
    
    -- Start automatic services if enabled
    if HYPERDRIVE.Docking.Config.AutoServices then
        self:StartAutomaticServices(ship)
    end
end

function DockingBay:AbortDocking(procedure, reason)
    local ship = procedure.ship
    local dockingPos = procedure.dockingPos
    
    -- Free docking position
    dockingPos.occupied = false
    dockingPos.ship = nil
    
    -- Stop ship autopilot
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        flight.autopilotActive = false
        flight:ClearWaypoints()
    end
    
    -- Clean up
    timer.Remove("DockingProcedure_" .. ship:EntIndex())
    
    print("[Docking] Docking aborted for ship " .. ship:EntIndex() .. ": " .. reason)
end

function DockingBay:StartAutomaticServices(ship)
    local dockedShip = self.dockedShips[ship]
    if not dockedShip then return end
    
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

function DockingBay:StartService(ship, serviceType)
    local service = self.services[serviceType]
    if not service or not service.active then return false end
    
    local serviceConfig = HYPERDRIVE.Docking.Config.Services[serviceType]
    if not serviceConfig then return false end
    
    -- Add to service queue
    table.insert(service.queue, {
        ship = ship,
        startTime = CurTime(),
        progress = 0,
        completed = false
    })
    
    print("[Docking] Started " .. serviceConfig.name .. " for ship " .. ship:EntIndex())
    return true
end

function DockingBay:UpdateServices()
    for serviceType, service in pairs(self.services) do
        if service.active and #service.queue > 0 then
            self:ProcessService(serviceType, service)
        end
    end
end

function DockingBay:ProcessService(serviceType, service)
    local serviceConfig = HYPERDRIVE.Docking.Config.Services[serviceType]
    if not serviceConfig then return end
    
    -- Process first ship in queue
    local serviceRequest = service.queue[1]
    if not serviceRequest or not IsValid(serviceRequest.ship) then
        table.remove(service.queue, 1)
        return
    end
    
    local ship = serviceRequest.ship
    local deltaTime = CurTime() - serviceRequest.startTime
    
    if serviceType == "refuel" then
        self:ProcessRefueling(ship, serviceRequest, serviceConfig, deltaTime)
    elseif serviceType == "repair" then
        self:ProcessRepair(ship, serviceRequest, serviceConfig, deltaTime)
    elseif serviceType == "resupply" then
        self:ProcessResupply(ship, serviceRequest, serviceConfig, deltaTime)
    end
    
    -- Remove completed services
    if serviceRequest.completed then
        table.remove(service.queue, 1)
        print("[Docking] Completed " .. serviceConfig.name .. " for ship " .. ship:EntIndex())
    end
end

function DockingBay:ProcessRefueling(ship, request, config, deltaTime)
    if HYPERDRIVE.SB3Resources then
        local currentEnergy = HYPERDRIVE.SB3Resources.GetResource(ship, "energy")
        local maxEnergy = HYPERDRIVE.SB3Resources.GetMaxResource(ship, "energy")
        
        if currentEnergy < maxEnergy then
            local refuelAmount = config.energyRate * 0.1 -- Per update
            HYPERDRIVE.SB3Resources.AddResource(ship, "energy", refuelAmount)
        else
            request.completed = true
        end
    else
        request.completed = true
    end
end

function DockingBay:ProcessRepair(ship, request, config, deltaTime)
    local currentHealth = ship:Health()
    local maxHealth = ship:GetMaxHealth()
    
    if currentHealth < maxHealth then
        local repairAmount = config.repairRate * 0.1 -- Per update
        ship:SetHealth(math.min(maxHealth, currentHealth + repairAmount))
    else
        request.completed = true
    end
end

function DockingBay:ProcessResupply(ship, request, config, deltaTime)
    if HYPERDRIVE.Ammunition then
        local storage = HYPERDRIVE.Ammunition.GetStorage(ship)
        if storage then
            -- Resupply all ammunition types
            for ammoType, ammoConfig in pairs(HYPERDRIVE.Ammunition.Config.AmmoTypes) do
                local currentAmmo = storage:GetAmmo(ammoType)
                local maxAmmo = math.floor(storage.capacity / ammoConfig.weight)
                
                if currentAmmo < maxAmmo then
                    local supplyAmount = config.supplyRate * 0.1
                    storage:AddAmmo(ammoType, supplyAmount)
                end
            end
        end
        request.completed = true
    else
        request.completed = true
    end
end

function DockingBay:UndockShip(ship)
    local dockedShip = self.dockedShips[ship]
    if not dockedShip then return false, "Ship not docked" end
    
    -- Free docking position
    local dockingPos = dockedShip.dockingPos
    dockingPos.occupied = false
    dockingPos.ship = nil
    
    -- Remove from docked ships
    self.dockedShips[ship] = nil
    self.occupied = self.occupied - 1
    
    -- Move ship away from docking bay
    local undockPos = dockingPos.position + dockingPos.angles:Forward() * -500
    
    local flight = HYPERDRIVE.Flight.GetFlightSystem(ship)
    if flight then
        flight:ClearWaypoints()
        flight:AddWaypoint(undockPos)
        flight:SetFlightMode("autopilot")
        flight.autopilotActive = true
    end
    
    print("[Docking] Ship " .. ship:EntIndex() .. " undocked")
    return true
end

function DockingBay:Update()
    -- Process docking queue
    self:ProcessDockingQueue()
    
    -- Update services
    self:UpdateServices()
    
    -- Update energy consumption
    self.energyConsumption = self.occupied * self.config.energyCost
    
    -- Consume energy
    if HYPERDRIVE.SB3Resources and self.energyConsumption > 0 then
        HYPERDRIVE.SB3Resources.ConsumeResource(self.entity, "energy", self.energyConsumption * 0.1)
    end
end

function DockingBay:GetStatus()
    return {
        active = self.active,
        bayType = self.bayType,
        occupied = self.occupied,
        capacity = self.config.capacity,
        queueLength = #self.dockingQueue,
        energyConsumption = self.energyConsumption,
        services = self.services
    }
end

-- Main docking functions
function HYPERDRIVE.Docking.CreateDockingBay(entity, bayType)
    if not IsValid(entity) then return nil end
    
    local bayId = entity:EntIndex()
    local bay = DockingBay:New(entity, bayType)
    HYPERDRIVE.Docking.DockingBays[bayId] = bay
    
    print("[Docking] Created docking bay: " .. bay.config.name .. " (ID: " .. bayId .. ")")
    return bay
end

function HYPERDRIVE.Docking.GetDockingBay(entity)
    if not IsValid(entity) then return nil end
    
    local bayId = entity:EntIndex()
    return HYPERDRIVE.Docking.DockingBays[bayId]
end

function HYPERDRIVE.Docking.RemoveDockingBay(entity)
    if not IsValid(entity) then return end
    
    local bayId = entity:EntIndex()
    HYPERDRIVE.Docking.DockingBays[bayId] = nil
    print("[Docking] Removed docking bay ID: " .. bayId)
end

function HYPERDRIVE.Docking.RequestDocking(ship, dockingBay)
    local bay = HYPERDRIVE.Docking.GetDockingBay(dockingBay)
    if not bay then return false, "Docking bay not found" end
    
    return bay:RequestDocking(ship)
end

function HYPERDRIVE.Docking.FindNearestDockingBay(ship, bayType)
    local shipPos = ship:GetPos()
    local nearestBay = nil
    local nearestDistance = math.huge
    
    for bayId, bay in pairs(HYPERDRIVE.Docking.DockingBays) do
        if not bayType or bay.bayType == bayType then
            local distance = shipPos:Distance(bay.entity:GetPos())
            if distance < nearestDistance then
                local canDock, _ = bay:CanDock(ship)
                if canDock then
                    nearestBay = bay
                    nearestDistance = distance
                end
            end
        end
    end
    
    return nearestBay, nearestDistance
end

-- Think function for docking system
timer.Create("HyperdriveDockingThink", 0.1, 0, function()
    for bayId, bay in pairs(HYPERDRIVE.Docking.DockingBays) do
        if IsValid(bay.entity) then
            bay:Update()
        else
            HYPERDRIVE.Docking.DockingBays[bayId] = nil
        end
    end
end)

print("[Hyperdrive Docking] Docking System loaded successfully!")
