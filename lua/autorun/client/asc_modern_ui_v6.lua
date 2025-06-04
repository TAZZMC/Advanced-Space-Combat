-- Advanced Space Combat - Modern UI System v6.0.0
-- Next-generation UI with dark mode, accessibility, and modern design principles
-- Based on 2025 UI/UX research and best practices

print("[Advanced Space Combat] Modern UI System v6.0.0 - Next-Generation Interface Loading...")

-- Initialize UI namespace
ASC = ASC or {}
ASC.UI = ASC.UI or {}

-- Modern UI configuration based on 2025 design trends
ASC.UI.Config = {
    -- Theme system
    Theme = {
        Current = "DarkSpace", -- Default to dark mode
        Available = {
            "DarkSpace",
            "LightSpace", 
            "HighContrast",
            "Accessibility"
        }
    },
    
    -- Modern color palette (research-based)
    Colors = {
        DarkSpace = {
            Primary = Color(18, 24, 38, 255),      -- Deep space blue
            Secondary = Color(25, 35, 55, 255),    -- Lighter space blue
            Accent = Color(64, 156, 255, 255),     -- Bright blue accent
            Success = Color(46, 204, 113, 255),    -- Modern green
            Warning = Color(241, 196, 15, 255),    -- Amber warning
            Error = Color(231, 76, 60, 255),       -- Modern red
            Text = Color(255, 255, 255, 255),      -- Pure white text
            TextSecondary = Color(189, 195, 199, 255), -- Light gray
            TextMuted = Color(127, 140, 141, 255), -- Muted gray
            Border = Color(52, 73, 94, 255),       -- Subtle border
            Surface = Color(44, 62, 80, 255),      -- Card surface
            Background = Color(13, 17, 23, 240),   -- Main background
            Overlay = Color(0, 0, 0, 180),         -- Modal overlay
            Glow = Color(64, 156, 255, 100),       -- Accent glow
            Gradient1 = Color(41, 128, 185, 255),  -- Gradient start
            Gradient2 = Color(142, 68, 173, 255)   -- Gradient end
        },
        
        LightSpace = {
            Primary = Color(236, 240, 241, 255),
            Secondary = Color(255, 255, 255, 255),
            Accent = Color(52, 152, 219, 255),
            Success = Color(39, 174, 96, 255),
            Warning = Color(243, 156, 18, 255),
            Error = Color(192, 57, 43, 255),
            Text = Color(44, 62, 80, 255),
            TextSecondary = Color(127, 140, 141, 255),
            TextMuted = Color(149, 165, 166, 255),
            Border = Color(189, 195, 199, 255),
            Surface = Color(255, 255, 255, 255),
            Background = Color(248, 249, 250, 240),
            Overlay = Color(255, 255, 255, 180),
            Glow = Color(52, 152, 219, 100),
            Gradient1 = Color(74, 144, 226, 255),
            Gradient2 = Color(180, 101, 218, 255)
        },

        HighContrast = {
            Primary = Color(0, 0, 0, 255),
            Secondary = Color(255, 255, 255, 255),
            Accent = Color(255, 255, 0, 255),
            Success = Color(0, 255, 0, 255),
            Warning = Color(255, 165, 0, 255),
            Error = Color(255, 0, 0, 255),
            Text = Color(255, 255, 255, 255),
            TextSecondary = Color(200, 200, 200, 255),
            TextMuted = Color(150, 150, 150, 255),
            Border = Color(255, 255, 255, 255),
            Surface = Color(0, 0, 0, 255),
            Background = Color(0, 0, 0, 255),
            Overlay = Color(0, 0, 0, 200),
            Glow = Color(255, 255, 0, 150),
            Gradient1 = Color(255, 255, 255, 255),
            Gradient2 = Color(0, 0, 0, 255)
        },

        Accessibility = {
            Primary = Color(0, 0, 0, 255),
            Secondary = Color(255, 255, 255, 255),
            Accent = Color(0, 100, 255, 255),
            Success = Color(0, 150, 0, 255),
            Warning = Color(200, 150, 0, 255),
            Error = Color(200, 0, 0, 255),
            Text = Color(255, 255, 255, 255),
            TextSecondary = Color(220, 220, 220, 255),
            TextMuted = Color(180, 180, 180, 255),
            Border = Color(255, 255, 255, 255),
            Surface = Color(20, 20, 20, 255),
            Background = Color(0, 0, 0, 255),
            Overlay = Color(0, 0, 0, 220),
            Glow = Color(0, 100, 255, 120),
            Gradient1 = Color(255, 255, 255, 255),
            Gradient2 = Color(50, 50, 50, 255)
        }
    },
    
    -- Modern typography (research-based font stack)
    Fonts = {
        Display = "ASC_Display",      -- Large headings
        Heading = "ASC_Heading",      -- Section headings
        Body = "ASC_Body",            -- Body text
        Caption = "ASC_Caption",      -- Small text
        Code = "ASC_Code",            -- Monospace code
        UI = "ASC_UI"                 -- UI elements
    },
    
    -- Modern spacing system (8px grid)
    Spacing = {
        XS = 4,   -- 0.25rem
        SM = 8,   -- 0.5rem
        MD = 16,  -- 1rem
        LG = 24,  -- 1.5rem
        XL = 32,  -- 2rem
        XXL = 48  -- 3rem
    },
    
    -- Modern border radius
    BorderRadius = {
        SM = 4,
        MD = 8,
        LG = 12,
        XL = 16,
        Round = 50
    },
    
    -- Animation settings
    Animation = {
        Duration = {
            Fast = 0.15,
            Normal = 0.25,
            Slow = 0.35
        },
        Easing = "ease-out"
    },
    
    -- Accessibility settings
    Accessibility = {
        HighContrast = false,
        ReducedMotion = false,
        LargeText = false,
        ScreenReader = false,
        FocusIndicators = true
    }
}

