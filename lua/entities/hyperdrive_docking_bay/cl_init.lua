-- Advanced Space Combat - Docking Bay Client
-- Client-side rendering for large docking bay facility

include("shared.lua")

-- Client-side variables
ENT.RenderBounds = Vector(500, 500, 200)
ENT.HologramAlpha = 0
ENT.StatusLights = {}
ENT.ForceFieldEffect = 0
ENT.LastUpdate = 0

function ENT:Initialize()
    self:SetRenderBounds(Vector(-500, -500, -100), Vector(500, 500, 300))
    
    -- Initialize status lights
    for i = 1, 12 do
        self.StatusLights[i] = {
            active = false,
            brightness = 0,
            color = Color(0, 255, 0)
        }
    end
    
    self.LastUpdate = CurTime()
end

function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 2500000 then return end -- 1500 unit distance
    
    self:DrawHologram()
    self:DrawStatusLights()
    self:DrawForceField()
end

function ENT:DrawHologram()
    local status = self:GetNWString("BayStatus", "Ready")
    local active = self:GetNWBool("Active", false)
    
    if active then
        self.HologramAlpha = Lerp(FrameTime() * 3, self.HologramAlpha, 200)
    else
        self.HologramAlpha = Lerp(FrameTime() * 3, self.HologramAlpha, 50)
    end
    
    if self.HologramAlpha < 10 then return end
    
    local pos = self:GetPos() + self:GetUp() * 150
    local ang = self:GetAngles()
    
    cam.Start3D2D(pos, ang, 0.5)
        surface.SetDrawColor(0, 30, 60, self.HologramAlpha * 0.8)
        surface.DrawRect(-300, -100, 600, 200)
        
        surface.SetDrawColor(0, 100, 200, self.HologramAlpha)
        surface.DrawOutlinedRect(-300, -100, 600, 200, 4)
        
        draw.SimpleText("DOCKING BAY", "DermaLarge", 0, -60, 
            Color(0, 200, 255, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        local statusColor = Color(0, 255, 0, self.HologramAlpha)
        if status == "Occupied" then
            statusColor = Color(255, 100, 0, self.HologramAlpha)
        elseif status == "Offline" then
            statusColor = Color(255, 0, 0, self.HologramAlpha)
        end
        
        draw.SimpleText("Status: " .. status, "DermaDefault", 0, -20, 
            statusColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        local capacity = self:GetNWInt("Capacity", 4)
        local occupied = self:GetNWInt("Occupied", 0)
        draw.SimpleText("Capacity: " .. occupied .. "/" .. capacity, "DermaDefault", 0, 20, 
            Color(255, 255, 255, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        draw.SimpleText("Large Ship Facility", "DermaDefault", 0, 60, 
            Color(200, 200, 200, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:DrawStatusLights()
    local status = self:GetNWString("BayStatus", "Ready")
    local time = CurTime()
    
    -- Update light states
    for i = 1, 12 do
        local light = self.StatusLights[i]
        
        if status == "Ready" then
            light.active = true
            light.brightness = 0.6 + math.sin(time * 2 + i * 0.5) * 0.2
            light.color = Color(0, 255, 0)
        elseif status == "Occupied" then
            light.active = true
            light.brightness = 0.4
            light.color = Color(255, 100, 0)
        else
            light.active = false
            light.brightness = 0
        end
    end
    
    -- Render lights around the bay
    local center = self:GetPos()
    local radius = 400
    
    for i = 1, 12 do
        local light = self.StatusLights[i]
        if light.active and light.brightness > 0 then
            local angle = (i / 12) * math.pi * 2
            local lightPos = center + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 50)
            
            local dlight = DynamicLight(self:EntIndex() * 20 + i)
            if dlight then
                dlight.pos = lightPos
                dlight.r = light.color.r
                dlight.g = light.color.g
                dlight.b = light.color.b
                dlight.brightness = light.brightness
                dlight.decay = 1000
                dlight.size = 150
                dlight.dietime = CurTime() + 0.1
            end
            
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(lightPos, 40 * light.brightness, 40 * light.brightness, 
                Color(light.color.r, light.color.g, light.color.b, 255 * light.brightness))
        end
    end
end

function ENT:DrawForceField()
    local hasForceField = self:GetNWBool("ForceField", false)
    
    if hasForceField then
        self.ForceFieldEffect = Lerp(FrameTime() * 2, self.ForceFieldEffect, 1)
    else
        self.ForceFieldEffect = Lerp(FrameTime() * 3, self.ForceFieldEffect, 0)
    end
    
    if self.ForceFieldEffect > 0.1 then
        local time = CurTime()
        local fieldPos = self:GetPos() + self:GetUp() * 100
        
        -- Force field barrier effect
        render.SetMaterial(Material("cable/rope"))
        
        -- Create grid pattern
        for x = -4, 4 do
            for y = -4, 4 do
                local startPos = fieldPos + self:GetRight() * (x * 100) + self:GetForward() * (y * 100)
                local endPos = startPos + self:GetUp() * 200
                
                local alpha = self.ForceFieldEffect * 50 * (1 + math.sin(time * 4 + x + y) * 0.3)
                render.DrawBeam(startPos, endPos, 2, 0, 1, Color(0, 150, 255, alpha))
            end
        end
        
        -- Force field glow
        local dlight = DynamicLight(self:EntIndex() * 100)
        if dlight then
            dlight.pos = fieldPos
            dlight.r = 0
            dlight.g = 150
            dlight.b = 255
            dlight.brightness = self.ForceFieldEffect * 2
            dlight.decay = 1000
            dlight.size = 800
            dlight.dietime = CurTime() + 0.1
        end
    end
end

function ENT:Think()
    local time = CurTime()
    
    if time > self.LastUpdate + 0.2 then
        self.LastUpdate = time
        -- Update logic here
    end
    
    self:SetNextClientThink(time + 0.1)
    return true
end

function ENT:OnRemove()
    -- Cleanup lights
    for i = 1, 12 do
        local dlight = DynamicLight(self:EntIndex() * 20 + i)
        if dlight then
            dlight.dietime = CurTime()
        end
    end
    
    local fieldLight = DynamicLight(self:EntIndex() * 100)
    if fieldLight then
        fieldLight.dietime = CurTime()
    end
end
