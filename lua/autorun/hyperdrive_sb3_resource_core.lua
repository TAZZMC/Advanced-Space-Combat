-- Enhanced Hyperdrive System v5.1.0 - Spacebuild 3 Resource Core Integration
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED WITH STEAM WORKSHOP
-- Ship core as central resource storage and distribution hub using official SB3 RD system
-- Steam Workshop SB3 v3.2.0 Support: https://steamcommunity.com/sharedfiles/filedetails/?id=693838486

if CLIENT then return end

print("[Hyperdrive SB3] COMPLETE CODE UPDATE v5.1.0 - Ultimate SB3 Resource Core")
print("[Hyperdrive] Loading Spacebuild 3 Resource Core Integration with enhanced Steam Workshop support...")

-- Initialize resource core system
HYPERDRIVE.SB3Resources = HYPERDRIVE.SB3Resources or {}
HYPERDRIVE.SB3Resources.CoreStorage = HYPERDRIVE.SB3Resources.CoreStorage or {}
HYPERDRIVE.SB3Resources.Networks = HYPERDRIVE.SB3Resources.Networks or {}

-- Check for Spacebuild 3 RD system using enhanced detection
local function CheckSpacebuild3()
    -- Use the enhanced detection from main spacebuild integration if available
    if HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.IsSpacebuild3Loaded then
        local isLoaded, message, details = HYPERDRIVE.Spacebuild.Enhanced.IsSpacebuild3Loaded()
        if isLoaded then
            print("[Hyperdrive SB3] Enhanced detection: " .. message)
            return true
        end
    end

    -- Check for CAF (Custom Addon Framework) which manages Spacebuild 3
    if CAF then
        print("[Hyperdrive SB3] CAF detected, checking for Spacebuild addons...")

        -- Check if CAF has loaded Resource Distribution addon
        if CAF.GetAddonStatus then
            local rdStatus = CAF.GetAddonStatus("Resource Distribution")
            if rdStatus then
                print("[Hyperdrive SB3] CAF Resource Distribution addon detected")
                return true
            end
        end

        -- Check CAF addon registry
        if CAF.CAF3 and CAF.CAF3.Addons then
            for addonName, addon in pairs(CAF.CAF3.Addons) do
                local lowerName = string.lower(addonName)
                if string.find(lowerName, "resource") or
                   string.find(lowerName, "rd") or
                   string.find(lowerName, "spacebuild") then
                    if addon.GetStatus and addon.GetStatus() then
                        print("[Hyperdrive SB3] CAF addon detected: " .. addonName)
                        return true
                    end
                end
            end
        end
    end

    -- Check for RESOURCES API (from Spacebuild repository)
    if RESOURCES and RESOURCES.ToolRegister then
        print("[Hyperdrive SB3] RESOURCES API detected")
        return true
    end

    -- Fallback to traditional RD system check
    if RD and type(RD) == "table" then
        local hasRD = RD.AddResource ~= nil and RD.GetResourceAmount ~= nil
        if hasRD then
            print("[Hyperdrive SB3] Traditional RD system detected")
            return true
        end
    end

    -- Additional checks for Spacebuild entities
    local spacebuildEntities = {
        "storage_energy", "generator_energy_fusion", "base_air_exchanger",
        "base_climate_control", "storage_gas", "generator_gas"
    }

    for _, entClass in ipairs(spacebuildEntities) do
        -- Try multiple detection methods for entities
        local entityFound = false

        -- Method 1: Check scripted_ents (if available)
        if scripted_ents and scripted_ents.GetStored then
            local success, storedEnts = pcall(scripted_ents.GetStored)
            if success and storedEnts and storedEnts[entClass] then
                entityFound = true
            end
        end

        -- Method 2: Check if we can create the entity (alternative method)
        if not entityFound then
            local success, result = pcall(ents.Create, entClass)
            if success and IsValid(result) then
                result:Remove() -- Clean up test entity
                entityFound = true
            end
        end

        if entityFound then
            print("[Hyperdrive SB3] Spacebuild entities detected: " .. entClass)
            return true
        end
    end

    return false
end

-- Check for Spacebuild 3 LS2 system
local function CheckLS2()
    return LS and type(LS) == "table" and LS.AddResource ~= nil
end

-- Spacebuild 3 resource types (official RD system)
HYPERDRIVE.SB3Resources.ResourceTypes = {
    energy = {
        name = "Energy",
        unit = "kW",
        rdType = "energy",
        color = Color(255, 255, 0),
        defaultCapacity = 10000,
        transferRate = 1000,
        priority = 1
    },
    oxygen = {
        name = "Oxygen",
        unit = "L",
        rdType = "oxygen",
        color = Color(0, 255, 255),
        defaultCapacity = 5000,
        transferRate = 500,
        priority = 2
    },
    coolant = {
        name = "Coolant",
        unit = "L",
        rdType = "coolant",
        color = Color(0, 255, 0),
        defaultCapacity = 2000,
        transferRate = 200,
        priority = 3
    },
    fuel = {
        name = "Fuel",
        unit = "L",
        rdType = "fuel",
        color = Color(255, 100, 0),
        defaultCapacity = 3000,
        transferRate = 300,
        priority = 4
    },
    water = {
        name = "Water",
        unit = "L",
        rdType = "water",
        color = Color(0, 100, 255),
        defaultCapacity = 1500,
        transferRate = 150,
        priority = 5
    },
    nitrogen = {
        name = "Nitrogen",
        unit = "L",
        rdType = "nitrogen",
        color = Color(200, 200, 200),
        defaultCapacity = 1000,
        transferRate = 100,
        priority = 6
    }
}

-- Configuration for resource core system (uses enhanced config if available)
HYPERDRIVE.SB3Resources.Config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.SB3Resources or {
    EnableResourceCore = true,              -- Enable ship core resource system
    AutoDetectSB3 = true,                   -- Auto-detect Spacebuild 3 systems
    UseShipCoreAsHub = true,                -- Use ship core as central hub
    EnableResourceDistribution = true,      -- Enable automatic distribution
    DistributionInterval = 1.0,             -- Distribution update interval
    MaxTransferDistance = 2000,             -- Maximum transfer distance
    EnableResourceSharing = true,           -- Enable resource sharing between ships
    LogResourceTransfers = false,           -- Log resource transfers (debug)
    EnableEmergencyShutdown = true,         -- Enable emergency resource shutdown
    CriticalResourceThreshold = 10,         -- Critical resource threshold (%)
    EnableResourceAlerts = true,            -- Enable resource alerts
    AutoBalanceResources = true,            -- Auto-balance resources across ship

    -- Automatic resource provision for newly welded entities
    EnableAutoResourceProvision = true,     -- Enable automatic resource provision
    AutoProvisionOnWeld = true,             -- Provide resources when entities are welded
    AutoProvisionDelay = 0.5,               -- Delay before providing resources (seconds)
    EnableWeldDetection = true,             -- Enable weld detection system
    LogWeldDetection = false,               -- Log weld detection events
    NotifyPlayersOnProvision = true,        -- Notify players when resources are provided
    AutoProvisionPercentage = 50,           -- Percentage of entity capacity to provide initially
    MinAutoProvisionAmount = 25,            -- Minimum amount to provide per resource type
    MaxAutoProvisionAmount = 500,           -- Maximum amount to provide per resource type

    -- NEW: Ship Core Resource Generation Settings
    EnableResourceGeneration = true,        -- Ship cores generate unlimited resources
    GenerationRate = 1000,                  -- Base resources generated per second per type
    MaxStorageCapacity = 50000,             -- Base maximum storage capacity per resource type
    KeepStorageFull = true,                 -- Always keep storage at maximum capacity
    UnlimitedResources = true,              -- Ship cores provide unlimited resources
    GenerationInterval = 0.5,               -- How often to generate resources (seconds)

    -- NEW: Size-Based Scaling Settings
    EnableSizeBasedScaling = true,          -- Scale resources based on ship size
    BaseShipSize = 50,                      -- Base ship size (entity count) for scaling
    SizeScalingFactor = 1.5,                -- Multiplier per size tier for capacity
    MinSizeMultiplier = 0.5,                -- Minimum size multiplier
    MaxSizeMultiplier = 10.0,               -- Maximum size multiplier

    -- NEW: Inverse Regeneration Scaling (small ships = fast regen, large ships = slow regen)
    EnableInverseRegenScaling = true,       -- Enable inverse regeneration scaling
    BaseRegenerationRate = 1.0,             -- Base regeneration rate multiplier
    RegenScalingFactor = 0.8,               -- Regeneration reduction per size tier (smaller = faster regen)
    MinRegenMultiplier = 0.1,               -- Minimum regeneration multiplier (large ships)
    MaxRegenMultiplier = 3.0,               -- Maximum regeneration multiplier (small ships)

    -- NEW: Life Support Settings
    EnableLifeSupport = true,               -- Ship cores provide life support
    LifeSupportRange = 2000,                -- Range of life support effect
    OxygenGenerationRate = 100,             -- Oxygen generated per second
    AtmosphereRegenerationRate = 50,        -- Atmosphere regeneration rate
    TemperatureRegulation = true,           -- Regulate temperature
    TargetTemperature = 20,                 -- Target temperature in Celsius
    LifeSupportUpdateInterval = 1.0,        -- How often to update life support
}

