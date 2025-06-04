-- Advanced Space Combat - Modern UI System v1.0.0
-- Based on modern UI/UX design principles and research

print("[Advanced Space Combat] Modern UI System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.ModernUI = ASC.ModernUI or {}

-- Modern UI configuration based on research
ASC.ModernUI.Config = {
    -- Design system
    DesignSystem = {
        -- Color palette (Material Design inspired)
        Colors = {
            Primary = Color(33, 150, 243, 255),      -- Blue 500
            PrimaryDark = Color(25, 118, 210, 255),  -- Blue 600
            PrimaryLight = Color(100, 181, 246, 255), -- Blue 300
            Secondary = Color(255, 193, 7, 255),      -- Amber 500
            Surface = Color(18, 18, 18, 240),         -- Dark surface
            Background = Color(12, 12, 12, 250),      -- Dark background
            OnSurface = Color(255, 255, 255, 255),    -- White text
            OnBackground = Color(255, 255, 255, 255), -- White text
            Error = Color(244, 67, 54, 255),          -- Red 500
            Success = Color(76, 175, 80, 255),        -- Green 500
            Warning = Color(255, 152, 0, 255),        -- Orange 500
            Info = Color(33, 150, 243, 255),          -- Blue 500
            
            -- Glassmorphism
            Glass = Color(255, 255, 255, 20),
            GlassBorder = Color(255, 255, 255, 40),
            
            -- Shadows
            Shadow = Color(0, 0, 0, 100),
            ShadowStrong = Color(0, 0, 0, 150)
        },
        
        -- Typography scale
        Typography = {
            H1 = {font = "ASC_Logo", size = 48, weight = 900},
            H2 = {font = "ASC_Title", size = 32, weight = 800},
            H3 = {font = "ASC_Subtitle", size = 24, weight = 700},
            H4 = {font = "ASC_Body", size = 20, weight = 600},
            Body1 = {font = "ASC_Body", size = 16, weight = 500},
            Body2 = {font = "ASC_Small", size = 14, weight = 400},
            Caption = {font = "ASC_Small", size = 12, weight = 400},
            Button = {font = "ASC_Button", size = 16, weight = 600}
        },
        
        -- Spacing system (8px grid)
        Spacing = {
            XS = 4,   -- 0.5 units
            S = 8,    -- 1 unit
            M = 16,   -- 2 units
            L = 24,   -- 3 units
            XL = 32,  -- 4 units
            XXL = 48, -- 6 units
            XXXL = 64 -- 8 units
        },
        
        -- Border radius scale
        BorderRadius = {
            None = 0,
            Small = 4,
            Medium = 8,
            Large = 12,
            XLarge = 16,
            Round = 50
        },
        
        -- Elevation system
        Elevation = {
            Level0 = 0,
            Level1 = 2,
            Level2 = 4,
            Level3 = 8,
            Level4 = 12,
            Level5 = 16
        }
    },
    
    -- Animation settings
    Animations = {
        Duration = {
            Fast = 0.15,
            Normal = 0.25,
            Slow = 0.35
        },
        Easing = {
            Standard = "ease-out",
            Decelerate = "ease-out",
            Accelerate = "ease-in"
        }
    },
    
    -- Accessibility
    Accessibility = {
        HighContrast = false,
        ReducedMotion = false,
        LargeText = false,
        FocusIndicators = true
    }
}

-- Modern component system
ASC.ModernUI.Components = {}

-- Create modern button component
function ASC.ModernUI.Components.CreateButton(parent, config)
    config = config or {}
    
    local button = vgui.Create("DButton", parent)
    button:SetSize(config.width or 120, config.height or 40)
    button:SetText("")
    
    -- Button state
    local state = {
        hovered = false,
        pressed = false,
        disabled = config.disabled or false,
        variant = config.variant or "primary" -- primary, secondary, outlined, text
    }
    
    -- Modern button paint function
    button.Paint = function(self, w, h)
        local colors = ASC.ModernUI.Config.DesignSystem.Colors
        local spacing = ASC.ModernUI.Config.DesignSystem.Spacing
        
        -- Determine colors based on variant and state
        local bgColor, textColor, borderColor
        
        if state.variant == "primary" then
            bgColor = state.hovered and colors.PrimaryDark or colors.Primary
            textColor = colors.OnSurface
        elseif state.variant == "secondary" then
            bgColor = state.hovered and colors.Secondary or Color(colors.Secondary.r, colors.Secondary.g, colors.Secondary.b, 200)
            textColor = colors.OnSurface
        elseif state.variant == "outlined" then
            bgColor = state.hovered and Color(colors.Primary.r, colors.Primary.g, colors.Primary.b, 40) or Color(0, 0, 0, 0)
            textColor = colors.Primary
            borderColor = colors.Primary
        else -- text variant
            bgColor = state.hovered and Color(colors.Primary.r, colors.Primary.g, colors.Primary.b, 20) or Color(0, 0, 0, 0)
            textColor = colors.Primary
        end
        
        -- Apply disabled state
        if state.disabled then
            bgColor = Color(colors.OnSurface.r, colors.OnSurface.g, colors.OnSurface.b, 30)
            textColor = Color(colors.OnSurface.r, colors.OnSurface.g, colors.OnSurface.b, 100)
        end
        
        -- Draw shadow for elevated buttons
        if state.variant == "primary" or state.variant == "secondary" then
            draw.RoundedBox(ASC.ModernUI.Config.DesignSystem.BorderRadius.Medium, 2, 2, w, h, colors.Shadow)
        end
        
        -- Draw background
        draw.RoundedBox(ASC.ModernUI.Config.DesignSystem.BorderRadius.Medium, 0, 0, w, h, bgColor)
        
        -- Draw border for outlined variant (2px thick)
        if borderColor then
            surface.SetDrawColor(borderColor)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
        end
        
        -- Draw text
        if config.text then
            local font = ASC.ModernUI.Config.DesignSystem.Typography.Button.font
            surface.SetFont(font)
            local textW, textH = surface.GetTextSize(config.text)
            
            surface.SetTextColor(textColor)
            surface.SetTextPos(w/2 - textW/2, h/2 - textH/2)
            surface.DrawText(config.text)
        end
        
        -- Draw focus indicator (3px thick)
        if ASC.ModernUI.Config.Accessibility.FocusIndicators and self:HasFocus() then
            surface.SetDrawColor(colors.Primary)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
            surface.DrawOutlinedRect(2, 2, w - 4, h - 4)
        end
    end
    
    -- Handle hover state
    button.OnCursorEntered = function(self)
        state.hovered = true
    end
    
    button.OnCursorExited = function(self)
        state.hovered = false
    end
    
    -- Store state for external access
    button.ModernUIState = state
    
    return button
end

-- Create modern card component
function ASC.ModernUI.Components.CreateCard(parent, config)
    config = config or {}
    
    local card = vgui.Create("DPanel", parent)
    card:SetSize(config.width or 300, config.height or 200)
    
    -- Card paint function with glassmorphism
    card.Paint = function(self, w, h)
        local colors = ASC.ModernUI.Config.DesignSystem.Colors
        local radius = ASC.ModernUI.Config.DesignSystem.BorderRadius.Large
        
        -- Draw shadow
        draw.RoundedBox(radius, 4, 4, w, h, colors.ShadowStrong)
        
        -- Draw glassmorphism background
        draw.RoundedBox(radius, 0, 0, w, h, colors.Surface)
        draw.RoundedBox(radius, 0, 0, w, h, colors.Glass)
        
        -- Draw border
        surface.SetDrawColor(colors.GlassBorder)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    return card
end

-- Create modern input field
function ASC.ModernUI.Components.CreateInput(parent, config)
    config = config or {}
    
    local input = vgui.Create("DTextEntry", parent)
    input:SetSize(config.width or 200, config.height or 40)
    
    -- Input state
    local state = {
        focused = false,
        hasError = config.error or false
    }
    
    -- Modern input paint function
    input.Paint = function(self, w, h)
        local colors = ASC.ModernUI.Config.DesignSystem.Colors
        local radius = ASC.ModernUI.Config.DesignSystem.BorderRadius.Medium
        
        -- Determine colors based on state
        local bgColor = colors.Surface
        local borderColor = state.hasError and colors.Error or (state.focused and colors.Primary or colors.GlassBorder)
        
        -- Draw background
        draw.RoundedBox(radius, 0, 0, w, h, bgColor)
        
        -- Draw border (variable thickness based on focus)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h)
        if state.focused then
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
        end
        
        -- Draw text
        self:DrawTextEntryText(colors.OnSurface, colors.Primary, colors.OnSurface)
    end
    
    -- Handle focus state
    input.OnGetFocus = function(self)
        state.focused = true
    end
    
    input.OnLoseFocus = function(self)
        state.focused = false
    end
    
    -- Store state for external access
    input.ModernUIState = state
    
    return input
