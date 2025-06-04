--[[
    Advanced Space Combat - Czech Language Auto-Detection System v3.0.0
    
    Automatically detects Czech language preference through multiple methods
    and sets appropriate language settings for the Advanced Space Combat addon.
]]

-- Initialize Czech Auto-Detection namespace
ASC = ASC or {}
ASC.CzechDetection = ASC.CzechDetection or {}

-- Czech Detection Configuration
ASC.CzechDetection.Config = {
    -- Core Settings
    Enabled = true,
    AutoSetLanguage = true,
    SavePreference = true,
    
    -- Detection Methods
    DetectionMethods = {
        SteamLanguage = true,
        SystemLocale = true,
        GMODLanguage = true,
        ChatAnalysis = true,
        ManualOverride = true
    },
    
    -- Chat Analysis Settings
    ChatAnalysis = {
        Enabled = true,
        MinMessages = 3,
        AnalysisWindow = 5, -- Number of recent messages to analyze
        CzechThreshold = 0.6, -- 60% Czech content required
        CzechWords = {
            -- Common Czech words and phrases
            "ahoj", "dobrý", "den", "děkuji", "prosím", "ano", "ne", "jak", "se", "máš",
            "co", "kde", "kdy", "proč", "kdo", "který", "jaký", "můžu", "chci", "potřebuji",
            "pomoc", "help", "nápověda", "česky", "čeština", "loď", "zbraň", "hyperpohon",
            "štít", "energie", "systém", "ovládání", "let", "navigace", "cíl", "útok"
        },
        CzechCharacters = {
            "á", "č", "ď", "é", "ě", "í", "ň", "ó", "ř", "š", "ť", "ú", "ů", "ý", "ž"
        }
    },
    
    -- Language Preference Storage
    PreferenceFile = "asc_language_preferences.txt",
    
    -- Detection Confidence Levels
    ConfidenceLevels = {
        STEAM_LANGUAGE = 0.9,
        SYSTEM_LOCALE = 0.8,
        GMOD_LANGUAGE = 0.7,
        CHAT_ANALYSIS = 0.6,
        MANUAL_OVERRIDE = 1.0
    }
}

