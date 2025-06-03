--[[
    Advanced Space Combat - Debug System v3.0.0
    
    Comprehensive debugging system to identify and fix issues
    in the Advanced Space Combat addon.
]]

-- Initialize Debug System namespace
ASC = ASC or {}
ASC.Debug = ASC.Debug or {}

-- Debug Configuration
ASC.Debug.Config = {
    Enabled = true,
    LogLevel = 2, -- 0=None, 1=Errors, 2=Warnings, 3=Info, 4=Debug
    LogToFile = false,
    LogToConsole = true,
    ShowStackTrace = true,
    CheckMissingFiles = true,
    CheckSystemIntegrity = true,
    AutoFix = true
}

-- Debug Core
ASC.Debug.Core = {
    -- Error tracking
    Errors = {},
    Warnings = {},
    
    -- System checks
    SystemChecks = {},
    
    -- Missing files
    MissingFiles = {},
    
    -- Initialize debug system
    Initialize = function()
        print("[Debug System] Initializing debug system v3.0.0")
        
        -- Check for missing files
        ASC.Debug.Core.CheckMissingFiles()
        
        -- Check system integrity
        ASC.Debug.Core.CheckSystemIntegrity()
        
        -- Run diagnostics
        ASC.Debug.Core.RunDiagnostics()
        
        return true
    end,
    
    -- Log function
    Log = function(level, message, category)
        if level > ASC.Debug.Config.LogLevel then return end
        
        local levelNames = {"ERROR", "WARN", "INFO", "DEBUG"}
        local levelName = levelNames[level] or "UNKNOWN"
        local timestamp = os.date("%H:%M:%S")
        local categoryText = category and ("[" .. category .. "] ") or ""
        
        local logMessage = "[" .. timestamp .. "] [" .. levelName .. "] " .. categoryText .. message
        
        if ASC.Debug.Config.LogToConsole then
            if level == 1 then
                ErrorNoHalt(logMessage .. "\n")
            else
                print(logMessage)
            end
        end
        
        -- Store in appropriate list
        if level == 1 then
            table.insert(ASC.Debug.Core.Errors, {
                time = CurTime(),
                message = message,
                category = category or "General"
            })
        elseif level == 2 then
            table.insert(ASC.Debug.Core.Warnings, {
                time = CurTime(),
                message = message,
                category = category or "General"
            })
        end
    end,
    
    -- Check for missing files
    CheckMissingFiles = function()
        local requiredFiles = {
            "lua/autorun/asc_documentation_system.lua",
            "lua/autorun/asc_console_commands.lua",
            "lua/autorun/asc_stargate_technology.lua",
            "lua/autorun/asc_resource_management.lua",
            "lua/autorun/asc_tactical_ai_system.lua",
            "lua/autorun/asc_shield_system.lua",
            "lua/autorun/asc_flight_system.lua",
            "lua/autorun/asc_docking_system.lua",
            "lua/autorun/asc_formation_system.lua",
            "lua/autorun/asc_boss_system.lua",
            "lua/autorun/asc_weapon_system.lua",
            "lua/autorun/asc_ai_system_v2.lua",
            "lua/autorun/asc_sound_definitions.lua",
            "lua/autorun/asc_sound_system.lua",
            "lua/autorun/asc_entity_spawning.lua",
            "lua/autorun/client/asc_fonts.lua",
            "lua/autorun/client/asc_ship_camera.lua",
            "lua/autorun/client/asc_spawn_menu_organization.lua",
            "lua/autorun/client/asc_entity_categories.lua",
            "lua/autorun/client/asc_ui_system.lua"
        }
        
        ASC.Debug.Core.MissingFiles = {}
        
        for _, filePath in ipairs(requiredFiles) do
            if not file.Exists(filePath, "LUA") then
                table.insert(ASC.Debug.Core.MissingFiles, filePath)
                ASC.Debug.Core.Log(2, "Missing file: " .. filePath, "FileCheck")
            end
        end
        
        if #ASC.Debug.Core.MissingFiles > 0 then
            ASC.Debug.Core.Log(2, "Found " .. #ASC.Debug.Core.MissingFiles .. " missing files", "FileCheck")
        else
            ASC.Debug.Core.Log(3, "All required files found", "FileCheck")
        end
    end,
    
    -- Check system integrity
    CheckSystemIntegrity = function()
        local checks = {
            {
                name = "ASC Namespace",
                check = function() return ASC ~= nil end,
                fix = function() ASC = ASC or {} end
            },
            {
                name = "System Status",
                check = function() return ASC.SystemStatus ~= nil end,
                fix = function() ASC.SystemStatus = ASC.SystemStatus or {} end
            },
            {
                name = "Config System",
                check = function() return ASC.Config ~= nil end,
                fix = function() ASC.Config = ASC.Config or {} end
            },
            {
                name = "Flight System",
                check = function() return ASC.Flight ~= nil and ASC.Flight.Core ~= nil end,
                fix = function() 
                    ASC.Flight = ASC.Flight or {}
                    ASC.Flight.Core = ASC.Flight.Core or {}
                end
            },
            {
                name = "Weapon System",
                check = function() return ASC.Weapons ~= nil and ASC.Weapons.Core ~= nil end,
                fix = function() 
                    ASC.Weapons = ASC.Weapons or {}
                    ASC.Weapons.Core = ASC.Weapons.Core or {}
                end
            },
            {
                name = "AI System",
                check = function() return ASC.AI ~= nil end,
                fix = function() ASC.AI = ASC.AI or {} end
            },
            {
                name = "Tactical AI",
                check = function() return ASC.TacticalAI ~= nil and ASC.TacticalAI.Core ~= nil end,
                fix = function() 
                    ASC.TacticalAI = ASC.TacticalAI or {}
                    ASC.TacticalAI.Core = ASC.TacticalAI.Core or {}
                end
            },
            {
                name = "Formation System",
                check = function() return ASC.Formation ~= nil and ASC.Formation.Core ~= nil end,
                fix = function() 
                    ASC.Formation = ASC.Formation or {}
                    ASC.Formation.Core = ASC.Formation.Core or {}
                end
            },
            {
                name = "Boss System",
                check = function() return ASC.Boss ~= nil and ASC.Boss.Core ~= nil end,
                fix = function() 
                    ASC.Boss = ASC.Boss or {}
                    ASC.Boss.Core = ASC.Boss.Core or {}
                end
            },
            {
                name = "Docking System",
                check = function() return ASC.Docking ~= nil and ASC.Docking.Core ~= nil end,
                fix = function() 
                    ASC.Docking = ASC.Docking or {}
                    ASC.Docking.Core = ASC.Docking.Core or {}
                end
            }
        }
        
        for _, check in ipairs(checks) do
            if not check.check() then
                ASC.Debug.Core.Log(2, "System integrity issue: " .. check.name, "SystemCheck")
                
                if ASC.Debug.Config.AutoFix and check.fix then
                    check.fix()
                    ASC.Debug.Core.Log(3, "Auto-fixed: " .. check.name, "SystemCheck")
                end
            else
                ASC.Debug.Core.Log(4, "System OK: " .. check.name, "SystemCheck")
            end
        end
    end,
    
    -- Run diagnostics
    RunDiagnostics = function()
        ASC.Debug.Core.Log(3, "Running system diagnostics", "Diagnostics")
        
        -- Check ConVars (Phase 3 Enhanced)
        local convars = {
            "asc_enabled",
            "asc_debug_mode",
            "asc_max_range",
            "asc_energy_cost",
            "asc_show_front_indicators",
            "asc_auto_show_arrows",
            "asc_indicator_distance",
            "asc_ship_core_volume",
            "asc_enable_ship_sounds",
            "asc_default_ship_sound"
        }
        
        for _, cvar in ipairs(convars) do
            if not ConVarExists(cvar) then
                ASC.Debug.Core.Log(2, "Missing ConVar: " .. cvar, "ConVar")
            end
        end
        
        -- Check timers
        local timers = {
            "ASC_Flight_Update",
            "ASC_Weapons_Update",
            "ASC_TacticalAI_Update",
            "ASC_Formation_Update",
            "ASC_Boss_Update",
            "ASC_Docking_Update"
        }
        
        for _, timerName in ipairs(timers) do
            if timer.Exists(timerName) then
                ASC.Debug.Core.Log(4, "Timer active: " .. timerName, "Timer")
            else
                ASC.Debug.Core.Log(2, "Timer not found: " .. timerName, "Timer")
            end
        end
        
        -- Check system status
        if ASC.SystemStatus then
            local systemCount = 0
            local activeCount = 0
            
            for system, status in pairs(ASC.SystemStatus) do
                if type(status) == "boolean" then
                    systemCount = systemCount + 1
                    if status then
                        activeCount = activeCount + 1
                    end
                end
            end
            
            ASC.Debug.Core.Log(3, "Systems: " .. activeCount .. "/" .. systemCount .. " active", "SystemStatus")
        end
    end,
    
    -- Get debug report
    GetDebugReport = function()
        local report = "🔧 Advanced Space Combat - Debug Report\n"
        report = report .. "Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"
        
        -- System status
        report = report .. "📊 System Status:\n"
        if ASC.SystemStatus then
            for system, status in pairs(ASC.SystemStatus) do
                if type(status) == "boolean" then
                    local icon = status and "✅" or "❌"
                    report = report .. icon .. " " .. system .. "\n"
                end
            end
        end
        
        -- Missing files
        if #ASC.Debug.Core.MissingFiles > 0 then
            report = report .. "\n📁 Missing Files (" .. #ASC.Debug.Core.MissingFiles .. "):\n"
            for _, file in ipairs(ASC.Debug.Core.MissingFiles) do
                report = report .. "❌ " .. file .. "\n"
            end
        end
        
        -- Errors
        if #ASC.Debug.Core.Errors > 0 then
            report = report .. "\n🚨 Errors (" .. #ASC.Debug.Core.Errors .. "):\n"
            for i = math.max(1, #ASC.Debug.Core.Errors - 5), #ASC.Debug.Core.Errors do
                local error = ASC.Debug.Core.Errors[i]
                report = report .. "❌ [" .. error.category .. "] " .. error.message .. "\n"
            end
        end
        
        -- Warnings
        if #ASC.Debug.Core.Warnings > 0 then
            report = report .. "\n⚠️ Warnings (" .. #ASC.Debug.Core.Warnings .. "):\n"
            for i = math.max(1, #ASC.Debug.Core.Warnings - 5), #ASC.Debug.Core.Warnings do
                local warning = ASC.Debug.Core.Warnings[i]
                report = report .. "⚠️ [" .. warning.category .. "] " .. warning.message .. "\n"
            end
        end
        
        -- Recommendations
        report = report .. "\n💡 Recommendations:\n"
        
        if #ASC.Debug.Core.MissingFiles > 0 then
            report = report .. "• Install missing files or disable related systems\n"
        end
        
        if #ASC.Debug.Core.Errors > 0 then
            report = report .. "• Check console for detailed error messages\n"
        end
        
        if ASC.SystemStatus and not ASC.SystemStatus.FlightSystem then
            report = report .. "• Flight system not active - check for errors\n"
        end
        
        if ASC.SystemStatus and not ASC.SystemStatus.WeaponsSystem then
            report = report .. "• Weapon system not active - check for errors\n"
        end
        
        return report
    end,
    
    -- Fix common issues
    FixCommonIssues = function()
        local fixes = 0
        
        -- Fix missing namespaces
        if not ASC.Flight then
            ASC.Flight = { Core = {} }
            fixes = fixes + 1
        end
        
        if not ASC.Weapons then
            ASC.Weapons = { Core = {} }
            fixes = fixes + 1
        end
        
        if not ASC.AI then
            ASC.AI = {}
            fixes = fixes + 1
        end
        
        -- Fix missing system status
        if not ASC.SystemStatus then
            ASC.SystemStatus = {}
            fixes = fixes + 1
        end
        
        -- Fix missing config
        if not ASC.Config then
            ASC.Config = {}
            fixes = fixes + 1
        end
        
        ASC.Debug.Core.Log(3, "Applied " .. fixes .. " automatic fixes", "AutoFix")
        return fixes
    end
}

-- Add debug commands to AI system
if ASC.AI then
    ASC.AI.HandleDebugCommands = function(player, query, queryLower)
        if not IsValid(player) then return "Invalid player" end
        
        if string.find(queryLower, "debug report") then
            return ASC.Debug.Core.GetDebugReport()
        elseif string.find(queryLower, "debug fix") then
            local fixes = ASC.Debug.Core.FixCommonIssues()
            return "🔧 Applied " .. fixes .. " automatic fixes"
        elseif string.find(queryLower, "debug status") then
            local errorCount = #ASC.Debug.Core.Errors
            local warningCount = #ASC.Debug.Core.Warnings
            local missingCount = #ASC.Debug.Core.MissingFiles
            
            return "🔧 Debug Status:\n" ..
                   "🚨 Errors: " .. errorCount .. "\n" ..
                   "⚠️ Warnings: " .. warningCount .. "\n" ..
                   "📁 Missing Files: " .. missingCount .. "\n" ..
                   "💡 Use 'aria debug report' for details"
        else
            return "🔧 Debug Commands:\n" ..
                   "• 'aria debug status' - Quick debug overview\n" ..
                   "• 'aria debug report' - Full debug report\n" ..
                   "• 'aria debug fix' - Apply automatic fixes"
        end
    end
end

-- Initialize on server
if SERVER then
    -- Initialize debug system
    timer.Simple(1, function()
        ASC.Debug.Core.Initialize()
    end)
    
    print("[Advanced Space Combat] Debug System v5.1.0 - Phase 3 Enhanced - loaded")
end
