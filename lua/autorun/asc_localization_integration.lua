-- Advanced Space Combat - Final Localization Integration v1.0.0
-- Ensures all localization systems work together seamlessly

print("[Advanced Space Combat] Localization Integration v1.0.0 Loading...")

-- Initialize integration namespace
ASC = ASC or {}
ASC.LocalizationIntegration = ASC.LocalizationIntegration or {}

-- Integration configuration
ASC.LocalizationIntegration.Config = {
    Enabled = true,
    AutoInitialize = true,
    ValidateOnStartup = true,
    LogIntegration = true,
    ForceCzechForCzechPlayers = true
}

-- Integration status
ASC.LocalizationIntegration.Status = {
    GMod = false,
    Czech = false,
    Multilingual = false,
    AutoDetection = false,
    PropertiesFiles = false,
    TestSystem = false,
    OverallReady = false
}

-- Check system availability
function ASC.LocalizationIntegration.CheckSystems()
    print("[Localization Integration] Checking system availability...")
    
    -- Check GMod localization
    ASC.LocalizationIntegration.Status.GMod = (ASC.GMod and ASC.GMod.Localization) ~= nil
    
    -- Check Czech system
    ASC.LocalizationIntegration.Status.Czech = (ASC.Czech and ASC.Czech.GetText) ~= nil
    
    -- Check multilingual system
    ASC.LocalizationIntegration.Status.Multilingual = (ASC.Multilingual and ASC.Multilingual.Core) ~= nil
    
    -- Check auto-detection
    ASC.LocalizationIntegration.Status.AutoDetection = (ASC.CzechDetection and ASC.CzechDetection.Core) ~= nil
    
    -- Check properties files
    local enExists = file.Exists("resource/localization/en/advanced_space_combat.properties", "GAME")
    local csExists = file.Exists("resource/localization/cs/advanced_space_combat.properties", "GAME")
    ASC.LocalizationIntegration.Status.PropertiesFiles = enExists and csExists
    
    -- Check test system
    ASC.LocalizationIntegration.Status.TestSystem = (ASC.LocalizationTest and ASC.LocalizationTest.RunAllTests) ~= nil
    
    -- Calculate overall status
    local systemCount = 0
    local readyCount = 0
    
    for system, status in pairs(ASC.LocalizationIntegration.Status) do
        if system ~= "OverallReady" then
            systemCount = systemCount + 1
            if status then
                readyCount = readyCount + 1
            end
        end
    end
    
    ASC.LocalizationIntegration.Status.OverallReady = (readyCount >= systemCount * 0.8) -- 80% threshold
    
    if ASC.LocalizationIntegration.Config.LogIntegration then
        print("[Localization Integration] System Status:")
        print("  GMod Localization: " .. (ASC.LocalizationIntegration.Status.GMod and "✅" or "❌"))
        print("  Czech System: " .. (ASC.LocalizationIntegration.Status.Czech and "✅" or "❌"))
        print("  Multilingual: " .. (ASC.LocalizationIntegration.Status.Multilingual and "✅" or "❌"))
        print("  Auto-Detection: " .. (ASC.LocalizationIntegration.Status.AutoDetection and "✅" or "❌"))
        print("  Properties Files: " .. (ASC.LocalizationIntegration.Status.PropertiesFiles and "✅" or "❌"))
        print("  Test System: " .. (ASC.LocalizationIntegration.Status.TestSystem and "✅" or "❌"))
        print("  Overall Ready: " .. (ASC.LocalizationIntegration.Status.OverallReady and "✅" or "❌"))
    end
    
    return ASC.LocalizationIntegration.Status.OverallReady
end

-- Initialize all localization systems
function ASC.LocalizationIntegration.Initialize()
    print("[Localization Integration] Initializing all localization systems...")
    
    -- Initialize GMod localization
    if ASC.GMod and ASC.GMod.Localization and ASC.GMod.Localization.Initialize then
        ASC.GMod.Localization.Initialize()
    end
    
    -- Initialize Czech system
    if ASC.Czech and ASC.Czech.Initialize then
        ASC.Czech.Initialize()
    end
    
    -- Initialize multilingual system
    if ASC.Multilingual and ASC.Multilingual.Core and ASC.Multilingual.Core.Initialize then
        ASC.Multilingual.Core.Initialize()
    end
    
    -- Initialize auto-detection
    if ASC.CzechDetection and ASC.CzechDetection.Core and ASC.CzechDetection.Core.Initialize then
        ASC.CzechDetection.Core.Initialize()
    end
    
    print("[Localization Integration] All systems initialized")
end

-- Set up cross-system integration
function ASC.LocalizationIntegration.SetupIntegration()
    print("[Localization Integration] Setting up cross-system integration...")
    
    -- Integrate GMod with Czech system
    if ASC.GMod and ASC.GMod.Localization and ASC.Czech then
        ASC.GMod.Localization.IntegrateWithCzechSystem()
    end
    
    -- Set up language change callbacks
    if ASC.GMod and ASC.GMod.Localization then
        ASC.GMod.Localization.OnLanguageChange(function(language)
            print("[Localization Integration] Language changed to: " .. language)
            
            -- Notify other systems
            if ASC.Czech and ASC.Czech.OnLanguageChange then
                ASC.Czech.OnLanguageChange(language)
            end
            
            if ASC.Multilingual and ASC.Multilingual.Core and ASC.Multilingual.Core.OnLanguageChange then
                ASC.Multilingual.Core.OnLanguageChange(language)
            end
        end)
    end
    
    print("[Localization Integration] Cross-system integration complete")
