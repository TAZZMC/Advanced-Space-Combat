-- Hyperdrive Ship Core System
-- Independent ship detection and management system

HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.ShipCore = HYPERDRIVE.ShipCore or {}

print("[Hyperdrive] Ship Core system loading...")

-- Ship detection configuration
HYPERDRIVE.ShipCore.Config = {
    MaxDetectionRadius = 5000,      -- Maximum detection radius
    DefaultRadius = 1500,           -- Default detection radius
    MinEntitySize = 10,             -- Minimum entity size to consider
    MaxEntitiesPerShip = 500,       -- Maximum entities per ship
    PlayerDetectionRadius = 2000,   -- Radius to detect players
    UpdateInterval = 0.5,           -- How often to update ship data
    UsePhysicsConstraints = true,   -- Use constraint detection
    UseProximityDetection = true,   -- Use proximity-based detection
    UseParentDetection = true,      -- Use parent-child relationships
    IgnoreWorld = true,             -- Ignore world entities
    IgnoreNPCs = false,             -- Include NPCs in detection
}

-- Ship data storage
HYPERDRIVE.ShipCore.Ships = HYPERDRIVE.ShipCore.Ships or {}
HYPERDRIVE.ShipCore.EntityToShip = HYPERDRIVE.ShipCore.EntityToShip or {}

-- Ship class definition
local ShipClass = {}
ShipClass.__index = ShipClass

function ShipClass:new(coreEntity)
    local ship = {
        core = coreEntity,
        entities = {},
        players = {},
        center = Vector(0, 0, 0),
        bounds = {
            min = Vector(0, 0, 0),
            max = Vector(0, 0, 0)
        },
        mass = 0,
        volume = 0,
        lastUpdate = 0,
        orientation = Angle(0, 0, 0),
        velocity = Vector(0, 0, 0),
        angularVelocity = Angle(0, 0, 0),
        shipType = "unknown",
        classification = {},
        constraints = {},
        parentEntities = {},
        childEntities = {}
    }
    setmetatable(ship, ShipClass)
    return ship
end

-- Update ship data
function ShipClass:Update()
    if not IsValid(self.core) then
        return false
    end

    local currentTime = CurTime()
    if currentTime - self.lastUpdate < HYPERDRIVE.ShipCore.Config.UpdateInterval then
        return true
    end

    self.lastUpdate = currentTime

    -- Clear previous data
    self.entities = {}
    self.players = {}
    self.constraints = {}
    self.parentEntities = {}
    self.childEntities = {}

    -- Detect ship entities
    self:DetectEntities()
    self:DetectPlayers()
    self:CalculateBounds()
    self:CalculatePhysics()
    self:ClassifyShip()

    return true
end

-- Detect all entities that belong to this ship
function ShipClass:DetectEntities()
    local corePos = self.core:GetPos()
    local radius = HYPERDRIVE.ShipCore.Config.DefaultRadius

    -- Get all entities in radius
    local nearbyEnts = ents.FindInSphere(corePos, radius)

    for _, ent in ipairs(nearbyEnts) do
        if self:ShouldIncludeEntity(ent) then
            if self:IsEntityPartOfShip(ent) then
                table.insert(self.entities, ent)
                HYPERDRIVE.ShipCore.EntityToShip[ent:EntIndex()] = self

                -- Check parent-child relationships
                self:MapEntityRelationships(ent)
            end
        end
    end
end

-- Check if entity should be included in ship detection
function ShipClass:ShouldIncludeEntity(ent)
    if not IsValid(ent) then return false end
    if ent == self.core then return true end
    if ent:IsWorld() and HYPERDRIVE.ShipCore.Config.IgnoreWorld then return false end
    if ent:IsNPC() and HYPERDRIVE.ShipCore.Config.IgnoreNPCs then return false end
    if ent:IsPlayer() then return false end -- Players handled separately

    -- Check entity size
    local mins, maxs = ent:GetCollisionBounds()
    local size = (maxs - mins):Length()
    if size < HYPERDRIVE.ShipCore.Config.MinEntitySize then return false end

    return true
end

