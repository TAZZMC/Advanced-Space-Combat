-- Enhanced Hyperdrive Tactical AI System v2.2.1
-- Advanced AI for automated combat management and tactical decisions

print("[Hyperdrive Weapons] Tactical AI System v2.2.1 - Initializing...")

-- Initialize tactical AI namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.TacticalAI = HYPERDRIVE.TacticalAI or {}

-- Tactical AI configuration
HYPERDRIVE.TacticalAI.Config = {
    -- AI Behavior Settings
    UpdateRate = 0.5, -- AI thinks every 0.5 seconds
    ScanRange = 5000, -- Range to scan for threats
    EngagementRange = 3000, -- Range to engage targets
    RetreatThreshold = 0.2, -- Retreat when health below 20%
    
    -- Target Priority System
    TargetPriorities = {
        ["ship_core"] = 100, -- Highest priority
        ["hyperdrive_"] = 80, -- Weapon systems
        ["player"] = 70, -- Players
        ["npc_"] = 60, -- NPCs
        ["prop_"] = 20, -- Props
        ["default"] = 10 -- Everything else
    },
    
    -- Weapon Selection AI
    WeaponSelection = {
        close_range = {"hyperdrive_pulse_cannon", "hyperdrive_plasma_cannon"},
        medium_range = {"hyperdrive_beam_weapon", "hyperdrive_torpedo_launcher"},
        long_range = {"hyperdrive_railgun"},
        point_defense = {"hyperdrive_point_defense"}
    },
    
    -- Tactical Behaviors
    Behaviors = {
        aggressive = {
            engagementRange = 1.2, -- 120% of base range
            retreatThreshold = 0.1, -- Retreat at 10% health
            fireRate = 1.5, -- 150% fire rate
            targetSwitching = 0.3 -- Switch targets frequently
        },
        defensive = {
            engagementRange = 0.8, -- 80% of base range
            retreatThreshold = 0.4, -- Retreat at 40% health
            fireRate = 1.0, -- Normal fire rate
            targetSwitching = 0.1 -- Stick to targets
        },
        balanced = {
            engagementRange = 1.0, -- Normal range
            retreatThreshold = 0.2, -- Retreat at 20% health
            fireRate = 1.0, -- Normal fire rate
            targetSwitching = 0.2 -- Moderate target switching
        }
    }
}

-- AI instances registry
HYPERDRIVE.TacticalAI.AIInstances = {}

-- Tactical AI class
local TacticalAI = {}
TacticalAI.__index = TacticalAI

function TacticalAI:New(shipCore, behavior)
    local ai = setmetatable({}, TacticalAI)

    ai.shipCore = shipCore
    ai.behavior = behavior or "balanced"
    ai.active = true
    ai.lastUpdate = 0
    ai.currentTarget = nil
    ai.threatList = {}
    ai.weaponGroups = {}
    ai.tacticalState = "patrol" -- patrol, engage, retreat, regroup
    ai.lastThreatScan = 0
    ai.engagementStartTime = 0
    ai.retreatPosition = nil

    -- Enhanced AI integration with ARIA-3
    ai.ARIA3Enhanced = true
    ai.AIDecisionHistory = {}
    ai.AILearningData = {
        successful_engagements = 0,
        failed_engagements = 0,
        preferred_tactics = {},
        threat_response_patterns = {},
        efficiency_scores = {}
    }

    -- AI Statistics
    ai.stats = {
        targetsEngaged = 0,
        shotsfired = 0,
        hits = 0,
        damageDealt = 0,
        damageTaken = 0,
        retreats = 0,
        aiDecisions = 0,
        successfulDecisions = 0
    }

    -- Integrate with ARIA-3 if available
    if ASC and ASC.AI and ASC.AI.AddonIntegration then
        ASC.AI.AddonIntegration.IntegrateWithTacticalAI(ai)
    end

    return ai
end

function TacticalAI:Update()
    if not self.active or not IsValid(self.shipCore) then return end
    
    local currentTime = CurTime()
    if currentTime - self.lastUpdate < HYPERDRIVE.TacticalAI.Config.UpdateRate then return end
    
    -- Update threat assessment
    self:UpdateThreatAssessment()
    
    -- Make tactical decisions
    self:MakeTacticalDecisions()
    
    -- Execute current tactical state
    self:ExecuteTacticalState()
    
    -- Update weapon groups
    self:UpdateWeaponGroups()
    
    self.lastUpdate = currentTime