end

-- Apply modern theme to existing VGUI elements
function ASC.ModernUI.ApplyModernTheme(panel)
    if not IsValid(panel) then return end
    
    -- Mark as modern themed
    panel.ModernUIThemed = true
    
    -- Apply based on panel type
    local panelType = panel:GetName() or panel.ClassName or "Unknown"
    
    if panelType:find("Frame") then
        ASC.ModernUI.ApplyFrameTheme(panel)
    elseif panelType:find("Button") then
        ASC.ModernUI.ApplyButtonTheme(panel)
    elseif panelType:find("TextEntry") then
        ASC.ModernUI.ApplyInputTheme(panel)
    end
    
    -- Apply to children
    for _, child in ipairs(panel:GetChildren()) do
        ASC.ModernUI.ApplyModernTheme(child)
    end
end

-- Apply modern frame theme
function ASC.ModernUI.ApplyFrameTheme(frame)
    frame.Paint = function(self, w, h)
        local colors = ASC.ModernUI.Config.DesignSystem.Colors
        local radius = ASC.ModernUI.Config.DesignSystem.BorderRadius.Large
        
        -- Draw shadow
        draw.RoundedBox(radius, 6, 6, w, h, colors.ShadowStrong)
        
        -- Draw glassmorphism background
        draw.RoundedBox(radius, 0, 0, w, h, colors.Background)
        draw.RoundedBox(radius, 0, 0, w, h, colors.Glass)
        
        -- Draw border (2px thick)
        surface.SetDrawColor(colors.GlassBorder)
        surface.DrawOutlinedRect(0, 0, w, h)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
    end
end

-- Console command to apply modern theme
concommand.Add("asc_modern_ui_apply", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[Advanced Space Combat] Applying modern UI theme...")
    
    -- Apply to all existing panels
    local panelCount = 0
    for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
        if IsValid(panel) then
            ASC.ModernUI.ApplyModernTheme(panel)
            panelCount = panelCount + 1
        end
    end
    
    ply:ChatPrint("[Advanced Space Combat] Modern UI applied to " .. panelCount .. " panels")
end, nil, "Apply modern UI theme to all panels")

print("[Advanced Space Combat] Modern UI System loaded successfully!")
