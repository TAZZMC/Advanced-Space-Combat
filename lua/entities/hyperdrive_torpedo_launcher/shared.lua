ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Torpedo Launcher"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Ship-mounted heavy torpedo launcher with guided projectiles"
ENT.Instructions = "Mount on ship near ship core. Fires guided torpedoes with high explosive damage."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive - Weapons"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdriveTorpedoFire")
    util.AddNetworkString("HyperdriveTorpedoReload")
    util.AddNetworkString("HyperdriveTorpedoLock")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "WeaponActive")
    self:NetworkVar("Bool", 1, "AutoTarget")
    self:NetworkVar("Bool", 2, "TargetLocked")
    self:NetworkVar("Bool", 3, "Reloading")
    self:NetworkVar("Int", 0, "Ammo")
    self:NetworkVar("Int", 1, "MaxAmmo")
    self:NetworkVar("Int", 2, "TorpedoType")
    self:NetworkVar("Float", 0, "Range")
    self:NetworkVar("Float", 1, "ReloadTime")
    self:NetworkVar("Float", 2, "LockTime")
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Entity", 1, "ShipCore")
    self:NetworkVar("String", 0, "WeaponStatus")
end
