-- Advanced Space Combat - Character Selection Server v1.0.0
-- Server-side character selection and player model management

print("[Advanced Space Combat] Character Selection Server v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.CharacterSelection = ASC.CharacterSelection or {}

-- Configuration
ASC.CharacterSelection.Config = {
    -- Valid player models (security check)
    ValidModels = {
        "models/player/alyx.mdl",
        "models/player/barney.mdl",
        "models/player/breen.mdl",
        "models/player/eli.mdl",
        "models/player/gman.mdl",
        "models/player/kleiner.mdl",
        "models/player/monk.mdl",
        "models/player/mossman.mdl"
    },
    
    -- Settings
    AllowModelChanges = true,
    SavePlayerModels = true,
    RequireAdminForCustomModels = false
}

-- Player model storage
ASC.CharacterSelection.PlayerModels = {}

-- Network strings
util.AddNetworkString("ASC_ChangePlayerModel")
util.AddNetworkString("ASC_PlayerModelChanged")

-- Validate model
function ASC.CharacterSelection.IsValidModel(model)
    return table.HasValue(ASC.CharacterSelection.Config.ValidModels, model)
end

-- Set player model
function ASC.CharacterSelection.SetPlayerModel(player, model)
    if not IsValid(player) then return false end
    if not ASC.CharacterSelection.IsValidModel(model) then
        print("[Advanced Space Combat] Invalid model rejected: " .. tostring(model))
        return false
    end
    
    -- Set the model
    player:SetModel(model)
    
    -- Store the model choice
    ASC.CharacterSelection.PlayerModels[player:SteamID()] = model
    
    -- Save to file if enabled
    if ASC.CharacterSelection.Config.SavePlayerModels then
        ASC.CharacterSelection.SavePlayerModel(player, model)
    end
    
    -- Notify other players
    net.Start("ASC_PlayerModelChanged")
    net.WriteEntity(player)
    net.WriteString(model)
    net.Broadcast()
    
    print("[Advanced Space Combat] Player " .. player:Name() .. " changed model to: " .. model)
    return true
end

-- Load player model from file
function ASC.CharacterSelection.LoadPlayerModel(player)
    if not IsValid(player) then return end
    
    local steamID = player:SteamID()
    local fileName = "asc_player_models/" .. string.gsub(steamID, ":", "_") .. ".txt"
    
    if file.Exists(fileName, "DATA") then
        local model = file.Read(fileName, "DATA")
        if model and ASC.CharacterSelection.IsValidModel(model) then
            ASC.CharacterSelection.PlayerModels[steamID] = model
            player:SetModel(model)
            print("[Advanced Space Combat] Loaded saved model for " .. player:Name() .. ": " .. model)
        end
    end
end

-- Save player model to file
function ASC.CharacterSelection.SavePlayerModel(player, model)
    if not IsValid(player) then return end
    
    local steamID = player:SteamID()
    local fileName = "asc_player_models/" .. string.gsub(steamID, ":", "_") .. ".txt"
    
    -- Create directory if it doesn't exist
    if not file.Exists("asc_player_models", "DATA") then
        file.CreateDir("asc_player_models")
    end
    
    -- Save model
    file.Write(fileName, model)
    print("[Advanced Space Combat] Saved model for " .. player:Name() .. ": " .. model)
end

-- Handle model change request
net.Receive("ASC_ChangePlayerModel", function(len, player)
    if not IsValid(player) then return end
    
    local model = net.ReadString()
    
    -- Check if model changes are allowed
    if not ASC.CharacterSelection.Config.AllowModelChanges then
        player:ChatPrint("[Advanced Space Combat] Model changes are currently disabled")
        return
    end
    
    -- Validate and set model
    if ASC.CharacterSelection.SetPlayerModel(player, model) then
        player:ChatPrint("[Advanced Space Combat] Character model changed successfully!")
        
        -- Czech translation if available
        if ASC.Czech and ASC.Czech.IsPlayerCzech and ASC.Czech.IsPlayerCzech(player) then
            player:ChatPrint("[Advanced Space Combat] Model postavy byl úspěšně změněn!")
        end
    else
        player:ChatPrint("[Advanced Space Combat] Invalid character model!")
        
        -- Czech translation if available
        if ASC.Czech and ASC.Czech.IsPlayerCzech and ASC.Czech.IsPlayerCzech(player) then
            player:ChatPrint("[Advanced Space Combat] Neplatný model postavy!")
        end
    end
end)

-- Player spawn hook
hook.Add("PlayerSpawn", "ASC_CharacterSelection_Spawn", function(player)
    -- Small delay to ensure player is fully spawned
    timer.Simple(0.1, function()
        if IsValid(player) then
            ASC.CharacterSelection.LoadPlayerModel(player)
        end
    end)
end)

-- Player initial spawn hook
hook.Add("PlayerInitialSpawn", "ASC_CharacterSelection_InitialSpawn", function(player)
    -- Load player's saved model
    timer.Simple(1, function()
        if IsValid(player) then
            ASC.CharacterSelection.LoadPlayerModel(player)
        end
    end)
end)

-- Console commands for admins
concommand.Add("asc_set_player_model", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Advanced Space Combat] Admin only command")
        return
    end
    
    if #args < 2 then
        local msg = "Usage: asc_set_player_model <player_name> <model_path>"
        if IsValid(ply) then
            ply:ChatPrint("[Advanced Space Combat] " .. msg)
        else
            print("[Advanced Space Combat] " .. msg)
        end
        return
    end
    
    local targetName = args[1]
    local model = args[2]
    
    -- Find player
    local targetPlayer = nil
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Name()), string.lower(targetName)) then
            targetPlayer = p
            break
        end
    end
    
    if not IsValid(targetPlayer) then
        local msg = "Player not found: " .. targetName
        if IsValid(ply) then
            ply:ChatPrint("[Advanced Space Combat] " .. msg)
        else
            print("[Advanced Space Combat] " .. msg)
        end
        return
    end
    
    -- Set model
    if ASC.CharacterSelection.SetPlayerModel(targetPlayer, model) then
        local msg = "Set " .. targetPlayer:Name() .. "'s model to: " .. model
        if IsValid(ply) then
            ply:ChatPrint("[Advanced Space Combat] " .. msg)
        else
            print("[Advanced Space Combat] " .. msg)
        end
        
        targetPlayer:ChatPrint("[Advanced Space Combat] Your character model was changed by an admin")
    else
        local msg = "Failed to set model (invalid model path)"
        if IsValid(ply) then
            ply:ChatPrint("[Advanced Space Combat] " .. msg)
        else
            print("[Advanced Space Combat] " .. msg)
        end
    end
