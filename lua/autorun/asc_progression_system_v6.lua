-- Advanced Space Combat - Progression & Achievement System v6.0.0
-- Comprehensive player progression, achievements, and skill development
-- Research-based implementation following 2025 progression system best practices

print("[Advanced Space Combat] Progression & Achievement System v6.0.0 - Player Development Loading...")

-- Initialize progression namespace
ASC = ASC or {}
ASC.Progression = ASC.Progression or {}

-- Progression configuration
ASC.Progression.Config = {
    Version = "6.0.0",
    
    -- Experience system
    Experience = {
        MaxLevel = 100,
        BaseExpRequired = 1000,
        ExpMultiplier = 1.2,
        SkillPoints = 2,  -- per level
        PrestigeEnabled = true
    },
    
    -- Skill trees
    SkillTrees = {
        Combat = {
            name = "Combat Mastery",
            maxLevel = 50,
            skills = {
                "weapon_proficiency", "shield_mastery", "tactical_awareness",
                "damage_boost", "critical_strikes", "combat_reflexes"
            }
        },
        Engineering = {
            name = "Engineering",
            maxLevel = 50,
            skills = {
                "ship_efficiency", "repair_speed", "system_optimization",
                "energy_management", "hull_reinforcement", "advanced_systems"
            }
        },
        Exploration = {
            name = "Exploration",
            maxLevel = 50,
            skills = {
                "navigation", "scanning", "resource_detection",
                "survival", "discovery_bonus", "deep_space_mastery"
            }
        },
        Diplomacy = {
            name = "Diplomacy",
            maxLevel = 50,
            skills = {
                "negotiation", "reputation_gain", "trade_efficiency",
                "alliance_building", "conflict_resolution", "leadership"
            }
        }
    },
    
    -- Achievement categories
    Achievements = {
        Combat = {
            "first_kill", "ace_pilot", "destroyer", "legendary_warrior",
            "shield_master", "weapon_collector", "combat_veteran"
        },
        Exploration = {
            "first_jump", "explorer", "deep_space_pioneer", "cartographer",
            "resource_hunter", "anomaly_investigator", "galaxy_wanderer"
        },
        Social = {
            "friend_maker", "guild_founder", "diplomat", "mentor",
            "community_leader", "peacekeeper", "alliance_builder"
        },
        Economic = {
            "first_trade", "merchant", "tycoon", "market_master",
            "resource_baron", "trade_route_king", "economic_powerhouse"
        },
        Technical = {
            "engineer", "system_master", "efficiency_expert", "innovator",
            "ship_designer", "technology_pioneer", "master_builder"
        }
    }
}

-- Progression state
ASC.Progression.State = {
    PlayerProfiles = {},
    Achievements = {},
    Leaderboards = {},
    SkillDefinitions = {},
    AchievementDefinitions = {}
}

-- Initialize skill definitions
ASC.Progression.InitializeSkills = function()
    ASC.Progression.State.SkillDefinitions = {
        -- Combat skills
        weapon_proficiency = {
            name = "Weapon Proficiency",
            description = "Increases weapon damage by 5% per level",
            maxLevel = 10,
            tree = "Combat",
            effect = function(level) return {weaponDamage = 1 + (level * 0.05)} end
        },
        shield_mastery = {
            name = "Shield Mastery",
            description = "Increases shield capacity by 10% per level",
            maxLevel = 10,
            tree = "Combat",
            effect = function(level) return {shieldCapacity = 1 + (level * 0.1)} end
        },
        tactical_awareness = {
            name = "Tactical Awareness",
            description = "Increases detection range by 15% per level",
            maxLevel = 8,
            tree = "Combat",
            effect = function(level) return {detectionRange = 1 + (level * 0.15)} end
        },
        
        -- Engineering skills
        ship_efficiency = {
            name = "Ship Efficiency",
            description = "Reduces energy consumption by 8% per level",
            maxLevel = 10,
            tree = "Engineering",
            effect = function(level) return {energyEfficiency = 1 - (level * 0.08)} end
        },
        repair_speed = {
            name = "Repair Speed",
            description = "Increases repair rate by 20% per level",
            maxLevel = 8,
            tree = "Engineering",
            effect = function(level) return {repairSpeed = 1 + (level * 0.2)} end
        },
        system_optimization = {
            name = "System Optimization",
            description = "Improves overall system performance by 5% per level",
            maxLevel = 12,
            tree = "Engineering",
            effect = function(level) return {systemPerformance = 1 + (level * 0.05)} end
        },
        
        -- Exploration skills
        navigation = {
            name = "Navigation",
            description = "Reduces hyperspace travel time by 10% per level",
            maxLevel = 8,
            tree = "Exploration",
            effect = function(level) return {hyperspaceSpeed = 1 + (level * 0.1)} end
        },
        scanning = {
            name = "Advanced Scanning",
            description = "Increases scan range and accuracy by 15% per level",
            maxLevel = 10,
            tree = "Exploration",
            effect = function(level) return {scanRange = 1 + (level * 0.15), scanAccuracy = 1 + (level * 0.15)} end
        },
        resource_detection = {
            name = "Resource Detection",
            description = "Increases chance to find rare resources by 5% per level",
            maxLevel = 10,
            tree = "Exploration",
            effect = function(level) return {resourceFindChance = level * 0.05} end
        },
        
        -- Diplomacy skills
        negotiation = {
            name = "Negotiation",
            description = "Improves trade prices by 3% per level",
            maxLevel = 10,
            tree = "Diplomacy",
            effect = function(level) return {tradePriceBonus = level * 0.03} end
        },
        reputation_gain = {
            name = "Reputation Gain",
            description = "Increases reputation gains by 10% per level",
            maxLevel = 8,
            tree = "Diplomacy",
            effect = function(level) return {reputationMultiplier = 1 + (level * 0.1)} end
        },
        leadership = {
            name = "Leadership",
            description = "Provides bonuses to guild members when nearby",
            maxLevel = 5,
            tree = "Diplomacy",
            effect = function(level) return {leadershipBonus = level * 0.05} end
        }
    }
