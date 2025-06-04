-- Advanced Space Combat - Branding Verification System v1.0.0
-- Ensures consistent branding throughout the addon

print("[Advanced Space Combat] Branding Verification System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.BrandingVerification = ASC.BrandingVerification or {}

-- Official branding standards
ASC.BrandingVerification.Standards = {
    -- Official addon information
    AddonName = "Advanced Space Combat",
    FullName = "Advanced Space Combat - ARIA-4 Ultimate Edition with Enhanced Stargate Hyperspace",
    Version = "5.1.0",
    Build = "2025.01.15.STARGATE.ULTIMATE",
    Status = "Production Ready - Ultimate Stargate Edition",
    
    -- AI System
    AIName = "ARIA-4",
    AIVersion = "5.1.0",
    AIFullName = "ARIA-4 AI Assistant v5.1.0",
    
    -- System prefixes
    ChatPrefix = "[Advanced Space Combat]",
    LogPrefix = "[Advanced Space Combat]",
    ConsolePrefix = "asc_",
    
    -- Legacy names that should be updated
    DeprecatedNames = {
        "Enhanced Hyperdrive System",
        "Hyperdrive System",
        "ARIA-2",
        "ARIA-3",
        "v3.0.0",
        "v4.0.0",
        "v5.0.0"
    }
}

-- Verify branding consistency
function ASC.BrandingVerification.VerifyBranding()
    local issues = {}
    local standards = ASC.BrandingVerification.Standards

    -- Check global variables
    if ASC.VERSION ~= standards.Version then
        table.insert(issues, "ASC.VERSION mismatch: " .. (ASC.VERSION or "nil") .. " should be " .. standards.Version)
    end

    if ASC.NAME ~= standards.FullName then
        table.insert(issues, "ASC.NAME mismatch: " .. (ASC.NAME or "nil") .. " should be " .. standards.FullName)
    end

    if ASC.BUILD ~= standards.Build then
        table.insert(issues, "ASC.BUILD mismatch: " .. (ASC.BUILD or "nil") .. " should be " .. standards.Build)
    end

    -- Check HYPERDRIVE namespace
    if HYPERDRIVE and HYPERDRIVE.Version ~= standards.Version then
        table.insert(issues, "HYPERDRIVE.Version mismatch: " .. (HYPERDRIVE.Version or "nil") .. " should be " .. standards.Version)
    end

    -- Check entity branding (CLIENT only to avoid server lag)
    if CLIENT then
        ASC.BrandingVerification.CheckEntityBranding(issues, standards)
    end

    return issues
end

-- Check entity branding consistency
function ASC.BrandingVerification.CheckEntityBranding(issues, standards)
    -- Check registered entities for proper branding
    local entityClasses = {
        "hyperdrive_beacon", "hyperdrive_computer", "hyperdrive_engine",
        "hyperdrive_shield_generator", "hyperdrive_shuttle", "hyperdrive_plasma_cannon"
    }

    for _, className in ipairs(entityClasses) do
        local entTable = scripted_ents.GetStored(className)
        if entTable and entTable.t then
            local ent = entTable.t

            -- Check PrintName
            if ent.PrintName and not string.find(ent.PrintName, "ASC") and not string.find(ent.PrintName, "Advanced Space Combat") then
                table.insert(issues, "Entity " .. className .. " PrintName should include ASC branding")
            end

            -- Check Author
            if ent.Author and ent.Author ~= "Advanced Space Combat Team" then
                table.insert(issues, "Entity " .. className .. " Author should be 'Advanced Space Combat Team'")
            end

            -- Check Category
            if ent.Category and ent.Category ~= "Advanced Space Combat" then
                table.insert(issues, "Entity " .. className .. " Category should be 'Advanced Space Combat'")
            end
        end
    end
end

-- Get branding report
function ASC.BrandingVerification.GetBrandingReport()
    local standards = ASC.BrandingVerification.Standards
    local report = {
        "=== Advanced Space Combat Branding Report ===",
        "",
        "Official Standards:",
        "• Addon Name: " .. standards.AddonName,
        "• Full Name: " .. standards.FullName,
        "• Version: " .. standards.Version,
        "• Build: " .. standards.Build,
        "• Status: " .. standards.Status,
        "",
        "AI System:",
        "• AI Name: " .. standards.AIName,
        "• AI Version: " .. standards.AIVersion,
        "• AI Full Name: " .. standards.AIFullName,
        "",
        "Current System Values:",
        "• ASC.VERSION: " .. (ASC.VERSION or "nil"),
        "• ASC.NAME: " .. (ASC.NAME or "nil"),
        "• ASC.BUILD: " .. (ASC.BUILD or "nil"),
        "• ASC.STATUS: " .. (ASC.STATUS or "nil"),
        ""
    }
    
    if HYPERDRIVE then
        table.insert(report, "HYPERDRIVE System:")
        table.insert(report, "• HYPERDRIVE.Version: " .. (HYPERDRIVE.Version or "nil"))
        table.insert(report, "• HYPERDRIVE.Status: " .. (HYPERDRIVE.Status or "nil"))
        table.insert(report, "")
    end
    
    -- Check for issues
    local issues = ASC.BrandingVerification.VerifyBranding()
    if #issues > 0 then
        table.insert(report, "⚠️ Branding Issues Found:")
        for _, issue in ipairs(issues) do
            table.insert(report, "• " .. issue)
        end
    else
        table.insert(report, "✅ All branding is consistent!")
    end
    
    table.insert(report, "")
    table.insert(report, "=== End Report ===")
    
    return report
end

-- Fix branding issues automatically
function ASC.BrandingVerification.FixBranding()
    local standards = ASC.BrandingVerification.Standards
    local fixed = {}
    
    -- Fix ASC namespace
    if ASC.VERSION ~= standards.Version then
        ASC.VERSION = standards.Version
        table.insert(fixed, "Fixed ASC.VERSION")
    end
    
    if ASC.NAME ~= standards.FullName then
        ASC.NAME = standards.FullName
        table.insert(fixed, "Fixed ASC.NAME")
    end
    
    if ASC.BUILD ~= standards.Build then
        ASC.BUILD = standards.Build
        table.insert(fixed, "Fixed ASC.BUILD")
    end
    
    if ASC.STATUS ~= standards.Status then
        ASC.STATUS = standards.Status
        table.insert(fixed, "Fixed ASC.STATUS")
    end
    
    -- Fix HYPERDRIVE namespace
    if HYPERDRIVE then
        if HYPERDRIVE.Version ~= standards.Version then
            HYPERDRIVE.Version = standards.Version
            table.insert(fixed, "Fixed HYPERDRIVE.Version")
        end
        
        if HYPERDRIVE.Status ~= standards.Status then
            HYPERDRIVE.Status = standards.Status
            table.insert(fixed, "Fixed HYPERDRIVE.Status")
        end
    end
    
    return fixed
end

-- Console commands for branding management
concommand.Add("asc_branding_report", function(ply, cmd, args)
    local report = ASC.BrandingVerification.GetBrandingReport()
    
    if IsValid(ply) then
        for _, line in ipairs(report) do
            ply:ChatPrint(line)
        end
    else
        for _, line in ipairs(report) do
            print(line)
        end
    end
end, nil, "Show comprehensive branding report")

concommand.Add("asc_branding_verify", function(ply, cmd, args)
    local issues = ASC.BrandingVerification.VerifyBranding()
    
    local msg = "[Advanced Space Combat] Branding Verification: "
    if #issues == 0 then
        msg = msg .. "✅ All branding is consistent!"
    else
        msg = msg .. "⚠️ " .. #issues .. " issues found"
    end
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
        if #issues > 0 then
            for _, issue in ipairs(issues) do
                ply:ChatPrint("• " .. issue)
            end
            ply:ChatPrint("Use 'asc_branding_fix' to automatically fix issues")
        end
    else
        print(msg)
        if #issues > 0 then
            for _, issue in ipairs(issues) do
                print("• " .. issue)
            end
            print("Use 'asc_branding_fix' to automatically fix issues")
        end
    end
end, nil, "Verify branding consistency")

concommand.Add("asc_branding_fix", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Advanced Space Combat] Admin only command")
        return
    end

    local fixed = ASC.BrandingVerification.FixBranding()

    local msg = "[Advanced Space Combat] Branding Fix: "
    if #fixed == 0 then
        msg = msg .. "No issues to fix"
    else
        msg = msg .. "Fixed " .. #fixed .. " issues"
    end

    if IsValid(ply) then
        ply:ChatPrint(msg)
        for _, fix in ipairs(fixed) do
            ply:ChatPrint("• " .. fix)
        end
    else
        print(msg)
        for _, fix in ipairs(fixed) do
            print("• " .. fix)
        end
    end
end, nil, "Automatically fix branding issues (Admin only)")

