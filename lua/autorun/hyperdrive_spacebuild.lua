-- Enhanced Hyperdrive Spacebuild 3 Integration
-- Advanced integration with Spacebuild 3 CAF framework, life support, and resource systems
-- Based on official Spacebuild 3 repository: https://github.com/spacebuild/spacebuild

if CLIENT then return end

-- Check for Spacebuild 3 CAF framework
local isSpacebuild3Loaded = CAF and CAF.GetAddon and true or false

print("[Hyperdrive] Enhanced Spacebuild 3 integration loading... (SB3 " .. (isSpacebuild3Loaded and "detected" or "not detected") .. ")")

HYPERDRIVE.Spacebuild = HYPERDRIVE.Spacebuild or {}

-- Enhanced Spacebuild integration settings
HYPERDRIVE.Spacebuild.Config = {
    Enabled = true,                     -- Enable Spacebuild integration
    UseCAFFramework = true,             -- Use CAF framework for detection
    RequireLifeSupport = true,          -- Require life support for jumps
    RequirePower = true,                -- Require power connection
    PowerConsumption = 50,              -- Power units per second during charge
    JumpPowerCost = 500,               -- Power cost per jump
    OxygenConsumption = 2,             -- Oxygen per second during charge
    CoolantRequired = true,            -- Require coolant for engines
    CoolantConsumption = 5,            -- Coolant per jump
    SpaceJumpBonus = 0.5,              -- Energy bonus when jumping in space
    AtmosphereJumpPenalty = 1.5,       -- Energy penalty when jumping in atmosphere
    CheckResourceDistribution = true,   -- Check RD3 network connectivity
    OverrideGravity = true,            -- Override gravity during jumps
    CheckAtmosphere = true,            -- Check atmosphere requirements
    ValidateShipIntegrity = true,      -- Validate ship systems before jump
    UseRD3System = true,               -- Use Resource Distribution 3 system
    CheckEnvironmentSystems = true,    -- Check environment control systems
}

-- Resource type mappings for Spacebuild
HYPERDRIVE.Spacebuild.Resources = {
    Power = "energy",
    Oxygen = "oxygen",
    Coolant = "coolant",
    Fuel = "fuel"
}

-- Spacebuild 3 entity categories for detection (based on official repository)
HYPERDRIVE.Spacebuild.EntityCategories = {
    LIFE_SUPPORT = {
        "base_air_exchanger",
        "base_climate_control",
        "base_gravity_control",
        "base_cube_environment",
        "base_sb_environment"
    },
    POWER_GENERATION = {
        "generator_energy_fusion",
        "generator_energy_hydro",
        "generator_energy_solar",
        "generator_energy_steam_turbine",
        "generator_energy_wind"
    },
    POWER_STORAGE = {
        "storage_energy"
    },
    RESOURCE_STORAGE = {
        "storage_gas",
        "storage_gas_steam",
        "storage_liquid_water",
        "storage_liquid_nitrogen",
        "storage_liquid_hvywater",
        "storage_cache"
    },
    RESOURCE_GENERATION = {
        "generator_gas",
        "generator_gas_o2h_water",
        "generator_gas_steam",
        "generator_liquid_water",
        "generator_liquid_nitrogen",
        "generator_ramscoop"
    },
    RD3_COMPONENTS = {
        "rd_pump",
        "rd_ent_valve",
        "rd_node_valve",
        "rd_one_way_valve",
        "resource_node"
    },
    ENVIRONMENT = {
        "base_terraformer",
        "base_temperature_exchanger"
    },
    UTILITY = {
        "other_dispenser",
        "other_lamp",
        "other_probe",
        "other_screen",
        "other_spotlight"
    }
}

-- Spacebuild state tracking
HYPERDRIVE.Spacebuild.State = {
    detectedEntities = {},
    resourceNetworks = {},
    lifeSupportSystems = {},
    powerSystems = {},
    environmentSystems = {},
    rd3Networks = {},
    lastScan = 0,
    cafAddons = {},
}

-- Enhanced Spacebuild 3 Integration Functions
HYPERDRIVE.Spacebuild.Enhanced = HYPERDRIVE.Spacebuild.Enhanced or {}

