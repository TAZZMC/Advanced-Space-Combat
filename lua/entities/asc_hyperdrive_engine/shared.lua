-- Advanced Space Combat - Hyperdrive Engine Entity v5.1.0
-- Shared configuration for hyperdrive engine

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Hyperdrive Engine"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Advanced hyperdrive propulsion system"
ENT.Instructions = "Place on ship and connect to ship core for hyperspace travel"

ENT.Category = "Advanced Space Combat"
ENT.Spawnable = true
ENT.AdminSpawnable = true

-- Model and appearance
ENT.Model = "models/props_c17/substation_transformer01d.mdl"
ENT.RenderGroup = RENDERGROUP_OPAQUE

-- Physics properties
ENT.AutomaticFrameAdvance = true

-- Wire properties
ENT.WireDebugName = "ASC Hyperdrive Engine"

-- Network variables
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("Bool", 1, "Charging")
    self:NetworkVar("Float", 0, "ChargeLevel")
    self:NetworkVar("Float", 1, "PowerLevel")
    self:NetworkVar("String", 0, "StatusMessage")
    self:NetworkVar("Entity", 0, "LinkedCore")
end
