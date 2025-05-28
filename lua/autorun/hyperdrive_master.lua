-- Hyperdrive Master Integration System
-- This file combines ALL hyperdrive features into a unified system

HYPERDRIVE.Master = HYPERDRIVE.Master or {}

-- Master configuration combining all systems
HYPERDRIVE.Master.Config = {
    -- Core System
    EnableCore = true,
    EnableAdvancedEffects = true,
    EnableSounds = true,
    
    -- Integration Systems
    EnableWiremod = true,
    EnableSpacebuild = true,
    EnableStargate = true,
    
    -- Performance Settings
    MaxActiveEngines = 50,
    EffectQuality = 1.0, -- 0.5 = low, 1.0 = normal, 2.0 = high
    NetworkUpdateRate = 0.5, -- seconds
    
    -- Master Bonuses (stack multiplicatively)
    MultiSystemBonus = 1.2, -- Bonus when multiple systems are integrated
    FleetCoordinationBonus = 1.1, -- Bonus for coordinated fleet operations
    NetworkEfficiencyBonus = 1.05, -- Bonus for beacon network usage
}

-- Unified entity detection and classification
function HYPERDRIVE.Master.ClassifyEntity(ent)
    if not IsValid(ent) then return nil end
    
    local class = ent:GetClass()
    local classification = {
        type = "unknown",
        category = "none",
        integrations = {},
        capabilities = {},
        efficiency = 1.0
    }
    
    -- Classify hyperdrive entities
    if string.find(class, "hyperdrive") then
        if string.find(class, "engine") then
            classification.type = "engine"
            classification.category = "propulsion"
            
            -- Determine engine variant
            if string.find(class, "sb_engine") then
                classification.integrations.spacebuild = true
                classification.capabilities.life_support = true
                classification.capabilities.resource_management = true
            end
            
            if string.find(class, "sg_engine") then
                classification.integrations.stargate = true
                classification.capabilities.technology_enhancement = true
                classification.capabilities.gate_network = true
            end
            
        elseif string.find(class, "computer") then
            classification.type = "computer"
            classification.category = "control"
            classification.capabilities.fleet_management = true
            
        elseif string.find(class, "beacon") then
            classification.type = "beacon"
            classification.category = "navigation"
            classification.capabilities.navigation = true
            classification.capabilities.network_node = true
            
        elseif string.find(class, "wire_controller") then
            classification.type = "controller"
            classification.category = "interface"
            classification.integrations.wiremod = true
            classification.capabilities.remote_control = true
        end
    end
    
    -- Check for external integrations
    if WireLib and ent.Inputs then
        classification.integrations.wiremod = true
    end
    
    if CAF and HYPERDRIVE.Spacebuild then
        local sbData = HYPERDRIVE.Spacebuild.HasStargateTech and HYPERDRIVE.Spacebuild.HasStargateTech(ent)
        if sbData and sbData.hasLifeSupport then
            classification.integrations.spacebuild = true
        end
    end
    
    if StarGate and HYPERDRIVE.Stargate then
        local sgData = HYPERDRIVE.Stargate.HasStargateTech and HYPERDRIVE.Stargate.HasStargateTech(ent)
        if sgData and sgData.hasGate then
            classification.integrations.stargate = true
            classification.efficiency = classification.efficiency * HYPERDRIVE.Stargate.GetTechBonus(sgData.techLevel)
        end
    end
    
    -- Calculate multi-system bonus
    local integrationCount = table.Count(classification.integrations)
    if integrationCount > 1 then
        classification.efficiency = classification.efficiency * HYPERDRIVE.Master.Config.MultiSystemBonus
    end
    
    return classification
end

-- Unified energy calculation system
function HYPERDRIVE.Master.CalculateEnergyCost(ent, startPos, endPos)
    local distance = HYPERDRIVE.GetDistance(startPos, endPos)
    local baseCost = HYPERDRIVE.CalculateEnergyCost(distance)
    local classification = HYPERDRIVE.Master.ClassifyEntity(ent)
    
    local totalModifier = classification.efficiency
    
    -- Apply Spacebuild modifiers
    if classification.integrations.spacebuild and HYPERDRIVE.Spacebuild then
        local envModifier = HYPERDRIVE.Spacebuild.GetEnvironmentModifier(startPos, endPos)
        totalModifier = totalModifier * envModifier
    end
    
    -- Apply Stargate modifiers
    if classification.integrations.stargate and HYPERDRIVE.Stargate then
        local sgModifier = HYPERDRIVE.Stargate.CalculateEnergyCost(ent, startPos, endPos, distance) / baseCost
        totalModifier = totalModifier * sgModifier
    end
    
    -- Apply network efficiency bonus
    if classification.capabilities.network_node then
        totalModifier = totalModifier * HYPERDRIVE.Master.Config.NetworkEfficiencyBonus
    end
    
    return baseCost * totalModifier
end

