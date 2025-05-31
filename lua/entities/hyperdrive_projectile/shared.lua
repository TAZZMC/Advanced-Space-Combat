ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Projectile"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Projectile for hyperdrive weapons"
ENT.Instructions = ""

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Hyperdrive - Weapons"

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Float", 0, "Damage")
    self:NetworkVar("Float", 1, "Speed")
    self:NetworkVar("Vector", 0, "TargetPos")
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Entity", 1, "Weapon")
    self:NetworkVar("String", 0, "ProjectileType")
end
