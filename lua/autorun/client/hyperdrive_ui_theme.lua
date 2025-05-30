-- Enhanced Hyperdrive System - Modern UI Theme System
-- Provides consistent theming across all UI components

if SERVER then return end

-- Modern UI Theme Configuration
HYPERDRIVE.UI = HYPERDRIVE.UI or {}
HYPERDRIVE.UI.Theme = {
    -- Color Palette
    Colors = {
        -- Primary Colors
        Primary = Color(25, 35, 55, 240),
        Secondary = Color(45, 65, 95, 220),
        Tertiary = Color(65, 85, 115, 200),
        
        -- Accent Colors
        Accent = Color(100, 150, 255, 255),
        AccentHover = Color(120, 170, 255, 255),
        AccentActive = Color(80, 130, 235, 255),
        
        -- Status Colors
        Success = Color(100, 200, 100, 255),
        Warning = Color(255, 200, 100, 255),
        Error = Color(255, 120, 120, 255),
        Info = Color(100, 180, 255, 255),
        
        -- Text Colors
        Text = Color(255, 255, 255, 255),
        TextSecondary = Color(200, 200, 200, 200),
        TextMuted = Color(150, 150, 150, 150),
        TextDisabled = Color(100, 100, 100, 100),
        
        -- Background Colors
        Background = Color(20, 30, 50, 240),
        BackgroundSecondary = Color(30, 40, 60, 220),
        BackgroundTertiary = Color(40, 50, 70, 200),
        
        -- Border Colors
        Border = Color(80, 120, 180, 150),
        BorderHover = Color(100, 140, 200, 200),
        BorderActive = Color(120, 160, 220, 255),
        
        -- Special Effects
        Glow = Color(255, 255, 255, 50),
        Shadow = Color(0, 0, 0, 150),
        Overlay = Color(0, 0, 0, 100)
    },
    
    -- Typography
    Fonts = {
        Title = "DermaLarge",
        Subtitle = "DermaDefaultBold",
        Body = "DermaDefault",
        Small = "DermaDefault",
        Tiny = "DermaDefault"
    },
    
    -- Spacing and Sizing
    Spacing = {
        Tiny = 4,
        Small = 8,
        Medium = 16,
        Large = 24,
        XLarge = 32
    },
    
    -- Border Radius
    BorderRadius = {
        Small = 4,
        Medium = 8,
        Large = 12,
        XLarge = 16
    },
    
    -- Animation Settings
    Animation = {
        Duration = {
            Fast = 0.15,
            Medium = 0.3,
            Slow = 0.5
        },
        Easing = {
            Linear = function(t) return t end,
            EaseIn = function(t) return t * t end,
            EaseOut = function(t) return 1 - (1 - t) * (1 - t) end,
            EaseInOut = function(t) return t < 0.5 and 2 * t * t or 1 - 2 * (1 - t) * (1 - t) end
        }
    }
}

-- Theme Helper Functions
HYPERDRIVE.UI.GetColor = function(colorName, alpha)
    local color = HYPERDRIVE.UI.Theme.Colors[colorName]
    if not color then return Color(255, 255, 255, alpha or 255) end
    
    if alpha then
        return Color(color.r, color.g, color.b, alpha)
    end
    return Color(color.r, color.g, color.b, color.a)
end

HYPERDRIVE.UI.GetFont = function(fontName)
    return HYPERDRIVE.UI.Theme.Fonts[fontName] or "DermaDefault"
end

HYPERDRIVE.UI.GetSpacing = function(spacingName)
    return HYPERDRIVE.UI.Theme.Spacing[spacingName] or 8
end

HYPERDRIVE.UI.GetBorderRadius = function(radiusName)
    return HYPERDRIVE.UI.Theme.BorderRadius[radiusName] or 8
end

