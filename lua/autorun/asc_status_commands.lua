-- Advanced Space Combat - Status Commands v5.0.0
-- Comprehensive status reporting and help commands with Enhanced Stargate Hyperspace

print("[ASC] Status Commands v5.0.0 - Enhanced Stargate Hyperspace Edition - Loading...")

-- Initialize status system
ASC = ASC or {}
ASC.StatusSystem = ASC.StatusSystem or {}

-- Status configuration
ASC.StatusSystem.Config = {
    EnableStatusCommands = true,
    EnableHelpCommands = true,
    EnableQuickFixes = true,
    ShowDetailedInfo = true,
    ShowHyperspaceStatus = true,
    ShowStargateIntegration = true
}

-- Get comprehensive system status
function ASC.StatusSystem.GetSystemStatus()
    local status = {
        timestamp = os.time(),
        version = "Advanced Space Combat v5.0.0 - Enhanced Stargate Hyperspace",
        systems = {},
        entities = {},
        tools = {},
        integrations = {},
        hyperspace = {},
        health = 0
    }
    
    -- Core systems
    status.systems.asc_core = ASC ~= nil
    status.systems.hyperdrive_core = HYPERDRIVE ~= nil
    status.systems.ai_system = ASC.AI ~= nil and ASC.AI.ProcessQuery ~= nil
    status.systems.menu_organization = ASC.MenuOrganization ~= nil
    status.systems.code_fixes = ASC.CodeFixes ~= nil
    status.systems.diagnostics = ASC.Diagnostics ~= nil
    
    -- Entity counts
    status.entities.ship_cores = #ents.FindByClass("ship_core")
    status.entities.engines = #ents.FindByClass("hyperdrive_engine") + #ents.FindByClass("hyperdrive_master_engine")
    status.entities.weapons = #ents.FindByClass("asc_pulse_cannon") + #ents.FindByClass("asc_plasma_cannon") + #ents.FindByClass("asc_railgun")
    status.entities.shields = #ents.FindByClass("asc_shield_generator") + #ents.FindByClass("hyperdrive_shield_generator")
    status.entities.total = #ents.GetAll()
    
    -- Tool availability
    status.tools.main_tool = file.Exists("lua/weapons/gmod_tool/stools/asc_main_tool.lua", "GAME")
    status.tools.ship_builder = file.Exists("lua/weapons/gmod_tool/stools/asc_ship_builder.lua", "GAME")
    status.tools.weapon_config = file.Exists("lua/weapons/gmod_tool/stools/asc_weapon_config.lua", "GAME")
    
    -- Integration status
    status.integrations.cap = CAP ~= nil or StarGate ~= nil
    status.integrations.wiremod = WireLib ~= nil
    status.integrations.spacebuild = Spacebuild ~= nil

    -- Enhanced Stargate Hyperspace status
    if ASC.StatusSystem.Config.ShowHyperspaceStatus and HYPERDRIVE and HYPERDRIVE.Hyperspace then
        status.hyperspace.enabled = HYPERDRIVE.Hyperspace.Config and HYPERDRIVE.Hyperspace.Config.EnableStargateHyperspace or false
        status.hyperspace.active_travels = HYPERDRIVE.Hyperspace.ActiveTravels and table.Count(HYPERDRIVE.Hyperspace.ActiveTravels) or 0
        status.hyperspace.four_stage_system = file.Exists("lua/autorun/hyperdrive_hyperspace.lua", "GAME")
        status.hyperspace.visual_effects = file.Exists("lua/effects/asc_stargate_hyperspace_window.lua", "GAME")
        status.hyperspace.stargate_integration = status.integrations.cap
    end
    
    -- Calculate health
    local totalChecks = 0
    local passedChecks = 0
    
    for _, v in pairs(status.systems) do
        totalChecks = totalChecks + 1
        if v then passedChecks = passedChecks + 1 end
    end
    
    for _, v in pairs(status.tools) do
        totalChecks = totalChecks + 1
        if v then passedChecks = passedChecks + 1 end
    end
    
    status.health = totalChecks > 0 and (passedChecks / totalChecks) or 0
    
    return status
end