-- Unified resource consumption system
function HYPERDRIVE.Master.ConsumeResources(ent, operation)
    local classification = HYPERDRIVE.Master.ClassifyEntity(ent)
    local results = {}
    
    -- Spacebuild resource consumption
    if classification.integrations.spacebuild and HYPERDRIVE.Spacebuild then
        local success, message = HYPERDRIVE.Spacebuild.ConsumeResources(ent, operation)
        results.spacebuild = {success = success, message = message}
        if not success then return false, "Spacebuild: " .. message end
    end
    
    -- Stargate resource consumption
    if classification.integrations.stargate and HYPERDRIVE.Stargate then
        local success, message = HYPERDRIVE.Stargate.ConsumeResources(ent, operation)
        results.stargate = {success = success, message = message}
        if not success then return false, "Stargate: " .. message end
    end
    
    return true, "All systems nominal"
end

-- Unified capability checking
function HYPERDRIVE.Master.CanOperate(ent)
    local classification = HYPERDRIVE.Master.ClassifyEntity(ent)
    local issues = {}
    
    -- Check Spacebuild requirements
    if classification.integrations.spacebuild and HYPERDRIVE.Spacebuild then
        local canOperate, reason = HYPERDRIVE.Spacebuild.CanOperate(ent)
        if not canOperate then
            table.insert(issues, "Spacebuild: " .. reason)
        end
    end
    
    -- Check Stargate requirements
    if classification.integrations.stargate and HYPERDRIVE.Stargate then
        local sgData = HYPERDRIVE.Stargate.HasStargateTech(ent)
        if HYPERDRIVE.Stargate.Config.RequireNaquadah and not sgData.hasNaquadah then
            table.insert(issues, "Stargate: Naquadah required")
        end
    end
    
    -- Check core hyperdrive requirements
    if not IsValid(ent) then
        table.insert(issues, "Core: Invalid entity")
    end
    
    if #issues > 0 then
        return false, table.concat(issues, "; ")
    end
    
    return true, "All systems operational"
end

-- Unified fleet management system
function HYPERDRIVE.Master.GetFleetStatus(computer)
    if not IsValid(computer) or computer:GetClass() ~= "hyperdrive_computer" then
        return nil
    end
    
    local engines = computer.LinkedEngines or {}
    local fleetStatus = {
        total = #engines,
        online = 0,
        ready = 0,
        charging = 0,
        spacebuild = 0,
        stargate = 0,
        wiremod = 0,
        totalEnergy = 0,
        maxEnergy = 0,
        avgEfficiency = 1.0,
        capabilities = {}
    }
    
    local totalEfficiency = 0
    
    for _, engine in ipairs(engines) do
        if IsValid(engine) then
            fleetStatus.online = fleetStatus.online + 1
            
            local classification = HYPERDRIVE.Master.ClassifyEntity(engine)
            totalEfficiency = totalEfficiency + classification.efficiency
            
            -- Count integrations
            if classification.integrations.spacebuild then
                fleetStatus.spacebuild = fleetStatus.spacebuild + 1
            end
            if classification.integrations.stargate then
                fleetStatus.stargate = fleetStatus.stargate + 1
            end
            if classification.integrations.wiremod then
                fleetStatus.wiremod = fleetStatus.wiremod + 1
            end
            
            -- Energy status
            if engine.GetEnergy then
                fleetStatus.totalEnergy = fleetStatus.totalEnergy + engine:GetEnergy()
                local maxEnergy = (HYPERDRIVE.Config and HYPERDRIVE.Config.MaxEnergy) or 1000
                fleetStatus.maxEnergy = fleetStatus.maxEnergy + maxEnergy
            end
            
            -- Operational status
            if engine.GetCharging and engine:GetCharging() then
                fleetStatus.charging = fleetStatus.charging + 1
            elseif engine.CanJump and engine:CanJump() then
                fleetStatus.ready = fleetStatus.ready + 1
            end
            
            -- Collect capabilities
            for capability, _ in pairs(classification.capabilities) do
                fleetStatus.capabilities[capability] = (fleetStatus.capabilities[capability] or 0) + 1
            end
        end
    end
    
    if fleetStatus.online > 0 then
        fleetStatus.avgEfficiency = totalEfficiency / fleetStatus.online
    end
    
    return fleetStatus
end

