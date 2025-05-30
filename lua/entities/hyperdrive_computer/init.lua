-- Hyperdrive Computer Entity - Server Side
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/monitor01a.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(50)
    end

    -- Initialize computer properties
    self:SetPowered(true)
    self:SetLinkedEngine(NULL)
    self:SetComputerMode(1) -- 1 = Navigation, 2 = Planets, 3 = Status

    self.LinkedEngines = {}
    self.LastUse = 0
    self.Owner = nil

    -- Enhanced computer data (initialize with safe defaults)
    self.SavedWaypoints = self.SavedWaypoints or {}
    self.LocationHistory = self.LocationHistory or {}
    self.ManualControlTarget = NULL
    self.CurrentCoordinates = Vector(0, 0, 0)
    self.JumpQueue = self.JumpQueue or {}
    self.SafetyChecks = true

    -- Planet detection system
    self.DetectedPlanets = self.DetectedPlanets or {}
    self.LastPlanetScan = 0
    self.PlanetScanInterval = 30 -- Scan every 30 seconds
    self.AutoDetectPlanets = true

    -- Auto-linking system
    self.LinkedPlanets = self.LinkedPlanets or {}
    self.AutoLinkPlanets = true
    self.PlanetLinkRadius = 100000 -- 100km auto-link radius
    self.QuickJumpTargets = self.QuickJumpTargets or {} -- Fast access planet targets

    -- Master Engine Control System
    self.ControlledMasterEngine = NULL
    self.MasterEngineDestination = Vector(0, 0, 0)
    self.LastMasterEngineCheck = 0
    self.MasterEngineCheckInterval = 1 -- Check every second
    self.FourStageJumpInProgress = false
    self.CurrentJumpStage = 0
    self.StageStartTime = 0

    -- Ship Core Integration
    self.DetectedShip = nil
    self.ShipUpdateInterval = 2.0
    self.LastShipUpdate = 0
    self.ShipInfo = {}

    -- Initialize ship detection
    if HYPERDRIVE.ShipCore then
        timer.Simple(0.5, function()
            if IsValid(self) then
                self:UpdateShipDetection()
            end
        end)
    end

    -- Initialize Wiremod support
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "LinkedEngine [ENTITY]",
            "FleetJump",
            "SetMode",
            "SetDestination [VECTOR]",
            "PowerToggle",
            "ScanEngines",
            "ManualJump",
            "SaveWaypoint [STRING]",
            "LoadWaypoint [STRING]",
            "SetCoordinates [VECTOR]",
            "EmergencyAbort",
            "ToggleSafety",
            "ScanPlanets",
            "TogglePlanetDetection",
            "ClearPlanets",
            "AutoLinkPlanets",
            "ToggleAutoLink",
            "QuickJumpToPlanet [STRING]",
            "SetPlanetLinkRadius",
            "Start4StageJump",
            "ControlMasterEngine [ENTITY]",
            "SetMasterDestination [VECTOR]",
            "StartMasterJump",
            "AbortMasterJump",
            "CheckMasterStatus"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "Powered",
            "Mode",
            "LinkedEngines",
            "OnlineEngines",
            "ChargingEngines",
            "ReadyEngines",
            "TotalEnergy",
            "MaxEnergy",
            "FleetStatus [STRING]",
            "CurrentCoords [VECTOR]",
            "WaypointCount",
            "SafetyEnabled",
            "ManualTarget [ENTITY]",
            "JumpCost",
            "EstimatedTime",
            "TriggerChargingEffects",
            "TriggerHyperspaceWindow",
            "TriggerStarlinesEffect",
            "TriggerStargateStage [STRING]",
            "UpdateShipDetection",
            "PlanetsDetected",
            "PlanetDetectionEnabled",
            "LastPlanetScan",
            "LinkedPlanets",
            "AutoLinkEnabled",
            "QuickJumpReady",
            "NearestPlanet [STRING]",
            "PlanetLinkRadius",
            "ControlledMasterEngine [ENTITY]",
            "MasterEngineStatus [STRING]",
            "MasterEngineEnergy",
            "MasterEngineReady",
            "MasterEngineCharging",
            "MasterEngineCooldown",
            "MasterEngineDestination [VECTOR]",
            "FourStageAvailable",
            "FourStageActive",
            "CurrentStage",
            "StageProgress",
            "MasterEfficiencyRating",
            "MasterIntegrations [STRING]",
            "ShipDetected",
            "ShipType [STRING]",
            "ShipEntityCount",
            "ShipPlayerCount",
            "ShipMass",
            "ShipVolume",
            "ShipCenter [VECTOR]"
        })
    end

    -- Auto-link nearby engines, load waypoints, and start planet detection
    timer.Simple(1, function()
        if IsValid(self) then
            self:AutoLinkEngines()
            self:LoadWaypointsFromFile()

            -- Initial planet scan and auto-linking
            if self.AutoDetectPlanets then
                timer.Simple(5, function()
                    if IsValid(self) then
                        self:ScanForPlanets()

                        -- Auto-link planets after initial scan
                        if self.AutoLinkPlanets then
                            timer.Simple(2, function()
                                if IsValid(self) then
                                    self:AutoLinkAllPlanets()
                                end
                            end)
                        end
                    end
                end)
            end
        end
    end)
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Powered")
    self:NetworkVar("Entity", 0, "LinkedEngine")
    self:NetworkVar("Int", 0, "ComputerMode")
end

