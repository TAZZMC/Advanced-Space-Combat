-- Hyperdrive System Initialization
-- This file initializes the hyperdrive addon and sets up global variables

-- Shared initialization
HYPERDRIVE = HYPERDRIVE or {}

-- Global hyperdrive settings (shared between client and server)
HYPERDRIVE.Config = {
    MaxJumpDistance = 50000,        -- Maximum jump distance in units
    MinJumpDistance = 1000,         -- Minimum jump distance in units
    EnergyPerUnit = 0.1,           -- Energy cost per unit of distance
    MaxEnergy = 1000,              -- Maximum energy capacity
    RechargeRate = 5,              -- Energy recharge per second
    CooldownTime = 10,             -- Cooldown between jumps in seconds
    JumpChargeTime = 3,            -- Time to charge before jump
    SafetyRadius = 500,            -- Safety radius around destination
}

if SERVER then
    -- Server-side initialization
    print("[Hyperdrive] Server-side initialization...")

    -- Add client-side files to download
    AddCSLuaFile("autorun/client/hyperdrive_hud.lua")
    AddCSLuaFile("autorun/client/hyperdrive_effects.lua")
    AddCSLuaFile("autorun/client/hyperdrive_effects_v2.lua")
    AddCSLuaFile("autorun/client/hyperdrive_sounds.lua")
    AddCSLuaFile("autorun/client/hyperdrive_materials.lua")
    AddCSLuaFile("autorun/client/hyperdrive_simple_interface.lua")
    AddCSLuaFile("autorun/client/hyperdrive_admin_panel.lua")
    AddCSLuaFile("autorun/client/hyperdrive_hyperspace_effects.lua")
    AddCSLuaFile("autorun/client/hyperdrive_hyperspace_window.lua")

    -- Load integration systems (with error handling)
    local serverFiles = {
        "autorun/hyperdrive_wiremod.lua",
        "autorun/hyperdrive_spacebuild.lua",
        "autorun/hyperdrive_stargate.lua",
        "autorun/hyperdrive_master.lua",
        "autorun/server/hyperdrive_hyperspace_dimension.lua"
    }

    for _, fileName in ipairs(serverFiles) do
        if file.Exists(fileName, "LUA") then
            include(fileName)
        else
            print("[Hyperdrive] Warning: " .. fileName .. " not found, skipping...")
        end
    end

    -- Custom resources would be added here if they existed
    -- Using default GMod materials and sounds for compatibility

    -- Destination storage
    HYPERDRIVE.Destinations = {}
    HYPERDRIVE.ActiveJumps = {}

    -- Utility functions
    function HYPERDRIVE.IsValidDestination(pos)
        if not pos or not isvector(pos) then return false end

        -- Check if destination is within map bounds
        local trace = util.TraceLine({
            start = pos + Vector(0, 0, 100),
            endpos = pos - Vector(0, 0, 100),
            mask = MASK_SOLID_BRUSHONLY
        })

        return not trace.Hit or trace.Fraction > 0.1
    end

    function HYPERDRIVE.CalculateEnergyCost(distance)
        return math.max(1, distance * HYPERDRIVE.Config.EnergyPerUnit)
    end

    -- Network strings
    util.AddNetworkString("hyperdrive_jump")
    util.AddNetworkString("hyperdrive_status")
    util.AddNetworkString("hyperdrive_destination")
    util.AddNetworkString("hyperdrive_open_interface")
    util.AddNetworkString("hyperdrive_set_destination")
    util.AddNetworkString("hyperdrive_start_jump")

    -- Enhanced effects network strings
    util.AddNetworkString("hyperdrive_effect")
    util.AddNetworkString("hyperdrive_quantum_event")
    util.AddNetworkString("hyperdrive_security_alert")
    util.AddNetworkString("hyperdrive_navigation_update")

    -- Hyperspace network strings
    util.AddNetworkString("hyperdrive_hyperspace_effect")
    util.AddNetworkString("hyperdrive_hyperspace_enter")
    util.AddNetworkString("hyperdrive_hyperspace_exit")

    print("[Hyperdrive] Server initialization complete!")

elseif CLIENT then
    -- Client-side initialization
    print("[Hyperdrive] Client-side initialization...")

    HYPERDRIVE = HYPERDRIVE or {}
    HYPERDRIVE.HUD = {}
    HYPERDRIVE.Effects = {}

    -- Load enhanced client-side systems (with error handling)
    local clientFiles = {
        "autorun/client/hyperdrive_hud.lua",
        "autorun/client/hyperdrive_effects.lua",
        "autorun/client/hyperdrive_effects_v2.lua",
        "autorun/client/hyperdrive_sounds.lua",
        "autorun/client/hyperdrive_materials.lua",
        "autorun/client/hyperdrive_simple_interface.lua",
        "autorun/client/hyperdrive_admin_panel.lua",
        "autorun/client/hyperdrive_hyperspace_effects.lua",
        "autorun/client/hyperdrive_hyperspace_window.lua"
    }

    for _, fileName in ipairs(clientFiles) do
        if file.Exists(fileName, "LUA") then
            include(fileName)
        else
            print("[Hyperdrive] Warning: " .. fileName .. " not found, skipping...")
        end
    end

    print("[Hyperdrive] Client initialization complete!")
end

-- Shared utility functions
function HYPERDRIVE.GetDistance(pos1, pos2)
    return pos1:Distance(pos2)
end

function HYPERDRIVE.FormatDistance(distance)
    if distance < 1000 then
        return string.format("%.0f units", distance)
    else
        return string.format("%.1f km", distance / 1000)
    end
end

function HYPERDRIVE.FormatEnergy(energy)
    return string.format("%.0f EU", energy)
end

-- Hook for cleanup
hook.Add("ShutDown", "HyperdriveCleanup", function()
    if SERVER and HYPERDRIVE.ActiveJumps then
        for k, v in pairs(HYPERDRIVE.ActiveJumps) do
            if IsValid(v.entity) then
                v.entity:Remove()
            end
        end
    end
end)
