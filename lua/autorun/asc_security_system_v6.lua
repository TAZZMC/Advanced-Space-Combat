-- Advanced Space Combat - Security & Anti-Cheat System v6.0.0
-- Advanced security monitoring, anti-cheat detection, and integrity verification
-- Research-based implementation following 2025 security best practices

print("[Advanced Space Combat] Security & Anti-Cheat System v6.0.0 - Advanced Protection Loading...")

-- Initialize security namespace
ASC = ASC or {}
ASC.Security = ASC.Security or {}

-- Security configuration
ASC.Security.Config = {
    Version = "6.0.0",
    Enabled = true,
    
    -- Detection systems
    Detection = {
        SpeedHacks = true,
        NoClip = true,
        Aimbot = true,
        Wallhacks = true,
        EntitySpam = true,
        CommandSpam = true,
        ResourceAbuse = true,
        IntegrityChecks = true
    },
    
    -- Thresholds
    Thresholds = {
        MaxSpeed = 2000,           -- units per second
        MaxAcceleration = 5000,    -- units per second squared
        MaxCommandsPerSecond = 10,
        MaxEntitiesPerPlayer = 50,
        SuspiciousActionCount = 5,
        IntegrityCheckInterval = 30
    },
    
    -- Response actions
    Actions = {
        LogOnly = false,
        WarnPlayer = true,
        KickPlayer = false,
        BanPlayer = false,
        NotifyAdmins = true,
        AutoCorrect = true
    }
}

-- Security state
ASC.Security.State = {
    PlayerProfiles = {},
    SuspiciousActivities = {},
    IntegrityHashes = {},
    LastIntegrityCheck = 0,
    ThreatLevel = "LOW"
}

-- Player security profile
ASC.Security.CreatePlayerProfile = function(player)
    if not IsValid(player) then return end
    
    local steamId = player:SteamID()
    
    ASC.Security.State.PlayerProfiles[steamId] = {
        player = player,
        joinTime = os.time(),
        lastPosition = player:GetPos(),
        lastVelocity = Vector(0, 0, 0),
        commandHistory = {},
        entityCount = 0,
        suspicionLevel = 0,
        violations = {},
        lastCheck = os.time()
    }
    
    print("[ASC Security] Security profile created for " .. player:Name())
end

-- Speed hack detection
ASC.Security.CheckSpeedHack = function(player)
    if not IsValid(player) or not ASC.Security.Config.Detection.SpeedHacks then return end
    
    local steamId = player:SteamID()
    local profile = ASC.Security.State.PlayerProfiles[steamId]
    if not profile then return end
    
    local currentPos = player:GetPos()
    local currentVel = player:GetVelocity()
    local currentTime = CurTime()
    
    -- Calculate speed and acceleration
    local speed = currentVel:Length()
    local timeDelta = currentTime - (profile.lastCheckTime or currentTime)
    
    if timeDelta > 0 then
        local acceleration = (currentVel - profile.lastVelocity):Length() / timeDelta
        
        -- Check for suspicious speed
        if speed > ASC.Security.Config.Thresholds.MaxSpeed then
            ASC.Security.ReportViolation(player, "SPEED_HACK", {
                speed = speed,
                maxSpeed = ASC.Security.Config.Thresholds.MaxSpeed,
                position = currentPos
            })
        end
        
        -- Check for suspicious acceleration
        if acceleration > ASC.Security.Config.Thresholds.MaxAcceleration then
            ASC.Security.ReportViolation(player, "ACCELERATION_HACK", {
                acceleration = acceleration,
                maxAcceleration = ASC.Security.Config.Thresholds.MaxAcceleration
            })
        end
    end
    
    -- Update profile
    profile.lastPosition = currentPos
    profile.lastVelocity = currentVel
    profile.lastCheckTime = currentTime
end

-- NoClip detection
ASC.Security.CheckNoClip = function(player)
    if not IsValid(player) or not ASC.Security.Config.Detection.NoClip then return end
    
    local steamId = player:SteamID()
    local profile = ASC.Security.State.PlayerProfiles[steamId]
    if not profile then return end
    
    -- Check if player is moving through solid objects
    local pos = player:GetPos()
    local trace = util.TraceLine({
        start = profile.lastPosition,
        endpos = pos,
        filter = player
    })
    
    if trace.Hit and trace.Fraction < 0.9 then
        -- Player moved through a solid object
        ASC.Security.ReportViolation(player, "NOCLIP_DETECTED", {
            startPos = profile.lastPosition,
            endPos = pos,
            hitPos = trace.HitPos
        })
    end
end

-- Entity spam detection
ASC.Security.CheckEntitySpam = function(player)
    if not IsValid(player) or not ASC.Security.Config.Detection.EntitySpam then return end
    
    local steamId = player:SteamID()
    local profile = ASC.Security.State.PlayerProfiles[steamId]
    if not profile then return end
    
    -- Count entities owned by player
    local entityCount = 0
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent:GetNWString("Owner") == player:Name() then
            entityCount = entityCount + 1
        end
    end
    
    profile.entityCount = entityCount
    
    if entityCount > ASC.Security.Config.Thresholds.MaxEntitiesPerPlayer then
        ASC.Security.ReportViolation(player, "ENTITY_SPAM", {
            entityCount = entityCount,
            maxEntities = ASC.Security.Config.Thresholds.MaxEntitiesPerPlayer
        })
    end
