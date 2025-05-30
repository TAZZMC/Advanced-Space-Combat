-- Hyperdrive Engine - Server-side code
-- Uses the new Hyperdrive Ship Core system for entity detection

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_phx/construct/metal_plate1.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Initialize hyperdrive properties
    self:SetEnergy(0)
    self:SetCharging(false)
    self:SetCooldown(0)
    self:SetDestination(Vector(0, 0, 0))
    self:SetJumpReady(false)

    -- Engine configuration
    self.MaxEnergy = 1000
    self.ChargeRate = 50 -- Energy per second
    self.JumpCost = 800
    self.CooldownTime = 5
    self.JumpRange = 50000

    -- Ship detection
    self.LastShipUpdate = 0
    self.ShipUpdateInterval = 1.0
    self.DetectedEntities = {}
    self.DetectedPlayers = {}

    -- Create ship in our ship core system
    if HYPERDRIVE.ShipCore then
        timer.Simple(0.1, function()
            if IsValid(self) then
                HYPERDRIVE.ShipCore.DetectShipForEngine(self)
            end
        end)
    end

    print("[Hyperdrive] Engine initialized: " .. self:EntIndex())
end

function ENT:Think()
    local currentTime = CurTime()

    -- Update energy and charging
    self:UpdateEnergy(currentTime)

    -- Update cooldown
    self:UpdateCooldown(currentTime)

    -- Update ship detection
    self:UpdateShipDetection(currentTime)

    self:NextThink(currentTime + 0.1)
    return true
end

function ENT:UpdateEnergy(currentTime)
    if self:GetCharging() then
        local energy = self:GetEnergy()
        local newEnergy = math.min(energy + (self.ChargeRate * 0.1), self.MaxEnergy)
        self:SetEnergy(newEnergy)

        -- Check if fully charged
        if newEnergy >= self.MaxEnergy then
            self:SetCharging(false)
            self:SetJumpReady(true)
            print("[Hyperdrive] Engine " .. self:EntIndex() .. " fully charged")
        end
    end
end

function ENT:UpdateCooldown(currentTime)
    local cooldown = self:GetCooldown()
    if cooldown > 0 then
        local newCooldown = math.max(cooldown - 0.1, 0)
        self:SetCooldown(newCooldown)

        if newCooldown <= 0 then
            print("[Hyperdrive] Engine " .. self:EntIndex() .. " cooldown complete")
        end
    end
end

function ENT:UpdateShipDetection(currentTime)
    if currentTime - self.LastShipUpdate < self.ShipUpdateInterval then
        return
    end

    self.LastShipUpdate = currentTime

    -- Update ship data using our ship core system
    if HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShip(self)
        if ship then
            ship:Update()
            self.DetectedEntities = ship:GetEntities()
            self.DetectedPlayers = ship:GetPlayers()
        end
    else
        -- Fallback detection
        self.DetectedEntities = self:GetNearbyEntities()
        self.DetectedPlayers = self:GetPlayersInShip()
    end
end

-- Get nearby entities for jumping (using our ship core system)
function ENT:GetNearbyEntities(radius)
    if HYPERDRIVE.ShipCore then
        -- Use our advanced ship detection system
        return HYPERDRIVE.ShipCore.GetAttachedEntities(self, radius)
    else
        -- Fallback to basic sphere detection
        radius = radius or 1500
        local pos = self:GetPos()
        local entities = {}

        for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
            if IsValid(ent) and ent ~= self and not ent:IsPlayer() then
                table.insert(entities, ent)
            end
        end

        return entities
    end
end

-- Get players in ship
function ENT:GetPlayersInShip()
    if HYPERDRIVE.ShipCore then
        return HYPERDRIVE.ShipCore.GetPlayersInShip(self)
    else
        -- Fallback to basic sphere detection
        local pos = self:GetPos()
        local players = {}

        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() and ply:GetPos():Distance(pos) <= 2000 then
                table.insert(players, ply)
            end
        end

        return players
    end
end

-- Get ship information
function ENT:GetShipInfo()
    if HYPERDRIVE.ShipCore then
        return HYPERDRIVE.ShipCore.GetShipInfo(self)
    else
        return {
            entities = self:GetNearbyEntities(),
            players = self:GetPlayersInShip(),
            center = self:GetPos(),
            orientation = self:GetAngles(),
            shipType = "unknown"
        }
    end
end

-- Start charging the engine
function ENT:StartCharging()
    if self:GetCooldown() > 0 then
        return false, "Engine is on cooldown"
    end

    if self:GetCharging() then
        return false, "Engine is already charging"
    end

    if self:GetEnergy() >= self.MaxEnergy then
        self:SetJumpReady(true)
        return true, "Engine already charged"
    end

    self:SetCharging(true)
    self:SetJumpReady(false)

    -- Create world effects around ship
    if HYPERDRIVE.WorldEffects and HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShip(self)
        if ship then
            HYPERDRIVE.WorldEffects.CreateChargingEffects(self, ship)
        end
    end

    print("[Hyperdrive] Engine " .. self:EntIndex() .. " started charging")
    return true, "Charging started"
