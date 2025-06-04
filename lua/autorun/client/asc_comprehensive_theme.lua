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

    -- Create console commands
    ASC.ComprehensiveTheme.CreateConsoleCommands()

    print("[Advanced Space Combat] Comprehensive theme system initialized")
end

-- Create console commands for theme management
function ASC.ComprehensiveTheme.CreateConsoleCommands()
    -- Theme testing command
    concommand.Add("asc_theme_test", function(ply, cmd, args)
        if not IsValid(ply) then return end

        ply:ChatPrint("[ASC Theme] Testing comprehensive theme system...")

        -- Create test panel
        local testFrame = vgui.Create("DFrame")
        testFrame:SetSize(400, 300)
        testFrame:Center()
        testFrame:SetTitle("Advanced Space Combat - Theme Test")
        testFrame:MakePopup()
        testFrame.ASCThemed = true

        -- Add test button
        local testButton = vgui.Create("DButton", testFrame)
        testButton:SetSize(200, 40)
        testButton:SetPos(100, 100)
        testButton:SetText("Test Themed Button")
        testButton.ASCThemed = true

        ply:ChatPrint("[ASC Theme] Test panel created with enhanced theming")
    end, nil, "Test the comprehensive theme system")

    -- Web resource status command
    concommand.Add("asc_theme_web_status", function(ply, cmd, args)
        if not IsValid(ply) then return end

        if ASC.WebResources then
            local status = {
                "Web Resource Manager: Available",
                "Background Material: " .. (ASC.ComprehensiveTheme.BackgroundMaterial and "Loaded" or "Not Available"),
                "Glow Material: " .. (ASC.ComprehensiveTheme.GlowMaterial and "Loaded" or "Not Available"),
                "Star Particle: " .. (ASC.ComprehensiveTheme.StarParticle and "Loaded" or "Not Available"),
                "Generated Fallbacks: " .. table.Count(ASC.WebResources.State.GeneratedFallbacks)
            }

            for _, line in ipairs(status) do
                ply:ChatPrint("[ASC Theme] " .. line)
            end
        else
            ply:ChatPrint("[ASC Theme] Web Resource Manager: Not Available")
        end
    end, nil, "Check web resource status for theme system")

    -- Reload theme resources command
    concommand.Add("asc_theme_reload", function(ply, cmd, args)
        if not IsValid(ply) then return end

        ply:ChatPrint("[ASC Theme] Reloading theme resources...")

        -- Reload fonts
        ASC.ComprehensiveTheme.CreateFonts()

        -- Reload web resources
        ASC.ComprehensiveTheme.LoadWebResources()

        -- Reinitialize effects
        ASC.ComprehensiveTheme.InitializeEnhancedEffects()

        ply:ChatPrint("[ASC Theme] Theme resources reloaded successfully")
    end, nil, "Reload theme resources and effects")

    -- Performance optimization command
    concommand.Add("asc_theme_optimize", function(ply, cmd, args)
        if not IsValid(ply) then return end

        ply:ChatPrint("[ASC Theme] Optimizing theme performance...")

        -- Disable particle effects for performance
        ASC.ComprehensiveTheme.Config.EnableParticleEffects = false

        -- Reduce animation complexity
        ASC.ComprehensiveTheme.Config.EnableAnimations = false

        -- Clear particle system
        if ASC.ComprehensiveTheme.ParticleSystem then
            ASC.ComprehensiveTheme.ParticleSystem.Stars = {}
        end

        ply:ChatPrint("[ASC Theme] Performance optimizations applied")
        ply:ChatPrint("[ASC Theme] Use 'asc_theme_reload' to restore full effects")
    end, nil, "Optimize theme system for better performance")

    print("[ASC Theme] Console commands created")
end

