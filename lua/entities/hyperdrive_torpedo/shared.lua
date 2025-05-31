ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Torpedo"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Guided torpedo projectile with explosive warhead"
ENT.Instructions = ""

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Hyperdrive - Weapons"

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Damage")
    self:NetworkVar("Float", 1, "Speed")
    self:NetworkVar("Float", 2, "BlastRadius")
    self:NetworkVar("Int", 0, "TorpedoType")
    self:NetworkVar("Vector", 0, "TargetPos")
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Entity", 1, "Weapon")
    self:NetworkVar("Bool", 0, "Armed")
    self:NetworkVar("Bool", 1, "Tracking")
end
