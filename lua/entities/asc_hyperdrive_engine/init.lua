-- Advanced Space Combat - Hyperdrive Engine Entity v5.1.0
-- Server-side hyperdrive engine functionality

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Initialize entity
function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(500)
    end
    
    -- Initialize state
    self:SetActive(false)
    self:SetCharging(false)
    self:SetChargeLevel(0)
    self:SetPowerLevel(0)
    self:SetStatusMessage("Offline")
    
    -- Wire inputs/outputs
    self:SetupWire()
    
    print("[Advanced Space Combat] Hyperdrive Engine " .. self:EntIndex() .. " initialized")
end

-- Setup wire inputs and outputs
function ENT:SetupWire()
    if not WireLib then return end
    
    -- Wire inputs
    self.Inputs = WireLib.CreateInputs(self, {
        "Activate",
        "Charge",
        "PowerLevel",
        "TargetGate"
    })
    
    -- Wire outputs
    self.Outputs = WireLib.CreateOutputs(self, {
        "Active",
        "Charging", 
        "ChargeLevel",
        "Ready",
        "Status"
    })
    
    -- Update outputs
    self:UpdateWireOutputs()
end

-- Update wire outputs
function ENT:UpdateWireOutputs()
    if not WireLib then return end
    
    WireLib.TriggerOutput(self, "Active", self:GetActive() and 1 or 0)
    WireLib.TriggerOutput(self, "Charging", self:GetCharging() and 1 or 0)
    WireLib.TriggerOutput(self, "ChargeLevel", self:GetChargeLevel())
    WireLib.TriggerOutput(self, "Ready", (self:GetChargeLevel() >= 100) and 1 or 0)
    WireLib.TriggerOutput(self, "Status", self:GetStatusMessage())
end

-- Wire input triggered
function ENT:TriggerInput(iname, value)
    if iname == "Activate" then
        if value > 0 then
            self:StartEngine()
        else
            self:StopEngine()
        end
    elseif iname == "Charge" then
        if value > 0 then
            self:StartCharging()
        else
            self:StopCharging()
        end
    elseif iname == "PowerLevel" then
        self:SetPowerLevel(math.Clamp(value, 0, 100))
    end
    
    self:UpdateWireOutputs()
end

-- Start engine
function ENT:StartEngine()
    -- Check for ship core
    local shipCore = self:FindShipCore()
    if not IsValid(shipCore) then
        self:SetStatusMessage("No Ship Core Detected")
        return false
    end
    
    self:SetActive(true)
    self:SetLinkedCore(shipCore)
    self:SetStatusMessage("Engine Active")
    
    -- Start charging if power available
    if self:GetPowerLevel() > 0 then
        self:StartCharging()
    end
    
    return true
end

-- Stop engine
function ENT:StopEngine()
    self:SetActive(false)
    self:SetCharging(false)
    self:SetChargeLevel(0)
    self:SetStatusMessage("Engine Offline")
end

-- Start charging
function ENT:StartCharging()
    if not self:GetActive() then return false end
    
    self:SetCharging(true)
    self:SetStatusMessage("Charging Hyperdrive")
    
    -- Start charge timer
    timer.Create("ASC_HyperdriveCharge_" .. self:EntIndex(), 0.1, 0, function()
        if not IsValid(self) or not self:GetCharging() then
            timer.Remove("ASC_HyperdriveCharge_" .. self:EntIndex())
            return
        end
        
        local chargeRate = self:GetPowerLevel() / 10 -- Charge rate based on power
        local newCharge = math.Clamp(self:GetChargeLevel() + chargeRate, 0, 100)
        self:SetChargeLevel(newCharge)
        
        if newCharge >= 100 then
            self:SetStatusMessage("Hyperdrive Ready")
            self:SetCharging(false)
            timer.Remove("ASC_HyperdriveCharge_" .. self:EntIndex())
        end
        
        self:UpdateWireOutputs()
    end)
    
    return true
end

-- Stop charging
function ENT:StopCharging()
    self:SetCharging(false)
    self:SetStatusMessage("Charge Stopped")
    timer.Remove("ASC_HyperdriveCharge_" .. self:EntIndex())
end

-- Find ship core
function ENT:FindShipCore()
    local cores = ents.FindByClass("ship_core")
    local closestCore = nil
    local closestDist = 2000
    
    for _, core in ipairs(cores) do
        if IsValid(core) then
            local dist = self:GetPos():Distance(core:GetPos())
            if dist < closestDist then
                closestCore = core
                closestDist = dist
            end
        end
    end
    
    return closestCore
end

-- Think function
function ENT:Think()
    self:NextThink(CurTime() + 1)
    
    -- Update status
    if self:GetActive() then
        local shipCore = self:GetLinkedCore()
        if not IsValid(shipCore) then
            self:StopEngine()
        end
    end
    
    return true
end

-- Remove function
function ENT:OnRemove()
    timer.Remove("ASC_HyperdriveCharge_" .. self:EntIndex())
end

-- Use function
function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    activator:ChatPrint("[Advanced Space Combat] Hyperdrive Engine Status:")
    activator:ChatPrint("• Active: " .. (self:GetActive() and "Yes" or "No"))
    activator:ChatPrint("• Charging: " .. (self:GetCharging() and "Yes" or "No"))
    activator:ChatPrint("• Charge Level: " .. math.Round(self:GetChargeLevel()) .. "%")
    activator:ChatPrint("• Power Level: " .. math.Round(self:GetPowerLevel()) .. "%")
    activator:ChatPrint("• Status: " .. self:GetStatusMessage())
end
