include("shared.lua")

--[[
    Advanced Space Combat - Point Defense Turret Entity (Client)
    
    Client-side rendering and effects for point defense turrets.
]]

-- Client-side initialization
function ENT:Initialize()
    self.LastStatusUpdate = 0
    self.StatusUpdateRate = 0.5
    
    -- Visual effects
    self.MuzzleFlashTime = 0
    self.MuzzleFlashDuration = 0.1
    
    -- HUD elements
    self.ShowHUD = false
    self.HUDAlpha = 0
    self.HUDTargetAlpha = 0
    
    -- Particle systems
    self.ParticleEmitter = nil
    
    -- Sound effects
    self.FireSound = nil
    self.TargetingSound = nil
    
    -- Initialize visual systems
    self:InitializeVisualEffects()
    self:InitializeSounds()
end

function ENT:InitializeVisualEffects()
    -- Create particle emitter for effects
    self.ParticleEmitter = ParticleEmitter(self:GetPos())
    
    -- Set up material overrides for CAP integration
    if ASC.CAP and ASC.CAP.IsAvailable() then
        local capMaterial = ASC.CAP.GetMaterial("point_defense_turret")
        if capMaterial then
            self:SetMaterial(capMaterial)
        end
    end
end

function ENT:InitializeSounds()
    -- Initialize sound effects
    if ASC.CAP and ASC.CAP.Sounds then
        self.FireSound = ASC.CAP.Sounds.GetSound("point_defense_fire")
        self.TargetingSound = ASC.CAP.Sounds.GetSound("point_defense_targeting")
    else
        -- Fallback sounds
        self.FireSound = "weapons/ar2/fire1.wav"
        self.TargetingSound = "buttons/blip1.wav"
    end
end

function ENT:Think()
    -- Update visual effects
    self:UpdateVisualEffects()
    
    -- Update HUD
    self:UpdateHUD()
    
    -- Update sounds
    self:UpdateSounds()
    
    self:SetNextClientThink(CurTime() + 0.05)
    return true
end

function ENT:UpdateVisualEffects()
    local currentTime = CurTime()
    
    -- Update muzzle flash
    if self.MuzzleFlashTime > 0 and currentTime - self.MuzzleFlashTime < self.MuzzleFlashDuration then
        self:RenderMuzzleFlash()
    end
    
    -- Update status light
    self:UpdateStatusLight()
    
    -- Update targeting beam
    if IsValid(self:GetCurrentTarget()) then
        self:RenderTargetingBeam()
    end
end

function ENT:RenderMuzzleFlash()
    if not self.ParticleEmitter then return end
    
    local pos = self:GetPos() + self:GetForward() * 20
    
    -- Create muzzle flash particles
    for i = 1, 3 do
        local particle = self.ParticleEmitter:Add("effects/muzzleflash" .. math.random(1, 4), pos)
        if particle then
            particle:SetVelocity(self:GetForward() * math.random(50, 100) + VectorRand() * 20)
            particle:SetLifeTime(0)
            particle:SetDieTime(0.1)
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.random(5, 10))
            particle:SetEndSize(0)
            particle:SetColor(255, 200, 100)
            particle:SetGravity(Vector(0, 0, -100))
        end
    end
end

function ENT:UpdateStatusLight()
    local color = self:GetStatusColor()
    
    -- Create status light effect
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = self:GetPos() + Vector(0, 0, 15)
        dlight.r = color.r
        dlight.g = color.g
        dlight.b = color.b
        dlight.brightness = self:GetActive() and 2 or 1
        dlight.decay = 1000
        dlight.size = 50
        dlight.dietime = CurTime() + 0.1
    end
end

function ENT:RenderTargetingBeam()
    local target = self:GetCurrentTarget()
    if not IsValid(target) then return end
    
    local startPos = self:GetPos()
    local endPos = target:GetPos()
    
    -- Render targeting beam
    render.SetMaterial(Material("cable/redlaser"))
    render.DrawBeam(startPos, endPos, 2, 0, 1, Color(255, 0, 0, 100))
end

-- HUD functionality removed

function ENT:UpdateSounds()
    -- Play targeting sound when acquiring target
    if IsValid(self:GetCurrentTarget()) and not self.playingTargetingSound then
        self:EmitSound(self.TargetingSound, 60, 100, 0.3)
        self.playingTargetingSound = true
    elseif not IsValid(self:GetCurrentTarget()) then
        self.playingTargetingSound = false
    end
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw additional visual elements
    self:DrawStatusIndicators()
    
    if self.ShowHUD then
        self:DrawHUD()
    end
end

function ENT:DrawStatusIndicators()
    local pos = self:GetPos() + Vector(0, 0, 20)
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Status text
        local status = self:GetStatusText()
        local color = self:GetStatusColor()
        
        draw.SimpleText(status, "DermaDefault", 0, 0, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Energy bar
        local energy = self:GetEnergy()
        local barWidth = 60
        local barHeight = 4
        
        draw.RoundedBox(2, -barWidth/2, 10, barWidth, barHeight, Color(50, 50, 50, 200))
        draw.RoundedBox(2, -barWidth/2, 10, (energy/100) * barWidth, barHeight, Color(0, 255, 0, 200))
        
        -- Heat bar
        local heat = self:GetHeat()
        draw.RoundedBox(2, -barWidth/2, 16, barWidth, barHeight, Color(50, 50, 50, 200))
        draw.RoundedBox(2, -barWidth/2, 16, (heat/100) * barWidth, barHeight, Color(255, 0, 0, 200))
        
        -- Ammo counter
        local ammo = self:GetAmmo()
        local maxAmmo = self:GetMaxAmmo()
        draw.SimpleText(ammo .. "/" .. maxAmmo, "DermaDefault", 0, 25, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

-- HUD drawing functionality removed as per user request

-- Network message handlers
net.Receive("ASC_PointDefense_MuzzleFlash", function()
    local ent = net.ReadEntity()
    if IsValid(ent) and ent.MuzzleFlashTime then
        ent.MuzzleFlashTime = CurTime()
        
        -- Play fire sound
        if ent.FireSound then
            ent:EmitSound(ent.FireSound, 75, math.random(95, 105), 0.5)
        end
    end
end)

net.Receive("ASC_PointDefense_TargetDestroyed", function()
    local ent = net.ReadEntity()
    local targetPos = net.ReadVector()
    
    if IsValid(ent) then
        -- Create target destroyed effect
        local effectData = EffectData()
        effectData:SetOrigin(targetPos)
        effectData:SetScale(0.5)
        util.Effect("Explosion", effectData)
        
        -- Update performance tracking
        if ent.pointDefense then
            ent.pointDefense.targetsDestroyed = (ent.pointDefense.targetsDestroyed or 0) + 1
        end
    end
end)

-- Cleanup
function ENT:OnRemove()
    if self.ParticleEmitter then
        self.ParticleEmitter:Finish()
    end
end
