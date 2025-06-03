-- Enhanced Hyperdrive Shuttle System v5.1.0
-- Advanced shuttle operations, passenger transport, and cargo delivery
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Hyperdrive Shuttle] Shuttle System v5.1.0 - Ultimate Edition Initializing...")

-- Initialize shuttle namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Shuttle = HYPERDRIVE.Shuttle or {}

-- Shuttle system configuration
HYPERDRIVE.Shuttle.Config = {
    -- Shuttle Operations
    MaxShuttles = 20, -- Maximum active shuttles
    LaunchDelay = 5, -- Seconds between launches
    AutoPilotAccuracy = 50, -- Landing accuracy
    EmergencyLandingRange = 2000, -- Emergency landing range
    
    -- Passenger System
    MaxPassengers = 8, -- Default passenger capacity
    BoardingTime = 2, -- Seconds per passenger
    PassengerSafety = true, -- Safety protocols
    LifeSupport = true, -- Life support systems
    
    -- Cargo System
    CargoTypes = {
        supplies = {
            name = "Supplies",
            weight = 1.0,
            value = 10,
            stackable = true
        },
        equipment = {
            name = "Equipment",
            weight = 5.0,
            value = 50,
            stackable = false
        },
        materials = {
            name = "Materials",
            weight = 2.0,
            value = 25,
            stackable = true
        },
        personnel = {
            name = "Personnel",
            weight = 80.0, -- Average person weight
            value = 0,
            stackable = false
        }
    },
    
    -- Mission Types
    MissionTypes = {
        transport = {
            name = "Passenger Transport",
            priority = 1,
            energyCost = 20,
            timeMultiplier = 1.0
        },
        cargo = {
            name = "Cargo Delivery",
            priority = 2,
            energyCost = 30,
            timeMultiplier = 1.2
        },
        emergency = {
            name = "Emergency Response",
            priority = 5,
            energyCost = 50,
            timeMultiplier = 0.5
        },
        patrol = {
            name = "Patrol Mission",
            priority = 1,
            energyCost = 15,
            timeMultiplier = 2.0
        }
    }
}

-- Shuttle system registry
HYPERDRIVE.Shuttle.ActiveShuttles = {} -- Active shuttle instances
HYPERDRIVE.Shuttle.ShuttleBays = {} -- Shuttle bay entities
HYPERDRIVE.Shuttle.Missions = {} -- Active missions
HYPERDRIVE.Shuttle.FlightPlans = {} -- Scheduled flights

-- Shuttle class
local Shuttle = {}
Shuttle.__index = Shuttle

function Shuttle:New(entity, shuttleType)
    local shuttle = setmetatable({}, Shuttle)
    
    shuttle.entity = entity
    shuttle.shuttleType = shuttleType or "transport"
    shuttle.config = HYPERDRIVE.Docking.Config.ShuttleTypes[shuttleType]
    shuttle.active = true
    shuttle.status = "docked" -- docked, launching, flying, landing, emergency
    
    -- Flight properties
    shuttle.flightSystem = nil
    shuttle.destination = nil
    shuttle.mission = nil
    shuttle.homeBase = nil
    
    -- Passenger and cargo
    shuttle.passengers = {}
    shuttle.cargo = {}
    shuttle.cargoWeight = 0
    shuttle.maxCargoWeight = shuttle.config.cargoSpace
    
    -- Mission tracking
    shuttle.missionStartTime = 0
    shuttle.missionProgress = 0
    shuttle.energyConsumed = 0
    
    return shuttle
end

function Shuttle:Initialize()
    -- Create flight system
    self.flightSystem = HYPERDRIVE.Flight.CreateFlightSystem(self.entity)
    if self.flightSystem then
        self.flightSystem:SetFlightMode("autopilot")
        self.flightSystem.mass = 500 -- Shuttle base mass
    end
    
    print("[Shuttle] Initialized " .. self.config.name .. " shuttle")
end

function Shuttle:LaunchMission(mission)
    if self.status ~= "docked" then
        return false, "Shuttle not available for launch"
    end
    
    self.mission = mission
    self.destination = mission.destination
    self.status = "launching"
    self.missionStartTime = CurTime()
    
    -- Set flight plan
    if self.flightSystem then
        self.flightSystem:ClearWaypoints()
        self.flightSystem:AddWaypoint(self.destination)
        self.flightSystem.autopilotActive = true
    end
    
    print("[Shuttle] Launching mission: " .. mission.type .. " to " .. tostring(self.destination))
    return true