-- Generate status report
function ASC.StatusSystem.GenerateReport(detailed)
    local status = ASC.StatusSystem.GetSystemStatus()
    local report = {}
    
    -- Header
    table.insert(report, "=== " .. status.version .. " ===")
    table.insert(report, "Status Report - " .. os.date("%H:%M:%S", status.timestamp))
    table.insert(report, "System Health: " .. math.floor(status.health * 100) .. "%")
    table.insert(report, "")
    
    -- Core systems
    table.insert(report, "=== CORE SYSTEMS ===")
    table.insert(report, (status.systems.asc_core and "✅" or "❌") .. " ASC Core System")
    table.insert(report, (status.systems.hyperdrive_core and "✅" or "❌") .. " Hyperdrive Core")
    table.insert(report, (status.systems.ai_system and "✅" or "❌") .. " AI Assistant")
    table.insert(report, (status.systems.menu_organization and "✅" or "❌") .. " Menu Organization")
    table.insert(report, (status.systems.code_fixes and "✅" or "❌") .. " Code Fixes")
    table.insert(report, (status.systems.diagnostics and "✅" or "❌") .. " Diagnostics")
    table.insert(report, "")
    
    -- Entity counts
    table.insert(report, "=== ENTITY COUNTS ===")
    table.insert(report, "Ship Cores: " .. status.entities.ship_cores)
    table.insert(report, "Engines: " .. status.entities.engines)
    table.insert(report, "Weapons: " .. status.entities.weapons)
    table.insert(report, "Shields: " .. status.entities.shields)
    table.insert(report, "Total Entities: " .. status.entities.total)
    table.insert(report, "")
    
    -- Tools
    table.insert(report, "=== TOOLS ===")
    table.insert(report, (status.tools.main_tool and "✅" or "❌") .. " ASC Main Tool")
    table.insert(report, (status.tools.ship_builder and "✅" or "❌") .. " Ship Builder")
    table.insert(report, (status.tools.weapon_config and "✅" or "❌") .. " Weapon Config")
    table.insert(report, "")
    
    -- Integrations
    table.insert(report, "=== INTEGRATIONS ===")
    table.insert(report, (status.integrations.cap and "✅" or "❌") .. " CAP/Stargate")
    table.insert(report, (status.integrations.wiremod and "✅" or "❌") .. " Wiremod")
    table.insert(report, (status.integrations.spacebuild and "✅" or "❌") .. " Spacebuild")

    -- Enhanced Stargate Hyperspace
    if status.hyperspace and next(status.hyperspace) then
        table.insert(report, "")
        table.insert(report, "=== ENHANCED STARGATE HYPERSPACE ===")
        table.insert(report, (status.hyperspace.enabled and "✅" or "❌") .. " 4-Stage Hyperspace System")
        table.insert(report, (status.hyperspace.four_stage_system and "✅" or "❌") .. " Core Hyperspace Engine")
        table.insert(report, (status.hyperspace.visual_effects and "✅" or "❌") .. " Stargate Visual Effects")
        table.insert(report, (status.hyperspace.stargate_integration and "✅" or "❌") .. " Ancient Tech Integration")
        if status.hyperspace.active_travels and status.hyperspace.active_travels > 0 then
            table.insert(report, "🚀 Active Hyperspace Travels: " .. status.hyperspace.active_travels)
        end
    end
    
    if detailed then
        table.insert(report, "")
        table.insert(report, "=== QUICK COMMANDS ===")
        table.insert(report, "• asc_diagnostics - Full system diagnostics")
        table.insert(report, "• asc_run_fixes - Attempt automatic fixes")
        table.insert(report, "• asc_help - Show help information")
        table.insert(report, "• !ai help - AI assistant help")
    end
    
    return table.concat(report, "\n")
end

-- Show help information
function ASC.StatusSystem.ShowHelp(player)
    local help = {
        "=== Advanced Space Combat - Help ===",
        "",
        "🔧 TOOLS:",
        "• Q Menu > Advanced Space Combat - Organized tools and spawning",
        "• ASC Main Tool - Primary entity spawning tool",
        "• Ship Builder - Build ships from templates",
        "• Weapon Config - Configure weapons and targeting",
        "",
        "🤖 AI ASSISTANT:",
        "• !ai help - General AI help",
        "• !ai ship building - Ship construction guide",
        "• !ai weapons - Weapon system help",
        "• !ai cap info - CAP integration status",
        "• !ai system status - System information",
        "",
        "⚙️ CONSOLE COMMANDS:",
        "• asc_status - System status report",
        "• asc_diagnostics - Full system diagnostics",
        "• asc_run_fixes - Attempt automatic fixes",
        "• asc_health - Quick health check",
        "",
        "📋 SPAWN MENU:",
        "• Entities > Advanced Space Combat - Categorized entities",
        "• Ship Cores, Engines, Weapons, Shields, Transport, Utilities",
        "",
        "🚀 QUICK START:",
        "1. Spawn a Ship Core (required for all ships)",
        "2. Add engines, weapons, shields within 2000 units",
        "3. Components auto-link to the ship core",
        "4. Use AI assistant for guidance: !ai help"
    }
    
    if IsValid(player) then
        for _, line in ipairs(help) do
            player:ChatPrint(line)
        end
    else
        for _, line in ipairs(help) do
            print(line)
        end
    end