-- Modern Drawing Functions
HYPERDRIVE.UI.DrawModernPanel = function(x, y, w, h, colorName, borderRadius)
    colorName = colorName or "Primary"
    borderRadius = borderRadius or HYPERDRIVE.UI.GetBorderRadius("Medium")
    
    local color = HYPERDRIVE.UI.GetColor(colorName)
    local shadowColor = HYPERDRIVE.UI.GetColor("Shadow")
    local glowColor = HYPERDRIVE.UI.GetColor("Glow")
    
    -- Shadow
    draw.RoundedBox(borderRadius, x - 2, y - 2, w + 4, h + 4, shadowColor)
    
    -- Main panel
    draw.RoundedBox(borderRadius, x, y, w, h, color)
    
    -- Subtle glow
    draw.RoundedBox(borderRadius, x, y, w, 2, glowColor)
end

HYPERDRIVE.UI.DrawModernButton = function(x, y, w, h, text, isHovered, isPressed, colorName)
    colorName = colorName or "Accent"
    local borderRadius = HYPERDRIVE.UI.GetBorderRadius("Small")
    
    local color = HYPERDRIVE.UI.GetColor(colorName)
    if isPressed then
        color = HYPERDRIVE.UI.GetColor(colorName .. "Active")
    elseif isHovered then
        color = HYPERDRIVE.UI.GetColor(colorName .. "Hover")
    end
    
    -- Button background
    draw.RoundedBox(borderRadius, x, y, w, h, color)
    
    -- Hover glow effect
    if isHovered then
        local glowColor = HYPERDRIVE.UI.GetColor("Glow")
        draw.RoundedBox(borderRadius, x - 1, y - 1, w + 2, h + 2, glowColor)
        draw.RoundedBox(borderRadius, x, y, w, h, color)
    end
    
    -- Button text
    local textColor = HYPERDRIVE.UI.GetColor("Text")
    local font = HYPERDRIVE.UI.GetFont("Body")
    draw.SimpleText(text, font, x + w/2, y + h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

HYPERDRIVE.UI.DrawProgressBar = function(x, y, w, h, value, maxValue, colorName, showText)
    colorName = colorName or "Accent"
    showText = showText ~= false
    
    local percentage = math.Clamp(value / maxValue, 0, 1)
    local borderRadius = h / 2
    
    -- Background
    local bgColor = HYPERDRIVE.UI.GetColor("BackgroundTertiary")
    draw.RoundedBox(borderRadius, x, y, w, h, bgColor)
    
    -- Fill
    if percentage > 0 then
        local fillColor = HYPERDRIVE.UI.GetColor(colorName)
        local fillW = (w - 2) * percentage
        draw.RoundedBox(borderRadius - 1, x + 1, y + 1, fillW, h - 2, fillColor)
    end
    
    -- Text
    if showText then
        local percentText = math.floor(percentage * 100) .. "%"
        local textColor = HYPERDRIVE.UI.GetColor("Text")
        local font = HYPERDRIVE.UI.GetFont("Small")
        draw.SimpleText(percentText, font, x + w/2, y + h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

HYPERDRIVE.UI.DrawModernTab = function(x, y, w, h, text, icon, isActive, isHovered, colorName)
    colorName = colorName or "Secondary"
    local borderRadius = HYPERDRIVE.UI.GetBorderRadius("Small")
    
    local color = HYPERDRIVE.UI.GetColor(colorName)
    local textColor = HYPERDRIVE.UI.GetColor("TextSecondary")
    local borderColor = HYPERDRIVE.UI.GetColor("Border")
    
    if isActive then
        color = HYPERDRIVE.UI.GetColor("Accent")
        textColor = HYPERDRIVE.UI.GetColor("Text")
        borderColor = HYPERDRIVE.UI.GetColor("BorderActive")
    elseif isHovered then
        color = HYPERDRIVE.UI.GetColor("BackgroundSecondary")
        textColor = HYPERDRIVE.UI.GetColor("Text")
        borderColor = HYPERDRIVE.UI.GetColor("BorderHover")
    end
    
    -- Tab background
    draw.RoundedBoxEx(borderRadius, x, y, w, h, color, true, true, not isActive, not isActive)
    
    -- Border
    draw.RoundedBoxEx(borderRadius, x, y, w, 2, borderColor, true, true, false, false)
    if not isActive then
        draw.RoundedBoxEx(borderRadius, x, y + h - 2, w, 2, borderColor, false, false, true, true)
    end
    
    -- Icon and text
    local font = HYPERDRIVE.UI.GetFont("Body")
    if icon then
        draw.SimpleText(icon, font, x + 15, y + h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(text, font, x + 35, y + h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    else
        draw.SimpleText(text, font, x + w/2, y + h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

HYPERDRIVE.UI.DrawNotification = function(x, y, w, h, text, type, alpha)
    type = type or "info"
    alpha = alpha or 255
    
    local borderRadius = HYPERDRIVE.UI.GetBorderRadius("Small")
    
    -- Background color based on type
    local bgColor = HYPERDRIVE.UI.GetColor("BackgroundSecondary", alpha * 0.9)
    local borderColor = HYPERDRIVE.UI.GetColor("Border", alpha)
    local textColor = HYPERDRIVE.UI.GetColor("Text", alpha)
    
    if type == "error" then
        bgColor = Color(120, 40, 40, alpha * 0.9)
        borderColor = HYPERDRIVE.UI.GetColor("Error", alpha)
    elseif type == "warning" then
        bgColor = Color(120, 80, 40, alpha * 0.9)
        borderColor = HYPERDRIVE.UI.GetColor("Warning", alpha)
    elseif type == "success" then
        bgColor = Color(40, 120, 40, alpha * 0.9)
        borderColor = HYPERDRIVE.UI.GetColor("Success", alpha)
    end
    
    -- Draw notification
    draw.RoundedBox(borderRadius, x, y, w, h, bgColor)
    draw.RoundedBox(borderRadius, x, y, 4, h, borderColor)
    
    -- Icon
    local icon = "ℹ️"
    if type == "error" then icon = "❌"
    elseif type == "warning" then icon = "⚠️"
    elseif type == "success" then icon = "✅"
    end
    
    local font = HYPERDRIVE.UI.GetFont("Body")
    draw.SimpleText(icon, font, x + 15, y + h/2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(text, font, x + 35, y + h/2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

-- Animation System
HYPERDRIVE.UI.Animations = {}

HYPERDRIVE.UI.CreateAnimation = function(id, startValue, endValue, duration, easing)
    easing = easing or HYPERDRIVE.UI.Theme.Animation.Easing.EaseInOut
    
    HYPERDRIVE.UI.Animations[id] = {
        startValue = startValue,
        endValue = endValue,
        duration = duration,
        easing = easing,
        startTime = CurTime(),
        currentValue = startValue
    }
end

HYPERDRIVE.UI.UpdateAnimations = function()
    local currentTime = CurTime()
    
    for id, anim in pairs(HYPERDRIVE.UI.Animations) do
        local elapsed = currentTime - anim.startTime
        local progress = math.Clamp(elapsed / anim.duration, 0, 1)
        
        if progress >= 1 then
            anim.currentValue = anim.endValue
            HYPERDRIVE.UI.Animations[id] = nil
        else
            local easedProgress = anim.easing(progress)
            anim.currentValue = anim.startValue + (anim.endValue - anim.startValue) * easedProgress
        end
    end
end

HYPERDRIVE.UI.GetAnimationValue = function(id)
    local anim = HYPERDRIVE.UI.Animations[id]
    return anim and anim.currentValue or 0
end

-- Hook to update animations
hook.Add("Think", "HyperdriveUIAnimations", function()
    HYPERDRIVE.UI.UpdateAnimations()
end)

-- Console commands for theme testing
concommand.Add("hyperdrive_ui_test", function()
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:SetTitle("Hyperdrive UI Theme Test")
    frame:Center()
    frame:MakePopup()
    
    frame.Paint = function(self, w, h)
        HYPERDRIVE.UI.DrawModernPanel(0, 0, w, h, "Primary")
    end
    
    local button = vgui.Create("DButton", frame)
    button:SetPos(50, 50)
    button:SetSize(100, 30)
    button:SetText("Test Button")
    
    button.Paint = function(self, w, h)
        local isHovered = self:IsHovered()
        local isPressed = self:IsDown()
        HYPERDRIVE.UI.DrawModernButton(0, 0, w, h, self:GetText(), isHovered, isPressed, "Accent")
        return true
    end
end)

print("[Hyperdrive] Modern UI theme system loaded")