-- Calculate ship size based on attached entities
function HYPERDRIVE.SB3Resources.CalculateShipSize(coreEntity)
    if not IsValid(coreEntity) then return HYPERDRIVE.SB3Resources.Config.BaseShipSize end

    local entityCount = HYPERDRIVE.SB3Resources.Config.BaseShipSize

    -- Try to get entities from ship core
    if coreEntity.GetEntities then
        local entities = coreEntity:GetEntities()
        if entities and #entities > 0 then
            entityCount = #entities
        end
    elseif coreEntity.GetShipEntities then
        local entities = coreEntity:GetShipEntities()
        if entities and #entities > 0 then
            entityCount = #entities
        end
    end

    return entityCount
end

-- Calculate size-based multiplier for resources (capacity)
function HYPERDRIVE.SB3Resources.CalculateSizeMultiplier(coreEntity)
    if not HYPERDRIVE.SB3Resources.Config.EnableSizeBasedScaling then
        return 1.0
    end

    local shipSize = HYPERDRIVE.SB3Resources.CalculateShipSize(coreEntity)
    local baseSize = HYPERDRIVE.SB3Resources.Config.BaseShipSize
    local scalingFactor = HYPERDRIVE.SB3Resources.Config.SizeScalingFactor

    -- Calculate size tier (every baseSize entities = 1 tier)
    local sizeTier = math.max(0, math.floor(shipSize / baseSize))

    -- Calculate multiplier with exponential scaling for capacity
    local multiplier = math.pow(scalingFactor, sizeTier)

    -- Clamp to min/max values
    multiplier = math.max(HYPERDRIVE.SB3Resources.Config.MinSizeMultiplier, multiplier)
    multiplier = math.min(HYPERDRIVE.SB3Resources.Config.MaxSizeMultiplier, multiplier)

    return multiplier
end

-- Calculate regeneration multiplier (inverse scaling - smaller ships regenerate faster)
function HYPERDRIVE.SB3Resources.CalculateRegenMultiplier(coreEntity)
    if not HYPERDRIVE.SB3Resources.Config.EnableInverseRegenScaling then
        return 1.0
    end

    local shipSize = HYPERDRIVE.SB3Resources.CalculateShipSize(coreEntity)
    local baseSize = HYPERDRIVE.SB3Resources.Config.BaseShipSize
    local regenScalingFactor = HYPERDRIVE.SB3Resources.Config.RegenScalingFactor

    -- Calculate size tier
    local sizeTier = math.max(0, math.floor(shipSize / baseSize))

    -- Calculate inverse regeneration multiplier (smaller ships = higher multiplier)
    -- For ships smaller than base size, give bonus regeneration
    if shipSize < baseSize then
        local smallShipBonus = (baseSize - shipSize) / baseSize
        local multiplier = HYPERDRIVE.SB3Resources.Config.BaseRegenerationRate + (smallShipBonus * 2.0)
        return math.min(HYPERDRIVE.SB3Resources.Config.MaxRegenMultiplier, multiplier)
    else
        -- For larger ships, reduce regeneration rate
        local multiplier = HYPERDRIVE.SB3Resources.Config.BaseRegenerationRate * math.pow(regenScalingFactor, sizeTier)
        return math.max(HYPERDRIVE.SB3Resources.Config.MinRegenMultiplier, multiplier)
    end
end

-- Initialize ship core resource storage with Spacebuild 3 RD integration
function HYPERDRIVE.SB3Resources.InitializeCoreStorage(coreEntity)
    if not IsValid(coreEntity) or coreEntity:GetClass() ~= "ship_core" then return false end

    local coreId = coreEntity:EntIndex()
    if HYPERDRIVE.SB3Resources.CoreStorage[coreId] then return true end

    -- Check if Spacebuild 3 is available
    local hasRD = CheckSpacebuild3()
    local hasLS2 = CheckLS2()

    -- Additional runtime verification of global variables
    if hasRD and not RD then
        print("[Hyperdrive SB3] Warning: RD system detected but RD global is nil - disabling RD integration")
        hasRD = false
    end

    if hasLS2 and not LS then
        print("[Hyperdrive SB3] Warning: LS2 system detected but LS global is nil - disabling LS2 integration")
        hasLS2 = false
    end

    if not hasRD and not hasLS2 then
        print("[Hyperdrive SB3] Spacebuild 3 not detected, resource system disabled")
        return false
    end

    -- Calculate size-based multipliers
    local sizeMultiplier = HYPERDRIVE.SB3Resources.CalculateSizeMultiplier(coreEntity)
    local regenMultiplier = HYPERDRIVE.SB3Resources.CalculateRegenMultiplier(coreEntity)
    local shipSize = HYPERDRIVE.SB3Resources.CalculateShipSize(coreEntity)

    -- Initialize storage for all resource types
    HYPERDRIVE.SB3Resources.CoreStorage[coreId] = {
        core = coreEntity,
        resources = {},
        capacity = {},
        transferRates = {},
        connections = {},
        lastUpdate = CurTime(),
        lastGenerationUpdate = CurTime(),
        lastLifeSupportUpdate = CurTime(),
        emergencyMode = false,
        alerts = {},
        rdEnabled = hasRD,
        ls2Enabled = hasLS2,
        resourceGenerator = true,  -- Mark as resource generator
        unlimitedResources = HYPERDRIVE.SB3Resources.Config.UnlimitedResources,
        shipSize = shipSize,
        sizeMultiplier = sizeMultiplier,
        regenMultiplier = regenMultiplier,
        lifeSupportActive = HYPERDRIVE.SB3Resources.Config.EnableLifeSupport
    }

    local storage = HYPERDRIVE.SB3Resources.CoreStorage[coreId]

    -- Setup resource storage with unlimited generation and size scaling
    for resourceType, config in pairs(HYPERDRIVE.SB3Resources.ResourceTypes) do
        -- Calculate size-scaled capacity
        local baseCapacity = HYPERDRIVE.SB3Resources.Config.EnableResourceGeneration and
                            HYPERDRIVE.SB3Resources.Config.MaxStorageCapacity or
                            config.defaultCapacity
        local capacity = math.floor(baseCapacity * sizeMultiplier)

        -- Calculate size-scaled transfer rate
        local transferRate = math.floor(config.transferRate * sizeMultiplier)

        -- Start with full resources if generation is enabled
        local initialAmount = HYPERDRIVE.SB3Resources.Config.EnableResourceGeneration and capacity or 0

        storage.resources[resourceType] = initialAmount
        storage.capacity[resourceType] = capacity
        storage.transferRates[resourceType] = transferRate

        -- Register with Spacebuild 3 RD system
        if hasRD and RD and RD.AddResource then
            RD.AddResource(coreEntity, config.rdType, initialAmount)
            if RD.SetResourceCapacity then
                RD.SetResourceCapacity(coreEntity, config.rdType, capacity)
            end
        end

        -- Register with CAF system if available
        if CAF and CAF.RegisterDevice then
            CAF.RegisterDevice(coreEntity, "resource_storage", config.rdType, capacity, initialAmount)
        end

        -- Register with RESOURCES API if available
        if RESOURCES and RESOURCES.ToolRegisterDevice then
            coreEntity:Register("Storage")
            if coreEntity.ResourcesSetDeviceCapacity then
                coreEntity:ResourcesSetDeviceCapacity(config.rdType, capacity, initialAmount)
            end
        end

        -- Register with LS2 system if available
        if hasLS2 and LS and LS.AddResource then
            LS.AddResource(coreEntity, config.rdType, initialAmount)
        end
    end

    -- Set entity as resource storage node
    if hasRD and RD then
        coreEntity.RD = coreEntity.RD or {}
        coreEntity.RD.IsStorage = true
        coreEntity.RD.IsGenerator = HYPERDRIVE.SB3Resources.Config.EnableResourceGeneration
        coreEntity.RD.StorageCapacity = {}
        coreEntity.RD.StorageAmount = {}

        for resourceType, config in pairs(HYPERDRIVE.SB3Resources.ResourceTypes) do
            local capacity = storage.capacity[resourceType]
            local amount = storage.resources[resourceType]
            coreEntity.RD.StorageCapacity[config.rdType] = capacity
            coreEntity.RD.StorageAmount[config.rdType] = amount
        end
    end

    local resourceMode = storage.unlimitedResources and "UNLIMITED" or "LIMITED"
    local sizeInfo = string.format("Size: %d entities (%.1fx capacity, %.1fx regen)", shipSize, sizeMultiplier, regenMultiplier)
    local lifeSupportInfo = storage.lifeSupportActive and "Life Support: ACTIVE" or "Life Support: DISABLED"
    print("[Hyperdrive SB3] Initialized resource storage for ship core " .. coreId .. " (RD: " .. tostring(hasRD) .. ", LS2: " .. tostring(hasLS2) .. ", Mode: " .. resourceMode .. ", " .. sizeInfo .. ", " .. lifeSupportInfo .. ")")
    return true
