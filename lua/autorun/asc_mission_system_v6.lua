-- Advanced Space Combat - Mission & Quest System v6.0.0
-- Dynamic mission generation, quest management, and narrative progression
-- Research-based implementation following 2025 game design best practices

print("[Advanced Space Combat] Mission & Quest System v6.0.0 - Dynamic Content Generation Loading...")

-- Initialize mission namespace
ASC = ASC or {}
ASC.Missions = ASC.Missions or {}

-- Mission system configuration
ASC.Missions.Config = {
    Version = "6.0.0",
    
    -- Mission generation
    Generation = {
        Enabled = true,
        DynamicMissions = true,
        AdaptiveDifficulty = true,
        PlayerSkillScaling = true,
        RandomEvents = true
    },
    
    -- Mission types
    Types = {
        EXPLORATION = {
            name = "Exploration",
            difficulty = 1,
            duration = 300,  -- 5 minutes
            rewards = {"experience", "resources"}
        },
        COMBAT = {
            name = "Combat",
            difficulty = 3,
            duration = 600,  -- 10 minutes
            rewards = {"experience", "weapons", "upgrades"}
        },
        RESCUE = {
            name = "Rescue",
            difficulty = 2,
            duration = 450,  -- 7.5 minutes
            rewards = {"experience", "reputation", "allies"}
        },
        TRANSPORT = {
            name = "Transport",
            difficulty = 1,
            duration = 240,  -- 4 minutes
            rewards = {"credits", "resources"}
        },
        RESEARCH = {
            name = "Research",
            difficulty = 2,
            duration = 480,  -- 8 minutes
            rewards = {"technology", "blueprints", "knowledge"}
        },
        DIPLOMACY = {
            name = "Diplomacy",
            difficulty = 2,
            duration = 360,  -- 6 minutes
            rewards = {"reputation", "allies", "trade_routes"}
        }
    },
    
    -- Difficulty scaling
    Difficulty = {
        Beginner = {multiplier = 0.5, maxEnemies = 2},
        Intermediate = {multiplier = 1.0, maxEnemies = 4},
        Advanced = {multiplier = 1.5, maxEnemies = 6},
        Expert = {multiplier = 2.0, maxEnemies = 8},
        Master = {multiplier = 3.0, maxEnemies = 12}
    },
    
    -- Reward system
    Rewards = {
        Experience = {base = 100, scaling = 1.2},
        Credits = {base = 500, scaling = 1.5},
        Resources = {base = 50, scaling = 1.1},
        Reputation = {base = 25, scaling = 1.3}
    }
}

-- Mission state
ASC.Missions.State = {
    ActiveMissions = {},
    CompletedMissions = {},
    AvailableMissions = {},
    PlayerProgress = {},
    GlobalEvents = {},
    MissionCounter = 0
}

-- Mission class
ASC.Missions.Mission = {}
ASC.Missions.Mission.__index = ASC.Missions.Mission

function ASC.Missions.Mission:New(missionType, player, customData)
    local mission = setmetatable({}, ASC.Missions.Mission)
    
    mission.id = ASC.Missions.State.MissionCounter + 1
    ASC.Missions.State.MissionCounter = mission.id
    
    mission.type = missionType
    mission.player = player
    mission.playerId = IsValid(player) and player:SteamID() or "unknown"
    mission.status = "available"
    mission.progress = 0
    mission.startTime = 0
    mission.endTime = 0
    mission.objectives = {}
    mission.rewards = {}
    mission.difficulty = 1
    mission.customData = customData or {}
    
    -- Generate mission content
    mission:GenerateContent()
    
    return mission
end

function ASC.Missions.Mission:GenerateContent()
    local missionConfig = ASC.Missions.Config.Types[self.type]
    if not missionConfig then return end
    
    -- Set basic properties
    self.name = self:GenerateName()
    self.description = self:GenerateDescription()
    self.difficulty = self:CalculateDifficulty()
    self.duration = missionConfig.duration * (0.8 + math.random() * 0.4)  -- ±20% variation
    
    -- Generate objectives
    self:GenerateObjectives()
    
    -- Generate rewards
    self:GenerateRewards()
    
    -- Set location
    self:GenerateLocation()
end

