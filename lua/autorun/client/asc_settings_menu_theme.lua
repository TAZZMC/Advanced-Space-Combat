-- Advanced Space Combat - Settings Menu Theme System v1.0.0
-- Enhanced theming for game settings, options, and configuration menus

print("[Advanced Space Combat] Settings Menu Theme System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.SettingsTheme = ASC.SettingsTheme or {}

-- Settings theme configuration
ASC.SettingsTheme.Config = {
    -- Enable/Disable Features
    EnableOptionsMenuTheming = true,
    EnableGameMenuTheming = true,
    EnableAddonMenuTheming = true,
    EnableControlsMenuTheming = true,
    EnableVideoMenuTheming = true,
    EnableAudioMenuTheming = true,
    
    -- Visual Settings
    UseAdvancedStyling = true,
    EnableAnimations = true,
    EnableGlowEffects = true,
    EnableGradients = true,
    
    -- Layout Settings
    BorderRadius = {
        Small = 4,
        Medium = 8,
        Large = 12
    },
    
    -- Colors (matching ASC theme)
    Colors = {
        Primary = Color(41, 128, 185, 240),
        Secondary = Color(52, 73, 94, 220),
        Accent = Color(155, 89, 182, 255),
        Success = Color(39, 174, 96, 255),
        Warning = Color(243, 156, 18, 255),
        Danger = Color(231, 76, 60, 255),
        Background = Color(23, 32, 42, 240),
        Surface = Color(30, 39, 46, 220),
        Panel = Color(44, 62, 80, 200),
        Text = Color(255, 255, 255, 255),
        TextSecondary = Color(178, 190, 195, 200),
        Border = Color(99, 110, 114, 150),
        Glow = Color(100, 150, 255, 100),
        
        -- Settings-specific colors
        OptionCategory = Color(52, 73, 94, 230),
        OptionItem = Color(44, 62, 80, 200),
        OptionHover = Color(155, 89, 182, 150),
        OptionSelected = Color(41, 128, 185, 200),
        Slider = Color(155, 89, 182, 255),
        SliderTrack = Color(99, 110, 114, 150)
    }
}

-- Settings theme state
ASC.SettingsTheme.State = {
    OptionsMenuOpen = false,
    GameMenuOpen = false,
    ThemedMenus = {},
    LastUpdate = 0,
    
    -- Animation states
    Animations = {
        MenuFade = 0,
        ButtonHover = {},
        SliderGlow = {},
        CategoryExpand = {}
    }
}

-- Initialize settings theme system
function ASC.SettingsTheme.Initialize()
    print("[Advanced Space Combat] Settings menu theme initialized")

    -- ConVars are now managed centrally by ASC.ConVarManager
    
    -- Initialize hooks
    ASC.SettingsTheme.InitializeHooks()
    
    -- Initialize menu detection
    ASC.SettingsTheme.InitializeMenuDetection()
end

-- Initialize hooks
function ASC.SettingsTheme.InitializeHooks()
    -- Hook into menu opening
    hook.Add("OnGamemodeLoaded", "ASC_SettingsTheme_GameLoaded", function()
        timer.Simple(2, function()
            ASC.SettingsTheme.ScanForSettingsMenus()
        end)
    end)
    
    -- Hook into Think for continuous scanning
    hook.Add("Think", "ASC_SettingsTheme_Think", function()
        if GetConVar("asc_settings_theme_enabled"):GetBool() then
            ASC.SettingsTheme.UpdateSettingsMenus()
        end
    end)
    
    -- Hook into VGUI creation for immediate theming
    hook.Add("VGUIElementCreated", "ASC_SettingsTheme_VGUI", function(element)
        if GetConVar("asc_settings_theme_enabled"):GetBool() then
            timer.Simple(0.1, function()
                if IsValid(element) then
                    ASC.SettingsTheme.CheckAndThemeElement(element)
                end
            end)
        end
    end)
end

-- Initialize menu detection
function ASC.SettingsTheme.InitializeMenuDetection()
    -- Override common menu functions to detect when they open
    local originalGameMenu = gamemode.Call
    if originalGameMenu then
        -- This is a simplified approach - in practice, you'd need more specific hooks
        print("[Advanced Space Combat] Menu detection initialized")
    end
end

-- Scan for settings menus
function ASC.SettingsTheme.ScanForSettingsMenus()
    if not GetConVar("asc_settings_theme_enabled"):GetBool() then return end
    
    print("[Advanced Space Combat] Scanning for settings menus...")
    
    local function ScanPanel(panel)
        if not IsValid(panel) then return end
        
        ASC.SettingsTheme.CheckAndThemeElement(panel)
        
        for _, child in pairs(panel:GetChildren()) do
            ScanPanel(child)
        end
    end
    
    -- Scan all top-level panels
    ScanPanel(vgui.GetWorldPanel())
    
    print("[Advanced Space Combat] Settings menu scan complete")
end

-- Check and theme element if it's a settings menu
function ASC.SettingsTheme.CheckAndThemeElement(element)
    if not IsValid(element) then return end
    if element.ASCSettingsThemed then return end -- Already themed
    
    local className = element:GetClassName()
    local isSettingsElement = false
    
    -- Check if this is a settings-related element
    if ASC.SettingsTheme.IsSettingsElement(element) then
        isSettingsElement = true
    end
    
    if isSettingsElement then
        ASC.SettingsTheme.ThemeSettingsElement(element)
    end
end

-- Check if element is settings-related
function ASC.SettingsTheme.IsSettingsElement(element)
    if not IsValid(element) then return false end
    
    local className = element:GetClassName()
    local title = ""
    
    -- Safely get title
    local success, result = pcall(function()
        if element.GetTitle then
            return element:GetTitle() or ""
        end
        return ""
    end)
    
    if success then
        title = string.lower(result)
    end
    
    -- Check for settings-related patterns
    local settingsPatterns = {
        "options", "settings", "preferences", "config", "controls",
        "video", "audio", "graphics", "sound", "game", "advanced",
        "multiplayer", "keyboard", "mouse", "display"
    }
    
    for _, pattern in ipairs(settingsPatterns) do
        if string.find(title, pattern) then
            return true
        end
    end
    
    -- Check class names
    local settingsClasses = {
        "DFrame", "DPanel", "DPropertySheet", "DTab", "DButton",
        "DSlider", "DNumSlider", "DCheckBox", "DComboBox", "DTextEntry"
    }
    
    for _, class in ipairs(settingsClasses) do
        if className == class then
            -- Additional check for parent context
            local parent = element:GetParent()
            if IsValid(parent) and ASC.SettingsTheme.IsSettingsElement(parent) then
                return true
            end
        end
    end
    
    return false
end

-- Theme settings element
function ASC.SettingsTheme.ThemeSettingsElement(element)
    if not IsValid(element) then return end
    if element.ASCSettingsThemed then return end
    
    local config = ASC.SettingsTheme.Config
    local className = element:GetClassName()
    
    element.ASCSettingsThemed = true
    
    -- Store original paint function
    local originalPaint = element.Paint
    
    -- Apply themed paint function based on element type
    if className == "DFrame" then
        ASC.SettingsTheme.ThemeSettingsFrame(element)
    elseif className == "DPanel" then
        ASC.SettingsTheme.ThemeSettingsPanel(element)
    elseif className == "DButton" then
        ASC.SettingsTheme.ThemeSettingsButton(element)
    elseif className == "DSlider" or className == "DNumSlider" then
        ASC.SettingsTheme.ThemeSettingsSlider(element)
    elseif className == "DCheckBox" then
        ASC.SettingsTheme.ThemeSettingsCheckBox(element)
    elseif className == "DComboBox" then
        ASC.SettingsTheme.ThemeSettingsComboBox(element)
    elseif className == "DTextEntry" then
        ASC.SettingsTheme.ThemeSettingsTextEntry(element)
    elseif className == "DPropertySheet" then
        ASC.SettingsTheme.ThemeSettingsPropertySheet(element)
    elseif className == "DTab" then
        ASC.SettingsTheme.ThemeSettingsTab(element)
    end
    
    -- Mark in state
    ASC.SettingsTheme.State.ThemedMenus[element] = className
end

-- Theme settings frame
function ASC.SettingsTheme.ThemeSettingsFrame(frame)
    if not IsValid(frame) then return end
    
    local config = ASC.SettingsTheme.Config
    
    frame.Paint = function(self, w, h)
        -- Background with glassmorphism
        draw.RoundedBox(config.BorderRadius.Large, 0, 0, w, h, config.Colors.Background)
        draw.RoundedBox(config.BorderRadius.Medium, 2, 2, w - 4, h - 4, config.Colors.Surface)
        
        -- Border
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 2)
        
        -- Glow effect
        if GetConVar("asc_settings_glow"):GetBool() then
            local glowAlpha = math.sin(CurTime() * 2) * 30 + 50
            surface.SetDrawColor(Color(config.Colors.Glow.r, config.Colors.Glow.g, config.Colors.Glow.b, glowAlpha))
            surface.DrawOutlinedRect(-1, -1, w + 2, h + 2, 1)
        end
        
        -- Title bar
        local success, title = pcall(function()
            if self.GetTitle then
                return self:GetTitle()
            end
            return nil
        end)
        
        if success and title and title ~= "" then
            draw.RoundedBox(config.BorderRadius.Small, 5, 5, w - 10, 30, config.Colors.Primary)
            
            surface.SetFont("DermaDefaultBold")
            surface.SetTextColor(config.Colors.Text)
            local titleW, titleH = surface.GetTextSize(title)
            surface.SetTextPos(w/2 - titleW/2, 10)
            surface.DrawText(title)
        end
    end