end

-- Initialize achievement definitions
ASC.Progression.InitializeAchievements = function()
    ASC.Progression.State.AchievementDefinitions = {
        -- Combat achievements
        first_kill = {
            name = "First Blood",
            description = "Destroy your first enemy",
            category = "Combat",
            points = 10,
            condition = function(stats) return stats.enemiesKilled >= 1 end
        },
        ace_pilot = {
            name = "Ace Pilot",
            description = "Destroy 50 enemies",
            category = "Combat",
            points = 50,
            condition = function(stats) return stats.enemiesKilled >= 50 end
        },
        destroyer = {
            name = "Destroyer",
            description = "Destroy 500 enemies",
            category = "Combat",
            points = 200,
            condition = function(stats) return stats.enemiesKilled >= 500 end
        },
        
        -- Exploration achievements
        first_jump = {
            name = "First Jump",
            description = "Complete your first hyperspace jump",
            category = "Exploration",
            points = 10,
            condition = function(stats) return stats.hyperspaceJumps >= 1 end
        },
        explorer = {
            name = "Explorer",
            description = "Visit 25 different locations",
            category = "Exploration",
            points = 50,
            condition = function(stats) return stats.locationsVisited >= 25 end
        },
        deep_space_pioneer = {
            name = "Deep Space Pioneer",
            description = "Travel 100,000 units in hyperspace",
            category = "Exploration",
            points = 100,
            condition = function(stats) return stats.hyperspaceDistance >= 100000 end
        },
        
        -- Social achievements
        friend_maker = {
            name = "Friend Maker",
            description = "Add 5 friends",
            category = "Social",
            points = 25,
            condition = function(stats) return stats.friendsAdded >= 5 end
        },
        guild_founder = {
            name = "Guild Founder",
            description = "Create a guild",
            category = "Social",
            points = 50,
            condition = function(stats) return stats.guildsCreated >= 1 end
        },
        
        -- Economic achievements
        first_trade = {
            name = "First Trade",
            description = "Complete your first trade",
            category = "Economic",
            points = 10,
            condition = function(stats) return stats.tradesCompleted >= 1 end
        },
        merchant = {
            name = "Merchant",
            description = "Complete 100 trades",
            category = "Economic",
            points = 75,
            condition = function(stats) return stats.tradesCompleted >= 100 end
        },
        tycoon = {
            name = "Tycoon",
            description = "Accumulate 1,000,000 credits",
            category = "Economic",
            points = 150,
            condition = function(stats) return stats.totalCreditsEarned >= 1000000 end
        },
        
        -- Technical achievements
        engineer = {
            name = "Engineer",
            description = "Repair 50 systems",
            category = "Technical",
            points = 40,
            condition = function(stats) return stats.systemsRepaired >= 50 end
        },
        system_master = {
            name = "System Master",
            description = "Achieve 100% efficiency on all ship systems",
            category = "Technical",
            points = 100,
            condition = function(stats) return stats.maxEfficiencyAchieved == true end
        }
    }
end