end

-- Get resource storage for ship core
function HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not IsValid(coreEntity) then return nil end

    local coreId = coreEntity:EntIndex()
    return HYPERDRIVE.SB3Resources.CoreStorage[coreId]
end

-- Add resources to ship core using Spacebuild 3 RD system
function HYPERDRIVE.SB3Resources.AddResource(coreEntity, resourceType, amount)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage or not storage.resources[resourceType] then return false, "Invalid storage or resource type" end

    local config = HYPERDRIVE.SB3Resources.ResourceTypes[resourceType]
    if not config then return false, "Unknown resource type" end

    local currentAmount = storage.resources[resourceType]
    local capacity = storage.capacity[resourceType]
    local maxAdd = capacity - currentAmount
    local actualAdd = math.min(amount, maxAdd)

    if actualAdd <= 0 then return false, "Storage full" end

    -- Update internal storage
    storage.resources[resourceType] = currentAmount + actualAdd

    -- Update Spacebuild 3 RD system
    if storage.rdEnabled and RD and RD.SetResourceAmount then
        RD.SetResourceAmount(coreEntity, config.rdType, storage.resources[resourceType])
        if coreEntity.RD and coreEntity.RD.StorageAmount then
            coreEntity.RD.StorageAmount[config.rdType] = storage.resources[resourceType]
        end
    end

    -- Update CAF system if available
    if CAF and CAF.SetResourceAmount then
        CAF.SetResourceAmount(coreEntity, config.rdType, storage.resources[resourceType])
    end

    -- Update RESOURCES API if available
    if RESOURCES and coreEntity.ResourcesSetDeviceCapacity then
        coreEntity:ResourcesSetDeviceCapacity(config.rdType, storage.capacity[resourceType], storage.resources[resourceType])
    end

    -- Update LS2 system if available
    if storage.ls2Enabled and LS and LS.SetResourceAmount then
        LS.SetResourceAmount(coreEntity, config.rdType, storage.resources[resourceType])
    end

    -- Log transfer if enabled
    if HYPERDRIVE.SB3Resources.Config.LogResourceTransfers then
        print("[Hyperdrive SB3] Added " .. actualAdd .. " " .. resourceType .. " to core " .. coreEntity:EntIndex())
    end

    return true, actualAdd
end

-- Remove resources from ship core using Spacebuild 3 RD system
function HYPERDRIVE.SB3Resources.RemoveResource(coreEntity, resourceType, amount)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage or not storage.resources[resourceType] then return false, "Invalid storage or resource type" end

    local config = HYPERDRIVE.SB3Resources.ResourceTypes[resourceType]
    if not config then return false, "Unknown resource type" end

    -- If unlimited resources are enabled, always provide the requested amount
    if storage.unlimitedResources and HYPERDRIVE.SB3Resources.Config.EnableResourceGeneration then
        -- Don't actually remove resources, just return success
        local actualRemove = amount

        -- Log transfer if enabled
        if HYPERDRIVE.SB3Resources.Config.LogResourceTransfers then
            print("[Hyperdrive SB3] Provided " .. actualRemove .. " " .. resourceType .. " from unlimited core " .. coreEntity:EntIndex())
        end

        return true, actualRemove
    end

    local currentAmount = storage.resources[resourceType]
    local actualRemove = math.min(amount, currentAmount)

    if actualRemove <= 0 then return false, "Insufficient resources" end

    -- Update internal storage
    storage.resources[resourceType] = currentAmount - actualRemove

    -- Update Spacebuild 3 RD system
    if storage.rdEnabled and RD and RD.SetResourceAmount then
        RD.SetResourceAmount(coreEntity, config.rdType, storage.resources[resourceType])
        if coreEntity.RD and coreEntity.RD.StorageAmount then
            coreEntity.RD.StorageAmount[config.rdType] = storage.resources[resourceType]
        end
    end

    -- Update CAF system if available
    if CAF and CAF.SetResourceAmount then
        CAF.SetResourceAmount(coreEntity, config.rdType, storage.resources[resourceType])
    end

    -- Update RESOURCES API if available
    if RESOURCES and coreEntity.ResourcesSetDeviceCapacity then
        coreEntity:ResourcesSetDeviceCapacity(config.rdType, storage.capacity[resourceType], storage.resources[resourceType])
    end

    -- Update LS2 system if available
    if storage.ls2Enabled and LS and LS.SetResourceAmount then
        LS.SetResourceAmount(coreEntity, config.rdType, storage.resources[resourceType])
    end

    -- Check for critical levels
    local percentage = (storage.resources[resourceType] / storage.capacity[resourceType]) * 100
    if percentage <= HYPERDRIVE.SB3Resources.Config.CriticalResourceThreshold then
        HYPERDRIVE.SB3Resources.TriggerResourceAlert(coreEntity, resourceType, "critical")
    end

    -- Log transfer if enabled
    if HYPERDRIVE.SB3Resources.Config.LogResourceTransfers then
        print("[Hyperdrive SB3] Removed " .. actualRemove .. " " .. resourceType .. " from core " .. coreEntity:EntIndex())
    end

    return true, actualRemove
end

-- Consume resources (wrapper for RemoveResource for compatibility)
function HYPERDRIVE.SB3Resources.ConsumeResource(coreEntity, resourceType, amount)
    return HYPERDRIVE.SB3Resources.RemoveResource(coreEntity, resourceType, amount)
end

-- Get resource amount
function HYPERDRIVE.SB3Resources.GetResourceAmount(coreEntity, resourceType)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage or not storage.resources[resourceType] then return 0 end

    return storage.resources[resourceType]
end

-- Get resource percentage
function HYPERDRIVE.SB3Resources.GetResourcePercentage(coreEntity, resourceType)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage or not storage.resources[resourceType] then return 0 end

    return (storage.resources[resourceType] / storage.capacity[resourceType]) * 100
end

-- Set resource capacity
function HYPERDRIVE.SB3Resources.SetResourceCapacity(coreEntity, resourceType, capacity)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return false end

    storage.capacity[resourceType] = capacity

    -- Adjust current amount if over capacity
    if storage.resources[resourceType] > capacity then
        storage.resources[resourceType] = capacity
    end

    -- Update CAF system if available
    if CAF and CAF.SetResourceCapacity then
        CAF.SetResourceCapacity(coreEntity, resourceType, capacity)
    end

    return true
end

-- Distribute resources to ship entities
function HYPERDRIVE.SB3Resources.DistributeResources(coreEntity)
    if not HYPERDRIVE.SB3Resources.Config.EnableResourceDistribution then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    -- Get ship entities
    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if not ship then return end

    local entities = ship:GetEntities()
    if not entities or #entities == 0 then return end

    -- Distribute resources to entities that need them
    for _, entity in ipairs(entities) do
        if IsValid(entity) and entity ~= coreEntity then
            HYPERDRIVE.SB3Resources.TransferToEntity(coreEntity, entity)
        end
    end
end

