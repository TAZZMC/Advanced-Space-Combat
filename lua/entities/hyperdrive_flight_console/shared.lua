ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Flight Console"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Ship flight control console with navigation and autopilot systems"
ENT.Instructions = "Mount on ship near ship core. Use E to access flight controls or wire for automation."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive - Flight"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdriveFlightControl")
    util.AddNetworkString("HyperdriveFlightStatus")
    util.AddNetworkString("HyperdriveWaypointUpdate")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "FlightActive")
    self:NetworkVar("Bool", 1, "AutopilotActive")
    self:NetworkVar("Bool", 2, "StabilizationActive")
    self:NetworkVar("Float", 0, "ThrustX")
    self:NetworkVar("Float", 1, "ThrustY")
    self:NetworkVar("Float", 2, "ThrustZ")
    self:NetworkVar("Float", 3, "RotationPitch")
    self:NetworkVar("Float", 4, "RotationYaw")
    self:NetworkVar("Float", 5, "RotationRoll")
    self:NetworkVar("Float", 6, "CurrentSpeed")
    self:NetworkVar("Float", 7, "MaxSpeed")
    self:NetworkVar("Int", 0, "WaypointCount")
    self:NetworkVar("Int", 1, "CurrentWaypoint")
    self:NetworkVar("Entity", 0, "ShipCore")
    self:NetworkVar("String", 0, "FlightMode")
    self:NetworkVar("String", 1, "FlightStatus")
end
