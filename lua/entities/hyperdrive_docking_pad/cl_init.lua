-- Advanced Space Combat - Docking Pad Client
-- Client-side rendering and effects for docking pad system

include("shared.lua")

-- Client-side variables
ENT.RenderBounds = Vector(200, 200, 100)
ENT.LastStatusUpdate = 0
ENT.StatusUpdateInterval = 0.5
ENT.HologramAlpha = 0
ENT.HologramTargetAlpha = 0
ENT.BeaconPulse = 0
ENT.LandingLights = {}

-- Initialize client-side systems
function ENT:Initialize()
    self:SetRenderBounds(Vector(-200, -200, -50), Vector(200, 200, 100))
    
    -- Initialize landing lights
    for i = 1, 8 do
        self.LandingLights[i] = {
            active = false,
            brightness = 0,
            color = Color(0, 255, 0)
        }
    end
    
    -- Start status updates
    self.LastStatusUpdate = CurTime()
end

-- Main drawing function
function ENT:Draw()
    self:DrawModel()
    
    if LocalPlayer():GetPos():DistToSqr(self:GetPos()) > 1000000 then return end -- 1000 unit distance
    
    self:DrawHologram()
    self:DrawLandingLights()
    self:DrawStatusBeacon()
    self:DrawDockingBeam()
end

