-- Hyperdrive CAP Integration Testing System
-- Comprehensive testing framework for Carter Addon Pack integration

if CLIENT then return end

-- Initialize testing system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.CAP = HYPERDRIVE.CAP or {}
HYPERDRIVE.CAP.Testing = HYPERDRIVE.CAP.Testing or {}

print("[Hyperdrive] CAP Integration Testing System loading...")

-- Test registry
HYPERDRIVE.CAP.Testing.Tests = {}
HYPERDRIVE.CAP.Testing.Results = {}
HYPERDRIVE.CAP.Testing.LastRun = 0

-- Test result structure
local function CreateTestResult(name, success, message, details)
    return {
        name = name,
        success = success,
        message = message,
        details = details or {},
        timestamp = CurTime(),
        duration = 0
    }
end

-- Register a CAP integration test
function HYPERDRIVE.CAP.Testing.RegisterTest(name, description, testFunction)
    HYPERDRIVE.CAP.Testing.Tests[name] = {
        name = name,
        description = description,
        testFunction = testFunction,
        category = "CAP_Integration"
    }
end

-- Run a specific CAP test
function HYPERDRIVE.CAP.Testing.RunTest(testName)
    local test = HYPERDRIVE.CAP.Testing.Tests[testName]
    if not test then
        return CreateTestResult(testName, false, "Test not found")
    end
    
    local startTime = SysTime()
    local success, result = pcall(test.testFunction)
    local duration = SysTime() - startTime
    
    if not success then
        result = CreateTestResult(testName, false, "Test execution failed: " .. tostring(result))
    elseif type(result) ~= "table" then
        result = CreateTestResult(testName, success, tostring(result))
    end
    
    result.duration = duration
    HYPERDRIVE.CAP.Testing.Results[testName] = result
    
    return result
end

-- Run all CAP integration tests
function HYPERDRIVE.CAP.Testing.RunAllTests()
    local results = {}
    local totalTests = 0
    local passedTests = 0
    
    print("[Hyperdrive CAP Testing] Running all CAP integration tests...")
    
    for testName, test in pairs(HYPERDRIVE.CAP.Testing.Tests) do
        totalTests = totalTests + 1
        local result = HYPERDRIVE.CAP.Testing.RunTest(testName)
        
        if result.success then
            passedTests = passedTests + 1
            print("  ✓ " .. testName .. " - " .. result.message)
        else
            print("  ✗ " .. testName .. " - " .. result.message)
        end
        
        table.insert(results, result)
    end
    
    HYPERDRIVE.CAP.Testing.LastRun = CurTime()
    
    print("[Hyperdrive CAP Testing] Completed: " .. passedTests .. "/" .. totalTests .. " tests passed")
    return results, passedTests, totalTests
end

-- CAP Framework Detection Test
HYPERDRIVE.CAP.Testing.RegisterTest("CAP_Framework_Detection", 
    "Test CAP framework detection and availability",
    function()
        local isLoaded, status, details = HYPERDRIVE.CAP.IsCAP_Loaded()
        
        if not isLoaded then
            return CreateTestResult("CAP_Framework_Detection", false, 
                "CAP framework not detected: " .. status)
        end
        
        local testDetails = {
            status = status,
            core_functions = details.core,
            shield_system = details.shields,
            tracing_system = details.tracing,
            event_horizon = details.eventHorizon,
            version = details.version
        }
        
        return CreateTestResult("CAP_Framework_Detection", true, 
            "CAP framework detected successfully", testDetails)
    end
)

-- Entity Detection Test
HYPERDRIVE.CAP.Testing.RegisterTest("CAP_Entity_Detection",
    "Test CAP entity detection and categorization",
    function()
        -- Create a test engine for detection
        local testEngine = ents.Create("prop_physics")
        if not IsValid(testEngine) then
            return CreateTestResult("CAP_Entity_Detection", false, "Failed to create test engine")
        end
        
        testEngine:SetPos(Vector(0, 0, 0))
        testEngine:Spawn()
        
        -- Run entity detection
        local entities = HYPERDRIVE.CAP.DetectCAPEntities(testEngine, 5000)
        
        -- Count entities by category
        local categoryCounts = {
            stargates = #HYPERDRIVE.CAP.State.detectedStargates,
            shields = #HYPERDRIVE.CAP.State.detectedShields,
            dhds = #HYPERDRIVE.CAP.State.detectedDHDs
        }
        
        -- Clean up
        testEngine:Remove()
        
        local totalDetected = categoryCounts.stargates + categoryCounts.shields + categoryCounts.dhds
        
        return CreateTestResult("CAP_Entity_Detection", true,
            "Detected " .. totalDetected .. " CAP entities", categoryCounts)
    end
)

-- Shield System Test
HYPERDRIVE.CAP.Testing.RegisterTest("CAP_Shield_System",
    "Test CAP shield system integration",
    function()
        if not StarGate or not StarGate.IsEntityShielded then
            return CreateTestResult("CAP_Shield_System", false, 
                "CAP shield functions not available")
        end
        
        -- Test shield detection at various positions
        local testPositions = {
            Vector(0, 0, 0),
            Vector(1000, 0, 0),
            Vector(0, 1000, 0),
            Vector(0, 0, 1000)
        }
        
        local shieldTests = {}
        for i, pos in ipairs(testPositions) do
            local isShielded = HYPERDRIVE.CAP.IsPositionShielded(pos)
            table.insert(shieldTests, {
                position = pos,
                shielded = isShielded
            })
        end
        
        return CreateTestResult("CAP_Shield_System", true,
            "Shield system tests completed", {tests = shieldTests})
    end
)

