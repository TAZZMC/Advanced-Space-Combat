-- Advanced Space Combat - Weapon Interface Theme System v1.0.0
-- Professional theming for all weapon control interfaces and panels

print("[Advanced Space Combat] Weapon Interface Theme System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.WeaponTheme = ASC.WeaponTheme or {}

-- Weapon interface theme configuration
ASC.WeaponTheme.Config = {
    -- Enable/Disable Features
    EnableWeaponPanels = true,
    EnableTargetingUI = true,
    EnableAmmoDisplays = true,
    EnableWeaponGroups = true,
    EnableTacticalDisplay = true,
    
    -- Visual Settings
    UseAdvancedEffects = true,
    EnableAnimations = true,
    EnableSoundFeedback = true,
    EnableHolographicStyle = true,
    
    -- Weapon-specific Colors
    Colors = {
        -- Weapon Type Colors
        PulseCannon = Color(100, 150, 255, 255),    -- Blue
        BeamWeapon = Color(255, 100, 100, 255),     -- Red
        TorpedoLauncher = Color(255, 200, 100, 255), -- Orange
        Railgun = Color(150, 255, 100, 255),        -- Green
        PlasmaCannon = Color(255, 100, 255, 255),   -- Magenta
        PointDefense = Color(100, 255, 255, 255),   -- Cyan
        
        -- Status Colors
        WeaponOnline = Color(39, 174, 96, 255),     -- Green
        WeaponOffline = Color(231, 76, 60, 255),    -- Red
        WeaponCharging = Color(243, 156, 18, 255),  -- Orange
        WeaponReady = Color(52, 152, 219, 255),     -- Blue
        WeaponCooldown = Color(155, 89, 182, 255),  -- Purple
        
        -- Targeting Colors
        TargetLocked = Color(255, 100, 100, 255),   -- Red
        TargetAcquiring = Color(255, 200, 100, 255), -- Orange
        NoTarget = Color(150, 150, 150, 255),       -- Gray
        FriendlyTarget = Color(100, 255, 100, 255), -- Green
        HostileTarget = Color(255, 100, 100, 255),  -- Red
        
        -- Ammo Colors
        AmmoFull = Color(39, 174, 96, 255),         -- Green
        AmmoMedium = Color(243, 156, 18, 255),      -- Orange
        AmmoLow = Color(231, 76, 60, 255),          -- Red
        AmmoEmpty = Color(100, 100, 100, 255),      -- Gray
        
        -- UI Colors
        Background = Color(23, 32, 42, 240),
        Surface = Color(30, 39, 46, 220),
        Panel = Color(37, 46, 56, 200),
        Text = Color(255, 255, 255, 255),
        TextSecondary = Color(178, 190, 195, 200),
        Border = Color(99, 110, 114, 150),
        Accent = Color(155, 89, 182, 255)
    },
    
    -- Layout Settings
    PanelWidth = 400,
    PanelHeight = 500,
    ButtonHeight = 30,
    ProgressBarHeight = 15,
    Spacing = 10,
    BorderRadius = 8
}

-- Weapon interface state
ASC.WeaponTheme.State = {
    ActiveWeaponPanels = {},
    WeaponData = {},
    TargetingData = {},
    LastUpdate = 0,
    UpdateInterval = 0.1,
    Animations = {}
}

-- Initialize weapon theme system
function ASC.WeaponTheme.Initialize()
    print("[Advanced Space Combat] Weapon interface theme initialized")
    
    -- Create ConVars
    CreateClientConVar("asc_weapon_theme_enabled", "1", true, false, "Enable weapon interface theming")
    CreateClientConVar("asc_weapon_holo_style", "1", true, false, "Enable holographic weapon displays")
    CreateClientConVar("asc_weapon_animations", "1", true, false, "Enable weapon interface animations")
    
    -- Initialize weapon interface hooks
    ASC.WeaponTheme.InitializeHooks()
end

-- Initialize hooks for weapon interfaces
function ASC.WeaponTheme.InitializeHooks()
    -- Hook into weapon interface creation
    hook.Add("ASC_WeaponInterfaceOpen", "ASC_WeaponTheme", function(weapon, weaponType)
        if GetConVar("asc_weapon_theme_enabled"):GetBool() then
            ASC.WeaponTheme.CreateWeaponInterface(weapon, weaponType)
        end
    end)
    
    -- Hook into weapon data updates
    hook.Add("ASC_WeaponDataUpdate", "ASC_WeaponTheme", function(weapon, data)
        ASC.WeaponTheme.UpdateWeaponData(weapon, data)
    end)
end

-- Create themed weapon interface
function ASC.WeaponTheme.CreateWeaponInterface(weapon, weaponType)
    if not IsValid(weapon) then return end
    
    local config = ASC.WeaponTheme.Config
    local weaponName = weapon:GetPrintName() or weapon:GetClass()
    
    -- Create main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(config.PanelWidth, config.PanelHeight)
    frame:SetTitle("")
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:SetDeleteOnClose(true)
    
    -- Custom paint function
    frame.Paint = function(self, w, h)
        ASC.WeaponTheme.DrawWeaponFrame(self, w, h, weaponType)
    end
    
    -- Store weapon reference
    frame.weapon = weapon
    frame.weaponType = weaponType
    
    -- Create interface elements
    ASC.WeaponTheme.CreateWeaponControls(frame, weapon, weaponType)
    ASC.WeaponTheme.CreateTargetingDisplay(frame, weapon)
    ASC.WeaponTheme.CreateAmmoDisplay(frame, weapon)
    ASC.WeaponTheme.CreateStatusDisplay(frame, weapon)
    
    -- Store panel reference
    ASC.WeaponTheme.State.ActiveWeaponPanels[weapon] = frame
    
    -- Close handler
    frame.OnClose = function()
        ASC.WeaponTheme.State.ActiveWeaponPanels[weapon] = nil
    end
    
    return frame
end

-- Draw weapon frame with weapon-specific styling
function ASC.WeaponTheme.DrawWeaponFrame(panel, w, h, weaponType)
    local config = ASC.WeaponTheme.Config
    local weaponColor = config.Colors[weaponType] or config.Colors.Accent
    
    -- Background with glassmorphism
    draw.RoundedBox(config.BorderRadius + 2, 0, 0, w, h, config.Colors.Background)
    draw.RoundedBox(config.BorderRadius, 2, 2, w - 4, h - 4, config.Colors.Surface)
    
    -- Weapon-specific colored border
    surface.SetDrawColor(weaponColor)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    
    -- Title bar with weapon type color
    draw.RoundedBox(config.BorderRadius - 2, 5, 5, w - 10, 35, weaponColor)
    
    -- Title text
    surface.SetFont("ASC_Subtitle")
    surface.SetTextColor(config.Colors.Text)
    local titleText = "WEAPON CONTROL - " .. string.upper(weaponType or "UNKNOWN")
    local titleW, titleH = surface.GetTextSize(titleText)
    surface.SetTextPos(w/2 - titleW/2, 12)
    surface.DrawText(titleText)
    
    -- Holographic effect
    if GetConVar("asc_weapon_holo_style"):GetBool() then
        local glowAlpha = math.sin(CurTime() * 3) * 30 + 50
        draw.RoundedBox(config.BorderRadius + 3, -2, -2, w + 4, h + 4,
            Color(weaponColor.r, weaponColor.g, weaponColor.b, glowAlpha))
    end
end

-- Create weapon control elements
function ASC.WeaponTheme.CreateWeaponControls(frame, weapon, weaponType)
    local config = ASC.WeaponTheme.Config
    local y = 50
    
    -- Weapon status label
    local statusLabel = vgui.Create("DLabel", frame)
    statusLabel:SetPos(10, y)
    statusLabel:SetSize(380, 25)
    statusLabel:SetFont("ASC_Body")
    statusLabel:SetTextColor(config.Colors.Text)
    statusLabel:SetText("Status: INITIALIZING...")
    
    y = y + 35
    
    -- Fire button
    local fireButton = vgui.Create("DButton", frame)
    fireButton:SetPos(10, y)
    fireButton:SetSize(120, config.ButtonHeight)
    fireButton:SetText("FIRE WEAPON")
    fireButton:SetFont("ASC_Button")
    
    fireButton.Paint = function(self, w, h)
        local bgColor = config.Colors.WeaponReady
        if self:IsHovered() then
            bgColor = Color(bgColor.r + 30, bgColor.g + 30, bgColor.b + 30, bgColor.a)
        end
        if self:IsDown() then
            bgColor = Color(bgColor.r - 30, bgColor.g - 30, bgColor.b - 30, bgColor.a)
        end
        
        draw.RoundedBox(config.BorderRadius - 2, 0, 0, w, h, bgColor)
        
        surface.SetFont("ASC_Button")
        surface.SetTextColor(config.Colors.Text)
        local textW, textH = surface.GetTextSize(self:GetText())
        surface.SetTextPos(w/2 - textW/2, h/2 - textH/2)
        surface.DrawText(self:GetText())
    end
    
    fireButton.DoClick = function()
        if IsValid(weapon) then
            -- Send fire command to weapon
            net.Start("ASC_WeaponFire")
            net.WriteEntity(weapon)
            net.SendToServer()
            
            -- Play sound
            surface.PlaySound("weapons/physcannon/energy_sing_explosion2.wav")
        end
    end
    
    -- Toggle power button
    local powerButton = vgui.Create("DButton", frame)
    powerButton:SetPos(140, y)
    powerButton:SetSize(120, config.ButtonHeight)
    powerButton:SetText("TOGGLE POWER")
    powerButton:SetFont("ASC_Button")
    
    powerButton.Paint = function(self, w, h)
        local isOnline = IsValid(weapon) and weapon:GetNWBool("WeaponOnline", true)
        local bgColor = isOnline and config.Colors.WeaponOnline or config.Colors.WeaponOffline
        
        if self:IsHovered() then
            bgColor = Color(bgColor.r + 20, bgColor.g + 20, bgColor.b + 20, bgColor.a)
        end
        
        draw.RoundedBox(config.BorderRadius - 2, 0, 0, w, h, bgColor)
        
        surface.SetFont("ASC_Button")
        surface.SetTextColor(config.Colors.Text)
        local textW, textH = surface.GetTextSize(self:GetText())
        surface.SetTextPos(w/2 - textW/2, h/2 - textH/2)
        surface.DrawText(self:GetText())
    end
    
    powerButton.DoClick = function()
        if IsValid(weapon) then
            -- Send power toggle command
            net.Start("ASC_WeaponTogglePower")
            net.WriteEntity(weapon)
            net.SendToServer()
        end
    end
    
    -- Auto-target button
    local autoButton = vgui.Create("DButton", frame)
    autoButton:SetPos(270, y)
    autoButton:SetSize(120, config.ButtonHeight)
    autoButton:SetText("AUTO TARGET")
    autoButton:SetFont("ASC_Button")
    
    autoButton.Paint = function(self, w, h)
        local autoTarget = IsValid(weapon) and weapon:GetNWBool("AutoTarget", false)
        local bgColor = autoTarget and config.Colors.TargetLocked or config.Colors.NoTarget
        
        if self:IsHovered() then
            bgColor = Color(bgColor.r + 20, bgColor.g + 20, bgColor.b + 20, bgColor.a)
        end
        
        draw.RoundedBox(config.BorderRadius - 2, 0, 0, w, h, bgColor)
        
        surface.SetFont("ASC_Button")
        surface.SetTextColor(config.Colors.Text)
        local textW, textH = surface.GetTextSize(self:GetText())
        surface.SetTextPos(w/2 - textW/2, h/2 - textH/2)
        surface.DrawText(self:GetText())
    end
    
    autoButton.DoClick = function()
        if IsValid(weapon) then
            -- Send auto-target toggle command
            net.Start("ASC_WeaponToggleAutoTarget")
            net.WriteEntity(weapon)
            net.SendToServer()
        end
    end
end

-- Create targeting display
function ASC.WeaponTheme.CreateTargetingDisplay(frame, weapon)
    local config = ASC.WeaponTheme.Config
    local y = 120
    
    -- Targeting section header
    local targetHeader = vgui.Create("DLabel", frame)
    targetHeader:SetPos(10, y)
    targetHeader:SetSize(380, 25)
    targetHeader:SetFont("ASC_Subtitle")
    targetHeader:SetTextColor(config.Colors.Text)
    targetHeader:SetText("TARGETING SYSTEM")
    
    y = y + 30
    
    -- Target display panel
    local targetPanel = vgui.Create("DPanel", frame)
    targetPanel:SetPos(10, y)
    targetPanel:SetSize(380, 100)
    
    targetPanel.Paint = function(self, w, h)
        draw.RoundedBox(config.BorderRadius - 2, 0, 0, w, h, config.Colors.Panel)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        -- Target information
        if IsValid(weapon) then
            local target = weapon:GetNWEntity("Target", NULL)
            local targetText = "NO TARGET ACQUIRED"
            local targetColor = config.Colors.NoTarget
            
            if IsValid(target) then
                targetText = "TARGET: " .. (target:GetClass() or "UNKNOWN")
                targetColor = config.Colors.TargetLocked
                
                -- Distance
                local distance = weapon:GetPos():Distance(target:GetPos())
                local distanceText = string.format("DISTANCE: %.0f units", distance)
                
                surface.SetFont("ASC_Small")
                surface.SetTextColor(config.Colors.TextSecondary)
                surface.SetTextPos(10, 30)
                surface.DrawText(distanceText)
                
                -- Target health (if applicable)
                if target.Health then
                    local healthText = string.format("TARGET HEALTH: %d", target:Health())
                    surface.SetTextPos(10, 50)
                    surface.DrawText(healthText)
                end
            end
            
            surface.SetFont("ASC_Body")
            surface.SetTextColor(targetColor)
            surface.SetTextPos(10, 10)
            surface.DrawText(targetText)
        end
    end
end

-- Create ammo display
function ASC.WeaponTheme.CreateAmmoDisplay(frame, weapon)
    local config = ASC.WeaponTheme.Config
    local y = 250
    
    -- Ammo section header
    local ammoHeader = vgui.Create("DLabel", frame)
    ammoHeader:SetPos(10, y)
    ammoHeader:SetSize(380, 25)
    ammoHeader:SetFont("ASC_Subtitle")
    ammoHeader:SetTextColor(config.Colors.Text)
    ammoHeader:SetText("AMMUNITION STATUS")
    
    y = y + 30
    
    -- Ammo display panel
    local ammoPanel = vgui.Create("DPanel", frame)
    ammoPanel:SetPos(10, y)
    ammoPanel:SetSize(380, 80)
    
    ammoPanel.Paint = function(self, w, h)
        draw.RoundedBox(config.BorderRadius - 2, 0, 0, w, h, config.Colors.Panel)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        if IsValid(weapon) then
            local ammo = weapon:GetNWInt("Ammo", 0)
            local maxAmmo = weapon:GetNWInt("MaxAmmo", 100)
            local ammoPercent = maxAmmo > 0 and (ammo / maxAmmo) or 0
            
            -- Ammo text
            local ammoText = string.format("AMMO: %d / %d", ammo, maxAmmo)
            surface.SetFont("ASC_Body")
            surface.SetTextColor(config.Colors.Text)
            surface.SetTextPos(10, 10)
            surface.DrawText(ammoText)
            
            -- Ammo bar
            local barY = 35
            local barWidth = w - 20
            local barHeight = config.ProgressBarHeight
            
            -- Background
            draw.RoundedBox(4, 10, barY, barWidth, barHeight, Color(50, 50, 50, 200))
            
            -- Ammo level
            local ammoColor = config.Colors.AmmoFull
            if ammoPercent < 0.25 then
                ammoColor = config.Colors.AmmoLow
            elseif ammoPercent < 0.5 then
                ammoColor = config.Colors.AmmoMedium
            end
            
            if ammoPercent > 0 then
                draw.RoundedBox(3, 11, barY + 1, (barWidth - 2) * ammoPercent, barHeight - 2, ammoColor)
            end
            
            -- Percentage text
            local percentText = string.format("%.0f%%", ammoPercent * 100)
            surface.SetFont("ASC_Small")
            surface.SetTextColor(config.Colors.Text)
            local textW, textH = surface.GetTextSize(percentText)
            surface.SetTextPos(w/2 - textW/2, barY + barHeight/2 - textH/2)
            surface.DrawText(percentText)
        end
    end
end

-- Create status display
function ASC.WeaponTheme.CreateStatusDisplay(frame, weapon)
    local config = ASC.WeaponTheme.Config
    local y = 360
    
    -- Status section header
    local statusHeader = vgui.Create("DLabel", frame)
    statusHeader:SetPos(10, y)
    statusHeader:SetSize(380, 25)
    statusHeader:SetFont("ASC_Subtitle")
    statusHeader:SetTextColor(config.Colors.Text)
    statusHeader:SetText("WEAPON STATUS")
    
    y = y + 30
    
    -- Status display panel
    local statusPanel = vgui.Create("DPanel", frame)
    statusPanel:SetPos(10, y)
    statusPanel:SetSize(380, 100)
    
    statusPanel.Paint = function(self, w, h)
        draw.RoundedBox(config.BorderRadius - 2, 0, 0, w, h, config.Colors.Panel)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        if IsValid(weapon) then
            local yPos = 10
            
            -- Power status
            local isOnline = weapon:GetNWBool("WeaponOnline", true)
            local powerText = "POWER: " .. (isOnline and "ONLINE" or "OFFLINE")
            local powerColor = isOnline and config.Colors.WeaponOnline or config.Colors.WeaponOffline
            
            surface.SetFont("ASC_Small")
            surface.SetTextColor(powerColor)
            surface.SetTextPos(10, yPos)
            surface.DrawText(powerText)
            yPos = yPos + 20
            
            -- Charge status
            local charge = weapon:GetNWFloat("Charge", 100)
            local chargeText = string.format("CHARGE: %.0f%%", charge)
            local chargeColor = charge > 75 and config.Colors.WeaponReady or 
                               charge > 25 and config.Colors.WeaponCharging or config.Colors.WeaponOffline
            
            surface.SetTextColor(chargeColor)
            surface.SetTextPos(10, yPos)
            surface.DrawText(chargeText)
            yPos = yPos + 20
            
            -- Temperature
            local temp = weapon:GetNWFloat("Temperature", 0)
            local tempText = string.format("TEMPERATURE: %.0f°C", temp)
            local tempColor = temp > 80 and config.Colors.WeaponOffline or config.Colors.Text
            
            surface.SetTextColor(tempColor)
            surface.SetTextPos(10, yPos)
            surface.DrawText(tempText)
            yPos = yPos + 20
            
            -- Fire rate
            local fireRate = weapon:GetNWFloat("FireRate", 1.0)
            local fireRateText = string.format("FIRE RATE: %.1f/sec", fireRate)
            
            surface.SetTextColor(config.Colors.TextSecondary)
            surface.SetTextPos(10, yPos)
            surface.DrawText(fireRateText)
        end
    end
end

-- Update weapon data
function ASC.WeaponTheme.UpdateWeaponData(weapon, data)
    if not IsValid(weapon) then return end
    
    ASC.WeaponTheme.State.WeaponData[weapon] = data
    
    -- Update any active panels for this weapon
    local panel = ASC.WeaponTheme.State.ActiveWeaponPanels[weapon]
    if IsValid(panel) then
        -- Panel will update automatically through Paint functions
    end
end

-- Console command to open weapon interface
concommand.Add("asc_weapon_interface", function(ply, cmd, args)
    local weapon = ply:GetEyeTrace().Entity
    if IsValid(weapon) and weapon:GetClass():find("weapon") then
        ASC.WeaponTheme.CreateWeaponInterface(weapon, "PulseCannon")
    else
        ply:ChatPrint("[Advanced Space Combat] No weapon found")
    end
end)

-- Initialize on client
hook.Add("Initialize", "ASC_WeaponTheme_Init", function()
    ASC.WeaponTheme.Initialize()
end)

print("[Advanced Space Combat] Weapon Interface Theme System loaded successfully!")
