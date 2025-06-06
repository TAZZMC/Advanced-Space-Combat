-- Advanced Space Combat - Enhanced CAP Integration System v3.0
-- Comprehensive CAP asset integration with advanced features
-- Includes fallback systems, performance optimization, and direct entity communication

print("[Advanced Space Combat] Enhanced CAP Integration System v3.0 - Loading...")

-- Initialize enhanced CAP namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.Enhanced = ASC.CAP.Enhanced or {}

-- Enhanced CAP Configuration
ASC.CAP.Enhanced.Config = {
    -- Core settings
    EnableEnhancedIntegration = true,
    EnableFallbackSystems = true,
    EnablePerformanceOptimization = true,
    EnableDirectEntityCommunication = true,
    
    -- Detection settings
    EnableDeepEntityScan = true,
    EnableRealTimeDetection = true,
    DetectionInterval = 5.0,
    MaxDetectionRadius = 5000,
    
    -- Resource integration
    EnableResourceBridging = true,
    EnableAutoResourceDistribution = true,
    ResourceUpdateInterval = 2.0,
    
    -- Shield integration
    EnableAdvancedShieldIntegration = true,
    AutoActivateShields = true,
    ShieldSyncInterval = 1.0,
    
    -- Performance settings
    EnableEntityCaching = true,
    CacheUpdateInterval = 10.0,
    MaxCachedEntities = 1000,
    
    -- Debug settings
    EnableDebugLogging = false,
    EnablePerformanceMetrics = false
}

-- Enhanced CAP Detection System
ASC.CAP.Enhanced.Detection = {
    lastScan = 0,
    cachedEntities = {},
    detectionResults = {},
    performanceMetrics = {}
}

-- Technology levels for CAP assets
ASC.CAP.Enhanced.TechnologyLevels = {
    ["Ancient"] = {
        priority = 10,
        powerMultiplier = 2.0,
        efficiencyBonus = 0.5,
        materials = {"ancient", "atlantis", "destiny"},
        sounds = {"ancient", "atlantis", "destiny"}
    },
    ["Asgard"] = {
        priority = 9,
        powerMultiplier = 1.8,
        efficiencyBonus = 0.4,
        materials = {"asgard", "asgard_tech"},
        sounds = {"asgard", "beam"}
    },
    ["Ori"] = {
        priority = 8,
        powerMultiplier = 1.6,
        efficiencyBonus = 0.3,
        materials = {"ori", "ori_tech"},
        sounds = {"ori", "energy"}
    },
    ["Wraith"] = {
        priority = 7,
        powerMultiplier = 1.4,
        efficiencyBonus = 0.2,
        materials = {"wraith", "wraith_tech"},
        sounds = {"wraith", "organic"}
    },
    ["Goauld"] = {
        priority = 6,
        powerMultiplier = 1.2,
        efficiencyBonus = 0.1,
        materials = {"goauld", "jaffa"},
        sounds = {"goauld", "staff"}
    },
    ["Tau_ri"] = {
        priority = 5,
        powerMultiplier = 1.0,
        efficiencyBonus = 0.0,
        materials = {"human", "earth", "tau_ri"},
        sounds = {"human", "earth"}
    }
}

-- Enhanced entity detection with caching
function ASC.CAP.Enhanced.DetectCAPEntities(forceUpdate)
    local currentTime = CurTime()
    
    -- Check if we need to update
    if not forceUpdate and currentTime - ASC.CAP.Enhanced.Detection.lastScan < ASC.CAP.Enhanced.Config.DetectionInterval then
        return ASC.CAP.Enhanced.Detection.cachedEntities
    end
    
    local startTime = currentTime
    local detectedEntities = {}
    local entityCount = 0
    
    -- Get all entities in the world
    local allEntities = ents.GetAll()
    
    for _, ent in ipairs(allEntities) do
        if IsValid(ent) then
            local className = ent:GetClass()
            local category = HYPERDRIVE.CAP.GetEntityCategory and HYPERDRIVE.CAP.GetEntityCategory(className)
            
            if category then
                local entityData = {
                    entity = ent,
                    class = className,
                    category = category,
                    position = ent:GetPos(),
                    owner = ent:GetOwner(),
                    technology = ASC.CAP.Enhanced.DetermineTechnology(ent),
                    lastUpdate = currentTime,
                    capabilities = ASC.CAP.Enhanced.AnalyzeEntityCapabilities(ent)
                }
                
                table.insert(detectedEntities, entityData)
                entityCount = entityCount + 1
            end
        end
    end
    
    -- Update cache
    ASC.CAP.Enhanced.Detection.cachedEntities = detectedEntities
    ASC.CAP.Enhanced.Detection.lastScan = currentTime
    
    -- Performance metrics
    local scanTime = CurTime() - startTime
    ASC.CAP.Enhanced.Detection.performanceMetrics.lastScanTime = scanTime
    ASC.CAP.Enhanced.Detection.performanceMetrics.entitiesScanned = #allEntities
    ASC.CAP.Enhanced.Detection.performanceMetrics.capEntitiesFound = entityCount
    
    if ASC.CAP.Enhanced.Config.EnableDebugLogging then
        print(string.format("[ASC CAP Enhanced] Detected %d CAP entities in %.3fs", entityCount, scanTime))
    end
    
    return detectedEntities
