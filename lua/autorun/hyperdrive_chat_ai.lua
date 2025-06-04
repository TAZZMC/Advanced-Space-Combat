-- Enhanced Hyperdrive System - Chat AI Assistant v5.1.0
-- In-game AI assistant for help and information
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Hyperdrive Chat AI] Chat AI Assistant v5.1.0 - Ultimate Edition Initializing...")

-- Initialize chat AI namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.ChatAI = HYPERDRIVE.ChatAI or {}

-- Chat AI configuration
HYPERDRIVE.ChatAI.Config = {
    -- AI Settings
    EnableChatAI = true,
    AIName = "ARIA", -- Advanced Robotic Intelligence Assistant
    AIPrefix = "[ARIA]",
    AIColor = Color(100, 200, 255),
    
    -- Trigger Settings (Updated for ARIA-4)
    TriggerWords = {"aria", "!ai", "!aria"}, -- Primary: aria, Legacy: !ai, !aria
    RequirePrefix = true,
    CaseSensitive = false,
    
    -- Response Settings
    MaxResponseLength = 200,
    ResponseDelay = 1, -- Seconds
    CooldownTime = 3, -- Seconds between requests per player
    
    -- Features
    EnableHelp = true,
    EnableStatus = true,
    EnableTutorial = true,
    EnableDiagnostics = true,
    EnableCommands = true,
    
    -- Permissions
    AdminOnly = false,
    RequireAlive = false,
    MaxDistance = 0, -- 0 = unlimited
    
    -- Learning
    EnableLearning = true,
    SaveResponses = true,
    AdaptToServer = true
}

-- AI Knowledge Base
HYPERDRIVE.ChatAI.Knowledge = {
    -- Basic Help
    help = {
        "I'm ARIA, your Enhanced Hyperdrive System assistant! Use !ai <question> to ask me anything.",
        "Available commands: !ai help, !ai status, !ai tutorial, !ai entities, !ai commands",
        "I can help with ship cores, weapons, flight systems, docking, shuttles, and more!",
        "For detailed help, try: !ai ship core, !ai weapons, !ai flight, !ai docking"
    },
    
    -- System Status
    status = {
        "Enhanced Hyperdrive System v2.2.1 is running with all systems operational.",
        "Active systems: Ship Cores, Weapons, Flight, Navigation, Docking, Shuttles, Undo",
        "Integration status: SB3 Resources, CAP, Wiremod, Real-time Monitoring",
        "Use !ai diagnostics for detailed system information."
    },
    
    -- Entity Information
    entities = {
        "Ship Core: Central hub for ship management and system coordination",
        "Weapons: 5 types - Pulse Cannon, Beam Weapon, Torpedo, Railgun, Plasma Cannon",
        "Flight Console: Ship movement control with autopilot and navigation",
        "Docking Pad: 5 types for automated landing and ship services",
        "Shuttle: 4 types for automated transport and cargo missions"
    },
    
    -- Commands
    commands = {
        "hyperdrive_help - Show system help and commands",
        "hyperdrive_status - Display system status and entity counts",
        "hyperdrive_undo - Undo last spawned entity",
        "hyperdrive_undo_list - Show undo history",
        "Use the Hyperdrive tool from the spawn menu to create entities"
    },
    
    -- Tutorials
    tutorial = {
        "1. Spawn a Ship Core first - it's the central hub for your ship",
        "2. Add Hyperdrive Engines within 2000 units - they'll auto-link",
        "3. Add weapons, flight console, or other systems as needed",
        "4. Use E key on entities for control interfaces",
        "5. Press Z to undo if you make mistakes"
    }
}

-- Player cooldowns
HYPERDRIVE.ChatAI.PlayerCooldowns = {}

-- Response history for learning
HYPERDRIVE.ChatAI.ResponseHistory = {}

