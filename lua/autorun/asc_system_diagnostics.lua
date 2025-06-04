-- Advanced Space Combat - System Diagnostics v3.1.0
-- Comprehensive system health monitoring and diagnostics

print("[ASC] System Diagnostics v3.1.0 - Loading...")

-- Initialize diagnostics namespace
ASC = ASC or {}
ASC.Diagnostics = ASC.Diagnostics or {}

-- Diagnostics configuration
ASC.Diagnostics.Config = {
    EnableDiagnostics = true,
    AutoRunOnStart = true,
    DetailedReporting = true,
    CheckInterval = 60, -- seconds
    AlertThreshold = 0.7 -- 70% systems must be working
}

-- System status tracking
ASC.Diagnostics.SystemStatus = {
    LastCheck = 0,
    OverallHealth = 0,
    SystemResults = {},
    Alerts = {},
    Recommendations = {}
}

-- Core system checks
function ASC.Diagnostics.CheckCoreSystems()
    local results = {}
    
    -- Check ASC namespace
    results.asc_namespace = {
        status = ASC ~= nil,
        details = ASC and "ASC namespace available" or "ASC namespace missing",
        critical = true
    }
    
    -- Check HYPERDRIVE namespace
    results.hyperdrive_namespace = {
        status = HYPERDRIVE ~= nil,
        details = HYPERDRIVE and "HYPERDRIVE namespace available" or "HYPERDRIVE namespace missing",
        critical = true
    }
    
    -- Check AI system
    results.ai_system = {
        status = ASC.AI ~= nil and ASC.AI.ProcessQuery ~= nil,
        details = (ASC.AI and ASC.AI.ProcessQuery) and "AI system operational" or "AI system not available",
        critical = false
    }
    
    -- Check menu organization
    results.menu_organization = {
        status = ASC.MenuOrganization ~= nil,
        details = ASC.MenuOrganization and "Menu organization loaded" or "Menu organization missing",
        critical = false
    }
    
    return results
end

-- Entity system checks
function ASC.Diagnostics.CheckEntitySystems()
    local results = {}
    
    -- Core entities
    local coreEntities = {
        "ship_core",
        "hyperdrive_master_engine",
        "hyperdrive_computer"
    }
    
    local availableEntities = 0
    for _, class in ipairs(coreEntities) do
        local available = scripted_ents.GetStored(class) ~= nil
        results["entity_" .. class] = {
            status = available,
            details = available and (class .. " entity available") or (class .. " entity missing"),
            critical = class == "ship_core"
        }
        if available then availableEntities = availableEntities + 1 end
    end
    
    -- Weapon entities
    local weaponEntities = {
        "asc_pulse_cannon",
        "asc_plasma_cannon", 
        "asc_railgun",
        "hyperdrive_beam_weapon",
        "hyperdrive_torpedo_launcher"
    }
    
    local availableWeapons = 0
    for _, class in ipairs(weaponEntities) do
        local available = scripted_ents.GetStored(class) ~= nil
        results["weapon_" .. class] = {
            status = available,
            details = available and (class .. " weapon available") or (class .. " weapon missing"),
            critical = false
        }
        if available then availableWeapons = availableWeapons + 1 end
    end
    
    -- Summary
    results.entity_summary = {
        status = availableEntities >= 2, -- At least ship_core and one engine
        details = "Core entities: " .. availableEntities .. "/" .. #coreEntities .. ", Weapons: " .. availableWeapons .. "/" .. #weaponEntities,
        critical = false
    }
    
    return results
end

-- Tool system checks
function ASC.Diagnostics.CheckToolSystems()
    local results = {}
    
    local tools = {
        "asc_main_tool",
        "asc_ship_builder", 
        "asc_weapon_config"
    }
    
    local availableTools = 0
    for _, tool in ipairs(tools) do
        local toolFile = "lua/weapons/gmod_tool/stools/" .. tool .. ".lua"
        local available = file.Exists(toolFile, "GAME")
        results["tool_" .. tool] = {
            status = available,
            details = available and (tool .. " tool available") or (tool .. " tool missing"),
            critical = tool == "asc_main_tool"
        }
        if available then availableTools = availableTools + 1 end
    end
    
    results.tool_summary = {
        status = availableTools >= 1,
        details = "Available tools: " .. availableTools .. "/" .. #tools,
        critical = false
    }
    
    return results