-- Player profile management
ASC.Progression.GetPlayerProfile = function(player)
    if not IsValid(player) then return nil end
    
    local steamId = player:SteamID()
    
    if not ASC.Progression.State.PlayerProfiles[steamId] then
        ASC.Progression.State.PlayerProfiles[steamId] = {
            steamId = steamId,
            name = player:Name(),
            level = 1,
            experience = 0,
            skillPoints = 0,
            prestigeLevel = 0,
            
            -- Skills
            skills = {},
            
            -- Statistics
            stats = {
                playtime = 0,
                enemiesKilled = 0,
                hyperspaceJumps = 0,
                hyperspaceDistance = 0,
                locationsVisited = 0,
                missionsCompleted = 0,
                tradesCompleted = 0,
                totalCreditsEarned = 0,
                systemsRepaired = 0,
                friendsAdded = 0,
                guildsCreated = 0,
                maxEfficiencyAchieved = false
            },
            
            -- Achievements
            achievements = {},
            achievementPoints = 0,
            
            -- Timestamps
            createdTime = os.time(),
            lastActive = os.time()
        }
    end
    
    return ASC.Progression.State.PlayerProfiles[steamId]
end

-- Experience and leveling
ASC.Progression.AddExperience = function(player, amount, source)
    local profile = ASC.Progression.GetPlayerProfile(player)
    if not profile then return false end
    
    profile.experience = profile.experience + amount
    
    -- Check for level up
    local requiredExp = ASC.Progression.GetRequiredExperience(profile.level)
    
    while profile.experience >= requiredExp and profile.level < ASC.Progression.Config.Experience.MaxLevel do
        profile.experience = profile.experience - requiredExp
        profile.level = profile.level + 1
        profile.skillPoints = profile.skillPoints + ASC.Progression.Config.Experience.SkillPoints
        
        -- Notify player
        if IsValid(player) then
            player:ChatPrint("[ASC Progression] Level up! You are now level " .. profile.level)
            player:ChatPrint("[ASC Progression] You gained " .. ASC.Progression.Config.Experience.SkillPoints .. " skill points!")
        end
        
        -- Track in analytics
        if ASC.Analytics then
            ASC.Analytics.TrackEvent("level_up", {
                player = player:Name(),
                newLevel = profile.level,
                source = source or "unknown"
            })
        end
        
        requiredExp = ASC.Progression.GetRequiredExperience(profile.level)
    end
    
    return true
end

ASC.Progression.GetRequiredExperience = function(level)
    local config = ASC.Progression.Config.Experience
    return math.floor(config.BaseExpRequired * (config.ExpMultiplier ^ (level - 1)))
end

-- Skill system
ASC.Progression.LearnSkill = function(player, skillId)
    local profile = ASC.Progression.GetPlayerProfile(player)
    if not profile then return false end
    
    local skillDef = ASC.Progression.State.SkillDefinitions[skillId]
    if not skillDef then return false end
    
    -- Initialize skill if not exists
    if not profile.skills[skillId] then
        profile.skills[skillId] = 0
    end
    
    -- Check if can level up
    if profile.skills[skillId] >= skillDef.maxLevel then return false end
    if profile.skillPoints <= 0 then return false end
    
    -- Level up skill
    profile.skills[skillId] = profile.skills[skillId] + 1
    profile.skillPoints = profile.skillPoints - 1
    
    -- Notify player
    if IsValid(player) then
        player:ChatPrint("[ASC Progression] Skill improved: " .. skillDef.name .. " (Level " .. profile.skills[skillId] .. ")")
    end
    
    return true
end

ASC.Progression.GetSkillEffect = function(player, skillId)
    local profile = ASC.Progression.GetPlayerProfile(player)
    if not profile or not profile.skills[skillId] then return {} end
    
    local skillDef = ASC.Progression.State.SkillDefinitions[skillId]
    if not skillDef or not skillDef.effect then return {} end
    
    return skillDef.effect(profile.skills[skillId])
end

-- Achievement system
ASC.Progression.CheckAchievements = function(player)
    local profile = ASC.Progression.GetPlayerProfile(player)
    if not profile then return end
    
    for achievementId, achievementDef in pairs(ASC.Progression.State.AchievementDefinitions) do
        -- Skip if already earned
        if profile.achievements[achievementId] then continue end
        
        -- Check condition
        if achievementDef.condition(profile.stats) then
            ASC.Progression.UnlockAchievement(player, achievementId)
        end
    end
end

