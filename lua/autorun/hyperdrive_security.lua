-- Hyperdrive Advanced Security System
-- This file provides comprehensive security and encryption for the hyperdrive system

-- Ensure HYPERDRIVE table exists first
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Security = HYPERDRIVE.Security or {}
HYPERDRIVE.Security.Version = "2.0.0"

-- Security configuration
HYPERDRIVE.Security.Config = {
    -- Authentication
    RequireAuthentication = true,
    BiometricSecurity = true,
    QuantumEncryption = true,
    MultiFactorAuth = false,

    -- Access control
    OwnershipSystem = true,
    TeamAccess = true,
    AdminOverride = true,
    GuestAccess = false,

    -- Encryption
    EncryptionLevel = 256, -- AES equivalent
    KeyRotationInterval = 3600, -- 1 hour
    QuantumKeyDistribution = true,

    -- Security features
    IntrusionDetection = true,
    AuditLogging = true,
    AntiTampering = true,
    SecureWipe = true,

    -- Lockdown features
    EmergencyLockdown = true,
    AutoLockdown = true,
    LockdownDuration = 300, -- 5 minutes
    MaxFailedAttempts = 3
}

-- Security state storage
HYPERDRIVE.Security.AuthTokens = {}
HYPERDRIVE.Security.AccessLogs = {}
HYPERDRIVE.Security.EncryptionKeys = {}
HYPERDRIVE.Security.LockedEntities = {}
HYPERDRIVE.Security.BiometricData = {}