end

-- Stop charging
function ENT:StopCharging()
    self:SetCharging(false)
    print("[Hyperdrive] Engine " .. self:EntIndex() .. " stopped charging")
end

-- Set destination
function ENT:SetDestinationPos(pos)
    if not isvector(pos) then
        return false, "Invalid destination"
    end

    local distance = self:GetPos():Distance(pos)
    if distance > self.JumpRange then
        return false, "Destination too far (max: " .. self.JumpRange .. ")"
    end

    self:SetDestination(pos)
    return true, "Destination set"
end

-- Perform hyperdrive jump
function ENT:StartJump()
    if not self:GetJumpReady() then
        return false, "Engine not ready"
    end

    if self:GetEnergy() < self.JumpCost then
        return false, "Insufficient energy"
    end

    local destination = self:GetDestination()
    if destination == Vector(0, 0, 0) then
        return false, "No destination set"
    end

    -- Get entities and players to move
    local entities = self.DetectedEntities or self:GetNearbyEntities()
    local players = self.DetectedPlayers or self:GetPlayersInShip()

    print("[Hyperdrive] Starting jump with " .. #entities .. " entities and " .. #players .. " players")

    -- Perform the jump
    local success = self:PerformJump(entities, players, destination)

    if success then
        -- Consume energy and start cooldown
        self:SetEnergy(self:GetEnergy() - self.JumpCost)
        self:SetJumpReady(false)
        self:SetCooldown(self.CooldownTime)

        print("[Hyperdrive] Jump completed successfully")
        return true, "Jump successful"
    else
        return false, "Jump failed"
    end
end

-- Perform the actual jump
function ENT:PerformJump(entities, players, destination)
    local currentPos = self:GetPos()
    local currentAng = self:GetAngles()

    -- Create hyperspace window effect
    if HYPERDRIVE.WorldEffects and HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShip(self)
        if ship then
            -- Entry window
            HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(self, ship, "enter")

            -- Starlines during travel
            timer.Simple(0.5, function()
                if IsValid(self) and ship then
                    HYPERDRIVE.WorldEffects.CreateStarlinesEffect(self, ship)
                end
            end)

            -- Exit window at destination
            timer.Simple(2.5, function()
                if IsValid(self) and ship then
                    -- Update ship position for exit effect
                    ship.center = destination
                    HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(self, ship, "exit")
                end
            end)
        end
    end

    -- Delay actual movement to sync with effects
    timer.Simple(1.0, function()
        if not IsValid(self) then return end

        -- Use ship core system for coordinated movement
        if HYPERDRIVE.ShipCore then
            HYPERDRIVE.ShipCore.MoveShip(self, destination, currentAng)
        else
            -- Fallback: move entities individually
            local offset = destination - currentPos

            -- Move entities
            for _, ent in ipairs(entities) do
                if IsValid(ent) then
                    local entPos = ent:GetPos()
                    local newPos = entPos + offset
                    ent:SetPos(newPos)

                    local phys = ent:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:SetPos(newPos)
                        phys:Wake()
                    end
                end
            end

            -- Move players
            for _, ply in ipairs(players) do
                if IsValid(ply) then
                    local plyPos = ply:GetPos()
                    local newPos = plyPos + offset
                    ply:SetPos(newPos)
                end
            end
        end
    end)

    return true
end

-- Wire inputs
function ENT:TriggerInput(iname, value)
    if iname == "Jump" and value > 0 then
        self:StartJump()
    elseif iname == "SetDestinationX" then
        local dest = self:GetDestination()
        self:SetDestinationPos(Vector(value, dest.y, dest.z))
    elseif iname == "SetDestinationY" then
        local dest = self:GetDestination()
        self:SetDestinationPos(Vector(dest.x, value, dest.z))
    elseif iname == "SetDestinationZ" then
        local dest = self:GetDestination()
        self:SetDestinationPos(Vector(dest.x, dest.y, value))
    elseif iname == "SetDestination" and isvector(value) then
        self:SetDestinationPos(value)
    elseif iname == "Abort" and value > 0 then
        self:StopCharging()
    elseif iname == "SetEnergy" then
        self:SetEnergy(math.Clamp(value, 0, self.MaxEnergy))
    end
end

-- Clean up
function ENT:OnRemove()
    if HYPERDRIVE.ShipCore then
        HYPERDRIVE.ShipCore.RemoveShip(self)
    end

    print("[Hyperdrive] Engine removed: " .. self:EntIndex())
end
