-- Advanced Space Combat - Hyperspace Portal Effect
-- Professional hyperspace portal visual effect

EFFECT.Mat = Material("effects/asc_hyperspace_portal")
EFFECT.MatGlow = Material("effects/energyball")
EFFECT.MatRing = Material("effects/select_ring")

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self.Normal = data:GetNormal()
    self.Scale = data:GetScale() or 1
    self.Magnitude = data:GetMagnitude() or 100
    
    self.LifeTime = 3.0
    self.DieTime = CurTime() + self.LifeTime
    
    -- Portal properties
    self.PortalSize = self.Magnitude * self.Scale
    self.MaxSize = self.PortalSize * 2
    self.CurrentSize = 0
    
    -- Animation phases
    self.Phase = 1 -- 1=opening, 2=stable, 3=closing
    self.PhaseTime = CurTime()
    
    -- Particle effects
    self:CreateParticles()
    
    -- Sound effect
    self:EmitSound("ambient/energy/weld1.wav", 75, 100)
end

function EFFECT:CreateParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end
    
    -- Energy particles
    for i = 1, 20 do
        local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 50)
        if particle then
            particle:SetVelocity(VectorRand() * 100)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 3))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(5, 15))
            particle:SetEndSize(0)
            particle:SetColor(100, 150, 255)
            particle:SetGravity(Vector(0, 0, -50))
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
    
    -- Phase management
    if progress < 0.3 then
        self.Phase = 1 -- Opening
        self.CurrentSize = Lerp(progress / 0.3, 0, self.PortalSize)
    elseif progress < 0.7 then
        self.Phase = 2 -- Stable
        self.CurrentSize = self.PortalSize + math.sin(CurTime() * 5) * 10
    else
        self.Phase = 3 -- Closing
        local closeProgress = (progress - 0.7) / 0.3
        self.CurrentSize = Lerp(closeProgress, self.PortalSize, 0)
    end
    
    return true
end

function EFFECT:Render()
    local alpha = math.Clamp((self.DieTime - CurTime()) / self.LifeTime, 0, 1)
    if alpha <= 0 then return end
    
    -- Portal ring
    render.SetMaterial(self.Mat)
    render.DrawQuadEasy(
        self.Position,
        self.Normal,
        self.CurrentSize,
        self.CurrentSize,
        Color(100, 150, 255, alpha * 255)
    )
    
    -- Inner glow
    render.SetMaterial(self.MatGlow)
    render.DrawQuadEasy(
        self.Position + self.Normal * 2,
        self.Normal,
        self.CurrentSize * 0.8,
        self.CurrentSize * 0.8,
        Color(150, 200, 255, alpha * 128)
    )
    
    -- Outer ring
    render.SetMaterial(self.MatRing)
    render.DrawQuadEasy(
        self.Position - self.Normal * 2,
        self.Normal,
        self.CurrentSize * 1.2,
        self.CurrentSize * 1.2,
        Color(80, 120, 255, alpha * 64)
    )
end
