-- Advanced Space Combat - Torpedo Client
-- Client-side rendering for guided torpedo weapon

include("shared.lua")

-- Client-side variables
ENT.EngineGlow = 0
ENT.NavigationLights = {}
ENT.TrailEffect = nil
ENT.TargetingBeam = 0
ENT.EngineSound = nil

function ENT:Initialize()
    self:SetRenderBounds(Vector(-20, -20, -20), Vector(20, 20, 20))
    
    -- Create engine trail
    self.TrailEffect = util.SpriteTrail(self, 0, Color(255, 150, 0, 180), false, 8, 1, 0.5, 1/9*0.5, "trails/laser")
    
    -- Initialize navigation lights
    self.NavigationLights = {
        {pos = Vector(15, 0, 0), color = Color(0, 255, 0), active = true},   -- Starboard
        {pos = Vector(-15, 0, 0), color = Color(255, 0, 0), active = true},  -- Port
        {pos = Vector(0, 20, 0), color = Color(255, 255, 255), active = true} -- Forward
    }
    
    -- Start engine sound
    self.EngineSound = CreateSound(self, "asc/weapons/torpedo_engine.wav")
    if self.EngineSound then
        self.EngineSound:Play()
    end
end

function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000000 then return end -- 1000 unit distance
    
    self:DrawEngineEffects()
    self:DrawNavigationLights()
    self:DrawTargetingSystem()
    self:DrawWarhead()
end

function ENT:DrawEngineEffects()
    local velocity = self:GetVelocity()
    local speed = velocity:Length()
    local active = self:GetNWBool("Active", false)
    
    -- Update engine glow based on thrust
    if active then
        self.EngineGlow = Lerp(FrameTime() * 6, self.EngineGlow, math.min(1, speed / 400))
    else
        self.EngineGlow = Lerp(FrameTime() * 8, self.EngineGlow, 0)
    end
    
    if self.EngineGlow > 0.1 then
        -- Engine position (rear of torpedo)
        local enginePos = self:GetPos() - self:GetForward() * 25
        
        -- Engine glow light
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = enginePos
            dlight.r = 255
            dlight.g = 150
            dlight.b = 0
            dlight.brightness = self.EngineGlow * 2
            dlight.decay = 1000
            dlight.size = 80
            dlight.dietime = CurTime() + 0.1
        end
        
        -- Engine sprite
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(enginePos, 25 * self.EngineGlow, 25 * self.EngineGlow, 
            Color(255, 150, 0, 255 * self.EngineGlow))
        
        -- Engine particles
        if self.EngineGlow > 0.3 then
            local time = CurTime()
            if time % 0.1 < 0.05 then
                local emitter = ParticleEmitter(enginePos)
                if emitter then
                    for i = 1, 3 do
                        local particle = emitter:Add("effects/energyball", enginePos + VectorRand() * 8)
                        if particle then
                            particle:SetVelocity(-self:GetForward() * 200 + VectorRand() * 40)
                            particle:SetLifeTime(0)
                            particle:SetDieTime(0.4)
                            particle:SetStartAlpha(255 * self.EngineGlow)
                            particle:SetEndAlpha(0)
                            particle:SetStartSize(4)
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

function ENT:DrawNavigationLights()
    local active = self:GetNWBool("Active", false)
    local time = CurTime()
    
    for i, light in ipairs(self.NavigationLights) do
        if active and light.active then
            local worldPos = self:LocalToWorld(light.pos)
            local brightness = 0.6 + math.sin(time * 4 + i) * 0.3
            
            -- Navigation light
            local dlight = DynamicLight(self:EntIndex() * 10 + i)
            if dlight then
                dlight.pos = worldPos
                dlight.r = light.color.r
                dlight.g = light.color.g
                dlight.b = light.color.b
                dlight.brightness = brightness * 0.4
                dlight.decay = 1000
                dlight.size = 30
                dlight.dietime = CurTime() + 0.1
            end
            
            -- Light sprite
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(worldPos, 8 * brightness, 8 * brightness, 
                Color(light.color.r, light.color.g, light.color.b, 255 * brightness))
        end
    end
end