-- Draw holographic status display
function ENT:DrawHologram()
    local status = self:GetNWString("DockingStatus", "Ready")
    local padType = self:GetNWString("PadType", "Small")
    
    -- Update hologram alpha based on status
    if status == "Occupied" or status == "Landing" or status == "Launching" then
        self.HologramTargetAlpha = 255
    else
        self.HologramTargetAlpha = 150
    end
    
    -- Smooth alpha transition
    self.HologramAlpha = Lerp(FrameTime() * 3, self.HologramAlpha, self.HologramTargetAlpha)
    
    if self.HologramAlpha < 10 then return end
    
    local pos = self:GetPos() + self:GetUp() * 60
    local ang = self:GetAngles()
    ang:RotateAroundAxis(ang:Up(), 90)
    
    cam.Start3D2D(pos, ang, 0.2)
        -- Background panel
        surface.SetDrawColor(0, 50, 100, self.HologramAlpha * 0.7)
        surface.DrawRect(-150, -80, 300, 160)
        
        -- Border
        surface.SetDrawColor(0, 150, 255, self.HologramAlpha)
        surface.DrawOutlinedRect(-150, -80, 300, 160, 2)
        
        -- Title
        draw.SimpleText("DOCKING PAD", "DermaLarge", 0, -60, Color(0, 200, 255, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Pad type
        draw.SimpleText("Type: " .. padType, "DermaDefault", 0, -30, Color(255, 255, 255, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Status with color coding
        local statusColor = Color(0, 255, 0, self.HologramAlpha) -- Green for ready
        if status == "Occupied" then
            statusColor = Color(255, 100, 0, self.HologramAlpha) -- Orange for occupied
        elseif status == "Landing" or status == "Launching" then
            statusColor = Color(255, 255, 0, self.HologramAlpha) -- Yellow for active
        elseif status == "Offline" then
            statusColor = Color(255, 0, 0, self.HologramAlpha) -- Red for offline
        end
        
        draw.SimpleText("Status: " .. status, "DermaDefault", 0, 0, statusColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Services available
        local services = self:GetNWString("Services", "Basic")
        draw.SimpleText("Services: " .. services, "DermaDefault", 0, 30, Color(200, 200, 200, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        
        -- Landing instructions
        if status == "Ready" then
            draw.SimpleText("Approach from above", "DermaDefault", 0, 60, Color(0, 255, 0, self.HologramAlpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

-- Draw landing lights around the pad
function ENT:DrawLandingLights()
    local status = self:GetNWString("DockingStatus", "Ready")
    local time = CurTime()
    
    -- Update light states based on status
    for i = 1, 8 do
        local light = self.LandingLights[i]
        
        if status == "Ready" then
            light.active = true
            light.brightness = 0.5 + math.sin(time * 2 + i) * 0.3
            light.color = Color(0, 255, 0)
        elseif status == "Landing" then
            light.active = true
            light.brightness = 0.8 + math.sin(time * 8 + i * 0.5) * 0.2
            light.color = Color(255, 255, 0)
        elseif status == "Launching" then
            light.active = true
            light.brightness = 1.0
            light.color = Color(255, 100, 0)
        elseif status == "Occupied" then
            light.active = true
            light.brightness = 0.3
            light.color = Color(0, 0, 255)
        else
            light.active = false
            light.brightness = 0
        end
    end
    
    -- Render the lights
    local center = self:GetPos()
    local radius = 80
    
    for i = 1, 8 do
        local light = self.LandingLights[i]
        if light.active and light.brightness > 0 then
            local angle = (i / 8) * math.pi * 2
            local lightPos = center + Vector(math.cos(angle) * radius, math.sin(angle) * radius, 5)
            
            -- Dynamic light
            local dlight = DynamicLight(self:EntIndex() * 10 + i)
            if dlight then
                dlight.pos = lightPos
                dlight.r = light.color.r
                dlight.g = light.color.g
                dlight.b = light.color.b
                dlight.brightness = light.brightness
                dlight.decay = 1000
                dlight.size = 100
                dlight.dietime = CurTime() + 0.1
            end
            
            -- Light sprite
            render.SetMaterial(Material("sprites/light_glow02_add"))
            render.DrawSprite(lightPos, 20 * light.brightness, 20 * light.brightness, 
                Color(light.color.r, light.color.g, light.color.b, 255 * light.brightness))
        end
    end
end

-- Draw status beacon
function ENT:DrawStatusBeacon()
    local status = self:GetNWString("DockingStatus", "Ready")
    if status == "Offline" then return end
    
    local time = CurTime()
    self.BeaconPulse = math.sin(time * 4) * 0.5 + 0.5
    
    local beaconPos = self:GetPos() + self:GetUp() * 80
    local beaconColor = Color(0, 255, 0)
    
    if status == "Occupied" then
        beaconColor = Color(255, 100, 0)
    elseif status == "Landing" or status == "Launching" then
        beaconColor = Color(255, 255, 0)
        self.BeaconPulse = math.sin(time * 8) * 0.5 + 0.5
    end
    
    -- Beacon light
    local dlight = DynamicLight(self:EntIndex() * 100)
    if dlight then
        dlight.pos = beaconPos
        dlight.r = beaconColor.r
        dlight.g = beaconColor.g
        dlight.b = beaconColor.b
        dlight.brightness = self.BeaconPulse * 2
        dlight.decay = 1000
        dlight.size = 200
        dlight.dietime = CurTime() + 0.1
    end
    
    -- Beacon sprite
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(beaconPos, 40 * self.BeaconPulse, 40 * self.BeaconPulse, 
        Color(beaconColor.r, beaconColor.g, beaconColor.b, 255 * self.BeaconPulse))
end

-- Draw docking guidance beam
function ENT:DrawDockingBeam()
    local status = self:GetNWString("DockingStatus", "Ready")
    if status ~= "Landing" and status ~= "Ready" then return end
    
    local beamHeight = 500
    local beamPos = self:GetPos()
    local beamTop = beamPos + Vector(0, 0, beamHeight)
    
    -- Beam color based on status
    local beamColor = Color(0, 255, 0, 50)
    if status == "Landing" then
        beamColor = Color(255, 255, 0, 100)
    end
    
    -- Draw beam cylinder
    render.SetMaterial(Material("cable/rope"))
    render.DrawBeam(beamPos, beamTop, 20, 0, 1, beamColor)
    
    -- Draw beam particles
    local time = CurTime()
    for i = 1, 5 do
        local height = (time * 100 + i * 100) % beamHeight
        local particlePos = beamPos + Vector(0, 0, height)
        
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(particlePos, 15, 15, Color(beamColor.r, beamColor.g, beamColor.b, 150))
    end
end

-- Handle network updates
function ENT:Think()
    local time = CurTime()
    
    -- Update status periodically
    if time > self.LastStatusUpdate + self.StatusUpdateInterval then
        self.LastStatusUpdate = time
        
        -- Request status update from server if needed
        -- This would be handled by the server automatically through networking
    end
    
    self:SetNextClientThink(time + 0.1)
    return true
end

-- Handle use key
function ENT:OnRemove()
    -- Cleanup any dynamic lights
    for i = 1, 8 do
        local dlight = DynamicLight(self:EntIndex() * 10 + i)
        if dlight then
            dlight.dietime = CurTime()
        end
    end
    
    local beaconLight = DynamicLight(self:EntIndex() * 100)
    if beaconLight then
        beaconLight.dietime = CurTime()
    end
end