function ENT:AutoLinkEngines()
    local engines = ents.FindInSphere(self:GetPos(), 1000)
    self.LinkedEngines = {}

    for _, ent in ipairs(engines) do
        -- Only link to master engines (which have all features)
        if ent:GetClass() == "hyperdrive_master_engine" then
            table.insert(self.LinkedEngines, ent)
        end
    end

    if #self.LinkedEngines > 0 then
        self:SetLinkedEngine(self.LinkedEngines[1])
        print("[Hyperdrive Computer] Linked to " .. #self.LinkedEngines .. " Master Engines")
    else
        print("[Hyperdrive Computer] No Master Engines found within 1000 units")
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if CurTime() - self.LastUse < 0.5 then return end
    if not self:GetPowered() then
        activator:ChatPrint("[Hyperdrive Computer] System offline")
        return
    end

    self.LastUse = CurTime()
    self.Owner = activator

    -- Open computer interface
    net.Start("hyperdrive_computer")
    net.WriteEntity(self)
    net.WriteInt(self:GetComputerMode(), 8)
    net.WriteInt(#self.LinkedEngines, 8)

    -- Send linked engines data
    for i, engine in ipairs(self.LinkedEngines) do
        if IsValid(engine) then
            net.WriteEntity(engine)
            net.WriteFloat(engine:GetEnergy())
            net.WriteFloat(engine:GetCooldown())
            net.WriteBool(engine:GetCharging())
            net.WriteVector(engine:GetDestination())
        end
    end

    net.Send(activator)

    -- Give user feedback
    activator:ChatPrint("[Hyperdrive Computer] Interface opened! Use the tabs to navigate.")
end

function ENT:GetEngineStatus()
    local status = {
        total = #self.LinkedEngines,
        online = 0,
        charging = 0,
        ready = 0,
        totalEnergy = 0,
        maxEnergy = 0
    }

    for _, engine in ipairs(self.LinkedEngines) do
        if IsValid(engine) then
            status.online = status.online + 1
            status.totalEnergy = status.totalEnergy + engine:GetEnergy()
            status.maxEnergy = status.maxEnergy + HYPERDRIVE.Config.MaxEnergy

            if engine:GetCharging() then
                status.charging = status.charging + 1
            elseif engine:CanJump() then
                status.ready = status.ready + 1
            end
        end
    end

    return status
end

function ENT:ExecuteFleetJump(destination)
    if not destination or not isvector(destination) then
        return false, "Invalid destination"
    end

    local readyEngines = {}
    local totalEnergyCost = 0

    -- Check all engines
    for _, engine in ipairs(self.LinkedEngines) do
        if IsValid(engine) and engine:CanJump() then
            local distance = HYPERDRIVE.GetDistance(engine:GetPos(), destination)
            local energyCost = HYPERDRIVE.CalculateEnergyCost(distance)

            if engine:GetEnergy() >= energyCost then
                table.insert(readyEngines, {engine = engine, cost = energyCost})
                totalEnergyCost = totalEnergyCost + energyCost
            end
        end
    end

    if #readyEngines == 0 then
        return false, "No engines ready for jump"
    end

    -- Create world effects instead of HUD animations
    self:CreateFleetJumpEffects(destination)

    -- Use hyperspace dimension system if available, otherwise use direct engine jumps
    local primaryEngine = readyEngines[1].engine
    local useHyperspaceDimension = HYPERDRIVE.HyperspaceDimension and HYPERDRIVE.HyperspaceDimension.StartHyperspaceTravel

    if useHyperspaceDimension and IsValid(primaryEngine) then
        -- Start hyperspace dimension travel with primary engine
        local success = HYPERDRIVE.HyperspaceDimension.StartHyperspaceTravel(primaryEngine, destination, 3)
        if success then
            print("[Hyperdrive Computer] Fleet jump initiated using hyperspace dimension system")
        else
            print("[Hyperdrive Computer] Hyperspace dimension system failed, falling back to direct jumps")
            useHyperspaceDimension = false
        end
    end

    -- Fallback to direct engine jumps if hyperspace dimension system is not available or failed
    if not useHyperspaceDimension then
        -- Execute coordinated jump using direct engine calls
        for _, data in ipairs(readyEngines) do
            local engine = data.engine
            local success, message = engine:SetDestinationPos(destination)
            if success then
                if engine:GetClass() == "hyperdrive_master_engine" then
                    engine:StartJumpMaster()
                else
                    engine:StartJump()
                end
            end
        end

        -- World effects are already handled by CreateFleetJumpEffects
    end

    return true, string.format("Fleet jump initiated: %d engines", #readyEngines)
end

function ENT:Think()
    -- Update ship detection
    if HYPERDRIVE.ShipCore and CurTime() - self.LastShipUpdate > self.ShipUpdateInterval then
        self:UpdateShipDetection()
    end

    -- Update power status based on linked engines
    local hasOnlineEngine = false
    for _, engine in ipairs(self.LinkedEngines) do
        if IsValid(engine) and engine:GetEnergy() > 0 then
            hasOnlineEngine = true
            break
        end
    end

    self:SetPowered(hasOnlineEngine)

    -- Auto-scan for planets if enabled
    if self.AutoDetectPlanets and hasOnlineEngine then
        self:ScanForPlanets()
    end

    -- Auto-link planets if enabled
    if self.AutoLinkPlanets and hasOnlineEngine then
        -- Re-link every 60 seconds to update distances and availability
        if not self.LastAutoLink or CurTime() - self.LastAutoLink > 60 then
            self:AutoLinkAllPlanets()
            self.LastAutoLink = CurTime()
        end
    end

    -- Auto-link master engines if none controlled
    if not IsValid(self.ControlledMasterEngine) and hasOnlineEngine then
        if not self.LastMasterEngineCheck or CurTime() - self.LastMasterEngineCheck > self.MasterEngineCheckInterval then
            self:AutoLinkMasterEngines()
            self.LastMasterEngineCheck = CurTime()
        end
    end

    -- Check if controlled master engine is still valid
    if IsValid(self.ControlledMasterEngine) then
        -- Validate the engine is still a master engine and nearby
        if self.ControlledMasterEngine:GetClass() ~= "hyperdrive_master_engine" or
           self.ControlledMasterEngine:GetPos():Distance(self:GetPos()) > 3000 then
            print("[Hyperdrive Computer] Lost connection to master engine")
            self.ControlledMasterEngine = NULL
            self.FourStageJumpInProgress = false
            self.CurrentJumpStage = 0
        end
    end

    self:UpdateWireOutputs()
    self:NextThink(CurTime() + 1)
    return true
end

-- Wiremod support functions
function ENT:TriggerInput(iname, value)
    if not WireLib then return end

    if iname == "LinkedEngine" and IsValid(value) then
        -- Wire a specific engine to the computer
        if value:GetClass() == "hyperdrive_master_engine" then
            -- Clear existing linked engines and add the wired one
            self.LinkedEngines = {value}
            self:SetLinkedEngine(value)
            print("[Hyperdrive Computer] Wired to Master Engine: " .. tostring(value))
        end

    elseif iname == "FleetJump" and value > 0 then
        local dest = self.WireDestination or Vector(0, 0, 0)
        if dest ~= Vector(0, 0, 0) then
            local success, message = self:ExecuteFleetJump(dest)
            self:UpdateWireOutputs()
        end

    elseif iname == "SetMode" then
        local mode = math.Clamp(math.floor(value), 1, 3)
        self:SetComputerMode(mode)

    elseif iname == "SetDestination" and isvector(value) then
        self.WireDestination = value

    elseif iname == "PowerToggle" and value > 0 then
        self:SetPowered(not self:GetPowered())

    elseif iname == "ScanEngines" and value > 0 then
        self:AutoLinkEngines()

    elseif iname == "ManualJump" and value > 0 then
        if IsValid(self.ManualControlTarget) and self.CurrentCoordinates ~= Vector(0, 0, 0) then
            self:ExecuteManualJump(self.ManualControlTarget, self.CurrentCoordinates)
        end

    elseif iname == "SaveWaypoint" and isstring(value) and value ~= "" then
        self:SaveWaypoint(value, self.CurrentCoordinates)

    elseif iname == "LoadWaypoint" and isstring(value) and value ~= "" then
        local waypoint = self:LoadWaypoint(value)
        if waypoint then
            self.CurrentCoordinates = waypoint.position
        end

    elseif iname == "SetCoordinates" and isvector(value) then
        self.CurrentCoordinates = value

    elseif iname == "EmergencyAbort" and value > 0 then
        self:EmergencyAbort()

    elseif iname == "ToggleSafety" and value > 0 then
        self.SafetyChecks = not self.SafetyChecks

    elseif iname == "ScanPlanets" and value > 0 then
        self:ScanForPlanets()

    elseif iname == "TogglePlanetDetection" and value > 0 then
        self:TogglePlanetDetection()

    elseif iname == "ClearPlanets" and value > 0 then
        self:ClearAutoDetectedPlanets()

    elseif iname == "AutoLinkPlanets" and value > 0 then
        self:AutoLinkAllPlanets()

    elseif iname == "ToggleAutoLink" and value > 0 then
        self:ToggleAutoLink()

    elseif iname == "QuickJumpToPlanet" and isstring(value) and value ~= "" then
        -- Use wired engine if available, otherwise use manual target or auto-find
        local targetEngine = nil
        if #self.LinkedEngines > 0 and IsValid(self.LinkedEngines[1]) then
            targetEngine = self.LinkedEngines[1]
        elseif IsValid(self.ManualControlTarget) then
            targetEngine = self.ManualControlTarget
        end

        self:QuickJumpToPlanet(value, targetEngine)

    elseif iname == "SetPlanetLinkRadius" and isnumber(value) then
        self:SetPlanetLinkRadius(value)

    -- Master Engine Control Inputs
    elseif iname == "Start4StageJump" and value > 0 then
        self:Start4StageJump()

    elseif iname == "ControlMasterEngine" and IsValid(value) then
        if value:GetClass() == "hyperdrive_master_engine" then
            self.ControlledMasterEngine = value
            print("[Hyperdrive Computer] Now controlling Master Engine: " .. tostring(value))
        end

    elseif iname == "SetMasterDestination" and isvector(value) then
        self.MasterEngineDestination = value
        if IsValid(self.ControlledMasterEngine) then
            local success, message = self.ControlledMasterEngine:SetDestinationPos(value)
            if not success then
                print("[Hyperdrive Computer] Failed to set master engine destination: " .. (message or "Unknown error"))
            end
        end

    elseif iname == "StartMasterJump" and value > 0 then
        self:StartMasterEngineJump()

    elseif iname == "AbortMasterJump" and value > 0 then
        self:AbortMasterEngineJump()

    elseif iname == "CheckMasterStatus" and value > 0 then
        self:CheckMasterEngineStatus()

    -- World Effects Control Inputs
    elseif iname == "TriggerChargingEffects" and value > 0 then
        if HYPERDRIVE.WorldEffects and self.DetectedShip then
            HYPERDRIVE.WorldEffects.CreateChargingEffects(self, self.DetectedShip)
        end

    elseif iname == "TriggerHyperspaceWindow" and value > 0 then
        if HYPERDRIVE.WorldEffects and self.DetectedShip then
            HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(self, self.DetectedShip, "enter")
        end

    elseif iname == "TriggerStarlinesEffect" and value > 0 then
        if HYPERDRIVE.WorldEffects and self.DetectedShip then
            HYPERDRIVE.WorldEffects.CreateStarlinesEffect(self, self.DetectedShip)
        end

    elseif iname == "TriggerStargateStage" and isstring(value) and value ~= "" then
        if HYPERDRIVE.WorldEffects and self.DetectedShip then
            local validStages = {"initiation", "window", "travel", "exit"}
            local stage = string.lower(value)
            if table.HasValue(validStages, stage) then
                HYPERDRIVE.WorldEffects.CreateStargateEffects(self, self.DetectedShip, stage)
            end
        end

    elseif iname == "UpdateShipDetection" and value > 0 then
        self:UpdateShipDetection()
    end

    self:UpdateWireOutputs()
end

function ENT:UpdateWireOutputs()
    if not WireLib then return end

    WireLib.TriggerOutput(self, "Powered", self:GetPowered() and 1 or 0)
    WireLib.TriggerOutput(self, "Mode", self:GetComputerMode())

    local status = self:GetEngineStatus()
    WireLib.TriggerOutput(self, "LinkedEngines", status.total)
    WireLib.TriggerOutput(self, "OnlineEngines", status.online)
    WireLib.TriggerOutput(self, "ChargingEngines", status.charging)
    WireLib.TriggerOutput(self, "ReadyEngines", status.ready)
    WireLib.TriggerOutput(self, "TotalEnergy", status.totalEnergy)
    WireLib.TriggerOutput(self, "MaxEnergy", status.maxEnergy)

    local fleetStatus = string.format("%d/%d READY", status.ready, status.total)
    WireLib.TriggerOutput(self, "FleetStatus", fleetStatus)

    -- New enhanced outputs
    WireLib.TriggerOutput(self, "CurrentCoords", self.CurrentCoordinates)
    WireLib.TriggerOutput(self, "WaypointCount", table.Count(self.SavedWaypoints))
    WireLib.TriggerOutput(self, "SafetyEnabled", self.SafetyChecks and 1 or 0)
    WireLib.TriggerOutput(self, "ManualTarget", self.ManualControlTarget)

    -- Calculate jump cost if we have a target and coordinates
    local jumpCost = 0
    local estimatedTime = 0
    if IsValid(self.ManualControlTarget) and self.CurrentCoordinates ~= Vector(0, 0, 0) then
        jumpCost = self:CalculateJumpCost(self.CurrentCoordinates, self.ManualControlTarget)
        local distance = self.ManualControlTarget:GetPos():Distance(self.CurrentCoordinates)
        estimatedTime = HYPERDRIVE.Config.JumpChargeTime + (distance / 10000) -- Rough estimate
    end

    WireLib.TriggerOutput(self, "JumpCost", jumpCost)
    WireLib.TriggerOutput(self, "EstimatedTime", estimatedTime)

    -- Planet detection outputs
    WireLib.TriggerOutput(self, "PlanetsDetected", table.Count(self.DetectedPlanets))
    WireLib.TriggerOutput(self, "PlanetDetectionEnabled", self.AutoDetectPlanets and 1 or 0)
    WireLib.TriggerOutput(self, "LastPlanetScan", self.LastPlanetScan)

    -- Auto-linking outputs
    WireLib.TriggerOutput(self, "LinkedPlanets", #self.LinkedPlanets)
    WireLib.TriggerOutput(self, "AutoLinkEnabled", self.AutoLinkPlanets and 1 or 0)
    WireLib.TriggerOutput(self, "QuickJumpReady", #self.QuickJumpTargets > 0 and 1 or 0)
    WireLib.TriggerOutput(self, "PlanetLinkRadius", self.PlanetLinkRadius)

    -- Nearest planet output
    local nearest = self:GetNearestPlanet()
    local nearestName = nearest and nearest.name or "None"
    WireLib.TriggerOutput(self, "NearestPlanet", nearestName)

    -- Master Engine Control Outputs
    WireLib.TriggerOutput(self, "ControlledMasterEngine", self.ControlledMasterEngine)

    if IsValid(self.ControlledMasterEngine) then
        local engine = self.ControlledMasterEngine
        local canOperate, reason = engine:CanOperateMaster()

        WireLib.TriggerOutput(self, "MasterEngineStatus", canOperate and "READY" or reason)
        WireLib.TriggerOutput(self, "MasterEngineEnergy", engine:GetEnergy())
        WireLib.TriggerOutput(self, "MasterEngineReady", canOperate and 1 or 0)
        WireLib.TriggerOutput(self, "MasterEngineCharging", engine:GetCharging() and 1 or 0)
        WireLib.TriggerOutput(self, "MasterEngineCooldown", engine:GetCooldownRemaining())
        WireLib.TriggerOutput(self, "MasterEngineDestination", engine:GetDestination())
        WireLib.TriggerOutput(self, "MasterEfficiencyRating", engine:GetEfficiencyRating())

        -- 4-Stage Travel System Status
        local fourStageAvailable = HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.Config.StageSystem.EnableFourStageTravel
        WireLib.TriggerOutput(self, "FourStageAvailable", fourStageAvailable and 1 or 0)
        WireLib.TriggerOutput(self, "FourStageActive", self.FourStageJumpInProgress and 1 or 0)
        WireLib.TriggerOutput(self, "CurrentStage", self.CurrentJumpStage)

        -- Calculate stage progress
        local stageProgress = 0
        if self.FourStageJumpInProgress and self.StageStartTime > 0 then
            local elapsed = CurTime() - self.StageStartTime
            local stageDuration = self:GetCurrentStageDuration()
            stageProgress = math.Clamp(elapsed / stageDuration, 0, 1)
        end
        WireLib.TriggerOutput(self, "StageProgress", stageProgress)

        -- Integration status
        local integrations = {}
        if engine.IntegrationData then
            if engine.IntegrationData.wiremod.active then table.insert(integrations, "Wiremod") end
            if engine.IntegrationData.spacebuild.active then table.insert(integrations, "Spacebuild") end
            if engine.IntegrationData.stargate.active then table.insert(integrations, "Stargate") end
        end
        WireLib.TriggerOutput(self, "MasterIntegrations", table.concat(integrations, ","))
    else
        WireLib.TriggerOutput(self, "MasterEngineStatus", "NO_ENGINE")
        WireLib.TriggerOutput(self, "MasterEngineEnergy", 0)
        WireLib.TriggerOutput(self, "MasterEngineReady", 0)
        WireLib.TriggerOutput(self, "MasterEngineCharging", 0)
        WireLib.TriggerOutput(self, "MasterEngineCooldown", 0)
        WireLib.TriggerOutput(self, "MasterEngineDestination", Vector(0, 0, 0))
        WireLib.TriggerOutput(self, "FourStageAvailable", 0)
        WireLib.TriggerOutput(self, "FourStageActive", 0)
        WireLib.TriggerOutput(self, "CurrentStage", 0)
        WireLib.TriggerOutput(self, "StageProgress", 0)
        WireLib.TriggerOutput(self, "MasterEfficiencyRating", 0)
        WireLib.TriggerOutput(self, "MasterIntegrations", "")
    end

    -- Update ship information outputs
    if self.DetectedShip and self.ShipInfo then
        local classification = self.ShipInfo.classification
        WireLib.TriggerOutput(self, "ShipDetected", 1)
        WireLib.TriggerOutput(self, "ShipType", self.ShipInfo.shipType or "unknown")
        WireLib.TriggerOutput(self, "ShipEntityCount", classification.entityCount or 0)
        WireLib.TriggerOutput(self, "ShipPlayerCount", classification.playerCount or 0)
        WireLib.TriggerOutput(self, "ShipMass", math.Round(classification.mass or 0, 2))
        WireLib.TriggerOutput(self, "ShipVolume", math.Round(classification.volume or 0, 2))
        WireLib.TriggerOutput(self, "ShipCenter", self.ShipInfo.center or Vector(0, 0, 0))
    else
        WireLib.TriggerOutput(self, "ShipDetected", 0)
        WireLib.TriggerOutput(self, "ShipType", "none")
        WireLib.TriggerOutput(self, "ShipEntityCount", 0)
        WireLib.TriggerOutput(self, "ShipPlayerCount", 0)
        WireLib.TriggerOutput(self, "ShipMass", 0)
        WireLib.TriggerOutput(self, "ShipVolume", 0)
        WireLib.TriggerOutput(self, "ShipCenter", Vector(0, 0, 0))
    end
end

-- Enhanced Computer Functions

-- Save current position as waypoint
function ENT:SaveWaypoint(name, position, ply)
    if not name or name == "" then return false, "Invalid waypoint name" end
    if not position then position = self:GetPos() end

    local waypoint = {
        name = name,
        position = position,
        timestamp = os.time(),
        creator = IsValid(ply) and ply:Nick() or "System",
        description = "",
        category = "User"
    }

    self.SavedWaypoints[name] = waypoint
    self:SaveWaypointsToFile()

    return true, "Waypoint '" .. name .. "' saved successfully"
end

-- Load waypoint by name
function ENT:LoadWaypoint(name)
    local waypoint = self.SavedWaypoints[name]
    if not waypoint then return nil, "Waypoint not found" end

    return waypoint, "Waypoint loaded"
end

-- Get all waypoints
function ENT:GetWaypoints()
    return self.SavedWaypoints
end

-- Delete waypoint
function ENT:DeleteWaypoint(name)
    if not self.SavedWaypoints[name] then return false, "Waypoint not found" end

    self.SavedWaypoints[name] = nil
    self:SaveWaypointsToFile()

    return true, "Waypoint deleted"
end

-- Calculate jump cost to destination
function ENT:CalculateJumpCost(destination, engine)
    if not IsValid(engine) then return 0 end
    if not destination then return 0 end

    local distance = engine:GetPos():Distance(destination)
    local baseCost = distance * HYPERDRIVE.Config.EnergyPerUnit

    -- Apply efficiency modifiers (simplified)
    local efficiency = 1.0

    -- Simple efficiency calculation for Master Engines
    if engine:GetClass() == "hyperdrive_master_engine" then
        -- Check if engine has its own efficiency rating
        if engine.GetEfficiencyRating and type(engine.GetEfficiencyRating) == "function" then
            local success, rating = pcall(engine.GetEfficiencyRating, engine)
            if success and rating and rating > 0 then
                efficiency = rating
            else
                efficiency = 1.2 -- Default Master Engine efficiency bonus
            end
        else
            efficiency = 1.2 -- Default Master Engine efficiency bonus
        end
    end

    return math.ceil(baseCost / efficiency)
end

-- Manual jump control
function ENT:ExecuteManualJump(engine, destination, ply)
    if not IsValid(engine) then return false, "Invalid engine" end
    if not destination then return false, "No destination set" end

    -- Safety checks
    if self.SafetyChecks then
        local distance = engine:GetPos():Distance(destination)
        if distance < HYPERDRIVE.Config.MinJumpDistance then
            return false, "Destination too close (minimum " .. HYPERDRIVE.Config.MinJumpDistance .. " units)"
        end
        if distance > HYPERDRIVE.Config.MaxJumpDistance then
            return false, "Destination too far (maximum " .. HYPERDRIVE.Config.MaxJumpDistance .. " units)"
        end

        -- Check for obstacles
        local trace = util.TraceLine({
            start = destination,
            endpos = destination + Vector(0, 0, 100),
            filter = engine
        })

        if trace.Hit and trace.HitSky then
            return false, "Destination is in the sky"
        end
    end

    -- Check energy requirements
    local requiredEnergy = self:CalculateJumpCost(destination, engine)
    if engine:GetEnergy() < requiredEnergy then
        return false, string.format("Insufficient energy (need %d, have %d)", requiredEnergy, engine:GetEnergy())
    end

    -- Create world effects instead of HUD animations
    if HYPERDRIVE.WorldEffects and self.DetectedShip then
        HYPERDRIVE.WorldEffects.CreateChargingEffects(engine, self.DetectedShip)

        timer.Simple(1, function()
            if IsValid(engine) and self.DetectedShip then
                HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(engine, self.DetectedShip, "enter")
            end
        end)

        timer.Simple(2, function()
            if IsValid(engine) and self.DetectedShip then
                HYPERDRIVE.WorldEffects.CreateStarlinesEffect(engine, self.DetectedShip)
            end
        end)
    end

    -- Debug information
    if GetConVar("developer"):GetInt() > 0 then
        print("[Hyperdrive Computer] Setting destination:")
        print("  Engine: " .. tostring(engine))
        print("  Engine position: " .. tostring(engine:GetPos()))
        print("  Destination: " .. tostring(destination))
        print("  Distance: " .. tostring(engine:GetPos():Distance(destination)))
    end

    -- Use hyperspace dimension system if available, otherwise use direct engine jump
    local useHyperspaceDimension = HYPERDRIVE.HyperspaceDimension and HYPERDRIVE.HyperspaceDimension.StartHyperspaceTravel
    local jumpSuccess = false

    if useHyperspaceDimension then
        -- Try hyperspace dimension system first
        jumpSuccess = HYPERDRIVE.HyperspaceDimension.StartHyperspaceTravel(engine, destination, 3)
        if jumpSuccess then
            print("[Hyperdrive Computer] Manual jump using hyperspace dimension system")
        else
            print("[Hyperdrive Computer] Hyperspace dimension system failed, falling back to direct jump")
        end
    end

    -- Fallback to direct engine jump if hyperspace dimension system failed or unavailable
    if not jumpSuccess then
        -- Execute jump using direct engine call
        local success, message = engine:SetDestinationPos(destination)
        if not success then
            return false, "Failed to set destination: " .. (message or "Unknown error")
        end

        -- For Master Engine, use StartJumpMaster instead of StartJump
        if engine:GetClass() == "hyperdrive_master_engine" then
            jumpSuccess, message = engine:StartJumpMaster()
            if not jumpSuccess then
                return false, "Jump failed: " .. (message or "Unknown error")
            end
        else
            jumpSuccess, message = engine:StartJump()
            if not jumpSuccess then
                return false, "Jump failed: " .. (message or "Unknown error")
            end
        end

        -- Create exit effects with world effects system
        timer.Simple(3, function()
            if IsValid(engine) and HYPERDRIVE.WorldEffects and self.DetectedShip then
                -- Update ship position for exit effect
                self.DetectedShip.center = destination
                HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(engine, self.DetectedShip, "exit")
            end
        end)
    end

    -- Add to location history
    table.insert(self.LocationHistory, {
        from = engine:GetPos(),
        to = destination,
        timestamp = os.time(),
        energy = requiredEnergy,
        pilot = IsValid(ply) and ply:Nick() or "Computer"
    })

    return true, "Manual jump initiated"
end

-- Emergency abort all operations
function ENT:EmergencyAbort()
    local aborted = 0

    for _, engine in ipairs(self.LinkedEngines) do
        if IsValid(engine) and engine:GetCharging() then
            if engine.AbortJump then
                engine:AbortJump()
                aborted = aborted + 1
            end
        end
    end

    -- Clear jump queue
    self.JumpQueue = {}

    return aborted > 0, string.format("Emergency abort: %d operations cancelled", aborted)
end

-- Safe table access functions
function ENT:SafeGetTable(tableName)
    if not self[tableName] then
        self[tableName] = {}
    end
    return self[tableName]
end

function ENT:SafeAddToTable(tableName, key, value)
    local tbl = self:SafeGetTable(tableName)
    if key ~= nil and value ~= nil then
        tbl[key] = value
    end
end

function ENT:SafeRemoveFromTable(tableName, key)
    local tbl = self:SafeGetTable(tableName)
    if key ~= nil then
        tbl[key] = nil
    end
end

-- Save waypoints to file (with safe serialization)
function ENT:SaveWaypointsToFile()
    local waypoints = self:SafeGetTable("SavedWaypoints")

    -- Clean waypoints before saving
    local cleanWaypoints = {}
    for name, pos in pairs(waypoints) do
        if name and pos and isvector(pos) then
            cleanWaypoints[tostring(name)] = Vector(pos.x, pos.y, pos.z)
        end
    end

    local data = util.TableToJSON(cleanWaypoints)
    if data then
        file.CreateDir("hyperdrive")
        file.Write("hyperdrive/computer_waypoints_" .. self:EntIndex() .. ".txt", data)
        return true
    end
    return false
end

-- Load waypoints from file (with safe deserialization)
function ENT:LoadWaypointsFromFile()
    local fileName = "hyperdrive/computer_waypoints_" .. self:EntIndex() .. ".txt"
    if file.Exists(fileName, "DATA") then
        local data = file.Read(fileName, "DATA")
        if data then
            local waypoints = util.JSONToTable(data)
            if waypoints and istable(waypoints) then
                -- Safely restore waypoints
                self.SavedWaypoints = {}
                for name, pos in pairs(waypoints) do
                    if name and pos and isvector(pos) then
                        self.SavedWaypoints[tostring(name)] = Vector(pos.x, pos.y, pos.z)
                    end
                end
                return true
            end
        end
    end
    return false
end

-- Update ship detection using ship core system
function ENT:UpdateShipDetection()
    if not HYPERDRIVE.ShipCore then return end

    self.LastShipUpdate = CurTime()

    -- Try to detect ship using computer as core
    local ship = HYPERDRIVE.ShipCore.GetShip(self)
    if not ship then
        -- Try to detect ship using linked engines
        for _, engine in ipairs(self.LinkedEngines) do
            if IsValid(engine) then
                ship = HYPERDRIVE.ShipCore.GetShip(engine)
                if ship then break end
            end
        end
    end

    if not ship then
        -- Try to create ship detection with computer as core
        ship = HYPERDRIVE.ShipCore.DetectShipForEngine(self)
    end

    if ship then
        self.DetectedShip = ship
        self.ShipInfo = {
            shipType = ship:GetShipType(),
            classification = ship:GetClassification(),
            center = ship:GetCenter(),
            bounds = {ship:GetBounds()},
            entities = ship:GetEntities(),
            players = ship:GetPlayers()
        }

        print("[Hyperdrive Computer] Ship detected: " .. ship:GetShipType() .. " with " .. #ship:GetEntities() .. " entities")
    else
        self.DetectedShip = nil
        self.ShipInfo = {}
    end
end

-- Get ship information for display
function ENT:GetShipInfo()
    if self.DetectedShip then
        return self.ShipInfo
    end
    return nil
end

-- Create world effects for fleet jump
function ENT:CreateFleetJumpEffects(destination)
    if not HYPERDRIVE.WorldEffects or not self.DetectedShip then return end

    -- Create charging effects around ship
    HYPERDRIVE.WorldEffects.CreateChargingEffects(self, self.DetectedShip)

    -- Create hyperspace window sequence
    timer.Simple(1, function()
        if IsValid(self) and self.DetectedShip then
            HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(self, self.DetectedShip, "enter")
        end
    end)

    -- Create starlines during travel
    timer.Simple(2, function()
        if IsValid(self) and self.DetectedShip then
            HYPERDRIVE.WorldEffects.CreateStarlinesEffect(self, self.DetectedShip)
        end
    end)

    -- Create exit effects
    timer.Simple(4, function()
        if IsValid(self) and self.DetectedShip then
            -- Update ship position for exit effect
            self.DetectedShip.center = destination
            HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(self, self.DetectedShip, "exit")
        end
    end)
end

-- Create Stargate 4-stage effects
function ENT:Create4StageEffects(stage)
    if not HYPERDRIVE.WorldEffects or not self.DetectedShip then return end

    HYPERDRIVE.WorldEffects.CreateStargateEffects(self, self.DetectedShip, stage)
end

-- Planet Detection System
function ENT:ScanForPlanets()
    if not self.AutoDetectPlanets then return end
    if CurTime() - self.LastPlanetScan < self.PlanetScanInterval then return end

    self.LastPlanetScan = CurTime()
    local planetsFound = 0

    -- Spacebuild planet entity classes to detect
    local planetClasses = {
        "sb3_planet",
        "sb_planet",
        "caf_planet",
        "spacebuild_planet",
        "planet",
        "sb3_moon",
        "sb_moon",
        "moon"
    }

    -- Scan for planets in a large radius
    local scanRadius = 50000 -- 50km scan radius
    local nearbyEnts = ents.FindInSphere(self:GetPos(), scanRadius)

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            local class = ent:GetClass()
            local isPlanet = false

            -- Check if entity is a planet
            for _, planetClass in ipairs(planetClasses) do
                if string.find(string.lower(class), string.lower(planetClass)) then
                    isPlanet = true
                    break
                end
            end

            -- Also check for large spherical entities that might be planets
            if not isPlanet and ent:GetModel() then
                local model = string.lower(ent:GetModel())
                if string.find(model, "planet") or string.find(model, "sphere") or string.find(model, "ball") then
                    local size = ent:BoundingRadius()
                    if size > 500 then -- Large enough to be a planet
                        isPlanet = true
                    end
                end
            end

            if isPlanet then
                local planetData = self:AnalyzePlanet(ent)
                if planetData then
                    self:AddPlanetWaypoint(planetData)
                    planetsFound = planetsFound + 1
                end
            end
        end
    end

    -- Also scan for Spacebuild environments that might indicate planets
    if CAF and CAF.GetEnvironment then
        self:ScanForSpacebuildEnvironments()
    end

    if planetsFound > 0 then
        print("[Hyperdrive Computer] Auto-detected " .. planetsFound .. " planets")
    end
end

-- Analyze planet entity to extract useful data
function ENT:AnalyzePlanet(planet)
    if not IsValid(planet) then return nil end

    local planetData = {
        entity = planet,
        name = self:GeneratePlanetName(planet),
        position = planet:GetPos(),
        class = planet:GetClass(),
        size = planet:BoundingRadius(),
        distance = self:GetPos():Distance(planet:GetPos()),
        timestamp = os.time(),
        type = "planet",
        category = "Celestial Body"
    }

    -- Try to get planet-specific data
    if planet.GetPlanetName and planet:GetPlanetName() then
        planetData.name = planet:GetPlanetName()
    elseif planet.GetName and planet:GetName() then
        planetData.name = planet:GetName()
    elseif planet.PrintName and planet.PrintName ~= "" then
        planetData.name = planet.PrintName
    end

    -- Get planet properties if available
    if planet.GetGravity then
        planetData.gravity = planet:GetGravity()
    end

    if planet.GetAtmosphere then
        planetData.atmosphere = planet:GetAtmosphere()
    end

    if planet.GetTemperature then
        planetData.temperature = planet:GetTemperature()
    end

    -- Determine planet type based on properties
    planetData.planetType = self:ClassifyPlanet(planetData)

    return planetData
end

-- Generate a name for unnamed planets
function ENT:GeneratePlanetName(planet)
    local baseName = "Planet"

    -- Try to use model name
    if planet:GetModel() then
        local model = planet:GetModel()
        local modelName = string.match(model, "([^/]+)%.mdl$")
        if modelName then
            baseName = string.gsub(modelName, "_", " ")
            baseName = string.gsub(baseName, "^%l", string.upper) -- Capitalize first letter
        end
    end

    -- Add coordinates for uniqueness
    local pos = planet:GetPos()
    local coordSuffix = string.format("_%d_%d", math.floor(pos.x/1000), math.floor(pos.y/1000))

    return baseName .. coordSuffix
end

-- Classify planet based on its properties
function ENT:ClassifyPlanet(planetData)
    if planetData.size < 1000 then
        return "Asteroid"
    elseif planetData.size < 2000 then
        return "Moon"
    elseif planetData.size < 5000 then
        return "Small Planet"
    elseif planetData.size < 10000 then
        return "Planet"
    else
        return "Large Planet"
    end
end

-- Add planet as waypoint
function ENT:AddPlanetWaypoint(planetData)
    local waypointName = "[PLANET] " .. planetData.name

    -- Check if already exists
    if self.SavedWaypoints[waypointName] then return end

    -- Calculate safe landing position (above planet surface)
    local safePosition = planetData.position + Vector(0, 0, planetData.size + 200)

    local waypoint = {
        name = waypointName,
        position = safePosition,
        timestamp = planetData.timestamp,
        creator = "Auto-Detection System",
        description = string.format("%s - Distance: %.0f units", planetData.planetType, planetData.distance),
        category = "Planet",
        planetData = planetData,
        autoDetected = true,
        isPlanet = true  -- Flag for client interface
    }

    self.SavedWaypoints[waypointName] = waypoint
    self.DetectedPlanets[planetData.entity] = planetData

    self:SaveWaypointsToFile()
end

-- Scan for Spacebuild environments that might indicate planets
function ENT:ScanForSpacebuildEnvironments()
    if not CAF or not CAF.GetEnvironment then return end

    -- Sample positions in a grid around the computer
    local sampleDistance = 5000
    local samples = {
        Vector(sampleDistance, 0, 0),
        Vector(-sampleDistance, 0, 0),
        Vector(0, sampleDistance, 0),
        Vector(0, -sampleDistance, 0),
        Vector(0, 0, sampleDistance),
        Vector(0, 0, -sampleDistance)
    }

    for _, offset in ipairs(samples) do
        local samplePos = self:GetPos() + offset
        local env = CAF.GetEnvironment(samplePos)

        if env and env.planet then
            -- Found a planet environment
            local planetData = {
                name = env.planet.name or "Unknown Planet",
                position = samplePos,
                class = "environment_planet",
                size = env.planet.radius or 2000,
                distance = self:GetPos():Distance(samplePos),
                timestamp = os.time(),
                type = "environment",
                category = "Spacebuild Planet",
                gravity = env.gravity or 1,
                atmosphere = env.atmosphere or 0,
                temperature = env.temperature or 20
            }

            planetData.planetType = self:ClassifyPlanet(planetData)
            self:AddPlanetWaypoint(planetData)
        end
    end
end

-- Clear auto-detected planets
function ENT:ClearAutoDetectedPlanets()
    local cleared = 0

    for name, waypoint in pairs(self.SavedWaypoints) do
        if waypoint.autoDetected then
            self.SavedWaypoints[name] = nil
            cleared = cleared + 1
        end
    end

    self.DetectedPlanets = {}
    self:SaveWaypointsToFile()

    return cleared
end

-- Toggle auto planet detection
function ENT:TogglePlanetDetection()
    self.AutoDetectPlanets = not self.AutoDetectPlanets

    if self.AutoDetectPlanets then
        self:ScanForPlanets() -- Immediate scan when enabled
    end

    return self.AutoDetectPlanets
end

-- Auto-Link Planet System
function ENT:DoAutoLinkPlanets()
    if not self.AutoLinkPlanets then return 0 end

    local linkedCount = 0
    self.LinkedPlanets = {}
    self.QuickJumpTargets = {}

    -- Link all detected planets within range
    for name, waypoint in pairs(self.SavedWaypoints) do
        if waypoint.autoDetected and waypoint.planetData then
            local distance = self:GetPos():Distance(waypoint.position)

            if distance <= self.PlanetLinkRadius then
                local planetLink = {
                    name = waypoint.name,
                    waypoint = waypoint,
                    distance = distance,
                    entity = waypoint.planetData.entity,
                    safeCoords = waypoint.position,
                    planetType = waypoint.planetData.planetType,
                    linkTime = CurTime(),
                    quickAccess = true
                }

                table.insert(self.LinkedPlanets, planetLink)

                -- Add to quick jump targets (limit to 10 closest)
                if #self.QuickJumpTargets < 10 then
                    table.insert(self.QuickJumpTargets, planetLink)
                end

                linkedCount = linkedCount + 1
            end
        end
    end

    -- Sort quick jump targets by distance
    table.sort(self.QuickJumpTargets, function(a, b)
        return a.distance < b.distance
    end)

    if linkedCount > 0 then
        print("[Hyperdrive Computer] Auto-linked " .. linkedCount .. " planets for quick navigation")
    end

    return linkedCount
end

-- Quick jump to planet by name
function ENT:QuickJumpToPlanet(planetName, engine)
    if not planetName or planetName == "" then return false, "No planet name specified" end

    -- Find planet in quick jump targets or saved waypoints
    local targetPlanet = nil

    -- Helper function to clean planet names for matching
    local function cleanPlanetName(name)
        if not name then return "" end
        local cleaned = name
        -- Remove emoji and special characters
        cleaned = string.gsub(cleaned, "🌍", "")
        cleaned = string.gsub(cleaned, "🌎", "")
        cleaned = string.gsub(cleaned, "🌏", "")
        cleaned = string.gsub(cleaned, "🪐", "")
        cleaned = string.gsub(cleaned, "☀️", "")
        cleaned = string.gsub(cleaned, "🌙", "")
        -- Remove [PLANET] prefix
        cleaned = string.gsub(cleaned, "%[PLANET%]%s*", "")
        -- Remove extra spaces
        cleaned = string.gsub(cleaned, "^%s+", "")
        cleaned = string.gsub(cleaned, "%s+$", "")
        return string.lower(cleaned)
    end

    local searchName = cleanPlanetName(planetName)

    -- First check quick jump targets
    for _, planet in ipairs(self.QuickJumpTargets) do
        local cleanName = cleanPlanetName(planet.name)
        if string.find(cleanName, searchName) or string.find(searchName, cleanName) then
            targetPlanet = planet
            break
        end
    end

    -- If not found in quick targets, check all saved waypoints
    if not targetPlanet then
        for name, waypoint in pairs(self.SavedWaypoints) do
            if waypoint.isPlanet or waypoint.autoDetected then
                local cleanName = cleanPlanetName(name)

                -- Check if planet name matches (partial match in either direction)
                if string.find(cleanName, searchName) or string.find(searchName, cleanName) then
                    targetPlanet = {
                        name = name,
                        waypoint = waypoint,
                        safeCoords = waypoint.position,
                        distance = self:GetPos():Distance(waypoint.position)
                    }
                    break
                end
            end
        end
    end

    if not targetPlanet then
        -- Debug: Show available planets if developer mode is on
        if GetConVar("developer"):GetInt() > 0 then
            print("[Hyperdrive Computer] Planet search failed:")
            print("  Searching for: '" .. planetName .. "' (cleaned: '" .. searchName .. "')")
            print("  Quick jump targets (" .. #self.QuickJumpTargets .. "):")
            for i, planet in ipairs(self.QuickJumpTargets) do
                local cleanName = cleanPlanetName(planet.name)
                print("    " .. i .. ": '" .. planet.name .. "' (cleaned: '" .. cleanName .. "')")
            end
            print("  Available waypoints:")
            for name, waypoint in pairs(self.SavedWaypoints) do
                if waypoint.isPlanet or waypoint.autoDetected then
                    local cleanName = cleanPlanetName(name)
                    print("    '" .. name .. "' (cleaned: '" .. cleanName .. "')")
                end
            end
        end

        return false, "Planet '" .. planetName .. "' not found. Available planets: " .. #self.QuickJumpTargets .. " quick targets, " .. table.Count(self.SavedWaypoints) .. " total waypoints."
    end

    -- Use provided engine or find best available engine
    local jumpEngine = engine
    if not IsValid(jumpEngine) then
        jumpEngine = self:FindBestEngineForJump(targetPlanet.safeCoords)
    end

    if not IsValid(jumpEngine) then
        return false, "No suitable engine available for jump"
    end

    -- Debug information (if needed)
    if GetConVar("developer"):GetInt() > 0 then
        print("[Hyperdrive Computer] Quick jump debug:")
        print("  Planet: " .. tostring(targetPlanet.name))
        print("  Destination: " .. tostring(targetPlanet.safeCoords))
        print("  Engine: " .. tostring(jumpEngine))
        print("  Engine valid: " .. tostring(IsValid(jumpEngine)))
        if IsValid(jumpEngine) then
            print("  Engine class: " .. jumpEngine:GetClass())
            print("  Engine can jump: " .. tostring(jumpEngine:CanJump()))
            print("  Engine energy: " .. tostring(jumpEngine:GetEnergy()))
        end
    end

    -- Execute the jump
    local success, message = self:ExecuteManualJump(jumpEngine, targetPlanet.safeCoords)
    if success then
        return true, "Quick jump to " .. targetPlanet.name .. " initiated"
    else
        return false, "Jump failed: " .. message
    end
end

-- Find best engine for a jump
function ENT:FindBestEngineForJump(destination)
    local bestEngine = nil
    local lowestCost = math.huge

    -- Debug output only if developer mode is on
    if GetConVar("developer"):GetInt() > 0 then
        print("[Hyperdrive Computer] Finding best engine:")
        print("  Total linked engines: " .. #self.LinkedEngines)
        print("  Destination: " .. tostring(destination))
    end

    for i, engine in ipairs(self.LinkedEngines) do
        if GetConVar("developer"):GetInt() > 0 then
            print("  Engine " .. i .. ": " .. tostring(engine))
        end

        if IsValid(engine) then
            if GetConVar("developer"):GetInt() > 0 then
                print("    Valid: true, Class: " .. engine:GetClass())
                print("    Can jump: " .. tostring(engine:CanJump()))
                print("    Energy: " .. tostring(engine:GetEnergy()))
            end

            -- Check if engine can jump (but ignore "no destination" error for selection)
            local canJump = false
            if engine:GetClass() == "hyperdrive_master_engine" then
                -- For Master Engine, check individual conditions
                local hasEnergy = engine:GetEnergy() > 0
                local notCharging = not engine:GetCharging()
                local notOnCooldown = not engine:IsOnCooldown()
                canJump = hasEnergy and notCharging and notOnCooldown

                if GetConVar("developer"):GetInt() > 0 then
                    print("    Has energy: " .. tostring(hasEnergy))
                    print("    Not charging: " .. tostring(notCharging))
                    print("    Not on cooldown: " .. tostring(notOnCooldown))
                    print("    Can jump (ignoring destination): " .. tostring(canJump))
                end
            else
                canJump = engine:CanJump()
            end

            if canJump then
                local cost = self:CalculateJumpCost(destination, engine)

                if GetConVar("developer"):GetInt() > 0 then
                    print("    Jump cost: " .. tostring(cost))
                end

                if cost < lowestCost and engine:GetEnergy() >= cost then
                    bestEngine = engine
                    lowestCost = cost

                    if GetConVar("developer"):GetInt() > 0 then
                        print("    Selected as best engine!")
                    end
                end
            end
        else
            if GetConVar("developer"):GetInt() > 0 then
                print("    Valid: false")
            end
        end
    end

    if GetConVar("developer"):GetInt() > 0 then
        print("  Best engine found: " .. tostring(bestEngine))
    end

    return bestEngine
end

-- Get nearest linked planet
function ENT:GetNearestPlanet()
    if #self.LinkedPlanets == 0 then return nil end

    local nearest = nil
    local nearestDistance = math.huge

    for _, planet in ipairs(self.LinkedPlanets) do
        if planet.distance < nearestDistance then
            nearest = planet
            nearestDistance = planet.distance
        end
    end

    return nearest
end

-- Auto-link all planets in range
function ENT:AutoLinkAllPlanets()
    local linked = self:DoAutoLinkPlanets()
    return linked > 0, string.format("Auto-linked %d planets", linked)
end

-- Toggle auto-linking
function ENT:ToggleAutoLink()
    self.AutoLinkPlanets = not self.AutoLinkPlanets

    if self.AutoLinkPlanets then
        self:AutoLinkAllPlanets() -- Immediate link when enabled
    else
        self.LinkedPlanets = {}
        self.QuickJumpTargets = {}
    end

    return self.AutoLinkPlanets
end

-- Set planet link radius
function ENT:SetPlanetLinkRadius(radius)
    if radius and radius > 0 then
        self.PlanetLinkRadius = math.Clamp(radius, 1000, 500000) -- 1km to 500km
        self:AutoLinkAllPlanets() -- Re-link with new radius
        return true, "Planet link radius set to " .. self.PlanetLinkRadius .. " units"
    end
    return false, "Invalid radius"
end

-- Enhanced planet waypoint creation with auto-linking
function ENT:AddPlanetWaypointWithLink(planetData)
    -- First add the waypoint normally
    self:AddPlanetWaypoint(planetData)

    -- Then auto-link if enabled
    if self.AutoLinkPlanets then
        local distance = self:GetPos():Distance(planetData.position)
        if distance <= self.PlanetLinkRadius then
            timer.Simple(0.1, function()
                if IsValid(self) then
                    self:AutoLinkAllPlanets()
                end
            end)
        end
    end
end

-- Network strings are loaded from hyperdrive_network_strings.lua

net.Receive("hyperdrive_computer_mode", function(len, ply)
    local computer = net.ReadEntity()
    local mode = net.ReadInt(8)

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    computer:SetComputerMode(mode)
    local modeNames = {"Navigation", "Planets", "Status"}
    ply:ChatPrint("[Hyperdrive Computer] Mode changed to " .. (modeNames[mode] or "Navigation"))
end)

net.Receive("hyperdrive_fleet_jump", function(len, ply)
    local computer = net.ReadEntity()
    local destination = net.ReadVector()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local success, message = computer:ExecuteFleetJump(destination)
    ply:ChatPrint("[Hyperdrive Computer] " .. message)
end)

-- Manual jump handler
net.Receive("hyperdrive_manual_jump", function(len, ply)
    local computer = net.ReadEntity()
    local engine = net.ReadEntity()
    local destination = net.ReadVector()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local success, message = computer:ExecuteManualJump(engine, destination, ply)
    ply:ChatPrint("[Hyperdrive Computer] " .. message)
end)

-- Save waypoint handler
net.Receive("hyperdrive_save_waypoint", function(len, ply)
    local computer = net.ReadEntity()
    local name = net.ReadString()
    local position = net.ReadVector()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local success, message = computer:SaveWaypoint(name, position, ply)
    ply:ChatPrint("[Hyperdrive Computer] " .. message)
end)

-- Load waypoint handler
net.Receive("hyperdrive_load_waypoint", function(len, ply)
    local computer = net.ReadEntity()
    local name = net.ReadString()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local waypoint, message = computer:LoadWaypoint(name)
    if waypoint then
        computer.CurrentCoordinates = waypoint.position
        ply:ChatPrint("[Hyperdrive Computer] Waypoint '" .. name .. "' loaded")
    else
        ply:ChatPrint("[Hyperdrive Computer] " .. message)
    end
end)

-- Delete waypoint handler
net.Receive("hyperdrive_delete_waypoint", function(len, ply)
    local computer = net.ReadEntity()
    local name = net.ReadString()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local success, message = computer:DeleteWaypoint(name)
    ply:ChatPrint("[Hyperdrive Computer] " .. message)
end)

-- Emergency abort handler
net.Receive("hyperdrive_emergency_abort", function(len, ply)
    local computer = net.ReadEntity()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local success, message = computer:EmergencyAbort()
    ply:ChatPrint("[Hyperdrive Computer] " .. message)
end)

-- Planet scan handler
net.Receive("hyperdrive_scan_planets", function(len, ply)
    local computer = net.ReadEntity()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    computer:ScanForPlanets()
    ply:ChatPrint("[Hyperdrive Computer] Planet scan initiated")
end)

-- Toggle planet detection handler
net.Receive("hyperdrive_toggle_planet_detection", function(len, ply)
    local computer = net.ReadEntity()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local enabled = computer:TogglePlanetDetection()
    ply:ChatPrint("[Hyperdrive Computer] Planet auto-detection " .. (enabled and "enabled" or "disabled"))
end)

-- Clear planets handler
net.Receive("hyperdrive_clear_planets", function(len, ply)
    local computer = net.ReadEntity()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local cleared = computer:ClearAutoDetectedPlanets()
    ply:ChatPrint("[Hyperdrive Computer] Cleared " .. cleared .. " auto-detected planets")
end)

-- Auto-link planets handler
net.Receive("hyperdrive_auto_link_planets", function(len, ply)
    local computer = net.ReadEntity()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local success, message = computer:AutoLinkAllPlanets()
    ply:ChatPrint("[Hyperdrive Computer] " .. message)
end)

-- Toggle auto-link handler
net.Receive("hyperdrive_toggle_auto_link", function(len, ply)
    local computer = net.ReadEntity()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local enabled = computer:ToggleAutoLink()
    ply:ChatPrint("[Hyperdrive Computer] Planet auto-linking " .. (enabled and "enabled" or "disabled"))
end)

-- Quick jump to planet handler
net.Receive("hyperdrive_quick_jump_planet", function(len, ply)
    local computer = net.ReadEntity()
    local planetName = net.ReadString()

    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then return end
    if computer:GetPos():Distance(ply:GetPos()) > 200 then return end

    local success, message = computer:QuickJumpToPlanet(planetName)
    ply:ChatPrint("[Hyperdrive Computer] " .. message)
end)

-- ========================================
-- MASTER ENGINE CONTROL FUNCTIONS
-- ========================================

-- Auto-link to nearby master engines
function ENT:AutoLinkMasterEngines()
    local engines = ents.FindInSphere(self:GetPos(), 2000)
    local masterEngines = {}

    for _, ent in ipairs(engines) do
        if ent:GetClass() == "hyperdrive_master_engine" then
            table.insert(masterEngines, ent)
        end
    end

    if #masterEngines > 0 then
        self.ControlledMasterEngine = masterEngines[1]
        print("[Hyperdrive Computer] Auto-linked to Master Engine: " .. tostring(self.ControlledMasterEngine))
        return true, "Linked to " .. #masterEngines .. " master engines"
    else
        return false, "No master engines found within 2000 units"
    end
end

-- Start 4-stage jump using controlled master engine
function ENT:Start4StageJump()
    if not IsValid(self.ControlledMasterEngine) then
        return false, "No master engine under control"
    end

    local engine = self.ControlledMasterEngine
    local destination = self.MasterEngineDestination

    if destination == Vector(0, 0, 0) then
        destination = engine:GetDestination()
    end

    if destination == Vector(0, 0, 0) then
        return false, "No destination set"
    end

    -- Check if 4-stage system is available
    if not HYPERDRIVE.Stargate or not HYPERDRIVE.Stargate.StartFourStageTravel then
        return false, "4-stage travel system not available"
    end

    -- Check if engine can operate
    local canOperate, reason = engine:CanOperateMaster()
    if not canOperate then
        return false, "Engine cannot operate: " .. reason
    end

    -- Set destination if needed
    if engine:GetDestination() ~= destination then
        local success, message = engine:SetDestinationPos(destination)
        if not success then
            return false, "Failed to set destination: " .. message
        end
    end

    -- Get entities to transport
    local entitiesToMove = engine:GetEntitiesToTransport()

    -- Start 4-stage travel
    local success, message = HYPERDRIVE.Stargate.StartFourStageTravel(engine, destination, entitiesToMove)

    if success then
        self.FourStageJumpInProgress = true
        self.CurrentJumpStage = 1
        self.StageStartTime = CurTime()

        -- Monitor the jump progress
        self:MonitorFourStageProgress()

        return true, "4-stage Stargate travel initiated via computer control"
    else
        return false, "4-stage travel failed: " .. (message or "Unknown error")
    end
end

-- Start master engine jump (standard or 4-stage)
function ENT:StartMasterEngineJump()
    if not IsValid(self.ControlledMasterEngine) then
        return false, "No master engine under control"
    end

    local engine = self.ControlledMasterEngine

    -- Set destination if we have one
    if self.MasterEngineDestination ~= Vector(0, 0, 0) then
        local success, message = engine:SetDestinationPos(self.MasterEngineDestination)
        if not success then
            return false, "Failed to set destination: " .. message
        end
    end

    -- Start the jump (will automatically use 4-stage if available)
    local success, message = engine:StartJumpMaster()

    if success then
        -- Check if it's using 4-stage travel
        if HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.Config.StageSystem.EnableFourStageTravel then
            self.FourStageJumpInProgress = true
            self.CurrentJumpStage = 1
            self.StageStartTime = CurTime()
            self:MonitorFourStageProgress()
        end

        return true, message
    else
        return false, message
    end
end

-- Abort master engine jump
function ENT:AbortMasterEngineJump()
    if not IsValid(self.ControlledMasterEngine) then
        return false, "No master engine under control"
    end

    local engine = self.ControlledMasterEngine
    engine:AbortJump("Computer abort command")

    self.FourStageJumpInProgress = false
    self.CurrentJumpStage = 0
    self.StageStartTime = 0

    return true, "Master engine jump aborted"
end

-- Check master engine status
function ENT:CheckMasterEngineStatus()
    if not IsValid(self.ControlledMasterEngine) then
        return false, "No master engine under control"
    end

    local engine = self.ControlledMasterEngine
    local canOperate, reason = engine:CanOperateMaster()

    local status = {
        canOperate = canOperate,
        reason = reason,
        energy = engine:GetEnergy(),
        charging = engine:GetCharging(),
        cooldown = engine:GetCooldownRemaining(),
        destination = engine:GetDestination(),
        efficiency = engine:GetEfficiencyRating(),
        fourStageAvailable = HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.Config.StageSystem.EnableFourStageTravel or false
    }

    return true, status
end

-- Monitor 4-stage progress
function ENT:MonitorFourStageProgress()
    if not self.FourStageJumpInProgress then return end

    timer.Create("computer_4stage_monitor_" .. self:EntIndex(), 0.5, 0, function()
        if not IsValid(self) or not self.FourStageJumpInProgress then
            timer.Remove("computer_4stage_monitor_" .. self:EntIndex())
            return
        end

        -- Check if jump is still active
        if IsValid(self.ControlledMasterEngine) then
            local engine = self.ControlledMasterEngine

            -- Check if engine is still jumping
            if not engine:GetCharging() and engine:GetCooldownRemaining() == 0 then
                -- Jump completed
                self.FourStageJumpInProgress = false
                self.CurrentJumpStage = 0
                self.StageStartTime = 0
                timer.Remove("computer_4stage_monitor_" .. self:EntIndex())
                return
            end
        else
            -- Engine no longer valid
            self.FourStageJumpInProgress = false
            self.CurrentJumpStage = 0
            self.StageStartTime = 0
            timer.Remove("computer_4stage_monitor_" .. self:EntIndex())
            return
        end

        -- Update stage progress (this is approximate)
        local elapsed = CurTime() - self.StageStartTime
        local stageDuration = self:GetCurrentStageDuration()

        if elapsed >= stageDuration then
            self.CurrentJumpStage = math.min(self.CurrentJumpStage + 1, 4)
            self.StageStartTime = CurTime()
        end
    end)
end

-- Get current stage duration
function ENT:GetCurrentStageDuration()
    if not HYPERDRIVE.Stargate or not HYPERDRIVE.Stargate.Config then
        return 3 -- Default duration
    end

    local config = HYPERDRIVE.Stargate.Config.StageSystem

    if self.CurrentJumpStage == 1 then
        return config.InitiationDuration or 4
    elseif self.CurrentJumpStage == 2 then
        return config.WindowOpenDuration or 3
    elseif self.CurrentJumpStage == 3 then
        -- Travel time is variable, estimate based on distance
        if IsValid(self.ControlledMasterEngine) then
            local engine = self.ControlledMasterEngine
            local destination = engine:GetDestination()
            local distance = engine:GetPos():Distance(destination)
            return math.Clamp(distance / 2000, 3, 30)
        end
        return 10 -- Default travel time
    elseif self.CurrentJumpStage == 4 then
        return (config.ExitDuration or 2) + (config.StabilizationTime or 3)
    end

    return 3 -- Default
end

-- Console commands for computer-controlled master engine
concommand.Add("hyperdrive_computer_link_master", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "hyperdrive_computer" then
        ply:ChatPrint("[Hyperdrive Computer] Look at a hyperdrive computer")
        return
    end

    local computer = trace.Entity
    local success, message = computer:AutoLinkMasterEngines()

    if success then
        ply:ChatPrint("[Hyperdrive Computer] " .. message)
        ply:ChatPrint("[Hyperdrive Computer] Master engine linked for computer control")
    else
        ply:ChatPrint("[Hyperdrive Computer] " .. message)
    end
end)

concommand.Add("hyperdrive_computer_4stage", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "hyperdrive_computer" then
        ply:ChatPrint("[Hyperdrive Computer] Look at a hyperdrive computer")
        return
    end

    local computer = trace.Entity

    -- Set destination if provided
    if #args >= 3 then
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if x and y and z then
            computer.MasterEngineDestination = Vector(x, y, z)
            ply:ChatPrint("[Hyperdrive Computer] Destination set to: " .. tostring(computer.MasterEngineDestination))
        end
    end

    local success, message = computer:Start4StageJump()

    if success then
        ply:ChatPrint("[Hyperdrive Computer] " .. message)
        ply:ChatPrint("[Hyperdrive Computer] Watch the HUD for 4-stage progress!")
    else
        ply:ChatPrint("[Hyperdrive Computer] " .. message)
    end
end)

concommand.Add("hyperdrive_computer_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "hyperdrive_computer" then
        ply:ChatPrint("[Hyperdrive Computer] Look at a hyperdrive computer")
        return
    end

    local computer = trace.Entity

    ply:ChatPrint("[Hyperdrive Computer] Master Engine Control Status:")

    if IsValid(computer.ControlledMasterEngine) then
        local engine = computer.ControlledMasterEngine
        local success, status = computer:CheckMasterEngineStatus()

        if success then
            ply:ChatPrint("  • Controlled Engine: " .. tostring(engine))
            ply:ChatPrint("  • Status: " .. (status.canOperate and "READY" or status.reason))
            ply:ChatPrint("  • Energy: " .. math.floor(status.energy))
            ply:ChatPrint("  • Efficiency: " .. string.format("%.1fx", status.efficiency))
            ply:ChatPrint("  • Charging: " .. (status.charging and "YES" or "NO"))
            ply:ChatPrint("  • Cooldown: " .. string.format("%.1fs", status.cooldown))
            ply:ChatPrint("  • Destination: " .. tostring(status.destination))
            ply:ChatPrint("  • 4-Stage Available: " .. (status.fourStageAvailable and "YES" or "NO"))

            if computer.FourStageJumpInProgress then
                ply:ChatPrint("  • 4-Stage Active: YES (Stage " .. computer.CurrentJumpStage .. "/4)")
            else
                ply:ChatPrint("  • 4-Stage Active: NO")
            end
        end
    else
        ply:ChatPrint("  • No master engine under control")
        ply:ChatPrint("  • Use 'hyperdrive_computer_link_master' to link to nearby master engine")
    end
end)

concommand.Add("hyperdrive_computer_abort", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "hyperdrive_computer" then
        ply:ChatPrint("[Hyperdrive Computer] Look at a hyperdrive computer")
        return
    end

    local computer = trace.Entity
    local success, message = computer:AbortMasterEngineJump()
    ply:ChatPrint("[Hyperdrive Computer] " .. message)
end)

print("[Hyperdrive Computer] Master Engine control functions and commands loaded")
