-- Advanced Space Combat - Ultimate UI System v5.1.0
-- Next-generation user interface with modern design, accessibility, and Stargate theming
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Advanced Space Combat] Ultimate UI System v5.1.0 - Ultimate Edition Loading...")

-- Initialize UI namespace
ASC = ASC or {}
ASC.UI = ASC.UI or {}

-- UI Configuration
ASC.UI.Config = {
    -- Theme Settings
    Theme = {
        Primary = Color(41, 128, 185),      -- Professional blue
        Secondary = Color(52, 73, 94),     -- Dark blue-gray
        Success = Color(39, 174, 96),      -- Green
        Warning = Color(243, 156, 18),     -- Orange
        Danger = Color(231, 76, 60),       -- Red
        Light = Color(236, 240, 241),      -- Light gray
        Dark = Color(44, 62, 80),          -- Dark gray
        Background = Color(23, 32, 42),    -- Dark background
        Surface = Color(30, 39, 46),       -- Surface color
        Text = Color(255, 255, 255),       -- White text
        TextSecondary = Color(178, 190, 195), -- Light gray text
        Border = Color(99, 110, 114),      -- Border color
        Accent = Color(155, 89, 182),      -- Purple accent
        Highlight = Color(26, 188, 156)    -- Teal highlight
    },
    
    -- Typography
    Fonts = {
        Title = "DermaLarge",
        Heading = "DermaDefaultBold", 
        Body = "DermaDefault",
        Small = "DermaDefaultBold",
        Code = "DebugFixed"
    },
    
    -- Spacing
    Spacing = {
        XS = 4,
        SM = 8,
        MD = 16,
        LG = 24,
        XL = 32,
        XXL = 48
    },
    
    -- Animation
    Animation = {
        Duration = 0.2,
        Easing = "ease-out",
        Enabled = true
    },
    
    -- Accessibility
    Accessibility = {
        HighContrast = false,
        LargeText = false,
        ReducedMotion = false,
        ScreenReader = false
    }
}

-- UI Component Base Class
ASC.UI.Component = {}
ASC.UI.Component.__index = ASC.UI.Component

function ASC.UI.Component:New(parent)
    local component = {}
    setmetatable(component, self)
    
    component.parent = parent
    component.children = {}
    component.visible = true
    component.enabled = true
    
    return component
end

function ASC.UI.Component:SetTheme(theme)
    self.theme = theme or ASC.UI.Config.Theme
end

function ASC.UI.Component:GetThemeColor(colorName)
    return self.theme and self.theme[colorName] or ASC.UI.Config.Theme[colorName]
end

-- Modern Button Component
ASC.UI.Button = {}
ASC.UI.Button.__index = ASC.UI.Button
setmetatable(ASC.UI.Button, ASC.UI.Component)

function ASC.UI.Button:New(parent, text, onClick)
    local button = ASC.UI.Component.New(self, parent)
    
    button.panel = vgui.Create("DButton", parent)
    button.text = text or "Button"
    button.onClick = onClick
    button.variant = "primary" -- primary, secondary, success, warning, danger
    button.size = "medium" -- small, medium, large
    button.disabled = false
    button.loading = false
    
    button:Setup()
    return button
end

function ASC.UI.Button:Setup()
    local panel = self.panel
    
    panel:SetText(self.text)
    panel:SetFont(ASC.UI.Config.Fonts.Body)
    
    -- Set size based on variant
    local height = self.size == "small" and 28 or (self.size == "large" and 44 or 36)
    panel:SetTall(height)
    
    -- Custom paint function
    panel.Paint = function(pnl, w, h)
        self:Paint(pnl, w, h)
    end
    
    -- Click handler
    panel.DoClick = function()
        if not self.disabled and not self.loading and self.onClick then
            self.onClick()
        end
    end
    
    -- Hover effects
    panel.OnCursorEntered = function()
        self.hovered = true
    end
    
    panel.OnCursorExited = function()
        self.hovered = false
    end
end

function ASC.UI.Button:Paint(panel, w, h)
    local theme = ASC.UI.Config.Theme
    local bgColor = theme.Primary
    
    -- Variant colors
    if self.variant == "secondary" then
        bgColor = theme.Secondary
    elseif self.variant == "success" then
        bgColor = theme.Success
    elseif self.variant == "warning" then
        bgColor = theme.Warning
    elseif self.variant == "danger" then
        bgColor = theme.Danger
    end
    
    -- State modifications
    if self.disabled then
        bgColor = Color(bgColor.r * 0.5, bgColor.g * 0.5, bgColor.b * 0.5, 128)
    elseif self.hovered then
        bgColor = Color(bgColor.r * 1.1, bgColor.g * 1.1, bgColor.b * 1.1, bgColor.a)
    end
    
    -- Draw background with rounded corners
    draw.RoundedBox(4, 0, 0, w, h, bgColor)
    
    -- Draw border
    surface.SetDrawColor(theme.Border)
    surface.DrawOutlinedRect(0, 0, w, h)
    
    -- Draw loading indicator
    if self.loading then
        local time = CurTime() * 5
        local x = w / 2 + math.sin(time) * 8
        draw.RoundedBox(2, x - 2, h / 2 - 2, 4, 4, theme.Light)
    end
