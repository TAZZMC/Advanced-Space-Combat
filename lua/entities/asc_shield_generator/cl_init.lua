-- Advanced Space Combat - Shield Generator Client v3.1.0
-- CAP-integrated bubble shield system - Client side

include("shared.lua")

function ENT:Initialize()
    -- Client-side initialization
    self.LastShieldUpdate = 0
    self.ShieldUpdateRate = 0.1
    self.ShieldEffect = nil
    self.ShieldActive = false
    self.ShieldStrength = 0
    self.MaxShieldStrength = 1000
    
    -- Visual effects
    self.GlowEffect = nil
    self.LastGlowUpdate = 0
    
    -- Sound effects
    self.ShieldSound = nil
    self.LastSoundUpdate = 0
end

function ENT:Think()
    local currentTime = CurTime()
    
    -- Update shield visuals
    if currentTime - self.LastShieldUpdate > self.ShieldUpdateRate then
        self:UpdateShieldVisuals()
        self.LastShieldUpdate = currentTime
    end
    
    -- Update glow effect
    if currentTime - self.LastGlowUpdate > 0.5 then
        self:UpdateGlowEffect()
        self.LastGlowUpdate = currentTime
    end
    
    self:NextThink(currentTime + 0.05)
    return true
end

function ENT:UpdateShieldVisuals()
    -- Get shield data from network vars
    local active = self:GetNWBool("ShieldActive", false)
    local strength = self:GetNWFloat("ShieldStrength", 0)
    local maxStrength = self:GetNWFloat("MaxShieldStrength", 1000)
    
    if active ~= self.ShieldActive then
        self.ShieldActive = active
        if active then
            self:CreateShieldEffect()
        else
            self:RemoveShieldEffect()
        end
    end
    
    if active and self.ShieldEffect then
        -- Update shield opacity based on strength
        local alpha = math.Clamp(strength / maxStrength, 0.1, 1.0)
        -- Shield effect updates would go here
    end
end

function ENT:CreateShieldEffect()
    -- Create shield bubble effect
    local effectData = EffectData()
    effectData:SetOrigin(self:GetPos())
    effectData:SetEntity(self)
    effectData:SetScale(1)
    effectData:SetMagnitude(1)
    util.Effect("asc_shield_activate", effectData)
    
    -- Play activation sound
    self:EmitSound("hyperdrive_shield_generator/shield_engage.mp3", 75, 100, 0.8)
end

function ENT:RemoveShieldEffect()
    -- Remove shield effect
    local effectData = EffectData()
    effectData:SetOrigin(self:GetPos())
    effectData:SetEntity(self)
    effectData:SetScale(1)
    effectData:SetMagnitude(0)
    util.Effect("asc_shield_deactivate", effectData)
    
    -- Play deactivation sound
    self:EmitSound("hyperdrive_shield_generator/shield_disengage.mp3", 75, 100, 0.8)
end

function ENT:UpdateGlowEffect()
    local active = self:GetNWBool("ShieldActive", false)
    
    if active then
        -- Create glow effect
        local dlight = DynamicLight(self:EntIndex())
        if dlight then
            dlight.pos = self:GetPos()
            dlight.r = 100
            dlight.g = 150
            dlight.b = 255
            dlight.brightness = 2
            dlight.decay = 1000
            dlight.size = 256
            dlight.dietime = CurTime() + 1
        end
    end
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw shield status
    if self:GetNWBool("ShieldActive", false) then
        local pos = self:GetPos() + Vector(0, 0, 50)
        local ang = LocalPlayer():EyeAngles()
        ang:RotateAroundAxis(ang.Forward, 90)
        ang:RotateAroundAxis(ang.Right, 90)
        
        cam.Start3D2D(pos, ang, 0.1)
            draw.SimpleText("SHIELD ACTIVE", "DermaDefault", 0, 0, Color(100, 255, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            local strength = self:GetNWFloat("ShieldStrength", 0)
            local maxStrength = self:GetNWFloat("MaxShieldStrength", 1000)
            local percentage = math.floor((strength / maxStrength) * 100)
            
            draw.SimpleText(percentage .. "%", "DermaDefault", 0, 20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        cam.End3D2D()
    end
end

function ENT:OnRemove()
    -- Clean up effects
    if self.ShieldEffect then
        self:RemoveShieldEffect()
    end
    
    if self.ShieldSound then
        self.ShieldSound:Stop()
    end
end

-- Network message handlers
net.Receive("asc_shield_update", function()
    local ent = net.ReadEntity()
    local active = net.ReadBool()
    local strength = net.ReadFloat()
    
    if IsValid(ent) and ent.UpdateShieldVisuals then
        ent:UpdateShieldVisuals()
    end
end)
