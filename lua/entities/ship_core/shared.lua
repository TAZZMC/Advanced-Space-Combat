-- Ship Core Entity - Shared
-- Mandatory ship core for Enhanced Hyperdrive System v2.0

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Ship Core"
ENT.Author = "Enhanced Hyperdrive System"
ENT.Contact = ""
ENT.Purpose = "Mandatory ship core for hyperdrive operations"
ENT.Instructions = "Place on ship for hyperdrive functionality. Only one core per ship allowed."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Enhanced Hyperdrive System"

ENT.RenderGroup = RENDERGROUP_OPAQUE

-- Ship core states
ENT.States = {
    INACTIVE = 0,
    ACTIVE = 1,
    INVALID = 2,
    CRITICAL = 3,
    EMERGENCY = 4
}

-- Network variables
function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "State")
    self:NetworkVar("Int", 1, "HullIntegrity")
    self:NetworkVar("Int", 2, "ShieldStrength")
    self:NetworkVar("Bool", 0, "ShipDetected")
    self:NetworkVar("Bool", 1, "CoreValid")
    self:NetworkVar("Bool", 2, "HullSystemActive")
    self:NetworkVar("Bool", 3, "ShieldSystemActive")
    self:NetworkVar("String", 0, "ShipType")
    self:NetworkVar("String", 1, "StatusMessage")
    self:NetworkVar("String", 2, "ShipName")
    self:NetworkVar("Vector", 0, "ShipCenter")
    self:NetworkVar("Vector", 1, "FrontDirection")

    if SERVER then
        self:SetState(self.States.INACTIVE)
        self:SetHullIntegrity(100)
        self:SetShieldStrength(0)
        self:SetShipDetected(false)
        self:SetCoreValid(true)
        self:SetHullSystemActive(false)
        self:SetShieldSystemActive(false)
        self:SetShipType("Unknown")
        self:SetStatusMessage("Initializing...")
        self:SetShipName("Unnamed Ship")
        self:SetShipCenter(Vector(0, 0, 0))
        self:SetFrontDirection(Vector(1, 0, 0))
    end
end

-- Get state color for UI
function ENT:GetStateColor()
    local state = self:GetState()

    if state == self.States.EMERGENCY then
        return Color(255, 50, 50) -- Red
    elseif state == self.States.CRITICAL then
        return Color(255, 150, 50) -- Orange
    elseif state == self.States.INVALID then
        return Color(255, 255, 50) -- Yellow
    elseif state == self.States.ACTIVE then
        return Color(50, 255, 50) -- Green
    else
        return Color(100, 100, 100) -- Gray
    end
end

-- Get state name
function ENT:GetStateName()
    local state = self:GetState()

    if state == self.States.EMERGENCY then
        return "EMERGENCY"
    elseif state == self.States.CRITICAL then
        return "CRITICAL"
    elseif state == self.States.INVALID then
        return "INVALID"
    elseif state == self.States.ACTIVE then
        return "ACTIVE"
    else
        return "INACTIVE"
    end
end

-- Get hull status color
function ENT:GetHullColor()
    local integrity = self:GetHullIntegrity()

    if integrity < 25 then
        return Color(255, 50, 50) -- Red
    elseif integrity < 50 then
        return Color(255, 150, 50) -- Orange
    elseif integrity < 75 then
        return Color(255, 255, 50) -- Yellow
    else
        return Color(50, 255, 50) -- Green
    end
end

-- Get shield status color
function ENT:GetShieldColor()
    local strength = self:GetShieldStrength()

    if strength < 25 then
        return Color(255, 50, 50) -- Red
    elseif strength < 50 then
        return Color(255, 150, 50) -- Orange
    elseif strength < 75 then
        return Color(255, 255, 50) -- Yellow
    else
        return Color(50, 255, 50) -- Green
    end
end

-- Wire inputs and outputs
if WireLib then
    ENT.Inputs = {
        {"DistributeResources", "NORMAL"},
        {"CollectResources", "NORMAL"},
        {"BalanceResources", "NORMAL"},
        {"SetEnergyCapacity", "NORMAL"},
        {"SetOxygenCapacity", "NORMAL"},
        {"SetCoolantCapacity", "NORMAL"},
        {"SetFuelCapacity", "NORMAL"},
        {"SetWaterCapacity", "NORMAL"},
        {"SetNitrogenCapacity", "NORMAL"},
        {"ToggleAutoProvision", "NORMAL"},
        {"ToggleWeldDetection", "NORMAL"},
        {"EmergencyResourceShutdown", "NORMAL"},
        {"RepairHull", "NORMAL"},
        {"ActivateShields", "NORMAL"},
        {"DeactivateShields", "NORMAL"}
    }

    ENT.Outputs = {
        {"ShipDetected", "NORMAL"},
        {"ShipType", "STRING"},
        {"ShipName", "STRING"},
        {"EntityCount", "NORMAL"},
        {"PlayerCount", "NORMAL"},
        {"ShipMass", "NORMAL"},
        {"CoreValid", "NORMAL"},
        {"CoreState", "NORMAL"},
        {"CoreStateName", "STRING"},
        {"StatusMessage", "STRING"},
        {"HullIntegrity", "NORMAL"},
        {"HullSystemActive", "NORMAL"},
        {"ShieldStrength", "NORMAL"},
        {"ShieldSystemActive", "NORMAL"},
        {"ShipCenter", "VECTOR"},
        {"FrontDirection", "VECTOR"},

        -- Resource system outputs
        {"EnergyLevel", "NORMAL"},
        {"OxygenLevel", "NORMAL"},
        {"CoolantLevel", "NORMAL"},
        {"FuelLevel", "NORMAL"},
        {"WaterLevel", "NORMAL"},
        {"NitrogenLevel", "NORMAL"},
        {"ResourceEmergency", "NORMAL"},
        {"ResourceSystemActive", "NORMAL"},
        {"TotalResourceCapacity", "NORMAL"},
        {"TotalResourceAmount", "NORMAL"},
        {"AutoProvisionEnabled", "NORMAL"},
        {"WeldDetectionEnabled", "NORMAL"},
        {"LastResourceActivity", "STRING"},
        {"ResourceDistributionRate", "NORMAL"},
        {"ResourceCollectionRate", "NORMAL"}
    }
end
