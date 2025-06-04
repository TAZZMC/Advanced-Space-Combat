-- Advanced Space Combat - Advanced HUD System v6.0.0
-- Next-generation HUD with modern design, performance optimization, and accessibility
-- Research-based implementation following 2025 HUD design best practices

print("[Advanced Space Combat] Advanced HUD System v6.0.0 - Next-Generation Interface Loading...")

-- Initialize HUD namespace
ASC = ASC or {}
ASC.HUD = ASC.HUD or {}

-- Modern HUD configuration
ASC.HUD.Config = {
    -- HUD Layout
    Layout = {
        Enabled = true,
        ShowHealth = true,
        ShowShields = true,
        ShowEnergy = true,
        ShowSpeed = true,
        ShowAltitude = true,
        ShowCompass = true,
        ShowMinimap = true,
        ShowTargeting = true,
        ShowWeapons = true,
        ShowStatus = true
    },
    
    -- Visual settings
    Visual = {
        Scale = 1.0,
        Opacity = 0.9,
        AnimationSpeed = 0.25,
        GlowIntensity = 0.5,
        BlurBackground = true,
        ShowGrid = true,
        ShowScanlines = false
    },
    
    -- Positioning (percentage of screen)
    Positions = {
        HealthBar = {x = 0.02, y = 0.85},
        ShieldBar = {x = 0.02, y = 0.80},
        EnergyBar = {x = 0.02, y = 0.75},
        SpeedMeter = {x = 0.85, y = 0.85},
        Compass = {x = 0.5, y = 0.05},
        Minimap = {x = 0.85, y = 0.05},
        TargetInfo = {x = 0.7, y = 0.3},
        WeaponStatus = {x = 0.02, y = 0.3},
        StatusPanel = {x = 0.02, y = 0.05}
    },
    
    -- Colors (will use theme system)
    Colors = {
        Health = Color(46, 204, 113, 255),
        HealthLow = Color(231, 76, 60, 255),
        Shield = Color(52, 152, 219, 255),
        Energy = Color(241, 196, 15, 255),
        Speed = Color(155, 89, 182, 255),
        Warning = Color(230, 126, 34, 255),
        Critical = Color(192, 57, 43, 255),
        Background = Color(0, 0, 0, 150),
        Border = Color(255, 255, 255, 100),
        Text = Color(255, 255, 255, 255),
        TextShadow = Color(0, 0, 0, 200)
    }
}

-- HUD state
ASC.HUD.State = {
    Visible = true,
    LastUpdate = 0,
    UpdateInterval = 0.05, -- 20 FPS for HUD updates
    AnimationTime = 0,
    
    -- Player data cache
    PlayerData = {
        Health = 100,
        MaxHealth = 100,
        Shield = 100,
        MaxShield = 100,
        Energy = 100,
        MaxEnergy = 100,
        Speed = 0,
        Altitude = 0,
        Position = Vector(0, 0, 0),
        Angle = Angle(0, 0, 0)
    },
    
    -- Ship data cache
    ShipData = {
        HasShip = false,
        ShipName = "",
        HullIntegrity = 100,
        ShieldStatus = false,
        WeaponCount = 0,
        EngineStatus = false
    }
}

-- Modern progress bar component
function ASC.HUD.DrawProgressBar(x, y, w, h, value, maxValue, color, label)
    local colors = ASC.UI and ASC.UI.GetColors() or ASC.HUD.Config.Colors
    local percentage = math.Clamp(value / maxValue, 0, 1)
    
    -- Background
    draw.RoundedBox(4, x, y, w, h, colors.Background or Color(0, 0, 0, 150))
    
    -- Border
    surface.SetDrawColor(colors.Border or Color(255, 255, 255, 100))
    surface.DrawOutlinedRect(x, y, w, h, 1)
    
    -- Fill
    local fillWidth = (w - 4) * percentage
    if fillWidth > 0 then
        draw.RoundedBox(2, x + 2, y + 2, fillWidth, h - 4, color)
        
        -- Glow effect
        if ASC.HUD.Config.Visual.GlowIntensity > 0 then
            local glowAlpha = math.sin(CurTime() * 3) * 20 + 30
            draw.RoundedBox(2, x + 2, y + 2, fillWidth, h - 4, 
                Color(color.r, color.g, color.b, glowAlpha * ASC.HUD.Config.Visual.GlowIntensity))
        end
    end
    
    -- Text label
    if label then
        surface.SetFont("ASC_Caption")
        local textW, textH = surface.GetTextSize(label)
        
        -- Text shadow
        surface.SetTextColor(colors.TextShadow or Color(0, 0, 0, 200))
        surface.SetTextPos(x + w/2 - textW/2 + 1, y + h/2 - textH/2 + 1)
        surface.DrawText(label)
        
        -- Main text
        surface.SetTextColor(colors.Text or Color(255, 255, 255, 255))
        surface.SetTextPos(x + w/2 - textW/2, y + h/2 - textH/2)
        surface.DrawText(label)
    end