-- Transfer resources to specific entity using Spacebuild 3 RD system
function HYPERDRIVE.SB3Resources.TransferToEntity(coreEntity, targetEntity)
    if not IsValid(coreEntity) or not IsValid(targetEntity) then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    -- Check if target entity needs resources (Spacebuild 3 RD system)
    local needs = {}

    if storage.rdEnabled and RD and RD.GetResourceNeeds then
        needs = RD.GetResourceNeeds(targetEntity) or {}
    elseif storage.rdEnabled and targetEntity.RD then
        -- Manual check for RD resource needs
        for rdType, _ in pairs(targetEntity.RD) do
            if targetEntity.RD[rdType] and targetEntity.RD[rdType].capacity then
                local current = targetEntity.RD[rdType].amount or 0
                local capacity = targetEntity.RD[rdType].capacity or 0
                if current < capacity then
                    needs[rdType] = capacity - current
                end
            end
        end
    end

    if not needs or table.Count(needs) == 0 then return end

    -- Transfer resources based on priority
    local resourcePriority = {}
    for rdType, needed in pairs(needs) do
        -- Find our resource type that matches this RD type
        for resourceType, config in pairs(HYPERDRIVE.SB3Resources.ResourceTypes) do
            if config.rdType == rdType then
                table.insert(resourcePriority, {
                    type = resourceType,
                    rdType = rdType,
                    priority = config.priority,
                    need = needed
                })
                break
            end
        end
    end

    -- Sort by priority
    table.sort(resourcePriority, function(a, b) return a.priority < b.priority end)

    -- Transfer resources
    for _, resourceInfo in ipairs(resourcePriority) do
        local resourceType = resourceInfo.type
        local rdType = resourceInfo.rdType
        local needed = resourceInfo.need
        local available = storage.resources[resourceType]
        local transferRate = storage.transferRates[resourceType]

        if needed > 0 then
            -- For unlimited resources, always provide what's needed
            local transferAmount = storage.unlimitedResources and needed or math.min(needed, available, transferRate)

            -- Only check availability for limited resources
            if storage.unlimitedResources or available > 0 then
                local success, actualTransfer = HYPERDRIVE.SB3Resources.RemoveResource(coreEntity, resourceType, transferAmount)
                if success then
                    -- Add to target entity using RD system
                    if storage.rdEnabled and RD and RD.AddResource then
                        RD.AddResource(targetEntity, rdType, actualTransfer)
                    elseif targetEntity.RD and targetEntity.RD[rdType] then
                        targetEntity.RD[rdType].amount = (targetEntity.RD[rdType].amount or 0) + actualTransfer
                    end
                end
            end
        end
    end
end

-- Collect resources from ship entities
function HYPERDRIVE.SB3Resources.CollectResources(coreEntity)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    -- Get ship entities
    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if not ship then return end

    local entities = ship:GetEntities()
    if not entities or #entities == 0 then return end

    -- Collect excess resources from entities
    for _, entity in ipairs(entities) do
        if IsValid(entity) and entity ~= coreEntity then
            HYPERDRIVE.SB3Resources.CollectFromEntity(coreEntity, entity)
        end
    end
end

-- Collect resources from specific entity using Spacebuild 3 RD system
function HYPERDRIVE.SB3Resources.CollectFromEntity(coreEntity, sourceEntity)
    if not IsValid(coreEntity) or not IsValid(sourceEntity) then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    -- Get surplus resources from Spacebuild 3 RD system
    local surplus = {}

    if storage.rdEnabled and RD and RD.GetResourceSurplus then
        surplus = RD.GetResourceSurplus(sourceEntity) or {}
    elseif storage.rdEnabled and sourceEntity.RD then
        -- Manual check for RD resource surplus
        for rdType, data in pairs(sourceEntity.RD) do
            if data and data.amount and data.capacity then
                local current = data.amount or 0
                local capacity = data.capacity or 0
                -- Consider surplus if over 90% capacity
                if current > (capacity * 0.9) then
                    surplus[rdType] = current - (capacity * 0.8) -- Leave 80% in source
                end
            end
        end
    end

    if not surplus or table.Count(surplus) == 0 then return end

    -- Collect surplus resources
    for rdType, amount in pairs(surplus) do
        if amount > 0 then
            -- Find our resource type that matches this RD type
            for resourceType, config in pairs(HYPERDRIVE.SB3Resources.ResourceTypes) do
                if config.rdType == rdType then
                    -- Remove from source entity
                    local actualCollect = 0
                    if storage.rdEnabled and RD and RD.RemoveResource then
                        local success, removed = RD.RemoveResource(sourceEntity, rdType, amount)
                        if success then
                            actualCollect = removed
                        end
                    elseif sourceEntity.RD and sourceEntity.RD[rdType] then
                        actualCollect = math.min(amount, sourceEntity.RD[rdType].amount or 0)
                        sourceEntity.RD[rdType].amount = (sourceEntity.RD[rdType].amount or 0) - actualCollect
                    end

                    -- Add to core storage
                    if actualCollect > 0 then
                        HYPERDRIVE.SB3Resources.AddResource(coreEntity, resourceType, actualCollect)
                    end
                    break
                end
            end
        end
    end
end

-- Trigger resource alert
function HYPERDRIVE.SB3Resources.TriggerResourceAlert(coreEntity, resourceType, alertType)
    if not HYPERDRIVE.SB3Resources.Config.EnableResourceAlerts then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    -- Add alert to storage
    table.insert(storage.alerts, {
        resourceType = resourceType,
        alertType = alertType,
        timestamp = CurTime(),
        message = "Resource " .. resourceType .. " is " .. alertType
    })

    -- Notify players on ship
    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if ship then
        local players = ship:GetPlayers()
        for _, player in ipairs(players) do
            if IsValid(player) then
                local resourceConfig = HYPERDRIVE.SB3Resources.ResourceTypes[resourceType]
                local message = "[Ship Core] " .. resourceConfig.name .. " is " .. alertType .. "!"

                if HYPERDRIVE.Interface then
                    HYPERDRIVE.Interface.SendFeedback(player, message, alertType == "critical" and "error" or "warning")
                else
                    player:ChatPrint(message)
                end
            end
        end
    end
end

-- Check for newly welded entities and provide them with resources
function HYPERDRIVE.SB3Resources.CheckForNewEntities(coreEntity)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    -- Get current ship entities
    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
    if not ship then return end

    local currentEntities = ship:GetEntities()
    if not currentEntities then return end

    -- Initialize tracked entities if not exists
    if not storage.trackedEntities then
        storage.trackedEntities = {}
        -- Add all current entities to tracked list
        for _, entity in ipairs(currentEntities) do
            if IsValid(entity) then
                storage.trackedEntities[entity:EntIndex()] = {
                    entity = entity,
                    addedTime = CurTime(),
                    resourcesProvided = false
                }
            end
        end
        return
    end

    -- Check for new entities
    local newEntities = {}
    for _, entity in ipairs(currentEntities) do
        if IsValid(entity) then
            local entIndex = entity:EntIndex()
            if not storage.trackedEntities[entIndex] then
                -- This is a new entity!
                storage.trackedEntities[entIndex] = {
                    entity = entity,
                    addedTime = CurTime(),
                    resourcesProvided = false
                }
                table.insert(newEntities, entity)
            end
        end
    end

    -- Provide resources to new entities
    for _, entity in ipairs(newEntities) do
        HYPERDRIVE.SB3Resources.ProvideInitialResources(coreEntity, entity)
    end

    -- Clean up tracked entities that no longer exist
    for entIndex, trackedData in pairs(storage.trackedEntities) do
        if not IsValid(trackedData.entity) then
            storage.trackedEntities[entIndex] = nil
        end
    end
end

-- Provide initial resources to a newly welded entity
function HYPERDRIVE.SB3Resources.ProvideInitialResources(coreEntity, targetEntity)
    if not IsValid(coreEntity) or not IsValid(targetEntity) then return end

    -- Check if auto resource provision is enabled
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.SB3Resources or HYPERDRIVE.SB3Resources.Config
    if not config.EnableAutoResourceProvision then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    -- Check if entity needs resources (Spacebuild 3 entities)
    local entityClass = targetEntity:GetClass()
    local needsResources = HYPERDRIVE.SB3Resources.EntityNeedsResources(targetEntity)

    if not needsResources then return end

    -- Get entity resource requirements
    local requirements = HYPERDRIVE.SB3Resources.GetEntityResourceRequirements(targetEntity)
    if not requirements then return end

    -- Apply configuration limits to requirements
    local provisionPercentage = config.AutoProvisionPercentage / 100
    local minAmount = config.MinAutoProvisionAmount
    local maxAmount = config.MaxAutoProvisionAmount

    -- Provide initial resources based on entity type and configuration
    local provided = {}
    for resourceType, baseAmount in pairs(requirements) do
        -- Calculate actual amount to provide
        local amount = math.floor(baseAmount * provisionPercentage)
        amount = math.max(amount, minAmount)
        amount = math.min(amount, maxAmount)

        if storage.resources[resourceType] and storage.resources[resourceType] >= amount then
            local success, actualAmount = HYPERDRIVE.SB3Resources.RemoveResource(coreEntity, resourceType, amount)
            if success then
                -- Add resources to the entity
                local addSuccess = HYPERDRIVE.SB3Resources.AddResourceToEntity(targetEntity, resourceType, actualAmount)
                if addSuccess then
                    provided[resourceType] = actualAmount
                end
            end
        end
    end

    -- Mark as resources provided
    local entIndex = targetEntity:EntIndex()
    if storage.trackedEntities[entIndex] then
        storage.trackedEntities[entIndex].resourcesProvided = true
        storage.trackedEntities[entIndex].providedResources = provided
    end

    -- Log the resource provision
    if config.LogResourceTransfers or config.LogWeldDetection then
        local providedList = {}
        for resourceType, amount in pairs(provided) do
            table.insert(providedList, amount .. " " .. resourceType)
        end
        if #providedList > 0 then
            print("[Hyperdrive SB3] Provided initial resources to " .. entityClass .. ": " .. table.concat(providedList, ", "))
        else
            print("[Hyperdrive SB3] No resources provided to " .. entityClass .. " (insufficient ship core resources)")
        end
    end

    -- Notify players on ship
    if config.NotifyPlayersOnProvision then
        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(coreEntity)
        if ship then
            local players = ship:GetPlayers()
            for _, player in ipairs(players) do
                if IsValid(player) then
                    local providedCount = table.Count(provided)
                    local message
                    if providedCount > 0 then
                        message = "[Ship Core] Provided " .. providedCount .. " resource types to new " .. entityClass
                    else
                        message = "[Ship Core] New " .. entityClass .. " detected but insufficient resources to provide"
                    end

                    if HYPERDRIVE.Interface then
                        HYPERDRIVE.Interface.SendFeedback(player, message, providedCount > 0 and "success" or "warning")
                    else
                        player:ChatPrint(message)
                    end
                end
            end
        end
    end
