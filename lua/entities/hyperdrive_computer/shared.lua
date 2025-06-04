-- Hyperdrive Computer Entity - Shared
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Enhanced Navigation Computer"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Enhanced hyperdrive control system with 4-stage travel, fleet coordination, and quantum mechanics"
ENT.Instructions = "Enhanced navigation computer with web research improvements. Press E to open interface. Features quantum entanglement, spatial folding, and Stargate-themed travel."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Advanced Space Combat"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Powered")
    self:NetworkVar("Entity", 0, "LinkedEngine")
    self:NetworkVar("Int", 0, "ComputerMode")

    -- Enhanced Hyperspace features
    self:NetworkVar("Bool", 1, "QuantumEntangled")
    self:NetworkVar("Bool", 2, "SpatialFoldingEnabled")
    self:NetworkVar("Bool", 3, "FleetCoordination")
    self:NetworkVar("Int", 1, "FleetSize")
    self:NetworkVar("Int", 2, "HyperspaceStage")
    self:NetworkVar("String", 0, "FleetFormation")
    self:NetworkVar("Float", 0, "QuantumCoherence")
end

function ENT:GetModeString()
    local mode = self:GetComputerMode()
    if mode == 1 then return "Enhanced Navigation"
    elseif mode == 2 then return "Fleet Coordination"
    elseif mode == 3 then return "Quantum Systems"
    elseif mode == 4 then return "Planets"
    elseif mode == 5 then return "Status"
    else return "Enhanced Navigation" end
end

-- Enhanced Hyperspace status functions
function ENT:GetHyperspaceStageString()
    local stage = self:GetHyperspaceStage()
    if stage == 1 then return "Energy Buildup"
    elseif stage == 2 then return "Window Opening"
    elseif stage == 3 then return "Dimensional Transit"
    elseif stage == 4 then return "System Stabilization"
    else return "Idle" end
end

function ENT:GetQuantumStatus()
    if self:GetQuantumEntangled() then
        local coherence = self:GetQuantumCoherence()
        return "Entangled (" .. math.floor(coherence * 100) .. "% coherence)"
    else
        return "Not Entangled"
    end
end

-- Enhanced Network strings
if SERVER then
    util.AddNetworkString("hyperdrive_computer")
    util.AddNetworkString("hyperdrive_fleet_jump")
    util.AddNetworkString("hyperdrive_fleet_shields")
    util.AddNetworkString("hyperdrive_scan_planets")
    util.AddNetworkString("hyperdrive_quick_jump_planet")
    util.AddNetworkString("hyperdrive_toggle_front_indicator")
    util.AddNetworkString("hyperdrive_auto_detect_front")

    -- Enhanced Hyperspace network strings
    util.AddNetworkString("hyperdrive_enhanced_destination")
    util.AddNetworkString("hyperdrive_quantum_entangle")
    util.AddNetworkString("hyperdrive_fleet_formation")
    util.AddNetworkString("hyperdrive_spatial_folding")
    util.AddNetworkString("hyperdrive_emergency_protocol")
    util.AddNetworkString("hyperdrive_4stage_travel")
    util.AddNetworkString("hyperdrive_quantum_status")
    util.AddNetworkString("hyperdrive_fleet_sync")
end
