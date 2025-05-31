ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Docking Bay"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Ship docking facility with automated services and cargo transfer"
ENT.Instructions = "Place on station or large ship. Ships can dock for refueling, repair, and resupply."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive - Docking"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdriveDockingRequest")
    util.AddNetworkString("HyperdriveDockingStatus")
    util.AddNetworkString("HyperdriveDockingServices")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "DockingActive")
    self:NetworkVar("Bool", 1, "ServicesActive")
    self:NetworkVar("Bool", 2, "TrafficControl")
    self:NetworkVar("Int", 0, "OccupiedSlots")
    self:NetworkVar("Int", 1, "TotalSlots")
    self:NetworkVar("Int", 2, "QueueLength")
    self:NetworkVar("Float", 0, "EnergyConsumption")
    self:NetworkVar("String", 0, "BayType")
    self:NetworkVar("String", 1, "DockingStatus")
end