end

-- Check if entity needs resources (Spacebuild 3 detection)
function HYPERDRIVE.SB3Resources.EntityNeedsResources(entity)
    if not IsValid(entity) then return false end

    local entityClass = entity:GetClass()

    -- Common Spacebuild 3 entities that need resources
    local sb3Entities = {
        -- Life Support
        "sb_ls2_generator", "sb_ls2_lifesupport", "sb_ls2_storagecontainer",
        "sb_ls2_oxygenator", "sb_ls2_recycler", "sb_ls2_gravitygenerator",

        -- Resource Distribution
        "sb_rd3_generator", "sb_rd3_processor", "sb_rd3_storage",
        "sb_rd3_pump", "sb_rd3_valve", "sb_rd3_pipe",

        -- CAF (Common Addon Framework) entities
        "caf_ls2_generator", "caf_ls2_lifesupport", "caf_ls2_storage",
        "caf_rd3_generator", "caf_rd3_processor", "caf_rd3_storage",

        -- Generic resource entities
        "generator", "lifesupport", "storage", "processor", "pump"
    }

    -- Check if entity class matches known resource entities
    for _, className in ipairs(sb3Entities) do
        if string.find(entityClass, className) then
            return true
        end
    end

    -- Check if entity has resource-related functions (CAF/RD/LS2 detection)
    if entity.GetResourceAmount or entity.SetResourceAmount or
       entity.GetEnergy or entity.SetEnergy or
       entity.GetOxygen or entity.SetOxygen or
       entity.GetResource or entity.SetResource then
        return true
    end

    -- Check for CAF framework
    if CAF and CAF.GetEntityResourceData and CAF.GetEntityResourceData(entity) then
        return true
    end

    return false
end

-- Get entity resource requirements based on type
function HYPERDRIVE.SB3Resources.GetEntityResourceRequirements(entity)
    if not IsValid(entity) then return nil end

    local entityClass = entity:GetClass()
    local requirements = {}

    -- Default requirements based on entity type
    if string.find(entityClass, "generator") then
        requirements.fuel = 100
        requirements.coolant = 50
    elseif string.find(entityClass, "lifesupport") or string.find(entityClass, "ls2") then
        requirements.energy = 200
        requirements.oxygen = 100
        requirements.water = 50
    elseif string.find(entityClass, "storage") then
        -- Storage entities get a small amount of each resource
        requirements.energy = 50
        requirements.oxygen = 25
        requirements.coolant = 25
        requirements.fuel = 25
        requirements.water = 25
    elseif string.find(entityClass, "processor") or string.find(entityClass, "rd3") then
        requirements.energy = 150
        requirements.coolant = 75
    elseif string.find(entityClass, "pump") or string.find(entityClass, "valve") then
        requirements.energy = 100
    else
        -- Generic resource entity
        requirements.energy = 100
        requirements.oxygen = 50
    end

    -- Check entity's actual capacity if available
    if entity.GetMaxEnergy then
        local maxEnergy = entity:GetMaxEnergy()
        if maxEnergy and maxEnergy > 0 then
            requirements.energy = math.min(maxEnergy * 0.5, requirements.energy or 100)
        end
    end

    if entity.GetMaxOxygen then
        local maxOxygen = entity:GetMaxOxygen()
        if maxOxygen and maxOxygen > 0 then
            requirements.oxygen = math.min(maxOxygen * 0.5, requirements.oxygen or 50)
        end
    end

    return requirements
end

-- Add resources to a specific entity
function HYPERDRIVE.SB3Resources.AddResourceToEntity(entity, resourceType, amount)
    if not IsValid(entity) or amount <= 0 then return false end

    -- Try CAF framework first
    if CAF and CAF.AddResource then
        local success = CAF.AddResource(entity, resourceType, amount)
        if success then return true end
    end

    -- Try direct entity methods
    if resourceType == "energy" then
        if entity.AddEnergy then
            entity:AddEnergy(amount)
            return true
        elseif entity.SetEnergy and entity.GetEnergy then
            local current = entity:GetEnergy() or 0
            entity:SetEnergy(current + amount)
            return true
        end
    elseif resourceType == "oxygen" then
        if entity.AddOxygen then
            entity:AddOxygen(amount)
            return true
        elseif entity.SetOxygen and entity.GetOxygen then
            local current = entity:GetOxygen() or 0
            entity:SetOxygen(current + amount)
            return true
        end
    end

    -- Try generic resource methods
    if entity.AddResource then
        entity:AddResource(resourceType, amount)
        return true
    elseif entity.SetResource and entity.GetResource then
        local current = entity:GetResource(resourceType) or 0
        entity:SetResource(resourceType, current + amount)
        return true
    end

    return false
end

-- Auto-balance resources across ship
function HYPERDRIVE.SB3Resources.AutoBalanceResources(coreEntity)
    if not HYPERDRIVE.SB3Resources.Config.AutoBalanceResources then return end

    -- First collect excess resources
    HYPERDRIVE.SB3Resources.CollectResources(coreEntity)

    -- Then distribute based on needs
    HYPERDRIVE.SB3Resources.DistributeResources(coreEntity)
end

-- Provide life support to players near ship core
function HYPERDRIVE.SB3Resources.ProvideLifeSupport(coreEntity)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage or not storage.lifeSupportActive then return end

    if not HYPERDRIVE.SB3Resources.Config.EnableLifeSupport then return end

    local currentTime = CurTime()
    if currentTime - storage.lastLifeSupportUpdate < HYPERDRIVE.SB3Resources.Config.LifeSupportUpdateInterval then return end

    storage.lastLifeSupportUpdate = currentTime

    local corePos = coreEntity:GetPos()
    local lifeSupportRange = HYPERDRIVE.SB3Resources.Config.LifeSupportRange * storage.sizeMultiplier

    -- Find all players within life support range
    local playersInRange = {}
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local distance = corePos:Distance(ply:GetPos())
            if distance <= lifeSupportRange then
                table.insert(playersInRange, ply)
            end
        end
    end

    -- Provide life support to players
    for _, ply in ipairs(playersInRange) do
        HYPERDRIVE.SB3Resources.ApplyLifeSupportToPlayer(coreEntity, ply, storage)
    end

    -- Update life support status
    storage.playersSupported = #playersInRange
end

-- Apply life support effects to a specific player
function HYPERDRIVE.SB3Resources.ApplyLifeSupportToPlayer(coreEntity, player, storage)
    if not IsValid(player) or not player:IsPlayer() then return end

    -- Heal player slowly if they have oxygen
    if player:Health() < player:GetMaxHealth() and player:Health() > 0 then
        local healAmount = math.min(2, player:GetMaxHealth() - player:Health())
        player:SetHealth(player:Health() + healAmount)
    end

    -- Remove drowning effects
    if player:WaterLevel() >= 3 then
        player:SetAir(player:GetMaxAir())
    end

    -- Provide oxygen through Spacebuild systems if available
    if CAF and CAF.AddResource then
        local oxygenAmount = HYPERDRIVE.SB3Resources.Config.OxygenGenerationRate * storage.sizeMultiplier * HYPERDRIVE.SB3Resources.Config.LifeSupportUpdateInterval
        CAF.AddResource(player, "oxygen", oxygenAmount)
    end

    -- Temperature regulation
    if HYPERDRIVE.SB3Resources.Config.TemperatureRegulation then
        if CAF and CAF.SetValue then
            CAF.SetValue(player, "temperature", HYPERDRIVE.SB3Resources.Config.TargetTemperature)
        end
    end

    -- Set player life support status
    player:SetNWBool("HasLifeSupport", true)
    player:SetNWFloat("LifeSupportRange", storage.sizeMultiplier)
    player:SetNWEntity("LifeSupportCore", coreEntity)