function ASC.Missions.Mission:GenerateName()
    local nameTemplates = {
        EXPLORATION = {
            "Explore the {location}",
            "Survey {location}",
            "Investigate {location}",
            "Scout {location}"
        },
        COMBAT = {
            "Eliminate {enemy} forces",
            "Defend {location}",
            "Attack {target}",
            "Neutralize {threat}"
        },
        RESCUE = {
            "Rescue {target}",
            "Extract {personnel}",
            "Save {civilians}",
            "Evacuate {location}"
        },
        TRANSPORT = {
            "Deliver {cargo} to {destination}",
            "Transport {passengers}",
            "Supply {location}",
            "Courier mission to {destination}"
        },
        RESEARCH = {
            "Research {technology}",
            "Analyze {artifact}",
            "Study {phenomenon}",
            "Investigate {anomaly}"
        },
        DIPLOMACY = {
            "Negotiate with {faction}",
            "Establish relations with {group}",
            "Mediate {conflict}",
            "Form alliance with {allies}"
        }
    }
    
    local templates = nameTemplates[self.type] or {"Generic Mission"}
    local template = templates[math.random(1, #templates)]
    
    -- Replace placeholders
    template = string.gsub(template, "{location}", self:GetRandomLocation())
    template = string.gsub(template, "{enemy}", self:GetRandomEnemy())
    template = string.gsub(template, "{target}", self:GetRandomTarget())
    template = string.gsub(template, "{faction}", self:GetRandomFaction())
    
    return template
end

function ASC.Missions.Mission:GenerateDescription()
    local descriptions = {
        EXPLORATION = "Venture into uncharted space and gather valuable intelligence about the area.",
        COMBAT = "Engage hostile forces and eliminate the threat to secure the region.",
        RESCUE = "Locate and extract personnel from a dangerous situation.",
        TRANSPORT = "Safely deliver cargo or passengers to their destination.",
        RESEARCH = "Conduct scientific research and gather important data.",
        DIPLOMACY = "Engage in diplomatic negotiations to achieve peaceful resolution."
    }
    
    return descriptions[self.type] or "Complete the assigned objectives."
end

function ASC.Missions.Mission:GenerateObjectives()
    local objectiveTemplates = {
        EXPLORATION = {
            {type = "visit", target = "location", count = 3, description = "Visit 3 points of interest"},
            {type = "scan", target = "objects", count = 5, description = "Scan 5 unknown objects"},
            {type = "survive", target = "time", count = 300, description = "Survive for 5 minutes"}
        },
        COMBAT = {
            {type = "eliminate", target = "enemies", count = 8, description = "Eliminate 8 hostile entities"},
            {type = "destroy", target = "structures", count = 3, description = "Destroy 3 enemy structures"},
            {type = "defend", target = "location", count = 1, description = "Defend the location"}
        },
        RESCUE = {
            {type = "locate", target = "personnel", count = 1, description = "Locate the missing personnel"},
            {type = "extract", target = "survivors", count = 5, description = "Extract 5 survivors"},
            {type = "escort", target = "convoy", count = 1, description = "Escort convoy to safety"}
        },
        TRANSPORT = {
            {type = "pickup", target = "cargo", count = 1, description = "Pick up the cargo"},
            {type = "deliver", target = "destination", count = 1, description = "Deliver to destination"},
            {type = "protect", target = "cargo", count = 1, description = "Protect cargo during transport"}
        },
        RESEARCH = {
            {type = "collect", target = "samples", count = 10, description = "Collect 10 research samples"},
            {type = "analyze", target = "data", count = 1, description = "Analyze collected data"},
            {type = "document", target = "findings", count = 1, description = "Document research findings"}
        },
        DIPLOMACY = {
            {type = "contact", target = "faction", count = 1, description = "Establish contact with faction"},
            {type = "negotiate", target = "terms", count = 1, description = "Negotiate agreement terms"},
            {type = "sign", target = "treaty", count = 1, description = "Finalize the agreement"}
        }
    }
    
    local templates = objectiveTemplates[self.type] or {}
    
    for _, template in ipairs(templates) do
        local objective = {
            id = #self.objectives + 1,
            type = template.type,
            target = template.target,
            required = template.count,
            current = 0,
            description = template.description,
            completed = false
        }
        
        table.insert(self.objectives, objective)
    end
end

function ASC.Missions.Mission:GenerateRewards()
    local missionConfig = ASC.Missions.Config.Types[self.type]
    if not missionConfig then return end
    
    local rewardConfig = ASC.Missions.Config.Rewards
    local difficultyMultiplier = self.difficulty
    
    for _, rewardType in ipairs(missionConfig.rewards) do
        if rewardConfig[rewardType] then
            local baseAmount = rewardConfig[rewardType].base
            local scaling = rewardConfig[rewardType].scaling
            local amount = math.floor(baseAmount * (difficultyMultiplier ^ scaling))
            
            table.insert(self.rewards, {
                type = rewardType,
                amount = amount,
                description = self:GetRewardDescription(rewardType, amount)
            })
        end
    end
end

function ASC.Missions.Mission:GetRewardDescription(rewardType, amount)
    local descriptions = {
        experience = amount .. " Experience Points",
        credits = amount .. " Credits",
        resources = amount .. " Resource Units",
        reputation = "+" .. amount .. " Reputation",
        weapons = "Advanced Weapon Blueprint",
        upgrades = "Ship Upgrade Component",
        technology = "New Technology Research",
        blueprints = "Construction Blueprints",
        knowledge = "Scientific Knowledge",
        allies = "New Faction Alliance",
        trade_routes = "Trade Route Access"
    }
    
    return descriptions[rewardType] or "Unknown Reward"
end

function ASC.Missions.Mission:CalculateDifficulty()
    -- Base difficulty from mission type
    local baseDifficulty = ASC.Missions.Config.Types[self.type].difficulty
    
    -- Player skill scaling
    if ASC.Missions.Config.Generation.PlayerSkillScaling and IsValid(self.player) then
        local playerProfile = ASC.Analytics and ASC.Analytics.Data and ASC.Analytics.Data.UserProfiles and ASC.Analytics.Data.UserProfiles[self.player:SteamID()]
        if playerProfile then
            local skillMultiplier = 1.0
            if playerProfile.skillLevel == "expert" then
                skillMultiplier = 1.5
            elseif playerProfile.skillLevel == "intermediate" then
                skillMultiplier = 1.2
            elseif playerProfile.skillLevel == "beginner" then
                skillMultiplier = 0.8
            end
            baseDifficulty = baseDifficulty * skillMultiplier
        end
    end
    
    -- Random variation
    baseDifficulty = baseDifficulty * (0.8 + math.random() * 0.4)
    
    return math.max(1, math.min(5, baseDifficulty))
end

function ASC.Missions.Mission:Start()
    if self.status ~= "available" then return false end
    
    self.status = "active"
    self.startTime = CurTime()
    self.progress = 0
    
    -- Add to active missions
    ASC.Missions.State.ActiveMissions[self.id] = self
    
    -- Notify player
    if IsValid(self.player) then
        self.player:ChatPrint("[ASC Missions] Mission started: " .. self.name)
        
        -- Show objectives
        for _, objective in ipairs(self.objectives) do
            self.player:ChatPrint("  • " .. objective.description)
        end
    end
    
    -- Track in analytics
    if ASC.Analytics then
        ASC.Analytics.TrackEvent("mission_started", {
            missionId = self.id,
            missionType = self.type,
            difficulty = self.difficulty,
            player = IsValid(self.player) and self.player:Name() or "Unknown"
        })
    end
    
    print("[ASC Missions] Mission " .. self.id .. " started: " .. self.name)
    return true
end

function ASC.Missions.Mission:UpdateObjective(objectiveType, target, amount)
    amount = amount or 1
    
    for _, objective in ipairs(self.objectives) do
        if objective.type == objectiveType and objective.target == target and not objective.completed then
            objective.current = math.min(objective.required, objective.current + amount)
            
            if objective.current >= objective.required then
                objective.completed = true
                
                -- Notify player
                if IsValid(self.player) then
                    self.player:ChatPrint("[ASC Missions] Objective completed: " .. objective.description)
                end
            end
            
            -- Update mission progress
            self:UpdateProgress()
            break
        end
    end
end

function ASC.Missions.Mission:UpdateProgress()
    local completedObjectives = 0
    local totalObjectives = #self.objectives
    
    for _, objective in ipairs(self.objectives) do
        if objective.completed then
            completedObjectives = completedObjectives + 1
        end
    end
    
    self.progress = totalObjectives > 0 and (completedObjectives / totalObjectives) or 0
    
    -- Check if mission is complete
    if self.progress >= 1.0 and self.status == "active" then
        self:Complete()
    end
end

function ASC.Missions.Mission:Complete()
    if self.status ~= "active" then return false end
    
    self.status = "completed"
    self.endTime = CurTime()
    
    -- Remove from active missions
    ASC.Missions.State.ActiveMissions[self.id] = nil
    
    -- Add to completed missions
    ASC.Missions.State.CompletedMissions[self.id] = self
    
    -- Give rewards
    self:GiveRewards()
    
    -- Notify player
    if IsValid(self.player) then
        self.player:ChatPrint("[ASC Missions] Mission completed: " .. self.name)
        self.player:ChatPrint("[ASC Missions] Rewards received!")
    end
    
    -- Track in analytics
    if ASC.Analytics then
        ASC.Analytics.TrackEvent("mission_completed", {
            missionId = self.id,
            missionType = self.type,
            difficulty = self.difficulty,
            duration = self.endTime - self.startTime,
            player = IsValid(self.player) and self.player:Name() or "Unknown"
        })
    end
    
    print("[ASC Missions] Mission " .. self.id .. " completed: " .. self.name)
    return true
end

function ASC.Missions.Mission:GiveRewards()
    if not IsValid(self.player) then return end
    
    for _, reward in ipairs(self.rewards) do
        -- Apply reward based on type
        if reward.type == "experience" then
            -- Would integrate with experience system
            self.player:ChatPrint("  + " .. reward.description)
        elseif reward.type == "credits" then
            -- Would integrate with economy system
            self.player:ChatPrint("  + " .. reward.description)
        elseif reward.type == "resources" then
            -- Would integrate with resource system
            self.player:ChatPrint("  + " .. reward.description)
        else
            self.player:ChatPrint("  + " .. reward.description)
        end
    end
end

-- Helper functions
function ASC.Missions.Mission:GetRandomLocation()
    local locations = {"Nebula Sector", "Asteroid Field", "Deep Space", "Binary System", "Wormhole Junction", "Space Station"}
    return locations[math.random(1, #locations)]
end

function ASC.Missions.Mission:GetRandomEnemy()
    local enemies = {"Pirate", "Hostile Alien", "Rogue AI", "Mercenary", "Rebel", "Unknown Entity"}
    return enemies[math.random(1, #enemies)]
end

function ASC.Missions.Mission:GetRandomTarget()
    local targets = {"Research Team", "Diplomatic Envoy", "Stranded Pilots", "Civilian Transport", "Science Vessel"}
    return targets[math.random(1, #targets)]
end

function ASC.Missions.Mission:GetRandomFaction()
    local factions = {"Trade Federation", "Scientific Consortium", "Mining Guild", "Explorer Alliance", "Peacekeeping Force"}
    return factions[math.random(1, #factions)]
end

function ASC.Missions.Mission:GenerateLocation()
    -- Generate random coordinates for mission location
    self.location = {
        x = math.random(-10000, 10000),
        y = math.random(-10000, 10000),
        z = math.random(-1000, 1000)
    }
end

-- Mission management functions
ASC.Missions.GenerateMission = function(player, missionType)
    if not IsValid(player) then return nil end

    missionType = missionType or ASC.Missions.GetRandomMissionType()

    local mission = ASC.Missions.Mission:New(missionType, player)

    -- Add to available missions
    ASC.Missions.State.AvailableMissions[mission.id] = mission

    return mission
end

ASC.Missions.GetRandomMissionType = function()
    local types = {}
    for missionType, _ in pairs(ASC.Missions.Config.Types) do
        table.insert(types, missionType)
    end
    return types[math.random(1, #types)]
end

ASC.Missions.GetPlayerMissions = function(player, status)
    if not IsValid(player) then return {} end

    local playerId = player:SteamID()
    local missions = {}

    local searchTable = ASC.Missions.State.ActiveMissions
    if status == "available" then
        searchTable = ASC.Missions.State.AvailableMissions
    elseif status == "completed" then
        searchTable = ASC.Missions.State.CompletedMissions
    end

    for _, mission in pairs(searchTable) do
        if mission.playerId == playerId then
            table.insert(missions, mission)
        end
    end

    return missions
end

ASC.Missions.Update = function()
    -- Update active missions
    for missionId, mission in pairs(ASC.Missions.State.ActiveMissions) do
        if mission.status == "active" then
            -- Check for timeout
            local elapsed = CurTime() - mission.startTime
            if elapsed > mission.duration then
                mission:Fail()
            end
        end
    end

    -- Generate new missions for players
    if ASC.Missions.Config.Generation.DynamicMissions then
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                local activeMissions = ASC.Missions.GetPlayerMissions(player, "active")
                local availableMissions = ASC.Missions.GetPlayerMissions(player, "available")

                -- Generate new mission if player has few available
                if #activeMissions < 2 and #availableMissions < 3 then
                    ASC.Missions.GenerateMission(player)
                end
            end
        end
    end
end

-- Console commands
concommand.Add("asc_mission_list", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local status = args[1] or "active"
    local missions = ASC.Missions.GetPlayerMissions(ply, status)

    ply:ChatPrint("[ASC Missions] " .. string.upper(status) .. " Missions:")

    if #missions == 0 then
        ply:ChatPrint("  No " .. status .. " missions found.")
    else
        for _, mission in ipairs(missions) do
            local progressText = ""
            if mission.status == "active" then
                progressText = " (" .. math.Round(mission.progress * 100) .. "%)"
            end
            ply:ChatPrint("  " .. mission.id .. ". " .. mission.name .. progressText)
        end
    end
end, nil, "List player missions")

concommand.Add("asc_mission_start", function(ply, cmd, args)
    if not IsValid(ply) or #args == 0 then return end

    local missionId = tonumber(args[1])
    if not missionId then return end

    local mission = ASC.Missions.State.AvailableMissions[missionId]
    if mission and mission.playerId == ply:SteamID() then
        mission:Start()
    else
        ply:ChatPrint("[ASC Missions] Mission not found or not available.")
    end
end, nil, "Start a mission")

concommand.Add("asc_mission_generate", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local missionType = args[1] and string.upper(args[1]) or nil

    if missionType and not ASC.Missions.Config.Types[missionType] then
        ply:ChatPrint("[ASC Missions] Invalid mission type. Available: " .. table.concat(table.GetKeys(ASC.Missions.Config.Types), ", "))
        return
    end

    local mission = ASC.Missions.GenerateMission(ply, missionType)
    if mission then
        ply:ChatPrint("[ASC Missions] New mission generated: " .. mission.name)
    else
        ply:ChatPrint("[ASC Missions] Failed to generate mission.")
    end
end, nil, "Generate a new mission")

-- Initialize mission system
function ASC.Missions.Initialize()
    print("[ASC Missions] Initializing mission system...")

    -- Generate initial missions for existing players
    timer.Simple(5, function()
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) then
                -- Generate 2 initial missions
                ASC.Missions.GenerateMission(player)
                ASC.Missions.GenerateMission(player)
            end
        end
    end)

    -- Start update timer
    timer.Create("ASC_Missions_Update", 30, 0, ASC.Missions.Update)

    print("[ASC Missions] Mission system initialized")
end

-- Hook into player events
hook.Add("PlayerInitialSpawn", "ASC_Missions_PlayerJoin", function(player)
    timer.Simple(10, function()
        if IsValid(player) then
            -- Generate welcome missions
            ASC.Missions.GenerateMission(player, "EXPLORATION")
            ASC.Missions.GenerateMission(player, "TRANSPORT")

            player:ChatPrint("[ASC Missions] Welcome! New missions have been generated for you.")
            player:ChatPrint("[ASC Missions] Use 'asc_mission_list available' to see available missions.")
        end
    end)
end)

-- Hook into core events
if ASC.Events then
    ASC.Events.Register("CoreInitialized", ASC.Missions.Initialize, 1)
end

-- Server initialization
if SERVER then
    hook.Add("Initialize", "ASC_Missions_Initialize", function()
        timer.Simple(5, ASC.Missions.Initialize)
    end)
end

print("[Advanced Space Combat] Mission & Quest System v6.0.0 - Dynamic Content Generation Loaded Successfully!")
