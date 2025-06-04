--[[
    Advanced Space Combat - Multilingual System v3.0.0
    
    Comprehensive multilingual support with web-based translation
    for Czech and other languages, automatic language detection,
    and localized responses.
]]

-- Initialize Multilingual System namespace
ASC = ASC or {}
ASC.Multilingual = ASC.Multilingual or {}

-- Multilingual Configuration
ASC.Multilingual.Config = {
    -- Core Settings
    Enabled = true,
    DefaultLanguage = "en",
    AutoDetect = true,
    WebTranslation = true,
    CacheTranslations = true,
    
    -- Translation Services
    TranslationServices = {
        {
            name = "Google Translate",
            url = "https://translate.googleapis.com/translate_a/single",
            enabled = true,
            priority = 1
        },
        {
            name = "LibreTranslate",
            url = "https://libretranslate.de/translate",
            enabled = true,
            priority = 2
        }
    },
    
    -- Supported Languages
    SupportedLanguages = {
        en = {name = "English", nativeName = "English", flag = "🇺🇸"},
        cs = {name = "Czech", nativeName = "Čeština", flag = "🇨🇿"},
        de = {name = "German", nativeName = "Deutsch", flag = "🇩🇪"},
        fr = {name = "French", nativeName = "Français", flag = "🇫🇷"},
        es = {name = "Spanish", nativeName = "Español", flag = "🇪🇸"},
        it = {name = "Italian", nativeName = "Italiano", flag = "🇮🇹"},
        pl = {name = "Polish", nativeName = "Polski", flag = "🇵🇱"},
        ru = {name = "Russian", nativeName = "Русский", flag = "🇷🇺"},
        sk = {name = "Slovak", nativeName = "Slovenčina", flag = "🇸🇰"},
        hu = {name = "Hungarian", nativeName = "Magyar", flag = "🇭🇺"},
        pt = {name = "Portuguese", nativeName = "Português", flag = "🇵🇹"},
        nl = {name = "Dutch", nativeName = "Nederlands", flag = "🇳🇱"},
        sv = {name = "Swedish", nativeName = "Svenska", flag = "🇸🇪"},
        da = {name = "Danish", nativeName = "Dansk", flag = "🇩🇰"},
        no = {name = "Norwegian", nativeName = "Norsk", flag = "🇳🇴"},
        fi = {name = "Finnish", nativeName = "Suomi", flag = "🇫🇮"},
        ja = {name = "Japanese", nativeName = "日本語", flag = "🇯🇵"},
        ko = {name = "Korean", nativeName = "한국어", flag = "🇰🇷"},
        zh = {name = "Chinese", nativeName = "中文", flag = "🇨🇳"}
    },
    
    -- Language Detection Patterns
    LanguagePatterns = {
        cs = {
            -- Basic words
            "jak", "kde", "co", "proč", "když", "ale", "nebo", "že", "být", "mít", "loď", "zbraň", "let",
            -- Extended Czech vocabulary
            "ahoj", "děkuji", "prosím", "ano", "ne", "dobře", "špatně", "jsem", "jsi", "je",
            "můžu", "můžeš", "může", "chci", "chceš", "chce", "potřebuji", "funguje", "nefunguje",
            -- Space combat terms
            "štít", "energie", "hyperpohon", "jádro", "systém", "stargate", "brána",
            "vesmír", "boj", "útok", "obrana", "cestování", "teleportovat", "skok",
            -- Commands
            "pomoc", "nápověda", "status", "stav", "spawn", "vytvoř", "nastav", "aktivuj", "vypni"
        },
        de = {"wie", "wo", "was", "warum", "wenn", "aber", "oder", "dass", "sein", "haben", "schiff", "waffe"},
        fr = {"comment", "où", "quoi", "pourquoi", "quand", "mais", "ou", "que", "être", "avoir", "navire"},
        es = {"cómo", "dónde", "qué", "por qué", "cuando", "pero", "o", "que", "ser", "tener", "nave"},
        it = {"come", "dove", "cosa", "perché", "quando", "ma", "o", "che", "essere", "avere", "nave"},
        pl = {"jak", "gdzie", "co", "dlaczego", "kiedy", "ale", "lub", "że", "być", "mieć", "statek"},
        ru = {"как", "где", "что", "почему", "когда", "но", "или", "что", "быть", "иметь", "корабль"},
        sk = {"ako", "kde", "čo", "prečo", "keď", "ale", "alebo", "že", "byť", "mať", "loď"}
    }
}

