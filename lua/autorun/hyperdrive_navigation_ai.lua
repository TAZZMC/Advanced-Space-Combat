-- Hyperdrive AI Navigation System
-- This file provides intelligent navigation and pathfinding for the hyperdrive system

-- Ensure HYPERDRIVE table exists first
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Navigation = HYPERDRIVE.Navigation or {}
HYPERDRIVE.Navigation.Version = "2.0.0"

-- AI Navigation configuration
HYPERDRIVE.Navigation.Config = {
    -- AI settings
    EnableAI = true,
    LearningRate = 0.1,
    PathOptimization = true,
    PredictiveRouting = true,

    -- Navigation features
    AutoPilot = true,
    CollisionAvoidance = true,
    TrafficManagement = true,
    WeatherAwareness = true,

    -- Performance
    MaxPathNodes = 100,
    UpdateInterval = 0.5,
    CacheSize = 1000,

    -- Safety
    EmergencyProtocols = true,
    RedundantPaths = true,
    RiskAssessment = true
}

-- Navigation node system
HYPERDRIVE.Navigation.Nodes = {}
HYPERDRIVE.Navigation.Paths = {}
HYPERDRIVE.Navigation.Cache = {}

-- AI learning data
HYPERDRIVE.Navigation.AI = {
    jumpHistory = {},
    successRates = {},
    optimalPaths = {},
    hazardMap = {},
    trafficPatterns = {}
}

-- Create navigation node
function HYPERDRIVE.Navigation.CreateNode(pos, nodeType, data)
    local node = {
        id = util.CRC(tostring(pos) .. nodeType),
        position = pos,
        type = nodeType or "waypoint",
        connections = {},
        data = data or {},
        created = os.time(),
        usage = 0,
        successRate = 1.0,
        riskLevel = 0.0
    }

    HYPERDRIVE.Navigation.Nodes[node.id] = node
    return node
end

-- Connect two nodes
function HYPERDRIVE.Navigation.ConnectNodes(nodeId1, nodeId2, weight)
    local node1 = HYPERDRIVE.Navigation.Nodes[nodeId1]
    local node2 = HYPERDRIVE.Navigation.Nodes[nodeId2]

    if not node1 or not node2 then return false end

    weight = weight or node1.position:Distance(node2.position)

    node1.connections[nodeId2] = weight
    node2.connections[nodeId1] = weight

    return true
end

-- A* pathfinding algorithm with AI enhancements
function HYPERDRIVE.Navigation.FindPath(startPos, endPos, constraints)
    constraints = constraints or {}

    -- Check cache first
    local cacheKey = util.CRC(tostring(startPos) .. tostring(endPos) .. util.TableToJSON(constraints))
    if HYPERDRIVE.Navigation.Cache[cacheKey] then
        local cached = HYPERDRIVE.Navigation.Cache[cacheKey]
        if CurTime() - cached.timestamp < 300 then -- 5 minute cache
            return cached.path, cached.cost
        end
    end

    -- Find nearest nodes to start and end positions
    local startNode = HYPERDRIVE.Navigation.FindNearestNode(startPos)
    local endNode = HYPERDRIVE.Navigation.FindNearestNode(endPos)

    if not startNode or not endNode then
        -- Create temporary nodes if none exist
        startNode = HYPERDRIVE.Navigation.CreateNode(startPos, "temp_start")
        endNode = HYPERDRIVE.Navigation.CreateNode(endPos, "temp_end")
    end

    -- A* algorithm with AI enhancements
    local openSet = {startNode.id}
    local closedSet = {}
    local gScore = {[startNode.id] = 0}
    local fScore = {[startNode.id] = HYPERDRIVE.Navigation.Heuristic(startNode.position, endNode.position)}
    local cameFrom = {}

    while #openSet > 0 do
        -- Find node with lowest fScore
        local current = openSet[1]
        local currentIndex = 1

        for i, nodeId in ipairs(openSet) do
            if fScore[nodeId] < fScore[current] then
                current = nodeId
                currentIndex = i
            end
        end

        -- Remove current from openSet
        table.remove(openSet, currentIndex)
        closedSet[current] = true

        -- Check if we reached the goal
        if current == endNode.id then
            local path = HYPERDRIVE.Navigation.ReconstructPath(cameFrom, current)
            local totalCost = gScore[current]

            -- Cache the result
            HYPERDRIVE.Navigation.Cache[cacheKey] = {
                path = path,
                cost = totalCost,
                timestamp = CurTime()
            }

            return path, totalCost
        end

        -- Check all neighbors
        local currentNode = HYPERDRIVE.Navigation.Nodes[current]
        for neighborId, edgeWeight in pairs(currentNode.connections) do
            if not closedSet[neighborId] then
                local neighbor = HYPERDRIVE.Navigation.Nodes[neighborId]

                -- Calculate AI-enhanced edge weight
                local aiWeight = HYPERDRIVE.Navigation.CalculateAIWeight(currentNode, neighbor, constraints)
                local tentativeGScore = gScore[current] + edgeWeight * aiWeight

                if not gScore[neighborId] or tentativeGScore < gScore[neighborId] then
                    cameFrom[neighborId] = current
                    gScore[neighborId] = tentativeGScore
                    fScore[neighborId] = gScore[neighborId] + HYPERDRIVE.Navigation.Heuristic(neighbor.position, endNode.position)

                    -- Add to open set if not already there
                    local inOpenSet = false
                    for _, id in ipairs(openSet) do
                        if id == neighborId then
                            inOpenSet = true
                            break
                        end
                    end

                    if not inOpenSet then
                        table.insert(openSet, neighborId)
                    end
                end
            end
        end
    end

    return nil, math.huge -- No path found