ASC.Progression.UnlockAchievement = function(player, achievementId)
    local profile = ASC.Progression.GetPlayerProfile(player)
    if not profile then return false end
    
    local achievementDef = ASC.Progression.State.AchievementDefinitions[achievementId]
    if not achievementDef then return false end
    
    -- Skip if already unlocked
    if profile.achievements[achievementId] then return false end
    
    -- Unlock achievement
    profile.achievements[achievementId] = {
        unlockedTime = os.time(),
        points = achievementDef.points
    }
    
    profile.achievementPoints = profile.achievementPoints + achievementDef.points
    
    -- Notify player
    if IsValid(player) then
        player:ChatPrint("[ASC Progression] Achievement unlocked: " .. achievementDef.name)
        player:ChatPrint("[ASC Progression] " .. achievementDef.description .. " (+" .. achievementDef.points .. " points)")
    end
    
    -- Track in analytics
    if ASC.Analytics then
        ASC.Analytics.TrackEvent("achievement_unlocked", {
            player = player:Name(),
            achievement = achievementId,
            points = achievementDef.points
        })
    end
    
    return true
end

-- Statistics tracking
ASC.Progression.IncrementStat = function(player, statName, amount)
    local profile = ASC.Progression.GetPlayerProfile(player)
    if not profile then return false end
    
    amount = amount or 1
    
    if not profile.stats[statName] then
        profile.stats[statName] = 0
    end
    
    profile.stats[statName] = profile.stats[statName] + amount
    
    -- Check achievements after stat update
    ASC.Progression.CheckAchievements(player)
    
    return true
end

-- Console commands
concommand.Add("asc_progression_profile", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local profile = ASC.Progression.GetPlayerProfile(ply)
    if not profile then return end
    
    ply:ChatPrint("[ASC Progression] Player Profile:")
    ply:ChatPrint("  Level: " .. profile.level .. " (XP: " .. profile.experience .. "/" .. ASC.Progression.GetRequiredExperience(profile.level) .. ")")
    ply:ChatPrint("  Skill Points: " .. profile.skillPoints)
    ply:ChatPrint("  Achievement Points: " .. profile.achievementPoints)
    ply:ChatPrint("  Achievements: " .. table.Count(profile.achievements))
end, nil, "Show progression profile")

concommand.Add("asc_progression_skills", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local profile = ASC.Progression.GetPlayerProfile(ply)
    if not profile then return end
    
    ply:ChatPrint("[ASC Progression] Skills:")
    
    for skillId, level in pairs(profile.skills) do
        local skillDef = ASC.Progression.State.SkillDefinitions[skillId]
        if skillDef then
            ply:ChatPrint("  " .. skillDef.name .. ": Level " .. level .. "/" .. skillDef.maxLevel)
        end
    end
    
    if profile.skillPoints > 0 then
        ply:ChatPrint("Available skill points: " .. profile.skillPoints)
        ply:ChatPrint("Use 'asc_progression_learn <skill_id>' to learn skills")
    end
end, nil, "Show player skills")

concommand.Add("asc_progression_learn", function(ply, cmd, args)
    if not IsValid(ply) or #args == 0 then return end
    
    local skillId = args[1]
    
    if ASC.Progression.LearnSkill(ply, skillId) then
        ply:ChatPrint("[ASC Progression] Skill learned successfully!")
    else
        ply:ChatPrint("[ASC Progression] Could not learn skill. Check requirements.")
    end
end, nil, "Learn a skill")

-- Initialize progression system
function ASC.Progression.Initialize()
    print("[ASC Progression] Initializing progression system...")
    
    ASC.Progression.InitializeSkills()
    ASC.Progression.InitializeAchievements()
    
    print("[ASC Progression] Progression system initialized")
end

-- Hook into core events
if ASC.Events then
    ASC.Events.Register("CoreInitialized", ASC.Progression.Initialize, 1)
end

-- Hook into player events
hook.Add("PlayerInitialSpawn", "ASC_Progression_PlayerJoin", function(player)
    timer.Simple(5, function()
        if IsValid(player) then
            local profile = ASC.Progression.GetPlayerProfile(player)
            player:ChatPrint("[ASC Progression] Welcome! Your progression profile has been loaded.")
            player:ChatPrint("[ASC Progression] Level: " .. profile.level .. " | Achievement Points: " .. profile.achievementPoints)
        end
    end)
end)

-- Server initialization
if SERVER then
    hook.Add("Initialize", "ASC_Progression_Initialize", function()
        timer.Simple(3, ASC.Progression.Initialize)
    end)
end

print("[Advanced Space Combat] Progression & Achievement System v6.0.0 - Player Development Loaded Successfully!")
