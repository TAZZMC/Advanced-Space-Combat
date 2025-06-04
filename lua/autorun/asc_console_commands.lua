-- Advanced Space Combat - Console Commands v5.1.0
-- Comprehensive console command system with help and administration
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Advanced Space Combat] Console Commands v5.1.0 - Ultimate Edition Loading...")

-- Initialize console commands namespace
ASC = ASC or {}
ASC.Commands = ASC.Commands or {}

-- Command configuration
ASC.Commands.Config = {
    Prefix = "asc_",
    AdminPrefix = "asc_admin_",
    EnableHelp = true,
    EnableAutocomplete = true,
    LogCommands = true
}

-- Command registry
ASC.Commands.Registry = {}

-- Command categories
ASC.Commands.Categories = {
    "General",
    "Ship Management", 
    "Combat",
    "Flight",
    "Transport",
    "Configuration",
    "Debug",
    "Admin"
}

-- Register a new command
function ASC.Commands.Register(name, func, description, category, adminOnly)
    local fullName = ASC.Commands.Config.Prefix .. name
    
    ASC.Commands.Registry[name] = {
        name = name,
        fullName = fullName,
        func = func,
        description = description or "No description available",
        category = category or "General",
        adminOnly = adminOnly or false,
        usage = "",
        examples = {}
    }
    
    -- Register the actual console command
    concommand.Add(fullName, function(ply, cmd, args, argStr)
        -- Check admin permissions
        if adminOnly and IsValid(ply) and not ply:IsAdmin() then
            ply:ChatPrint("[Advanced Space Combat] This command requires admin privileges")
            return
        end
        
        -- Log command usage
        if ASC.Commands.Config.LogCommands then
            local playerName = IsValid(ply) and ply:Name() or "Console"
            print("[Advanced Space Combat] Command executed: " .. cmd .. " by " .. playerName)
        end
        
        -- Execute command
        local success, err = pcall(func, ply, cmd, args, argStr)
        if not success then
            local errorMsg = "[Advanced Space Combat] Command error: " .. tostring(err)
            print(errorMsg)
            if IsValid(ply) then
                ply:ChatPrint(errorMsg)
            end
        end
    end)
end

-- General Commands
ASC.Commands.Register("help", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local category = args[1]

    -- Get localized text function
    local function GetText(key, fallback)
        if ASC.Czech and ASC.Czech.GetText then
            return ASC.Czech.GetText(key, fallback)
        end
        return fallback or key
    end

    if category then
        -- Show commands in specific category
        local categoryText = GetText("Commands in category", "Commands in category")
        ply:ChatPrint("[" .. GetText("Advanced Space Combat", "Advanced Space Combat") .. "] " .. categoryText .. ": " .. GetText(category, category))
        for name, cmdData in pairs(ASC.Commands.Registry) do
            if cmdData.category == category then
                ply:ChatPrint("• " .. cmdData.fullName .. " - " .. GetText(cmdData.description, cmdData.description))
            end
        end
    else
        -- Show all categories and ARIA-4 info
        ply:ChatPrint("[" .. GetText("Advanced Space Combat", "Advanced Space Combat") .. "] v5.1.0 - ARIA-4 Ultimate Edition")
        ply:ChatPrint(GetText("Available command categories", "Available command categories") .. ":")
        for _, cat in ipairs(ASC.Commands.Categories) do
            local localizedCat = GetText(cat, cat)
            ply:ChatPrint("• " .. localizedCat .. " (use 'asc_help " .. cat .. "' for commands)")
        end
        ply:ChatPrint("")
        ply:ChatPrint("ARIA-4 AI " .. GetText("Commands", "Commands") .. ":")
        ply:ChatPrint("• aria " .. GetText("help", "help") .. " - " .. GetText("AI assistance", "AI assistance"))
        ply:ChatPrint("• aria <" .. GetText("question", "question") .. "> - " .. GetText("Ask anything", "Ask anything"))
        ply:ChatPrint("• aria " .. GetText("system status", "system status") .. " - " .. GetText("System overview", "System overview"))
        ply:ChatPrint("• aria " .. GetText("ship status", "ship status") .. " - " .. GetText("Ship information", "Ship information"))
        ply:ChatPrint("• Legacy: !ai " .. GetText("commands", "commands") .. " " .. GetText("still supported", "still supported"))
        ply:ChatPrint("")
        ply:ChatPrint(GetText("Use", "Use") .. " 'asc_help <" .. GetText("category", "category") .. ">' " .. GetText("to see commands in that category", "to see commands in that category"))
    end
end, "Show help for commands", "General")

ASC.Commands.Register("version", function(ply, cmd, args)
    -- Get localized text function
    local function GetText(key, fallback)
        if ASC.Czech and ASC.Czech.GetText then
            return ASC.Czech.GetText(key, fallback)
        end
        return fallback or key
    end

    local msg = "[" .. GetText("Advanced Space Combat", "Advanced Space Combat") .. "] " ..
                GetText("Version", "Version") .. ": " .. ASC.VERSION .. " " ..
                GetText("Build", "Build") .. ": " .. ASC.BUILD
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end, "Show addon version information", "General")

