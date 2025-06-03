-- Enhanced Ship Core System v5.1.0
-- Comprehensive ship detection and management with real-time updates
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.ShipCore = HYPERDRIVE.ShipCore or {}

print("[Hyperdrive] Ship Core System v5.1.0 - Ultimate Edition with Enhanced Real-Time Updates")

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
        shipName = "Unnamed Ship", -- Ship name
        classification = {},
        constraints = {},
        parentEntities = {},
        childEntities = {},
        frontDirection = Vector(1, 0, 0), -- Default forward direction
        frontIndicator = nil, -- Green arrow entity
        showFrontIndicator = false -- Whether to show the indicator
    }
    setmetatable(ship, ShipClass)

    -- Create front direction indicator
    ship:CreateFrontIndicator()

    -- Initialize ship name from core if available
    if IsValid(coreEntity) and coreEntity.GetShipName then
        ship.shipName = coreEntity:GetShipName() or "Unnamed Ship"
    end

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

    -- Update front indicator if visible
    if self.showFrontIndicator then
        self:UpdateFrontIndicator()
    end

    -- Sync ship name with core
    if IsValid(self.core) and self.core.GetShipName then
        local coreName = self.core:GetShipName()
        if coreName and coreName ~= self.shipName then
            self.shipName = coreName
        end
    end

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

-- Create front direction indicator (enhanced green arrow)
function ShipClass:CreateFrontIndicator()
    if not IsValid(self.core) then return end

    -- Remove existing indicator
    self:RemoveFrontIndicator()

    -- Create enhanced arrow indicator with better visibility
    local indicator = ents.Create("prop_physics")
    if not IsValid(indicator) then return end

    -- Use a more arrow-like model
    indicator:SetModel("models/hunter/misc/cone1x1.mdl") -- Cone shape for better arrow appearance
    indicator:SetPos(self.core:GetPos() + self.core:GetForward() * 150) -- Further out for better visibility
    indicator:SetAngles(self.core:GetAngles() + Angle(0, 0, 90)) -- Rotate to point forward
    indicator:Spawn()
    indicator:Activate()

    -- Enhanced green appearance with glow
    indicator:SetColor(Color(0, 255, 0, 220))
    indicator:SetMaterial("models/debug/debugwhite")
    indicator:SetRenderMode(RENDERMODE_TRANSALPHA)
    indicator:SetModelScale(0.8) -- Slightly smaller for better aesthetics

    -- Make it non-solid and non-colliding
    indicator:SetSolid(SOLID_NONE)
    indicator:SetCollisionGroup(COLLISION_GROUP_WORLD)
    indicator:SetNotSolid(true)

    -- Remove physics
    local phys = indicator:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:EnableCollisions(false)
    end

    -- Parent to core for automatic movement
    indicator:SetParent(self.core)

    -- Store reference
    self.frontIndicator = indicator

    -- Show by default for better user experience
    self:ShowFrontIndicator()

    print("[Ship Core] Enhanced front indicator created for " .. self.shipType)
end

-- Remove front direction indicator
function ShipClass:RemoveFrontIndicator()
    if IsValid(self.frontIndicator) then
        self.frontIndicator:Remove()
        self.frontIndicator = nil
    end
end

-- Show front direction indicator
function ShipClass:ShowFrontIndicator()
    if IsValid(self.frontIndicator) then
        self.frontIndicator:SetNoDraw(false)
        self.showFrontIndicator = true

        -- Update position
        self:UpdateFrontIndicator()
    end
end

-- Hide front direction indicator
function ShipClass:HideFrontIndicator()
    if IsValid(self.frontIndicator) then
        self.frontIndicator:SetNoDraw(true)
        self.showFrontIndicator = false
    end
end

-- Update front indicator position and orientation
function ShipClass:UpdateFrontIndicator()
    if not IsValid(self.frontIndicator) or not IsValid(self.core) then return end

    -- Calculate position in front of ship center
    local shipSize = (self.bounds.max - self.bounds.min):Length()
    local distance = math.max(100, shipSize * 0.6) -- Distance in front of ship

    local frontPos = self.center + self.frontDirection * distance

    -- Update indicator position and orientation
    self.frontIndicator:SetPos(frontPos)
    self.frontIndicator:SetAngles(self.orientation)

    -- Create arrow effect with multiple spheres
    self:CreateArrowEffect(frontPos)
