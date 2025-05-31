-- Enhanced Hyperdrive Shuttle v2.2.1
-- Automated shuttle craft for passenger and cargo transport

print("[Hyperdrive Shuttle] Shuttle v2.2.1 - Entity loading...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_dropship_container.mdl")
    self:SetModelScale(0.8)
    self:PhysicsInit(SOLID_VBBOX)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VBBOX)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(300)
    end

    -- Shuttle properties
    self:SetMaxHealth(800)
    self:SetHealth(800)
    
    -- Initialize shuttle system
    self.shuttle = nil
    self.shuttleType = "transport" -- Default shuttle type
    self.lastUpdate = 0
    self.updateRate = 0.5
    
    -- Initialize network variables
    self:SetShuttleActive(false)
    self:SetOnMission(false)
    self:SetEmergencyMode(false)
    self:SetPassengerCount(0)
    self:SetMaxPassengers(8)
    self:SetMissionsCompleted(0)
    self:SetCargoWeight(0)
    self:SetMaxCargoWeight(200)
    self:SetMissionProgress(0)
    self:SetEnergyConsumed(0)
    self:SetShuttleType("transport")
    self:SetShuttleStatus("Initializing...")
    self:SetCurrentMission("None")

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "ShuttleActive",
            "AssignMission",
            "LaunchMission",
            "ReturnToBase",
            "EmergencyLanding",
            "LoadPassenger",
            "LoadCargo",
            "ShuttleType"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "ShuttleActive",
            "OnMission",
            "EmergencyMode",
            "PassengerCount",
            "CargoWeight",
            "MissionProgress",
            "EnergyConsumed",
            "MissionsCompleted",
            "FlightTime"
        })
    end

    -- Initialize shuttle after short delay
    timer.Simple(1, function()
        if IsValid(self) then
            self:InitializeShuttle()
        end
    end)

    print("[Hyperdrive Shuttle] Shuttle initialized")
end

function ENT:InitializeShuttle()
    -- Create shuttle system
    self.shuttle = HYPERDRIVE.Shuttle.CreateShuttle(self, self.shuttleType)
    
    if self.shuttle then
        self:SetShuttleActive(true)
        self:SetMaxPassengers(self.shuttle.maxPassengers)
        self:SetMaxCargoWeight(self.shuttle.maxCargoWeight)
        self:SetShuttleType(self.shuttleType)
        self:SetShuttleStatus("Shuttle ready for missions")
        print("[Shuttle] Initialized " .. self.shuttle.config.name)
    else
        self:SetShuttleStatus("Failed to initialize shuttle")
    end
end

function ENT:Think()
    if not self.shuttle then
        self:NextThink(CurTime() + 1)
        return true
    end
    
    -- Update shuttle status
    if CurTime() - self.lastUpdate >= self.updateRate then
        self:UpdateShuttleStatus()
        self:UpdateWireOutputs()
        self.lastUpdate = CurTime()
    end
    
    self:NextThink(CurTime() + self.updateRate)
    return true
end

function ENT:UpdateShuttleStatus()
    if not self.shuttle then return end
    
    local status = self.shuttle:GetStatus()
    
    self:SetShuttleActive(status.active)
    self:SetOnMission(status.currentMission ~= nil)
    self:SetEmergencyMode(status.status == "emergency")
    self:SetPassengerCount(status.passengers)
    self:SetCargoWeight(status.cargoWeight)
    self:SetMissionProgress(status.missionProgress)
    self:SetEnergyConsumed(status.energyConsumed)
    self:SetMissionsCompleted(status.missionsCompleted)
    
    -- Update status message
    if status.status == "docked" then
        if status.currentMission then
            self:SetShuttleStatus("Docked - Mission assigned")
            self:SetCurrentMission(status.currentMission.type)
        else
            self:SetShuttleStatus("Docked - Awaiting mission")
            self:SetCurrentMission("None")
        end
    elseif status.status == "launching" then
        self:SetShuttleStatus("Launching")
    elseif status.status == "flying" then
        self:SetShuttleStatus("En route - " .. math.floor(status.missionProgress * 100) .. "% complete")
    elseif status.status == "landing" then
        self:SetShuttleStatus("Landing")
    elseif status.status == "emergency" then
        self:SetShuttleStatus("EMERGENCY - Seeking landing site")
        self:SetCurrentMission("Emergency")
    else
        self:SetShuttleStatus("Status: " .. status.status)
    end
end

