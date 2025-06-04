-- Enhanced Hyperdrive System - Fleet Management
-- Multi-ship fleet coordination and control system

HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Fleet = HYPERDRIVE.Fleet or {}

-- Fleet management configuration
HYPERDRIVE.Fleet.Config = {
    Enabled = true,
    MaxFleetSize = 10,
    MaxFleetDistance = 5000, -- Maximum distance between fleet members
    AutoFormation = true,
    FormationSpacing = 100,
    SynchronizedJumps = true,
    FleetCommunication = true,
    RequireFleetCore = true, -- Require a designated fleet command ship
    
    -- Formation types
    Formations = {
        line = "Line Formation",
        wedge = "Wedge Formation", 
        diamond = "Diamond Formation",
        circle = "Circle Formation",
        custom = "Custom Formation"
    },
    
    -- Fleet roles
    Roles = {
        flagship = "Fleet Flagship",
        escort = "Escort Ship",
        support = "Support Ship",
        scout = "Scout Ship",
        cargo = "Cargo Ship"
    }
}

-- Fleet registry
HYPERDRIVE.Fleet.ActiveFleets = {}
HYPERDRIVE.Fleet.FleetCounter = 0

-- Fleet class
local FleetMeta = {}
FleetMeta.__index = FleetMeta

function HYPERDRIVE.Fleet.CreateFleet(owner, fleetName)
    if not IsValid(owner) then return nil end
    
    HYPERDRIVE.Fleet.FleetCounter = HYPERDRIVE.Fleet.FleetCounter + 1
    
    local fleet = {
        id = HYPERDRIVE.Fleet.FleetCounter,
        name = fleetName or ("Fleet " .. HYPERDRIVE.Fleet.FleetCounter),
        owner = owner,
        flagship = nil,
        ships = {},
        formation = "line",
        status = "idle", -- idle, moving, jumping, combat
        destination = nil,
        created = CurTime(),
        lastUpdate = CurTime()
    }
    
    setmetatable(fleet, FleetMeta)
    
    HYPERDRIVE.Fleet.ActiveFleets[fleet.id] = fleet
    
    print(string.format("[Fleet Management] Fleet '%s' created by %s", fleet.name, owner:Nick()))
    
    return fleet
end

function FleetMeta:AddShip(shipCore, role)
    if not IsValid(shipCore) then return false end
    if #self.ships >= HYPERDRIVE.Fleet.Config.MaxFleetSize then return false end
    
    -- Check if ship is already in a fleet
    for _, fleet in pairs(HYPERDRIVE.Fleet.ActiveFleets) do
        if fleet:HasShip(shipCore) then
            return false, "Ship already in fleet"
        end
    end
    
    role = role or "escort"
    
    local shipData = {
        entity = shipCore,
        role = role,
        position = shipCore:GetPos(),
        joinTime = CurTime(),
        formationOffset = Vector(0, 0, 0)
    }
    
    table.insert(self.ships, shipData)
    
    -- Set flagship if this is the first ship or role is flagship
    if not self.flagship or role == "flagship" then
        self.flagship = shipCore
    end
    
    -- Update ship's fleet information
    shipCore:SetNWString("FleetName", self.name)
    shipCore:SetNWInt("FleetID", self.id)
    shipCore:SetNWString("FleetRole", role)
    
    self:UpdateFormation()
    
    print(string.format("[Fleet Management] Ship '%s' joined fleet '%s' as %s", 
        shipCore:GetNWString("ShipName", "Unnamed"), self.name, role))
    
    return true
end

function FleetMeta:RemoveShip(shipCore)
    if not IsValid(shipCore) then return false end
    
    for i, ship in ipairs(self.ships) do
        if ship.entity == shipCore then
            table.remove(self.ships, i)
            
            -- Clear ship's fleet information
            shipCore:SetNWString("FleetName", "")
            shipCore:SetNWInt("FleetID", 0)
            shipCore:SetNWString("FleetRole", "")
            
            -- If this was the flagship, assign a new one
            if self.flagship == shipCore and #self.ships > 0 then
                self.flagship = self.ships[1].entity
                self.ships[1].role = "flagship"
                self.flagship:SetNWString("FleetRole", "flagship")
            end
            
            self:UpdateFormation()
            
            print(string.format("[Fleet Management] Ship '%s' left fleet '%s'", 
                shipCore:GetNWString("ShipName", "Unnamed"), self.name))
            
            return true
        end
    end
    
    return false
end

function FleetMeta:HasShip(shipCore)
    for _, ship in ipairs(self.ships) do
        if ship.entity == shipCore then
            return true
        end
    end
    return false
end

function FleetMeta:SetFormation(formationType)
    if not HYPERDRIVE.Fleet.Config.Formations[formationType] then
        return false
    end
    
    self.formation = formationType
    self:UpdateFormation()
    
    return true
end

