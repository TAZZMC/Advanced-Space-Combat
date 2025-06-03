-- Advanced Space Combat - VGUI Theme Integration v1.0.0
-- Automatic theming for all VGUI elements throughout the addon

print("[Advanced Space Combat] VGUI Theme Integration v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.VGUITheme = ASC.VGUITheme or {}

-- VGUI theme integration configuration
ASC.VGUITheme.Config = {
    -- Enable/Disable Features
    EnableAutoTheming = true,
    EnableFrameTheming = true,
    EnableButtonTheming = true,
    EnablePanelTheming = true,
    EnableTextEntryTheming = true,
    EnableLabelTheming = true,
    
    -- Auto-detection patterns
    ASCPatterns = {
        "Advanced Space Combat",
        "ASC",
        "Weapon",
        "Ship Core",
        "Flight",
        "Hyperdrive",
        "ARIA",
        "AI"
    },
    
    -- Theme override settings
    ForceThemeAll = false, -- Set to true to theme ALL VGUI elements
    ThemeOnlyASC = true,   -- Only theme ASC-related panels
    
    -- Performance settings
    UpdateInterval = 0.1,
    MaxElementsPerFrame = 10
}

-- State tracking
ASC.VGUITheme.State = {
    ThemedElements = {},
    LastUpdate = 0,
    ProcessingQueue = {},
    OriginalPaintFunctions = {}
}

-- Initialize VGUI theme integration
function ASC.VGUITheme.Initialize()
    print("[Advanced Space Combat] VGUI theme integration initialized")
    
    -- Create ConVars
    CreateClientConVar("asc_vgui_theme_enabled", "1", true, false, "Enable VGUI auto-theming")
    CreateClientConVar("asc_vgui_theme_all", "0", true, false, "Theme all VGUI elements (not just ASC)")
    CreateClientConVar("asc_vgui_performance_mode", "1", true, false, "Enable performance optimizations")
    
    -- Initialize hooks
    ASC.VGUITheme.InitializeHooks()
    
    -- Override VGUI creation functions
    ASC.VGUITheme.OverrideVGUICreation()
end

-- Initialize hooks
function ASC.VGUITheme.InitializeHooks()
    -- Hook into VGUI element creation
    hook.Add("VGUIElementCreated", "ASC_VGUITheme", function(element)
        if GetConVar("asc_vgui_theme_enabled"):GetBool() then
            ASC.VGUITheme.QueueElementForTheming(element)
        end
    end)
    
    -- Hook into Think for processing queue
    hook.Add("Think", "ASC_VGUITheme_Process", function()
        if GetConVar("asc_vgui_theme_enabled"):GetBool() then
            ASC.VGUITheme.ProcessThemingQueue()
        end
    end)
    
    -- Hook into panel creation
    hook.Add("OnGamemodeLoaded", "ASC_VGUITheme_Setup", function()
        timer.Simple(1, function()
            ASC.VGUITheme.ScanExistingElements()
        end)
    end)
end

-- Override VGUI creation functions
function ASC.VGUITheme.OverrideVGUICreation()
    -- Store original vgui.Create function
    local originalCreate = vgui.Create
    
    -- Override vgui.Create to automatically theme ASC elements
    vgui.Create = function(classname, parent, name)
        local element = originalCreate(classname, parent, name)
        
        if IsValid(element) and GetConVar("asc_vgui_theme_enabled"):GetBool() then
            -- Check if this should be themed
            if ASC.VGUITheme.ShouldThemeElement(element) then
                ASC.VGUITheme.QueueElementForTheming(element)
            end
        end
        
        return element
    end
    
    print("[Advanced Space Combat] VGUI creation override installed")
end

-- Check if element should be themed
function ASC.VGUITheme.ShouldThemeElement(element)
    if not IsValid(element) then return false end
    
    local config = ASC.VGUITheme.Config
    
    -- Force theme all if enabled
    if GetConVar("asc_vgui_theme_all"):GetBool() or config.ForceThemeAll then
        return true
    end
    
    -- Only theme ASC elements if configured
    if config.ThemeOnlyASC then
        return ASC.VGUITheme.IsASCElement(element)
    end
    
    return false
end

-- Check if element is ASC-related
function ASC.VGUITheme.IsASCElement(element)
    if not IsValid(element) then return false end
    
    local config = ASC.VGUITheme.Config
    
    -- Check element title/text
    local title = ""
    if element.GetTitle then title = element:GetTitle() or "" end
    if element.GetText then title = title .. " " .. (element:GetText() or "") end
    if element.GetName then title = title .. " " .. (element:GetName() or "") end
    
    -- Check parent hierarchy
    local parent = element:GetParent()
    while IsValid(parent) do
        if parent.GetTitle then
            title = title .. " " .. (parent:GetTitle() or "")
        end
        parent = parent:GetParent()
    end
    
    -- Check against ASC patterns
    title = string.lower(title)
    for _, pattern in ipairs(config.ASCPatterns) do
        if string.find(title, string.lower(pattern)) then
            return true
        end
    end
    
    -- Check if element has ASCThemed flag
    if element.ASCThemed then
        return true
    end
    
    return false
end

-- Queue element for theming
function ASC.VGUITheme.QueueElementForTheming(element)
    if not IsValid(element) then return end
    if ASC.VGUITheme.State.ThemedElements[element] then return end
    
    table.insert(ASC.VGUITheme.State.ProcessingQueue, element)
end

-- Process theming queue
function ASC.VGUITheme.ProcessThemingQueue()
    local currentTime = CurTime()
    if currentTime - ASC.VGUITheme.State.LastUpdate < ASC.VGUITheme.Config.UpdateInterval then
        return
    end
    
    local config = ASC.VGUITheme.Config
    local processed = 0
    local maxProcess = GetConVar("asc_vgui_performance_mode"):GetBool() and config.MaxElementsPerFrame or 999
    
    while #ASC.VGUITheme.State.ProcessingQueue > 0 and processed < maxProcess do
        local element = table.remove(ASC.VGUITheme.State.ProcessingQueue, 1)
        
        if IsValid(element) then
            ASC.VGUITheme.ApplyThemeToElement(element)
            processed = processed + 1
        end
    end
    
    ASC.VGUITheme.State.LastUpdate = currentTime
end

-- Apply theme to specific element
function ASC.VGUITheme.ApplyThemeToElement(element)
    if not IsValid(element) then return end
    if ASC.VGUITheme.State.ThemedElements[element] then return end
    
    local className = element:GetClassName()
    
    -- Apply theming based on element type
    if className == "DFrame" then
        ASC.VGUITheme.ThemeFrame(element)
    elseif className == "DButton" then
        ASC.VGUITheme.ThemeButton(element)
    elseif className == "DPanel" then
        ASC.VGUITheme.ThemePanel(element)
    elseif className == "DTextEntry" then
        ASC.VGUITheme.ThemeTextEntry(element)
    elseif className == "DLabel" then
        ASC.VGUITheme.ThemeLabel(element)
    elseif className == "DScrollPanel" then
        ASC.VGUITheme.ThemeScrollPanel(element)
    elseif className == "DComboBox" then
        ASC.VGUITheme.ThemeComboBox(element)
    elseif className == "DCheckBox" then
        ASC.VGUITheme.ThemeCheckBox(element)
    elseif className == "DSlider" then
        ASC.VGUITheme.ThemeSlider(element)
    end
    
    -- Mark as themed
    ASC.VGUITheme.State.ThemedElements[element] = true
    element.ASCThemed = true
    
    -- Theme child elements
    for _, child in pairs(element:GetChildren()) do
        if ASC.VGUITheme.ShouldThemeElement(child) then
            ASC.VGUITheme.QueueElementForTheming(child)
        end
    end
end

-- Theme DFrame elements
function ASC.VGUITheme.ThemeFrame(frame)
    if not IsValid(frame) then return end
    
    -- Store original paint function
    if not ASC.VGUITheme.State.OriginalPaintFunctions[frame] then
        ASC.VGUITheme.State.OriginalPaintFunctions[frame] = frame.Paint
    end
    
    -- Apply themed paint function
    frame.Paint = function(self, w, h)
        if ASC and ASC.ComprehensiveTheme then
            ASC.ComprehensiveTheme.DrawThemedFrame(self, w, h)
        else
            -- Fallback to original
            local original = ASC.VGUITheme.State.OriginalPaintFunctions[self]
            if original then original(self, w, h) end
        end
    end
end

-- Theme DButton elements
function ASC.VGUITheme.ThemeButton(button)
    if not IsValid(button) then return end
    
    -- Store original paint function
    if not ASC.VGUITheme.State.OriginalPaintFunctions[button] then
        ASC.VGUITheme.State.OriginalPaintFunctions[button] = button.Paint
    end
    
    -- Apply themed paint function
    button.Paint = function(self, w, h)
        if ASC and ASC.ComprehensiveTheme then
            ASC.ComprehensiveTheme.DrawThemedButton(self, w, h)
        else
            -- Fallback to original
            local original = ASC.VGUITheme.State.OriginalPaintFunctions[self]
            if original then original(self, w, h) end
        end
    end
    
    -- Override DoClick for sound effects
    local originalDoClick = button.DoClick
    button.DoClick = function(self)
        -- Play themed sound
        if GetConVar("asc_theme_sounds") and GetConVar("asc_theme_sounds"):GetBool() then
            surface.PlaySound("buttons/button15.wav")
        end
        
        -- Call original function
        if originalDoClick then originalDoClick(self) end
    end
end

-- Theme DPanel elements
function ASC.VGUITheme.ThemePanel(panel)
    if not IsValid(panel) then return end
    
    -- Store original paint function
    if not ASC.VGUITheme.State.OriginalPaintFunctions[panel] then
        ASC.VGUITheme.State.OriginalPaintFunctions[panel] = panel.Paint
    end
    
    -- Apply themed paint function
    panel.Paint = function(self, w, h)
        if ASC and ASC.ComprehensiveTheme then
            ASC.ComprehensiveTheme.DrawThemedPanel(self, w, h)
        else
            -- Fallback to original
            local original = ASC.VGUITheme.State.OriginalPaintFunctions[self]
            if original then original(self, w, h) end
        end
    end
end

-- Theme DTextEntry elements
function ASC.VGUITheme.ThemeTextEntry(textEntry)
    if not IsValid(textEntry) then return end
    
    -- Store original paint function
    if not ASC.VGUITheme.State.OriginalPaintFunctions[textEntry] then
        ASC.VGUITheme.State.OriginalPaintFunctions[textEntry] = textEntry.Paint
    end
    
    -- Apply themed paint function
    textEntry.Paint = function(self, w, h)
        if ASC and ASC.ComprehensiveTheme then
            local config = ASC.ComprehensiveTheme.Config
            
            -- Background
            draw.RoundedBox(config.BorderRadius.Small, 0, 0, w, h, config.Colors.Surface)
            
            -- Border
            local borderColor = self:HasFocus() and config.Colors.Accent or config.Colors.Border
            surface.SetDrawColor(borderColor)
            surface.DrawOutlinedRect(0, 0, w, h, 1)
            
            -- Draw text
            self:DrawTextEntryText(config.Colors.Text, config.Colors.Accent, config.Colors.Text)
        else
            -- Fallback to original
            local original = ASC.VGUITheme.State.OriginalPaintFunctions[self]
            if original then original(self, w, h) end
        end
    end
end

-- Theme DLabel elements
function ASC.VGUITheme.ThemeLabel(label)
    if not IsValid(label) then return end
    
    -- Apply themed text color
    if ASC and ASC.ComprehensiveTheme then
        local config = ASC.ComprehensiveTheme.Config
        label:SetTextColor(config.Colors.Text)
        
        -- Apply themed font if available
        if config.Fonts.Body then
            label:SetFont(config.Fonts.Body)
        end
    end
end

-- Theme DScrollPanel elements
function ASC.VGUITheme.ThemeScrollPanel(scrollPanel)
    if not IsValid(scrollPanel) then return end
    
    -- Theme the scroll panel background
    ASC.VGUITheme.ThemePanel(scrollPanel)
    
    -- Theme the scrollbar
    local vbar = scrollPanel:GetVBar()
    if IsValid(vbar) then
        ASC.VGUITheme.ThemeScrollBar(vbar)
    end
end

-- Theme scrollbar
function ASC.VGUITheme.ThemeScrollBar(scrollbar)
    if not IsValid(scrollbar) then return end
    
    if ASC and ASC.ComprehensiveTheme then
        local config = ASC.ComprehensiveTheme.Config
        
        scrollbar.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, config.Colors.Panel)
        end
        
        scrollbar.btnGrip.Paint = function(self, w, h)
            local bgColor = config.Colors.Secondary
            if self:IsHovered() then
                bgColor = config.Colors.Accent
            end
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
        end
        
        scrollbar.btnUp.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, config.Colors.Secondary)
        end
        
        scrollbar.btnDown.Paint = function(self, w, h)
            draw.RoundedBox(2, 0, 0, w, h, config.Colors.Secondary)
        end
    end
