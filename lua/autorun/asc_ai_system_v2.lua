-- Advanced Space Combat - Enhanced AI System v2.2.1
-- Next-generation AI assistant with advanced capabilities and Stargate knowledge

print("[Advanced Space Combat] Enhanced AI System v2.2.1 - Loading...")

-- Initialize AI namespace
ASC = ASC or {}
ASC.AI = ASC.AI or {}

-- AI Configuration
ASC.AI.Config = {
    Name = "ARIA-2",
    Version = "2.2.1",
    Personality = "Professional space combat AI with extensive Stargate knowledge",
    EnableAdvancedFeatures = true,
    EnableContextAwareness = true,
    EnableLearning = true,
    EnableProactiveAssistance = true,
    ResponseDelay = 0.5, -- Seconds
    MaxResponseLength = 500,
    CommandPrefix = "!ai",
    AdminCommandPrefix = "!admin-ai"
}

-- AI Knowledge Base
ASC.AI.Knowledge = {
    -- Core Systems
    CoreSystems = {
        {
            topic = "ship_core",
            keywords = {"ship core", "core", "ship", "hub", "central"},
            response = "Ship cores are the central management hubs of all ships. They auto-detect nearby components within 2000 units, manage energy distribution, monitor hull integrity, and coordinate all ship systems. Use E to access the interface."
        },
        {
            topic = "auto_linking",
            keywords = {"auto link", "linking", "connect", "attach", "detection"},
            response = "Auto-linking connects components to nearby ship cores automatically. Place components within 2000 units of a ship core and they'll link automatically. No manual configuration needed!"
        },
        {
            topic = "energy_management",
            keywords = {"energy", "power", "zpm", "reactor", "battery"},
            response = "Energy is managed by ship cores and power sources like ZPMs. Ship cores regenerate 5 energy/sec. ZPMs provide unlimited energy. Monitor energy levels in the ship interface."
        }
    },
    
    -- Stargate Technology
    StargateTech = {
        {
            topic = "ancient_tech",
            keywords = {"ancient", "lantean", "atlantis", "zpm", "drone"},
            response = "Ancient technology is Tier 10 - the most advanced. Features: ZPMs (unlimited energy), drone weapons (adaptive targeting), city shields (planetary scale), control chairs (neural interface), and instant hyperdrives."
        },
        {
            topic = "asgard_tech",
            keywords = {"asgard", "ion cannon", "beaming", "hologram"},
            response = "Asgard technology is Tier 8 - highly advanced. Features: ion cannons (particle beams), computer cores (quantum processing), beaming technology (matter transport), and efficient hyperdrives."
        },
        {
            topic = "goauld_tech",
            keywords = {"goa'uld", "goauld", "staff", "sarcophagus", "naquadah"},
            response = "Goa'uld technology is Tier 5 - intermediate. Features: staff cannons (plasma weapons), sarcophagus (resurrection), hand devices (energy weapons), ring transporters, and naquadah reactors."
        },
        {
            topic = "wraith_tech",
            keywords = {"wraith", "dart", "culling", "hive", "organic"},
            response = "Wraith technology is Tier 6 - bio-organic. Features: dart weapons (organic energy), culling beams (matter transport), hive shields (adaptive), regeneration chambers, and hive mind interfaces."
        },
        {
            topic = "ori_tech",
            keywords = {"ori", "prior", "supergate", "ascended"},
            response = "Ori technology is Tier 9 - ascended being tech. Features: pulse weapons (advanced energy), supergates (intergalactic transport), prior staffs (energy manipulation), and satellite weapons."
        },
        {
            topic = "tauri_tech",
            keywords = {"tau'ri", "tauri", "earth", "human", "f302"},
            response = "Tau'ri technology is Tier 3 - human engineering. Features: F-302 fighters, railguns (kinetic), nuclear missiles, iris protection, and reverse-engineered alien tech."
        }
    },
    
    -- Combat Systems
    CombatSystems = {
        {
            topic = "weapons",
            keywords = {"weapon", "gun", "cannon", "fire", "shoot"},
            response = "5 weapon types available: Pulse Cannon (fast energy), Beam Weapon (continuous), Torpedo Launcher (guided), Railgun (kinetic), Plasma Cannon (area effect). All auto-link to ship cores."
        },
        {
            topic = "tactical_ai",
            keywords = {"tactical", "ai", "combat ai", "behavior", "strategy"},
            response = "Tactical AI has 3 modes: Aggressive (max firepower), Defensive (protection focus), Balanced (adaptive). AI handles targeting, weapon coordination, and fleet tactics automatically."
        },
        {
            topic = "shields",
            keywords = {"shield", "protection", "barrier", "defense"},
            response = "Shield systems provide energy barriers. CAP-integrated shields available. Shields auto-recharge, have frequency modulation, and provide multi-layer protection. Monitor shield strength in ship interface."
        }
    ],
    
    -- Commands and Usage
    Commands = {
        {
            topic = "commands",
            keywords = {"command", "help", "how to", "usage"},
            response = "Key commands: asc_help (help system), asc_status (system info), asc_stargate_spawn <culture> <type> (spawn tech), asc_config (settings). Use !ai <question> to ask me anything!"
        },
        {
            topic = "spawning",
            keywords = {"spawn", "create", "place", "tool"},
            response = "Use the Advanced Space Combat tool in Q menu. Spawn ship cores first, then add components within 2000 units. Use asc_stargate_spawn for Stargate tech. Everything auto-links!"
        }
    ]
}