end

-- Modern circular gauge
function ASC.HUD.DrawCircularGauge(x, y, radius, value, maxValue, color, label)
    local colors = ASC.UI and ASC.UI.GetColors() or ASC.HUD.Config.Colors
    local percentage = math.Clamp(value / maxValue, 0, 1)
    local angle = percentage * 360
    
    -- Background circle
    surface.SetDrawColor(colors.Background or Color(0, 0, 0, 150))
    surface.DrawOutlinedCircle(x, y, radius, 3)
    
    -- Progress arc
    surface.SetDrawColor(color)
    for i = 0, angle, 2 do
        local rad = math.rad(i - 90)
        local x1 = x + math.cos(rad) * (radius - 5)
        local y1 = y + math.sin(rad) * (radius - 5)
        local x2 = x + math.cos(rad) * (radius - 2)
        local y2 = y + math.sin(rad) * (radius - 2)
        surface.DrawLine(x1, y1, x2, y2)
    end
    
    -- Center text
    if label then
        surface.SetFont("ASC_Caption")
        local textW, textH = surface.GetTextSize(label)
        
        -- Text shadow
        surface.SetTextColor(colors.TextShadow or Color(0, 0, 0, 200))
        surface.SetTextPos(x - textW/2 + 1, y - textH/2 + 1)
        surface.DrawText(label)
        
        -- Main text
        surface.SetTextColor(colors.Text or Color(255, 255, 255, 255))
        surface.SetTextPos(x - textW/2, y - textH/2)
        surface.DrawText(label)
    end
end

-- Update player data
function ASC.HUD.UpdatePlayerData()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local data = ASC.HUD.State.PlayerData
    
    -- Basic player stats
    data.Health = ply:Health()
    data.MaxHealth = ply:GetMaxHealth()
    data.Speed = math.Round(ply:GetVelocity():Length() * 0.0568182, 1) -- Convert to MPH
    data.Position = ply:GetPos()
    data.Angle = ply:EyeAngles()
    data.Altitude = math.Round(data.Position.z / 12, 1) -- Convert to feet
    
    -- Shield system integration
    if ply.GetShield then
        data.Shield = ply:GetShield() or 0
        data.MaxShield = ply:GetMaxShield() or 100
    end
    
    -- Energy system integration
    if ply.GetEnergy then
        data.Energy = ply:GetEnergy() or 100
        data.MaxEnergy = ply:GetMaxEnergy() or 100
    end
end

-- Update ship data
function ASC.HUD.UpdateShipData()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    local data = ASC.HUD.State.ShipData
    
    -- Find player's ship core
    local shipCore = nil
    local cores = ents.FindByClass("ship_core")
    
    for _, core in ipairs(cores) do
        if IsValid(core) and core:GetNWString("Owner") == ply:Name() then
            shipCore = core
            break
        end
    end
    
    if IsValid(shipCore) then
        data.HasShip = true
        data.ShipName = shipCore:GetNWString("ShipName", "Unnamed Ship")
        data.HullIntegrity = shipCore:GetNWFloat("HullIntegrity", 100)
        data.ShieldStatus = shipCore:GetNWBool("ShieldActive", false)
        data.EngineStatus = shipCore:GetNWBool("EngineActive", false)
    else
        data.HasShip = false
    end
end

-- Draw health and status bars
function ASC.HUD.DrawStatusBars()
    local scrW, scrH = ScrW(), ScrH()
    local data = ASC.HUD.State.PlayerData
    local config = ASC.HUD.Config
    
    -- Health bar
    if config.Layout.ShowHealth then
        local x = scrW * config.Positions.HealthBar.x
        local y = scrH * config.Positions.HealthBar.y
        local healthColor = data.Health < 30 and config.Colors.HealthLow or config.Colors.Health
        
        ASC.HUD.DrawProgressBar(x, y, 200, 20, data.Health, data.MaxHealth, healthColor, 
            "Health: " .. data.Health .. "/" .. data.MaxHealth)
    end
    
    -- Shield bar
    if config.Layout.ShowShields and data.Shield > 0 then
        local x = scrW * config.Positions.ShieldBar.x
        local y = scrH * config.Positions.ShieldBar.y
        
        ASC.HUD.DrawProgressBar(x, y, 200, 20, data.Shield, data.MaxShield, config.Colors.Shield,
            "Shields: " .. data.Shield .. "/" .. data.MaxShield)
    end
    
    -- Energy bar
    if config.Layout.ShowEnergy and data.Energy > 0 then
        local x = scrW * config.Positions.EnergyBar.x
        local y = scrH * config.Positions.EnergyBar.y
        
        ASC.HUD.DrawProgressBar(x, y, 200, 20, data.Energy, data.MaxEnergy, config.Colors.Energy,
            "Energy: " .. data.Energy .. "/" .. data.MaxEnergy)
    end