end

-- Theme DComboBox elements
function ASC.VGUITheme.ThemeComboBox(comboBox)
    if not IsValid(comboBox) then return end
    
    -- Theme similar to text entry
    ASC.VGUITheme.ThemeTextEntry(comboBox)
end

-- Theme DCheckBox elements
function ASC.VGUITheme.ThemeCheckBox(checkBox)
    if not IsValid(checkBox) then return end
    
    if ASC and ASC.ComprehensiveTheme then
        local config = ASC.ComprehensiveTheme.Config
        
        checkBox.Paint = function(self, w, h)
            local bgColor = self:GetChecked() and config.Colors.Success or config.Colors.Surface
            draw.RoundedBox(2, 0, 0, 16, 16, bgColor)
            
            surface.SetDrawColor(config.Colors.Border)
            surface.DrawOutlinedRect(0, 0, 16, 16, 1)
            
            if self:GetChecked() then
                surface.SetTextColor(config.Colors.Text)
                surface.SetFont("DermaDefault")
                surface.SetTextPos(4, 2)
                surface.DrawText("✓")
            end
        end
    end
end

-- Theme DSlider elements
function ASC.VGUITheme.ThemeSlider(slider)
    if not IsValid(slider) then return end
    
    if ASC and ASC.ComprehensiveTheme then
        local config = ASC.ComprehensiveTheme.Config
        
        slider.Paint = function(self, w, h)
            -- Track
            draw.RoundedBox(4, 0, h/2 - 2, w, 4, config.Colors.Panel)
            
            -- Knob
            local knobX = (w - 16) * self:GetSlideX()
            draw.RoundedBox(8, knobX, h/2 - 8, 16, 16, config.Colors.Accent)
        end
    end
