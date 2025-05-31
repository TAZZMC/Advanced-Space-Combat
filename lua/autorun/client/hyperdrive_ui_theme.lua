-- Enhanced Hyperdrive System - Modern UI Theme System v2.2.1
-- COMPLETE CODE UPDATE v2.2.1 - ALL SYSTEMS INTEGRATED WITH STEAM WORKSHOP
-- Provides consistent theming across all UI components with Steam Workshop addon support

if SERVER then return end

print("[Hyperdrive UI] COMPLETE CODE UPDATE v2.2.1 - UI Theme System being updated")
print("[Hyperdrive UI] Steam Workshop addon UI compatibility active")

-- Modern UI Theme Configuration
HYPERDRIVE.UI = HYPERDRIVE.UI or {}
HYPERDRIVE.UI.Config = HYPERDRIVE.UI.Config or {}

-- Load configuration from ConVars with error handling
local function LoadUIConfig()
    -- Helper function to safely get ConVar values
    local function SafeGetConVar(name, default, getFunc)
        local convar = GetConVar(name)
        if convar then
            return convar[getFunc](convar)
        end
        return default
    end

    HYPERDRIVE.UI.Config.ModernUIEnabled = SafeGetConVar("hyperdrive_modern_ui_enabled", true, "GetBool")
    HYPERDRIVE.UI.Config.GlassmorphismEnabled = SafeGetConVar("hyperdrive_ui_glassmorphism", true, "GetBool")
    HYPERDRIVE.UI.Config.AnimationsEnabled = SafeGetConVar("hyperdrive_ui_animations", true, "GetBool")
    HYPERDRIVE.UI.Config.NotificationsEnabled = SafeGetConVar("hyperdrive_ui_notifications", true, "GetBool")
    HYPERDRIVE.UI.Config.SoundsEnabled = SafeGetConVar("hyperdrive_ui_sounds", true, "GetBool")
    HYPERDRIVE.UI.Config.AnimationSpeed = SafeGetConVar("hyperdrive_ui_anim_speed", 1.0, "GetFloat")
    HYPERDRIVE.UI.Config.UIScale = SafeGetConVar("hyperdrive_ui_scale", 1.0, "GetFloat")
    HYPERDRIVE.UI.Config.NotificationDuration = SafeGetConVar("hyperdrive_ui_notif_duration", 5.0, "GetFloat")

    -- New v2.2.0 features
    HYPERDRIVE.UI.Config.RealTimeUpdates = SafeGetConVar("hyperdrive_ui_realtime", true, "GetBool")
    HYPERDRIVE.UI.Config.FleetManagement = SafeGetConVar("hyperdrive_ui_fleet", true, "GetBool")
    HYPERDRIVE.UI.Config.AdminPanel = SafeGetConVar("hyperdrive_ui_admin", true, "GetBool")
    HYPERDRIVE.UI.Config.StargateSequence = SafeGetConVar("hyperdrive_ui_stargate", true, "GetBool")
    HYPERDRIVE.UI.Config.VisualEffects = SafeGetConVar("hyperdrive_ui_effects", true, "GetBool")
    HYPERDRIVE.UI.Config.HoverEffects = SafeGetConVar("hyperdrive_ui_hover", true, "GetBool")
    HYPERDRIVE.UI.Config.ClickEffects = SafeGetConVar("hyperdrive_ui_click", true, "GetBool")
    HYPERDRIVE.UI.Config.ThemeTransitions = SafeGetConVar("hyperdrive_ui_transitions", true, "GetBool")
    HYPERDRIVE.UI.Config.MaxNotifications = SafeGetConVar("hyperdrive_ui_max_notifications", 5, "GetInt")
    HYPERDRIVE.UI.Config.HighContrast = SafeGetConVar("hyperdrive_ui_high_contrast", false, "GetBool")
    HYPERDRIVE.UI.Config.LargeText = SafeGetConVar("hyperdrive_ui_large_text", false, "GetBool")
    HYPERDRIVE.UI.Config.ReducedMotion = SafeGetConVar("hyperdrive_ui_reduced_motion", false, "GetBool")
    HYPERDRIVE.UI.Config.ColorBlindFriendly = SafeGetConVar("hyperdrive_ui_colorblind_friendly", false, "GetBool")
    HYPERDRIVE.UI.Config.ReduceOnLowFPS = SafeGetConVar("hyperdrive_ui_reduce_on_low_fps", true, "GetBool")
    HYPERDRIVE.UI.Config.MinFPS = SafeGetConVar("hyperdrive_ui_min_fps", 30, "GetInt")
