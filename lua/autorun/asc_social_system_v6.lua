-- Advanced Space Combat - Social & Guild System v6.0.0
-- Advanced social features, guild management, and community systems
-- Research-based implementation following 2025 social gaming best practices

print("[Advanced Space Combat] Social & Guild System v6.0.0 - Community Features Loading...")

-- Initialize social namespace
ASC = ASC or {}
ASC.Social = ASC.Social or {}

-- Social system configuration
ASC.Social.Config = {
    Version = "6.0.0",
    
    -- Guild settings
    Guilds = {
        MaxMembers = 50,
        MaxGuilds = 100,
        CreationCost = 5000,  -- credits
        MaintenanceCost = 100, -- credits per day
        MaxRankLevels = 10
    },
    
    -- Friend system
    Friends = {
        MaxFriends = 100,
        OnlineNotifications = true,
        StatusSharing = true,
        LocationSharing = false
    },
    
    -- Communication
    Communication = {
        GlobalChat = true,
        GuildChat = true,
        PrivateMessages = true,
        VoiceChat = false,  -- Would require additional implementation
        ChatHistory = 100
    },
    
    -- Reputation system
    Reputation = {
        Enabled = true,
        MaxReputation = 10000,
        MinReputation = -10000,
        DecayRate = 0.1,  -- per day
        Actions = {
            helpPlayer = 10,
            completeGuildMission = 25,
            betrayGuild = -100,
            griefing = -50
        }
    }
}

-- Social state
ASC.Social.State = {
    Guilds = {},
    Players = {},
    FriendRequests = {},
    ChatHistory = {},
    OnlinePlayers = {},
    GuildInvites = {}
}

-- Guild class
ASC.Social.Guild = {}
ASC.Social.Guild.__index = ASC.Social.Guild

function ASC.Social.Guild:New(name, founder)
    local guild = setmetatable({}, ASC.Social.Guild)
    
    guild.id = #ASC.Social.State.Guilds + 1
    guild.name = name
    guild.founder = IsValid(founder) and founder:SteamID() or "unknown"
    guild.founderName = IsValid(founder) and founder:Name() or "Unknown"
    guild.createdTime = os.time()
    guild.description = ""
    guild.tag = ""
    guild.level = 1
    guild.experience = 0
    guild.credits = 0
    guild.reputation = 0
    
    guild.members = {}
    guild.ranks = {
        {name = "Leader", level = 10, permissions = {"all"}},
        {name = "Officer", level = 5, permissions = {"invite", "kick", "promote", "demote"}},
        {name = "Member", level = 1, permissions = {"chat", "participate"}}
    }
    
    guild.settings = {
        public = true,
        autoAccept = false,
        requireApproval = true
    }
    
    guild.stats = {
        missionsCompleted = 0,
        totalExperience = 0,
        totalCredits = 0,
        memberCount = 0
    }
    
    -- Add founder as leader
    if IsValid(founder) then
        guild:AddMember(founder, 10)
    end
    
    return guild
end

function ASC.Social.Guild:AddMember(player, rankLevel)
    if not IsValid(player) then return false end
    
    local steamId = player:SteamID()
    rankLevel = rankLevel or 1
    
    if self.members[steamId] then return false end  -- Already a member
    
    if #table.GetKeys(self.members) >= ASC.Social.Config.Guilds.MaxMembers then
        return false  -- Guild full
    end
    
    self.members[steamId] = {
        name = player:Name(),
        joinTime = os.time(),
        rankLevel = rankLevel,
        contribution = 0,
        lastActive = os.time()
    }
    
    self.stats.memberCount = #table.GetKeys(self.members)
    
    -- Update player's guild
    local playerData = ASC.Social.GetPlayerData(player)
    playerData.guildId = self.id
    
    -- Notify guild members
    self:BroadcastMessage(player:Name() .. " has joined the guild!")
    
    return true
end

function ASC.Social.Guild:RemoveMember(steamId)
    if not self.members[steamId] then return false end
    
    local memberName = self.members[steamId].name
    self.members[steamId] = nil
    self.stats.memberCount = #table.GetKeys(self.members)
    
    -- Find player and update their data
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:SteamID() == steamId then
            local playerData = ASC.Social.GetPlayerData(ply)
            playerData.guildId = nil
            break
        end
    end
    
    -- Notify guild members
    self:BroadcastMessage(memberName .. " has left the guild.")
    
    return true
end

