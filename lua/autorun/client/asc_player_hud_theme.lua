-- Advanced Space Combat - Enhanced Player HUD Theme v1.0.0
-- Professional HUD theming with space combat aesthetics and real-time updates

print("[Advanced Space Combat] Enhanced Player HUD Theme v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.HUDTheme = ASC.HUDTheme or {}

-- HUD Configuration
ASC.HUDTheme.Config = {
    -- Enable/Disable Features
    EnableCustomHUD = true,
    EnableWeaponDisplay = true,
    EnableShipStatus = true,
    EnableMinimap = false, -- Would require additional implementation
    EnableCrosshair = true,
    EnableDamageIndicators = true,
    
    -- Visual Settings
    UseModernStyle = true,
    EnableAnimations = true,
    EnableGlowEffects = true,
    EnableParticles = false, -- Performance consideration
    
    -- Layout Settings
    HUDScale = 1.0,
    ElementSpacing = 10,
    CornerRadius = 8,
    BorderWidth = 2,
    
    -- Colors (matching ASC theme)
    Colors = {
        Primary = Color(41, 128, 185, 240),
        Secondary = Color(52, 73, 94, 220),
        Accent = Color(155, 89, 182, 255),
        Success = Color(39, 174, 96, 255),
        Warning = Color(243, 156, 18, 255),
        Danger = Color(231, 76, 60, 255),
        Background = Color(23, 32, 42, 200),
        Surface = Color(30, 39, 46, 180),
        Text = Color(255, 255, 255, 255),
        TextSecondary = Color(178, 190, 195, 200),
        Border = Color(99, 110, 114, 150),
        Glow = Color(100, 150, 255, 100),
        
        -- Status Colors
        Health = Color(39, 174, 96, 255),
        HealthLow = Color(231, 76, 60, 255),
        Armor = Color(41, 128, 185, 255),
        Ammo = Color(243, 156, 18, 255),
        AmmoLow = Color(231, 76, 60, 255),
        Energy = Color(155, 89, 182, 255),
        Shield = Color(100, 200, 255, 255)
    }
}

-- HUD State
ASC.HUDTheme.State = {
    LastUpdate = 0,
    UpdateInterval = 0.1, -- 10 FPS updates for smooth animations
    
    -- Animated values
    Health = 100,
    MaxHealth = 100,
    Armor = 0,
    Ammo = 0,
    MaxAmmo = 0,
    Clip = 0,
    MaxClip = 0,
    
    -- Animation states
    Animations = {
        HealthBar = 100,
        ArmorBar = 0,
        AmmoBar = 0,
        ClipBar = 0,
        CrosshairAlpha = 255,
        DamageFlash = 0
    },
    
    -- Damage tracking
    LastHealth = 100,
    DamageTime = 0,
    
    -- Weapon info
    WeaponName = "",
    WeaponClass = ""
}

-- Initialize HUD theme
function ASC.HUDTheme.Initialize()
    print("[Advanced Space Combat] HUD theme initialized")
    
    -- Create ConVars
    CreateClientConVar("asc_hud_enabled", "1", true, false, "Enable custom HUD")
    CreateClientConVar("asc_hud_scale", "1.0", true, false, "HUD scale factor")
    CreateClientConVar("asc_hud_animations", "1", true, false, "Enable HUD animations")
    CreateClientConVar("asc_crosshair_enabled", "1", true, false, "Enable custom crosshair")
    
    -- Initialize fonts
    ASC.HUDTheme.CreateFonts()
end

-- Create custom fonts for HUD
function ASC.HUDTheme.CreateFonts()
    local scale = GetConVar("asc_hud_scale"):GetFloat()
    
    surface.CreateFont("ASC_HUD_Large", {
        font = "Arial",
        size = math.floor(24 * scale),
        weight = 700,
        antialias = true,
        shadow = true
    })
    
    surface.CreateFont("ASC_HUD_Medium", {
        font = "Arial",
        size = math.floor(18 * scale),
        weight = 600,
        antialias = true,
        shadow = true
    })
    
    surface.CreateFont("ASC_HUD_Small", {
        font = "Arial",
        size = math.floor(14 * scale),
        weight = 500,
        antialias = true
    })
end

-- Update HUD data
function ASC.HUDTheme.UpdateData()
    local currentTime = CurTime()
    if currentTime - ASC.HUDTheme.State.LastUpdate < ASC.HUDTheme.State.UpdateInterval then
        return
    end
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local state = ASC.HUDTheme.State
    
    -- Update player stats
    local newHealth = ply:Health()
    state.MaxHealth = ply:GetMaxHealth()
    state.Armor = ply:Armor()
    
    -- Check for damage
    if newHealth < state.LastHealth then
        state.DamageTime = currentTime
        state.Animations.DamageFlash = 255
    end
    state.LastHealth = newHealth
    state.Health = newHealth
    
    -- Update weapon info
    local weapon = ply:GetActiveWeapon()
    if IsValid(weapon) then
        state.WeaponName = weapon:GetPrintName() or weapon:GetClass()
        state.WeaponClass = weapon:GetClass()
        state.Clip = weapon:Clip1()
        state.MaxClip = weapon:GetMaxClip1()
        state.Ammo = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
        state.MaxAmmo = 999 -- This would need to be determined based on weapon type
    else
        state.WeaponName = ""
        state.WeaponClass = ""
        state.Clip = 0
        state.MaxClip = 0
        state.Ammo = 0
    end
    
    state.LastUpdate = currentTime
end

-- Update animations
function ASC.HUDTheme.UpdateAnimations()
    if not GetConVar("asc_hud_animations"):GetBool() then return end
    
    local state = ASC.HUDTheme.State
    local frameTime = FrameTime()
    
    -- Smooth bar animations
    state.Animations.HealthBar = Lerp(frameTime * 5, state.Animations.HealthBar, state.Health)
    state.Animations.ArmorBar = Lerp(frameTime * 5, state.Animations.ArmorBar, state.Armor)
    state.Animations.AmmoBar = Lerp(frameTime * 5, state.Animations.AmmoBar, state.Ammo)
    state.Animations.ClipBar = Lerp(frameTime * 5, state.Animations.ClipBar, state.Clip)
    
    -- Damage flash fade
    if state.Animations.DamageFlash > 0 then
        state.Animations.DamageFlash = math.max(0, state.Animations.DamageFlash - frameTime * 500)
    end
    
    -- Crosshair pulse
    state.Animations.CrosshairAlpha = 200 + math.sin(CurTime() * 3) * 55
end

-- Draw health and armor bars
function ASC.HUDTheme.DrawHealthArmor()
    local config = ASC.HUDTheme.Config
    local state = ASC.HUDTheme.State
    local scale = GetConVar("asc_hud_scale"):GetFloat()
    
    local barWidth = math.floor(200 * scale)
    local barHeight = math.floor(20 * scale)
    local x = math.floor(20 * scale)
    local y = ScrH() - math.floor(100 * scale)
    
    -- Health bar background
    draw.RoundedBox(config.CornerRadius, x - 2, y - 2, barWidth + 4, barHeight + 4, 
        Color(0, 0, 0, 150))
    
    -- Health bar
    local healthPercent = state.Animations.HealthBar / state.MaxHealth
    local healthColor = config.Colors.Health
    if healthPercent < 0.3 then
        healthColor = config.Colors.HealthLow
    elseif healthPercent < 0.6 then
        healthColor = config.Colors.Warning
    end
    
    -- Add damage flash effect
    if state.Animations.DamageFlash > 0 then
        healthColor = Color(255, 255, 255, state.Animations.DamageFlash)
    end
    
    draw.RoundedBox(config.CornerRadius - 2, x, y, barWidth * healthPercent, barHeight, healthColor)
    
    -- Health text
    surface.SetFont("ASC_HUD_Medium")
    surface.SetTextColor(config.Colors.Text)
    surface.SetTextPos(x + 5, y + 2)
    surface.DrawText(string.format("Health: %d/%d", math.floor(state.Animations.HealthBar), state.MaxHealth))
    
    -- Armor bar (if player has armor)
    if state.Armor > 0 then
        y = y + math.floor(30 * scale)
        
        -- Armor bar background
        draw.RoundedBox(config.CornerRadius, x - 2, y - 2, barWidth + 4, barHeight + 4, 
            Color(0, 0, 0, 150))
        
        -- Armor bar
        local armorPercent = state.Animations.ArmorBar / 100
        draw.RoundedBox(config.CornerRadius - 2, x, y, barWidth * armorPercent, barHeight, 
            config.Colors.Armor)
        
        -- Armor text
        surface.SetTextPos(x + 5, y + 2)
        surface.DrawText(string.format("Armor: %d", math.floor(state.Animations.ArmorBar)))
    end
end

-- Draw weapon information
function ASC.HUDTheme.DrawWeaponInfo()
    if not GetConVar("asc_hud_enabled"):GetBool() or not config.EnableWeaponDisplay then return end
    
    local config = ASC.HUDTheme.Config
    local state = ASC.HUDTheme.State
    local scale = GetConVar("asc_hud_scale"):GetFloat()
    
    if state.WeaponName == "" then return end
    
    local scrW = ScrW()
    local scrH = ScrH()
    local panelWidth = math.floor(250 * scale)
    local panelHeight = math.floor(80 * scale)
    local x = scrW - panelWidth - math.floor(20 * scale)
    local y = scrH - math.floor(120 * scale)
    
    -- Background panel
    draw.RoundedBox(config.CornerRadius, x, y, panelWidth, panelHeight, config.Colors.Background)
    draw.RoundedBox(config.CornerRadius - 2, x + 2, y + 2, panelWidth - 4, panelHeight - 4, 
        config.Colors.Surface)
    
    -- Weapon name
    surface.SetFont("ASC_HUD_Medium")
    surface.SetTextColor(config.Colors.Text)
    surface.SetTextPos(x + 10, y + 10)
    surface.DrawText(state.WeaponName)
    
    -- Ammo information
    if state.MaxClip > 0 then
        -- Clip ammo
        local clipText = string.format("Clip: %d/%d", state.Clip, state.MaxClip)
        surface.SetFont("ASC_HUD_Small")
        surface.SetTextPos(x + 10, y + 35)
        surface.DrawText(clipText)
        
        -- Reserve ammo
        local ammoText = string.format("Ammo: %d", state.Ammo)
        surface.SetTextPos(x + 10, y + 55)
        surface.DrawText(ammoText)
        
        -- Ammo bars
        local barWidth = math.floor(100 * scale)
        local barHeight = math.floor(8 * scale)
        local barX = x + panelWidth - barWidth - 10
        
        -- Clip bar
        local clipY = y + 35
        draw.RoundedBox(4, barX - 1, clipY - 1, barWidth + 2, barHeight + 2, Color(0, 0, 0, 150))
        
        local clipPercent = state.MaxClip > 0 and (state.Animations.ClipBar / state.MaxClip) or 0
        local clipColor = clipPercent < 0.3 and config.Colors.AmmoLow or config.Colors.Ammo
        draw.RoundedBox(2, barX, clipY, barWidth * clipPercent, barHeight, clipColor)
    else
        -- Direct ammo (no clip)
        local ammoText = string.format("Ammo: %d", state.Ammo)
        surface.SetFont("ASC_HUD_Small")
        surface.SetTextPos(x + 10, y + 45)
        surface.DrawText(ammoText)
    end
end

-- Draw custom crosshair
function ASC.HUDTheme.DrawCrosshair()
    if not GetConVar("asc_crosshair_enabled"):GetBool() then return end
    
    local config = ASC.HUDTheme.Config
    local state = ASC.HUDTheme.State
    local scale = GetConVar("asc_hud_scale"):GetFloat()
    
    local scrW, scrH = ScrW(), ScrH()
    local centerX, centerY = scrW / 2, scrH / 2
    local size = math.floor(10 * scale)
    local thickness = math.floor(2 * scale)
    
    local alpha = state.Animations.CrosshairAlpha
    local color = Color(config.Colors.Accent.r, config.Colors.Accent.g, config.Colors.Accent.b, alpha)
    
    -- Draw crosshair lines
    surface.SetDrawColor(color)
    
    -- Horizontal line
    surface.DrawRect(centerX - size, centerY - thickness/2, size * 2, thickness)
    
    -- Vertical line  
    surface.DrawRect(centerX - thickness/2, centerY - size, thickness, size * 2)
    
    -- Center dot
    surface.DrawRect(centerX - 1, centerY - 1, 2, 2)
end

-- Main HUD drawing function
function ASC.HUDTheme.DrawHUD()
    if not GetConVar("asc_hud_enabled"):GetBool() then return end
    
    ASC.HUDTheme.UpdateData()
    ASC.HUDTheme.UpdateAnimations()
    
    ASC.HUDTheme.DrawHealthArmor()
    ASC.HUDTheme.DrawWeaponInfo()
    ASC.HUDTheme.DrawCrosshair()
end

-- Hook into HUD painting
hook.Add("HUDPaint", "ASC_HUDTheme", function()
    ASC.HUDTheme.DrawHUD()
end)

-- Hide default HUD elements when custom HUD is enabled
hook.Add("HUDShouldDraw", "ASC_HUDTheme_HideDefault", function(name)
    if not GetConVar("asc_hud_enabled"):GetBool() then return end
    
    local hideElements = {
        "CHudHealth",
        "CHudBattery", 
        "CHudAmmo",
        "CHudSecondaryAmmo",
        "CHudCrosshair"
    }
    
    for _, element in ipairs(hideElements) do
        if name == element then
            return false
        end
    end
end)

-- Console command to toggle HUD
concommand.Add("asc_toggle_hud", function()
    local current = GetConVar("asc_hud_enabled"):GetBool()
    RunConsoleCommand("asc_hud_enabled", current and "0" or "1")
    print("[Advanced Space Combat] Custom HUD " .. (current and "disabled" or "enabled"))
end)

-- Initialize on client
hook.Add("Initialize", "ASC_HUDTheme_Init", function()
    ASC.HUDTheme.Initialize()
end)

print("[Advanced Space Combat] Enhanced Player HUD Theme loaded successfully!")