-- Create custom fonts for consistent theming with web font support
function ASC.ComprehensiveTheme.CreateFonts()
    -- Try to use space-themed fonts, fallback to system fonts
    local spaceFonts = {
        "Orbitron", "Exo 2", "Rajdhani", "Russo One", "Audiowide"
    }

    local primaryFont = "Arial" -- Default fallback
    local secondaryFont = "Tahoma" -- Secondary fallback

    -- Check if any space fonts are available
    for _, font in ipairs(spaceFonts) do
        if ASC.ComprehensiveTheme.IsFontAvailable(font) then
            primaryFont = font
            break
        end
    end

    -- Create fonts with enhanced styling
    surface.CreateFont("ASC_Title", {
        font = primaryFont,
        size = 32,
        weight = 800,
        antialias = true,
        shadow = true,
        outline = true
    })

    surface.CreateFont("ASC_Subtitle", {
        font = primaryFont,
        size = 24,
        weight = 700,
        antialias = true,
        shadow = true,
        outline = false
    })

    surface.CreateFont("ASC_Body", {
        font = secondaryFont,
        size = 16,
        weight = 500,
        antialias = true,
        shadow = false
    })

    surface.CreateFont("ASC_Small", {
        font = secondaryFont,
        size = 14,
        weight = 400,
        antialias = true,
        shadow = false
    })

    surface.CreateFont("ASC_Button", {
        font = primaryFont,
        size = 16,
        weight = 600,
        antialias = true,
        shadow = true
    })

    surface.CreateFont("ASC_HUD", {
        font = primaryFont,
        size = 20,
        weight = 700,
        antialias = true,
        shadow = true,
        outline = true
    })

    -- Create additional specialized fonts
    surface.CreateFont("ASC_Console", {
        font = "Courier New",
        size = 14,
        weight = 500,
        antialias = true,
        shadow = false
    })

    surface.CreateFont("ASC_Logo", {
        font = primaryFont,
        size = 48,
        weight = 900,
        antialias = true,
        shadow = true,
        outline = true
    })

    print("[Advanced Space Combat] Fonts created using: " .. primaryFont)
end

-- Check if a font is available on the system
function ASC.ComprehensiveTheme.IsFontAvailable(fontName)
    -- Create a test font and check if it falls back to default
    local testFontName = "ASC_FontTest_" .. string.gsub(fontName, " ", "_")

    surface.CreateFont(testFontName, {
        font = fontName,
        size = 16,
        weight = 400,
        antialias = true
    })

    -- This is a basic check - in practice, font availability detection is limited in GMod
    return true -- Assume available for now, will fallback gracefully
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
    -- Load web resources for enhanced theming
    ASC.ComprehensiveTheme.LoadWebResources()

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

    -- Initialize enhanced visual effects
    ASC.ComprehensiveTheme.InitializeEnhancedEffects()
end

-- Load web resources for enhanced theming
function ASC.ComprehensiveTheme.LoadWebResources()
    if not ASC.WebResources then
        print("[ASC Theme] Web resource manager not available, using fallbacks")
        return
    end

    -- Load background materials
    ASC.ComprehensiveTheme.BackgroundMaterial = ASC.WebResources.GetResource("material", "space_background")
    ASC.ComprehensiveTheme.GlowMaterial = ASC.WebResources.GetResource("material", "ui_glow")
    ASC.ComprehensiveTheme.StarParticle = ASC.WebResources.GetResource("material", "particle_star")

    print("[ASC Theme] Web resources loaded for enhanced theming")
end

-- Initialize enhanced visual effects
function ASC.ComprehensiveTheme.InitializeEnhancedEffects()
    -- Create particle system for backgrounds
    ASC.ComprehensiveTheme.ParticleSystem = {
        Stars = {},
        LastUpdate = 0,
        UpdateInterval = 0.1
    }

    -- Generate initial star particles
    for i = 1, 50 do
        table.insert(ASC.ComprehensiveTheme.ParticleSystem.Stars, {
            x = math.random(0, ScrW()),
            y = math.random(0, ScrH()),
            speed = math.random(10, 30),
            size = math.random(1, 3),
            alpha = math.random(100, 255)
        })
    end

    print("[ASC Theme] Enhanced visual effects initialized")
end

-- Entity interface theming - PROPER APPROACH
function ASC.ComprehensiveTheme.InitializeEntityTheming()
    -- DO NOT override global vgui.GetControlTable() functions
    -- This causes spawn menu visibility issues

    -- Instead, use hooks to apply theming only to specific panels
    hook.Add("VGUICreated", "ASC_ThemeEntityPanels", function(panel, panelType)
        if not IsValid(panel) then return end

        -- Only theme panels that are explicitly marked for ASC theming
        timer.Simple(0.01, function()
            if IsValid(panel) and panel.ASCThemed then
                ASC.ComprehensiveTheme.ApplyThemeToSpecificPanel(panel, panelType)
            end
        end)
    end)

    -- Hook for when panels are created by ASC systems
    hook.Add("ASC_PanelCreated", "ASC_ApplyTheming", function(panel, panelType)
        if IsValid(panel) then
            ASC.ComprehensiveTheme.ApplyThemeToSpecificPanel(panel, panelType)
        end
    end)

    print("[Advanced Space Combat] Entity interface theming initialized (safe method)")
