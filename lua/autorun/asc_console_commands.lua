-- Advanced Space Combat - Console Commands v2.2.1
-- Comprehensive console command system with help and administration

print("[Advanced Space Combat] Console Commands v2.2.1 - Loading...")

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
    
    if category then
        -- Show commands in specific category
        ply:ChatPrint("[Advanced Space Combat] Commands in category: " .. category)
        for name, cmdData in pairs(ASC.Commands.Registry) do
            if cmdData.category == category then
                ply:ChatPrint("• " .. cmdData.fullName .. " - " .. cmdData.description)
            end
        end
    else
        -- Show all categories
        ply:ChatPrint("[Advanced Space Combat] Available command categories:")
        for _, cat in ipairs(ASC.Commands.Categories) do
            ply:ChatPrint("• " .. cat .. " (use 'asc_help " .. cat .. "' for commands)")
        end
        ply:ChatPrint("Use 'asc_help <category>' to see commands in that category")
    end
end, "Show help for commands", "General")

ASC.Commands.Register("version", function(ply, cmd, args)
    local msg = "[Advanced Space Combat] Version: " .. ASC.VERSION .. " Build: " .. ASC.BUILD
    if IsValid(ply) then
        ply:ChatPrint(msg)
    else
        print(msg)
    end
end, "Show addon version information", "General")

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
    local shipCore = ents.Create("ship_core")
    if IsValid(shipCore) then
        shipCore:SetPos(pos)
        shipCore:SetAngles(ang)
        shipCore:Spawn()
        shipCore:SetNWString("ShipName", shipName)
        
        ply:ChatPrint("[Advanced Space Combat] Ship core '" .. shipName .. "' spawned successfully!")
        
        -- Add to undo
        undo.Create("Ship Core")
        undo.AddEntity(shipCore)
        undo.SetPlayer(ply)
        undo.Finish()
    else
        ply:ChatPrint("[Advanced Space Combat] Failed to spawn ship core")
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
        ply:ChatPrint("• chat_ai_enabled - Enable/disable ARIA chat AI")
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

print("[Advanced Space Combat] Console Commands loaded successfully!")
