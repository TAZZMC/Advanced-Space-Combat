ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Pulse Cannon"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Ship-mounted energy pulse weapon with targeting system"
ENT.Instructions = "Mount on ship near ship core. Wire for automated firing or use manual controls."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive - Weapons"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdriveWeaponFire")
    util.AddNetworkString("HyperdriveWeaponTarget")
    util.AddNetworkString("HyperdriveWeaponStatus")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "WeaponActive")
    self:NetworkVar("Bool", 1, "AutoTarget")
    self:NetworkVar("Bool", 2, "TargetLocked")
    self:NetworkVar("Bool", 3, "Overheated")
    self:NetworkVar("Int", 0, "Ammo")
    self:NetworkVar("Int", 1, "MaxAmmo")
    self:NetworkVar("Int", 2, "Heat")
    self:NetworkVar("Int", 3, "MaxHeat")
    self:NetworkVar("Float", 0, "FireRate")
    self:NetworkVar("Float", 1, "Range")
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Entity", 1, "ShipCore")
    self:NetworkVar("String", 0, "WeaponStatus")
end