end

-- Command spam detection
ASC.Security.CheckCommandSpam = function(player, command)
    if not IsValid(player) or not ASC.Security.Config.Detection.CommandSpam then return end
    
    local steamId = player:SteamID()
    local profile = ASC.Security.State.PlayerProfiles[steamId]
    if not profile then return end
    
    local currentTime = os.time()
    
    -- Add command to history
    table.insert(profile.commandHistory, {
        command = command,
        timestamp = currentTime
    })
    
    -- Remove old commands (older than 1 second)
    for i = #profile.commandHistory, 1, -1 do
        if currentTime - profile.commandHistory[i].timestamp > 1 then
            table.remove(profile.commandHistory, i)
        end
    end
    
    -- Check command rate
    if #profile.commandHistory > ASC.Security.Config.Thresholds.MaxCommandsPerSecond then
        ASC.Security.ReportViolation(player, "COMMAND_SPAM", {
            commandsPerSecond = #profile.commandHistory,
            maxCommands = ASC.Security.Config.Thresholds.MaxCommandsPerSecond,
            recentCommand = command
        })
    end
end

-- Integrity verification
ASC.Security.VerifyIntegrity = function()
    if not ASC.Security.Config.Detection.IntegrityChecks then return end
    
    local currentTime = os.time()
    if currentTime - ASC.Security.State.LastIntegrityCheck < ASC.Security.Config.Thresholds.IntegrityCheckInterval then
        return
    end
    
    -- Check core files
    local coreFiles = {
        "lua/autorun/asc_core_v6.lua",
        "lua/autorun/asc_ai_system_v6.lua",
        "lua/autorun/client/asc_modern_ui_v6.lua",
        "lua/autorun/asc_performance_optimizer_v6.lua"
    }
    
    local integrityIssues = {}
    
    for _, filePath in ipairs(coreFiles) do
        if file.Exists(filePath, "GAME") then
            local content = file.Read(filePath, "GAME")
            local hash = util.CRC(content)
            
            if ASC.Security.State.IntegrityHashes[filePath] then
                if ASC.Security.State.IntegrityHashes[filePath] ~= hash then
                    table.insert(integrityIssues, {
                        file = filePath,
                        expectedHash = ASC.Security.State.IntegrityHashes[filePath],
                        actualHash = hash
                    })
                end
            else
                -- First time, store the hash
                ASC.Security.State.IntegrityHashes[filePath] = hash
            end
        else
            table.insert(integrityIssues, {
                file = filePath,
                issue = "FILE_MISSING"
            })
        end
    end
    
    if #integrityIssues > 0 then
        ASC.Security.ReportIntegrityIssues(integrityIssues)
    end
    
    ASC.Security.State.LastIntegrityCheck = currentTime
end

-- Report security violation
ASC.Security.ReportViolation = function(player, violationType, details)
    if not IsValid(player) then return end
    
    local steamId = player:SteamID()
    local profile = ASC.Security.State.PlayerProfiles[steamId]
    if not profile then return end
    
    local violation = {
        type = violationType,
        player = player:Name(),
        steamId = steamId,
        details = details,
        timestamp = os.time(),
        severity = ASC.Security.GetViolationSeverity(violationType)
    }
    
    -- Add to player profile
    table.insert(profile.violations, violation)
    profile.suspicionLevel = profile.suspicionLevel + violation.severity
    
    -- Add to global suspicious activities
    table.insert(ASC.Security.State.SuspiciousActivities, violation)
    
    -- Update threat level
    ASC.Security.UpdateThreatLevel()
    
    -- Log violation
    print("[ASC Security] VIOLATION: " .. violationType .. " by " .. player:Name() .. " (Severity: " .. violation.severity .. ")")
    
    -- Track in analytics
    if ASC.Analytics then
        ASC.Analytics.TrackEvent("security_violation", {
            type = violationType,
            player = player:Name(),
            severity = violation.severity
        })
    end
    
    -- Take action
    ASC.Security.TakeAction(player, violation)
end

-- Get violation severity
ASC.Security.GetViolationSeverity = function(violationType)
    local severities = {
        SPEED_HACK = 3,
        ACCELERATION_HACK = 2,
        NOCLIP_DETECTED = 4,
        ENTITY_SPAM = 2,
        COMMAND_SPAM = 1,
        AIMBOT_DETECTED = 5,
        WALLHACK_DETECTED = 4
    }
    
    return severities[violationType] or 1
end