-- Determine if entity is part of this ship
function ShipClass:IsEntityPartOfShip(ent)
    if not IsValid(ent) then return false end

    -- Always include the core
    if ent == self.core then return true end

    -- Check various connection methods
    if HYPERDRIVE.ShipCore.Config.UsePhysicsConstraints and self:IsConstrainedToShip(ent) then
        return true
    end

    if HYPERDRIVE.ShipCore.Config.UseParentDetection and self:IsParentedToShip(ent) then
        return true
    end

    if HYPERDRIVE.ShipCore.Config.UseProximityDetection and self:IsInProximityToShip(ent) then
        return true
    end

    return false
end

-- Check if entity is constrained to ship
function ShipClass:IsConstrainedToShip(ent)
    if not IsValid(ent) then return false end

    local constraints = constraint.GetAllConstrainedEntities(ent)
    if not constraints then return false end

    for constrainedEnt, _ in pairs(constraints) do
        if IsValid(constrainedEnt) then
            if constrainedEnt == self.core then
                return true
            end

            -- Check if constrained entity is already part of ship
            for _, shipEnt in ipairs(self.entities) do
                if constrainedEnt == shipEnt then
                    return true
                end
            end
        end
    end

    return false
end

-- Check if entity is parented to ship
function ShipClass:IsParentedToShip(ent)
    if not IsValid(ent) then return false end

    local parent = ent:GetParent()
    local checkDepth = 0

    while IsValid(parent) and checkDepth < 10 do -- Prevent infinite loops
        if parent == self.core then
            return true
        end

        -- Check if parent is already part of ship
        for _, shipEnt in ipairs(self.entities) do
            if parent == shipEnt then
                return true
            end
        end

        parent = parent:GetParent()
        checkDepth = checkDepth + 1
    end

    return false
end

-- Check if entity is in proximity to ship (for loose connections)
function ShipClass:IsInProximityToShip(ent)
    if not IsValid(ent) then return false end

    local entPos = ent:GetPos()
    local corePos = self.core:GetPos()

    -- Check distance to core
    local distanceToCore = entPos:Distance(corePos)
    if distanceToCore <= 200 then -- Close proximity to core
        return true
    end

    -- Check distance to other ship entities
    for _, shipEnt in ipairs(self.entities) do
        if IsValid(shipEnt) then
            local distanceToShipEnt = entPos:Distance(shipEnt:GetPos())
            if distanceToShipEnt <= 100 then -- Very close to ship entity
                return true
            end
        end
    end

    return false
end

-- Map entity parent-child relationships
function ShipClass:MapEntityRelationships(ent)
    if not IsValid(ent) then return end

    -- Map parent relationships
    local parent = ent:GetParent()
    if IsValid(parent) then
        if not self.parentEntities[ent:EntIndex()] then
            self.parentEntities[ent:EntIndex()] = {}
        end
        table.insert(self.parentEntities[ent:EntIndex()], parent)
    end

    -- Map child relationships
    local children = ent:GetChildren()
    if children and #children > 0 then
        if not self.childEntities[ent:EntIndex()] then
            self.childEntities[ent:EntIndex()] = {}
        end
        for _, child in ipairs(children) do
            if IsValid(child) then
                table.insert(self.childEntities[ent:EntIndex()], child)
            end
        end
    end

    -- Map constraints
    local constraints = constraint.GetAllConstrainedEntities(ent)
    if constraints then
        if not self.constraints[ent:EntIndex()] then
            self.constraints[ent:EntIndex()] = {}
        end
        for constrainedEnt, _ in pairs(constraints) do
            if IsValid(constrainedEnt) and constrainedEnt ~= ent then
                table.insert(self.constraints[ent:EntIndex()], constrainedEnt)
            end
        end
    end
end

-- Detect players inside or on the ship
function ShipClass:DetectPlayers()
    local corePos = self.core:GetPos()
    local radius = HYPERDRIVE.ShipCore.Config.PlayerDetectionRadius

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local plyPos = ply:GetPos()

            -- Check if player is within ship bounds
            if self:IsPlayerInShip(ply) then
                table.insert(self.players, ply)
            end
        end
    end
end

