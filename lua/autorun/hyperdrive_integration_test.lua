-- Hyperdrive Integration Testing and Validation
-- Comprehensive testing system for SC2 and SB3 integration

if CLIENT then return end

-- Initialize testing system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.IntegrationTest = HYPERDRIVE.IntegrationTest or {}

print("[Hyperdrive] Integration testing system loading...")

-- Test configuration
HYPERDRIVE.IntegrationTest.Config = {
    AutoRunTests = false,           -- Automatically run tests on startup
    DetailedLogging = true,         -- Enable detailed test logging
    TestTimeout = 30,               -- Test timeout in seconds
    RequireAdmin = true,            -- Require admin to run tests
}

-- Test results storage
HYPERDRIVE.IntegrationTest.Results = {}

-- Test framework functions
function HYPERDRIVE.IntegrationTest.RunTest(testName, testFunction, description)
    local startTime = SysTime()
    local success, result = pcall(testFunction)
    local endTime = SysTime()
    local duration = endTime - startTime

    local testResult = {
        name = testName,
        description = description or "No description",
        success = success,
        result = result,
        duration = duration,
        timestamp = os.time()
    }

    HYPERDRIVE.IntegrationTest.Results[testName] = testResult

    if HYPERDRIVE.IntegrationTest.Config.DetailedLogging then
        local status = success and "PASS" or "FAIL"
        print(string.format("[Hyperdrive Test] %s: %s (%.3fs)", testName, status, duration))
        if not success then
            print(string.format("[Hyperdrive Test] Error: %s", tostring(result)))
        end
    end

    return testResult
end

-- Integration detection tests
function HYPERDRIVE.IntegrationTest.TestSpaceCombat2Detection()
    local detected = false
    local details = {}

    -- Check gamemode
    if GAMEMODE and GAMEMODE.Name == "Space Combat 2" then
        detected = true
        table.insert(details, "SC2 gamemode active")
    end

    -- Check file existence
    if file.Exists("gamemodes/spacecombat2/gamemode/init.lua", "GAME") then
        detected = true
        table.insert(details, "SC2 files detected")
    end

    -- Check for SC2 functions
    if SC_HasGenericPodLink then
        detected = true
        table.insert(details, "SC_HasGenericPodLink available")
    end

    -- Check for GetProtector metamethod
    local testEnt = ents.Create("prop_physics")
    if IsValid(testEnt) then
        if testEnt.GetProtector and type(testEnt.GetProtector) == "function" then
            table.insert(details, "GetProtector metamethod available")
            detected = true
        else
            table.insert(details, "GetProtector metamethod NOT available")
        end
        testEnt:Remove()
    end

    return detected, table.concat(details, ", ")
end

function HYPERDRIVE.IntegrationTest.TestSpacebuild3Detection()
    local detected = CAF ~= nil
    local details = {}

    if CAF then
        table.insert(details, "CAF framework detected")
        if CAF.GetEnvironment then
            table.insert(details, "Environment system available")
        end
        if CAF.GetValue then
            table.insert(details, "Resource system available")
        end
    end

    return detected, table.concat(details, ", ")
end

-- Entity detection tests
function HYPERDRIVE.IntegrationTest.TestEntityDetection()
    local results = {}

    -- Test SC2 entity detection
    if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.EnhancedEntityDetection then
        results.sc2_detection = "Available"
    else
        results.sc2_detection = "Not available"
    end

    -- Test SB3 entity detection
    if HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.GetAttachedEntities then
        results.sb3_detection = "Available"
    else
        results.sb3_detection = "Not available"
    end

    return true, string.format("SC2: %s, SB3: %s", results.sc2_detection, results.sb3_detection)
end

-- Movement system tests
function HYPERDRIVE.IntegrationTest.TestMovementSystems()
    local results = {}

    -- Test SC2 movement
    if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.MoveShip then
        results.sc2_movement = "Available"
    else
        results.sc2_movement = "Not available"
    end

    -- Test SB3 movement
    if HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.MoveShip then
        results.sb3_movement = "Available"
    else
        results.sb3_movement = "Not available"
    end

    return true, string.format("SC2: %s, SB3: %s", results.sc2_movement, results.sb3_movement)
end

-- Gravity system tests
function HYPERDRIVE.IntegrationTest.TestGravitySystems()
    local results = {}

    -- Test SC2 gravity override
    if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.OverrideGravity then
        results.sc2_gravity = "Available"
    else
        results.sc2_gravity = "Not available"
    end

    -- Test SB3 gravity override
    if HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity then
        results.sb3_gravity = "Available"
    else
        results.sb3_gravity = "Not available"
    end

    return true, string.format("SC2: %s, SB3: %s", results.sc2_gravity, results.sb3_gravity)
end

-- Configuration system tests
function HYPERDRIVE.IntegrationTest.TestConfigurationSystem()
    local results = {}

    -- Test enhanced config system
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        results.enhanced_config = "Available"

        -- Test configuration retrieval
        local testValue = HYPERDRIVE.EnhancedConfig.Get("SpaceCombat2", "UseGyropodMovement", false)
        results.config_retrieval = type(testValue) == "boolean" and "Working" or "Failed"
    else
        results.enhanced_config = "Not available"
        results.config_retrieval = "N/A"
    end

    return true, string.format("Enhanced Config: %s, Retrieval: %s", results.enhanced_config, results.config_retrieval)
end