end

-- Create arrow effect using multiple small entities
function ShipClass:CreateArrowEffect(pos)
    if not self.showFrontIndicator then return end

    -- Clean up old arrow entities
    if self.arrowEntities then
        for _, ent in ipairs(self.arrowEntities) do
            if IsValid(ent) then
                ent:Remove()
            end
        end
    end
    self.arrowEntities = {}

    -- Create arrow shape with small spheres
    local forward = self.frontDirection
    local right = forward:Cross(Vector(0, 0, 1)):GetNormalized()
    local up = forward:Cross(right):GetNormalized()

    -- Arrow shaft
    for i = 0, 3 do
        local shaftPos = pos - forward * (i * 15)
        local sphere = self:CreateIndicatorSphere(shaftPos, 5)
        if IsValid(sphere) then
            table.insert(self.arrowEntities, sphere)
        end
    end

    -- Arrow head
    local headPos = pos + forward * 20
    local headSphere = self:CreateIndicatorSphere(headPos, 8)
    if IsValid(headSphere) then
        table.insert(self.arrowEntities, headSphere)
    end

    -- Arrow wings
    local wingPos1 = pos - forward * 10 + right * 15
    local wingPos2 = pos - forward * 10 - right * 15
    local wing1 = self:CreateIndicatorSphere(wingPos1, 6)
    local wing2 = self:CreateIndicatorSphere(wingPos2, 6)

    if IsValid(wing1) then table.insert(self.arrowEntities, wing1) end
    if IsValid(wing2) then table.insert(self.arrowEntities, wing2) end
end

-- Create a small green sphere for the arrow
function ShipClass:CreateIndicatorSphere(pos, size)
    local sphere = ents.Create("prop_physics")
    if not IsValid(sphere) then return nil end

    sphere:SetModel("models/hunter/misc/sphere025x025.mdl")
    sphere:SetPos(pos)
    sphere:SetModelScale(size / 12.5) -- Scale to desired size
    sphere:Spawn()
    sphere:Activate()

    -- Make it green and glowing
    sphere:SetColor(Color(0, 255, 0, 180))
    sphere:SetMaterial("models/debug/debugwhite")
    sphere:SetRenderMode(RENDERMODE_TRANSALPHA)

    -- Make it non-solid
    sphere:SetSolid(SOLID_NONE)
    sphere:SetCollisionGroup(COLLISION_GROUP_WORLD)
    sphere:SetNotSolid(true)

    -- Remove physics
    local phys = sphere:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:EnableCollisions(false)
    end

    -- Auto-remove after 5 seconds
    timer.Simple(5, function()
        if IsValid(sphere) then
            sphere:Remove()
        end
    end)

    return sphere
end

-- Set ship front direction
function ShipClass:SetFrontDirection(direction)
    if isvector(direction) then
        self.frontDirection = direction:GetNormalized()
        self:UpdateFrontIndicator()
    end
end

-- Get ship front direction
function ShipClass:GetFrontDirection()
    return self.frontDirection
end

-- Get ship name
function ShipClass:GetShipName()
    return self.shipName or "Unnamed Ship"
end

-- Set ship name
function ShipClass:SetShipName(name)
    if name and type(name) == "string" then
        self.shipName = name

        -- Update core entity if available
        if IsValid(self.core) and self.core.SetShipName then
            self.core:SetShipName(name)
        end
    end
end