-- Function to get configuration value with enhanced config fallback
local function GetSBConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("Spacebuild3", key, HYPERDRIVE.Spacebuild.Config[key] or default)
    end
    return HYPERDRIVE.Spacebuild.Config[key] or default
end

-- Check if Spacebuild 3 is loaded and functional
function HYPERDRIVE.Spacebuild.Enhanced.IsSpacebuild3Loaded()
    if not CAF then return false, "CAF framework not found" end
    if not CAF.GetAddon then return false, "CAF.GetAddon not available" end

    -- Check for core CAF functionality
    local hasCore = CAF.RegisterAddon and CAF.GetAddonStatus and true or false
    if not hasCore then return false, "Core CAF functions missing" end

    -- Check for resource distribution system
    local hasRD3 = CAF.GetAddon("Resource Distribution") ~= nil

    return true, "Spacebuild 3 fully loaded", {
        caf = true,
        rd3 = hasRD3,
        version = CAF.version or "unknown"
    }
end

-- Get CAF addon information
function HYPERDRIVE.Spacebuild.Enhanced.GetCAFAddons()
    if not CAF or not CAF.GetAddon then return {} end

    local addons = {}

    -- Common Spacebuild addons to check
    local addonNames = {
        "Resource Distribution",
        "Life Support",
        "Environment",
        "Spacebuild Core"
    }

    for _, name in ipairs(addonNames) do
        local addon = CAF.GetAddon(name)
        if addon then
            local status = CAF.GetAddonStatus(name)
            local version = CAF.GetAddonVersion(name)

            addons[name] = {
                addon = addon,
                status = status,
                version = version,
                available = true
            }
        else
            addons[name] = {
                available = false
            }
        end
    end

    return addons
end

