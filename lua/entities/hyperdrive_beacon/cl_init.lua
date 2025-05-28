-- Hyperdrive Beacon Entity - Client Side
include("shared.lua")

function ENT:Initialize()
    self.NextPulse = 0
    self.PulseRadius = 0
    self.BeaconGlow = 0
end

function ENT:Draw()
    self:DrawModel()
    
    if self:GetActive() then
        self:DrawBeaconEffects()
    end
end

function ENT:DrawBeaconEffects()
    local pos = self:GetPos() + self:GetUp() * 15
    local time = CurTime()
    
    -- Beacon glow
    local glowIntensity = math.sin(time * 2) * 0.3 + 0.7
    local glowColor = Color(0, 255, 100, 200 * glowIntensity)
    
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, 40 * glowIntensity, 40 * glowIntensity, glowColor)
    
    -- Pulse ring
    if time > self.NextPulse then
        self.NextPulse = time + 2
        self.PulseRadius = 0
    end
    
    if self.PulseRadius < self:GetRange() then
        self.PulseRadius = self.PulseRadius + FrameTime() * 500
        
        local alpha = 1 - (self.PulseRadius / self:GetRange())
        local ringColor = Color(0, 200, 255, 100 * alpha)
        
        -- Draw pulse ring (simplified)
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(pos, self.PulseRadius * 0.1, self.PulseRadius * 0.1, ringColor)
    end
    
    -- Beacon info display
    if LocalPlayer():GetPos():Distance(self:GetPos()) < 500 then
        self:DrawBeaconInfo()
    end
end

