-- Advanced Space Combat - Stargate Hyperspace Starlines Effect
-- Creates the stretched starlines effect during hyperspace travel

EFFECT.Mat = Material("effects/laser1")
EFFECT.MatStar = Material("effects/yellowflare")
EFFECT.MatBeam = Material("effects/blueflare1")

function EFFECT:Init(data)
    self.Position = data:GetOrigin()
    self.Destination = data:GetStart() or (self.Position + Vector(1000, 0, 0))
    self.Scale = data:GetScale() or 300
    self.TravelTime = data:GetMagnitude() or 5
    self.Radius = data:GetRadius() or 100
    
    self.StartTime = CurTime()
    self.LifeTime = self.TravelTime
    
    -- Calculate travel direction
    self.Direction = (self.Destination - self.Position):GetNormalized()
    self.Distance = self.Position:Distance(self.Destination)
    
    -- Create starlines
    self.Starlines = {}
    self:CreateStarlines()
    
    -- Sound effect
    self:EmitSound("asc/hyperspace/starlines_whoosh.wav", 70, 100)
end

function EFFECT:CreateStarlines()
    -- Create multiple starlines around the ship
    for i = 1, 50 do
        local angle1 = math.random() * math.pi * 2
        local angle2 = math.random() * math.pi * 2
        local radius = math.random(50, self.Radius * 2)
        
        local offset = Vector(
            math.cos(angle1) * math.cos(angle2) * radius,
            math.sin(angle1) * math.cos(angle2) * radius,
            math.sin(angle2) * radius
        )
        
        local starline = {
            startPos = self.Position + offset,
            endPos = self.Position + offset + (self.Direction * self.Scale),
            width = math.random(1, 3),
            speed = math.random(0.8, 1.2),
            color = HSVToColor(math.random(200, 240), 0.7, 1.0),
            alpha = math.random(100, 255),
            length = math.random(100, 300)
        }
        
        table.insert(self.Starlines, starline)
    end
end

function EFFECT:Think()
    local age = CurTime() - self.StartTime
    local progress = age / self.LifeTime
    
    if progress >= 1 then
        return false
    end
    
    -- Update starlines - make them stretch and move
    for _, starline in ipairs(self.Starlines) do
        local moveDistance = progress * self.Distance * starline.speed
        local stretchFactor = 1 + (progress * 5) -- Stretch effect
        
        -- Move starline along travel direction
        starline.currentStart = starline.startPos + (self.Direction * moveDistance)
        starline.currentEnd = starline.currentStart + (self.Direction * starline.length * stretchFactor)
        
        -- Fade out towards end of travel
        starline.currentAlpha = starline.alpha * (1 - progress * 0.5)
    end
    
    return true
end

function EFFECT:Render()
    local age = CurTime() - self.StartTime
    local progress = age / self.LifeTime
    
    if progress >= 1 then return end
    
    -- Render stretched starlines
    render.SetMaterial(self.Mat)
    
    for _, starline in ipairs(self.Starlines) do
        if starline.currentStart and starline.currentEnd then
            local color = Color(
                starline.color.r,
                starline.color.g, 
                starline.color.b,
                starline.currentAlpha or starline.alpha
            )
            
            render.DrawBeam(
                starline.currentStart,
                starline.currentEnd,
                starline.width,
                0, 1,
                color
            )
        end
    end
    
    -- Add some energy streams for extra effect
    render.SetMaterial(self.MatBeam)
    
    for i = 1, 5 do
        local streamAngle = (age * 3 + i * 72) % 360
        local streamRad = math.rad(streamAngle)
        local streamRadius = self.Radius * 0.5
        
        local streamStart = self.Position + Vector(
            math.cos(streamRad) * streamRadius,
            math.sin(streamRad) * streamRadius,
            0
        )
        
        local streamEnd = streamStart + (self.Direction * self.Scale * 0.5)
        
        render.DrawBeam(
            streamStart,
            streamEnd,
            8,
            0, 1,
            Color(100, 150, 255, 150 * (1 - progress * 0.5))
        )
    end
    
    -- Central energy core
    render.SetMaterial(self.MatStar)
    local coreSize = 30 + math.sin(age * 10) * 10
    render.DrawSprite(
        self.Position,
        coreSize, coreSize,
        Color(200, 220, 255, 200 * (1 - progress * 0.3))
    )
end
