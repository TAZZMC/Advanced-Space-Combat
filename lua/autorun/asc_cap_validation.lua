-- Advanced Space Combat - CAP Integration Validation System v3.0
-- Comprehensive testing and validation for CAP integration
-- Ensures all CAP systems work correctly and provides diagnostics

print("[Advanced Space Combat] CAP Integration Validation System v3.0 - Loading...")

-- Initialize validation namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.Validation = ASC.CAP.Validation or {}

-- Validation configuration
ASC.CAP.Validation.Config = {
    EnableAutoValidation = true,
    EnablePerformanceTesting = true,
    EnableCompatibilityChecks = true,
    ValidationInterval = 30.0,
    MaxValidationTime = 5.0,
    
    -- Test settings
    EnableEntityTests = true,
    EnableCommunicationTests = true,
    EnableResourceTests = true,
    EnableFallbackTests = true
}

-- Validation results storage
ASC.CAP.Validation.Results = {
    lastValidation = 0,
    overallStatus = "Unknown",
    detectionStatus = "Unknown",
    communicationStatus = "Unknown",
    resourceStatus = "Unknown",
    fallbackStatus = "Unknown",
    performanceMetrics = {},
    errors = {},
    warnings = {}
}

-- Validation test suite
ASC.CAP.Validation.Tests = {}

-- Test CAP detection system
function ASC.CAP.Validation.Tests.DetectionSystem()
    local results = {
        passed = 0,
        failed = 0,
        errors = {},
        warnings = {}
    }
    
    -- Test 1: Basic CAP availability
    if HYPERDRIVE.CAP and HYPERDRIVE.CAP.Available then
        results.passed = results.passed + 1
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "HYPERDRIVE.CAP not available")
    end
    
    -- Test 2: CAP detection function
    if HYPERDRIVE.CAP.DetectCAP then
        local success, detection = pcall(HYPERDRIVE.CAP.DetectCAP)
        if success and detection then
            results.passed = results.passed + 1
        else
            results.failed = results.failed + 1
            table.insert(results.errors, "CAP detection function failed")
        end
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "CAP detection function missing")
    end
    
    -- Test 3: Entity category detection
    if HYPERDRIVE.CAP.GetEntityCategory then
        local testClasses = {"stargate_sg1", "shield_core_buble", "zpm"}
        for _, className in ipairs(testClasses) do
            local category = HYPERDRIVE.CAP.GetEntityCategory(className)
            if category then
                results.passed = results.passed + 1
            else
                results.failed = results.failed + 1
                table.insert(results.warnings, "Entity category not detected for: " .. className)
            end
        end
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "Entity category detection function missing")
    end
    
    -- Test 4: Enhanced detection (if available)
    if ASC.CAP.Enhanced and ASC.CAP.Enhanced.DetectCAPEntities then
        local success, entities = pcall(ASC.CAP.Enhanced.DetectCAPEntities, false)
        if success then
            results.passed = results.passed + 1
            if entities and #entities > 0 then
                table.insert(results.warnings, "Enhanced detection found " .. #entities .. " CAP entities")
            end
        else
            results.failed = results.failed + 1
            table.insert(results.errors, "Enhanced CAP detection failed")
        end
    end
    
    return results
end

-- Test CAP communication system
function ASC.CAP.Validation.Tests.CommunicationSystem()
    local results = {
        passed = 0,
        failed = 0,
        errors = {},
        warnings = {}
    }
    
    -- Test 1: Communication system availability
    if ASC.CAP.Communication then
        results.passed = results.passed + 1
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "CAP communication system not available")
        return results
    end
    
    -- Test 2: Protocol definitions
    if ASC.CAP.Communication.Protocols then
        local requiredProtocols = {"STARGATE", "SHIELD", "ENERGY", "TRANSPORT"}
        for _, protocol in ipairs(requiredProtocols) do
            if ASC.CAP.Communication.Protocols[protocol] then
                results.passed = results.passed + 1
            else
                results.failed = results.failed + 1
                table.insert(results.errors, "Missing communication protocol: " .. protocol)
            end
        end
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "Communication protocols not defined")
    end
    
    -- Test 3: Core communication functions
    local coreFunctions = {"SendCommand", "GetProperty", "SetProperty", "ControlEntity"}
    for _, funcName in ipairs(coreFunctions) do
        if ASC.CAP.Communication[funcName] then
            results.passed = results.passed + 1
        else
            results.failed = results.failed + 1
            table.insert(results.errors, "Missing communication function: " .. funcName)
        end
    end
    
    return results
