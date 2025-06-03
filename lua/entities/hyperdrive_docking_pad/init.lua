-- Enhanced Hyperdrive Docking Pad v2.2.1
-- Ship landing pad with automated guidance and services

print("[Hyperdrive Docking] Docking Pad v2.2.1 - Entity loading...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_interface002.mdl")
    self:SetModelScale(3.0)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Docking pad properties
    self:SetMaxHealth(1500)
    self:SetHealth(1500)
    
    -- Initialize docking system
    self.landingPad = nil
    self.padType = "medium" -- Default pad type
    self.lastUpdate = 0
    self.updateRate = 0.2
    
    -- Initialize network variables
    self:SetPadActive(false)
    self:SetServicesActive(true)
    self:SetGuidanceActive(true)
    self:SetOccupied(false)
    self:SetQueueLength(0)
    self:SetEnergyConsumption(0)
    self:SetLandingRadius(250)
    self:SetPadType("medium")
    self:SetPadStatus("Initializing...")

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "PadActive",
            "ServicesActive",
            "GuidanceActive",
            "RequestLanding",
            "LaunchShip",
            "PadType"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "PadActive",
            "Occupied",
            "QueueLength",
            "EnergyConsumption",
            "LandedShip",
            "ServiceStatus",
            "LandingRequests"
        })
    end

    -- Initialize landing pad after short delay
    timer.Simple(1, function()
        if IsValid(self) then
            self:InitializeLandingPad()
        end
    end)

    print("[Hyperdrive Docking] Docking Pad initialized")
end

function ENT:InitializeLandingPad()
    -- Create landing pad system
    self.landingPad = HYPERDRIVE.DockingPad.CreateLandingPad(self, self.padType)
    
    if self.landingPad then
        self:SetPadActive(true)
        self:SetLandingRadius(self.landingPad.config.landingRadius)
        self:SetPadType(self.padType)
        self:SetPadStatus("Landing pad online")
        print("[Docking Pad] Initialized " .. self.landingPad.config.name)
    else
        self:SetPadStatus("Failed to initialize landing pad")
    end
end

function ENT:Think()
    if not self.landingPad then
        self:NextThink(CurTime() + 1)
        return true
    end
    
    -- Update landing pad status
    if CurTime() - self.lastUpdate >= self.updateRate then
        self:UpdatePadStatus()
        self:UpdateWireOutputs()
        self.lastUpdate = CurTime()
    end
    
    self:NextThink(CurTime() + self.updateRate)
    return true
end

function ENT:UpdatePadStatus()
    if not self.landingPad then return end
    
    local status = self.landingPad:GetStatus()
    
    self:SetPadActive(status.active)
    self:SetOccupied(status.occupied)
    self:SetQueueLength(status.queueLength)
    self:SetEnergyConsumption(status.energyConsumption)
    self:SetLandedShip(status.landedShip)
    
    -- Update status message
    if not status.active then
        self:SetPadStatus("Landing pad offline")
    elseif status.occupied then
        self:SetPadStatus("Occupied - Ship landed")
    elseif status.queueLength > 0 then
        self:SetPadStatus("Available - " .. status.queueLength .. " in queue")
    else
        self:SetPadStatus("Available - Ready for landing")
    end
end

function ENT:TriggerInput(iname, value)
    if not self.landingPad then return end
    
    if iname == "PadActive" then
        self.landingPad.active = value > 0
        self:SetPadActive(value > 0)
    elseif iname == "ServicesActive" then
        self:SetServicesActive(value > 0)
        for serviceType, service in pairs(self.landingPad.services) do
            service.active = value > 0
        end
    elseif iname == "GuidanceActive" then
        self:SetGuidanceActive(value > 0)
        self.landingPad.guidanceBeacon = value > 0
    elseif iname == "RequestLanding" and value > 0 then
        -- Find nearest ship to land
        self:FindAndLandNearestShip()
    elseif iname == "LaunchShip" and value > 0 then
        -- Launch currently landed ship
        if self.landingPad.landedShip then
            self.landingPad:LaunchShip(self.landingPad.landedShip)
        end
    elseif iname == "PadType" and value > 0 then
        -- Cycle pad type
        self:CyclePadType()
    end
    
    self:UpdateWireOutputs()
end

function ENT:FindAndLandNearestShip()
    local nearbyShips = ents.FindInSphere(self:GetPos(), HYPERDRIVE.DockingPad.Config.LandingRange)
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
        local success, reason = self.landingPad:RequestLanding(closestShip)
        if success then
            print("[Docking Pad] Landing request accepted for ship " .. closestShip:EntIndex())
        else
            print("[Docking Pad] Landing request denied: " .. reason)
        end
    end
end

