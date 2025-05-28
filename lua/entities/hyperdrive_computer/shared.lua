-- Hyperdrive Computer Entity - Shared
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Hyperdrive Computer"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Easy-to-use hyperdrive control system with automatic planet detection"
ENT.Instructions = "Simple hyperdrive computer. Press E to open interface. Automatically finds Master Engines and planets."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive"

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