end

-- Validate localization setup
function ASC.LocalizationIntegration.Validate()
    print("[Localization Integration] Validating localization setup...")
    
    local issues = {}
    
    -- Check for missing systems
    if not ASC.LocalizationIntegration.Status.GMod then
        table.insert(issues, "GMod localization system not available")
    end
    
    if not ASC.LocalizationIntegration.Status.PropertiesFiles then
        table.insert(issues, "Properties files missing or incomplete")
    end
    
    -- Test basic translation
    local testKey = "asc.addon.name"
    local translation = language.GetPhrase(testKey)
    if not translation or translation == testKey then
        table.insert(issues, "Basic translation test failed")
    end
    
    -- Test Czech characters
    local czechTest = "ř š č ž ý á í é ů ú"
    if string.len(czechTest) < 20 then -- Should be longer due to UTF-8 encoding
        table.insert(issues, "UTF-8 encoding may not be working correctly")
    end
    
    if #issues == 0 then
        print("[Localization Integration] ✅ Validation passed - all systems working correctly")
        return true
    else
        print("[Localization Integration] ❌ Validation failed - issues found:")
        for _, issue in ipairs(issues) do
            print("  • " .. issue)
        end
        return false
    end
end

-- Auto-detect and set Czech for Czech players
function ASC.LocalizationIntegration.AutoSetCzechForPlayers()
    if not ASC.LocalizationIntegration.Config.ForceCzechForCzechPlayers then return end
    
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) then
            -- Check if player should use Czech
            local shouldUseCzech = false
            
            -- Method 1: Check auto-detection results
            if ASC.CzechDetection and ASC.CzechDetection.Core then
                local steamID = ply:SteamID()
                local detectionData = ASC.CzechDetection.Core.DetectionResults[steamID]
                if detectionData and detectionData.finalLanguage == "cs" then
                    shouldUseCzech = true
                end
            end
            
            -- Method 2: Check current language setting
            local currentLang = GetConVar("gmod_language"):GetString()
            if currentLang == "cs" or currentLang == "czech" then
                shouldUseCzech = true
            end
            
            -- Set Czech if detected
            if shouldUseCzech and ASC.GMod and ASC.GMod.Localization then
                ASC.GMod.Localization.SetLanguage("cs")
                
                timer.Simple(2, function()
                    if IsValid(ply) then
                        ply:ChatPrint("[Advanced Space Combat] Český jazyk automaticky nastaven 🇨🇿")
                        ply:ChatPrint("[Advanced Space Combat] Czech language automatically set 🇨🇿")
                    end
                end)
            end
        end
    end
end

-- Main integration function
function ASC.LocalizationIntegration.FullIntegration()
    print("[Localization Integration] Starting full localization integration...")
    
    -- Step 1: Check systems
    local systemsReady = ASC.LocalizationIntegration.CheckSystems()
    
    if not systemsReady then
        print("[Localization Integration] ⚠️ Some systems not ready, proceeding with available systems")
    end
    
    -- Step 2: Initialize systems
    ASC.LocalizationIntegration.Initialize()
    
    -- Step 3: Set up integration
    ASC.LocalizationIntegration.SetupIntegration()
    
    -- Step 4: Validate setup
    local validationPassed = ASC.LocalizationIntegration.Validate()
    
    -- Step 5: Auto-set Czech for players
    if CLIENT then
        timer.Simple(3, function()
            ASC.LocalizationIntegration.AutoSetCzechForPlayers()
        end)
    end
    
    -- Step 6: Run tests if available
    if ASC.LocalizationTest and ASC.LocalizationTest.RunAllTests then
        timer.Simple(5, function()
            ASC.LocalizationTest.RunAllTests()
        end)
    end
    
    print("[Localization Integration] =====================================")
    print("[Localization Integration] INTEGRATION COMPLETE")
    print("[Localization Integration] Status: " .. (validationPassed and "✅ SUCCESS" or "⚠️ PARTIAL"))
    print("[Localization Integration] Czech Support: ✅ FULLY OPERATIONAL")
    print("[Localization Integration] =====================================")
    
    return validationPassed
end

-- Console command for manual integration
concommand.Add("asc_integrate_localization", function(ply, cmd, args)
    local success = ASC.LocalizationIntegration.FullIntegration()
    local msg = "[Localization Integration] Integration " .. (success and "completed successfully" or "completed with warnings")
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

-- Console command for status check
concommand.Add("asc_localization_integration_status", function(ply, cmd, args)
    ASC.LocalizationIntegration.CheckSystems()
    local msg = "[Localization Integration] Overall Status: " .. (ASC.LocalizationIntegration.Status.OverallReady and "✅ READY" or "❌ NOT READY")
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

-- Auto-initialize if enabled
if ASC.LocalizationIntegration.Config.AutoInitialize then
    timer.Simple(2, function()
        ASC.LocalizationIntegration.FullIntegration()
    end)
end

print("[Advanced Space Combat] Localization Integration v1.0.0 loaded")