-- State management
ASC.UI.State = {
    CurrentTheme = "DarkSpace",
    AnimationsEnabled = true,
    AccessibilityMode = false,
    ResponsiveBreakpoint = "desktop"
}

-- Create modern font system
function ASC.UI.CreateFonts()
    local fonts = {
        -- Modern font stack with fallbacks
        primary = {"Inter", "SF Pro Display", "Segoe UI", "Roboto", "Arial"},
        monospace = {"JetBrains Mono", "Fira Code", "Consolas", "Monaco", "Courier New"}
    }
    
    -- Display font (48px)
    surface.CreateFont("ASC_Display", {
        font = fonts.primary[1],
        size = 48,
        weight = 700,
        antialias = true,
        shadow = false,
        outline = false
    })
    
    -- Heading font (32px)
    surface.CreateFont("ASC_Heading", {
        font = fonts.primary[1],
        size = 32,
        weight = 600,
        antialias = true,
        shadow = false,
        outline = false
    })
    
    -- Body font (16px)
    surface.CreateFont("ASC_Body", {
        font = fonts.primary[1],
        size = 16,
        weight = 400,
        antialias = true,
        shadow = false,
        outline = false
    })
    
    -- Caption font (14px)
    surface.CreateFont("ASC_Caption", {
        font = fonts.primary[1],
        size = 14,
        weight = 400,
        antialias = true,
        shadow = false,
        outline = false
    })
    
    -- Code font (14px)
    surface.CreateFont("ASC_Code", {
        font = fonts.monospace[1],
        size = 14,
        weight = 400,
        antialias = true,
        shadow = false,
        outline = false
    })
    
    -- UI font (16px)
    surface.CreateFont("ASC_UI", {
        font = fonts.primary[1],
        size = 16,
        weight = 500,
        antialias = true,
        shadow = false,
        outline = false
    })
    
    print("[ASC UI] Modern font system created")
end

