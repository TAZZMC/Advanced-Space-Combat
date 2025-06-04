-- Advanced Space Combat - World Events & Dynamic Content System v6.0.0
-- Dynamic world events, emergent gameplay, and procedural content generation
-- Research-based implementation following 2025 dynamic content best practices

print("[Advanced Space Combat] World Events & Dynamic Content System v6.0.0 - Dynamic Universe Loading...")

-- Initialize world events namespace
ASC = ASC or {}
ASC.WorldEvents = ASC.WorldEvents or {}

-- World events configuration
ASC.WorldEvents.Config = {
    Version = "6.0.0",
    
    -- Event generation
    Generation = {
        Enabled = true,
        BaseEventChance = 0.1,  -- 10% chance per check
        CheckInterval = 300,    -- 5 minutes
        MaxActiveEvents = 5,
        EventDuration = 1800,   -- 30 minutes default
        PlayerProximityRequired = true
    },
    
    -- Event types
    Types = {
        ANOMALY = {
            name = "Space Anomaly",
            rarity = "common",
            duration = 900,  -- 15 minutes
            rewards = {"research_data", "rare_materials"},
            requirements = {"exploration_skill"}
        },
        DISTRESS_CALL = {
            name = "Distress Call",
            rarity = "common",
            duration = 1200,  -- 20 minutes
            rewards = {"reputation", "credits", "allies"},
            requirements = {"combat_readiness"}
        },
        PIRATE_RAID = {
            name = "Pirate Raid",
            rarity = "uncommon",
            duration = 1800,  -- 30 minutes
            rewards = {"combat_experience", "salvage", "bounty"},
            requirements = {"combat_capability"}
        },
        TRADE_CONVOY = {
            name = "Trade Convoy",
            rarity = "common",
            duration = 600,   -- 10 minutes
            rewards = {"trade_opportunities", "credits", "reputation"},
            requirements = {"trading_license"}
        },
        ANCIENT_RELIC = {
            name = "Ancient Relic Discovery",
            rarity = "rare",
            duration = 2400,  -- 40 minutes
            rewards = {"ancient_technology", "massive_experience", "prestige"},
            requirements = {"advanced_scanning", "archaeology_skill"}
        },
        DIPLOMATIC_CRISIS = {
            name = "Diplomatic Crisis",
            rarity = "uncommon",
            duration = 1800,  -- 30 minutes
            rewards = {"diplomatic_standing", "alliance_opportunities", "influence"},
            requirements = {"diplomacy_skill", "reputation"}
        },
        RESOURCE_RUSH = {
            name = "Resource Rush",
            rarity = "uncommon",
            duration = 1200,  -- 20 minutes
            rewards = {"rare_resources", "mining_rights", "economic_boost"},
            requirements = {"mining_equipment", "industrial_backing"}
        },
        STELLAR_PHENOMENON = {
            name = "Stellar Phenomenon",
            rarity = "rare",
            duration = 3600,  -- 1 hour
            rewards = {"scientific_breakthrough", "energy_boost", "cosmic_knowledge"},
            requirements = {"scientific_equipment", "research_team"}
        }
    },
    
    -- Rarity weights
    RarityWeights = {
        common = 60,
        uncommon = 30,
        rare = 8,
        legendary = 2
    },
    
    -- Dynamic factors
    DynamicFactors = {
        PlayerActivity = true,
        TimeOfDay = true,
        ServerPopulation = true,
        RecentEvents = true,
        SeasonalEvents = true
    }
}

-- World events state
ASC.WorldEvents.State = {
    ActiveEvents = {},
    EventHistory = {},
    PlayerParticipation = {},
    GlobalModifiers = {},
    EventCounter = 0,
    LastEventCheck = 0
}

-- Event class
ASC.WorldEvents.Event = {}
ASC.WorldEvents.Event.__index = ASC.WorldEvents.Event

function ASC.WorldEvents.Event:New(eventType, location, customData)
    local event = setmetatable({}, ASC.WorldEvents.Event)
    
    event.id = ASC.WorldEvents.State.EventCounter + 1
    ASC.WorldEvents.State.EventCounter = event.id
    
    event.type = eventType
    event.config = ASC.WorldEvents.Config.Types[eventType]
    event.location = location or ASC.WorldEvents.GenerateRandomLocation()
    event.status = "active"
    event.startTime = CurTime()
    event.endTime = CurTime() + (event.config and event.config.duration or ASC.WorldEvents.Config.Generation.EventDuration)
    event.participants = {}
    event.rewards = {}
    event.customData = customData or {}
    
    -- Generate event content
    event:GenerateContent()
    
    return event