end

function TacticalAI:UpdateThreatAssessment()
    local currentTime = CurTime()
    if currentTime - self.lastThreatScan < 1.0 then return end -- Scan every second
    
    self.threatList = {}
    local shipPos = self.shipCore:GetPos()
    local scanRange = HYPERDRIVE.TacticalAI.Config.ScanRange
    
    -- Scan for potential threats
    local entities = ents.FindInSphere(shipPos, scanRange)
    for _, ent in ipairs(entities) do
        if self:IsValidThreat(ent) then
            local threat = self:AnalyzeThreat(ent)
            if threat then
                table.insert(self.threatList, threat)
            end
        end
    end
    
    -- Sort threats by priority
    table.sort(self.threatList, function(a, b)
        return a.priority > b.priority
    end)
    
    self.lastThreatScan = currentTime
end

function TacticalAI:IsValidThreat(ent)
    if not IsValid(ent) then return false end
    if ent == self.shipCore then return false end
    
    -- Check if it's part of our ship
    if HYPERDRIVE.ShipCore then
        local ourShip = HYPERDRIVE.ShipCore.GetShip(self.shipCore)
        local entShip = HYPERDRIVE.ShipCore.GetShipByEntity(ent)
        if ourShip and entShip and ourShip == entShip then
            return false -- Same ship
        end
    end
    
    -- Check if it's a valid target type
    local entClass = ent:GetClass()
    if ent:IsPlayer() or ent:IsNPC() then return true end
    if string.find(entClass, "ship_core") then return true end
    if string.find(entClass, "hyperdrive_") then return true end
    if string.find(entClass, "weapon") then return true end
    
    return false
end

function TacticalAI:AnalyzeThreat(ent)
    local shipPos = self.shipCore:GetPos()
    local entPos = ent:GetPos()
    local distance = shipPos:Distance(entPos)
    
    -- Calculate base priority
    local priority = 0
    local entClass = ent:GetClass()
    
    for pattern, value in pairs(HYPERDRIVE.TacticalAI.Config.TargetPriorities) do
        if pattern == "default" or string.find(entClass, pattern) then
            priority = math.max(priority, value)
        end
    end
    
    -- Adjust priority based on distance
    local distanceFactor = math.max(0, 1 - (distance / HYPERDRIVE.TacticalAI.Config.ScanRange))
    priority = priority * distanceFactor
    
    -- Adjust priority based on threat level
    if ent:IsPlayer() then
        priority = priority * 1.5 -- Players are more dangerous
    end
    
    if ent:Health() and ent:Health() > 0 then
        local healthFactor = ent:Health() / (ent:GetMaxHealth() or ent:Health())
        priority = priority * (0.5 + healthFactor * 0.5) -- Prefer damaged targets
    end
    
    return {
        entity = ent,
        priority = priority,
        distance = distance,
        lastSeen = CurTime(),
        threatLevel = self:CalculateThreatLevel(ent)
    }
end

function TacticalAI:CalculateThreatLevel(ent)
    local threatLevel = 1
    
    -- Check if entity has weapons
    if string.find(ent:GetClass(), "weapon") or string.find(ent:GetClass(), "hyperdrive_") then
        threatLevel = threatLevel + 2
    end
    
    -- Check if it's a ship core (high threat)
    if string.find(ent:GetClass(), "ship_core") then
        threatLevel = threatLevel + 3
    end
    
    -- Check if it's a player (unpredictable)
    if ent:IsPlayer() then
        threatLevel = threatLevel + 1
    end
    
    return threatLevel
end

