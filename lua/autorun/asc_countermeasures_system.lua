--[[
    Advanced Space Combat - Countermeasures & ECM System v3.0.0
    
    Electronic countermeasures, chaff, flares, and jamming systems
    for defending against guided weapons and sensor-based attacks.
]]

-- Initialize Countermeasures namespace
ASC = ASC or {}
ASC.Countermeasures = ASC.Countermeasures or {}

-- Countermeasures Configuration
ASC.Countermeasures.Config = {
    -- Core Settings
    Enabled = true,
    UpdateRate = 0.1,
    MaxRange = 2000,
    
    -- Countermeasure Types
    CountermeasureTypes = {
        CHAFF = {
            name = "Chaff Dispensers",
            description = "Metallic strips to confuse radar-guided weapons",
            effectiveness = 0.8,
            duration = 5.0,
            cooldown = 3.0,
            capacity = 20,
            reloadTime = 10.0
        },
        FLARE = {
            name = "Flare Dispensers",
            description = "Heat sources to confuse heat-seeking weapons",
            effectiveness = 0.75,
            duration = 4.0,
            cooldown = 2.5,
            capacity = 25,
            reloadTime = 8.0
        },
        ECM = {
            name = "Electronic Countermeasures",
            description = "Electronic jamming to disrupt targeting systems",
            effectiveness = 0.9,
            duration = 8.0,
            cooldown = 15.0,
            capacity = 10,
            reloadTime = 20.0
        },
        DECOY = {
            name = "Holographic Decoys",
            description = "False targets to confuse enemy sensors",
            effectiveness = 0.7,
            duration = 6.0,
            cooldown = 5.0,
            capacity = 15,
            reloadTime = 12.0
        }
    },
    
    -- Threat Detection
    ThreatTypes = {
        "missile", "torpedo", "guided_projectile", "laser_guided", "radar_guided", "heat_seeking"
    },
    
    -- Performance Settings
    MaxCountermeasureSystems = 15,
    AutoDeployment = true,
    ThreatAssessment = true,
    FleetCoordination = true,
    
    -- Integration Settings
    CAPIntegration = true,
    TacticalAIIntegration = true,
    PointDefenseIntegration = true
}

