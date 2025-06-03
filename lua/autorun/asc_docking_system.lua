--[[
    Advanced Space Combat - Docking System v3.0.0
    
    Comprehensive ship docking system with automated docking procedures,
    docking pads, shuttle operations, and cargo transfer capabilities.
]]

-- Initialize Docking System namespace
ASC = ASC or {}
ASC.Docking = ASC.Docking or {}

-- Docking System Configuration
ASC.Docking.Config = {
    -- Core Settings
    Enabled = true,
    UpdateRate = 0.5,
    MaxDockingPads = 50,
    MaxShuttles = 20,
    
    -- Docking Parameters
    DockingRange = 300,
    DockingSpeed = 100,
    DockingAccuracy = 50,
    DockingTimeout = 60,
    ApproachDistance = 500,
    
    -- Docking Pad Types
    PadTypes = {
        SMALL = {
            name = "Small Docking Pad",
            maxShipSize = 1000,
            capacity = 1,
            services = {"refuel", "repair"}
        },
        MEDIUM = {
            name = "Medium Docking Pad",
            maxShipSize = 2500,
            capacity = 2,
            services = {"refuel", "repair", "rearm"}
        },
        LARGE = {
            name = "Large Docking Pad",
            maxShipSize = 5000,
            capacity = 3,
            services = {"refuel", "repair", "rearm", "upgrade"}
        },
        SHUTTLE = {
            name = "Shuttle Bay",
            maxShipSize = 500,
            capacity = 5,
            services = {"refuel", "passenger"}
        }
    },
    
    -- Service Settings
    Services = {
        refuel = {
            name = "Refueling",
            time = 10,
            cost = 100
        },
        repair = {
            name = "Hull Repair",
            time = 15,
            cost = 200
        },
        rearm = {
            name = "Weapon Rearmament",
            time = 20,
            cost = 300
        },
        upgrade = {
            name = "Ship Upgrades",
            time = 30,
            cost = 500
        },
        passenger = {
            name = "Passenger Transfer",
            time = 5,
            cost = 50
        }
    },
    
    -- Safety Settings
    CollisionCheck = true,
    SafetyRadius = 100,
    EmergencyProtocols = true,
    AutomaticGuidance = true
}

