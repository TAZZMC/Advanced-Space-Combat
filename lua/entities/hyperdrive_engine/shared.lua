-- Hyperdrive Engine - Shared code

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Engine"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Advanced FTL propulsion system with ship detection"
ENT.Instructions = "Use with Hyperdrive Computer for easy control"

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive"

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
        "SetEnergy [NORMAL]"
    }
    
    ENT.Outputs = {
        "Energy [NORMAL]",
        "EnergyPercent [NORMAL]",
        "Charging [NORMAL]",
        "Cooldown [NORMAL]",
        "JumpReady [NORMAL]",
        "Destination [VECTOR]",
        "Status [STRING]"
    }
end