-- Czech Detection Core System
ASC.CzechDetection.Core = {
    -- Player language data
    PlayerLanguages = {},
    
    -- Chat analysis data
    ChatHistory = {},
    
    -- Detection results
    DetectionResults = {},
    
    -- Initialize Czech detection system
    Initialize = function()
        print("[Czech Detection] Initializing Czech language auto-detection system...")
        
        -- Load saved preferences
        ASC.CzechDetection.Core.LoadLanguagePreferences()
        
        -- Set up detection hooks
        ASC.CzechDetection.Core.SetupDetectionHooks()
        
        -- Start detection for existing players
        for _, player in ipairs(player.GetAll()) do
            ASC.CzechDetection.Core.DetectPlayerLanguage(player)
        end
        
        print("[Czech Detection] Czech auto-detection system initialized")
    end,
    
    -- Set up detection hooks
    SetupDetectionHooks = function()
        -- Player spawn hook
        hook.Add("PlayerSpawn", "ASC_CzechDetection_PlayerSpawn", function(player)
            timer.Simple(2, function() -- Delay to allow player data to load
                if IsValid(player) then
                    ASC.CzechDetection.Core.DetectPlayerLanguage(player)
                end
            end)
        end)
        
        -- Chat analysis hook
        if ASC.CzechDetection.Config.ChatAnalysis.Enabled then
            hook.Add("PlayerSay", "ASC_CzechDetection_ChatAnalysis", function(player, text)
                ASC.CzechDetection.Core.AnalyzeChatMessage(player, text)
            end)
        end
        
        -- Player disconnect cleanup
        hook.Add("PlayerDisconnected", "ASC_CzechDetection_Cleanup", function(player)
            local steamID = player:SteamID()
            ASC.CzechDetection.Core.ChatHistory[steamID] = nil
            ASC.CzechDetection.Core.DetectionResults[steamID] = nil
        end)
    end,
    
    -- Detect player language using multiple methods
    DetectPlayerLanguage = function(player)
        if not IsValid(player) then return end
        
        local steamID = player:SteamID()
        local detectionData = {
            player = player,
            steamID = steamID,
            methods = {},
            confidence = 0,
            finalLanguage = "en",
            detectionTime = CurTime()
        }
        
        -- Method 1: Steam Language Detection
        if ASC.CzechDetection.Config.DetectionMethods.SteamLanguage then
            local steamLang = ASC.CzechDetection.Core.DetectSteamLanguage(player)
            if steamLang then
                detectionData.methods.steam = {
                    language = steamLang,
                    confidence = ASC.CzechDetection.Config.ConfidenceLevels.STEAM_LANGUAGE
                }
            end
        end
        
        -- Method 2: System Locale Detection
        if ASC.CzechDetection.Config.DetectionMethods.SystemLocale then
            local systemLang = ASC.CzechDetection.Core.DetectSystemLocale(player)
            if systemLang then
                detectionData.methods.system = {
                    language = systemLang,
                    confidence = ASC.CzechDetection.Config.ConfidenceLevels.SYSTEM_LOCALE
                }
            end
        end
        
        -- Method 3: GMod Language Detection
        if ASC.CzechDetection.Config.DetectionMethods.GMODLanguage then
            local gmodLang = ASC.CzechDetection.Core.DetectGMODLanguage(player)
            if gmodLang then
                detectionData.methods.gmod = {
                    language = gmodLang,
                    confidence = ASC.CzechDetection.Config.ConfidenceLevels.GMOD_LANGUAGE
                }
            end
        end
        
        -- Method 4: Check saved preferences
        local savedLang = ASC.CzechDetection.Core.GetSavedLanguagePreference(steamID)
        if savedLang then
            detectionData.methods.saved = {
                language = savedLang,
                confidence = ASC.CzechDetection.Config.ConfidenceLevels.MANUAL_OVERRIDE
            }
        end
        
        -- Determine final language based on highest confidence
        local highestConfidence = 0
        for method, data in pairs(detectionData.methods) do
            if data.confidence > highestConfidence then
                highestConfidence = data.confidence
                detectionData.finalLanguage = data.language
                detectionData.confidence = data.confidence
            end
        end
        
        -- Store detection results
        ASC.CzechDetection.Core.DetectionResults[steamID] = detectionData
        
        -- Apply language setting if Czech detected
        if detectionData.finalLanguage == "cs" or detectionData.finalLanguage == "czech" then
            ASC.CzechDetection.Core.SetPlayerLanguage(player, "cs")
            
            -- Notify player in Czech
            timer.Simple(3, function()
                if IsValid(player) then
                    player:ChatPrint("[Advanced Space Combat] Detekován český jazyk - automaticky nastaveno")
                    player:ChatPrint("[Advanced Space Combat] Czech language detected - automatically set")
                end
            end)
        else
            ASC.CzechDetection.Core.SetPlayerLanguage(player, "en")
        end
        
        print("[Czech Detection] Language detection for " .. player:Name() .. ": " .. detectionData.finalLanguage .. " (confidence: " .. math.floor(detectionData.confidence * 100) .. "%)")
    end,
    
    -- Detect Steam language
    DetectSteamLanguage = function(player)
        -- This would require Steam API integration
        -- For now, we'll use a placeholder that checks player's Steam profile
        -- In a real implementation, this would query Steam's language setting
        
        -- Placeholder: Check if player has Czech in their name or profile
        local name = player:Name():lower()
        if string.find(name, "cz") or string.find(name, "czech") or string.find(name, "česk") then
            return "cs"
        end
        
        return nil
    end,
    
    -- Detect system locale
    DetectSystemLocale = function(player)
        -- This would require client-side detection
        -- For now, we'll use server-side heuristics
        
        -- Check player's IP geolocation (if available)
        local ip = player:IPAddress()
        if ip then
            -- Placeholder for IP-based country detection
            -- In a real implementation, this would use a GeoIP service
        end
        
        return nil
    end,
    
    -- Detect GMod language setting
    DetectGMODLanguage = function(player)
        -- Check GMod's language setting
        if CLIENT then
            local gmodLang = GetConVar("gmod_language")
            if gmodLang then
                local lang = gmodLang:GetString()
                if lang == "cs" or lang == "czech" then
                    return "cs"
                end
            end
        end
        
        return nil
    end,
    
    -- Analyze chat message for Czech content
    AnalyzeChatMessage = function(player, text)
        if not IsValid(player) or not text or text == "" then return end
        
        local steamID = player:SteamID()
        
        -- Initialize chat history for player
        if not ASC.CzechDetection.Core.ChatHistory[steamID] then
            ASC.CzechDetection.Core.ChatHistory[steamID] = {}
        end
        
        -- Add message to history
        table.insert(ASC.CzechDetection.Core.ChatHistory[steamID], {
            text = text:lower(),
            time = CurTime()
        })
        
        -- Keep only recent messages
        local history = ASC.CzechDetection.Core.ChatHistory[steamID]
        while #history > ASC.CzechDetection.Config.ChatAnalysis.AnalysisWindow do
            table.remove(history, 1)
        end
        
        -- Analyze if we have enough messages
        if #history >= ASC.CzechDetection.Config.ChatAnalysis.MinMessages then
            local czechScore = ASC.CzechDetection.Core.CalculateCzechScore(history)
            
            if czechScore >= ASC.CzechDetection.Config.ChatAnalysis.CzechThreshold then
                -- Czech detected through chat analysis
                local detectionData = ASC.CzechDetection.Core.DetectionResults[steamID] or {}
                detectionData.methods = detectionData.methods or {}
                detectionData.methods.chat = {
                    language = "cs",
                    confidence = ASC.CzechDetection.Config.ConfidenceLevels.CHAT_ANALYSIS,
                    score = czechScore
                }
                
                -- Update final language if chat analysis has higher confidence
                if not detectionData.finalLanguage or detectionData.confidence < ASC.CzechDetection.Config.ConfidenceLevels.CHAT_ANALYSIS then
                    detectionData.finalLanguage = "cs"
                    detectionData.confidence = ASC.CzechDetection.Config.ConfidenceLevels.CHAT_ANALYSIS
                    
                    ASC.CzechDetection.Core.SetPlayerLanguage(player, "cs")
                    
                    player:ChatPrint("[Advanced Space Combat] Detekován český jazyk v chatu - přepínám na češtinu")
                    player:ChatPrint("[Advanced Space Combat] Czech language detected in chat - switching to Czech")
                end
                
                ASC.CzechDetection.Core.DetectionResults[steamID] = detectionData
                
                print("[Czech Detection] Czech detected in chat for " .. player:Name() .. " (score: " .. math.floor(czechScore * 100) .. "%)")
            end
        end
    end,
    
    -- Calculate Czech score for chat messages
    CalculateCzechScore = function(messages)
        local totalWords = 0
        local czechWords = 0
        local czechChars = 0
        local totalChars = 0
        
        for _, message in ipairs(messages) do
            local text = message.text
            local words = string.Split(text, " ")
            
            for _, word in ipairs(words) do
                if word ~= "" then
                    totalWords = totalWords + 1
                    
                    -- Check for Czech words
                    for _, czechWord in ipairs(ASC.CzechDetection.Config.ChatAnalysis.CzechWords) do
                        if string.find(word, czechWord) then
                            czechWords = czechWords + 1
                            break
                        end
                    end
                end
            end
            
            -- Check for Czech characters
            for i = 1, #text do
                local char = string.sub(text, i, i)
                totalChars = totalChars + 1
                
                for _, czechChar in ipairs(ASC.CzechDetection.Config.ChatAnalysis.CzechCharacters) do
                    if char == czechChar then
                        czechChars = czechChars + 1
                        break
                    end
                end
            end
        end
        
        -- Calculate score based on Czech words and characters
        local wordScore = totalWords > 0 and (czechWords / totalWords) or 0
        local charScore = totalChars > 0 and (czechChars / totalChars) or 0
        
        -- Weighted average (words are more important than characters)
        return (wordScore * 0.7) + (charScore * 0.3)
    end,
    
    -- Set player language preference
    SetPlayerLanguage = function(player, language)
        if not IsValid(player) then return end
        
        local steamID = player:SteamID()
        ASC.CzechDetection.Core.PlayerLanguages[steamID] = language
        
        -- Save preference if enabled
        if ASC.CzechDetection.Config.SavePreference then
            ASC.CzechDetection.Core.SaveLanguagePreference(steamID, language)
        end
        
        -- Apply language to ASC systems
        if ASC.Multilingual and ASC.Multilingual.Core then
            ASC.Multilingual.Core.SetPlayerLanguage(player, language)
        end
        
        -- Apply to Czech localization system
        if ASC.Czech and ASC.Czech.SetPlayerLanguage then
            ASC.Czech.SetPlayerLanguage(player, language)
        end
    end,
    
    -- Get player language
    GetPlayerLanguage = function(player)
        if not IsValid(player) then return "en" end
        
        local steamID = player:SteamID()
        return ASC.CzechDetection.Core.PlayerLanguages[steamID] or "en"
    end,
    
    -- Save language preference to file
    SaveLanguagePreference = function(steamID, language)
        local preferences = ASC.CzechDetection.Core.LoadLanguagePreferences()
        preferences[steamID] = language
        
        local data = util.TableToJSON(preferences)
        file.Write(ASC.CzechDetection.Config.PreferenceFile, data)
    end,
    
    -- Load language preferences from file
    LoadLanguagePreferences = function()
        if file.Exists(ASC.CzechDetection.Config.PreferenceFile, "DATA") then
            local data = file.Read(ASC.CzechDetection.Config.PreferenceFile, "DATA")
            local preferences = util.JSONToTable(data)
            
            if preferences then
                for steamID, language in pairs(preferences) do
                    ASC.CzechDetection.Core.PlayerLanguages[steamID] = language
                end
                return preferences
            end
        end
        
        return {}
    end,
    
    -- Get saved language preference
    GetSavedLanguagePreference = function(steamID)
        return ASC.CzechDetection.Core.PlayerLanguages[steamID]
    end,
    
    -- Manual language override
    SetManualLanguageOverride = function(player, language)
        if not IsValid(player) then return false end
        
        local steamID = player:SteamID()
        
        -- Update detection results
        local detectionData = ASC.CzechDetection.Core.DetectionResults[steamID] or {}
        detectionData.methods = detectionData.methods or {}
        detectionData.methods.manual = {
            language = language,
            confidence = ASC.CzechDetection.Config.ConfidenceLevels.MANUAL_OVERRIDE
        }
        detectionData.finalLanguage = language
        detectionData.confidence = ASC.CzechDetection.Config.ConfidenceLevels.MANUAL_OVERRIDE
        
        ASC.CzechDetection.Core.DetectionResults[steamID] = detectionData
        ASC.CzechDetection.Core.SetPlayerLanguage(player, language)
        
        print("[Czech Detection] Manual language override for " .. player:Name() .. ": " .. language)
        return true
    end
}

-- Console commands
concommand.Add("asc_set_language", function(ply, cmd, args)
    if not IsValid(ply) or not args[1] then return end
    
    local language = args[1]:lower()
    if language == "cs" or language == "czech" or language == "en" or language == "english" then
        ASC.CzechDetection.Core.SetManualLanguageOverride(ply, language == "cs" or language == "czech" and "cs" or "en")
        ply:ChatPrint("[Advanced Space Combat] Language set to: " .. (language == "cs" or language == "czech" and "Czech" or "English"))
    else
        ply:ChatPrint("[Advanced Space Combat] Usage: asc_set_language <cs|en>")
    end
end)

-- Initialize on addon load
hook.Add("Initialize", "ASC_CzechDetection_Init", function()
    ASC.CzechDetection.Core.Initialize()
end)
