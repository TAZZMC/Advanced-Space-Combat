-- Advanced Space Combat - Enhanced User Experience System v1.0.0
-- Based on UX best practices and user-centered design principles

if SERVER then return end

print("[Advanced Space Combat] Enhanced User Experience System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.UX = ASC.UX or {}

-- UX configuration based on research
ASC.UX.Config = {
    -- Accessibility
    EnableHighContrast = false,
    EnableLargeText = false,
    EnableReducedMotion = false,
    EnableScreenReader = false,
    
    -- Visual feedback
    EnableHoverEffects = true,
    EnableClickFeedback = true,
    EnableProgressIndicators = true,
    EnableTooltips = true,
    
    -- Performance
    EnableAnimations = true,
    AnimationDuration = 0.3,
    EnableTransitions = true,
    TransitionDuration = 0.2,
    
    -- User guidance
    EnableOnboarding = true,
    EnableContextualHelp = true,
    EnableSmartSuggestions = true,
    
    -- Personalization
    RememberUserPreferences = true,
    AdaptToUserBehavior = true,
    EnableCustomization = true
}

-- UX state tracking
ASC.UX.State = {
    FirstTimeUser = true,
    UserPreferences = {},
    InteractionHistory = {},
    CurrentContext = "menu",
    LastAction = nil,
    HelpShown = {}
}

-- Initialize UX system
function ASC.UX.Initialize()
    print("[Advanced Space Combat] Initializing enhanced UX system...")
    
    -- Load user preferences
    ASC.UX.LoadUserPreferences()
    
    -- Set up accessibility features
    ASC.UX.SetupAccessibility()
    
    -- Set up visual feedback
    ASC.UX.SetupVisualFeedback()
    
    -- Set up user guidance
    ASC.UX.SetupUserGuidance()
    
    -- Set up onboarding
    ASC.UX.SetupOnboarding()
    
    print("[Advanced Space Combat] Enhanced UX system initialized")
end

-- Load user preferences
function ASC.UX.LoadUserPreferences()
    local preferences = cookie.GetString("asc_ux_preferences", "{}")
    ASC.UX.State.UserPreferences = util.JSONToTable(preferences) or {}
    
    -- Apply loaded preferences
    for key, value in pairs(ASC.UX.State.UserPreferences) do
        if ASC.UX.Config[key] ~= nil then
            ASC.UX.Config[key] = value
        end
    end
end

-- Save user preferences
function ASC.UX.SaveUserPreferences()
    local preferences = util.TableToJSON(ASC.UX.State.UserPreferences)
    cookie.Set("asc_ux_preferences", preferences)
end

-- Set up accessibility features
function ASC.UX.SetupAccessibility()
    -- High contrast mode
    if ASC.UX.Config.EnableHighContrast then
        ASC.UX.ApplyHighContrastMode()
    end
    
    -- Large text mode
    if ASC.UX.Config.EnableLargeText then
        ASC.UX.ApplyLargeTextMode()
    end
    
    -- Reduced motion mode
    if ASC.UX.Config.EnableReducedMotion then
        ASC.UX.Config.EnableAnimations = false
        ASC.UX.Config.EnableTransitions = false
    end
end

-- Apply high contrast mode
function ASC.UX.ApplyHighContrastMode()
    -- Override theme colors for better contrast
    if ASC.ComprehensiveTheme then
        ASC.ComprehensiveTheme.Colors.Primary = Color(255, 255, 255, 255)
        ASC.ComprehensiveTheme.Colors.Secondary = Color(0, 0, 0, 255)
        ASC.ComprehensiveTheme.Colors.Background = Color(0, 0, 0, 255)
        ASC.ComprehensiveTheme.Colors.Text = Color(255, 255, 255, 255)
    end
end

-- Apply large text mode
function ASC.UX.ApplyLargeTextMode()
    -- Increase font sizes
    surface.CreateFont("ASC_LargeText", {
        font = "Roboto",
        size = 24,
        weight = 500,
        antialias = true
    })
    
    surface.CreateFont("ASC_LargeTitle", {
        font = "Roboto",
        size = 32,
        weight = 700,
        antialias = true
    })
end

-- Set up visual feedback
function ASC.UX.SetupVisualFeedback()
    -- Enhanced button feedback
    ASC.UX.SetupButtonFeedback()
    
    -- Progress indicators
    ASC.UX.SetupProgressIndicators()
    
    -- Tooltips
    ASC.UX.SetupTooltips()
    
    -- Loading states
    ASC.UX.SetupLoadingStates()
end

-- Set up button feedback
function ASC.UX.SetupButtonFeedback()
    -- Override button paint functions for better feedback
    local originalButtonPaint = vgui.GetControlTable("DButton").Paint
    
    vgui.GetControlTable("DButton").Paint = function(self, w, h)
        -- Call original paint
        if originalButtonPaint then
            originalButtonPaint(self, w, h)
        end
        
        -- Add enhanced feedback
        if ASC.UX.Config.EnableHoverEffects and self:IsHovered() then
            -- Hover glow effect
            surface.SetDrawColor(100, 200, 255, 50)
            surface.DrawRect(0, 0, w, h)
        end
        
        if ASC.UX.Config.EnableClickFeedback and self:IsDown() then
            -- Click ripple effect
            ASC.UX.DrawRippleEffect(self, w, h)
        end
    end
end

-- Draw ripple effect
function ASC.UX.DrawRippleEffect(panel, w, h)
    if not panel.RippleStartTime then
        panel.RippleStartTime = CurTime()
        panel.RippleX = w / 2
        panel.RippleY = h / 2
    end
    
    local elapsed = CurTime() - panel.RippleStartTime
    local maxRadius = math.sqrt(w * w + h * h) / 2
    local radius = math.min(elapsed * 200, maxRadius)
    local alpha = math.max(0, 100 - (elapsed * 200))
    
    if alpha > 0 then
        surface.SetDrawColor(255, 255, 255, alpha)
        ASC.UX.DrawCircle(panel.RippleX, panel.RippleY, radius)
    else
        panel.RippleStartTime = nil
    end
end

-- Draw circle helper
function ASC.UX.DrawCircle(x, y, radius)
    local segmentCount = math.max(8, radius / 2)
    local vertices = {}
    
    for i = 0, segmentCount do
        local angle = (i / segmentCount) * math.pi * 2
        table.insert(vertices, {
            x = x + math.cos(angle) * radius,
            y = y + math.sin(angle) * radius
        })
    end
    
    surface.DrawPoly(vertices)
end

-- Set up progress indicators
function ASC.UX.SetupProgressIndicators()
    -- Create progress indicator for loading operations
    ASC.UX.CreateProgressIndicator = function(parent, text)
        local progress = vgui.Create("DPanel", parent)
        progress:SetSize(300, 60)
        progress:Center()
        
        progress.Text = text or "Loading..."
        progress.Progress = 0
        progress.StartTime = CurTime()
        
        progress.Paint = function(self, w, h)
            -- Background
            surface.SetDrawColor(20, 30, 50, 240)
            surface.DrawRect(0, 0, w, h)
            
            -- Border
            surface.SetDrawColor(100, 150, 255, 200)
            surface.DrawOutlinedRect(0, 0, w, h, 2)
            
            -- Progress bar
            local barWidth = (w - 20) * (self.Progress / 100)
            surface.SetDrawColor(100, 200, 255, 200)
            surface.DrawRect(10, h - 15, barWidth, 5)
            
            -- Text
            surface.SetTextColor(200, 220, 255, 255)
            surface.SetFont("DermaDefault")
            local textW, textH = surface.GetTextSize(self.Text)
            surface.SetTextPos((w - textW) / 2, (h - textH) / 2 - 5)
            surface.DrawText(self.Text)
            
            -- Percentage
            local percent = math.floor(self.Progress) .. "%"
            local percentW, percentH = surface.GetTextSize(percent)
            surface.SetTextPos((w - percentW) / 2, (h - percentH) / 2 + 10)
            surface.DrawText(percent)
        end
        
        return progress
    end
end

-- Set up tooltips
function ASC.UX.SetupTooltips()
    if not ASC.UX.Config.EnableTooltips then return end
    
    -- Enhanced tooltip system
    ASC.UX.ShowTooltip = function(panel, text, delay)
        delay = delay or 0.5
        
        if panel.TooltipTimer then
            timer.Remove(panel.TooltipTimer)
        end
        
        panel.TooltipTimer = "ASC_Tooltip_" .. panel:GetHashCode()
        
        timer.Create(panel.TooltipTimer, delay, 1, function()
            if IsValid(panel) and panel:IsHovered() then
                ASC.UX.CreateTooltip(text)
            end
        end)
    end
    
    ASC.UX.CreateTooltip = function(text)
        if IsValid(ASC.UX.CurrentTooltip) then
            ASC.UX.CurrentTooltip:Remove()
        end
        
        local tooltip = vgui.Create("DPanel")
        tooltip:SetSize(200, 40)
        tooltip:SetPos(gui.MouseX() + 10, gui.MouseY() + 10)
        tooltip:MakePopup()
        
        tooltip.Paint = function(self, w, h)
            surface.SetDrawColor(20, 30, 50, 240)
            surface.DrawRect(0, 0, w, h)
            
            surface.SetDrawColor(100, 150, 255, 200)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            surface.SetTextColor(200, 220, 255, 255)
            surface.SetFont("DermaDefault")
            local textW, textH = surface.GetTextSize(text)
            surface.SetTextPos((w - textW) / 2, (h - textH) / 2)
            surface.DrawText(text)
        end
        
        ASC.UX.CurrentTooltip = tooltip
        
        timer.Simple(3, function()
            if IsValid(tooltip) then
                tooltip:Remove()
            end
        end)
    end
end

-- Set up loading states
function ASC.UX.SetupLoadingStates()
    ASC.UX.ShowLoadingState = function(panel, text)
        if not IsValid(panel) then return end
        
        panel.LoadingOverlay = vgui.Create("DPanel", panel)
        panel.LoadingOverlay:SetSize(panel:GetSize())
        panel.LoadingOverlay:SetPos(0, 0)
        
        panel.LoadingOverlay.Text = text or "Loading..."
        panel.LoadingOverlay.StartTime = CurTime()
        
        panel.LoadingOverlay.Paint = function(self, w, h)
            -- Semi-transparent overlay
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(0, 0, w, h)
            
            -- Spinning loader
            local elapsed = CurTime() - self.StartTime
            local rotation = (elapsed * 180) % 360
            
            surface.SetDrawColor(100, 200, 255, 200)
            ASC.UX.DrawSpinner(w / 2, h / 2 - 10, 20, rotation)
            
            -- Loading text
            surface.SetTextColor(200, 220, 255, 255)
            surface.SetFont("DermaDefault")
            local textW, textH = surface.GetTextSize(self.Text)
            surface.SetTextPos((w - textW) / 2, h / 2 + 15)
            surface.DrawText(self.Text)
        end
    end
    
    ASC.UX.HideLoadingState = function(panel)
        if IsValid(panel) and IsValid(panel.LoadingOverlay) then
            panel.LoadingOverlay:Remove()
            panel.LoadingOverlay = nil
        end
    end
end

-- Draw spinner
function ASC.UX.DrawSpinner(x, y, radius, rotation)
    local segments = 8
    for i = 0, segments - 1 do
        local angle = (i / segments) * 360 + rotation
        local alpha = 255 - (i * 30)
        
        local startX = x + math.cos(math.rad(angle)) * radius
        local startY = y + math.sin(math.rad(angle)) * radius
        local endX = x + math.cos(math.rad(angle)) * (radius - 5)
        local endY = y + math.sin(math.rad(angle)) * (radius - 5)
        
        surface.SetDrawColor(100, 200, 255, alpha)
        surface.DrawLine(startX, startY, endX, endY)
    end
end

-- Set up user guidance
function ASC.UX.SetupUserGuidance()
    -- Context-sensitive help
    ASC.UX.ShowContextualHelp = function(context, message)
        if not ASC.UX.Config.EnableContextualHelp then return end
        if ASC.UX.State.HelpShown[context] then return end
        
        local help = vgui.Create("DFrame")
        help:SetSize(400, 200)
        help:Center()
        help:SetTitle("Help - " .. context)
        help:MakePopup()
        
        local label = vgui.Create("DLabel", help)
        label:SetText(message)
        label:SetWrap(true)
        label:SetTextColor(Color(200, 220, 255))
        label:Dock(FILL)
        label:DockMargin(10, 10, 10, 50)
        
        local button = vgui.Create("DButton", help)
        button:SetText("Got it!")
        button:SetSize(100, 30)
        button:SetPos(help:GetWide() - 110, help:GetTall() - 40)
        button.DoClick = function()
            ASC.UX.State.HelpShown[context] = true
            help:Close()
        end
        
        -- Don't show again checkbox
        local checkbox = vgui.Create("DCheckBoxLabel", help)
        checkbox:SetText("Don't show this again")
        checkbox:SetPos(10, help:GetTall() - 40)
        checkbox:SizeToContents()
        checkbox.OnChange = function(self, checked)
            if checked then
                ASC.UX.State.HelpShown[context] = true
            end
        end
    end
end

-- Set up onboarding
function ASC.UX.SetupOnboarding()
    if not ASC.UX.Config.EnableOnboarding then return end
    
    -- Check if first time user
    local hasUsedBefore = cookie.GetString("asc_has_used", "false") == "true"
    
    if not hasUsedBefore then
        timer.Simple(2, function()
            ASC.UX.ShowOnboardingTour()
        end)
    end
end

-- Show onboarding tour
function ASC.UX.ShowOnboardingTour()
    local tour = vgui.Create("DFrame")
    tour:SetSize(500, 300)
    tour:Center()
    tour:SetTitle("Welcome to Advanced Space Combat!")
    tour:MakePopup()
    
    local html = vgui.Create("DHTML", tour)
    html:Dock(FILL)
    html:DockMargin(10, 10, 10, 50)
    
    local welcomeHTML = [[
        <html>
        <body style="background: #1a2040; color: #c8dcff; font-family: Arial; padding: 20px;">
            <h2>Welcome to Advanced Space Combat!</h2>
            <p>This addon provides advanced space combat features including:</p>
            <ul>
                <li>🚀 Ship Core System with life support</li>
                <li>🌌 4-Stage Stargate Hyperspace Travel</li>
                <li>⚔️ Advanced Weapon Systems</li>
                <li>🛡️ Shield Technology</li>
                <li>🤖 ARIA-4 AI Assistant</li>
            </ul>
            <p>Use <strong>asc_help</strong> in console for commands, or say <strong>aria help</strong> for AI assistance!</p>
        </body>
        </html>
    ]]
    
    html:SetHTML(welcomeHTML)
    
    local button = vgui.Create("DButton", tour)
    button:SetText("Start Exploring!")
    button:SetSize(150, 30)
    button:SetPos(tour:GetWide() - 160, tour:GetTall() - 40)
    button.DoClick = function()
        cookie.Set("asc_has_used", "true")
        tour:Close()
        
        -- Show first contextual help
        timer.Simple(1, function()
            ASC.UX.ShowContextualHelp("first_use", "Try spawning a Ship Core from the Q menu under 'Advanced Space Combat' to get started!")
        end)
    end
end

-- Console commands for UX management
concommand.Add("asc_ux_reset", function()
    cookie.Delete("asc_ux_preferences")
    cookie.Delete("asc_has_used")
    ASC.UX.State.HelpShown = {}
    chat.AddText(Color(100, 200, 255), "[ASC] ", Color(255, 255, 255), "UX preferences reset")
end, nil, "Reset UX preferences and onboarding")

concommand.Add("asc_ux_accessibility", function()
    -- Toggle accessibility features
    ASC.UX.Config.EnableHighContrast = not ASC.UX.Config.EnableHighContrast
    ASC.UX.Config.EnableLargeText = not ASC.UX.Config.EnableLargeText
    
    ASC.UX.SetupAccessibility()
    
    chat.AddText(Color(100, 200, 255), "[ASC] ", Color(255, 255, 255), "Accessibility features toggled")
end, nil, "Toggle accessibility features")

-- Initialize UX system
hook.Add("Initialize", "ASC_UX_Init", function()
    timer.Simple(1, function()
        ASC.UX.Initialize()
    end)
end)

print("[Advanced Space Combat] Enhanced User Experience System loaded successfully!")