end

-- Generate resources for ship core (unlimited resources)
function HYPERDRIVE.SB3Resources.GenerateResources(coreEntity)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage or not storage.unlimitedResources then return end

    if not HYPERDRIVE.SB3Resources.Config.EnableResourceGeneration then return end

    local currentTime = CurTime()
    if currentTime - storage.lastGenerationUpdate < HYPERDRIVE.SB3Resources.Config.GenerationInterval then return end

    storage.lastGenerationUpdate = currentTime

    -- Keep all resources at maximum capacity
    for resourceType, config in pairs(HYPERDRIVE.SB3Resources.ResourceTypes) do
        if storage.resources[resourceType] then
            local capacity = storage.capacity[resourceType]
            local currentAmount = storage.resources[resourceType]

            if HYPERDRIVE.SB3Resources.Config.KeepStorageFull then
                -- Always keep at full capacity
                storage.resources[resourceType] = capacity

                -- Update Spacebuild 3 RD system
                if storage.rdEnabled and RD and RD.SetResourceAmount then
                    RD.SetResourceAmount(coreEntity, config.rdType, capacity)
                    if coreEntity.RD and coreEntity.RD.StorageAmount then
                        coreEntity.RD.StorageAmount[config.rdType] = capacity
                    end
                end

                -- Update LS2 system if available
                if storage.ls2Enabled and LS and LS.SetResourceAmount then
                    LS.SetResourceAmount(coreEntity, config.rdType, capacity)
                end
            else
                -- Generate resources at specified rate with regeneration scaling (inverse of size)
                local baseGenerateAmount = HYPERDRIVE.SB3Resources.Config.GenerationRate * HYPERDRIVE.SB3Resources.Config.GenerationInterval
                local generateAmount = math.floor(baseGenerateAmount * storage.regenMultiplier)
                local newAmount = math.min(capacity, currentAmount + generateAmount)

                if newAmount > currentAmount then
                    storage.resources[resourceType] = newAmount

                    -- Update Spacebuild 3 RD system
                    if storage.rdEnabled and RD and RD.SetResourceAmount then
                        RD.SetResourceAmount(coreEntity, config.rdType, newAmount)
                        if coreEntity.RD and coreEntity.RD.StorageAmount then
                            coreEntity.RD.StorageAmount[config.rdType] = newAmount
                        end
                    end

                    -- Update LS2 system if available
                    if storage.ls2Enabled and LS and LS.SetResourceAmount then
                        LS.SetResourceAmount(coreEntity, config.rdType, newAmount)
                    end
                end
            end
        end
    end
end

-- Main resource update function
function HYPERDRIVE.SB3Resources.UpdateCoreResources(coreEntity)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    local currentTime = CurTime()
    if currentTime - storage.lastUpdate < HYPERDRIVE.SB3Resources.Config.DistributionInterval then return end

    storage.lastUpdate = currentTime

    -- Generate resources if enabled
    HYPERDRIVE.SB3Resources.GenerateResources(coreEntity)

    -- Provide life support if enabled
    HYPERDRIVE.SB3Resources.ProvideLifeSupport(coreEntity)

    -- Check for newly welded entities and update ship size
    HYPERDRIVE.SB3Resources.CheckForNewEntities(coreEntity)
    HYPERDRIVE.SB3Resources.UpdateShipSize(coreEntity)

    -- Auto-balance resources
    HYPERDRIVE.SB3Resources.AutoBalanceResources(coreEntity)

    -- Check for emergency conditions
    HYPERDRIVE.SB3Resources.CheckEmergencyConditions(coreEntity)

    -- Clean up old alerts
    HYPERDRIVE.SB3Resources.CleanupAlerts(storage)
end

-- Check for emergency resource conditions
function HYPERDRIVE.SB3Resources.CheckEmergencyConditions(coreEntity)
    if not HYPERDRIVE.SB3Resources.Config.EnableEmergencyShutdown then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    local criticalResources = 0
    local totalResources = 0

    for resourceType, amount in pairs(storage.resources) do
        totalResources = totalResources + 1
        local percentage = (amount / storage.capacity[resourceType]) * 100
        if percentage <= HYPERDRIVE.SB3Resources.Config.CriticalResourceThreshold then
            criticalResources = criticalResources + 1
        end
    end

    -- Trigger emergency mode if too many resources are critical
    local criticalRatio = criticalResources / totalResources
    if criticalRatio >= 0.5 and not storage.emergencyMode then
        storage.emergencyMode = true
        HYPERDRIVE.SB3Resources.TriggerResourceAlert(coreEntity, "system", "emergency")

        -- Disable non-essential systems
        if coreEntity.SetEmergencyMode then
            coreEntity:SetEmergencyMode(true)
        end
    elseif criticalRatio < 0.3 and storage.emergencyMode then
        storage.emergencyMode = false

        -- Re-enable systems
        if coreEntity.SetEmergencyMode then
            coreEntity:SetEmergencyMode(false)
        end
    end
end

-- Clean up old alerts
function HYPERDRIVE.SB3Resources.CleanupAlerts(storage)
    local currentTime = CurTime()
    for i = #storage.alerts, 1, -1 do
        local alert = storage.alerts[i]
        if currentTime - alert.timestamp > 60 then -- Remove alerts older than 1 minute
            table.remove(storage.alerts, i)
        end
    end
end

-- Update ship size and recalculate resource scaling
function HYPERDRIVE.SB3Resources.UpdateShipSize(coreEntity)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    local oldSize = storage.shipSize
    local oldMultiplier = storage.sizeMultiplier
    local oldRegenMultiplier = storage.regenMultiplier

    -- Recalculate ship size and multipliers
    storage.shipSize = HYPERDRIVE.SB3Resources.CalculateShipSize(coreEntity)
    storage.sizeMultiplier = HYPERDRIVE.SB3Resources.CalculateSizeMultiplier(coreEntity)
    storage.regenMultiplier = HYPERDRIVE.SB3Resources.CalculateRegenMultiplier(coreEntity)

    -- If size changed significantly, update capacities
    if math.abs(storage.sizeMultiplier - oldMultiplier) > 0.1 then
        for resourceType, config in pairs(HYPERDRIVE.SB3Resources.ResourceTypes) do
            -- Recalculate capacity with new size multiplier
            local baseCapacity = HYPERDRIVE.SB3Resources.Config.EnableResourceGeneration and
                                HYPERDRIVE.SB3Resources.Config.MaxStorageCapacity or
                                config.defaultCapacity
            local newCapacity = math.floor(baseCapacity * storage.sizeMultiplier)

            -- Update capacity
            storage.capacity[resourceType] = newCapacity

            -- If keeping storage full, update current amount
            if HYPERDRIVE.SB3Resources.Config.KeepStorageFull and storage.unlimitedResources then
                storage.resources[resourceType] = newCapacity
            end

            -- Update transfer rates
            storage.transferRates[resourceType] = math.floor(config.transferRate * storage.sizeMultiplier)

            -- Update RD system
            if storage.rdEnabled and RD and RD.SetResourceCapacity then
                RD.SetResourceCapacity(coreEntity, config.rdType, newCapacity)
                if HYPERDRIVE.SB3Resources.Config.KeepStorageFull and storage.unlimitedResources then
                    RD.SetResourceAmount(coreEntity, config.rdType, newCapacity)
                end
            end
        end

        print("[Hyperdrive SB3] Ship size updated for core " .. coreEntity:EntIndex() ..
              " - Size: " .. storage.shipSize .. " entities (was " .. oldSize ..
              "), Capacity: " .. string.format("%.1f", storage.sizeMultiplier) ..
              "x (was " .. string.format("%.1f", oldMultiplier) .. "x)" ..
              ", Regen: " .. string.format("%.1f", storage.regenMultiplier) ..
              "x (was " .. string.format("%.1f", oldRegenMultiplier) .. "x)")
    end
end

