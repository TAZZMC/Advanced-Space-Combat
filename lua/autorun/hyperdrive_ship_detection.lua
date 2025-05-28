-- Hyperdrive Advanced Ship Detection and Classification System
-- Intelligent ship detection, classification, and optimization

if CLIENT then return end

-- Initialize ship detection system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.ShipDetection = HYPERDRIVE.ShipDetection or {}

print("[Hyperdrive] Advanced ship detection system loading...")

-- Ship classification types
HYPERDRIVE.ShipDetection.ShipTypes = {
    FIGHTER = {name = "Fighter", maxEntities = 10, energyMultiplier = 0.8},
    CORVETTE = {name = "Corvette", maxEntities = 25, energyMultiplier = 1.0},
    FRIGATE = {name = "Frigate", maxEntities = 50, energyMultiplier = 1.2},
    DESTROYER = {name = "Destroyer", maxEntities = 100, energyMultiplier = 1.5},
    CRUISER = {name = "Cruiser", maxEntities = 200, energyMultiplier = 2.0},
    BATTLESHIP = {name = "Battleship", maxEntities = 400, energyMultiplier = 3.0},
    DREADNOUGHT = {name = "Dreadnought", maxEntities = 800, energyMultiplier = 4.0},
    TITAN = {name = "Titan", maxEntities = 1600, energyMultiplier = 6.0},
    MEGASTRUCTURE = {name = "Megastructure", maxEntities = 99999, energyMultiplier = 10.0}
}

-- Ship detection configuration
HYPERDRIVE.ShipDetection.Config = {
    EnableClassification = true,    -- Enable ship classification
    EnableOptimization = true,      -- Enable ship-specific optimizations
    CacheClassifications = true,    -- Cache ship classifications
    DetailedAnalysis = false,       -- Enable detailed ship analysis
    AutoOptimize = true,            -- Automatically optimize based on ship type
}

-- Ship classification cache
HYPERDRIVE.ShipDetection.ClassificationCache = {}

-- Function to get configuration with fallback
local function GetDetectionConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("ShipDetection", key, HYPERDRIVE.ShipDetection.Config[key] or default)
    end
    return HYPERDRIVE.ShipDetection.Config[key] or default
end

-- Analyze ship composition
function HYPERDRIVE.ShipDetection.AnalyzeShipComposition(entities)
    local composition = {
        totalEntities = #entities,
        players = 0,
        vehicles = 0,
        props = 0,
        weapons = 0,
        engines = 0,
        lifesupport = 0,
        other = 0,
        totalMass = 0,
        boundingBox = {min = Vector(0,0,0), max = Vector(0,0,0)}
    }
    
    local minPos = Vector(math.huge, math.huge, math.huge)
    local maxPos = Vector(-math.huge, -math.huge, -math.huge)
    
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            local pos = ent:GetPos()
            
            -- Update bounding box
            if pos.x < minPos.x then minPos.x = pos.x end
            if pos.y < minPos.y then minPos.y = pos.y end
            if pos.z < minPos.z then minPos.z = pos.z end
            if pos.x > maxPos.x then maxPos.x = pos.x end
            if pos.y > maxPos.y then maxPos.y = pos.y end
            if pos.z > maxPos.z then maxPos.z = pos.z end
            
            -- Classify entity type
            local class = ent:GetClass()
            if ent:IsPlayer() then
                composition.players = composition.players + 1
            elseif ent:IsVehicle() then
                composition.vehicles = composition.vehicles + 1
            elseif class == "prop_physics" then
                composition.props = composition.props + 1
            elseif string.find(class, "weapon") or string.find(class, "turret") then
                composition.weapons = composition.weapons + 1
            elseif string.find(class, "engine") or string.find(class, "thruster") then
                composition.engines = composition.engines + 1
            elseif string.find(class, "life") or string.find(class, "oxygen") then
                composition.lifesupport = composition.lifesupport + 1
            else
                composition.other = composition.other + 1
            end
            
            -- Calculate mass
            if ent:GetPhysicsObject():IsValid() then
                composition.totalMass = composition.totalMass + ent:GetPhysicsObject():GetMass()
            end
        end
    end
    
    composition.boundingBox.min = minPos
    composition.boundingBox.max = maxPos
    composition.dimensions = maxPos - minPos
    composition.volume = composition.dimensions.x * composition.dimensions.y * composition.dimensions.z
    
    return composition
end