function ASC.Social.Guild:PromoteMember(steamId, newRankLevel)
    if not self.members[steamId] then return false end
    
    local member = self.members[steamId]
    local oldRank = member.rankLevel
    member.rankLevel = math.min(9, newRankLevel)  -- Can't promote to leader level
    
    local oldRankName = self:GetRankName(oldRank)
    local newRankName = self:GetRankName(member.rankLevel)
    
    self:BroadcastMessage(member.name .. " has been promoted from " .. oldRankName .. " to " .. newRankName)
    
    return true
end

function ASC.Social.Guild:GetRankName(level)
    for _, rank in ipairs(self.ranks) do
        if rank.level == level then
            return rank.name
        end
    end
    return "Unknown"
end

function ASC.Social.Guild:HasPermission(steamId, permission)
    if not self.members[steamId] then return false end
    
    local member = self.members[steamId]
    
    for _, rank in ipairs(self.ranks) do
        if rank.level == member.rankLevel then
            return table.HasValue(rank.permissions, permission) or table.HasValue(rank.permissions, "all")
        end
    end
    
    return false
end

function ASC.Social.Guild:BroadcastMessage(message)
    for steamId, member in pairs(self.members) do
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:SteamID() == steamId then
                ply:ChatPrint("[Guild: " .. self.name .. "] " .. message)
                break
            end
        end
    end
end

function ASC.Social.Guild:AddExperience(amount)
    self.experience = self.experience + amount
    self.stats.totalExperience = self.stats.totalExperience + amount
    
    -- Check for level up
    local requiredExp = self.level * 1000
    if self.experience >= requiredExp then
        self.level = self.level + 1
        self.experience = self.experience - requiredExp
        self:BroadcastMessage("Guild leveled up! Now level " .. self.level)
    end
end

-- Player data management
ASC.Social.GetPlayerData = function(player)
    if not IsValid(player) then return nil end
    
    local steamId = player:SteamID()
    
    if not ASC.Social.State.Players[steamId] then
        ASC.Social.State.Players[steamId] = {
            name = player:Name(),
            steamId = steamId,
            guildId = nil,
            friends = {},
            reputation = 0,
            status = "online",
            lastSeen = os.time(),
            settings = {
                showOnlineStatus = true,
                allowFriendRequests = true,
                showLocation = false
            },
            stats = {
                playtime = 0,
                missionsCompleted = 0,
                friendsHelped = 0
            }
        }
    end
    
    return ASC.Social.State.Players[steamId]
end

-- Friend system
ASC.Social.SendFriendRequest = function(sender, target)
    if not IsValid(sender) or not IsValid(target) then return false end
    if sender == target then return false end
    
    local senderId = sender:SteamID()
    local targetId = target:SteamID()
    
    -- Check if already friends
    local senderData = ASC.Social.GetPlayerData(sender)
    if table.HasValue(senderData.friends, targetId) then return false end
    
    -- Check if request already exists
    for _, request in ipairs(ASC.Social.State.FriendRequests) do
        if request.senderId == senderId and request.targetId == targetId then
            return false
        end
    end
    
    -- Create friend request
    local request = {
        id = #ASC.Social.State.FriendRequests + 1,
        senderId = senderId,
        senderName = sender:Name(),
        targetId = targetId,
        targetName = target:Name(),
        timestamp = os.time(),
        status = "pending"
    }
    
    table.insert(ASC.Social.State.FriendRequests, request)
    
    -- Notify target
    target:ChatPrint("[ASC Social] " .. sender:Name() .. " sent you a friend request. Use 'asc_friend_accept " .. request.id .. "' to accept.")
    
    return true
end

ASC.Social.AcceptFriendRequest = function(player, requestId)
    if not IsValid(player) then return false end
    
    local request = ASC.Social.State.FriendRequests[requestId]
    if not request or request.targetId ~= player:SteamID() or request.status ~= "pending" then
        return false
    end
    
    -- Add to friend lists
    local senderData = ASC.Social.State.Players[request.senderId]
    local targetData = ASC.Social.GetPlayerData(player)
    
    if senderData then
        table.insert(senderData.friends, request.targetId)
    end
    table.insert(targetData.friends, request.senderId)
    
    request.status = "accepted"
    
    -- Notify both players
    player:ChatPrint("[ASC Social] You are now friends with " .. request.senderName)
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:SteamID() == request.senderId then
            ply:ChatPrint("[ASC Social] " .. request.targetName .. " accepted your friend request!")
            break
        end
    end
    
    return true
end