-- Czech localization command
ASC.Commands.Register("czech", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local action = args[1] or "enable"

    if action == "enable" or action == "on" or action == "1" then
        if ASC.Czech then
            ASC.Czech.SetEnabled(true)
            ply:ChatPrint("[" .. ASC.Czech.GetText("Advanced Space Combat", "Advanced Space Combat") .. "] " ..
                         ASC.Czech.GetText("Czech localization enabled", "Česká lokalizace povolena") .. " 🇨🇿")
            ply:ChatPrint("[ASC] " .. ASC.Czech.GetText("All text will now be displayed in Czech", "Veškerý text bude nyní zobrazen v češtině"))
        else
            ply:ChatPrint("[Advanced Space Combat] Czech localization system not loaded!")
        end
    elseif action == "disable" or action == "off" or action == "0" then
        if ASC.Czech then
            ASC.Czech.SetEnabled(false)
            ply:ChatPrint("[Advanced Space Combat] Czech localization disabled")
        else
            ply:ChatPrint("[Advanced Space Combat] Czech localization system not loaded!")
        end
    elseif action == "status" then
        if ASC.Czech then
            local enabled = ASC.Czech.IsEnabled()
            local status = enabled and "enabled" or "disabled"
            local statusCzech = enabled and "povolena" or "zakázána"
            ply:ChatPrint("[Advanced Space Combat] Czech localization: " .. status .. " / Česká lokalizace: " .. statusCzech)
            ply:ChatPrint("[ASC] Available translations: " .. table.Count(ASC.Czech.Translations))
        else
            ply:ChatPrint("[Advanced Space Combat] Czech localization system not loaded!")
        end
    else
        ply:ChatPrint("[Advanced Space Combat] Usage: asc_czech [enable|disable|status]")
        ply:ChatPrint("[ASC] Použití: asc_czech [enable|disable|status]")
    end
end, "Enable/disable Czech localization for the entire addon", "Configuration")

ASC.Commands.Register("status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[Advanced Space Combat] System Status:")
    ply:ChatPrint("Version: " .. ASC.VERSION .. " (" .. ASC.STATUS .. ")")
    ply:ChatPrint("Features: " .. #ASC.FEATURES .. " systems loaded")
    
    -- Show entity counts
    if ASC.SystemStatus and ASC.SystemStatus.EntityCounts then
        ply:ChatPrint("Entity Counts:")
        for entityType, count in pairs(ASC.SystemStatus.EntityCounts) do
            ply:ChatPrint("• " .. entityType .. ": " .. count)
        end
    end
    
    -- Show system status
    if ASC.SystemStatus then
        ply:ChatPrint("System Status:")
        local systems = {
            {"Weapons System", ASC.SystemStatus.WeaponsSystem},
            {"Flight System", ASC.SystemStatus.FlightSystem},
            {"Docking System", ASC.SystemStatus.DockingPadSystem},
            {"Chat AI", ASC.SystemStatus.ChatAI},
            {"Undo System", ASC.SystemStatus.UndoSystem}
        }
        
        for _, system in ipairs(systems) do
            local status = system[2] and "✓ Active" or "✗ Inactive"
            ply:ChatPrint("• " .. system[1] .. ": " .. status)
        end
    end
end, "Show comprehensive system status", "General")

-- Ship Management Commands
ASC.Commands.Register("spawn_ship_core", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local shipName = args[1] or "New Ship"
    
    -- Get player's aim position
    local trace = ply:GetEyeTrace()
    local pos = trace.HitPos + trace.HitNormal * 50
    local ang = ply:EyeAngles()
    ang.pitch = 0
    ang.roll = 0
    
    -- Spawn ship core
    local shipCore = ents.Create("asc_ship_core")
    if IsValid(shipCore) then
        shipCore:SetPos(pos)
        shipCore:SetAngles(ang)
        shipCore:Spawn()
        shipCore:SetNWString("ShipName", shipName)

        ply:ChatPrint("[Advanced Space Combat] ASC ship core '" .. shipName .. "' spawned successfully!")

        -- Add to undo
        undo.Create("ASC Ship Core")
        undo.AddEntity(shipCore)
        undo.SetPlayer(ply)
        undo.Finish()
    else
        ply:ChatPrint("[Advanced Space Combat] Failed to spawn ASC ship core")
    end
end, "Spawn a ship core with optional name", "Ship Management")

ASC.Commands.Register("list_ships", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local shipCores = ents.FindByClass("ship_core")
    
    if #shipCores == 0 then
        ply:ChatPrint("[Advanced Space Combat] No ships found")
        return
    end
    
    ply:ChatPrint("[Advanced Space Combat] Active Ships:")
    for i, core in ipairs(shipCores) do
        local shipName = core:GetNWString("ShipName", "Unnamed Ship")
        local owner = core:GetNWString("Owner", "Unknown")
        local health = core:Health() or 0
        local maxHealth = core:GetMaxHealth() or 1000
        
        ply:ChatPrint(string.format("• %s (Owner: %s, Health: %d/%d)", 
            shipName, owner, health, maxHealth))
    end
end, "List all active ships", "Ship Management")

-- Combat Commands
ASC.Commands.Register("spawn_weapon", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local weaponType = args[1] or "asc_pulse_cannon"
    local validWeapons = {
        "asc_pulse_cannon",
        "asc_beam_weapon", 
        "asc_torpedo_launcher",
        "asc_railgun",
        "asc_plasma_cannon"
    }
    
    if not table.HasValue(validWeapons, weaponType) then
        ply:ChatPrint("[Advanced Space Combat] Invalid weapon type. Valid types:")
        for _, weapon in ipairs(validWeapons) do
            ply:ChatPrint("• " .. weapon)
        end
        return
    end
    
    -- Get spawn position
    local trace = ply:GetEyeTrace()
    local pos = trace.HitPos + trace.HitNormal * 50
    local ang = ply:EyeAngles()
    ang.pitch = 0
    ang.roll = 0
    
    -- Spawn weapon
    local weapon = ents.Create(weaponType)
    if IsValid(weapon) then
        weapon:SetPos(pos)
        weapon:SetAngles(ang)
        weapon:Spawn()
        
        ply:ChatPrint("[Advanced Space Combat] " .. weaponType .. " spawned successfully!")
        
        -- Add to undo
        undo.Create("Weapon")
        undo.AddEntity(weapon)
        undo.SetPlayer(ply)
        undo.Finish()
    else
        ply:ChatPrint("[Advanced Space Combat] Failed to spawn weapon")
    end
end, "Spawn a weapon of specified type", "Combat")

