-- Advanced Space Combat - Plasma Cannon Client
-- Client-side rendering and effects for plasma cannon

include("shared.lua")

-- Materials
local matEntity = Material("entities/asc_plasma_cannon")
local matGlow = Material("effects/energyball")
local matBeam = Material("effects/asc_plasma_beam")
local matCharge = Material("effects/energysplash")

function ENT:Initialize()
    -- Set up rendering
    self.LastEffect = 0
    self.ChargeParticles = {}
    self.GlowIntensity = 0
    self.HeatGlow = 0
    
    -- Create particle emitter
    self.ParticleEmitter = ParticleEmitter(self:GetPos())
    
    -- Initialize client-side systems
    self:InitializeClientSystems()
end

function ENT:InitializeClientSystems()
    -- Set up dynamic lighting
    self.DynamicLight = DynamicLight(self:EntIndex())
    if self.DynamicLight then
        self.DynamicLight.pos = self:GetPos()
        self.DynamicLight.r = 255
        self.DynamicLight.g = 100
        self.DynamicLight.b = 50
        self.DynamicLight.brightness = 0
        self.DynamicLight.decay = 1000
        self.DynamicLight.size = 200
        self.DynamicLight.dietime = CurTime() + 1
    end
    
    -- Set up sound loops
    self.ChargingSound = nil
    self.CoolingSound = nil
end

function ENT:Think()
    -- Update particle effects
    self:UpdateParticleEffects()
    
    -- Update dynamic lighting
    self:UpdateDynamicLighting()
    
    -- Update sound effects
    self:UpdateSoundEffects()
    
    -- Update glow intensity
    local chargeLevel = self:GetChargeLevel()
    local heatLevel = self:GetHeatLevel()
    
    self.GlowIntensity = Lerp(FrameTime() * 5, self.GlowIntensity, chargeLevel / 100)
    self.HeatGlow = Lerp(FrameTime() * 3, self.HeatGlow, heatLevel / 100)
end

function ENT:UpdateParticleEffects()
    if not IsValid(self.ParticleEmitter) then
        self.ParticleEmitter = ParticleEmitter(self:GetPos())
        if not self.ParticleEmitter then return end
    end
    
    local pos = self:GetPos()
    
    -- Charging particles
    if self:GetIsCharging() then
        if CurTime() - self.LastEffect > 0.1 then
            self:CreateChargingParticles()
            self.LastEffect = CurTime()
        end
    end
    
    -- Heat particles
    if self:GetHeatLevel() > 50 then
        if math.random() < 0.3 then
            self:CreateHeatParticles()
        end
    end
    
    -- Overheated particles
    if self:GetOverheated() then
        if math.random() < 0.5 then
            self:CreateOverheatParticles()
        end
    end
end

function ENT:CreateChargingParticles()
    local pos = self:GetPos() + self:GetUp() * 20
    
    for i = 1, 3 do
        local particle = self.ParticleEmitter:Add("effects/energyball", pos + VectorRand() * 15)
        if particle then
            particle:SetVelocity(Vector(0, 0, math.Rand(20, 50)))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.5, 1.5))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(3, 8))
            particle:SetEndSize(0)
            particle:SetColor(255, 150, 100)
            particle:SetGravity(Vector(0, 0, -50))
            particle:SetAirResistance(50)
        end
    end
end

function ENT:CreateHeatParticles()
    local pos = self:GetPos() + VectorRand() * 10
    
    local particle = self.ParticleEmitter:Add("effects/fire_cloud1", pos)
    if particle then
        particle:SetVelocity(VectorRand() * 30)
        particle:SetLifeTime(0)
        particle:SetDieTime(math.Rand(1, 2))
        particle:SetStartAlpha(100)
        particle:SetEndAlpha(0)
        particle:SetStartSize(math.Rand(5, 12))
        particle:SetEndSize(math.Rand(15, 25))
        particle:SetColor(255, 100, 50)
        particle:SetAirResistance(100)
    end
end