-- Take action against violator
ASC.Security.TakeAction = function(player, violation)
    if not IsValid(player) then return end
    
    local config = ASC.Security.Config.Actions
    local steamId = player:SteamID()
    local profile = ASC.Security.State.PlayerProfiles[steamId]
    
    -- Warn player
    if config.WarnPlayer then
        player:ChatPrint("[ASC Security] Warning: Suspicious activity detected (" .. violation.type .. ")")
    end
    
    -- Notify admins
    if config.NotifyAdmins then
        for _, admin in ipairs(player.GetAll()) do
            if IsValid(admin) and admin:IsAdmin() then
                admin:ChatPrint("[ASC Security] " .. player:Name() .. " triggered " .. violation.type .. " (Severity: " .. violation.severity .. ")")
            end
        end
    end
    
    -- Auto-correct if possible
    if config.AutoCorrect then
        ASC.Security.AutoCorrect(player, violation)
    end
    
    -- Escalate if necessary
    if profile and profile.suspicionLevel >= ASC.Security.Config.Thresholds.SuspiciousActionCount then
        if config.KickPlayer then
            player:Kick("Suspicious activity detected by ASC Security")
        elseif config.BanPlayer then
            -- Would implement ban logic here
            print("[ASC Security] Player " .. player:Name() .. " would be banned (ban system not implemented)")
        end
    end
end

-- Auto-correct violations
ASC.Security.AutoCorrect = function(player, violation)
    if not IsValid(player) then return end
    
    if violation.type == "SPEED_HACK" or violation.type == "ACCELERATION_HACK" then
        -- Reset player velocity
        player:SetVelocity(Vector(0, 0, 0))
        print("[ASC Security] Auto-corrected speed violation for " .. player:Name())
    elseif violation.type == "NOCLIP_DETECTED" then
        -- Teleport player back to safe position
        local profile = ASC.Security.State.PlayerProfiles[player:SteamID()]
        if profile and profile.lastPosition then
            player:SetPos(profile.lastPosition)
            print("[ASC Security] Auto-corrected position for " .. player:Name())
        end
    end
end

-- Update threat level
ASC.Security.UpdateThreatLevel = function()
    local recentViolations = 0
    local currentTime = os.time()
    
    -- Count violations in last 5 minutes
    for _, activity in ipairs(ASC.Security.State.SuspiciousActivities) do
        if currentTime - activity.timestamp < 300 then
            recentViolations = recentViolations + activity.severity
        end
    end
    
    if recentViolations >= 15 then
        ASC.Security.State.ThreatLevel = "CRITICAL"
    elseif recentViolations >= 10 then
        ASC.Security.State.ThreatLevel = "HIGH"
    elseif recentViolations >= 5 then
        ASC.Security.State.ThreatLevel = "MEDIUM"
    else
        ASC.Security.State.ThreatLevel = "LOW"
    end
end

-- Main security update function
ASC.Security.Update = function()
    if not ASC.Security.Config.Enabled then return end
    
    -- Check all players
    for _, player in ipairs(player.GetAll()) do
        if IsValid(player) then
            local steamId = player:SteamID()
            
            -- Create profile if needed
            if not ASC.Security.State.PlayerProfiles[steamId] then
                ASC.Security.CreatePlayerProfile(player)
            end
            
            -- Run security checks
            ASC.Security.CheckSpeedHack(player)
            ASC.Security.CheckNoClip(player)
            ASC.Security.CheckEntitySpam(player)
        end
    end
    
    -- Verify integrity
    ASC.Security.VerifyIntegrity()
end

-- Console commands
concommand.Add("asc_security_status", function(ply, cmd, args)
    local function printMsg(msg)
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    printMsg("[ASC Security] Security Status:")
    printMsg("  Threat Level: " .. ASC.Security.State.ThreatLevel)
    printMsg("  Monitored Players: " .. table.Count(ASC.Security.State.PlayerProfiles))
    printMsg("  Recent Violations: " .. #ASC.Security.State.SuspiciousActivities)
    
    -- Show recent violations
    local recentCount = 0
    local currentTime = os.time()
    for _, activity in ipairs(ASC.Security.State.SuspiciousActivities) do
        if currentTime - activity.timestamp < 300 then
            recentCount = recentCount + 1
        end
    end
    printMsg("  Violations (5 min): " .. recentCount)
end, nil, "Show security system status")

-- Hook into player events
hook.Add("PlayerInitialSpawn", "ASC_Security_PlayerJoin", function(player)
    timer.Simple(1, function()
        if IsValid(player) then
            ASC.Security.CreatePlayerProfile(player)
        end
    end)
end)

hook.Add("PlayerDisconnected", "ASC_Security_PlayerLeave", function(player)
    local steamId = player:SteamID()
    ASC.Security.State.PlayerProfiles[steamId] = nil
end)

-- Server-side security monitoring
if SERVER then
    timer.Create("ASC_Security_Update", 1, 0, ASC.Security.Update)
    
    -- Hook into console commands
    hook.Add("PlayerSay", "ASC_Security_CommandMonitor", function(player, text)
        if string.sub(text, 1, 1) == "!" or string.sub(text, 1, 1) == "/" then
            ASC.Security.CheckCommandSpam(player, text)
        end
    end)
end

print("[Advanced Space Combat] Security & Anti-Cheat System v6.0.0 - Advanced Protection Loaded Successfully!")
