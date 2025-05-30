-- Enhanced Hyperdrive System v2.1 - Enhanced Configuration
-- Comprehensive configuration system with all features, integrations, and USE key interfaces

if CLIENT then return end

-- Initialize enhanced configuration
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.EnhancedConfig = HYPERDRIVE.EnhancedConfig or {}

-- Version and metadata
HYPERDRIVE.EnhancedConfig.Version = "2.1.0"
HYPERDRIVE.EnhancedConfig.LastUpdate = os.time()
HYPERDRIVE.EnhancedConfig.BuildDate = os.date("%Y-%m-%d")

print("[Hyperdrive] Enhanced configuration v2.1 loading...")

-- Enhanced configuration options
HYPERDRIVE.EnhancedConfig = {
    -- Core System Integration (SHIP CORE IS MANDATORY)
    Core = {
        EnableShipCore = true,              -- Enable ship core integration (REQUIRED)
        AutoDetectShips = true,             -- Automatically detect ships
        RequireShipForJump = true,          -- Require ship for jump operations (MANDATORY)
        RequireShipCore = true,             -- Require ship core for all operations (MANDATORY)
        EnforceOneCorePerShip = true,       -- Enforce only one ship core per ship (MANDATORY)
        ShowFrontIndicator = true,          -- Show ship front indicator
        AutoFrontDetection = true,          -- Auto-detect ship front direction
        MinShipSize = 5,                    -- Minimum ship size (entities)

        -- Shield Integration
        EnableShields = true,               -- Enable shield system
        AutoActivateShields = true,         -- Auto-activate shields during jumps
        ShieldEnergyConsumption = 10,       -- Energy consumption per second
        ShieldAutoDeactivate = false,       -- Auto-deactivate after jumps
        ShieldProtectionLevel = 0.8,        -- Damage reduction percentage

        -- CAP Integration
        EnableCAPIntegration = true,        -- Enable CAP bubble shield integration
        PreferCAPShields = true,            -- Prefer CAP shields over custom
        CAPFallbackEnabled = true,          -- Fallback to custom if CAP unavailable
        CAPAutoDetection = true,            -- Auto-detect CAP installation

        -- Hull Damage System
        EnableHullDamage = true,            -- Enable hull damage system
        AutoCreateHullSystem = true,        -- Auto-create hull system for ships
        HullDamageWireIntegration = true,   -- Enable wire integration for hull damage
        HullAutoRepair = true,              -- Enable automatic hull repair
    },

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

    -- Hull Damage System
    HullDamage = {
        EnableHullDamage = true,            -- Enable hull damage system
        AutoCreateHullSystem = true,        -- Auto-create hull system for ships
        MaxHullIntegrity = 100,             -- Maximum hull integrity
        CriticalHullThreshold = 25,         -- Critical damage threshold
        EmergencyHullThreshold = 10,        -- Emergency threshold
        HullRepairRate = 0.5,               -- Auto-repair rate per second
        AutoRepairEnabled = true,           -- Enable auto-repair
        AutoRepairDelay = 30,               -- Delay before auto-repair starts
        DamageToShieldsRatio = 0.3,         -- Ratio of damage that goes to shields
        HullBreachChance = 0.1,             -- Chance of hull breach per damage
        SystemFailureChance = 0.05,         -- Chance of system failure
        DamageVisualsEnabled = true,        -- Enable damage visual effects
        DamageEffectsEnabled = true,        -- Enable damage sound effects
        HullDamageWireIntegration = true,   -- Enable wire integration
        PreventJumpOnCritical = true,       -- Prevent hyperdrive when hull critical
        RepairCostMultiplier = 1.0,         -- Cost multiplier for repairs
    },

    -- Ship Naming System
    ShipNaming = {
        EnableShipNaming = true,            -- Enable ship naming system
        MaxNameLength = 32,                 -- Maximum ship name length
        MinNameLength = 1,                  -- Minimum ship name length
        AllowSpecialCharacters = false,     -- Allow special characters in names
        SaveShipNames = true,               -- Save ship names to files
        ShowNameInUI = true,                -- Show ship name in UI
        ShowNameAboveCore = true,           -- Show ship name above core in 3D
        DefaultShipName = "Unnamed Ship",   -- Default name for new ships
        ValidateNameUniqueness = false,     -- Validate ship name uniqueness (optional)
        AutoGenerateNames = false,          -- Auto-generate names for unnamed ships
        NameGenerationPattern = "Ship-%d",  -- Pattern for auto-generated names
        LogNameChanges = true,              -- Log ship name changes
        AllowPlayerRename = true,           -- Allow players to rename ships
        RequireOwnershipToRename = false,   -- Require ownership to rename ships
        BroadcastNameChanges = true,        -- Broadcast name changes to all players
        NameValidationPattern = "^[%w%s%-_]+$", -- Regex pattern for name validation
        ReservedNames = {                   -- Reserved names that cannot be used
            "Admin", "Server", "System", "Core", "Engine", "Computer"
        }
    },

    -- Interface System (USE Key Integration)
    Interface = {
        EnableUSEKeyInterfaces = true,      -- Enable USE key for all interfaces
        MaxInteractionDistance = 200,       -- Maximum distance for USE interactions
        ShowInteractionHints = true,        -- Show interaction hints to players
        EnableDistanceChecking = true,      -- Enable distance validation
        InterfaceTimeout = 300,             -- Interface timeout in seconds
        EnableFeedbackMessages = true,      -- Enable chat feedback messages
        EnableStatusDisplay = true,         -- Enable status information display
        EnableHelpCommands = true,          -- Enable help command system
        EnableShiftModifier = true,         -- Enable SHIFT+USE for ship core access
        EnableAdvancedInterfaces = true,    -- Enable advanced interface features
        LogInterfaceUsage = false,          -- Log interface usage (debug)
        EnableSoundFeedback = true,         -- Enable sound feedback for interactions
        EnableVisualFeedback = true,        -- Enable visual feedback for interactions
        InterfaceUpdateRate = 1.0,          -- Interface update rate in seconds
        EnableSessionTracking = true,       -- Track active interface sessions
        MaxConcurrentSessions = 10,         -- Maximum concurrent interface sessions per player
        EnablePermissionChecks = false,     -- Enable permission checking for interfaces
        DefaultPermissionLevel = "user",    -- Default permission level for interfaces
    },

    -- Spacebuild 3 Resource System (Official RD Integration)
    SB3Resources = {
        EnableResourceCore = true,          -- Enable ship core resource system
        AutoDetectSB3 = true,               -- Auto-detect Spacebuild 3 RD/LS2 systems
        UseShipCoreAsHub = true,            -- Use ship core as central resource hub
        EnableResourceDistribution = true,  -- Enable automatic resource distribution
        DistributionInterval = 1.0,         -- Distribution update interval (seconds)
        MaxTransferDistance = 2000,         -- Maximum transfer distance (units)
        EnableResourceSharing = true,       -- Enable resource sharing between ships
        LogResourceTransfers = false,       -- Log resource transfers (debug mode)
        EnableEmergencyShutdown = true,     -- Enable emergency resource shutdown
        CriticalResourceThreshold = 10,     -- Critical resource threshold (%)
        EnableResourceAlerts = true,        -- Enable resource alerts to players
        AutoBalanceResources = true,        -- Auto-balance resources across ship

        -- Resource Capacities (Spacebuild 3 Compatible)
        DefaultEnergyCapacity = 10000,      -- Default energy capacity (kW)
        DefaultOxygenCapacity = 5000,       -- Default oxygen capacity (L)
        DefaultCoolantCapacity = 2000,      -- Default coolant capacity (L)
        DefaultFuelCapacity = 3000,         -- Default fuel capacity (L)
        DefaultWaterCapacity = 1500,        -- Default water capacity (L)
        DefaultNitrogenCapacity = 1000,     -- Default nitrogen capacity (L)

        -- Transfer Rates (Per Second)
        EnergyTransferRate = 1000,          -- Energy transfer rate (kW/s)
        OxygenTransferRate = 500,           -- Oxygen transfer rate (L/s)
        CoolantTransferRate = 200,          -- Coolant transfer rate (L/s)
        FuelTransferRate = 300,             -- Fuel transfer rate (L/s)
        WaterTransferRate = 150,            -- Water transfer rate (L/s)
        NitrogenTransferRate = 100,         -- Nitrogen transfer rate (L/s)

        -- Spacebuild 3 Integration Settings
        EnableRDIntegration = true,         -- Enable Resource Distribution (RD) integration
        EnableLS2Integration = true,        -- Enable Life Support 2 (LS2) integration
        RDCompatibilityMode = "auto",       -- RD compatibility: "auto", "manual", "disabled"
        SurplusCollectionThreshold = 90,    -- Collect surplus when over this % capacity
        SurplusRetentionLevel = 80,         -- Retain this % when collecting surplus
        EnableRDNetworking = true,          -- Enable RD network participation
        RDNetworkPriority = 1,              -- Priority in RD network (1=highest)

        -- Automatic Resource Provision for Newly Welded Entities
        EnableAutoResourceProvision = true, -- Enable automatic resource provision
        AutoProvisionOnWeld = true,         -- Provide resources when entities are welded
        AutoProvisionDelay = 0.5,           -- Delay before providing resources (seconds)
        EnableWeldDetection = true,         -- Enable weld detection system
        LogWeldDetection = false,           -- Log weld detection events
        NotifyPlayersOnProvision = true,    -- Notify players when resources are provided
        AutoProvisionPercentage = 50,       -- Percentage of entity capacity to provide initially
        MinAutoProvisionAmount = 25,        -- Minimum amount to provide per resource type
        MaxAutoProvisionAmount = 500,       -- Maximum amount to provide per resource type
    },

    -- Debug Options
    Debug = {
        LogEntityDetection = false,         -- Log entity detection details
        LogMovement = false,                -- Log movement operations
        LogGravityChanges = false,          -- Log gravity changes
        LogSC2Integration = false,          -- Log SC2 integration details
        LogSB3Integration = false,          -- Log SB3 integration details
        LogHullDamage = false,              -- Log hull damage operations
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

-- Integration registry
HYPERDRIVE.EnhancedConfig.Integrations = HYPERDRIVE.EnhancedConfig.Integrations or {}

-- Register an integration
function HYPERDRIVE.EnhancedConfig.RegisterIntegration(name, config)
    if not name or not config then
        print("[Hyperdrive] Error: Invalid integration registration")
        return false
    end

    HYPERDRIVE.EnhancedConfig.Integrations[name] = {
        name = config.name or name,
        description = config.description or "No description",
        version = config.version or "1.0.0",
        checkFunction = config.checkFunction,
        validateFunction = config.validateFunction,
        configCategories = config.configCategories or {},
        registered = true,
        registrationTime = CurTime()
    }

    print("[Hyperdrive] Registered integration: " .. name .. " (" .. (config.version or "1.0.0") .. ")")
    return true
end

-- Get registered integrations
function HYPERDRIVE.EnhancedConfig.GetIntegrations()
    return HYPERDRIVE.EnhancedConfig.Integrations
end

-- Check if integration is registered
function HYPERDRIVE.EnhancedConfig.IsIntegrationRegistered(name)
    return HYPERDRIVE.EnhancedConfig.Integrations[name] ~= nil
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
        Stargate = false,
        CAP = false
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

    -- Check CAP (Carter Addon Pack)
    if HYPERDRIVE.CAP and HYPERDRIVE.CAP.Available then
        status.CAP = true
    elseif StarGate or CAP or CAP_RESOURCES then
        status.CAP = true
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

concommand.Add("hyperdrive_list_integrations", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local integrations = HYPERDRIVE.EnhancedConfig.GetIntegrations()

    ply:ChatPrint("[Hyperdrive] Registered Integrations:")
    for name, data in pairs(integrations) do
        ply:ChatPrint("  • " .. data.name .. " v" .. data.version)
        ply:ChatPrint("    " .. data.description)
    end

    if table.Count(integrations) == 0 then
        ply:ChatPrint("  No integrations registered yet.")
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

    if not status.CAP then
        HYPERDRIVE.EnhancedConfig.Set("CAP", "EnableCAPIntegration", false)
    end

    print("[Hyperdrive] Enhanced configuration loaded with auto-detection:")
    print("  • Space Combat 2: " .. (status.SpaceCombat2 and "Detected" or "Not Found"))
    print("  • Spacebuild 3: " .. (status.Spacebuild3 and "Detected" or "Not Found"))
    print("  • Wiremod: " .. (status.Wiremod and "Detected" or "Not Found"))
    print("  • Stargate: " .. (status.Stargate and "Detected" or "Not Found"))
    print("  • CAP (Carter Addon Pack): " .. (status.CAP and "Detected" or "Not Found"))
end)

-- Add CAP configuration to the main config
HYPERDRIVE.EnhancedConfig.Core.CAP = {
    -- Core Integration Settings
    EnableCAPIntegration = true,
    PreferCAPSystems = true,
    AutoCreateCAPShields = false,
    CAPResourceIntegration = true,
    CAPEffectsEnabled = true,
    CAPShieldAutoActivation = true,

    -- Shield Integration
    UseCAPShields = true,
    PreferCAPShields = true,
    AutoDetectCAPShields = true,
    IntegrateWithCAPResources = true,

    -- Energy Integration
    UseCAPEnergy = true,
    ShareEnergyWithStargates = true,
    UseCAPEnergyTypes = true,

    -- Effects Integration
    UseCAPEffects = true,
    UseStargateEffects = true,
    UseShieldEffects = true,
    UseTransportEffects = true,

    -- Stargate Integration
    IntegrateWithStargates = true,
    UseStargateNetwork = true,
    PreventStargateConflicts = true,
    UseStargateAddresses = true,
    IntegrateWithDHD = true,
    CheckStargateStatus = true,
    UseStargateProtection = true,
    RequireStargateEnergy = false,

    -- Detection and Performance
    CAPDetectionRange = 2000,
    CAPUpdateInterval = 2.0,
    AutoDetectCAP = true,

    -- Shield Configuration
    ShieldActivationDelay = 2.0,
    ShieldRechargeRate = 5.0,
    UseShieldFrequencies = true,
    IntegrateShieldPower = true,

    -- Resource Configuration
    ShareResourceStorage = true,
    AutoProvisionCAP = true
}

print("[Hyperdrive] Enhanced configuration system with CAP integration loaded")