end

-- Integration checks
function ASC.Diagnostics.CheckIntegrations()
    local results = {}
    
    -- CAP integration
    results.cap_integration = {
        status = CAP ~= nil or StarGate ~= nil,
        details = (CAP or StarGate) and "CAP/Stargate detected" or "CAP/Stargate not available",
        critical = false
    }
    
    -- Wiremod integration
    results.wiremod_integration = {
        status = WireLib ~= nil,
        details = WireLib and "Wiremod detected" or "Wiremod not available",
        critical = false
    }
    
    -- Spacebuild integration
    results.spacebuild_integration = {
        status = Spacebuild ~= nil,
        details = Spacebuild and "Spacebuild detected" or "Spacebuild not available",
        critical = false
    }
    
    return results
end

-- File system checks
function ASC.Diagnostics.CheckFileSystems()
    local results = {}
    
    -- Core files (Phase 3 Enhanced)
    local coreFiles = {
        "lua/autorun/asc_ai_system_v2.lua",
        "lua/autorun/client/asc_spawn_menu_complete.lua",
        "lua/autorun/hyperdrive_init.lua",
        "lua/autorun/asc_code_fixes.lua",
        "lua/autorun/asc_weapon_system.lua",
        "lua/autorun/advanced_space_combat_init.lua",
        "lua/autorun/hyperdrive_core_v2.lua"
    }
    
    local availableFiles = 0
    for _, filePath in ipairs(coreFiles) do
        local available = file.Exists(filePath, "GAME")
        local fileName = string.GetFileFromFilename(filePath)
        results["file_" .. fileName] = {
            status = available,
            details = available and (fileName .. " file present") or (fileName .. " file missing"),
            critical = string.find(fileName, "init") ~= nil
        }
        if available then availableFiles = availableFiles + 1 end
    end
    
    results.file_summary = {
        status = availableFiles >= 3,
        details = "Core files present: " .. availableFiles .. "/" .. #coreFiles,
        critical = false
    }
    
    return results
end

-- Run comprehensive diagnostics
function ASC.Diagnostics.RunDiagnostics()
    if not ASC.Diagnostics.Config.EnableDiagnostics then return end
    
    print("[ASC] Running system diagnostics...")
    
    local allResults = {}
    
    -- Run all checks
    local coreResults = ASC.Diagnostics.CheckCoreSystems()
    local entityResults = ASC.Diagnostics.CheckEntitySystems()
    local toolResults = ASC.Diagnostics.CheckToolSystems()
    local integrationResults = ASC.Diagnostics.CheckIntegrations()
    local fileResults = ASC.Diagnostics.CheckFileSystems()
    
    -- Combine results
    for k, v in pairs(coreResults) do allResults[k] = v end
    for k, v in pairs(entityResults) do allResults[k] = v end
    for k, v in pairs(toolResults) do allResults[k] = v end
    for k, v in pairs(integrationResults) do allResults[k] = v end
    for k, v in pairs(fileResults) do allResults[k] = v end
    
    -- Calculate overall health
    local totalSystems = 0
    local workingSystems = 0
    local criticalIssues = 0
    
    for name, result in pairs(allResults) do
        totalSystems = totalSystems + 1
        if result.status then
            workingSystems = workingSystems + 1
        elseif result.critical then
            criticalIssues = criticalIssues + 1
        end
    end
    
    local healthPercentage = totalSystems > 0 and (workingSystems / totalSystems) or 0
    
    -- Store results
    ASC.Diagnostics.SystemStatus.LastCheck = CurTime()
    ASC.Diagnostics.SystemStatus.OverallHealth = healthPercentage
    ASC.Diagnostics.SystemStatus.SystemResults = allResults
    
    -- Generate alerts and recommendations
    ASC.Diagnostics.GenerateAlerts(allResults, healthPercentage, criticalIssues)
    
    return allResults, healthPercentage, criticalIssues
end

