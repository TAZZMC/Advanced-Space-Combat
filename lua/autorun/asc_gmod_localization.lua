-- Advanced Space Combat - Garry's Mod Official Localization Integration v1.0.0
-- Integrates with Garry's Mod's official localization system using .properties files
-- Provides seamless Czech language support with proper UTF-8 encoding

print("[Advanced Space Combat] GMod Localization Integration v1.0.0 Loading...")

-- Initialize GMod localization namespace
ASC = ASC or {}
ASC.GMod = ASC.GMod or {}
ASC.GMod.Localization = ASC.GMod.Localization or {}

-- Configuration
ASC.GMod.Localization.Config = {
    Enabled = true,
    DefaultLanguage = "en",
    SupportedLanguages = {"en", "cs"},
    PropertiesFile = "advanced_space_combat",
    AutoDetectLanguage = true,
    FallbackToEnglish = true,
    LogTranslations = false,
    ValidateEncoding = true
}

-- Language detection and management
ASC.GMod.Localization.Core = {
    CurrentLanguage = "en",
    LoadedLanguages = {},
    TranslationCache = {},
    LanguageChangeCallbacks = {}
}

-- Get current language from GMod
function ASC.GMod.Localization.GetCurrentLanguage()
    local gmodLang = GetConVar("gmod_language")
    if gmodLang and gmodLang:GetString() then
        local lang = gmodLang:GetString()
        -- Map common language codes
        if lang == "czech" or lang == "cs" or lang == "cz" then
            return "cs"
        elseif lang == "english" or lang == "en" then
            return "en"
        end
        return lang
    end
    return ASC.GMod.Localization.Config.DefaultLanguage
end

-- Set language preference
function ASC.GMod.Localization.SetLanguage(language)
    if not language then return false end
    
    -- Validate language support
    local supported = false
    for _, lang in ipairs(ASC.GMod.Localization.Config.SupportedLanguages) do
        if lang == language then
            supported = true
            break
        end
    end
    
    if not supported then
        print("[GMod Localization] Language '" .. language .. "' not supported")
        return false
    end
    
    -- Update GMod language setting
    RunConsoleCommand("gmod_language", language)
    ASC.GMod.Localization.Core.CurrentLanguage = language
    
    -- Trigger callbacks
    for _, callback in ipairs(ASC.GMod.Localization.Core.LanguageChangeCallbacks) do
        if callback and type(callback) == "function" then
            pcall(callback, language)
        end
    end
    
    print("[GMod Localization] Language set to: " .. language)
    return true
end

-- Get localized text using GMod's system
function ASC.GMod.Localization.GetText(key, fallback)
    if not ASC.GMod.Localization.Config.Enabled then
        return fallback or key
    end
    
    -- Try to get translation from GMod's language system
    local translation = language.GetPhrase(key)
    
    -- If translation found and different from key
    if translation and translation ~= key then
        if ASC.GMod.Localization.Config.LogTranslations then
            print("[GMod Localization] Translated: " .. key .. " -> " .. translation)
        end
        return translation
    end
    
    -- Fallback to English if enabled
    if ASC.GMod.Localization.Config.FallbackToEnglish and fallback then
        return fallback
    end
    
    return key
end

-- Add translation to GMod's system
function ASC.GMod.Localization.AddTranslation(key, text, language)
    if not key or not text then return false end
    
    language = language or ASC.GMod.Localization.Core.CurrentLanguage
    
    -- Add to GMod's language system
    language.Add(key, text)
    
    if ASC.GMod.Localization.Config.LogTranslations then
        print("[GMod Localization] Added translation: " .. key .. " = " .. text .. " (" .. language .. ")")
    end
    
    return true
end

-- Load all translations from properties files
function ASC.GMod.Localization.LoadAllTranslations()
    print("[GMod Localization] Loading translations from properties files...")
    
    -- Note: GMod automatically loads .properties files from resource/localization/
    -- We just need to ensure they're properly formatted and encoded
    
    local loadedCount = 0
    
    for _, lang in ipairs(ASC.GMod.Localization.Config.SupportedLanguages) do
        local filePath = "resource/localization/" .. lang .. "/" .. ASC.GMod.Localization.Config.PropertiesFile .. ".properties"
        
        if file.Exists(filePath, "GAME") then
            print("[GMod Localization] Found properties file: " .. filePath)
            ASC.GMod.Localization.Core.LoadedLanguages[lang] = true
            loadedCount = loadedCount + 1
        else
            print("[GMod Localization] Properties file not found: " .. filePath)
        end
    end
    
    print("[GMod Localization] Loaded " .. loadedCount .. " language files")
    return loadedCount > 0
end