end

-- Theme settings panel
function ASC.SettingsTheme.ThemeSettingsPanel(panel)
    if not IsValid(panel) then return end
    
    local config = ASC.SettingsTheme.Config
    
    panel.Paint = function(self, w, h)
        draw.RoundedBox(config.BorderRadius.Medium, 0, 0, w, h, config.Colors.Panel)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
end

-- Theme settings button
function ASC.SettingsTheme.ThemeSettingsButton(button)
    if not IsValid(button) then return end
    
    local config = ASC.SettingsTheme.Config
    
    button.Paint = function(self, w, h)
        local bgColor = config.Colors.Secondary
        
        if self:IsHovered() then
            bgColor = config.Colors.OptionHover
        end
        
        if self:IsDown() then
            bgColor = config.Colors.OptionSelected
        end
        
        draw.RoundedBox(config.BorderRadius.Small, 0, 0, w, h, bgColor)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        -- Button text
        local text = self:GetText()
        if text and text ~= "" then
            surface.SetFont("DermaDefaultBold")
            surface.SetTextColor(config.Colors.Text)
            local textW, textH = surface.GetTextSize(text)
            surface.SetTextPos(w/2 - textW/2, h/2 - textH/2)
            surface.DrawText(text)
        end
    end
end

-- Theme settings slider
function ASC.SettingsTheme.ThemeSettingsSlider(slider)
    if not IsValid(slider) then return end
    
    local config = ASC.SettingsTheme.Config
    
    slider.Paint = function(self, w, h)
        -- Track
        local trackY = h/2 - 2
        draw.RoundedBox(2, 0, trackY, w, 4, config.Colors.SliderTrack)
        
        -- Knob
        local knobX = 0
        if self.GetSlideX then
            knobX = (w - 16) * self:GetSlideX()
        end
        
        draw.RoundedBox(8, knobX, h/2 - 8, 16, 16, config.Colors.Slider)
        
        -- Glow effect on knob
        if GetConVar("asc_settings_glow"):GetBool() then
            local glowAlpha = math.sin(CurTime() * 3) * 50 + 100
            surface.SetDrawColor(Color(config.Colors.Slider.r, config.Colors.Slider.g, config.Colors.Slider.b, glowAlpha))
            surface.DrawOutlinedRect(knobX - 1, h/2 - 9, 18, 18, 1)
        end
    end