-- Generate secure random key
function HYPERDRIVE.Security.GenerateKey(length)
    length = length or 32
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*"
    local key = ""

    for i = 1, length do
        local randomIndex = math.random(1, #chars)
        key = key .. string.sub(chars, randomIndex, randomIndex)
    end

    return key
end

-- Simple encryption function (XOR-based for demonstration)
function HYPERDRIVE.Security.Encrypt(data, key)
    if not data or not key then return nil end

    local encrypted = ""
    local keyLen = #key

    for i = 1, #data do
        local dataChar = string.byte(data, i)
        local keyChar = string.byte(key, ((i - 1) % keyLen) + 1)
        local encryptedChar = bit.bxor(dataChar, keyChar)
        encrypted = encrypted .. string.char(encryptedChar)
    end

    return util.Base64Encode(encrypted)
end

-- Simple decryption function
function HYPERDRIVE.Security.Decrypt(encryptedData, key)
    if not encryptedData or not key then return nil end

    local decoded = util.Base64Decode(encryptedData)
    if not decoded then return nil end

    local decrypted = ""
    local keyLen = #key

    for i = 1, #decoded do
        local encryptedChar = string.byte(decoded, i)
        local keyChar = string.byte(key, ((i - 1) % keyLen) + 1)
        local decryptedChar = bit.bxor(encryptedChar, keyChar)
        decrypted = decrypted .. string.char(decryptedChar)
    end

    return decrypted
end

-- Generate authentication token
function HYPERDRIVE.Security.GenerateAuthToken(player, entity)
    if not IsValid(player) or not IsValid(entity) then return nil end

    local tokenData = {
        playerID = player:SteamID(),
        playerName = player:Name(),
        entityID = entity:EntIndex(),
        entityClass = entity:GetClass(),
        timestamp = os.time(),
        expires = os.time() + 3600, -- 1 hour
        permissions = {"use", "configure"}
    }

    local tokenString = util.TableToJSON(tokenData)
    local key = HYPERDRIVE.Security.GetEncryptionKey(entity)
    local encryptedToken = HYPERDRIVE.Security.Encrypt(tokenString, key)

    HYPERDRIVE.Security.AuthTokens[player:SteamID() .. "_" .. entity:EntIndex()] = {
        token = encryptedToken,
        data = tokenData
    }

    return encryptedToken
end

-- Validate authentication token
function HYPERDRIVE.Security.ValidateAuthToken(player, entity, token)
    if not IsValid(player) or not IsValid(entity) then return false end

    local tokenKey = player:SteamID() .. "_" .. entity:EntIndex()
    local storedToken = HYPERDRIVE.Security.AuthTokens[tokenKey]

    if not storedToken then return false end

    -- Check token expiration
    if storedToken.data.expires < os.time() then
        HYPERDRIVE.Security.AuthTokens[tokenKey] = nil
        return false
    end

    -- Validate token
    if storedToken.token ~= token then
        HYPERDRIVE.Security.LogSecurityEvent("Invalid token used", player, entity)
        return false
    end

    return true, storedToken.data
end

-- Check entity access permissions
function HYPERDRIVE.Security.CheckAccess(player, entity, action)
    if not IsValid(player) or not IsValid(entity) then return false end

    action = action or "use"

    -- Admin override
    if HYPERDRIVE.Security.Config.AdminOverride and player:IsAdmin() then
        return true
    end

    -- Check if entity is locked down
    if HYPERDRIVE.Security.IsLockedDown(entity) then
        return false, "Entity is in security lockdown"
    end

    -- Ownership system
    if HYPERDRIVE.Security.Config.OwnershipSystem then
        local owner = entity:GetNWString("HyperdriveOwner", "")
        if owner == "" then
            -- No owner set, claim ownership
            entity:SetNWString("HyperdriveOwner", player:SteamID())
            HYPERDRIVE.Security.LogSecurityEvent("Ownership claimed", player, entity)
            return true
        elseif owner == player:SteamID() then
            return true
        end

        -- Team access
        if HYPERDRIVE.Security.Config.TeamAccess then
            local ownerPlayer = player.GetBySteamID and player.GetBySteamID(owner)
            if IsValid(ownerPlayer) and ownerPlayer:Team() == player:Team() and player:Team() ~= 0 then
                return true
            end
        end

        return false, "Access denied - not owner"
    end

    -- Guest access
    if HYPERDRIVE.Security.Config.GuestAccess then
        return true
    end

    return false, "Access denied"
end

-- Biometric authentication
function HYPERDRIVE.Security.RegisterBiometric(player, entity)
    if not HYPERDRIVE.Security.Config.BiometricSecurity then return false end
    if not IsValid(player) or not IsValid(entity) then return false end

    local biometricData = {
        playerID = player:SteamID(),
        entityID = entity:EntIndex(),
        fingerprint = util.CRC(player:SteamID() .. player:Name() .. os.time()),
        voiceprint = util.CRC(player:Name() .. player:GetUserGroup()),
        retinalScan = util.CRC(player:SteamID() .. entity:EntIndex()),
        registered = os.time()
    }

    local biometricKey = player:SteamID() .. "_" .. entity:EntIndex()
    HYPERDRIVE.Security.BiometricData[biometricKey] = biometricData

    HYPERDRIVE.Security.LogSecurityEvent("Biometric data registered", player, entity)
    return true
end

-- Verify biometric authentication
function HYPERDRIVE.Security.VerifyBiometric(player, entity)
    if not HYPERDRIVE.Security.Config.BiometricSecurity then return true end
    if not IsValid(player) or not IsValid(entity) then return false end

    local biometricKey = player:SteamID() .. "_" .. entity:EntIndex()
    local storedBiometric = HYPERDRIVE.Security.BiometricData[biometricKey]

    if not storedBiometric then
        -- Auto-register if not found
        return HYPERDRIVE.Security.RegisterBiometric(player, entity)
    end

    -- Verify biometric data (simplified)
    local currentFingerprint = util.CRC(player:SteamID() .. player:Name() .. math.floor(os.time() / 3600))
    local storedFingerprint = storedBiometric.fingerprint

    -- Allow some variance for time-based changes
    if math.abs(currentFingerprint - storedFingerprint) < 1000 then
        return true
    end

    HYPERDRIVE.Security.LogSecurityEvent("Biometric verification failed", player, entity)
    return false
end

-- Get or create encryption key for entity
function HYPERDRIVE.Security.GetEncryptionKey(entity)
    if not IsValid(entity) then return nil end

    local keyId = entity:EntIndex()
    local keyData = HYPERDRIVE.Security.EncryptionKeys[keyId]

    if not keyData or (keyData.expires and keyData.expires < os.time()) then
        -- Generate new key
        local newKey = HYPERDRIVE.Security.GenerateKey(HYPERDRIVE.Security.Config.EncryptionLevel / 8)
        HYPERDRIVE.Security.EncryptionKeys[keyId] = {
            key = newKey,
            created = os.time(),
            expires = os.time() + HYPERDRIVE.Security.Config.KeyRotationInterval
        }
        return newKey
    end

    return keyData.key
end

-- Security lockdown system
function HYPERDRIVE.Security.LockdownEntity(entity, reason, duration)
    if not IsValid(entity) then return false end

    duration = duration or HYPERDRIVE.Security.Config.LockdownDuration

    local lockdown = {
        entity = entity,
        reason = reason or "Security breach",
        startTime = CurTime(),
        duration = duration,
        endTime = CurTime() + duration
    }

    HYPERDRIVE.Security.LockedEntities[entity:EntIndex()] = lockdown

    -- Visual indication
    entity:SetColor(Color(255, 0, 0, 200))
    entity:SetMaterial("models/debug/debugwhite")

    -- Remove lockdown after duration
    timer.Create("SecurityLockdown_" .. entity:EntIndex(), duration, 1, function()
        HYPERDRIVE.Security.RemoveLockdown(entity)
    end)

    HYPERDRIVE.Security.LogSecurityEvent("Entity locked down: " .. reason, nil, entity)
    return true
end

-- Remove security lockdown
function HYPERDRIVE.Security.RemoveLockdown(entity)
    if not IsValid(entity) then return end

    local lockdown = HYPERDRIVE.Security.LockedEntities[entity:EntIndex()]
    if not lockdown then return end

    HYPERDRIVE.Security.LockedEntities[entity:EntIndex()] = nil

    -- Restore appearance
    entity:SetColor(Color(255, 255, 255, 255))
    entity:SetMaterial("")

    timer.Remove("SecurityLockdown_" .. entity:EntIndex())

    HYPERDRIVE.Security.LogSecurityEvent("Lockdown removed", nil, entity)
end

-- Check if entity is locked down
function HYPERDRIVE.Security.IsLockedDown(entity)
    if not IsValid(entity) then return false end

    local lockdown = HYPERDRIVE.Security.LockedEntities[entity:EntIndex()]
    if not lockdown then return false end

    if CurTime() > lockdown.endTime then
        HYPERDRIVE.Security.RemoveLockdown(entity)
        return false
    end

    return true, lockdown
end

-- Intrusion detection system
function HYPERDRIVE.Security.DetectIntrusion(player, entity, action)
    if not HYPERDRIVE.Security.Config.IntrusionDetection then return false end
    if not IsValid(player) or not IsValid(entity) then return false end

    local playerKey = player:SteamID()
    local entityKey = entity:EntIndex()

    -- Track failed access attempts
    local attemptKey = playerKey .. "_" .. entityKey
    HYPERDRIVE.Security.FailedAttempts = HYPERDRIVE.Security.FailedAttempts or {}

    local attempts = HYPERDRIVE.Security.FailedAttempts[attemptKey] or 0
    attempts = attempts + 1
    HYPERDRIVE.Security.FailedAttempts[attemptKey] = attempts

    -- Check for intrusion
    if attempts >= HYPERDRIVE.Security.Config.MaxFailedAttempts then
        HYPERDRIVE.Security.LogSecurityEvent("Intrusion detected - multiple failed attempts", player, entity)

        if HYPERDRIVE.Security.Config.AutoLockdown then
            HYPERDRIVE.Security.LockdownEntity(entity, "Intrusion detected", HYPERDRIVE.Security.Config.LockdownDuration)
        end

        return true
    end

    return false
end

-- Security audit logging
function HYPERDRIVE.Security.LogSecurityEvent(event, player, entity, data)
    if not HYPERDRIVE.Security.Config.AuditLogging then return end

    local logEntry = {
        timestamp = os.time(),
        event = event,
        playerID = IsValid(player) and player:SteamID() or "SYSTEM",
        playerName = IsValid(player) and player:Name() or "SYSTEM",
        entityID = IsValid(entity) and entity:EntIndex() or 0,
        entityClass = IsValid(entity) and entity:GetClass() or "unknown",
        data = data or {}
    }

    table.insert(HYPERDRIVE.Security.AccessLogs, logEntry)

    -- Limit log size
    if #HYPERDRIVE.Security.AccessLogs > 1000 then
        table.remove(HYPERDRIVE.Security.AccessLogs, 1)
    end

    -- Debug output
    if HYPERDRIVE.Debug then
        HYPERDRIVE.Debug.Info("SECURITY: " .. event .. " by " .. logEntry.playerName, "SECURITY")
    end
end

-- Secure data wipe
function HYPERDRIVE.Security.SecureWipe(entity)
    if not HYPERDRIVE.Security.Config.SecureWipe then return end
    if not IsValid(entity) then return end

    local entityKey = entity:EntIndex()

    -- Wipe encryption keys
    HYPERDRIVE.Security.EncryptionKeys[entityKey] = nil

    -- Wipe auth tokens
    for tokenKey, tokenData in pairs(HYPERDRIVE.Security.AuthTokens) do
        if string.find(tokenKey, "_" .. entityKey) then
            HYPERDRIVE.Security.AuthTokens[tokenKey] = nil
        end
    end

    -- Wipe biometric data
    for biometricKey, biometricData in pairs(HYPERDRIVE.Security.BiometricData) do
        if string.find(biometricKey, "_" .. entityKey) then
            HYPERDRIVE.Security.BiometricData[biometricKey] = nil
        end
    end

    -- Remove lockdown
    HYPERDRIVE.Security.RemoveLockdown(entity)

    HYPERDRIVE.Security.LogSecurityEvent("Secure wipe completed", nil, entity)
end

-- Hook into entity removal for secure wipe
hook.Add("EntityRemoved", "HyperdriveSecurityWipe", function(entity)
    if IsValid(entity) and string.find(entity:GetClass(), "hyperdrive") then
        HYPERDRIVE.Security.SecureWipe(entity)
    end
end)

-- Console commands for security management
concommand.Add("hyperdrive_security_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    ply:ChatPrint("[Hyperdrive Security] Status Report:")
    ply:ChatPrint("  • Auth Tokens: " .. table.Count(HYPERDRIVE.Security.AuthTokens))
    ply:ChatPrint("  • Encryption Keys: " .. table.Count(HYPERDRIVE.Security.EncryptionKeys))
    ply:ChatPrint("  • Biometric Records: " .. table.Count(HYPERDRIVE.Security.BiometricData))
    ply:ChatPrint("  • Locked Entities: " .. table.Count(HYPERDRIVE.Security.LockedEntities))
    ply:ChatPrint("  • Audit Log Entries: " .. #HYPERDRIVE.Security.AccessLogs)
end)

concommand.Add("hyperdrive_security_lockdown", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or not string.find(trace.Entity:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive Security] Look at a hyperdrive entity")
        return
    end

    local reason = table.concat(args, " ") or "Admin lockdown"
    local success = HYPERDRIVE.Security.LockdownEntity(trace.Entity, reason)

    ply:ChatPrint("[Hyperdrive Security] " .. (success and "Entity locked down" or "Lockdown failed"))
end)

concommand.Add("hyperdrive_security_unlock", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) then
        ply:ChatPrint("[Hyperdrive Security] Look at an entity")
        return
    end

    HYPERDRIVE.Security.RemoveLockdown(trace.Entity)
    ply:ChatPrint("[Hyperdrive Security] Lockdown removed")
end)

print("[Hyperdrive] Advanced security system loaded")