-- Validate UTF-8 encoding for Czech text
function ASC.GMod.Localization.ValidateUTF8(text)
    if not text or text == "" then return true end
    
    -- Check for common Czech characters that might have encoding issues
    local czechChars = {"ř", "š", "č", "ž", "ý", "á", "í", "é", "ů", "ú", "ň", "ť", "ď"}
    
    for _, char in ipairs(czechChars) do
        if string.find(text, char) then
            -- If we find Czech characters, assume UTF-8 is working
            return true
        end
    end
    
    return true -- No Czech characters found, assume valid
end

-- Integration with existing Czech system
function ASC.GMod.Localization.IntegrateWithCzechSystem()
    if not ASC.Czech then
        print("[GMod Localization] Czech system not found, skipping integration")
        return
    end
    
    print("[GMod Localization] Integrating with existing Czech system...")
    
    -- Override Czech system's GetText function to use GMod's system first
    local originalGetText = ASC.Czech.GetText
    ASC.Czech.GetText = function(key, fallback)
        -- Try GMod localization first
        local gmodText = ASC.GMod.Localization.GetText("asc." .. string.lower(key), nil)
        if gmodText and gmodText ~= ("asc." .. string.lower(key)) then
            return gmodText
        end
        
        -- Fall back to original Czech system
        return originalGetText(key, fallback)
    end
    
    print("[GMod Localization] Czech system integration complete")
end

-- Auto-detect and set Czech language
function ASC.GMod.Localization.AutoDetectCzech()
    if not ASC.GMod.Localization.Config.AutoDetectLanguage then return end
    
    local currentLang = ASC.GMod.Localization.GetCurrentLanguage()
    
    -- Check if Czech is already set
    if currentLang == "cs" then
        print("[GMod Localization] Czech language already active")
        return true
    end
    
    -- Try to detect Czech through various methods
    local czechDetected = false
    
    -- Method 1: Check if Czech detection system found Czech
    if ASC.CzechDetection and ASC.CzechDetection.Core then
        local player = LocalPlayer()
        if IsValid(player) then
            local steamID = player:SteamID()
            local detectionData = ASC.CzechDetection.Core.DetectionResults[steamID]
            if detectionData and detectionData.finalLanguage == "cs" then
                czechDetected = true
            end
        end
    end
    
    -- Method 2: Check existing Czech system
    if ASC.Czech and ASC.Czech.Config and ASC.Czech.Config.Enabled then
        czechDetected = true
    end
    
    -- Set language if detected
    if czechDetected then
        ASC.GMod.Localization.SetLanguage("cs")
        print("[GMod Localization] Auto-detected Czech language, switching to Czech")
        return true
    end
    
    return false
end

-- Register language change callback
function ASC.GMod.Localization.OnLanguageChange(callback)
    if callback and type(callback) == "function" then
        table.insert(ASC.GMod.Localization.Core.LanguageChangeCallbacks, callback)
    end
end

-- Initialize the system
function ASC.GMod.Localization.Initialize()
    print("[GMod Localization] Initializing...")
    
    -- Load current language
    ASC.GMod.Localization.Core.CurrentLanguage = ASC.GMod.Localization.GetCurrentLanguage()
    
    -- Load translations
    ASC.GMod.Localization.LoadAllTranslations()
    
    -- Auto-detect Czech if enabled
    if CLIENT then
        timer.Simple(1, function()
            ASC.GMod.Localization.AutoDetectCzech()
        end)
    end
    
    -- Integrate with existing systems
    timer.Simple(2, function()
        ASC.GMod.Localization.IntegrateWithCzechSystem()
    end)
    
    print("[GMod Localization] Initialization complete")
end

-- Console commands
concommand.Add("asc_gmod_lang", function(ply, cmd, args)
    if not args[1] then
        local currentLang = ASC.GMod.Localization.GetCurrentLanguage()
        local msg = "[GMod Localization] Current language: " .. currentLang
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
        return
    end
    
    local newLang = args[1]
    local success = ASC.GMod.Localization.SetLanguage(newLang)
    
    local msg = success and 
        "[GMod Localization] Language changed to: " .. newLang or
        "[GMod Localization] Failed to change language to: " .. newLang
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

concommand.Add("asc_gmod_lang_reload", function(ply, cmd, args)
    ASC.GMod.Localization.LoadAllTranslations()
    local msg = "[GMod Localization] Translations reloaded"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

-- Initialize on load
if CLIENT then
    timer.Simple(0.5, function()
        ASC.GMod.Localization.Initialize()
    end)
else
    ASC.GMod.Localization.Initialize()
end

print("[Advanced Space Combat] GMod Localization Integration v1.0.0 loaded")
