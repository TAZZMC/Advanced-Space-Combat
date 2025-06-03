-- Advanced Space Combat - Railgun Client
-- Client-side rendering for electromagnetic railgun

include("shared.lua")

-- Client-side variables
ENT.ChargeEffect = 0
ENT.ElectricArcs = {}
ENT.MagneticField = 0
ENT.ChargingSound = nil

function ENT:Initialize()
    self:SetRenderBounds(Vector(-40, -40, -40), Vector(40, 40, 40))
    
    -- Initialize electric arcs
    for i = 1, 6 do
        self.ElectricArcs[i] = {
            active = false,
            intensity = 0,
            nextArc = 0
        }
    end
end

function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 250000 then return end
    
    self:DrawChargeEffect()
    self:DrawElectricArcs()
    self:DrawMagneticField()
    self:DrawTargetingSystem()
end

function ENT:DrawChargeEffect()
    local charging = self:GetNWBool("Charging", false)
    local chargeLevel = self:GetNWFloat("ChargeLevel", 0)
    
    if charging then
        self.ChargeEffect = Lerp(FrameTime() * 4, self.ChargeEffect, chargeLevel)
    else
        self.ChargeEffect = Lerp(FrameTime() * 6, self.ChargeEffect, 0)
    end
    
    if self.ChargeEffect > 0.1 then
        local chargePos = self:GetPos()
        
        -- Electromagnetic glow
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = chargePos
            dlight.r = 100 + self.ChargeEffect * 155
            dlight.g = 150 + self.ChargeEffect * 105
            dlight.b = 255
            dlight.brightness = self.ChargeEffect * 1.5
            dlight.decay = 1000
            dlight.size = 80
            dlight.dietime = CurTime() + 0.1
        end
        
        -- Charge buildup effect
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(chargePos, 25 * self.ChargeEffect, 25 * self.ChargeEffect, 
            Color(100 + self.ChargeEffect * 155, 150 + self.ChargeEffect * 105, 255, 200 * self.ChargeEffect))
    end
end

function ENT:DrawElectricArcs()
    if self.ChargeEffect < 0.3 then return end
    
    local time = CurTime()
    local basePos = self:GetPos()
    
    -- Update electric arcs
    for i = 1, 6 do
        local arc = self.ElectricArcs[i]
        
        if time > arc.nextArc then
            arc.active = true
            arc.intensity = math.Rand(0.5, 1.0) * self.ChargeEffect
            arc.nextArc = time + math.Rand(0.1, 0.3)
        end
        
        if arc.active then
            arc.intensity = arc.intensity * 0.95
            
            if arc.intensity < 0.1 then
                arc.active = false
            else
                -- Draw electric arc
                local arcStart = basePos + VectorRand() * 30
                local arcEnd = basePos + VectorRand() * 30
                
                render.SetMaterial(Material("cable/rope"))
                render.DrawBeam(arcStart, arcEnd, 2 * arc.intensity, 0, 1, 
                    Color(150 + arc.intensity * 105, 200 + arc.intensity * 55, 255, 255 * arc.intensity))
                
                -- Arc endpoints
                render.SetMaterial(Material("sprites/light_glow02_add"))
                render.DrawSprite(arcStart, 8 * arc.intensity, 8 * arc.intensity, 
                    Color(200, 220, 255, 255 * arc.intensity))
                render.DrawSprite(arcEnd, 8 * arc.intensity, 8 * arc.intensity, 
                    Color(200, 220, 255, 255 * arc.intensity))
            end
        end
    end
end

function ENT:DrawMagneticField()
    local active = self:GetNWBool("Active", false)
    
    if active then
        self.MagneticField = Lerp(FrameTime() * 3, self.MagneticField, 1)
    else
        self.MagneticField = Lerp(FrameTime() * 5, self.MagneticField, 0)
    end
    
    if self.MagneticField > 0.1 then
        local time = CurTime()
        local fieldPos = self:GetPos()
        
        -- Magnetic field visualization
        for i = 1, 8 do
            local angle = (i / 8) * math.pi * 2
            local radius = 40 + math.sin(time * 3 + i) * 10
            local fieldPoint = fieldPos + Vector(
                math.cos(angle) * radius,
                math.sin(angle) * radius,
                math.sin(time * 2 + i) * 15
            )
            
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(fieldPoint, 6 * self.MagneticField, 6 * self.MagneticField, 
                Color(100, 150, 255, 150 * self.MagneticField))
        end
        
        -- Magnetic field lines
        for i = 1, 4 do
            local startAngle = (i / 4) * math.pi * 2
            local endAngle = startAngle + math.pi
            
            local startPos = fieldPos + Vector(math.cos(startAngle) * 35, math.sin(startAngle) * 35, 0)
            local endPos = fieldPos + Vector(math.cos(endAngle) * 35, math.sin(endAngle) * 35, 0)
            
            render.SetMaterial(Material("cable/rope"))
            render.DrawBeam(startPos, endPos, 1, 0, 1, 
                Color(100, 150, 255, 100 * self.MagneticField))
        end
    end
end

function ENT:DrawTargetingSystem()
    local target = self:GetNWEntity("Target", NULL)
    local active = self:GetNWBool("Active", false)
    
    if active and IsValid(target) then
        local startPos = self:GetPos() + self:GetForward() * 35
        local targetPos = target:GetPos()
        
        -- Targeting beam
        render.SetMaterial(Material("cable/rope"))
        render.DrawBeam(startPos, targetPos, 1, 0, 1, Color(255, 100, 100, 80))
        
        -- Target marker
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(targetPos, 20, 20, Color(255, 100, 100, 150))
    end
end

function ENT:Think()
    local charging = self:GetNWBool("Charging", false)
    
    -- Handle charging sound
    if charging then
        if not self.ChargingSound then
            self.ChargingSound = CreateSound(self, "asc/weapons/railgun_charge.wav")
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
