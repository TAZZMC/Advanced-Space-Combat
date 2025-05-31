-- Enhanced Hyperdrive Docking Bay v2.2.1
-- Ship docking facility with automated services

print("[Hyperdrive Docking] Docking Bay v2.2.1 - Entity loading...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_interface002.mdl")
    self:SetModelScale(2.0)
    self:PhysicsInit(SOLID_VBBOX)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VBBOX)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Docking bay properties
    self:SetMaxHealth(2000)
    self:SetHealth(2000)
    
    -- Initialize docking system
    self.dockingBay = nil
    self.bayType = "medium" -- Default bay type
    self.lastUpdate = 0
    self.updateRate = 0.1
    
    -- Initialize network variables
    self:SetDockingActive(false)
    self:SetServicesActive(true)
    self:SetTrafficControl(true)
    self:SetOccupiedSlots(0)
    self:SetTotalSlots(0)
    self:SetQueueLength(0)
    self:SetEnergyConsumption(0)
    self:SetBayType("medium")
    self:SetDockingStatus("Initializing...")

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "DockingActive",
            "ServicesActive",
            "TrafficControl",
            "RequestDocking",
            "EmergencyUndock",
            "BayType"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "DockingActive",
            "OccupiedSlots",
            "TotalSlots",
            "QueueLength",
            "EnergyConsumption",
            "ServiceStatus",
            "DockingRequests"
        })
    end

    -- Initialize docking bay after short delay
    timer.Simple(1, function()
        if IsValid(self) then
            self:InitializeDockingBay()
        end
    end)

    print("[Hyperdrive Docking] Docking Bay initialized")
end

function ENT:InitializeDockingBay()
    -- Create docking bay system
    self.dockingBay = HYPERDRIVE.Docking.CreateDockingBay(self, self.bayType)
    
    if self.dockingBay then
        self:SetDockingActive(true)
        self:SetTotalSlots(self.dockingBay.config.capacity)
        self:SetBayType(self.bayType)
        self:SetDockingStatus("Docking bay online")
        print("[Docking Bay] Initialized " .. self.dockingBay.config.name)
    else
        self:SetDockingStatus("Failed to initialize docking bay")
    end
end

function ENT:Think()
    if not self.dockingBay then
        self:NextThink(CurTime() + 1)
        return true
    end
    
    -- Update docking bay status
    if CurTime() - self.lastUpdate >= self.updateRate then
        self:UpdateDockingStatus()
        self:UpdateWireOutputs()
        self.lastUpdate = CurTime()
    end
    
    self:NextThink(CurTime() + self.updateRate)
    return true
end

function ENT:UpdateDockingStatus()
    if not self.dockingBay then return end
    
    local status = self.dockingBay:GetStatus()
    
    self:SetDockingActive(status.active)
    self:SetOccupiedSlots(status.occupied)
    self:SetQueueLength(status.queueLength)
    self:SetEnergyConsumption(status.energyConsumption)
    
    -- Update status message
    if status.occupied == 0 then
        self:SetDockingStatus("Available - " .. status.capacity .. " slots")
    elseif status.occupied < status.capacity then
        self:SetDockingStatus("Partial - " .. status.occupied .. "/" .. status.capacity .. " occupied")
    else
        self:SetDockingStatus("Full - " .. status.queueLength .. " in queue")
    end
end

function ENT:TriggerInput(iname, value)
    if not self.dockingBay then return end
    
    if iname == "DockingActive" then
        self.dockingBay.active = value > 0
        self:SetDockingActive(value > 0)
    elseif iname == "ServicesActive" then
        self:SetServicesActive(value > 0)
        for serviceType, service in pairs(self.dockingBay.services) do
            service.active = value > 0
        end
    elseif iname == "TrafficControl" then
        self:SetTrafficControl(value > 0)
    elseif iname == "RequestDocking" and value > 0 then
        -- Find nearest ship to dock
        self:FindAndDockNearestShip()
    elseif iname == "EmergencyUndock" and value > 0 then
        -- Emergency undock all ships
        self:EmergencyUndockAll()
    elseif iname == "BayType" and value > 0 then
        -- Cycle bay type
        self:CycleBayType()
    end
    
    self:UpdateWireOutputs()
end

function ENT:FindAndDockNearestShip()
    local nearbyShips = ents.FindInSphere(self:GetPos(), HYPERDRIVE.Docking.Config.DockingRange)
    local closestShip = nil
    local closestDistance = math.huge
    
    for _, ent in ipairs(nearbyShips) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            local distance = self:GetPos():Distance(ent:GetPos())
            if distance < closestDistance then
                closestShip = ent
                closestDistance = distance
            end
        end
    end
    
    if closestShip then
        local success, reason = self.dockingBay:RequestDocking(closestShip)
        if success then
            print("[Docking Bay] Docking request accepted for ship " .. closestShip:EntIndex())
        else
            print("[Docking Bay] Docking request denied: " .. reason)
        end
    end
end

function ENT:EmergencyUndockAll()
    if not self.dockingBay then return end
    
    for ship, _ in pairs(self.dockingBay.dockedShips) do
        if IsValid(ship) then
            self.dockingBay:UndockShip(ship)
        end
    end
    
    print("[Docking Bay] Emergency undock initiated")
end