-- Get current theme colors
function ASC.UI.GetColors()
    -- Ensure Config and Colors exist
    if not ASC.UI.Config or not ASC.UI.Config.Colors then
        return {
            Primary = Color(18, 24, 38, 255),
            Secondary = Color(25, 35, 55, 255),
            Accent = Color(64, 156, 255, 255),
            Text = Color(255, 255, 255, 255),
            TextSecondary = Color(189, 195, 199, 255),
            Border = Color(52, 73, 94, 255),
            Surface = Color(44, 62, 80, 255),
            Background = Color(13, 17, 23, 240)
        }
    end

    local currentTheme = ASC.UI.State and ASC.UI.State.CurrentTheme or "DarkSpace"
    return ASC.UI.Config.Colors[currentTheme] or ASC.UI.Config.Colors.DarkSpace
end

-- Modern button component
function ASC.UI.CreateButton(parent, text, onClick)
    local colors = ASC.UI.GetColors()
    local spacing = ASC.UI.Config.Spacing
    
    local button = vgui.Create("DButton", parent)
    button:SetText("")
    button.Text = text
    button.OnClick = onClick or function() end
    
    -- Modern button styling
    button.Paint = function(self, w, h)
        local bgColor = colors.Accent
        local textColor = colors.Text
        
        -- Hover state
        if self:IsHovered() then
            bgColor = Color(
                math.min(255, bgColor.r + 20),
                math.min(255, bgColor.g + 20),
                math.min(255, bgColor.b + 20),
                bgColor.a
            )
        end
        
        -- Pressed state
        if self:IsDown() then
            bgColor = Color(
                math.max(0, bgColor.r - 20),
                math.max(0, bgColor.g - 20),
                math.max(0, bgColor.b - 20),
                bgColor.a
            )
        end
        
        -- Draw button background
        draw.RoundedBox(ASC.UI.Config.BorderRadius.MD, 0, 0, w, h, bgColor)
        
        -- Draw text
        surface.SetFont("ASC_UI")
        local textW, textH = surface.GetTextSize(self.Text)
        surface.SetTextColor(textColor)
        surface.SetTextPos(w/2 - textW/2, h/2 - textH/2)
        surface.DrawText(self.Text)
        
        -- Focus indicator for accessibility
        if ASC.UI.Config.Accessibility.FocusIndicators and self:HasFocus() then
            surface.SetDrawColor(colors.Accent.r, colors.Accent.g, colors.Accent.b, 100)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
        end
    end
    
    button.DoClick = function(self)
        self.OnClick()
    end
    
    return button
end

