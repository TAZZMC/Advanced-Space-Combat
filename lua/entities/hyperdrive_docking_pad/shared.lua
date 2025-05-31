ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Docking Pad"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Ship landing pad with automated guidance and services"
ENT.Instructions = "Place on ground or platform. Ships can land for refueling, repair, and resupply."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive - Docking"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdriveLandingRequest")
    util.AddNetworkString("HyperdriveLandingStatus")
    util.AddNetworkString("HyperdrivePadServices")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "PadActive")
    self:NetworkVar("Bool", 1, "ServicesActive")
    self:NetworkVar("Bool", 2, "GuidanceActive")
    self:NetworkVar("Bool", 3, "Occupied")
    self:NetworkVar("Int", 0, "QueueLength")
    self:NetworkVar("Float", 0, "EnergyConsumption")
    self:NetworkVar("Float", 1, "LandingRadius")
    self:NetworkVar("Entity", 0, "LandedShip")
    self:NetworkVar("String", 0, "PadType")
    self:NetworkVar("String", 1, "PadStatus")
end