end

function ASC.WorldEvents.Event:GenerateContent()
    if not self.config then return end
    
    -- Generate event name and description
    self.name = self:GenerateName()
    self.description = self:GenerateDescription()
    
    -- Generate objectives
    self.objectives = self:GenerateObjectives()
    
    -- Generate rewards
    self.rewards = self:GenerateRewards()
    
    -- Set difficulty based on participants
    self.difficulty = self:CalculateDifficulty()
end

function ASC.WorldEvents.Event:GenerateName()
    local nameTemplates = {
        ANOMALY = {
            "Quantum Anomaly Detected",
            "Temporal Distortion Event",
            "Unknown Energy Signature",
            "Gravitational Anomaly"
        },
        DISTRESS_CALL = {
            "Emergency Beacon Activated",
            "Mayday Signal Received",
            "Ship in Distress",
            "Rescue Operation Required"
        },
        PIRATE_RAID = {
            "Pirate Fleet Detected",
            "Hostile Forces Incoming",
            "Raider Attack Imminent",
            "Bandit Assault in Progress"
        },
        TRADE_CONVOY = {
            "Trade Fleet Passing",
            "Merchant Convoy Detected",
            "Commercial Opportunity",
            "Trading Post Established"
        },
        ANCIENT_RELIC = {
            "Ancient Artifact Discovered",
            "Precursor Technology Found",
            "Archaeological Site Located",
            "Lost Civilization Remnant"
        },
        DIPLOMATIC_CRISIS = {
            "Diplomatic Incident",
            "Alliance Negotiations",
            "Peace Talks Required",
            "Faction Dispute"
        },
        RESOURCE_RUSH = {
            "Rich Asteroid Field",
            "Mineral Deposit Found",
            "Resource Bonanza",
            "Mining Opportunity"
        },
        STELLAR_PHENOMENON = {
            "Solar Flare Activity",
            "Neutron Star Pulse",
            "Cosmic Storm Detected",
            "Stellar Alignment Event"
        }
    }
    
    local templates = nameTemplates[self.type] or {"Unknown Event"}
    return templates[math.random(1, #templates)]
end

function ASC.WorldEvents.Event:GenerateDescription()
    local descriptions = {
        ANOMALY = "A strange anomaly has been detected in this sector. Investigation may yield valuable scientific data.",
        DISTRESS_CALL = "A distress signal has been received from this location. Lives may be at stake.",
        PIRATE_RAID = "Hostile forces have been detected in the area. Prepare for combat.",
        TRADE_CONVOY = "A trade convoy is passing through. Opportunities for commerce await.",
        ANCIENT_RELIC = "Ancient technology has been discovered. This could be a significant archaeological find.",
        DIPLOMATIC_CRISIS = "A diplomatic situation requires immediate attention. Your actions could affect galactic politics.",
        RESOURCE_RUSH = "Valuable resources have been detected. Competition for these materials will be fierce.",
        STELLAR_PHENOMENON = "A rare stellar event is occurring. This presents unique research opportunities."
    }
    
    return descriptions[self.type] or "An unknown event is occurring in this sector."
end

function ASC.WorldEvents.Event:GenerateObjectives()
    local objectiveTemplates = {
        ANOMALY = {
            {type = "investigate", target = "anomaly", description = "Investigate the anomaly"},
            {type = "scan", target = "energy_signature", description = "Scan the energy signature"},
            {type = "collect", target = "data", description = "Collect scientific data"}
        },
        DISTRESS_CALL = {
            {type = "locate", target = "distressed_ship", description = "Locate the distressed vessel"},
            {type = "rescue", target = "survivors", description = "Rescue any survivors"},
            {type = "escort", target = "to_safety", description = "Escort survivors to safety"}
        },
        PIRATE_RAID = {
            {type = "eliminate", target = "pirates", description = "Eliminate pirate forces"},
            {type = "protect", target = "civilians", description = "Protect civilian vessels"},
            {type = "secure", target = "area", description = "Secure the area"}
        },
        TRADE_CONVOY = {
            {type = "negotiate", target = "trade_deal", description = "Negotiate favorable trade terms"},
            {type = "escort", target = "convoy", description = "Provide convoy escort"},
            {type = "establish", target = "trade_route", description = "Establish new trade route"}
        },
        ANCIENT_RELIC = {
            {type = "excavate", target = "artifact", description = "Carefully excavate the artifact"},
            {type = "analyze", target = "technology", description = "Analyze ancient technology"},
            {type = "preserve", target = "site", description = "Preserve the archaeological site"}
        },
        DIPLOMATIC_CRISIS = {
            {type = "mediate", target = "dispute", description = "Mediate the dispute"},
            {type = "negotiate", target = "agreement", description = "Negotiate a peaceful resolution"},
            {type = "establish", target = "communication", description = "Establish diplomatic communication"}
        },
        RESOURCE_RUSH = {
            {type = "claim", target = "mining_rights", description = "Claim mining rights"},
            {type = "extract", target = "resources", description = "Extract valuable resources"},
            {type = "defend", target = "operation", description = "Defend mining operation"}
        },
        STELLAR_PHENOMENON = {
            {type = "observe", target = "phenomenon", description = "Observe the stellar phenomenon"},
            {type = "record", target = "data", description = "Record scientific measurements"},
            {type = "analyze", target = "effects", description = "Analyze the phenomenon's effects"}
        }
    }
    
    return objectiveTemplates[self.type] or {}
end

function ASC.WorldEvents.Event:GenerateRewards()
    if not self.config or not self.config.rewards then return {} end
    
    local rewards = {}
    
    for _, rewardType in ipairs(self.config.rewards) do
        local reward = {
            type = rewardType,
            amount = self:CalculateRewardAmount(rewardType),
            description = self:GetRewardDescription(rewardType)
        }
        table.insert(rewards, reward)
    end
    
    return rewards
end

function ASC.WorldEvents.Event:CalculateRewardAmount(rewardType)
    local baseAmounts = {
        credits = 1000,
        experience = 500,
        reputation = 100,
        research_data = 50,
        rare_materials = 25,
        ancient_technology = 1,
        prestige = 10
    }
    
    local base = baseAmounts[rewardType] or 100
    local difficultyMultiplier = self.difficulty or 1
    local participantBonus = math.max(1, #self.participants * 0.1)
    
    return math.floor(base * difficultyMultiplier * participantBonus)
end

function ASC.WorldEvents.Event:GetRewardDescription(rewardType)
    local descriptions = {
        credits = "Credits",
        experience = "Experience Points",
        reputation = "Reputation",
        research_data = "Research Data",
        rare_materials = "Rare Materials",
        ancient_technology = "Ancient Technology",
        prestige = "Prestige Points",
        salvage = "Salvage Materials",
        bounty = "Bounty Reward",
        allies = "New Allies",
        trade_opportunities = "Trade Opportunities",
        mining_rights = "Mining Rights",
        diplomatic_standing = "Diplomatic Standing",
        influence = "Political Influence",
        cosmic_knowledge = "Cosmic Knowledge"
    }
    
    return descriptions[rewardType] or "Unknown Reward"
end

function ASC.WorldEvents.Event:CalculateDifficulty()
    local baseDifficulty = 1.0
    
    -- Adjust based on event type rarity
    if self.config then
        if self.config.rarity == "uncommon" then
            baseDifficulty = 1.5
        elseif self.config.rarity == "rare" then
            baseDifficulty = 2.0
        elseif self.config.rarity == "legendary" then
            baseDifficulty = 3.0
        end
    end
    
    -- Adjust based on participant count
    local participantMultiplier = 1.0 + (#self.participants * 0.2)
    
    return baseDifficulty * participantMultiplier
end

function ASC.WorldEvents.Event:AddParticipant(player)
    if not IsValid(player) then return false end
    
    local steamId = player:SteamID()
    
    if self.participants[steamId] then return false end  -- Already participating
    
    self.participants[steamId] = {
        player = player,
        name = player:Name(),
        joinTime = CurTime(),
        contribution = 0,
        objectivesCompleted = 0
    }
    
    -- Notify player
    player:ChatPrint("[ASC World Events] You have joined the event: " .. self.name)
    
    -- Update difficulty
    self.difficulty = self:CalculateDifficulty()
    
    return true
end

function ASC.WorldEvents.Event:RemoveParticipant(steamId)
    if not self.participants[steamId] then return false end
    
    local participant = self.participants[steamId]
    self.participants[steamId] = nil
    
    -- Update difficulty
    self.difficulty = self:CalculateDifficulty()
    
    return true
end

function ASC.WorldEvents.Event:CompleteObjective(player, objectiveType)
    if not IsValid(player) then return false end
    
    local steamId = player:SteamID()
    local participant = self.participants[steamId]
    
    if not participant then return false end
    
    participant.contribution = participant.contribution + 1
    participant.objectivesCompleted = participant.objectivesCompleted + 1
    
    -- Check if event is complete
    self:CheckCompletion()
    
    return true
end

function ASC.WorldEvents.Event:CheckCompletion()
    -- Simple completion check - can be made more sophisticated
    local totalContribution = 0
    local participantCount = 0
    
    for _, participant in pairs(self.participants) do
        totalContribution = totalContribution + participant.contribution
        participantCount = participantCount + 1
    end
    
    local requiredContribution = #self.objectives * math.max(1, participantCount)
    
    if totalContribution >= requiredContribution then
        self:Complete()
    end
end

function ASC.WorldEvents.Event:Complete()
    if self.status ~= "active" then return end
    
    self.status = "completed"
    self.endTime = CurTime()
    
    -- Distribute rewards
    self:DistributeRewards()
    
    -- Notify participants
    for steamId, participant in pairs(self.participants) do
        if IsValid(participant.player) then
            participant.player:ChatPrint("[ASC World Events] Event completed: " .. self.name)
        end
    end
    
    -- Move to history
    table.insert(ASC.WorldEvents.State.EventHistory, self)
    ASC.WorldEvents.State.ActiveEvents[self.id] = nil
    
    -- Track in analytics
    if ASC.Analytics then
        ASC.Analytics.TrackEvent("world_event_completed", {
            eventId = self.id,
            eventType = self.type,
            participantCount = table.Count(self.participants),
            duration = self.endTime - self.startTime
        })
    end
end

function ASC.WorldEvents.Event:DistributeRewards()
    for steamId, participant in pairs(self.participants) do
        if IsValid(participant.player) then
            local contributionRatio = participant.contribution / math.max(1, participant.contribution)
            
            for _, reward in ipairs(self.rewards) do
                local adjustedAmount = math.floor(reward.amount * contributionRatio)
                
                -- Apply rewards based on type
                if reward.type == "credits" and ASC.Economy then
                    ASC.Economy.AddCredits(participant.player, adjustedAmount)
                elseif reward.type == "experience" and ASC.Progression then
                    ASC.Progression.AddExperience(participant.player, adjustedAmount, "world_event")
                elseif reward.type == "reputation" and ASC.Social then
                    local playerData = ASC.Social.GetPlayerData(participant.player)
                    if playerData then
                        playerData.reputation = playerData.reputation + adjustedAmount
                    end
                end
                
                participant.player:ChatPrint("  + " .. adjustedAmount .. " " .. reward.description)
            end
        end
    end
end

-- World events management functions
ASC.WorldEvents.GenerateRandomLocation = function()
    return {
        x = math.random(-10000, 10000),
        y = math.random(-10000, 10000),
        z = math.random(-1000, 1000)
    }
end

ASC.WorldEvents.SelectEventType = function()
    local totalWeight = 0
    local weights = ASC.WorldEvents.Config.RarityWeights

    -- Calculate total weight
    for _, weight in pairs(weights) do
        totalWeight = totalWeight + weight
    end

    -- Select random rarity
    local random = math.random(1, totalWeight)
    local currentWeight = 0
    local selectedRarity = "common"

    for rarity, weight in pairs(weights) do
        currentWeight = currentWeight + weight
        if random <= currentWeight then
            selectedRarity = rarity
            break
        end
    end

    -- Select event type of chosen rarity
    local availableTypes = {}
    for eventType, config in pairs(ASC.WorldEvents.Config.Types) do
        if config.rarity == selectedRarity then
            table.insert(availableTypes, eventType)
        end
    end

    if #availableTypes > 0 then
        return availableTypes[math.random(1, #availableTypes)]
    end

    return "ANOMALY"  -- Fallback
end

ASC.WorldEvents.GenerateEvent = function(eventType, location)
    eventType = eventType or ASC.WorldEvents.SelectEventType()
    location = location or ASC.WorldEvents.GenerateRandomLocation()

    local event = ASC.WorldEvents.Event:New(eventType, location)
    ASC.WorldEvents.State.ActiveEvents[event.id] = event

    -- Announce event
    ASC.WorldEvents.AnnounceEvent(event)

    return event
end

ASC.WorldEvents.AnnounceEvent = function(event)
    local message = "[ASC World Events] " .. event.name .. " - " .. event.description

    for _, player in ipairs(player.GetAll()) do
        if IsValid(player) then
            player:ChatPrint(message)
            player:ChatPrint("[ASC World Events] Location: " .. math.Round(event.location.x) .. ", " .. math.Round(event.location.y) .. ", " .. math.Round(event.location.z))
        end
    end

    print("[ASC World Events] Event generated: " .. event.name .. " (ID: " .. event.id .. ")")
end

ASC.WorldEvents.Update = function()
    local currentTime = CurTime()

    -- Check for event generation
    if ASC.WorldEvents.Config.Generation.Enabled and
       currentTime - ASC.WorldEvents.State.LastEventCheck >= ASC.WorldEvents.Config.Generation.CheckInterval then

        ASC.WorldEvents.State.LastEventCheck = currentTime

        -- Check if we should generate a new event
        local activeEventCount = table.Count(ASC.WorldEvents.State.ActiveEvents)

        if activeEventCount < ASC.WorldEvents.Config.Generation.MaxActiveEvents then
            local eventChance = ASC.WorldEvents.Config.Generation.BaseEventChance

            -- Modify chance based on dynamic factors
            if ASC.WorldEvents.Config.DynamicFactors.ServerPopulation then
                local playerCount = #player.GetAll()
                eventChance = eventChance * (1 + playerCount * 0.1)
            end

            if math.random() < eventChance then
                ASC.WorldEvents.GenerateEvent()
            end
        end
    end

    -- Update active events
    for eventId, event in pairs(ASC.WorldEvents.State.ActiveEvents) do
        if event.status == "active" then
            -- Check for expiration
            if currentTime >= event.endTime then
                event:Expire()
            end
        end
    end
end

-- Console commands
concommand.Add("asc_events_list", function(ply, cmd, args)
    local function printMsg(msg)
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    end

    printMsg("[ASC World Events] Active Events:")

    local count = 0
    for eventId, event in pairs(ASC.WorldEvents.State.ActiveEvents) do
        count = count + 1
        local timeLeft = math.max(0, event.endTime - CurTime())
        printMsg("  " .. eventId .. ". " .. event.name .. " (" .. math.Round(timeLeft) .. "s remaining)")
    end

    if count == 0 then
        printMsg("  No active events.")
    end
end, nil, "List active world events")

concommand.Add("asc_events_join", function(ply, cmd, args)
    if not IsValid(ply) or #args == 0 then return end

    local eventId = tonumber(args[1])
    if not eventId then return end

    local event = ASC.WorldEvents.State.ActiveEvents[eventId]
    if not event then
        ply:ChatPrint("[ASC World Events] Event not found.")
        return
    end

    if event:AddParticipant(ply) then
        ply:ChatPrint("[ASC World Events] Successfully joined event!")
    else
        ply:ChatPrint("[ASC World Events] Could not join event.")
    end
end, nil, "Join a world event")

concommand.Add("asc_events_generate", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[ASC World Events] Admin only command.")
        return
    end

    local eventType = args[1] and string.upper(args[1]) or nil

    if eventType and not ASC.WorldEvents.Config.Types[eventType] then
        local msg = "[ASC World Events] Invalid event type. Available: " .. table.concat(table.GetKeys(ASC.WorldEvents.Config.Types), ", ")
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
        return
    end

    local event = ASC.WorldEvents.GenerateEvent(eventType)
    local msg = "[ASC World Events] Event generated: " .. event.name

    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end, nil, "Generate a world event (Admin)")

-- Initialize world events system
function ASC.WorldEvents.Initialize()
    print("[ASC World Events] Initializing world events system...")

    -- Start update timer
    timer.Create("ASC_WorldEvents_Update", 30, 0, ASC.WorldEvents.Update)

    -- Generate initial event
    timer.Simple(60, function()
        if ASC.WorldEvents.Config.Generation.Enabled then
            ASC.WorldEvents.GenerateEvent()
        end
    end)

    print("[ASC World Events] World events system initialized")
end

-- Hook into core events
if ASC.Events then
    ASC.Events.Register("CoreInitialized", ASC.WorldEvents.Initialize, 1)
end

-- Server initialization
if SERVER then
    hook.Add("Initialize", "ASC_WorldEvents_Initialize", function()
        timer.Simple(10, ASC.WorldEvents.Initialize)
    end)
end

print("[Advanced Space Combat] World Events & Dynamic Content System v6.0.0 - Dynamic Universe Loaded Successfully!")
