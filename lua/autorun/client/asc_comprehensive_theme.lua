-- Advanced Space Combat - Comprehensive Theme System v1.0.0
-- Complete theming for all in-game elements and interfaces

print("[Advanced Space Combat] Comprehensive Theme System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.ComprehensiveTheme = ASC.ComprehensiveTheme or {}

-- Master theme configuration
ASC.ComprehensiveTheme.Config = {
    -- Enable/Disable Features
    EnableEntityInterfaces = true,
    EnableToolPanels = true,
    EnableSpawnMenuTheming = true,
    EnableWeaponInterfaces = true,
    EnableFlightControls = true,
    EnableAIInterfaces = true,
    
    -- Global Theme Settings
    UseGlobalTheme = true,
    EnableAnimations = true,
    EnableSoundEffects = true,
    EnableParticleEffects = false, -- Performance consideration
    
    -- Master Color Palette (Space Combat Theme)
    Colors = {
        -- Primary Colors
        Primary = Color(41, 128, 185, 240),      -- Space Blue
        Secondary = Color(52, 73, 94, 220),     -- Dark Blue-Gray
        Tertiary = Color(44, 62, 80, 200),      -- Darker Gray
        
        -- Accent Colors
        Accent = Color(155, 89, 182, 255),      -- Purple
        AccentHover = Color(175, 109, 202, 255), -- Lighter Purple
        AccentActive = Color(135, 69, 162, 255), -- Darker Purple
        
        -- Status Colors
        Success = Color(39, 174, 96, 255),      -- Green
        Warning = Color(243, 156, 18, 255),     -- Orange
        Danger = Color(231, 76, 60, 255),       -- Red
        Info = Color(52, 152, 219, 255),        -- Light Blue
        
        -- System Colors
        Energy = Color(0, 255, 255, 200),       -- Cyan
        Shield = Color(100, 200, 255, 200),     -- Shield Blue
        Hull = Color(255, 100, 100, 200),       -- Hull Red
        Weapon = Color(255, 200, 100, 200),     -- Weapon Orange
        Flight = Color(100, 255, 100, 200),     -- Flight Green
        AI = Color(255, 100, 255, 200),         -- AI Magenta
        
        -- Background Colors
        Background = Color(23, 32, 42, 240),    -- Dark Background
        Surface = Color(30, 39, 46, 220),       -- Surface
        Panel = Color(37, 46, 56, 200),         -- Panel Background
        
        -- Text Colors (Enhanced for visibility)
        Text = Color(255, 255, 255, 255),       -- Bright White
        TextSecondary = Color(220, 220, 220, 255), -- Very Light Gray
        TextMuted = Color(180, 180, 180, 255),  -- Light Gray
        TextDisabled = Color(120, 120, 120, 200), -- Disabled Gray
        TextContrast = Color(255, 255, 255, 255), -- High contrast white
        TextShadow = Color(0, 0, 0, 200),       -- Text shadow for readability

        -- Border Colors
        Border = Color(99, 110, 114, 150),      -- Border
        BorderHover = Color(119, 130, 134, 200), -- Hover Border
        BorderActive = Color(139, 150, 154, 255), -- Active Border
        
        -- Special Effects
        Glow = Color(100, 150, 255, 100),       -- Blue Glow
        Shadow = Color(0, 0, 0, 150),           -- Shadow
        Overlay = Color(0, 0, 0, 100)           -- Overlay
    },
    
    -- Typography
    Fonts = {
        Title = "ASC_Title",
        Subtitle = "ASC_Subtitle",
        Body = "ASC_Body",
        Small = "ASC_Small",
        Button = "ASC_Button",
        HUD = "ASC_HUD"
    },
    
    -- Layout Settings
    Spacing = {
        Small = 5,
        Medium = 10,
        Large = 20,
        XLarge = 30
    },
    
    BorderRadius = {
        Small = 4,
        Medium = 8,
        Large = 12,
        XLarge = 16
    },
    
    -- Animation Settings
    Animations = {
        FadeSpeed = 3.0,
        SlideSpeed = 2.0,
        ScaleSpeed = 4.0,
        ColorSpeed = 2.5
    }
}

-- Theme state management
ASC.ComprehensiveTheme.State = {
    ActivePanels = {},
    AnimationStates = {},
    LastUpdate = 0,
    UpdateInterval = 0.05 -- 20 FPS for smooth animations
}

-- Initialize comprehensive theme system
function ASC.ComprehensiveTheme.Initialize()
    print("[Advanced Space Combat] Initializing comprehensive theme system...")
    
    -- Create custom fonts
    ASC.ComprehensiveTheme.CreateFonts()
    
    -- Set up ConVars
    ASC.ComprehensiveTheme.CreateConVars()
    
    -- Initialize theme components
    ASC.ComprehensiveTheme.InitializeComponents()
    
    print("[Advanced Space Combat] Comprehensive theme system initialized")
end

-- Create custom fonts for consistent theming
function ASC.ComprehensiveTheme.CreateFonts()
    surface.CreateFont("ASC_Title", {
        font = "Arial",
        size = 28,
        weight = 700,
        antialias = true,
        shadow = true
    })
    
    surface.CreateFont("ASC_Subtitle", {
        font = "Arial",
        size = 22,
        weight = 600,
        antialias = true,
        shadow = true
    })
    
    surface.CreateFont("ASC_Body", {
        font = "Arial",
        size = 16,
        weight = 500,
        antialias = true
    })
    
    surface.CreateFont("ASC_Small", {
        font = "Arial",
        size = 14,
        weight = 400,
        antialias = true
    })
    
    surface.CreateFont("ASC_Button", {
        font = "Arial",
        size = 16,
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("ASC_HUD", {
        font = "Arial",
        size = 18,
        weight = 600,
        antialias = true,
        shadow = true
    })
end

-- Create configuration ConVars
function ASC.ComprehensiveTheme.CreateConVars()
    CreateClientConVar("asc_theme_enabled", "1", true, false, "Enable comprehensive theme system")
    CreateClientConVar("asc_theme_animations", "1", true, false, "Enable theme animations")
    CreateClientConVar("asc_theme_sounds", "1", true, false, "Enable theme sound effects")
    CreateClientConVar("asc_theme_entity_interfaces", "1", true, false, "Enable entity interface theming")
    CreateClientConVar("asc_theme_tool_panels", "0", true, false, "Enable tool panel theming")
    CreateClientConVar("asc_theme_spawn_menu", "0", true, false, "Enable spawn menu theming (DISABLED by default due to visibility issues)")
end

-- Initialize theme components
function ASC.ComprehensiveTheme.InitializeComponents()
    -- Initialize entity interface theming
    if GetConVar("asc_theme_entity_interfaces"):GetBool() then
        ASC.ComprehensiveTheme.InitializeEntityTheming()
    end

    -- Initialize tool panel theming
    if GetConVar("asc_theme_tool_panels"):GetBool() then
        ASC.ComprehensiveTheme.InitializeToolTheming()
    end

    -- Initialize spawn menu theming
    if GetConVar("asc_theme_spawn_menu"):GetBool() then
        ASC.ComprehensiveTheme.InitializeSpawnMenuTheming()
    end

    -- Initialize game interface theming integration
    if ASC.GameTheme then
        ASC.ComprehensiveTheme.IntegrateWithGameTheme()
    end
end

-- Entity interface theming
function ASC.ComprehensiveTheme.InitializeEntityTheming()
    -- Store original paint functions safely
    if not ASC.ComprehensiveTheme.OriginalPaintFunctions then
        ASC.ComprehensiveTheme.OriginalPaintFunctions = {}
    end

    -- Store original DFrame paint function
    ASC.ComprehensiveTheme.OriginalPaintFunctions.DFrame = vgui.GetControlTable("DFrame").Paint

    -- Override VGUI panel painting for consistent theming with error protection
    vgui.GetControlTable("DFrame").Paint = function(self, w, h)
        -- Protect against errors
        local success, err = pcall(function()
            -- Check if this is an ASC panel
            if self.ASCThemed then
                ASC.ComprehensiveTheme.DrawThemedFrame(self, w, h)
            else
                -- Use original paint function with error protection
                local original = ASC.ComprehensiveTheme.OriginalPaintFunctions.DFrame
                if original then
                    original(self, w, h)
                end
            end
        end)

        if not success then
            -- Emergency fallback
            draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200))
        end
    end

    -- Store original DButton paint function
    ASC.ComprehensiveTheme.OriginalPaintFunctions.DButton = vgui.GetControlTable("DButton").Paint

    -- Override button painting with error protection
    vgui.GetControlTable("DButton").Paint = function(self, w, h)
        local success, err = pcall(function()
            if self.ASCThemed then
                ASC.ComprehensiveTheme.DrawThemedButton(self, w, h)
            else
                local original = ASC.ComprehensiveTheme.OriginalPaintFunctions.DButton
                if original then
                    original(self, w, h)
                end
            end
        end)

        if not success then
            -- Emergency fallback for buttons
            draw.RoundedBox(4, 0, 0, w, h, Color(70, 70, 70, 200))
        end
    end

    print("[Advanced Space Combat] Entity interface theming initialized")
end

-- Tool panel theming
function ASC.ComprehensiveTheme.InitializeToolTheming()
    -- Hook into tool panel creation
    hook.Add("SpawnMenuOpen", "ASC_ThemeToolPanels", function()
        timer.Simple(0.1, function()
            ASC.ComprehensiveTheme.ApplyToolPanelTheming()
        end)
    end)
    
    print("[Advanced Space Combat] Tool panel theming initialized")
end

-- Spawn menu theming
function ASC.ComprehensiveTheme.InitializeSpawnMenuTheming()
    -- Hook into spawn menu creation
    hook.Add("SpawnMenuOpen", "ASC_ThemeSpawnMenu", function()
        timer.Simple(0.1, function()
            ASC.ComprehensiveTheme.ApplySpawnMenuTheming()
        end)
    end)
    
    print("[Advanced Space Combat] Spawn menu theming initialized")
end

-- Draw themed frame
function ASC.ComprehensiveTheme.DrawThemedFrame(panel, w, h)
    local config = ASC.ComprehensiveTheme.Config
    
    -- Background with glassmorphism effect
    draw.RoundedBox(config.BorderRadius.Large, 0, 0, w, h, config.Colors.Background)
    draw.RoundedBox(config.BorderRadius.Medium, 2, 2, w - 4, h - 4, config.Colors.Surface)
    
    -- Border
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    
    -- Title bar with error protection
    local success, title = pcall(function()
        if panel.GetTitle then
            return panel:GetTitle()
        end
        return nil
    end)

    if success and title and title ~= "" then
        draw.RoundedBox(config.BorderRadius.Small, 5, 5, w - 10, 30, config.Colors.Primary)

        surface.SetFont(config.Fonts.Subtitle)
        local titleW, titleH = surface.GetTextSize(title)
        local textX, textY = w/2 - titleW/2, 10

        -- Draw text shadow for better readability
        surface.SetTextColor(config.Colors.TextShadow)
        surface.SetTextPos(textX + 1, textY + 1)
        surface.DrawText(title)

        -- Draw main text
        surface.SetTextColor(config.Colors.TextContrast)
        surface.SetTextPos(textX, textY)
        surface.DrawText(title)
    end
    
    -- Glow effect
    if config.EnableAnimations then
        local glowAlpha = math.sin(CurTime() * 2) * 30 + 50
        draw.RoundedBox(config.BorderRadius.Large + 2, -2, -2, w + 4, h + 4, 
            Color(config.Colors.Glow.r, config.Colors.Glow.g, config.Colors.Glow.b, glowAlpha))
    end
end

-- Draw themed button
function ASC.ComprehensiveTheme.DrawThemedButton(panel, w, h)
    local config = ASC.ComprehensiveTheme.Config
    local bgColor = config.Colors.Secondary
    local textColor = config.Colors.Text
    
    -- Button state colors
    if panel:IsHovered() then
        bgColor = config.Colors.AccentHover
    end
    
    if panel:IsDown() then
        bgColor = config.Colors.AccentActive
    end
    
    if not panel:IsEnabled() then
        bgColor = config.Colors.TextDisabled
        textColor = config.Colors.TextMuted
    end
    
    -- Draw button background
    draw.RoundedBox(config.BorderRadius.Small, 0, 0, w, h, bgColor)
    
    -- Draw border
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
    
    -- Draw button text with shadow for better readability
    if panel:GetText() and panel:GetText() ~= "" then
        surface.SetFont(config.Fonts.Button)
        local textW, textH = surface.GetTextSize(panel:GetText())
        local textX, textY = w/2 - textW/2, h/2 - textH/2

        -- Draw text shadow
        surface.SetTextColor(config.Colors.TextShadow)
        surface.SetTextPos(textX + 1, textY + 1)
        surface.DrawText(panel:GetText())

        -- Draw main text
        surface.SetTextColor(textColor)
        surface.SetTextPos(textX, textY)
        surface.DrawText(panel:GetText())
    end
    
    -- Hover glow effect
    if panel:IsHovered() and config.EnableAnimations then
        local glowAlpha = math.sin(CurTime() * 4) * 20 + 30
        draw.RoundedBox(config.BorderRadius.Small + 1, -1, -1, w + 2, h + 2,
            Color(config.Colors.Accent.r, config.Colors.Accent.g, config.Colors.Accent.b, glowAlpha))
    end
end

-- Apply tool panel theming
function ASC.ComprehensiveTheme.ApplyToolPanelTheming()
    -- Find and theme tool panels
    local function ThemePanel(panel)
        if IsValid(panel) then
            panel.ASCThemed = true
            
            -- Theme child elements
            for _, child in pairs(panel:GetChildren()) do
                if child:GetClassName() == "DButton" or child:GetClassName() == "DFrame" then
                    child.ASCThemed = true
                end
                ThemePanel(child)
            end
        end
    end
    
    -- Find tool panels with error protection
    for _, panel in pairs(vgui.GetWorldPanel():GetChildren()) do
        if IsValid(panel) and panel:GetClassName() == "DFrame" then
            local success, title = pcall(function()
                if panel.GetTitle then
                    return panel:GetTitle()
                end
                return nil
            end)

            if success and title and (string.find(title, "Weapon") or string.find(title, "Advanced Space Combat")) then
                ThemePanel(panel)
            end
        end
    end
end

-- Apply spawn menu theming
function ASC.ComprehensiveTheme.ApplySpawnMenuTheming()
    -- Find and theme spawn menu elements
    local spawnMenu = g_SpawnMenu
    if IsValid(spawnMenu) then
        -- Theme spawn menu panels with selective theming
        local function ThemeSpawnMenuPanel(panel)
            if IsValid(panel) then
                local className = panel:GetClassName()

                -- Blacklist of elements that should NEVER be themed to preserve visibility
                local blacklistedClasses = {
                    "SpawnIcon", "ContentIcon", "DImageButton", "DImage",
                    "DModelPanel", "DScrollPanel", "DListView", "DTree",
                    "DPropertySheet", "DTab", "DIconLayout", "DTileLayout"
                }

                -- Check if this class should be skipped
                for _, blacklisted in ipairs(blacklistedClasses) do
                    if className == blacklisted or string.find(className:lower(), "icon") or
                       string.find(className:lower(), "image") or string.find(className:lower(), "model") then
                        -- Skip theming for this element and its children
                        return
                    end
                end

                -- Only theme background containers and frames
                if className == "DFrame" and panel:GetTitle() and
                   string.find(panel:GetTitle():lower(), "spawn") then
                    panel.ASCThemed = true
                elseif className == "ContentSidebar" or className == "ContentContainer" then
                    -- Theme only the background, preserve content
                    panel.ASCThemed = true
                end

                -- Recursively check children
                for _, child in pairs(panel:GetChildren()) do
                    ThemeSpawnMenuPanel(child)
                end
            end
        end

        ThemeSpawnMenuPanel(spawnMenu)
    end
end

-- Utility function to create themed panels
function ASC.ComprehensiveTheme.CreateThemedPanel(parent, panelType)
    local panel = vgui.Create(panelType or "DPanel", parent)
    if IsValid(panel) then
        panel.ASCThemed = true
        
        -- Apply custom paint function
        panel.Paint = function(self, w, h)
            ASC.ComprehensiveTheme.DrawThemedPanel(self, w, h)
        end
    end
    
    return panel
end

-- Draw themed panel
function ASC.ComprehensiveTheme.DrawThemedPanel(panel, w, h)
    local config = ASC.ComprehensiveTheme.Config
    
    draw.RoundedBox(config.BorderRadius.Medium, 0, 0, w, h, config.Colors.Panel)
    
    -- Border
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

-- Utility function to create themed buttons
function ASC.ComprehensiveTheme.CreateThemedButton(parent, text, callback)
    local button = vgui.Create("DButton", parent)
    if IsValid(button) then
        button.ASCThemed = true
        button:SetText(text or "")
        
        if callback then
            button.DoClick = callback
        end
        
        -- Play sound on click
        button.DoClick = function(self)
            if GetConVar("asc_theme_sounds"):GetBool() then
                surface.PlaySound("buttons/button15.wav")
            end
            if callback then callback() end
        end
    end
    
    return button
end

-- Console commands for testing and fixing visibility
concommand.Add("asc_theme_test", function()
    local frame = ASC.ComprehensiveTheme.CreateThemedPanel(nil, "DFrame")
    frame:SetSize(400, 300)
    frame:SetTitle("Advanced Space Combat - Theme Test")
    frame:Center()
    frame:MakePopup()

    local button = ASC.ComprehensiveTheme.CreateThemedButton(frame, "Test Button", function()
        print("Themed button clicked!")
    end)
    button:SetPos(150, 100)
    button:SetSize(100, 30)
end)

-- Emergency fix for visibility issues
concommand.Add("asc_fix_visibility", function()
    print("[Advanced Space Combat] Emergency fix for spawn menu visibility...")

    -- Completely disable all spawn menu theming
    RunConsoleCommand("asc_theme_spawn_menu", "0")

    -- Remove all hooks that might be theming spawn menu
    hook.Remove("SpawnMenuOpen", "ASC_ThemeSpawnMenu")
    hook.Remove("SpawnMenuOpen", "ASC_ComprehensiveTheme_GameIntegration")
    hook.Remove("SpawnMenuOpen", "ASC_ThemeToolPanels")

    -- Restore original VGUI paint functions
    if ASC.ComprehensiveTheme.OriginalPaintFunctions then
        if ASC.ComprehensiveTheme.OriginalPaintFunctions.DFrame then
            vgui.GetControlTable("DFrame").Paint = ASC.ComprehensiveTheme.OriginalPaintFunctions.DFrame
        end
        if ASC.ComprehensiveTheme.OriginalPaintFunctions.DButton then
            vgui.GetControlTable("DButton").Paint = ASC.ComprehensiveTheme.OriginalPaintFunctions.DButton
        end
    end

    -- Reset spawn menu completely
    local spawnMenu = g_SpawnMenu
    if IsValid(spawnMenu) then
        local function CompleteReset(panel)
            if IsValid(panel) then
                -- Remove ALL ASC theming
                panel.ASCThemed = nil
                panel.Paint = nil -- Reset to default

                -- Recursively reset ALL children
                for _, child in pairs(panel:GetChildren()) do
                    CompleteReset(child)
                end
            end
        end

        CompleteReset(spawnMenu)

        -- Force spawn menu refresh
        spawnMenu:Close()
        timer.Simple(0.1, function()
            RunConsoleCommand("spawnmenu_reload")
        end)
    end

    print("[Advanced Space Combat] Emergency visibility fix applied!")
    print("All theming disabled. Spawn menu should be fully visible now.")
    print("Use 'asc_restore_minimal_theming' to restore only entity theming.")
end)

-- Restore minimal theming (entity interfaces only)
concommand.Add("asc_restore_minimal_theming", function()
    print("[Advanced Space Combat] Restoring minimal theming (entity interfaces only)...")

    -- Enable only entity interface theming
    RunConsoleCommand("asc_theme_enabled", "1")
    RunConsoleCommand("asc_theme_entity_interfaces", "1")
    RunConsoleCommand("asc_theme_tool_panels", "0")
    RunConsoleCommand("asc_theme_spawn_menu", "0")

    -- Reinitialize with minimal theming
    ASC.ComprehensiveTheme.InitializeEntityTheming()

    print("[Advanced Space Combat] Minimal theming restored!")
    print("Only ASC entity interfaces will be themed. Spawn menu remains untouched.")
end)

-- Restore full theming
concommand.Add("asc_restore_theming", function()
    print("[Advanced Space Combat] Restoring full theming...")

    RunConsoleCommand("asc_theme_enabled", "1")
    RunConsoleCommand("asc_theme_entity_interfaces", "1")
    RunConsoleCommand("asc_theme_tool_panels", "1")
    RunConsoleCommand("asc_theme_spawn_menu", "1")

    -- Reinitialize all theming
    ASC.ComprehensiveTheme.Initialize()

    print("[Advanced Space Combat] Full theming restored!")
    print("WARNING: This may cause spawn menu visibility issues again.")
end)

-- Integrate with game theme system
function ASC.ComprehensiveTheme.IntegrateWithGameTheme()
    print("[Advanced Space Combat] Integrating comprehensive theme with game interface theme")

    -- Share color configuration
    if ASC.GameTheme and ASC.GameTheme.Config then
        -- Sync colors between systems
        for colorName, color in pairs(ASC.ComprehensiveTheme.Config.Colors) do
            if ASC.GameTheme.Config.Colors[colorName] then
                ASC.GameTheme.Config.Colors[colorName] = color
            end
        end
    end

    -- Add hook to apply comprehensive theming after game theming
    hook.Add("SpawnMenuOpen", "ASC_ComprehensiveTheme_GameIntegration", function()
        timer.Simple(0.2, function()
            if ASC.GameTheme and ASC.GameTheme.ApplySpawnMenuTheming then
                ASC.GameTheme.ApplySpawnMenuTheming()
            end
            ASC.ComprehensiveTheme.ApplySpawnMenuTheming()
        end)
    end)
end

-- Enhanced spawn menu theming with game integration
function ASC.ComprehensiveTheme.ApplyEnhancedSpawnMenuTheming()
    local spawnMenu = g_SpawnMenu
    if not IsValid(spawnMenu) then return end

    -- Apply comprehensive theming to spawn menu
    local function EnhanceSpawnMenuPanel(panel)
        if not IsValid(panel) then return end

        local className = panel:GetClassName()

        -- Enhanced theming for specific spawn menu elements
        if className == "ContentSidebar" or className == "ContentContainer" or
           className == "SpawnIcon" or className == "ContentIcon" then

            -- Store original paint
            local originalPaint = panel.Paint

            panel.Paint = function(self, w, h)
                -- Apply ASC theme
                local config = ASC.ComprehensiveTheme.Config
                draw.RoundedBox(config.BorderRadius.Small, 0, 0, w, h, config.Colors.Surface)
                surface.SetDrawColor(config.Colors.Border)
                surface.DrawOutlinedRect(0, 0, w, h, 1)

                -- Call original if exists
                if originalPaint then
                    originalPaint(self, w, h)
                end
            end

            panel.ASCThemed = true
        end

        -- Recursively theme children
        for _, child in pairs(panel:GetChildren()) do
            EnhanceSpawnMenuPanel(child)
        end
    end

    EnhanceSpawnMenuPanel(spawnMenu)
end

-- Console command for enhanced theming
concommand.Add("asc_comprehensive_theme_reload", function()
    ASC.ComprehensiveTheme.Initialize()
    if ASC.GameTheme then
        ASC.GameTheme.Initialize()
    end
    print("[Advanced Space Combat] All theme systems reloaded")
end)

-- Initialize on client
hook.Add("Initialize", "ASC_ComprehensiveTheme_Init", function()
    ASC.ComprehensiveTheme.Initialize()
end)

print("[Advanced Space Combat] Comprehensive Theme System loaded successfully!")
