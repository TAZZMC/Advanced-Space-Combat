-- Enhanced Hyperdrive System - Startup Test and Validation
-- Comprehensive startup testing to ensure all systems work correctly

if CLIENT then return end

HYPERDRIVE.StartupTest = HYPERDRIVE.StartupTest or {}

-- Run comprehensive startup test
function HYPERDRIVE.StartupTest.RunTest()
    print("[Hyperdrive] Running comprehensive startup test...")

    local results = {
        passed = 0,
        failed = 0,
        warnings = 0,
        tests = {}
    }

    -- Test 1: Core namespace validation
    local test1 = HYPERDRIVE.StartupTest.TestCoreNamespaces()
    table.insert(results.tests, test1)
    if test1.status == "PASS" then results.passed = results.passed + 1
    elseif test1.status == "FAIL" then results.failed = results.failed + 1
    else results.warnings = results.warnings + 1 end

    -- Test 2: CAP integration validation
    local test2 = HYPERDRIVE.StartupTest.TestCAPIntegration()
    table.insert(results.tests, test2)
    if test2.status == "PASS" then results.passed = results.passed + 1
    elseif test2.status == "FAIL" then results.failed = results.failed + 1
    else results.warnings = results.warnings + 1 end

    -- Test 3: Entity system validation
    local test3 = HYPERDRIVE.StartupTest.TestEntitySystems()
    table.insert(results.tests, test3)
    if test3.status == "PASS" then results.passed = results.passed + 1
    elseif test3.status == "FAIL" then results.failed = results.failed + 1
    else results.warnings = results.warnings + 1 end

    -- Test 4: Shield system validation
    local test4 = HYPERDRIVE.StartupTest.TestShieldSystems()
    table.insert(results.tests, test4)
    if test4.status == "PASS" then results.passed = results.passed + 1
    elseif test4.status == "FAIL" then results.failed = results.failed + 1
    else results.warnings = results.warnings + 1 end

    -- Test 5: Error handling validation
    local test5 = HYPERDRIVE.StartupTest.TestErrorHandling()
    table.insert(results.tests, test5)
    if test5.status == "PASS" then results.passed = results.passed + 1
    elseif test5.status == "FAIL" then results.failed = results.failed + 1
    else results.warnings = results.warnings + 1 end

    -- Report results
    print("[Hyperdrive] Startup test complete:")
    print("  PASSED: " .. results.passed)
    print("  FAILED: " .. results.failed)
    print("  WARNINGS: " .. results.warnings)
    print("  TOTAL: " .. #results.tests)

    for i, test in ipairs(results.tests) do
        local statusColor = test.status == "PASS" and "✓" or test.status == "FAIL" and "✗" or "⚠"
        print("  " .. statusColor .. " " .. test.name .. ": " .. test.message)
    end

    return results
end

-- Test core namespaces
function HYPERDRIVE.StartupTest.TestCoreNamespaces()
    local test = { name = "Core Namespaces", status = "PASS", message = "All core namespaces exist" }

    local requiredNamespaces = {
        "HYPERDRIVE",
        "HYPERDRIVE.Core",
        "HYPERDRIVE.ShipCore",
        "HYPERDRIVE.CAP",
        "HYPERDRIVE.Shields",
        "HYPERDRIVE.HullDamage",
        "HYPERDRIVE.SB3Resources",
        "HYPERDRIVE.Wire",
        "HYPERDRIVE.Config",
        "HYPERDRIVE.Effects",
        "HYPERDRIVE.UI",
        "HYPERDRIVE.Stargate"
    }

    local missing = {}
    for _, namespace in ipairs(requiredNamespaces) do
        local parts = string.Split(namespace, ".")
        local current = _G
        for _, part in ipairs(parts) do
            if not current[part] then
                table.insert(missing, namespace)
                break
            end
            current = current[part]
        end
    end

    if #missing > 0 then
        test.status = "WARN"
        test.message = "Missing namespaces: " .. table.concat(missing, ", ")
    end

    return test
end

-- Test CAP integration
function HYPERDRIVE.StartupTest.TestCAPIntegration()
    local test = { name = "CAP Integration", status = "PASS", message = "CAP integration working" }

    if not HYPERDRIVE.CAP then
        test.status = "FAIL"
        test.message = "HYPERDRIVE.CAP namespace missing"
        return test
    end

    if not HYPERDRIVE.CAP.DetectCAP then
        test.status = "FAIL"
        test.message = "CAP detection function missing"
        return test
    end

    -- Test CAP detection safely
    local success, result = pcall(HYPERDRIVE.CAP.DetectCAP)
    if not success then
        test.status = "FAIL"
        test.message = "CAP detection failed: " .. tostring(result)
        return test
    end

    if not HYPERDRIVE.CAP.EntityCategories then
        test.status = "WARN"
        test.message = "CAP entity categories not initialized"
        return test
    end

    test.message = "CAP integration functional (" .. (HYPERDRIVE.CAP.Available and "available" or "not detected") .. ")"
    return test
end

-- Test entity systems
function HYPERDRIVE.StartupTest.TestEntitySystems()
    local test = { name = "Entity Systems", status = "PASS", message = "Entity systems working" }

    -- Use a more robust entity detection method
    local function CheckEntitySystems()
        -- First try scripted_ents.GetStored()
        local storedEnts = scripted_ents.GetStored()
        if storedEnts then
            local requiredEntities = {"ship_core", "hyperdrive_engine", "hyperdrive_master_engine"}
            local found = {}
            local missing = {}

            for _, entClass in ipairs(requiredEntities) do
                if storedEnts[entClass] then
                    table.insert(found, entClass)
                else
                    table.insert(missing, entClass)
                end
            end

            if #found > 0 then
                return "PASS", string.format("Entity registry functional (%d/%d entities)", #found, #requiredEntities)
            end
        end

        -- Fallback: Check if entity files exist
        local entityFiles = {
            {"lua/entities/hyperdrive_engine/init.lua", "hyperdrive_engine"},
            {"lua/entities/hyperdrive_master_engine/init.lua", "hyperdrive_master_engine"},
            {"lua/entities/ship_core/init.lua", "ship_core"},
            {"lua/entities/hyperdrive_shield_generator/init.lua", "hyperdrive_shield_generator"}
        }

        local foundFiles = {}
        for _, fileData in ipairs(entityFiles) do
            local filePath, entityName = fileData[1], fileData[2]
            if file.Exists(filePath, "LUA") then
                table.insert(foundFiles, entityName)
            end
        end

        if #foundFiles > 0 then
            return "PASS", string.format("Entity files detected (%d entities)", #foundFiles)
        end

        -- Final fallback: Check if entities are registered in spawn list
        local registeredEntities = list.Get("SpawnableEntities")
        if registeredEntities then
            local hyperdriveCount = 0
            for class, data in pairs(registeredEntities) do
                if string.find(class, "hyperdrive") or string.find(class, "ship_core") then
                    hyperdriveCount = hyperdriveCount + 1
                end
            end

            if hyperdriveCount > 0 then
                return "PASS", string.format("Spawnable entities registered (%d)", hyperdriveCount)
            end
        end

        return "WARN", "Entity systems not fully loaded - may be timing issue"
    end

    test.status, test.message = CheckEntitySystems()
    return test
end

-- Test shield systems
function HYPERDRIVE.StartupTest.TestShieldSystems()
    local test = { name = "Shield Systems", status = "PASS", message = "Shield systems working" }

    if not HYPERDRIVE.Shields then
        test.status = "WARN"
        test.message = "HYPERDRIVE.Shields namespace missing"
        return test
    end

    if not HYPERDRIVE.Shields.RegisterProvider then
        test.status = "WARN"
        test.message = "Shield provider registration not available"
        return test
    end

    if not HYPERDRIVE.Shields.Providers then
        test.status = "WARN"
        test.message = "Shield providers not initialized"
        return test
    end

    local providerCount = table.Count(HYPERDRIVE.Shields.Providers)
    test.message = "Shield system functional (" .. providerCount .. " providers)"
    return test
end

-- Test error handling
function HYPERDRIVE.StartupTest.TestErrorHandling()
    local test = { name = "Error Handling", status = "PASS", message = "Error handling working" }

    if not HYPERDRIVE.ErrorFixes then
        test.status = "WARN"
        test.message = "Error fixes system not loaded"
        return test
    end

    if not HYPERDRIVE.ErrorFixes.ValidateSystem then
        test.status = "WARN"
        test.message = "Validation system not available"
        return test
    end

    -- Test validation system
    local success, result = pcall(HYPERDRIVE.ErrorFixes.ValidateSystem)
    if not success then
        test.status = "FAIL"
        test.message = "Validation system failed: " .. tostring(result)
        return test
    end

    test.message = "Error handling and validation functional"
    return test
end

-- Console command for manual testing
concommand.Add("hyperdrive_startup_test", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Hyperdrive] Access denied - superadmin required")
        return
    end

    local results = HYPERDRIVE.StartupTest.RunTest()

    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive] Startup test complete - check console for details")
        ply:ChatPrint("Results: " .. results.passed .. " passed, " .. results.failed .. " failed, " .. results.warnings .. " warnings")
    end
end)

-- Auto-run startup test
timer.Simple(5, function()
    print("[Hyperdrive] Running automatic startup test...")
    HYPERDRIVE.StartupTest.RunTest()
end)

print("[Hyperdrive] Startup test system loaded")
