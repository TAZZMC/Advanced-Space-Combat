--[[
    Advanced Space Combat - Enhanced Q Menu Configuration UI v3.0.0
    
    Comprehensive Q Menu integration with organized tabs, tools, and spawn menu
    for the Advanced Space Combat addon.
]]

-- Initialize Enhanced Q Menu namespace
ASC = ASC or {}
ASC.QMenu = ASC.QMenu or {}

-- Enhanced Q Menu Configuration
ASC.QMenu.Config = {
    -- Core Settings
    Enabled = true,
    CategoryName = "Advanced Space Combat",
    CategoryIcon = "icon16/world.png",
    
    -- Tab Organization
    MainTabs = {
        {
            name = "Ship Systems",
            icon = "icon16/car.png",
            description = "Ship cores, engines, and propulsion systems"
        },
        {
            name = "Combat",
            icon = "icon16/bomb.png",
            description = "Weapons, shields, and defensive systems"
        },
        {
            name = "Flight & Navigation",
            icon = "icon16/arrow_up.png",
            description = "Flight controls, autopilot, and navigation"
        },
        {
            name = "AI & Automation",
            icon = "icon16/computer.png",
            description = "ARIA-4 AI system and automated systems"
        },
        {
            name = "Configuration",
            icon = "icon16/cog.png",
            description = "Addon settings and preferences"
        },
        {
            name = "Help & Diagnostics",
            icon = "icon16/help.png",
            description = "Documentation, troubleshooting, and diagnostics"
        }
    },
    
    -- Tool Categories
    ToolCategories = {
        "Core Tools",
        "Weapon Tools", 
        "Flight Tools",
        "Utility Tools",
        "Diagnostic Tools"
    },
    
    -- Spawn Menu Categories
    SpawnCategories = {
        "Ship Components",
        "Weapons & Defense",
        "Flight Systems",
        "Utility Entities",
        "AI & Automation"
    }
}

