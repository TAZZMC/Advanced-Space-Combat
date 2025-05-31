-- Advanced Space Combat - Ancient ZPM Entity (Shared)

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Ancient ZPM"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Zero Point Module - Unlimited energy source"
ENT.Instructions = "Use to activate/deactivate. Automatically supplies energy to nearby ship cores."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Advanced Space Combat - Ancient"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "EnergyOutput")
    self:NetworkVar("Int", 1, "EnergyStored")
    self:NetworkVar("Int", 2, "MaxEnergy")
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("Bool", 1, "Glowing")
    self:NetworkVar("Int", 3, "TechnologyTier")
    self:NetworkVar("String", 0, "TechnologyCulture")
end