function FleetMeta:UpdateFormation()
    if not IsValid(self.flagship) then return end
    if not HYPERDRIVE.Fleet.Config.AutoFormation then return end
    
    local flagshipPos = self.flagship:GetPos()
    local flagshipAng = self.flagship:GetAngles()
    local spacing = HYPERDRIVE.Fleet.Config.FormationSpacing
    
    for i, ship in ipairs(self.ships) do
        if ship.entity == self.flagship then continue end
        
        local offset = Vector(0, 0, 0)
        
        if self.formation == "line" then
            offset = Vector(0, (i - 1) * spacing, 0)
        elseif self.formation == "wedge" then
            local side = (i % 2 == 0) and 1 or -1
            local row = math.ceil(i / 2)
            offset = Vector(-row * spacing, side * row * spacing * 0.5, 0)
        elseif self.formation == "diamond" then
            local angle = (i - 1) * (360 / (#self.ships - 1))
            offset = Vector(
                math.cos(math.rad(angle)) * spacing,
                math.sin(math.rad(angle)) * spacing,
                0
            )
        elseif self.formation == "circle" then
            local angle = (i - 1) * (360 / (#self.ships - 1))
            offset = Vector(
                math.cos(math.rad(angle)) * spacing * 1.5,
                math.sin(math.rad(angle)) * spacing * 1.5,
                0
            )
        end
        
        -- Rotate offset based on flagship orientation
        offset:Rotate(flagshipAng)
        ship.formationOffset = offset
        
        -- Update ship's target position
        ship.targetPosition = flagshipPos + offset
    end
end

function FleetMeta:ExecuteFleetJump(destination)
    if not IsValid(self.flagship) then return false end
    if self.status == "jumping" then return false end
    
    self.status = "jumping"
    self.destination = destination
    
    print(string.format("[Fleet Management] Fleet '%s' initiating synchronized jump", self.name))
    
    -- Calculate jump sequence timing
    local jumpDelay = 0
    
    for i, ship in ipairs(self.ships) do
        if not IsValid(ship.entity) then continue end
        
        -- Find ship's hyperdrive engine
        local engine = self:FindShipEngine(ship.entity)
        if not IsValid(engine) then continue end
        
        -- Calculate destination for this ship
        local shipDestination = destination + ship.formationOffset
        
        -- Execute jump with delay for formation
        timer.Simple(jumpDelay, function()
            if IsValid(engine) and engine.ExecuteJump then
                engine:ExecuteJump(shipDestination)
            end
        end)
        
        jumpDelay = jumpDelay + 0.5 -- 0.5 second delay between ships
    end
    
    -- Reset status after all ships should have jumped
    timer.Simple(jumpDelay + 10, function()
        if self.status == "jumping" then
            self.status = "idle"
        end
    end)
    
    return true
end

function FleetMeta:FindShipEngine(shipCore)
    if not IsValid(shipCore) then return nil end
    
    local engines = ents.FindByClass("hyperdrive_master_engine")
    
    local closestEngine = nil
    local closestDist = math.huge
    
    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            local dist = engine:GetPos():Distance(shipCore:GetPos())
            if dist < closestDist and dist < 500 then -- Within 500 units
                closestDist = dist
                closestEngine = engine
            end
        end
    end
    
    return closestEngine
end

function FleetMeta:GetStatus()
    return {
        id = self.id,
        name = self.name,
        owner = self.owner,
        shipCount = #self.ships,
        formation = self.formation,
        status = self.status,
        flagship = self.flagship,
        ships = self.ships
    }
end

function FleetMeta:Disband()
    -- Remove all ships from fleet
    for _, ship in ipairs(self.ships) do
        if IsValid(ship.entity) then
            ship.entity:SetNWString("FleetName", "")
            ship.entity:SetNWInt("FleetID", 0)
            ship.entity:SetNWString("FleetRole", "")
        end
    end
    
    -- Remove from active fleets
    HYPERDRIVE.Fleet.ActiveFleets[self.id] = nil
    
    print(string.format("[Fleet Management] Fleet '%s' disbanded", self.name))
end

-- Fleet management functions
function HYPERDRIVE.Fleet.GetPlayerFleet(ply)
    for _, fleet in pairs(HYPERDRIVE.Fleet.ActiveFleets) do
        if fleet.owner == ply then
            return fleet
        end
    end
    return nil
end

function HYPERDRIVE.Fleet.GetShipFleet(shipCore)
    local fleetID = shipCore:GetNWInt("FleetID", 0)
    return HYPERDRIVE.Fleet.ActiveFleets[fleetID]
end

function HYPERDRIVE.Fleet.GetAllFleets()
    return HYPERDRIVE.Fleet.ActiveFleets
end

-- Console commands
concommand.Add("hyperdrive_fleet_create", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local fleetName = args[1] or ("Fleet " .. (HYPERDRIVE.Fleet.FleetCounter + 1))
    local fleet = HYPERDRIVE.Fleet.CreateFleet(ply, fleetName)
    
    if fleet then
        ply:ChatPrint(string.format("[Fleet] Created fleet '%s' (ID: %d)", fleet.name, fleet.id))
    else
        ply:ChatPrint("[Fleet] Failed to create fleet")
    end
end)

concommand.Add("hyperdrive_fleet_status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local fleet = HYPERDRIVE.Fleet.GetPlayerFleet(ply)
    if not fleet then
        ply:ChatPrint("[Fleet] You are not commanding a fleet")
        return
    end
    
    local status = fleet:GetStatus()
    ply:ChatPrint(string.format("=== Fleet '%s' Status ===", status.name))
    ply:ChatPrint(string.format("Ships: %d | Formation: %s | Status: %s", 
        status.shipCount, status.formation, status.status))
    
    for i, ship in ipairs(status.ships) do
        if IsValid(ship.entity) then
            ply:ChatPrint(string.format("%d. %s (%s)", i, 
                ship.entity:GetNWString("ShipName", "Unnamed"), ship.role))
        end
    end
end)

-- Update fleet formations periodically
timer.Create("HyperdriveFleetUpdate", 1, 0, function()
    for _, fleet in pairs(HYPERDRIVE.Fleet.ActiveFleets) do
        if fleet and IsValid(fleet.flagship) then
            fleet:UpdateFormation()
            fleet.lastUpdate = CurTime()
        end
    end
end)

print("[Hyperdrive] Fleet Management system loaded")
