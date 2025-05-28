-- Enhanced Hyperdrive Configuration
-- Configuration options for Space Combat 2 and Spacebuild 3 integration

if CLIENT then return end

-- Initialize enhanced configuration
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.EnhancedConfig = HYPERDRIVE.EnhancedConfig or {}

print("[Hyperdrive] Enhanced configuration loading...")

-- Enhanced configuration options
HYPERDRIVE.EnhancedConfig = {
    -- Space Combat 2 Integration
    SpaceCombat2 = {
        Enabled = true,                     -- Enable SC2 integration
        UseGyropodMovement = true,          -- Use gyropod for ship movement
        UseShipCore = true,                 -- Use ship core for entity detection
        OverrideGravity = true,             -- Override SC2 gravity during jumps
        OptimizedMovement = true,           -- Use optimized SetPos/SetAngles
        GyropodSearchRadius = 2000,         -- Radius to search for gyropods
        ShipCoreSearchRadius = 1500,        -- Radius to search for ship cores
        GravityOverrideDuration = 5,        -- Seconds to override gravity
    },
    
    -- Spacebuild 3 Integration
    Spacebuild3 = {
        Enabled = true,                     -- Enable SB3 integration
        UseShipCore = true,                 -- Use ship core for entity detection
        OverrideGravity = true,             -- Override SB3 gravity during jumps
        RequireLifeSupport = true,          -- Require life support for jumps
        RequirePower = true,                -- Require power for operation
        ShipCoreSearchRadius = 1500,        -- Radius to search for ship cores
        GravityOverrideDuration = 5,        -- Seconds to override gravity
    },
    
    -- Enhanced Entity Detection
    EntityDetection = {
        UseConstraintSystem = true,         -- Use constraint system as fallback
        UseShipCores = true,                -- Prefer ship cores for detection
        SearchRadius = 1000,                -- Default search radius
        IncludeVehicles = true,             -- Include vehicles in detection
        IncludePlayers = true,              -- Include players in detection
        IncludeProps = true,                -- Include props in detection
        IncludeSCEntities = true,           -- Include Space Combat entities
        IncludeSBEntities = true,           -- Include Spacebuild entities
    },
    
    -- Movement Optimization
    Movement = {
        UseBatchMovement = true,            -- Batch entity movement
        UseOptimizedSetPos = true,          -- Use optimized SetPos if available
        ClearVelocities = true,             -- Clear entity velocities after movement
        NetworkOptimization = true,         -- Enable network optimization
        MovementDelay = 0,                  -- Delay between entity movements (seconds)
    },
    
    -- Gravity Management
    Gravity = {
        OverrideDuringJumps = true,         -- Override gravity during jumps
        HyperspaceGravity = 0.5,            -- Gravity multiplier in hyperspace
        RestoreDelay = 3,                   -- Delay before restoring gravity
        UseGamemodeOverride = true,         -- Use gamemode-specific gravity override
    },
    
    -- Debug Options
    Debug = {
        LogEntityDetection = false,         -- Log entity detection details
        LogMovement = false,                -- Log movement operations
        LogGravityChanges = false,          -- Log gravity changes
        LogSC2Integration = false,          -- Log SC2 integration details
        LogSB3Integration = false,          -- Log SB3 integration details
    }
}

-- Function to get configuration value with fallback
function HYPERDRIVE.EnhancedConfig.Get(category, key, default)
    if HYPERDRIVE.EnhancedConfig[category] and HYPERDRIVE.EnhancedConfig[category][key] ~= nil then
        return HYPERDRIVE.EnhancedConfig[category][key]
    end
    return default
end

-- Function to set configuration value
function HYPERDRIVE.EnhancedConfig.Set(category, key, value)
    if not HYPERDRIVE.EnhancedConfig[category] then
        HYPERDRIVE.EnhancedConfig[category] = {}
    end
    HYPERDRIVE.EnhancedConfig[category][key] = value
end

