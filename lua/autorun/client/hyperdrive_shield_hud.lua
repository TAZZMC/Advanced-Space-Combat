-- Hyperdrive Shield HUD - Client Side
if SERVER then return end

local shieldHUD = {
    enabled = true,
    lastUpdate = 0,
    updateInterval = 0.5,
    shieldData = {},
    showDetails = false
}

-- Configuration
local HUD_CONFIG = {
    position = {x = 50, y = ScrH() - 150},
    width = 300,
    height = 100,
    backgroundColor = Color(0, 0, 0, 150),
    borderColor = Color(0, 100, 200, 255),
    textColor = Color(255, 255, 255, 255),
    shieldColor = Color(0, 255, 255, 255),
    warningColor = Color(255, 255, 0, 255),
    criticalColor = Color(255, 0, 0, 255)
}

-- Console command to toggle shield HUD
concommand.Add("hyperdrive_toggle_shield_hud", function()
    shieldHUD.enabled = not shieldHUD.enabled
    LocalPlayer():ChatPrint("[Hyperdrive Shields] HUD " .. (shieldHUD.enabled and "enabled" or "disabled"))
end)

concommand.Add("hyperdrive_toggle_shield_details", function()
    shieldHUD.showDetails = not shieldHUD.showDetails
    LocalPlayer():ChatPrint("[Hyperdrive Shields] Details " .. (shieldHUD.showDetails and "enabled" or "disabled"))
end)

-- Update shield data from nearby engines
local function UpdateShieldData()
    if CurTime() - shieldHUD.lastUpdate < shieldHUD.updateInterval then return end
    shieldHUD.lastUpdate = CurTime()
    
    local ply = LocalPlayer()
    if not IsValid(ply) then return end
    
    -- Find nearby hyperdrive engines
    local nearbyEngines = {}
    for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 2000)) do
        if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive") then
            table.insert(nearbyEngines, ent)
        end
    end
    
    -- Get shield data from engines
    shieldHUD.shieldData = {}
    for _, engine in ipairs(nearbyEngines) do
        if IsValid(engine) then
            local shieldActive = engine.GetShieldActive and engine:GetShieldActive() or false
            local shieldStrength = engine.GetShieldStrength and engine:GetShieldStrength() or 0
            local shieldPercent = engine.GetShieldPercent and engine:GetShieldPercent() or 0
            
            if shieldActive or shieldStrength > 0 then
                table.insert(shieldHUD.shieldData, {
                    engine = engine,
                    active = shieldActive,
                    strength = shieldStrength,
                    percent = shieldPercent,
                    distance = ply:GetPos():Distance(engine:GetPos())
                })
            end
        end
    end
    
    -- Sort by distance
    table.sort(shieldHUD.shieldData, function(a, b)
        return a.distance < b.distance
    end)
end

