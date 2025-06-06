--[[
    Advanced Space Combat - Czech Language Management Commands v1.0.0
    
    Comprehensive console commands for managing Czech language integration,
    testing, debugging, and configuration.
]]

-- Initialize Czech Commands namespace
ASC = ASC or {}
ASC.CzechCommands = ASC.CzechCommands or {}

-- Czech Commands Configuration
ASC.CzechCommands.Config = {
    AdminOnly = false,
    LogCommands = true,
    ShowHelp = true
}

-- Main Czech language management command
concommand.Add("aria_czech", function(ply, cmd, args)
    local action = args[1] or "help"
    local target = args[2]
    
    -- Log command usage
    if ASC.CzechCommands.Config.LogCommands then
        local playerName = IsValid(ply) and ply:Name() or "Console"
        print("[Czech Commands] " .. playerName .. " executed: aria_czech " .. table.concat(args, " "))
    end
    
    -- Helper function to send message
    local function sendMsg(message, isError)
        local prefix = isError and "[ASC Error] " or "[ASC] "
        if IsValid(ply) then
            ply:ChatPrint(prefix .. message)
        else
            print(prefix .. message)
        end
    end
    
    -- === AKCE PŘÍKAZŮ ===
    
    if action == "help" or action == "nápověda" then
        sendMsg("=== Advanced Space Combat - Czech Language Commands ===")
        sendMsg("aria_czech status - Show Czech language system status")
        sendMsg("aria_czech enable - Enable Czech language system")
        sendMsg("aria_czech disable - Disable Czech language system")
        sendMsg("aria_czech detect [player] - Detect language for player")
        sendMsg("aria_czech set [player] - Set Czech for player")
        sendMsg("aria_czech test [type] - Run Czech language tests")
        sendMsg("aria_czech validate - Validate Czech integration")
        sendMsg("aria_czech info - Show detailed system information")
        sendMsg("aria_czech reset - Reset Czech language settings")
        sendMsg("=== Česká nápověda ===")
        sendMsg("aria_czech stav - Zobrazit stav českého systému")
        sendMsg("aria_czech povolit - Povolit český jazyk")
        sendMsg("aria_czech zakázat - Zakázat český jazyk")
        
    elseif action == "status" or action == "stav" then
        sendMsg("=== Czech Language System Status ===")
        
        -- Czech system status
        local czechEnabled = ASC.Czech and ASC.Czech.Config and ASC.Czech.Config.Enabled
        sendMsg("Czech System: " .. (czechEnabled and "ENABLED ✓" or "DISABLED ✗"))
        
        -- AI integration status
        local aiIntegrated = ASC.AI and ASC.AI.Languages and ASC.AI.Languages.Database and ASC.AI.Languages.Database.czech
        sendMsg("AI Integration: " .. (aiIntegrated and "CONNECTED ✓" or "MISSING ✗"))
        
        -- Multilingual integration status
        local multiIntegrated = ASC.Multilingual and ASC.Multilingual.Core and ASC.Multilingual.Core.LocalizedStrings and ASC.Multilingual.Core.LocalizedStrings.cs
        sendMsg("Multilingual Integration: " .. (multiIntegrated and "CONNECTED ✓" or "MISSING ✗"))
        
        -- Auto-detection status
        local autoDetect = ASC.Czech and ASC.Czech.Config and ASC.Czech.Config.AutoSetLanguage
        sendMsg("Auto-Detection: " .. (autoDetect and "ENABLED ✓" or "DISABLED ✗"))
        
        -- Translation count
        local translationCount = ASC.Czech and ASC.Czech.Translations and table.Count(ASC.Czech.Translations) or 0
        sendMsg("Translations Available: " .. translationCount)
        
        -- Player count with Czech enabled
        local czechPlayers = 0
        for _, player in ipairs(player.GetAll()) do
            if IsValid(player) and ASC.Multilingual and ASC.Multilingual.Core then
                local lang = ASC.Multilingual.Core.GetPlayerLanguage(player)
                if lang == "cs" then
                    czechPlayers = czechPlayers + 1
                end
            end
        end
        sendMsg("Players with Czech: " .. czechPlayers .. "/" .. #player.GetAll())
        
    elseif action == "enable" or action == "povolit" then
        if ASC.Czech and ASC.Czech.SetEnabled then
            ASC.Czech.SetEnabled(true)
            if ASC.Czech.ApplyToAddon then
                ASC.Czech.ApplyToAddon()
            end
            sendMsg("Czech language system enabled! Český jazyk povolen! 🇨🇿")
        else
            sendMsg("Czech system not available!", true)
        end
        
    elseif action == "disable" or action == "zakázat" then
        if ASC.Czech and ASC.Czech.SetEnabled then
            ASC.Czech.SetEnabled(false)
            sendMsg("Czech language system disabled. Český jazyk zakázán.")
        else
            sendMsg("Czech system not available!", true)
        end
        
    elseif action == "detect" or action == "detekovat" then
        local targetPlayer = nil
        
        if target then
            -- Find player by name
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Name()) == string.lower(target) then
                    targetPlayer = p
                    break
                end
            end
        elseif IsValid(ply) then
            targetPlayer = ply
        end
        
        if targetPlayer then
            sendMsg("Detecting language for " .. targetPlayer:Name() .. "...")
            
            if ASC.Czech and ASC.Czech.DetectPlayerLanguage then
                local detected = ASC.Czech.DetectPlayerLanguage(targetPlayer)
                sendMsg("Detected language: " .. detected)
                
                if detected == "czech" or detected == "cs" then
                    sendMsg("Czech language detected! Applying Czech settings...")
                    if ASC.Czech.AutoDetectAndSetLanguage then
                        ASC.Czech.AutoDetectAndSetLanguage(targetPlayer)
                    end
                end
            else
                sendMsg("Language detection not available!", true)
            end
        else
            sendMsg("Player not found: " .. (target or "none"), true)
        end
        
    elseif action == "set" or action == "nastav" then
        local targetPlayer = nil
        
        if target then
            for _, p in ipairs(player.GetAll()) do
                if string.lower(p:Name()) == string.lower(target) then
                    targetPlayer = p
                    break
                end
            end
        elseif IsValid(ply) then
            targetPlayer = ply
        end
        
        if targetPlayer then
            sendMsg("Setting Czech language for " .. targetPlayer:Name() .. "...")
            
            if ASC.Czech and ASC.Czech.SetPlayerLanguagePreference then
                local success = ASC.Czech.SetPlayerLanguagePreference(targetPlayer, "czech")
                if success then
                    sendMsg("Czech language set successfully! Český jazyk úspěšně nastaven! 🇨🇿")
                else
                    sendMsg("Failed to set Czech language!", true)
                end
            else
                sendMsg("Czech language setting not available!", true)
            end
        else
            sendMsg("Player not found: " .. (target or "none"), true)
        end
        
    elseif action == "test" or action == "testovat" then
        local testType = target or "all"
        
        sendMsg("Running Czech language tests: " .. testType)
        
        if ASC.CzechTesting and ASC.CzechTesting.RunAllTests then
            local success = ASC.CzechTesting.RunAllTests()
            sendMsg("Tests completed: " .. (success and "ALL PASSED ✓" or "SOME FAILED ✗"))
        else
            sendMsg("Testing system not available!", true)
        end
        
    elseif action == "validate" or action == "ověřit" then
        sendMsg("Validating Czech language integration...")
        
        if ASC.Czech and ASC.Czech.ValidateLanguageIntegrity then
            local valid = ASC.Czech.ValidateLanguageIntegrity()
            sendMsg("Validation completed: " .. (valid and "ALL SYSTEMS OK ✓" or "ISSUES FOUND ✗"))
        else
            sendMsg("Validation system not available!", true)
        end
        
    elseif action == "info" or action == "informace" then
        sendMsg("=== Detailed Czech Language Information ===")
        
        -- System versions
        sendMsg("Czech Localization: v2.0.0")
        sendMsg("AI Integration: " .. (ASC.AI and "Available" or "Not Available"))
        sendMsg("Multilingual System: " .. (ASC.Multilingual and "Available" or "Not Available"))
        sendMsg("Auto-Detection: " .. (ASC.CzechDetection and "Available" or "Not Available"))
        sendMsg("Testing Framework: " .. (ASC.CzechTesting and "Available" or "Not Available"))
        
        -- Configuration details
        if ASC.Czech and ASC.Czech.Config then
            sendMsg("=== Configuration ===")
            for key, value in pairs(ASC.Czech.Config) do
                sendMsg(key .. ": " .. tostring(value))
            end
        end
        
    elseif action == "reset" or action == "resetovat" then
        sendMsg("Resetting Czech language settings...")
        
        -- Reset all Czech settings
        if ASC.Czech then
            if ASC.Czech.Config then
                ASC.Czech.Config.Enabled = true
                ASC.Czech.Config.AutoSetLanguage = true
                ASC.Czech.Config.AutoDetect = true
            end
            
            if ASC.Czech.IntegrateWithAllSystems then
                ASC.Czech.IntegrateWithAllSystems()
            end
        end
        
        sendMsg("Czech language settings reset to defaults.")
        
    else
        sendMsg("Unknown action: " .. action, true)
        sendMsg("Use 'aria_czech help' for available commands.")
    end
end)

-- Quick Czech enable command
concommand.Add("aria_czech_enable", function(ply, cmd, args)
    RunConsoleCommand("aria_czech", "enable")
end)

-- Quick Czech status command
concommand.Add("aria_czech_status", function(ply, cmd, args)
    RunConsoleCommand("aria_czech", "status")
end)

-- Quick Czech test command
concommand.Add("aria_czech_test", function(ply, cmd, args)
    RunConsoleCommand("aria_czech", "test")
end)

print("[Advanced Space Combat] Czech Language Management Commands v1.0.0 Loaded")