-- Auto-detect front direction based on ship shape
function ShipClass:AutoDetectFrontDirection()
    if #self.entities < 2 then
        -- Not enough entities to determine direction
        self.frontDirection = self.core:GetForward()
        return
    end

    -- Find the longest axis of the ship
    local size = self.bounds.max - self.bounds.min
    local longestAxis = Vector(1, 0, 0) -- Default forward

    if size.y > size.x and size.y > size.z then
        longestAxis = Vector(0, 1, 0) -- Ship is longer in Y axis
    elseif size.z > size.x and size.z > size.y then
        longestAxis = Vector(0, 0, 1) -- Ship is longer in Z axis
    end

    -- Check entity distribution to determine which end is front
    local centerPos = self.center
    local positiveCount = 0
    local negativeCount = 0

    for _, ent in ipairs(self.entities) do
        if IsValid(ent) then
            local entPos = ent:GetPos()
            local relativePos = entPos - centerPos
            local dotProduct = relativePos:Dot(longestAxis)

            if dotProduct > 0 then
                positiveCount = positiveCount + 1
            else
                negativeCount = negativeCount + 1
            end
        end
    end

    -- If more entities are in the negative direction, flip the axis
    if negativeCount > positiveCount then
        longestAxis = -longestAxis
    end

    -- Use core's orientation to refine the direction
    local coreForward = self.core:GetForward()
    local dotWithCore = longestAxis:Dot(coreForward)

    -- If the detected direction is opposite to core forward, consider flipping
    if math.abs(dotWithCore) > 0.5 then
        if dotWithCore < 0 then
            longestAxis = -longestAxis
        end
    end

    self.frontDirection = longestAxis:GetNormalized()
    print("[Hyperdrive] Auto-detected front direction: " .. tostring(self.frontDirection) .. " for " .. self.shipType)
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

-- Validate ship core uniqueness (ENFORCES ONE CORE PER SHIP)
function HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness(core)
    if not IsValid(core) or core:GetClass() ~= "ship_core" then
        return false, "Invalid ship core"
    end

    if core.InvalidDueToDuplicate then
        return false, "Ship core marked as duplicate - remove extra cores from ship"
    end

    -- Find all ship cores within range
    local cores = ents.FindInSphere(core:GetPos(), 2000)
    local nearbyShipCores = {}

    for _, ent in ipairs(cores) do
        if IsValid(ent) and ent:GetClass() == "ship_core" and ent ~= core then
            table.insert(nearbyShipCores, ent)
        end
    end

    if #nearbyShipCores == 0 then
        return true, "Ship core is unique"
    end

    -- Check if any nearby cores are connected to the same ship structure
    local testShip = HYPERDRIVE.ShipCore.CreateShip(core)
    if not testShip then
        return true, "Ship core is unique (no ship detected)"
    end

    local coreEntities = testShip:GetEntities()
    local conflictingCores = {}

    for _, otherCore in ipairs(nearbyShipCores) do
        -- Check if other core is part of this ship
        for _, ent in ipairs(coreEntities) do
            if ent == otherCore then
                table.insert(conflictingCores, otherCore)
                break
            end
        end
    end

    -- Clean up test ship
    HYPERDRIVE.ShipCore.Ships[core:EntIndex()] = nil

    if #conflictingCores > 0 then
        return false, "Multiple ship cores detected in same ship structure - remove " .. #conflictingCores .. " duplicate core(s)"
    end

    return true, "Ship core is unique"
end

