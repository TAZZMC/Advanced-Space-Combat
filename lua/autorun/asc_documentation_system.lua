-- Advanced Space Combat - Ultimate Documentation System v2.2.1
-- Next-generation in-game documentation with Stargate technology integration

print("[Advanced Space Combat] Ultimate Documentation System v2.2.1 - Loading...")

-- Initialize documentation namespace
ASC = ASC or {}
ASC.Documentation = ASC.Documentation or {}

-- Documentation configuration
ASC.Documentation.Config = {
    -- Documentation settings
    EnableInGameHelp = true,
    EnableTooltips = true,
    EnableContextHelp = true,
    EnableSearchHelp = true,
    
    -- Help categories
    Categories = {
        "Quick Start Guide",
        "Ship Building & Management",
        "Stargate Technology",
        "Combat & Weapons",
        "Flight & Navigation",
        "Transport & Docking",
        "AI & Automation",
        "Configuration & Commands",
        "Troubleshooting",
        "Advanced Features"
    }
}

-- Documentation database
ASC.Documentation.Database = {
    ["Quick Start Guide"] = {
        {
            title = "Ultimate Quick Start",
            content = [[
Welcome to Advanced Space Combat v2.2.1 - Ultimate Edition!

🚀 INSTANT SETUP (30 seconds):
1. Open Q Menu → Advanced Space Combat tab
2. Ship Building → Ship Core Manager → "Spawn Ship Core"
3. Add components within 2000 units (auto-links!)
4. Use E key on any entity for control interface
5. Ask ARIA-2: "!ai help" for instant assistance

⚡ FIRST SHIP BUILD:
1. Ship Core (central hub) - REQUIRED
2. Weapons (Pulse Cannon recommended)
3. Hyperdrive Engine (for travel)
4. Flight Console (for movement)
5. Shield Generator (for protection)

🌌 STARGATE TECHNOLOGY:
- Ancient (Tier 10): ZPMs, Drone Weapons, City Shields
- Asgard (Tier 8): Ion Cannons, Beaming Tech
- Goa'uld (Tier 5): Staff Cannons, Sarcophagus
- Wraith (Tier 6): Dart Weapons, Organic Tech
- Ori (Tier 9): Pulse Weapons, Supergates
- Tau'ri (Tier 3): F-302s, Railguns

🤖 AI ASSISTANT:
- "!ai ship core" - Ship building help
- "!ai ancient tech" - Stargate technology
- "!ai weapons" - Combat systems
- "!ai commands" - All available commands

Ready for epic space adventures! 🌟
            ]],
            tags = {"quickstart", "beginner", "setup", "stargate"}
        },
        {
            title = "Entity Overview",
            content = [[
CORE ENTITIES:
• Ship Core - Central management hub
• Hyperdrive Engine - Space propulsion
• Flight Console - Movement control

WEAPONS (5 Types):
• Pulse Cannon - Fast-firing energy
• Beam Weapon - Continuous beam
• Torpedo Launcher - Guided projectiles
• Railgun - Kinetic penetration
• Plasma Cannon - Area effect

TRANSPORT:
• Docking Pad - Landing facilities
• Shuttle - Automated transport

DEFENSE:
• Shield Generator - Protection systems
            ]],
            tags = {"entities", "overview", "reference"}
        }
    ],
    
    ["Ship Building"] = {
        {
            title = "Ship Core System",
            content = [[
The Ship Core is the central hub of every ship.

FEATURES:
• Auto-detects ship structure
• Manages all ship systems
• Provides real-time status
• Handles resource distribution
• Coordinates system integration

SETUP:
1. Spawn Ship Core first
2. Place other components within 2000 units
3. Systems auto-link to ship core
4. Use E key to access interface
5. Configure ship name and settings

SHIP DETECTION:
• Automatically finds welded entities
• Calculates ship mass and size
• Monitors hull integrity
• Tracks system status
• Manages energy distribution

CONFIGURATION:
• Ship naming system
• Health monitoring
• Energy management
• System coordination
• Performance tracking
            ]],
            tags = {"ship core", "setup", "configuration"}
        },
        {
            title = "Auto-Linking System",
            content = [[
Advanced Space Combat features automatic system linking.

HOW IT WORKS:
• Components auto-link to nearby ship cores
• Link range: 2000 units
• No manual configuration required
• Real-time status updates
• Cross-system communication

SUPPORTED SYSTEMS:
• All weapon types
• Flight consoles
• Shield generators
• Ammunition systems
• Tactical AI

BENEFITS:
• Plug-and-play operation
• No complex setup
• Automatic coordination
• Real-time integration
• Professional operation
            ]],
            tags = {"auto-linking", "systems", "integration"}
        }
    ],
    
    ["Combat Systems"] = {
        {
            title = "Weapon Types Guide",
            content = [[
Advanced Space Combat features 5 weapon types:

PULSE CANNON:
• Fast-firing energy weapon
• High rate of fire
• Good for light targets
• Energy efficient

BEAM WEAPON:
• Continuous energy beam
• Sustained damage
• Excellent accuracy
• High energy consumption

TORPEDO LAUNCHER:
• Guided heavy projectiles
• Smart targeting
• High damage
• Limited ammunition

RAILGUN:
• Electromagnetic kinetic weapon
• Penetrating rounds
• Armor piercing
• High velocity

PLASMA CANNON:
• Area-effect energy weapon
• Splash damage
• Good vs groups
• Energy intensive

All weapons auto-link to ship cores and coordinate with tactical AI.
            ]],
            tags = {"weapons", "combat", "guide"}
        },
        {
            title = "Tactical AI System",
            content = [[
The Tactical AI provides intelligent combat assistance.

BEHAVIOR MODES:
• Aggressive - Maximum firepower
• Defensive - Protection focus
• Balanced - Adaptive strategy

FEATURES:
• Auto-targeting
• Weapon coordination
• Fleet communication
• Threat assessment
• Combat optimization

CONFIGURATION:
• AI behavior selection
• Target prioritization
• Engagement rules
• Fleet coordination
• Performance tuning

The AI integrates with all weapon systems and provides real-time combat assistance.
            ]],
            tags = {"tactical ai", "combat", "automation"}
        }
    ],
    
    ["Flight & Navigation"] = {
        {
            title = "Flight System Guide",
            content = [[
Advanced flight system with physics-based movement.

FEATURES:
• 6-DOF movement (6 degrees of freedom)
• Physics-based flight
• Collision avoidance
• Autopilot system
• Formation flying

FLIGHT CONSOLE:
• Interactive control interface
• Real-time HUD display
• Navigation controls
• Autopilot settings
• Formation management

AUTOPILOT:
• Waypoint navigation
• Collision avoidance
• Automatic approach
• Formation maintenance
• Emergency procedures

FORMATIONS:
• Line formation
• V-formation
• Diamond formation
• Box formation
• Custom spacing
            ]],
            tags = {"flight", "navigation", "autopilot"}
        }
    ],
    
    ["Transport Systems"] = {
        {
            title = "Docking System Guide",
            content = [[
Automated docking and landing system.

DOCKING PAD TYPES:
• Small Pad - Light ships (800 mass)
• Medium Pad - Standard ships (2500 mass)
• Large Pad - Heavy ships (6000 mass)
• Shuttle Pad - Shuttles only (500 mass)
• Cargo Pad - Cargo operations (3000 mass)

LANDING PHASES:
1. Approach - Ship guided to landing area
2. Descent - Controlled descent to pad
3. Touchdown - Precise positioning
4. Service - Refuel, repair, resupply

SERVICES:
• Refueling - 150 energy/sec
• Repair - 75 health/sec
• Resupply - 15 ammo/sec
• Passenger transfer - 2/sec
• Cargo transfer - 50 units/sec
            ]],
            tags = {"docking", "landing", "services"}
        },
        {
            title = "Shuttle System Guide",
            content = [[
Automated shuttle transport system.

SHUTTLE TYPES:
• Transport - 8 passengers, 200kg cargo
• Cargo - 2 passengers, 800kg cargo
• Emergency - 12 passengers, 100kg cargo
• Scout - 2 passengers, 50kg cargo

MISSION TYPES:
• Passenger transport
• Cargo delivery
• Emergency evacuation
• Supply runs
• Patrol missions

AUTOMATION:
• Auto-assignment
• Route planning
• Mission execution
• Progress tracking
• Emergency response
            ]],
            tags = {"shuttles", "transport", "automation"}
        }
    ],

    ["Stargate Technology"] = {
        {
            title = "Technology Cultures Guide",
            content = [[
Advanced Space Combat features authentic Stargate-inspired technologies.

TECHNOLOGY TIERS (1-10):
• Tau'ri (Earth) - Tier 3
• Goa'uld - Tier 5
• Wraith - Tier 6
• Asgard - Tier 8
• Ori - Tier 9
• Ancient - Tier 10

ANCIENT TECHNOLOGY:
• Drone Weapons - Self-guided energy projectiles
• City Shields - Planetary-scale barriers
• ZPM Power - Unlimited energy sources
• Instant Hyperdrives - Intergalactic travel

ASGARD TECHNOLOGY:
• Ion Cannons - High-energy particle beams
• Advanced Shields - Multi-layer protection
• Beaming Tech - Matter transportation
• Efficient Hyperdrives - Long-range travel

GOA'ULD TECHNOLOGY:
• Staff Cannons - Plasma-based weapons
• Pyramid Shields - Naquadah-enhanced barriers
• Ribbon Devices - Neural disruption weapons
• Reliable Hyperdrives - Galactic range

COMMANDS:
• asc_stargate_spawn <culture> <type>
• asc_stargate_upgrade <culture>
• asc_stargate_info
            ]],
            tags = {"stargate", "technology", "cultures", "ancient", "asgard", "goa'uld"}
        },
        {
            title = "Technology Compatibility",
            content = [[
Technology compatibility system for mixed-tech ships.

COMPATIBILITY RULES:
• Higher tier tech can interface with lower tier
• Same tier technology is fully compatible
• Lower tier cannot fully utilize higher tier
• Compatibility affects efficiency and performance

TECHNOLOGY INTEGRATION:
• Ship cores detect technology levels
• Auto-balancing for mixed systems
• Performance scaling based on compatibility
• Upgrade paths available

UPGRADE SYSTEM:
• Upgrade entities to higher technology tiers
• Enhanced capabilities and performance
• Visual and functional improvements
• Maintains backward compatibility

BEST PRACTICES:
• Use same-tier technology for optimal performance
• Upgrade systematically from core outward
• Consider energy requirements for higher tiers
• Plan ship designs around technology culture
            ]],
            tags = {"compatibility", "upgrades", "integration", "performance"}
        }
    ]
}