-- Energy System Test
HYPERDRIVE.CAP.Testing.RegisterTest("CAP_Energy_System",
    "Test CAP energy system integration",
    function()
        -- Create a test engine
        local testEngine = ents.Create("prop_physics")
        if not IsValid(testEngine) then
            return CreateTestResult("CAP_Energy_System", false, "Failed to create test engine")
        end
        
        testEngine:SetPos(Vector(0, 0, 0))
        testEngine:Spawn()
        
        -- Test energy sharing
        local hasEnergy, availableEnergy = HYPERDRIVE.CAP.ManageEnergySharing(testEngine, 1000)
        
        -- Clean up
        testEngine:Remove()
        
        return CreateTestResult("CAP_Energy_System", true,
            "Energy system test completed", {
                has_energy = hasEnergy,
                available_energy = availableEnergy
            })
    end
)

-- Stargate Network Test
HYPERDRIVE.CAP.Testing.RegisterTest("CAP_Stargate_Network",
    "Test Stargate network integration",
    function()
        local destinations = HYPERDRIVE.CAP.GetStargateDestinations()
        
        local networkData = {
            total_destinations = #destinations,
            destinations = {}
        }
        
        for i, dest in ipairs(destinations) do
            if i <= 5 then -- Limit for testing
                table.insert(networkData.destinations, {
                    name = dest.name,
                    address = dest.address,
                    type = dest.type
                })
            end
        end
        
        return CreateTestResult("CAP_Stargate_Network", true,
            "Found " .. #destinations .. " Stargate destinations", networkData)
    end
)

-- Address Resolution Test
HYPERDRIVE.CAP.Testing.RegisterTest("CAP_Address_Resolution",
    "Test Stargate address resolution",
    function()
        local destinations = HYPERDRIVE.CAP.GetStargateDestinations()
        local resolutionTests = {}
        
        -- Test address resolution for first few destinations
        for i, dest in ipairs(destinations) do
            if i > 3 then break end -- Limit tests
            
            local resolved = HYPERDRIVE.CAP.ResolveStargateAddress(dest.address)
            table.insert(resolutionTests, {
                address = dest.address,
                resolved = resolved ~= nil,
                status = resolved and resolved.status or "not_found"
            })
        end
        
        return CreateTestResult("CAP_Address_Resolution", true,
            "Address resolution tests completed", {tests = resolutionTests})
    end
)

-- Conflict Detection Test
HYPERDRIVE.CAP.Testing.RegisterTest("CAP_Conflict_Detection",
    "Test Stargate conflict detection",
    function()
        -- Create test engine
        local testEngine = ents.Create("prop_physics")
        if not IsValid(testEngine) then
            return CreateTestResult("CAP_Conflict_Detection", false, "Failed to create test engine")
        end
        
        testEngine:SetPos(Vector(0, 0, 0))
        testEngine:Spawn()
        
        -- Test conflict detection
        local hasConflicts, conflicts = HYPERDRIVE.CAP.CheckStargateConflicts(testEngine, Vector(1000, 0, 0))
        
        -- Clean up
        testEngine:Remove()
        
        return CreateTestResult("CAP_Conflict_Detection", true,
            "Conflict detection completed", {
                has_conflicts = hasConflicts,
                conflict_count = #conflicts
            })
    end
)

-- Configuration Test
HYPERDRIVE.CAP.Testing.RegisterTest("CAP_Configuration",
    "Test CAP configuration system",
    function()
        local configTests = {}
        
        -- Test key configuration options
        local configKeys = {
            "Enabled", "UseStargateNetwork", "RespectShields", 
            "ShareEnergyWithStargates", "PreventConflicts"
        }
        
        for _, key in ipairs(configKeys) do
            local value = HYPERDRIVE.CAP.Config[key]
            table.insert(configTests, {
                key = key,
                value = value,
                type = type(value)
            })
        end
        
        return CreateTestResult("CAP_Configuration", true,
            "Configuration tests completed", {tests = configTests})
    end
)

-- Console command for running CAP tests
concommand.Add("hyperdrive_cap_test_all", function(ply, cmd, args)
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    sendMessage("[Hyperdrive CAP Testing] Starting comprehensive CAP integration tests...")
    
    local results, passed, total = HYPERDRIVE.CAP.Testing.RunAllTests()
    
    sendMessage("[Hyperdrive CAP Testing] Test Results Summary:")
    sendMessage("  • Total Tests: " .. total)
    sendMessage("  • Passed: " .. passed)
    sendMessage("  • Failed: " .. (total - passed))
    sendMessage("  • Success Rate: " .. math.floor((passed / total) * 100) .. "%")
    
    -- Show failed tests
    for _, result in ipairs(results) do
        if not result.success then
            sendMessage("  • FAILED: " .. result.name .. " - " .. result.message)
        end
    end
end)

concommand.Add("hyperdrive_cap_test_single", function(ply, cmd, args)
    if not args[1] then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive CAP Testing] Usage: hyperdrive_cap_test_single <test_name>")
        end
        return
    end
    
    local testName = args[1]
    local result = HYPERDRIVE.CAP.Testing.RunTest(testName)
    
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end
    
    sendMessage("[Hyperdrive CAP Testing] Test: " .. testName)
    sendMessage("  • Result: " .. (result.success and "PASSED" or "FAILED"))
    sendMessage("  • Message: " .. result.message)
    sendMessage("  • Duration: " .. string.format("%.3f", result.duration) .. "s")
    
    if result.details and table.Count(result.details) > 0 then
        sendMessage("  • Details: " .. util.TableToJSON(result.details))
    end
end)

print("[Hyperdrive] CAP Integration Testing System loaded successfully")