end

-- Test CAP resource system
function ASC.CAP.Validation.Tests.ResourceSystem()
    local results = {
        passed = 0,
        failed = 0,
        errors = {},
        warnings = {}
    }
    
    -- Test 1: Basic resource system
    if HYPERDRIVE.CAP.Resources then
        results.passed = results.passed + 1
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "CAP resource system not available")
    end
    
    -- Test 2: Enhanced resource bridging
    if ASC.CAP.Enhanced and ASC.CAP.Enhanced.ResourceBridge then
        results.passed = results.passed + 1
        
        -- Test conversion rates
        if ASC.CAP.Enhanced.ResourceBridge.ConversionRates then
            results.passed = results.passed + 1
        else
            results.failed = results.failed + 1
            table.insert(results.errors, "Resource conversion rates not defined")
        end
    else
        table.insert(results.warnings, "Enhanced resource bridging not available")
    end
    
    -- Test 3: Shield system
    if HYPERDRIVE.CAP.Shields then
        results.passed = results.passed + 1
        
        local shieldFunctions = {"FindShields", "Activate", "Deactivate"}
        for _, funcName in ipairs(shieldFunctions) do
            if HYPERDRIVE.CAP.Shields[funcName] then
                results.passed = results.passed + 1
            else
                results.failed = results.failed + 1
                table.insert(results.errors, "Missing shield function: " .. funcName)
            end
        end
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "CAP shield system not available")
    end
    
    return results
end

-- Test CAP fallback system
function ASC.CAP.Validation.Tests.FallbackSystem()
    local results = {
        passed = 0,
        failed = 0,
        errors = {},
        warnings = {}
    }
    
    -- Test 1: Fallback system availability
    if ASC.CAP.Fallback then
        results.passed = results.passed + 1
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "CAP fallback system not available")
        return results
    end
    
    -- Test 2: Fallback resources
    if ASC.CAP.Fallback.Resources then
        local resourceTypes = {"sounds", "materials", "models"}
        for _, resType in ipairs(resourceTypes) do
            if ASC.CAP.Fallback.Resources[resType] then
                results.passed = results.passed + 1
            else
                results.failed = results.failed + 1
                table.insert(results.errors, "Missing fallback resources: " .. resType)
            end
        end
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "Fallback resources not defined")
    end
    
    -- Test 3: Virtual entity system
    if ASC.CAP.Fallback.CreateVirtualEntity then
        results.passed = results.passed + 1
    else
        results.failed = results.failed + 1
        table.insert(results.errors, "Virtual entity system not available")
    end
    
    -- Test 4: Fallback integration
    if HYPERDRIVE.CAP.Fallback then
        results.passed = results.passed + 1
        table.insert(results.warnings, "System is running on fallback CAP integration")
    end
    
    return results
end

-- Run comprehensive validation
function ASC.CAP.Validation.RunValidation()
    local startTime = CurTime()
    local overallResults = {
        detection = {},
        communication = {},
        resource = {},
        fallback = {},
        performance = {}
    }
    
    print("[ASC CAP Validation] Starting comprehensive CAP integration validation...")
    
    -- Run detection tests
    if ASC.CAP.Validation.Config.EnableEntityTests then
        overallResults.detection = ASC.CAP.Validation.Tests.DetectionSystem()
    end
    
    -- Run communication tests
    if ASC.CAP.Validation.Config.EnableCommunicationTests then
        overallResults.communication = ASC.CAP.Validation.Tests.CommunicationSystem()
    end
    
    -- Run resource tests
    if ASC.CAP.Validation.Config.EnableResourceTests then
        overallResults.resource = ASC.CAP.Validation.Tests.ResourceSystem()
    end
    
    -- Run fallback tests
    if ASC.CAP.Validation.Config.EnableFallbackTests then
        overallResults.fallback = ASC.CAP.Validation.Tests.FallbackSystem()
    end
    
    -- Calculate performance metrics
    local validationTime = CurTime() - startTime
    overallResults.performance = {
        validationTime = validationTime,
        timestamp = os.date("%Y-%m-%d %H:%M:%S")
    }
    
    -- Store results
    ASC.CAP.Validation.Results = overallResults
    ASC.CAP.Validation.Results.lastValidation = CurTime()
    
    -- Generate summary
    ASC.CAP.Validation.GenerateSummary(overallResults)
    
    return overallResults