end

-- Initialize configuration
LoadUIConfig()

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

        -- New v2.2.0 Colors
        Fleet = Color(100, 255, 150, 255),
        Admin = Color(255, 100, 100, 255),
        Stargate = Color(255, 200, 100, 255),
        RealTime = Color(150, 255, 200, 255),
        Critical = Color(255, 50, 50, 255),
        Emergency = Color(255, 0, 0, 255),

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
    local font = HYPERDRIVE.UI.Theme.Fonts[fontName] or "DermaDefault"

    -- Apply large text mode if enabled
    if HYPERDRIVE.UI.Config.LargeText then
        if fontName == "Title" then return "DermaLarge"
        elseif fontName == "Subtitle" then return "DermaLarge"
        else return "DermaDefaultBold" end
    end

    return font
end

-- Get scaled size based on UI scale setting
HYPERDRIVE.UI.Scale = function(size)
    local scale = HYPERDRIVE.UI.Config.UIScale or 1.0
    return math.floor(size * scale)
end

-- Protect the Scale function from being overwritten
local originalScale = HYPERDRIVE.UI.Scale
timer.Simple(1, function()
    if type(HYPERDRIVE.UI.Scale) ~= "function" then
        print("[Hyperdrive UI] Warning: Scale function was overwritten, restoring...")
        HYPERDRIVE.UI.Scale = originalScale
    end
end)

-- Get animation duration based on settings
HYPERDRIVE.UI.GetAnimationDuration = function(baseDuration)
    if not HYPERDRIVE.UI.Config.AnimationsEnabled or HYPERDRIVE.UI.Config.ReducedMotion then
        return 0
    end

    -- Check FPS-based reduction
    if HYPERDRIVE.UI.Config.ReduceOnLowFPS then
        local fps = 1 / FrameTime()
        if fps < HYPERDRIVE.UI.Config.MinFPS then
            return baseDuration * 0.5 -- Reduce animation duration
        end
    end

    local speed = HYPERDRIVE.UI.Config.AnimationSpeed or 1.0
    return baseDuration / speed
end

-- Apply theme modifications based on accessibility settings
HYPERDRIVE.UI.ApplyAccessibilityTheme = function()
    if HYPERDRIVE.UI.Config.HighContrast then
        -- High contrast modifications
        HYPERDRIVE.UI.Theme.Colors.Primary = Color(0, 0, 0, 255)
        HYPERDRIVE.UI.Theme.Colors.Secondary = Color(40, 40, 40, 255)
        HYPERDRIVE.UI.Theme.Colors.Text = Color(255, 255, 255, 255)
        HYPERDRIVE.UI.Theme.Colors.Accent = Color(255, 255, 0, 255)
    end

    if HYPERDRIVE.UI.Config.ColorBlindFriendly then
        -- Color blind friendly modifications
        HYPERDRIVE.UI.Theme.Colors.Success = Color(0, 150, 255, 255) -- Blue instead of green
        HYPERDRIVE.UI.Theme.Colors.Warning = Color(255, 150, 0, 255) -- Orange
        HYPERDRIVE.UI.Theme.Colors.Error = Color(255, 0, 150, 255) -- Magenta instead of red
    end
end

-- Notification system
HYPERDRIVE.UI.Notifications = HYPERDRIVE.UI.Notifications or {}
HYPERDRIVE.UI.NotificationQueue = HYPERDRIVE.UI.NotificationQueue or {}

