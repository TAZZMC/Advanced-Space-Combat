-- Advanced Space Combat - Torpedo Launcher Client
-- Client-side rendering for torpedo launcher weapon

include("shared.lua")

-- Client-side variables
ENT.LoadingEffect = 0
ENT.TubeGlow = {}
ENT.TargetingSystem = 0
ENT.LoadingSound = nil

function ENT:Initialize()
    self:SetRenderBounds(Vector(-40, -40, -40), Vector(40, 40, 40))
    
    -- Initialize torpedo tubes
    for i = 1, 4 do
        self.TubeGlow[i] = {
            loaded = false,
            glow = 0,
            targetGlow = 0
        }
    end
end

function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 250000 then return end -- 500 unit distance
    
    self:DrawTorpedoTubes()
    self:DrawLoadingSystem()
    self:DrawTargetingDisplay()
    self:DrawStatusLights()
end

function ENT:DrawTorpedoTubes()
    local tubePositions = {
        Vector(15, 30, 0),   -- Tube 1
        Vector(-15, 30, 0),  -- Tube 2
        Vector(15, 30, 15),  -- Tube 3
        Vector(-15, 30, 15)  -- Tube 4
    }
    
    for i = 1, 4 do
        local tube = self.TubeGlow[i]
        local loaded = self:GetNWBool("Tube" .. i .. "Loaded", false)
        local loading = self:GetNWBool("Tube" .. i .. "Loading", false)
        
        -- Update tube state
        tube.loaded = loaded
        
        if loaded then
            tube.targetGlow = 1
        elseif loading then
            tube.targetGlow = 0.5 + math.sin(CurTime() * 8) * 0.3
        else
            tube.targetGlow = 0
        end
        
        -- Smooth glow transition
        tube.glow = Lerp(FrameTime() * 4, tube.glow, tube.targetGlow)
        
        if tube.glow > 0.1 then
            local tubePos = self:LocalToWorld(tubePositions[i])
            
            -- Tube glow
            local glowColor = Color(0, 255, 0) -- Green for loaded
            if loading then
                glowColor = Color(255, 255, 0) -- Yellow for loading
            end
            
            local dlight = DynamicLight(self:EntIndex() * 10 + i)
            if dlight then
                dlight.pos = tubePos
                dlight.r = glowColor.r
                dlight.g = glowColor.g
                dlight.b = glowColor.b
                dlight.brightness = tube.glow
                dlight.decay = 1000
                dlight.size = 40
                dlight.dietime = CurTime() + 0.1
            end
            
            -- Tube sprite
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(tubePos, 15 * tube.glow, 15 * tube.glow, 
                Color(glowColor.r, glowColor.g, glowColor.b, 255 * tube.glow))
            
            -- Torpedo outline in tube
            if loaded then
                local torpedoPos = tubePos - self:GetForward() * 10
                render.DrawSprite(torpedoPos, 8, 8, Color(255, 150, 0, 150))
            end
        end
    end
end

function ENT:DrawLoadingSystem()
    local loading = self:GetNWBool("Loading", false)
    local loadProgress = self:GetNWFloat("LoadProgress", 0)
    
    if loading then
        self.LoadingEffect = Lerp(FrameTime() * 5, self.LoadingEffect, loadProgress)
    else
        self.LoadingEffect = Lerp(FrameTime() * 8, self.LoadingEffect, 0)
    end
    
    if self.LoadingEffect > 0.1 then
        local loadPos = self:GetPos() - self:GetForward() * 30
        
        -- Loading mechanism glow
        local dlight = DynamicLight(self:EntIndex() * 100)
        if dlight then
            dlight.pos = loadPos
            dlight.r = 255
            dlight.g = 200
            dlight.b = 0
            dlight.brightness = self.LoadingEffect
            dlight.decay = 1000
            dlight.size = 60
            dlight.dietime = CurTime() + 0.1
        end
        
        -- Loading progress visualization
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(loadPos, 20 * self.LoadingEffect, 20 * self.LoadingEffect, 
            Color(255, 200, 0, 200 * self.LoadingEffect))
        
        -- Loading particles
        if self.LoadingEffect > 0.5 then
            local time = CurTime()
            if time % 0.2 < 0.1 then
                local emitter = ParticleEmitter(loadPos)
                if emitter then
                    local particle = emitter:Add("effects/energyball", loadPos + VectorRand() * 15)
                    if particle then
                        particle:SetVelocity(self:GetForward() * 50 + VectorRand() * 20)
                        particle:SetLifeTime(0)
                        particle:SetDieTime(0.5)
                        particle:SetStartAlpha(255 * self.LoadingEffect)
                        particle:SetEndAlpha(0)
                        particle:SetStartSize(3)
                        particle:SetEndSize(1)
                        particle:SetColor(255, 200, 0)
                        particle:SetGravity(Vector(0, 0, 0))
                    end
                    emitter:Finish()
                end
            end
        end
    end
