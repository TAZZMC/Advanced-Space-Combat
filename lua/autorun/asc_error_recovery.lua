--[[
    Advanced Space Combat - Error Recovery System v3.0.0
    
    Handles missing files and system errors gracefully,
    providing fallback functionality and error recovery.
]]

-- Initialize Error Recovery System
ASC = ASC or {}
ASC.ErrorRecovery = ASC.ErrorRecovery or {}

-- Error Recovery Configuration
ASC.ErrorRecovery.Config = {
    Enabled = true,
    CreateFallbacks = true,
    LogErrors = true,
    AutoRecover = true,
    MaxRetries = 3
}

-- Error Recovery Core
ASC.ErrorRecovery.Core = {
    -- Missing systems
    MissingSystems = {},
    
    -- Error count
    ErrorCount = 0,
    
    -- Initialize error recovery
    Initialize = function()
        print("[Error Recovery] Initializing error recovery system v3.0.0")
        
        -- Set up error handlers
        ASC.ErrorRecovery.Core.SetupErrorHandlers()
        
        -- Create fallback systems
        ASC.ErrorRecovery.Core.CreateFallbackSystems()
        
        return true
    end,
    
    -- Setup error handlers
    SetupErrorHandlers = function()
        -- Override include function to handle missing files
        local originalInclude = include
        include = function(filePath)
            local success, err = pcall(originalInclude, filePath)
            if not success then
                ASC.ErrorRecovery.Core.HandleMissingFile(filePath, err)
            end
            return success
        end
        
        -- Override timer creation to handle errors
        local originalTimerCreate = timer.Create
        timer.Create = function(name, delay, reps, func)
            local wrappedFunc = function()
                local success, err = pcall(func)
                if not success then
                    ASC.ErrorRecovery.Core.HandleTimerError(name, err)
                end
            end
            return originalTimerCreate(name, delay, reps, wrappedFunc)
        end
    end,
    
    -- Handle missing file
    HandleMissingFile = function(filePath, error)
        print("[Error Recovery] Missing file: " .. filePath .. " - " .. tostring(error))
        
        table.insert(ASC.ErrorRecovery.Core.MissingSystems, filePath)
        ASC.ErrorRecovery.Core.ErrorCount = ASC.ErrorRecovery.Core.ErrorCount + 1
        
        -- Create fallback based on file type
        if string.find(filePath, "flight_system") then
            ASC.ErrorRecovery.Core.CreateFlightFallback()
        elseif string.find(filePath, "weapon_system") then
            ASC.ErrorRecovery.Core.CreateWeaponFallback()
        elseif string.find(filePath, "ai_system") then
            ASC.ErrorRecovery.Core.CreateAIFallback()
        elseif string.find(filePath, "tactical_ai") then
            ASC.ErrorRecovery.Core.CreateTacticalAIFallback()
        elseif string.find(filePath, "formation") then
            ASC.ErrorRecovery.Core.CreateFormationFallback()
        elseif string.find(filePath, "boss") then
            ASC.ErrorRecovery.Core.CreateBossFallback()
        elseif string.find(filePath, "docking") then
            ASC.ErrorRecovery.Core.CreateDockingFallback()
        elseif string.find(filePath, "shield") then
            ASC.ErrorRecovery.Core.CreateShieldFallback()
        end
    end,
    
    -- Handle timer error
    HandleTimerError = function(timerName, error)
        print("[Error Recovery] Timer error in " .. timerName .. ": " .. tostring(error))
        ASC.ErrorRecovery.Core.ErrorCount = ASC.ErrorRecovery.Core.ErrorCount + 1
        
        -- Remove problematic timer
        timer.Remove(timerName)
    end,
    
    -- Create fallback systems
    CreateFallbackSystems = function()
        -- Ensure basic namespaces exist
        ASC.Flight = ASC.Flight or { Core = {} }
        ASC.Weapons = ASC.Weapons or { Core = {} }
        ASC.AI = ASC.AI or {}
        ASC.TacticalAI = ASC.TacticalAI or { Core = {} }
        ASC.Formation = ASC.Formation or { Core = {} }
        ASC.Boss = ASC.Boss or { Core = {} }
        ASC.Docking = ASC.Docking or { Core = {} }
        ASC.Shields = ASC.Shields or { Core = {} }
        ASC.SystemStatus = ASC.SystemStatus or {}
    end,
    
    -- Create flight system fallback
    CreateFlightFallback = function()
        if ASC.Flight.Core.ActivateFlightSystem then return end
        
        ASC.Flight.Core.ActivateFlightSystem = function(shipID, shipCore)
            return false, "Flight system not available (fallback mode)"
        end
        
        ASC.Flight.Core.EnableAutopilot = function(shipID, target, mode)
            return false, "Autopilot not available (fallback mode)"
        end
        
        ASC.Flight.Core.ActiveFlights = {}
        
        print("[Error Recovery] Created flight system fallback")
    end,
    
    -- Create weapon system fallback
    CreateWeaponFallback = function()
        if ASC.Weapons.Core.CreateWeaponSystem then return end
        
        ASC.Weapons.Core.CreateWeaponSystem = function(shipCore)
            return nil, "Weapon system not available (fallback mode)"
        end
        
        ASC.Weapons.Core.WeaponSystems = {}
        
        print("[Error Recovery] Created weapon system fallback")
    end,
    
    -- Create AI system fallback
    CreateAIFallback = function()
        if ASC.AI.ProcessQuery then return end
        
        ASC.AI.ProcessQuery = function(player, query)
            return "AI system not available (fallback mode). Basic commands may still work."
        end
        
        ASC.AI.FindPlayerShipCore = function(player)
            return nil
        end
        
        print("[Error Recovery] Created AI system fallback")
    end,
    
    -- Create tactical AI fallback
    CreateTacticalAIFallback = function()
        if ASC.TacticalAI.Core.StartSession then return end
        
        ASC.TacticalAI.Core.StartSession = function(shipCore, player)
            return nil, "Tactical AI not available (fallback mode)"
        end
        
        ASC.TacticalAI.Core.ActiveSessions = {}
        
        print("[Error Recovery] Created tactical AI fallback")
    end,
    
    -- Create formation system fallback
    CreateFormationFallback = function()
        if ASC.Formation.Core.CreateFormation then return end
        
        ASC.Formation.Core.CreateFormation = function(leader, formationType, spacing)
            return nil, "Formation system not available (fallback mode)"
        end
        
        ASC.Formation.Core.ActiveFormations = {}
        
        print("[Error Recovery] Created formation system fallback")
    end,
    
    -- Create boss system fallback
    CreateBossFallback = function()
        if ASC.Boss.Core.StartBossVote then return end
        
        ASC.Boss.Core.StartBossVote = function(initiator)
            return false, "Boss system not available (fallback mode)"
        end
        
        ASC.Boss.Core.ActiveBosses = {}
        
        print("[Error Recovery] Created boss system fallback")
    end,
    
    -- Create docking system fallback
    CreateDockingFallback = function()
        if ASC.Docking.Core.CreateDockingPad then return end
        
        ASC.Docking.Core.CreateDockingPad = function(position, angles, padType, owner)
            return nil, "Docking system not available (fallback mode)"
        end
        
        ASC.Docking.Core.DockingPads = {}
        
        print("[Error Recovery] Created docking system fallback")
    end,
    
    -- Create shield system fallback
    CreateShieldFallback = function()
        if ASC.Shields.Core.ActivateShields then return end
        
        ASC.Shields.Core.ActivateShields = function(shipCore)
            return false, "Shield system not available (fallback mode)"
        end
        
        ASC.Shields.Core.ActiveShields = {}
        
        print("[Error Recovery] Created shield system fallback")
    end,
    
    -- Get recovery status
    GetRecoveryStatus = function()
        local status = "🔧 Error Recovery Status:\n"
        status = status .. "📊 Total Errors: " .. ASC.ErrorRecovery.Core.ErrorCount .. "\n"
        status = status .. "📁 Missing Systems: " .. #ASC.ErrorRecovery.Core.MissingSystems .. "\n"
        
        if #ASC.ErrorRecovery.Core.MissingSystems > 0 then
            status = status .. "\nMissing Files:\n"
            for _, file in ipairs(ASC.ErrorRecovery.Core.MissingSystems) do
                status = status .. "❌ " .. file .. "\n"
            end
        end
        
        status = status .. "\n✅ Fallback systems active\n"
        status = status .. "💡 Some features may be limited"
        
        return status
    end,
    
    -- Attempt system recovery
    AttemptRecovery = function()
        local recovered = 0
        
        -- Try to reload missing systems
        for _, filePath in ipairs(ASC.ErrorRecovery.Core.MissingSystems) do
            local success = pcall(include, filePath)
            if success then
                recovered = recovered + 1
                print("[Error Recovery] Successfully recovered: " .. filePath)
            end
        end
        
        return recovered
    end
}

-- Add recovery commands to AI system
if ASC.AI then
    ASC.AI.HandleRecoveryCommands = function(player, query, queryLower)
        if not IsValid(player) then return "Invalid player" end
        
        if string.find(queryLower, "recovery status") then
            return ASC.ErrorRecovery.Core.GetRecoveryStatus()
        elseif string.find(queryLower, "recovery attempt") then
            local recovered = ASC.ErrorRecovery.Core.AttemptRecovery()
            return "🔧 Recovery attempt complete: " .. recovered .. " systems recovered"
        else
            return "🔧 Recovery Commands:\n" ..
                   "• 'aria recovery status' - View recovery status\n" ..
                   "• 'aria recovery attempt' - Attempt to recover systems"
        end
    end
end

-- Initialize on server
if SERVER then
    -- Initialize error recovery
    timer.Simple(0.5, function()
        ASC.ErrorRecovery.Core.Initialize()
    end)
    
    print("[Advanced Space Combat] Error Recovery System v3.0.0 loaded")
end