-- Multilingual Core
ASC.Multilingual.Core = {
    -- Player language preferences
    PlayerLanguages = {},
    
    -- Translation cache
    TranslationCache = {},
    
    -- Localized strings
    LocalizedStrings = {},
    
    -- Initialize multilingual system
    Initialize = function()
        print("[Multilingual] Initializing multilingual system v3.0.0")
        
        -- Load localized strings
        ASC.Multilingual.Core.LoadLocalizedStrings()
        
        -- Initialize player language tracking
        ASC.Multilingual.Core.InitializePlayerTracking()
        
        return true
    end,
    
    -- Detect language from text
    DetectLanguage = function(text)
        if not text or text == "" then return ASC.Multilingual.Config.DefaultLanguage end
        
        local textLower = string.lower(text)
        local scores = {}
        
        -- Initialize scores
        for lang, _ in pairs(ASC.Multilingual.Config.LanguagePatterns) do
            scores[lang] = 0
        end
        
        -- Check for language patterns
        for lang, patterns in pairs(ASC.Multilingual.Config.LanguagePatterns) do
            for _, pattern in ipairs(patterns) do
                if string.find(textLower, pattern) then
                    scores[lang] = scores[lang] + 1
                end
            end
        end
        
        -- Find highest scoring language
        local bestLang = ASC.Multilingual.Config.DefaultLanguage
        local bestScore = 0
        
        for lang, score in pairs(scores) do
            if score > bestScore then
                bestLang = lang
                bestScore = score
            end
        end
        
        -- Require minimum confidence
        if bestScore < 2 then
            return ASC.Multilingual.Config.DefaultLanguage
        end
        
        return bestLang
    end,
    
    -- Get player language
    GetPlayerLanguage = function(player)
        if not IsValid(player) then return ASC.Multilingual.Config.DefaultLanguage end
        
        local steamID = player:SteamID()
        return ASC.Multilingual.Core.PlayerLanguages[steamID] or ASC.Multilingual.Config.DefaultLanguage
    end,
    
    -- Set player language
    SetPlayerLanguage = function(player, language)
        if not IsValid(player) then return false end
        if not ASC.Multilingual.Config.SupportedLanguages[language] then return false end

        local steamID = player:SteamID()
        ASC.Multilingual.Core.PlayerLanguages[steamID] = language

        -- If setting to Czech, also enable Czech localization system
        if language == "cs" and ASC.Czech then
            ASC.Czech.SetEnabled(true)
            print("[Multilingual] Enabled Czech localization system for " .. player:Name())
        end

        -- Save to file
        ASC.Multilingual.Core.SavePlayerLanguages()

        return true
    end,

    -- Integration with Czech localization system
    IntegrateWithCzechSystem = function()
        if not ASC.Czech then return false end

        print("[Multilingual] Integrating with Czech localization system...")

        -- Ensure Czech localized strings table exists
        if not ASC.Multilingual.Core.LocalizedStrings.cs then
            ASC.Multilingual.Core.LocalizedStrings.cs = {}
        end

        -- Import Czech translations from the Czech system
        if ASC.Czech.Translations then
            local imported = 0
            for key, translation in pairs(ASC.Czech.Translations) do
                if not ASC.Multilingual.Core.LocalizedStrings.cs[key] then
                    ASC.Multilingual.Core.LocalizedStrings.cs[key] = translation
                    imported = imported + 1
                end
            end
            print("[Multilingual] Imported " .. imported .. " translations from Czech system")
        end

        -- Set up automatic synchronization
        hook.Add("ASC_Czech_TranslationAdded", "Multilingual_SyncCzech", function(key, translation)
            -- Ensure Czech table exists before adding translation
            if not ASC.Multilingual.Core.LocalizedStrings.cs then
                ASC.Multilingual.Core.LocalizedStrings.cs = {}
            end
            ASC.Multilingual.Core.LocalizedStrings.cs[key] = translation
        end)

        return true
    end,
    
    -- Translate text
    TranslateText = function(text, targetLang, sourceLang)
        if not text or text == "" then return text end
        if not targetLang then targetLang = ASC.Multilingual.Config.DefaultLanguage end
        if not sourceLang then sourceLang = ASC.Multilingual.Core.DetectLanguage(text) end
        
        -- No translation needed
        if sourceLang == targetLang then return text end
        
        -- Check cache first
        local cacheKey = sourceLang .. "_" .. targetLang .. "_" .. util.CRC(text)
        if ASC.Multilingual.Core.TranslationCache[cacheKey] then
            return ASC.Multilingual.Core.TranslationCache[cacheKey]
        end
        
        -- Use web translation if enabled
        if ASC.Multilingual.Config.WebTranslation then
            ASC.Multilingual.Core.RequestWebTranslation(text, targetLang, sourceLang, cacheKey)
        end
        
        -- Return localized string if available
        local localizedText = ASC.Multilingual.Core.GetLocalizedString(text, targetLang)
        if localizedText then
            return localizedText
        end
        
        -- Fallback to original text
        return text
    end,
    
    -- Request web translation
    RequestWebTranslation = function(text, targetLang, sourceLang, cacheKey)
        if not HTTP then return end
        
        -- Try Google Translate first
        local url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=" .. 
                   sourceLang .. "&tl=" .. targetLang .. "&dt=t&q=" .. util.URLEncode(text)
        
        HTTP({
            url = url,
            method = "GET",
            success = function(code, body, headers)
                if code == 200 then
                    local translation = ASC.Multilingual.Core.ParseGoogleTranslation(body)
                    if translation then
                        ASC.Multilingual.Core.TranslationCache[cacheKey] = translation
                        print("[Multilingual] Translated: " .. text .. " -> " .. translation)
                    end
                end
            end,
            failed = function(reason)
                print("[Multilingual] Translation failed: " .. reason)
                -- Try LibreTranslate as fallback
                ASC.Multilingual.Core.RequestLibreTranslation(text, targetLang, sourceLang, cacheKey)
            end
        })
    end,
    
    -- Request LibreTranslate translation
    RequestLibreTranslation = function(text, targetLang, sourceLang, cacheKey)
        if not HTTP then return end
        
        local postData = util.TableToJSON({
            q = text,
            source = sourceLang,
            target = targetLang,
            format = "text"
        })
        
        HTTP({
            url = "https://libretranslate.de/translate",
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json"
            },
            body = postData,
            success = function(code, body, headers)
                if code == 200 then
                    local response = util.JSONToTable(body)
                    if response and response.translatedText then
                        ASC.Multilingual.Core.TranslationCache[cacheKey] = response.translatedText
                        print("[Multilingual] LibreTranslate: " .. text .. " -> " .. response.translatedText)
                    end
                end
            end,
            failed = function(reason)
                print("[Multilingual] LibreTranslate failed: " .. reason)
            end
        })
    end,
    
    -- Parse Google Translate response
    ParseGoogleTranslation = function(body)
        -- Google Translate returns a complex JSON array
        -- We need to extract the translated text from the first element
        local startPos = string.find(body, '"')
        if not startPos then return nil end
        
        local endPos = string.find(body, '"', startPos + 1)
        if not endPos then return nil end
        
        local translation = string.sub(body, startPos + 1, endPos - 1)
        
        -- Unescape JSON characters
        translation = string.gsub(translation, "\\n", "\n")
        translation = string.gsub(translation, "\\\"", '"')
        translation = string.gsub(translation, "\\\\", "\\")
        
        return translation
    end,
    
    -- Get localized string
    GetLocalizedString = function(key, language)
        if not ASC.Multilingual.Core.LocalizedStrings[language] then return nil end
        return ASC.Multilingual.Core.LocalizedStrings[language][key]
    end,
    
    -- Load localized strings
    LoadLocalizedStrings = function()
        -- English (default)
        ASC.Multilingual.Core.LocalizedStrings.en = {
            ["ship_status"] = "Ship Status",
            ["weapons_online"] = "Weapons Online",
            ["shields_active"] = "Shields Active",
            ["flight_system"] = "Flight System",
            ["tactical_ai"] = "Tactical AI",
            ["formation_flying"] = "Formation Flying",
            ["docking_system"] = "Docking System",
            ["boss_encounter"] = "Boss Encounter",
            ["system_error"] = "System Error",
            ["command_not_found"] = "Command not found",
            ["invalid_target"] = "Invalid target",
            ["mission_complete"] = "Mission Complete",
            ["welcome_message"] = "Welcome to Advanced Space Combat!"
        }
        
        -- Czech (comprehensive)
        ASC.Multilingual.Core.LocalizedStrings.cs = {
            -- Basic system messages
            ["ship_status"] = "Stav Lodi",
            ["weapons_online"] = "Zbraně Online",
            ["shields_active"] = "Štíty Aktivní",
            ["flight_system"] = "Letový Systém",
            ["tactical_ai"] = "Taktická AI",
            ["formation_flying"] = "Formační Let",
            ["docking_system"] = "Dokovací Systém",
            ["boss_encounter"] = "Setkání s Bossem",
            ["system_error"] = "Systémová Chyba",
            ["command_not_found"] = "Příkaz nenalezen",
            ["invalid_target"] = "Neplatný cíl",
            ["mission_complete"] = "Mise Dokončena",
            ["welcome_message"] = "Vítejte v Advanced Space Combat!",

            -- Ship systems
            ["ship_core"] = "Jádro Lodi",
            ["hyperdrive"] = "Hyperpohon",
            ["energy_system"] = "Energetický Systém",
            ["shield_system"] = "Štítový Systém",
            ["weapon_system"] = "Zbraňový Systém",
            ["life_support"] = "Životní Podpora",
            ["navigation"] = "Navigace",
            ["sensors"] = "Senzory",

            -- Stargate technology
            ["stargate"] = "Stargate",
            ["dhd"] = "DHD",
            ["ancient_tech"] = "Starověká Technologie",
            ["asgard_tech"] = "Asgardská Technologie",
            ["goauld_tech"] = "Goa'uldská Technologie",
            ["wraith_tech"] = "Wraith Technologie",
            ["ori_tech"] = "Ori Technologie",
            ["tauri_tech"] = "Tau'ri Technologie",

            -- Combat
            ["weapons"] = "Zbraně",
            ["shields"] = "Štíty",
            ["armor"] = "Pancéřování",
            ["targeting"] = "Zaměřování",
            ["fire_control"] = "Řízení Palby",
            ["tactical_mode"] = "Taktický Režim",

            -- Status messages
            ["online"] = "Online",
            ["offline"] = "Offline",
            ["active"] = "Aktivní",
            ["inactive"] = "Neaktivní",
            ["ready"] = "Připraven",
            ["charging"] = "Nabíjení",
            ["cooldown"] = "Chlazení",
            ["damaged"] = "Poškozeno",
            ["destroyed"] = "Zničeno",

            -- Commands
            ["help"] = "Nápověda",
            ["status"] = "Stav",
            ["spawn"] = "Spawn",
            ["configure"] = "Konfigurovat",
            ["activate"] = "Aktivovat",
            ["deactivate"] = "Deaktivovat",
            ["jump"] = "Skok",
            ["dial"] = "Vytočit",
            ["teleport"] = "Teleportovat",

            -- AI responses
            ["ai_greeting"] = "Ahoj! Jsem ARIA-3, váš asistent AI.",
            ["ai_help"] = "Jak vám mohu pomoci?",
            ["ai_processing"] = "Zpracovávám...",
            ["ai_error"] = "Promiňte, nerozuměl jsem.",
            ["ai_success"] = "Úkol dokončen!",
            ["ai_thinking"] = "Přemýšlím...",

            -- Error messages
            ["error_general"] = "Obecná chyba",
            ["error_network"] = "Síťová chyba",
            ["error_permission"] = "Chyba oprávnění",
            ["error_resource"] = "Chyba prostředků",
            ["access_denied"] = "Přístup odepřen",
            ["insufficient_energy"] = "Nedostatek energie",
            ["target_not_found"] = "Cíl nenalezen",

            -- UI elements
            ["button_ok"] = "OK",
            ["button_cancel"] = "Zrušit",
            ["button_apply"] = "Použít",
            ["button_close"] = "Zavřít",
            ["button_save"] = "Uložit",
            ["button_load"] = "Načíst",
            ["button_reset"] = "Reset",
            ["button_help"] = "Nápověda",

            -- === INTEGRATION WITH CZECH LOCALIZATION SYSTEM ===
            ["czech_system_enabled"] = "Český systém povolen",
            ["czech_system_disabled"] = "Český systém zakázán",
            ["comprehensive_czech_support"] = "Komplexní česká podpora",
            ["addon_fully_localized"] = "Addon plně lokalizován",
            ["translation_count"] = "Počet překladů",
            ["localization_active"] = "Lokalizace aktivní",
            ["language_preference"] = "Jazyková preference",
            ["auto_detection"] = "Automatická detekce",
            ["fallback_enabled"] = "Záložní režim povolen",
            ["system_integration"] = "Systémová integrace",
            ["ui_localization"] = "Lokalizace UI",
            ["command_localization"] = "Lokalizace příkazů",
            ["entity_localization"] = "Lokalizace entit",
            ["menu_localization"] = "Lokalizace menu",
            ["ai_localization"] = "Lokalizace AI"
        }
        
        -- German
        ASC.Multilingual.Core.LocalizedStrings.de = {
            ["ship_status"] = "Schiffsstatus",
            ["weapons_online"] = "Waffen Online",
            ["shields_active"] = "Schilde Aktiv",
            ["flight_system"] = "Flugsystem",
            ["tactical_ai"] = "Taktische KI",
            ["formation_flying"] = "Formationsflug",
            ["docking_system"] = "Andocksystem",
            ["boss_encounter"] = "Boss-Begegnung",
            ["system_error"] = "Systemfehler",
            ["command_not_found"] = "Befehl nicht gefunden",
            ["invalid_target"] = "Ungültiges Ziel",
            ["mission_complete"] = "Mission Abgeschlossen",
            ["welcome_message"] = "Willkommen bei Advanced Space Combat!"
        }
        
        -- French
        ASC.Multilingual.Core.LocalizedStrings.fr = {
            ["ship_status"] = "État du Vaisseau",
            ["weapons_online"] = "Armes En Ligne",
            ["shields_active"] = "Boucliers Actifs",
            ["flight_system"] = "Système de Vol",
            ["tactical_ai"] = "IA Tactique",
            ["formation_flying"] = "Vol en Formation",
            ["docking_system"] = "Système d'Amarrage",
            ["boss_encounter"] = "Rencontre de Boss",
            ["system_error"] = "Erreur Système",
            ["command_not_found"] = "Commande introuvable",
            ["invalid_target"] = "Cible invalide",
            ["mission_complete"] = "Mission Terminée",
            ["welcome_message"] = "Bienvenue dans Advanced Space Combat!"
        }
        
        print("[Multilingual] Loaded localized strings for " .. table.Count(ASC.Multilingual.Core.LocalizedStrings) .. " languages")
    end,
    
    -- Initialize player tracking
    InitializePlayerTracking = function()
        -- Load saved player languages
        ASC.Multilingual.Core.LoadPlayerLanguages()
        
        -- Hook player connect to detect language
        hook.Add("PlayerInitialSpawn", "ASC_Multilingual_PlayerConnect", function(player)
            timer.Simple(5, function()
                if IsValid(player) then
                    ASC.Multilingual.Core.DetectPlayerLanguage(player)
                end
            end)
        end)
    end,
    
    -- Detect player language from their first messages
    DetectPlayerLanguage = function(player)
        if not IsValid(player) then return end
        
        local steamID = player:SteamID()
        if ASC.Multilingual.Core.PlayerLanguages[steamID] then return end
        
        -- Hook player chat to detect language
        local hookName = "ASC_Multilingual_Detect_" .. steamID
        hook.Add("PlayerSay", hookName, function(ply, text)
            if ply == player then
                local detectedLang = ASC.Multilingual.Core.DetectLanguage(text)
                if detectedLang ~= ASC.Multilingual.Config.DefaultLanguage then
                    ASC.Multilingual.Core.SetPlayerLanguage(player, detectedLang)
                    
                    local langInfo = ASC.Multilingual.Config.SupportedLanguages[detectedLang]
                    player:ChatPrint(langInfo.flag .. " Language detected: " .. langInfo.nativeName)
                    player:ChatPrint("Use 'aria language " .. detectedLang .. "' to confirm or 'aria language en' for English")
                    
                    hook.Remove("PlayerSay", hookName)
                end
            end
        end)
        
        -- Remove hook after 5 minutes
        timer.Simple(300, function()
            hook.Remove("PlayerSay", hookName)
        end)
    end,
    
    -- Save player languages
    SavePlayerLanguages = function()
        local data = util.TableToJSON(ASC.Multilingual.Core.PlayerLanguages)
        file.Write("asc_player_languages.txt", data)
    end,
    
    -- Load player languages
    LoadPlayerLanguages = function()
        if file.Exists("asc_player_languages.txt", "DATA") then
            local data = file.Read("asc_player_languages.txt", "DATA")
            local languages = util.JSONToTable(data)
            if languages then
                ASC.Multilingual.Core.PlayerLanguages = languages
                print("[Multilingual] Loaded " .. table.Count(languages) .. " player language preferences")
            end
        end
    end,
    
    -- Get language list
    GetLanguageList = function()
        local list = "🌍 Supported Languages:\n"
        
        for code, info in pairs(ASC.Multilingual.Config.SupportedLanguages) do
            list = list .. info.flag .. " " .. code .. " - " .. info.nativeName .. " (" .. info.name .. ")\n"
        end
        
        list = list .. "\n💡 Use 'aria language [code]' to set your language"
        return list
    end
}

