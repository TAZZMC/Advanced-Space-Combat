--[[
    Advanced Space Combat - Point Defense System v3.0.0
    
    Automated point defense systems for intercepting incoming projectiles,
    missiles, and small craft. Features smart targeting, predictive firing,
    and integration with ship tactical systems.
]]

-- Initialize Point Defense namespace
ASC = ASC or {}
ASC.PointDefense = ASC.PointDefense or {}

-- Point Defense Configuration
ASC.PointDefense.Config = {
    -- Core Settings
    Enabled = true,
    UpdateRate = 0.05, -- High update rate for fast response
    MaxDefenseRange = 1500,
    MinDefenseRange = 50,
    
    -- Targeting Settings
    PredictiveTargeting = true,
    TargetLeadTime = 0.3,
    MaxTargets = 8,
    TargetPriority = {
        "missile", "torpedo", "projectile", "small_craft", "fighter"
    },
    
    -- Engagement Settings
    EngagementRange = 1200,
    MinEngagementTime = 0.1,
    MaxEngagementTime = 3.0,
    BurstFireMode = true,
    BurstSize = 3,
    BurstDelay = 0.1,
    
    -- Performance Settings
    MaxDefenseSystems = 20,
    EnergyPerShot = 5,
    CooldownTime = 0.2,
    OverheatThreshold = 100,
    CooldownRate = 10, -- per second
    
    -- Integration Settings
    CAPIntegration = true,
    TacticalAIIntegration = true,
    FleetCoordination = true,
    SharedTargeting = true
}

