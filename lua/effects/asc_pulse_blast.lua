-- Advanced Space Combat - Pulse Blast Effect
-- Professional pulse weapon discharge effect

EFFECT.Mat = Material("effects/asc_pulse_beam")
EFFECT.MatCore = Material("effects/energyball")
EFFECT.MatFlash = Material("effects/muzzleflash1")

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self.Direction = data:GetNormal()
    self.Scale = data:GetScale() or 1
    self.Magnitude = data:GetMagnitude() or 100
    
    self.LifeTime = 0.8
    self.DieTime = CurTime() + self.LifeTime
    
    -- Pulse properties
    self.PulseLength = self.Magnitude
    self.PulseWidth = 8 * self.Scale
    self.MaxWidth = self.PulseWidth * 2
    
    -- Animation
    self.CurrentLength = 0
    self.CurrentWidth = self.PulseWidth
    
    -- Create muzzle flash
    self:CreateMuzzleFlash()
    
    -- Create trail particles
    self:CreateTrailParticles()
    
    -- Sound effect
    self:EmitSound("weapons/physcannon/energy_sing_explosion2.wav", 75, 150)
end

function EFFECT:CreateMuzzleFlash()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Muzzle flash particles
    for i = 1, 8 do
        local particle = emitter:Add("effects/muzzleflash" .. math.random(1, 4), self.Position)
        if particle then
            particle:SetVelocity(self.Direction * math.Rand(50, 100) + VectorRand() * 30)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.1, 0.3))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(15, 25))
            particle:SetEndSize(math.Rand(5, 10))
            particle:SetColor(255, 100, 50)
            particle:SetAirResistance(200)
        end
    end
    
    emitter:Finish()
end

function EFFECT:CreateTrailParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Energy trail particles
    for i = 1, 12 do
        local offset = self.Direction * i * 20
        local particle = emitter:Add("effects/energyball", self.Position + offset)
        if particle then
            particle:SetVelocity(self.Direction * 500 + VectorRand() * 20)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(0.3, 0.6))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(8, 12))
            particle:SetEndSize(0)
            particle:SetColor(255, 150, 100)
            particle:SetAirResistance(50)
        end
    end
    
    emitter:Finish()
end

function EFFECT:Think()
    if CurTime() > self.DieTime then
        return false
    end
    
    local timeLeft = self.DieTime - CurTime()
    local progress = 1 - (timeLeft / self.LifeTime)
    
    -- Animate pulse
    self.CurrentLength = Lerp(progress, 0, self.PulseLength)
    
    if progress < 0.3 then
        self.CurrentWidth = Lerp(progress / 0.3, self.PulseWidth, self.MaxWidth)
    else
        self.CurrentWidth = Lerp((progress - 0.3) / 0.7, self.MaxWidth, 0)
    end
    
    return true
end

function EFFECT:Render()
    local alpha = math.Clamp((self.DieTime - CurTime()) / self.LifeTime, 0, 1)
    if alpha <= 0 then return end
    
    local endPos = self.Position + self.Direction * self.CurrentLength
    
    -- Main beam
    render.SetMaterial(self.Mat)
    render.DrawBeam(
        self.Position,
        endPos,
        self.CurrentWidth,
        0,
        1,
        Color(255, 150, 100, alpha * 255)
    )
    
    -- Core beam
    render.SetMaterial(self.MatCore)
    render.DrawBeam(
        self.Position,
        endPos,
        self.CurrentWidth * 0.5,
        0,
        1,
        Color(255, 200, 150, alpha * 200)
    )
end
