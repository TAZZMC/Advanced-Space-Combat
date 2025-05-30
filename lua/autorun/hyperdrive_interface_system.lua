-- Enhanced Hyperdrive System v2.1 - Interface System
-- Comprehensive USE key interface management system

if CLIENT then return end

print("[Hyperdrive] Loading Interface System v2.1...")

-- Initialize interface system
HYPERDRIVE.Interface = HYPERDRIVE.Interface or {}
HYPERDRIVE.Interface.ActiveSessions = HYPERDRIVE.Interface.ActiveSessions or {}
HYPERDRIVE.Interface.SessionHistory = HYPERDRIVE.Interface.SessionHistory or {}
HYPERDRIVE.Interface.EntityInterfaces = HYPERDRIVE.Interface.EntityInterfaces or {}

-- Interface configuration
HYPERDRIVE.Interface.Config = {
    MaxInteractionDistance = 200,
    EnableDistanceChecking = true,
    EnableSessionTracking = true,
    MaxConcurrentSessions = 10,
    EnableFeedbackMessages = true,
    EnableSoundFeedback = true,
    EnableVisualFeedback = true,
    InterfaceTimeout = 300,
    LogInterfaceUsage = false,
    EnablePermissionChecks = false,
    DefaultPermissionLevel = "user"
}

-- Interface validation function
function HYPERDRIVE.Interface.ValidateInteraction(entity, player, options)
    if not IsValid(entity) or not IsValid(player) or not player:IsPlayer() then
        return false, "Invalid entity or player"
    end

    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or HYPERDRIVE.Interface.Config
    options = options or {}

    -- Check if USE key interfaces are enabled
    if not config.EnableUSEKeyInterfaces then
        return false, "Interface access is disabled"
    end

    -- Check distance
    local maxDistance = options.maxDistance or config.MaxInteractionDistance or 200
    if config.EnableDistanceChecking then
        local distance = entity:GetPos():Distance(player:GetPos())
        if distance > maxDistance then
            return false, "Too far away to access interface (max " .. maxDistance .. " units)"
        end
    end

    -- Check session limits
    if config.EnableSessionTracking then
        local activeSessions = HYPERDRIVE.Interface.ActiveSessions[player] or 0
        local maxSessions = config.MaxConcurrentSessions or 10
        if activeSessions >= maxSessions then
            return false, "Too many active interface sessions"
        end
    end

    -- Check permissions
    if config.EnablePermissionChecks and options.requiredPermission then
        if not HYPERDRIVE.Interface.CheckPermission(player, options.requiredPermission) then
            return false, "Insufficient permissions"
        end
    end

    return true, "Validation passed"
end

-- Permission checking function
function HYPERDRIVE.Interface.CheckPermission(player, requiredPermission)
    if not IsValid(player) then return false end
    
    -- Admin always has access
    if player:IsAdmin() or player:IsSuperAdmin() then return true end
    
    -- Default permission level check
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or HYPERDRIVE.Interface.Config
    local defaultLevel = config.DefaultPermissionLevel or "user"
    
    if requiredPermission == "user" then return true end
    if requiredPermission == "admin" then return player:IsAdmin() end
    if requiredPermission == "superadmin" then return player:IsSuperAdmin() end
    
    return false
end

-- Session management functions
function HYPERDRIVE.Interface.StartSession(entity, player, sessionType)
    if not IsValid(entity) or not IsValid(player) then return false end

    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or HYPERDRIVE.Interface.Config
    
    if config.EnableSessionTracking then
        HYPERDRIVE.Interface.ActiveSessions[player] = (HYPERDRIVE.Interface.ActiveSessions[player] or 0) + 1
        
        -- Log session start
        if config.LogInterfaceUsage then
            print("[Hyperdrive Interface] Session started: " .. player:Nick() .. " -> " .. entity:GetClass() .. " (" .. (sessionType or "unknown") .. ")")
        end
        
        -- Store session history
        table.insert(HYPERDRIVE.Interface.SessionHistory, {
            player = player,
            entity = entity,
            sessionType = sessionType or "unknown",
            startTime = CurTime(),
            endTime = nil
        })
    end
    
    return true
end

function HYPERDRIVE.Interface.EndSession(entity, player, sessionType)
    if not IsValid(player) then return false end

    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or HYPERDRIVE.Interface.Config
    
    if config.EnableSessionTracking then
        HYPERDRIVE.Interface.ActiveSessions[player] = math.max(0, (HYPERDRIVE.Interface.ActiveSessions[player] or 1) - 1)
        
        -- Log session end
        if config.LogInterfaceUsage then
            print("[Hyperdrive Interface] Session ended: " .. player:Nick() .. " -> " .. (IsValid(entity) and entity:GetClass() or "removed") .. " (" .. (sessionType or "unknown") .. ")")
        end
        
        -- Update session history
        for i = #HYPERDRIVE.Interface.SessionHistory, 1, -1 do
            local session = HYPERDRIVE.Interface.SessionHistory[i]
            if session.player == player and session.entity == entity and not session.endTime then
                session.endTime = CurTime()
                break
            end
        end
    end
    
    return true
