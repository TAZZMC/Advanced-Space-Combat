-- Advanced Space Combat - Shuttle Client
-- Client-side rendering and effects for shuttle system

include("shared.lua")

-- Client-side variables
ENT.RenderBounds = Vector(100, 100, 50)
ENT.EngineGlow = 0
ENT.EngineTargetGlow = 0
ENT.NavigationLights = {}
ENT.HologramAlpha = 0
ENT.LastUpdate = 0
ENT.TrailEffect = nil

-- Initialize client-side systems
function ENT:Initialize()
    self:SetRenderBounds(Vector(-100, -100, -25), Vector(100, 100, 75))
    
    -- Initialize navigation lights
    self.NavigationLights = {
        {pos = Vector(40, 0, 10), color = Color(0, 255, 0), active = true},   -- Starboard (green)
        {pos = Vector(-40, 0, 10), color = Color(255, 0, 0), active = true},  -- Port (red)
        {pos = Vector(0, 50, 10), color = Color(255, 255, 255), active = true}, -- Forward (white)
        {pos = Vector(0, -50, 10), color = Color(255, 255, 0), active = true}   -- Aft (yellow)
    }
    
    self.LastUpdate = CurTime()
end

-- Main drawing function
function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000000 then return end -- 1000 unit distance
    
    self:DrawEngineEffects()
    self:DrawNavigationLights()
    self:DrawHologram()
    self:DrawTrailEffect()
end

-- Draw engine glow effects
function ENT:DrawEngineEffects()
    local velocity = self:GetVelocity()
    local speed = velocity:Length()
    local active = self:GetNWBool("Active", false)
    
    -- Update engine glow based on movement
    if active and speed > 10 then
        self.EngineTargetGlow = math.min(1, speed / 500)
    else
        self.EngineTargetGlow = 0
    end
    
    -- Smooth glow transition
    self.EngineGlow = Lerp(FrameTime() * 5, self.EngineGlow, self.EngineTargetGlow)
    
    if self.EngineGlow > 0.1 then
        -- Engine positions (rear of shuttle)
        local enginePositions = {
            Vector(-20, -45, 0),
            Vector(20, -45, 0),
            Vector(0, -45, 15)
        }
        
        for i, enginePos in ipairs(enginePositions) do
            local worldPos = self:LocalToWorld(enginePos)
            
            -- Engine glow light
            local dlight = DynamicLight(self:EntIndex() * 10 + i)
            if dlight then
                dlight.pos = worldPos
                dlight.r = 100
                dlight.g = 150
                dlight.b = 255
                dlight.brightness = self.EngineGlow * 2
                dlight.decay = 1000
                dlight.size = 80
                dlight.dietime = CurTime() + 0.1
            end
            
            -- Engine sprite
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(worldPos, 30 * self.EngineGlow, 30 * self.EngineGlow, 
                Color(100, 150, 255, 255 * self.EngineGlow))
            
            -- Engine particles
            if self.EngineGlow > 0.5 then
                local emitter = ParticleEmitter(worldPos)
                if emitter then
                    for j = 1, 2 do
                        local particle = emitter:Add("effects/energyball", worldPos)
                        if particle then
                            particle:SetVelocity(-self:GetForward() * 200 + VectorRand() * 50)
                            particle:SetLifeTime(0)
                            particle:SetDieTime(0.5)
                            particle:SetStartAlpha(255 * self.EngineGlow)
                            particle:SetEndAlpha(0)
                            particle:SetStartSize(5)
                            particle:SetEndSize(1)
                            particle:SetColor(100, 150, 255)
                            particle:SetGravity(Vector(0, 0, 0))
                        end
                    end
                    emitter:Finish()
                end
            end
        end
    end
end

-- Draw navigation lights
function ENT:DrawNavigationLights()
    local active = self:GetNWBool("Active", false)
    local time = CurTime()
    
    for i, light in ipairs(self.NavigationLights) do
        if active and light.active then
            local worldPos = self:LocalToWorld(light.pos)
            local brightness = 0.7 + math.sin(time * 3 + i) * 0.3
            
            -- Navigation light
            local dlight = DynamicLight(self:EntIndex() * 20 + i)
            if dlight then
                dlight.pos = worldPos
                dlight.r = light.color.r
                dlight.g = light.color.g
                dlight.b = light.color.b
                dlight.brightness = brightness * 0.5
                dlight.decay = 1000
                dlight.size = 40
                dlight.dietime = CurTime() + 0.1
            end
            
            -- Light sprite
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(worldPos, 12 * brightness, 12 * brightness, 
                Color(light.color.r, light.color.g, light.color.b, 255 * brightness))
        end
    end
end