function ENT:TriggerInput(iname, value)
    if not self.shuttle then return end
    
    if iname == "ShuttleActive" then
        self.shuttle.active = value > 0
        self:SetShuttleActive(value > 0)
    elseif iname == "AssignMission" and value > 0 then
        -- Create a basic transport mission to a random nearby location
        self:CreateRandomMission()
    elseif iname == "LaunchMission" and value > 0 then
        if self.shuttle.currentMission then
            self.shuttle:LaunchMission()
        end
    elseif iname == "ReturnToBase" and value > 0 then
        self.shuttle:ReturnToBase()
    elseif iname == "EmergencyLanding" and value > 0 then
        self.shuttle:InitiateEmergencyProcedures()
    elseif iname == "LoadPassenger" and value > 0 then
        -- Simulate loading a passenger
        if #self.shuttle.passengers < self.shuttle.maxPassengers then
            self.shuttle:LoadPassenger("Passenger_" .. (#self.shuttle.passengers + 1))
        end
    elseif iname == "LoadCargo" and value > 0 then
        -- Simulate loading cargo
        self.shuttle:LoadCargo("supplies", 10)
    elseif iname == "ShuttleType" and value > 0 then
        -- Cycle shuttle type
        self:CycleShuttleType()
    end
    
    self:UpdateWireOutputs()
end

function ENT:CreateRandomMission()
    -- Find a random destination within range
    local shuttlePos = self:GetPos()
    local range = self.shuttle.config.range
    local destination = shuttlePos + VectorRand() * range
    destination.z = math.max(destination.z, shuttlePos.z) -- Keep above ground
    
    -- Create mission
    local missionTypes = {"passenger_transport", "cargo_delivery", "supply_run"}
    local missionType = missionTypes[math.random(#missionTypes)]
    
    local mission = HYPERDRIVE.Shuttle.CreateMission(missionType, destination, 2)
    
    -- Add some passengers or cargo
    if missionType == "passenger_transport" then
        for i = 1, math.random(1, 4) do
            mission:AddPassenger("Passenger_" .. i)
        end
    elseif missionType == "cargo_delivery" then
        mission:AddCargo("supplies", math.random(10, 50))
        mission:AddCargo("equipment", math.random(1, 5))
    elseif missionType == "supply_run" then
        mission:AddCargo("supplies", math.random(20, 100))
        mission:AddCargo("medical", math.random(5, 20))
    end
    
    -- Assign mission to this shuttle
    local success = self.shuttle:AssignMission(mission)
    if success then
        print("[Shuttle] Random mission assigned: " .. missionType)
    else
        print("[Shuttle] Failed to assign mission")
    end
end

function ENT:CycleShuttleType()
    local shuttleTypes = {"transport", "cargo", "emergency", "scout"}
    local currentIndex = 1
    
    for i, shuttleType in ipairs(shuttleTypes) do
        if shuttleType == self.shuttleType then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = (currentIndex % #shuttleTypes) + 1
    self.shuttleType = shuttleTypes[nextIndex]
    
    -- Reinitialize with new shuttle type
    if self.shuttle then
        HYPERDRIVE.Shuttle.RemoveShuttle(self)
    end
    
    self:InitializeShuttle()
    print("[Shuttle] Shuttle type changed to: " .. self.shuttleType)
end

function ENT:UpdateWireOutputs()
    if not WireLib or not self.shuttle then return end
    
    local status = self.shuttle:GetStatus()
    
    WireLib.TriggerOutput(self, "ShuttleActive", status.active and 1 or 0)
    WireLib.TriggerOutput(self, "OnMission", (status.currentMission ~= nil) and 1 or 0)
    WireLib.TriggerOutput(self, "EmergencyMode", (status.status == "emergency") and 1 or 0)
    WireLib.TriggerOutput(self, "PassengerCount", status.passengers)
    WireLib.TriggerOutput(self, "CargoWeight", status.cargoWeight)
    WireLib.TriggerOutput(self, "MissionProgress", status.missionProgress * 100)
    WireLib.TriggerOutput(self, "EnergyConsumed", status.energyConsumed)
    WireLib.TriggerOutput(self, "MissionsCompleted", status.missionsCompleted)
    WireLib.TriggerOutput(self, "FlightTime", status.totalFlightTime)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Shuttle] Too far away to access shuttle")
        return
    end
    
    if not self.shuttle then
        activator:ChatPrint("[Shuttle] Shuttle system not initialized")
        return
    end
    
    self:ShowShuttleInterface(activator)
end

function ENT:ShowShuttleInterface(player)
    local status = self.shuttle:GetStatus()
    
    player:ChatPrint("[Shuttle] === SHUTTLE CONTROL ===")
    player:ChatPrint("Type: " .. self.shuttle.config.name)
    player:ChatPrint("Status: " .. self:GetShuttleStatus())
    player:ChatPrint("Passengers: " .. status.passengers .. "/" .. status.maxPassengers)
    player:ChatPrint("Cargo: " .. math.floor(status.cargoWeight) .. "/" .. status.maxCargoWeight .. " kg")
    player:ChatPrint("Missions Completed: " .. status.missionsCompleted)
    player:ChatPrint("Flight Time: " .. math.floor(status.totalFlightTime) .. " seconds")
    player:ChatPrint("Energy Consumed: " .. math.floor(status.energyConsumed))
    player:ChatPrint("")
    
    -- Show current mission
    if status.currentMission then
        player:ChatPrint("Current Mission: " .. status.currentMission.type)
        player:ChatPrint("Progress: " .. math.floor(status.missionProgress * 100) .. "%")
        player:ChatPrint("Destination: " .. tostring(status.destination))
    else
        player:ChatPrint("No active mission")
    end
    
    player:ChatPrint("")
    player:ChatPrint("Use wire inputs to control shuttle operations")
    
    -- Show cargo manifest
    if next(self.shuttle.cargo) then
        player:ChatPrint("")
        player:ChatPrint("Cargo Manifest:")
        for cargoType, amount in pairs(self.shuttle.cargo) do
            local cargoConfig = HYPERDRIVE.Shuttle.Config.CargoTypes[cargoType]
            if cargoConfig then
                player:ChatPrint("- " .. amount .. " " .. cargoConfig.name)
            end
        end
    end
    
    -- Show passenger list
    if #self.shuttle.passengers > 0 then
        player:ChatPrint("")
        player:ChatPrint("Passengers:")
        for i, passenger in ipairs(self.shuttle.passengers) do
            player:ChatPrint("- " .. tostring(passenger))
        end
    end
end

function ENT:AssignMission(mission)
    if not self.shuttle then return false, "Shuttle system offline" end
    
    return self.shuttle:AssignMission(mission)
end

function ENT:LaunchMission()
    if not self.shuttle then return false, "Shuttle system offline" end
    
    return self.shuttle:LaunchMission()
end

function ENT:LoadPassenger(passenger)
    if not self.shuttle then return false, "Shuttle system offline" end
    
    return self.shuttle:LoadPassenger(passenger)
end

function ENT:LoadCargo(cargoType, amount)
    if not self.shuttle then return false, "Shuttle system offline" end
    
    return self.shuttle:LoadCargo(cargoType, amount)
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    
    -- Damage can trigger emergency procedures
    if self.shuttle and math.random() < 0.4 then
        if not self.shuttle.status == "emergency" then
            self.shuttle:InitiateEmergencyProcedures()
        end
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Emergency landing if carrying passengers
        if self.shuttle and #self.shuttle.passengers > 0 then
            self.shuttle:InitiateEmergencyProcedures()
            
            -- Give shuttle time to land
            timer.Simple(10, function()
                if IsValid(self) then
                    self:CreateExplosion()
                    self:Remove()
                end
            end)
        else
            self:CreateExplosion()
            self:Remove()
        end
    end
end

function ENT:CreateExplosion()
    -- Create explosion effect
    local effectData = EffectData()
    effectData:SetOrigin(self:GetPos())
    effectData:SetScale(3)
    util.Effect("Explosion", effectData)
    
    -- Create debris
    for i = 1, 5 do
        timer.Simple(i * 0.1, function()
            local debris = EffectData()
            debris:SetOrigin(self:GetPos() + VectorRand() * 100)
            debris:SetScale(1)
            util.Effect("MetalSpark", debris)
        end)
    end
end

function ENT:OnRemove()
    -- Clean up shuttle system
    if self.shuttle then
        HYPERDRIVE.Shuttle.RemoveShuttle(self)
    end

    if WireLib then
        Wire_Remove(self)
    end

    -- Support undo system
    if self.UndoID then
        undo.ReplaceEntity(self.UndoID, NULL)
    end

    print("[Hyperdrive Shuttle] Shuttle removed")
end

-- Network message handling
net.Receive("HyperdriveShuttleMission", function(len, ply)
    local shuttle = net.ReadEntity()
    local missionType = net.ReadString()
    local destination = net.ReadVector()
    
    if IsValid(shuttle) and shuttle.shuttle then
        local mission = HYPERDRIVE.Shuttle.CreateMission(missionType, destination, 2)
        local success = shuttle:AssignMission(mission)
        
        -- Send response back to client
        net.Start("HyperdriveShuttleStatus")
        net.WriteEntity(shuttle)
        net.WriteBool(success)
        net.WriteString(success and "Mission assigned" or "Failed to assign mission")
        net.Send(ply)
    end
end)