-- Check if player is inside the ship
function ShipClass:IsPlayerInShip(ply)
    if not IsValid(ply) then return false end

    local plyPos = ply:GetPos()
    local corePos = self.core:GetPos()

    -- Basic distance check
    local distanceToCore = plyPos:Distance(corePos)
    if distanceToCore > HYPERDRIVE.ShipCore.Config.PlayerDetectionRadius then
        return false
    end

    -- Check if player is inside ship bounds
    if self:IsPositionInBounds(plyPos) then
        return true
    end

    -- Check if player is standing on ship entity
    local ground = ply:GetGroundEntity()
    if IsValid(ground) then
        for _, shipEnt in ipairs(self.entities) do
            if ground == shipEnt then
                return true
            end
        end
    end

    -- Check if player is inside any ship entity
    for _, shipEnt in ipairs(self.entities) do
        if IsValid(shipEnt) then
            local mins, maxs = shipEnt:GetCollisionBounds()
            local entPos = shipEnt:GetPos()
            local entAng = shipEnt:GetAngles()

            -- Transform player position to entity local space
            local localPos = WorldToLocal(plyPos, angle_zero, entPos, entAng)

            -- Check if player is inside entity bounds
            if localPos.x >= mins.x and localPos.x <= maxs.x and
               localPos.y >= mins.y and localPos.y <= maxs.y and
               localPos.z >= mins.z and localPos.z <= maxs.z then
                return true
            end
        end
    end

    return false
end

-- Calculate ship bounds
function ShipClass:CalculateBounds()
    if #self.entities == 0 then
        local corePos = self.core:GetPos()
        self.bounds.min = corePos
        self.bounds.max = corePos
        self.center = corePos
        return
    end

    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge

    for _, ent in ipairs(self.entities) do
        if IsValid(ent) then
            local pos = ent:GetPos()
            local mins, maxs = ent:GetCollisionBounds()
            local ang = ent:GetAngles()

            -- Get world space bounds
            local worldMins = LocalToWorld(mins, angle_zero, pos, ang)
            local worldMaxs = LocalToWorld(maxs, angle_zero, pos, ang)

            minX = math.min(minX, worldMins.x, worldMaxs.x)
            minY = math.min(minY, worldMins.y, worldMaxs.y)
            minZ = math.min(minZ, worldMins.z, worldMaxs.z)

            maxX = math.max(maxX, worldMins.x, worldMaxs.x)
            maxY = math.max(maxY, worldMins.y, worldMaxs.y)
            maxZ = math.max(maxZ, worldMins.z, worldMaxs.z)
        end
    end

    self.bounds.min = Vector(minX, minY, minZ)
    self.bounds.max = Vector(maxX, maxY, maxZ)
    self.center = (self.bounds.min + self.bounds.max) / 2

    -- Calculate volume
    local size = self.bounds.max - self.bounds.min
    self.volume = size.x * size.y * size.z
end

-- Check if position is within ship bounds
function ShipClass:IsPositionInBounds(pos)
    return pos.x >= self.bounds.min.x and pos.x <= self.bounds.max.x and
           pos.y >= self.bounds.min.y and pos.y <= self.bounds.max.y and
           pos.z >= self.bounds.min.z and pos.z <= self.bounds.max.z
end

-- Calculate ship physics properties
function ShipClass:CalculatePhysics()
    self.mass = 0
    local totalPos = Vector(0, 0, 0)
    local validEntities = 0

    for _, ent in ipairs(self.entities) do
        if IsValid(ent) then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                local entMass = phys:GetMass()
                self.mass = self.mass + entMass
                totalPos = totalPos + (ent:GetPos() * entMass)
                validEntities = validEntities + 1
            end
        end
    end

    -- Calculate center of mass
    if self.mass > 0 then
        self.center = totalPos / self.mass
    end

    -- Get orientation from core entity
    if IsValid(self.core) then
        self.orientation = self.core:GetAngles()

        local phys = self.core:GetPhysicsObject()
        if IsValid(phys) then
            self.velocity = phys:GetVelocity()
            self.angularVelocity = phys:GetAngleVelocity()
        end
    end
end

-- Classify ship type based on size, mass, and entities
function ShipClass:ClassifyShip()
    local entityCount = #self.entities
    local playerCount = #self.players

    self.classification = {
        entityCount = entityCount,
        playerCount = playerCount,
        mass = self.mass,
        volume = self.volume,
        size = (self.bounds.max - self.bounds.min):Length()
    }

    -- Determine ship type
    if entityCount < 10 then
        self.shipType = "fighter"
    elseif entityCount < 25 then
        self.shipType = "corvette"
    elseif entityCount < 50 then
        self.shipType = "frigate"
    elseif entityCount < 100 then
        self.shipType = "destroyer"
    elseif entityCount < 200 then
        self.shipType = "cruiser"
    elseif entityCount < 400 then
        self.shipType = "battleship"
    else
        self.shipType = "dreadnought"
    end

    -- Special classifications
    if playerCount > 10 then
        self.shipType = "carrier"
    elseif self.volume > 1000000 then
        self.shipType = "station"
    end