-- Docking System Core
ASC.Docking.Core = {
    -- Active docking pads
    DockingPads = {},
    
    -- Active docking procedures
    ActiveDockings = {},
    
    -- Shuttle operations
    Shuttles = {},
    
    -- Initialize docking system
    Initialize = function()
        print("[Docking System] Initializing docking system v3.0.0")
        
        -- Create docking pad counter
        ASC.Docking.Core.PadCounter = 0
        ASC.Docking.Core.ShuttleCounter = 0
        
        return true
    end,
    
    -- Create docking pad
    CreateDockingPad = function(position, angles, padType, owner)
        if table.Count(ASC.Docking.Core.DockingPads) >= ASC.Docking.Config.MaxDockingPads then
            return nil, "Maximum docking pads reached"
        end
        
        ASC.Docking.Core.PadCounter = ASC.Docking.Core.PadCounter + 1
        padType = padType or "MEDIUM"
        
        local pad = {
            id = ASC.Docking.Core.PadCounter,
            position = position,
            angles = angles or Angle(0, 0, 0),
            padType = padType,
            config = ASC.Docking.Config.PadTypes[padType],
            owner = owner,
            
            -- Status
            active = true,
            occupied = false,
            dockedShips = {},
            services = {},
            
            -- Operations
            lastUpdate = CurTime(),
            totalDockings = 0,
            servicesProvided = 0,
            
            -- Queue
            dockingQueue = {},
            serviceQueue = {}
        }
        
        ASC.Docking.Core.DockingPads[pad.id] = pad
        
        print("[Docking System] Created " .. pad.config.name .. " at " .. tostring(position))
        return pad
    end,
    
    -- Request docking
    RequestDocking = function(shipCore, padID)
        if not IsValid(shipCore) then
            return false, "Invalid ship core"
        end
        
        local pad = ASC.Docking.Core.DockingPads[padID]
        if not pad then
            return false, "Docking pad not found"
        end
        
        -- Check if ship can dock
        local canDock, reason = ASC.Docking.Core.CanShipDock(shipCore, pad)
        if not canDock then
            return false, reason
        end
        
        -- Check if pad has capacity
        if #pad.dockedShips >= pad.config.capacity then
            -- Add to queue
            table.insert(pad.dockingQueue, {
                ship = shipCore,
                requestTime = CurTime(),
                priority = 1
            })
            return true, "Added to docking queue (position " .. #pad.dockingQueue .. ")"
        end
        
        -- Start docking procedure
        return ASC.Docking.Core.StartDockingProcedure(shipCore, pad)
    end,
    
    -- Check if ship can dock
    CanShipDock = function(shipCore, pad)
        if not IsValid(shipCore) then
            return false, "Invalid ship core"
        end
        
        if not pad.active then
            return false, "Docking pad is offline"
        end
        
        -- Check ship size
        local shipSize = ASC.Docking.Core.GetShipSize(shipCore)
        if shipSize > pad.config.maxShipSize then
            return false, "Ship too large for this docking pad"
        end
        
        -- Check distance
        local distance = shipCore:GetPos():Distance(pad.position)
        if distance > ASC.Docking.Config.DockingRange then
            return false, "Ship too far from docking pad"
        end
        
        -- Check if ship is already docked
        for _, dockedShip in ipairs(pad.dockedShips) do
            if dockedShip.ship == shipCore then
                return false, "Ship already docked"
            end
        end
        
        return true
    end,
    
    -- Get ship size
    GetShipSize = function(shipCore)
        if not IsValid(shipCore) or not shipCore.GetEntities then
            return 100
        end
        
        local entityCount = #shipCore:GetEntities()
        return entityCount * 50 -- Rough size calculation
    end,
    
    -- Start docking procedure
    StartDockingProcedure = function(shipCore, pad)
        local dockingID = shipCore:EntIndex()
        
        -- Check if ship has flight system
        local flightSystem = nil
        if ASC.Flight and ASC.Flight.Core.ActiveFlights[dockingID] then
            flightSystem = ASC.Flight.Core.ActiveFlights[dockingID]
        end
        
        local procedure = {
            ship = shipCore,
            pad = pad,
            flightSystem = flightSystem,
            phase = "approach", -- approach, align, dock, complete
            startTime = CurTime(),
            timeout = ASC.Docking.Config.DockingTimeout,
            targetPosition = pad.position + Vector(0, 0, 100), -- Hover above pad
            finalPosition = pad.position + Vector(0, 0, 50) -- Final docking position
        }
        
        ASC.Docking.Core.ActiveDockings[dockingID] = procedure
        
        -- Enable autopilot if available
        if flightSystem and ASC.Flight then
            ASC.Flight.Core.EnableAutopilot(dockingID, procedure.targetPosition, "DOCKING")
        end
        
        print("[Docking System] Started docking procedure for ship " .. dockingID .. " to pad " .. pad.id)
        return true, "Docking procedure initiated"
    end,
    
    -- Update docking procedure
    UpdateDockingProcedure = function(dockingID)
        local procedure = ASC.Docking.Core.ActiveDockings[dockingID]
        if not procedure or not IsValid(procedure.ship) then
            ASC.Docking.Core.ActiveDockings[dockingID] = nil
            return
        end
        
        local currentTime = CurTime()
        local shipPos = procedure.ship:GetPos()
        
        -- Check timeout
        if currentTime - procedure.startTime > procedure.timeout then
            ASC.Docking.Core.AbortDocking(dockingID, "Timeout")
            return
        end
        
        -- Update based on phase
        if procedure.phase == "approach" then
            local distance = shipPos:Distance(procedure.targetPosition)
            if distance < ASC.Docking.Config.DockingAccuracy then
                procedure.phase = "align"
                print("[Docking System] Ship " .. dockingID .. " reached approach position")
            end
            
        elseif procedure.phase == "align" then
            -- Check alignment and move to final position
            if procedure.flightSystem and ASC.Flight then
                ASC.Flight.Core.EnableAutopilot(dockingID, procedure.finalPosition, "DOCKING")
            end
            procedure.phase = "dock"
            
        elseif procedure.phase == "dock" then
            local distance = shipPos:Distance(procedure.finalPosition)
            if distance < ASC.Docking.Config.DockingAccuracy then
                ASC.Docking.Core.CompleteDocking(dockingID)
            end
        end
    end,
    
    -- Complete docking
    CompleteDocking = function(dockingID)
        local procedure = ASC.Docking.Core.ActiveDockings[dockingID]
        if not procedure then return end
        
        local ship = procedure.ship
        local pad = procedure.pad
        
        -- Add ship to docked ships
        table.insert(pad.dockedShips, {
            ship = ship,
            dockTime = CurTime(),
            services = {}
        })
        
        -- Disable flight system
        if procedure.flightSystem and ASC.Flight then
            ASC.Flight.Core.DisableAutopilot(dockingID)
        end
        
        -- Update statistics
        pad.totalDockings = pad.totalDockings + 1
        pad.occupied = true
        
        -- Clean up procedure
        ASC.Docking.Core.ActiveDockings[dockingID] = nil
        
        -- Notify owner
        local owner = ship:CPPIGetOwner()
        if IsValid(owner) then
            owner:ChatPrint("🚁 Ship successfully docked at " .. pad.config.name)
            owner:ChatPrint("💡 Available services: " .. table.concat(pad.config.services, ", "))
        end
        
        print("[Docking System] Ship " .. dockingID .. " successfully docked at pad " .. pad.id)
    end,
    
    -- Abort docking
    AbortDocking = function(dockingID, reason)
        local procedure = ASC.Docking.Core.ActiveDockings[dockingID]
        if not procedure then return end
        
        -- Disable autopilot
        if procedure.flightSystem and ASC.Flight then
            ASC.Flight.Core.DisableAutopilot(dockingID)
        end
        
        -- Notify owner
        local owner = procedure.ship:CPPIGetOwner()
        if IsValid(owner) then
            owner:ChatPrint("❌ Docking aborted: " .. (reason or "Unknown error"))
        end
        
        -- Clean up
        ASC.Docking.Core.ActiveDockings[dockingID] = nil
        
        print("[Docking System] Docking aborted for ship " .. dockingID .. ": " .. (reason or "Unknown"))
    end,
    
    -- Undock ship
    UndockShip = function(shipCore, padID)
        if not IsValid(shipCore) then
            return false, "Invalid ship core"
        end
        
        local pad = ASC.Docking.Core.DockingPads[padID]
        if not pad then
            return false, "Docking pad not found"
        end
        
        -- Find and remove ship from docked ships
        for i, dockedShip in ipairs(pad.dockedShips) do
            if dockedShip.ship == shipCore then
                table.remove(pad.dockedShips, i)
                
                -- Update pad status
                if #pad.dockedShips == 0 then
                    pad.occupied = false
                end
                
                -- Process queue
                ASC.Docking.Core.ProcessDockingQueue(pad)
                
                -- Notify owner
                local owner = shipCore:CPPIGetOwner()
                if IsValid(owner) then
                    owner:ChatPrint("🚁 Ship undocked from " .. pad.config.name)
                end
                
                print("[Docking System] Ship " .. shipCore:EntIndex() .. " undocked from pad " .. pad.id)
                return true
            end
        end
        
        return false, "Ship not found at this docking pad"
    end,
    
    -- Process docking queue
    ProcessDockingQueue = function(pad)
        if #pad.dockingQueue == 0 or #pad.dockedShips >= pad.config.capacity then
            return
        end
        
        -- Get next ship in queue
        local nextDocking = table.remove(pad.dockingQueue, 1)
        if IsValid(nextDocking.ship) then
            ASC.Docking.Core.StartDockingProcedure(nextDocking.ship, pad)
        end
    end,
    
    -- Find nearest docking pad
    FindNearestDockingPad = function(shipCore, padType)
        if not IsValid(shipCore) then return nil end
        
        local shipPos = shipCore:GetPos()
        local nearestPad = nil
        local nearestDistance = math.huge
        
        for _, pad in pairs(ASC.Docking.Core.DockingPads) do
            if not padType or pad.padType == padType then
                local distance = shipPos:Distance(pad.position)
                if distance < nearestDistance then
                    local canDock, _ = ASC.Docking.Core.CanShipDock(shipCore, pad)
                    if canDock then
                        nearestPad = pad
                        nearestDistance = distance
                    end
                end
            end
        end
        
        return nearestPad, nearestDistance
    end,
    
    -- Update docking system
    Update = function()
        -- Update active docking procedures
        for dockingID, procedure in pairs(ASC.Docking.Core.ActiveDockings) do
            ASC.Docking.Core.UpdateDockingProcedure(dockingID)
        end
        
        -- Update docking pads
        for _, pad in pairs(ASC.Docking.Core.DockingPads) do
            pad.lastUpdate = CurTime()
        end
    end,
    
    -- Get docking status
    GetDockingStatus = function(shipCore)
        if not IsValid(shipCore) then return nil end
        
        local shipID = shipCore:EntIndex()
        
        -- Check if ship is in docking procedure
        if ASC.Docking.Core.ActiveDockings[shipID] then
            local procedure = ASC.Docking.Core.ActiveDockings[shipID]
            return {
                status = "DOCKING",
                phase = procedure.phase,
                pad = procedure.pad,
                timeRemaining = procedure.timeout - (CurTime() - procedure.startTime)
            }
        end
        
        -- Check if ship is docked
        for _, pad in pairs(ASC.Docking.Core.DockingPads) do
            for _, dockedShip in ipairs(pad.dockedShips) do
                if dockedShip.ship == shipCore then
                    return {
                        status = "DOCKED",
                        pad = pad,
                        dockTime = CurTime() - dockedShip.dockTime,
                        services = dockedShip.services
                    }
                end
            end
        end
        
        return {
            status = "FREE",
            nearestPad = ASC.Docking.Core.FindNearestDockingPad(shipCore)
        }
    end
}

-- Initialize system
if SERVER then
    -- Initialize docking system
    ASC.Docking.Core.Initialize()
    
    -- Update docking system
    timer.Create("ASC_Docking_Update", ASC.Docking.Config.UpdateRate, 0, function()
        ASC.Docking.Core.Update()
    end)
    
    -- Update system status
    ASC.SystemStatus.DockingPadSystem = true
    
    print("[Advanced Space Combat] Docking System v3.0.0 loaded")
end
