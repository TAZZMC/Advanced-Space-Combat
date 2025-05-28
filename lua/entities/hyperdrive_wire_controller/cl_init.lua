-- Hyperdrive Wire Controller Entity - Client Side
include("shared.lua")

function ENT:Initialize()
    self.NextGlow = 0
    self.GlowIntensity = 0
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw controller status glow
    local time = CurTime()
    if time > self.NextGlow then
        self.NextGlow = time + 0.1
        self.GlowIntensity = math.sin(time * 3) * 0.3 + 0.7
    end
    
    local target = self:GetTargetEntity()
    local glowColor = Color(100, 100, 255, 150 * self.GlowIntensity)
    
    if IsValid(target) then
        glowColor = Color(0, 255, 100, 150 * self.GlowIntensity)
    end
    
    local pos = self:GetPos() + self:GetUp() * 8
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, 30 * self.GlowIntensity, 30 * self.GlowIntensity, glowColor)
    
    -- Draw connection line to target
    if IsValid(target) and LocalPlayer():GetPos():Distance(self:GetPos()) < 500 then
        self:DrawConnectionLine(target)
    end
    
    -- Draw info display
    if LocalPlayer():GetPos():Distance(self:GetPos()) < 200 then
        self:DrawInfoDisplay()
    end
end

function ENT:DrawConnectionLine(target)
    local startPos = self:GetPos() + self:GetUp() * 10
    local endPos = target:GetPos() + target:GetUp() * 10
    
    render.SetMaterial(Material("cable/cable2"))
    render.DrawBeam(startPos, endPos, 2, 0, 1, Color(0, 150, 255, 100))
end

function ENT:DrawInfoDisplay()
    local pos = self:GetPos() + Vector(0, 0, 25)
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.08)
        -- Background
        draw.RoundedBox(4, -80, -30, 160, 60, Color(0, 0, 0, 150))
        draw.RoundedBox(4, -78, -28, 156, 56, Color(20, 40, 80, 200))
        
        -- Title
        draw.SimpleText("WIRE CONTROLLER", "DermaDefaultBold", 0, -20, Color(100, 200, 255), TEXT_ALIGN_CENTER)
        
        -- Mode
        draw.SimpleText("Mode: " .. self:GetModeString(), "DermaDefault", 0, -5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        
        -- Target status
        local target = self:GetTargetEntity()
        if IsValid(target) then
            local targetColor = Color(0, 255, 0)
            draw.SimpleText("Target: " .. target:GetClass(), "DermaDefault", 0, 10, targetColor, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText("No Target", "DermaDefault", 0, 10, Color(255, 100, 0), TEXT_ALIGN_CENTER)
        end
        
        -- Range
        draw.SimpleText("Range: " .. math.floor(self:GetControlRange()) .. "u", "DermaDefault", 0, 25, Color(200, 200, 200), TEXT_ALIGN_CENTER)
    cam.End3D2D()
end