end

-- AI-enhanced weight calculation
function HYPERDRIVE.Navigation.CalculateAIWeight(node1, node2, constraints)
    local baseWeight = 1.0

    -- Risk assessment
    local riskFactor = (node1.riskLevel + node2.riskLevel) / 2
    baseWeight = baseWeight * (1 + riskFactor)

    -- Success rate consideration
    local successFactor = (node1.successRate + node2.successRate) / 2
    baseWeight = baseWeight * (2 - successFactor)

    -- Traffic consideration
    local trafficFactor = HYPERDRIVE.Navigation.GetTrafficFactor(node1, node2)
    baseWeight = baseWeight * (1 + trafficFactor * 0.5)

    -- Constraint penalties
    if constraints.avoidHazards and (node1.riskLevel > 0.5 or node2.riskLevel > 0.5) then
        baseWeight = baseWeight * 2.0
    end

    if constraints.preferSafe and successFactor < 0.8 then
        baseWeight = baseWeight * 1.5
    end

    if constraints.fastRoute and trafficFactor > 0.3 then
        baseWeight = baseWeight * 1.3
    end

    return baseWeight
end

-- Heuristic function for A*
function HYPERDRIVE.Navigation.Heuristic(pos1, pos2)
    return pos1:Distance(pos2)
end

-- Reconstruct path from A* result
function HYPERDRIVE.Navigation.ReconstructPath(cameFrom, current)
    local path = {current}

    while cameFrom[current] do
        current = cameFrom[current]
        table.insert(path, 1, current)
    end

    return path
end

-- Find nearest navigation node
function HYPERDRIVE.Navigation.FindNearestNode(pos)
    local nearestNode = nil
    local nearestDistance = math.huge

    for _, node in pairs(HYPERDRIVE.Navigation.Nodes) do
        local distance = pos:Distance(node.position)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestNode = node
        end
    end

    return nearestNode
end

-- Traffic management system
function HYPERDRIVE.Navigation.GetTrafficFactor(node1, node2)
    local currentTime = CurTime()
    local trafficKey = node1.id .. "_" .. node2.id

    -- Check recent traffic on this route
    local recentTraffic = 0
    for _, jump in ipairs(HYPERDRIVE.Navigation.AI.jumpHistory) do
        if currentTime - jump.timestamp < 300 then -- Last 5 minutes
            if (jump.startNode == node1.id and jump.endNode == node2.id) or
               (jump.startNode == node2.id and jump.endNode == node1.id) then
                recentTraffic = recentTraffic + 1
            end
        end
    end

    return math.min(1.0, recentTraffic / 10) -- Normalize to 0-1
