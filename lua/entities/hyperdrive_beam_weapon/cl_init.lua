include("shared.lua")

-- Client-side beam weapon
function ENT:Initialize()
    self.NextEffectTime = 0
    self.beamEffect = nil
    self.beamStartTime = 0
    self.beamEndPos = Vector(0, 0, 0)
    self.chargeEffect = 0
    self.pulseTime = 0
    self.beamIntensity = 0
    self.hitEffects = {}
end

function ENT:Draw()
    self:DrawModel()
    
    -- Apply dynamic material based on weapon state
    if self:GetWeaponActive() then
        self:SetMaterial("models/props_combine/metal_combinebridge001")
        
        -- Color based on status
        if self:GetOverheated() then
            self:SetColor(Color(255, 100, 100, 255)) -- Red when overheated
        elseif self:GetBeamFiring() then
            self:SetColor(Color(255, 255, 100, 255)) -- Yellow when firing
        elseif self:GetTargetLocked() then
            self:SetColor(Color(255, 200, 100, 255)) -- Orange when locked
        else
            self:SetColor(Color(100, 200, 255, 255)) -- Blue when active
        end
        
        -- Pulsing effect when active
        self.pulseTime = self.pulseTime + FrameTime() * 2
        local pulse = math.sin(self.pulseTime) * 0.3 + 0.7
        
        -- Weapon charge effect
        local pos = self:GetPos()
        local forward = self:GetForward()
        local size = 20 * pulse
        
        -- Main weapon glow
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(pos + forward * 30, size, size, Color(100, 200, 255, 150 * pulse))
        
        -- Charging effect when about to fire
        if self:GetBeamFiring() then
            self.chargeEffect = math.min(1, self.chargeEffect + FrameTime() * 3)
            local chargeSize = size * (1 + self.chargeEffect)
            render.DrawSprite(pos + forward * 30, chargeSize, chargeSize, Color(255, 255, 255, 100 * self.chargeEffect))
            
            -- Draw the beam
            self:DrawBeam()
        else
            self.chargeEffect = math.max(0, self.chargeEffect - FrameTime() * 2)
        end
        
        -- Targeting laser when locked but not firing
        if self:GetTargetLocked() and not self:GetBeamFiring() and IsValid(self:GetTarget()) then
            self:DrawTargetingLaser()
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

function ENT:DrawBeam()
    if not self:GetBeamFiring() then return end
    
    local startPos = self:GetPos() + self:GetForward() * 35
    local endPos = self:GetBeamEnd()
    
    if endPos == Vector(0, 0, 0) and IsValid(self:GetTarget()) then
        endPos = self:GetTarget():GetPos()
    end
    
    if endPos == Vector(0, 0, 0) then return end
    
    -- Update beam intensity
    self.beamIntensity = math.min(1, self.beamIntensity + FrameTime() * 4)
    
    -- Main beam
    local beamWidth = 12 * self.beamIntensity
    local beamColor = Color(100, 200, 255, 255 * self.beamIntensity)
    
    render.SetMaterial(Material("cable/blue_elec"))
    render.DrawBeam(startPos, endPos, beamWidth, 0, 1, beamColor)
    
    -- Inner core beam
    local coreWidth = 6 * self.beamIntensity
    local coreColor = Color(255, 255, 255, 200 * self.beamIntensity)
    
    render.SetMaterial(Material("cable/redlaser"))
    render.DrawBeam(startPos, endPos, coreWidth, 0, 1, coreColor)
    
    -- Outer glow beam
    local glowWidth = 20 * self.beamIntensity
    local glowColor = Color(150, 220, 255, 100 * self.beamIntensity)
    
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawBeam(startPos, endPos, glowWidth, 0, 1, glowColor)
    
    -- Beam fluctuation effect
    local fluctuation = math.sin(CurTime() * 20) * 0.1 + 0.9
    local fluctuationColor = Color(200, 240, 255, 150 * self.beamIntensity * fluctuation)
    render.DrawBeam(startPos, endPos, beamWidth * fluctuation, 0, 1, fluctuationColor)
    
    -- Muzzle effect
    local muzzleSize = 25 * self.beamIntensity
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(startPos, muzzleSize, muzzleSize, Color(255, 255, 255, 200 * self.beamIntensity))
    
    -- Impact effect
    local impactSize = 30 * self.beamIntensity
    render.DrawSprite(endPos, impactSize, impactSize, Color(255, 200, 100, 150 * self.beamIntensity))
end