end

-- Feedback system
function HYPERDRIVE.Interface.SendFeedback(player, message, messageType)
    if not IsValid(player) then return end

    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or HYPERDRIVE.Interface.Config
    
    if config.EnableFeedbackMessages then
        local prefix = "[Hyperdrive]"
        if messageType == "error" then
            prefix = "[Hyperdrive Error]"
        elseif messageType == "warning" then
            prefix = "[Hyperdrive Warning]"
        elseif messageType == "success" then
            prefix = "[Hyperdrive Success]"
        end
        
        player:ChatPrint(prefix .. " " .. message)
    end
    
    -- Sound feedback
    if config.EnableSoundFeedback then
        local sound = "buttons/button15.wav" -- Default sound
        if messageType == "error" then
            sound = "buttons/button10.wav"
        elseif messageType == "success" then
            sound = "buttons/button14.wav"
        end
        
        player:EmitSound(sound, 50, 100, 0.5)
    end
end

-- Interface registration system
function HYPERDRIVE.Interface.RegisterEntityInterface(entityClass, interfaceData)
    HYPERDRIVE.Interface.EntityInterfaces[entityClass] = interfaceData
    print("[Hyperdrive Interface] Registered interface for " .. entityClass)
end

-- Standard USE function wrapper
function HYPERDRIVE.Interface.CreateUSEFunction(entityClass, interfaceFunction, options)
    options = options or {}
    
    return function(self, activator, caller)
        local valid, message = HYPERDRIVE.Interface.ValidateInteraction(self, activator, options)
        
        if not valid then
            HYPERDRIVE.Interface.SendFeedback(activator, message, "error")
            return
        end
        
        -- Start session
        HYPERDRIVE.Interface.StartSession(self, activator, options.sessionType or entityClass)
        
        -- Call the actual interface function
        local success, result = pcall(interfaceFunction, self, activator, caller)
        
        if not success then
            HYPERDRIVE.Interface.SendFeedback(activator, "Interface error: " .. tostring(result), "error")
            HYPERDRIVE.Interface.EndSession(self, activator, options.sessionType or entityClass)
            return
        end
        
        -- Success feedback
        if options.successMessage then
            HYPERDRIVE.Interface.SendFeedback(activator, options.successMessage, "success")
        end
    end
end

-- Cleanup functions
function HYPERDRIVE.Interface.CleanupSessions()
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or HYPERDRIVE.Interface.Config
    local timeout = config.InterfaceTimeout or 300
    local currentTime = CurTime()
    
    -- Clean up old session history
    for i = #HYPERDRIVE.Interface.SessionHistory, 1, -1 do
        local session = HYPERDRIVE.Interface.SessionHistory[i]
        if session.endTime and (currentTime - session.endTime) > timeout then
            table.remove(HYPERDRIVE.Interface.SessionHistory, i)
        end
    end
    
    -- Clean up disconnected players
    for player, sessions in pairs(HYPERDRIVE.Interface.ActiveSessions) do
        if not IsValid(player) then
            HYPERDRIVE.Interface.ActiveSessions[player] = nil
        end
    end
end

-- Periodic cleanup
timer.Create("HyperdriveInterfaceCleanup", 60, 0, function()
    HYPERDRIVE.Interface.CleanupSessions()
end)

-- Player disconnect cleanup
hook.Add("PlayerDisconnected", "HyperdriveInterfaceCleanup", function(ply)
    HYPERDRIVE.Interface.ActiveSessions[ply] = nil
    
    -- End all active sessions for this player
    for i, session in ipairs(HYPERDRIVE.Interface.SessionHistory) do
        if session.player == ply and not session.endTime then
            session.endTime = CurTime()
        end
    end
end)

-- Console commands for debugging
concommand.Add("hyperdrive_interface_status", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then return end
    
    local target = IsValid(ply) and ply or nil
    local function printMsg(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    printMsg("=== Hyperdrive Interface System Status ===")
    
    local totalSessions = 0
    for player, sessions in pairs(HYPERDRIVE.Interface.ActiveSessions) do
        if IsValid(player) then
            totalSessions = totalSessions + sessions
            printMsg("• " .. player:Nick() .. ": " .. sessions .. " active sessions")
        end
    end
    
    printMsg("• Total Active Sessions: " .. totalSessions)
    printMsg("• Session History Entries: " .. #HYPERDRIVE.Interface.SessionHistory)
    printMsg("• Registered Interfaces: " .. table.Count(HYPERDRIVE.Interface.EntityInterfaces))
end)

print("[Hyperdrive] Interface System v2.1 loaded successfully!")