end

-- AI learning system
function HYPERDRIVE.Navigation.RecordJump(startPos, endPos, success, duration, energy)
    local jump = {
        startPos = startPos,
        endPos = endPos,
        startNode = HYPERDRIVE.Navigation.FindNearestNode(startPos),
        endNode = HYPERDRIVE.Navigation.FindNearestNode(endPos),
        success = success,
        duration = duration,
        energy = energy,
        timestamp = CurTime()
    }

    table.insert(HYPERDRIVE.Navigation.AI.jumpHistory, jump)

    -- Limit history size
    if #HYPERDRIVE.Navigation.AI.jumpHistory > 1000 then
        table.remove(HYPERDRIVE.Navigation.AI.jumpHistory, 1)
    end

    -- Update node success rates
    if jump.startNode and jump.endNode then
        HYPERDRIVE.Navigation.UpdateNodeStats(jump.startNode.id, success)
        HYPERDRIVE.Navigation.UpdateNodeStats(jump.endNode.id, success)
    end

    -- Learn from the jump
    HYPERDRIVE.Navigation.LearnFromJump(jump)
end

-- Update node statistics
function HYPERDRIVE.Navigation.UpdateNodeStats(nodeId, success)
    local node = HYPERDRIVE.Navigation.Nodes[nodeId]
    if not node then return end

    node.usage = node.usage + 1

    -- Update success rate with learning rate
    local learningRate = HYPERDRIVE.Navigation.Config.LearningRate
    if success then
        node.successRate = node.successRate + learningRate * (1 - node.successRate)
    else
        node.successRate = node.successRate - learningRate * node.successRate
        node.riskLevel = math.min(1.0, node.riskLevel + learningRate * 0.1)
    end
end

-- AI learning from jump data
function HYPERDRIVE.Navigation.LearnFromJump(jump)
    if not HYPERDRIVE.Navigation.Config.EnableAI then return end

    -- Learn optimal paths
    if jump.success and jump.duration and jump.energy then
        local efficiency = 1000 / (jump.duration + jump.energy / 100) -- Simple efficiency metric

        local pathKey = tostring(jump.startPos) .. "_" .. tostring(jump.endPos)
        if not HYPERDRIVE.Navigation.AI.optimalPaths[pathKey] or
           HYPERDRIVE.Navigation.AI.optimalPaths[pathKey].efficiency < efficiency then
            HYPERDRIVE.Navigation.AI.optimalPaths[pathKey] = {
                startPos = jump.startPos,
                endPos = jump.endPos,
                efficiency = efficiency,
                timestamp = CurTime()
            }
        end
    end

    -- Learn hazard patterns
    if not jump.success then
        local hazardKey = tostring(jump.endPos)
        HYPERDRIVE.Navigation.AI.hazardMap[hazardKey] = (HYPERDRIVE.Navigation.AI.hazardMap[hazardKey] or 0) + 1
    end
end

-- Predictive routing
function HYPERDRIVE.Navigation.PredictOptimalRoute(startPos, endPos, constraints)
    if not HYPERDRIVE.Navigation.Config.PredictiveRouting then
        return HYPERDRIVE.Navigation.FindPath(startPos, endPos, constraints)
    end

    -- Check if we have learned an optimal path
    local pathKey = tostring(startPos) .. "_" .. tostring(endPos)
    local optimalPath = HYPERDRIVE.Navigation.AI.optimalPaths[pathKey]

    if optimalPath and CurTime() - optimalPath.timestamp < 3600 then -- 1 hour validity
        return {optimalPath.startPos, optimalPath.endPos}, optimalPath.efficiency
    end

    -- Use standard pathfinding with AI enhancements
    return HYPERDRIVE.Navigation.FindPath(startPos, endPos, constraints)
end

