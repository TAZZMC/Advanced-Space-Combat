-- Advanced Space Combat - Plasma Ball Shared
-- Shared definitions for plasma cannon projectile

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Plasma Ball"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "High-energy plasma projectile"
ENT.Instructions = "Superheated plasma containment field"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Advanced Space Combat - Projectiles"

ENT.RenderGroup = RENDERGROUP_BOTH

-- Projectile specifications
ENT.MaxSpeed = 600
ENT.Damage = 180
ENT.BlastRadius = 150
ENT.LifeTime = 8
ENT.Temperature = 10000

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Owner")
    self:NetworkVar("Vector", 0, "StartPos")
    self:NetworkVar("Vector", 1, "Direction")
    self:NetworkVar("Float", 0, "LaunchTime")
    self:NetworkVar("Float", 1, "Temperature")
    self:NetworkVar("Float", 2, "PlasmaIntensity")
end
