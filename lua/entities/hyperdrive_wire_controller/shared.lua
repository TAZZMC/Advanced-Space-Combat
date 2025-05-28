-- Hyperdrive Wire Controller Entity - Shared
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Wire Controller"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Advanced Wiremod controller for hyperdrive systems"
ENT.Instructions = "Connect wire inputs to control hyperdrive engines, computers, and beacons remotely."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ControllerMode")
    self:NetworkVar("Entity", 0, "TargetEntity")
    self:NetworkVar("Float", 0, "ControlRange")
end

function ENT:GetModeString()
    local mode = self:GetControllerMode()
    if mode == 1 then return "Engine Control"
    elseif mode == 2 then return "Fleet Control"
    elseif mode == 3 then return "Beacon Control"
    else return "Unknown" end
end