-- Classify ship based on composition
function HYPERDRIVE.ShipDetection.ClassifyShip(engine, entities)
    if not GetDetectionConfig("EnableClassification", true) then
        return HYPERDRIVE.ShipDetection.ShipTypes.CORVETTE -- Default
    end
    
    -- Check cache first
    local cacheKey = tostring(engine)
    if GetDetectionConfig("CacheClassifications", true) then
        local cached = HYPERDRIVE.ShipDetection.ClassificationCache[cacheKey]
        if cached and CurTime() - cached.timestamp < 60 then -- 1 minute cache
            return cached.shipType, cached.composition
        end
    end
    
    local composition = HYPERDRIVE.ShipDetection.AnalyzeShipComposition(entities)
    local shipType = HYPERDRIVE.ShipDetection.ShipTypes.CORVETTE -- Default
    
    -- Classify based on entity count
    local entityCount = composition.totalEntities
    
    if entityCount <= 10 then
        shipType = HYPERDRIVE.ShipDetection.ShipTypes.FIGHTER
    elseif entityCount <= 25 then
        shipType = HYPERDRIVE.ShipDetection.ShipTypes.CORVETTE
    elseif entityCount <= 50 then
        shipType = HYPERDRIVE.ShipDetection.ShipTypes.FRIGATE
    elseif entityCount <= 100 then
        shipType = HYPERDRIVE.ShipDetection.ShipTypes.DESTROYER
    elseif entityCount <= 200 then
        shipType = HYPERDRIVE.ShipDetection.ShipTypes.CRUISER
    elseif entityCount <= 400 then
        shipType = HYPERDRIVE.ShipDetection.ShipTypes.BATTLESHIP
    elseif entityCount <= 800 then
        shipType = HYPERDRIVE.ShipDetection.ShipTypes.DREADNOUGHT
    elseif entityCount <= 1600 then
        shipType = HYPERDRIVE.ShipDetection.ShipTypes.TITAN
    else
        shipType = HYPERDRIVE.ShipDetection.ShipTypes.MEGASTRUCTURE
    end
    
    -- Adjust classification based on mass and volume
    if composition.totalMass > 50000 then -- Very heavy ship
        if shipType == HYPERDRIVE.ShipDetection.ShipTypes.FIGHTER then
            shipType = HYPERDRIVE.ShipDetection.ShipTypes.CORVETTE
        elseif shipType == HYPERDRIVE.ShipDetection.ShipTypes.CORVETTE then
            shipType = HYPERDRIVE.ShipDetection.ShipTypes.FRIGATE
        end
    end
    
    if composition.volume > 10000000 then -- Very large ship
        if entityCount < 100 then
            shipType = HYPERDRIVE.ShipDetection.ShipTypes.CRUISER
        end
    end
    
    -- Cache the result
    if GetDetectionConfig("CacheClassifications", true) then
        HYPERDRIVE.ShipDetection.ClassificationCache[cacheKey] = {
            shipType = shipType,
            composition = composition,
            timestamp = CurTime()
        }
    end
    
    return shipType, composition
end

-- Calculate optimized energy cost based on ship type
function HYPERDRIVE.ShipDetection.CalculateOptimizedEnergyCost(engine, destination, entities)
    local distance = engine:GetPos():Distance(destination)
    local baseCost = distance * 0.1
    
    if not GetDetectionConfig("EnableOptimization", true) then
        return baseCost
    end
    
    local shipType, composition = HYPERDRIVE.ShipDetection.ClassifyShip(engine, entities)
    
    -- Apply ship type multiplier
    local energyCost = baseCost * shipType.energyMultiplier
    
    -- Apply mass factor
    local massFactor = math.max(0.5, math.min(3.0, composition.totalMass / 10000))
    energyCost = energyCost * massFactor
    
    -- Apply efficiency bonuses
    local efficiencyBonus = 1.0
    
    -- SC2 gyropod bonus
    if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.FindGyropod then
        local gyropod = HYPERDRIVE.SpaceCombat2.FindGyropod(engine)
        if IsValid(gyropod) then
            efficiencyBonus = efficiencyBonus * 0.85 -- 15% bonus
        end
    end
    
    -- SB3 life support bonus
    if HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.GetLifeSupportStatus then
        local status = HYPERDRIVE.Spacebuild.GetLifeSupportStatus(engine)
        if status.hasLifeSupport then
            efficiencyBonus = efficiencyBonus * 0.9 -- 10% bonus
        end
    end
    
    return energyCost * efficiencyBonus
end