-- In-game branding check command
concommand.Add("asc_branding_check_ingame", function(ply, cmd, args)
    if not IsValid(ply) then return end

    ply:ChatPrint("[Advanced Space Combat] Checking in-game branding...")

    -- Check spawn menu entities
    local entityIssues = 0
    local entityClasses = {
        "hyperdrive_beacon", "hyperdrive_computer", "hyperdrive_engine",
        "hyperdrive_shield_generator", "hyperdrive_shuttle", "hyperdrive_plasma_cannon"
    }

    for _, className in ipairs(entityClasses) do
        local entTable = scripted_ents.GetStored(className)
        if entTable and entTable.t then
            local ent = entTable.t

            if ent.PrintName and not string.find(ent.PrintName, "ASC") then
                ply:ChatPrint("⚠️ " .. className .. " needs branding update")
                entityIssues = entityIssues + 1
            end
        end
    end

    if entityIssues == 0 then
        ply:ChatPrint("✅ All in-game entities have consistent branding!")
    else
        ply:ChatPrint("❌ Found " .. entityIssues .. " entity branding issues")
    end
end, nil, "Check in-game entity branding consistency")

-- Automatic branding verification on load
timer.Simple(2, function()
    local issues = ASC.BrandingVerification.VerifyBranding()
    if #issues > 0 then
        print("[Advanced Space Combat] ⚠️ Branding issues detected: " .. #issues)
        print("[Advanced Space Combat] Use 'asc_branding_verify' for details")
    else
        print("[Advanced Space Combat] ✅ Branding verification passed")
    end
end)

print("[Advanced Space Combat] Branding Verification System loaded successfully!")
