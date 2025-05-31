ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Railgun"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Ship-mounted electromagnetic railgun with penetrating kinetic projectiles"
ENT.Instructions = "Mount on ship near ship core. Fires high-velocity slugs that penetrate multiple targets."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive - Weapons"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdriveRailgunFire")
    util.AddNetworkString("HyperdriveRailgunCharge")
    util.AddNetworkString("HyperdriveRailgunPenetration")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "WeaponActive")
    self:NetworkVar("Bool", 1, "AutoTarget")
    self:NetworkVar("Bool", 2, "TargetLocked")
    self:NetworkVar("Bool", 3, "Charging")
    self:NetworkVar("Bool", 4, "Overheated")
    self:NetworkVar("Int", 0, "Ammo")
    self:NetworkVar("Int", 1, "MaxAmmo")
    self:NetworkVar("Int", 2, "ChargeLevel")
    self:NetworkVar("Int", 3, "Heat")
    self:NetworkVar("Float", 0, "Range")
    self:NetworkVar("Float", 1, "ChargeTime")
    self:NetworkVar("Float", 2, "PenetrationPower")
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Entity", 1, "ShipCore")
    self:NetworkVar("String", 0, "WeaponStatus")
end