function TacticalAI:MakeTacticalDecisions()
    local behaviorConfig = HYPERDRIVE.TacticalAI.Config.Behaviors[self.behavior]
    local shipHealth = self:GetShipHealth()
    
    -- Check if we should retreat
    if shipHealth < behaviorConfig.retreatThreshold then
        if self.tacticalState ~= "retreat" then
            self.tacticalState = "retreat"
            self.stats.retreats = self.stats.retreats + 1
            print("[Tactical AI] Ship " .. self.shipCore:EntIndex() .. " retreating - low health")
        end
        return
    end
    
    -- Check for threats in engagement range
    local engagementRange = HYPERDRIVE.TacticalAI.Config.EngagementRange * behaviorConfig.engagementRange
    local threatsInRange = {}
    
    for _, threat in ipairs(self.threatList) do
        if threat.distance <= engagementRange then
            table.insert(threatsInRange, threat)
        end
    end
    
    if #threatsInRange > 0 then
        -- Engage threats
        if self.tacticalState ~= "engage" then
            self.tacticalState = "engage"
            self.engagementStartTime = CurTime()
            print("[Tactical AI] Ship " .. self.shipCore:EntIndex() .. " engaging " .. #threatsInRange .. " threats")
        end
        
        -- Select primary target
        self:SelectPrimaryTarget(threatsInRange)
    else
        -- No immediate threats - patrol
        if self.tacticalState ~= "patrol" then
            self.tacticalState = "patrol"
            self.currentTarget = nil
            print("[Tactical AI] Ship " .. self.shipCore:EntIndex() .. " returning to patrol")
        end
    end
end

function TacticalAI:SelectPrimaryTarget(threats)
    local behaviorConfig = HYPERDRIVE.TacticalAI.Config.Behaviors[self.behavior]
    
    -- Check if we should switch targets
    local shouldSwitch = false
    
    if not self.currentTarget or not IsValid(self.currentTarget.entity) then
        shouldSwitch = true
    elseif math.random() < behaviorConfig.targetSwitching then
        shouldSwitch = true
    end
    
    if shouldSwitch and #threats > 0 then
        self.currentTarget = threats[1] -- Highest priority threat
        self.stats.targetsEngaged = self.stats.targetsEngaged + 1
        print("[Tactical AI] Target selected: " .. self.currentTarget.entity:GetClass())
    end
end

function TacticalAI:ExecuteTacticalState()
    if self.tacticalState == "engage" then
        self:ExecuteEngagement()
    elseif self.tacticalState == "retreat" then
        self:ExecuteRetreat()
    elseif self.tacticalState == "patrol" then
        self:ExecutePatrol()
    end
end

function TacticalAI:ExecuteEngagement()
    if not self.currentTarget or not IsValid(self.currentTarget.entity) then return end
    
    -- Set target for all weapon groups
    for groupId, group in pairs(HYPERDRIVE.WeaponGroups.Groups) do
        if group.shipCore == self.shipCore then
            group:SetTarget(self.currentTarget.entity)
            
            -- Fire weapons based on behavior
            local behaviorConfig = HYPERDRIVE.TacticalAI.Config.Behaviors[self.behavior]
            if math.random() < behaviorConfig.fireRate then
                local success = group:Fire()
                if success then
                    self.stats.shotsfired = self.stats.shotsfired + 1
                end
            end
        end
    end
end

function TacticalAI:ExecuteRetreat()
    -- Find safe retreat position
    if not self.retreatPosition then
        self.retreatPosition = self:FindRetreatPosition()
    end
    
    -- Disable weapon auto-targeting during retreat
    for groupId, group in pairs(HYPERDRIVE.WeaponGroups.Groups) do
        if group.shipCore == self.shipCore then
            group.autoFire = false
        end
    end
    
    -- TODO: Implement movement commands for retreat
    -- This would require integration with ship movement systems
end

function TacticalAI:ExecutePatrol()
    -- Enable weapon auto-targeting during patrol
    for groupId, group in pairs(HYPERDRIVE.WeaponGroups.Groups) do
        if group.shipCore == self.shipCore then
            group.autoFire = true
        end
    end
    
    -- Clear retreat position
    self.retreatPosition = nil
end

function TacticalAI:UpdateWeaponGroups()
    -- Find all weapon groups for this ship
    self.weaponGroups = {}
    for groupId, group in pairs(HYPERDRIVE.WeaponGroups.Groups) do
        if group.shipCore == self.shipCore then
            table.insert(self.weaponGroups, group)
        end
    end
end

function TacticalAI:GetShipHealth()
    if not IsValid(self.shipCore) then return 0 end
    
    local health = self.shipCore:Health()
    local maxHealth = self.shipCore:GetMaxHealth()
    
    if maxHealth and maxHealth > 0 then
        return health / maxHealth
    end
    
    return 1.0 -- Assume full health if we can't determine
end

function TacticalAI:FindRetreatPosition()
    local shipPos = self.shipCore:GetPos()
    local retreatDistance = 2000
    
    -- Find position away from threats
    local avgThreatPos = Vector(0, 0, 0)
    local threatCount = 0
    
    for _, threat in ipairs(self.threatList) do
        if IsValid(threat.entity) then
            avgThreatPos = avgThreatPos + threat.entity:GetPos()
            threatCount = threatCount + 1
        end
    end
    
    if threatCount > 0 then
        avgThreatPos = avgThreatPos / threatCount
        local retreatDir = (shipPos - avgThreatPos):GetNormalized()
        return shipPos + retreatDir * retreatDistance
    end
    
    -- Fallback: random direction
    return shipPos + VectorRand() * retreatDistance
end

function TacticalAI:GetStatus()
    return {
        shipCore = self.shipCore:EntIndex(),
        behavior = self.behavior,
        active = self.active,
        tacticalState = self.tacticalState,
        currentTarget = self.currentTarget and self.currentTarget.entity:GetClass() or "None",
        threatCount = #self.threatList,
        weaponGroups = #self.weaponGroups,
        stats = table.Copy(self.stats)
    }
end

-- Main tactical AI functions
function HYPERDRIVE.TacticalAI.CreateAI(shipCore, behavior)
    if not IsValid(shipCore) then return nil end
    
    local coreId = shipCore:EntIndex()
    local ai = TacticalAI:New(shipCore, behavior)
    HYPERDRIVE.TacticalAI.AIInstances[coreId] = ai
    
    print("[Tactical AI] Created AI for ship core " .. coreId .. " with " .. behavior .. " behavior")
    return ai
end

function HYPERDRIVE.TacticalAI.GetAI(shipCore)
    if not IsValid(shipCore) then return nil end
    
    local coreId = shipCore:EntIndex()
    return HYPERDRIVE.TacticalAI.AIInstances[coreId]
end

function HYPERDRIVE.TacticalAI.RemoveAI(shipCore)
    if not IsValid(shipCore) then return end
    
    local coreId = shipCore:EntIndex()
    HYPERDRIVE.TacticalAI.AIInstances[coreId] = nil
    print("[Tactical AI] Removed AI for ship core " .. coreId)
end

function HYPERDRIVE.TacticalAI.SetBehavior(shipCore, behavior)
    local ai = HYPERDRIVE.TacticalAI.GetAI(shipCore)
    if ai then
        ai.behavior = behavior
        print("[Tactical AI] Set behavior to " .. behavior .. " for ship core " .. shipCore:EntIndex())
        return true
    end
    return false
end

function HYPERDRIVE.TacticalAI.GetAllAIStatus()
    local status = {}
    for coreId, ai in pairs(HYPERDRIVE.TacticalAI.AIInstances) do
        if IsValid(ai.shipCore) then
            status[coreId] = ai:GetStatus()
        else
            HYPERDRIVE.TacticalAI.AIInstances[coreId] = nil
        end
    end
    return status
end

-- Register with master scheduler instead of timer
timer.Simple(2, function()
    if ASC and ASC.MasterScheduler then
        ASC.MasterScheduler.RegisterTask("HyperdriveTacticalAI", "Medium", function()
            for coreId, ai in pairs(HYPERDRIVE.TacticalAI.AIInstances) do
                if IsValid(ai.shipCore) then
                    ai:Update()
                else
                    HYPERDRIVE.TacticalAI.AIInstances[coreId] = nil
                end
            end
        end, 0.5) -- 2 FPS update rate
    else
        -- Fallback timer if master scheduler not available
        timer.Create("HyperdriveTacticalAIThink", 0.5, 0, function()
            for coreId, ai in pairs(HYPERDRIVE.TacticalAI.AIInstances) do
                if IsValid(ai.shipCore) then
                    ai:Update()
                else
                    HYPERDRIVE.TacticalAI.AIInstances[coreId] = nil
                end
            end
        end)
    end
end)

print("[Hyperdrive Weapons] Tactical AI System loaded successfully!")
