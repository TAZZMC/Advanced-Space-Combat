-- Enhanced Hyperdrive System - Error Fixes and Validation
-- Comprehensive error checking and validation system

if CLIENT then return end

HYPERDRIVE.ErrorFixes = HYPERDRIVE.ErrorFixes or {}

-- Error fix validation system
function HYPERDRIVE.ErrorFixes.ValidateSystem()
    local errors = {}
    local warnings = {}
    local fixes = {}

    print("[Hyperdrive] Running comprehensive system validation...")

    -- 1. Validate CAP Integration
    local capStatus = HYPERDRIVE.ErrorFixes.ValidateCAP()
    if capStatus.errors then
        table.Add(errors, capStatus.errors)
    end
    if capStatus.warnings then
        table.Add(warnings, capStatus.warnings)
    end
    if capStatus.fixes then
        table.Add(fixes, capStatus.fixes)
    end

    -- 2. Validate Entity Systems
    local entityStatus = HYPERDRIVE.ErrorFixes.ValidateEntities()
    if entityStatus.errors then
        table.Add(errors, entityStatus.errors)
    end
    if entityStatus.warnings then
        table.Add(warnings, entityStatus.warnings)
    end
    if entityStatus.fixes then
        table.Add(fixes, entityStatus.fixes)
    end

    -- 3. Validate UI Systems
    local uiStatus = HYPERDRIVE.ErrorFixes.ValidateUI()
    if uiStatus.errors then
        table.Add(errors, uiStatus.errors)
    end
    if uiStatus.warnings then
        table.Add(warnings, uiStatus.warnings)
    end
    if uiStatus.fixes then
        table.Add(fixes, uiStatus.fixes)
    end

    -- Report results
    print("[Hyperdrive] Validation complete:")
    print("  - Errors: " .. #errors)
    print("  - Warnings: " .. #warnings)
    print("  - Fixes applied: " .. #fixes)

    if #errors > 0 then
        print("[Hyperdrive] ERRORS FOUND:")
        for i, error in ipairs(errors) do
            print("  " .. i .. ". " .. error)
        end
    end

    if #warnings > 0 then
        print("[Hyperdrive] WARNINGS:")
        for i, warning in ipairs(warnings) do
            print("  " .. i .. ". " .. warning)
        end
    end

    if #fixes > 0 then
        print("[Hyperdrive] FIXES APPLIED:")
        for i, fix in ipairs(fixes) do
            print("  " .. i .. ". " .. fix)
        end
    end

    return {
        errors = errors,
        warnings = warnings,
        fixes = fixes,
        success = #errors == 0
    }
end

-- Validate CAP integration
function HYPERDRIVE.ErrorFixes.ValidateCAP()
    local result = { errors = {}, warnings = {}, fixes = {} }

    -- Check if CAP namespace exists
    if not HYPERDRIVE.CAP then
        table.insert(result.errors, "HYPERDRIVE.CAP namespace missing")
        return result
    end

    -- Check CAP detection
    if not HYPERDRIVE.CAP.DetectCAP then
        table.insert(result.errors, "CAP detection function missing")
        return result
    end

    -- Test CAP detection
    local success, capAvailable = pcall(HYPERDRIVE.CAP.DetectCAP)
    if not success then
        table.insert(result.errors, "CAP detection failed: " .. tostring(capAvailable))
        return result
    end

    -- Check entity categories
    if not HYPERDRIVE.CAP.EntityCategories then
        table.insert(result.warnings, "CAP entity categories not defined")
    else
        local categoryCount = table.Count(HYPERDRIVE.CAP.EntityCategories)
        if categoryCount == 0 then
            table.insert(result.warnings, "No CAP entity categories defined")
        else
            table.insert(result.fixes, "CAP entity categories validated (" .. categoryCount .. " categories)")
        end
    end

    -- Check shield system
    if HYPERDRIVE.CAP.Shields then
        if HYPERDRIVE.CAP.Shields.Types then
            local shieldCount = table.Count(HYPERDRIVE.CAP.Shields.Types)
            table.insert(result.fixes, "CAP shield types validated (" .. shieldCount .. " types)")
        else
            table.insert(result.warnings, "CAP shield types not initialized")
        end
    else
        table.insert(result.warnings, "CAP shield system not initialized")
    end

    return result
end

-- Validate entity systems
function HYPERDRIVE.ErrorFixes.ValidateEntities()
    local result = { errors = {}, warnings = {}, fixes = {} }

    -- Check ship core entity
    local storedEnts = scripted_ents.GetStored()
    if storedEnts then
        local shipCoreClass = storedEnts["ship_core"]
        if not shipCoreClass then
            table.insert(result.errors, "Ship core entity not registered")
        else
            table.insert(result.fixes, "Ship core entity validated")
        end

        -- Check hyperdrive engine entity
        local engineClass = storedEnts["hyperdrive_engine"]
        if not engineClass then
            table.insert(result.errors, "Hyperdrive engine entity not registered")
        else
            table.insert(result.fixes, "Hyperdrive engine entity validated")
        end
    else
        table.insert(result.warnings, "scripted_ents.GetStored() returned nil - entities may not be loaded yet")
    end

    -- Check for existing entities
    local shipCores = ents.FindByClass("ship_core")
    local engines = ents.FindByClass("hyperdrive_engine")

    if #shipCores > 0 then
        table.insert(result.fixes, "Found " .. #shipCores .. " ship cores in world")
    end

    if #engines > 0 then
        table.insert(result.fixes, "Found " .. #engines .. " hyperdrive engines in world")
    end

    return result
end

-- Validate UI systems
function HYPERDRIVE.ErrorFixes.ValidateUI()
    local result = { errors = {}, warnings = {}, fixes = {} }

    -- Check UI namespace
    if not HYPERDRIVE.UI then
        table.insert(result.warnings, "HYPERDRIVE.UI namespace not available (client-side only)")
        return result
    end

    -- Check theme system
    if HYPERDRIVE.UI.Theme then
        table.insert(result.fixes, "UI theme system available")
    else
        table.insert(result.warnings, "UI theme system not initialized")
    end

    -- Check entity selector
    if HYPERDRIVE.EntitySelector then
        table.insert(result.fixes, "Entity selector system available")
    else
        table.insert(result.warnings, "Entity selector system not initialized")
    end

    return result
end

-- Auto-fix common issues
function HYPERDRIVE.ErrorFixes.AutoFix()
    print("[Hyperdrive] Running auto-fix procedures...")

    local fixes = {}

    -- Fix 1: Ensure CAP namespace exists
    if not HYPERDRIVE.CAP then
        HYPERDRIVE.CAP = {}
        table.insert(fixes, "Created HYPERDRIVE.CAP namespace")
    end

    -- Fix 2: Ensure entity categories exist
    if not HYPERDRIVE.CAP.EntityCategories then
        HYPERDRIVE.CAP.EntityCategories = {
            STARGATES = {"stargate", "stargate_sg1", "stargate_atlantis", "stargate_universe"},
            SHIELDS = {"shield", "shield_core_buble", "shield_core_goauld", "shield_core_asgard"},
            ENERGY_SYSTEMS = {"zpm", "zpm_hub", "naquadah_generator", "potentia"},
            RESOURCES = {"naquadah", "trinium", "neutronium"},
            TRANSPORTATION = {"rings", "asgard_transporter", "ancient_transporter"}
        }
        table.insert(fixes, "Initialized CAP entity categories")
    end

    -- Fix 3: Ensure UI namespace exists
    if not HYPERDRIVE.UI then
        HYPERDRIVE.UI = {}
        table.insert(fixes, "Created HYPERDRIVE.UI namespace")
    end

    -- Fix 4: Ensure system status tracking
    if not HYPERDRIVE.SystemStatus then
        HYPERDRIVE.SystemStatus = {
            Initialized = true,
            LoadedModules = {},
            IntegrationStatus = {},
            LastUpdate = CurTime()
        }
        table.insert(fixes, "Initialized system status tracking")
    end

    -- Fix 5: Ensure shield system exists
    if not HYPERDRIVE.Shields then
        HYPERDRIVE.Shields = {}
        table.insert(fixes, "Created HYPERDRIVE.Shields namespace")
    end

    -- Fix 6: Ensure shield provider registration system
    if not HYPERDRIVE.Shields.Providers then
        HYPERDRIVE.Shields.Providers = {}
        table.insert(fixes, "Initialized shield provider system")
    end

    if not HYPERDRIVE.Shields.RegisterProvider then
        HYPERDRIVE.Shields.RegisterProvider = function(name, provider)
            HYPERDRIVE.Shields.Providers[name] = provider
            print("[Hyperdrive] Registered shield provider: " .. name)
        end
        table.insert(fixes, "Created shield provider registration function")
    end

    if #fixes > 0 then
        print("[Hyperdrive] Auto-fixes applied:")
        for i, fix in ipairs(fixes) do
            print("  " .. i .. ". " .. fix)
        end
    else
        print("[Hyperdrive] No auto-fixes needed")
    end

    return fixes
end

-- Console command for manual validation
concommand.Add("hyperdrive_validate", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Hyperdrive] Access denied - superadmin required")
        return
    end

    local result = HYPERDRIVE.ErrorFixes.ValidateSystem()

    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive] Validation complete - check console for details")
    end
end)

-- Console command for auto-fix
concommand.Add("hyperdrive_autofix", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsSuperAdmin() then
        ply:ChatPrint("[Hyperdrive] Access denied - superadmin required")
        return
    end

    local fixes = HYPERDRIVE.ErrorFixes.AutoFix()

    if IsValid(ply) then
        ply:ChatPrint("[Hyperdrive] Auto-fix complete - " .. #fixes .. " fixes applied")
    end
end)

-- Run auto-fix on initialization
timer.Simple(2, function()
    HYPERDRIVE.ErrorFixes.AutoFix()

    -- Run validation after auto-fix
    timer.Simple(1, function()
        HYPERDRIVE.ErrorFixes.ValidateSystem()
    end)
end)

print("[Hyperdrive] Error fixes and validation system loaded")