end

-- Draw speed and navigation info
function ASC.HUD.DrawNavigationInfo()
    local scrW, scrH = ScrW(), ScrH()
    local data = ASC.HUD.State.PlayerData
    local config = ASC.HUD.Config
    
    -- Speed meter
    if config.Layout.ShowSpeed then
        local x = scrW * config.Positions.SpeedMeter.x
        local y = scrH * config.Positions.SpeedMeter.y
        
        ASC.HUD.DrawCircularGauge(x, y, 50, data.Speed, 100, config.Colors.Speed, 
            math.Round(data.Speed) .. " MPH")
    end
    
    -- Altitude display
    if config.Layout.ShowAltitude then
        local x = scrW * config.Positions.SpeedMeter.x
        local y = scrH * config.Positions.SpeedMeter.y + 120
        
        surface.SetFont("ASC_Body")
        local text = "ALT: " .. data.Altitude .. " ft"
        local textW, textH = surface.GetTextSize(text)
        
        -- Background
        draw.RoundedBox(4, x - textW/2 - 5, y - textH/2 - 3, textW + 10, textH + 6, 
            Color(0, 0, 0, 150))
        
        -- Text
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x - textW/2, y - textH/2)
        surface.DrawText(text)
    end
end

-- Draw ship information
function ASC.HUD.DrawShipInfo()
    local scrW, scrH = ScrW(), ScrH()
    local data = ASC.HUD.State.ShipData
    local config = ASC.HUD.Config
    
    if not data.HasShip then return end
    
    -- Ship status panel
    if config.Layout.ShowStatus then
        local x = scrW * config.Positions.StatusPanel.x
        local y = scrH * config.Positions.StatusPanel.y
        
        -- Background panel
        draw.RoundedBox(8, x, y, 250, 100, Color(0, 0, 0, 180))
        surface.SetDrawColor(64, 156, 255, 100)
        surface.DrawOutlinedRect(x, y, 250, 100, 2)
        
        -- Ship name
        surface.SetFont("ASC_Heading")
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x + 10, y + 10)
        surface.DrawText(data.ShipName)
        
        -- Hull integrity
        surface.SetFont("ASC_Body")
        surface.SetTextPos(x + 10, y + 40)
        local hullColor = data.HullIntegrity < 30 and "255,76,60" or "46,204,113"
        surface.DrawText("Hull: " .. math.Round(data.HullIntegrity) .. "%")
        
        -- Systems status
        surface.SetTextPos(x + 10, y + 60)
        local shieldText = data.ShieldStatus and "ONLINE" or "OFFLINE"
        local engineText = data.EngineStatus and "ONLINE" or "OFFLINE"
        surface.DrawText("Shields: " .. shieldText .. " | Engines: " .. engineText)
    end
end

-- Main HUD draw function
function ASC.HUD.Draw()
    if not ASC.HUD.State.Visible or not ASC.HUD.Config.Layout.Enabled then return end
    
    local currentTime = CurTime()
    
    -- Update data at specified interval
    if currentTime - ASC.HUD.State.LastUpdate > ASC.HUD.State.UpdateInterval then
        ASC.HUD.UpdatePlayerData()
        ASC.HUD.UpdateShipData()
        ASC.HUD.State.LastUpdate = currentTime
    end
    
    -- Update animation time
    ASC.HUD.State.AnimationTime = currentTime
    
    -- Draw HUD components
    ASC.HUD.DrawStatusBars()
    ASC.HUD.DrawNavigationInfo()
    ASC.HUD.DrawShipInfo()
end

-- Toggle HUD visibility
function ASC.HUD.Toggle()
    ASC.HUD.State.Visible = not ASC.HUD.State.Visible
    chat.AddText(Color(100, 255, 100), "[ASC HUD] HUD " .. (ASC.HUD.State.Visible and "enabled" or "disabled"))
end

-- Console commands
concommand.Add("asc_hud_toggle", ASC.HUD.Toggle, nil, "Toggle HUD visibility")

concommand.Add("asc_hud_scale", function(ply, cmd, args)
    if #args > 0 then
        local scale = tonumber(args[1])
        if scale and scale > 0 and scale <= 2 then
            ASC.HUD.Config.Visual.Scale = scale
            chat.AddText(Color(100, 255, 100), "[ASC HUD] Scale set to " .. scale)
        end
    else
        chat.AddText(Color(255, 255, 100), "[ASC HUD] Current scale: " .. ASC.HUD.Config.Visual.Scale)
    end
end, nil, "Set HUD scale (0.1-2.0)")

-- Hook into HUD paint
hook.Add("HUDPaint", "ASC_Advanced_HUD", ASC.HUD.Draw)

print("[Advanced Space Combat] Advanced HUD System v6.0.0 - Next-Generation Interface Loaded Successfully!")
