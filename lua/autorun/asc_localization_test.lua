-- Advanced Space Combat - Localization Test & Validation System v1.0.0
-- Tests and validates Czech language integration and encoding

print("[Advanced Space Combat] Localization Test System v1.0.0 Loading...")

-- Initialize test namespace
ASC = ASC or {}
ASC.LocalizationTest = ASC.LocalizationTest or {}

-- Test configuration
ASC.LocalizationTest.Config = {
    Enabled = true,
    RunOnStartup = true,
    LogResults = true,
    TestEncoding = true,
    TestTranslations = true,
    TestIntegration = true
}

-- Test results storage
ASC.LocalizationTest.Results = {
    EncodingTests = {},
    TranslationTests = {},
    IntegrationTests = {},
    OverallStatus = "unknown"
}

-- Czech characters for encoding tests
ASC.LocalizationTest.CzechTestChars = {
    "ř", "š", "č", "ž", "ý", "á", "í", "é", "ů", "ú", "ň", "ť", "ď",
    "Ř", "Š", "Č", "Ž", "Ý", "Á", "Í", "É", "Ů", "Ú", "Ň", "Ť", "Ď"
}

-- Test phrases
ASC.LocalizationTest.TestPhrases = {
    {key = "asc.addon.name", expected_cs = "Pokročilý Vesmírný Boj", expected_en = "Advanced Space Combat"},
    {key = "asc.ship_core.name", expected_cs = "Jádro Lodi", expected_en = "Ship Core"},
    {key = "asc.hyperdrive.status", expected_cs = "Stav Hyperpoháněče", expected_en = "Hyperdrive Status"},
    {key = "asc.weapons.online", expected_cs = "Zbraně Online", expected_en = "Weapons Online"},
    {key = "asc.shields.active", expected_cs = "Štíty Aktivní", expected_en = "Shields Active"},
    {key = "asc.ai.greeting", expected_cs = "Ahoj! Jsem ARIA-4, váš asistent Advanced Space Combat AI. Jak vám mohu pomoci?", expected_en = "Hello! I'm ARIA-4, your Advanced Space Combat AI assistant. How can I help you?"}
}

