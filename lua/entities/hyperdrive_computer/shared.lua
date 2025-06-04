-- Hyperdrive Computer Entity - Shared
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Navigation Computer"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Easy-to-use hyperdrive control system with automatic planet detection"
ENT.Instructions = "Advanced navigation computer. Press E to open interface. Automatically finds Master Engines and planets."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Advanced Space Combat"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Powered")
    self:NetworkVar("Entity", 0, "LinkedEngine")
    self:NetworkVar("Int", 0, "ComputerMode")
end

function ENT:GetModeString()
    local mode = self:GetComputerMode()
    if mode == 1 then return "Navigation"
    elseif mode == 2 then return "Planets"
    elseif mode == 3 then return "Status"
    else return "Navigation" end
end

-- Network strings
if SERVER then
    util.AddNetworkString("hyperdrive_computer")
    util.AddNetworkString("hyperdrive_fleet_jump")
    util.AddNetworkString("hyperdrive_fleet_shields")
    util.AddNetworkString("hyperdrive_scan_planets")
    util.AddNetworkString("hyperdrive_quick_jump_planet")
    util.AddNetworkString("hyperdrive_toggle_front_indicator")
    util.AddNetworkString("hyperdrive_auto_detect_front")
end