-- Enhanced Q Menu Core System
ASC.QMenu.Core = {
    -- Initialization status
    Initialized = false,
    
    -- UI Elements
    ActivePanels = {},
    
    -- Initialize enhanced Q menu
    Initialize = function()
        if ASC.QMenu.Core.Initialized then return end
        
        print("[Enhanced Q Menu] Initializing enhanced Q menu system...")
        
        -- Set up Q menu tabs
        ASC.QMenu.Core.SetupQMenuTabs()
        
        -- Set up tool categories
        ASC.QMenu.Core.SetupToolCategories()
        
        -- Set up spawn menu integration
        ASC.QMenu.Core.SetupSpawnMenuIntegration()
        
        -- Set up entity categories
        ASC.QMenu.Core.SetupEntityCategories()
        
        ASC.QMenu.Core.Initialized = true
        print("[Enhanced Q Menu] Enhanced Q menu system initialized")
    end,
    
    -- Set up Q menu tabs
    SetupQMenuTabs = function()
        -- Add main Advanced Space Combat tab
        hook.Add("AddToolMenuTabs", "ASC_EnhancedQMenu_AddTabs", function()
            spawnmenu.AddToolTab(ASC.QMenu.Config.CategoryName, ASC.QMenu.Config.CategoryName, ASC.QMenu.Config.CategoryIcon)
        end)
        
        -- Add sub-categories
        hook.Add("AddToolMenuCategories", "ASC_EnhancedQMenu_AddCategories", function()
            for _, tab in ipairs(ASC.QMenu.Config.MainTabs) do
                spawnmenu.AddToolCategory(ASC.QMenu.Config.CategoryName, tab.name, tab.name)
            end
        end)
        
        print("[Enhanced Q Menu] Q menu tabs configured")
    end,
    
    -- Set up tool categories
    SetupToolCategories = function()
        -- Ship Systems Tab
        ASC.QMenu.Core.CreateShipSystemsTab()
        
        -- Combat Tab
        ASC.QMenu.Core.CreateCombatTab()
        
        -- Flight & Navigation Tab
        ASC.QMenu.Core.CreateFlightNavigationTab()
        
        -- AI & Automation Tab
        ASC.QMenu.Core.CreateAIAutomationTab()
        
        -- Configuration Tab
        ASC.QMenu.Core.CreateConfigurationTab()
        
        -- Help & Diagnostics Tab
        ASC.QMenu.Core.CreateHelpDiagnosticsTab()
        
        print("[Enhanced Q Menu] Tool categories configured")
    end,
    
    -- Create Ship Systems tab
    CreateShipSystemsTab = function()
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Ship Systems", "ship_core_manager", "Ship Core Manager", "", "", function(panel)
            panel:ClearControls()
            
            panel:AddControl("Header", {
                Text = "Ship Core Management",
                Description = "Central ship management and control systems"
            })
            
            -- Ship Core Tools
            panel:AddControl("Button", {
                Label = "Ship Core Tool",
                Command = "gmod_tool asc_ship_core_tool"
            })
            
            panel:AddControl("Button", {
                Label = "Spawn ASC Ship Core",
                Command = "asc_spawn_entity asc_ship_core"
            })
            
            -- Ship Configuration
            panel:AddControl("TextBox", {
                Label = "Default Ship Name",
                Command = "asc_default_ship_name"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Auto-Link Components",
                Command = "asc_enable_auto_linking"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Real-Time Updates",
                Command = "asc_enable_realtime_updates"
            })
            
            -- Ship Detection Range
            panel:AddControl("Slider", {
                Label = "Ship Detection Range",
                Command = "asc_default_ship_range",
                Type = "Integer",
                Min = 500,
                Max = 5000
            })
        end)
        
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Ship Systems", "hyperdrive_systems", "Hyperdrive Systems", "", "", function(panel)
            panel:ClearControls()
            
            panel:AddControl("Header", {
                Text = "Hyperdrive & Propulsion",
                Description = "Faster-than-light travel and propulsion systems"
            })
            
            -- Hyperdrive Tools
            panel:AddControl("Button", {
                Label = "Hyperdrive Tool",
                Command = "gmod_tool asc_hyperdrive_tool"
            })
            
            panel:AddControl("Button", {
                Label = "Spawn Enhanced Master Engine",
                Command = "asc_spawn_entity hyperdrive_master_engine"
            })
            
            -- Hyperdrive Configuration
            panel:AddControl("CheckBox", {
                Label = "4-Stage Stargate Hyperspace",
                Command = "asc_enable_stargate_hyperspace"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Dimensional Travel Effects",
                Command = "asc_enable_dimensional_effects"
            })
            
            panel:AddControl("Slider", {
                Label = "Max Jump Distance",
                Command = "asc_max_jump_distance",
                Type = "Integer",
                Min = 10000,
                Max = 100000
            })
        end)
        
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Ship Systems", "resource_management", "Resource Management", "", "", function(panel)
            panel:ClearControls()
            
            panel:AddControl("Header", {
                Text = "Resource & Energy Systems",
                Description = "Spacebuild 3 integration and resource management"
            })
            
            -- Resource Settings
            panel:AddControl("CheckBox", {
                Label = "Enable SB3 Integration",
                Command = "asc_enable_sb3_integration"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Auto Resource Distribution",
                Command = "asc_enable_auto_resources"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Life Support Systems",
                Command = "asc_enable_life_support"
            })
            
            -- Resource Scaling
            panel:AddControl("Slider", {
                Label = "Resource Capacity Scaling",
                Command = "asc_resource_capacity_scale",
                Type = "Float",
                Min = 0.1,
                Max = 5.0
            })
            
            panel:AddControl("Slider", {
                Label = "Regeneration Rate Scaling",
                Command = "asc_resource_regen_scale",
                Type = "Float",
                Min = 0.1,
                Max = 3.0
            })
        end)
    end,
    
    -- Create Combat tab
    CreateCombatTab = function()
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Combat", "weapon_systems", "Weapon Systems", "", "", function(panel)
            panel:ClearControls()
            
            panel:AddControl("Header", {
                Text = "Advanced Weapon Systems",
                Description = "Ship-to-ship combat weapons and systems"
            })
            
            -- Weapon Tools
            panel:AddControl("Button", {
                Label = "Weapon Tool",
                Command = "gmod_tool asc_weapon_tool"
            })
            
            -- Weapon Spawning
            panel:AddControl("Label", {
                Text = "Weapon Types:"
            })
            
            panel:AddControl("Button", {
                Label = "Pulse Cannon",
                Command = "asc_spawn_entity asc_pulse_cannon"
            })
            
            panel:AddControl("Button", {
                Label = "Plasma Cannon",
                Command = "asc_spawn_entity asc_plasma_cannon"
            })
            
            panel:AddControl("Button", {
                Label = "Railgun",
                Command = "asc_spawn_entity asc_railgun"
            })
            
            panel:AddControl("Button", {
                Label = "Torpedo Launcher",
                Command = "asc_spawn_entity asc_torpedo_launcher"
            })
            
            -- Weapon Configuration
            panel:AddControl("CheckBox", {
                Label = "Predictive Targeting",
                Command = "asc_enable_predictive_targeting"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Auto-Targeting",
                Command = "asc_enable_auto_targeting"
            })
            
            panel:AddControl("Slider", {
                Label = "Max Weapons Per Ship",
                Command = "asc_max_weapons_per_ship",
                Type = "Integer",
                Min = 5,
                Max = 50
            })
        end)
        
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Combat", "defense_systems", "Defense Systems", "", "", function(panel)
            panel:ClearControls()
            
            panel:AddControl("Header", {
                Text = "Defensive Systems",
                Description = "Shields, point defense, and countermeasures"
            })
            
            -- Defense Tools
            panel:AddControl("Button", {
                Label = "Shield Tool",
                Command = "gmod_tool asc_shield_tool"
            })
            
            -- Defense Spawning
            panel:AddControl("Button", {
                Label = "Shield Generator",
                Command = "asc_spawn_entity asc_shield_generator"
            })
            
            panel:AddControl("Button", {
                Label = "Point Defense Turret",
                Command = "asc_spawn_entity asc_point_defense"
            })
            
            panel:AddControl("Button", {
                Label = "Countermeasures System",
                Command = "asc_spawn_entity asc_countermeasures"
            })
            
            -- Defense Configuration
            panel:AddControl("CheckBox", {
                Label = "CAP Shield Integration",
                Command = "asc_enable_cap_shields"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Auto Point Defense",
                Command = "asc_enable_auto_point_defense"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Auto Countermeasures",
                Command = "asc_enable_auto_countermeasures"
            })
        end)
        
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Combat", "tactical_ai", "Tactical AI", "", "", function(panel)
            panel:ClearControls()
            
            panel:AddControl("Header", {
                Text = "Tactical AI Systems",
                Description = "Automated combat and tactical decision making"
            })
            
            -- Tactical AI Configuration
            panel:AddControl("CheckBox", {
                Label = "Enable Tactical AI",
                Command = "asc_enable_tactical_ai"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Auto Combat Mode",
                Command = "asc_enable_auto_combat"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Fleet Coordination",
                Command = "asc_enable_fleet_coordination"
            })
            
            panel:AddControl("Slider", {
                Label = "AI Update Rate",
                Command = "asc_tactical_ai_update_rate",
                Type = "Float",
                Min = 0.1,
                Max = 2.0
            })
            
            -- Boss System
            panel:AddControl("Label", {
                Text = "AI Boss System:"
            })
            
            panel:AddControl("Button", {
                Label = "Start Boss Vote",
                Command = "asc_start_boss_vote"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Enable Boss System",
                Command = "asc_enable_boss_system"
            })
        end)
    end,
    
    -- Create Flight & Navigation tab
    CreateFlightNavigationTab = function()
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Flight & Navigation", "flight_systems", "Flight Systems", "", "", function(panel)
            panel:ClearControls()
            
            panel:AddControl("Header", {
                Text = "Ship Flight & Control",
                Description = "Flight systems, autopilot, and ship control"
            })
            
            -- Flight Configuration
            panel:AddControl("CheckBox", {
                Label = "Auto Flight Mode on Seat Entry",
                Command = "asc_enable_auto_flight_mode"
            })
            
            panel:AddControl("CheckBox", {
                Label = "Auto Level on Seat Exit",
                Command = "asc_enable_auto_level"
            })
            
            panel:AddControl("CheckBox", {
                Label = "External Camera Mode",
                Command = "asc_enable_external_camera"
            })
            
            panel:AddControl("Slider", {
                Label = "Flight Update Rate",
                Command = "asc_flight_update_rate",
                Type = "Float",
                Min = 0.05,
                Max = 0.5
            })
            
            panel:AddControl("Slider", {
                Label = "Camera Distance",
                Command = "asc_camera_distance",
                Type = "Integer",
                Min = 100,
                Max = 1000
            })
        end)
        
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Flight & Navigation", "docking_systems", "Docking & Transport", "", "", function(panel)
            panel:ClearControls()
            
            panel:AddControl("Header", {
                Text = "Docking & Transport Systems",
                Description = "Docking pads, shuttles, and transport systems"
            })
            
            -- Docking Tools
            panel:AddControl("Button", {
                Label = "Docking Pad Tool",
                Command = "gmod_tool asc_docking_tool"
            })
            
            panel:AddControl("Button", {
                Label = "Spawn Docking Pad",
                Command = "asc_spawn_entity asc_docking_pad"
            })
            
            panel:AddControl("Button", {
                Label = "Spawn Shuttle",
                Command = "asc_spawn_entity asc_shuttle"
            })
            
            -- Docking Configuration
            panel:AddControl("CheckBox", {
                Label = "Auto Docking",
                Command = "asc_enable_auto_docking"
            })
            
            panel:AddControl("Slider", {
                Label = "Docking Range",
                Command = "asc_docking_range",
                Type = "Integer",
                Min = 500,
                Max = 5000
            })
        end)
    end,

    -- Create AI & Automation tab
    CreateAIAutomationTab = function()
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "AI & Automation", "aria_ai_system", "ARIA-4 AI System", "", "", function(panel)
            panel:ClearControls()

            panel:AddControl("Header", {
                Text = "ARIA-4 AI Assistant",
                Description = "Advanced AI system with machine learning and web access"
            })

            -- AI Configuration
            panel:AddControl("CheckBox", {
                Label = "Enable AI System",
                Command = "asc_enable_ai_system"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable Web Access",
                Command = "asc_ai_web_access"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable Learning Mode",
                Command = "asc_ai_learning_mode"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable Proactive Assistance",
                Command = "asc_ai_proactive_mode"
            })

            -- AI Commands
            panel:AddControl("Label", {
                Text = "AI Commands:"
            })

            panel:AddControl("Button", {
                Label = "AI Status",
                Command = "asc_ai_status"
            })

            panel:AddControl("Button", {
                Label = "AI Diagnostics",
                Command = "say !ai diagnostic"
            })

            panel:AddControl("Button", {
                Label = "AI Help",
                Command = "say !ai help"
            })
        end)

        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "AI & Automation", "character_selection", "Character Selection", "", "", function(panel)
            panel:ClearControls()

            panel:AddControl("Header", {
                Text = "Player Character Selection",
                Description = "Select and customize player models"
            })

            -- Character Selection
            panel:AddControl("Button", {
                Label = "Open Character Selection",
                Command = "asc_open_character_selection"
            })

            -- Quick Model Selection
            panel:AddControl("Label", {
                Text = "Quick Model Selection:"
            })

            panel:AddControl("Button", {
                Label = "Default Male",
                Command = "asc_set_model models/player/Group01/male_01.mdl"
            })

            panel:AddControl("Button", {
                Label = "Default Female",
                Command = "asc_set_model models/player/Group01/female_01.mdl"
            })

            -- CAP Models (if available)
            if ASC.CAP and ASC.CAP.IsAvailable() then
                panel:AddControl("Label", {
                    Text = "CAP Character Models:"
                })

                panel:AddControl("Button", {
                    Label = "Tau'ri Officer",
                    Command = "asc_set_model models/cap/tauri/officer.mdl"
                })

                panel:AddControl("Button", {
                    Label = "Goa'uld Jaffa",
                    Command = "asc_set_model models/cap/goauld/jaffa.mdl"
                })
            end
        end)
    end,

    -- Create Configuration tab
    CreateConfigurationTab = function()
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Configuration", "general_settings", "General Settings", "", "", function(panel)
            panel:ClearControls()

            panel:AddControl("Header", {
                Text = "Advanced Space Combat Configuration",
                Description = "General addon settings and preferences"
            })

            -- Core Settings
            panel:AddControl("CheckBox", {
                Label = "Enable Debug Mode",
                Command = "asc_debug_mode"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable Performance Monitoring",
                Command = "asc_enable_performance_monitoring"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable Error Recovery",
                Command = "asc_enable_error_recovery"
            })

            -- Integration Settings
            panel:AddControl("Label", {
                Text = "Integration Settings:"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable CAP Integration",
                Command = "asc_enable_cap_integration"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable Spacebuild Integration",
                Command = "asc_enable_spacebuild_integration"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable ULX Integration",
                Command = "asc_enable_ulx_integration"
            })

            -- Reset Options
            panel:AddControl("Label", {
                Text = "Reset Options:"
            })

            panel:AddControl("Button", {
                Label = "Reset All Settings",
                Command = "asc_reset_all_settings"
            })

            panel:AddControl("Button", {
                Label = "Reset Performance Data",
                Command = "asc_reset_performance_data"
            })
        end)

        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Configuration", "language_settings", "Language Settings", "", "", function(panel)
            panel:ClearControls()

            panel:AddControl("Header", {
                Text = "Language & Localization",
                Description = "Language preferences and Czech localization"
            })

            -- Language Selection
            panel:AddControl("Label", {
                Text = "Language Selection:"
            })

            panel:AddControl("Button", {
                Label = "English",
                Command = "asc_set_language en"
            })

            panel:AddControl("Button", {
                Label = "Czech (Čeština)",
                Command = "asc_set_language cs"
            })

            -- Auto-Detection Settings
            panel:AddControl("CheckBox", {
                Label = "Enable Auto Language Detection",
                Command = "asc_enable_auto_language_detection"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable Chat Analysis",
                Command = "asc_enable_chat_analysis"
            })

            panel:AddControl("CheckBox", {
                Label = "Save Language Preference",
                Command = "asc_save_language_preference"
            })

            -- Detection Status
            panel:AddControl("Button", {
                Label = "Check Language Detection Status",
                Command = "asc_language_detection_status"
            })
        end)

        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Configuration", "theme_settings", "Theme Settings", "", "", function(panel)
            panel:ClearControls()

            panel:AddControl("Header", {
                Text = "Theme & Visual Settings",
                Description = "Loading screen, theme, and visual customization"
            })

            -- Theme Settings
            panel:AddControl("CheckBox", {
                Label = "Enable Loading Screen",
                Command = "asc_enable_loading_screen"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable Theme System",
                Command = "asc_enable_theme_system"
            })

            panel:AddControl("CheckBox", {
                Label = "Apply Theme to All Elements",
                Command = "asc_apply_theme_globally"
            })

            -- Visual Effects
            panel:AddControl("CheckBox", {
                Label = "Enable Visual Effects",
                Command = "asc_enable_visual_effects"
            })

            panel:AddControl("CheckBox", {
                Label = "Enable Particle Effects",
                Command = "asc_enable_particle_effects"
            })

            panel:AddControl("Slider", {
                Label = "Effect Quality",
                Command = "asc_effect_quality",
                Type = "Integer",
                Min = 1,
                Max = 5
            })
        end)
    end,

    -- Create Help & Diagnostics tab
    CreateHelpDiagnosticsTab = function()
        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Help & Diagnostics", "help_documentation", "Help & Documentation", "", "", function(panel)
            panel:ClearControls()

            panel:AddControl("Header", {
                Text = "Help & Documentation",
                Description = "Comprehensive documentation and help resources"
            })

            -- Documentation
            panel:AddControl("Button", {
                Label = "Open Documentation",
                Command = "asc_open_documentation"
            })

            panel:AddControl("Button", {
                Label = "Quick Start Guide",
                Command = "asc_open_quick_start"
            })

            panel:AddControl("Button", {
                Label = "Feature Overview",
                Command = "asc_show_features"
            })

            -- Help Commands
            panel:AddControl("Label", {
                Text = "Help Commands:"
            })

            panel:AddControl("Button", {
                Label = "AI Help",
                Command = "say !ai help"
            })

            panel:AddControl("Button", {
                Label = "Command List",
                Command = "asc_command_list"
            })

            panel:AddControl("Button", {
                Label = "Troubleshooting",
                Command = "asc_troubleshooting"
            })
        end)

        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Help & Diagnostics", "system_diagnostics", "System Diagnostics", "", "", function(panel)
            panel:ClearControls()

            panel:AddControl("Header", {
                Text = "System Diagnostics",
                Description = "System status, performance monitoring, and diagnostics"
            })

            -- System Status
            panel:AddControl("Button", {
                Label = "System Status",
                Command = "asc_system_status"
            })

            panel:AddControl("Button", {
                Label = "Performance Report",
                Command = "asc_performance_report"
            })

            panel:AddControl("Button", {
                Label = "Integration Status",
                Command = "asc_integration_status"
            })

            -- Diagnostic Tools
            panel:AddControl("Label", {
                Text = "Diagnostic Tools:"
            })

            panel:AddControl("Button", {
                Label = "Ship Core Diagnostic",
                Command = "say !ai diagnostic ship"
            })

            panel:AddControl("Button", {
                Label = "Weapon System Diagnostic",
                Command = "say !ai diagnostic weapons"
            })

            panel:AddControl("Button", {
                Label = "Flight System Diagnostic",
                Command = "say !ai diagnostic flight"
            })

            panel:AddControl("Button", {
                Label = "Full System Diagnostic",
                Command = "say !ai diagnostic all"
            })
        end)

        spawnmenu.AddToolMenuOption(ASC.QMenu.Config.CategoryName, "Help & Diagnostics", "troubleshooting", "Troubleshooting", "", "", function(panel)
            panel:ClearControls()

            panel:AddControl("Header", {
                Text = "Troubleshooting Tools",
                Description = "Common issues and automated fixes"
            })

            -- Common Fixes
            panel:AddControl("Label", {
                Text = "Common Fixes:"
            })

            panel:AddControl("Button", {
                Label = "Fix Q Menu Issues",
                Command = "asc_fix_qmenu"
            })

            panel:AddControl("Button", {
                Label = "Fix Spawn Menu Issues",
                Command = "asc_fix_spawn_menu"
            })

            panel:AddControl("Button", {
                Label = "Refresh Ship Detection",
                Command = "asc_refresh_ship_detection"
            })

            panel:AddControl("Button", {
                Label = "Reset AI System",
                Command = "asc_reset_ai_system"
            })

            -- Advanced Troubleshooting
            panel:AddControl("Label", {
                Text = "Advanced Troubleshooting:"
            })

            panel:AddControl("Button", {
                Label = "Force Entity Registration",
                Command = "asc_force_register_entities"
            })

            panel:AddControl("Button", {
                Label = "Reload All Systems",
                Command = "asc_reload_all_systems"
            })

            panel:AddControl("Button", {
                Label = "Clear Error Log",
                Command = "asc_clear_error_log"
            })
        end)
    end,

    -- Set up spawn menu integration
    SetupSpawnMenuIntegration = function()
        -- This will be handled by the existing spawn menu organization system
        print("[Enhanced Q Menu] Spawn menu integration configured")
    end,

    -- Set up entity categories
    SetupEntityCategories = function()
        -- This will be handled by the existing entity categories system
        print("[Enhanced Q Menu] Entity categories configured")
    end
}

-- Initialize on client load
hook.Add("InitPostEntity", "ASC_EnhancedQMenu_Init", function()
    timer.Simple(1, function()
        ASC.QMenu.Core.Initialize()
    end)
end)

-- Console command to force Q menu setup
concommand.Add("asc_force_setup_qmenu", function()
    ASC.QMenu.Core.Initialize()
    chat.AddText(Color(100, 200, 255), "[Advanced Space Combat] Q Menu setup completed!")
end)
