--[[
    Advanced Space Combat - AI Boss Ship System v3.0.0
    
    Player-voted AI boss encounters with intelligent boss ships,
    advanced tactics, special abilities, and reward systems.
]]

-- Initialize Boss System namespace
ASC = ASC or {}
ASC.Boss = ASC.Boss or {}

-- Boss System Configuration
ASC.Boss.Config = {
    -- Core Settings
    Enabled = true,
    UpdateRate = 0.1,
    MaxActiveBosses = 3,
    VotingDuration = 30,
    MinPlayersForVote = 2,
    
    -- Boss Spawn Settings
    SpawnDistance = 3000,
    SafeSpawnRadius = 1000,
    DespawnDistance = 8000,
    RespawnCooldown = 300,
    
    -- Combat Settings
    EngagementRange = 2500,
    RetreatThreshold = 0.25,
    AggroRange = 1500,
    PatrolRadius = 2000,
    
    -- Reward Settings
    BaseReward = 1000,
    BonusReward = 500,
    TeamReward = true,
    ExperienceReward = 100,

    -- Reward Types
    RewardTypes = {
        CREDITS = {
            name = "Credits",
            baseAmount = 1000,
            bonusMultiplier = 1.5,
            teamBonus = 0.2
        },
        EXPERIENCE = {
            name = "Experience Points",
            baseAmount = 100,
            bonusMultiplier = 2.0,
            teamBonus = 0.3
        },
        MATERIALS = {
            name = "Rare Materials",
            baseAmount = 50,
            bonusMultiplier = 1.8,
            teamBonus = 0.25
        },
        TECHNOLOGY = {
            name = "Technology Blueprints",
            baseAmount = 1,
            bonusMultiplier = 1.0,
            teamBonus = 0.1
        }
    },
    
    -- Boss Types
    BossTypes = {
        DESTROYER = {
            name = "Goa'uld Ha'tak Destroyer",
            description = "Massive pyramid ship with heavy weapons and shields",
            health = 50000,
            shields = 25000,
            speed = 150,
            agility = 0.3,
            weapons = {"plasma_cannon", "staff_cannon", "death_glider"},
            abilities = {"shield_boost", "weapon_overcharge", "fighter_launch"},
            difficulty = 3,
            reward = 2000,
            model = "models/cap/ships/hatak/hatak.mdl"
        },
        CRUISER = {
            name = "Wraith Hive Ship",
            description = "Organic ship with regenerative abilities and dart fighters",
            health = 35000,
            shields = 15000,
            speed = 200,
            agility = 0.5,
            weapons = {"wraith_beam", "dart_launcher"},
            abilities = {"regeneration", "dart_swarm", "culling_beam"},
            difficulty = 2,
            reward = 1500,
            model = "models/cap/ships/wraith_hive/wraith_hive.mdl"
        },
        FRIGATE = {
            name = "Ori Warship",
            description = "Advanced ship with energy weapons and prior technology",
            health = 40000,
            shields = 20000,
            speed = 180,
            agility = 0.4,
            weapons = {"ori_beam", "energy_torpedo"},
            abilities = {"energy_shield", "beam_focus", "teleport"},
            difficulty = 4,
            reward = 2500,
            model = "models/cap/ships/ori/ori_warship.mdl"
        },
        SCOUT = {
            name = "Replicator Ship",
            description = "Fast ship that can replicate and adapt to damage",
            health = 20000,
            shields = 10000,
            speed = 300,
            agility = 0.8,
            weapons = {"replicator_beam", "nanite_swarm"},
            abilities = {"adaptation", "replication", "nanite_repair"},
            difficulty = 2,
            reward = 1200,
            model = "models/cap/ships/replicator/replicator.mdl"
        },
        DREADNOUGHT = {
            name = "Ancient Aurora-class Battleship",
            description = "Legendary Ancient warship with devastating weapons",
            health = 75000,
            shields = 40000,
            speed = 120,
            agility = 0.2,
            weapons = {"drone_weapon", "ancient_beam", "asgard_beam"},
            abilities = {"drone_swarm", "shield_harmonics", "time_dilation"},
            difficulty = 5,
            reward = 5000,
            model = "models/cap/ships/ancient/aurora.mdl"
        }
    }
}