function ENT:DrawTargetingLaser()
    local target = self:GetTarget()
    if not IsValid(target) then return end
    
    local startPos = self:GetPos() + self:GetForward() * 35
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
        draw.SimpleText("BEAM TARGET", "DermaDefault", 0, 0, Color(255, 100, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:DrawHeatIndicator()
    local heat = self:GetHeat()
    local maxHeat = self:GetMaxHeat()
    
    if heat <= 0 or maxHeat <= 0 then return end
    
    local heatPercent = heat / maxHeat
    local pos = self:GetPos() + self:GetUp() * 30 + self:GetRight() * 20
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang.Forward(), 90)
    ang:RotateAroundAxis(ang.Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Heat bar background
        draw.RoundedBox(4, -35, -5, 70, 10, Color(50, 50, 50, 200))
        
        -- Heat bar fill
        local heatColor = Color(255 * heatPercent, 255 * (1 - heatPercent), 0, 200)
        draw.RoundedBox(4, -33, -3, 66 * heatPercent, 6, heatColor)
        
        -- Heat text
        draw.SimpleText("HEAT", "DermaDefault", 0, -15, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Beam power indicator
        local beamPower = self:GetBeamPower()
        draw.SimpleText("POWER: " .. beamPower .. "%", "DermaDefault", 0, 15, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:DrawStatusDisplay()
    local pos = self:GetPos() + self:GetUp() * 35
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang.Forward(), 90)
    ang:RotateAroundAxis(ang.Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.08)
        local status = self:GetWeaponStatus()
        local color = Color(255, 255, 255)
        
        if self:GetOverheated() then
            color = Color(255, 100, 100)
            status = "OVERHEATED"
        elseif self:GetBeamFiring() then
            color = Color(255, 255, 100)
            status = "BEAM FIRING"
        elseif self:GetTargetLocked() then
            color = Color(255, 200, 100)
        elseif self:GetWeaponActive() then
            color = Color(100, 255, 100)
        end
        
        draw.SimpleText(status, "DermaDefault", 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Weapon info
        draw.SimpleText("BEAM WEAPON", "DermaDefault", 0, -20, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        if self:GetAutoTarget() then
            draw.SimpleText("AUTO-TARGET", "DermaDefault", 0, 15, Color(100, 200, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        
        -- Beam firing indicator
        if self:GetBeamFiring() then
            local fireTime = CurTime() - self.beamStartTime
            draw.SimpleText("FIRING: " .. string.format("%.1f", fireTime) .. "s", "DermaDefault", 0, 30, Color(255, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

function ENT:Think()
    -- Update beam effects
    if self:GetWeaponActive() and CurTime() > self.NextEffectTime then
        self:CreateWeaponEffects()
        self.NextEffectTime = CurTime() + 0.5
    end
    
    -- Update beam intensity
    if not self:GetBeamFiring() then
        self.beamIntensity = math.max(0, self.beamIntensity - FrameTime() * 2)
    end
    
    -- Clean up old hit effects
    for i = #self.hitEffects, 1, -1 do
        local effect = self.hitEffects[i]
        if CurTime() - effect.time > 0.5 then
            table.remove(self.hitEffects, i)
        end
    end
end

function ENT:CreateWeaponEffects()
    local pos = self:GetPos()
    local forward = self:GetForward()
    
    -- Energy buildup particles
    local effectData = EffectData()
    effectData:SetOrigin(pos + forward * 25)
    effectData:SetNormal(forward)
    effectData:SetScale(0.8)
    effectData:SetMagnitude(1)
    util.Effect("BlueFlash", effectData)
    
    -- Weapon charging sound
    if self:GetBeamFiring() then
        if math.random() < 0.5 then
            self:EmitSound("ambient/energy/electric_loop.wav", 60, 110, 0.4)
        end
    else
        if math.random() < 0.2 then
            self:EmitSound("ambient/energy/electric_loop.wav", 40, 130, 0.2)
        end
    end
end

function ENT:CreateBeamStartEffect()
    local pos = self:GetPos()
    local forward = self:GetForward()
    local muzzlePos = pos + forward * 35
    
    -- Beam start effect
    local effectData = EffectData()
    effectData:SetOrigin(muzzlePos)
    effectData:SetNormal(forward)
    effectData:SetScale(3)
    effectData:SetMagnitude(3)
    util.Effect("BlueFlash", effectData)
    
    -- Charge effect
    self.chargeEffect = 1.0
    self.beamStartTime = CurTime()
    self.beamIntensity = 0
    
    -- Beam start sound
    self:EmitSound("weapons/physcannon/energy_sing_loop4.wav", 75, 100, 0.6)
end

function ENT:CreateBeamStopEffect()
    -- Beam stop effect
    local pos = self:GetPos()
    local forward = self:GetForward()
    local muzzlePos = pos + forward * 35
    
    local effectData = EffectData()
    effectData:SetOrigin(muzzlePos)
    effectData:SetScale(2)
    util.Effect("BlueFlash", effectData)
    
    -- Stop sound
    self:StopSound("weapons/physcannon/energy_sing_loop4.wav")
    self:EmitSound("weapons/physcannon/energy_disintegrate4.wav", 70, 120, 0.5)
end

function ENT:CreateBeamHitEffect(hitPos)
    -- Impact effect
    local effectData = EffectData()
    effectData:SetOrigin(hitPos)
    effectData:SetScale(2)
    util.Effect("BlueFlash", effectData)
    
    -- Sparks
    for i = 1, 3 do
        local spark = EffectData()
        spark:SetOrigin(hitPos + VectorRand() * 15)
        spark:SetScale(0.3)
        util.Effect("Sparks", spark)
    end
    
    -- Add to hit effects list
    table.insert(self.hitEffects, {pos = hitPos, time = CurTime()})
end

-- Network message handling
net.Receive("HyperdriveBeamFire", function()
    local weapon = net.ReadEntity()
    local target = net.ReadEntity()
    
    if IsValid(weapon) and weapon.CreateBeamStartEffect then
        weapon:CreateBeamStartEffect()
    end
end)

net.Receive("HyperdriveBeamStop", function()
    local weapon = net.ReadEntity()
    
    if IsValid(weapon) and weapon.CreateBeamStopEffect then
        weapon:CreateBeamStopEffect()
    end
end)

net.Receive("HyperdriveBeamHit", function()
    local weapon = net.ReadEntity()
    local hitPos = net.ReadVector()
    
    if IsValid(weapon) and weapon.CreateBeamHitEffect then
        weapon:CreateBeamHitEffect(hitPos)
    end
end)