function ENT:CreateOverheatParticles()
    local pos = self:GetPos() + VectorRand() * 20
    
    local particle = self.ParticleEmitter:Add("effects/energysplash", pos)
    if particle then
        particle:SetVelocity(VectorRand() * 100)
        particle:SetLifeTime(0)
        particle:SetDieTime(math.Rand(0.3, 0.8))
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(0)
        particle:SetStartSize(math.Rand(2, 6))
        particle:SetEndSize(0)
        particle:SetColor(255, 50, 50)
        particle:SetGravity(Vector(0, 0, -200))
        particle:SetAirResistance(150)
    end
end

function ENT:UpdateDynamicLighting()
    if not self.DynamicLight then return end
    
    local pos = self:GetPos() + self:GetUp() * 15
    self.DynamicLight.pos = pos
    
    -- Charging light
    if self:GetIsCharging() then
        local intensity = self:GetChargeLevel() / 100
        self.DynamicLight.brightness = intensity * 2
        self.DynamicLight.r = 255
        self.DynamicLight.g = 150 + intensity * 105
        self.DynamicLight.b = 100 + intensity * 155
    -- Heat light
    elseif self:GetHeatLevel() > 30 then
        local intensity = self:GetHeatLevel() / 100
        self.DynamicLight.brightness = intensity * 1.5
        self.DynamicLight.r = 255
        self.DynamicLight.g = 100 - intensity * 50
        self.DynamicLight.b = 50 - intensity * 30
    else
        self.DynamicLight.brightness = 0
    end
    
    self.DynamicLight.dietime = CurTime() + 1
end

function ENT:UpdateSoundEffects()
    -- Charging sound
    if self:GetIsCharging() then
        if not self.ChargingSound then
            self.ChargingSound = CreateSound(self, "ambient/energy/weld1.wav")
            self.ChargingSound:Play()
        end
        
        local pitch = 80 + (self:GetChargeLevel() / 100) * 40
        self.ChargingSound:ChangePitch(pitch)
    else
        if self.ChargingSound then
            self.ChargingSound:Stop()
            self.ChargingSound = nil
        end
    end
    
    -- Cooling sound
    if self:GetHeatLevel() > 70 then
        if not self.CoolingSound then
            self.CoolingSound = CreateSound(self, "ambient/water/water_spray1.wav")
            self.CoolingSound:Play()
        end
        
        local volume = (self:GetHeatLevel() - 70) / 30
        self.CoolingSound:ChangeVolume(volume * 0.5)
    else
        if self.CoolingSound then
            self.CoolingSound:Stop()
            self.CoolingSound = nil
        end
    end
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw charging effects
    if self:GetIsCharging() then
        self:DrawChargingEffects()
    end
    
    -- Draw heat effects
    if self:GetHeatLevel() > 30 then
        self:DrawHeatEffects()
    end
    
    -- Draw targeting laser
    if self:GetAutoTarget() and IsValid(self:GetTargetEntity()) then
        self:DrawTargetingLaser()
    end
end

function ENT:DrawChargingEffects()
    local pos = self:GetPos() + self:GetUp() * 20
    local intensity = self:GetChargeLevel() / 100
    
    render.SetMaterial(matGlow)
    render.DrawSprite(pos, 30 * intensity, 30 * intensity, Color(255, 150 + intensity * 105, 100 + intensity * 155, 200 * intensity))
end

function ENT:DrawHeatEffects()
    local pos = self:GetPos()
    local intensity = self:GetHeatLevel() / 100
    
    render.SetMaterial(matGlow)
    render.DrawSprite(pos, 20 * intensity, 20 * intensity, Color(255, 100 - intensity * 50, 50 - intensity * 30, 150 * intensity))
end

function ENT:DrawTargetingLaser()
    local target = self:GetTargetEntity()
    if not IsValid(target) then return end
    
    local startPos = self:GetPos() + self:GetUp() * 15
    local endPos = target:GetPos()
    
    render.SetMaterial(matBeam)
    render.DrawBeam(startPos, endPos, 2, 0, 1, Color(255, 0, 0, 100))
end

function ENT:OnRemove()
    -- Clean up sounds
    if self.ChargingSound then
        self.ChargingSound:Stop()
    end
    
    if self.CoolingSound then
        self.CoolingSound:Stop()
    end
    
    -- Clean up particle emitter
    if IsValid(self.ParticleEmitter) then
        self.ParticleEmitter:Finish()
    end
end
