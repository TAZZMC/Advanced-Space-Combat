-- Advanced Space Combat - Font Definitions (Client)
-- Professional font system for UI and HUD elements

print("[Advanced Space Combat] Font Definitions - Loading...")

-- Initialize font namespace
ASC = ASC or {}
ASC.Fonts = ASC.Fonts or {}

-- Font configuration
ASC.Fonts.Config = {
    EnableCustomFonts = true,
    EnableScaling = true,
    BaseScale = 1.0,
    MinScale = 0.5,
    MaxScale = 2.0
}

-- Font definitions
ASC.Fonts.Definitions = {
    -- UI Fonts
    {
        name = "ASC_UI_Title",
        font = "Roboto",
        size = 32,
        weight = 700,
        antialias = true,
        additive = false,
        shadow = true,
        outline = false
    },
    {
        name = "ASC_UI_Heading",
        font = "Roboto",
        size = 24,
        weight = 600,
        antialias = true,
        additive = false,
        shadow = true,
        outline = false
    },
    {
        name = "ASC_UI_Body",
        font = "Roboto",
        size = 16,
        weight = 400,
        antialias = true,
        additive = false,
        shadow = false,
        outline = false
    },
    {
        name = "ASC_UI_Small",
        font = "Roboto",
        size = 12,
        weight = 400,
        antialias = true,
        additive = false,
        shadow = false,
        outline = false
    },
    {
        name = "ASC_UI_Code",
        font = "Consolas",
        size = 14,
        weight = 400,
        antialias = true,
        additive = false,
        shadow = false,
        outline = false
    },
    
    -- HUD Fonts
    {
        name = "ASC_HUD_Large",
        font = "Orbitron",
        size = 28,
        weight = 700,
        antialias = true,
        additive = true,
        shadow = false,
        outline = true
    },
    {
        name = "ASC_HUD_Medium",
        font = "Orbitron",
        size = 20,
        weight = 600,
        antialias = true,
        additive = true,
        shadow = false,
        outline = true
    },
    {
        name = "ASC_HUD_Small",
        font = "Orbitron",
        size = 14,
        weight = 500,
        antialias = true,
        additive = true,
        shadow = false,
        outline = true
    },
    
    -- Technology-specific fonts
    {
        name = "ASC_Ancient",
        font = "Trajan Pro",
        size = 18,
        weight = 400,
        antialias = true,
        additive = true,
        shadow = false,
        outline = true
    },
    {
        name = "ASC_Asgard",
        font = "Eurostile",
        size = 16,
        weight = 500,
        antialias = true,
        additive = true,
        shadow = false,
        outline = true
    },
    {
        name = "ASC_Goauld",
        font = "Papyrus",
        size = 18,
        weight = 600,
        antialias = true,
        additive = true,
        shadow = true,
        outline = false
    },
    {
        name = "ASC_Wraith",
        font = "Impact",
        size = 16,
        weight = 700,
        antialias = true,
        additive = true,
        shadow = false,
        outline = true
    },
    {
        name = "ASC_Ori",
        font = "Times New Roman",
        size = 18,
        weight = 700,
        antialias = true,
        additive = true,
        shadow = true,
        outline = true
    },
    {
        name = "ASC_Tauri",
        font = "Arial",
        size = 16,
        weight = 600,
        antialias = true,
        additive = false,
        shadow = false,
        outline = true
    },
    
    -- Status and indicator fonts
    {
        name = "ASC_Status_Critical",
        font = "Impact",
        size = 20,
        weight = 900,
        antialias = true,
        additive = true,
        shadow = false,
        outline = true
    },
    {
        name = "ASC_Status_Warning",
        font = "Arial",
        size = 16,
        weight = 700,
        antialias = true,
        additive = true,
        shadow = false,
        outline = true
    },
    {
        name = "ASC_Status_Normal",
        font = "Arial",
        size = 14,
        weight = 500,
        antialias = true,
        additive = false,
        shadow = false,
        outline = false
    },
    
    -- Chat and notification fonts
    {
        name = "ASC_Chat_AI",
        font = "Segoe UI",
        size = 16,
        weight = 500,
        antialias = true,
        additive = false,
        shadow = true,
        outline = false
    },
    {
        name = "ASC_Notification",
        font = "Segoe UI",
        size = 14,
        weight = 600,
        antialias = true,
        additive = false,
        shadow = true,
        outline = false
    },
    
    -- Debug and console fonts
    {
        name = "ASC_Debug",
        font = "Courier New",
        size = 12,
        weight = 400,
        antialias = true,
        additive = false,
        shadow = false,
        outline = false
    },
    {
        name = "ASC_Console",
        font = "Consolas",
        size = 14,
        weight = 400,
        antialias = true,
        additive = false,
        shadow = false,
        outline = false
    }
}

-- Font scaling functions
function ASC.Fonts.GetScaledSize(baseSize)
    if not ASC.Fonts.Config.EnableScaling then
        return baseSize
    end
    
    local scale = ASC.Fonts.Config.BaseScale
    
    -- Adjust scale based on screen resolution
    local screenWidth = ScrW()
    if screenWidth < 1280 then
        scale = scale * 0.8
    elseif screenWidth > 1920 then
        scale = scale * 1.2
    end
    
    -- Apply scale limits
    scale = math.Clamp(scale, ASC.Fonts.Config.MinScale, ASC.Fonts.Config.MaxScale)
    
    return math.Round(baseSize * scale)