end

-- Console commands
if SERVER then
    -- Main status command
    concommand.Add("asc_status", function(ply, cmd, args)
        local detailed = args[1] == "detailed" or args[1] == "full"
        local report = ASC.StatusSystem.GenerateReport(detailed)
        
        if IsValid(ply) then
            for _, line in ipairs(string.Split(report, "\n")) do
                ply:ChatPrint(line)
            end
        else
            print(report)
        end
    end)
    
    -- Help command
    concommand.Add("asc_help", function(ply, cmd, args)
        ASC.StatusSystem.ShowHelp(ply)
    end)
    
    -- Quick health check
    concommand.Add("asc_health", function(ply, cmd, args)
        local status = ASC.StatusSystem.GetSystemStatus()
        local health = math.floor(status.health * 100)
        local message = "[ASC] System Health: " .. health .. "%"
        
        if health >= 80 then
            message = message .. " ✅ Excellent"
        elseif health >= 60 then
            message = message .. " ⚠️ Good"
        elseif health >= 40 then
            message = message .. " ⚠️ Fair - Run asc_run_fixes"
        else
            message = message .. " ❌ Poor - Check asc_diagnostics"
        end
        
        if IsValid(ply) then
            ply:ChatPrint(message)
        else
            print(message)
        end
    end)
    
    -- Quick fix command
    concommand.Add("asc_quick_fix", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        
        -- Run fixes
        if ASC.CodeFixes and ASC.CodeFixes.RunAllFixes then
            ASC.CodeFixes.RunAllFixes()
        end
        
        -- Run diagnostics
        if ASC.Diagnostics and ASC.Diagnostics.RunDiagnostics then
            ASC.Diagnostics.RunDiagnostics()
        end
        
        local message = "[ASC] Quick fix completed - Check asc_status for results"
        if IsValid(ply) then
            ply:ChatPrint(message)
        else
            print(message)
        end
    end)
    
    -- Version command
    concommand.Add("asc_version", function(ply, cmd, args)
        local message = "[ASC] Advanced Space Combat v5.1.0 - ARIA-4 Ultimate Edition with Enhanced Stargate Hyperspace"
        if IsValid(ply) then
            ply:ChatPrint(message)
            ply:ChatPrint("[ASC] Features: 4-stage Stargate hyperspace, ARIA-4 AI v5.1.0, Ancient tech bonuses, authentic visual effects")
        else
            print(message)
            print("[ASC] Features: 4-stage Stargate hyperspace, ARIA-4 AI v5.1.0, Ancient tech bonuses, authentic visual effects")
        end
    end)
end

-- Client-side commands
if CLIENT then
    concommand.Add("asc_menu", function()
        RunConsoleCommand("gmod_tool", "asc_main_tool")
        chat.AddText(Color(100, 200, 255), "[ASC] ", Color(255, 255, 255), "ASC Main Tool selected")
    end)
    
    concommand.Add("asc_ship_builder", function()
        RunConsoleCommand("gmod_tool", "asc_ship_builder")
        chat.AddText(Color(100, 200, 255), "[ASC] ", Color(255, 255, 255), "Ship Builder selected")
    end)
    
    concommand.Add("asc_weapon_config", function()
        RunConsoleCommand("gmod_tool", "asc_weapon_config")
        chat.AddText(Color(100, 200, 255), "[ASC] ", Color(255, 255, 255), "Weapon Config selected")
    end)
end

-- Auto-show status on first load
timer.Simple(5, function()
    if SERVER then
        local status = ASC.StatusSystem.GetSystemStatus()
        local health = math.floor(status.health * 100)
        print("[ASC] ========================================")
        print("[ASC] Advanced Space Combat v5.1.0 - ARIA-4 Ultimate Edition Loaded!")
        print("[ASC] System Health: " .. health .. "%")
        print("[ASC] Use 'asc_help' for commands")
        print("[ASC] Use 'aria help' for ARIA-4 AI assistance")
        print("[ASC] ========================================")
    end
end)

print("[ASC] Status Commands v5.1.0 loaded successfully!")
