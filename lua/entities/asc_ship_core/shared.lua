-- Advanced Space Combat - Ship Core Entity v5.1.0
-- Shared configuration for ship core

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Ship Core"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Central ship management and control system"
ENT.Instructions = "Place on ship to enable all ship systems and hyperspace travel"

ENT.Category = "Advanced Space Combat"
ENT.Spawnable = true
ENT.AdminSpawnable = true

-- Model and appearance
ENT.Model = "models/props_combine/combine_core.mdl"
ENT.RenderGroup = RENDERGROUP_OPAQUE

-- Physics properties
ENT.AutomaticFrameAdvance = true

-- Wire properties
ENT.WireDebugName = "ASC Ship Core"

-- Network variables
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("Bool", 1, "ShieldActive")
    self:NetworkVar("Bool", 2, "LifeSupportActive")
    self:NetworkVar("Float", 0, "HullIntegrity")
    self:NetworkVar("Float", 1, "ShieldLevel")
    self:NetworkVar("Float", 2, "PowerLevel")
    self:NetworkVar("Float", 3, "OxygenLevel")
    self:NetworkVar("String", 0, "ShipName")
    self:NetworkVar("String", 1, "StatusMessage")
    self:NetworkVar("String", 2, "Owner")
    self:NetworkVar("Entity", 0, "FrontIndicator")
end
