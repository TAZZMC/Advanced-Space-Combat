-- Hyperdrive Hyperspace Dimension System
-- Creates a separate dimension where players can move around during hyperspace travel
-- RE-ENABLED: This system provides the actual hyperspace dimension functionality

if CLIENT then return end

-- Initialize hyperspace dimension system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.HyperspaceDimension = HYPERDRIVE.HyperspaceDimension or {}

print("[Hyperdrive] Hyperspace dimension system loading...")

-- Hyperspace dimension configuration
local HYPERSPACE_OFFSET = Vector(0, 0, 50000) -- Offset for hyperspace dimension
local HYPERSPACE_BOUNDS = 10000 -- Size of hyperspace area

-- Active hyperspace travels
local activeHyperspaceTravel = {}
local hyperspaceEntities = {}

-- Network strings
util.AddNetworkString("hyperdrive_hyperspace_enter")
util.AddNetworkString("hyperdrive_hyperspace_exit")
util.AddNetworkString("hyperdrive_hyperspace_status")

-- Create hyperspace dimension area
function HYPERDRIVE.HyperspaceDimension.CreateHyperspaceArea(centerPos, size)
    local hyperspacePos = centerPos + HYPERSPACE_OFFSET

    -- Create invisible walls around hyperspace area
    local walls = {}
    local wallPositions = {
        {pos = hyperspacePos + Vector(size/2, 0, 0), ang = Angle(0, 90, 0)},
        {pos = hyperspacePos + Vector(-size/2, 0, 0), ang = Angle(0, -90, 0)},
        {pos = hyperspacePos + Vector(0, size/2, 0), ang = Angle(0, 0, 0)},
        {pos = hyperspacePos + Vector(0, -size/2, 0), ang = Angle(0, 180, 0)},
        {pos = hyperspacePos + Vector(0, 0, size/2), ang = Angle(90, 0, 0)},
        {pos = hyperspacePos + Vector(0, 0, -size/2), ang = Angle(-90, 0, 0)}
    }

    for i, wallData in ipairs(wallPositions) do
        local wall = ents.Create("prop_physics")
        if IsValid(wall) then
            wall:SetModel("models/hunter/plates/plate4x4.mdl")  -- Larger walls
            wall:SetPos(wallData.pos)
            wall:SetAngles(wallData.ang)
            wall:Spawn()
            wall:SetMaterial("models/effects/vol_light001")  -- Energy-like material
            wall:SetColor(Color(100, 150, 255, 100))  -- More visible
            wall:SetCollisionGroup(COLLISION_GROUP_WORLD)
            wall:GetPhysicsObject():EnableMotion(false)
            wall:SetNoDraw(false) -- Make walls visible in hyperspace
            wall.IsHyperspaceWall = true  -- Mark as hyperspace wall

            table.insert(walls, wall)
        end
    end

    return walls, hyperspacePos
end