end

-- Determine technology level of CAP entity
function ASC.CAP.Enhanced.DetermineTechnology(entity)
    if not IsValid(entity) then return "Tau_ri" end
    
    local className = string.lower(entity:GetClass())
    local model = string.lower(entity:GetModel() or "")
    
    -- Check for technology indicators in class name and model
    for techName, techData in pairs(ASC.CAP.Enhanced.TechnologyLevels) do
        local techLower = string.lower(techName)
        
        if string.find(className, techLower) or string.find(model, techLower) then
            return techName
        end
        
        -- Check material indicators
        for _, material in ipairs(techData.materials) do
            if string.find(className, material) or string.find(model, material) then
                return techName
            end
        end
    end
    
    -- Default to Tau'ri (human) technology
    return "Tau_ri"
end

-- Analyze entity capabilities
function ASC.CAP.Enhanced.AnalyzeEntityCapabilities(entity)
    if not IsValid(entity) then return {} end
    
    local capabilities = {}
    
    -- Check for common CAP entity methods
    local methods = {
        "Activate", "Deactivate", "TurnOn", "TurnOff", "SetActive", "SetEnabled",
        "GetShieldStrength", "SetShieldStrength", "GetEnergy", "SetEnergy",
        "GetFrequency", "SetFrequency", "Dial", "GetAddress", "SetAddress",
        "GetPower", "SetPower", "GetStatus", "SetStatus"
    }
    
    for _, method in ipairs(methods) do
        if entity[method] then
            capabilities[method] = true
        end
    end
    
    -- Check for CAP-specific properties
    if entity.IsStargate then capabilities.stargate = true end
    if entity.IsShield then capabilities.shield = true end
    if entity.IsPowerSource then capabilities.power = true end
    if entity.IsTransporter then capabilities.transport = true end
    if entity.IsWeapon then capabilities.weapon = true end
    
    return capabilities
end

-- Get best available technology for player
function ASC.CAP.Enhanced.GetBestAvailableTechnology(player)
    if not IsValid(player) then return "Tau_ri" end
    
    -- Check player's available CAP entities
    local playerEntities = ASC.CAP.Enhanced.GetPlayerCAPEntities(player)
    local bestTech = "Tau_ri"
    local bestPriority = 0
    
    for _, entityData in ipairs(playerEntities) do
        local techData = ASC.CAP.Enhanced.TechnologyLevels[entityData.technology]
        if techData and techData.priority > bestPriority then
            bestTech = entityData.technology
            bestPriority = techData.priority
        end
    end
    
    return bestTech
end

-- Get CAP entities owned by player
function ASC.CAP.Enhanced.GetPlayerCAPEntities(player)
    if not IsValid(player) then return {} end
    
    local playerEntities = {}
    local allCAPEntities = ASC.CAP.Enhanced.DetectCAPEntities()
    
    for _, entityData in ipairs(allCAPEntities) do
        if IsValid(entityData.entity) then
            local owner = entityData.owner
            if not IsValid(owner) and entityData.entity.CPPIGetOwner then
                owner = entityData.entity:CPPIGetOwner()
            end
            
            if IsValid(owner) and owner == player then
                table.insert(playerEntities, entityData)
            end
        end
    end
    
    return playerEntities
end

-- Enhanced resource bridging system
ASC.CAP.Enhanced.ResourceBridge = {}