-- Console commands for configuration
concommand.Add("hyperdrive_config_show", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    local category = args[1]
    if category and HYPERDRIVE.EnhancedConfig[category] then
        ply:ChatPrint("[Hyperdrive] Configuration for " .. category .. ":")
        for key, value in pairs(HYPERDRIVE.EnhancedConfig[category]) do
            ply:ChatPrint("  • " .. key .. ": " .. tostring(value))
        end
    else
        ply:ChatPrint("[Hyperdrive] Available configuration categories:")
        for cat, _ in pairs(HYPERDRIVE.EnhancedConfig) do
            if type(HYPERDRIVE.EnhancedConfig[cat]) == "table" then
                ply:ChatPrint("  • " .. cat)
            end
        end
        ply:ChatPrint("Usage: hyperdrive_config_show <category>")
    end
end)

concommand.Add("hyperdrive_config_set", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    if #args < 3 then
        ply:ChatPrint("[Hyperdrive] Usage: hyperdrive_config_set <category> <key> <value>")
        return
    end
    
    local category = args[1]
    local key = args[2]
    local value = args[3]
    
    -- Convert value to appropriate type
    if value == "true" then
        value = true
    elseif value == "false" then
        value = false
    elseif tonumber(value) then
        value = tonumber(value)
    end
    
    HYPERDRIVE.EnhancedConfig.Set(category, key, value)
    ply:ChatPrint("[Hyperdrive] Set " .. category .. "." .. key .. " = " .. tostring(value))
end)

concommand.Add("hyperdrive_config_reset", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    -- Reset to defaults (reload the file)
    include("autorun/hyperdrive_config_enhanced.lua")
    ply:ChatPrint("[Hyperdrive] Configuration reset to defaults")
end)

-- Integration status check
function HYPERDRIVE.EnhancedConfig.CheckIntegrations()
    local status = {
        SpaceCombat2 = false,
        Spacebuild3 = false,
        Wiremod = false,
        Stargate = false
    }
    
    -- Check Space Combat 2
    if GAMEMODE and GAMEMODE.Name == "Space Combat 2" then
        status.SpaceCombat2 = true
    elseif file.Exists("gamemodes/spacecombat2/gamemode/init.lua", "GAME") then
        status.SpaceCombat2 = true
    end
    
    -- Check Spacebuild 3
    if CAF then
        status.Spacebuild3 = true
    end
    
    -- Check Wiremod
    if WireLib then
        status.Wiremod = true
    end
    
    -- Check Stargate
    if StarGate then
        status.Stargate = true
    end
    
    return status
end

concommand.Add("hyperdrive_integration_status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local status = HYPERDRIVE.EnhancedConfig.CheckIntegrations()
    
    ply:ChatPrint("[Hyperdrive] Integration Status:")
    for integration, enabled in pairs(status) do
        local statusText = enabled and "✓ Detected" or "✗ Not Found"
        ply:ChatPrint("  • " .. integration .. ": " .. statusText)
    end
end)

-- Auto-configure based on detected addons
timer.Simple(1, function()
    local status = HYPERDRIVE.EnhancedConfig.CheckIntegrations()
    
    -- Auto-disable integrations if addons not found
    if not status.SpaceCombat2 then
        HYPERDRIVE.EnhancedConfig.Set("SpaceCombat2", "Enabled", false)
    end
    
    if not status.Spacebuild3 then
        HYPERDRIVE.EnhancedConfig.Set("Spacebuild3", "Enabled", false)
    end
    
    print("[Hyperdrive] Enhanced configuration loaded with auto-detection:")
    print("  • Space Combat 2: " .. (status.SpaceCombat2 and "Detected" or "Not Found"))
    print("  • Spacebuild 3: " .. (status.Spacebuild3 and "Detected" or "Not Found"))
    print("  • Wiremod: " .. (status.Wiremod and "Detected" or "Not Found"))
    print("  • Stargate: " .. (status.Stargate and "Detected" or "Not Found"))
end)

print("[Hyperdrive] Enhanced configuration system loaded")