function ENT:DrawBeaconInfo()
    local pos = self:GetPos() + Vector(0, 0, 30)
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Background
        draw.RoundedBox(4, -60, -25, 120, 50, Color(0, 0, 0, 150))
        draw.RoundedBox(4, -58, -23, 116, 46, Color(0, 50, 100, 200))
        
        -- Beacon name
        draw.SimpleText(self:GetBeaconName(), "DermaDefaultBold", 0, -15, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        
        -- Status
        local statusColor = self:GetActive() and Color(0, 255, 0) or Color(255, 0, 0)
        draw.SimpleText(self:GetStatusString(), "DermaDefault", 0, 0, statusColor, TEXT_ALIGN_CENTER)
        
        -- ID
        draw.SimpleText("ID: " .. self:GetBeaconID(), "DermaDefault", 0, 15, Color(200, 200, 200), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

-- Beacon configuration interface
local beaconConfig = {
    entity = nil,
    visible = false,
    name = "",
    active = true,
    range = 5000,
    lastUpdate = 0
}

function ENT:OpenConfig(name, active, range, id)
    beaconConfig.entity = self
    beaconConfig.visible = true
    beaconConfig.name = name or ""
    beaconConfig.active = active ~= false
    beaconConfig.range = range or 5000
    beaconConfig.id = id or 0
    gui.EnableScreenClicker(true)
end

function ENT:CloseConfig()
    beaconConfig.visible = false
    gui.EnableScreenClicker(false)
end

-- Network handlers
net.Receive("hyperdrive_beacon_config", function()
    local beacon = net.ReadEntity()
    local name = net.ReadString()
    local active = net.ReadBool()
    local range = net.ReadFloat()
    local id = net.ReadInt(16)
    
    if IsValid(beacon) then
        beacon:OpenConfig(name, active, range, id)
    end
end)

net.Receive("hyperdrive_beacon_pulse", function()
    local beacon = net.ReadEntity()
    local pos = net.ReadVector()
    
    if IsValid(beacon) then
        -- Create pulse effect
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetMagnitude(1)
        util.Effect("hyperdrive_beacon_pulse", effectdata)
    end
end)

-- Beacon configuration HUD
hook.Add("HUDPaint", "HyperdriveBeaconConfig", function()
    if not beaconConfig.visible or not IsValid(beaconConfig.entity) then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local panelW, panelH = 400, 300
    local x, y = (scrW - panelW) / 2, (scrH - panelH) / 2
    
    -- Background
    draw.RoundedBox(8, x, y, panelW, panelH, Color(20, 20, 40, 240))
    draw.RoundedBox(8, x + 2, y + 2, panelW - 4, panelH - 4, Color(40, 40, 80, 200))
    
    -- Title
    draw.SimpleText("BEACON CONFIGURATION", "DermaLarge", x + panelW/2, y + 20, Color(100, 255, 200), TEXT_ALIGN_CENTER)
    
    -- Beacon ID
    draw.SimpleText("Beacon ID: " .. beaconConfig.id, "DermaDefault", x + 20, y + 50, Color(200, 200, 200))
    
    -- Name field
    draw.SimpleText("Name: " .. beaconConfig.name, "DermaDefault", x + 20, y + 80, Color(255, 255, 255))
    
    -- Active toggle
    local activeColor = beaconConfig.active and Color(0, 255, 0) or Color(255, 0, 0)
    local activeText = beaconConfig.active and "ACTIVE" or "INACTIVE"
    draw.SimpleText("Status: " .. activeText, "DermaDefault", x + 20, y + 110, activeColor)
    
    -- Range
    draw.SimpleText("Range: " .. HYPERDRIVE.FormatDistance(beaconConfig.range), "DermaDefault", x + 20, y + 140, Color(255, 255, 255))
    
    -- Buttons
    local buttonW, buttonH = 80, 30
    local button1X, button1Y = x + 20, y + panelH - 50
    local button2X, button2Y = x + 120, y + panelH - 50
    local button3X, button3Y = x + 220, y + panelH - 50
    local button4X, button4Y = x + 320, y + panelH - 50
    
    -- Toggle Active button
    local toggleColor = Color(100, 100, 200)
    if input.IsMouseDown(MOUSE_LEFT) and 
       gui.MouseX() >= button1X and gui.MouseX() <= button1X + buttonW and
       gui.MouseY() >= button1Y and gui.MouseY() <= button1Y + buttonH then
        toggleColor = Color(150, 150, 255)
        
        if CurTime() - beaconConfig.lastUpdate > 0.2 then
            beaconConfig.lastUpdate = CurTime()
            beaconConfig.active = not beaconConfig.active
        end
    end
    
    draw.RoundedBox(4, button1X, button1Y, buttonW, buttonH, toggleColor)
    draw.SimpleText("Toggle", "DermaDefault", button1X + buttonW/2, button1Y + buttonH/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Range buttons
    local rangeDownColor = Color(200, 100, 0)
    if input.IsMouseDown(MOUSE_LEFT) and 
       gui.MouseX() >= button2X and gui.MouseX() <= button2X + buttonW and
       gui.MouseY() >= button2Y and gui.MouseY() <= button2Y + buttonH then
        rangeDownColor = Color(255, 150, 0)
        
        if CurTime() - beaconConfig.lastUpdate > 0.1 then
            beaconConfig.lastUpdate = CurTime()
            beaconConfig.range = math.max(500, beaconConfig.range - 500)
        end
    end
    
    draw.RoundedBox(4, button2X, button2Y, buttonW, buttonH, rangeDownColor)
    draw.SimpleText("Range -", "DermaDefault", button2X + buttonW/2, button2Y + buttonH/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    local rangeUpColor = Color(0, 200, 100)
    if input.IsMouseDown(MOUSE_LEFT) and 
       gui.MouseX() >= button3X and gui.MouseX() <= button3X + buttonW and
       gui.MouseY() >= button3Y and gui.MouseY() <= button3Y + buttonH then
        rangeUpColor = Color(0, 255, 150)
        
        if CurTime() - beaconConfig.lastUpdate > 0.1 then
            beaconConfig.lastUpdate = CurTime()
            beaconConfig.range = math.min(10000, beaconConfig.range + 500)
        end
    end
    
    draw.RoundedBox(4, button3X, button3Y, buttonW, buttonH, rangeUpColor)
    draw.SimpleText("Range +", "DermaDefault", button3X + buttonW/2, button3Y + buttonH/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Save button
    local saveColor = Color(0, 200, 0)
    if input.IsMouseDown(MOUSE_LEFT) and 
       gui.MouseX() >= button4X and gui.MouseX() <= button4X + buttonW and
       gui.MouseY() >= button4Y and gui.MouseY() <= button4Y + buttonH then
        saveColor = Color(0, 255, 0)
        
        if CurTime() - beaconConfig.lastUpdate > 0.2 then
            beaconConfig.lastUpdate = CurTime()
            
            -- Send update to server
            net.Start("hyperdrive_beacon_update")
            net.WriteEntity(beaconConfig.entity)
            net.WriteString(beaconConfig.name)
            net.WriteBool(beaconConfig.active)
            net.WriteFloat(beaconConfig.range)
            net.SendToServer()
            
            beaconConfig.entity:CloseConfig()
        end
    end
    
    draw.RoundedBox(4, button4X, button4Y, buttonW, buttonH, saveColor)
    draw.SimpleText("Save", "DermaDefault", button4X + buttonW/2, button4Y + buttonH/2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)