-- Enhanced entity detection using CAF framework and Ship Core system
function HYPERDRIVE.Spacebuild.Enhanced.DetectSpacebuildEntities(engine, searchRadius)
    if not GetSBConfig("Enabled", true) then return {} end

    -- Use our new ship core system first
    if HYPERDRIVE.ShipCore then
        local shipEntities = HYPERDRIVE.ShipCore.GetAttachedEntities(engine, searchRadius)
        if #shipEntities > 0 then
            print("[Hyperdrive SB3] Using Ship Core system - found " .. #shipEntities .. " entities")

            -- Filter for Spacebuild entities only
            local spacebuildEntities = {}
            for _, ent in ipairs(shipEntities) do
                if IsValid(ent) then
                    local category = HYPERDRIVE.Spacebuild.Enhanced.GetEntityCategory(ent:GetClass())
                    if category then
                        table.insert(spacebuildEntities, ent)
                    end
                end
            end

            if #spacebuildEntities > 0 then
                print("[Hyperdrive SB3] Found " .. #spacebuildEntities .. " Spacebuild entities in ship")
                return spacebuildEntities
            end
        end
    end

    if not GetSBConfig("UseCAFFramework", true) then
        return HYPERDRIVE.Spacebuild.Enhanced.DetectSpacebuildEntitiesBasic(engine, searchRadius)
    end

    searchRadius = searchRadius or 2000
    local entities = {}
    local enginePos = engine:GetPos()

    -- Get all entities in radius
    local nearbyEnts = ents.FindInSphere(enginePos, searchRadius)

    -- Categorize Spacebuild entities
    local categorizedEntities = {
        lifeSupport = {},
        powerGeneration = {},
        powerStorage = {},
        resourceStorage = {},
        resourceGeneration = {},
        rd3Components = {},
        environment = {},
        utility = {},
        other = {}
    }

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            local entClass = ent:GetClass()
            local category = HYPERDRIVE.Spacebuild.Enhanced.GetEntityCategory(entClass)

            if category then
                local entityData = {
                    entity = ent,
                    class = entClass,
                    position = ent:GetPos(),
                    distance = enginePos:Distance(ent:GetPos()),
                    category = category
                }

                -- Add CAF-specific data if available
                if CAF and ent.GetResourceAmount then
                    entityData.resources = {}
                    for resourceType, _ in pairs(HYPERDRIVE.Spacebuild.Resources) do
                        local amount = ent:GetResourceAmount(resourceType)
                        if amount and amount > 0 then
                            entityData.resources[resourceType] = amount
                        end
                    end
                end

                table.insert(categorizedEntities[category], entityData)
                table.insert(entities, ent)
            end
        end
    end

    -- Store categorized data
    HYPERDRIVE.Spacebuild.State.detectedEntities = categorizedEntities
    HYPERDRIVE.Spacebuild.State.lastScan = CurTime()

    return entities
end

-- Get entity category based on class name
function HYPERDRIVE.Spacebuild.Enhanced.GetEntityCategory(className)
    for categoryName, classes in pairs(HYPERDRIVE.Spacebuild.EntityCategories) do
        for _, class in ipairs(classes) do
            if className == class then
                return string.lower(categoryName:gsub("_", ""))
            end
        end
    end
    return nil
end

-- Validate Spacebuild 3 ship configuration
function HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration(engine)
    if not GetSBConfig("Enabled", true) then return true, {} end
    if not IsValid(engine) then return false, {"Invalid engine"} end

    local issues = {}
    local warnings = {}

    -- Detect Spacebuild entities
    local entities = HYPERDRIVE.Spacebuild.Enhanced.DetectSpacebuildEntities(engine)
    local categorized = HYPERDRIVE.Spacebuild.State.detectedEntities

    -- Check life support requirements
    if GetSBConfig("RequireLifeSupport", true) then
        if #categorized.lifeSupport == 0 then
            table.insert(issues, "No life support systems detected")
        else
            -- Check for specific life support components
            local hasAirExchanger = false
            local hasClimateControl = false

            for _, entData in ipairs(categorized.lifeSupport) do
                if entData.class == "base_air_exchanger" then hasAirExchanger = true end
                if entData.class == "base_climate_control" then hasClimateControl = true end
            end

            if not hasAirExchanger then
                table.insert(warnings, "No air exchanger detected - oxygen may be limited")
            end
            if not hasClimateControl then
                table.insert(warnings, "No climate control detected - temperature regulation may fail")
            end
        end
    end

    -- Check power requirements
    if GetSBConfig("RequirePower", true) then
        local totalPowerGeneration = #categorized.powerGeneration
        local totalPowerStorage = #categorized.powerStorage

        if totalPowerGeneration == 0 and totalPowerStorage == 0 then
            table.insert(issues, "No power generation or storage detected")
        elseif totalPowerGeneration == 0 then
            table.insert(warnings, "No power generation detected - relying on stored power only")
        elseif totalPowerStorage == 0 then
            table.insert(warnings, "No power storage detected - no backup power available")
        end
    end

    -- Check resource distribution network
    if GetSBConfig("CheckResourceDistribution", true) then
        if #categorized.rd3components == 0 then
            table.insert(warnings, "No RD3 components detected - resource distribution may be limited")
        end
    end

    -- Check environment systems
    if GetSBConfig("CheckEnvironmentSystems", true) then
        if #categorized.environment == 0 then
            table.insert(warnings, "No environment control systems detected")
        end
    end

    -- Validate ship integrity
    if GetSBConfig("ValidateShipIntegrity", true) then
        local totalEntities = #entities
        if totalEntities < 5 then
            table.insert(warnings, "Very small ship detected - may not be suitable for long jumps")
        elseif totalEntities > 1000 then
            table.insert(warnings, "Very large ship detected - jump may consume significant resources")
        end
    end

    local isValid = #issues == 0
    local allIssues = {}

    for _, issue in ipairs(issues) do
        table.insert(allIssues, {type = "error", message = issue})
    end
    for _, warning in ipairs(warnings) do
        table.insert(allIssues, {type = "warning", message = warning})
    end

    return isValid, allIssues
end

-- Check resource availability for jump
function HYPERDRIVE.Spacebuild.Enhanced.CheckResourceAvailability(engine, destination)
    if not GetSBConfig("Enabled", true) then return true, {} end
    if not IsValid(engine) or not CAF then return true, {} end

    local issues = {}
    local distance = engine:GetPos():Distance(destination)

    -- Calculate resource requirements
    local powerRequired = GetSBConfig("JumpPowerCost", 500)
    local oxygenRequired = GetSBConfig("OxygenConsumption", 2) * 10 -- Assume 10 second jump
    local coolantRequired = GetSBConfig("CoolantConsumption", 5)

    -- Adjust for distance
    local distanceMultiplier = math.max(1, distance / 10000)
    powerRequired = powerRequired * distanceMultiplier
    oxygenRequired = oxygenRequired * distanceMultiplier
    coolantRequired = coolantRequired * distanceMultiplier

    -- Check available resources
    local categorized = HYPERDRIVE.Spacebuild.State.detectedEntities
    local availableResources = {
        power = 0,
        oxygen = 0,
        coolant = 0
    }

    -- Sum up resources from storage entities
    for _, category in pairs({"powerStorage", "resourceStorage"}) do
        for _, entData in ipairs(categorized[category] or {}) do
            if entData.resources then
                for resourceType, amount in pairs(entData.resources) do
                    local mappedType = string.lower(resourceType)
                    if availableResources[mappedType] then
                        availableResources[mappedType] = availableResources[mappedType] + amount
                    end
                end
            end
        end
    end

    -- Check if requirements are met
    if GetSBConfig("RequirePower", true) and availableResources.power < powerRequired then
        table.insert(issues, string.format("Insufficient power: %d required, %d available",
            powerRequired, availableResources.power))
    end

    if GetSBConfig("RequireLifeSupport", true) and availableResources.oxygen < oxygenRequired then
        table.insert(issues, string.format("Insufficient oxygen: %d required, %d available",
            oxygenRequired, availableResources.oxygen))
    end

    if GetSBConfig("CoolantRequired", true) and availableResources.coolant < coolantRequired then
        table.insert(issues, string.format("Insufficient coolant: %d required, %d available",
            coolantRequired, availableResources.coolant))
    end

    return #issues == 0, issues
end

-- Enhanced gravity override for Spacebuild 3
function HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity(player, override)
    if not IsValid(player) or not player:IsPlayer() then return end
    if not GetSBConfig("OverrideGravity", true) then return end
    if not CAF then return end

    if override then
        -- Store original gravity state
        player.HyperdriveOriginalGravity = player:GetGravity()

        -- Check for gravity control systems
        local gravityControllers = ents.FindByClass("base_gravity_control")
        local hasGravityControl = false

        for _, controller in ipairs(gravityControllers) do
            if IsValid(controller) and controller:GetPos():Distance(player:GetPos()) < 2000 then
                hasGravityControl = true
                break
            end
        end

        -- Set appropriate gravity based on ship systems
        local gravityValue = hasGravityControl and 0.8 or 0.3
        player:SetGravity(gravityValue)

        -- Notify gravity controllers if available
        for _, controller in ipairs(gravityControllers) do
            if IsValid(controller) and controller.OnHyperdriveJump then
                controller:OnHyperdriveJump(true)
            end
        end
    else
        -- Restore original gravity
        if player.HyperdriveOriginalGravity then
            player:SetGravity(player.HyperdriveOriginalGravity)
            player.HyperdriveOriginalGravity = nil
        end

        -- Notify gravity controllers
        local gravityControllers = ents.FindByClass("base_gravity_control")
        for _, controller in ipairs(gravityControllers) do
            if IsValid(controller) and controller.OnHyperdriveJump then
                controller:OnHyperdriveJump(false)
            end
        end
    end
end

-- Find SB3 ship core equivalent (resource distribution center)
function HYPERDRIVE.Spacebuild.Enhanced.FindShipCore(engine)
    if not IsValid(engine) or not CAF then return nil end

    local searchRadius = 1500
    local nearbyEnts = ents.FindInSphere(engine:GetPos(), searchRadius)

    -- Look for resource nodes or storage caches as ship core equivalents
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            local class = ent:GetClass()
            if class == "resource_node" or class == "storage_cache" then
                return ent
            end
        end
    end

    -- Fallback: look for any power storage as central system
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == "storage_energy" then
            return ent
        end
    end

    return nil
end

-- Console commands for Spacebuild 3 integration
concommand.Add("hyperdrive_sb3_validate", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local engine = ply:GetEyeTrace().Entity
    if not IsValid(engine) or not string.find(engine:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive SB3] Please look at a hyperdrive engine")
        return
    end

    local isValid, issues = HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration(engine)

    ply:ChatPrint("[Hyperdrive SB3] Ship Validation Results:")
    ply:ChatPrint("  • Status: " .. (isValid and "VALID" or "INVALID"))
    ply:ChatPrint("  • Issues Found: " .. #issues)

    for i, issue in ipairs(issues) do
        if i <= 10 then -- Limit output
            local prefix = issue.type == "error" and "ERROR" or "WARNING"
            ply:ChatPrint("  • [" .. prefix .. "] " .. issue.message)
        end
    end

    if #issues > 10 then
        ply:ChatPrint("  • ... and " .. (#issues - 10) .. " more issues")
    end
end)

concommand.Add("hyperdrive_sb3_status", function(ply, cmd, args)
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end

    local isLoaded, status, details = HYPERDRIVE.Spacebuild.Enhanced.IsSpacebuild3Loaded()
    local addons = HYPERDRIVE.Spacebuild.Enhanced.GetCAFAddons()

    sendMessage("[Hyperdrive SB3] Integration Status:")
    sendMessage("  • Spacebuild 3: " .. (isLoaded and "Loaded" or "Not Loaded"))
    sendMessage("  • Status: " .. status)

    if details then
        sendMessage("  • CAF Version: " .. (details.version or "unknown"))
        sendMessage("  • RD3 System: " .. (details.rd3 and "Available" or "Not Available"))
    end

    sendMessage("[Hyperdrive SB3] CAF Addons:")
    for name, addon in pairs(addons) do
        if addon.available then
            sendMessage("  • " .. name .. ": " .. (addon.status and "Active" or "Inactive"))
        else
            sendMessage("  • " .. name .. ": Not Found")
        end
    end

    -- Entity statistics
    local totalSB3Entities = 0
    for _, class in pairs(HYPERDRIVE.Spacebuild.EntityCategories) do
        for _, className in ipairs(class) do
            totalSB3Entities = totalSB3Entities + #ents.FindByClass(className)
        end
    end

    sendMessage("  • Total SB3 Entities: " .. totalSB3Entities)
end)

concommand.Add("hyperdrive_sb3_resources", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local engine = ply:GetEyeTrace().Entity
    if not IsValid(engine) or not string.find(engine:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive SB3] Please look at a hyperdrive engine")
        return
    end

    local destination = engine:GetPos() + Vector(1000, 0, 0) -- Test destination
    local canJump, issues = HYPERDRIVE.Spacebuild.Enhanced.CheckResourceAvailability(engine, destination)

    ply:ChatPrint("[Hyperdrive SB3] Resource Check:")
    ply:ChatPrint("  • Jump Possible: " .. (canJump and "YES" or "NO"))

    if #issues > 0 then
        ply:ChatPrint("  • Resource Issues:")
        for _, issue in ipairs(issues) do
            ply:ChatPrint("    - " .. issue)
        end
    else
        ply:ChatPrint("  • All resources available")
    end
end)

-- Integration with enhanced configuration system
if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.RegisterIntegration then
    HYPERDRIVE.EnhancedConfig.RegisterIntegration("Spacebuild3", {
        name = "Spacebuild 3",
        description = "Enhanced Spacebuild 3 CAF framework integration",
        version = "2.0.0",
        checkFunction = HYPERDRIVE.Spacebuild.Enhanced.IsSpacebuild3Loaded,
        validateFunction = HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration,
        configCategories = {
            "RequireLifeSupport",
            "RequirePower",
            "UseCAFFramework",
            "CheckResourceDistribution",
            "ValidateShipIntegrity"
        }
    })
else
    -- Fallback: register later when the function becomes available
    timer.Simple(0.1, function()
        if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.RegisterIntegration then
            HYPERDRIVE.EnhancedConfig.RegisterIntegration("Spacebuild3", {
                name = "Spacebuild 3",
                description = "Enhanced Spacebuild 3 CAF framework integration",
                version = "2.0.0",
                checkFunction = HYPERDRIVE.Spacebuild.Enhanced.IsSpacebuild3Loaded,
                validateFunction = HYPERDRIVE.Spacebuild.Enhanced.ValidateShipConfiguration,
                configCategories = {
                    "RequireLifeSupport",
                    "RequirePower",
                    "UseCAFFramework",
                    "CheckResourceDistribution",
                    "ValidateShipIntegrity"
                }
            })
        else
            print("[Hyperdrive] Warning: Could not register Spacebuild3 integration - EnhancedConfig not available")
        end
    end)
end

print("[Hyperdrive] Enhanced Spacebuild 3 integration loaded successfully")

-- Get all attached entities using SB3 ship core or constraint system
function HYPERDRIVE.Spacebuild.Enhanced.GetAttachedEntities(engine)
    local entities = {}

    -- Try to find ship core first
    local shipCore = HYPERDRIVE.Spacebuild.Enhanced.FindShipCore(engine)
    if IsValid(shipCore) then
        -- Use ship core's attached entities list if available
        if shipCore.GetAttachedEntities then
            local attached = shipCore:GetAttachedEntities()
            if attached then
                for _, ent in ipairs(attached) do
                    if IsValid(ent) then
                        table.insert(entities, ent)
                    end
                end
            end
        end

        -- Also get players in the ship if method exists
        if shipCore.GetPlayersInShip then
            local players = shipCore:GetPlayersInShip()
            if players then
                for _, ply in ipairs(players) do
                    if IsValid(ply) then
                        table.insert(entities, ply)
                    end
                end
            end
        end
    end

    -- Fallback: use constraint system for entity detection
    if #entities == 0 then
        local constrainedEnts = constraint.GetAllConstrainedEntities(engine)
        if constrainedEnts then
            for _, ent in ipairs(constrainedEnts) do
                if IsValid(ent) and ent ~= engine then
                    table.insert(entities, ent)
                end
            end
        end
    end

    -- Always include the engine itself
    table.insert(entities, engine)

    return entities
end

-- Check if entity is in space environment
function HYPERDRIVE.Spacebuild.IsInSpace(pos)
    if not CAF or not CAF.GetEnvironment then return false end

    local env = CAF.GetEnvironment(pos)
    return env and env.space
end

-- Check if entity has atmosphere
function HYPERDRIVE.Spacebuild.HasAtmosphere(pos)
    if not CAF or not CAF.GetEnvironment then return true end

    local env = CAF.GetEnvironment(pos)
    return env and env.atmosphere and env.atmosphere > 0
end

-- Get life support status for entity
function HYPERDRIVE.Spacebuild.GetLifeSupportStatus(ent)
    if not IsValid(ent) or not CAF then return false end

    local status = {
        hasLifeSupport = false,
        oxygen = 0,
        power = 0,
        coolant = 0,
        temperature = 20
    }

    -- Check for life support system
    if CAF.GetValue then
        status.oxygen = CAF.GetValue(ent, "oxygen") or 0
        status.power = CAF.GetValue(ent, "energy") or 0
        status.coolant = CAF.GetValue(ent, "coolant") or 0
        status.temperature = CAF.GetValue(ent, "temperature") or 20

        status.hasLifeSupport = status.oxygen > 0 and status.power > 0
    end

    return status
end

-- Consume resources for hyperdrive operation
function HYPERDRIVE.Spacebuild.ConsumeResources(ent, operation)
    if not IsValid(ent) or not CAF then return true end

    local config = HYPERDRIVE.Spacebuild.Config

    if operation == "charge" then
        -- Consume power and oxygen during charging
        if config.RequirePower then
            local powerConsumed = CAF.ConsumeResource(ent, "energy", config.PowerConsumption)
            if powerConsumed < config.PowerConsumption then
                return false, "Insufficient power"
            end
        end

        if config.RequireLifeSupport then
            local oxygenConsumed = CAF.ConsumeResource(ent, "oxygen", config.OxygenConsumption)
            if oxygenConsumed < config.OxygenConsumption then
                return false, "Insufficient oxygen"
            end
        end

    elseif operation == "jump" then
        -- Consume resources for jump
        if config.RequirePower then
            local powerConsumed = CAF.ConsumeResource(ent, "energy", config.JumpPowerCost)
            if powerConsumed < config.JumpPowerCost then
                return false, "Insufficient power for jump"
            end
        end

        if config.CoolantRequired then
            local coolantConsumed = CAF.ConsumeResource(ent, "coolant", config.CoolantConsumption)
            if coolantConsumed < config.CoolantConsumption then
                return false, "Insufficient coolant"
            end
        end
    end

    return true
end

-- Calculate energy cost modifier based on environment
function HYPERDRIVE.Spacebuild.GetEnvironmentModifier(startPos, endPos)
    local modifier = 1.0

    -- Check start position environment
    if HYPERDRIVE.Spacebuild.IsInSpace(startPos) then
        modifier = modifier * (1 - HYPERDRIVE.Spacebuild.Config.SpaceJumpBonus)
    elseif HYPERDRIVE.Spacebuild.HasAtmosphere(startPos) then
        modifier = modifier * HYPERDRIVE.Spacebuild.Config.AtmosphereJumpPenalty
    end

    -- Check destination environment
    if HYPERDRIVE.Spacebuild.IsInSpace(endPos) then
        modifier = modifier * 0.9 -- Slight bonus for jumping to space
    end

    return modifier
end

-- Check if hyperdrive can operate safely
function HYPERDRIVE.Spacebuild.CanOperate(ent)
    if not IsValid(ent) or not CAF then return true, "No Spacebuild integration" end

    local config = HYPERDRIVE.Spacebuild.Config
    local status = HYPERDRIVE.Spacebuild.GetLifeSupportStatus(ent)

    -- Check life support requirements
    if config.RequireLifeSupport and not status.hasLifeSupport then
        return false, "Life support required"
    end

    -- Check power requirements
    if config.RequirePower and status.power < config.PowerConsumption then
        return false, "Insufficient power"
    end

    -- Check oxygen requirements
    if config.RequireLifeSupport and status.oxygen < config.OxygenConsumption then
        return false, "Insufficient oxygen"
    end

    -- Check coolant requirements
    if config.CoolantRequired and status.coolant < config.CoolantConsumption then
        return false, "Insufficient coolant"
    end

    -- Check temperature limits
    if status.temperature > 100 then
        return false, "Engine overheating"
    elseif status.temperature < -50 then
        return false, "Engine too cold"
    end

    return true, "All systems nominal"
end

-- Enhanced energy calculation with Spacebuild factors
function HYPERDRIVE.Spacebuild.CalculateEnergyCost(startPos, endPos, baseDistance)
    local baseCost = HYPERDRIVE.CalculateEnergyCost(baseDistance)
    local envModifier = HYPERDRIVE.Spacebuild.GetEnvironmentModifier(startPos, endPos)

    return baseCost * envModifier
end

-- Create Spacebuild-compatible hyperdrive engine
function HYPERDRIVE.Spacebuild.CreateSpacebuildEngine(pos, ang, ply)
    local engine = ents.Create("hyperdrive_engine")
    if not IsValid(engine) then return nil end

    engine:SetPos(pos)
    engine:SetAngles(ang)
    engine:Spawn()
    engine:Activate()

    if IsValid(ply) then
        engine:SetCreator(ply)
    end

    -- Add Spacebuild resource nodes
    if CAF and CAF.AddResourceNode then
        -- Add power input
        CAF.AddResourceNode(engine, "energy", "input", {
            capacity = 1000,
            rate = 100
        })

        -- Add oxygen input
        CAF.AddResourceNode(engine, "oxygen", "input", {
            capacity = 500,
            rate = 50
        })

        -- Add coolant input
        CAF.AddResourceNode(engine, "coolant", "input", {
            capacity = 200,
            rate = 20
        })
    end

    return engine
end

-- Hook into hyperdrive engine initialization
hook.Add("OnEntityCreated", "HyperdriveSpacebuildInit", function(ent)
    if not IsValid(ent) or ent:GetClass() ~= "hyperdrive_engine" then return end

    timer.Simple(0.1, function()
        if IsValid(ent) and CAF then
            -- Add Spacebuild resource support
            HYPERDRIVE.Spacebuild.SetupResourceNodes(ent)
        end
    end)
end)

-- Setup resource nodes for existing engines
function HYPERDRIVE.Spacebuild.SetupResourceNodes(ent)
    if not IsValid(ent) or not CAF then return end

    -- Store original functions
    ent.OriginalStartJump = ent.OriginalStartJump or ent.StartJump
    ent.OriginalRechargeEnergy = ent.OriginalRechargeEnergy or ent.RechargeEnergy

    -- Override StartJump with Spacebuild checks
    ent.StartJump = function(self)
        local canOperate, reason = HYPERDRIVE.Spacebuild.CanOperate(self)
        if not canOperate then
            return false, reason
        end

        -- Consume resources for charging
        local success, message = HYPERDRIVE.Spacebuild.ConsumeResources(self, "charge")
        if not success then
            return false, message
        end

        return self:OriginalStartJump()
    end

    -- Override energy recharge with power consumption
    ent.RechargeEnergy = function(self)
        if HYPERDRIVE.Spacebuild.Config.RequirePower then
            local status = HYPERDRIVE.Spacebuild.GetLifeSupportStatus(self)
            if status.power < 10 then
                return -- No power, no recharge
            end
        end

        return self:OriginalRechargeEnergy()
    end
end

-- Console commands for Spacebuild integration
concommand.Add("hyperdrive_sb_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "hyperdrive_engine" then
        ply:ChatPrint("[Hyperdrive] Look at a hyperdrive engine")
        return
    end

    local status = HYPERDRIVE.Spacebuild.GetLifeSupportStatus(trace.Entity)
    local canOperate, reason = HYPERDRIVE.Spacebuild.CanOperate(trace.Entity)

    ply:ChatPrint("[Hyperdrive] Spacebuild Status:")
    ply:ChatPrint("  • Power: " .. math.floor(status.power))
    ply:ChatPrint("  • Oxygen: " .. math.floor(status.oxygen))
    ply:ChatPrint("  • Coolant: " .. math.floor(status.coolant))
    ply:ChatPrint("  • Temperature: " .. math.floor(status.temperature) .. "°C")
    ply:ChatPrint("  • Status: " .. reason)
    ply:ChatPrint("  • Environment: " .. (HYPERDRIVE.Spacebuild.IsInSpace(trace.Entity:GetPos()) and "Space" or "Atmosphere"))
end)

concommand.Add("hyperdrive_sb_config", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end

    ply:ChatPrint("[Hyperdrive] Spacebuild Configuration:")
    for key, value in pairs(HYPERDRIVE.Spacebuild.Config) do
        ply:ChatPrint("  • " .. key .. ": " .. tostring(value))
    end
end)

-- Network strings for Spacebuild integration
if SERVER then
    util.AddNetworkString("hyperdrive_sb_status")
    util.AddNetworkString("hyperdrive_sb_warning")
end

-- Enhanced SB3 ship movement with optimization
function HYPERDRIVE.Spacebuild.Enhanced.MoveShip(engine, destination)
    if not IsValid(engine) or not CAF then return false end
    if not GetSBConfig("Enabled", true) then return false end

    local entities = HYPERDRIVE.Spacebuild.Enhanced.GetAttachedEntities(engine)
    local enginePos = engine:GetPos()

    -- Use optimized movement method if available
    if GetSBConfig("OptimizedMovement", true) then
        -- Batch movement to reduce network overhead
        for _, ent in ipairs(entities) do
            if IsValid(ent) then
                local offset = ent:GetPos() - enginePos
                local newPos = destination + offset

                -- Use optimized method if available
                if ent.SetPosOptimized then
                    ent:SetPosOptimized(newPos)
                else
                    ent:SetPos(newPos)
                end

                -- Clear velocity to prevent physics issues
                if ent:GetPhysicsObject():IsValid() then
                    ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
                    ent:GetPhysicsObject():SetAngularVelocity(Vector(0, 0, 0))
                end
            end
        end
    else
        -- Standard movement
        for _, ent in ipairs(entities) do
            if IsValid(ent) then
                local offset = ent:GetPos() - enginePos
                ent:SetPos(destination + offset)
            end
        end
    end

    return true
end

-- Override gravity for SB3 players during hyperspace travel
function HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity(player, override)
    if not IsValid(player) or not player:IsPlayer() then return end
    if not GetSBConfig("OverrideGravity", true) then return end

    if override then
        -- Override SB3 gravity system
        player.HyperdriveGravityOverride = true
        local gravityValue = 0.5
        if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
            gravityValue = HYPERDRIVE.EnhancedConfig.Get("Gravity", "HyperspaceGravity", 0.5)
        end
        player:SetGravity(gravityValue)
    else
        -- Restore SB3 gravity system
        player.HyperdriveGravityOverride = nil
        player:SetGravity(1)
    end
end

print("[Hyperdrive] Spacebuild 3 integration loaded with enhanced features")
