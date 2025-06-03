-- Advanced Space Combat - Shield Generator Shared v3.1.0
-- CAP-integrated bubble shield system - Shared definitions

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Shield Generator"
ENT.Author = "Advanced Space Combat"
ENT.Contact = ""
ENT.Purpose = "CAP-integrated bubble shield system"
ENT.Instructions = "Place near ship core for automatic integration"

ENT.Category = "Advanced Space Combat - Shields"
ENT.Spawnable = true
ENT.AdminSpawnable = true

-- Model and appearance
ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"
ENT.Material = "models/debug/debugwhite"
ENT.Color = Color(100, 150, 255)

-- Shield configuration
ENT.ShieldConfig = {
    MaxStrength = 1000,
    RechargeRate = 10,
    RechargeDelay = 5,
    EnergyConsumption = 25,
    DamageReduction = 0.8,
    Range = 500,
    AutoActivate = true
}

-- CAP integration settings
ENT.CAPIntegration = {
    Enabled = true,
    PreferCAPShields = true,
    CAPShieldClass = "cap_shield_generator",
    AutoDetectCAP = true,
    CAPResourceIntegration = true
}

-- Network variables
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "ShieldActive")
    self:NetworkVar("Float", 0, "ShieldStrength")
    self:NetworkVar("Float", 1, "MaxShieldStrength")
    self:NetworkVar("Float", 2, "RechargeRate")
    self:NetworkVar("Float", 3, "EnergyLevel")
    self:NetworkVar("Bool", 1, "CAPIntegrated")
    self:NetworkVar("String", 0, "ShieldStatus")
    self:NetworkVar("Int", 0, "ShieldMode")
    self:NetworkVar("Entity", 0, "LinkedShipCore")
    self:NetworkVar("Entity", 1, "CAPShieldEntity")
end

-- Shield modes
ENT.ShieldModes = {
    MANUAL = 0,
    AUTO = 1,
    DEFENSIVE = 2,
    EMERGENCY = 3
}

-- Utility functions
function ENT:GetShieldPercentage()
    local current = self:GetShieldStrength()
    local max = self:GetMaxShieldStrength()
    return max > 0 and (current / max) or 0
end

function ENT:IsShieldOperational()
    return self:GetShieldActive() and self:GetShieldStrength() > 0
end

function ENT:GetShieldModeString()
    local mode = self:GetShieldMode()
    for name, value in pairs(self.ShieldModes) do
        if value == mode then
            return name
        end
    end
    return "UNKNOWN"
end

function ENT:CanActivateShield()
    local energy = self:GetEnergyLevel()
    local minEnergy = self.ShieldConfig.EnergyConsumption
    return energy >= minEnergy
end

-- Sound definitions
ENT.Sounds = {
    Activate = "hyperdrive_shield_generator/shield_engage.mp3",
    Deactivate = "hyperdrive_shield_generator/shield_disengage.mp3",
    Hit = "hyperdrive_shield_generator/shield_hit.mp3",
    Recharge = "hyperdrive_shield_generator/shield_recharge.mp3",
    Overload = "hyperdrive_shield_generator/shield_overload.mp3"
}

-- Effect definitions
ENT.Effects = {
    Activate = "asc_shield_activate",
    Deactivate = "asc_shield_deactivate",
    Hit = "asc_shield_hit",
    Recharge = "asc_shield_recharge",
    Bubble = "asc_shield_bubble"
}

-- Material definitions
ENT.Materials = {
    Base = "models/debug/debugwhite",
    Active = "hyperdrive/shield_generator_active",
    Charging = "hyperdrive/shield_generator_charging",
    Overloaded = "hyperdrive/shield_generator_overloaded"
}

-- Initialize default values
function ENT:InitializeSharedData()
    self:SetShieldActive(false)
    self:SetShieldStrength(self.ShieldConfig.MaxStrength)
    self:SetMaxShieldStrength(self.ShieldConfig.MaxStrength)
    self:SetRechargeRate(self.ShieldConfig.RechargeRate)
    self:SetEnergyLevel(100)
    self:SetCAPIntegrated(false)
    self:SetShieldStatus("Initializing")
    self:SetShieldMode(self.ShieldModes.AUTO)
    self:SetLinkedShipCore(NULL)
    self:SetCAPShieldEntity(NULL)
end

-- Validation functions
function ENT:ValidateShieldStrength(strength)
    return math.Clamp(strength or 0, 0, self:GetMaxShieldStrength())
end

function ENT:ValidateEnergyLevel(energy)
    return math.Clamp(energy or 0, 0, 100)
end

function ENT:ValidateShieldMode(mode)
    for _, validMode in pairs(self.ShieldModes) do
        if mode == validMode then
            return mode
        end
    end
    return self.ShieldModes.AUTO
end

-- Helper functions for CAP integration
function ENT:IsCAPAvailable()
    return CAP ~= nil or StarGate ~= nil
end

function ENT:GetCAPShieldClass()
    if CAP and CAP.ShieldGenerator then
        return "cap_shield_generator"
    elseif StarGate and StarGate.Shield then
        return "stargate_shield"
    end
    return nil
end

function ENT:ShouldUseCAPIntegration()
    return self.CAPIntegration.Enabled and 
           self.CAPIntegration.PreferCAPShields and 
           self:IsCAPAvailable()
end
