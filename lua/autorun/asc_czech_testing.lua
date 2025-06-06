--[[
    Advanced Space Combat - Czech Language Testing & Validation System v1.0.0
    
    Comprehensive testing framework for Czech language integration
    including encoding validation, AI response testing, and cultural context verification.
]]

-- Initialize Czech Testing namespace
ASC = ASC or {}
ASC.CzechTesting = ASC.CzechTesting or {}

-- Czech Testing Configuration
ASC.CzechTesting.Config = {
    Enabled = true,
    AutoTest = false,
    LogResults = true,
    TestOnPlayerJoin = false,
    ComprehensiveTests = true
}

-- Test Cases for Czech Language Integration
ASC.CzechTesting.TestCases = {
    -- === ZÁKLADNÍ TESTY KÓDOVÁNÍ ===
    EncodingTests = {
        {
            name = "Czech Diacritics UTF-8",
            input = "áčďéěíňóřšťúůýž ÁČĎÉĚÍŇÓŘŠŤÚŮÝŽ",
            expected = true,
            test = function(input) 
                return ASC.Czech and ASC.Czech.ValidateUTF8 and ASC.Czech.ValidateUTF8(input) 
            end
        },
        {
            name = "Mixed Czech-English Text",
            input = "Ahoj! Jak se máš? How are you?",
            expected = true,
            test = function(input) 
                return ASC.Czech and ASC.Czech.ValidateUTF8 and ASC.Czech.ValidateUTF8(input) 
            end
        }
    },
    
    -- === TESTY DETEKCE JAZYKA ===
    LanguageDetectionTests = {
        {
            name = "Czech Language Detection - Basic",
            input = "ahoj jak se máš",
            expected = "czech",
            test = function(input) 
                return ASC.AI and ASC.AI.Languages and ASC.AI.Languages.DetectLanguage and ASC.AI.Languages.DetectLanguage(input) 
            end
        },
        {
            name = "Czech Language Detection - Commands",
            input = "pomoc s jádrem lodi",
            expected = "czech",
            test = function(input) 
                return ASC.AI and ASC.AI.Languages and ASC.AI.Languages.DetectLanguage and ASC.AI.Languages.DetectLanguage(input) 
            end
        },
        {
            name = "Czech Language Detection - Diacritics",
            input = "potřebuji nápovědu s hyperpoháněčem",
            expected = "czech",
            test = function(input) 
                return ASC.AI and ASC.AI.Languages and ASC.AI.Languages.DetectLanguage and ASC.AI.Languages.DetectLanguage(input) 
            end
        }
    },
    
    -- === TESTY FORMÁLNOSTI ===
    FormalityTests = {
        {
            name = "Formal Czech Detection",
            input = "Prosím vás, můžete mi pomoci s konfigurací?",
            expected = "formal",
            test = function(input) 
                return ASC.AI and ASC.AI.Languages and ASC.AI.Languages.DetectCzechFormality and ASC.AI.Languages.DetectCzechFormality(input) 
            end
        },
        {
            name = "Informal Czech Detection",
            input = "ahoj, můžeš mi pomoct s tím?",
            expected = "informal",
            test = function(input) 
                return ASC.AI and ASC.AI.Languages and ASC.AI.Languages.DetectCzechFormality and ASC.AI.Languages.DetectCzechFormality(input) 
            end
        }
    },
    
    -- === TESTY PŘEKLADU PŘÍKAZŮ ===
    CommandTranslationTests = {
        {
            name = "Basic Command Translation",
            input = "pomoc",
            expected = "help",
            test = function(input) 
                return ASC.AI and ASC.AI.Languages and ASC.AI.Languages.TranslateCzechCommand and ASC.AI.Languages.TranslateCzechCommand(input) 
            end
        },
        {
            name = "Complex Command Translation",
            input = "nastav jádro lodi",
            expected = "configure ship core",
            test = function(input) 
                return ASC.AI and ASC.AI.Languages and ASC.AI.Languages.TranslateCzechCommand and ASC.AI.Languages.TranslateCzechCommand(input) 
            end
        }
    }
}

