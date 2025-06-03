-- Advanced Space Combat - Pulse Cannon Shared

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Pulse Cannon"
ENT.Author = "Advanced Space Combat"
ENT.Contact = ""
ENT.Purpose = "High-frequency energy weapon"
ENT.Instructions = "Use to toggle auto-fire mode"

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Advanced Space Combat - Weapons"

-- Model and appearance
ENT.Model = "models/props_c17/oildrum001_explosive.mdl" -- Fallback model for pulse cannon

-- Network variables
function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "ShipCore")
    self:NetworkVar("Bool", 0, "AutoFire")
    self:NetworkVar("Float", 0, "Energy")
    self:NetworkVar("Int", 0, "Ammo")
end