-- Start hyperspace travel for a ship and its occupants
function HYPERDRIVE.HyperspaceDimension.StartHyperspaceTravel(engine, destination, travelTime)
    if not IsValid(engine) then
        print("[Hyperdrive Dimension] Error: Invalid engine")
        return false
    end

    if not destination or not isvector(destination) then
        print("[Hyperdrive Dimension] Error: Invalid destination")
        return false
    end

    local shipPos = engine:GetPos()
    local shipAng = engine:GetAngles()

    print("[Hyperdrive Dimension] Starting hyperspace travel:")
    print("  Engine: " .. tostring(engine))
    print("  From: " .. tostring(shipPos))
    print("  To: " .. tostring(destination))
    print("  Travel Time: " .. tostring(travelTime or 3))

    -- Find all entities to move to hyperspace
    local entitiesToMove = {}
    local searchRadius = 1000

    -- Find attached vehicle
    local attachedVehicle = engine:GetAttachedVehicle()
    if IsValid(attachedVehicle) then
        table.insert(entitiesToMove, attachedVehicle)
        searchRadius = math.max(searchRadius, attachedVehicle:BoundingRadius() * 2)
    end

    -- Find all entities within ship bounds
    local nearbyEnts = ents.FindInSphere(shipPos, searchRadius)
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent ~= engine then
            -- Include players, vehicles, props, and other ship components
            if ent:IsPlayer() or ent:IsVehicle() or ent:GetClass() == "prop_physics" or
               ent:GetClass():find("hyperdrive") or ent:GetClass():find("life_support") or
               ent:GetClass():find("sb_") or ent:GetClass():find("spacebuild") then
                table.insert(entitiesToMove, ent)
            end
        end
    end

    -- Always include the engine itself
    table.insert(entitiesToMove, engine)

    -- Create hyperspace area
    local walls, hyperspaceCenter = HYPERDRIVE.HyperspaceDimension.CreateHyperspaceArea(shipPos, HYPERSPACE_BOUNDS)

    -- Store travel data
    local travelId = engine:EntIndex()
    activeHyperspaceTravel[travelId] = {
        engine = engine,
        originalPos = shipPos,
        originalAng = shipAng,
        destination = destination,
        hyperspaceCenter = hyperspaceCenter,
        entities = entitiesToMove,
        walls = walls,
        startTime = CurTime(),
        travelTime = travelTime or 3,
        completed = false
    }

    -- Move all entities to hyperspace
    for _, ent in ipairs(entitiesToMove) do
        if IsValid(ent) then
            local relativePos = ent:GetPos() - shipPos
            local relativeAng = ent:GetAngles() - shipAng

            local newPos = hyperspaceCenter + relativePos
            local newAng = shipAng + relativeAng

            -- Store original position for restoration
            ent.HyperspaceOriginalPos = ent:GetPos()
            ent.HyperspaceOriginalAng = ent:GetAngles()
            ent.HyperspaceTravelId = travelId

            -- Move to hyperspace
            ent:SetPos(newPos)
            ent:SetAngles(newAng)

            -- Special handling for players
            if ent:IsPlayer() then
                -- Notify player they're in hyperspace
                net.Start("hyperdrive_hyperspace_enter")
                net.WriteVector(newPos)
                net.WriteFloat(travelTime)
                net.Send(ent)

                -- Set player's view to hyperspace
                ent:SetNoDraw(false)
                ent:Freeze(false) -- Allow movement in hyperspace
                ent:SetGravity(0.5) -- Reduced gravity in hyperspace

                -- Add to hyperspace entities list
                hyperspaceEntities[ent] = travelId

                -- Chat notification
                ent:ChatPrint("[Hyperdrive] Entered hyperspace dimension - you can move around!")
                ent:ChatPrint("[Hyperdrive] Travel time: " .. travelTime .. " seconds")

                print("[Hyperdrive Dimension] Player " .. ent:Nick() .. " entered hyperspace")
            end

            -- Handle vehicles
            if ent:IsVehicle() then
                -- Keep vehicle functional in hyperspace
                ent:SetNoDraw(false)
            end
        end
    end

    -- Schedule hyperspace exit
    timer.Create("HyperspaceTravel_" .. travelId, travelTime, 1, function()
        HYPERDRIVE.HyperspaceDimension.EndHyperspaceTravel(travelId)
    end)

    print("[Hyperdrive] Started hyperspace travel for " .. #entitiesToMove .. " entities")
    return true
end

-- End hyperspace travel and move entities to destination
function HYPERDRIVE.HyperspaceDimension.EndHyperspaceTravel(travelId)
    local travelData = activeHyperspaceTravel[travelId]
    if not travelData then return false end

    local engine = travelData.engine
    local destination = travelData.destination
    local originalPos = travelData.originalPos

    if not IsValid(engine) then
        -- Clean up if engine is gone
        HYPERDRIVE.HyperspaceDimension.CleanupHyperspaceTravel(travelId)
        return false
    end

    -- Calculate offset from original ship position to destination
    local positionOffset = destination - originalPos

    -- Move all entities to destination
    for _, ent in ipairs(travelData.entities) do
        if IsValid(ent) and ent.HyperspaceTravelId == travelId then
            local originalEntPos = ent.HyperspaceOriginalPos
            local originalEntAng = ent.HyperspaceOriginalAng

            if originalEntPos then
                local newPos = originalEntPos + positionOffset
                local newAng = originalEntAng

                -- Move to destination
                ent:SetPos(newPos)
                ent:SetAngles(newAng)

                -- Special handling for players
                if ent:IsPlayer() then
                    -- Notify player they've exited hyperspace
                    net.Start("hyperdrive_hyperspace_exit")
                    net.WriteVector(newPos)
                    net.Send(ent)

                    -- Restore normal gravity
                    ent:SetGravity(1)

                    -- Remove from hyperspace entities list
                    hyperspaceEntities[ent] = nil

                    -- Chat notification
                    ent:ChatPrint("[Hyperdrive] Exited hyperspace dimension!")

                    print("[Hyperdrive Dimension] Player " .. ent:Nick() .. " exited hyperspace")
                end

                -- Clean up hyperspace data
                ent.HyperspaceOriginalPos = nil
                ent.HyperspaceOriginalAng = nil
                ent.HyperspaceTravelId = nil
            end
        end
    end

    -- Clean up hyperspace area
    HYPERDRIVE.HyperspaceDimension.CleanupHyperspaceTravel(travelId)

    print("[Hyperdrive] Completed hyperspace travel to destination")
    return true
end

-- Clean up hyperspace travel data
function HYPERDRIVE.HyperspaceDimension.CleanupHyperspaceTravel(travelId)
    local travelData = activeHyperspaceTravel[travelId]
    if not travelData then return end

    -- Remove hyperspace walls
    for _, wall in ipairs(travelData.walls) do
        if IsValid(wall) then
            wall:Remove()
        end
    end

    -- Clean up any remaining entities
    for _, ent in ipairs(travelData.entities) do
        if IsValid(ent) then
            ent.HyperspaceOriginalPos = nil
            ent.HyperspaceOriginalAng = nil
            ent.HyperspaceTravelId = nil

            if ent:IsPlayer() then
                hyperspaceEntities[ent] = nil
            end
        end
    end

    -- Remove timer
    timer.Remove("HyperspaceTravel_" .. travelId)

    -- Remove travel data
    activeHyperspaceTravel[travelId] = nil
end

-- Check if player is in hyperspace
function HYPERDRIVE.HyperspaceDimension.IsPlayerInHyperspace(ply)
    return hyperspaceEntities[ply] ~= nil
end

-- Get hyperspace travel info for player
function HYPERDRIVE.HyperspaceDimension.GetPlayerHyperspaceInfo(ply)
    local travelId = hyperspaceEntities[ply]
    if not travelId then return nil end

    return activeHyperspaceTravel[travelId]
end

-- Get count of active hyperspace travels (for debugging)
function HYPERDRIVE.HyperspaceDimension.GetActiveCount()
    return table.Count(activeHyperspaceTravel)
end

-- Get count of entities in hyperspace (for debugging)
function HYPERDRIVE.HyperspaceDimension.GetHyperspaceEntityCount()
    return table.Count(hyperspaceEntities)
end

-- Get all active travel data (for debugging)
function HYPERDRIVE.HyperspaceDimension.GetActiveTravels()
    return activeHyperspaceTravel
end

-- Get all hyperspace entities (for debugging)
function HYPERDRIVE.HyperspaceDimension.GetHyperspaceEntities()
    return hyperspaceEntities
end

-- Emergency exit from hyperspace
function HYPERDRIVE.HyperspaceDimension.EmergencyExit(ply)
    local travelId = hyperspaceEntities[ply]
    if not travelId then return false end

    local travelData = activeHyperspaceTravel[travelId]
    if not travelData then return false end

    -- Move player back to original position
    if ply.HyperspaceOriginalPos then
        ply:SetPos(ply.HyperspaceOriginalPos)
        ply:SetAngles(ply.HyperspaceOriginalAng or Angle(0, 0, 0))

        -- Clean up player data
        ply.HyperspaceOriginalPos = nil
        ply.HyperspaceOriginalAng = nil
        ply.HyperspaceTravelId = nil
        hyperspaceEntities[ply] = nil

        -- Notify player
        net.Start("hyperdrive_hyperspace_exit")
        net.WriteVector(ply:GetPos())
        net.Send(ply)

        ply:ChatPrint("[Hyperdrive] Emergency exit from hyperspace!")
        return true
    end

    return false
end

-- Console command for emergency exit
concommand.Add("hyperdrive_emergency_exit", function(ply, cmd, args)
    if not IsValid(ply) then return end

    if HYPERDRIVE.HyperspaceDimension.EmergencyExit(ply) then
        ply:ChatPrint("[Hyperdrive] Emergency exit successful!")
    else
        ply:ChatPrint("[Hyperdrive] You are not in hyperspace!")
    end
end)

-- Clean up on player disconnect
hook.Add("PlayerDisconnected", "HyperdriveHyperspaceCleanup", function(ply)
    if hyperspaceEntities[ply] then
        hyperspaceEntities[ply] = nil
    end
end)

-- Periodic cleanup of invalid travel data
timer.Create("HyperdriveHyperspaceCleanup", 30, 0, function()
    for travelId, travelData in pairs(activeHyperspaceTravel) do
        if not IsValid(travelData.engine) or
           (CurTime() - travelData.startTime) > (travelData.travelTime + 10) then
            HYPERDRIVE.HyperspaceDimension.CleanupHyperspaceTravel(travelId)
        end
    end
end)

print("[Hyperdrive] Hyperspace Dimension system loaded")
