ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Shield Generator"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Generates protective shields for ships using CAP bubble technology"
ENT.Instructions = "Place near ship core or hyperdrive engine. Use E to toggle shield."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdriveShieldStatus")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "ShieldActive")
    self:NetworkVar("Int", 0, "ShieldStrength")
    self:NetworkVar("Int", 1, "MaxShieldStrength")
    self:NetworkVar("String", 0, "ShipType")
end
