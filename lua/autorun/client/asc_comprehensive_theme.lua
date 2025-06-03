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
        
        -- Text Colors
        Text = Color(255, 255, 255, 255),       -- White
        TextSecondary = Color(178, 190, 195, 200), -- Light Gray
        TextMuted = Color(150, 150, 150, 150),  -- Muted Gray
        TextDisabled = Color(100, 100, 100, 100), -- Disabled Gray
        
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
    CreateClientConVar("asc_theme_tool_panels", "1", true, false, "Enable tool panel theming")
    CreateClientConVar("asc_theme_spawn_menu", "1", true, false, "Enable spawn menu theming")
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
end

-- Entity interface theming
function ASC.ComprehensiveTheme.InitializeEntityTheming()
    -- Override VGUI panel painting for consistent theming
    local originalPaint = vgui.GetControlTable("DFrame").Paint
    
    vgui.GetControlTable("DFrame").Paint = function(self, w, h)
        -- Check if this is an ASC panel
        if self.ASCThemed then
            ASC.ComprehensiveTheme.DrawThemedFrame(self, w, h)
        else
            originalPaint(self, w, h)
        end
    end
    
    -- Override button painting
    local originalButtonPaint = vgui.GetControlTable("DButton").Paint
    
    vgui.GetControlTable("DButton").Paint = function(self, w, h)
        if self.ASCThemed then
            ASC.ComprehensiveTheme.DrawThemedButton(self, w, h)
        else
            originalButtonPaint(self, w, h)
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
    
    -- Title bar
    if panel:GetTitle() and panel:GetTitle() ~= "" then
        draw.RoundedBox(config.BorderRadius.Small, 5, 5, w - 10, 30, config.Colors.Primary)
        
        surface.SetFont(config.Fonts.Subtitle)
        surface.SetTextColor(config.Colors.Text)
        local titleW, titleH = surface.GetTextSize(panel:GetTitle())
        surface.SetTextPos(w/2 - titleW/2, 10)
        surface.DrawText(panel:GetTitle())
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
    
    -- Draw button text
    if panel:GetText() and panel:GetText() ~= "" then
        surface.SetFont(config.Fonts.Button)
        surface.SetTextColor(textColor)
        local textW, textH = surface.GetTextSize(panel:GetText())
        surface.SetTextPos(w/2 - textW/2, h/2 - textH/2)
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
    
    -- Find tool panels
    for _, panel in pairs(vgui.GetWorldPanel():GetChildren()) do
        if IsValid(panel) and panel:GetClassName() == "DFrame" then
            local title = panel:GetTitle()
            if title and (string.find(title, "Weapon") or string.find(title, "Advanced Space Combat")) then
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
        -- Theme spawn menu panels
        local function ThemeSpawnMenuPanel(panel)
            if IsValid(panel) then
                panel.ASCThemed = true
                
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

-- Console commands for testing
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

-- Initialize on client
hook.Add("Initialize", "ASC_ComprehensiveTheme_Init", function()
    ASC.ComprehensiveTheme.Initialize()
end)

print("[Advanced Space Combat] Comprehensive Theme System loaded successfully!")