end

-- Scan existing elements for theming
function ASC.VGUITheme.ScanExistingElements()
    if not GetConVar("asc_vgui_theme_enabled"):GetBool() then return end
    
    print("[Advanced Space Combat] Scanning existing VGUI elements for theming...")
    
    local function ScanPanel(panel)
        if IsValid(panel) then
            if ASC.VGUITheme.ShouldThemeElement(panel) then
                ASC.VGUITheme.QueueElementForTheming(panel)
            end
            
            for _, child in pairs(panel:GetChildren()) do
                ScanPanel(child)
            end
        end
    end
    
    -- Scan all top-level panels
    ScanPanel(vgui.GetWorldPanel())
    
    print("[Advanced Space Combat] VGUI element scan complete")
end

-- Console commands
concommand.Add("asc_vgui_rescan", function()
    ASC.VGUITheme.ScanExistingElements()
    print("[Advanced Space Combat] VGUI elements rescanned")
end)

concommand.Add("asc_vgui_clear_theme", function()
    ASC.VGUITheme.State.ThemedElements = {}
    ASC.VGUITheme.State.ProcessingQueue = {}
    print("[Advanced Space Combat] VGUI theme cache cleared")
end)

-- Initialize on client
hook.Add("Initialize", "ASC_VGUITheme_Init", function()
    ASC.VGUITheme.Initialize()
end)

print("[Advanced Space Combat] VGUI Theme Integration loaded successfully!")