end

-- Get all entities in ship
function ShipClass:GetEntities()
    return self.entities
end

-- Get all players in ship
function ShipClass:GetPlayers()
    return self.players
end

-- Get ship center position
function ShipClass:GetCenter()
    return self.center
end

-- Get ship bounds
function ShipClass:GetBounds()
    return self.bounds.min, self.bounds.max
end

-- Get ship orientation
function ShipClass:GetOrientation()
    return self.orientation
end

-- Get ship velocity
function ShipClass:GetVelocity()
    return self.velocity
end

-- Get ship classification
function ShipClass:GetClassification()
    return self.classification
end

-- Get ship type
function ShipClass:GetShipType()
    return self.shipType
end

-- Move entire ship to new position
function ShipClass:MoveTo(newPos, newAng)
    if not IsValid(self.core) then return false end

    local currentPos = self.core:GetPos()
    local currentAng = self.core:GetAngles()

    local offset = newPos - currentPos
    local angleOffset = newAng - currentAng

    -- Move all entities
    for _, ent in ipairs(self.entities) do
        if IsValid(ent) then
            local entPos = ent:GetPos()
            local entAng = ent:GetAngles()

            -- Calculate new position relative to core
            local relativePos = entPos - currentPos
            local rotatedPos = relativePos

            -- Apply rotation if needed
            if angleOffset:Length() > 0 then
                rotatedPos = LocalToWorld(WorldToLocal(relativePos, angle_zero, vector_origin, currentAng), angle_zero, vector_origin, newAng)
            end

            local newEntPos = newPos + rotatedPos
            local newEntAng = entAng + angleOffset

            -- Move entity
            ent:SetPos(newEntPos)
            ent:SetAngles(newEntAng)

            -- Update physics
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetPos(newEntPos)
                phys:SetAngles(newEntAng)
                phys:Wake()
            end
        end
    end

    -- Move players
    for _, ply in ipairs(self.players) do
        if IsValid(ply) then
            local plyPos = ply:GetPos()
            local relativePos = plyPos - currentPos
            local rotatedPos = relativePos

            -- Apply rotation if needed
            if angleOffset:Length() > 0 then
                rotatedPos = LocalToWorld(WorldToLocal(relativePos, angle_zero, vector_origin, currentAng), angle_zero, vector_origin, newAng)
            end

            local newPlyPos = newPos + rotatedPos
            ply:SetPos(newPlyPos)
        end
    end

    -- Update ship data
    self:Update()

    return true
end

-- Store ship class in global namespace
HYPERDRIVE.ShipCore.ShipClass = ShipClass

-- Ship management functions
function HYPERDRIVE.ShipCore.CreateShip(coreEntity)
    if not IsValid(coreEntity) then return nil end

    local ship = ShipClass:new(coreEntity)
    ship:Update()

    local shipId = coreEntity:EntIndex()
    HYPERDRIVE.ShipCore.Ships[shipId] = ship

    print("[Hyperdrive] Created ship with core: " .. coreEntity:GetClass() .. " (" .. shipId .. ")")
    return ship
end

function HYPERDRIVE.ShipCore.GetShip(coreEntity)
    if not IsValid(coreEntity) then return nil end

    local shipId = coreEntity:EntIndex()
    return HYPERDRIVE.ShipCore.Ships[shipId]
end

function HYPERDRIVE.ShipCore.GetShipByEntity(entity)
    if not IsValid(entity) then return nil end

    local entIndex = entity:EntIndex()
    return HYPERDRIVE.ShipCore.EntityToShip[entIndex]
end

