-- Enhanced Hyperdrive System v2.2.1 - Spacebuild 3 Resource Core Integration
-- COMPLETE CODE UPDATE v2.2.1 - ALL SYSTEMS INTEGRATED WITH STEAM WORKSHOP
-- Ship core as central resource storage and distribution hub using official SB3 RD system
-- Steam Workshop SB3 v3.2.0 Support: https://steamcommunity.com/sharedfiles/filedetails/?id=693838486

if CLIENT then return end

print("[Hyperdrive SB3] COMPLETE CODE UPDATE v2.2.1 - SB3 Resource Core being updated")
print("[Hyperdrive] Loading Spacebuild 3 Resource Core Integration with Steam Workshop support...")

-- Initialize resource core system
HYPERDRIVE.SB3Resources = HYPERDRIVE.SB3Resources or {}
HYPERDRIVE.SB3Resources.CoreStorage = HYPERDRIVE.SB3Resources.CoreStorage or {}
HYPERDRIVE.SB3Resources.Networks = HYPERDRIVE.SB3Resources.Networks or {}

-- Check for Spacebuild 3 RD system
local function CheckSpacebuild3()
    return RD ~= nil and RD.AddResource ~= nil and RD.GetResourceAmount ~= nil
end

-- Check for Spacebuild 3 LS2 system
local function CheckLS2()
    return LS ~= nil and LS.AddResource ~= nil
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
}

-- Initialize ship core resource storage with Spacebuild 3 RD integration
function HYPERDRIVE.SB3Resources.InitializeCoreStorage(coreEntity)
    if not IsValid(coreEntity) or coreEntity:GetClass() ~= "ship_core" then return false end

    local coreId = coreEntity:EntIndex()
    if HYPERDRIVE.SB3Resources.CoreStorage[coreId] then return true end

    -- Check if Spacebuild 3 is available
    local hasRD = CheckSpacebuild3()
    local hasLS2 = CheckLS2()

    if not hasRD and not hasLS2 then
        print("[Hyperdrive SB3] Spacebuild 3 not detected, resource system disabled")
        return false
    end

    -- Initialize storage for all resource types
    HYPERDRIVE.SB3Resources.CoreStorage[coreId] = {
        core = coreEntity,
        resources = {},
        capacity = {},
        transferRates = {},
        connections = {},
        lastUpdate = CurTime(),
        emergencyMode = false,
        alerts = {},
        rdEnabled = hasRD,
        ls2Enabled = hasLS2
    }

    local storage = HYPERDRIVE.SB3Resources.CoreStorage[coreId]

    -- Setup resource storage
    for resourceType, config in pairs(HYPERDRIVE.SB3Resources.ResourceTypes) do
        storage.resources[resourceType] = 0
        storage.capacity[resourceType] = config.defaultCapacity
        storage.transferRates[resourceType] = config.transferRate

        -- Register with Spacebuild 3 RD system
        if hasRD and RD.AddResource then
            RD.AddResource(coreEntity, config.rdType, 0)
            RD.SetResourceCapacity(coreEntity, config.rdType, config.defaultCapacity)
        end

        -- Register with LS2 system if available
        if hasLS2 and LS.AddResource then
            LS.AddResource(coreEntity, config.rdType, 0)
        end
    end

    -- Set entity as resource storage node
    if hasRD then
        coreEntity.RD = coreEntity.RD or {}
        coreEntity.RD.IsStorage = true
        coreEntity.RD.StorageCapacity = {}
        coreEntity.RD.StorageAmount = {}

        for resourceType, config in pairs(HYPERDRIVE.SB3Resources.ResourceTypes) do
            coreEntity.RD.StorageCapacity[config.rdType] = config.defaultCapacity
            coreEntity.RD.StorageAmount[config.rdType] = 0
        end
    end

    print("[Hyperdrive SB3] Initialized resource storage for ship core " .. coreId .. " (RD: " .. tostring(hasRD) .. ", LS2: " .. tostring(hasLS2) .. ")")
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

        if available > 0 and needed > 0 then
            local transferAmount = math.min(needed, available, transferRate)

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

-- Main resource update function
function HYPERDRIVE.SB3Resources.UpdateCoreResources(coreEntity)
    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(coreEntity)
    if not storage then return end

    local currentTime = CurTime()
    if currentTime - storage.lastUpdate < HYPERDRIVE.SB3Resources.Config.DistributionInterval then return end

    storage.lastUpdate = currentTime

    -- Check for newly welded entities
    HYPERDRIVE.SB3Resources.CheckForNewEntities(coreEntity)

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

print("[Hyperdrive] Spacebuild 3 Resource Core Integration loaded successfully!")