-- Comprehensive integration test
function HYPERDRIVE.IntegrationTest.RunAllTests()
    print("[Hyperdrive Test] Running comprehensive integration tests...")

    -- Test GetProtector metamethod functionality
    function HYPERDRIVE.IntegrationTest.TestGetProtectorMethod()
        local results = {}

        -- Test if GetProtector metamethod is available
        local testEnt = ents.Create("prop_physics")
        if IsValid(testEnt) then
            if testEnt.GetProtector and type(testEnt.GetProtector) == "function" then
                results.metamethod = "Available"

                -- Test if it returns nil for unprotected entity
                local protector = testEnt:GetProtector()
                if protector == nil then
                    results.unprotected_test = "Passed"
                else
                    results.unprotected_test = "Failed (should return nil)"
                end
            else
                results.metamethod = "Not available"
                results.unprotected_test = "N/A"
            end
            testEnt:Remove()
        else
            results.metamethod = "Cannot test (entity creation failed)"
            results.unprotected_test = "N/A"
        end

        -- Test SC2 integration functions that use GetProtector
        if HYPERDRIVE.SpaceCombat2 then
            results.sc2_integration = "Available"
        else
            results.sc2_integration = "Not available"
        end

        return true, string.format("Metamethod: %s, Unprotected test: %s, SC2 integration: %s",
            results.metamethod, results.unprotected_test, results.sc2_integration)
    end

    local tests = {
        {"SC2_Detection", HYPERDRIVE.IntegrationTest.TestSpaceCombat2Detection, "Space Combat 2 detection"},
        {"SB3_Detection", HYPERDRIVE.IntegrationTest.TestSpacebuild3Detection, "Spacebuild 3 detection"},
        {"GetProtector_Method", HYPERDRIVE.IntegrationTest.TestGetProtectorMethod, "GetProtector metamethod functionality"},
        {"Entity_Detection", HYPERDRIVE.IntegrationTest.TestEntityDetection, "Entity detection systems"},
        {"Movement_Systems", HYPERDRIVE.IntegrationTest.TestMovementSystems, "Movement optimization systems"},
        {"Gravity_Systems", HYPERDRIVE.IntegrationTest.TestGravitySystems, "Gravity override systems"},
        {"Configuration", HYPERDRIVE.IntegrationTest.TestConfigurationSystem, "Configuration system"},
    }

    local totalTests = #tests
    local passedTests = 0

    for _, test in ipairs(tests) do
        local result = HYPERDRIVE.IntegrationTest.RunTest(test[1], test[2], test[3])
        if result.success then
            passedTests = passedTests + 1
        end
    end

    print(string.format("[Hyperdrive Test] Tests completed: %d/%d passed", passedTests, totalTests))

    return passedTests, totalTests
end

-- Console commands for testing
concommand.Add("hyperdrive_test_all", function(ply, cmd, args)
    if IsValid(ply) and HYPERDRIVE.IntegrationTest.Config.RequireAdmin and not ply:IsAdmin() then
        ply:ChatPrint("[Hyperdrive Test] Admin access required!")
        return
    end

    local passed, total = HYPERDRIVE.IntegrationTest.RunAllTests()

    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end

    sendMessage("[Hyperdrive Test] Integration Test Results:")
    sendMessage(string.format("  • Tests Passed: %d/%d", passed, total))

    for testName, result in pairs(HYPERDRIVE.IntegrationTest.Results) do
        local status = result.success and "✓" or "✗"
        sendMessage(string.format("  • %s %s: %s", status, testName, result.result))
    end
end)

concommand.Add("hyperdrive_test_single", function(ply, cmd, args)
    if IsValid(ply) and HYPERDRIVE.IntegrationTest.Config.RequireAdmin and not ply:IsAdmin() then
        ply:ChatPrint("[Hyperdrive Test] Admin access required!")
        return
    end

    if #args < 1 then
        local target = IsValid(ply) and ply or nil
        local function sendMessage(msg)
            if target then
                target:ChatPrint(msg)
            else
                print(msg)
            end
        end

        sendMessage("[Hyperdrive Test] Available tests:")
        sendMessage("  • SC2_Detection - Test Space Combat 2 detection")
        sendMessage("  • SB3_Detection - Test Spacebuild 3 detection")
        sendMessage("  • Entity_Detection - Test entity detection systems")
        sendMessage("  • Movement_Systems - Test movement systems")
        sendMessage("  • Gravity_Systems - Test gravity systems")
        sendMessage("  • Configuration - Test configuration system")
        return
    end

    local testName = args[1]
    local testFunctions = {
        SC2_Detection = HYPERDRIVE.IntegrationTest.TestSpaceCombat2Detection,
        SB3_Detection = HYPERDRIVE.IntegrationTest.TestSpacebuild3Detection,
        Entity_Detection = HYPERDRIVE.IntegrationTest.TestEntityDetection,
        Movement_Systems = HYPERDRIVE.IntegrationTest.TestMovementSystems,
        Gravity_Systems = HYPERDRIVE.IntegrationTest.TestGravitySystems,
        Configuration = HYPERDRIVE.IntegrationTest.TestConfigurationSystem,
    }

    if testFunctions[testName] then
        local result = HYPERDRIVE.IntegrationTest.RunTest(testName, testFunctions[testName])
        local status = result.success and "PASSED" or "FAILED"

        local target = IsValid(ply) and ply or nil
        local function sendMessage(msg)
            if target then
                target:ChatPrint(msg)
            else
                print(msg)
            end
        end

        sendMessage(string.format("[Hyperdrive Test] %s: %s", testName, status))
        sendMessage(string.format("  Result: %s", result.result))
        sendMessage(string.format("  Duration: %.3fs", result.duration))
    else
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Test] Unknown test: " .. testName)
        else
            print("[Hyperdrive Test] Unknown test: " .. testName)
        end
    end
end)

-- Auto-run tests if configured
if HYPERDRIVE.IntegrationTest.Config.AutoRunTests then
    timer.Simple(5, function()
        HYPERDRIVE.IntegrationTest.RunAllTests()
    end)
end

print("[Hyperdrive] Integration testing system loaded")