end

-- Apply theme to specific panel without affecting global VGUI
function ASC.ComprehensiveTheme.ApplyThemeToSpecificPanel(panel, panelType)
    if not IsValid(panel) or not panel.ASCThemed then return end

    -- Store original paint function for this specific panel
    if not panel.OriginalPaint then
        panel.OriginalPaint = panel.Paint
    end

    -- Apply custom paint function based on panel type
    if panelType == "DFrame" or panel:GetClassName() == "DFrame" then
        panel.Paint = function(self, w, h)
            ASC.ComprehensiveTheme.DrawThemedFrame(self, w, h)
        end
    elseif panelType == "DButton" or panel:GetClassName() == "DButton" then
        panel.Paint = function(self, w, h)
            ASC.ComprehensiveTheme.DrawThemedButton(self, w, h)
        end
    elseif panelType == "DPanel" or panel:GetClassName() == "DPanel" then
        panel.Paint = function(self, w, h)
            ASC.ComprehensiveTheme.DrawThemedPanel(self, w, h)
        end
    end

    -- Apply theming to children if they're also marked for theming
    for _, child in ipairs(panel:GetChildren()) do
        if IsValid(child) and child.ASCThemed then
            ASC.ComprehensiveTheme.ApplyThemeToSpecificPanel(child, child:GetClassName())
        end
    end
end

-- Draw themed panel (generic panel theming)
function ASC.ComprehensiveTheme.DrawThemedPanel(panel, w, h)
    local config = ASC.ComprehensiveTheme.Config

    -- Draw animated background if available
    if ASC.ComprehensiveTheme.BackgroundMaterial then
        surface.SetMaterial(ASC.ComprehensiveTheme.BackgroundMaterial)
        surface.SetDrawColor(255, 255, 255, 20)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    -- Background
    draw.RoundedBox(config.BorderRadius.Medium, 0, 0, w, h, config.Colors.Surface)

    -- Border
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    -- Subtle glow effect
    if config.EnableAnimations then
        local glowAlpha = math.sin(CurTime() * 1.5) * 20 + 30
        draw.RoundedBox(config.BorderRadius.Medium + 1, -1, -1, w + 2, h + 2,
            Color(config.Colors.Glow.r, config.Colors.Glow.g, config.Colors.Glow.b, glowAlpha))
    end
end

-- Tool panel theming - SAFE APPROACH
function ASC.ComprehensiveTheme.InitializeToolTheming()
    -- DO NOT hook into SpawnMenuOpen as it affects the entire spawn menu
    -- Instead, only theme ASC-specific tool panels

    -- Hook for ASC tool creation
    hook.Add("ASC_ToolPanelCreated", "ASC_ThemeToolPanels", function(panel)
        if IsValid(panel) then
            panel.ASCThemed = true
            ASC.ComprehensiveTheme.ApplyThemeToSpecificPanel(panel, panel:GetClassName())
        end
    end)

    print("[Advanced Space Combat] Tool panel theming initialized (safe method)")
end

-- Spawn menu theming - SAFE APPROACH
function ASC.ComprehensiveTheme.InitializeSpawnMenuTheming()
    -- DO NOT theme the entire spawn menu as it causes visibility issues
    -- Only theme ASC-specific spawn menu elements

    -- Hook for ASC spawn menu elements
    hook.Add("ASC_SpawnMenuElementCreated", "ASC_ThemeSpawnMenuElements", function(panel)
        if IsValid(panel) then
            panel.ASCThemed = true
            ASC.ComprehensiveTheme.ApplyThemeToSpecificPanel(panel, panel:GetClassName())
        end
    end)

    print("[Advanced Space Combat] Spawn menu theming initialized (safe method)")
end

