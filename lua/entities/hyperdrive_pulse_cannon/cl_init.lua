include("shared.lua")

-- Client-side pulse cannon
function ENT:Initialize()
    self.NextEffectTime = 0
    self.WeaponActive = false
    self.TargetLocked = false
    self.lastFireTime = 0
    self.pulseTime = 0
    self.chargeEffect = 0
end

function ENT:Draw()
    self:DrawModel()
    
    -- Apply dynamic material based on weapon state
    if self:GetWeaponActive() then
        self:SetMaterial("models/props_combine/metal_combinebridge001")
        
        -- Color based on status
        if self:GetOverheated() then
            self:SetColor(Color(255, 100, 100, 255)) -- Red when overheated
        elseif self:GetTargetLocked() then
            self:SetColor(Color(255, 200, 100, 255)) -- Orange when locked
        else
            self:SetColor(Color(100, 200, 255, 255)) -- Blue when active
        end
        
        -- Pulsing effect when active
        self.pulseTime = self.pulseTime + FrameTime() * 3
        local pulse = math.sin(self.pulseTime) * 0.3 + 0.7
        
        -- Weapon charge effect
        local pos = self:GetPos()
        local forward = self:GetForward()
        local size = 16 * pulse
        
        -- Main weapon glow
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(pos + forward * 25, size, size, Color(100, 200, 255, 150 * pulse))
        
        -- Targeting laser when locked
        if self:GetTargetLocked() and IsValid(self:GetTarget()) then
            self:DrawTargetingLaser()
        end
        
        -- Charge effect when about to fire
        if CurTime() - self.lastFireTime < 0.5 then
            self.chargeEffect = math.max(0, self.chargeEffect - FrameTime() * 2)
            local chargeSize = size * (1 + self.chargeEffect)
            render.DrawSprite(pos + forward * 25, chargeSize, chargeSize, Color(255, 255, 255, 100 * self.chargeEffect))
        end
        
        -- Heat indicator
        self:DrawHeatIndicator()
        
        -- Status display
        self:DrawStatusDisplay()
    else
        self:SetMaterial("")
        self:SetColor(Color(150, 150, 150, 255)) -- Gray when inactive
    end
end

function ENT:DrawTargetingLaser()
    local target = self:GetTarget()
    if not IsValid(target) then return end
    
    local startPos = self:GetPos() + self:GetForward() * 30
    local endPos = target:GetPos()
    
    -- Draw targeting beam
    render.SetMaterial(Material("cable/redlaser"))
    render.DrawBeam(startPos, endPos, 2, 0, 1, Color(255, 100, 100, 150))
    
    -- Draw target indicator
    local targetPos = endPos + Vector(0, 0, 20)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang.Forward(), 90)
    ang:RotateAroundAxis(ang.Right(), 90)
    
    cam.Start3D2D(targetPos, ang, 0.2)
        draw.SimpleText("TARGET", "DermaDefault", 0, 0, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:DrawHeatIndicator()
    local heat = self:GetHeat()
    local maxHeat = self:GetMaxHeat()
    
    if heat <= 0 or maxHeat <= 0 then return end
    
    local heatPercent = heat / maxHeat
    local pos = self:GetPos() + self:GetUp() * 25 + self:GetRight() * 15
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang.Forward(), 90)
    ang:RotateAroundAxis(ang.Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Heat bar background
        draw.RoundedBox(4, -30, -5, 60, 10, Color(50, 50, 50, 200))
        
        -- Heat bar fill
        local heatColor = Color(255 * heatPercent, 255 * (1 - heatPercent), 0, 200)
        draw.RoundedBox(4, -28, -3, 56 * heatPercent, 6, heatColor)
        
        -- Heat text
        draw.SimpleText("HEAT", "DermaDefault", 0, -15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:DrawStatusDisplay()
    local pos = self:GetPos() + self:GetUp() * 30
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang.Forward(), 90)
    ang:RotateAroundAxis(ang.Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.08)
        local status = self:GetWeaponStatus()
        local color = Color(255, 255, 255)
        
        if self:GetOverheated() then
            color = Color(255, 100, 100)
            status = "OVERHEATED"
        elseif self:GetTargetLocked() then
            color = Color(255, 200, 100)
        elseif self:GetWeaponActive() then
            color = Color(100, 255, 100)
        end
        
        draw.SimpleText(status, "DermaDefault", 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Weapon info
        draw.SimpleText("PULSE CANNON", "DermaDefault", 0, -20, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if self:GetAutoTarget() then
            draw.SimpleText("AUTO-TARGET", "DermaDefault", 0, 15, Color(100, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

function ENT:Think()
    -- Update weapon effects
    if self:GetWeaponActive() and CurTime() > self.NextEffectTime then
        self:CreateWeaponEffects()
        self.NextEffectTime = CurTime() + 1
    end
    
    -- Targeting effects
    if self:GetTargetLocked() and CurTime() - self.lastFireTime > 2 then
        self:CreateTargetingEffects()
    end
end

function ENT:CreateWeaponEffects()
    local pos = self:GetPos()
    local forward = self:GetForward()
    
    -- Energy buildup particles
    local effectData = EffectData()
    effectData:SetOrigin(pos + forward * 20)
    effectData:SetNormal(forward)
    effectData:SetScale(0.5)
    effectData:SetMagnitude(1)
    util.Effect("BlueFlash", effectData)
    
    -- Weapon charging sound
    if math.random() < 0.3 then
        self:EmitSound("ambient/energy/electric_loop.wav", 50, 120, 0.3)
    end
end

function ENT:CreateTargetingEffects()
    if not IsValid(self:GetTarget()) then return end
    
    local targetPos = self:GetTarget():GetPos()
    
    -- Target acquisition effect
    local effectData = EffectData()
    effectData:SetOrigin(targetPos)
    effectData:SetScale(1)
    util.Effect("BlueFlash", effectData)
end

function ENT:CreateFireEffect(targetPos)
    local pos = self:GetPos()
    local forward = self:GetForward()
    local muzzlePos = pos + forward * 30
    
    -- Muzzle flash
    local effectData = EffectData()
    effectData:SetOrigin(muzzlePos)
    effectData:SetNormal(forward)
    effectData:SetScale(2)
    effectData:SetMagnitude(2)
    util.Effect("MuzzleFlash", effectData)
    
    -- Pulse trail
    if targetPos then
        render.SetMaterial(Material("cable/blue_elec"))
        render.DrawBeam(muzzlePos, targetPos, 8, 0, 1, Color(100, 200, 255, 255))
        
        -- Impact effect at target
        timer.Simple(0.1, function()
            local impactData = EffectData()
            impactData:SetOrigin(targetPos)
            impactData:SetScale(3)
            util.Effect("BlueFlash", impactData)
        end)
    end
    
    -- Charge effect
    self.chargeEffect = 1.0
    self.lastFireTime = CurTime()
    
    -- Fire sound
    self:EmitSound("weapons/physcannon/energy_sing_explosion2.wav", 75, 100, 0.8)
end

-- Network message handling
net.Receive("HyperdriveWeaponFire", function()
    local weapon = net.ReadEntity()
    local targetPos = net.ReadVector()
    
    if IsValid(weapon) and weapon.CreateFireEffect then
        weapon:CreateFireEffect(targetPos)
    end
end)