end

-- Theme settings checkbox
function ASC.SettingsTheme.ThemeSettingsCheckBox(checkBox)
    if not IsValid(checkBox) then return end
    
    local config = ASC.SettingsTheme.Config
    
    checkBox.Paint = function(self, w, h)
        local bgColor = self:GetChecked() and config.Colors.Success or config.Colors.Surface
        
        draw.RoundedBox(2, 0, 0, 16, 16, bgColor)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, 16, 16, 1)
        
        if self:GetChecked() then
            surface.SetTextColor(config.Colors.Text)
            surface.SetFont("DermaDefaultBold")
            surface.SetTextPos(4, 2)
            surface.DrawText("✓")
        end
    end
end

-- Theme settings combobox
function ASC.SettingsTheme.ThemeSettingsComboBox(comboBox)
    if not IsValid(comboBox) then return end
    
    local config = ASC.SettingsTheme.Config
    
    comboBox.Paint = function(self, w, h)
        draw.RoundedBox(config.BorderRadius.Small, 0, 0, w, h, config.Colors.Surface)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        -- Dropdown arrow
        surface.SetDrawColor(config.Colors.Text)
        local arrowX, arrowY = w - 15, h/2
        surface.DrawLine(arrowX - 3, arrowY - 2, arrowX, arrowY + 2)
        surface.DrawLine(arrowX, arrowY + 2, arrowX + 3, arrowY - 2)
    end