end

function Shuttle:Update()
    if not self.active or not IsValid(self.entity) then return end
    
    -- Update based on status
    if self.status == "launching" then
        self:UpdateLaunching()
    elseif self.status == "flying" then
        self:UpdateFlying()
    elseif self.status == "landing" then
        self:UpdateLanding()
    elseif self.status == "emergency" then
        self:UpdateEmergency()
    end
    
    -- Update energy consumption
    self:UpdateEnergyConsumption()
    
    -- Update mission progress
    self:UpdateMissionProgress()
end

function Shuttle:UpdateLaunching()
    -- Check if shuttle has cleared launch area
    if self.homeBase then
        local distance = self.entity:GetPos():Distance(self.homeBase:GetPos())
        if distance > 500 then
            self.status = "flying"
            print("[Shuttle] Shuttle cleared launch area, now flying")
        end
    else
        -- No home base, assume launched
        self.status = "flying"
    end
end

function Shuttle:UpdateFlying()
    if not self.flightSystem or not self.destination then return end
    
    local distance = self.entity:GetPos():Distance(self.destination)
    
    -- Check if approaching destination
    if distance < 200 then
        self.status = "landing"
        print("[Shuttle] Approaching destination, beginning landing sequence")
    end
    
    -- Check for emergency conditions
    if self:CheckEmergencyConditions() then
        self:InitiateEmergencyLanding()
    end
end

function Shuttle:UpdateLanding()
    if not self.flightSystem or not self.destination then return end
    
    local distance = self.entity:GetPos():Distance(self.destination)
    
    -- Check if landed
    if distance < HYPERDRIVE.Shuttle.Config.AutoPilotAccuracy then
        self:CompleteMission()
    end
end

function Shuttle:UpdateEmergency()
    -- Find nearest safe landing site
    local emergencyLanding = self:FindEmergencyLanding()
    if emergencyLanding then
        self.destination = emergencyLanding
        if self.flightSystem then
            self.flightSystem:ClearWaypoints()
            self.flightSystem:AddWaypoint(emergencyLanding)
        end
    end
end

function Shuttle:CheckEmergencyConditions()
    -- Check energy levels
    if HYPERDRIVE.SB3Resources then
        local energy = HYPERDRIVE.SB3Resources.GetResource(self.entity, "energy")
        local maxEnergy = HYPERDRIVE.SB3Resources.GetMaxResource(self.entity, "energy")
        if energy / maxEnergy < 0.2 then -- Less than 20% energy
            return true
        end
    end
    
    -- Check hull integrity
    if self.entity:Health() / self.entity:GetMaxHealth() < 0.3 then -- Less than 30% health
        return true
    end
    
    return false
end

function Shuttle:InitiateEmergencyLanding()
    self.status = "emergency"
    self.mission.type = "emergency"
    
    -- Find emergency landing site
    local emergencyLanding = self:FindEmergencyLanding()
    if emergencyLanding then
        self.destination = emergencyLanding
        if self.flightSystem then
            self.flightSystem:ClearWaypoints()
            self.flightSystem:AddWaypoint(emergencyLanding)
        end
    end
    
    print("[Shuttle] Emergency landing initiated")
end

function Shuttle:FindEmergencyLanding()
    local shuttlePos = self.entity:GetPos()
    local range = HYPERDRIVE.Shuttle.Config.EmergencyLandingRange
    
    -- Look for docking bays
    for _, bay in pairs(HYPERDRIVE.Docking.DockingBays) do
        if IsValid(bay.entity) then
            local distance = shuttlePos:Distance(bay.entity:GetPos())
            if distance < range and bay.bayType == "shuttle" then
                return bay.entity:GetPos()
            end
        end
    end
    
    -- Look for flat ground
    local trace = util.TraceLine({
        start = shuttlePos,
        endpos = shuttlePos + Vector(0, 0, -1000),
        filter = self.entity
    })
    
    if trace.Hit then
        return trace.HitPos + Vector(0, 0, 100)
    end
    
    return nil
end

function Shuttle:CompleteMission()
    self.status = "docked"
    
    if self.mission then
        print("[Shuttle] Mission completed: " .. self.mission.type)
        
        -- Unload passengers and cargo
        self:UnloadPassengers()
        self:UnloadCargo()
        
        -- Return to home base if not already there
        if self.homeBase and self.entity:GetPos():Distance(self.homeBase:GetPos()) > 500 then
            self:ReturnToBase()
        end
    end
