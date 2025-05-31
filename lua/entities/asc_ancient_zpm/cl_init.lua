-- Advanced Space Combat - Ancient ZPM Entity (Client)

include("shared.lua")

function ENT:Initialize()
    self.GlowSprite = Material("sprites/light_glow02_add")
    self.NextParticle = 0
    self.ParticleDelay = 0.1
end

function ENT:Draw()
    self:DrawModel()
    
    if self:GetNWBool("Glowing") then
        self:DrawGlow()
        self:DrawParticles()
    end
end

function ENT:DrawGlow()
    local pos = self:GetPos() + self:GetUp() * 20
    local size = 50 + math.sin(CurTime() * 3) * 10
    
    render.SetMaterial(self.GlowSprite)
    render.DrawSprite(pos, size, size, Color(100, 150, 255, 200))
    
    -- Energy field effect
    local matrix = Matrix()
    matrix:Translate(pos)
    matrix:Scale(Vector(1, 1, 1) * (1 + math.sin(CurTime() * 2) * 0.1))
    
    cam.PushModelMatrix(matrix)
    render.SetMaterial(Material("hyperdrive/energy_field"))
    render.DrawSphere(Vector(0, 0, 0), 30, 16, 16, Color(100, 150, 255, 100))
    cam.PopModelMatrix()
end

function ENT:DrawParticles()
    if CurTime() < self.NextParticle then return end
    self.NextParticle = CurTime() + self.ParticleDelay
    
    local pos = self:GetPos() + self:GetUp() * 20
    
    local emitter = ParticleEmitter(pos)
    if emitter then
        for i = 1, 3 do
            local particle = emitter:Add("effects/spark", pos + VectorRand() * 20)
            if particle then
                particle:SetVelocity(VectorRand() * 50)
                particle:SetLifeTime(0)
                particle:SetDieTime(2)
                particle:SetStartAlpha(255)
                particle:SetEndAlpha(0)
                particle:SetStartSize(2)
                particle:SetEndSize(0)
                particle:SetColor(100, 150, 255)
                particle:SetGravity(Vector(0, 0, -50))
            end
        end
        emitter:Finish()
    end
end

function ENT:Think()
    -- Energy transfer beam effect
    local shipCore = self:FindNearbyShipCore()
    if IsValid(shipCore) and self:GetNWBool("Active") then
        self:DrawEnergyBeam(shipCore)
    end
end

function ENT:FindNearbyShipCore()
    local nearbyEnts = ents.FindInSphere(self:GetPos(), 2000)
    
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            return ent
        end
    end
    
    return nil
end

function ENT:DrawEnergyBeam(target)
    if not IsValid(target) then return end
    
    local startPos = self:GetPos() + self:GetUp() * 20
    local endPos = target:GetPos()
    
    render.SetMaterial(Material("hyperdrive/energy_beam"))
    render.DrawBeam(startPos, endPos, 5, 0, 1, Color(100, 150, 255, 150))
end