-- Point Defense Core System
ASC.PointDefense.Core = {
    -- Active defense systems
    DefenseSystems = {},
    
    -- Global targeting data
    TrackedTargets = {},
    SharedTargets = {},
    
    -- Performance tracking
    TotalInterceptions = 0,
    TotalShots = 0,
    SuccessRate = 0,
    
    -- Initialize point defense system
    Initialize = function(shipCore, defenseType)
        if not IsValid(shipCore) then
            return false, "Invalid ship core"
        end
        
        local shipID = shipCore:EntIndex()
        defenseType = defenseType or "STANDARD"
        
        if ASC.PointDefense.Core.DefenseSystems[shipID] then
            return false, "Point defense already initialized"
        end
        
        ASC.PointDefense.Core.DefenseSystems[shipID] = {
            shipCore = shipCore,
            defenseType = defenseType,
            config = ASC.PointDefense.Config,
            
            -- Defense status
            active = false,
            energy = 100,
            heat = 0,
            overheated = false,
            
            -- Targeting system
            currentTargets = {},
            engagedTargets = {},
            targetHistory = {},
            
            -- Weapon systems
            defenseTurrets = {},
            weaponGroups = {},
            
            -- Performance tracking
            shotsfired = 0,
            targetsDestroyed = 0,
            missedShots = 0,
            efficiency = 1.0,
            
            -- Tactical integration
            fleetMode = false,
            coordinatedTargeting = false,
            priorityOverride = nil,
            
            -- Timing
            lastUpdate = CurTime(),
            lastShot = 0,
            lastTargetScan = 0
        }
        
        -- Initialize defense turrets
        ASC.PointDefense.Core.InitializeDefenseTurrets(shipID)
        
        -- Start defense system
        ASC.PointDefense.Core.ActivateDefense(shipID)
        
        print("[Point Defense] Initialized " .. defenseType .. " defense system for ship " .. shipID)
        return true, "Point defense system initialized"
    end,
    
    -- Initialize defense turrets
    InitializeDefenseTurrets = function(shipID)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense then return end
        
        -- Find nearby defense turrets
        local turrets = ASC.PointDefense.Core.FindDefenseTurrets(defense.shipCore)
        defense.defenseTurrets = turrets
        
        -- Create weapon groups for coordinated firing
        ASC.PointDefense.Core.CreateWeaponGroups(shipID)
        
        print("[Point Defense] Found " .. #turrets .. " defense turrets for ship " .. shipID)
    end,
    
    -- Find defense turrets near ship core
    FindDefenseTurrets = function(shipCore)
        local turrets = {}
        local shipPos = shipCore:GetPos()
        
        for _, ent in ipairs(ents.FindInSphere(shipPos, ASC.PointDefense.Config.MaxDefenseRange)) do
            if IsValid(ent) and ent:GetClass() == "asc_point_defense" then
                table.insert(turrets, ent)
            end
        end
        
        return turrets
    end,
    
    -- Create weapon groups for coordinated firing
    CreateWeaponGroups = function(shipID)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense then return end
        
        -- Group turrets by position for optimal coverage
        defense.weaponGroups = {
            forward = {},
            aft = {},
            port = {},
            starboard = {},
            dorsal = {},
            ventral = {}
        }
        
        local shipPos = defense.shipCore:GetPos()
        local shipAngles = defense.shipCore:GetAngles()
        
        for _, turret in ipairs(defense.defenseTurrets) do
            local relativePos = turret:GetPos() - shipPos
            local localPos = shipAngles:Forward():Dot(relativePos)
            
            -- Assign to appropriate group based on position
            if localPos > 0 then
                table.insert(defense.weaponGroups.forward, turret)
            else
                table.insert(defense.weaponGroups.aft, turret)
            end
        end
    end,
    
    -- Activate defense system
    ActivateDefense = function(shipID)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense then return false end
        
        defense.active = true
        defense.lastUpdate = CurTime()
        
        -- Start defense update timer
        timer.Create("ASC_PointDefense_" .. shipID, ASC.PointDefense.Config.UpdateRate, 0, function()
            ASC.PointDefense.Core.UpdateDefenseSystem(shipID)
        end)
        
        print("[Point Defense] Activated defense system for ship " .. shipID)
        return true
    end,
    
    -- Update defense system
    UpdateDefenseSystem = function(shipID)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense or not defense.active then return end
        
        local currentTime = CurTime()
        
        -- Update heat and energy
        ASC.PointDefense.Core.UpdateDefenseStatus(shipID, currentTime)
        
        -- Scan for targets
        ASC.PointDefense.Core.ScanForTargets(shipID, currentTime)
        
        -- Engage targets
        ASC.PointDefense.Core.EngageTargets(shipID, currentTime)
        
        -- Update performance metrics
        ASC.PointDefense.Core.UpdatePerformanceMetrics(shipID)
        
        defense.lastUpdate = currentTime
    end,
    
    -- Update defense status (heat, energy, etc.)
    UpdateDefenseStatus = function(shipID, currentTime)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense then return end
        
        local deltaTime = currentTime - defense.lastUpdate
        
        -- Cool down heat
        if defense.heat > 0 then
            defense.heat = math.max(0, defense.heat - (ASC.PointDefense.Config.CooldownRate * deltaTime))
        end
        
        -- Check overheat status
        if defense.heat >= ASC.PointDefense.Config.OverheatThreshold then
            defense.overheated = true
        elseif defense.heat < ASC.PointDefense.Config.OverheatThreshold * 0.5 then
            defense.overheated = false
        end
        
        -- Regenerate energy (if ship core provides it)
        if IsValid(defense.shipCore) and defense.shipCore.GetEnergy then
            defense.energy = defense.shipCore:GetEnergy()
        end
    end,
    
    -- Scan for incoming targets
    ScanForTargets = function(shipID, currentTime)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense then return end
        
        -- Only scan periodically to save performance
        if currentTime - defense.lastTargetScan < 0.1 then return end
        defense.lastTargetScan = currentTime
        
        local shipPos = defense.shipCore:GetPos()
        local targets = {}
        
        -- Find potential targets in range
        for _, ent in ipairs(ents.FindInSphere(shipPos, ASC.PointDefense.Config.EngagementRange)) do
            if ASC.PointDefense.Core.IsValidTarget(ent, defense) then
                local targetData = ASC.PointDefense.Core.AnalyzeTarget(ent, defense)
                if targetData then
                    table.insert(targets, targetData)
                end
            end
        end
        
        -- Sort targets by priority
        table.sort(targets, function(a, b)
            return a.priority > b.priority
        end)
        
        -- Limit to max targets
        if #targets > ASC.PointDefense.Config.MaxTargets then
            for i = ASC.PointDefense.Config.MaxTargets + 1, #targets do
                targets[i] = nil
            end
        end
        
        defense.currentTargets = targets
    end,
    
    -- Check if entity is a valid target
    IsValidTarget = function(ent, defense)
        if not IsValid(ent) then return false end
        
        local class = ent:GetClass()
        
        -- Check target types
        for _, targetType in ipairs(ASC.PointDefense.Config.TargetPriority) do
            if string.find(class, targetType) then
                return true
            end
        end
        
        -- Check for projectiles
        if ent:GetClass() == "prop_physics" and ent:GetVelocity():Length() > 100 then
            return true
        end
        
        return false
    end,
    
    -- Analyze target and calculate priority
    AnalyzeTarget = function(ent, defense)
        local shipPos = defense.shipCore:GetPos()
        local targetPos = ent:GetPos()
        local distance = shipPos:Distance(targetPos)
        
        if distance > ASC.PointDefense.Config.EngagementRange then
            return nil
        end
        
        local velocity = ent:GetVelocity()
        local speed = velocity:Length()
        
        -- Calculate threat level
        local threat = ASC.PointDefense.Core.CalculateThreatLevel(ent, defense, distance, speed)
        
        -- Calculate intercept point if using predictive targeting
        local interceptPoint = targetPos
        if ASC.PointDefense.Config.PredictiveTargeting and speed > 0 then
            interceptPoint = ASC.PointDefense.Core.CalculateInterceptPoint(targetPos, velocity, shipPos)
        end
        
        return {
            entity = ent,
            position = targetPos,
            velocity = velocity,
            speed = speed,
            distance = distance,
            threat = threat,
            priority = threat * (1 / math.max(distance, 1)), -- Closer = higher priority
            interceptPoint = interceptPoint,
            timeToImpact = distance / math.max(speed, 1),
            lastSeen = CurTime()
        }
    end,
    
    -- Calculate threat level of target
    CalculateThreatLevel = function(ent, defense, distance, speed)
        local threat = 1.0
        local class = ent:GetClass()
        
        -- Base threat by type
        if string.find(class, "missile") then
            threat = 10.0
        elseif string.find(class, "torpedo") then
            threat = 8.0
        elseif string.find(class, "projectile") then
            threat = 5.0
        elseif string.find(class, "fighter") then
            threat = 3.0
        end
        
        -- Increase threat for fast-moving objects
        if speed > 500 then
            threat = threat * 1.5
        end
        
        -- Increase threat for close objects
        if distance < 300 then
            threat = threat * 2.0
        end
        
        return threat
    end,
    
    -- Calculate intercept point for predictive targeting
    CalculateInterceptPoint = function(targetPos, targetVel, shooterPos)
        local timeToTarget = targetPos:Distance(shooterPos) / 1000 -- Assume projectile speed of 1000
        return targetPos + (targetVel * timeToTarget * ASC.PointDefense.Config.TargetLeadTime)
    end
}

    -- Engage targets with available turrets
    EngageTargets = function(shipID, currentTime)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense or defense.overheated or #defense.currentTargets == 0 then return end

        for _, target in ipairs(defense.currentTargets) do
            if ASC.PointDefense.Core.CanEngageTarget(target, defense, currentTime) then
                ASC.PointDefense.Core.FireAtTarget(target, defense, currentTime)
            end
        end
    end,

    -- Check if we can engage a target
    CanEngageTarget = function(target, defense, currentTime)
        if not IsValid(target.entity) then return false end
        if defense.energy < ASC.PointDefense.Config.EnergyPerShot then return false end
        if currentTime - defense.lastShot < ASC.PointDefense.Config.CooldownTime then return false end

        return true
    end,

    -- Fire at target
    FireAtTarget = function(target, defense, currentTime)
        local availableTurrets = ASC.PointDefense.Core.GetAvailableTurrets(defense)
        if #availableTurrets == 0 then return end

        local turret = availableTurrets[1] -- Use first available turret

        -- Fire at intercept point
        local success = ASC.PointDefense.Core.FireTurret(turret, target.interceptPoint, target)

        if success then
            defense.lastShot = currentTime
            defense.shotsfired = defense.shotsfired + 1
            defense.heat = defense.heat + 10
            defense.energy = defense.energy - ASC.PointDefense.Config.EnergyPerShot

            -- Track engagement
            defense.engagedTargets[target.entity:EntIndex()] = {
                target = target,
                engageTime = currentTime,
                turret = turret
            }

            print("[Point Defense] Firing at " .. target.entity:GetClass() .. " at distance " .. math.floor(target.distance))
        end
    end,

    -- Get available turrets for firing
    GetAvailableTurrets = function(defense)
        local available = {}

        for _, turret in ipairs(defense.defenseTurrets) do
            if IsValid(turret) and turret:CanFire() then
                table.insert(available, turret)
            end
        end

        return available
    end,

    -- Fire turret at position
    FireTurret = function(turret, targetPos, targetData)
        if not IsValid(turret) then return false end

        -- Aim turret at target
        local turretPos = turret:GetPos()
        local aimDir = (targetPos - turretPos):GetNormalized()

        -- Fire projectile
        local projectile = ents.Create("asc_defense_projectile")
        if IsValid(projectile) then
            projectile:SetPos(turretPos + aimDir * 50)
            projectile:SetAngles(aimDir:Angle())
            projectile:Spawn()
            projectile:Activate()

            -- Set projectile properties
            projectile:SetVelocity(aimDir * 2000)
            projectile:SetTarget(targetData.entity)

            return true
        end

        return false
    end,

    -- Update performance metrics
    UpdatePerformanceMetrics = function(shipID)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense then return end

        -- Calculate efficiency
        if defense.shotsfired > 0 then
            defense.efficiency = defense.targetsDestroyed / defense.shotsfired
        end

        -- Update global stats
        ASC.PointDefense.Core.TotalShots = ASC.PointDefense.Core.TotalShots + defense.shotsfired
        ASC.PointDefense.Core.TotalInterceptions = ASC.PointDefense.Core.TotalInterceptions + defense.targetsDestroyed

        if ASC.PointDefense.Core.TotalShots > 0 then
            ASC.PointDefense.Core.SuccessRate = ASC.PointDefense.Core.TotalInterceptions / ASC.PointDefense.Core.TotalShots
        end
    end,

    -- Get defense system status
    GetDefenseStatus = function(shipID)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense then return nil end

        return {
            active = defense.active,
            energy = defense.energy,
            heat = defense.heat,
            overheated = defense.overheated,
            turrets = #defense.defenseTurrets,
            targets = #defense.currentTargets,
            efficiency = defense.efficiency,
            shotsFired = defense.shotsfired,
            targetsDestroyed = defense.targetsDestroyed
        }
    end,

    -- Deactivate defense system
    DeactivateDefense = function(shipID)
        local defense = ASC.PointDefense.Core.DefenseSystems[shipID]
        if not defense then return false end

        defense.active = false
        timer.Remove("ASC_PointDefense_" .. shipID)

        print("[Point Defense] Deactivated defense system for ship " .. shipID)
        return true
    end,

    -- Remove defense system
    RemoveDefenseSystem = function(shipID)
        ASC.PointDefense.Core.DeactivateDefense(shipID)
        ASC.PointDefense.Core.DefenseSystems[shipID] = nil

        print("[Point Defense] Removed defense system for ship " .. shipID)
    end
}

-- Console commands for point defense
concommand.Add("asc_point_defense_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local shipCore = ASC.AI.FindPlayerShipCore(ply)
    if not IsValid(shipCore) then
        ply:ChatPrint("[Point Defense] No ship core found")
        return
    end

    local status = ASC.PointDefense.Core.GetDefenseStatus(shipCore:EntIndex())
    if not status then
        ply:ChatPrint("[Point Defense] No defense system found")
        return
    end

    ply:ChatPrint("[Point Defense] Status:")
    ply:ChatPrint("• Active: " .. (status.active and "Yes" or "No"))
    ply:ChatPrint("• Energy: " .. status.energy .. "%")
    ply:ChatPrint("• Heat: " .. status.heat .. "%")
    ply:ChatPrint("• Turrets: " .. status.turrets)
    ply:ChatPrint("• Current Targets: " .. status.targets)
    ply:ChatPrint("• Efficiency: " .. math.floor(status.efficiency * 100) .. "%")
end)

-- Initialize point defense system on addon load
hook.Add("Initialize", "ASC_PointDefense_Init", function()
    print("[Advanced Space Combat] Point Defense System v3.0.0 loaded")
end)