end)

concommand.Add("asc_reset_player_model", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Advanced Space Combat] Admin only command")
        return
    end
    
    if #args < 1 then
        local msg = "Usage: asc_reset_player_model <player_name>"
        if IsValid(ply) then
            ply:ChatPrint("[Advanced Space Combat] " .. msg)
        else
            print("[Advanced Space Combat] " .. msg)
        end
        return
    end
    
    local targetName = args[1]
    
    -- Find player
    local targetPlayer = nil
    for _, p in ipairs(player.GetAll()) do
        if string.find(string.lower(p:Name()), string.lower(targetName)) then
            targetPlayer = p
            break
        end
    end
    
    if not IsValid(targetPlayer) then
        local msg = "Player not found: " .. targetName
        if IsValid(ply) then
            ply:ChatPrint("[Advanced Space Combat] " .. msg)
        else
            print("[Advanced Space Combat] " .. msg)
        end
        return
    end
    
    -- Reset to default model
    local defaultModel = "models/player/alyx.mdl"
    if ASC.CharacterSelection.SetPlayerModel(targetPlayer, defaultModel) then
        local msg = "Reset " .. targetPlayer:Name() .. "'s model to default"
        if IsValid(ply) then
            ply:ChatPrint("[Advanced Space Combat] " .. msg)
        else
            print("[Advanced Space Combat] " .. msg)
        end
        
        targetPlayer:ChatPrint("[Advanced Space Combat] Your character model was reset by an admin")
    end
end)

concommand.Add("asc_list_player_models", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Advanced Space Combat] Admin only command")
        return
    end
    
    local msg = "[Advanced Space Combat] Player Models:"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
    
    for _, p in ipairs(player.GetAll()) do
        local model = p:GetModel()
        local line = "• " .. p:Name() .. ": " .. model
        if IsValid(ply) then
            ply:ChatPrint(line)
        else
            print(line)
        end
    end
end)

print("[Advanced Space Combat] Character Selection Server loaded successfully!")
