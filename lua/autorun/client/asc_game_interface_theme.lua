-- Advanced Space Combat - Game Interface Theme System v1.0.0
-- Comprehensive theming for all game interfaces including spawn menu, chat, console, etc.

print("[Advanced Space Combat] Game Interface Theme System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.GameTheme = ASC.GameTheme or {}

-- Game interface theme configuration
ASC.GameTheme.Config = {
    -- Enable/Disable Features
    EnableSpawnMenuTheming = true,
    EnableContextMenuTheming = true,
    EnableChatTheming = true,
    EnableConsoleTheming = true,
    EnableNotificationTheming = true,
    EnableScoreboardTheming = true,
    EnableSettingsMenuTheming = true,
    
    -- Visual Settings
    UseGlassmorphism = true,
    EnableAnimations = true,
    EnableSoundEffects = true,
    EnableGlowEffects = true,
    
    -- Layout Settings
    BorderRadius = {
        Small = 4,
        Medium = 8,
        Large = 12,
        XLarge = 16
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
        
        -- Game-specific colors
        SpawnMenu = Color(41, 128, 185, 230),
        Chat = Color(30, 39, 46, 200),
        Console = Color(23, 32, 42, 250),
        Notification = Color(155, 89, 182, 220),
        Scoreboard = Color(52, 73, 94, 240)
    },
    
    -- Fonts
    Fonts = {
        Title = "ASC_Title",
        Subtitle = "ASC_Subtitle", 
        Body = "ASC_Body",
        Small = "ASC_Small",
        Console = "ASC_Console"
    }
}

-- Game theme state
ASC.GameTheme.State = {
    SpawnMenuOpen = false,
    ContextMenuOpen = false,
    ChatOpen = false,
    ConsoleOpen = false,
    ScoreboardOpen = false,
    ThemedPanels = {},
    LastUpdate = 0
}

-- Initialize game theme system
function ASC.GameTheme.Initialize()
    print("[Advanced Space Combat] Game interface theme initialized")

    -- ConVars are now managed centrally by ASC.ConVarManager

    -- Create fonts
    ASC.GameTheme.CreateFonts()

    -- Initialize hooks
    ASC.GameTheme.InitializeHooks()

    -- Initialize theming systems
    ASC.GameTheme.InitializeSpawnMenuTheming()
    ASC.GameTheme.InitializeContextMenuTheming()
    ASC.GameTheme.InitializeChatTheming()
    ASC.GameTheme.InitializeConsoleTheming()
    ASC.GameTheme.InitializeNotificationTheming()
    ASC.GameTheme.InitializeScoreboardTheming()

    -- Apply notification theming immediately
    ASC.GameTheme.ApplyNotificationTheming()
end

-- Create custom fonts
function ASC.GameTheme.CreateFonts()
    surface.CreateFont("ASC_GameTitle", {
        font = "Roboto",
        size = 24,
        weight = 700,
        antialias = true,
        shadow = true
    })
    
    surface.CreateFont("ASC_GameSubtitle", {
        font = "Roboto",
        size = 18,
        weight = 600,
        antialias = true
    })
    
    surface.CreateFont("ASC_GameBody", {
        font = "Roboto",
        size = 14,
        weight = 400,
        antialias = true
    })
    
    surface.CreateFont("ASC_GameSmall", {
        font = "Roboto",
        size = 12,
        weight = 400,
        antialias = true
    })
    
    surface.CreateFont("ASC_GameConsole", {
        font = "Consolas",
        size = 14,
        weight = 400,
        antialias = true
    })
end

-- Initialize hooks
function ASC.GameTheme.InitializeHooks()
    -- Hook into spawn menu
    hook.Add("SpawnMenuOpen", "ASC_GameTheme_SpawnMenu", function()
        ASC.GameTheme.State.SpawnMenuOpen = true
        if GetConVar("asc_theme_spawn_menu"):GetBool() then
            timer.Simple(0.1, function()
                ASC.GameTheme.ApplySpawnMenuTheming()
            end)
        end
    end)
    
    hook.Add("SpawnMenuClose", "ASC_GameTheme_SpawnMenuClose", function()
        ASC.GameTheme.State.SpawnMenuOpen = false
    end)
    
    -- Hook into context menu
    hook.Add("OnContextMenuOpen", "ASC_GameTheme_ContextMenu", function()
        ASC.GameTheme.State.ContextMenuOpen = true
        if GetConVar("asc_theme_context_menu"):GetBool() then
            timer.Simple(0.05, function()
                ASC.GameTheme.ApplyContextMenuTheming()
            end)
        end
    end)
    
    hook.Add("OnContextMenuClose", "ASC_GameTheme_ContextMenuClose", function()
        ASC.GameTheme.State.ContextMenuOpen = false
    end)
    
    -- Hook into chat
    hook.Add("StartChat", "ASC_GameTheme_ChatOpen", function()
        ASC.GameTheme.State.ChatOpen = true
        if GetConVar("asc_theme_chat"):GetBool() then
            timer.Simple(0.05, function()
                ASC.GameTheme.ApplyChatTheming()
            end)
        end
    end)
    
    hook.Add("FinishChat", "ASC_GameTheme_ChatClose", function()
        ASC.GameTheme.State.ChatOpen = false
    end)
    
    -- Hook into scoreboard
    hook.Add("ScoreboardShow", "ASC_GameTheme_ScoreboardOpen", function()
        ASC.GameTheme.State.ScoreboardOpen = true
        if GetConVar("asc_theme_scoreboard"):GetBool() then
            timer.Simple(0.05, function()
                ASC.GameTheme.ApplyScoreboardTheming()
            end)
        end
    end)
    
    hook.Add("ScoreboardHide", "ASC_GameTheme_ScoreboardClose", function()
        ASC.GameTheme.State.ScoreboardOpen = false
    end)
end

-- Initialize spawn menu theming
function ASC.GameTheme.InitializeSpawnMenuTheming()
    print("[Advanced Space Combat] Spawn menu theming initialized")
end

-- Initialize context menu theming
function ASC.GameTheme.InitializeContextMenuTheming()
    print("[Advanced Space Combat] Context menu theming initialized")
end

-- Initialize chat theming
function ASC.GameTheme.InitializeChatTheming()
    print("[Advanced Space Combat] Chat theming initialized")
end

-- Initialize console theming
function ASC.GameTheme.InitializeConsoleTheming()
    print("[Advanced Space Combat] Console theming initialized")
end

-- Initialize notification theming
function ASC.GameTheme.InitializeNotificationTheming()
    print("[Advanced Space Combat] Notification theming initialized")
end

-- Initialize scoreboard theming
function ASC.GameTheme.InitializeScoreboardTheming()
    print("[Advanced Space Combat] Scoreboard theming initialized")
end

-- Apply spawn menu theming
function ASC.GameTheme.ApplySpawnMenuTheming()
    if not GetConVar("asc_theme_spawn_menu"):GetBool() then return end
    
    local spawnMenu = g_SpawnMenu
    if not IsValid(spawnMenu) then return end
    
    -- Theme the spawn menu
    ASC.GameTheme.ThemePanel(spawnMenu, "SpawnMenu")
    
    -- Theme spawn menu children
    local function ThemeSpawnMenuChildren(panel)
        if not IsValid(panel) then return end
        
        for _, child in pairs(panel:GetChildren()) do
            ASC.GameTheme.ThemePanel(child, "SpawnMenuChild")
            ThemeSpawnMenuChildren(child)
        end
    end
    
    ThemeSpawnMenuChildren(spawnMenu)
    
    print("[Advanced Space Combat] Spawn menu themed")
end

-- Apply context menu theming
function ASC.GameTheme.ApplyContextMenuTheming()
    if not GetConVar("asc_theme_context_menu"):GetBool() then return end
    
    -- Find and theme context menu panels
    local function FindAndThemeContextMenus(panel)
        if not IsValid(panel) then return end
        
        local className = panel:GetClassName()
        if className == "DMenu" or className == "DMenuOption" then
            ASC.GameTheme.ThemePanel(panel, "ContextMenu")
        end
        
        for _, child in pairs(panel:GetChildren()) do
            FindAndThemeContextMenus(child)
        end
    end
    
    FindAndThemeContextMenus(vgui.GetWorldPanel())
    
    print("[Advanced Space Combat] Context menu themed")
end

-- Apply chat theming
function ASC.GameTheme.ApplyChatTheming()
    if not GetConVar("asc_theme_chat"):GetBool() then return end
    
    -- Find and theme chat panels
    local function FindAndThemeChatPanels(panel)
        if not IsValid(panel) then return end
        
        local className = panel:GetClassName()
        if className == "ChatBox" or className == "RichText" or 
           (className == "DTextEntry" and panel:GetParent() and 
            panel:GetParent():GetClassName() == "ChatBox") then
            ASC.GameTheme.ThemePanel(panel, "Chat")
        end
        
        for _, child in pairs(panel:GetChildren()) do
            FindAndThemeChatPanels(child)
        end
    end
    
    FindAndThemeChatPanels(vgui.GetWorldPanel())
    
    print("[Advanced Space Combat] Chat themed")
end

-- Apply scoreboard theming
function ASC.GameTheme.ApplyScoreboardTheming()
    if not GetConVar("asc_theme_scoreboard"):GetBool() then return end
    
    -- Find and theme scoreboard panels
    local function FindAndThemeScoreboardPanels(panel)
        if not IsValid(panel) then return end
        
        local className = panel:GetClassName()
        if className == "ScoreBoard" or string.find(className:lower(), "score") then
            ASC.GameTheme.ThemePanel(panel, "Scoreboard")
        end
        
        for _, child in pairs(panel:GetChildren()) do
            FindAndThemeScoreboardPanels(child)
        end
    end
    
    FindAndThemeScoreboardPanels(vgui.GetWorldPanel())
    
    print("[Advanced Space Combat] Scoreboard themed")
end

-- Theme a panel based on type
function ASC.GameTheme.ThemePanel(panel, panelType)
    if not IsValid(panel) then return end
    if panel.ASCGameThemed then return end -- Already themed

    local config = ASC.GameTheme.Config
    panel.ASCGameThemed = true

    -- Store original paint function
    local originalPaint = panel.Paint

    -- Apply themed paint function
    panel.Paint = function(self, w, h)
        local success, err = pcall(function()
            ASC.GameTheme.DrawThemedPanel(self, w, h, panelType)
        end)

        if not success then
            -- Fallback to original or basic styling
            if originalPaint then
                originalPaint(self, w, h)
            else
                draw.RoundedBox(4, 0, 0, w, h, config.Colors.Surface)
            end
        end
    end

    -- Mark in state
    ASC.GameTheme.State.ThemedPanels[panel] = panelType
end

-- Draw themed panel
function ASC.GameTheme.DrawThemedPanel(panel, w, h, panelType)
    local config = ASC.GameTheme.Config
    local colors = config.Colors

    -- Get panel-specific colors
    local bgColor = colors.Surface
    local borderColor = colors.Border
    local radius = config.BorderRadius.Medium

    if panelType == "SpawnMenu" then
        bgColor = colors.SpawnMenu
        radius = config.BorderRadius.Large
    elseif panelType == "ContextMenu" then
        bgColor = colors.Panel
        radius = config.BorderRadius.Small
    elseif panelType == "Chat" then
        bgColor = colors.Chat
        radius = config.BorderRadius.Medium
    elseif panelType == "Scoreboard" then
        bgColor = colors.Scoreboard
        radius = config.BorderRadius.Large
    end

    -- Background with glassmorphism effect
    if config.UseGlassmorphism then
        draw.RoundedBox(radius + 2, 0, 0, w, h, Color(bgColor.r, bgColor.g, bgColor.b, bgColor.a * 0.8))
        draw.RoundedBox(radius, 2, 2, w - 4, h - 4, Color(bgColor.r + 10, bgColor.g + 10, bgColor.b + 10, bgColor.a * 0.6))
    else
        draw.RoundedBox(radius, 0, 0, w, h, bgColor)
    end

    -- Border
    surface.SetDrawColor(borderColor)
    surface.DrawOutlinedRect(0, 0, w, h, 1)

    -- Glow effect
    if config.EnableGlowEffects then
        local glowAlpha = math.sin(CurTime() * 2) * 20 + 30
        surface.SetDrawColor(Color(colors.Glow.r, colors.Glow.g, colors.Glow.b, glowAlpha))
        surface.DrawOutlinedRect(-1, -1, w + 2, h + 2, 1)
    end
end

-- Apply notification theming
function ASC.GameTheme.ApplyNotificationTheming()
    -- Check if ConVar exists before using it
    local notifConVar = GetConVar("asc_theme_notifications")
    if not notifConVar or not notifConVar:GetBool() then return end

    -- Hook into notification system
    local originalNotification = notification.AddLegacy
    if originalNotification then
        notification.AddLegacy = function(text, type, length)
            -- Create custom themed notification
            ASC.GameTheme.CreateThemedNotification(text, type, length)

            -- Also call original for compatibility
            return originalNotification(text, type, length)
        end
    end
end

-- Create themed notification
function ASC.GameTheme.CreateThemedNotification(text, notifType, length)
    local config = ASC.GameTheme.Config

    -- Create notification panel
    local notif = vgui.Create("DPanel")
    notif:SetSize(400, 60)
    notif:SetPos(ScrW() - 420, 20)

    -- Get notification color based on type
    local bgColor = config.Colors.Notification
    if notifType == NOTIFY_ERROR then
        bgColor = config.Colors.Danger
    elseif notifType == NOTIFY_UNDO then
        bgColor = config.Colors.Warning
    elseif notifType == NOTIFY_HINT then
        bgColor = config.Colors.Success
    end

    notif.Paint = function(self, w, h)
        draw.RoundedBox(config.BorderRadius.Medium, 0, 0, w, h, bgColor)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        -- Text
        surface.SetFont("ASC_GameBody")
        surface.SetTextColor(config.Colors.Text)
        local textW, textH = surface.GetTextSize(text)
        surface.SetTextPos(w/2 - textW/2, h/2 - textH/2)
        surface.DrawText(text)
    end

    -- Auto-remove after length
    timer.Simple(length or 4, function()
        if IsValid(notif) then
            notif:Remove()
        end
    end)
end

-- Console commands
concommand.Add("asc_theme_reload", function()
    ASC.GameTheme.Initialize()
    print("[Advanced Space Combat] Game theme reloaded")
end)

concommand.Add("asc_theme_spawn_menu", function()
    ASC.GameTheme.ApplySpawnMenuTheming()
end)

concommand.Add("asc_theme_context_menu", function()
    ASC.GameTheme.ApplyContextMenuTheming()
end)

concommand.Add("asc_theme_chat", function()
    ASC.GameTheme.ApplyChatTheming()
end)

concommand.Add("asc_theme_scoreboard", function()
    ASC.GameTheme.ApplyScoreboardTheming()
end)

concommand.Add("asc_theme_enable_all", function()
    -- Enable all theming systems
    RunConsoleCommand("asc_vgui_theme_enabled", "1")
    RunConsoleCommand("asc_vgui_theme_all", "1")
    RunConsoleCommand("asc_theme_spawn_menu", "1")
    RunConsoleCommand("asc_theme_context_menu", "1")
    RunConsoleCommand("asc_theme_chat", "1")
    RunConsoleCommand("asc_theme_console", "1")
    RunConsoleCommand("asc_theme_notifications", "1")
    RunConsoleCommand("asc_theme_scoreboard", "1")
    RunConsoleCommand("asc_game_theme_enabled", "1")
    RunConsoleCommand("asc_game_theme_glassmorphism", "1")
    RunConsoleCommand("asc_game_theme_animations", "1")
    RunConsoleCommand("asc_game_theme_glow", "1")

    -- Reload all theme systems
    ASC.GameTheme.Initialize()
    if ASC.VGUITheme then ASC.VGUITheme.Initialize() end
    if ASC.ComprehensiveTheme then ASC.ComprehensiveTheme.Initialize() end

    print("[Advanced Space Combat] All theme systems enabled and reloaded!")
    print("The Advanced Space Combat theme is now applied to the entire game.")
    print("Use 'asc_theme_disable_all' to disable theming.")
end)

concommand.Add("asc_theme_disable_all", function()
    -- Disable all theming systems
    RunConsoleCommand("asc_vgui_theme_enabled", "0")
    RunConsoleCommand("asc_vgui_theme_all", "0")
    RunConsoleCommand("asc_theme_spawn_menu", "0")
    RunConsoleCommand("asc_theme_context_menu", "0")
    RunConsoleCommand("asc_theme_chat", "0")
    RunConsoleCommand("asc_theme_console", "0")
    RunConsoleCommand("asc_theme_notifications", "0")
    RunConsoleCommand("asc_theme_scoreboard", "0")
    RunConsoleCommand("asc_game_theme_enabled", "0")

    print("[Advanced Space Combat] All theme systems disabled.")
    print("Restart the game or reload the map to fully remove theming.")
end)

-- Initialize on client
hook.Add("Initialize", "ASC_GameTheme_Init", function()
    ASC.GameTheme.Initialize()
end)

print("[Advanced Space Combat] Game Interface Theme System loaded successfully!")