-- Console command to toggle unlimited resources
concommand.Add("asc_unlimited_resources", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "ship_core" then
        ply:ChatPrint("[Ship Core] Look at a ship core to toggle unlimited resources!")
        return
    end

    local coreEntity = trace.Entity
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then
        ply:ChatPrint("[Ship Core] Resource system not initialized!")
        return
    end

    -- Toggle unlimited resources
    storage.unlimitedResources = not storage.unlimitedResources

    if storage.unlimitedResources then
        -- Fill all resources to maximum
        for resourceType, config in pairs(HYPERDRIVE.SB3Resources.ResourceTypes) do
            storage.resources[resourceType] = storage.capacity[resourceType]

            -- Update RD system
            if storage.rdEnabled and RD and RD.SetResourceAmount then
                RD.SetResourceAmount(coreEntity, config.rdType, storage.capacity[resourceType])
                if coreEntity.RD and coreEntity.RD.StorageAmount then
                    coreEntity.RD.StorageAmount[config.rdType] = storage.capacity[resourceType]
                end
            end
        end

        ply:ChatPrint("[Ship Core] ✅ Unlimited resources ENABLED! Ship core now provides unlimited resources.")
    else
        ply:ChatPrint("[Ship Core] ❌ Unlimited resources DISABLED! Ship core now uses normal resource consumption.")
    end
end)

-- Console command to toggle life support
concommand.Add("asc_life_support", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "ship_core" then
        ply:ChatPrint("[Ship Core] Look at a ship core to toggle life support!")
        return
    end

    local coreEntity = trace.Entity
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then
        ply:ChatPrint("[Ship Core] Resource system not initialized!")
        return
    end

    -- Toggle life support
    storage.lifeSupportActive = not storage.lifeSupportActive

    if storage.lifeSupportActive then
        ply:ChatPrint("[Ship Core] ✅ Life support ENABLED! Range: " .. string.format("%.0f", HYPERDRIVE.SB3Resources.Config.LifeSupportRange * storage.sizeMultiplier) .. " units")
    else
        ply:ChatPrint("[Ship Core] ❌ Life support DISABLED!")

        -- Remove life support from all players
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                player:SetNWBool("HasLifeSupport", false)
                player:SetNWEntity("LifeSupportCore", NULL)
            end
        end
    end
end)

-- Console command to check ship size and scaling
concommand.Add("asc_ship_info", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "ship_core" then
        ply:ChatPrint("[Ship Core] Look at a ship core to check ship information!")
        return
    end

    local coreEntity = trace.Entity
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then
        ply:ChatPrint("[Ship Core] Resource system not initialized!")
        return
    end

    -- Force update ship size
    HYPERDRIVE.SB3Resources.UpdateShipSize(coreEntity)

    ply:ChatPrint("=== Ship Core Information ===")
    ply:ChatPrint("Ship Size: " .. storage.shipSize .. " entities")
    ply:ChatPrint("Capacity Multiplier: " .. string.format("%.2f", storage.sizeMultiplier) .. "x")
    ply:ChatPrint("Regeneration Multiplier: " .. string.format("%.2f", storage.regenMultiplier) .. "x")
    ply:ChatPrint("Unlimited Resources: " .. (storage.unlimitedResources and "YES" or "NO"))
    ply:ChatPrint("Life Support: " .. (storage.lifeSupportActive and "ACTIVE" or "DISABLED"))

    if storage.lifeSupportActive then
        local range = HYPERDRIVE.SB3Resources.Config.LifeSupportRange * storage.sizeMultiplier
        ply:ChatPrint("Life Support Range: " .. string.format("%.0f", range) .. " units")
        ply:ChatPrint("Players Supported: " .. (storage.playersSupported or 0))
    end

    ply:ChatPrint("Resource Capacities:")
    for resourceType, capacity in pairs(storage.capacity) do
        local config = HYPERDRIVE.SB3Resources.ResourceTypes[resourceType]
        if config then
            ply:ChatPrint("  " .. config.name .. ": " .. string.format("%,d", capacity) .. " " .. config.unit)
        end
    end
end)

-- Hook into ship core initialization
hook.Add("OnEntityCreated", "HyperdriveSB3ResourceCore", function(ent)
    if not IsValid(ent) or ent:GetClass() ~= "ship_core" then return end

    timer.Simple(0.1, function()
        if IsValid(ent) and HYPERDRIVE.SB3Resources.Config.EnableResourceCore then
            HYPERDRIVE.SB3Resources.InitializeCoreStorage(ent)
        end
    end)
end)

-- Cleanup on entity removal
hook.Add("EntityRemoved", "HyperdriveSB3ResourceCoreCleanup", function(ent)
    if not IsValid(ent) or ent:GetClass() ~= "ship_core" then return end

    local coreId = ent:EntIndex()
    HYPERDRIVE.SB3Resources.CoreStorage[coreId] = nil
end)

-- Hook for when entities are welded (constraint created)
hook.Add("OnEntityCreated", "HyperdriveSB3WeldDetection", function(ent)
    if not IsValid(ent) then return end

    -- Check if weld detection is enabled
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.SB3Resources or HYPERDRIVE.SB3Resources.Config
    if not config.EnableWeldDetection or not config.AutoProvisionOnWeld then return end

    -- Check if this is a constraint (weld, rope, etc.)
    if ent:GetClass() == "phys_constraint" or string.find(ent:GetClass(), "constraint") then
        timer.Simple(0.1, function()
            if IsValid(ent) then
                HYPERDRIVE.SB3Resources.HandleConstraintCreated(ent)
            end
        end)
    end

    -- Also check for direct entity welding
    local delay = config.AutoProvisionDelay or 0.5
    timer.Simple(delay, function()
        if IsValid(ent) then
            HYPERDRIVE.SB3Resources.CheckEntityWeldedToShip(ent)
        end
    end)
end)

-- Handle constraint creation (welding detection)
function HYPERDRIVE.SB3Resources.HandleConstraintCreated(constraint)
    if not IsValid(constraint) then return end

    -- Get entities connected by this constraint using the correct method
    local ent1, ent2 = nil, nil

    -- Try different methods to get constrained entities
    if constraint.Ent1 and constraint.Ent2 then
        ent1 = constraint.Ent1
        ent2 = constraint.Ent2
    elseif constraint.Entity1 and constraint.Entity2 then
        ent1 = constraint.Entity1
        ent2 = constraint.Entity2
    elseif constraint.GetTable then
        local constraintTable = constraint:GetTable()
        if constraintTable then
            ent1 = constraintTable.Ent1 or constraintTable.Entity1
            ent2 = constraintTable.Ent2 or constraintTable.Entity2
        end
    end

    if not IsValid(ent1) or not IsValid(ent2) then return end

    -- Check if either entity is part of a ship with a core
    local ship1 = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(ent1)
    local ship2 = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(ent2)

    -- If one entity is part of a ship and the other isn't, the other might be newly welded
    if ship1 and not ship2 then
        -- ent2 might be newly welded to ship1
        timer.Simple(0.5, function()
            if IsValid(ent2) then
                local newShip = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(ent2)
                if newShip and newShip.core == ship1.core then
                    HYPERDRIVE.SB3Resources.HandleNewlyWeldedEntity(ship1.core, ent2)
                end
            end
        end)
    elseif ship2 and not ship1 then
        -- ent1 might be newly welded to ship2
        timer.Simple(0.5, function()
            if IsValid(ent1) then
                local newShip = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(ent1)
                if newShip and newShip.core == ship2.core then
                    HYPERDRIVE.SB3Resources.HandleNewlyWeldedEntity(ship2.core, ent1)
                end
            end
        end)
    end
end

-- Check if an entity has been welded to a ship
function HYPERDRIVE.SB3Resources.CheckEntityWeldedToShip(entity)
    if not IsValid(entity) then return end

    -- Skip if entity is already tracked by a ship core
    for coreId, storage in pairs(HYPERDRIVE.SB3Resources.CoreStorage) do
        if storage.trackedEntities and storage.trackedEntities[entity:EntIndex()] then
            return -- Already tracked
        end
    end

    -- Check if entity is now part of a ship
    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(entity)
    if ship and ship.core and IsValid(ship.core) then
        HYPERDRIVE.SB3Resources.HandleNewlyWeldedEntity(ship.core, entity)
    end
end