end

-- Theme settings text entry
function ASC.SettingsTheme.ThemeSettingsTextEntry(textEntry)
    if not IsValid(textEntry) then return end
    
    local config = ASC.SettingsTheme.Config
    
    textEntry.Paint = function(self, w, h)
        local borderColor = self:HasFocus() and config.Colors.Accent or config.Colors.Border
        
        draw.RoundedBox(config.BorderRadius.Small, 0, 0, w, h, config.Colors.Surface)
        surface.SetDrawColor(borderColor)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        -- Draw text
        self:DrawTextEntryText(config.Colors.Text, config.Colors.Accent, config.Colors.Text)
    end
end

-- Theme settings property sheet
function ASC.SettingsTheme.ThemeSettingsPropertySheet(propertySheet)
    if not IsValid(propertySheet) then return end
    
    local config = ASC.SettingsTheme.Config
    
    propertySheet.Paint = function(self, w, h)
        draw.RoundedBox(config.BorderRadius.Medium, 0, 0, w, h, config.Colors.Panel)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
end

-- Theme settings tab
function ASC.SettingsTheme.ThemeSettingsTab(tab)
    if not IsValid(tab) then return end
    
    local config = ASC.SettingsTheme.Config
    
    tab.Paint = function(self, w, h)
        local bgColor = self:IsActive() and config.Colors.OptionSelected or config.Colors.Secondary
        
        draw.RoundedBox(config.BorderRadius.Small, 0, 0, w, h, bgColor)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
end

-- Update settings menus
function ASC.SettingsTheme.UpdateSettingsMenus()
    local currentTime = CurTime()
    local state = ASC.SettingsTheme.State
    
    if currentTime - state.LastUpdate < 0.5 then return end -- Update every 0.5 seconds
    
    -- Scan for new settings menus
    ASC.SettingsTheme.ScanForSettingsMenus()
    
    state.LastUpdate = currentTime
end

-- Console commands
concommand.Add("asc_settings_theme_reload", function()
    ASC.SettingsTheme.Initialize()
    print("[Advanced Space Combat] Settings theme system reloaded")
end)

concommand.Add("asc_settings_theme_scan", function()
    ASC.SettingsTheme.ScanForSettingsMenus()
end)

-- Initialize on client
hook.Add("Initialize", "ASC_SettingsTheme_Init", function()
    ASC.SettingsTheme.Initialize()
end)

print("[Advanced Space Combat] Settings Menu Theme System loaded successfully!")
