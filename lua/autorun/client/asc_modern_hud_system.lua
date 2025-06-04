-- Advanced Space Combat - Modern HUD System v1.0.0
-- Based on 2024 sci-fi UI design principles and modern game HUD best practices

print("[Advanced Space Combat] Modern HUD System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.ModernHUD = ASC.ModernHUD or {}

-- Modern HUD configuration based on research
ASC.ModernHUD.Config = {
    -- Design principles from research
    EnableDiegeticUI = true,        -- UI elements that exist in the game world
    EnableSpatialUI = true,         -- 3D positioned UI elements
    EnableAdaptiveLayout = true,    -- Layout adapts to screen size
    EnableGlassmorphism = true,     -- Modern glass-like effects
    EnableNeumorphism = false,      -- Soft UI style (performance heavy)
    
    -- Color scheme (modern sci-fi)
    Colors = {
        Primary = Color(64, 224, 255, 255),      -- Cyan blue
        Secondary = Color(255, 165, 0, 255),     -- Orange accent
        Success = Color(0, 255, 127, 255),       -- Spring green
        Warning = Color(255, 215, 0, 255),       -- Gold
        Danger = Color(255, 69, 58, 255),        -- Red
        Background = Color(0, 0, 0, 180),        -- Semi-transparent black
        Surface = Color(28, 28, 30, 200),        -- Dark surface
        Text = Color(255, 255, 255, 255),        -- White text
        TextSecondary = Color(174, 174, 178, 255), -- Gray text
        Glow = Color(64, 224, 255, 100),         -- Glow effect
        Border = Color(99, 99, 102, 255)         -- Border color
    },
    
    -- Typography (modern sci-fi fonts)
    Fonts = {
        Title = "ASC_HUD_Title",
        Subtitle = "ASC_HUD_Subtitle", 
        Body = "ASC_HUD_Body",
        Caption = "ASC_HUD_Caption",
        Monospace = "ASC_HUD_Mono"
    },
    
    -- Layout settings
    Layout = {
        Padding = 16,
        Margin = 8,
        BorderRadius = 12,
        GlowRadius = 24,
        AnimationSpeed = 0.3,
        FadeDistance = 2000
    },
    
    -- HUD elements configuration
    Elements = {
        ShipStatus = {
            Enabled = true,
            Position = {x = 50, y = 50},
            Size = {w = 300, h = 200},
            Anchor = "TopLeft"
        },
        WeaponStatus = {
            Enabled = true,
            Position = {x = -350, y = 50},
            Size = {w = 300, h = 150},
            Anchor = "TopRight"
        },
        Navigation = {
            Enabled = true,
            Position = {x = 0, y = -200},
            Size = {w = 400, h = 100},
            Anchor = "Bottom"
        },
        Minimap = {
            Enabled = true,
            Position = {x = -50, y = -50},
            Size = {w = 200, h = 200},
            Anchor = "BottomRight"
        },
        ChatInterface = {
            Enabled = true,
            Position = {x = 50, y = -300},
            Size = {w = 400, h = 200},
            Anchor = "BottomLeft"
        }
    }
}

-- HUD state management
ASC.ModernHUD.State = {
    Visible = true,
    CurrentShip = nil,
    LastUpdate = 0,
    AnimationStates = {},
    ActiveElements = {},
    
    -- Performance tracking
    RenderTime = 0,
    ElementCount = 0,
    LastOptimization = 0
}

-- Initialize modern HUD system
function ASC.ModernHUD.Initialize()
    print("[ASC Modern HUD] Initializing modern HUD system...")
    
    -- Create modern fonts
    ASC.ModernHUD.CreateFonts()
    
    -- Set up HUD elements
    ASC.ModernHUD.SetupElements()
    
    -- Initialize animations
    ASC.ModernHUD.InitializeAnimations()
    
    -- Set up hooks
    ASC.ModernHUD.SetupHooks()
    
    print("[ASC Modern HUD] Modern HUD system initialized")
end

-- Create modern sci-fi fonts
function ASC.ModernHUD.CreateFonts()
    local config = ASC.ModernHUD.Config
    
    -- Title font (large, bold)
    surface.CreateFont(config.Fonts.Title, {
        font = "Orbitron",
        size = 32,
        weight = 800,
        antialias = true,
        shadow = true,
        outline = true
    })
    
    -- Subtitle font (medium)
    surface.CreateFont(config.Fonts.Subtitle, {
        font = "Orbitron", 
        size = 24,
        weight = 600,
        antialias = true,
        shadow = true
    })
    
    -- Body font (readable)
    surface.CreateFont(config.Fonts.Body, {
        font = "Exo 2",
        size = 16,
        weight = 500,
        antialias = true
    })
    
    -- Caption font (small)
    surface.CreateFont(config.Fonts.Caption, {
        font = "Exo 2",
        size = 14,
        weight = 400,
        antialias = true
    })
    
    -- Monospace font (data display)
    surface.CreateFont(config.Fonts.Monospace, {
        font = "Courier New",
        size = 14,
        weight = 500,
        antialias = true
    })
end

-- Set up HUD elements
function ASC.ModernHUD.SetupElements()
    ASC.ModernHUD.Elements = {
        ShipStatus = ASC.ModernHUD.CreateShipStatusElement(),
        WeaponStatus = ASC.ModernHUD.CreateWeaponStatusElement(),
        Navigation = ASC.ModernHUD.CreateNavigationElement(),
        Minimap = ASC.ModernHUD.CreateMinimapElement(),
        ChatInterface = ASC.ModernHUD.CreateChatInterfaceElement()
    }
end

-- Create ship status element
function ASC.ModernHUD.CreateShipStatusElement()
    return {
        Type = "ShipStatus",
        Render = function(self, x, y, w, h)
            local ship = ASC.ModernHUD.GetPlayerShip()
            if not IsValid(ship) then return end
            
            -- Background with glassmorphism
            ASC.ModernHUD.DrawGlassPanel(x, y, w, h, "Ship Status")
            
            local yOffset = 40
            
            -- Ship name
            local shipName = ship:GetNWString("ShipName", "Unknown Ship")
            ASC.ModernHUD.DrawText(shipName, x + 16, y + yOffset, ASC.ModernHUD.Config.Fonts.Subtitle, ASC.ModernHUD.Config.Colors.Primary)
            yOffset = yOffset + 30
            
            -- Hull integrity
            local hullIntegrity = ship:GetNWFloat("HullIntegrity", 100)
            ASC.ModernHUD.DrawProgressBar(x + 16, y + yOffset, w - 32, 20, hullIntegrity / 100, "Hull Integrity", ASC.ModernHUD.Config.Colors.Success)
            yOffset = yOffset + 35
            
            -- Shield status
            local shieldActive = ship:GetNWBool("ShieldActive", false)
            local shieldStrength = ship:GetNWFloat("ShieldStrength", 0)
            local shieldColor = shieldActive and ASC.ModernHUD.Config.Colors.Primary or ASC.ModernHUD.Config.Colors.TextSecondary
            ASC.ModernHUD.DrawProgressBar(x + 16, y + yOffset, w - 32, 20, shieldStrength / 100, "Shield Status", shieldColor)
            yOffset = yOffset + 35
            
            -- Power level
            local powerLevel = ship:GetNWFloat("PowerLevel", 100)
            ASC.ModernHUD.DrawProgressBar(x + 16, y + yOffset, w - 32, 20, powerLevel / 100, "Power Level", ASC.ModernHUD.Config.Colors.Warning)
        end
    }
end

-- Create weapon status element
function ASC.ModernHUD.CreateWeaponStatusElement()
    return {
        Type = "WeaponStatus",
        Render = function(self, x, y, w, h)
            -- Background
            ASC.ModernHUD.DrawGlassPanel(x, y, w, h, "Weapon Systems")
            
            local yOffset = 40
            
            -- Find nearby weapons
            local weapons = ASC.ModernHUD.GetNearbyWeapons()
            
            if #weapons == 0 then
                ASC.ModernHUD.DrawText("No weapons detected", x + 16, y + yOffset, ASC.ModernHUD.Config.Fonts.Body, ASC.ModernHUD.Config.Colors.TextSecondary)
                return
            end
            
            -- Display weapon status
            for i, weapon in ipairs(weapons) do
                if i > 3 then break end -- Limit to 3 weapons
                
                local weaponName = weapon:GetClass():gsub("_", " "):upper()
                local ammo = weapon:GetNWInt("Ammo", 0)
                local maxAmmo = weapon:GetNWInt("MaxAmmo", 100)
                local ammoPercent = maxAmmo > 0 and (ammo / maxAmmo) or 0
                
                ASC.ModernHUD.DrawText(weaponName, x + 16, y + yOffset, ASC.ModernHUD.Config.Fonts.Caption, ASC.ModernHUD.Config.Colors.Text)
                yOffset = yOffset + 20
                
                ASC.ModernHUD.DrawProgressBar(x + 16, y + yOffset, w - 32, 16, ammoPercent, "Ammo", ASC.ModernHUD.Config.Colors.Secondary)
                yOffset = yOffset + 25
            end
        end
    }
end

-- Create navigation element
function ASC.ModernHUD.CreateNavigationElement()
    return {
        Type = "Navigation",
        Render = function(self, x, y, w, h)
            -- Background
            ASC.ModernHUD.DrawGlassPanel(x, y, w, h, "Navigation")
            
            -- Compass
            local player = LocalPlayer()
            if not IsValid(player) then return end
            
            local angle = player:EyeAngles().y
            ASC.ModernHUD.DrawCompass(x + w/2, y + h/2, 80, angle)
        end
    }
end

-- Create minimap element
function ASC.ModernHUD.CreateMinimapElement()
    return {
        Type = "Minimap",
        Render = function(self, x, y, w, h)
            -- Background
            ASC.ModernHUD.DrawGlassPanel(x, y, w, h, "Tactical Map")
            
            -- Simple radar-style minimap
            ASC.ModernHUD.DrawRadar(x + w/2, y + h/2, math.min(w, h) / 2 - 20)
        end
    }
end

-- Create chat interface element
function ASC.ModernHUD.CreateChatInterfaceElement()
    return {
        Type = "ChatInterface",
        Render = function(self, x, y, w, h)
            -- Background
            ASC.ModernHUD.DrawGlassPanel(x, y, w, h, "ARIA-4 Assistant")
            
            local yOffset = 40
            
            -- ARIA-4 status
            ASC.ModernHUD.DrawText("ARIA-4 Online", x + 16, y + yOffset, ASC.ModernHUD.Config.Fonts.Body, ASC.ModernHUD.Config.Colors.Success)
            yOffset = yOffset + 25
            
            -- Quick commands
            ASC.ModernHUD.DrawText("Say 'aria help' for assistance", x + 16, y + yOffset, ASC.ModernHUD.Config.Fonts.Caption, ASC.ModernHUD.Config.Colors.TextSecondary)
        end
    }
end

-- Draw glass panel with modern styling
function ASC.ModernHUD.DrawGlassPanel(x, y, w, h, title)
    local config = ASC.ModernHUD.Config
    
    -- Background blur effect (simulated)
    draw.RoundedBox(config.Layout.BorderRadius, x, y, w, h, config.Colors.Background)
    
    -- Glass surface
    draw.RoundedBox(config.Layout.BorderRadius, x + 2, y + 2, w - 4, h - 4, config.Colors.Surface)
    
    -- Glow effect
    local glowAlpha = math.sin(CurTime() * 2) * 20 + 40
    draw.RoundedBox(config.Layout.BorderRadius + 4, x - 4, y - 4, w + 8, h + 8, 
        Color(config.Colors.Glow.r, config.Colors.Glow.g, config.Colors.Glow.b, glowAlpha))
    
    -- Border
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedRect(x, y, w, h, 2)
    
    -- Title bar
    if title then
        draw.RoundedBox(config.Layout.BorderRadius, x + 8, y + 8, w - 16, 24, config.Colors.Primary)
        ASC.ModernHUD.DrawText(title, x + 16, y + 12, config.Fonts.Caption, config.Colors.Background)
    end
end

-- Draw modern progress bar
function ASC.ModernHUD.DrawProgressBar(x, y, w, h, progress, label, color)
    local config = ASC.ModernHUD.Config
    
    -- Background
    draw.RoundedBox(h/2, x, y, w, h, Color(0, 0, 0, 100))
    
    -- Progress fill
    local fillWidth = w * math.Clamp(progress, 0, 1)
    if fillWidth > 0 then
        draw.RoundedBox(h/2, x, y, fillWidth, h, color)
    end
    
    -- Label
    if label then
        local text = label .. ": " .. math.floor(progress * 100) .. "%"
        ASC.ModernHUD.DrawText(text, x + 4, y - 18, config.Fonts.Caption, config.Colors.Text)
    end
end

-- Draw text with modern styling
function ASC.ModernHUD.DrawText(text, x, y, font, color)
    -- Text shadow
    surface.SetFont(font)
    surface.SetTextColor(0, 0, 0, 100)
    surface.SetTextPos(x + 1, y + 1)
    surface.DrawText(text)
    
    -- Main text
    surface.SetTextColor(color)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
end

-- Get player's ship
function ASC.ModernHUD.GetPlayerShip()
    local player = LocalPlayer()
    if not IsValid(player) then return nil end
    
    -- Find nearest ship core
    local nearestCore = nil
    local nearestDistance = math.huge
    
    for _, ent in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(ent) then
            local distance = ent:GetPos():Distance(player:GetPos())
            if distance < nearestDistance and distance < 1000 then
                nearestCore = ent
                nearestDistance = distance
            end
        end
    end
    
    return nearestCore
end

-- Get nearby weapons
function ASC.ModernHUD.GetNearbyWeapons()
    local player = LocalPlayer()
    if not IsValid(player) then return {} end
    
    local weapons = {}
    local weaponClasses = {"asc_pulse_cannon", "asc_plasma_cannon", "asc_railgun"}
    
    for _, class in ipairs(weaponClasses) do
        for _, weapon in ipairs(ents.FindByClass(class)) do
            if IsValid(weapon) and weapon:GetPos():Distance(player:GetPos()) < 1000 then
                table.insert(weapons, weapon)
            end
        end
    end
    
    return weapons
end

-- Draw compass
function ASC.ModernHUD.DrawCompass(centerX, centerY, radius, angle)
    local config = ASC.ModernHUD.Config
    
    -- Compass circle
    surface.SetDrawColor(config.Colors.Border)
    surface.DrawOutlinedCircle(centerX, centerY, radius, 2)
    
    -- North indicator
    local northX = centerX + math.sin(math.rad(-angle)) * (radius - 10)
    local northY = centerY + math.cos(math.rad(-angle)) * (radius - 10)
    
    surface.SetDrawColor(config.Colors.Danger)
    surface.DrawLine(centerX, centerY, northX, northY)
    
    ASC.ModernHUD.DrawText("N", northX - 5, northY - 10, config.Fonts.Caption, config.Colors.Danger)
end

-- Draw radar
function ASC.ModernHUD.DrawRadar(centerX, centerY, radius)
    local config = ASC.ModernHUD.Config
    local player = LocalPlayer()
    if not IsValid(player) then return end
    
    -- Radar circle
    surface.SetDrawColor(config.Colors.Primary)
    surface.DrawOutlinedCircle(centerX, centerY, radius, 2)
    
    -- Sweep line (animated)
    local sweepAngle = CurTime() * 90 % 360
    local sweepX = centerX + math.sin(math.rad(sweepAngle)) * radius
    local sweepY = centerY + math.cos(math.rad(sweepAngle)) * radius
    
    surface.SetDrawColor(config.Colors.Success)
    surface.DrawLine(centerX, centerY, sweepX, sweepY)
    
    -- Show nearby entities as blips
    for _, ent in ipairs(ents.FindInSphere(player:GetPos(), 2000)) do
        if IsValid(ent) and ent ~= player and (ent:IsPlayer() or ent:GetClass():find("ship_core")) then
            local entPos = ent:GetPos()
            local playerPos = player:GetPos()
            local distance = entPos:Distance(playerPos)
            
            if distance < 2000 then
                local relativePos = entPos - playerPos
                local blipX = centerX + (relativePos.x / 2000) * radius
                local blipY = centerY - (relativePos.y / 2000) * radius
                
                local blipColor = ent:IsPlayer() and config.Colors.Warning or config.Colors.Secondary
                surface.SetDrawColor(blipColor)
                surface.DrawRect(blipX - 2, blipY - 2, 4, 4)
            end
        end
    end
end

-- Initialize animations
function ASC.ModernHUD.InitializeAnimations()
    ASC.ModernHUD.Animations = {
        FadeIn = function(element, duration)
            -- Implement fade in animation
        end,
        SlideIn = function(element, direction, duration)
            -- Implement slide in animation
        end,
        Pulse = function(element, intensity, speed)
            -- Implement pulse animation
        end
    }
end

-- Set up hooks
function ASC.ModernHUD.SetupHooks()
    -- Main HUD render hook
    hook.Add("HUDPaint", "ASC_ModernHUD_Paint", function()
        if not ASC.ModernHUD.State.Visible then return end
        
        ASC.ModernHUD.RenderHUD()
    end)
    
    -- Hide default HUD elements
    hook.Add("HUDShouldDraw", "ASC_ModernHUD_Hide", function(name)
        if ASC.ModernHUD.State.Visible then
            local hideElements = {"CHudHealth", "CHudBattery", "CHudAmmo"}
            if table.HasValue(hideElements, name) then
                return false
            end
        end
    end)
end

-- Main HUD render function
function ASC.ModernHUD.RenderHUD()
    local config = ASC.ModernHUD.Config
    local scrW, scrH = ScrW(), ScrH()
    
    -- Render each enabled element
    for name, elementConfig in pairs(config.Elements) do
        if elementConfig.Enabled then
            local element = ASC.ModernHUD.Elements[name]
            if element and element.Render then
                -- Calculate position based on anchor
                local x, y = ASC.ModernHUD.CalculatePosition(elementConfig, scrW, scrH)
                
                -- Render element
                element:Render(x, y, elementConfig.Size.w, elementConfig.Size.h)
            end
        end
    end
end

-- Calculate element position based on anchor
function ASC.ModernHUD.CalculatePosition(elementConfig, scrW, scrH)
    local pos = elementConfig.Position
    local anchor = elementConfig.Anchor
    
    local x, y = 0, 0
    
    if anchor == "TopLeft" then
        x, y = pos.x, pos.y
    elseif anchor == "TopRight" then
        x, y = scrW + pos.x - elementConfig.Size.w, pos.y
    elseif anchor == "BottomLeft" then
        x, y = pos.x, scrH + pos.y - elementConfig.Size.h
    elseif anchor == "BottomRight" then
        x, y = scrW + pos.x - elementConfig.Size.w, scrH + pos.y - elementConfig.Size.h
    elseif anchor == "Bottom" then
        x, y = scrW/2 + pos.x - elementConfig.Size.w/2, scrH + pos.y - elementConfig.Size.h
    end
    
    return x, y
end

-- Console commands
concommand.Add("asc_hud_toggle", function()
    ASC.ModernHUD.State.Visible = not ASC.ModernHUD.State.Visible
    chat.AddText(Color(100, 255, 100), "[Advanced Space Combat] Modern HUD " .. (ASC.ModernHUD.State.Visible and "enabled" or "disabled"))
end, nil, "Toggle modern HUD visibility")

-- Initialize on client
hook.Add("InitPostEntity", "ASC_ModernHUD_Init", function()
    timer.Simple(2, function()
        ASC.ModernHUD.Initialize()
    end)
end)

print("[Advanced Space Combat] Modern HUD System loaded successfully!")