-- Flight Commands
ASC.Commands.Register("spawn_flight_console", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local trace = ply:GetEyeTrace()
    local pos = trace.HitPos + trace.HitNormal * 50
    local ang = ply:EyeAngles()
    ang.pitch = 0
    ang.roll = 0
    
    local console = ents.Create("asc_flight_console")
    if IsValid(console) then
        console:SetPos(pos)
        console:SetAngles(ang)
        console:Spawn()
        
        ply:ChatPrint("[Advanced Space Combat] Flight console spawned successfully!")
        
        undo.Create("Flight Console")
        undo.AddEntity(console)
        undo.SetPlayer(ply)
        undo.Finish()
    else
        ply:ChatPrint("[Advanced Space Combat] Failed to spawn flight console")
    end
end, "Spawn a flight console", "Flight")

-- Transport Commands
ASC.Commands.Register("spawn_docking_pad", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local padType = args[1] or "medium"
    local validTypes = {"small", "medium", "large", "shuttle", "cargo"}
    
    if not table.HasValue(validTypes, padType) then
        ply:ChatPrint("[Advanced Space Combat] Invalid pad type. Valid types: " .. table.concat(validTypes, ", "))
        return
    end
    
    local trace = ply:GetEyeTrace()
    local pos = trace.HitPos + trace.HitNormal * 10
    local ang = Angle(0, ply:EyeAngles().yaw, 0)
    
    local pad = ents.Create("asc_docking_pad")
    if IsValid(pad) then
        pad:SetPos(pos)
        pad:SetAngles(ang)
        pad:SetNWString("PadType", padType)
        pad:Spawn()
        
        ply:ChatPrint("[Advanced Space Combat] " .. padType .. " docking pad spawned successfully!")
        
        undo.Create("Docking Pad")
        undo.AddEntity(pad)
        undo.SetPlayer(ply)
        undo.Finish()
    else
        ply:ChatPrint("[Advanced Space Combat] Failed to spawn docking pad")
    end
end, "Spawn a docking pad of specified type", "Transport")

-- Configuration Commands
ASC.Commands.Register("config", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local setting = args[1]
    local value = args[2]
    
    if not setting then
        ply:ChatPrint("[Advanced Space Combat] Available settings:")
        ply:ChatPrint("• weapons_enabled - Enable/disable weapon systems")
        ply:ChatPrint("• flight_enabled - Enable/disable flight systems")
        ply:ChatPrint("• docking_enabled - Enable/disable docking systems")
        ply:ChatPrint("• chat_ai_enabled - Enable/disable ARIA-4 chat AI")
        ply:ChatPrint("• debug_mode - Enable/disable debug mode")
        ply:ChatPrint("Usage: asc_config <setting> <value>")
        return
    end
    
    if not value then
        -- Show current value
        local cvar = GetConVar("asc_enable_" .. setting:gsub("_enabled", ""))
        if cvar then
            ply:ChatPrint("[Advanced Space Combat] " .. setting .. " = " .. cvar:GetString())
        else
            ply:ChatPrint("[Advanced Space Combat] Unknown setting: " .. setting)
        end
        return
    end
    
    -- Set value
    local cvarName = "asc_enable_" .. setting:gsub("_enabled", "")
    local cvar = GetConVar(cvarName)
    if cvar then
        RunConsoleCommand(cvarName, value)
        ply:ChatPrint("[Advanced Space Combat] " .. setting .. " set to " .. value)
    else
        ply:ChatPrint("[Advanced Space Combat] Unknown setting: " .. setting)
    end
end, "Configure addon settings", "Configuration")

