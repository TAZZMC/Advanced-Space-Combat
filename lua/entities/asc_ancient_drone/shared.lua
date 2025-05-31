-- Advanced Space Combat - Ancient Drone Weapon (Shared)
-- Self-guided energy projectiles with adaptive targeting and swarm intelligence

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Ancient Drone Weapon"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Ancient technology drone weapon system"
ENT.Instructions = "Place near ship core for auto-linking. Use E to configure."

ENT.Category = "Advanced Space Combat - Stargate - Ancient"
ENT.Spawnable = true
ENT.AdminSpawnable = true

-- Entity properties
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true

-- Technology information
ENT.TechnologyTier = 10
ENT.TechnologyCulture = "Ancient"
ENT.WeaponType = "Energy Projectile"
ENT.Damage = 1000
ENT.Range = 15000
ENT.EnergyConsumption = 500
ENT.FireRate = 2.0

-- Features
ENT.Features = {
    "Adaptive Targeting",
    "Shield Penetration", 
    "Swarm Intelligence",
    "Auto-Targeting",
    "Multi-Target Engagement"
}

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "WeaponName")
    self:NetworkVar("Int", 0, "TechnologyTier")
    self:NetworkVar("String", 1, "TechnologyCulture")
    self:NetworkVar("Int", 1, "Energy")
    self:NetworkVar("Int", 2, "MaxEnergy")
    self:NetworkVar("Int", 3, "Damage")
    self:NetworkVar("Int", 4, "Range")
    self:NetworkVar("Bool", 0, "WeaponOnline")
    self:NetworkVar("Bool", 1, "AutoTargeting")
    self:NetworkVar("Entity", 0, "ShipCore")
end
