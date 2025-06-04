-- Advanced Space Combat - Advanced Derma Skin System v1.0.0
-- Based on Garry's Mod Derma skin creation best practices

if SERVER then return end

print("[Advanced Space Combat] Advanced Derma Skin System v1.0.0 - Loading...")

-- Initialize skin namespace
ASC = ASC or {}
ASC.DermaSkin = ASC.DermaSkin or {}

-- Create the skin table
local SKIN = {}

-- Skin information
SKIN.PrintName = "Advanced Space Combat"
SKIN.Author = "Advanced Space Combat Team"
SKIN.DermaVersion = 1
SKIN.GwenTexture = Material("asc/ui/derma_skin.png", "noclamp smooth")

-- Color definitions based on space theme
SKIN.Colours = {}

-- Text colors
SKIN.Colours.Window = {}
SKIN.Colours.Window.TitleActive = Color(200, 220, 255, 255)
SKIN.Colours.Window.TitleInactive = Color(150, 170, 200, 255)

SKIN.Colours.Button = {}
SKIN.Colours.Button.Normal = Color(200, 220, 255, 255)
SKIN.Colours.Button.Hover = Color(220, 240, 255, 255)
SKIN.Colours.Button.Down = Color(180, 200, 235, 255)
SKIN.Colours.Button.Disabled = Color(100, 120, 150, 255)

SKIN.Colours.Tab = {}
SKIN.Colours.Tab.Active = {}
SKIN.Colours.Tab.Active.Normal = Color(200, 220, 255, 255)
SKIN.Colours.Tab.Active.Hover = Color(220, 240, 255, 255)
SKIN.Colours.Tab.Active.Down = Color(180, 200, 235, 255)
SKIN.Colours.Tab.Active.Disabled = Color(100, 120, 150, 255)

SKIN.Colours.Tab.Inactive = {}
SKIN.Colours.Tab.Inactive.Normal = Color(150, 170, 200, 255)
SKIN.Colours.Tab.Inactive.Hover = Color(170, 190, 220, 255)
SKIN.Colours.Tab.Inactive.Down = Color(130, 150, 180, 255)
SKIN.Colours.Tab.Inactive.Disabled = Color(80, 100, 130, 255)

SKIN.Colours.Label = {}
SKIN.Colours.Label.Default = Color(200, 220, 255, 255)
SKIN.Colours.Label.Bright = Color(255, 255, 255, 255)
SKIN.Colours.Label.Dark = Color(100, 120, 150, 255)
SKIN.Colours.Label.Highlight = Color(100, 200, 255, 255)

-- Text entry colors
SKIN.colTextEntryText = Color(200, 220, 255, 255)
SKIN.colTextEntryTextHighlight = Color(100, 200, 255, 200)
SKIN.colTextEntryTextCursor = Color(100, 200, 255, 255)
SKIN.colTextEntryTextPlaceholder = Color(150, 170, 200, 200)

-- Texture definitions for UI elements
SKIN.tex = {}

-- Create texture functions
function SKIN.tex.Window(x, y, w, h)
    -- Draw space-themed window background
    surface.SetDrawColor(20, 30, 50, 240)
    surface.DrawRect(x, y, w, h)
    
    -- Draw border
    surface.SetDrawColor(100, 150, 255, 200)
    surface.DrawOutlinedRect(x, y, w, h, 2)
    
    -- Draw title bar gradient
    local gradient = Material("gui/gradient")
    surface.SetMaterial(gradient)
    surface.SetDrawColor(50, 80, 150, 200)
    surface.DrawTexturedRect(x, y, w, 25)
end

function SKIN.tex.Button(x, y, w, h, state)
    local colors = {
        normal = Color(40, 60, 100, 200),
        hover = Color(60, 90, 150, 220),
        down = Color(30, 50, 90, 240),
        disabled = Color(20, 30, 50, 150)
    }
    
    local color = colors[state] or colors.normal
    
    -- Draw button background
    surface.SetDrawColor(color)
    surface.DrawRect(x, y, w, h)
    
    -- Draw border
    surface.SetDrawColor(100, 150, 255, 150)
    surface.DrawOutlinedRect(x, y, w, h, 1)
    
    -- Draw highlight effect for hover/down states
    if state == "hover" or state == "down" then
        surface.SetDrawColor(100, 200, 255, 50)
        surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
    end
end

-- Paint functions for different elements
function SKIN:PaintFrame(panel, w, h)
    if panel.m_bPaintShadow then
        -- Draw shadow
        local wasEnabled = DisableClipping(true)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(-4, -4, w + 8, h + 8)
        DisableClipping(wasEnabled)
    end
    
    -- Draw window
    self.tex.Window(0, 0, w, h)
end

function SKIN:PaintButton(panel, w, h)
    local state = "normal"
    
    if not panel:IsEnabled() then
        state = "disabled"
    elseif panel:IsDown() then
        state = "down"
    elseif panel:IsHovered() then
        state = "hover"
    end
    
    self.tex.Button(0, 0, w, h, state)
end

