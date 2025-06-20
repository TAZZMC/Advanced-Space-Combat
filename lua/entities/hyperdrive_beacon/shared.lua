-- Hyperdrive Beacon Entity - Shared
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Navigation Beacon"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Navigation beacon for Advanced Space Combat systems"
ENT.Instructions = "Use to configure beacon settings. Provides navigation reference for hyperdrive engines."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Advanced Space Combat"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "BeaconName")
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("Float", 0, "Range")
    self:NetworkVar("Int", 0, "BeaconID")
end

function ENT:GetStatusString()
    return self:GetActive() and "ACTIVE" or "INACTIVE"
end

function ENT:GetRangeString()
    return HYPERDRIVE.FormatDistance(self:GetRange())
end