-- Draw themed frame with enhanced effects
function ASC.ComprehensiveTheme.DrawThemedFrame(panel, w, h)
    local config = ASC.ComprehensiveTheme.Config

    -- Draw animated background if available
    if ASC.ComprehensiveTheme.BackgroundMaterial then
        surface.SetMaterial(ASC.ComprehensiveTheme.BackgroundMaterial)
        surface.SetDrawColor(255, 255, 255, 30)
        surface.DrawTexturedRect(0, 0, w, h)
    end

    -- Background with glassmorphism effect
    draw.RoundedBox(config.BorderRadius.Large, 0, 0, w, h, config.Colors.Background)
    draw.RoundedBox(config.BorderRadius.Medium, 2, 2, w - 4, h - 4, config.Colors.Surface)

    -- Enhanced border with gradient effect
    ASC.ComprehensiveTheme.DrawGradientBorder(0, 0, w, h, config.Colors.Border, config.Colors.BorderHover)

    -- Title bar with enhanced styling
    local success, title = pcall(function()
        if panel.GetTitle then
            return panel:GetTitle()
        end
        return nil
    end)

    if success and title and title ~= "" then
        -- Title background with gradient
        ASC.ComprehensiveTheme.DrawGradientRect(5, 5, w - 10, 30, config.Colors.Primary, config.Colors.Secondary)

        surface.SetFont(config.Fonts.Subtitle)
        local titleW, titleH = surface.GetTextSize(title)
        local textX, textY = w/2 - titleW/2, 10

        -- Draw enhanced text with multiple shadows
        ASC.ComprehensiveTheme.DrawEnhancedText(title, textX, textY, config.Colors.TextContrast, config.Colors.TextShadow)
    end

    -- Enhanced glow effect with web resources
    if config.EnableAnimations then
        ASC.ComprehensiveTheme.DrawEnhancedGlow(panel, w, h)
    end

    -- Draw particle effects if enabled
    if config.EnableParticleEffects then
        ASC.ComprehensiveTheme.DrawParticleEffects(w, h)
    end
end

-- Draw gradient border
function ASC.ComprehensiveTheme.DrawGradientBorder(x, y, w, h, color1, color2)
    local steps = 10
    for i = 0, steps do
        local alpha = i / steps
        local r = Lerp(alpha, color1.r, color2.r)
        local g = Lerp(alpha, color1.g, color2.g)
        local b = Lerp(alpha, color1.b, color2.b)
        local a = Lerp(alpha, color1.a, color2.a)

        surface.SetDrawColor(r, g, b, a)
        surface.DrawOutlinedRect(x + i, y + i, w - i*2, h - i*2, 1)
    end
end

-- Draw gradient rectangle
function ASC.ComprehensiveTheme.DrawGradientRect(x, y, w, h, color1, color2)
    local steps = math.min(w, 20) -- Limit steps for performance
    for i = 0, steps do
        local alpha = i / steps
        local r = Lerp(alpha, color1.r, color2.r)
        local g = Lerp(alpha, color1.g, color2.g)
        local b = Lerp(alpha, color1.b, color2.b)
        local a = Lerp(alpha, color1.a, color2.a)

        surface.SetDrawColor(r, g, b, a)
        surface.DrawRect(x + (i * w / steps), y, w / steps + 1, h)
    end
end

-- Draw enhanced text with multiple effects
function ASC.ComprehensiveTheme.DrawEnhancedText(text, x, y, textColor, shadowColor)
    -- Draw outer glow
    for dx = -2, 2 do
        for dy = -2, 2 do
            if dx ~= 0 or dy ~= 0 then
                surface.SetTextColor(shadowColor.r, shadowColor.g, shadowColor.b, shadowColor.a / 4)
                surface.SetTextPos(x + dx, y + dy)
                surface.DrawText(text)
            end
        end
    end

    -- Draw main shadow
    surface.SetTextColor(shadowColor)
    surface.SetTextPos(x + 1, y + 1)
    surface.DrawText(text)

    -- Draw main text
    surface.SetTextColor(textColor)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
end

-- Draw enhanced glow effect
function ASC.ComprehensiveTheme.DrawEnhancedGlow(panel, w, h)
    local config = ASC.ComprehensiveTheme.Config

    if ASC.ComprehensiveTheme.GlowMaterial then
        -- Use web resource glow material
        surface.SetMaterial(ASC.ComprehensiveTheme.GlowMaterial)
        local glowAlpha = math.sin(CurTime() * 2) * 50 + 100
        surface.SetDrawColor(config.Colors.Glow.r, config.Colors.Glow.g, config.Colors.Glow.b, glowAlpha)
        surface.DrawTexturedRect(-10, -10, w + 20, h + 20)
    else
        -- Fallback glow effect
        local glowAlpha = math.sin(CurTime() * 2) * 30 + 50
        draw.RoundedBox(config.BorderRadius.Large + 2, -2, -2, w + 4, h + 4,
            Color(config.Colors.Glow.r, config.Colors.Glow.g, config.Colors.Glow.b, glowAlpha))
    end