end

function Shuttle:ReturnToBase()
    if not self.homeBase then return end
    
    self.destination = self.homeBase:GetPos()
    self.status = "flying"
    
    if self.flightSystem then
        self.flightSystem:ClearWaypoints()
        self.flightSystem:AddWaypoint(self.destination)
        self.flightSystem.autopilotActive = true
    end
    
    print("[Shuttle] Returning to base")
end

function Shuttle:LoadPassenger(passenger)
    if #self.passengers >= self.config.capacity then
        return false, "Shuttle at passenger capacity"
    end
    
    table.insert(self.passengers, passenger)
    print("[Shuttle] Loaded passenger: " .. tostring(passenger))
    return true
end

function Shuttle:UnloadPassengers()
    for _, passenger in ipairs(self.passengers) do
        print("[Shuttle] Unloaded passenger: " .. tostring(passenger))
    end
    self.passengers = {}
end

function Shuttle:LoadCargo(cargoType, amount)
    local cargoConfig = HYPERDRIVE.Shuttle.Config.CargoTypes[cargoType]
    if not cargoConfig then return false, "Invalid cargo type" end
    
    local weight = amount * cargoConfig.weight
    if self.cargoWeight + weight > self.maxCargoWeight then
        return false, "Cargo capacity exceeded"
    end
    
    if not self.cargo[cargoType] then
        self.cargo[cargoType] = 0
    end
    
    self.cargo[cargoType] = self.cargo[cargoType] + amount
    self.cargoWeight = self.cargoWeight + weight
    
    print("[Shuttle] Loaded cargo: " .. amount .. " " .. cargoConfig.name)
    return true
end

function Shuttle:UnloadCargo()
    for cargoType, amount in pairs(self.cargo) do
        local cargoConfig = HYPERDRIVE.Shuttle.Config.CargoTypes[cargoType]
        if cargoConfig then
            print("[Shuttle] Unloaded cargo: " .. amount .. " " .. cargoConfig.name)
        end
    end
    self.cargo = {}
    self.cargoWeight = 0
end

function Shuttle:UpdateEnergyConsumption()
    if HYPERDRIVE.SB3Resources and self.status == "flying" then
        local energyCost = self.config.energyCost * 0.1 -- Per update
        HYPERDRIVE.SB3Resources.ConsumeResource(self.entity, "energy", energyCost)
        self.energyConsumed = self.energyConsumed + energyCost
    end
end

function Shuttle:UpdateMissionProgress()
    if not self.mission or self.status == "docked" then return end
    
    local totalTime = CurTime() - self.missionStartTime
    local missionConfig = HYPERDRIVE.Shuttle.Config.MissionTypes[self.mission.type]
    
    if missionConfig then
        local estimatedTime = self.mission.estimatedTime * missionConfig.timeMultiplier
        self.missionProgress = math.min(1.0, totalTime / estimatedTime)
    end
end

function Shuttle:GetStatus()
    return {
        active = self.active,
        status = self.status,
        shuttleType = self.shuttleType,
        passengers = #self.passengers,
        maxPassengers = self.config.capacity,
        cargoWeight = self.cargoWeight,
        maxCargoWeight = self.maxCargoWeight,
        mission = self.mission,
        missionProgress = self.missionProgress,
        energyConsumed = self.energyConsumed,
        destination = self.destination
    }
end

-- Mission class
local Mission = {}
Mission.__index = Mission

function Mission:New(missionType, destination, priority)
    local mission = setmetatable({}, Mission)
    
    mission.type = missionType or "transport"
    mission.destination = destination
    mission.priority = priority or 1
    mission.status = "pending" -- pending, assigned, active, completed, failed
    mission.assignedShuttle = nil
    mission.passengers = {}
    mission.cargo = {}
    mission.createdTime = CurTime()
    mission.estimatedTime = 300 -- 5 minutes default
    
    return mission
end

function Mission:AssignShuttle(shuttle)
    self.assignedShuttle = shuttle
    self.status = "assigned"
    print("[Shuttle] Mission assigned to shuttle " .. shuttle.entity:EntIndex())
end

function Mission:GetInfo()
    return {
        type = self.type,
        destination = self.destination,
        priority = self.priority,
        status = self.status,
        assignedShuttle = self.assignedShuttle,
        passengers = #self.passengers,
        cargo = self.cargo,
        estimatedTime = self.estimatedTime
    }
