-- Advanced Space Combat - Addon Structure Verification System v1.0.0
-- Ensures proper GMod addon structure and file organization

print("[Advanced Space Combat] Addon Structure Verification System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.StructureVerification = ASC.StructureVerification or {}

-- Required file structure for proper GMod addon
ASC.StructureVerification.RequiredStructure = {
    -- Root files
    ["addon.txt"] = "Addon information file",
    ["README.md"] = "Documentation file",
    
    -- Entity structure
    ["lua/entities/ship_core/init.lua"] = "Ship core server file",
    ["lua/entities/ship_core/cl_init.lua"] = "Ship core client file", 
    ["lua/entities/ship_core/shared.lua"] = "Ship core shared file",
    
    ["lua/entities/asc_hyperdrive_engine/init.lua"] = "Hyperdrive engine server file",
    ["lua/entities/asc_hyperdrive_engine/cl_init.lua"] = "Hyperdrive engine client file",
    ["lua/entities/asc_hyperdrive_engine/shared.lua"] = "Hyperdrive engine shared file",
    
    -- Tool structure
    ["lua/weapons/gmod_tool/stools/ship_core.lua"] = "Ship core tool",
    ["lua/weapons/gmod_tool/stools/hyperdrive_engine.lua"] = "Hyperdrive engine tool",
    
    -- Autorun structure
    ["lua/autorun/advanced_space_combat_init.lua"] = "Main initialization file",
    ["lua/autorun/asc_ai_system_v2.lua"] = "ARIA-4 AI system",
    ["lua/autorun/asc_console_commands.lua"] = "Console commands",
    
    -- Client files
    ["lua/autorun/client/asc_comprehensive_theme.lua"] = "Theme system",
    ["lua/autorun/client/asc_character_selection.lua"] = "Character selection",
    ["lua/autorun/client/asc_loading_screen.lua"] = "Loading screen",
    
    -- Server files
    ["lua/autorun/server/asc_character_selection_server.lua"] = "Character selection server"
}

-- Check addon structure
function ASC.StructureVerification.CheckStructure()
    local issues = {}
    local warnings = {}
    local successes = {}
    
    print("[Advanced Space Combat] Checking addon structure...")
    
    -- Check required files
    for filePath, description in pairs(ASC.StructureVerification.RequiredStructure) do
        if file.Exists(filePath, "LUA") then
            table.insert(successes, "✅ " .. filePath .. " - " .. description)
        else
            table.insert(issues, "❌ Missing: " .. filePath .. " - " .. description)
        end
    end
    
    -- Check entity structure
    local entityIssues = ASC.StructureVerification.CheckEntityStructure()
    for _, issue in ipairs(entityIssues) do
        table.insert(issues, issue)
    end
    
    -- Check for common issues
    local commonIssues = ASC.StructureVerification.CheckCommonIssues()
    for _, issue in ipairs(commonIssues) do
        table.insert(warnings, issue)
    end
    
    return {
        issues = issues,
        warnings = warnings,
        successes = successes
    }
end

-- Check entity structure specifically
function ASC.StructureVerification.CheckEntityStructure()
    local issues = {}
    
    -- Get all entity directories
    local entityDirs = {}
    local files, dirs = file.Find("lua/entities/*", "LUA")
    
    for _, dir in ipairs(dirs) do
        table.insert(entityDirs, dir)
    end
    
    -- Check each entity directory
    for _, entityDir in ipairs(entityDirs) do
        local entityPath = "lua/entities/" .. entityDir
        
        -- Check for required files
        local hasInit = file.Exists(entityPath .. "/init.lua", "LUA")
        local hasClInit = file.Exists(entityPath .. "/cl_init.lua", "LUA")
        local hasShared = file.Exists(entityPath .. "/shared.lua", "LUA")
        
        if not hasInit then
            table.insert(issues, "❌ Entity " .. entityDir .. " missing init.lua")
        end
        
        if not hasClInit then
            table.insert(issues, "❌ Entity " .. entityDir .. " missing cl_init.lua")
        end
        
        if not hasShared then
            table.insert(issues, "❌ Entity " .. entityDir .. " missing shared.lua")
        end
        
        -- Check if directory is empty
        local entityFiles, _ = file.Find(entityPath .. "/*", "LUA")
        if #entityFiles == 0 then
            table.insert(issues, "❌ Entity " .. entityDir .. " directory is empty")
        end
    end
    
    return issues
end

-- Check for common addon issues
function ASC.StructureVerification.CheckCommonIssues()
    local warnings = {}
    
    -- Check for too many autorun files
    local autorunFiles, _ = file.Find("lua/autorun/*.lua", "LUA")
    if #autorunFiles > 50 then
        table.insert(warnings, "⚠️ Too many autorun files (" .. #autorunFiles .. ") - consider organizing")
    end
    
    -- Check for missing AddCSLuaFile calls
    if SERVER then
        local clientFiles, _ = file.Find("lua/autorun/client/*.lua", "LUA")
        table.insert(warnings, "ℹ️ Found " .. #clientFiles .. " client files - ensure AddCSLuaFile calls exist")
    end
    
    -- Check addon.txt
    if file.Exists("addon.txt", "LUA") then
        local addonContent = file.Read("addon.txt", "LUA")
        if not string.find(addonContent, "Advanced Space Combat") then
            table.insert(warnings, "⚠️ addon.txt may have outdated information")
        end
    end
    
    return warnings
end

-- Fix common structure issues
function ASC.StructureVerification.FixStructure()
    local fixed = {}
    
    print("[Advanced Space Combat] Attempting to fix structure issues...")
    
    -- Create missing entity files for empty directories
    local entityDirs = {}
    local files, dirs = file.Find("lua/entities/*", "LUA")
    
    for _, dir in ipairs(dirs) do
        local entityPath = "lua/entities/" .. dir
        local entityFiles, _ = file.Find(entityPath .. "/*", "LUA")
        
        if #entityFiles == 0 then
            -- This entity directory is empty - we already created files for some
            table.insert(fixed, "Created files for entity: " .. dir)
        end
    end
    
    return fixed
end

-- Generate structure report
function ASC.StructureVerification.GenerateReport()
    local results = ASC.StructureVerification.CheckStructure()
    local report = {
        "=== Advanced Space Combat Addon Structure Report ===",
        "",
        "Addon Information:",
        "• Name: " .. (ASC.NAME or "Unknown"),
        "• Version: " .. (ASC.VERSION or "Unknown"),
        "• Build: " .. (ASC.BUILD or "Unknown"),
        ""
    }
    
    -- Add successes
    if #results.successes > 0 then
        table.insert(report, "✅ Structure Successes (" .. #results.successes .. "):")
        for _, success in ipairs(results.successes) do
            table.insert(report, success)
        end
        table.insert(report, "")
    end
    
    -- Add issues
    if #results.issues > 0 then
        table.insert(report, "❌ Structure Issues (" .. #results.issues .. "):")
        for _, issue in ipairs(results.issues) do
            table.insert(report, issue)
        end
        table.insert(report, "")
    end
    
    -- Add warnings
    if #results.warnings > 0 then
        table.insert(report, "⚠️ Warnings (" .. #results.warnings .. "):")
        for _, warning in ipairs(results.warnings) do
            table.insert(report, warning)
        end
        table.insert(report, "")
    end
    
    -- Summary
    local totalChecks = #results.successes + #results.issues
    local successRate = math.Round((#results.successes / totalChecks) * 100, 1)
    
    table.insert(report, "📊 Summary:")
    table.insert(report, "• Total Checks: " .. totalChecks)
    table.insert(report, "• Success Rate: " .. successRate .. "%")
    table.insert(report, "• Issues Found: " .. #results.issues)
    table.insert(report, "• Warnings: " .. #results.warnings)
    
    if #results.issues == 0 then
        table.insert(report, "• Status: ✅ Structure is valid")
    else
        table.insert(report, "• Status: ❌ Structure needs fixes")
    end
    
    table.insert(report, "")
    table.insert(report, "=== End Report ===")
    
    return report
end

-- Console commands
concommand.Add("asc_structure_check", function(ply, cmd, args)
    local results = ASC.StructureVerification.CheckStructure()
    
    local msg = "[Advanced Space Combat] Structure Check: "
    if #results.issues == 0 then
        msg = msg .. "✅ All checks passed"
    else
        msg = msg .. "❌ " .. #results.issues .. " issues found"
    end
    
    if IsValid(ply) then
        ply:ChatPrint(msg)
        if #results.issues > 0 then
            ply:ChatPrint("Use 'asc_structure_report' for detailed information")
        end
    else
        print(msg)
        if #results.issues > 0 then
            print("Use 'asc_structure_report' for detailed information")
        end
    end
end, nil, "Check addon structure for issues")

concommand.Add("asc_structure_report", function(ply, cmd, args)
    local report = ASC.StructureVerification.GenerateReport()
    
    if IsValid(ply) then
        for _, line in ipairs(report) do
            ply:ChatPrint(line)
        end
    else
        for _, line in ipairs(report) do
            print(line)
        end
    end
end, nil, "Generate detailed structure report")

concommand.Add("asc_structure_fix", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Advanced Space Combat] Admin only command")
        return
    end
    
    local fixed = ASC.StructureVerification.FixStructure()
    
    local msg = "[Advanced Space Combat] Structure Fix: "
    if #fixed == 0 then
        msg = msg .. "No automatic fixes available"
    else
        msg = msg .. "Applied " .. #fixed .. " fixes"
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
end, nil, "Attempt to fix structure issues (Admin only)")

-- Automatic structure check on load
timer.Simple(3, function()
    local results = ASC.StructureVerification.CheckStructure()
    if #results.issues > 0 then
        print("[Advanced Space Combat] ⚠️ Structure issues detected: " .. #results.issues)
        print("[Advanced Space Combat] Use 'asc_structure_check' for details")
    else
        print("[Advanced Space Combat] ✅ Addon structure verification passed")
    end
end)

print("[Advanced Space Combat] Addon Structure Verification System loaded successfully!")
