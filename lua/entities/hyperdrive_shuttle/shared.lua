ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Shuttle"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Automated shuttle craft for passenger and cargo transport"
ENT.Instructions = "Spawns as a shuttle that can be assigned missions for transport operations."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive - Shuttle"

-- Network strings
if SERVER then
    util.AddNetworkString("HyperdriveShuttleMission")
    util.AddNetworkString("HyperdriveShuttleStatus")
    util.AddNetworkString("HyperdriveShuttleCargo")
end

-- Shared functions
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "ShuttleActive")
    self:NetworkVar("Bool", 1, "OnMission")
    self:NetworkVar("Bool", 2, "EmergencyMode")
    self:NetworkVar("Int", 0, "PassengerCount")
    self:NetworkVar("Int", 1, "MaxPassengers")
    self:NetworkVar("Int", 2, "MissionsCompleted")
    self:NetworkVar("Float", 0, "CargoWeight")
    self:NetworkVar("Float", 1, "MaxCargoWeight")
    self:NetworkVar("Float", 2, "MissionProgress")
    self:NetworkVar("Float", 3, "EnergyConsumed")
    self:NetworkVar("String", 0, "ShuttleType")
    self:NetworkVar("String", 1, "ShuttleStatus")
    self:NetworkVar("String", 2, "CurrentMission")
end