-- AI Response Functions
function HYPERDRIVE.ChatAI.ProcessMessage(player, message)
    if not HYPERDRIVE.ChatAI.Config.EnableChatAI then return false end
    if not IsValid(player) then return false end
    
    -- Check cooldown
    local steamID = player:SteamID()
    local currentTime = CurTime()
    
    if HYPERDRIVE.ChatAI.PlayerCooldowns[steamID] and 
       currentTime - HYPERDRIVE.ChatAI.PlayerCooldowns[steamID] < HYPERDRIVE.ChatAI.Config.CooldownTime then
        return false
    end
    
    -- Check if message triggers AI
    local triggerFound = false
    local cleanMessage = message
    
    for _, trigger in ipairs(HYPERDRIVE.ChatAI.Config.TriggerWords) do
        local searchTrigger = HYPERDRIVE.ChatAI.Config.CaseSensitive and trigger or string.lower(trigger)
        local searchMessage = HYPERDRIVE.ChatAI.Config.CaseSensitive and message or string.lower(message)
        
        if string.find(searchMessage, searchTrigger, 1, true) then
            triggerFound = true
            -- Remove trigger from message
            cleanMessage = string.gsub(searchMessage, searchTrigger, "")
            cleanMessage = string.Trim(cleanMessage)
            break
        end
    end
    
    if not triggerFound then return false end
    
    -- Set cooldown
    HYPERDRIVE.ChatAI.PlayerCooldowns[steamID] = currentTime
    
    -- Process the request
    timer.Simple(HYPERDRIVE.ChatAI.Config.ResponseDelay, function()
        if IsValid(player) then
            HYPERDRIVE.ChatAI.GenerateResponse(player, cleanMessage)
        end
    end)
    
    return true
end

function HYPERDRIVE.ChatAI.GenerateResponse(player, query)
    local response = HYPERDRIVE.ChatAI.FindBestResponse(query)
    
    if response then
        HYPERDRIVE.ChatAI.SendResponse(player, response)
        
        -- Save to history for learning
        if HYPERDRIVE.ChatAI.Config.EnableLearning then
            table.insert(HYPERDRIVE.ChatAI.ResponseHistory, {
                query = query,
                response = response,
                player = player:SteamID(),
                timestamp = CurTime()
            })
        end
    else
        HYPERDRIVE.ChatAI.SendResponse(player, "I'm not sure about that. Try !ai help for available commands.")
    end
end