-- Unified jump coordination system
function HYPERDRIVE.Master.ExecuteCoordinatedJump(entities, destination)
    if not destination or not isvector(destination) then
        return false, "Invalid destination"
    end
    
    local jumpQueue = {}
    local totalEnergyCost = 0
    
    -- Analyze and prepare all entities
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            local classification = HYPERDRIVE.Master.ClassifyEntity(ent)
            
            if classification.type == "engine" then
                local canOperate, reason = HYPERDRIVE.Master.CanOperate(ent)
                if canOperate then
                    local energyCost = HYPERDRIVE.Master.CalculateEnergyCost(ent, ent:GetPos(), destination)
                    
                    if ent.GetEnergy and ent:GetEnergy() >= energyCost then
                        table.insert(jumpQueue, {
                            entity = ent,
                            energyCost = energyCost,
                            classification = classification
                        })
                        totalEnergyCost = totalEnergyCost + energyCost
                    end
                end
            end
        end
    end
    
    if #jumpQueue == 0 then
        return false, "No engines ready for coordinated jump"
    end
    
    -- Execute coordinated jump sequence
    local jumpDelay = 0
    for i, jumpData in ipairs(jumpQueue) do
        timer.Simple(jumpDelay, function()
            if IsValid(jumpData.entity) then
                -- Consume resources
                HYPERDRIVE.Master.ConsumeResources(jumpData.entity, "jump")
                
                -- Set destination and execute
                if jumpData.entity.SetDestinationPos then
                    jumpData.entity:SetDestinationPos(destination)
                end
                if jumpData.entity.StartJump then
                    jumpData.entity:StartJump()
                end
            end
        end)
        
        -- Stagger jumps for better visual effect
        jumpDelay = jumpDelay + 0.2
    end
    
    return true, string.format("Coordinated jump initiated: %d engines", #jumpQueue)
end

-- Unified status reporting system
function HYPERDRIVE.Master.GetSystemStatus()
    local status = {
        core = {
            active = true,
            engines = 0,
            computers = 0,
            beacons = 0,
            controllers = 0
        },
        integrations = {
            wiremod = WireLib ~= nil,
            spacebuild = CAF ~= nil,
            stargate = StarGate ~= nil
        },
        performance = {
            activeEntities = 0,
            networkLoad = 0,
            effectQuality = HYPERDRIVE.Master.Config.EffectQuality
        }
    }
    
    -- Count active entities
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) then
            local classification = HYPERDRIVE.Master.ClassifyEntity(ent)
            if classification.type ~= "unknown" then
                status.performance.activeEntities = status.performance.activeEntities + 1
                
                if classification.type == "engine" then
                    status.core.engines = status.core.engines + 1
                elseif classification.type == "computer" then
                    status.core.computers = status.core.computers + 1
                elseif classification.type == "beacon" then
                    status.core.beacons = status.core.beacons + 1
                elseif classification.type == "controller" then
                    status.core.controllers = status.core.controllers + 1
                end
            end
        end
    end
    
    return status
end

-- Master console command
concommand.Add("hyperdrive_master_status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local status = HYPERDRIVE.Master.GetSystemStatus()
    
    ply:ChatPrint("[Hyperdrive Master] System Status Report:")
    ply:ChatPrint("=== CORE SYSTEM ===")
    ply:ChatPrint("  • Engines: " .. status.core.engines)
    ply:ChatPrint("  • Computers: " .. status.core.computers)
    ply:ChatPrint("  • Beacons: " .. status.core.beacons)
    ply:ChatPrint("  • Controllers: " .. status.core.controllers)
    
    ply:ChatPrint("=== INTEGRATIONS ===")
    ply:ChatPrint("  • Wiremod: " .. (status.integrations.wiremod and "ACTIVE" or "INACTIVE"))
    ply:ChatPrint("  • Spacebuild: " .. (status.integrations.spacebuild and "ACTIVE" or "INACTIVE"))
    ply:ChatPrint("  • Stargate: " .. (status.integrations.stargate and "ACTIVE" or "INACTIVE"))
    
    ply:ChatPrint("=== PERFORMANCE ===")
    ply:ChatPrint("  • Active Entities: " .. status.performance.activeEntities)
    ply:ChatPrint("  • Effect Quality: " .. status.performance.effectQuality .. "x")
end)

-- Master entity analysis command
concommand.Add("hyperdrive_analyze", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) then
        ply:ChatPrint("[Hyperdrive] Look at an entity to analyze")
        return
    end
    
    local classification = HYPERDRIVE.Master.ClassifyEntity(trace.Entity)
    
    ply:ChatPrint("[Hyperdrive] Entity Analysis:")
    ply:ChatPrint("  • Type: " .. classification.type)
    ply:ChatPrint("  • Category: " .. classification.category)
    ply:ChatPrint("  • Efficiency: " .. string.format("%.2fx", classification.efficiency))
    
    ply:ChatPrint("  • Integrations:")
    for integration, active in pairs(classification.integrations) do
        ply:ChatPrint("    - " .. integration .. ": " .. (active and "YES" or "NO"))
    end
    
    ply:ChatPrint("  • Capabilities:")
    for capability, active in pairs(classification.capabilities) do
        ply:ChatPrint("    - " .. capability .. ": " .. (active and "YES" or "NO"))
    end
    
    local canOperate, reason = HYPERDRIVE.Master.CanOperate(trace.Entity)
    ply:ChatPrint("  • Operational: " .. (canOperate and "YES" or "NO"))
    if not canOperate then
        ply:ChatPrint("    Reason: " .. reason)
    end
end)

print("[Hyperdrive] Master integration system loaded - ALL FEATURES UNIFIED")