end

-- Font creation function
function ASC.Fonts.CreateFont(fontDef)
    local scaledSize = ASC.Fonts.GetScaledSize(fontDef.size)
    
    surface.CreateFont(fontDef.name, {
        font = fontDef.font,
        size = scaledSize,
        weight = fontDef.weight,
        antialias = fontDef.antialias,
        additive = fontDef.additive,
        shadow = fontDef.shadow,
        outline = fontDef.outline
    })
    
    -- Create scaled variants
    surface.CreateFont(fontDef.name .. "_Large", {
        font = fontDef.font,
        size = scaledSize * 1.5,
        weight = fontDef.weight,
        antialias = fontDef.antialias,
        additive = fontDef.additive,
        shadow = fontDef.shadow,
        outline = fontDef.outline
    })
    
    surface.CreateFont(fontDef.name .. "_Small", {
        font = fontDef.font,
        size = scaledSize * 0.75,
        weight = fontDef.weight,
        antialias = fontDef.antialias,
        additive = fontDef.additive,
        shadow = fontDef.shadow,
        outline = fontDef.outline
    })
end

-- Initialize all fonts
function ASC.Fonts.Initialize()
    if not ASC.Fonts.Config.EnableCustomFonts then
        print("[Advanced Space Combat] Custom fonts disabled")
        return
    end
    
    print("[Advanced Space Combat] Creating custom fonts...")
    
    for _, fontDef in ipairs(ASC.Fonts.Definitions) do
        ASC.Fonts.CreateFont(fontDef)
        print("[Advanced Space Combat] Created font: " .. fontDef.name)
    end
    
    print("[Advanced Space Combat] Font creation complete!")
end

-- Font utility functions
function ASC.Fonts.GetTechnologyFont(culture)
    local fontMap = {
        Ancient = "ASC_Ancient",
        Asgard = "ASC_Asgard",
        Goa_uld = "ASC_Goauld",
        Wraith = "ASC_Wraith",
        Ori = "ASC_Ori",
        Tau_ri = "ASC_Tauri"
    }
    
    return fontMap[culture] or "ASC_UI_Body"
end

function ASC.Fonts.GetStatusFont(status)
    if status == "Critical" or status == "Emergency" then
        return "ASC_Status_Critical"
    elseif status == "Warning" or status == "Damaged" then
        return "ASC_Status_Warning"
    else
        return "ASC_Status_Normal"
    end
end

function ASC.Fonts.GetUIFont(type, size)
    local baseFont = "ASC_UI_Body"
    
    if type == "title" then
        baseFont = "ASC_UI_Title"
    elseif type == "heading" then
        baseFont = "ASC_UI_Heading"
    elseif type == "body" then
        baseFont = "ASC_UI_Body"
    elseif type == "small" then
        baseFont = "ASC_UI_Small"
    elseif type == "code" then
        baseFont = "ASC_UI_Code"
    end
    
    if size == "large" then
        return baseFont .. "_Large"
    elseif size == "small" then
        return baseFont .. "_Small"
    else
        return baseFont
    end
end

function ASC.Fonts.GetHUDFont(size)
    if size == "large" then
        return "ASC_HUD_Large"
    elseif size == "medium" then
        return "ASC_HUD_Medium"
    elseif size == "small" then
        return "ASC_HUD_Small"
    else
        return "ASC_HUD_Medium"
    end
end

-- Font refresh function for resolution changes
function ASC.Fonts.RefreshFonts()
    print("[Advanced Space Combat] Refreshing fonts for resolution change...")
    ASC.Fonts.Initialize()
end

-- Hook for resolution changes
hook.Add("OnScreenSizeChanged", "ASC_FontRefresh", function()
    timer.Simple(0.1, function()
        ASC.Fonts.RefreshFonts()
    end)
end)

-- Initialize fonts on client load
hook.Add("Initialize", "ASC_FontInit", function()
    ASC.Fonts.Initialize()
end)

-- Console command for font testing
concommand.Add("asc_test_fonts", function()
    local testFrame = vgui.Create("DFrame")
    testFrame:SetSize(600, 400)
    testFrame:SetTitle("Advanced Space Combat - Font Test")
    testFrame:Center()
    testFrame:MakePopup()
    
    local scroll = vgui.Create("DScrollPanel", testFrame)
    scroll:Dock(FILL)
    
    local y = 10
    
    for _, fontDef in ipairs(ASC.Fonts.Definitions) do
        local label = vgui.Create("DLabel", scroll)
        label:SetPos(10, y)
        label:SetSize(580, 30)
        label:SetText(fontDef.name .. " - The quick brown fox jumps over the lazy dog")
        label:SetFont(fontDef.name)
        label:SetTextColor(Color(255, 255, 255))
        
        y = y + 35
    end
end)

print("[Advanced Space Combat] Font Definitions loaded successfully!")