end

-- Main shuttle functions
function HYPERDRIVE.Shuttle.CreateShuttle(entity, shuttleType)
    if not IsValid(entity) then return nil end
    
    local shuttleId = entity:EntIndex()
    local shuttle = Shuttle:New(entity, shuttleType)
    shuttle:Initialize()
    
    HYPERDRIVE.Shuttle.ActiveShuttles[shuttleId] = shuttle
    
    print("[Shuttle] Created shuttle: " .. shuttle.config.name .. " (ID: " .. shuttleId .. ")")
    return shuttle
end

function HYPERDRIVE.Shuttle.GetShuttle(entity)
    if not IsValid(entity) then return nil end
    
    local shuttleId = entity:EntIndex()
    return HYPERDRIVE.Shuttle.ActiveShuttles[shuttleId]
end

function HYPERDRIVE.Shuttle.RemoveShuttle(entity)
    if not IsValid(entity) then return end
    
    local shuttleId = entity:EntIndex()
    HYPERDRIVE.Shuttle.ActiveShuttles[shuttleId] = nil
    print("[Shuttle] Removed shuttle ID: " .. shuttleId)
end

function HYPERDRIVE.Shuttle.CreateMission(missionType, destination, priority)
    local mission = Mission:New(missionType, destination, priority)
    table.insert(HYPERDRIVE.Shuttle.Missions, mission)
    
    print("[Shuttle] Created mission: " .. missionType .. " to " .. tostring(destination))
    return mission
end

function HYPERDRIVE.Shuttle.AssignMission(mission)
    -- Find available shuttle
    local bestShuttle = nil
    local bestScore = -1
    
    for shuttleId, shuttle in pairs(HYPERDRIVE.Shuttle.ActiveShuttles) do
        if shuttle.status == "docked" and not shuttle.mission then
            -- Calculate suitability score
            local score = 0
            
            -- Distance factor
            local distance = shuttle.entity:GetPos():Distance(mission.destination)
            score = score + (1000 - math.min(distance, 1000)) / 1000
            
            -- Shuttle type factor
            if mission.type == "transport" and shuttle.shuttleType == "transport" then
                score = score + 0.5
            elseif mission.type == "cargo" and shuttle.shuttleType == "cargo" then
                score = score + 0.5
            elseif mission.type == "emergency" and shuttle.shuttleType == "combat" then
                score = score + 0.3
            end
            
            if score > bestScore then
                bestShuttle = shuttle
                bestScore = score
            end
        end
    end
    
    if bestShuttle then
        mission:AssignShuttle(bestShuttle)
        bestShuttle:LaunchMission(mission)
        return true
    end
    
    return false, "No available shuttles"
end

function HYPERDRIVE.Shuttle.GetShuttleStatus()
    local status = {}
    
    for shuttleId, shuttle in pairs(HYPERDRIVE.Shuttle.ActiveShuttles) do
        if IsValid(shuttle.entity) then
            status[shuttleId] = shuttle:GetStatus()
        else
            HYPERDRIVE.Shuttle.ActiveShuttles[shuttleId] = nil
        end
    end
    
    return status
end

function HYPERDRIVE.Shuttle.GetMissionStatus()
    local status = {}
    
    for i, mission in ipairs(HYPERDRIVE.Shuttle.Missions) do
        status[i] = mission:GetInfo()
    end
    
    return status
end

-- Think function for shuttle system
timer.Create("HyperdriveShuttleThink", 0.5, 0, function()
    -- Update shuttles
    for shuttleId, shuttle in pairs(HYPERDRIVE.Shuttle.ActiveShuttles) do
        if IsValid(shuttle.entity) then
            shuttle:Update()
        else
            HYPERDRIVE.Shuttle.ActiveShuttles[shuttleId] = nil
        end
    end
    
    -- Process mission queue
    for i = #HYPERDRIVE.Shuttle.Missions, 1, -1 do
        local mission = HYPERDRIVE.Shuttle.Missions[i]
        
        if mission.status == "pending" then
            local success = HYPERDRIVE.Shuttle.AssignMission(mission)
            if success then
                mission.status = "active"
            end
        elseif mission.status == "completed" or mission.status == "failed" then
            table.remove(HYPERDRIVE.Shuttle.Missions, i)
        end
    end
end)

print("[Hyperdrive Shuttle] Shuttle System loaded successfully!")
