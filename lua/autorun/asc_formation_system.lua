--[[
    Advanced Space Combat - Formation Flying System v3.0.0
    
    Comprehensive formation flying and fleet coordination system with
    multiple formation types, automated positioning, and fleet commands.
]]

-- Initialize Formation System namespace
ASC = ASC or {}
ASC.Formation = ASC.Formation or {}

-- Formation System Configuration
ASC.Formation.Config = {
    -- Core Settings
    Enabled = true,
    UpdateRate = 0.2,
    MaxFleetSize = 12,
    MaxFormationDistance = 2000,
    
    -- Formation Parameters
    DefaultSpacing = 200,
    MinSpacing = 100,
    MaxSpacing = 500,
    FormationAccuracy = 50,
    PositionTolerance = 75,
    
    -- Formation Types
    FormationTypes = {
        LINE = {
            name = "Line Formation",
            description = "Ships arranged in a straight line",
            spacing = 200,
            positions = function(count, spacing)
                local positions = {}
                for i = 1, count do
                    local offset = (i - (count + 1) / 2) * spacing
                    table.insert(positions, Vector(0, offset, 0))
                end
                return positions
            end
        },
        WEDGE = {
            name = "Wedge Formation",
            description = "V-shaped formation with leader at front",
            spacing = 180,
            positions = function(count, spacing)
                local positions = {}
                positions[1] = Vector(0, 0, 0) -- Leader at front
                for i = 2, count do
                    local side = (i % 2 == 0) and -1 or 1
                    local row = math.ceil((i - 1) / 2)
                    table.insert(positions, Vector(-row * spacing * 0.8, side * row * spacing, 0))
                end
                return positions
            end
        },
        DIAMOND = {
            name = "Diamond Formation",
            description = "Diamond-shaped formation",
            spacing = 220,
            positions = function(count, spacing)
                local positions = {}
                positions[1] = Vector(0, 0, 0) -- Center
                if count > 1 then positions[2] = Vector(spacing, 0, 0) end -- Front
                if count > 2 then positions[3] = Vector(-spacing, 0, 0) end -- Back
                if count > 3 then positions[4] = Vector(0, spacing, 0) end -- Right
                if count > 4 then positions[5] = Vector(0, -spacing, 0) end -- Left
                -- Additional ships in outer diamond
                for i = 6, count do
                    local angle = (i - 6) * (360 / (count - 5))
                    local rad = math.rad(angle)
                    local x = math.cos(rad) * spacing * 1.5
                    local y = math.sin(rad) * spacing * 1.5
                    table.insert(positions, Vector(x, y, 0))
                end
                return positions
            end
        },
        CIRCLE = {
            name = "Circle Formation",
            description = "Ships arranged in a circle",
            spacing = 250,
            positions = function(count, spacing)
                local positions = {}
                if count == 1 then
                    positions[1] = Vector(0, 0, 0)
                else
                    for i = 1, count do
                        local angle = (i - 1) * (360 / count)
                        local rad = math.rad(angle)
                        local x = math.cos(rad) * spacing
                        local y = math.sin(rad) * spacing
                        table.insert(positions, Vector(x, y, 0))
                    end
                end
                return positions
            end
        },
        COLUMN = {
            name = "Column Formation",
            description = "Ships in single file",
            spacing = 150,
            positions = function(count, spacing)
                local positions = {}
                for i = 1, count do
                    table.insert(positions, Vector(-(i - 1) * spacing, 0, 0))
                end
                return positions
            end
        }
    },
    
    -- Movement Settings
    FormationSpeed = 0.8,
    CatchUpSpeed = 1.2,
    SlowDownDistance = 300,
    StopDistance = 100,
    
    -- AI Settings
    AutoFormation = true,
    CollisionAvoidance = true,
    LeaderFollowing = true,
    PositionCorrection = true
}