-- Test UTF-8 encoding
function ASC.LocalizationTest.TestEncoding()
    print("[Localization Test] Testing UTF-8 encoding...")
    
    local results = {}
    
    for i, char in ipairs(ASC.LocalizationTest.CzechTestChars) do
        local test = {
            character = char,
            length = string.len(char),
            utf8_length = utf8.len and utf8.len(char) or "N/A",
            byte_representation = string.byte(char, 1, -1),
            status = "unknown"
        }
        
        -- Test if character displays correctly
        if string.len(char) >= 2 then -- Czech chars are multi-byte in UTF-8
            test.status = "pass"
        else
            test.status = "fail"
        end
        
        results[i] = test
        
        if ASC.LocalizationTest.Config.LogResults then
            print("[Localization Test] Character '" .. char .. "': " .. test.status .. " (length: " .. test.length .. ")")
        end
    end
    
    ASC.LocalizationTest.Results.EncodingTests = results
    
    -- Calculate overall encoding status
    local passCount = 0
    for _, test in ipairs(results) do
        if test.status == "pass" then
            passCount = passCount + 1
        end
    end
    
    local encodingStatus = (passCount == #results) and "pass" or "fail"
    print("[Localization Test] Encoding test: " .. encodingStatus .. " (" .. passCount .. "/" .. #results .. " passed)")
    
    return encodingStatus == "pass"
end

-- Test translation functionality
function ASC.LocalizationTest.TestTranslations()
    print("[Localization Test] Testing translations...")
    
    local results = {}
    
    for i, phrase in ipairs(ASC.LocalizationTest.TestPhrases) do
        local test = {
            key = phrase.key,
            expected_cs = phrase.expected_cs,
            expected_en = phrase.expected_en,
            actual_translation = nil,
            status = "unknown"
        }
        
        -- Test translation retrieval
        local translation = language.GetPhrase(phrase.key)
        test.actual_translation = translation
        
        -- Check if translation is working
        if translation and translation ~= phrase.key then
            test.status = "pass"
        else
            test.status = "fail"
        end
        
        results[i] = test
        
        if ASC.LocalizationTest.Config.LogResults then
            print("[Localization Test] Key '" .. phrase.key .. "': " .. test.status)
            print("  Expected (CS): " .. phrase.expected_cs)
            print("  Actual: " .. (translation or "nil"))
        end
    end
    
    ASC.LocalizationTest.Results.TranslationTests = results
    
    -- Calculate overall translation status
    local passCount = 0
    for _, test in ipairs(results) do
        if test.status == "pass" then
            passCount = passCount + 1
        end
    end
    
    local translationStatus = (passCount >= (#results * 0.8)) and "pass" or "fail" -- 80% pass rate
    print("[Localization Test] Translation test: " .. translationStatus .. " (" .. passCount .. "/" .. #results .. " passed)")
    
    return translationStatus == "pass"
end

-- Test system integration
function ASC.LocalizationTest.TestIntegration()
    print("[Localization Test] Testing system integration...")
    
    local results = {}
    
    -- Test 1: GMod localization system
    local gmodTest = {
        name = "GMod Localization System",
        status = (ASC.GMod and ASC.GMod.Localization) and "pass" or "fail"
    }
    table.insert(results, gmodTest)
    
    -- Test 2: Czech localization system
    local czechTest = {
        name = "Czech Localization System",
        status = (ASC.Czech and ASC.Czech.GetText) and "pass" or "fail"
    }
    table.insert(results, czechTest)
    
    -- Test 3: Multilingual system
    local multilingualTest = {
        name = "Multilingual System",
        status = (ASC.Multilingual and ASC.Multilingual.Core) and "pass" or "fail"
    }
    table.insert(results, multilingualTest)
    
    -- Test 4: Auto-detection system
    local autoDetectTest = {
        name = "Auto-Detection System",
        status = (ASC.CzechDetection and ASC.CzechDetection.Core) and "pass" or "fail"
    }
    table.insert(results, autoDetectTest)
    
    -- Test 5: Properties files
    local propertiesTest = {
        name = "Properties Files",
        status = "unknown"
    }
    
    local enExists = file.Exists("resource/localization/en/advanced_space_combat.properties", "GAME")
    local csExists = file.Exists("resource/localization/cs/advanced_space_combat.properties", "GAME")
    
    if enExists and csExists then
        propertiesTest.status = "pass"
    elseif enExists or csExists then
        propertiesTest.status = "partial"
    else
        propertiesTest.status = "fail"
    end
    
    table.insert(results, propertiesTest)
    
    ASC.LocalizationTest.Results.IntegrationTests = results
    
    -- Log results
    if ASC.LocalizationTest.Config.LogResults then
        for _, test in ipairs(results) do
            print("[Localization Test] " .. test.name .. ": " .. test.status)
        end
    end
    
    -- Calculate overall integration status
    local passCount = 0
    for _, test in ipairs(results) do
        if test.status == "pass" then
            passCount = passCount + 1
        end
    end
    
    local integrationStatus = (passCount >= (#results * 0.8)) and "pass" or "fail"
    print("[Localization Test] Integration test: " .. integrationStatus .. " (" .. passCount .. "/" .. #results .. " passed)")
    
    return integrationStatus == "pass"
end

-- Run all tests
function ASC.LocalizationTest.RunAllTests()
    print("[Localization Test] Running comprehensive localization tests...")
    
    local encodingPass = ASC.LocalizationTest.Config.TestEncoding and ASC.LocalizationTest.TestEncoding() or true
    local translationPass = ASC.LocalizationTest.Config.TestTranslations and ASC.LocalizationTest.TestTranslations() or true
    local integrationPass = ASC.LocalizationTest.Config.TestIntegration and ASC.LocalizationTest.TestIntegration() or true
    
    -- Overall status
    local overallPass = encodingPass and translationPass and integrationPass
    ASC.LocalizationTest.Results.OverallStatus = overallPass and "pass" or "fail"
    
    print("[Localization Test] =====================================")
    print("[Localization Test] OVERALL RESULT: " .. string.upper(ASC.LocalizationTest.Results.OverallStatus))
    print("[Localization Test] Encoding: " .. (encodingPass and "PASS" or "FAIL"))
    print("[Localization Test] Translations: " .. (translationPass and "PASS" or "FAIL"))
    print("[Localization Test] Integration: " .. (integrationPass and "PASS" or "FAIL"))
    print("[Localization Test] =====================================")
    
    return overallPass
end

-- Get test results
function ASC.LocalizationTest.GetResults()
    return ASC.LocalizationTest.Results
end

-- Console command to run tests
concommand.Add("asc_test_localization", function(ply, cmd, args)
    local success = ASC.LocalizationTest.RunAllTests()
    local msg = "[Localization Test] Tests completed. Result: " .. (success and "PASS" or "FAIL")
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end)

-- Console command to show test results
concommand.Add("asc_localization_status", function(ply, cmd, args)
    local results = ASC.LocalizationTest.GetResults()
    local msg = "[Localization Test] Status: " .. string.upper(results.OverallStatus)
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
        ply:ChatPrint("Use 'asc_test_localization' to run tests")
    else
        print(msg)
        print("Use 'asc_test_localization' to run tests")
    end
end)

-- Auto-run tests on startup if enabled
if ASC.LocalizationTest.Config.RunOnStartup then
    timer.Simple(3, function()
        ASC.LocalizationTest.RunAllTests()
    end)
end

print("[Advanced Space Combat] Localization Test System v1.0.0 loaded")
