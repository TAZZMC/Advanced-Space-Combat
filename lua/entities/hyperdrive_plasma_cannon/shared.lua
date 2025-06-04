ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Plasma Cannon"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Ship-mounted plasma cannon with area-effect damage and heat effects"
ENT.Instructions = "Mount on ship near ship core. Fires superheated plasma bolts with splash damage."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Advanced Space Combat"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdrivePlasmaFire")
    util.AddNetworkString("HyperdrivePlaymaCharge")
    util.AddNetworkString("HyperdrivePlaymaOverheat")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "WeaponActive")
    self:NetworkVar("Bool", 1, "AutoTarget")
    self:NetworkVar("Bool", 2, "TargetLocked")
    self:NetworkVar("Bool", 3, "Overheated")
    self:NetworkVar("Bool", 4, "Charging")
    self:NetworkVar("Int", 0, "Ammo")
    self:NetworkVar("Int", 1, "MaxAmmo")
    self:NetworkVar("Int", 2, "Heat")
    self:NetworkVar("Int", 3, "MaxHeat")
    self:NetworkVar("Int", 4, "PlasmaTemp")
    self:NetworkVar("Float", 0, "Range")
    self:NetworkVar("Float", 1, "SplashRadius")
    self:NetworkVar("Float", 2, "ChargeLevel")
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Entity", 1, "ShipCore")
    self:NetworkVar("String", 0, "WeaponStatus")
end