function HYPERDRIVE.ShipCore.RemoveShip(coreEntity)
    if not IsValid(coreEntity) then return end

    local shipId = coreEntity:EntIndex()
    local ship = HYPERDRIVE.ShipCore.Ships[shipId]

    if ship then
        -- Clear entity mappings
        for _, ent in ipairs(ship.entities) do
            if IsValid(ent) then
                HYPERDRIVE.ShipCore.EntityToShip[ent:EntIndex()] = nil
            end
        end

        HYPERDRIVE.ShipCore.Ships[shipId] = nil
        print("[Hyperdrive] Removed ship: " .. shipId)
    end
end

function HYPERDRIVE.ShipCore.UpdateAllShips()
    for shipId, ship in pairs(HYPERDRIVE.ShipCore.Ships) do
        if not ship:Update() then
            -- Ship core is invalid, remove ship
            HYPERDRIVE.ShipCore.Ships[shipId] = nil
        end
    end
end

function HYPERDRIVE.ShipCore.GetAllShips()
    return HYPERDRIVE.ShipCore.Ships
end

function HYPERDRIVE.ShipCore.GetShipCount()
    return table.Count(HYPERDRIVE.ShipCore.Ships)
end

-- Automatic ship detection for hyperdrive engines
function HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
    if not IsValid(engine) then return nil end

    -- Check if ship already exists
    local existingShip = HYPERDRIVE.ShipCore.GetShip(engine)
    if existingShip then
        existingShip:Update()
        return existingShip
    end

    -- Create new ship with engine as core
    return HYPERDRIVE.ShipCore.CreateShip(engine)
end

-- Get entities attached to engine (main function for hyperdrive system)
function HYPERDRIVE.ShipCore.GetAttachedEntities(engine, radius)
    local ship = HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
    if not ship then return {} end

    return ship:GetEntities()
end

-- Get players in ship
function HYPERDRIVE.ShipCore.GetPlayersInShip(engine)
    local ship = HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
    if not ship then return {} end

    return ship:GetPlayers()
end

-- Move ship to new location
function HYPERDRIVE.ShipCore.MoveShip(engine, newPos, newAng)
    local ship = HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
    if not ship then return false end

    return ship:MoveTo(newPos, newAng or ship:GetOrientation())
end

-- Get ship information
function HYPERDRIVE.ShipCore.GetShipInfo(engine)
    local ship = HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
    if not ship then return nil end

    return {
        entities = ship:GetEntities(),
        players = ship:GetPlayers(),
        center = ship:GetCenter(),
        bounds = {ship:GetBounds()},
        orientation = ship:GetOrientation(),
        velocity = ship:GetVelocity(),
        classification = ship:GetClassification(),
        shipType = ship:GetShipType(),
        mass = ship.mass,
        volume = ship.volume
    }
end

-- Console commands for debugging
concommand.Add("hyperdrive_ship_info", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) then
        ply:ChatPrint("[Hyperdrive] No entity found")
        return
    end

    local ship = HYPERDRIVE.ShipCore.GetShipByEntity(ent)
    if not ship then
        -- Try to create ship with this entity as core
        ship = HYPERDRIVE.ShipCore.CreateShip(ent)
    end

    if ship then
        local info = ship:GetClassification()
        ply:ChatPrint("[Hyperdrive] Ship Info:")
        ply:ChatPrint("  • Type: " .. ship:GetShipType())
        ply:ChatPrint("  • Entities: " .. info.entityCount)
        ply:ChatPrint("  • Players: " .. info.playerCount)
        ply:ChatPrint("  • Mass: " .. math.Round(info.mass, 2))
        ply:ChatPrint("  • Size: " .. math.Round(info.size, 2))
    else
        ply:ChatPrint("[Hyperdrive] Could not detect ship")
    end
end)

concommand.Add("hyperdrive_list_ships", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local ships = HYPERDRIVE.ShipCore.GetAllShips()
    local count = table.Count(ships)

    ply:ChatPrint("[Hyperdrive] Active Ships: " .. count)

    for shipId, ship in pairs(ships) do
        if ship and IsValid(ship.core) then
            local info = ship:GetClassification()
            ply:ChatPrint("  • " .. ship.core:GetClass() .. " (" .. shipId .. ") - " .. ship:GetShipType() .. " - " .. info.entityCount .. " entities")
        end
    end
end)

-- Update timer
timer.Create("HyperdriveShipCoreUpdate", 2, 0, function()
    HYPERDRIVE.ShipCore.UpdateAllShips()
end)

print("[Hyperdrive] Ship Core system loaded")
