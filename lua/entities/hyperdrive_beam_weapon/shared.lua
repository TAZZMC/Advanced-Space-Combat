ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Beam Weapon"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Ship-mounted continuous energy beam weapon with sustained fire capability"
ENT.Instructions = "Mount on ship near ship core. Fires continuous beam while target is locked."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive - Weapons"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdriveBeamFire")
    util.AddNetworkString("HyperdriveBeamStop")
    util.AddNetworkString("HyperdriveBeamHit")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "WeaponActive")
    self:NetworkVar("Bool", 1, "AutoTarget")
    self:NetworkVar("Bool", 2, "TargetLocked")
    self:NetworkVar("Bool", 3, "BeamFiring")
    self:NetworkVar("Bool", 4, "Overheated")
    self:NetworkVar("Int", 0, "Heat")
    self:NetworkVar("Int", 1, "MaxHeat")
    self:NetworkVar("Int", 2, "BeamPower")
    self:NetworkVar("Float", 0, "Range")
    self:NetworkVar("Float", 1, "BeamDamage")
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Entity", 1, "ShipCore")
    self:NetworkVar("Vector", 0, "BeamEnd")
    self:NetworkVar("String", 0, "WeaponStatus")
end