-- Show notification with modern UI
HYPERDRIVE.UI.ShowNotification = function(title, message, type, duration)
    if not HYPERDRIVE.UI.Config.NotificationsEnabled then return end

    type = type or "info"
    duration = duration or HYPERDRIVE.UI.Config.NotificationDuration or 5.0

    local notification = {
        title = title,
        message = message,
        type = type,
        duration = duration,
        startTime = CurTime(),
        alpha = 0
    }

    -- Add to queue
    table.insert(HYPERDRIVE.UI.NotificationQueue, notification)

    -- Limit notifications
    local maxNotifs = HYPERDRIVE.UI.Config.MaxNotifications or 5
    while #HYPERDRIVE.UI.NotificationQueue > maxNotifs do
        table.remove(HYPERDRIVE.UI.NotificationQueue, 1)
    end

    -- Play sound if enabled
    if HYPERDRIVE.UI.Config.SoundsEnabled then
        local soundFile = "buttons/button15.wav"
        if type == "success" then soundFile = "buttons/button14.wav"
        elseif type == "warning" then soundFile = "buttons/button10.wav"
        elseif type == "error" then soundFile = "buttons/button11.wav" end

        surface.PlaySound(soundFile)
    end
end

-- Animation system
HYPERDRIVE.UI.AnimatePanel = function(panel, animationType, duration, callback)
    if not IsValid(panel) then return end
    if not HYPERDRIVE.UI.Config.AnimationsEnabled or HYPERDRIVE.UI.Config.ReducedMotion then
        if callback then callback() end
        return
    end

    duration = HYPERDRIVE.UI.GetAnimationDuration(duration or 0.3)
    if duration <= 0 then
        if callback then callback() end
        return
    end

    local startTime = CurTime()
    local startAlpha = panel:GetAlpha()

    if animationType == "fadeIn" then
        panel:SetAlpha(0)
        panel.AnimationThink = function()
            local progress = math.min((CurTime() - startTime) / duration, 1)
            panel:SetAlpha(255 * progress)

            if progress >= 1 then
                panel.AnimationThink = nil
                if callback then callback() end
            end
        end
    elseif animationType == "fadeOut" then
        panel.AnimationThink = function()
            local progress = math.min((CurTime() - startTime) / duration, 1)
            panel:SetAlpha(startAlpha * (1 - progress))

            if progress >= 1 then
                panel.AnimationThink = nil
                if callback then callback() end
            end
        end
    end
end

-- Reload theme system
HYPERDRIVE.UI.ReloadTheme = function()
    LoadUIConfig()
    HYPERDRIVE.UI.ApplyAccessibilityTheme()
    print("[Hyperdrive UI] Theme reloaded with current settings")
end

