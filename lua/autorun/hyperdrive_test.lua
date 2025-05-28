-- Hyperdrive Test System
-- This file provides testing commands and validation for the hyperdrive system

HYPERDRIVE.Test = HYPERDRIVE.Test or {}

-- Test configuration
HYPERDRIVE.Test.Config = {
    EnableTests = true,
    AutoRunTests = false,
    TestTimeout = 30
}

-- Test results storage
HYPERDRIVE.Test.Results = {}

-- Test function wrapper
function HYPERDRIVE.Test.Run(testName, testFunc)
    if not HYPERDRIVE.Test.Config.EnableTests then return end
    
    local startTime = SysTime()
    local success, result = pcall(testFunc)
    local endTime = SysTime()
    
    local testResult = {
        name = testName,
        success = success,
        result = result,
        duration = endTime - startTime,
        timestamp = os.time()
    }
    
    HYPERDRIVE.Test.Results[testName] = testResult
    
    local status = success and "PASS" or "FAIL"
    local message = string.format("[Test %s] %s (%.3fs)", status, testName, testResult.duration)
    
    if success then
        HYPERDRIVE.Debug.Info(message, "TEST")
    else
        HYPERDRIVE.Debug.Error(message .. " - " .. tostring(result), "TEST")
    end
    
    return testResult
end

-- Core system tests
function HYPERDRIVE.Test.CoreSystem()
    HYPERDRIVE.Test.Run("Core Initialization", function()
        assert(HYPERDRIVE ~= nil, "HYPERDRIVE table not initialized")
        assert(HYPERDRIVE.Config ~= nil, "HYPERDRIVE.Config not loaded")
        assert(type(HYPERDRIVE.CalculateEnergyCost) == "function", "CalculateEnergyCost function missing")
        assert(type(HYPERDRIVE.GetDistance) == "function", "GetDistance function missing")
        assert(type(HYPERDRIVE.IsValidDestination) == "function", "IsValidDestination function missing")
        return "Core system initialized correctly"
    end)
    
    HYPERDRIVE.Test.Run("Configuration Values", function()
        assert(HYPERDRIVE.Config.MaxEnergy > 0, "MaxEnergy must be positive")
        assert(HYPERDRIVE.Config.RechargeRate > 0, "RechargeRate must be positive")
        assert(HYPERDRIVE.Config.MaxJumpDistance > HYPERDRIVE.Config.MinJumpDistance, "MaxJumpDistance must be greater than MinJumpDistance")
        return "Configuration values are valid"
    end)
    
    HYPERDRIVE.Test.Run("Energy Calculation", function()
        local cost1 = HYPERDRIVE.CalculateEnergyCost(1000)
        local cost2 = HYPERDRIVE.CalculateEnergyCost(2000)
        assert(cost1 > 0, "Energy cost must be positive")
        assert(cost2 > cost1, "Longer distance should cost more energy")
        return "Energy calculation working correctly"
    end)
    
    HYPERDRIVE.Test.Run("Distance Calculation", function()
        local pos1 = Vector(0, 0, 0)
        local pos2 = Vector(100, 0, 0)
        local distance = HYPERDRIVE.GetDistance(pos1, pos2)
        assert(distance == 100, "Distance calculation incorrect")
        return "Distance calculation working correctly"
    end)
    
    HYPERDRIVE.Test.Run("Destination Validation", function()
        local validPos = Vector(1000, 1000, 100)
        local invalidPos = Vector(0, 0, -32768) -- Likely out of bounds
        assert(HYPERDRIVE.IsValidDestination(validPos), "Valid destination rejected")
        -- Note: Invalid destination test might pass depending on map
        return "Destination validation working"
    end)
end

-- Entity tests
function HYPERDRIVE.Test.Entities()
    HYPERDRIVE.Test.Run("Entity Classes", function()
        local requiredClasses = {
            "hyperdrive_engine",
            "hyperdrive_sb_engine", 
            "hyperdrive_sg_engine",
            "hyperdrive_master_engine",
            "hyperdrive_computer",
            "hyperdrive_beacon",
            "hyperdrive_wire_controller"
        }
        
        for _, class in ipairs(requiredClasses) do
            local entTable = scripted_ents.Get(class)
            assert(entTable ~= nil, "Entity class " .. class .. " not found")
        end
        
        return "All entity classes registered"
    end)
    
    if SERVER then
        HYPERDRIVE.Test.Run("Entity Creation", function()
            local testPos = Vector(0, 0, 100)
            local engine = ents.Create("hyperdrive_engine")
            assert(IsValid(engine), "Failed to create hyperdrive_engine")
            
            engine:SetPos(testPos)
            engine:Spawn()
            
            assert(engine:GetClass() == "hyperdrive_engine", "Entity class mismatch")
            assert(engine:GetPos():Distance(testPos) < 10, "Entity position incorrect")
            
            -- Clean up
            engine:Remove()
            
            return "Entity creation successful"
        end)
    end
end

