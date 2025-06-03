-- Advanced Space Combat - Character Theme System v1.0.0
-- Enhanced character UI theming with space combat aesthetics

print("[Advanced Space Combat] Character Theme System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.CharacterTheme = ASC.CharacterTheme or {}

-- Theme configuration
ASC.CharacterTheme.Config = {
    -- Enable/Disable Features
    EnableCharacterUI = true,
    EnablePlayerModelSelection = true,
    EnableCustomHUD = true,
    EnableSpaceSuitTheme = true,
    
    -- Visual Settings
    UseGlassmorphism = true,
    EnableAnimations = true,
    EnableParticleEffects = true,
    
    -- Color Scheme (Space Combat Theme)
    Colors = {
        Primary = Color(41, 128, 185, 240),      -- Space Blue
        Secondary = Color(52, 73, 94, 220),     -- Dark Blue-Gray
        Accent = Color(155, 89, 182, 255),      -- Purple Accent
        Success = Color(39, 174, 96, 255),      -- Green
        Warning = Color(243, 156, 18, 255),     -- Orange
        Danger = Color(231, 76, 60, 255),       -- Red
        Background = Color(23, 32, 42, 240),    -- Dark Background
        Surface = Color(30, 39, 46, 220),       -- Surface
        Text = Color(255, 255, 255, 255),       -- White Text
        TextSecondary = Color(178, 190, 195, 200), -- Light Gray
        Border = Color(99, 110, 114, 150),      -- Border
        Glow = Color(100, 150, 255, 100),       -- Blue Glow
        Energy = Color(0, 255, 255, 200),       -- Cyan Energy
        Shield = Color(100, 200, 255, 150),     -- Shield Blue
        Hull = Color(255, 100, 100, 200),       -- Hull Red
        Oxygen = Color(100, 255, 100, 200)      -- Oxygen Green
    },
    
    -- Fonts
    Fonts = {
        Title = "DermaLarge",
        Subtitle = "DermaDefaultBold", 
        Body = "DermaDefault",
        Small = "DermaDefault",
        HUD = "DermaDefaultBold"
    }
}

-- Character UI state
ASC.CharacterTheme.State = {
    PlayerModelMenuOpen = false,
    CharacterStatsVisible = false,
    SpaceSuitMode = false,
    LastHealthCheck = 0,
    Animations = {
        HealthBar = 100,
        ArmorBar = 100,
        OxygenBar = 100,
        EnergyBar = 100
    }
}

-- Available player models (space-themed)
ASC.CharacterTheme.PlayerModels = {
    {
        name = "Space Marine",
        model = "models/player/combine_soldier.mdl",
        description = "Heavy combat specialist"
    },
    {
        name = "Pilot",
        model = "models/player/kleiner.mdl", 
        description = "Ship pilot and navigator"
    },
    {
        name = "Engineer",
        model = "models/player/eli.mdl",
        description = "Technical specialist"
    },
    {
        name = "Commander",
        model = "models/player/breen.mdl",
        description = "Fleet commander"
    },
    {
        name = "Scientist",
        model = "models/player/mossman.mdl",
        description = "Research specialist"
    }
}

-- Initialize character theme
function ASC.CharacterTheme.Initialize()
    print("[Advanced Space Combat] Character theme initialized")
    
    -- Set up ConVars
    CreateClientConVar("asc_character_theme_enabled", "1", true, false, "Enable character theme system")
    CreateClientConVar("asc_spacesuit_mode", "0", true, false, "Enable space suit mode")
    CreateClientConVar("asc_show_character_stats", "1", true, false, "Show character statistics")
    
    -- Initialize fonts if needed
    ASC.CharacterTheme.CreateFonts()
end

-- Create custom fonts
function ASC.CharacterTheme.CreateFonts()
    surface.CreateFont("ASC_CharacterTitle", {
        font = "Arial",
        size = 24,
        weight = 700,
        antialias = true,
        shadow = true
    })
    
    surface.CreateFont("ASC_CharacterBody", {
        font = "Arial", 
        size = 16,
        weight = 500,
        antialias = true
    })
    
    surface.CreateFont("ASC_CharacterHUD", {
        font = "Arial",
        size = 18,
        weight = 600,
        antialias = true,
        shadow = true
    })
end

-- Draw enhanced health/armor display
function ASC.CharacterTheme.DrawHealthArmor()
    if not GetConVar("asc_show_character_stats"):GetBool() then return end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local config = ASC.CharacterTheme.Config
    local state = ASC.CharacterTheme.State
    
    local health = ply:Health()
    local maxHealth = ply:GetMaxHealth()
    local armor = ply:Armor()
    
    -- Animate bars
    state.Animations.HealthBar = Lerp(FrameTime() * 3, state.Animations.HealthBar, health)
    state.Animations.ArmorBar = Lerp(FrameTime() * 3, state.Animations.ArmorBar, armor)
    
    local scrW, scrH = ScrW(), ScrH()
    local barWidth = 200
    local barHeight = 20
    local x = 50
    local y = scrH - 120
    
    -- Health bar background
    draw.RoundedBox(8, x - 2, y - 2, barWidth + 4, barHeight + 4, Color(0, 0, 0, 150))
    
    -- Health bar
    local healthPercent = state.Animations.HealthBar / maxHealth
    local healthColor = config.Colors.Success
    if healthPercent < 0.3 then
        healthColor = config.Colors.Danger
    elseif healthPercent < 0.6 then
        healthColor = config.Colors.Warning
    end
    
    draw.RoundedBox(6, x, y, barWidth * healthPercent, barHeight, healthColor)
    
    -- Health text
    surface.SetFont("ASC_CharacterHUD")
    surface.SetTextColor(config.Colors.Text)
    surface.SetTextPos(x + 5, y + 2)
    surface.DrawText(string.format("Health: %d/%d", math.floor(state.Animations.HealthBar), maxHealth))
    
    -- Armor bar (if player has armor)
    if armor > 0 then
        y = y + 30
        
        -- Armor bar background
        draw.RoundedBox(8, x - 2, y - 2, barWidth + 4, barHeight + 4, Color(0, 0, 0, 150))
        
        -- Armor bar
        local armorPercent = state.Animations.ArmorBar / 100
        draw.RoundedBox(6, x, y, barWidth * armorPercent, barHeight, config.Colors.Primary)
        
        -- Armor text
        surface.SetTextPos(x + 5, y + 2)
        surface.DrawText(string.format("Armor: %d", math.floor(state.Animations.ArmorBar)))
    end
end

-- Draw space suit HUD elements
function ASC.CharacterTheme.DrawSpaceSuitHUD()
    if not GetConVar("asc_spacesuit_mode"):GetBool() then return end
    
    local config = ASC.CharacterTheme.Config
    local scrW, scrH = ScrW(), ScrH()
    
    -- Simulate oxygen and energy levels
    local oxygenLevel = 100 -- This would be networked from server in real implementation
    local energyLevel = 85
    
    local barWidth = 150
    local barHeight = 15
    local x = scrW - barWidth - 50
    local y = 50
    
    -- Oxygen bar
    draw.RoundedBox(6, x - 2, y - 2, barWidth + 4, barHeight + 4, Color(0, 0, 0, 150))
    draw.RoundedBox(4, x, y, barWidth * (oxygenLevel / 100), barHeight, config.Colors.Oxygen)
    
    surface.SetFont("ASC_CharacterBody")
    surface.SetTextColor(config.Colors.Text)
    surface.SetTextPos(x, y - 20)
    surface.DrawText(string.format("O2: %d%%", oxygenLevel))
    
    -- Energy bar
    y = y + 35
    draw.RoundedBox(6, x - 2, y - 2, barWidth + 4, barHeight + 4, Color(0, 0, 0, 150))
    draw.RoundedBox(4, x, y, barWidth * (energyLevel / 100), barHeight, config.Colors.Energy)
    
    surface.SetTextPos(x, y - 20)
    surface.DrawText(string.format("Energy: %d%%", energyLevel))
    
    -- Environmental status
    y = y + 50
    surface.SetTextPos(x, y)
    surface.DrawText("Environment: Space")
    
    y = y + 20
    surface.DrawText("Pressure: 0 atm")
    
    y = y + 20
    surface.DrawText("Temperature: -270°C")
end

-- Create player model selection menu
function ASC.CharacterTheme.CreatePlayerModelMenu()
    if ASC.CharacterTheme.State.PlayerModelMenuOpen then return end
    
    ASC.CharacterTheme.State.PlayerModelMenuOpen = true
    
    local config = ASC.CharacterTheme.Config
    local frame = vgui.Create("DFrame")
    frame:SetSize(600, 400)
    frame:Center()
    frame:SetTitle("Advanced Space Combat - Character Selection")
    frame:SetDraggable(true)
    frame:SetDeleteOnClose(true)
    frame:MakePopup()
    
    -- Custom paint function for space theme
    frame.Paint = function(self, w, h)
        draw.RoundedBox(12, 0, 0, w, h, config.Colors.Background)
        draw.RoundedBox(10, 2, 2, w - 4, h - 4, config.Colors.Surface)
        
        -- Title bar
        draw.RoundedBox(8, 5, 5, w - 10, 30, config.Colors.Primary)
        
        surface.SetFont("ASC_CharacterTitle")
        surface.SetTextColor(config.Colors.Text)
        local titleW, titleH = surface.GetTextSize("Character Selection")
        surface.SetTextPos(w/2 - titleW/2, 10)
        surface.DrawText("Character Selection")
    end
    
    frame.OnClose = function()
        ASC.CharacterTheme.State.PlayerModelMenuOpen = false
    end
    
    -- Model list
    local modelList = vgui.Create("DScrollPanel", frame)
    modelList:SetPos(20, 50)
    modelList:SetSize(560, 300)
    
    for i, modelData in ipairs(ASC.CharacterTheme.PlayerModels) do
        local modelPanel = vgui.Create("DPanel", modelList)
        modelPanel:SetSize(540, 60)
        modelPanel:Dock(TOP)
        modelPanel:DockMargin(0, 5, 0, 5)
        
        modelPanel.Paint = function(self, w, h)
            local bgColor = config.Colors.Surface
            if self:IsHovered() then
                bgColor = config.Colors.Primary
            end
            draw.RoundedBox(8, 0, 0, w, h, bgColor)
        end
        
        -- Model name
        local nameLabel = vgui.Create("DLabel", modelPanel)
        nameLabel:SetPos(10, 10)
        nameLabel:SetSize(200, 20)
        nameLabel:SetText(modelData.name)
        nameLabel:SetFont("ASC_CharacterBody")
        nameLabel:SetTextColor(config.Colors.Text)
        
        -- Description
        local descLabel = vgui.Create("DLabel", modelPanel)
        descLabel:SetPos(10, 30)
        descLabel:SetSize(300, 20)
        descLabel:SetText(modelData.description)
        descLabel:SetFont("DermaDefault")
        descLabel:SetTextColor(config.Colors.TextSecondary)
        
        -- Select button
        local selectBtn = vgui.Create("DButton", modelPanel)
        selectBtn:SetPos(450, 15)
        selectBtn:SetSize(80, 30)
        selectBtn:SetText("Select")
        selectBtn:SetFont("ASC_CharacterBody")
        
        selectBtn.Paint = function(self, w, h)
            local btnColor = config.Colors.Accent
            if self:IsHovered() then
                btnColor = Color(btnColor.r + 20, btnColor.g + 20, btnColor.b + 20, btnColor.a)
            end
            draw.RoundedBox(6, 0, 0, w, h, btnColor)
        end
        
        selectBtn.DoClick = function()
            -- Change player model (this would need server-side implementation)
            RunConsoleCommand("say", "Selected character: " .. modelData.name)
            frame:Close()
        end
    end
    
    -- Close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(500, 360)
    closeBtn:SetSize(80, 30)
    closeBtn:SetText("Close")
    closeBtn:SetFont("ASC_CharacterBody")
    
    closeBtn.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, config.Colors.Danger)
    end
    
    closeBtn.DoClick = function()
        frame:Close()
    end
end

-- Console command to open character menu
concommand.Add("asc_character_menu", function()
    ASC.CharacterTheme.CreatePlayerModelMenu()
end)

-- Hook into HUD painting
hook.Add("HUDPaint", "ASC_CharacterTheme", function()
    if not GetConVar("asc_character_theme_enabled"):GetBool() then return end
    
    ASC.CharacterTheme.DrawHealthArmor()
    ASC.CharacterTheme.DrawSpaceSuitHUD()
end)

-- Initialize on client
hook.Add("Initialize", "ASC_CharacterTheme_Init", function()
    ASC.CharacterTheme.Initialize()
end)

print("[Advanced Space Combat] Character Theme System loaded successfully!")
