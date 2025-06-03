-- Enhanced Hyperdrive System - Q Menu Configuration v2.2.1
-- Q Menu integration and configuration interface

if not CLIENT then return end

print("[Hyperdrive] Loading Q Menu Configuration v2.2.1...")

-- Initialize Q Menu system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.QMenu = HYPERDRIVE.QMenu or {}

-- Q Menu configuration
HYPERDRIVE.QMenu.Config = {
    CategoryName = "Enhanced Hyperdrive",
    CategoryIcon = "icon16/world.png",
    EnableQMenu = true,
    ShowAdvancedOptions = false
}

-- Add Q Menu tab and categories
hook.Add("AddToolMenuTabs", "HyperdriveAddToolMenuTabs", function()
    if not HYPERDRIVE.QMenu.Config.EnableQMenu then return end
    
    spawnmenu.AddToolTab(HYPERDRIVE.QMenu.Config.CategoryName, HYPERDRIVE.QMenu.Config.CategoryName, HYPERDRIVE.QMenu.Config.CategoryIcon)
end)

-- Add Q Menu categories
hook.Add("AddToolMenuCategories", "HyperdriveAddToolMenuCategories", function()
    if not HYPERDRIVE.QMenu.Config.EnableQMenu then return end
    
    local categories = {
        "Core Settings",
        "Ship Systems",
        "Combat Systems", 
        "Performance",
        "Integration",
        "Advanced",
        "Help & Status"
    }
    
    for _, category in ipairs(categories) do
        spawnmenu.AddToolCategory(HYPERDRIVE.QMenu.Config.CategoryName, category, category)
    end
end)

-- Populate Q Menu options
hook.Add("PopulateToolMenu", "HyperdrivePopulateToolMenu", function()
    if not HYPERDRIVE.QMenu.Config.EnableQMenu then return end
    
    -- Core Settings
    spawnmenu.AddToolMenuOption(HYPERDRIVE.QMenu.Config.CategoryName, "Core Settings", "hyperdrive_core_settings", "Core Settings", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Enhanced Hyperdrive Core Settings",
            Description = "Configure core hyperdrive system behavior"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Hyperdrive System",
            Command = "hyperdrive_enabled"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Require Ship Core for Operation",
            Command = "hyperdrive_require_ship_core"
        })
        
        panel:AddControl("CheckBox", {
            Label = "One Ship Core Per Ship",
            Command = "hyperdrive_one_core_per_ship"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Auto-detect Ship Structures",
            Command = "hyperdrive_auto_detect_ships"
        })
        
        panel:AddControl("Slider", {
            Label = "Maximum Jump Range",
            Type = "Float",
            Min = "1000",
            Max = "200000",
            Command = "hyperdrive_max_range"
        })
        
        panel:AddControl("Slider", {
            Label = "Energy Cost per Jump",
            Type = "Float",
            Min = "100",
            Max = "10000",
            Command = "hyperdrive_energy_cost"
        })
        
        panel:AddControl("Slider", {
            Label = "Cooldown Time (seconds)",
            Type = "Float",
            Min = "5",
            Max = "120",
            Command = "hyperdrive_cooldown"
        })
    end)
    
    -- Ship Systems
    spawnmenu.AddToolMenuOption(HYPERDRIVE.QMenu.Config.CategoryName, "Ship Systems", "hyperdrive_ship_systems", "Ship Systems", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Ship Systems Configuration",
            Description = "Configure ship-related systems"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Shield System",
            Command = "hyperdrive_enable_shields"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Hull Damage System",
            Command = "hyperdrive_enable_hull_damage"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable USE Key Interfaces",
            Command = "hyperdrive_enable_use_key_interfaces"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable SHIFT+USE for Ship Core Access",
            Command = "hyperdrive_enable_shift_modifier"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Feedback Messages",
            Command = "hyperdrive_enable_feedback_messages"
        })
    end)
    
    -- Combat Systems
    spawnmenu.AddToolMenuOption(HYPERDRIVE.QMenu.Config.CategoryName, "Combat Systems", "hyperdrive_combat_systems", "Combat Systems", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Combat Systems Configuration",
            Description = "Configure weapons and combat features"
        })
        
        panel:AddControl("Label", {
            Text = "Weapon Systems:"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Pulse Cannon",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type asc_pulse_cannon"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Plasma Cannon", 
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type asc_plasma_cannon"
        })
        
        panel:AddControl("Button", {
            Label = "Spawn Railgun",
            Command = "gmod_tool asc_main_tool; asc_main_tool_entity_type asc_railgun"
        })
        
        panel:AddControl("Button", {
            Label = "Configure Weapons",
            Command = "gmod_tool asc_weapon_config"
        })
    end)
    
    -- Performance
    spawnmenu.AddToolMenuOption(HYPERDRIVE.QMenu.Config.CategoryName, "Performance", "hyperdrive_performance", "Performance", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Performance & Monitoring",
            Description = "Monitor and optimize system performance"
        })
        
        panel:AddControl("Button", {
            Label = "Show System Status",
            Command = "hyperdrive_status"
        })
        
        panel:AddControl("Button", {
            Label = "Show Monitoring Report",
            Command = "hyperdrive_monitoring_status"
        })
        
        panel:AddControl("Button", {
            Label = "Show Analytics Report",
            Command = "hyperdrive_analytics_report"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Real-time Monitoring",
            Command = "hyperdrive_monitoring_toggle"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Performance Analytics",
            Command = "hyperdrive_analytics_toggle"
        })
    end)
    
    -- Integration
    spawnmenu.AddToolMenuOption(HYPERDRIVE.QMenu.Config.CategoryName, "Integration", "hyperdrive_integration", "Integration", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Addon Integration",
            Description = "Configure integration with other addons"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable CAP Integration",
            Command = "hyperdrive_enable_cap_integration"
        })
        
        panel:AddControl("CheckBox", {
            Label = "Enable Spacebuild 3 Resources",
            Command = "hyperdrive_enable_sb3_resources"
        })
        
        panel:AddControl("Button", {
            Label = "Check CAP Status",
            Command = "say !ai cap info"
        })
        
        panel:AddControl("Button", {
            Label = "Check Integration Status",
            Command = "hyperdrive_status"
        })
    end)
    
    -- Help & Status
    spawnmenu.AddToolMenuOption(HYPERDRIVE.QMenu.Config.CategoryName, "Help & Status", "hyperdrive_help_status", "Help & Status", "", "", function(panel)
        panel:ClearControls()
        
        panel:AddControl("Header", {
            Text = "Help & System Information",
            Description = "Get help and check system status"
        })
        
        panel:AddControl("Button", {
            Label = "Show Help",
            Command = "hyperdrive_help"
        })
        
        panel:AddControl("Button", {
            Label = "System Status",
            Command = "hyperdrive_status"
        })
        
        panel:AddControl("Button", {
            Label = "AI Assistant Help",
            Command = "say !ai help"
        })
        
        panel:AddControl("Label", {
            Text = "AI Commands:"
        })
        
        panel:AddControl("Label", {
            Text = "!ai help - General help"
        })
        
        panel:AddControl("Label", {
            Text = "!ai ship building - Ship construction"
        })
        
        panel:AddControl("Label", {
            Text = "!ai weapons - Weapon systems"
        })
        
        panel:AddControl("Label", {
            Text = "!ai cap info - CAP integration"
        })
        
        panel:AddControl("Label", {
            Text = "!ai system status - System information"
        })
    end)
end)

print("[Hyperdrive] Q Menu Configuration v2.2.1 loaded successfully!")