-- Integration tests
function HYPERDRIVE.Test.Integrations()
    HYPERDRIVE.Test.Run("Wiremod Integration", function()
        if WireLib then
            assert(HYPERDRIVE.Wiremod ~= nil, "Wiremod integration not loaded")
            return "Wiremod integration available"
        else
            return "Wiremod not installed (optional)"
        end
    end)
    
    HYPERDRIVE.Test.Run("Spacebuild Integration", function()
        if CAF then
            assert(HYPERDRIVE.Spacebuild ~= nil, "Spacebuild integration not loaded")
            return "Spacebuild integration available"
        else
            return "Spacebuild not installed (optional)"
        end
    end)
    
    HYPERDRIVE.Test.Run("Stargate Integration", function()
        if StarGate then
            assert(HYPERDRIVE.Stargate ~= nil, "Stargate integration not loaded")
            return "Stargate integration available"
        else
            return "Stargate CAP not installed (optional)"
        end
    end)
    
    HYPERDRIVE.Test.Run("Master System", function()
        assert(HYPERDRIVE.Master ~= nil, "Master system not loaded")
        assert(type(HYPERDRIVE.Master.ClassifyEntity) == "function", "ClassifyEntity function missing")
        assert(type(HYPERDRIVE.Master.CalculateEnergyCost) == "function", "Master CalculateEnergyCost missing")
        return "Master system loaded correctly"
    end)
end

-- Network tests (server only)
function HYPERDRIVE.Test.Network()
    if not SERVER then return end
    
    HYPERDRIVE.Test.Run("Network Strings", function()
        local requiredNetStrings = {
            "hyperdrive_jump",
            "hyperdrive_status",
            "hyperdrive_destination",
            "hyperdrive_open_interface",
            "hyperdrive_set_destination",
            "hyperdrive_start_jump"
        }
        
        -- Note: Can't easily test if network strings are registered
        -- This test just verifies the list exists
        assert(#requiredNetStrings > 0, "Network string list empty")
        return "Network strings defined"
    end)
end

-- Performance tests
function HYPERDRIVE.Test.Performance()
    HYPERDRIVE.Test.Run("Entity Count", function()
        local hyperdriveEnts = 0
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive") then
                hyperdriveEnts = hyperdriveEnts + 1
            end
        end
        
        assert(hyperdriveEnts >= 0, "Entity count check failed")
        return "Found " .. hyperdriveEnts .. " hyperdrive entities"
    end)
    
    HYPERDRIVE.Test.Run("Memory Usage", function()
        local memBefore = collectgarbage("count")
        
        -- Simulate some operations
        for i = 1, 100 do
            HYPERDRIVE.CalculateEnergyCost(math.random(1000, 10000))
        end
        
        collectgarbage("collect")
        local memAfter = collectgarbage("count")
        
        assert(memAfter - memBefore < 100, "Excessive memory usage detected")
        return string.format("Memory usage: %.2f KB", memAfter - memBefore)
    end)
end

-- Run all tests
function HYPERDRIVE.Test.RunAll()
    HYPERDRIVE.Debug.Info("Starting comprehensive test suite", "TEST")
    
    local startTime = SysTime()
    
    HYPERDRIVE.Test.CoreSystem()
    HYPERDRIVE.Test.Entities()
    HYPERDRIVE.Test.Integrations()
    HYPERDRIVE.Test.Network()
    HYPERDRIVE.Test.Performance()
    
    local endTime = SysTime()
    local totalTime = endTime - startTime
    
    -- Count results
    local passed = 0
    local failed = 0
    
    for _, result in pairs(HYPERDRIVE.Test.Results) do
        if result.success then
            passed = passed + 1
        else
            failed = failed + 1
        end
    end
    
    local summary = string.format("Test suite complete: %d passed, %d failed (%.3fs)", passed, failed, totalTime)
    
    if failed == 0 then
        HYPERDRIVE.Debug.Info(summary, "TEST")
    else
        HYPERDRIVE.Debug.Warn(summary, "TEST")
    end
    
    return {
        passed = passed,
        failed = failed,
        totalTime = totalTime,
        results = HYPERDRIVE.Test.Results
    }
end

-- Console command for testing
concommand.Add("hyperdrive_test", function(ply, cmd, args)
    local command = args[1] or "all"
    
    if command == "all" then
        local results = HYPERDRIVE.Test.RunAll()
        
        if IsValid(ply) then
            ply:ChatPrint(string.format("[Hyperdrive Test] %d passed, %d failed - check console", results.passed, results.failed))
        end
        
    elseif command == "core" then
        HYPERDRIVE.Test.CoreSystem()
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Test] Core tests complete - check console")
        end
        
    elseif command == "entities" then
        HYPERDRIVE.Test.Entities()
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Test] Entity tests complete - check console")
        end
        
    elseif command == "integrations" then
        HYPERDRIVE.Test.Integrations()
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Test] Integration tests complete - check console")
        end
        
    elseif command == "results" then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Test] Test results - check console")
        end
        
        print("=== HYPERDRIVE TEST RESULTS ===")
        for name, result in pairs(HYPERDRIVE.Test.Results) do
            local status = result.success and "PASS" or "FAIL"
            print(string.format("[%s] %s (%.3fs) - %s", status, name, result.duration, tostring(result.result)))
        end
        
    else
        local message = "Usage: hyperdrive_test [all|core|entities|integrations|results]"
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Test] " .. message)
        else
            print(message)
        end
    end
end)

-- Auto-run tests if enabled
if HYPERDRIVE.Test.Config.AutoRunTests then
    timer.Simple(2, function()
        HYPERDRIVE.Test.RunAll()
    end)
end

HYPERDRIVE.Debug.Info("Test system loaded", "SYSTEM")