function ENT:CyclePadType()
    local padTypes = {"small", "medium", "large", "shuttle", "cargo"}
    local currentIndex = 1
    
    for i, padType in ipairs(padTypes) do
        if padType == self.padType then
            currentIndex = i
            break
        end
    end
    
    local nextIndex = (currentIndex % #padTypes) + 1
    self.padType = padTypes[nextIndex]
    
    -- Reinitialize with new pad type
    if self.landingPad then
        HYPERDRIVE.DockingPad.RemoveLandingPad(self)
    end
    
    self:InitializeLandingPad()
    print("[Docking Pad] Pad type changed to: " .. self.padType)
end

function ENT:UpdateWireOutputs()
    if not WireLib or not self.landingPad then return end
    
    local status = self.landingPad:GetStatus()
    local serviceStatus = 0
    
    -- Calculate service status (bitmask)
    for serviceType, service in pairs(status.services) do
        if service.active then
            if serviceType == "refuel" then serviceStatus = serviceStatus + 1 end
            if serviceType == "repair" then serviceStatus = serviceStatus + 2 end
            if serviceType == "resupply" then serviceStatus = serviceStatus + 4 end
            if serviceType == "passenger_transfer" then serviceStatus = serviceStatus + 8 end
            if serviceType == "cargo_transfer" then serviceStatus = serviceStatus + 16 end
        end
    end
    
    WireLib.TriggerOutput(self, "PadActive", self:GetPadActive() and 1 or 0)
    WireLib.TriggerOutput(self, "Occupied", self:GetOccupied() and 1 or 0)
    WireLib.TriggerOutput(self, "QueueLength", self:GetQueueLength())
    WireLib.TriggerOutput(self, "EnergyConsumption", self:GetEnergyConsumption())
    WireLib.TriggerOutput(self, "LandedShip", IsValid(self:GetLandedShip()) and self:GetLandedShip():EntIndex() or 0)
    WireLib.TriggerOutput(self, "ServiceStatus", serviceStatus)
    WireLib.TriggerOutput(self, "LandingRequests", #self.landingPad.landingQueue)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Docking Pad] Too far away to access controls")
        return
    end
    
    if not self.landingPad then
        activator:ChatPrint("[Docking Pad] Landing system not initialized")
        return
    end
    
    self:ShowLandingInterface(activator)
end

function ENT:ShowLandingInterface(player)
    local status = self.landingPad:GetStatus()
    
    player:ChatPrint("[Docking Pad] === LANDING CONTROL ===")
    player:ChatPrint("Pad Type: " .. self.landingPad.config.name)
    player:ChatPrint("Status: " .. self:GetPadStatus())
    player:ChatPrint("Landing Radius: " .. status.landingRadius .. " units")
    player:ChatPrint("Queue: " .. status.queueLength .. " ships waiting")
    player:ChatPrint("Energy: " .. math.floor(status.energyConsumption) .. "/sec")
    player:ChatPrint("")
    
    -- Show services
    player:ChatPrint("Available Services:")
    for serviceType, service in pairs(status.services) do
        local serviceConfig = HYPERDRIVE.DockingPad.Config.Services[serviceType]
        if serviceConfig then
            local statusText = service.active and "ONLINE" or "OFFLINE"
            player:ChatPrint("- " .. serviceConfig.name .. ": " .. statusText)
        end
    end
    
    player:ChatPrint("")
    
    -- Show landed ship
    if status.occupied and IsValid(status.landedShip) then
        player:ChatPrint("Landed Ship: " .. status.landedShip:EntIndex())
        player:ChatPrint("Use wire inputs or nearby ship cores can request landing")
    else
        player:ChatPrint("No ship currently landed")
        player:ChatPrint("Ships can request landing automatically")
    end
end

function ENT:RequestLanding(ship)
    if not self.landingPad then return false, "Landing system offline" end
    
    return self.landingPad:RequestLanding(ship)
end

function ENT:LaunchShip(ship)
    if not self.landingPad then return false, "Landing system offline" end
    
    return self.landingPad:LaunchShip(ship)
end

function ENT:GetLandingPosition()
    if not self.landingPad then return self:GetPos() end
    
    return self.landingPad.landingPosition
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    
    -- Damage can disrupt landing operations
    if self.landingPad and math.random() < 0.3 then
        self.landingPad.active = false
        self:SetPadActive(false)
        self:SetPadStatus("Landing systems damaged")
        
        timer.Simple(8, function()
            if IsValid(self) and self.landingPad then
                self.landingPad.active = true
                self:SetPadActive(true)
                self:SetPadStatus("Landing systems restored")
            end
        end)
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Emergency launch landed ship
        if self.landingPad and self.landingPad.landedShip then
            self.landingPad:LaunchShip(self.landingPad.landedShip)
        end
        
        -- Create explosion effect
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetScale(5)
        util.Effect("Explosion", effectData)
        
        self:Remove()
    end
end

function ENT:OnRemove()
    -- Emergency launch landed ship
    if self.landingPad and self.landingPad.landedShip then
        self.landingPad:LaunchShip(self.landingPad.landedShip)
        HYPERDRIVE.DockingPad.RemoveLandingPad(self)
    end

    if WireLib then
        Wire_Remove(self)
    end

    -- Support undo system
    if self.UndoID then
        undo.ReplaceEntity(self.UndoID, NULL)
    end

    print("[Hyperdrive Docking] Docking Pad removed")
end

-- Network message handling
net.Receive("HyperdriveLandingRequest", function(len, ply)
    local landingPad = net.ReadEntity()
    local ship = net.ReadEntity()
    
    if IsValid(landingPad) and IsValid(ship) then
        local success, reason = landingPad:RequestLanding(ship)
        
        -- Send response back to client
        net.Start("HyperdriveLandingStatus")
        net.WriteEntity(landingPad)
        net.WriteEntity(ship)
        net.WriteBool(success)
        net.WriteString(reason or "")
        net.Send(ply)
    end
end)