end

-- Generate validation summary
function ASC.CAP.Validation.GenerateSummary(results)
    local totalPassed = 0
    local totalFailed = 0
    local totalErrors = {}
    local totalWarnings = {}
    
    -- Aggregate results
    for category, categoryResults in pairs(results) do
        if categoryResults.passed then
            totalPassed = totalPassed + categoryResults.passed
        end
        if categoryResults.failed then
            totalFailed = totalFailed + categoryResults.failed
        end
        if categoryResults.errors then
            for _, error in ipairs(categoryResults.errors) do
                table.insert(totalErrors, category .. ": " .. error)
            end
        end
        if categoryResults.warnings then
            for _, warning in ipairs(categoryResults.warnings) do
                table.insert(totalWarnings, category .. ": " .. warning)
            end
        end
    end
    
    -- Determine overall status
    local overallStatus = "PASS"
    if totalFailed > 0 then
        overallStatus = "FAIL"
    elseif #totalWarnings > 0 then
        overallStatus = "WARN"
    end
    
    -- Print summary
    print("[ASC CAP Validation] ========== VALIDATION SUMMARY ==========")
    print("[ASC CAP Validation] Overall Status: " .. overallStatus)
    print("[ASC CAP Validation] Tests Passed: " .. totalPassed)
    print("[ASC CAP Validation] Tests Failed: " .. totalFailed)
    print("[ASC CAP Validation] Validation Time: " .. string.format("%.3fs", results.performance.validationTime or 0))
    
    if #totalErrors > 0 then
        print("[ASC CAP Validation] ERRORS:")
        for _, error in ipairs(totalErrors) do
            print("[ASC CAP Validation]   - " .. error)
        end
    end
    
    if #totalWarnings > 0 then
        print("[ASC CAP Validation] WARNINGS:")
        for _, warning in ipairs(totalWarnings) do
            print("[ASC CAP Validation]   - " .. warning)
        end
    end
    
    print("[ASC CAP Validation] ==========================================")
    
    -- Store summary
    ASC.CAP.Validation.Results.overallStatus = overallStatus
    ASC.CAP.Validation.Results.errors = totalErrors
    ASC.CAP.Validation.Results.warnings = totalWarnings
end

-- Initialize validation system
function ASC.CAP.Validation.Initialize()
    if not ASC.CAP.Validation.Config.EnableAutoValidation then
        print("[ASC CAP Validation] Auto-validation disabled")
        return false
    end
    
    -- Run initial validation
    timer.Simple(5, function()
        ASC.CAP.Validation.RunValidation()
    end)
    
    -- Set up periodic validation
    timer.Create("ASC_CAP_Validation", ASC.CAP.Validation.Config.ValidationInterval, 0, function()
        ASC.CAP.Validation.RunValidation()
    end)
    
    print("[ASC CAP Validation] Validation system initialized")
    return true
end

-- Console command for manual validation
concommand.Add("asc_cap_validate", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("You must be an admin to run CAP validation")
        return
    end
    
    ASC.CAP.Validation.RunValidation()
    
    if IsValid(ply) then
        ply:ChatPrint("CAP validation completed. Check console for results.")
    end
end)

-- Initialize when ready
hook.Add("Initialize", "ASC_CAP_Validation_Init", function()
    timer.Simple(3, function()
        ASC.CAP.Validation.Initialize()
    end)
end)

print("[Advanced Space Combat] CAP Integration Validation System v3.0 - Loaded")