end

function ASC.UI.Button:SetVariant(variant)
    self.variant = variant
end

function ASC.UI.Button:SetSize(size)
    self.size = size
    local height = size == "small" and 28 or (size == "large" and 44 or 36)
    self.panel:SetTall(height)
end

function ASC.UI.Button:SetDisabled(disabled)
    self.disabled = disabled
    self.panel:SetEnabled(not disabled)
end

function ASC.UI.Button:SetLoading(loading)
    self.loading = loading
    self.panel:SetText(loading and "Loading..." or self.text)
end

-- Modern Card Component
ASC.UI.Card = {}
ASC.UI.Card.__index = ASC.UI.Card
setmetatable(ASC.UI.Card, ASC.UI.Component)

function ASC.UI.Card:New(parent, title)
    local card = ASC.UI.Component.New(self, parent)
    
    card.panel = vgui.Create("DPanel", parent)
    card.title = title
    card.elevation = 2 -- 0-5 shadow depth
    
    card:Setup()
    return card
end

function ASC.UI.Card:Setup()
    local panel = self.panel
    
    panel.Paint = function(pnl, w, h)
        self:Paint(pnl, w, h)
    end
    
    -- Create title label if title provided
    if self.title then
        self.titleLabel = vgui.Create("DLabel", panel)
        self.titleLabel:SetText(self.title)
        self.titleLabel:SetFont(ASC.UI.Config.Fonts.Heading)
        self.titleLabel:SetTextColor(ASC.UI.Config.Theme.Text)
        self.titleLabel:Dock(TOP)
        self.titleLabel:SetTall(32)
        self.titleLabel:DockMargin(ASC.UI.Config.Spacing.MD, ASC.UI.Config.Spacing.MD, ASC.UI.Config.Spacing.MD, 0)
    end
end

function ASC.UI.Card:Paint(panel, w, h)
    local theme = ASC.UI.Config.Theme
    
    -- Draw shadow based on elevation
    if self.elevation > 0 then
        local shadowOffset = self.elevation
        local shadowColor = Color(0, 0, 0, 20 * self.elevation)
        draw.RoundedBox(8, shadowOffset, shadowOffset, w, h, shadowColor)
    end
    
    -- Draw card background
    draw.RoundedBox(8, 0, 0, w, h, theme.Surface)
    
    -- Draw border
    surface.SetDrawColor(theme.Border)
    surface.DrawOutlinedRect(0, 0, w, h)
end

-- Modern Input Component
ASC.UI.Input = {}
ASC.UI.Input.__index = ASC.UI.Input
setmetatable(ASC.UI.Input, ASC.UI.Component)

function ASC.UI.Input:New(parent, placeholder, value)
    local input = ASC.UI.Component.New(self, parent)
    
    input.panel = vgui.Create("DTextEntry", parent)
    input.placeholder = placeholder or ""
    input.value = value or ""
    input.error = false
    input.errorMessage = ""
    
    input:Setup()
    return input
end

function ASC.UI.Input:Setup()
    local panel = self.panel
    
    panel:SetText(self.value)
    panel:SetPlaceholderText(self.placeholder)
    panel:SetFont(ASC.UI.Config.Fonts.Body)
    panel:SetTall(36)
    
    panel.Paint = function(pnl, w, h)
        self:Paint(pnl, w, h)
    end
    
    panel.OnValueChange = function(pnl, value)
        self.value = value
        if self.onChange then
            self.onChange(value)
        end
    end
end

function ASC.UI.Input:Paint(panel, w, h)
    local theme = ASC.UI.Config.Theme
    local bgColor = theme.Light
    local borderColor = self.error and theme.Danger or theme.Border
    
    if panel:HasFocus() then
        borderColor = theme.Primary
    end
    
    -- Draw background
    draw.RoundedBox(4, 0, 0, w, h, bgColor)
    
    -- Draw border
    surface.SetDrawColor(borderColor)
    surface.DrawOutlinedRect(0, 0, w, h)
    
    -- Draw error message
    if self.error and self.errorMessage ~= "" then
        surface.SetFont(ASC.UI.Config.Fonts.Small)
        surface.SetTextColor(theme.Danger)
        surface.SetTextPos(4, h + 2)
        surface.DrawText(self.errorMessage)
    end
end

function ASC.UI.Input:SetError(error, message)
    self.error = error
    self.errorMessage = message or ""
end