-- AI Response System
function ASC.AI.ProcessQuery(player, query)
    if not IsValid(player) then return end
    
    local response = ASC.AI.GenerateResponse(query)
    
    -- Add response delay for realism
    timer.Simple(ASC.AI.Config.ResponseDelay, function()
        if IsValid(player) then
            ASC.AI.SendResponse(player, response)
        end
    end)
end

function ASC.AI.GenerateResponse(query)
    local queryLower = string.lower(query)
    local bestMatch = nil
    local bestScore = 0
    
    -- Search all knowledge categories
    local allKnowledge = {}
    table.Add(allKnowledge, ASC.AI.Knowledge.CoreSystems)
    table.Add(allKnowledge, ASC.AI.Knowledge.StargateTech)
    table.Add(allKnowledge, ASC.AI.Knowledge.CombatSystems)
    table.Add(allKnowledge, ASC.AI.Knowledge.Commands)
    
    -- Find best matching knowledge
    for _, knowledge in ipairs(allKnowledge) do
        local score = ASC.AI.CalculateRelevance(queryLower, knowledge.keywords)
        if score > bestScore then
            bestScore = score
            bestMatch = knowledge
        end
    end
    
    -- Generate response
    if bestMatch and bestScore > 0 then
        return ASC.AI.FormatResponse(bestMatch.response, queryLower)
    else
        return ASC.AI.GetFallbackResponse(queryLower)
    end
end

function ASC.AI.CalculateRelevance(query, keywords)
    local score = 0
    
    for _, keyword in ipairs(keywords) do
        if string.find(query, keyword) then
            score = score + 1
            -- Bonus for exact matches
            if query == keyword then
                score = score + 2
            end
        end
    end
    
    return score
end

function ASC.AI.FormatResponse(response, query)
    local formattedResponse = "[ARIA-2] " .. response
    
    -- Add contextual suggestions
    if string.find(query, "how") then
        formattedResponse = formattedResponse .. " Need more help? Ask me about specific topics!"
    elseif string.find(query, "spawn") then
        formattedResponse = formattedResponse .. " Tip: Use asc_help for detailed spawning guides."
    elseif string.find(query, "stargate") then
        formattedResponse = formattedResponse .. " Try: asc_stargate_info for complete tech details."
    end
    
    return formattedResponse
end

