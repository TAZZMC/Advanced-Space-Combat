--[[
    Advanced Space Combat - Tactical AI System v3.0.0
    
    Provides intelligent combat assistance, weapon management, and tactical analysis
    for Advanced Space Combat ships and weapons systems.
    
    Features:
    - Automated target acquisition and tracking
    - Weapon group management and coordination
    - Threat assessment and prioritization
    - Combat maneuver suggestions
    - Ammunition management
    - Shield optimization during combat
    - Formation flying and fleet coordination
]]

-- Initialize Tactical AI namespace
ASC = ASC or {}
ASC.TacticalAI = ASC.TacticalAI or {}

-- Tactical AI Configuration
ASC.TacticalAI.Config = {
    -- Core Settings
    Enabled = true,
    UpdateRate = 0.5,
    MaxTargets = 10,
    MaxRange = 5000,
    MinRange = 100,
    
    -- Target Acquisition
    AutoTargeting = true,
    TargetPriority = {
        "ship_core",
        "weapon_",
        "shield_",
        "engine_",
        "player"
    },
    
    -- Weapon Management
    AutoFire = false,
    WeaponGrouping = true,
    AmmunitionConservation = true,
    OptimalRange = 2000,
    
    -- Threat Assessment
    ThreatRadius = 3000,
    HostileDetection = true,
    FriendlyFire = false,
    
    -- Combat Maneuvers
    EvasiveManeuvers = true,
    FormationKeeping = true,
    CoverSeeking = true,
    
    -- AI Assistance Levels
    AssistanceLevel = {
        PASSIVE = 1,    -- Information only
        ADVISORY = 2,   -- Suggestions and warnings
        ASSISTED = 3,   -- Automated non-critical actions
        AUTONOMOUS = 4  -- Full AI control (admin only)
    },
    DefaultLevel = 2
}

-- Tactical AI Core System
ASC.TacticalAI.Core = {
    -- Active tactical sessions
    ActiveSessions = {},
    
    -- Global threat tracking
    ThreatDatabase = {},
    
    -- Combat statistics
    CombatStats = {},
    
    -- Initialize tactical AI for a ship
    Initialize = function(shipCore, player)
        if not IsValid(shipCore) or not IsValid(player) then
            return false, "Invalid ship core or player"
        end
        
        local sessionID = shipCore:EntIndex()
        
        -- Create tactical session
        ASC.TacticalAI.Core.ActiveSessions[sessionID] = {
            shipCore = shipCore,
            player = player,
            weapons = {},
            targets = {},
            threats = {},
            maneuvers = {},
            lastUpdate = CurTime(),
            assistanceLevel = ASC.TacticalAI.Config.DefaultLevel,
            status = "STANDBY",
            combatMode = false
        }
        
        -- Initialize weapon detection
        ASC.TacticalAI.Weapons.DetectWeapons(sessionID)
        
        -- Initialize threat detection
        ASC.TacticalAI.Threats.StartMonitoring(sessionID)
        
        print("[Tactical AI] Initialized for ship " .. sessionID .. " - Player: " .. player:Name())
        return true, "Tactical AI initialized successfully"
    end,
    
    -- Update tactical AI session
    Update = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session or not IsValid(session.shipCore) then
            ASC.TacticalAI.Core.ActiveSessions[sessionID] = nil
            return
        end
        
        local currentTime = CurTime()
        if currentTime - session.lastUpdate < ASC.TacticalAI.Config.UpdateRate then
            return
        end
        
        session.lastUpdate = currentTime
        
        -- Update weapon status
        ASC.TacticalAI.Weapons.UpdateWeapons(sessionID)
        
        -- Update threat assessment
        ASC.TacticalAI.Threats.UpdateThreats(sessionID)
        
        -- Update target tracking
        ASC.TacticalAI.Targeting.UpdateTargets(sessionID)
        
        -- Process tactical decisions
        ASC.TacticalAI.Decisions.ProcessDecisions(sessionID)
        
        -- Update combat status
        ASC.TacticalAI.Core.UpdateCombatStatus(sessionID)
    end,
    
    -- Update combat status
    UpdateCombatStatus = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return end
        
        local threatCount = table.Count(session.threats)
        local targetCount = table.Count(session.targets)
        
        local newStatus = "STANDBY"
        local newCombatMode = false
        
        if threatCount > 0 then
            newStatus = "ALERT"
            newCombatMode = true
        end
        
        if targetCount > 0 and session.assistanceLevel >= ASC.TacticalAI.Config.AssistanceLevel.ASSISTED then
            newStatus = "COMBAT"
            newCombatMode = true
        end
        
        -- Update session status
        if session.status ~= newStatus then
            session.status = newStatus
            ASC.TacticalAI.Core.NotifyStatusChange(sessionID, newStatus)
        end
        
        session.combatMode = newCombatMode
    end,
    
    -- Notify status change
    NotifyStatusChange = function(sessionID, newStatus)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session or not IsValid(session.player) then return end
        
        local statusMessages = {
            STANDBY = "🟢 Tactical AI: Standing by",
            ALERT = "🟡 Tactical AI: Threats detected - Alert status",
            COMBAT = "🔴 Tactical AI: Combat mode active"
        }
        
        local message = statusMessages[newStatus] or "Tactical AI: Status unknown"
        session.player:ChatPrint(message)
        
        -- Play appropriate sound
        if newStatus == "ALERT" then
            session.player:EmitSound("buttons/button10.wav", 50, 120)
        elseif newStatus == "COMBAT" then
            session.player:EmitSound("buttons/button14.wav", 60, 100)
        end
    end,
    
    -- Shutdown tactical AI session
    Shutdown = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if session and IsValid(session.player) then
            session.player:ChatPrint("🔵 Tactical AI: System shutdown")
        end
        
        ASC.TacticalAI.Core.ActiveSessions[sessionID] = nil
        print("[Tactical AI] Shutdown for ship " .. sessionID)
    end
}