-- Draw shield HUD
local function DrawShieldHUD()
    if not shieldHUD.enabled then return end
    
    UpdateShieldData()
    
    if #shieldHUD.shieldData == 0 then return end
    
    local x, y = HUD_CONFIG.position.x, HUD_CONFIG.position.y
    local w, h = HUD_CONFIG.width, HUD_CONFIG.height
    
    -- Adjust height based on number of shields
    if shieldHUD.showDetails then
        h = 60 + (#shieldHUD.shieldData * 25)
    end
    
    -- Background
    draw.RoundedBox(8, x, y, w, h, HUD_CONFIG.backgroundColor)
    draw.RoundedBox(8, x + 2, y + 2, w - 4, h - 4, Color(0, 20, 40, 100))
    
    -- Border
    surface.SetDrawColor(HUD_CONFIG.borderColor)
    surface.DrawOutlinedRect(x, y, w, h, 2)
    
    -- Title
    draw.SimpleText("SHIELD STATUS", "DermaDefaultBold", x + w/2, y + 15, HUD_CONFIG.textColor, TEXT_ALIGN_CENTER)
    
    if shieldHUD.showDetails then
        -- Detailed view
        local yOffset = 35
        
        for i, shieldData in ipairs(shieldHUD.shieldData) do
            if i > 5 then break end -- Limit to 5 shields
            
            local engine = shieldData.engine
            local engineName = engine:GetClass():gsub("hyperdrive_", ""):upper()
            local statusColor = shieldData.active and HUD_CONFIG.shieldColor or Color(100, 100, 100)
            
            -- Shield bar background
            draw.RoundedBox(4, x + 10, y + yOffset, w - 20, 20, Color(50, 50, 50, 150))
            
            -- Shield bar fill
            if shieldData.percent > 0 then
                local barColor = HUD_CONFIG.shieldColor
                if shieldData.percent < 25 then
                    barColor = HUD_CONFIG.criticalColor
                elseif shieldData.percent < 50 then
                    barColor = HUD_CONFIG.warningColor
                end
                
                local barWidth = (w - 24) * (shieldData.percent / 100)
                draw.RoundedBox(4, x + 12, y + yOffset + 2, barWidth, 16, barColor)
            end
            
            -- Text overlay
            local statusText = string.format("%s: %d%% (%dm)", engineName, shieldData.percent, shieldData.distance)
            draw.SimpleText(statusText, "DermaDefault", x + w/2, y + yOffset + 10, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            yOffset = yOffset + 25
        end
    else
        -- Simple view
        local totalShields = #shieldHUD.shieldData
        local activeShields = 0
        local avgPercent = 0
        
        for _, shieldData in ipairs(shieldHUD.shieldData) do
            if shieldData.active then
                activeShields = activeShields + 1
            end
            avgPercent = avgPercent + shieldData.percent
        end
        
        if totalShields > 0 then
            avgPercent = avgPercent / totalShields
        end
        
        -- Status text
        local statusText = string.format("SHIELDS: %d/%d ACTIVE", activeShields, totalShields)
        draw.SimpleText(statusText, "DermaDefault", x + w/2, y + 35, HUD_CONFIG.textColor, TEXT_ALIGN_CENTER)
        
        -- Average shield bar
        draw.RoundedBox(4, x + 20, y + 55, w - 40, 15, Color(50, 50, 50, 150))
        
        if avgPercent > 0 then
            local barColor = HUD_CONFIG.shieldColor
            if avgPercent < 25 then
                barColor = HUD_CONFIG.criticalColor
            elseif avgPercent < 50 then
                barColor = HUD_CONFIG.warningColor
            end
            
            local barWidth = (w - 44) * (avgPercent / 100)
            draw.RoundedBox(4, x + 22, y + 57, barWidth, 11, barColor)
        end
        
        -- Percentage text
        draw.SimpleText(string.format("%.0f%%", avgPercent), "DermaDefault", x + w/2, y + 62, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    -- Toggle hint
    local hintText = "F1: Toggle Details | F2: Toggle HUD"
    draw.SimpleText(hintText, "DermaDefault", x + w/2, y + h - 15, Color(150, 150, 150), TEXT_ALIGN_CENTER)
end

-- Key bindings
hook.Add("PlayerButtonDown", "HyperdriveShieldHUDKeys", function(ply, button)
    if ply ~= LocalPlayer() then return end
    
    if button == KEY_F1 then
        shieldHUD.showDetails = not shieldHUD.showDetails
    elseif button == KEY_F2 then
        shieldHUD.enabled = not shieldHUD.enabled
    end
end)

-- HUD Paint hook
hook.Add("HUDPaint", "HyperdriveShieldHUD", DrawShieldHUD)

-- Network message for shield updates
net.Receive("HyperdriveShieldStatus", function()
    local ent = net.ReadEntity()
    local active = net.ReadBool()
    local strength = net.ReadFloat()
    local percent = net.ReadFloat()
    
    if IsValid(ent) then
        ent.ShieldActive = active
        ent.ShieldStrength = strength
        ent.ShieldPercent = percent
    end
end)

print("[Hyperdrive Shields] HUD system loaded - F1: Toggle Details, F2: Toggle HUD")