function HYPERDRIVE.ChatAI.FindBestResponse(query)
    if not query or query == "" then
        return HYPERDRIVE.ChatAI.Knowledge.help[1]
    end
    
    local lowerQuery = string.lower(query)
    
    -- Direct keyword matching
    for category, responses in pairs(HYPERDRIVE.ChatAI.Knowledge) do
        if string.find(lowerQuery, category) then
            return responses[math.random(#responses)]
        end
    end
    
    -- Specific entity help
    if string.find(lowerQuery, "ship") and string.find(lowerQuery, "core") then
        return "Ship Core is the central hub. Spawn it first, then add other systems within 2000 units. Use E key to access its interface."
    end
    
    if string.find(lowerQuery, "weapon") then
        return "Weapons auto-link to nearby ship cores. 5 types available: Pulse Cannon (fast), Beam (continuous), Torpedo (guided), Railgun (penetrating), Plasma (area effect)."
    end
    
    if string.find(lowerQuery, "flight") then
        return "Flight Console provides ship movement control. Features autopilot, waypoint navigation, and formation flying. Links to ship core automatically."
    end
    
    if string.find(lowerQuery, "dock") then
        return "Docking Pads provide automated landing. 5 types: Small, Medium, Large, Shuttle, Cargo. Ships auto-request landing when nearby."
    end
    
    if string.find(lowerQuery, "shuttle") then
        return "Shuttles are automated transport craft. 4 types: Transport, Cargo, Emergency, Scout. They handle missions automatically."
    end
    
    if string.find(lowerQuery, "undo") then
        return "Press Z to undo last spawned entity. Use 'hyperdrive_undo_list' to see undo history. All systems clean up automatically."
    end
    
    if string.find(lowerQuery, "spawn") or string.find(lowerQuery, "tool") then
        return "Use the Hyperdrive tool from spawn menu. Left-click to spawn, right-click to configure, reload to remove. All entities auto-link to nearby ship cores."
    end
    
    if string.find(lowerQuery, "wire") then
        return "All entities support Wiremod. Ship cores output system status, weapons have firing controls, flight systems have movement inputs."
    end
    
    if string.find(lowerQuery, "energy") or string.find(lowerQuery, "sb3") then
        return "SB3 integration provides energy and resource management. Ship cores auto-distribute resources to welded entities."
    end
    
    if string.find(lowerQuery, "cap") then
        return "CAP integration provides Stargate-themed shields and effects. Shield generators auto-link to ship cores for protection."
    end
    
    -- System diagnostics
    if string.find(lowerQuery, "diagnostic") or string.find(lowerQuery, "problem") then
        return HYPERDRIVE.ChatAI.GetSystemDiagnostics()
    end
    
    -- Current status
    if string.find(lowerQuery, "count") or string.find(lowerQuery, "how many") then
        return HYPERDRIVE.ChatAI.GetEntityCounts()
    end
    
    return nil
end

function HYPERDRIVE.ChatAI.GetSystemDiagnostics()
    local diagnostics = {}
    
    -- Check core systems
    if HYPERDRIVE.ShipCore then
        table.insert(diagnostics, "Ship Core System: Online")
    else
        table.insert(diagnostics, "Ship Core System: Offline")
    end
    
    if HYPERDRIVE.Weapons then
        table.insert(diagnostics, "Weapon Systems: Online")
    else
        table.insert(diagnostics, "Weapon Systems: Offline")
    end
    
    if HYPERDRIVE.Flight then
        table.insert(diagnostics, "Flight Systems: Online")
    else
        table.insert(diagnostics, "Flight Systems: Offline")
    end
    
    if HYPERDRIVE.DockingPad then
        table.insert(diagnostics, "Docking Systems: Online")
    else
        table.insert(diagnostics, "Docking Systems: Offline")
    end
    
    return "System Diagnostics: " .. table.concat(diagnostics, ", ")
end

function HYPERDRIVE.ChatAI.GetEntityCounts()
    local counts = {}
    
    local shipCores = #ents.FindByClass("ship_core")
    local engines = #ents.FindByClass("hyperdrive_master_engine")
    local weapons = #ents.FindByClass("hyperdrive_pulse_cannon") + #ents.FindByClass("hyperdrive_beam_weapon") + 
                   #ents.FindByClass("hyperdrive_torpedo_launcher") + #ents.FindByClass("hyperdrive_railgun") + 
                   #ents.FindByClass("hyperdrive_plasma_cannon")
    local flightConsoles = #ents.FindByClass("hyperdrive_flight_console")
    local dockingPads = #ents.FindByClass("hyperdrive_docking_pad")
    local shuttles = #ents.FindByClass("hyperdrive_shuttle")
    
    return string.format("Current entities: %d Ship Cores, %d Engines, %d Weapons, %d Flight Consoles, %d Docking Pads, %d Shuttles", 
                        shipCores, engines, weapons, flightConsoles, dockingPads, shuttles)
end

function HYPERDRIVE.ChatAI.SendResponse(player, response)
    if not IsValid(player) or not response then return end
    
    -- Limit response length
    if string.len(response) > HYPERDRIVE.ChatAI.Config.MaxResponseLength then
        response = string.sub(response, 1, HYPERDRIVE.ChatAI.Config.MaxResponseLength - 3) .. "..."
    end
    
    -- Send to player
    player:ChatPrint(HYPERDRIVE.ChatAI.Config.AIPrefix .. " " .. response)
    
    -- Optional: Send to all players (for public AI)
    -- PrintMessage(HUD_PRINTTALK, HYPERDRIVE.ChatAI.Config.AIPrefix .. " " .. response)
end

-- Hook into chat
if SERVER then
    hook.Add("PlayerSay", "HyperdriveChatAI", function(player, text, teamChat)
        if HYPERDRIVE.ChatAI.ProcessMessage(player, text) then
            -- Return empty string to suppress the original message if it was an AI command
            -- Comment this out if you want AI commands to still appear in chat
            -- return ""
        end
    end)
end

-- Console commands for AI management
if SERVER then
    concommand.Add("hyperdrive_ai_toggle", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        
        HYPERDRIVE.ChatAI.Config.EnableChatAI = not HYPERDRIVE.ChatAI.Config.EnableChatAI
        local status = HYPERDRIVE.ChatAI.Config.EnableChatAI and "enabled" or "disabled"
        ply:ChatPrint("[Hyperdrive AI] Chat AI " .. status)
    end)
    
    concommand.Add("hyperdrive_ai_status", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local status = HYPERDRIVE.ChatAI.Config.EnableChatAI and "Online" or "Offline"
        local responses = #HYPERDRIVE.ChatAI.ResponseHistory
        
        ply:ChatPrint("[Hyperdrive AI] Status: " .. status)
        ply:ChatPrint("[Hyperdrive AI] Total responses: " .. responses)
        ply:ChatPrint("[Hyperdrive AI] Trigger words: " .. table.concat(HYPERDRIVE.ChatAI.Config.TriggerWords, ", "))
    end)
    
    concommand.Add("hyperdrive_ai_help", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        ply:ChatPrint("[ARIA-4] === ARIA-4 CHAT AI HELP ===")
        ply:ChatPrint("Primary command: aria <question>")
        ply:ChatPrint("Legacy commands: " .. table.concat(HYPERDRIVE.ChatAI.Config.TriggerWords, ", "))
        ply:ChatPrint("Examples: aria help, aria status, aria ship status")
        ply:ChatPrint("Available topics: help, status, tutorial, entities, commands")
        ply:ChatPrint("Specific help: ship core, weapons, flight, docking, shuttles")
        ply:ChatPrint("System info: diagnostics, count, undo, spawn, wire, energy")
    end)
end

-- Advanced AI Features
HYPERDRIVE.ChatAI.AdvancedFeatures = {
    -- Context awareness
    playerContexts = {},

    -- Learning system
    learnedResponses = {},

    -- Personality traits
    personality = {
        helpful = true,
        friendly = true,
        technical = true,
        patient = true
    }
}

-- Context-aware responses
function HYPERDRIVE.ChatAI.UpdatePlayerContext(player, query, response)
    local steamID = player:SteamID()

    if not HYPERDRIVE.ChatAI.AdvancedFeatures.playerContexts[steamID] then
        HYPERDRIVE.ChatAI.AdvancedFeatures.playerContexts[steamID] = {
            lastQueries = {},
            interests = {},
            helpLevel = "beginner" -- beginner, intermediate, advanced
        }
    end

    local context = HYPERDRIVE.ChatAI.AdvancedFeatures.playerContexts[steamID]

    -- Track recent queries
    table.insert(context.lastQueries, {query = query, time = CurTime()})
    if #context.lastQueries > 5 then
        table.remove(context.lastQueries, 1)
    end

    -- Determine interests
    if string.find(string.lower(query), "weapon") then
        context.interests.weapons = (context.interests.weapons or 0) + 1
    elseif string.find(string.lower(query), "flight") then
        context.interests.flight = (context.interests.flight or 0) + 1
    elseif string.find(string.lower(query), "ship") then
        context.interests.ships = (context.interests.ships or 0) + 1
    end

    -- Adjust help level based on questions
    local totalQuestions = #context.lastQueries
    if totalQuestions > 3 then
        context.helpLevel = "intermediate"
    end
    if totalQuestions > 8 then
        context.helpLevel = "advanced"
    end
end

-- Personality-based response modification
function HYPERDRIVE.ChatAI.AddPersonality(response, player)
    local steamID = player:SteamID()
    local context = HYPERDRIVE.ChatAI.AdvancedFeatures.playerContexts[steamID]

    -- Add personality touches
    local personalityPrefixes = {
        "I'd be happy to help! ",
        "Great question! ",
        "Let me assist you with that. ",
        "Here's what I can tell you: ",
        "I'm here to help! "
    }

    local personalitySuffixes = {
        " Let me know if you need more details!",
        " Feel free to ask if you have more questions!",
        " I'm always here to help!",
        " Hope this helps!",
        " Ask me anything else you'd like to know!"
    }

    -- Adjust based on help level
    if context and context.helpLevel == "advanced" then
        -- More technical, less hand-holding
        return response
    elseif context and context.helpLevel == "beginner" then
        -- More encouraging and detailed
        local prefix = personalityPrefixes[math.random(#personalityPrefixes)]
        local suffix = personalitySuffixes[math.random(#personalitySuffixes)]
        return prefix .. response .. suffix
    end

    return response
end

-- Smart help suggestions
function HYPERDRIVE.ChatAI.GetSmartSuggestions(player, query)
    local steamID = player:SteamID()
    local context = HYPERDRIVE.ChatAI.AdvancedFeatures.playerContexts[steamID]

    if not context then return {} end

    local suggestions = {}

    -- Based on interests
    if context.interests.weapons and context.interests.weapons > 2 then
        table.insert(suggestions, "Try asking about weapon upgrades or tactical AI!")
    end

    if context.interests.flight and context.interests.flight > 2 then
        table.insert(suggestions, "You might be interested in formation flying or autopilot features!")
    end

    if context.interests.ships and context.interests.ships > 2 then
        table.insert(suggestions, "Ask me about ship naming or hull damage systems!")
    end

    -- Based on recent queries
    local recentTopics = {}
    for _, queryData in ipairs(context.lastQueries) do
        if string.find(string.lower(queryData.query), "spawn") then
            recentTopics.spawn = true
        end
    end

    if recentTopics.spawn then
        table.insert(suggestions, "Since you're spawning entities, you might want to know about the undo system!")
    end

    return suggestions
end

-- Enhanced response generation with context
local originalGenerateResponse = HYPERDRIVE.ChatAI.GenerateResponse
HYPERDRIVE.ChatAI.GenerateResponse = function(player, query)
    local response = HYPERDRIVE.ChatAI.FindBestResponse(query)

    if response then
        -- Add personality
        response = HYPERDRIVE.ChatAI.AddPersonality(response, player)

        -- Update context
        HYPERDRIVE.ChatAI.UpdatePlayerContext(player, query, response)

        -- Send main response
        HYPERDRIVE.ChatAI.SendResponse(player, response)

        -- Send smart suggestions occasionally
        if math.random() < 0.3 then -- 30% chance
            local suggestions = HYPERDRIVE.ChatAI.GetSmartSuggestions(player, query)
            if #suggestions > 0 then
                timer.Simple(2, function()
                    if IsValid(player) then
                        local suggestion = suggestions[math.random(#suggestions)]
                        HYPERDRIVE.ChatAI.SendResponse(player, "💡 " .. suggestion)
                    end
                end)
            end
        end

        -- Save to history for learning
        if HYPERDRIVE.ChatAI.Config.EnableLearning then
            table.insert(HYPERDRIVE.ChatAI.ResponseHistory, {
                query = query,
                response = response,
                player = player:SteamID(),
                timestamp = CurTime()
            })
        end
    else
        local fallbackResponse = "I'm not sure about that. Try !ai help for available commands."
        fallbackResponse = HYPERDRIVE.ChatAI.AddPersonality(fallbackResponse, player)
        HYPERDRIVE.ChatAI.SendResponse(player, fallbackResponse)
    end
end

print("[Hyperdrive Chat AI] ARIA Chat AI Assistant v2.2.1 loaded successfully!")
print("[Hyperdrive Chat AI] Advanced features: Context awareness, personality, smart suggestions")
print("[Hyperdrive Chat AI] Use !ai, !aria, or !help to interact with the AI")