-- Notification rendering
hook.Add("HUDPaint", "HyperdriveUINotifications", function()
    if not HYPERDRIVE.UI.Config.NotificationsEnabled then return end
    if #HYPERDRIVE.UI.NotificationQueue == 0 then return end

    local currentTime = CurTime()
    local yOffset = HYPERDRIVE.UI.Scale(50)
    local screenW, screenH = ScrW(), ScrH()
    local notifWidth = HYPERDRIVE.UI.Scale(300)
    local notifHeight = HYPERDRIVE.UI.Scale(60)
    local margin = HYPERDRIVE.UI.Scale(10)

    -- Process notifications
    for i = #HYPERDRIVE.UI.NotificationQueue, 1, -1 do
        local notif = HYPERDRIVE.UI.NotificationQueue[i]
        local elapsed = currentTime - notif.startTime

        -- Remove expired notifications
        if elapsed > notif.duration then
            table.remove(HYPERDRIVE.UI.NotificationQueue, i)
            continue
        end

        -- Calculate alpha for fade in/out
        local fadeTime = 0.3
        if elapsed < fadeTime then
            notif.alpha = math.min(255, (elapsed / fadeTime) * 255)
        elseif elapsed > notif.duration - fadeTime then
            local fadeOut = (notif.duration - elapsed) / fadeTime
            notif.alpha = math.max(0, fadeOut * 255)
        else
            notif.alpha = 255
        end

        -- Position
        local x = screenW - notifWidth - margin
        local y = yOffset + (i - 1) * (notifHeight + margin)

        -- Background color based on type
        local bgColor = HYPERDRIVE.UI.GetColor("Primary", notif.alpha * 0.9)
        local accentColor = HYPERDRIVE.UI.GetColor("Accent", notif.alpha)

        if notif.type == "success" then
            accentColor = HYPERDRIVE.UI.GetColor("Success", notif.alpha)
        elseif notif.type == "warning" then
            accentColor = HYPERDRIVE.UI.GetColor("Warning", notif.alpha)
        elseif notif.type == "error" then
            accentColor = HYPERDRIVE.UI.GetColor("Error", notif.alpha)
        end

        -- Draw notification
        if HYPERDRIVE.UI.Config.GlassmorphismEnabled then
            -- Glassmorphism effect
            draw.RoundedBox(8, x, y, notifWidth, notifHeight, bgColor)
            draw.RoundedBox(8, x, y, 4, notifHeight, accentColor)
        else
            -- Simple style
            draw.RoundedBox(4, x, y, notifWidth, notifHeight, bgColor)
            draw.RoundedBox(4, x, y, 4, notifHeight, accentColor)
        end

        -- Text
        local textColor = HYPERDRIVE.UI.GetColor("Text", notif.alpha)
        local titleFont = HYPERDRIVE.UI.GetFont("Subtitle")
        local bodyFont = HYPERDRIVE.UI.GetFont("Body")

        draw.SimpleText(notif.title, titleFont, x + 15, y + 8, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(notif.message, bodyFont, x + 15, y + 28, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end)

-- Console commands for UI system
concommand.Add("hyperdrive_ui_test", function()
    if HYPERDRIVE.UI.ShowNotification then
        HYPERDRIVE.UI.ShowNotification("UI Test", "Modern UI system is working correctly!", "success", 3)
    end
end)

concommand.Add("hyperdrive_ui_reload", function()
    if HYPERDRIVE.UI.ReloadTheme then
        HYPERDRIVE.UI.ReloadTheme()
    end
end)

-- ConVar change callbacks with error handling
local function SafeAddCallback(convarName, callback)
    if ConVarExists(convarName) then
        cvars.AddChangeCallback(convarName, callback)
    else
        -- Retry after a delay if ConVar doesn't exist yet
        timer.Simple(1, function()
            if ConVarExists(convarName) then
                cvars.AddChangeCallback(convarName, callback)
            end
        end)
    end
end

SafeAddCallback("hyperdrive_ui_scale", function(name, old, new)
    if HYPERDRIVE.UI.Config then
        HYPERDRIVE.UI.Config.UIScale = tonumber(new) or 1.0
    end
end)

SafeAddCallback("hyperdrive_ui_animations", function(name, old, new)
    if HYPERDRIVE.UI.Config then
        HYPERDRIVE.UI.Config.AnimationsEnabled = tobool(new)
    end
end)

SafeAddCallback("hyperdrive_ui_notifications", function(name, old, new)
    if HYPERDRIVE.UI.Config then
        HYPERDRIVE.UI.Config.NotificationsEnabled = tobool(new)
    end
end)

SafeAddCallback("hyperdrive_ui_high_contrast", function(name, old, new)
    if HYPERDRIVE.UI.Config then
        HYPERDRIVE.UI.Config.HighContrast = tobool(new)
        if HYPERDRIVE.UI.ApplyAccessibilityTheme then
            HYPERDRIVE.UI.ApplyAccessibilityTheme()
        end
    end
end)

SafeAddCallback("hyperdrive_ui_colorblind_friendly", function(name, old, new)
    if HYPERDRIVE.UI.Config then
        HYPERDRIVE.UI.Config.ColorBlindFriendly = tobool(new)
        if HYPERDRIVE.UI.ApplyAccessibilityTheme then
            HYPERDRIVE.UI.ApplyAccessibilityTheme()
        end
    end
end)

-- Initialize theme
HYPERDRIVE.UI.ApplyAccessibilityTheme()

print("[Hyperdrive UI] Modern UI theme system loaded with configuration integration")

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

-- Enhanced UI functions for v2.2.0 features
function HYPERDRIVE.UI.DrawFleetPanel(x, y, w, h, fleetData)
    local contentX, contentY, contentW, contentH = HYPERDRIVE.UI.DrawModernPanel(x, y, w, h, "Fleet Management", nil)

    if not fleetData then
        draw.SimpleText("No fleet data available", HYPERDRIVE.UI.GetFont("Body"),
            contentX + contentW/2, contentY + contentH/2, HYPERDRIVE.UI.GetColor("TextSecondary"),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    local yPos = contentY

    -- Fleet name and status
    draw.SimpleText(fleetData.name or "Unknown Fleet", HYPERDRIVE.UI.GetFont("Title"),
        contentX + contentW/2, yPos, HYPERDRIVE.UI.GetColor("Fleet"), TEXT_ALIGN_CENTER)
    yPos = yPos + 25

    -- Fleet statistics
    local shipCount = fleetData.shipCount or 0
    local formation = fleetData.formation or "none"
    local status = fleetData.status or "idle"

    draw.SimpleText(string.format("Ships: %d | Formation: %s | Status: %s",
        shipCount, formation, status), HYPERDRIVE.UI.GetFont("Body"),
        contentX + 10, yPos, HYPERDRIVE.UI.GetColor("Text"))
    yPos = yPos + 20

    -- Ship list
    if fleetData.ships then
        for i, ship in ipairs(fleetData.ships) do
            if i > 5 then break end -- Limit display

            local shipName = ship.entity and ship.entity:GetNWString("ShipName", "Unnamed") or "Unknown"
            local role = ship.role or "escort"

            HYPERDRIVE.UI.DrawStatusIndicator(contentX + 10, yPos, 12, "fleet",
                string.format("%s (%s)", shipName, role))
            yPos = yPos + 20
        end
    end
end

function HYPERDRIVE.UI.DrawAdminPanel(x, y, w, h, adminData)
    local contentX, contentY, contentW, contentH = HYPERDRIVE.UI.DrawModernPanel(x, y, w, h, "Admin Control", nil)

    local yPos = contentY

    -- System status
    draw.SimpleText("System Status", HYPERDRIVE.UI.GetFont("Subtitle"),
        contentX + 10, yPos, HYPERDRIVE.UI.GetColor("Admin"))
    yPos = yPos + 25

    if adminData and adminData.performance then
        local perf = adminData.performance

        -- Server FPS
        local fpsColor = "Success"
        if perf.serverFPS < 30 then fpsColor = "Error"
        elseif perf.serverFPS < 50 then fpsColor = "Warning" end

        draw.SimpleText(string.format("Server FPS: %d", perf.serverFPS), HYPERDRIVE.UI.GetFont("Body"),
            contentX + 10, yPos, HYPERDRIVE.UI.GetColor(fpsColor))
        yPos = yPos + 18

        -- Entity counts
        draw.SimpleText(string.format("Total Entities: %d", perf.entityCount or 0), HYPERDRIVE.UI.GetFont("Body"),
            contentX + 10, yPos, HYPERDRIVE.UI.GetColor("Text"))
        yPos = yPos + 18

        draw.SimpleText(string.format("Hyperdrive Entities: %d", perf.hyperdriveEntityCount or 0), HYPERDRIVE.UI.GetFont("Body"),
            contentX + 10, yPos, HYPERDRIVE.UI.GetColor("Text"))
        yPos = yPos + 18

        -- Memory usage
        local memoryMB = (perf.memoryUsage or 0) / 1024
        draw.SimpleText(string.format("Memory: %.1f MB", memoryMB), HYPERDRIVE.UI.GetFont("Body"),
            contentX + 10, yPos, HYPERDRIVE.UI.GetColor("Text"))
    end
end

function HYPERDRIVE.UI.DrawStargateSequence(x, y, w, h, stageData)
    local contentX, contentY, contentW, contentH = HYPERDRIVE.UI.DrawModernPanel(x, y, w, h, "Stargate Sequence", nil)

    if not stageData or not stageData.stage then
        draw.SimpleText("No sequence active", HYPERDRIVE.UI.GetFont("Body"),
            contentX + contentW/2, contentY + contentH/2, HYPERDRIVE.UI.GetColor("TextSecondary"),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    local yPos = contentY

    -- Current stage
    draw.SimpleText("Stage: " .. stageData.stage, HYPERDRIVE.UI.GetFont("Subtitle"),
        contentX + 10, yPos, HYPERDRIVE.UI.GetColor("Stargate"))
    yPos = yPos + 25

    -- Stage description
    if stageData.description then
        draw.SimpleText(stageData.description, HYPERDRIVE.UI.GetFont("Body"),
            contentX + 10, yPos, HYPERDRIVE.UI.GetColor("Text"))
        yPos = yPos + 20
    end

    -- Progress bar
    if stageData.progress then
        HYPERDRIVE.UI.DrawProgressBar(contentX + 10, yPos, contentW - 20, 20,
            stageData.progress, 1, "Stargate", true)
        yPos = yPos + 30
    end

    -- Stage indicators
    local stages = {"Initiation", "Window Opening", "Hyperspace Travel", "Exit"}
    local currentStageIndex = 1

    for i, stage in ipairs(stages) do
        if stage == stageData.stage then
            currentStageIndex = i
            break
        end
    end

    local stageWidth = (contentW - 40) / #stages
    for i, stage in ipairs(stages) do
        local stageX = contentX + 10 + (i - 1) * stageWidth
        local stageColor = "TextSecondary"

        if i < currentStageIndex then
            stageColor = "Success"
        elseif i == currentStageIndex then
            stageColor = "Stargate"
        end

        HYPERDRIVE.UI.DrawStatusIndicator(stageX, yPos, 12, stageColor == "Success" and "success" or
            (stageColor == "Stargate" and "stargate" or "info"), nil)

        draw.SimpleText(tostring(i), HYPERDRIVE.UI.GetFont("Small"),
            stageX + 6, yPos + 6, HYPERDRIVE.UI.GetColor("Text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

function HYPERDRIVE.UI.DrawRealTimeStatus(x, y, w, h, statusData)
    local contentX, contentY, contentW, contentH = HYPERDRIVE.UI.DrawModernPanel(x, y, w, h, "Real-Time Status", nil)

    local yPos = contentY

    -- Update indicator
    local updateColor = statusData and statusData.lastUpdate and
        (CurTime() - statusData.lastUpdate < 1) and "RealTime" or "Warning"

    HYPERDRIVE.UI.DrawStatusIndicator(contentX + contentW - 30, contentY - 15, 12,
        updateColor == "RealTime" and "realtime" or "warning", nil)

    if not statusData then
        draw.SimpleText("No real-time data", HYPERDRIVE.UI.GetFont("Body"),
            contentX + contentW/2, contentY + contentH/2, HYPERDRIVE.UI.GetColor("TextSecondary"),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        return
    end

    -- Ship status
    if statusData.shipStatus and statusData.shipStatus.entity then
        local ship = statusData.shipStatus

        draw.SimpleText("Ship: " .. (ship.name or "Unnamed"), HYPERDRIVE.UI.GetFont("Subtitle"),
            contentX + 10, yPos, HYPERDRIVE.UI.GetColor("Text"))
        yPos = yPos + 20

        -- Hull integrity
        if ship.hullIntegrity then
            local hullColor = "Success"
            if ship.hullIntegrity < 25 then hullColor = "Critical"
            elseif ship.hullIntegrity < 50 then hullColor = "Warning" end

            HYPERDRIVE.UI.DrawProgressBar(contentX + 10, yPos, contentW - 20, 15,
                ship.hullIntegrity, 100, hullColor, "Hull: " .. math.floor(ship.hullIntegrity) .. "%")
            yPos = yPos + 25
        end

        -- Energy level
        if ship.energyLevel then
            local energyColor = ship.energyLevel < 25 and "Warning" or "Success"

            HYPERDRIVE.UI.DrawProgressBar(contentX + 10, yPos, contentW - 20, 15,
                ship.energyLevel, 100, energyColor, "Energy: " .. math.floor(ship.energyLevel) .. "%")
            yPos = yPos + 25
        end

        -- Alerts
        if statusData.alerts and #statusData.alerts > 0 then
            for _, alert in ipairs(statusData.alerts) do
                HYPERDRIVE.UI.DrawStatusIndicator(contentX + 10, yPos, 12, alert.type, alert.message)
                yPos = yPos + 20
            end
        end
    end
end

-- Initialize the UI theme system
timer.Simple(0.1, function()
    if HYPERDRIVE and HYPERDRIVE.UI then
        HYPERDRIVE.UI.Initialized = true
        print("[Hyperdrive] Enhanced Modern UI Theme System v2.2.0 initialized successfully")
    else
        print("[Hyperdrive] Warning: UI theme system failed to initialize - HYPERDRIVE.UI not available")
    end
end)

print("[Hyperdrive] Enhanced Modern UI Theme System v2.2.0 loaded")