-- Draw holographic status display
function ENT:DrawHologram()
    local active = self:GetNWBool("Active", false)
    local mission = self:GetNWString("Mission", "Standby")
    
    -- Update hologram alpha
    if active then
        self.HologramAlpha = Lerp(FrameTime() * 3, self.HologramAlpha, 150)
    else
        self.HologramAlpha = Lerp(FrameTime() * 3, self.HologramAlpha, 0)
    end
    
    if self.HologramAlpha < 10 then return end
    
    local pos = self:GetPos() + self:GetUp() * 60
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    
    cam.Start3D2D(pos, ang, 0.2)
        -- Background panel
        surface.SetDrawColor(0, 30, 60, self.HologramAlpha * 0.8)
        surface.DrawRect(-120, -60, 240, 120)
        
        -- Border
        surface.SetDrawColor(0, 100, 200, self.HologramAlpha)
        surface.DrawOutlinedRect(-120, -60, 240, 120, 2)
        
        -- Title
        draw.SimpleText("SHUTTLE", "DermaLarge", 0, -40, 
            Color(0, 150, 255, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Shuttle type
        local shuttleType = self:GetNWString("ShuttleType", "Transport")
        draw.SimpleText("Type: " .. shuttleType, "DermaDefault", 0, -15, 
            Color(255, 255, 255, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Mission status
        local missionColor = Color(0, 255, 0, self.HologramAlpha)
        if mission == "Transit" then
            missionColor = Color(255, 255, 0, self.HologramAlpha)
        elseif mission == "Emergency" then
            missionColor = Color(255, 0, 0, self.HologramAlpha)
        elseif mission == "Docking" then
            missionColor = Color(0, 255, 255, self.HologramAlpha)
        end
        
        draw.SimpleText("Status: " .. mission, "DermaDefault", 0, 5, 
            missionColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Passenger count
        local passengers = self:GetNWInt("Passengers", 0)
        local maxPassengers = self:GetNWInt("MaxPassengers", 4)
        draw.SimpleText("Passengers: " .. passengers .. "/" .. maxPassengers, "DermaDefault", 0, 25, 
            Color(200, 200, 200, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Speed display
        local speed = math.Round(self:GetVelocity():Length(), 0)
        draw.SimpleText("Speed: " .. speed .. " u/s", "DermaDefault", 0, 45, 
            Color(150, 255, 150, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
    cam.End3D2D()
end

-- Draw trail effect when moving fast
function ENT:DrawTrailEffect()
    local velocity = self:GetVelocity()
    local speed = velocity:Length()
    
    if speed > 100 and self.EngineGlow > 0.3 then
        -- Create trail effect
        if not self.TrailEffect then
            self.TrailEffect = util.SpriteTrail(self, 0, Color(100, 150, 255, 100), false, 15, 1, 0.5, 1/(15+1)*0.5, "trails/laser")
        end
    else
        -- Remove trail effect
        if self.TrailEffect then
            SafeRemoveEntity(self.TrailEffect)
            self.TrailEffect = nil
        end
    end
end

-- Handle network updates
function ENT:Think()
    local time = CurTime()
    
    -- Update every 0.1 seconds
    if time > self.LastUpdate + 0.1 then
        self.LastUpdate = time
        
        -- Update navigation light patterns based on mission
        local mission = self:GetNWString("Mission", "Standby")
        
        if mission == "Emergency" then
            -- Flash red lights rapidly
            for i, light in ipairs(self.NavigationLights) do
                light.color = Color(255, 0, 0)
            end
        elseif mission == "Transit" then
            -- Normal navigation colors
            self.NavigationLights[1].color = Color(0, 255, 0)   -- Starboard
            self.NavigationLights[2].color = Color(255, 0, 0)   -- Port
            self.NavigationLights[3].color = Color(255, 255, 255) -- Forward
            self.NavigationLights[4].color = Color(255, 255, 0)   -- Aft
        elseif mission == "Docking" then
            -- Blue lights for docking
            for i, light in ipairs(self.NavigationLights) do
                light.color = Color(0, 100, 255)
            end
        end
    end
    
    self:SetNextClientThink(time + 0.1)
    return true
end

-- Cleanup on removal
function ENT:OnRemove()
    -- Cleanup dynamic lights
    for i = 1, 3 do
        local dlight = DynamicLight(self:EntIndex() * 10 + i)
        if dlight then
            dlight.dietime = CurTime()
        end
    end
    
    for i = 1, 4 do
        local dlight = DynamicLight(self:EntIndex() * 20 + i)
        if dlight then
            dlight.dietime = CurTime()
        end
    end
    
    -- Remove trail effect
    if self.TrailEffect then
        SafeRemoveEntity(self.TrailEffect)
        self.TrailEffect = nil
    end
end
