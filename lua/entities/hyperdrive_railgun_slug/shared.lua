-- Advanced Space Combat - Railgun Slug Shared
-- Shared definitions for railgun projectile

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Railgun Slug"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "High-velocity kinetic projectile"
ENT.Instructions = "Electromagnetic accelerated projectile"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Advanced Space Combat - Projectiles"

ENT.RenderGroup = RENDERGROUP_BOTH

-- Projectile specifications
ENT.MaxSpeed = 2000
ENT.Damage = 200
ENT.PenetrationPower = 5
ENT.LifeTime = 10
ENT.Mass = 2

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Owner")
    self:NetworkVar("Vector", 0, "StartPos")
    self:NetworkVar("Vector", 1, "Direction")
    self:NetworkVar("Float", 0, "LaunchTime")
    self:NetworkVar("Float", 1, "Velocity")
    self:NetworkVar("Int", 0, "Penetrations")
end