-- Initialize system
if SERVER then
    -- Initialize multilingual system
    timer.Simple(2, function()
        ASC.Multilingual.Core.Initialize()

        -- Integrate with Czech system if available
        timer.Simple(1, function()
            if ASC.Czech then
                ASC.Multilingual.Core.IntegrateWithCzechSystem()
            end
        end)
    end)

    -- Update system status
    ASC.SystemStatus.MultilingualSupport = true
    ASC.SystemStatus.WebTranslation = true
    ASC.SystemStatus.LanguageDetection = true
    ASC.SystemStatus.CzechIntegration = ASC.Czech ~= nil

    print("[Advanced Space Combat] Multilingual System v3.0.0 loaded")
end

-- Hook for Czech system integration
hook.Add("ASC_Czech_SystemLoaded", "Multilingual_IntegrateCzech", function()
    if ASC.Multilingual and ASC.Multilingual.Core and ASC.Multilingual.Core.LocalizedStrings then
        ASC.Multilingual.Core.IntegrateWithCzechSystem()
    else
        -- If multilingual system isn't ready yet, try again in a moment
        timer.Simple(1, function()
            if ASC.Multilingual and ASC.Multilingual.Core and ASC.Multilingual.Core.LocalizedStrings then
                ASC.Multilingual.Core.IntegrateWithCzechSystem()
            end
        end)
    end
end)