-- Handle a newly welded entity
function HYPERDRIVE.SB3Resources.HandleNewlyWeldedEntity(coreEntity, newEntity)
    if not IsValid(coreEntity) or not IsValid(newEntity) then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    local entIndex = newEntity:EntIndex()

    -- Check if already tracked
    if storage.trackedEntities and storage.trackedEntities[entIndex] then
        return
    end

    -- Add to tracked entities
    if not storage.trackedEntities then
        storage.trackedEntities = {}
    end

    storage.trackedEntities[entIndex] = {
        entity = newEntity,
        addedTime = CurTime(),
        resourcesProvided = false,
        weldDetected = true
    }

    -- Provide initial resources immediately
    HYPERDRIVE.SB3Resources.ProvideInitialResources(coreEntity, newEntity)

    -- Log the welding detection
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.SB3Resources or HYPERDRIVE.SB3Resources.Config
    if config.LogWeldDetection or config.LogResourceTransfers then
        print("[Hyperdrive SB3] Detected newly welded entity: " .. newEntity:GetClass() .. " to ship core " .. coreEntity:EntIndex())
    end
end

-- Console commands for resource management
concommand.Add("hyperdrive_sb3_resources", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end

    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end

    sendMessage("=== Hyperdrive SB3 Resource System Status ===")

    local totalCores = 0
    local activeCores = 0

    for coreId, storage in pairs(HYPERDRIVE.SB3Resources.CoreStorage) do
        totalCores = totalCores + 1
        if IsValid(storage.core) then
            activeCores = activeCores + 1

            sendMessage("• Core " .. coreId .. ":")
            for resourceType, amount in pairs(storage.resources) do
                local capacity = storage.capacity[resourceType]
                local percentage = (amount / capacity) * 100
                sendMessage("  - " .. HYPERDRIVE.SB3Resources.ResourceTypes[resourceType].name .. ": " ..
                           math.floor(amount) .. "/" .. capacity .. " (" .. string.format("%.1f", percentage) .. "%)")
            end

            if storage.emergencyMode then
                sendMessage("  - STATUS: EMERGENCY MODE")
            end
        end
    end

    sendMessage("• Total Cores: " .. totalCores)
    sendMessage("• Active Cores: " .. activeCores)
    sendMessage("• CAF Available: " .. (CAF and "Yes" or "No"))

    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.SB3Resources or HYPERDRIVE.SB3Resources.Config
    sendMessage("• Auto Resource Provision: " .. (config.EnableAutoResourceProvision and "Enabled" or "Disabled"))
    sendMessage("• Weld Detection: " .. (config.EnableWeldDetection and "Enabled" or "Disabled"))
end)

-- Console command to test automatic resource provision
concommand.Add("hyperdrive_sb3_test_provision", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end

    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end

    if not args[1] then
        sendMessage("Usage: hyperdrive_sb3_test_provision <entity_id>")
        sendMessage("Tests automatic resource provision for a specific entity")
        return
    end

    local entId = tonumber(args[1])
    if not entId then
        sendMessage("Invalid entity ID")
        return
    end

    local entity = Entity(entId)
    if not IsValid(entity) then
        sendMessage("Entity not found")
        return
    end

    -- Find ship core for this entity
    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(entity)
    if not ship or not ship.core or not IsValid(ship.core) then
        sendMessage("Entity is not part of a ship with a core")
        return
    end

    sendMessage("Testing automatic resource provision for " .. entity:GetClass() .. " (ID: " .. entId .. ")")
    sendMessage("Ship Core: " .. ship.core:EntIndex())

    -- Test if entity needs resources
    local needsResources = HYPERDRIVE.SB3Resources.EntityNeedsResources(entity)
    sendMessage("Needs Resources: " .. (needsResources and "Yes" or "No"))

    if needsResources then
        local requirements = HYPERDRIVE.SB3Resources.GetEntityResourceRequirements(entity)
        if requirements then
            sendMessage("Resource Requirements:")
            for resourceType, amount in pairs(requirements) do
                sendMessage("  - " .. resourceType .. ": " .. amount)
            end

            -- Test provision
            HYPERDRIVE.SB3Resources.ProvideInitialResources(ship.core, entity)
            sendMessage("Resource provision test completed")
        else
            sendMessage("No resource requirements found")
        end
    end
end)

-- Add Q menu configuration command
concommand.Add("hyperdrive_open_qmenu_config", function(ply, cmd, args)
    if CLIENT then
        -- Open the Q menu to the hyperdrive configuration
        if spawnmenu and spawnmenu.ActivateTool then
            spawnmenu.ActivateTool("hyperdrive_config")
        end

        -- Also show a helpful message
        chat.AddText(Color(100, 200, 255), "[Hyperdrive] Opening Q Menu configuration...")
        chat.AddText(Color(255, 255, 255), "Navigate to: Q Menu → Utilities → Enhanced Hyperdrive")
    end
end)

local resourceMode = HYPERDRIVE.SB3Resources.Config.EnableResourceGeneration and "UNLIMITED GENERATION" or "STANDARD"
local lifeSupportMode = HYPERDRIVE.SB3Resources.Config.EnableLifeSupport and "ENABLED" or "DISABLED"
local sizeScalingMode = HYPERDRIVE.SB3Resources.Config.EnableSizeBasedScaling and "ENABLED" or "DISABLED"
local regenScalingMode = HYPERDRIVE.SB3Resources.Config.EnableInverseRegenScaling and "INVERSE (Small=Fast)" or "DISABLED"

-- Console command to test CAF integration
if SERVER then
    concommand.Add("asc_test_caf", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end

        print("[Hyperdrive SB3] CAF Integration Test:")
        print("  - CAF: " .. (CAF and "exists" or "nil"))

        if CAF then
            print("  - CAF.CAF3: " .. (CAF.CAF3 and "exists" or "nil"))
            if CAF.CAF3 and CAF.CAF3.Addons then
                print("  - CAF Addons:")
                for addonName, addon in pairs(CAF.CAF3.Addons) do
                    local status = "unknown"
                    if addon.GetStatus then
                        status = addon.GetStatus() and "active" or "inactive"
                    end
                    print("    " .. addonName .. ": " .. status)
                end
            end
        end

        print("  - RESOURCES: " .. (RESOURCES and "exists" or "nil"))
        print("  - RD: " .. (RD and "exists" or "nil"))
        print("  - LS: " .. (LS and "exists" or "nil"))

        local hasRD = CheckSpacebuild3()
        local hasLS2 = CheckLS2()
        print("  - Spacebuild 3 Detection: " .. (hasRD and "SUCCESS" or "FAILED"))
        print("  - LS2 Detection: " .. (hasLS2 and "SUCCESS" or "FAILED"))
    end)
end

-- Test Spacebuild detection after functions are defined
timer.Simple(1, function()
    local hasRD = CheckSpacebuild3()
    local hasLS2 = CheckLS2()

    print("[Hyperdrive SB3] Detection Results:")
    print("  - Spacebuild 3 RD: " .. (hasRD and "DETECTED" or "NOT DETECTED"))
    print("  - Spacebuild 3 LS2: " .. (hasLS2 and "DETECTED" or "NOT DETECTED"))
    print("  - Current Map: " .. game.GetMap())

    if GAMEMODE and GAMEMODE.Name then
        print("  - Current Gamemode: " .. GAMEMODE.Name)
    end

    -- Check for global variables
    print("  - Global Variables:")
    print("    CAF: " .. (CAF and "exists" or "nil"))
    if CAF and CAF.CAF3 and CAF.CAF3.Addons then
        local addonCount = 0
        for _ in pairs(CAF.CAF3.Addons) do
            addonCount = addonCount + 1
        end
        print("    CAF Addons: " .. addonCount .. " registered")
    end
    print("    RESOURCES: " .. (RESOURCES and "exists" or "nil"))
    print("    RD: " .. (RD and "exists" or "nil"))
    print("    LS: " .. (LS and "exists" or "nil"))
    print("    ENV: " .. (ENV and "exists" or "nil"))

    print("[Hyperdrive SB3] Use 'asc_test_caf' command for detailed CAF integration test")
end)

print("[Hyperdrive] Spacebuild 3 Resource Core Integration loaded successfully!")
print("[Hyperdrive] Resource Mode: " .. resourceMode .. " | Life Support: " .. lifeSupportMode)
print("[Hyperdrive] Size Scaling: " .. sizeScalingMode .. " | Regen Scaling: " .. regenScalingMode)
print("[Hyperdrive] Ship cores will " .. (HYPERDRIVE.SB3Resources.Config.UnlimitedResources and "provide unlimited resources" or "use standard resource consumption"))
print("[Hyperdrive] Small ships: High regen, low capacity | Large ships: Low regen, high capacity")
print("[Hyperdrive] Console Commands:")
print("[Hyperdrive]   asc_unlimited_resources - Toggle unlimited resources")
print("[Hyperdrive]   asc_life_support - Toggle life support")
print("[Hyperdrive]   asc_ship_info - Show ship size and scaling information")
