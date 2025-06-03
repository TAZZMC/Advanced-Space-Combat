-- Advanced Space Combat - Railgun Shared

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Railgun"
ENT.Author = "Advanced Space Combat"
ENT.Contact = ""
ENT.Purpose = "High-velocity kinetic weapon"
ENT.Instructions = "Use to toggle auto-fire mode"

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Advanced Space Combat - Weapons"

-- Model and appearance
ENT.Model = "models/props_combine/combine_barricade_med02a.mdl" -- Fallback model for railgun

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "ShipCore")
    self:NetworkVar("Bool", 0, "AutoFire")
    self:NetworkVar("Bool", 1, "Charging")
    self:NetworkVar("Float", 0, "Energy")
    self:NetworkVar("Float", 1, "ChargeLevel")
end