-- Guild management functions
ASC.Social.CreateGuild = function(player, guildName)
    if not IsValid(player) then return nil end
    
    -- Check if player already in a guild
    local playerData = ASC.Social.GetPlayerData(player)
    if playerData.guildId then return nil end
    
    -- Check if player has enough credits
    if not ASC.Economy or not ASC.Economy.RemoveCredits(player, ASC.Social.Config.Guilds.CreationCost) then
        return nil
    end
    
    -- Create guild
    local guild = ASC.Social.Guild:New(guildName, player)
    table.insert(ASC.Social.State.Guilds, guild)
    
    player:ChatPrint("[ASC Social] Guild '" .. guildName .. "' created successfully!")
    
    return guild
end

ASC.Social.GetPlayerGuild = function(player)
    if not IsValid(player) then return nil end
    
    local playerData = ASC.Social.GetPlayerData(player)
    if not playerData.guildId then return nil end
    
    return ASC.Social.State.Guilds[playerData.guildId]
end

ASC.Social.InviteToGuild = function(inviter, target, guild)
    if not IsValid(inviter) or not IsValid(target) or not guild then return false end
    
    -- Check permissions
    if not guild:HasPermission(inviter:SteamID(), "invite") then return false end
    
    -- Check if target already in a guild
    local targetData = ASC.Social.GetPlayerData(target)
    if targetData.guildId then return false end
    
    -- Create invite
    local invite = {
        id = #ASC.Social.State.GuildInvites + 1,
        guildId = guild.id,
        guildName = guild.name,
        inviterId = inviter:SteamID(),
        inviterName = inviter:Name(),
        targetId = target:SteamID(),
        targetName = target:Name(),
        timestamp = os.time(),
        status = "pending"
    }
    
    table.insert(ASC.Social.State.GuildInvites, invite)
    
    target:ChatPrint("[ASC Social] " .. inviter:Name() .. " invited you to join guild '" .. guild.name .. "'. Use 'asc_guild_accept " .. invite.id .. "' to accept.")
    
    return true
end

-- Console commands
concommand.Add("asc_guild_create", function(ply, cmd, args)
    if not IsValid(ply) or #args == 0 then return end
    
    local guildName = table.concat(args, " ")
    local guild = ASC.Social.CreateGuild(ply, guildName)
    
    if not guild then
        ply:ChatPrint("[ASC Social] Failed to create guild. Check requirements.")
    end
end, nil, "Create a new guild")

concommand.Add("asc_guild_info", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local guild = ASC.Social.GetPlayerGuild(ply)
    if not guild then
        ply:ChatPrint("[ASC Social] You are not in a guild.")
        return
    end
    
    ply:ChatPrint("[ASC Social] Guild: " .. guild.name)
    ply:ChatPrint("  Level: " .. guild.level .. " (XP: " .. guild.experience .. ")")
    ply:ChatPrint("  Members: " .. guild.stats.memberCount .. "/" .. ASC.Social.Config.Guilds.MaxMembers)
    ply:ChatPrint("  Reputation: " .. guild.reputation)
    ply:ChatPrint("  Founded: " .. os.date("%Y-%m-%d", guild.createdTime))
end, nil, "Show guild information")

concommand.Add("asc_friend_add", function(ply, cmd, args)
    if not IsValid(ply) or #args == 0 then return end
    
    local targetName = args[1]
    local target = nil
    
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) and p:Name():lower():find(targetName:lower()) then
            target = p
            break
        end
    end
    
    if not target then
        ply:ChatPrint("[ASC Social] Player not found.")
        return
    end
    
    if ASC.Social.SendFriendRequest(ply, target) then
        ply:ChatPrint("[ASC Social] Friend request sent to " .. target:Name())
    else
        ply:ChatPrint("[ASC Social] Could not send friend request.")
    end
end, nil, "Send a friend request")

concommand.Add("asc_social_status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local playerData = ASC.Social.GetPlayerData(ply)
    
    ply:ChatPrint("[ASC Social] Social Status:")
    ply:ChatPrint("  Reputation: " .. playerData.reputation)
    ply:ChatPrint("  Friends: " .. #playerData.friends)
    
    local guild = ASC.Social.GetPlayerGuild(ply)
    if guild then
        ply:ChatPrint("  Guild: " .. guild.name .. " (Level " .. guild.level .. ")")
    else
        ply:ChatPrint("  Guild: None")
    end
end, nil, "Show social status")

print("[Advanced Space Combat] Social & Guild System v6.0.0 - Community Features Loaded Successfully!")