function SKIN:PaintTab(panel, w, h)
    local active = panel:IsActive()
    local state = "normal"
    
    if not panel:IsEnabled() then
        state = "disabled"
    elseif panel:IsDown() then
        state = "down"
    elseif panel:IsHovered() then
        state = "hover"
    end
    
    -- Different colors for active/inactive tabs
    local baseColor = active and Color(60, 90, 150, 220) or Color(40, 60, 100, 180)
    
    if state == "hover" then
        baseColor = Color(baseColor.r + 20, baseColor.g + 20, baseColor.b + 20, baseColor.a)
    elseif state == "down" then
        baseColor = Color(baseColor.r - 10, baseColor.g - 10, baseColor.b - 10, baseColor.a)
    elseif state == "disabled" then
        baseColor = Color(baseColor.r / 2, baseColor.g / 2, baseColor.b / 2, baseColor.a / 2)
    end
    
    surface.SetDrawColor(baseColor)
    surface.DrawRect(0, 0, w, h)
    
    -- Draw border
    surface.SetDrawColor(100, 150, 255, 150)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintPanel(panel, w, h)
    if panel:GetPaintBackground() then
        surface.SetDrawColor(30, 45, 75, 200)
        surface.DrawRect(0, 0, w, h)
    end
end

function SKIN:PaintTextEntry(panel, w, h)
    local state = "normal"
    
    if not panel:IsEnabled() then
        state = "disabled"
    elseif panel:IsEditing() then
        state = "focus"
    end
    
    local colors = {
        normal = Color(20, 30, 50, 220),
        focus = Color(30, 45, 75, 240),
        disabled = Color(15, 25, 40, 150)
    }
    
    local color = colors[state] or colors.normal
    
    -- Draw background
    surface.SetDrawColor(color)
    surface.DrawRect(0, 0, w, h)
    
    -- Draw border
    local borderColor = state == "focus" and Color(100, 200, 255, 200) or Color(100, 150, 255, 150)
    surface.SetDrawColor(borderColor)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintScrollBar(panel, w, h)
    -- Draw track
    surface.SetDrawColor(20, 30, 50, 200)
    surface.DrawRect(0, 0, w, h)
    
    -- Draw border
    surface.SetDrawColor(100, 150, 255, 100)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintScrollBarGrip(panel, w, h)
    local state = "normal"
    
    if not panel:IsEnabled() then
        state = "disabled"
    elseif panel:IsDown() then
        state = "down"
    elseif panel:IsHovered() then
        state = "hover"
    end
    
    local colors = {
        normal = Color(60, 90, 150, 200),
        hover = Color(80, 120, 200, 220),
        down = Color(50, 80, 130, 240),
        disabled = Color(30, 45, 75, 150)
    }
    
    local color = colors[state] or colors.normal
    
    surface.SetDrawColor(color)
    surface.DrawRect(0, 0, w, h)
    
    -- Draw border
    surface.SetDrawColor(100, 150, 255, 150)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintProgress(panel, w, h)
    -- Draw background
    surface.SetDrawColor(20, 30, 50, 200)
    surface.DrawRect(0, 0, w, h)
    
    -- Draw progress
    local fraction = panel:GetFraction()
    if fraction > 0 then
        surface.SetDrawColor(100, 200, 255, 200)
        surface.DrawRect(0, 0, w * fraction, h)
    end
    
    -- Draw border
    surface.SetDrawColor(100, 150, 255, 150)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

-- Hook functions for different panel types
function SKIN:PaintListView(panel, w, h)
    surface.SetDrawColor(25, 35, 60, 220)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(100, 150, 255, 100)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

function SKIN:PaintTree(panel, w, h)
    if panel:GetDrawBackground() then
        surface.SetDrawColor(25, 35, 60, 200)
        surface.DrawRect(0, 0, w, h)
    end
end

function SKIN:PaintPropertySheet(panel, w, h)
    surface.SetDrawColor(30, 45, 75, 220)
    surface.DrawRect(0, 0, w, h)
    
    surface.SetDrawColor(100, 150, 255, 100)
    surface.DrawOutlinedRect(0, 0, w, h, 1)
end

-- Register the skin
derma.DefineSkin("AdvancedSpaceCombat", "Advanced Space Combat Theme", SKIN)

-- Auto-apply skin to ASC panels
ASC.DermaSkin.ApplyToPanel = function(panel)
    if IsValid(panel) then
        panel:SetSkin("AdvancedSpaceCombat")
        
        -- Apply to children recursively
        for _, child in ipairs(panel:GetChildren()) do
            ASC.DermaSkin.ApplyToPanel(child)
        end
    end
end

-- Hook to auto-apply skin to new ASC panels
hook.Add("VGUICreated", "ASC_AutoApplySkin", function(panel, name)
    if IsValid(panel) and (name:find("ASC") or name:find("asc_")) then
        timer.Simple(0, function()
            if IsValid(panel) then
                ASC.DermaSkin.ApplyToPanel(panel)
            end
        end)
    end
end)

-- Console command to apply skin to all panels
concommand.Add("asc_apply_skin", function()
    for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
        ASC.DermaSkin.ApplyToPanel(panel)
    end
    
    chat.AddText(Color(100, 200, 255), "[ASC] ", Color(255, 255, 255), "Advanced Space Combat skin applied to all panels")
end, nil, "Apply ASC skin to all VGUI panels")

print("[Advanced Space Combat] Advanced Derma Skin System loaded successfully!")
