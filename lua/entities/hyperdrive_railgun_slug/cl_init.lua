-- Advanced Space Combat - Railgun Slug Client
-- Client-side rendering for high-velocity kinetic projectile

include("shared.lua")

-- Client-side variables
ENT.TrailEffect = nil
ENT.ElectricTrail = nil
ENT.SonicBoom = 0
ENT.LastSonicTime = 0

function ENT:Initialize()
    self:SetRenderBounds(Vector(-5, -5, -5), Vector(5, 5, 5))
    
    -- Create electromagnetic trail
    self.TrailEffect = util.SpriteTrail(self, 0, Color(150, 200, 255, 200), false, 4, 1, 0.3, 1/5*0.3, "trails/laser")
    
    -- Create electric discharge trail
    self.ElectricTrail = util.SpriteTrail(self, 0, Color(255, 255, 255, 150), false, 2, 1, 0.1, 1/3*0.1, "trails/electric")
end

function ENT:Draw()
    -- Don't draw model for small projectile, just effects
    -- self:DrawModel()
    
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 4000000 then return end -- 2000 unit distance
    
    self:DrawProjectileCore()
    self:DrawElectromagneticField()
    self:DrawSonicEffects()
end

function ENT:DrawProjectileCore()
    local velocity = self:GetVelocity()
    local speed = velocity:Length()
    local speedRatio = math.min(1, speed / self.MaxSpeed)
    
    -- Core projectile glow
    local corePos = self:GetPos()
    
    -- Dynamic light based on speed
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = corePos
        dlight.r = 150 + speedRatio * 105
        dlight.g = 200 + speedRatio * 55
        dlight.b = 255
        dlight.brightness = 0.5 + speedRatio * 1.5
        dlight.decay = 1000
        dlight.size = 40 + speedRatio * 40
        dlight.dietime = CurTime() + 0.1
    end
    
    -- Core sprite
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(corePos, 8 + speedRatio * 12, 8 + speedRatio * 12, 
        Color(150 + speedRatio * 105, 200 + speedRatio * 55, 255, 255))
    
    -- Kinetic energy visualization
    if speedRatio > 0.7 then
        local energySize = (speedRatio - 0.7) * 20
        render.DrawSprite(corePos, energySize, energySize, 
            Color(255, 255, 255, 150 * (speedRatio - 0.7)))
    end
end

function ENT:DrawElectromagneticField()
    local velocity = self:GetVelocity()
    local speed = velocity:Length()
    
    if speed < 100 then return end
    
    local time = CurTime()
    local fieldPos = self:GetPos()
    local direction = velocity:GetNormalized()
    
    -- Electromagnetic field distortion
    for i = 1, 4 do
        local offset = VectorRand() * 15
        offset = offset - direction * offset:Dot(direction) -- Perpendicular to movement
        
        local fieldPoint = fieldPos + offset
        local intensity = math.sin(time * 20 + i * 1.5) * 0.5 + 0.5
        
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(fieldPoint, 4 * intensity, 4 * intensity, 
            Color(100, 150, 255, 100 * intensity))
    end
    
    -- Magnetic field lines
    if speed > 500 then
        local perpendicular = direction:Cross(Vector(0, 0, 1)):GetNormalized()
        if perpendicular:Length() < 0.1 then
            perpendicular = direction:Cross(Vector(1, 0, 0)):GetNormalized()
        end
        
        for i = 1, 3 do
            local lineOffset = perpendicular * (i * 8 - 12)
            local lineStart = fieldPos + lineOffset - direction * 20
            local lineEnd = fieldPos + lineOffset + direction * 20
            
            render.SetMaterial(Material("cable/rope"))
            render.DrawBeam(lineStart, lineEnd, 1, 0, 1, Color(100, 150, 255, 80))
        end
    end
end

function ENT:DrawSonicEffects()
    local velocity = self:GetVelocity()
    local speed = velocity:Length()
    
    -- Sonic boom effects at high speed
    if speed > 800 then
        local time = CurTime()
        
        -- Create sonic boom rings
        if time > self.LastSonicTime + 0.2 then
            self.LastSonicTime = time
            self.SonicBoom = 1
        end
        
        -- Fade sonic boom
        self.SonicBoom = self.SonicBoom * 0.9
        
        if self.SonicBoom > 0.1 then
            local boomPos = self:GetPos()
            local direction = velocity:GetNormalized()
            
            -- Sonic boom ring
            local ringSize = (1 - self.SonicBoom) * 100
            
            -- Create perpendicular vectors for ring
            local up = Vector(0, 0, 1)
            local right = direction:Cross(up):GetNormalized()
            if right:Length() < 0.1 then
                right = direction:Cross(Vector(1, 0, 0)):GetNormalized()
            end
            up = direction:Cross(right):GetNormalized()
            
            -- Draw sonic ring
            for i = 1, 16 do
                local angle = (i / 16) * math.pi * 2
                local ringPoint = boomPos + 
                    right * math.cos(angle) * ringSize + 
                    up * math.sin(angle) * ringSize
                
                render.SetMaterial(Material("sprites/light_glow02_add"))
                render.DrawSprite(ringPoint, 6 * self.SonicBoom, 6 * self.SonicBoom, 
                    Color(255, 255, 255, 200 * self.SonicBoom))
            end
            
            -- Shock wave distortion
            render.SetMaterial(Material("cable/rope"))
            for i = 1, 8 do
                local angle = (i / 8) * math.pi * 2
                local wavePoint = boomPos + 
                    right * math.cos(angle) * ringSize * 0.8 + 
                    up * math.sin(angle) * ringSize * 0.8
                
                render.DrawBeam(boomPos, wavePoint, 2, 0, 1, 
                    Color(255, 255, 255, 100 * self.SonicBoom))
            end
        end
    end
end

function ENT:Think()
    local velocity = self:GetVelocity()
    local speed = velocity:Length()
    
    -- Update trail effects based on speed
    if self.TrailEffect then
        -- Trail intensity based on speed
        local trailAlpha = math.min(255, speed / 4)
        -- Trail color would be updated here if supported
    end
    
    -- Create penetration sparks at very high speed
    if speed > 1500 then
        local time = CurTime()
        if time % 0.1 < 0.05 then -- Every 0.1 seconds
            local sparkPos = self:GetPos() + VectorRand() * 5
            
            local emitter = ParticleEmitter(sparkPos)
            if emitter then
                local particle = emitter:Add("effects/spark", sparkPos)
                if particle then
                    particle:SetVelocity(VectorRand() * 100)
                    particle:SetLifeTime(0)
                    particle:SetDieTime(0.2)
                    particle:SetStartAlpha(255)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(2)
                    particle:SetEndSize(0)
                    particle:SetColor(255, 255, 255)
                    particle:SetGravity(Vector(0, 0, 0))
                end
                emitter:Finish()
            end
        end
    end
    
    self:SetNextClientThink(CurTime() + 0.05)
    return true
end

function ENT:OnRemove()
    -- Remove trail effects
    if self.TrailEffect then
        SafeRemoveEntity(self.TrailEffect)
        self.TrailEffect = nil
    end
    
    if self.ElectricTrail then
        SafeRemoveEntity(self.ElectricTrail)
        self.ElectricTrail = nil
    end
    
    -- Cleanup dynamic light
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.dietime = CurTime()
    end
    
    -- Create impact effect
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(self.Damage)
    effectdata:SetScale(1)
    util.Effect("asc_railgun_impact", effectdata)
end