-- Formation System Core
ASC.Formation.Core = {
    -- Active formations
    ActiveFormations = {},
    
    -- Formation counter
    FormationCounter = 0,
    
    -- Create new formation
    CreateFormation = function(leader, formationType, spacing)
        if not IsValid(leader) then
            return nil, "Invalid leader ship"
        end
        
        ASC.Formation.Core.FormationCounter = ASC.Formation.Core.FormationCounter + 1
        formationType = formationType or "LINE"
        spacing = spacing or ASC.Formation.Config.DefaultSpacing
        
        local formation = {
            id = ASC.Formation.Core.FormationCounter,
            leader = leader,
            ships = {leader},
            formationType = formationType,
            spacing = spacing,
            
            -- Formation state
            active = true,
            moving = false,
            destination = nil,
            
            -- Formation positions
            positions = {},
            targetPositions = {},
            
            -- Statistics
            created = CurTime(),
            lastUpdate = CurTime(),
            totalMoves = 0,
            formationChanges = 0
        }
        
        -- Calculate initial positions
        ASC.Formation.Core.CalculateFormationPositions(formation)
        
        ASC.Formation.Core.ActiveFormations[formation.id] = formation
        
        print("[Formation System] Created " .. formationType .. " formation " .. formation.id .. " with leader " .. leader:EntIndex())
        return formation
    end,
    
    -- Add ship to formation
    AddShipToFormation = function(formationID, ship)
        local formation = ASC.Formation.Core.ActiveFormations[formationID]
        if not formation or not IsValid(ship) then
            return false, "Invalid formation or ship"
        end
        
        if #formation.ships >= ASC.Formation.Config.MaxFleetSize then
            return false, "Formation at maximum capacity"
        end
        
        -- Check if ship is already in a formation
        for _, existingFormation in pairs(ASC.Formation.Core.ActiveFormations) do
            for _, existingShip in ipairs(existingFormation.ships) do
                if existingShip == ship then
                    return false, "Ship already in formation"
                end
            end
        end
        
        table.insert(formation.ships, ship)
        
        -- Recalculate positions
        ASC.Formation.Core.CalculateFormationPositions(formation)
        
        -- Enable formation flying for the ship
        ASC.Formation.Core.EnableFormationFlying(ship, formation)
        
        print("[Formation System] Added ship " .. ship:EntIndex() .. " to formation " .. formationID)
        return true
    end,
    
    -- Remove ship from formation
    RemoveShipFromFormation = function(formationID, ship)
        local formation = ASC.Formation.Core.ActiveFormations[formationID]
        if not formation then return false end
        
        for i, formationShip in ipairs(formation.ships) do
            if formationShip == ship then
                table.remove(formation.ships, i)
                
                -- Disable formation flying
                ASC.Formation.Core.DisableFormationFlying(ship)
                
                -- If leader was removed, promote next ship or disband
                if ship == formation.leader then
                    if #formation.ships > 0 then
                        formation.leader = formation.ships[1]
                        print("[Formation System] New leader: " .. formation.leader:EntIndex())
                    else
                        ASC.Formation.Core.DisbandFormation(formationID)
                        return true
                    end
                end
                
                -- Recalculate positions
                ASC.Formation.Core.CalculateFormationPositions(formation)
                
                print("[Formation System] Removed ship " .. ship:EntIndex() .. " from formation " .. formationID)
                return true
            end
        end
        
        return false, "Ship not in formation"
    end,
    
    -- Calculate formation positions
    CalculateFormationPositions = function(formation)
        if not formation or #formation.ships == 0 then return end
        
        local formationConfig = ASC.Formation.Config.FormationTypes[formation.formationType]
        if not formationConfig then return end
        
        -- Get relative positions from formation type
        local relativePositions = formationConfig.positions(#formation.ships, formation.spacing)
        
        formation.positions = relativePositions
        
        -- Calculate world positions based on leader
        ASC.Formation.Core.UpdateFormationPositions(formation)
    end,
    
    -- Update formation positions in world space
    UpdateFormationPositions = function(formation)
        if not formation or not IsValid(formation.leader) then return end
        
        local leaderPos = formation.leader:GetPos()
        local leaderAng = formation.leader:GetAngles()
        
        formation.targetPositions = {}
        
        for i, relativePos in ipairs(formation.positions) do
            -- Transform relative position to world space
            local worldPos = leaderPos + leaderAng:Forward() * relativePos.x + 
                            leaderAng:Right() * relativePos.y + 
                            leaderAng:Up() * relativePos.z
            
            formation.targetPositions[i] = worldPos
        end
    end,
    
    -- Enable formation flying for a ship
    EnableFormationFlying = function(ship, formation)
        if not IsValid(ship) or not ASC.Flight then return end
        
        local shipID = ship:EntIndex()
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        
        if flight then
            flight.formationActive = true
            flight.formation = formation
            flight.formationPosition = ASC.Formation.Core.GetShipPositionInFormation(ship, formation)
            
            -- Update ship core
            ship:SetNWBool("FormationActive", true)
            ship:SetNWInt("FormationID", formation.id)
            ship:SetNWString("FormationType", formation.formationType)
        end
    end,
    
    -- Disable formation flying for a ship
    DisableFormationFlying = function(ship)
        if not IsValid(ship) or not ASC.Flight then return end
        
        local shipID = ship:EntIndex()
        local flight = ASC.Flight.Core.ActiveFlights[shipID]
        
        if flight then
            flight.formationActive = false
            flight.formation = nil
            flight.formationPosition = nil
            
            -- Update ship core
            ship:SetNWBool("FormationActive", false)
            ship:SetNWInt("FormationID", 0)
            ship:SetNWString("FormationType", "")
        end
    end,
    
    -- Get ship position in formation
    GetShipPositionInFormation = function(ship, formation)
        for i, formationShip in ipairs(formation.ships) do
            if formationShip == ship then
                return i
            end
        end
        return 1
    end,
    
    -- Update formation system
    Update = function()
        for formationID, formation in pairs(ASC.Formation.Core.ActiveFormations) do
            ASC.Formation.Core.UpdateFormation(formationID)
        end
    end,
    
    -- Update individual formation
    UpdateFormation = function(formationID)
        local formation = ASC.Formation.Core.ActiveFormations[formationID]
        if not formation then return end
        
        -- Check if leader is still valid
        if not IsValid(formation.leader) then
            ASC.Formation.Core.DisbandFormation(formationID)
            return
        end
        
        -- Remove invalid ships
        for i = #formation.ships, 1, -1 do
            if not IsValid(formation.ships[i]) then
                table.remove(formation.ships, i)
            end
        end
        
        -- Disband if no ships left
        if #formation.ships == 0 then
            ASC.Formation.Core.DisbandFormation(formationID)
            return
        end
        
        -- Update formation positions
        ASC.Formation.Core.UpdateFormationPositions(formation)
        
        -- Update ship flight systems
        ASC.Formation.Core.UpdateShipPositions(formation)
        
        formation.lastUpdate = CurTime()
    end,
    
    -- Update ship positions in formation
    UpdateShipPositions = function(formation)
        if not formation or not ASC.Flight then return end
        
        for i, ship in ipairs(formation.ships) do
            if IsValid(ship) and i > 1 then -- Skip leader (position 1)
                local shipID = ship:EntIndex()
                local flight = ASC.Flight.Core.ActiveFlights[shipID]
                local targetPos = formation.targetPositions[i]
                
                if flight and targetPos then
                    local currentPos = ship:GetPos()
                    local distance = currentPos:Distance(targetPos)
                    
                    -- Only move if outside tolerance
                    if distance > ASC.Formation.Config.PositionTolerance then
                        -- Calculate movement speed based on distance
                        local speed = ASC.Formation.Config.FormationSpeed
                        if distance > ASC.Formation.Config.SlowDownDistance then
                            speed = ASC.Formation.Config.CatchUpSpeed
                        end
                        
                        -- Set autopilot to formation position
                        if ASC.Flight.Core.EnableAutopilot then
                            ASC.Flight.Core.EnableAutopilot(shipID, targetPos, "FORMATION")
                            if flight.autopilotSpeed then
                                flight.autopilotSpeed = speed
                            end
                        end
                    end
                end
            end
        end
    end,
    
    -- Change formation type
    ChangeFormationType = function(formationID, newType)
        local formation = ASC.Formation.Core.ActiveFormations[formationID]
        if not formation then return false end
        
        if not ASC.Formation.Config.FormationTypes[newType] then
            return false, "Invalid formation type"
        end
        
        formation.formationType = newType
        formation.formationChanges = formation.formationChanges + 1
        
        -- Recalculate positions
        ASC.Formation.Core.CalculateFormationPositions(formation)
        
        -- Update all ships
        for _, ship in ipairs(formation.ships) do
            if IsValid(ship) then
                ship:SetNWString("FormationType", newType)
            end
        end
        
        print("[Formation System] Changed formation " .. formationID .. " to " .. newType)
        return true
    end,
    
    -- Disband formation
    DisbandFormation = function(formationID)
        local formation = ASC.Formation.Core.ActiveFormations[formationID]
        if not formation then return end
        
        -- Disable formation flying for all ships
        for _, ship in ipairs(formation.ships) do
            if IsValid(ship) then
                ASC.Formation.Core.DisableFormationFlying(ship)
            end
        end
        
        ASC.Formation.Core.ActiveFormations[formationID] = nil
        
        print("[Formation System] Disbanded formation " .. formationID)
    end,
    
    -- Get formation status
    GetFormationStatus = function(ship)
        if not IsValid(ship) then return nil end
        
        -- Find formation containing this ship
        for _, formation in pairs(ASC.Formation.Core.ActiveFormations) do
            for i, formationShip in ipairs(formation.ships) do
                if formationShip == ship then
                    return {
                        formationID = formation.id,
                        formationType = formation.formationType,
                        position = i,
                        totalShips = #formation.ships,
                        isLeader = (ship == formation.leader),
                        spacing = formation.spacing,
                        active = formation.active
                    }
                end
            end
        end
        
        return nil
    end,
    
    -- Find formation by leader
    FindFormationByLeader = function(leader)
        if not IsValid(leader) then return nil end
        
        for _, formation in pairs(ASC.Formation.Core.ActiveFormations) do
            if formation.leader == leader then
                return formation
            end
        end
        
        return nil
    end
}

-- Initialize system
if SERVER then
    -- Update formation system
    timer.Create("ASC_Formation_Update", ASC.Formation.Config.UpdateRate, 0, function()
        ASC.Formation.Core.Update()
    end)
    
    -- Update system status
    ASC.SystemStatus.FormationFlying = true
    ASC.SystemStatus.FleetCoordination = true
    
    print("[Advanced Space Combat] Formation Flying System v3.0.0 loaded")
end