function ASC.AI.GetFallbackResponse(query)
    local fallbacks = {
        "[ARIA-2] I understand you're asking about '" .. query .. "'. Try asking about: ship cores, weapons, Stargate tech, or commands.",
        "[ARIA-2] I'm not sure about that specific topic. I can help with: ship building, combat systems, Stargate technology, or general commands.",
        "[ARIA-2] Let me help! I specialize in: Advanced Space Combat systems, Stargate technology (Ancient/Asgard/Goa'uld/Wraith/Ori/Tau'ri), and combat operations.",
        "[ARIA-2] I can assist with ship cores, weapons, flight systems, Stargate tech, or commands. What would you like to know more about?"
    }
    
    return fallbacks[math.random(1, #fallbacks)]
end

function ASC.AI.SendResponse(player, response)
    -- Limit response length
    if string.len(response) > ASC.AI.Config.MaxResponseLength then
        response = string.sub(response, 1, ASC.AI.Config.MaxResponseLength - 3) .. "..."
    end
    
    player:ChatPrint(response)
    
    -- Log interaction
    print("[Advanced Space Combat] AI Response to " .. player:Name() .. ": " .. response)
end

-- Proactive assistance system
function ASC.AI.CheckForProactiveHelp(player, entity)
    if not ASC.AI.Config.EnableProactiveAssistance then return end
    if not IsValid(player) or not IsValid(entity) then return end
    
    local class = entity:GetClass()
    local suggestions = {}
    
    -- Entity-specific suggestions
    if class == "ship_core" then
        table.insert(suggestions, "Ship core spawned! Add weapons and systems within 2000 units for auto-linking.")
    elseif string.find(class, "asc_ancient") then
        table.insert(suggestions, "Ancient technology detected! This is Tier 10 - the most advanced available.")
    elseif string.find(class, "weapon") then
        table.insert(suggestions, "Weapon spawned! It will auto-link to nearby ship cores for tactical AI control.")
    elseif string.find(class, "zpm") then
        table.insert(suggestions, "ZPM active! This provides unlimited energy to nearby ship cores.")
    end
    
    -- Send suggestion
    if #suggestions > 0 then
        timer.Simple(2, function()
            if IsValid(player) then
                player:ChatPrint("[ARIA-2] " .. suggestions[1] .. " Ask me anything with !ai <question>")
            end
        end)
    end
end

-- Chat command processing
hook.Add("PlayerSay", "ASC_AI_ChatProcessor", function(player, text, team)
    if not IsValid(player) then return end
    
    local command = string.lower(text)
    
    -- Check for AI command
    if string.sub(command, 1, 3) == "!ai" then
        local query = string.Trim(string.sub(text, 4))
        
        if query == "" or query == "help" then
            ASC.AI.ShowHelp(player)
        else
            ASC.AI.ProcessQuery(player, query)
        end
        
        return "" -- Suppress original message
    end
end)

-- AI help system
function ASC.AI.ShowHelp(player)
    if not IsValid(player) then return end
    
    player:ChatPrint("[ARIA-2] Advanced Space Combat AI Assistant v2.2.1")
    player:ChatPrint("Usage: !ai <question> - Ask me anything about the addon")
    player:ChatPrint("Topics I can help with:")
    player:ChatPrint("• Ship building and cores")
    player:ChatPrint("• Stargate technology (Ancient, Asgard, Goa'uld, Wraith, Ori, Tau'ri)")
    player:ChatPrint("• Combat systems and weapons")
    player:ChatPrint("• Commands and configuration")
    player:ChatPrint("Examples: !ai ship core, !ai ancient tech, !ai weapons")
end

-- Entity spawn hook for proactive assistance
hook.Add("PlayerSpawnedSENT", "ASC_AI_ProactiveHelp", function(player, entity)
    ASC.AI.CheckForProactiveHelp(player, entity)
end)

-- Status command
concommand.Add("asc_ai_status", function(player, cmd, args)
    if not IsValid(player) then return end
    
    player:ChatPrint("[ARIA-2] AI System Status:")
    player:ChatPrint("Version: " .. ASC.AI.Config.Version)
    player:ChatPrint("Personality: " .. ASC.AI.Config.Personality)
    player:ChatPrint("Advanced Features: " .. (ASC.AI.Config.EnableAdvancedFeatures and "Enabled" or "Disabled"))
    player:ChatPrint("Context Awareness: " .. (ASC.AI.Config.EnableContextAwareness and "Enabled" or "Disabled"))
    player:ChatPrint("Proactive Assistance: " .. (ASC.AI.Config.EnableProactiveAssistance and "Enabled" or "Disabled"))
    player:ChatPrint("Knowledge Base: " .. (#ASC.AI.Knowledge.CoreSystems + #ASC.AI.Knowledge.StargateTech + #ASC.AI.Knowledge.CombatSystems + #ASC.AI.Knowledge.Commands) .. " topics")
end)

-- Initialize AI system
hook.Add("Initialize", "ASC_AI_Initialize", function()
    print("[Advanced Space Combat] ARIA-2 AI Assistant initialized")
    print("[Advanced Space Combat] Knowledge base: " .. (#ASC.AI.Knowledge.CoreSystems + #ASC.AI.Knowledge.StargateTech + #ASC.AI.Knowledge.CombatSystems + #ASC.AI.Knowledge.Commands) .. " topics loaded")
    print("[Advanced Space Combat] Use !ai <question> to interact with ARIA-2")
end)

print("[Advanced Space Combat] Enhanced AI System loaded successfully!")