-- Get optimized movement strategy based on ship type
function HYPERDRIVE.ShipDetection.GetOptimizedMovementStrategy(engine, entities)
    if not GetDetectionConfig("AutoOptimize", true) then
        return "standard"
    end
    
    local shipType, composition = HYPERDRIVE.ShipDetection.ClassifyShip(engine, entities)
    
    -- Determine best movement strategy
    if composition.totalEntities > 200 then
        return "batch" -- Use batch movement for large ships
    elseif composition.totalEntities > 50 then
        return "optimized" -- Use optimized movement for medium ships
    else
        return "standard" -- Use standard movement for small ships
    end
end

-- Enhanced ship detection with classification
function HYPERDRIVE.ShipDetection.DetectAndClassifyShip(engine, searchRadius)
    local entities = {}
    
    -- Use performance-optimized detection if available
    if HYPERDRIVE.Performance and HYPERDRIVE.Performance.OptimizedEntityDetection then
        entities = HYPERDRIVE.Performance.OptimizedEntityDetection(engine, searchRadius)
    else
        -- Fallback to basic detection
        entities = ents.FindInSphere(engine:GetPos(), searchRadius or 1000)
    end
    
    local shipType, composition = HYPERDRIVE.ShipDetection.ClassifyShip(engine, entities)
    
    return {
        entities = entities,
        shipType = shipType,
        composition = composition,
        movementStrategy = HYPERDRIVE.ShipDetection.GetOptimizedMovementStrategy(engine, entities)
    }
end

-- Ship analysis report
function HYPERDRIVE.ShipDetection.GenerateShipReport(engine)
    local detection = HYPERDRIVE.ShipDetection.DetectAndClassifyShip(engine)
    
    local report = {
        "Ship Analysis Report",
        "==================",
        "Ship Type: " .. detection.shipType.name,
        "Total Entities: " .. detection.composition.totalEntities,
        "Total Mass: " .. string.format("%.1f tons", detection.composition.totalMass / 1000),
        "Dimensions: " .. string.format("%.1f x %.1f x %.1f", 
            detection.composition.dimensions.x,
            detection.composition.dimensions.y,
            detection.composition.dimensions.z),
        "Volume: " .. string.format("%.1f m³", detection.composition.volume),
        "",
        "Entity Breakdown:",
        "  Players: " .. detection.composition.players,
        "  Vehicles: " .. detection.composition.vehicles,
        "  Props: " .. detection.composition.props,
        "  Weapons: " .. detection.composition.weapons,
        "  Engines: " .. detection.composition.engines,
        "  Life Support: " .. detection.composition.lifesupport,
        "  Other: " .. detection.composition.other,
        "",
        "Optimization:",
        "  Movement Strategy: " .. detection.movementStrategy,
        "  Energy Multiplier: " .. detection.shipType.energyMultiplier .. "x"
    }
    
    return table.concat(report, "\n")
end

-- Console commands for ship detection
concommand.Add("hyperdrive_ship_analyze", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or not string.find(trace.Entity:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive] Look at a hyperdrive engine")
        return
    end
    
    local report = HYPERDRIVE.ShipDetection.GenerateShipReport(trace.Entity)
    
    -- Send report to player (split into multiple chat messages)
    local lines = string.Split(report, "\n")
    for _, line in ipairs(lines) do
        ply:ChatPrint(line)
    end
end)

concommand.Add("hyperdrive_ship_classify", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or not string.find(trace.Entity:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive] Look at a hyperdrive engine")
        return
    end
    
    local detection = HYPERDRIVE.ShipDetection.DetectAndClassifyShip(trace.Entity)
    
    ply:ChatPrint("[Hyperdrive] Ship Classification:")
    ply:ChatPrint("  • Type: " .. detection.shipType.name)
    ply:ChatPrint("  • Entities: " .. detection.composition.totalEntities)
    ply:ChatPrint("  • Mass: " .. string.format("%.1f tons", detection.composition.totalMass / 1000))
    ply:ChatPrint("  • Strategy: " .. detection.movementStrategy)
    ply:ChatPrint("  • Energy Multiplier: " .. detection.shipType.energyMultiplier .. "x")
end)

-- Clean up cache periodically
timer.Create("HyperdriveShipDetectionCleanup", 300, 0, function() -- Every 5 minutes
    local currentTime = CurTime()
    for key, cached in pairs(HYPERDRIVE.ShipDetection.ClassificationCache) do
        if currentTime - cached.timestamp > 300 then -- 5 minute cache
            HYPERDRIVE.ShipDetection.ClassificationCache[key] = nil
        end
    end
end)

print("[Hyperdrive] Advanced ship detection system loaded")