end

-- Draw particle effects
function ASC.ComprehensiveTheme.DrawParticleEffects(w, h)
    if not ASC.ComprehensiveTheme.ParticleSystem then return end

    local particles = ASC.ComprehensiveTheme.ParticleSystem.Stars
    local currentTime = CurTime()

    -- Update particles
    if currentTime - ASC.ComprehensiveTheme.ParticleSystem.LastUpdate > ASC.ComprehensiveTheme.ParticleSystem.UpdateInterval then
        for _, particle in ipairs(particles) do
            particle.x = particle.x + particle.speed * ASC.ComprehensiveTheme.ParticleSystem.UpdateInterval
            if particle.x > w + 10 then
                particle.x = -10
                particle.y = math.random(0, h)
            end
        end
        ASC.ComprehensiveTheme.ParticleSystem.LastUpdate = currentTime
    end

    -- Draw particles
    if ASC.ComprehensiveTheme.StarParticle then
        surface.SetMaterial(ASC.ComprehensiveTheme.StarParticle)
        for _, particle in ipairs(particles) do
            surface.SetDrawColor(255, 255, 255, particle.alpha)
            surface.DrawTexturedRect(particle.x, particle.y, particle.size, particle.size)
        end
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

-- VGUI rescan function for console command
function ASC.ComprehensiveTheme.RescanVGUI()
    print("[ASC Theme] Rescanning VGUI elements for theming...")

    -- Re-apply theming to all existing panels
    local panelCount = 0

    -- Find all VGUI panels
    for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
        if IsValid(panel) then
            ASC.ComprehensiveTheme.ApplyThemeToPanel(panel)
            panelCount = panelCount + 1
        end
    end

    -- Reinitialize theme components
    ASC.ComprehensiveTheme.InitializeComponents()

    print("[ASC Theme] Rescan complete - " .. panelCount .. " panels processed")
end

-- Apply theme to a specific panel
function ASC.ComprehensiveTheme.ApplyThemeToPanel(panel)
    if not IsValid(panel) then return end

    -- Mark panel as themed
    panel.ASCThemed = true

    -- Apply theme based on panel type
    local panelType = panel:GetName() or panel.ClassName or "Unknown"

    if panelType:find("Frame") or panelType:find("Window") then
        -- Apply frame theming
        panel.Paint = function(self, w, h)
            ASC.ComprehensiveTheme.DrawThemedFrame(self, w, h)
        end
    elseif panelType:find("Button") then
        -- Apply button theming
        panel.Paint = function(self, w, h)
            ASC.ComprehensiveTheme.DrawThemedButton(self, w, h)
        end
    end

    -- Apply to children recursively
    for _, child in ipairs(panel:GetChildren()) do
        ASC.ComprehensiveTheme.ApplyThemeToPanel(child)
    end
end

-- Helper function to create themed panels properly
function ASC.ComprehensiveTheme.CreateThemedPanel(panelType, parent, name)
    local panel = vgui.Create(panelType, parent, name)

    if IsValid(panel) then
        -- Mark panel for ASC theming
        panel.ASCThemed = true

        -- Apply theming immediately
        timer.Simple(0.01, function()
            if IsValid(panel) then
                ASC.ComprehensiveTheme.ApplyThemeToSpecificPanel(panel, panelType)
            end
        end)

        -- Call hook for other systems
        hook.Call("ASC_PanelCreated", GAMEMODE, panel, panelType)
    end

    return panel
end

-- Helper function to create themed frames
function ASC.ComprehensiveTheme.CreateThemedFrame(title, width, height)
    local frame = ASC.ComprehensiveTheme.CreateThemedPanel("DFrame")

    if IsValid(frame) then
        frame:SetTitle(title or "Advanced Space Combat")
        frame:SetSize(width or 400, height or 300)
        frame:Center()
        frame:SetDraggable(true)
        frame:SetDeleteOnClose(true)
    end

    return frame
end

-- Helper function to create themed buttons
function ASC.ComprehensiveTheme.CreateThemedButton(text, parent)
    local button = ASC.ComprehensiveTheme.CreateThemedPanel("DButton", parent)

    if IsValid(button) then
        button:SetText(text or "Button")
    end

    return button
end

print("[Advanced Space Combat] Comprehensive Theme System loaded successfully!")
