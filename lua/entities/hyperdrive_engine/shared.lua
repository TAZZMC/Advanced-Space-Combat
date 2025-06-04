-- Hyperdrive Engine - Shared code

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Hyperdrive Engine"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Advanced FTL propulsion system with ship detection"
ENT.Instructions = "Use with ASC Navigation Computer for easy control"

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Advanced Space Combat"

-- Network variables
function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Energy")
    self:NetworkVar("Bool", 0, "Charging")
    self:NetworkVar("Float", 1, "Cooldown")
    self:NetworkVar("Vector", 0, "Destination")
    self:NetworkVar("Bool", 1, "JumpReady")
end

-- Wire inputs and outputs
if WireLib then
    ENT.Inputs = {
        "Jump [NORMAL]",
        "SetDestinationX [NORMAL]",
        "SetDestinationY [NORMAL]",
        "SetDestinationZ [NORMAL]",
        "SetDestination [VECTOR]",
        "Abort [NORMAL]",
        "SetEnergy [NORMAL]",
        "ShowFrontIndicator [NORMAL]",
        "HideFrontIndicator [NORMAL]",
        "SetFrontDirection [VECTOR]",
        "AutoDetectFront [NORMAL]",
        "ActivateShield [NORMAL]",
        "DeactivateShield [NORMAL]"
    }

    ENT.Outputs = {
        "Energy [NORMAL]",
        "EnergyPercent [NORMAL]",
        "Charging [NORMAL]",
        "Cooldown [NORMAL]",
        "JumpReady [NORMAL]",
        "Destination [VECTOR]",
        "Status [STRING]",
        "FrontIndicatorVisible [NORMAL]",
        "ShipFrontDirection [VECTOR]",
        "ShieldActive [NORMAL]",
        "ShieldStrength [NORMAL]",
        "ShieldPercent [NORMAL]",
        "ShieldRecharging [NORMAL]",
        "ShieldOverloaded [NORMAL]",
        "CAPIntegrated [NORMAL]",

        -- Hull damage outputs
        "HullIntegrity [NORMAL]",
        "HullIntegrityPercent [NORMAL]",
        "HullCriticalMode [NORMAL]",
        "HullEmergencyMode [NORMAL]",
        "HullBreaches [NORMAL]",
        "HullSystemFailures [NORMAL]",
        "HullAutoRepairActive [NORMAL]",
        "HullRepairProgress [NORMAL]",
        "HullTotalDamage [NORMAL]",
        "HullDamagedSections [NORMAL]",

        -- Ship core validation
        "ShipCoreValid [NORMAL]",
        "ShipCoreStatus [STRING]",

        -- Resource system outputs
        "ResourceSystemActive [NORMAL]",
        "ResourceEnergyLevel [NORMAL]",
        "ResourceOxygenLevel [NORMAL]",
        "ResourceCoolantLevel [NORMAL]",
        "ResourceFuelLevel [NORMAL]",
        "ResourceWaterLevel [NORMAL]",
        "ResourceNitrogenLevel [NORMAL]",
        "ResourceEmergencyMode [NORMAL]",
        "ResourcesReady [NORMAL]"
    }
end