-- Generate alerts and recommendations
function ASC.Diagnostics.GenerateAlerts(results, healthPercentage, criticalIssues)
    local alerts = {}
    local recommendations = {}
    
    -- Critical system alerts
    if criticalIssues > 0 then
        table.insert(alerts, "🚨 CRITICAL: " .. criticalIssues .. " critical systems are not working")
        table.insert(recommendations, "Fix critical systems immediately for proper functionality")
    end
    
    -- Overall health alerts
    if healthPercentage < ASC.Diagnostics.Config.AlertThreshold then
        table.insert(alerts, "⚠️ WARNING: System health is " .. math.floor(healthPercentage * 100) .. "%")
        table.insert(recommendations, "Run 'asc_run_fixes' to attempt automatic repairs")
    end
    
    -- Specific recommendations
    if not results.asc_namespace or not results.asc_namespace.status then
        table.insert(recommendations, "Restart the server or reload the addon")
    end
    
    if not results.entity_ship_core or not results.entity_ship_core.status then
        table.insert(recommendations, "Ship core entity is missing - core functionality will not work")
    end
    
    if not results.tool_asc_main_tool or not results.tool_asc_main_tool.status then
        table.insert(recommendations, "Main tool is missing - use spawn menu instead")
    end
    
    ASC.Diagnostics.SystemStatus.Alerts = alerts
    ASC.Diagnostics.SystemStatus.Recommendations = recommendations
end

-- Generate diagnostic report
function ASC.Diagnostics.GenerateReport()
    local status = ASC.Diagnostics.SystemStatus
    local results = status.SystemResults
    
    if not results or table.Count(results) == 0 then
        return "No diagnostic data available. Run 'asc_diagnostics' to generate report."
    end
    
    local report = {
        "=== Advanced Space Combat - System Diagnostics ===",
        "Last Check: " .. os.date("%H:%M:%S", status.LastCheck),
        "Overall Health: " .. math.floor(status.OverallHealth * 100) .. "%",
        ""
    }
    
    -- Add alerts
    if #status.Alerts > 0 then
        table.insert(report, "=== ALERTS ===")
        for _, alert in ipairs(status.Alerts) do
            table.insert(report, alert)
        end
        table.insert(report, "")
    end
    
    -- Add system status
    table.insert(report, "=== SYSTEM STATUS ===")
    for name, result in pairs(results) do
        local statusIcon = result.status and "✅" or (result.critical and "🚨" or "⚠️")
        table.insert(report, statusIcon .. " " .. result.details)
    end
    
    -- Add recommendations
    if #status.Recommendations > 0 then
        table.insert(report, "")
        table.insert(report, "=== RECOMMENDATIONS ===")
        for _, rec in ipairs(status.Recommendations) do
            table.insert(report, "• " .. rec)
        end
    end
    
    return table.concat(report, "\n")
end

-- Console commands
if SERVER then
    concommand.Add("asc_diagnostics", function(ply, cmd, args)
        local results, health, critical = ASC.Diagnostics.RunDiagnostics()
        local report = ASC.Diagnostics.GenerateReport()
        
        if IsValid(ply) then
            for _, line in ipairs(string.Split(report, "\n")) do
                ply:ChatPrint(line)
            end
        else
            print(report)
        end
    end)
    
    concommand.Add("asc_health", function(ply, cmd, args)
        local health = ASC.Diagnostics.SystemStatus.OverallHealth
        local message = "[ASC] System Health: " .. math.floor(health * 100) .. "%"
        
        if IsValid(ply) then
            ply:ChatPrint(message)
        else
            print(message)
        end
    end)
end

-- Auto-run diagnostics
if ASC.Diagnostics.Config.AutoRunOnStart then
    timer.Simple(3, function()
        ASC.Diagnostics.RunDiagnostics()
        print("[ASC] Initial diagnostics complete - Health: " .. math.floor(ASC.Diagnostics.SystemStatus.OverallHealth * 100) .. "%")
    end)
end

-- Periodic diagnostics
timer.Create("ASC_PeriodicDiagnostics", ASC.Diagnostics.Config.CheckInterval, 0, function()
    ASC.Diagnostics.RunDiagnostics()
end)

print("[ASC] System Diagnostics v3.1.0 loaded successfully!")