-- Countermeasures Core System
ASC.Countermeasures.Core = {
    -- Active countermeasure systems
    CountermeasureSystems = {},
    
    -- Active countermeasures in the field
    ActiveCountermeasures = {},
    
    -- Threat tracking
    DetectedThreats = {},
    
    -- Performance tracking
    TotalDeployments = 0,
    SuccessfulDeflections = 0,
    EffectivenessRate = 0,
    
    -- Initialize countermeasures system
    Initialize = function(shipCore, systemType)
        if not IsValid(shipCore) then
            return false, "Invalid ship core"
        end
        
        local shipID = shipCore:EntIndex()
        systemType = systemType or "STANDARD"
        
        if ASC.Countermeasures.Core.CountermeasureSystems[shipID] then
            return false, "Countermeasures already initialized"
        end
        
        ASC.Countermeasures.Core.CountermeasureSystems[shipID] = {
            shipCore = shipCore,
            systemType = systemType,
            config = ASC.Countermeasures.Config,
            
            -- System status
            active = false,
            energy = 100,
            
            -- Countermeasure inventory
            inventory = {
                CHAFF = ASC.Countermeasures.Config.CountermeasureTypes.CHAFF.capacity,
                FLARE = ASC.Countermeasures.Config.CountermeasureTypes.FLARE.capacity,
                ECM = ASC.Countermeasures.Config.CountermeasureTypes.ECM.capacity,
                DECOY = ASC.Countermeasures.Config.CountermeasureTypes.DECOY.capacity
            },
            
            -- Deployment tracking
            lastDeployment = {},
            deploymentHistory = {},
            
            -- Threat assessment
            currentThreats = {},
            threatLevel = 0,
            
            -- Performance tracking
            deploymentsCount = 0,
            successfulDeflections = 0,
            efficiency = 1.0,
            
            -- Timing
            lastUpdate = CurTime(),
            lastThreatScan = 0
        }
        
        -- Initialize countermeasure dispensers
        ASC.Countermeasures.Core.InitializeDispensers(shipID)
        
        -- Start countermeasures system
        ASC.Countermeasures.Core.ActivateCountermeasures(shipID)
        
        print("[Countermeasures] Initialized " .. systemType .. " countermeasures for ship " .. shipID)
        return true, "Countermeasures system initialized"
    end,
    
    -- Initialize countermeasure dispensers
    InitializeDispensers = function(shipID)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return end
        
        -- Find nearby countermeasure dispensers
        local dispensers = ASC.Countermeasures.Core.FindDispensers(system.shipCore)
        system.dispensers = dispensers
        
        print("[Countermeasures] Found " .. #dispensers .. " dispensers for ship " .. shipID)
    end,
    
    -- Find countermeasure dispensers near ship core
    FindDispensers = function(shipCore)
        local dispensers = {}
        local shipPos = shipCore:GetPos()
        
        for _, ent in ipairs(ents.FindInSphere(shipPos, ASC.Countermeasures.Config.MaxRange)) do
            if IsValid(ent) and ent:GetClass() == "asc_countermeasures" then
                table.insert(dispensers, ent)
            end
        end
        
        return dispensers
    end,
    
    -- Activate countermeasures system
    ActivateCountermeasures = function(shipID)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return false end
        
        system.active = true
        system.lastUpdate = CurTime()
        
        -- Start countermeasures update timer
        timer.Create("ASC_Countermeasures_" .. shipID, ASC.Countermeasures.Config.UpdateRate, 0, function()
            ASC.Countermeasures.Core.UpdateCountermeasures(shipID)
        end)
        
        print("[Countermeasures] Activated countermeasures for ship " .. shipID)
        return true
    end,
    
    -- Update countermeasures system
    UpdateCountermeasures = function(shipID)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system or not system.active then return end
        
        local currentTime = CurTime()
        
        -- Scan for threats
        ASC.Countermeasures.Core.ScanForThreats(shipID, currentTime)
        
        -- Assess threat level
        ASC.Countermeasures.Core.AssessThreatLevel(shipID)
        
        -- Auto-deploy countermeasures if needed
        if ASC.Countermeasures.Config.AutoDeployment then
            ASC.Countermeasures.Core.AutoDeployCountermeasures(shipID, currentTime)
        end
        
        -- Update active countermeasures
        ASC.Countermeasures.Core.UpdateActiveCountermeasures(shipID, currentTime)
        
        -- Update performance metrics
        ASC.Countermeasures.Core.UpdatePerformanceMetrics(shipID)
        
        system.lastUpdate = currentTime
    end,
    
    -- Scan for incoming threats
    ScanForThreats = function(shipID, currentTime)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return end
        
        -- Only scan periodically to save performance
        if currentTime - system.lastThreatScan < 0.2 then return end
        system.lastThreatScan = currentTime
        
        local shipPos = system.shipCore:GetPos()
        local threats = {}
        
        -- Find potential threats in range
        for _, ent in ipairs(ents.FindInSphere(shipPos, ASC.Countermeasures.Config.MaxRange)) do
            if ASC.Countermeasures.Core.IsValidThreat(ent, system) then
                local threatData = ASC.Countermeasures.Core.AnalyzeThreat(ent, system)
                if threatData then
                    table.insert(threats, threatData)
                end
            end
        end
        
        -- Sort threats by danger level
        table.sort(threats, function(a, b)
            return a.dangerLevel > b.dangerLevel
        end)
        
        system.currentThreats = threats
    end,
    
    -- Check if entity is a valid threat
    IsValidThreat = function(ent, system)
        if not IsValid(ent) then return false end
        
        local class = ent:GetClass()
        
        -- Check threat types
        for _, threatType in ipairs(ASC.Countermeasures.Config.ThreatTypes) do
            if string.find(class, threatType) then
                return true
            end
        end
        
        -- Check for guided projectiles
        if ent.IsGuided and ent:IsGuided() then
            return true
        end
        
        return false
    end,
    
    -- Analyze threat and calculate danger level
    AnalyzeThreat = function(ent, system)
        local shipPos = system.shipCore:GetPos()
        local threatPos = ent:GetPos()
        local distance = shipPos:Distance(threatPos)
        
        if distance > ASC.Countermeasures.Config.MaxRange then
            return nil
        end
        
        local velocity = ent:GetVelocity()
        local speed = velocity:Length()
        
        -- Calculate danger level
        local danger = ASC.Countermeasures.Core.CalculateDangerLevel(ent, system, distance, speed)
        
        -- Determine best countermeasure type
        local bestCountermeasure = ASC.Countermeasures.Core.DetermineBestCountermeasure(ent)
        
        return {
            entity = ent,
            position = threatPos,
            velocity = velocity,
            speed = speed,
            distance = distance,
            dangerLevel = danger,
            timeToImpact = distance / math.max(speed, 1),
            bestCountermeasure = bestCountermeasure,
            lastSeen = CurTime()
        }
    end,
    
    -- Calculate danger level of threat
    CalculateDangerLevel = function(ent, system, distance, speed)
        local danger = 1.0
        local class = ent:GetClass()
        
        -- Base danger by type
        if string.find(class, "missile") then
            danger = 10.0
        elseif string.find(class, "torpedo") then
            danger = 8.0
        elseif string.find(class, "guided") then
            danger = 6.0
        end
        
        -- Increase danger for fast-moving threats
        if speed > 800 then
            danger = danger * 1.5
        end
        
        -- Increase danger for close threats
        if distance < 500 then
            danger = danger * 2.0
        end
        
        return danger
    end,
    
    -- Determine best countermeasure for threat
    DetermineBestCountermeasure = function(ent)
        local class = ent:GetClass()
        
        if string.find(class, "heat") or string.find(class, "thermal") then
            return "FLARE"
        elseif string.find(class, "radar") or string.find(class, "guided") then
            return "CHAFF"
        elseif string.find(class, "laser") or string.find(class, "beam") then
            return "ECM"
        else
            return "DECOY"
        end
    end,
    
    -- Assess overall threat level
    AssessThreatLevel = function(shipID)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return end

        local totalThreat = 0
        for _, threat in ipairs(system.currentThreats) do
            totalThreat = totalThreat + threat.dangerLevel
        end

        system.threatLevel = totalThreat
    end,

    -- Auto-deploy countermeasures based on threat assessment
    AutoDeployCountermeasures = function(shipID, currentTime)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return end

        -- Deploy countermeasures for high-priority threats
        for _, threat in ipairs(system.currentThreats) do
            if threat.dangerLevel > 5.0 and threat.timeToImpact < 3.0 then
                ASC.Countermeasures.Core.DeployCountermeasure(shipID, threat.bestCountermeasure, threat)
            end
        end
    end,

    -- Deploy specific countermeasure
    DeployCountermeasure = function(shipID, countermeasureType, threat)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return false end

        local config = ASC.Countermeasures.Config.CountermeasureTypes[countermeasureType]
        if not config then return false end

        -- Check inventory
        if system.inventory[countermeasureType] <= 0 then
            return false, "No " .. countermeasureType .. " remaining"
        end

        -- Check cooldown
        local lastDeploy = system.lastDeployment[countermeasureType] or 0
        if CurTime() - lastDeploy < config.cooldown then
            return false, "Countermeasure on cooldown"
        end

        -- Deploy countermeasure
        local success = ASC.Countermeasures.Core.CreateCountermeasure(shipID, countermeasureType, threat)

        if success then
            -- Update inventory and tracking
            system.inventory[countermeasureType] = system.inventory[countermeasureType] - 1
            system.lastDeployment[countermeasureType] = CurTime()
            system.deploymentsCount = system.deploymentsCount + 1

            -- Add to deployment history
            table.insert(system.deploymentHistory, {
                type = countermeasureType,
                time = CurTime(),
                threat = threat and threat.entity:GetClass() or "Unknown",
                success = false -- Will be updated later
            })

            print("[Countermeasures] Deployed " .. countermeasureType .. " against " .. (threat and threat.entity:GetClass() or "threat"))
            return true
        end

        return false, "Failed to deploy countermeasure"
    end,

    -- Create countermeasure entity
    CreateCountermeasure = function(shipID, countermeasureType, threat)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return false end

        local shipPos = system.shipCore:GetPos()
        local config = ASC.Countermeasures.Config.CountermeasureTypes[countermeasureType]

        -- Create countermeasure entity
        local countermeasure = ents.Create("asc_countermeasure_" .. string.lower(countermeasureType))
        if not IsValid(countermeasure) then
            -- Fallback to generic countermeasure
            countermeasure = ents.Create("asc_countermeasure")
            if not IsValid(countermeasure) then
                return false
            end
            countermeasure:SetCountermeasureType(countermeasureType)
        end

        -- Position countermeasure
        local deployPos = shipPos + VectorRand() * 100
        countermeasure:SetPos(deployPos)
        countermeasure:SetAngles(AngleRand())
        countermeasure:Spawn()
        countermeasure:Activate()

        -- Set countermeasure properties
        countermeasure:SetDuration(config.duration)
        countermeasure:SetEffectiveness(config.effectiveness)
        countermeasure:SetOwner(system.shipCore)

        if threat then
            countermeasure:SetTarget(threat.entity)
        end

        -- Track active countermeasure
        ASC.Countermeasures.Core.ActiveCountermeasures[countermeasure:EntIndex()] = {
            entity = countermeasure,
            type = countermeasureType,
            deployTime = CurTime(),
            duration = config.duration,
            shipID = shipID,
            threat = threat
        }

        -- Remove after duration
        timer.Simple(config.duration, function()
            if IsValid(countermeasure) then
                countermeasure:Remove()
            end
            ASC.Countermeasures.Core.ActiveCountermeasures[countermeasure:EntIndex()] = nil
        end)

        return true
    end,

    -- Update active countermeasures
    UpdateActiveCountermeasures = function(shipID, currentTime)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return end

        -- Check for successful deflections
        for entIndex, cmData in pairs(ASC.Countermeasures.Core.ActiveCountermeasures) do
            if cmData.shipID == shipID and cmData.threat then
                if not IsValid(cmData.threat.entity) then
                    -- Threat destroyed/deflected
                    system.successfulDeflections = system.successfulDeflections + 1
                    ASC.Countermeasures.Core.SuccessfulDeflections = ASC.Countermeasures.Core.SuccessfulDeflections + 1

                    -- Update deployment history
                    for _, deployment in ipairs(system.deploymentHistory) do
                        if deployment.time == cmData.deployTime then
                            deployment.success = true
                            break
                        end
                    end

                    cmData.threat = nil -- Mark as processed
                end
            end
        end
    end,

    -- Update performance metrics
    UpdatePerformanceMetrics = function(shipID)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return end

        -- Calculate efficiency
        if system.deploymentsCount > 0 then
            system.efficiency = system.successfulDeflections / system.deploymentsCount
        end

        -- Update global stats
        ASC.Countermeasures.Core.TotalDeployments = ASC.Countermeasures.Core.TotalDeployments + system.deploymentsCount

        if ASC.Countermeasures.Core.TotalDeployments > 0 then
            ASC.Countermeasures.Core.EffectivenessRate = ASC.Countermeasures.Core.SuccessfulDeflections / ASC.Countermeasures.Core.TotalDeployments
        end
    end,

    -- Manual countermeasure deployment
    ManualDeploy = function(shipID, countermeasureType)
        return ASC.Countermeasures.Core.DeployCountermeasure(shipID, countermeasureType, nil)
    end,

    -- Get countermeasures status
    GetCountermeasuresStatus = function(shipID)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return nil end

        return {
            active = system.active,
            threatLevel = system.threatLevel,
            currentThreats = #system.currentThreats,
            inventory = system.inventory,
            efficiency = system.efficiency,
            deployments = system.deploymentsCount,
            deflections = system.successfulDeflections
        }
    end,

    -- Deactivate countermeasures
    DeactivateCountermeasures = function(shipID)
        local system = ASC.Countermeasures.Core.CountermeasureSystems[shipID]
        if not system then return false end

        system.active = false
        timer.Remove("ASC_Countermeasures_" .. shipID)

        print("[Countermeasures] Deactivated countermeasures for ship " .. shipID)
        return true
    end,

    -- Remove countermeasures system
    RemoveCountermeasuresSystem = function(shipID)
        ASC.Countermeasures.Core.DeactivateCountermeasures(shipID)
        ASC.Countermeasures.Core.CountermeasureSystems[shipID] = nil

        print("[Countermeasures] Removed countermeasures system for ship " .. shipID)
    end
}

-- Console commands for countermeasures
concommand.Add("asc_countermeasures_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local shipCore = ASC.AI.FindPlayerShipCore(ply)
    if not IsValid(shipCore) then
        ply:ChatPrint("[Countermeasures] No ship core found")
        return
    end

    local status = ASC.Countermeasures.Core.GetCountermeasuresStatus(shipCore:EntIndex())
    if not status then
        ply:ChatPrint("[Countermeasures] No countermeasures system found")
        return
    end

    ply:ChatPrint("[Countermeasures] Status:")
    ply:ChatPrint("• Active: " .. (status.active and "Yes" or "No"))
    ply:ChatPrint("• Threat Level: " .. math.floor(status.threatLevel))
    ply:ChatPrint("• Current Threats: " .. status.currentThreats)
    ply:ChatPrint("• Chaff: " .. status.inventory.CHAFF)
    ply:ChatPrint("• Flares: " .. status.inventory.FLARE)
    ply:ChatPrint("• ECM: " .. status.inventory.ECM)
    ply:ChatPrint("• Decoys: " .. status.inventory.DECOY)
    ply:ChatPrint("• Efficiency: " .. math.floor(status.efficiency * 100) .. "%")
end)

-- Manual deployment commands
concommand.Add("asc_deploy_chaff", function(ply, cmd, args)
    if not IsValid(ply) then return end
    local shipCore = ASC.AI.FindPlayerShipCore(ply)
    if IsValid(shipCore) then
        local success, msg = ASC.Countermeasures.Core.ManualDeploy(shipCore:EntIndex(), "CHAFF")
        ply:ChatPrint("[Countermeasures] " .. (msg or (success and "Chaff deployed" or "Failed to deploy chaff")))
    end
end)

-- Initialize countermeasures system on addon load
hook.Add("Initialize", "ASC_Countermeasures_Init", function()
    print("[Advanced Space Combat] Countermeasures & ECM System v3.0.0 loaded")
end)
}