-- Modern card component
function ASC.UI.CreateCard(parent, title, content)
    local colors = ASC.UI.GetColors()
    local spacing = ASC.UI.Config.Spacing
    
    local card = vgui.Create("DPanel", parent)
    card.Title = title
    card.Content = content
    
    card.Paint = function(self, w, h)
        -- Card background
        draw.RoundedBox(ASC.UI.Config.BorderRadius.LG, 0, 0, w, h, colors.Surface)
        
        -- Subtle border
        surface.SetDrawColor(colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        -- Title
        if self.Title then
            surface.SetFont("ASC_Heading")
            surface.SetTextColor(colors.Text)
            surface.SetTextPos(spacing.MD, spacing.MD)
            surface.DrawText(self.Title)
        end
        
        -- Content
        if self.Content then
            surface.SetFont("ASC_Body")
            surface.SetTextColor(colors.TextSecondary)
            surface.SetTextPos(spacing.MD, spacing.MD + 40)
            surface.DrawText(self.Content)
        end
    end
    
    return card
end

-- Modern gradient background
function ASC.UI.DrawGradientBackground(x, y, w, h, color1, color2, vertical)
    vertical = vertical or false
    
    local steps = 32
    for i = 0, steps do
        local alpha = i / steps
        local r = Lerp(alpha, color1.r, color2.r)
        local g = Lerp(alpha, color1.g, color2.g)
        local b = Lerp(alpha, color1.b, color2.b)
        local a = Lerp(alpha, color1.a, color2.a)
        
        surface.SetDrawColor(r, g, b, a)
        
        if vertical then
            surface.DrawRect(x, y + (i * h / steps), w, h / steps + 1)
        else
            surface.DrawRect(x + (i * w / steps), y, w / steps + 1, h)
        end
    end
end

-- Theme switching
function ASC.UI.SetTheme(themeName)
    -- Ensure Config and Colors exist
    if not ASC.UI.Config or not ASC.UI.Config.Colors then
        print("[ASC UI] Warning: Config not ready, deferring theme change")
        return false
    end

    if ASC.UI.Config.Colors[themeName] then
        ASC.UI.State.CurrentTheme = themeName
        print("[ASC UI] Theme changed to: " .. themeName)

        -- Fire theme change event
        if ASC.Events then
            ASC.Events.Fire("ThemeChanged", themeName)
        end
        return true
    else
        print("[ASC UI] Warning: Theme '" .. themeName .. "' not found")
        return false
    end
end

-- Accessibility support
function ASC.UI.SetAccessibilityMode(enabled)
    -- Ensure Config exists
    if not ASC.UI.Config or not ASC.UI.Config.Accessibility then
        print("[ASC UI] Warning: Config not ready for accessibility mode")
        return
    end

    ASC.UI.State.AccessibilityMode = enabled
    ASC.UI.Config.Accessibility.HighContrast = enabled
    ASC.UI.Config.Accessibility.LargeText = enabled
    ASC.UI.Config.Accessibility.FocusIndicators = enabled

    if enabled then
        ASC.UI.SetTheme("HighContrast")
    end

    print("[ASC UI] Accessibility mode: " .. (enabled and "enabled" or "disabled"))
end

-- Initialize modern UI system
function ASC.UI.Initialize()
    print("[ASC UI] Initializing modern UI system...")

    -- Ensure State exists
    if not ASC.UI.State then
        ASC.UI.State = {
            CurrentTheme = "DarkSpace",
            AnimationsEnabled = true,
            AccessibilityMode = false,
            ResponsiveBreakpoint = "desktop"
        }
    end

    -- Create fonts
    ASC.UI.CreateFonts()

    -- Set default theme (with retry if config not ready)
    if not ASC.UI.SetTheme("DarkSpace") then
        -- Fallback: set theme directly
        ASC.UI.State.CurrentTheme = "DarkSpace"
        print("[ASC UI] Used fallback theme setting")
    end

    print("[ASC UI] Modern UI system initialized with " .. (ASC.UI.State.CurrentTheme or "DarkSpace") .. " theme")
end

-- Console commands for UI management
concommand.Add("asc_ui_theme", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    if #args == 0 then
        ply:ChatPrint("[ASC UI] Available themes: " .. table.concat(ASC.UI.Config.Theme.Available, ", "))
        ply:ChatPrint("[ASC UI] Current theme: " .. ASC.UI.State.CurrentTheme)
        return
    end
    
    local theme = args[1]
    if table.HasValue(ASC.UI.Config.Theme.Available, theme) then
        ASC.UI.SetTheme(theme)
        ply:ChatPrint("[ASC UI] Theme changed to: " .. theme)
    else
        ply:ChatPrint("[ASC UI] Invalid theme. Available: " .. table.concat(ASC.UI.Config.Theme.Available, ", "))
    end
end, nil, "Change UI theme")

concommand.Add("asc_ui_accessibility", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local enabled = #args > 0 and args[1] == "1"
    ASC.UI.SetAccessibilityMode(enabled)
    ply:ChatPrint("[ASC UI] Accessibility mode: " .. (enabled and "enabled" or "disabled"))
end, nil, "Toggle accessibility mode")

-- Initialize immediately on client load (high priority)
hook.Add("Initialize", "ASC_UI_Initialize_Early", function()
    ASC.UI.Initialize()
end)

-- Backup initialization for safety
hook.Add("InitPostEntity", "ASC_UI_Initialize", function()
    timer.Simple(0.1, function()
        if not ASC.UI.State or not ASC.UI.State.CurrentTheme then
            ASC.UI.Initialize()
        end
    end)
end)

print("[Advanced Space Combat] Modern UI System v6.0.0 - Next-Generation Interface Loaded Successfully!")