-- Help system functions
function ASC.Documentation.ShowHelp(category, topic)
    if not ASC.Documentation.Config.EnableInGameHelp then return end
    
    local categoryData = ASC.Documentation.Database[category]
    if not categoryData then
        ASC.Documentation.ShowHelpIndex()
        return
    end
    
    if topic then
        -- Show specific topic
        for _, item in ipairs(categoryData) do
            if item.title == topic then
                ASC.Documentation.ShowHelpTopic(item)
                return
            end
        end
    end
    
    -- Show category index
    ASC.Documentation.ShowCategoryIndex(category, categoryData)
end

function ASC.Documentation.ShowHelpIndex()
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:SetTitle("Advanced Space Combat - Help System")
    frame:Center()
    frame:MakePopup()
    
    -- Create category list
    local categoryList = vgui.Create("DListView", frame)
    categoryList:SetPos(10, 30)
    categoryList:SetSize(200, 560)
    categoryList:AddColumn("Help Categories")
    
    for _, category in ipairs(ASC.Documentation.Config.Categories) do
        local line = categoryList:AddLine(category)
        line.OnSelect = function()
            ASC.Documentation.ShowHelp(category)
            frame:Close()
        end
    end
    
    -- Create welcome panel
    local welcomePanel = vgui.Create("DPanel", frame)
    welcomePanel:SetPos(220, 30)
    welcomePanel:SetSize(570, 560)
    
    welcomePanel.Paint = function(pnl, w, h)
        surface.SetDrawColor(240, 240, 240)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(200, 200, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    local welcomeLabel = vgui.Create("DLabel", welcomePanel)
    welcomeLabel:SetPos(20, 20)
    welcomeLabel:SetSize(530, 520)
    welcomeLabel:SetText([[
Welcome to Advanced Space Combat v2.2.1 Help System!

Select a category from the left to browse help topics.

QUICK ACCESS:
• Type "!ai help" in chat for AI assistance
• Use "asc_help" console command
• Press F1 for context-sensitive help

CATEGORIES:
• Getting Started - New player guide
• Ship Building - Ship construction
• Combat Systems - Weapons and tactics
• Flight & Navigation - Movement systems
• Transport Systems - Docking and shuttles
• Configuration - Settings and options
• Troubleshooting - Common issues
• API Reference - Developer information

For immediate assistance, try the ARIA chat AI by typing "!ai" followed by your question in chat.
    ]])
    welcomeLabel:SetWrap(true)
    welcomeLabel:SetAutoStretchVertical(true)
end

function ASC.Documentation.ShowCategoryIndex(category, categoryData)
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:SetTitle("Advanced Space Combat - " .. category)
    frame:Center()
    frame:MakePopup()
    
    -- Create topic list
    local topicList = vgui.Create("DListView", frame)
    topicList:SetPos(10, 30)
    topicList:SetSize(780, 560)
    topicList:AddColumn("Topic")
    topicList:AddColumn("Tags")
    
    for _, item in ipairs(categoryData) do
        local tags = table.concat(item.tags or {}, ", ")
        local line = topicList:AddLine(item.title, tags)
        line.OnSelect = function()
            ASC.Documentation.ShowHelpTopic(item)
        end
    end
end

function ASC.Documentation.ShowHelpTopic(topic)
    local frame = vgui.Create("DFrame")
    frame:SetSize(800, 600)
    frame:SetTitle("Advanced Space Combat - " .. topic.title)
    frame:Center()
    frame:MakePopup()
    
    -- Create content panel
    local contentPanel = vgui.Create("DPanel", frame)
    contentPanel:SetPos(10, 30)
    contentPanel:SetSize(780, 560)
    
    contentPanel.Paint = function(pnl, w, h)
        surface.SetDrawColor(250, 250, 250)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(200, 200, 200)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    -- Create scrollable text
    local textPanel = vgui.Create("DScrollPanel", contentPanel)
    textPanel:SetPos(10, 10)
    textPanel:SetSize(760, 540)
    
    local textLabel = vgui.Create("DLabel", textPanel)
    textLabel:SetPos(10, 10)
    textLabel:SetSize(740, 1000)
    textLabel:SetText(topic.content)
    textLabel:SetWrap(true)
    textLabel:SetAutoStretchVertical(true)
    textLabel:SetFont("DermaDefault")
end

-- Search function
function ASC.Documentation.SearchHelp(query)
    local results = {}
    
    for category, items in pairs(ASC.Documentation.Database) do
        for _, item in ipairs(items) do
            local searchText = (item.title .. " " .. item.content .. " " .. table.concat(item.tags or {}, " ")):lower()
            if string.find(searchText, query:lower()) then
                table.insert(results, {
                    category = category,
                    item = item,
                    relevance = ASC.Documentation.CalculateRelevance(searchText, query:lower())
                })
            end
        end
    end
    
    -- Sort by relevance
    table.sort(results, function(a, b) return a.relevance > b.relevance end)
    
    return results
end

function ASC.Documentation.CalculateRelevance(text, query)
    local relevance = 0
    local words = string.Split(query, " ")
    
    for _, word in ipairs(words) do
        local count = 0
        local start = 1
        while true do
            local pos = string.find(text, word, start)
            if not pos then break end
            count = count + 1
            start = pos + 1
        end
        relevance = relevance + count
    end
    
    return relevance
end

-- Console commands
concommand.Add("asc_help", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local category = args[1]
    local topic = args[2]
    
    if category then
        ASC.Documentation.ShowHelp(category, topic)
    else
        ASC.Documentation.ShowHelpIndex()
    end
end)

concommand.Add("asc_help_search", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local query = table.concat(args, " ")
    if query == "" then
        ply:ChatPrint("[Advanced Space Combat] Usage: asc_help_search <search terms>")
        return
    end
    
    local results = ASC.Documentation.SearchHelp(query)
    
    if #results == 0 then
        ply:ChatPrint("[Advanced Space Combat] No help topics found for: " .. query)
        return
    end
    
    ply:ChatPrint("[Advanced Space Combat] Help search results for: " .. query)
    for i, result in ipairs(results) do
        if i <= 5 then -- Show top 5 results
            ply:ChatPrint("• " .. result.item.title .. " (" .. result.category .. ")")
        end
    end
    
    if #results > 5 then
        ply:ChatPrint("... and " .. (#results - 5) .. " more results")
    end
end)

-- Context-sensitive help
hook.Add("PlayerUse", "ASC_ContextHelp", function(ply, ent)
    if not ASC.Documentation.Config.EnableContextHelp then return end
    if not IsValid(ent) then return end
    
    local class = ent:GetClass()
    local helpTopic = nil
    
    -- Map entity classes to help topics
    if class == "ship_core" then
        helpTopic = {category = "Ship Building", topic = "Ship Core System"}
    elseif string.find(class, "weapon") then
        helpTopic = {category = "Combat Systems", topic = "Weapon Types Guide"}
    elseif class == "asc_flight_console" then
        helpTopic = {category = "Flight & Navigation", topic = "Flight System Guide"}
    elseif class == "asc_docking_pad" then
        helpTopic = {category = "Transport Systems", topic = "Docking System Guide"}
    elseif class == "asc_shuttle" then
        helpTopic = {category = "Transport Systems", topic = "Shuttle System Guide"}
    end
    
    -- Show context help if F1 is held
    if input.IsKeyDown(KEY_F1) and helpTopic then
        ASC.Documentation.ShowHelp(helpTopic.category, helpTopic.topic)
        return false -- Prevent normal use
    end
end)

print("[Advanced Space Combat] Documentation System loaded successfully!")