-- Check for duplicate ship cores and mark them
function HYPERDRIVE.ShipCore.CheckForDuplicateCores()
    local allCores = {}

    -- Find all ship cores
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            table.insert(allCores, ent)
        end
    end

    print("[Hyperdrive Ship Core] Checking " .. #allCores .. " ship cores for duplicates...")

    local duplicatesFound = 0
    local processedCores = {}

    for _, core in ipairs(allCores) do
        if not processedCores[core:EntIndex()] then
            local valid, message = HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness(core)

            if not valid then
                core.InvalidDueToDuplicate = true
                core:SetColor(Color(255, 100, 100, 200))
                duplicatesFound = duplicatesFound + 1
                print("[Hyperdrive Ship Core] Core " .. core:EntIndex() .. " marked as duplicate: " .. message)
            else
                -- Clear any previous duplicate marking
                core.InvalidDueToDuplicate = false
                core:SetColor(Color(255, 255, 255, 255))
            end

            processedCores[core:EntIndex()] = true
        end
    end

    if duplicatesFound > 0 then
        print("[Hyperdrive Ship Core] Found " .. duplicatesFound .. " duplicate ship cores - marked as invalid")
    else
        print("[Hyperdrive Ship Core] No duplicate ship cores found")
    end

    return duplicatesFound
end

-- Automatic ship detection for hyperdrive engines (ENFORCES ONE CORE PER SHIP)
function HYPERDRIVE.ShipCore.DetectShipForEngine(engine)
    if not IsValid(engine) then return nil end

    -- Check if ship already exists
    local existingShip = HYPERDRIVE.ShipCore.GetShip(engine)
    if existingShip then
        existingShip:Update()
        return existingShip
    end

    -- Find all ship cores within range to check for conflicts
    local cores = ents.FindInSphere(engine:GetPos(), 2000)
    local shipCores = {}

    for _, ent in ipairs(cores) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            table.insert(shipCores, ent)
        end
    end

    -- If multiple ship cores found, enforce one core per ship rule
    if #shipCores > 1 then
        print("[Hyperdrive Ship Core] WARNING: Multiple ship cores detected near engine " .. engine:EntIndex())
        print("[Hyperdrive Ship Core] Found " .. #shipCores .. " ship cores - checking for conflicts")

        -- Check which cores are connected to the same ship structure
        local connectedCores = {}
        for _, core in ipairs(shipCores) do
            -- Test if this core would include the engine in its ship
            local testShip = HYPERDRIVE.ShipCore.CreateShip(core)
            if testShip then
                local entities = testShip:GetEntities()
                for _, ent in ipairs(entities) do
                    if ent == engine then
                        table.insert(connectedCores, core)
                        break
                    end
                end
                -- Clean up test ship
                HYPERDRIVE.ShipCore.Ships[core:EntIndex()] = nil
            end
        end

        -- ENFORCE: Only one ship core per ship structure
        if #connectedCores > 1 then
            print("[Hyperdrive Ship Core] ERROR: Multiple ship cores (" .. #connectedCores .. ") connected to same ship structure!")

            -- Find the oldest core (first spawned) to use as primary
            local primaryCore = connectedCores[1]
            local oldestTime = primaryCore:GetCreationTime()

            for i = 2, #connectedCores do
                local core = connectedCores[i]
                if core:GetCreationTime() < oldestTime then
                    oldestTime = core:GetCreationTime()
                    primaryCore = core
                end
            end

            -- Mark other cores as invalid and notify
            for _, core in ipairs(connectedCores) do
                if core ~= primaryCore then
                    core.InvalidDueToDuplicate = true
                    core:SetColor(Color(255, 100, 100, 200)) -- Red tint for invalid cores
                    print("[Hyperdrive Ship Core] Marked core " .. core:EntIndex() .. " as INVALID (duplicate)")

                    -- Add warning message to core
                    if core.SetOverlayText then
                        core:SetOverlayText("INVALID: Multiple cores detected\nRemove duplicate cores")
                    end
                end
            end

            print("[Hyperdrive Ship Core] Using primary core " .. primaryCore:EntIndex() .. " (oldest)")
            return HYPERDRIVE.ShipCore.CreateShip(primaryCore)
        elseif #connectedCores == 1 then
            -- Single core connected - normal operation
            return HYPERDRIVE.ShipCore.CreateShip(connectedCores[1])
        end
    elseif #shipCores == 1 then
        -- Single ship core found - normal operation
        return HYPERDRIVE.ShipCore.CreateShip(shipCores[1])
    end

    -- No ship cores found - create ship with engine as core (fallback)
    print("[Hyperdrive Ship Core] No ship cores found - engine cannot operate without ship core")
    return nil
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

-- Console commands for front indicator control
if SERVER then
    concommand.Add("hyperdrive_show_front_indicator", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core or hyperdrive engine to show front indicator")
            return
        end

        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        ship:ShowFrontIndicator()
        ply:ChatPrint("Front indicator shown for " .. ship.shipType .. " (green arrow)")
    end)

    concommand.Add("hyperdrive_hide_front_indicator", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core or hyperdrive engine to hide front indicator")
            return
        end

        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        ship:HideFrontIndicator()
        ply:ChatPrint("Front indicator hidden for " .. ship.shipType)
    end)

    concommand.Add("hyperdrive_set_front_direction", function(ply, cmd, args)
        if not IsValid(ply) then return end

        if #args < 3 then
            ply:ChatPrint("Usage: hyperdrive_set_front_direction <x> <y> <z>")
            ply:ChatPrint("Example: hyperdrive_set_front_direction 1 0 0 (forward)")
            return
        end

        local x = tonumber(args[1]) or 1
        local y = tonumber(args[2]) or 0
        local z = tonumber(args[3]) or 0
        local direction = Vector(x, y, z)

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core or hyperdrive engine to set front direction")
            return
        end

        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        ship:SetFrontDirection(direction)
        ply:ChatPrint("Front direction set to " .. tostring(direction) .. " for " .. ship.shipType)

        -- Show indicator temporarily
        ship:ShowFrontIndicator()
        timer.Simple(3, function()
            if ship and ship.HideFrontIndicator then
                ship:HideFrontIndicator()
            end
        end)
    end)

    concommand.Add("hyperdrive_auto_detect_front", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core or hyperdrive engine to auto-detect front")
            return
        end

        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        -- Auto-detect front based on ship shape
        ship:AutoDetectFrontDirection()
        ply:ChatPrint("Auto-detected front direction for " .. ship.shipType)

        -- Show indicator temporarily
        ship:ShowFrontIndicator()
        timer.Simple(5, function()
            if ship and ship.HideFrontIndicator then
                ship:HideFrontIndicator()
            end
        end)
    end)

    -- Console command to check for duplicate ship cores
    concommand.Add("hyperdrive_check_duplicate_cores", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then
            ply:ChatPrint("Only admins can use this command")
            return
        end

        local duplicates = HYPERDRIVE.ShipCore.CheckForDuplicateCores()
        local message = "Duplicate core check complete. Found " .. duplicates .. " duplicate cores."

        if IsValid(ply) then
            ply:ChatPrint(message)
        else
            print(message)
        end
    end)

    -- Console command to validate specific ship core
    concommand.Add("hyperdrive_validate_core", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "ship_core" then
            ply:ChatPrint("Look at a ship core to validate it")
            return
        end

        local valid, message = HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness(trace.Entity)
        ply:ChatPrint("Ship core validation: " .. message)

        if not valid then
            ply:ChatPrint("This ship core is marked as invalid due to duplicates")
        end
    end)

    -- Console command to remove duplicate cores (admin only)
    concommand.Add("hyperdrive_remove_duplicate_cores", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then
            ply:ChatPrint("Only admins can use this command")
            return
        end

        local removed = 0
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent:GetClass() == "ship_core" and ent.InvalidDueToDuplicate then
                ent:Remove()
                removed = removed + 1
            end
        end

        local message = "Removed " .. removed .. " duplicate ship cores"
        if IsValid(ply) then
            ply:ChatPrint(message)
        else
            print(message)
        end
    end)
end

-- API functions for front indicator
function HYPERDRIVE.ShipCore.ShowFrontIndicator(coreEntity)
    local ship = HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if ship then
        ship:ShowFrontIndicator()
        return true
    end
    return false
end

function HYPERDRIVE.ShipCore.HideFrontIndicator(coreEntity)
    local ship = HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if ship then
        ship:HideFrontIndicator()
        return true
    end
    return false
end

function HYPERDRIVE.ShipCore.SetFrontDirection(coreEntity, direction)
    local ship = HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if ship and isvector(direction) then
        ship:SetFrontDirection(direction)
        return true
    end
    return false
end

function HYPERDRIVE.ShipCore.GetFrontDirection(coreEntity)
    local ship = HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if ship then
        return ship:GetFrontDirection()
    end
    return Vector(1, 0, 0)
end

function HYPERDRIVE.ShipCore.AutoDetectFrontDirection(coreEntity)
    local ship = HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if ship then
        ship:AutoDetectFrontDirection()
        return true
    end
    return false
end

-- Test command for front indicator system
if SERVER then
    concommand.Add("hyperdrive_test_front_indicator", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core or hyperdrive engine to test front indicator")
            return
        end

        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        ply:ChatPrint("=== Front Indicator Test ===")
        ply:ChatPrint("Ship Type: " .. ship:GetShipType())
        ply:ChatPrint("Entity Count: " .. #ship:GetEntities())
        ply:ChatPrint("Current Front Direction: " .. tostring(ship:GetFrontDirection()))
        ply:ChatPrint("Indicator Visible: " .. tostring(ship.showFrontIndicator))

        -- Test sequence
        ply:ChatPrint("Starting test sequence...")

        -- 1. Auto-detect front
        ship:AutoDetectFrontDirection()
        ply:ChatPrint("1. Auto-detected front: " .. tostring(ship:GetFrontDirection()))

        -- 2. Show indicator
        ship:ShowFrontIndicator()
        ply:ChatPrint("2. Showing green arrow indicator")

        -- 3. Test different directions
        timer.Simple(2, function()
            if IsValid(ply) and ship then
                ship:SetFrontDirection(Vector(0, 1, 0))
                ply:ChatPrint("3. Set front to +Y direction")
            end
        end)

        timer.Simple(4, function()
            if IsValid(ply) and ship then
                ship:SetFrontDirection(Vector(0, 0, 1))
                ply:ChatPrint("4. Set front to +Z direction")
            end
        end)

        timer.Simple(6, function()
            if IsValid(ply) and ship then
                ship:AutoDetectFrontDirection()
                ply:ChatPrint("5. Auto-detected front again: " .. tostring(ship:GetFrontDirection()))
            end
        end)

        timer.Simple(8, function()
            if IsValid(ply) and ship then
                ship:HideFrontIndicator()
                ply:ChatPrint("6. Hidden indicator - test complete!")
            end
        end)
    end)
end

-- Integration with shield system
function HYPERDRIVE.ShipCore.GetShipShieldStatus(coreEntity)
    if not HYPERDRIVE.Shields then return nil end

    local ship = HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if not ship then return nil end

    return HYPERDRIVE.Shields.GetShieldStatus(coreEntity)
end

function HYPERDRIVE.ShipCore.ActivateShipShield(coreEntity)
    if not HYPERDRIVE.Shields then return false end

    local ship = HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if not ship then return false end

    return HYPERDRIVE.Shields.ActivateShield(coreEntity, ship)
end

function HYPERDRIVE.ShipCore.DeactivateShipShield(coreEntity)
    if not HYPERDRIVE.Shields then return false end

    return HYPERDRIVE.Shields.DeactivateShield(coreEntity)
end

-- Integration with hull damage system
function HYPERDRIVE.ShipCore.GetShipHullStatus(coreEntity)
    if not HYPERDRIVE.HullDamage then return nil end

    return HYPERDRIVE.HullDamage.GetHullStatus(coreEntity)
end

function HYPERDRIVE.ShipCore.ApplyHullDamage(coreEntity, damage, damageType, attacker, hitPos)
    if not HYPERDRIVE.HullDamage then return false end

    return HYPERDRIVE.HullDamage.ApplyDamage(coreEntity, damage, damageType, attacker, hitPos)
end

function HYPERDRIVE.ShipCore.RepairShipHull(coreEntity, repairAmount)
    if not HYPERDRIVE.HullDamage then return false end

    return HYPERDRIVE.HullDamage.RepairHull(coreEntity, repairAmount)
end

function HYPERDRIVE.ShipCore.GetHullDamageHistory(coreEntity)
    if not HYPERDRIVE.HullDamage then return {} end

    return HYPERDRIVE.HullDamage.GetDamageHistory(coreEntity)
end

-- Hook into ship detection for automatic shield and hull damage setup
hook.Add("HyperdriveShipDetected", "ShipCoreShieldIntegration", function(ship, engine)
    if HYPERDRIVE.Shields and HYPERDRIVE.Shields.Config.AutoCreateShieldOnDetection then
        timer.Simple(1, function()
            if IsValid(engine) and ship then
                local shield = HYPERDRIVE.Shields.GetShield(engine)
                if not shield then
                    HYPERDRIVE.Shields.CreateShield(engine, ship)
                    print("[Ship Core] Auto-created shield for detected ship: " .. ship:GetShipType())
                end
            end
        end)
    end

    -- Auto-create hull damage system
    if HYPERDRIVE.HullDamage and ship.core and IsValid(ship.core) then
        timer.Simple(1.5, function()
            if IsValid(ship.core) and ship then
                local hull = HYPERDRIVE.HullDamage.GetHullSystem(ship.core)
                if not hull then
                    HYPERDRIVE.HullDamage.CreateHullSystem(ship, ship.core)
                    print("[Ship Core] Auto-created hull damage system for detected ship: " .. ship:GetShipType())
                end
            end
        end)
    end
end)

-- Update timer
timer.Create("HyperdriveShipCoreUpdate", 2, 0, function()
    HYPERDRIVE.ShipCore.UpdateAllShips()
end)

-- Duplicate core detection timer (checks every 30 seconds)
timer.Create("HyperdriveShipCoreDuplicateCheck", 30, 0, function()
    if SERVER then
        HYPERDRIVE.ShipCore.CheckForDuplicateCores()
    end
end)

print("[Hyperdrive] Ship Core system loaded with front indicator, shield integration, and one-core-per-ship enforcement")