function ENT:CycleBayType()
    local bayTypes = {"small", "medium", "large", "shuttle"}
    local currentIndex = 1
    
    for i, bayType in ipairs(bayTypes) do
        if bayType == self.bayType then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = (currentIndex % #bayTypes) + 1
    self.bayType = bayTypes[nextIndex]
    
    -- Reinitialize with new bay type
    if self.dockingBay then
        HYPERDRIVE.Docking.RemoveDockingBay(self)
    end
    
    self:InitializeDockingBay()
    print("[Docking Bay] Bay type changed to: " .. self.bayType)
end

function ENT:UpdateWireOutputs()
    if not WireLib or not self.dockingBay then return end
    
    local status = self.dockingBay:GetStatus()
    local serviceStatus = 0
    
    -- Calculate service status (bitmask)
    for serviceType, service in pairs(status.services) do
        if service.active then
            if serviceType == "refuel" then serviceStatus = serviceStatus + 1 end
            if serviceType == "repair" then serviceStatus = serviceStatus + 2 end
            if serviceType == "resupply" then serviceStatus = serviceStatus + 4 end
            if serviceType == "upgrade" then serviceStatus = serviceStatus + 8 end
            if serviceType == "manufacturing" then serviceStatus = serviceStatus + 16 end
        end
    end
    
    WireLib.TriggerOutput(self, "DockingActive", self:GetDockingActive() and 1 or 0)
    WireLib.TriggerOutput(self, "OccupiedSlots", self:GetOccupiedSlots())
    WireLib.TriggerOutput(self, "TotalSlots", self:GetTotalSlots())
    WireLib.TriggerOutput(self, "QueueLength", self:GetQueueLength())
    WireLib.TriggerOutput(self, "EnergyConsumption", self:GetEnergyConsumption())
    WireLib.TriggerOutput(self, "ServiceStatus", serviceStatus)
    WireLib.TriggerOutput(self, "DockingRequests", #self.dockingBay.dockingQueue)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Docking Bay] Too far away to access controls")
        return
    end
    
    if not self.dockingBay then
        activator:ChatPrint("[Docking Bay] Docking system not initialized")
        return
    end
    
    self:ShowDockingInterface(activator)
end

function ENT:ShowDockingInterface(player)
    local status = self.dockingBay:GetStatus()
    
    player:ChatPrint("[Docking Bay] === DOCKING CONTROL ===")
    player:ChatPrint("Bay Type: " .. self.dockingBay.config.name)
    player:ChatPrint("Status: " .. self:GetDockingStatus())
    player:ChatPrint("Capacity: " .. status.occupied .. "/" .. status.capacity)
    player:ChatPrint("Queue: " .. status.queueLength .. " ships waiting")
    player:ChatPrint("Energy: " .. math.floor(status.energyConsumption) .. "/sec")
    player:ChatPrint("")
    
    -- Show services
    player:ChatPrint("Available Services:")
    for serviceType, service in pairs(status.services) do
        local serviceConfig = HYPERDRIVE.Docking.Config.Services[serviceType]
        if serviceConfig then
            local statusText = service.active and "ONLINE" or "OFFLINE"
            player:ChatPrint("- " .. serviceConfig.name .. ": " .. statusText)
        end
    end
    
    player:ChatPrint("")
    player:ChatPrint("Controls: Use wire inputs or nearby ship cores can request docking")
    
    -- Show docked ships
    if status.occupied > 0 then
        player:ChatPrint("")
        player:ChatPrint("Docked Ships:")
        for ship, shipData in pairs(self.dockingBay.dockedShips) do
            if IsValid(ship) then
                local dockTime = math.floor(CurTime() - shipData.dockTime)
                player:ChatPrint("- Ship " .. ship:EntIndex() .. " (docked " .. dockTime .. "s ago)")
            end
        end
    end
end

function ENT:RequestDocking(ship)
    if not self.dockingBay then return false, "Docking system offline" end
    
    return self.dockingBay:RequestDocking(ship)
end

function ENT:UndockShip(ship)
    if not self.dockingBay then return false, "Docking system offline" end
    
    return self.dockingBay:UndockShip(ship)
end

function ENT:GetDockingPositions()
    if not self.dockingBay then return {} end
    
    return self.dockingBay.dockingPositions
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    
    -- Damage can disrupt docking operations
    if self.dockingBay and math.random() < 0.2 then
        self.dockingBay.active = false
        self:SetDockingActive(false)
        self:SetDockingStatus("Docking systems damaged")
        
        timer.Simple(5, function()
            if IsValid(self) and self.dockingBay then
                self.dockingBay.active = true
                self:SetDockingActive(true)
                self:SetDockingStatus("Docking systems restored")
            end
        end)
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Emergency undock all ships
        self:EmergencyUndockAll()
        
        -- Create explosion effect
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetScale(4)
        util.Effect("Explosion", effectData)
        
        self:Remove()
    end
end

function ENT:OnRemove()
    -- Emergency undock all ships
    if self.dockingBay then
        self:EmergencyUndockAll()
        HYPERDRIVE.Docking.RemoveDockingBay(self)
    end
    
    if WireLib then
        Wire_Remove(self)
    end
    
    print("[Hyperdrive Docking] Docking Bay removed")
end

-- Network message handling
net.Receive("HyperdriveDockingRequest", function(len, ply)
    local dockingBay = net.ReadEntity()
    local ship = net.ReadEntity()
    
    if IsValid(dockingBay) and IsValid(ship) then
        local success, reason = dockingBay:RequestDocking(ship)
        
        -- Send response back to client
        net.Start("HyperdriveDockingStatus")
        net.WriteEntity(dockingBay)
        net.WriteEntity(ship)
        net.WriteBool(success)
        net.WriteString(reason or "")
        net.Send(ply)
    end
end)