-- Run comprehensive Czech language tests
function ASC.CzechTesting.RunAllTests()
    if not ASC.CzechTesting.Config.Enabled then 
        print("[Czech Testing] Testing disabled")
        return false 
    end
    
    print("[Czech Testing] Starting comprehensive Czech language integration tests...")
    
    local totalTests = 0
    local passedTests = 0
    local failedTests = {}
    
    -- Run all test categories
    for categoryName, tests in pairs(ASC.CzechTesting.TestCases) do
        print("[Czech Testing] Running " .. categoryName .. " tests...")
        
        for _, testCase in ipairs(tests) do
            totalTests = totalTests + 1
            
            local success, result = pcall(testCase.test, testCase.input)
            
            if success and result == testCase.expected then
                passedTests = passedTests + 1
                if ASC.CzechTesting.Config.LogResults then
                    print("  ✓ " .. testCase.name .. " - PASSED")
                end
            else
                table.insert(failedTests, {
                    category = categoryName,
                    name = testCase.name,
                    input = testCase.input,
                    expected = testCase.expected,
                    actual = result,
                    error = not success and result or nil
                })
                if ASC.CzechTesting.Config.LogResults then
                    print("  ✗ " .. testCase.name .. " - FAILED (expected: " .. tostring(testCase.expected) .. ", got: " .. tostring(result) .. ")")
                end
            end
        end
    end
    
    -- Report results
    print("[Czech Testing] Test Results:")
    print("  Total Tests: " .. totalTests)
    print("  Passed: " .. passedTests)
    print("  Failed: " .. #failedTests)
    print("  Success Rate: " .. math.floor((passedTests / totalTests) * 100) .. "%")
    
    if #failedTests > 0 then
        print("[Czech Testing] Failed Tests:")
        for _, failure in ipairs(failedTests) do
            print("  - " .. failure.category .. ": " .. failure.name)
            if failure.error then
                print("    Error: " .. tostring(failure.error))
            end
        end
    end
    
    return #failedTests == 0
end

-- Test Czech language integration for a specific player
function ASC.CzechTesting.TestPlayerIntegration(player)
    if not IsValid(player) then return false end
    
    print("[Czech Testing] Testing Czech integration for " .. player:Name())
    
    local tests = {
        {
            name = "Language Detection",
            test = function()
                return ASC.Czech and ASC.Czech.DetectPlayerLanguage and ASC.Czech.DetectPlayerLanguage(player)
            end
        },
        {
            name = "AI Language Setting",
            test = function()
                if ASC.AI and ASC.AI.Languages and ASC.AI.Languages.SetLanguage then
                    return ASC.AI.Languages.SetLanguage(player:SteamID(), "czech")
                end
                return false
            end
        },
        {
            name = "Multilingual Integration",
            test = function()
                if ASC.Multilingual and ASC.Multilingual.Core and ASC.Multilingual.Core.SetPlayerLanguage then
                    return ASC.Multilingual.Core.SetPlayerLanguage(player, "cs")
                end
                return false
            end
        }
    }
    
    local passed = 0
    local total = #tests
    
    for _, test in ipairs(tests) do
        local success, result = pcall(test.test)
        if success and result then
            passed = passed + 1
            print("  ✓ " .. test.name .. " - OK")
        else
            print("  ✗ " .. test.name .. " - FAILED")
        end
    end
    
    print("[Czech Testing] Player integration: " .. passed .. "/" .. total .. " tests passed")
    return passed == total
end

-- Console command for running tests
concommand.Add("asc_test_czech", function(ply, cmd, args)
    local testType = args[1] or "all"
    
    if testType == "all" then
        local success = ASC.CzechTesting.RunAllTests()
        local msg = "[Czech Testing] All tests " .. (success and "PASSED" or "FAILED")
        
        if IsValid(ply) then
            ply:ChatPrint(msg)
        else
            print(msg)
        end
    elseif testType == "player" and IsValid(ply) then
        local success = ASC.CzechTesting.TestPlayerIntegration(ply)
        ply:ChatPrint("[Czech Testing] Player integration " .. (success and "PASSED" or "FAILED"))
    elseif testType == "encoding" then
        -- Test encoding specifically
        local testText = "Testování českých znaků: áčďéěíňóřšťúůýž"
        local valid = ASC.Czech and ASC.Czech.ValidateUTF8 and ASC.Czech.ValidateUTF8(testText)
        local msg = "[Czech Testing] Encoding test: " .. (valid and "PASSED" or "FAILED")
        
        if IsValid(ply) then
            ply:ChatPrint(msg)
            ply:ChatPrint("Test text: " .. testText)
        else
            print(msg)
            print("Test text: " .. testText)
        end
    else
        local usage = "[Czech Testing] Usage: asc_test_czech [all|player|encoding]"
        if IsValid(ply) then
            ply:ChatPrint(usage)
        else
            print(usage)
        end
    end
end)

-- Auto-test on system load
if ASC.CzechTesting.Config.AutoTest then
    timer.Simple(5, function()
        print("[Czech Testing] Running automatic tests...")
        ASC.CzechTesting.RunAllTests()
    end)
end

-- Test when players join if enabled
if ASC.CzechTesting.Config.TestOnPlayerJoin then
    hook.Add("PlayerInitialSpawn", "ASC_CzechTesting_PlayerJoin", function(player)
        timer.Simple(5, function()
            if IsValid(player) then
                ASC.CzechTesting.TestPlayerIntegration(player)
            end
        end)
    end)
end

print("[Advanced Space Combat] Czech Language Testing System v1.0.0 Loaded")