function ENT:DrawTargetingSystem()
    local target = self:GetNWEntity("Target", NULL)
    local isTracking = self:GetNWBool("IsTracking", false)
    
    if IsValid(target) and isTracking then
        self.TargetingBeam = Lerp(FrameTime() * 4, self.TargetingBeam, 1)
        
        if self.TargetingBeam > 0.1 then
            local startPos = self:GetPos() + self:GetForward() * 15
            local targetPos = target:GetPos()
            
            -- Targeting beam
            render.SetMaterial(Material("cable/rope"))
            render.DrawBeam(startPos, targetPos, 1, 0, 1, 
                Color(255, 255, 0, 150 * self.TargetingBeam))
            
            -- Target marker
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(targetPos, 20 * self.TargetingBeam, 20 * self.TargetingBeam, 
                Color(255, 255, 0, 200 * self.TargetingBeam))
            
            -- Targeting reticle
            cam.Start3D2D(targetPos, (startPos - targetPos):GetNormalized():Angle(), 0.3)
                surface.SetDrawColor(255, 255, 0, 200 * self.TargetingBeam)
                
                -- Target box
                surface.DrawOutlinedRect(-20, -20, 40, 40, 2)
                
                -- Corner markers
                surface.DrawRect(-25, -25, 10, 2)
                surface.DrawRect(-25, -25, 2, 10)
                surface.DrawRect(15, -25, 10, 2)
                surface.DrawRect(23, -25, 2, 10)
                surface.DrawRect(-25, 15, 10, 2)
                surface.DrawRect(-25, 23, 2, 10)
                surface.DrawRect(15, 15, 10, 2)
                surface.DrawRect(23, 23, 2, 10)
            cam.End3D2D()
        end
    else
        self.TargetingBeam = Lerp(FrameTime() * 6, self.TargetingBeam, 0)
    end
end

function ENT:DrawWarhead()
    local armTime = self:GetNWFloat("ArmTime", 0)
    local armed = self:GetNWBool("Armed", false)
    
    if armed then
        local time = CurTime()
        local warheadPos = self:GetPos() + self:GetForward() * 15
        
        -- Armed warhead indicator
        local pulseIntensity = math.sin(time * 8) * 0.5 + 0.5
        
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(warheadPos, 12 * pulseIntensity, 12 * pulseIntensity, 
            Color(255, 0, 0, 200 * pulseIntensity))
        
        -- Warning light
        local dlight = DynamicLight(self:EntIndex() * 100)
        if dlight then
            dlight.pos = warheadPos
            dlight.r = 255
            dlight.g = 0
            dlight.b = 0
            dlight.brightness = pulseIntensity
            dlight.decay = 1000
            dlight.size = 50
            dlight.dietime = CurTime() + 0.1
        end
    end
end

function ENT:Think()
    local velocity = self:GetVelocity()
    local speed = velocity:Length()
    
    -- Update engine sound
    if self.EngineSound then
        local pitch = 80 + (speed / 400) * 40
        local volume = 0.4 + self.EngineGlow * 0.4
        self.EngineSound:ChangePitch(pitch, 0.1)
        self.EngineSound:ChangeVolume(volume, 0.1)
    end
    
    self:SetNextClientThink(CurTime() + 0.1)
    return true
end

function ENT:OnRemove()
    -- Stop engine sound
    if self.EngineSound then
        self.EngineSound:Stop()
        self.EngineSound = nil
    end
    
    -- Remove trail effect
    if self.TrailEffect then
        SafeRemoveEntity(self.TrailEffect)
        self.TrailEffect = nil
    end
    
    -- Cleanup dynamic lights
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.dietime = CurTime()
    end
    
    for i = 1, 3 do
        local navLight = DynamicLight(self:EntIndex() * 10 + i)
        if navLight then
            navLight.dietime = CurTime()
        end
    end
    
    local warheadLight = DynamicLight(self:EntIndex() * 100)
    if warheadLight then
        warheadLight.dietime = CurTime()
    end
    
    -- Create explosion effect
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(self.BlastRadius or 200)
    effectdata:SetScale(1)
    util.Effect("asc_torpedo_explosion", effectdata)
end
