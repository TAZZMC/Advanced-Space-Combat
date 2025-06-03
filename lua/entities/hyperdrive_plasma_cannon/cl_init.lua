-- Advanced Space Combat - Plasma Cannon Client
-- Client-side rendering for plasma cannon weapon

include("shared.lua")

-- Client-side variables
ENT.ChargeEffect = 0
ENT.BarrelGlow = 0
ENT.LastFireTime = 0
ENT.ChargingSound = nil

function ENT:Initialize()
    self:SetRenderBounds(Vector(-30, -30, -30), Vector(30, 30, 30))
end

function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 250000 then return end
    
    self:DrawChargeEffect()
    self:DrawBarrelGlow()
    self:DrawTargetingLaser()
end

function ENT:DrawChargeEffect()
    local charging = self:GetNWBool("Charging", false)
    local chargeLevel = self:GetNWFloat("ChargeLevel", 0)
    
    if charging then
        self.ChargeEffect = Lerp(FrameTime() * 5, self.ChargeEffect, chargeLevel)
    else
        self.ChargeEffect = Lerp(FrameTime() * 8, self.ChargeEffect, 0)
    end
    
    if self.ChargeEffect > 0.1 then
        local chargePos = self:GetPos() + self:GetForward() * 20
        
        -- Charge glow
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = chargePos
            dlight.r = 255
            dlight.g = 100 + self.ChargeEffect * 155
            dlight.b = 0
            dlight.brightness = self.ChargeEffect * 2
            dlight.decay = 1000
            dlight.size = 100
            dlight.dietime = CurTime() + 0.1
        end
        
        -- Charge sprite
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(chargePos, 30 * self.ChargeEffect, 30 * self.ChargeEffect, 
            Color(255, 100 + self.ChargeEffect * 155, 0, 255 * self.ChargeEffect))
        
        -- Charge particles
        if self.ChargeEffect > 0.5 then
            local time = CurTime()
            if time > self.LastFireTime + 0.1 then
                self.LastFireTime = time
                
                local emitter = ParticleEmitter(chargePos)
                if emitter then
                    for i = 1, 3 do
                        local particle = emitter:Add("effects/energyball", chargePos + VectorRand() * 20)
                        if particle then
                            particle:SetVelocity(VectorRand() * 50)
                            particle:SetLifeTime(0)
                            particle:SetDieTime(0.5)
                            particle:SetStartAlpha(255 * self.ChargeEffect)
                            particle:SetEndAlpha(0)
                            particle:SetStartSize(5)
                            particle:SetEndSize(1)
                            particle:SetColor(255, 150, 0)
                            particle:SetGravity(Vector(0, 0, 0))
                        end
                    end
                    emitter:Finish()
                end
            end
        end
    end
end

function ENT:DrawBarrelGlow()
    local active = self:GetNWBool("Active", false)
    local temperature = self:GetNWFloat("Temperature", 0)
    
    if active then
        self.BarrelGlow = Lerp(FrameTime() * 3, self.BarrelGlow, temperature)
    else
        self.BarrelGlow = Lerp(FrameTime() * 5, self.BarrelGlow, 0)
    end
    
    if self.BarrelGlow > 0.1 then
        local barrelPos = self:GetPos() + self:GetForward() * 25
        
        -- Barrel heat glow
        local heatColor = Color(255, 100 + self.BarrelGlow * 100, self.BarrelGlow * 50)
        
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(barrelPos, 15 * self.BarrelGlow, 15 * self.BarrelGlow, 
            Color(heatColor.r, heatColor.g, heatColor.b, 150 * self.BarrelGlow))
    end
end

function ENT:DrawTargetingLaser()
    local target = self:GetNWEntity("Target", NULL)
    local active = self:GetNWBool("Active", false)
    
    if active and IsValid(target) then
        local startPos = self:GetPos() + self:GetForward() * 30
        local endPos = target:GetPos()
        
        -- Targeting laser
        render.SetMaterial(Material("cable/rope"))
        render.DrawBeam(startPos, endPos, 1, 0, 1, Color(255, 0, 0, 100))
    end
end

function ENT:Think()
    local charging = self:GetNWBool("Charging", false)
    
    -- Handle charging sound
    if charging then
        if not self.ChargingSound then
            self.ChargingSound = CreateSound(self, "asc/weapons/plasma_cannon_charge.wav")
            if self.ChargingSound then
                self.ChargingSound:Play()
            end
        end
    else
        if self.ChargingSound then
            self.ChargingSound:Stop()
            self.ChargingSound = nil
        end
    end
    
    self:SetNextClientThink(CurTime() + 0.1)
    return true
end

function ENT:OnRemove()
    if self.ChargingSound then
        self.ChargingSound:Stop()
        self.ChargingSound = nil
    end
    
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.dietime = CurTime()
    end
end