-- Progress Bar Component
ASC.UI.ProgressBar = {}
ASC.UI.ProgressBar.__index = ASC.UI.ProgressBar
setmetatable(ASC.UI.ProgressBar, ASC.UI.Component)

function ASC.UI.ProgressBar:New(parent, value, max)
    local progress = ASC.UI.Component.New(self, parent)
    
    progress.panel = vgui.Create("DPanel", parent)
    progress.value = value or 0
    progress.max = max or 100
    progress.animated = true
    progress.color = ASC.UI.Config.Theme.Primary
    
    progress:Setup()
    return progress
end

function ASC.UI.ProgressBar:Setup()
    local panel = self.panel
    
    panel:SetTall(8)
    
    panel.Paint = function(pnl, w, h)
        self:Paint(pnl, w, h)
    end
end

function ASC.UI.ProgressBar:Paint(panel, w, h)
    local theme = ASC.UI.Config.Theme
    local progress = math.Clamp(self.value / self.max, 0, 1)
    
    -- Draw background
    draw.RoundedBox(4, 0, 0, w, h, theme.Secondary)
    
    -- Draw progress
    if progress > 0 then
        local progressWidth = w * progress
        draw.RoundedBox(4, 0, 0, progressWidth, h, self.color)
    end
end

function ASC.UI.ProgressBar:SetValue(value)
    if self.animated then
        -- Animate to new value
        local startValue = self.value
        local startTime = CurTime()
        local duration = ASC.UI.Config.Animation.Duration
        
        local function animate()
            local elapsed = CurTime() - startTime
            local progress = math.Clamp(elapsed / duration, 0, 1)
            
            self.value = Lerp(progress, startValue, value)
            
            if progress < 1 then
                timer.Simple(0.01, animate)
            else
                self.value = value
            end
        end
        
        animate()
    else
        self.value = value
    end
end

-- Notification System
ASC.UI.Notifications = {}
ASC.UI.Notifications.queue = {}

function ASC.UI.Notifications.Show(message, type, duration)
    local notification = {
        message = message,
        type = type or "info", -- info, success, warning, error
        duration = duration or 5,
        startTime = CurTime()
    }
    
    table.insert(ASC.UI.Notifications.queue, notification)
    
    -- Auto-remove after duration
    timer.Simple(notification.duration, function()
        for i, notif in ipairs(ASC.UI.Notifications.queue) do
            if notif == notification then
                table.remove(ASC.UI.Notifications.queue, i)
                break
            end
        end
    end)
end

function ASC.UI.Notifications.Paint()
    local theme = ASC.UI.Config.Theme
    local y = 50
    
    for i, notification in ipairs(ASC.UI.Notifications.queue) do
        local elapsed = CurTime() - notification.startTime
        local alpha = 255
        
        -- Fade out in last second
        if elapsed > notification.duration - 1 then
            alpha = 255 * (notification.duration - elapsed)
        end
        
        -- Color based on type
        local bgColor = theme.Primary
        if notification.type == "success" then
            bgColor = theme.Success
        elseif notification.type == "warning" then
            bgColor = theme.Warning
        elseif notification.type == "error" then
            bgColor = theme.Danger
        end
        
        bgColor = Color(bgColor.r, bgColor.g, bgColor.b, alpha)
        
        -- Draw notification
        local w, h = 300, 50
        local x = ScrW() - w - 20
        
        draw.RoundedBox(8, x, y, w, h, bgColor)
        
        -- Draw text
        surface.SetFont(ASC.UI.Config.Fonts.Body)
        surface.SetTextColor(Color(255, 255, 255, alpha))
        surface.SetTextPos(x + 16, y + 16)
        surface.DrawText(notification.message)
        
        y = y + h + 10
    end
end

-- Hook for painting notifications
hook.Add("HUDPaint", "ASC_UI_Notifications", function()
    ASC.UI.Notifications.Paint()
end)

-- Accessibility functions
function ASC.UI.SetHighContrast(enabled)
    ASC.UI.Config.Accessibility.HighContrast = enabled
    
    if enabled then
        ASC.UI.Config.Theme.Background = Color(0, 0, 0)
        ASC.UI.Config.Theme.Surface = Color(255, 255, 255)
        ASC.UI.Config.Theme.Text = Color(0, 0, 0)
    end
end

function ASC.UI.SetLargeText(enabled)
    ASC.UI.Config.Accessibility.LargeText = enabled
    
    if enabled then
        ASC.UI.Config.Fonts.Body = "DermaLarge"
        ASC.UI.Config.Fonts.Small = "DermaDefault"
    end
end

-- Initialize UI system
hook.Add("Initialize", "ASC_UI_Initialize", function()
    print("[Advanced Space Combat] UI System initialized with modern design")
    print("[Advanced Space Combat] Accessibility features available")
end)

print("[Advanced Space Combat] UI System loaded successfully!")