-- Boss System Core
ASC.Boss.Core = {
    -- Active bosses
    ActiveBosses = {},

    -- Voting system
    CurrentVote = nil,
    VoteResults = {},

    -- Boss counter
    BossCounter = 0,

    -- Player data storage
    PlayerData = {},

    -- Reward history
    RewardHistory = {},

    -- Performance tracking
    TotalBossesSpawned = 0,
    TotalBossesDefeated = 0,
    TotalRewardsDistributed = 0,
    
    -- Initialize boss system
    Initialize = function()
        print("[Boss System] Initializing AI Boss Ship System v3.0.0")
        
        -- Reset counters
        ASC.Boss.Core.BossCounter = 0
        ASC.Boss.Core.ActiveBosses = {}
        ASC.Boss.Core.CurrentVote = nil
        
        return true
    end,
    
    -- Start boss vote
    StartBossVote = function(initiator)
        if ASC.Boss.Core.CurrentVote then
            return false, "Boss vote already in progress"
        end
        
        local playerCount = #player.GetAll()
        if playerCount < ASC.Boss.Config.MinPlayersForVote then
            return false, "Need at least " .. ASC.Boss.Config.MinPlayersForVote .. " players for boss vote"
        end
        
        if table.Count(ASC.Boss.Core.ActiveBosses) >= ASC.Boss.Config.MaxActiveBosses then
            return false, "Maximum number of bosses already active"
        end
        
        ASC.Boss.Core.CurrentVote = {
            initiator = initiator,
            startTime = CurTime(),
            duration = ASC.Boss.Config.VotingDuration,
            votes = {},
            options = {}
        }
        
        -- Add boss type options
        for bossType, config in pairs(ASC.Boss.Config.BossTypes) do
            table.insert(ASC.Boss.Core.CurrentVote.options, {
                type = bossType,
                name = config.name,
                difficulty = config.difficulty,
                reward = config.reward,
                votes = 0
            })
        end
        
        -- Notify all players
        ASC.Boss.Core.BroadcastVoteStart(initiator)
        
        -- Set vote timer
        timer.Create("ASC_Boss_Vote", ASC.Boss.Config.VotingDuration, 1, function()
            ASC.Boss.Core.EndBossVote()
        end)
        
        print("[Boss System] Boss vote started by " .. initiator:Name())
        return true
    end,

    -- Distribute rewards to players
    DistributeRewards = function(bossType, participants, bonusMultiplier)
        bonusMultiplier = bonusMultiplier or 1.0
        local bossConfig = ASC.Boss.Config.BossTypes[bossType]
        if not bossConfig then return end

        local teamSize = #participants
        local teamBonus = teamSize > 1 and 1.0 or 0.0

        for _, player in ipairs(participants) do
            if IsValid(player) then
                ASC.Boss.Core.GivePlayerRewards(player, bossConfig, bonusMultiplier, teamBonus, teamSize)
            end
        end

        -- Broadcast reward notification
        ASC.Boss.Core.BroadcastRewardDistribution(bossType, participants, bonusMultiplier)
    end,

    -- Give rewards to individual player
    GivePlayerRewards = function(player, bossConfig, bonusMultiplier, teamBonus, teamSize)
        local rewards = {}

        for rewardType, rewardConfig in pairs(ASC.Boss.Config.RewardTypes) do
            local baseAmount = rewardConfig.baseAmount
            local finalAmount = math.floor(baseAmount * bonusMultiplier * rewardConfig.bonusMultiplier)

            -- Apply team bonus
            if teamSize > 1 then
                finalAmount = math.floor(finalAmount * (1 + (rewardConfig.teamBonus * (teamSize - 1))))
            end

            -- Apply difficulty multiplier from boss config
            if bossConfig.rewardMultiplier then
                finalAmount = math.floor(finalAmount * bossConfig.rewardMultiplier)
            end

            rewards[rewardType] = finalAmount

            -- Actually give the reward (integrate with economy systems if available)
            ASC.Boss.Core.ApplyReward(player, rewardType, finalAmount)
        end

        -- Store reward history
        ASC.Boss.Core.StoreRewardHistory(player, rewards, bossConfig.name)

        -- Notify player
        ASC.Boss.Core.NotifyPlayerRewards(player, rewards)
    end,

    -- Apply specific reward to player
    ApplyReward = function(player, rewardType, amount)
        local steamID = player:SteamID()

        -- Initialize player data if needed
        if not ASC.Boss.Core.PlayerData[steamID] then
            ASC.Boss.Core.PlayerData[steamID] = {
                credits = 0,
                experience = 0,
                materials = 0,
                technology = 0,
                bossesDefeated = 0,
                totalRewards = 0
            }
        end

        local playerData = ASC.Boss.Core.PlayerData[steamID]

        -- Apply reward based on type
        if rewardType == "CREDITS" then
            playerData.credits = playerData.credits + amount
            -- Integrate with DarkRP or other economy systems if available
            if player.addMoney then
                player:addMoney(amount)
            end
        elseif rewardType == "EXPERIENCE" then
            playerData.experience = playerData.experience + amount
            -- Integrate with leveling systems if available
        elseif rewardType == "MATERIALS" then
            playerData.materials = playerData.materials + amount
            -- Could integrate with inventory systems
        elseif rewardType == "TECHNOLOGY" then
            playerData.technology = playerData.technology + amount
            -- Could unlock new technologies or blueprints
        end

        playerData.totalRewards = playerData.totalRewards + amount

        -- Save player data
        ASC.Boss.Core.SavePlayerData(steamID, playerData)
    end,

    -- Store reward history
    StoreRewardHistory = function(player, rewards, bossName)
        local steamID = player:SteamID()

        if not ASC.Boss.Core.RewardHistory[steamID] then
            ASC.Boss.Core.RewardHistory[steamID] = {}
        end

        table.insert(ASC.Boss.Core.RewardHistory[steamID], {
            bossName = bossName,
            rewards = rewards,
            timestamp = os.time(),
            date = os.date("%Y-%m-%d %H:%M:%S")
        })

        -- Keep only last 50 entries
        while #ASC.Boss.Core.RewardHistory[steamID] > 50 do
            table.remove(ASC.Boss.Core.RewardHistory[steamID], 1)
        end
    end,

    -- Notify player of rewards received
    NotifyPlayerRewards = function(player, rewards)
        player:ChatPrint("[Boss System] 🎉 Rewards Received:")

        for rewardType, amount in pairs(rewards) do
            local rewardConfig = ASC.Boss.Config.RewardTypes[rewardType]
            if rewardConfig and amount > 0 then
                player:ChatPrint("• " .. rewardConfig.name .. ": " .. amount)
            end
        end

        -- Czech translation if available
        if ASC.Czech and ASC.Czech.IsPlayerCzech and ASC.Czech.IsPlayerCzech(player) then
            player:ChatPrint("[Boss System] 🎉 Obdržené odměny:")
            for rewardType, amount in pairs(rewards) do
                local rewardConfig = ASC.Boss.Config.RewardTypes[rewardType]
                if rewardConfig and amount > 0 then
                    local czechName = ASC.Czech.TranslateRewardType(rewardType) or rewardConfig.name
                    player:ChatPrint("• " .. czechName .. ": " .. amount)
                end
            end
        end
    end,

    -- Broadcast reward distribution to all players
    BroadcastRewardDistribution = function(bossType, participants, bonusMultiplier)
        local bossConfig = ASC.Boss.Config.BossTypes[bossType]
        if not bossConfig then return end

        local participantNames = {}
        for _, player in ipairs(participants) do
            if IsValid(player) then
                table.insert(participantNames, player:Name())
            end
        end

        local message = "[Boss System] 🏆 Boss " .. bossConfig.name .. " defeated!"
        local participantsText = "Participants: " .. table.concat(participantNames, ", ")

        if bonusMultiplier > 1.0 then
            message = message .. " (Bonus: " .. math.floor(bonusMultiplier * 100) .. "%)"
        end

        for _, player in ipairs(player.GetAll()) do
            player:ChatPrint(message)
            player:ChatPrint(participantsText)

            -- Czech translation if available
            if ASC.Czech and ASC.Czech.IsPlayerCzech and ASC.Czech.IsPlayerCzech(player) then
                player:ChatPrint("[Boss System] 🏆 Boss " .. bossConfig.name .. " poražen!")
                player:ChatPrint("Účastníci: " .. table.concat(participantNames, ", "))
            end
        end
    end,

    -- Save player data to file
    SavePlayerData = function(steamID, playerData)
        local fileName = "asc_boss_data/" .. string.gsub(steamID, ":", "_") .. ".txt"
        local data = util.TableToJSON(playerData)

        if not file.Exists("asc_boss_data", "DATA") then
            file.CreateDir("asc_boss_data")
        end

        file.Write(fileName, data)
    end,

    -- Load player data from file
    LoadPlayerData = function(steamID)
        local fileName = "asc_boss_data/" .. string.gsub(steamID, ":", "_") .. ".txt"

        if file.Exists(fileName, "DATA") then
            local data = file.Read(fileName, "DATA")
            local playerData = util.JSONToTable(data)

            if playerData then
                ASC.Boss.Core.PlayerData[steamID] = playerData
                return playerData
            end
        end

        return nil
    end,

    -- Get player statistics
    GetPlayerStats = function(player)
        if not IsValid(player) then return nil end

        local steamID = player:SteamID()
        local playerData = ASC.Boss.Core.PlayerData[steamID]

        if not playerData then
            playerData = ASC.Boss.Core.LoadPlayerData(steamID)
        end

        if not playerData then
            return {
                credits = 0,
                experience = 0,
                materials = 0,
                technology = 0,
                bossesDefeated = 0,
                totalRewards = 0
            }
        end

        return playerData
    end,
    
    -- Cast vote
    CastVote = function(player, optionIndex)
        if not ASC.Boss.Core.CurrentVote then
            return false, "No active boss vote"
        end
        
        if not ASC.Boss.Core.CurrentVote.options[optionIndex] then
            return false, "Invalid vote option"
        end
        
        -- Remove previous vote if exists
        if ASC.Boss.Core.CurrentVote.votes[player] then
            local prevOption = ASC.Boss.Core.CurrentVote.votes[player]
            ASC.Boss.Core.CurrentVote.options[prevOption].votes = ASC.Boss.Core.CurrentVote.options[prevOption].votes - 1
        end
        
        -- Cast new vote
        ASC.Boss.Core.CurrentVote.votes[player] = optionIndex
        ASC.Boss.Core.CurrentVote.options[optionIndex].votes = ASC.Boss.Core.CurrentVote.options[optionIndex].votes + 1
        
        player:ChatPrint("🗳️ Vote cast for " .. ASC.Boss.Core.CurrentVote.options[optionIndex].name)
        return true
    end,
    
    -- End boss vote
    EndBossVote = function()
        if not ASC.Boss.Core.CurrentVote then return end
        
        -- Find winning option
        local winningOption = nil
        local maxVotes = 0
        
        for _, option in ipairs(ASC.Boss.Core.CurrentVote.options) do
            if option.votes > maxVotes then
                maxVotes = option.votes
                winningOption = option
            end
        end
        
        -- Clean up vote
        local vote = ASC.Boss.Core.CurrentVote
        ASC.Boss.Core.CurrentVote = nil
        timer.Remove("ASC_Boss_Vote")
        
        if winningOption and maxVotes > 0 then
            -- Spawn winning boss
            ASC.Boss.Core.SpawnBoss(winningOption.type, vote.initiator)
            ASC.Boss.Core.BroadcastVoteResult(winningOption, true)
        else
            ASC.Boss.Core.BroadcastVoteResult(nil, false)
        end
    end,
    
    -- Spawn boss
    SpawnBoss = function(bossType, initiator)
        local config = ASC.Boss.Config.BossTypes[bossType]
        if not config then return nil end
        
        -- Find spawn position
        local spawnPos = ASC.Boss.Core.FindBossSpawnPosition(initiator)
        if not spawnPos then
            return nil, "No suitable spawn position found"
        end
        
        ASC.Boss.Core.BossCounter = ASC.Boss.Core.BossCounter + 1
        
        -- Create boss entity (placeholder - would need actual boss ship entity)
        local boss = ents.Create("asc_ship_core")
        if not IsValid(boss) then return nil end
        
        boss:SetPos(spawnPos)
        boss:SetAngles(Angle(0, math.random(0, 360), 0))
        boss:Spawn()
        
        -- Configure boss
        local bossData = {
            id = ASC.Boss.Core.BossCounter,
            entity = boss,
            type = bossType,
            config = config,
            
            -- Status
            health = config.health,
            maxHealth = config.health,
            shields = config.shields,
            maxShields = config.shields,
            
            -- AI State
            state = "PATROL", -- PATROL, ENGAGE, RETREAT, ABILITY
            target = nil,
            lastTarget = nil,
            aggroList = {},
            
            -- Combat
            lastAttack = 0,
            lastAbility = 0,
            combatStartTime = 0,
            
            -- Movement
            patrolCenter = spawnPos,
            patrolTarget = spawnPos,
            lastPatrolUpdate = 0,
            
            -- Statistics
            spawnTime = CurTime(),
            damageDealt = 0,
            damageTaken = 0,
            playersKilled = 0,
            
            -- Rewards
            initiator = initiator,
            participants = {}
        }
        
        -- Set up boss entity
        boss:SetNWString("BossType", bossType)
        boss:SetNWString("BossName", config.name)
        boss:SetNWInt("BossHealth", config.health)
        boss:SetNWInt("BossMaxHealth", config.health)
        boss:SetNWInt("BossShields", config.shields)
        boss:SetNWInt("BossMaxShields", config.shields)
        boss:SetNWBool("IsBoss", true)
        
        -- Add to active bosses
        ASC.Boss.Core.ActiveBosses[bossData.id] = bossData
        
        -- Initialize boss AI
        ASC.Boss.Core.InitializeBossAI(bossData)
        
        print("[Boss System] Spawned " .. config.name .. " at " .. tostring(spawnPos))
        return bossData
    end,
    
    -- Find boss spawn position
    FindBossSpawnPosition = function(initiator)
        local attempts = 10
        local initiatorPos = IsValid(initiator) and initiator:GetPos() or Vector(0, 0, 1000)
        
        for i = 1, attempts do
            -- Random position around initiator
            local angle = math.random(0, 360)
            local distance = ASC.Boss.Config.SpawnDistance + math.random(-500, 500)
            
            local spawnPos = initiatorPos + Vector(
                math.cos(math.rad(angle)) * distance,
                math.sin(math.rad(angle)) * distance,
                math.random(500, 2000)
            )
            
            -- Check if position is safe
            if ASC.Boss.Core.IsSpawnPositionSafe(spawnPos) then
                return spawnPos
            end
        end
        
        -- Fallback position
        return initiatorPos + Vector(0, 0, 2000)
    end,
    
    -- Check if spawn position is safe
    IsSpawnPositionSafe = function(pos)
        -- Check for nearby players
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:GetPos():Distance(pos) < ASC.Boss.Config.SafeSpawnRadius then
                return false
            end
        end
        
        -- Check for world collision
        local trace = util.TraceLine({
            start = pos,
            endpos = pos + Vector(0, 0, -1000),
            mask = MASK_SOLID_BRUSHONLY
        })
        
        return not trace.Hit or trace.HitPos:Distance(pos) > 500
    end,
    
    -- Initialize boss AI
    InitializeBossAI = function(bossData)
        if not bossData or not IsValid(bossData.entity) then return end
        
        -- Set initial patrol target
        ASC.Boss.Core.SetNewPatrolTarget(bossData)
        
        -- Initialize flight system if available
        if ASC.Flight then
            local shipID = bossData.entity:EntIndex()
            ASC.Flight.Core.ActivateFlightSystem(shipID, bossData.entity)
        end
        
        print("[Boss System] Initialized AI for " .. bossData.config.name)
    end,
    
    -- Set new patrol target
    SetNewPatrolTarget = function(bossData)
        if not bossData then return end
        
        local center = bossData.patrolCenter
        local radius = ASC.Boss.Config.PatrolRadius
        
        -- Random position within patrol radius
        local angle = math.random(0, 360)
        local distance = math.random(radius * 0.3, radius)
        
        bossData.patrolTarget = center + Vector(
            math.cos(math.rad(angle)) * distance,
            math.sin(math.rad(angle)) * distance,
            math.random(-200, 200)
        )
        
        bossData.lastPatrolUpdate = CurTime()
    end,
    
    -- Update boss system
    Update = function()
        for bossID, bossData in pairs(ASC.Boss.Core.ActiveBosses) do
            ASC.Boss.Core.UpdateBoss(bossID)
        end
    end,

    -- Update individual boss
    UpdateBoss = function(bossID)
        local bossData = ASC.Boss.Core.ActiveBosses[bossID]
        if not bossData or not IsValid(bossData.entity) then
            ASC.Boss.Core.ActiveBosses[bossID] = nil
            return
        end

        -- Update boss AI state
        ASC.Boss.Core.UpdateBossAI(bossData)

        -- Update boss combat
        ASC.Boss.Core.UpdateBossCombat(bossData)

        -- Update boss abilities
        ASC.Boss.Core.UpdateBossAbilities(bossData)

        -- Check despawn conditions
        ASC.Boss.Core.CheckBossDespawn(bossData)
    end,

    -- Update boss AI
    UpdateBossAI = function(bossData)
        if not bossData or not IsValid(bossData.entity) then return end

        local currentTime = CurTime()
        local bossPos = bossData.entity:GetPos()

        -- Find nearest target
        local nearestTarget = ASC.Boss.Core.FindNearestTarget(bossData)

        -- Update AI state based on conditions
        if bossData.state == "PATROL" then
            if nearestTarget and bossPos:Distance(nearestTarget:GetPos()) <= ASC.Boss.Config.AggroRange then
                bossData.state = "ENGAGE"
                bossData.target = nearestTarget
                bossData.combatStartTime = currentTime
                ASC.Boss.Core.BroadcastBossEngagement(bossData, nearestTarget)
            else
                -- Continue patrolling
                ASC.Boss.Core.UpdatePatrol(bossData)
            end

        elseif bossData.state == "ENGAGE" then
            if not IsValid(bossData.target) or bossPos:Distance(bossData.target:GetPos()) > ASC.Boss.Config.EngagementRange then
                -- Lost target, return to patrol
                bossData.state = "PATROL"
                bossData.target = nil
                ASC.Boss.Core.SetNewPatrolTarget(bossData)
            elseif bossData.health < bossData.maxHealth * ASC.Boss.Config.RetreatThreshold then
                -- Low health, retreat
                bossData.state = "RETREAT"
                ASC.Boss.Core.InitiateRetreat(bossData)
            else
                -- Continue combat
                ASC.Boss.Core.UpdateCombat(bossData)
            end

        elseif bossData.state == "RETREAT" then
            if bossData.health > bossData.maxHealth * 0.5 then
                -- Recovered enough, re-engage
                bossData.state = "ENGAGE"
            else
                ASC.Boss.Core.UpdateRetreat(bossData)
            end

        elseif bossData.state == "ABILITY" then
            -- Ability state handled in UpdateBossAbilities
            if currentTime - bossData.lastAbility > 5 then
                bossData.state = "ENGAGE"
            end
        end
    end,

    -- Find nearest target
    FindNearestTarget = function(bossData)
        if not bossData or not IsValid(bossData.entity) then return nil end

        local bossPos = bossData.entity:GetPos()
        local nearestTarget = nil
        local nearestDistance = math.huge

        -- Check all players
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() then
                local distance = bossPos:Distance(ply:GetPos())
                if distance < nearestDistance and distance <= ASC.Boss.Config.EngagementRange then
                    nearestTarget = ply
                    nearestDistance = distance
                end
            end
        end

        -- Check player ships
        if ASC.Flight then
            for shipID, flight in pairs(ASC.Flight.Core.ActiveFlights) do
                if IsValid(flight.shipCore) then
                    local distance = bossPos:Distance(flight.shipCore:GetPos())
                    if distance < nearestDistance and distance <= ASC.Boss.Config.EngagementRange then
                        nearestTarget = flight.shipCore
                        nearestDistance = distance
                    end
                end
            end
        end

        return nearestTarget
    end,

    -- Update patrol behavior
    UpdatePatrol = function(bossData)
        if not bossData or not IsValid(bossData.entity) then return end

        local bossPos = bossData.entity:GetPos()
        local targetDistance = bossPos:Distance(bossData.patrolTarget)

        -- Check if reached patrol target
        if targetDistance < 200 or CurTime() - bossData.lastPatrolUpdate > 30 then
            ASC.Boss.Core.SetNewPatrolTarget(bossData)
        end

        -- Move towards patrol target
        if ASC.Flight then
            local shipID = bossData.entity:EntIndex()
            ASC.Flight.Core.EnableAutopilot(shipID, bossData.patrolTarget, "PATROL")
        end
    end,

    -- Update combat behavior
    UpdateCombat = function(bossData)
        if not bossData or not IsValid(bossData.entity) or not IsValid(bossData.target) then return end

        local bossPos = bossData.entity:GetPos()
        local targetPos = bossData.target:GetPos()
        local distance = bossPos:Distance(targetPos)

        -- Maintain optimal combat distance
        local optimalDistance = 800
        local combatTarget = targetPos

        if distance < optimalDistance * 0.7 then
            -- Too close, back away
            local direction = (bossPos - targetPos):GetNormalized()
            combatTarget = targetPos + direction * optimalDistance
        elseif distance > optimalDistance * 1.5 then
            -- Too far, move closer
            local direction = (targetPos - bossPos):GetNormalized()
            combatTarget = bossPos + direction * (distance - optimalDistance)
        end

        -- Move to combat position
        if ASC.Flight then
            local shipID = bossData.entity:EntIndex()
            ASC.Flight.Core.EnableAutopilot(shipID, combatTarget, "COMBAT")
        end

        -- Attack target
        ASC.Boss.Core.AttackTarget(bossData, bossData.target)
    end,

    -- Initiate retreat
    InitiateRetreat = function(bossData)
        if not bossData or not IsValid(bossData.entity) then return end

        local bossPos = bossData.entity:GetPos()
        local retreatDirection = Vector(math.random(-1, 1), math.random(-1, 1), 1):GetNormalized()
        local retreatTarget = bossPos + retreatDirection * 2000

        -- Move to retreat position
        if ASC.Flight then
            local shipID = bossData.entity:EntIndex()
            ASC.Flight.Core.EnableAutopilot(shipID, retreatTarget, "RETREAT")
        end

        ASC.Boss.Core.BroadcastBossRetreat(bossData)
    end,

    -- Update retreat behavior
    UpdateRetreat = function(bossData)
        if not bossData then return end

        -- Regenerate health/shields during retreat
        local regenRate = bossData.maxHealth * 0.02 -- 2% per second
        bossData.health = math.min(bossData.health + regenRate * ASC.Boss.Config.UpdateRate, bossData.maxHealth)

        local shieldRegenRate = bossData.maxShields * 0.05 -- 5% per second
        bossData.shields = math.min(bossData.shields + shieldRegenRate * ASC.Boss.Config.UpdateRate, bossData.maxShields)

        -- Update network values
        if IsValid(bossData.entity) then
            bossData.entity:SetNWInt("BossHealth", math.floor(bossData.health))
            bossData.entity:SetNWInt("BossShields", math.floor(bossData.shields))
        end
    end,

    -- Attack target
    AttackTarget = function(bossData, target)
        if not bossData or not IsValid(bossData.entity) or not IsValid(target) then return end

        local currentTime = CurTime()
        if currentTime - bossData.lastAttack < 2 then return end -- Attack cooldown

        local bossPos = bossData.entity:GetPos()
        local targetPos = target:GetPos()
        local distance = bossPos:Distance(targetPos)

        -- Choose weapon based on distance and boss type
        local weapon = bossData.config.weapons[1] -- Default to first weapon

        -- Simulate weapon attack
        ASC.Boss.Core.FireWeapon(bossData, target, weapon)

        bossData.lastAttack = currentTime

        -- Add target to participants for rewards
        if target:IsPlayer() then
            bossData.participants[target] = (bossData.participants[target] or 0) + 1
        end
    end,

    -- Fire weapon at target
    FireWeapon = function(bossData, target, weapon)
        if not bossData or not IsValid(bossData.entity) or not IsValid(target) then return end

        local bossPos = bossData.entity:GetPos()
        local targetPos = target:GetPos()

        -- Create weapon effect (placeholder - would need actual weapon entities)
        local effectData = EffectData()
        effectData:SetStart(bossPos)
        effectData:SetOrigin(targetPos)
        effectData:SetEntity(bossData.entity)
        util.Effect("boss_weapon_" .. weapon, effectData)

        -- Deal damage
        local damage = math.random(100, 300) -- Base damage
        ASC.Boss.Core.DealDamageToTarget(target, damage, bossData)

        bossData.damageDealt = bossData.damageDealt + damage

        print("[Boss System] " .. bossData.config.name .. " attacked with " .. weapon .. " for " .. damage .. " damage")
    end,

    -- Deal damage to target
    DealDamageToTarget = function(target, damage, bossData)
        if not IsValid(target) then return end

        if target:IsPlayer() then
            -- Damage player
            target:TakeDamage(damage, bossData.entity, bossData.entity)
            target:ChatPrint("💥 Hit by " .. bossData.config.name .. " for " .. damage .. " damage!")
        else
            -- Damage ship or entity
            if target.TakeDamage then
                target:TakeDamage(damage, bossData.entity, bossData.entity)
            end
        end
    end,

    -- Update boss abilities
    UpdateBossAbilities = function(bossData)
        if not bossData or not IsValid(bossData.entity) then return end

        local currentTime = CurTime()
        if currentTime - bossData.lastAbility < 15 then return end -- Ability cooldown

        if bossData.state ~= "ENGAGE" or not IsValid(bossData.target) then return end

        -- Random chance to use ability
        if math.random() < 0.3 then
            local ability = bossData.config.abilities[math.random(#bossData.config.abilities)]
            ASC.Boss.Core.UseAbility(bossData, ability)
            bossData.lastAbility = currentTime
            bossData.state = "ABILITY"
        end
    end,

    -- Use boss ability
    UseAbility = function(bossData, ability)
        if not bossData or not IsValid(bossData.entity) then return end

        print("[Boss System] " .. bossData.config.name .. " using ability: " .. ability)

        if ability == "shield_boost" then
            bossData.shields = math.min(bossData.shields + bossData.maxShields * 0.3, bossData.maxShields)
            ASC.Boss.Core.BroadcastAbility(bossData, "Shield Boost", "🛡️ Boss shields increased!")

        elseif ability == "weapon_overcharge" then
            -- Increase damage for next few attacks
            bossData.weaponOvercharge = CurTime() + 10
            ASC.Boss.Core.BroadcastAbility(bossData, "Weapon Overcharge", "⚡ Boss weapons overcharged!")

        elseif ability == "regeneration" then
            bossData.health = math.min(bossData.health + bossData.maxHealth * 0.2, bossData.maxHealth)
            ASC.Boss.Core.BroadcastAbility(bossData, "Regeneration", "💚 Boss is regenerating!")

        elseif ability == "teleport" then
            local newPos = ASC.Boss.Core.FindTeleportPosition(bossData)
            if newPos then
                bossData.entity:SetPos(newPos)
                ASC.Boss.Core.BroadcastAbility(bossData, "Teleport", "🌀 Boss teleported!")
            end

        elseif ability == "fighter_launch" then
            ASC.Boss.Core.SpawnFighters(bossData)
            ASC.Boss.Core.BroadcastAbility(bossData, "Fighter Launch", "🚀 Boss launched fighters!")
        end

        -- Update network values
        bossData.entity:SetNWInt("BossHealth", math.floor(bossData.health))
        bossData.entity:SetNWInt("BossShields", math.floor(bossData.shields))
    end,

    -- Find teleport position
    FindTeleportPosition = function(bossData)
        if not bossData or not IsValid(bossData.target) then return nil end

        local targetPos = bossData.target:GetPos()
        local attempts = 5

        for i = 1, attempts do
            local angle = math.random(0, 360)
            local distance = math.random(1000, 1500)
            local newPos = targetPos + Vector(
                math.cos(math.rad(angle)) * distance,
                math.sin(math.rad(angle)) * distance,
                math.random(200, 800)
            )

            -- Check if position is safe
            if ASC.Boss.Core.IsSpawnPositionSafe(newPos) then
                return newPos
            end
        end

        return nil
    end,

    -- Spawn fighter escorts
    SpawnFighters = function(bossData)
        if not bossData or not IsValid(bossData.entity) then return end

        local bossPos = bossData.entity:GetPos()
        local fighterCount = math.random(2, 4)

        for i = 1, fighterCount do
            local angle = (i / fighterCount) * 360
            local distance = 300
            local fighterPos = bossPos + Vector(
                math.cos(math.rad(angle)) * distance,
                math.sin(math.rad(angle)) * distance,
                math.random(-100, 100)
            )

            -- Create fighter (placeholder - would need actual fighter entity)
            local fighter = ents.Create("asc_ship_core")
            if IsValid(fighter) then
                fighter:SetPos(fighterPos)
                fighter:SetAngles(Angle(0, angle, 0))
                fighter:Spawn()
                fighter:SetNWString("BossType", "FIGHTER")
                fighter:SetNWString("BossName", "Fighter")
                fighter:SetNWBool("IsBossFighter", true)

                -- Set fighter to follow boss
                timer.Simple(1, function()
                    if IsValid(fighter) and IsValid(bossData.entity) then
                        fighter:Remove() -- Remove after 30 seconds
                    end
                end)
            end
        end
    end,

    -- Check boss despawn conditions
    CheckBossDespawn = function(bossData)
        if not bossData or not IsValid(bossData.entity) then return end

        local bossPos = bossData.entity:GetPos()
        local shouldDespawn = false

        -- Check if boss is too far from all players
        local nearestPlayerDistance = math.huge
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                local distance = bossPos:Distance(ply:GetPos())
                if distance < nearestPlayerDistance then
                    nearestPlayerDistance = distance
                end
            end
        end

        if nearestPlayerDistance > ASC.Boss.Config.DespawnDistance then
            shouldDespawn = true
        end

        -- Check if boss is dead
        if bossData.health <= 0 then
            ASC.Boss.Core.DefeatBoss(bossData)
            return
        end

        if shouldDespawn then
            ASC.Boss.Core.DespawnBoss(bossData.id)
        end
    end,

    -- Defeat boss
    DefeatBoss = function(bossData)
        if not bossData then return end

        -- Calculate and distribute rewards
        ASC.Boss.Core.DistributeRewards(bossData)

        -- Broadcast defeat
        ASC.Boss.Core.BroadcastBossDefeat(bossData)

        -- Remove boss
        if IsValid(bossData.entity) then
            bossData.entity:Remove()
        end

        ASC.Boss.Core.ActiveBosses[bossData.id] = nil

        print("[Boss System] Boss " .. bossData.config.name .. " defeated!")
    end,

    -- Despawn boss
    DespawnBoss = function(bossID)
        local bossData = ASC.Boss.Core.ActiveBosses[bossID]
        if not bossData then return end

        -- Broadcast despawn
        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint("👹 " .. bossData.config.name .. " has retreated from the battlefield")
        end

        -- Remove boss
        if IsValid(bossData.entity) then
            bossData.entity:Remove()
        end

        ASC.Boss.Core.ActiveBosses[bossID] = nil

        print("[Boss System] Boss " .. bossData.config.name .. " despawned")
    end,

    -- Distribute rewards
    DistributeRewards = function(bossData)
        if not bossData then return end

        local baseReward = bossData.config.reward
        local participantCount = table.Count(bossData.participants)

        if participantCount == 0 then return end

        for participant, contribution in pairs(bossData.participants) do
            if IsValid(participant) then
                local reward = math.floor(baseReward * (contribution / participantCount))
                participant:ChatPrint("💰 Boss defeat reward: " .. reward .. " credits!")

                -- Add experience if system exists
                if participant.AddExperience then
                    participant:AddExperience(ASC.Boss.Config.ExperienceReward)
                end
            end
        end
    end,

    -- Broadcast boss engagement
    BroadcastBossEngagement = function(bossData, target)
        if not bossData then return end

        local targetName = IsValid(target) and (target:IsPlayer() and target:Name() or "Ship") or "Unknown"
        local message = "⚔️ " .. bossData.config.name .. " is engaging " .. targetName .. "!"

        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint(message)
        end
    end,

    -- Broadcast boss retreat
    BroadcastBossRetreat = function(bossData)
        if not bossData then return end

        local message = "🏃 " .. bossData.config.name .. " is retreating to regenerate!"

        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint(message)
        end
    end,

    -- Broadcast ability use
    BroadcastAbility = function(bossData, abilityName, message)
        if not bossData then return end

        local fullMessage = "💫 " .. bossData.config.name .. " used " .. abilityName .. "! " .. message

        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint(fullMessage)
        end
    end,

    -- Broadcast boss defeat
    BroadcastBossDefeat = function(bossData)
        if not bossData then return end

        local message = "🎉 " .. bossData.config.name .. " has been defeated!\n" ..
                       "💰 Rewards distributed to participants!\n" ..
                       "⏱️ Combat duration: " .. math.floor(CurTime() - bossData.spawnTime) .. " seconds"

        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint(message)
        end
    end,

    -- Broadcast vote start
    BroadcastVoteStart = function(initiator)
        local message = "🗳️ " .. initiator:Name() .. " started a boss vote!\n" ..
                       "Type 'aria vote boss [1-" .. #ASC.Boss.Core.CurrentVote.options .. "]' to vote:\n"
        
        for i, option in ipairs(ASC.Boss.Core.CurrentVote.options) do
            message = message .. i .. ". " .. option.name .. " (Difficulty: " .. option.difficulty .. "⭐)\n"
        end
        
        message = message .. "Vote ends in " .. ASC.Boss.Config.VotingDuration .. " seconds!"
        
        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint(message)
        end
    end,
    
    -- Broadcast vote result
    BroadcastVoteResult = function(winningOption, success)
        local message
        if success then
            message = "🎯 Boss vote complete! Spawning " .. winningOption.name .. "!\n" ..
                     "💰 Reward: " .. winningOption.reward .. " credits\n" ..
                     "⚔️ Prepare for battle!"
        else
            message = "❌ Boss vote failed - no votes cast or tie result"
        end
        
        for _, ply in ipairs(player.GetAll()) do
            ply:ChatPrint(message)
        end
    end,
    
    -- Get boss status
    GetBossStatus = function()
        local activeBosses = table.Count(ASC.Boss.Core.ActiveBosses)
        local voteActive = ASC.Boss.Core.CurrentVote ~= nil
        
        local status = "🤖 Boss System Status:\n" ..
                      "👹 Active Bosses: " .. activeBosses .. " / " .. ASC.Boss.Config.MaxActiveBosses .. "\n"
        
        if voteActive then
            local timeLeft = math.ceil(ASC.Boss.Core.CurrentVote.startTime + ASC.Boss.Core.CurrentVote.duration - CurTime())
            status = status .. "🗳️ Vote Active: " .. timeLeft .. " seconds remaining\n"
        else
            status = status .. "🗳️ Vote Status: Ready\n"
        end
        
        if activeBosses > 0 then
            status = status .. "\nActive Bosses:\n"
            for _, bossData in pairs(ASC.Boss.Core.ActiveBosses) do
                local healthPercent = math.floor((bossData.health / bossData.maxHealth) * 100)
                status = status .. "• " .. bossData.config.name .. " (" .. healthPercent .. "% HP)\n"
            end
        end
        
        return status
    end
}

-- Initialize system
if SERVER then
    -- Initialize boss system
    ASC.Boss.Core.Initialize()
    
    -- Update boss system
    timer.Create("ASC_Boss_Update", ASC.Boss.Config.UpdateRate, 0, function()
        ASC.Boss.Core.Update()
    end)
    
    -- Update system status
    ASC.SystemStatus.BossSystem = true
    ASC.SystemStatus.AIBosses = true
    
    print("[Advanced Space Combat] AI Boss Ship System v3.0.0 loaded")
end