-- Weapon Management System
ASC.TacticalAI.Weapons = {
    -- Detect weapons on ship
    DetectWeapons = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return end
        
        local shipCore = session.shipCore
        if not IsValid(shipCore) or not shipCore.GetEntities then return end
        
        session.weapons = {}
        
        -- Find weapons on ship
        for _, ent in ipairs(shipCore:GetEntities()) do
            if IsValid(ent) and ASC.TacticalAI.Weapons.IsWeapon(ent) then
                local weaponData = {
                    entity = ent,
                    class = ent:GetClass(),
                    type = ASC.TacticalAI.Weapons.GetWeaponType(ent),
                    range = ASC.TacticalAI.Weapons.GetWeaponRange(ent),
                    damage = ASC.TacticalAI.Weapons.GetWeaponDamage(ent),
                    ammo = ASC.TacticalAI.Weapons.GetWeaponAmmo(ent),
                    cooldown = 0,
                    lastFired = 0,
                    group = 1,
                    status = "READY"
                }
                
                table.insert(session.weapons, weaponData)
            end
        end
        
        print("[Tactical AI] Detected " .. #session.weapons .. " weapons for ship " .. sessionID)
    end,
    
    -- Check if entity is a weapon
    IsWeapon = function(ent)
        if not IsValid(ent) then return false end
        
        local class = ent:GetClass()
        local weaponClasses = {
            "weapon_", "gun_", "cannon_", "turret_", "launcher_",
            "pulse_cannon", "beam_weapon", "torpedo_launcher",
            "railgun", "plasma_cannon", "phaser_", "disruptor_"
        }
        
        for _, weaponClass in ipairs(weaponClasses) do
            if string.find(class, weaponClass) then
                return true
            end
        end
        
        return false
    end,
    
    -- Get weapon type
    GetWeaponType = function(ent)
        if not IsValid(ent) then return "UNKNOWN" end
        
        local class = ent:GetClass()
        
        if string.find(class, "pulse") or string.find(class, "cannon") then
            return "PULSE"
        elseif string.find(class, "beam") or string.find(class, "laser") then
            return "BEAM"
        elseif string.find(class, "torpedo") or string.find(class, "missile") then
            return "PROJECTILE"
        elseif string.find(class, "railgun") then
            return "KINETIC"
        elseif string.find(class, "plasma") then
            return "PLASMA"
        end
        
        return "ENERGY"
    end,
    
    -- Get weapon range
    GetWeaponRange = function(ent)
        if not IsValid(ent) then return 1000 end
        
        -- Try to get range from entity
        if ent.GetRange then
            return ent:GetRange()
        elseif ent.Range then
            return ent.Range
        end
        
        -- Default ranges by type
        local class = ent:GetClass()
        if string.find(class, "beam") then
            return 3000
        elseif string.find(class, "torpedo") then
            return 5000
        elseif string.find(class, "railgun") then
            return 4000
        end
        
        return 2000
    end,
    
    -- Get weapon damage
    GetWeaponDamage = function(ent)
        if not IsValid(ent) then return 100 end
        
        if ent.GetDamage then
            return ent:GetDamage()
        elseif ent.Damage then
            return ent.Damage
        end
        
        return 100
    end,
    
    -- Get weapon ammunition
    GetWeaponAmmo = function(ent)
        if not IsValid(ent) then return 0 end
        
        if ent.GetAmmo then
            return ent:GetAmmo()
        elseif ent.Ammo then
            return ent.Ammo
        end
        
        return -1 -- Unlimited
    end,
    
    -- Update weapon status
    UpdateWeapons = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return end
        
        local currentTime = CurTime()
        
        for _, weapon in ipairs(session.weapons) do
            if IsValid(weapon.entity) then
                -- Update cooldown
                if weapon.cooldown > 0 then
                    weapon.cooldown = math.max(0, weapon.cooldown - ASC.TacticalAI.Config.UpdateRate)
                end
                
                -- Update status
                if weapon.cooldown > 0 then
                    weapon.status = "COOLING"
                elseif weapon.ammo == 0 then
                    weapon.status = "NO_AMMO"
                else
                    weapon.status = "READY"
                end
                
                -- Update ammo count
                weapon.ammo = ASC.TacticalAI.Weapons.GetWeaponAmmo(weapon.entity)
            else
                weapon.status = "OFFLINE"
            end
        end
    end
}

-- Threat Detection System
ASC.TacticalAI.Threats = {
    -- Start monitoring threats for a ship
    StartMonitoring = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return end

        session.threats = {}
        print("[Tactical AI] Threat monitoring started for ship " .. sessionID)
    end,

    -- Update threat assessment
    UpdateThreats = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session or not IsValid(session.shipCore) then return end

        local shipPos = session.shipCore:GetPos()
        local threats = {}

        -- Scan for potential threats
        for _, ent in ipairs(ents.FindInSphere(shipPos, ASC.TacticalAI.Config.ThreatRadius)) do
            if ASC.TacticalAI.Threats.IsThreat(ent, session) then
                local threatData = ASC.TacticalAI.Threats.AnalyzeThreat(ent, session)
                if threatData then
                    threats[ent:EntIndex()] = threatData
                end
            end
        end

        session.threats = threats
    end,

    -- Check if entity is a threat
    IsThreat = function(ent, session)
        if not IsValid(ent) or not session then return false end

        -- Don't target own ship entities
        if session.shipCore.GetEntities then
            for _, shipEnt in ipairs(session.shipCore:GetEntities()) do
                if ent == shipEnt then return false end
            end
        end

        -- Check for hostile weapons
        if ASC.TacticalAI.Weapons.IsWeapon(ent) then
            local owner = ent:CPPIGetOwner()
            if IsValid(owner) and owner ~= session.player then
                return true
            end
        end

        -- Check for hostile ships
        if ent:GetClass() == "ship_core" then
            local owner = ent:CPPIGetOwner()
            if IsValid(owner) and owner ~= session.player then
                return true
            end
        end

        return false
    end,

    -- Analyze threat level
    AnalyzeThreat = function(ent, session)
        if not IsValid(ent) or not session then return nil end

        local shipPos = session.shipCore:GetPos()
        local entPos = ent:GetPos()
        local distance = shipPos:Distance(entPos)

        local threatLevel = 0
        local threatType = "UNKNOWN"

        -- Analyze by entity type
        if ASC.TacticalAI.Weapons.IsWeapon(ent) then
            threatType = "WEAPON"
            threatLevel = 3

            -- Higher threat for closer weapons
            if distance < 1000 then
                threatLevel = 5
            elseif distance < 2000 then
                threatLevel = 4
            end
        elseif ent:GetClass() == "ship_core" then
            threatType = "SHIP"
            threatLevel = 2

            -- Check if ship has weapons
            if ent.GetEntities then
                for _, shipEnt in ipairs(ent:GetEntities()) do
                    if ASC.TacticalAI.Weapons.IsWeapon(shipEnt) then
                        threatLevel = 4
                        break
                    end
                end
            end
        end

        return {
            entity = ent,
            type = threatType,
            level = threatLevel,
            distance = distance,
            lastSeen = CurTime(),
            tracking = true
        }
    end
}

-- Targeting System
ASC.TacticalAI.Targeting = {
    -- Update target tracking
    UpdateTargets = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return end

        -- Clear old targets
        session.targets = {}

        -- Auto-targeting if enabled
        if ASC.TacticalAI.Config.AutoTargeting and session.assistanceLevel >= ASC.TacticalAI.Config.AssistanceLevel.ADVISORY then
            ASC.TacticalAI.Targeting.AutoTarget(sessionID)
        end
    end,

    -- Automatic target acquisition
    AutoTarget = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return end

        -- Convert threats to targets based on priority
        local prioritizedThreats = {}

        for _, threat in pairs(session.threats) do
            if threat.level >= 3 then -- Only target significant threats
                table.insert(prioritizedThreats, threat)
            end
        end

        -- Sort by threat level and distance
        table.sort(prioritizedThreats, function(a, b)
            if a.level == b.level then
                return a.distance < b.distance
            end
            return a.level > b.level
        end)

        -- Add top threats as targets
        local maxTargets = math.min(#prioritizedThreats, ASC.TacticalAI.Config.MaxTargets)
        for i = 1, maxTargets do
            local threat = prioritizedThreats[i]
            session.targets[threat.entity:EntIndex()] = {
                entity = threat.entity,
                priority = threat.level,
                distance = threat.distance,
                lastUpdate = CurTime(),
                weapons = ASC.TacticalAI.Targeting.GetOptimalWeapons(sessionID, threat)
            }
        end
    end,

    -- Get optimal weapons for target
    GetOptimalWeapons = function(sessionID, threat)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return {} end

        local optimalWeapons = {}

        for _, weapon in ipairs(session.weapons) do
            if weapon.status == "READY" and weapon.range >= threat.distance then
                table.insert(optimalWeapons, weapon)
            end
        end

        return optimalWeapons
    end
}

-- Decision Making System
ASC.TacticalAI.Decisions = {
    -- Process tactical decisions
    ProcessDecisions = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return end

        -- Only make decisions if assistance level allows
        if session.assistanceLevel < ASC.TacticalAI.Config.AssistanceLevel.ADVISORY then
            return
        end

        -- Provide tactical advice
        ASC.TacticalAI.Decisions.ProvideTacticalAdvice(sessionID)

        -- Automated actions for higher assistance levels
        if session.assistanceLevel >= ASC.TacticalAI.Config.AssistanceLevel.ASSISTED then
            ASC.TacticalAI.Decisions.AutomatedActions(sessionID)
        end
    end,

    -- Provide tactical advice to player
    ProvideTacticalAdvice = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session or not IsValid(session.player) then return end

        local currentTime = CurTime()

        -- Limit advice frequency
        if not session.lastAdvice or currentTime - session.lastAdvice > 5 then
            session.lastAdvice = currentTime

            local threatCount = table.Count(session.threats)
            local targetCount = table.Count(session.targets)

            if threatCount > 0 and targetCount == 0 then
                session.player:ChatPrint("⚠️ Tactical AI: " .. threatCount .. " threats detected - No targets acquired")
            elseif targetCount > 0 then
                session.player:ChatPrint("🎯 Tactical AI: " .. targetCount .. " targets acquired - Weapons ready")
            end
        end
    end,

    -- Automated actions
    AutomatedActions = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return end

        -- Automated shield management
        ASC.TacticalAI.Decisions.ManageShields(sessionID)

        -- Automated weapon grouping
        ASC.TacticalAI.Decisions.ManageWeaponGroups(sessionID)
    end,

    -- Manage shields automatically
    ManageShields = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session or not IsValid(session.shipCore) then return end

        local threatCount = table.Count(session.threats)

        -- Activate shields if threats detected
        if threatCount > 0 and session.shipCore.ActivateShields then
            session.shipCore:ActivateShields("tactical_ai")
        end
    end,

    -- Manage weapon groups
    ManageWeaponGroups = function(sessionID)
        local session = ASC.TacticalAI.Core.ActiveSessions[sessionID]
        if not session then return end

        -- Group weapons by type for better coordination
        local weaponGroups = {}

        for _, weapon in ipairs(session.weapons) do
            local groupKey = weapon.type
            if not weaponGroups[groupKey] then
                weaponGroups[groupKey] = {}
            end
            table.insert(weaponGroups[groupKey], weapon)
        end

        -- Assign group numbers
        local groupNum = 1
        for groupType, weapons in pairs(weaponGroups) do
            for _, weapon in ipairs(weapons) do
                weapon.group = groupNum
            end
            groupNum = groupNum + 1
        end
    end
}

-- Enhanced tactical AI functions for system integration
ASC.TacticalAI.Integration = {
    -- Update ship tactics (called from weapon system)
    UpdateShipTactics = function(weaponSystem)
        if not weaponSystem or not IsValid(weaponSystem.shipCore) then return end

        local shipID = weaponSystem.shipID
        local aiData = ASC.TacticalAI.Core.ActiveSessions[shipID]

        if not aiData then
            -- Create AI session for this ship
            aiData = ASC.TacticalAI.Core.StartSession(weaponSystem.shipCore, weaponSystem.shipCore:CPPIGetOwner())
            if aiData then
                aiData.weaponSystem = weaponSystem
                aiData.combatState = "PATROL"
            end
        end

        if aiData then
            -- Update AI state based on current situation
            ASC.TacticalAI.Integration.UpdateCombatState(aiData, weaponSystem)

            -- Execute tactical decisions
            ASC.TacticalAI.Integration.ExecuteTacticalDecisions(aiData, weaponSystem)
        end
    end,

    -- Update combat state
    UpdateCombatState = function(aiData, weaponSystem)
        local shipPos = weaponSystem.shipCore:GetPos()
        local threats = ASC.TacticalAI.Integration.AnalyzeThreatEnvironment(shipPos, weaponSystem)

        -- Determine combat state
        if #threats == 0 then
            aiData.combatState = "PATROL"
        elseif #threats == 1 then
            aiData.combatState = "ENGAGE"
        elseif #threats > 1 then
            aiData.combatState = "MULTIPLE_THREATS"
        end

        -- Update threat assessment
        aiData.currentThreats = threats
        aiData.primaryThreat = threats[1] or nil
    end,

    -- Analyze threat environment
    AnalyzeThreatEnvironment = function(shipPos, weaponSystem)
        local threats = {}
        local scanRadius = weaponSystem.targetingRange or 2500

        for _, ent in ipairs(ents.FindInSphere(shipPos, scanRadius)) do
            if ASC.Weapons and ASC.Weapons.Core.IsValidTarget(ent, weaponSystem.shipCore) then
                local threat = {
                    entity = ent,
                    distance = shipPos:Distance(ent:GetPos()),
                    threatLevel = ASC.TacticalAI.Integration.CalculateThreatLevel(ent, weaponSystem),
                    lastSeen = CurTime()
                }
                table.insert(threats, threat)
            end
        end

        -- Sort by threat level (highest first)
        table.sort(threats, function(a, b) return a.threatLevel > b.threatLevel end)

        return threats
    end,

    -- Calculate threat level
    CalculateThreatLevel = function(target, weaponSystem)
        local threatLevel = 1
        local distance = weaponSystem.shipCore:GetPos():Distance(target:GetPos())

        -- Distance factor (closer = more threatening)
        threatLevel = threatLevel + (2500 - distance) / 2500

        -- Target type factor
        if target:IsPlayer() then
            threatLevel = threatLevel + 0.5
        elseif target:GetClass() == "asc_ship_core" then
            threatLevel = threatLevel + 1.0
        end

        -- Boss factor
        if target:GetNWBool("IsBoss", false) then
            threatLevel = threatLevel + 2.0
        end

        return threatLevel
    end,

    -- Execute tactical decisions
    ExecuteTacticalDecisions = function(aiData, weaponSystem)
        if aiData.combatState == "PATROL" then
            ASC.TacticalAI.Integration.ExecutePatrolBehavior(aiData, weaponSystem)
        elseif aiData.combatState == "ENGAGE" then
            ASC.TacticalAI.Integration.ExecuteEngageBehavior(aiData, weaponSystem)
        elseif aiData.combatState == "MULTIPLE_THREATS" then
            ASC.TacticalAI.Integration.ExecuteMultiThreatBehavior(aiData, weaponSystem)
        end
    end,

    -- Execute patrol behavior
    ExecutePatrolBehavior = function(aiData, weaponSystem)
        -- Clear target
        weaponSystem.currentTarget = nil

        -- Use flight system for patrol if available
        if ASC.Flight then
            local shipID = weaponSystem.shipID
            local flight = ASC.Flight.Core.ActiveFlights[shipID]

            if flight and not flight.autopilotActive then
                -- Set random patrol waypoint
                local shipPos = weaponSystem.shipCore:GetPos()
                local patrolPos = shipPos + Vector(
                    math.random(-1000, 1000),
                    math.random(-1000, 1000),
                    math.random(-200, 200)
                )
                ASC.Flight.Core.EnableAutopilot(shipID, patrolPos, "PATROL")
            end
        end
    end,

    -- Execute engage behavior
    ExecuteEngageBehavior = function(aiData, weaponSystem)
        local threat = aiData.primaryThreat
        if not threat or not IsValid(threat.entity) then return end

        -- Set target
        weaponSystem.currentTarget = threat.entity

        -- Use flight system for combat positioning
        if ASC.Flight then
            local shipID = weaponSystem.shipID
            local flight = ASC.Flight.Core.ActiveFlights[shipID]

            if flight then
                local optimalRange = 800 -- Optimal combat range
                local targetPos = threat.entity:GetPos()
                local shipPos = weaponSystem.shipCore:GetPos()
                local direction = (shipPos - targetPos):GetNormalized()
                local combatPos = targetPos + direction * optimalRange

                ASC.Flight.Core.EnableAutopilot(shipID, combatPos, "COMBAT")
            end
        end

        -- Fire weapons if in range
        if threat.distance <= ASC.Weapons.Config.MaxRange then
            for i, weaponGroup in ipairs(weaponSystem.weaponGroups) do
                if CurTime() - weaponGroup.lastFired > 2 then
                    ASC.Weapons.Core.FireWeaponGroup(weaponSystem.shipID, i, threat.entity)
                    break
                end
            end
        end
    end,

    -- Execute multi-threat behavior
    ExecuteMultiThreatBehavior = function(aiData, weaponSystem)
        local threats = aiData.currentThreats or {}
        if #threats == 0 then return end

        -- Target highest threat
        weaponSystem.currentTarget = threats[1].entity

        -- Defensive positioning
        if ASC.Flight then
            local shipID = weaponSystem.shipID
            local shipPos = weaponSystem.shipCore:GetPos()

            -- Calculate safe position away from multiple threats
            local escapeVector = Vector(0, 0, 0)
            for _, threat in ipairs(threats) do
                if IsValid(threat.entity) then
                    local direction = (shipPos - threat.entity:GetPos()):GetNormalized()
                    escapeVector = escapeVector + direction
                end
            end

            escapeVector:Normalize()
            local safePos = shipPos + escapeVector * 1500

            ASC.Flight.Core.EnableAutopilot(shipID, safePos, "RETREAT")
        end

        -- Fire at closest threat
        local closestThreat = threats[1]
        if closestThreat.distance <= ASC.Weapons.Config.MaxRange then
            for i, weaponGroup in ipairs(weaponSystem.weaponGroups) do
                if CurTime() - weaponGroup.lastFired > 1.5 then -- Faster firing under pressure
                    ASC.Weapons.Core.FireWeaponGroup(weaponSystem.shipID, i, closestThreat.entity)
                    break
                end
            end
        end
    end,

    -- Get tactical status
    GetTacticalStatus = function(shipCore)
        if not IsValid(shipCore) then return nil end

        local shipID = shipCore:EntIndex()
        local aiData = ASC.TacticalAI.Core.ActiveSessions[shipID]

        if not aiData then
            return {
                status = "INACTIVE",
                combatState = "NONE",
                threats = 0,
                target = nil
            }
        end

        return {
            status = "ACTIVE",
            combatState = aiData.combatState or "PATROL",
            threats = #(aiData.currentThreats or {}),
            target = aiData.primaryThreat and aiData.primaryThreat.entity or nil,
            lastUpdate = aiData.lastUpdate or 0
        }
    end
}

-- Add integration functions to main core
ASC.TacticalAI.Core.UpdateShipTactics = ASC.TacticalAI.Integration.UpdateShipTactics
ASC.TacticalAI.Core.GetTacticalStatus = ASC.TacticalAI.Integration.GetTacticalStatus

-- Initialize system
if SERVER then
    -- Update all tactical AI sessions
    timer.Create("ASC_TacticalAI_Update", ASC.TacticalAI.Config.UpdateRate, 0, function()
        for sessionID, session in pairs(ASC.TacticalAI.Core.ActiveSessions) do
            ASC.TacticalAI.Core.Update(sessionID)
        end
    end)

    -- Update system status
    ASC.SystemStatus.TacticalAI = true
    ASC.SystemStatus.CombatAI = true
    ASC.SystemStatus.ThreatAnalysis = true

    print("[Advanced Space Combat] Tactical AI System v3.0.0 loaded with full integration")
end