end

function ENT:DrawTargetingDisplay()
    local target = self:GetNWEntity("Target", NULL)
    local active = self:GetNWBool("Active", false)
    
    if active and IsValid(target) then
        self.TargetingSystem = Lerp(FrameTime() * 3, self.TargetingSystem, 1)
        
        if self.TargetingSystem > 0.1 then
            local startPos = self:GetPos() + self:GetForward() * 35
            local targetPos = target:GetPos()
            
            -- Targeting beam
            render.SetMaterial(Material("cable/rope"))
            render.DrawBeam(startPos, targetPos, 2, 0, 1, 
                Color(255, 0, 0, 120 * self.TargetingSystem))
            
            -- Target lock indicator
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(targetPos, 25 * self.TargetingSystem, 25 * self.TargetingSystem, 
                Color(255, 0, 0, 180 * self.TargetingSystem))
            
            -- Targeting computer display
            local displayPos = self:GetPos() + self:GetUp() * 25
            local ang = self:GetAngles()
            
            cam.Start3D2D(displayPos, ang, 0.2)
                surface.SetDrawColor(0, 50, 0, 150 * self.TargetingSystem)
                surface.DrawRect(-60, -30, 120, 60)
                
                surface.SetDrawColor(0, 255, 0, 200 * self.TargetingSystem)
                surface.DrawOutlinedRect(-60, -30, 120, 60, 2)
                
                draw.SimpleText("TARGET LOCK", "DermaDefault", 0, -15, 
                    Color(255, 0, 0, 255 * self.TargetingSystem), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                
                local distance = math.Round(self:GetPos():Distance(targetPos), 0)
                draw.SimpleText("Range: " .. distance, "DermaDefault", 0, 5, 
                    Color(0, 255, 0, 255 * self.TargetingSystem), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            cam.End3D2D()
        end
    else
        self.TargetingSystem = Lerp(FrameTime() * 5, self.TargetingSystem, 0)
    end
end

function ENT:DrawStatusLights()
    local active = self:GetNWBool("Active", false)
    local ready = self:GetNWBool("Ready", false)
    local time = CurTime()
    
    -- Status light positions
    local lightPositions = {
        Vector(20, 0, 20),   -- Power
        Vector(-20, 0, 20),  -- Ready
        Vector(0, 20, 20),   -- Targeting
        Vector(0, -20, 20)   -- Loading
    }
    
    local lightStates = {
        active,                                    -- Power
        ready,                                     -- Ready
        self.TargetingSystem > 0.5,               -- Targeting
        self.LoadingEffect > 0.5                  -- Loading
    }
    
    local lightColors = {
        Color(0, 255, 0),    -- Power (green)
        Color(0, 0, 255),    -- Ready (blue)
        Color(255, 0, 0),    -- Targeting (red)
        Color(255, 255, 0)   -- Loading (yellow)
    }
    
    for i = 1, 4 do
        if lightStates[i] then
            local lightPos = self:LocalToWorld(lightPositions[i])
            local brightness = 0.7 + math.sin(time * 4 + i) * 0.2
            local color = lightColors[i]
            
            -- Status light
            local dlight = DynamicLight(self:EntIndex() * 20 + i)
            if dlight then
                dlight.pos = lightPos
                dlight.r = color.r
                dlight.g = color.g
                dlight.b = color.b
                dlight.brightness = brightness * 0.5
                dlight.decay = 1000
                dlight.size = 25
                dlight.dietime = CurTime() + 0.1
            end
            
            -- Light sprite
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(lightPos, 8 * brightness, 8 * brightness, 
                Color(color.r, color.g, color.b, 255 * brightness))
        end
    end
end

function ENT:Think()
    local loading = self:GetNWBool("Loading", false)
    
    -- Handle loading sound
    if loading then
        if not self.LoadingSound then
            self.LoadingSound = CreateSound(self, "asc/weapons/torpedo_loading.wav")
            if self.LoadingSound then
                self.LoadingSound:Play()
            end
        end
    else
        if self.LoadingSound then
            self.LoadingSound:Stop()
            self.LoadingSound = nil
        end
    end
    
    self:SetNextClientThink(CurTime() + 0.1)
    return true
end

function ENT:OnRemove()
    -- Stop loading sound
    if self.LoadingSound then
        self.LoadingSound:Stop()
        self.LoadingSound = nil
    end
    
    -- Cleanup dynamic lights
    for i = 1, 4 do
        local tubeLight = DynamicLight(self:EntIndex() * 10 + i)
        if tubeLight then
            tubeLight.dietime = CurTime()
        end
        
        local statusLight = DynamicLight(self:EntIndex() * 20 + i)
        if statusLight then
            statusLight.dietime = CurTime()
        end
    end
    
    local loadingLight = DynamicLight(self:EntIndex() * 100)
    if loadingLight then
        loadingLight.dietime = CurTime()
    end
end