-- Initialize resource bridging
function ASC.CAP.Enhanced.ResourceBridge.Initialize()
    if not ASC.CAP.Enhanced.Config.EnableResourceBridging then return false end
    
    -- Define resource conversion rates
    ASC.CAP.Enhanced.ResourceBridge.ConversionRates = {
        -- CAP to SB3 conversions
        ["zpm_energy"] = { sb3_type = "energy", rate = 10.0, capacity = 50000 },
        ["naquadah_energy"] = { sb3_type = "energy", rate = 5.0, capacity = 25000 },
        ["potentia_energy"] = { sb3_type = "energy", rate = 3.0, capacity = 15000 },
        
        -- CAP resources to SB3 resources
        ["naquadah"] = { sb3_type = "fuel", rate = 2.0, capacity = 5000 },
        ["trinium"] = { sb3_type = "coolant", rate = 1.5, capacity = 3000 },
        ["neutronium"] = { sb3_type = "nitrogen", rate = 1.0, capacity = 2000 }
    }
    
    print("[ASC CAP Enhanced] Resource bridging system initialized")
    return true
end

-- Bridge CAP resources to SB3 system
function ASC.CAP.Enhanced.ResourceBridge.BridgeResources(shipCore, capEntities)
    if not IsValid(shipCore) or not capEntities then return false end
    if not ASC.CAP.Enhanced.Config.EnableResourceBridging then return false end
    
    local totalBridged = 0
    
    for _, entityData in ipairs(capEntities) do
        if IsValid(entityData.entity) and entityData.category == "ENERGY_SYSTEMS" then
            local bridged = ASC.CAP.Enhanced.ResourceBridge.BridgeEntity(shipCore, entityData)
            if bridged then
                totalBridged = totalBridged + 1
            end
        end
    end
    
    if totalBridged > 0 and ASC.CAP.Enhanced.Config.EnableDebugLogging then
        print(string.format("[ASC CAP Enhanced] Bridged %d CAP entities to SB3 system", totalBridged))
    end
    
    return totalBridged > 0
end

-- Bridge individual CAP entity to SB3
function ASC.CAP.Enhanced.ResourceBridge.BridgeEntity(shipCore, entityData)
    if not IsValid(shipCore) or not entityData or not IsValid(entityData.entity) then return false end
    
    local entity = entityData.entity
    local className = entityData.class
    
    -- Check if entity has energy/resource methods
    local energy = 0
    if entity.GetEnergy then
        energy = entity:GetEnergy() or 0
    elseif entity.GetPower then
        energy = entity:GetPower() or 0
    elseif entity.GetStoredEnergy then
        energy = entity:GetStoredEnergy() or 0
    end
    
    if energy > 0 then
        -- Convert CAP energy to SB3 energy
        local conversionData = ASC.CAP.Enhanced.ResourceBridge.ConversionRates[className] or 
                              ASC.CAP.Enhanced.ResourceBridge.ConversionRates["naquadah_energy"]
        
        local convertedEnergy = energy * conversionData.rate
        
        -- Add to ship core's SB3 resources
        if shipCore.AddResource then
            shipCore:AddResource(conversionData.sb3_type, convertedEnergy)
            return true
        end
    end
    
    return false
end

-- Initialize enhanced CAP integration
function ASC.CAP.Enhanced.Initialize()
    if not ASC.CAP.Enhanced.Config.EnableEnhancedIntegration then
        print("[ASC CAP Enhanced] Enhanced integration disabled")
        return false
    end
    
    -- Check if base CAP integration is available
    if not HYPERDRIVE or not HYPERDRIVE.CAP then
        print("[ASC CAP Enhanced] Base CAP integration not available")
        return false
    end
    
    -- Initialize subsystems
    ASC.CAP.Enhanced.ResourceBridge.Initialize()
    
    -- Start detection timer
    if ASC.CAP.Enhanced.Config.EnableRealTimeDetection then
        timer.Create("ASC_CAP_Enhanced_Detection", ASC.CAP.Enhanced.Config.DetectionInterval, 0, function()
            ASC.CAP.Enhanced.DetectCAPEntities(false)
        end)
    end
    
    print("[ASC CAP Enhanced] Enhanced CAP integration system initialized")
    return true
end

-- Initialize when ready
hook.Add("Initialize", "ASC_CAP_Enhanced_Init", function()
    timer.Simple(2, function()
        ASC.CAP.Enhanced.Initialize()
    end)
end)

print("[Advanced Space Combat] Enhanced CAP Integration System v3.0 - Loaded")