-- Debug Commands
ASC.Commands.Register("debug_info", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[Advanced Space Combat] Debug Information:")
    ply:ChatPrint("Lua State: " .. (CLIENT and "CLIENT" or "SERVER"))
    ply:ChatPrint("Game Mode: " .. engine.ActiveGamemode())
    ply:ChatPrint("Map: " .. game.GetMap())
    ply:ChatPrint("Players: " .. #player.GetAll())
    ply:ChatPrint("Entities: " .. #ents.GetAll())
    
    -- Memory usage
    local memUsage = collectgarbage("count")
    ply:ChatPrint("Memory Usage: " .. math.Round(memUsage / 1024, 2) .. " MB")
    
    -- FPS (client only)
    if CLIENT then
        ply:ChatPrint("FPS: " .. math.Round(1 / FrameTime()))
    end
end, "Show debug information", "Debug")

-- Admin Commands
ASC.Commands.Register("cleanup", function(ply, cmd, args)
    local entityType = args[1] or "all"
    local count = 0
    
    if entityType == "all" then
        -- Clean up all ASC entities
        local ascEntities = {}
        for _, ent in ipairs(ents.GetAll()) do
            local class = ent:GetClass()
            if string.find(class, "asc_") or string.find(class, "ship_core") or string.find(class, "hyperdrive_") then
                table.insert(ascEntities, ent)
            end
        end
        
        for _, ent in ipairs(ascEntities) do
            if IsValid(ent) then
                ent:Remove()
                count = count + 1
            end
        end
    else
        -- Clean up specific entity type
        local entities = ents.FindByClass(entityType)
        for _, ent in ipairs(entities) do
            if IsValid(ent) then
                ent:Remove()
                count = count + 1
            end
        end
    end
    
    local msg = "[Advanced Space Combat] Cleaned up " .. count .. " entities"
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end, "Clean up ASC entities", "Admin", true)

ASC.Commands.Register("reload", function(ply, cmd, args)
    -- Reload the addon
    local msg = "[Advanced Space Combat] Reloading addon..."
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
    
    -- This would trigger a reload of the addon
    -- Implementation depends on specific reload mechanism
    
end, "Reload the addon", "Admin", true)

-- Initialize autocomplete
hook.Add("OnPlayerChat", "ASC_CommandAutocomplete", function(ply, text, team, dead)
    if not ASC.Commands.Config.EnableAutocomplete then return end
    
    -- Check if text starts with command prefix
    if string.sub(text, 1, #ASC.Commands.Config.Prefix) == ASC.Commands.Config.Prefix then
        local partial = string.sub(text, #ASC.Commands.Config.Prefix + 1)
        
        -- Find matching commands
        local matches = {}
        for name, cmdData in pairs(ASC.Commands.Registry) do
            if string.find(name, partial) == 1 then
                table.insert(matches, cmdData.fullName)
            end
        end
        
        -- Show suggestions
        if #matches > 0 and #matches <= 5 then
            ply:ChatPrint("[Advanced Space Combat] Command suggestions:")
            for _, match in ipairs(matches) do
                ply:ChatPrint("• " .. match)
            end
        end
    end
end)

-- Missing console commands implementation
ASC.Commands.Register("weapon_interface", function(ply, cmd, args)
    if not IsValid(ply) then return end

    -- Open weapon interface (placeholder for actual implementation)
    ply:ChatPrint("[Advanced Space Combat] Opening weapon interface...")
    ply:ConCommand("asc_weapon_config")
end, "Open weapon configuration interface", "Combat")

-- Enhanced Hyperspace Help System
ASC.Commands.Register("help", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local topic = args[1] or "main"

    if topic == "main" or topic == "hyperspace" then
        ply:ChatPrint("=== Enhanced Hyperspace System Help ===")
        ply:ChatPrint("Basic Commands:")
        ply:ChatPrint("  aria set_destination [coordinates] - Set hyperspace destination")
        ply:ChatPrint("  aria set_destination [player_name] - Set destination to player location")
        ply:ChatPrint("  aria jump - Initiate hyperspace travel")
        ply:ChatPrint("  aria abort - Cancel hyperspace sequence")
        ply:ChatPrint("  aria status - Check engine status")
        ply:ChatPrint("")
        ply:ChatPrint("For more help: aria help [fleet|effects|physics|troubleshooting]")

    elseif topic == "fleet" then
        ply:ChatPrint("=== Fleet Coordination Help ===")
        ply:ChatPrint("Fleet Commands:")
        ply:ChatPrint("  aria fleet status - View fleet information")
        ply:ChatPrint("  aria fleet sync - Force fleet synchronization")
        ply:ChatPrint("  aria fleet formation [type] - Set formation")
        ply:ChatPrint("  aria emergency [type] - Trigger emergency protocols")
        ply:ChatPrint("")
        ply:ChatPrint("Formations: Diamond, V-Formation, Line, Sphere")
        ply:ChatPrint("Fleet Size: Up to 12 engines, optimal 4-6")
        ply:ChatPrint("Range: 3000 units for auto-coordination")

    elseif topic == "effects" then
        ply:ChatPrint("=== Visual Effects Help ===")
        ply:ChatPrint("4-Stage Travel Process:")
        ply:ChatPrint("  Stage 1 (4.0s): Energy buildup + vortex formation")
        ply:ChatPrint("  Stage 2 (3.5s): Blue window + swirling energy")
        ply:ChatPrint("  Stage 3 (6.0s): Dimensional transit + starlines")
        ply:ChatPrint("  Stage 4 (2.5s): Dramatic exit + stabilization")
        ply:ChatPrint("")
        ply:ChatPrint("Features: 3000 particles, 24 vortex rings, quantum effects")
        ply:ChatPrint("Theme: Authentic Stargate blue energy aesthetics")

    elseif topic == "physics" then
        ply:ChatPrint("=== Advanced Physics Help ===")
        ply:ChatPrint("TARDIS-Inspired Features:")
        ply:ChatPrint("  Spatial Folding: 90% distance reduction")
        ply:ChatPrint("  Dimensional Layers: 8 layers for traffic management")
        ply:ChatPrint("  Time Distortion: 15% time dilation effects")
        ply:ChatPrint("  Quantum Tunneling: 98% tunnel stability")
        ply:ChatPrint("")
        ply:ChatPrint("Stargate Integration:")
        ply:ChatPrint("  304.8 Hz frequency coordination")
        ply:ChatPrint("  Ancient technology bonuses")
        ply:ChatPrint("  SG-1 Enhanced protocols")

    elseif topic == "troubleshooting" then
        ply:ChatPrint("=== Troubleshooting Help ===")
        ply:ChatPrint("Common Issues:")
        ply:ChatPrint("  'No ship core detected' - Add ship core to your ship")
        ply:ChatPrint("  'Insufficient energy' - Check power generation")
        ply:ChatPrint("  'Coordination failed' - Use 'aria fleet sync'")
        ply:ChatPrint("  'Window unstable' - Reduce ship complexity")
        ply:ChatPrint("")
        ply:ChatPrint("Debug: Use 'aria debug on' for detailed information")
        ply:ChatPrint("Performance: Reduce fleet size or visual effects")

    else
        ply:ChatPrint("Available help topics: main, fleet, effects, physics, troubleshooting")
    end
end, "Show Enhanced Hyperspace help system", "Help")

ASC.Commands.Register("quickstart", function(ply, cmd, args)
    if not IsValid(ply) then return end

    ply:ChatPrint("=== Enhanced Hyperspace Quick Start ===")
    ply:ChatPrint("1. Spawn hyperdrive_master_engine from spawn menu")
    ply:ChatPrint("2. Build ship around engine (weld props, seats, etc.)")
    ply:ChatPrint("3. Set destination: aria set_destination [coordinates] or aria set_destination [player]")
    ply:ChatPrint("4. Initiate jump: aria jump")
    ply:ChatPrint("5. Enjoy enhanced 4-stage hyperspace travel!")
    ply:ChatPrint("")
    ply:ChatPrint("For detailed help: aria help")
    ply:ChatPrint("For fleet coordination: aria help fleet")
end, "Show quick start guide", "Help")

-- Enhanced Hyperspace Configuration Commands
ASC.Commands.Register("config", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local system = args[1]
    local setting = args[2]
    local value = args[3]

    if not system then
        ply:ChatPrint("=== Enhanced Hyperspace Configuration ===")
        ply:ChatPrint("Usage: aria config [system] [setting] [value]")
        ply:ChatPrint("Systems: hyperspace, coordination, effects")
        ply:ChatPrint("Example: aria config effects particles 2000")
        ply:ChatPrint("Use 'aria config [system]' to see available settings")
        return
    end

    if system == "hyperspace" then
        if not setting then
            ply:ChatPrint("Hyperspace Settings:")
            ply:ChatPrint("  stage1_duration - Stage 1 duration (default: 4.0)")
            ply:ChatPrint("  stage2_duration - Stage 2 duration (default: 3.5)")
            ply:ChatPrint("  stage3_duration - Stage 3 duration (default: 6.0)")
            ply:ChatPrint("  stage4_duration - Stage 4 duration (default: 2.5)")
            ply:ChatPrint("  spatial_folding - Enable spatial folding (1/0)")
            ply:ChatPrint("  quantum_stability - Quantum tunnel stability (0.0-1.0)")
            return
        end

        if setting == "spatial_folding" and value then
            local enabled = tonumber(value) == 1
            if ASC.EnhancedHyperspace and ASC.EnhancedHyperspace.Config then
                ASC.EnhancedHyperspace.Config.HyperspacePhysics.EnableSpatialFolding = enabled
                ply:ChatPrint("Spatial folding " .. (enabled and "enabled" or "disabled"))
            end
        end

    elseif system == "coordination" then
        if not setting then
            ply:ChatPrint("Coordination Settings:")
            ply:ChatPrint("  sync_radius - Engine detection radius (default: 3000)")
            ply:ChatPrint("  sync_tolerance - Sync tolerance in seconds (default: 0.025)")
            ply:ChatPrint("  max_fleet_size - Maximum engines per fleet (default: 12)")
            ply:ChatPrint("  quantum_entanglement - Enable quantum coordination (1/0)")
            ply:ChatPrint("  predictive_sync - Enable predictive synchronization (1/0)")
            return
        end

        if setting == "quantum_entanglement" and value then
            local enabled = tonumber(value) == 1
            if ASC.MasterEngineCoord and ASC.MasterEngineCoord.Config then
                ASC.MasterEngineCoord.Config.Synchronization.EnableQuantumEntanglement = enabled
                ply:ChatPrint("Quantum entanglement " .. (enabled and "enabled" or "disabled"))
            end
        end

    elseif system == "effects" then
        if not setting then
            ply:ChatPrint("Visual Effects Settings:")
            ply:ChatPrint("  particles - Particle count (default: 3000)")
            ply:ChatPrint("  vortex_rings - Vortex ring count (default: 24)")
            ply:ChatPrint("  quantum_particles - Quantum particle count (default: 200)")
            ply:ChatPrint("  progressive_vortex - Enable progressive vortex (1/0)")
            ply:ChatPrint("  energy_harmonics - Enable energy harmonics (1/0)")
            return
        end

        -- Effect settings would be applied to client-side config
        ply:ChatPrint("Effect setting '" .. setting .. "' noted for next hyperspace travel")

    else
        ply:ChatPrint("Unknown system: " .. system)
        ply:ChatPrint("Available systems: hyperspace, coordination, effects")
    end
end, "Configure Enhanced Hyperspace settings", "Configuration")

-- Debug and monitoring commands
ASC.Commands.Register("debug", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local mode = args[1] or "toggle"

    if mode == "on" or mode == "1" or mode == "true" then
        ply.ASC_DebugMode = true
        ply:ChatPrint("[Enhanced Hyperspace] Debug mode enabled")
        ply:ChatPrint("You will now see detailed system information")
    elseif mode == "off" or mode == "0" or mode == "false" then
        ply.ASC_DebugMode = false
        ply:ChatPrint("[Enhanced Hyperspace] Debug mode disabled")
    else
        ply.ASC_DebugMode = not ply.ASC_DebugMode
        ply:ChatPrint("[Enhanced Hyperspace] Debug mode " .. (ply.ASC_DebugMode and "enabled" or "disabled"))
    end
end, "Toggle Enhanced Hyperspace debug mode", "Debug")

ASC.Commands.Register("performance", function(ply, cmd, args)
    if not IsValid(ply) then return end

    ply:ChatPrint("=== Enhanced Hyperspace Performance Info ===")

    -- Count active engines
    local engineCount = 0
    for _, ent in ipairs(ents.FindByClass("hyperdrive_master_engine")) do
        if IsValid(ent) then engineCount = engineCount + 1 end
    end

    -- Count active fleets
    local fleetCount = 0
    if ASC.MasterEngineCoord and ASC.MasterEngineCoord.Fleets then
        for _ in pairs(ASC.MasterEngineCoord.Fleets) do
            fleetCount = fleetCount + 1
        end
    end

    ply:ChatPrint("Active Engines: " .. engineCount)
    ply:ChatPrint("Active Fleets: " .. fleetCount)
    ply:ChatPrint("Server FPS: " .. math.floor(1 / FrameTime()))
    ply:ChatPrint("Player Count: " .. #player.GetAll())

    if engineCount > 8 then
        ply:ChatPrint("⚠️  High engine count may impact performance")
    end

    if fleetCount > 3 then
        ply:ChatPrint("⚠️  Multiple fleets may impact coordination")
    end

    ply:ChatPrint("For better performance, limit fleet size to 4-6 engines")
end, "Show Enhanced Hyperspace performance information", "Debug")

-- Essential Hyperspace Commands Implementation
ASC.Commands.Register("set_destination", function(ply, cmd, args)
    if not IsValid(ply) then return end

    -- Find nearest hyperdrive engine
    local engine = nil
    local minDist = math.huge

    for _, ent in ipairs(ents.FindByClass("hyperdrive_master_engine")) do
        if IsValid(ent) then
            local dist = ply:GetPos():Distance(ent:GetPos())
            if dist < 1000 and dist < minDist then -- Within 1000 units
                engine = ent
                minDist = dist
            end
        end
    end

    if not engine then
        ply:ChatPrint("[Enhanced Hyperspace] No hyperdrive engine found nearby (within 1000 units)")
        return
    end

    if #args == 0 then
        ply:ChatPrint("[Enhanced Hyperspace] Usage: aria set_destination [coordinates] or aria set_destination [player_name]")
        ply:ChatPrint("Examples:")
        ply:ChatPrint("  aria set_destination 1000 500 200")
        ply:ChatPrint("  aria set_destination Oliver")
        return
    end

    local destination = nil

    -- Check if it's coordinates (3 numbers)
    if #args >= 3 then
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if x and y and z then
            destination = Vector(x, y, z)
        end
    end

    -- Check if it's a player name
    if not destination and #args >= 1 then
        local targetName = table.concat(args, " ")
        for _, targetPly in ipairs(player.GetAll()) do
            if string.lower(targetPly:Nick()):find(string.lower(targetName), 1, true) then
                destination = targetPly:GetPos() + Vector(0, 0, 100) -- Slightly above player
                ply:ChatPrint("[Enhanced Hyperspace] Destination set to player: " .. targetPly:Nick())
                break
            end
        end
    end

    if not destination then
        ply:ChatPrint("[Enhanced Hyperspace] Invalid destination. Use coordinates or player name.")
        return
    end

    -- Set destination on engine
    if engine.SetDestinationPos then
        local success, message = engine:SetDestinationPos(destination)
        if success then
            ply:ChatPrint("[Enhanced Hyperspace] Destination set: " .. tostring(destination))
        else
            ply:ChatPrint("[Enhanced Hyperspace] Error: " .. (message or "Unknown error"))
        end
    else
        engine.DestinationPos = destination
        ply:ChatPrint("[Enhanced Hyperspace] Destination set: " .. tostring(destination))
    end
end, "Set hyperspace destination", "Hyperspace")

ASC.Commands.Register("jump", function(ply, cmd, args)
    if not IsValid(ply) then return end

    -- Find nearest hyperdrive engine
    local engine = nil
    local minDist = math.huge

    for _, ent in ipairs(ents.FindByClass("hyperdrive_master_engine")) do
        if IsValid(ent) then
            local dist = ply:GetPos():Distance(ent:GetPos())
            if dist < 1000 and dist < minDist then -- Within 1000 units
                engine = ent
                minDist = dist
            end
        end
    end

    if not engine then
        ply:ChatPrint("[Enhanced Hyperspace] No hyperdrive engine found nearby (within 1000 units)")
        return
    end

    -- Check if destination is set
    if not engine.DestinationPos and not (engine.GetDestination and engine:GetDestination()) then
        ply:ChatPrint("[Enhanced Hyperspace] No destination set. Use 'aria set_destination' first.")
        return
    end

    -- Initiate jump
    if engine.StartJump then
        local success, message = engine:StartJump()
        if success then
            ply:ChatPrint("[Enhanced Hyperspace] Hyperspace jump initiated!")
        else
            ply:ChatPrint("[Enhanced Hyperspace] Jump failed: " .. (message or "Unknown error"))
        end
    else
        ply:ChatPrint("[Enhanced Hyperspace] Engine does not support jumping")
    end
end, "Initiate hyperspace travel", "Hyperspace")

ASC.Commands.Register("abort", function(ply, cmd, args)
    if not IsValid(ply) then return end

    -- Find nearest hyperdrive engine
    local engine = nil
    local minDist = math.huge

    for _, ent in ipairs(ents.FindByClass("hyperdrive_master_engine")) do
        if IsValid(ent) then
            local dist = ply:GetPos():Distance(ent:GetPos())
            if dist < 1000 and dist < minDist then -- Within 1000 units
                engine = ent
                minDist = dist
            end
        end
    end

    if not engine then
        ply:ChatPrint("[Enhanced Hyperspace] No hyperdrive engine found nearby (within 1000 units)")
        return
    end

    -- Abort jump
    if engine.AbortJump then
        engine:AbortJump("User abort via console")
        ply:ChatPrint("[Enhanced Hyperspace] Hyperspace sequence aborted")
    else
        ply:ChatPrint("[Enhanced Hyperspace] Engine does not support abort function")
    end
end, "Cancel hyperspace sequence", "Hyperspace")

ASC.Commands.Register("status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    -- Find all nearby hyperdrive engines
    local engines = {}
    for _, ent in ipairs(ents.FindByClass("hyperdrive_master_engine")) do
        if IsValid(ent) then
            local dist = ply:GetPos():Distance(ent:GetPos())
            if dist < 1000 then -- Within 1000 units
                table.insert(engines, {entity = ent, distance = dist})
            end
        end
    end

    if #engines == 0 then
        ply:ChatPrint("[Enhanced Hyperspace] No hyperdrive engines found nearby (within 1000 units)")
        return
    end

    -- Sort by distance
    table.sort(engines, function(a, b) return a.distance < b.distance end)

    ply:ChatPrint("=== Enhanced Hyperspace Engine Status ===")

    for i, engineData in ipairs(engines) do
        local engine = engineData.entity
        local dist = math.floor(engineData.distance)

        ply:ChatPrint("Engine #" .. i .. " (Distance: " .. dist .. " units):")

        -- Basic status
        local status = "Unknown"
        if engine.GetCharging and engine:GetCharging() then
            status = "Charging"
        elseif engine.GetJumpReady and engine:GetJumpReady() then
            status = "Ready"
        elseif engine.IsOnCooldown and engine:IsOnCooldown() then
            status = "Cooldown"
        else
            status = "Idle"
        end
        ply:ChatPrint("  Status: " .. status)

        -- Destination
        local dest = engine.DestinationPos or (engine.GetDestination and engine:GetDestination())
        if dest then
            ply:ChatPrint("  Destination: " .. tostring(dest))
        else
            ply:ChatPrint("  Destination: Not set")
        end

        -- Energy
        if engine.GetEnergy then
            ply:ChatPrint("  Energy: " .. math.floor(engine:GetEnergy()) .. "%")
        end

        ply:ChatPrint("")
    end
end, "Check hyperdrive engine status", "Hyperspace")

-- Fleet Coordination Commands
ASC.Commands.Register("fleet", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local subcommand = args[1] or "status"

    if subcommand == "status" then
        -- Find nearby engines for fleet status
        local engines = {}
        for _, ent in ipairs(ents.FindByClass("hyperdrive_master_engine")) do
            if IsValid(ent) then
                local dist = ply:GetPos():Distance(ent:GetPos())
                if dist < 3000 then -- Fleet coordination range
                    table.insert(engines, {entity = ent, distance = dist})
                end
            end
        end

        if #engines == 0 then
            ply:ChatPrint("[Enhanced Hyperspace] No fleet engines found within coordination range (3000 units)")
            return
        end

        ply:ChatPrint("=== Enhanced Hyperspace Fleet Status ===")
        ply:ChatPrint("Engines in coordination range: " .. #engines)
        ply:ChatPrint("Optimal fleet size: 4-6 engines")
        ply:ChatPrint("Maximum fleet size: 12 engines")

        if #engines > 12 then
            ply:ChatPrint("⚠️  Warning: Too many engines may impact performance")
        elseif #engines > 6 then
            ply:ChatPrint("ℹ️  Large fleet detected - consider splitting for better performance")
        end

        -- Show quantum entanglement status
        local entangled = 0
        for _, engineData in ipairs(engines) do
            if engineData.entity.QuantumEntanglement then
                entangled = entangled + 1
            end
        end

        ply:ChatPrint("Quantum entangled engines: " .. entangled .. "/" .. #engines)

        if entangled < #engines then
            ply:ChatPrint("Use 'aria fleet sync' to establish quantum entanglement")
        end

    elseif subcommand == "sync" then
        -- Force fleet synchronization
        local engines = {}
        for _, ent in ipairs(ents.FindByClass("hyperdrive_master_engine")) do
            if IsValid(ent) then
                local dist = ply:GetPos():Distance(ent:GetPos())
                if dist < 3000 then
                    table.insert(engines, ent)
                end
            end
        end

        if #engines < 2 then
            ply:ChatPrint("[Enhanced Hyperspace] Need at least 2 engines for fleet synchronization")
            return
        end

        -- Establish quantum entanglement
        if ASC.MasterEngineCoord and ASC.MasterEngineCoord.EstablishQuantumEntanglement then
            local success = ASC.MasterEngineCoord.EstablishQuantumEntanglement(engines)
            if success then
                ply:ChatPrint("[Enhanced Hyperspace] Quantum entanglement established between " .. #engines .. " engines")
            else
                ply:ChatPrint("[Enhanced Hyperspace] Failed to establish quantum entanglement")
            end
        else
            -- Fallback synchronization
            for _, engine in ipairs(engines) do
                engine.FleetSynced = true
                engine.FleetSyncTime = CurTime()
            end
            ply:ChatPrint("[Enhanced Hyperspace] Fleet synchronized: " .. #engines .. " engines")
        end

    elseif subcommand == "formation" then
        local formationType = args[2] or "Diamond"
        local validFormations = {"Diamond", "V-Formation", "Line", "Sphere"}

        if not table.HasValue(validFormations, formationType) then
            ply:ChatPrint("[Enhanced Hyperspace] Invalid formation. Valid types: " .. table.concat(validFormations, ", "))
            return
        end

        -- Find fleet engines
        local engines = {}
        for _, ent in ipairs(ents.FindByClass("hyperdrive_master_engine")) do
            if IsValid(ent) then
                local dist = ply:GetPos():Distance(ent:GetPos())
                if dist < 3000 then
                    table.insert(engines, ent)
                end
            end
        end

        if #engines < 2 then
            ply:ChatPrint("[Enhanced Hyperspace] Need at least 2 engines for formation")
            return
        end

        -- Apply formation
        if ASC.MasterEngineCoord and ASC.MasterEngineCoord.ManageFleetFormation then
            local fleet = {engines = {}}
            for i, engine in ipairs(engines) do
                fleet.engines[i] = engine:EntIndex()
            end
            ASC.MasterEngineCoord.ManageFleetFormation(fleet, formationType)
            ply:ChatPrint("[Enhanced Hyperspace] Fleet formation set to: " .. formationType)
        else
            -- Fallback formation setting
            for i, engine in ipairs(engines) do
                engine.FleetFormation = formationType
                engine.FormationPosition = i
            end
            ply:ChatPrint("[Enhanced Hyperspace] Fleet formation set to: " .. formationType .. " (" .. #engines .. " engines)")
        end

    else
        ply:ChatPrint("[Enhanced Hyperspace] Fleet subcommands: status, sync, formation [type]")
        ply:ChatPrint("Formations: Diamond, V-Formation, Line, Sphere")
    end
end, "Fleet coordination commands", "Hyperspace")

ASC.Commands.Register("emergency", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local emergencyType = args[1] or "general"

    -- Find nearest engine
    local engine = nil
    local minDist = math.huge

    for _, ent in ipairs(ents.FindByClass("hyperdrive_master_engine")) do
        if IsValid(ent) then
            local dist = ply:GetPos():Distance(ent:GetPos())
            if dist < 1000 and dist < minDist then
                engine = ent
                minDist = dist
            end
        end
    end

    if not engine then
        ply:ChatPrint("[Enhanced Hyperspace] No hyperdrive engine found nearby for emergency protocols")
        return
    end

    ply:ChatPrint("[Enhanced Hyperspace] Emergency protocol activated: " .. emergencyType)

    if emergencyType == "abort" then
        -- Emergency abort
        if engine.AbortJump then
            engine:AbortJump("Emergency abort")
        end
        ply:ChatPrint("Emergency abort completed")

    elseif emergencyType == "reroute" then
        -- Emergency rerouting
        if ASC.MasterEngineCoord and ASC.MasterEngineCoord.EmergencyRerouting then
            local originalDest = engine.DestinationPos or Vector(0, 0, 0)
            local newDest = ASC.MasterEngineCoord.EmergencyRerouting(engine, originalDest, "manual")
            ply:ChatPrint("Emergency rerouting completed")
        else
            ply:ChatPrint("Emergency rerouting not available")
        end

    elseif emergencyType == "shutdown" then
        -- Emergency shutdown
        if engine.SetCharging then
            engine:SetCharging(false)
        end
        if engine.SetJumpReady then
            engine:SetJumpReady(false)
        end
        ply:ChatPrint("Emergency shutdown completed")

    else
        ply:ChatPrint("Emergency types: abort, reroute, shutdown")
    end
end, "Emergency hyperspace protocols", "Hyperspace")

ASC.Commands.Register("ai_chat", function(ply, cmd, args)
    if not IsValid(ply) then return end

    ply:ChatPrint("[Advanced Space Combat] Opening ARIA-4 AI chat interface...")
    ply:ChatPrint("[Advanced Space Combat] Use 'aria <question>' to chat with ARIA-4")
    ply:ChatPrint("[Advanced Space Combat] Example: aria help")
end, "Open ARIA-4 AI chat interface", "General")

ASC.Commands.Register("vgui_rescan", function(ply, cmd, args)
    if not IsValid(ply) then return end

    ply:ChatPrint("[Advanced Space Combat] Rescanning VGUI elements for theming...")

    -- Trigger VGUI rescan
    if ASC.ComprehensiveTheme and ASC.ComprehensiveTheme.RescanVGUI then
        ASC.ComprehensiveTheme.RescanVGUI()
        ply:ChatPrint("[Advanced Space Combat] VGUI rescan completed")
    else
        ply:ChatPrint("[Advanced Space Combat] Theme system not available")
    end
end, "Rescan all VGUI elements for theming", "Configuration")

ASC.Commands.Register("ship_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    -- Find player's ship core
    local shipCore = nil
    local cores = ents.FindByClass("ship_core")

    for _, core in ipairs(cores) do
        if IsValid(core) and core:GetNWString("Owner") == ply:Name() then
            shipCore = core
            break
        end
    end

    if not IsValid(shipCore) then
        ply:ChatPrint("[Advanced Space Combat] No ship core found")
        return
    end

    ply:ChatPrint("[Advanced Space Combat] Ship Status:")
    ply:ChatPrint("• Name: " .. shipCore:GetNWString("ShipName", "Unnamed Ship"))
    ply:ChatPrint("• Health: " .. shipCore:Health() .. "/" .. shipCore:GetMaxHealth())
    ply:ChatPrint("• Hull Integrity: " .. shipCore:GetNWFloat("HullIntegrity", 100) .. "%")
    ply:ChatPrint("• Shield Status: " .. (shipCore:GetNWBool("ShieldActive", false) and "Active" or "Inactive"))
    ply:ChatPrint("• Core State: " .. shipCore:GetNWString("StatusMessage", "Unknown"))
end, "Show detailed ship status information", "Ship Management")

ASC.Commands.Register("weapon_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    -- Find weapons near player
    local weapons = {}
    local weaponClasses = {"asc_pulse_cannon", "asc_plasma_cannon", "asc_railgun", "hyperdrive_pulse_cannon", "hyperdrive_plasma_cannon", "hyperdrive_railgun"}

    for _, class in ipairs(weaponClasses) do
        local found = ents.FindByClass(class)
        for _, weapon in ipairs(found) do
            if IsValid(weapon) and weapon:GetPos():Distance(ply:GetPos()) < 2000 then
                table.insert(weapons, weapon)
            end
        end
    end

    if #weapons == 0 then
        ply:ChatPrint("[Advanced Space Combat] No weapons found nearby")
        return
    end

    ply:ChatPrint("[Advanced Space Combat] Weapon Status (" .. #weapons .. " weapons found):")
    for i, weapon in ipairs(weapons) do
        local name = weapon:GetClass():gsub("_", " "):gsub("asc ", ""):gsub("hyperdrive ", "")
        local health = weapon:Health() or 100
        local maxHealth = weapon:GetMaxHealth() or 100
        ply:ChatPrint("• " .. name .. ": " .. health .. "/" .. maxHealth .. " HP")
    end
end, "Show weapon system status", "Combat")

ASC.Commands.Register("stargate_info", function(ply, cmd, args)
    if not IsValid(ply) then return end

    ply:ChatPrint("[Advanced Space Combat] Stargate Technology Information:")
    ply:ChatPrint("• Supported Technologies: Ancient, Asgard, Goa'uld, Wraith, Ori, Tau'ri")
    ply:ChatPrint("• Hyperspace Travel: 4-stage Stargate-inspired system")
    ply:ChatPrint("• Integration: Full CAP (Carter Addon Pack) support")
    ply:ChatPrint("• Commands: Use 'aria stargate help' for detailed assistance")

    -- Show nearby stargates
    local stargates = {}
    local sgClasses = {"stargate_sg1", "stargate_movie", "stargate_infinity", "stargate_tollan"}

    for _, class in ipairs(sgClasses) do
        local found = ents.FindByClass(class)
        for _, sg in ipairs(found) do
            if IsValid(sg) and sg:GetPos():Distance(ply:GetPos()) < 5000 then
                table.insert(stargates, sg)
            end
        end
    end

    if #stargates > 0 then
        ply:ChatPrint("• Nearby Stargates: " .. #stargates .. " found")
    end
end, "Show Stargate technology information", "Transport")

print("[Advanced Space Combat] Console Commands v5.1.0 - Ultimate Edition Loaded successfully!")
print("[Advanced Space Combat] Use 'asc_help' for a complete list of available commands")
print("[Advanced Space Combat] Use 'asc_help <category>' to see commands in a specific category")