-- Auto-pilot system
function HYPERDRIVE.Navigation.EnableAutoPilot(engine, destination, options)
    if not HYPERDRIVE.Navigation.Config.AutoPilot then return false end
    if not IsValid(engine) then return false end

    options = options or {}

    local autoPilot = {
        engine = engine,
        destination = destination,
        options = options,
        active = true,
        startTime = CurTime(),
        waypoints = {},
        currentWaypoint = 1
    }

    -- Calculate route
    local path, cost = HYPERDRIVE.Navigation.PredictOptimalRoute(
        engine:GetPos(),
        destination,
        {
            avoidHazards = options.safe or false,
            preferSafe = options.safe or false,
            fastRoute = options.fast or false
        }
    )

    if not path then return false end

    -- Convert path to waypoints
    for _, nodeId in ipairs(path) do
        local node = HYPERDRIVE.Navigation.Nodes[nodeId]
        if node then
            table.insert(autoPilot.waypoints, node.position)
        end
    end

    -- Store auto-pilot data
    engine.AutoPilot = autoPilot

    -- Start auto-pilot timer
    timer.Create("AutoPilot_" .. engine:EntIndex(), 1, 0, function()
        if IsValid(engine) and engine.AutoPilot and engine.AutoPilot.active then
            HYPERDRIVE.Navigation.UpdateAutoPilot(engine)
        else
            timer.Remove("AutoPilot_" .. engine:EntIndex())
        end
    end)

    return true
end

-- Update auto-pilot system
function HYPERDRIVE.Navigation.UpdateAutoPilot(engine)
    local autoPilot = engine.AutoPilot
    if not autoPilot or not autoPilot.active then return end

    -- Check if we've reached the current waypoint
    local currentPos = engine:GetPos()
    local currentWaypoint = autoPilot.waypoints[autoPilot.currentWaypoint]

    if currentWaypoint and currentPos:Distance(currentWaypoint) < 500 then
        autoPilot.currentWaypoint = autoPilot.currentWaypoint + 1

        -- Check if we've reached the final destination
        if autoPilot.currentWaypoint > #autoPilot.waypoints then
            autoPilot.active = false
            if engine.Owner and IsValid(engine.Owner) then
                engine.Owner:ChatPrint("[Hyperdrive] Auto-pilot destination reached")
            end
            return
        end
    end

    -- Set next waypoint as destination
    local nextWaypoint = autoPilot.waypoints[autoPilot.currentWaypoint]
    if nextWaypoint and engine.SetDestinationPos then
        engine:SetDestinationPos(nextWaypoint)

        -- Auto-jump if ready
        if engine.CanJump and engine:CanJump() and engine.StartJump then
            local success, message = engine:StartJump()
            if not success and engine.Owner and IsValid(engine.Owner) then
                engine.Owner:ChatPrint("[Hyperdrive Auto-pilot] " .. message)
            end
        end
    end
end

-- Console commands for navigation
concommand.Add("hyperdrive_nav_create_node", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not trace.Hit then
        ply:ChatPrint("[Hyperdrive Nav] Look at a location to create a node")
        return
    end

    local nodeType = args[1] or "waypoint"
    local node = HYPERDRIVE.Navigation.CreateNode(trace.HitPos, nodeType)

    ply:ChatPrint("[Hyperdrive Nav] Created " .. nodeType .. " node at " .. tostring(trace.HitPos))
end)

concommand.Add("hyperdrive_nav_auto_pilot", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or not string.find(trace.Entity:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive Nav] Look at a hyperdrive engine")
        return
    end

    local destination = ply:GetPos() + ply:GetAimVector() * 5000
    local options = {
        safe = args[1] == "safe",
        fast = args[1] == "fast"
    }

    local success = HYPERDRIVE.Navigation.EnableAutoPilot(trace.Entity, destination, options)
    if success then
        ply:ChatPrint("[Hyperdrive Nav] Auto-pilot enabled")
    else
        ply:ChatPrint("[Hyperdrive Nav] Failed to enable auto-pilot")
    end
end)

print("[Hyperdrive] AI Navigation system loaded")
