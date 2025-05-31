-- Advanced Space Combat - Ancient Drone Weapon (Client)
-- Self-guided energy projectiles with adaptive targeting and swarm intelligence

include("shared.lua")

function ENT:Initialize()
    self.LastEffect = 0
    self.GlowIntensity = 0
    self.TargetGlow = 0
    
    -- Ancient technology visual effects
    self.AncientGlow = true
    self.EnergyParticles = true
    self.HologramDisplay = true
    
    -- Create holographic display
    self:CreateHologramDisplay()
end

function ENT:CreateHologramDisplay()
    -- This would create a holographic status display above the weapon
    -- Implementation would depend on available particle/effect systems
end

function ENT:Draw()
    self:DrawModel()
    
    -- Ancient technology glow effect
    if self.AncientGlow then
        self:DrawAncientGlow()
    end
    
    -- Status indicators
    self:DrawStatusIndicators()
    
    -- Holographic display
    if self.HologramDisplay then
        self:DrawHologramDisplay()
    end
end

function ENT:DrawAncientGlow()
    local online = self:GetNWBool("WeaponOnline", true)
    local energy = self:GetNWInt("Energy", 500)
    local maxEnergy = self:GetNWInt("MaxEnergy", 500)
    
    -- Calculate glow intensity
    self.TargetGlow = online and (energy / maxEnergy) or 0
    self.GlowIntensity = Lerp(FrameTime() * 3, self.GlowIntensity, self.TargetGlow)
    
    if self.GlowIntensity > 0.1 then
        local glowColor = Color(100, 150, 255, self.GlowIntensity * 100)
        
        -- Render glow effect
        render.SetMaterial(Material("sprites/light_glow02_add"))
        render.DrawSprite(self:GetPos() + self:GetUp() * 20, 50 * self.GlowIntensity, 50 * self.GlowIntensity, glowColor)
        
        -- Energy core glow
        render.DrawSprite(self:GetPos(), 30 * self.GlowIntensity, 30 * self.GlowIntensity, glowColor)
    end
end

function ENT:DrawStatusIndicators()
    local pos = self:GetPos() + self:GetUp() * 40
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang.forward, 90)
    ang:RotateAroundAxis(ang.right, 90)
    
    local distance = LocalPlayer():GetPos():Distance(pos)
    if distance > 500 then return end
    
    cam.Start3D2D(pos, ang, 0.1)
        -- Background
        surface.SetDrawColor(0, 0, 0, 150)
        surface.DrawRect(-100, -30, 200, 60)
        
        -- Weapon name
        draw.SimpleText("Ancient Drone Weapon", "DermaDefault", 0, -20, Color(100, 150, 255), TEXT_ALIGN_CENTER)
        
        -- Status
        local online = self:GetNWBool("WeaponOnline", true)
        local statusText = online and "ONLINE" or "OFFLINE"
        local statusColor = online and Color(0, 255, 0) or Color(255, 0, 0)
        draw.SimpleText(statusText, "DermaDefault", 0, 0, statusColor, TEXT_ALIGN_CENTER)
        
        -- Auto-targeting indicator
        local autoTarget = self:GetNWBool("AutoTargeting", true)
        if autoTarget then
            draw.SimpleText("AUTO-TARGET", "DermaDefault", 0, 15, Color(255, 255, 0), TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

function ENT:DrawHologramDisplay()
    if not self:GetNWBool("WeaponOnline", true) then return end
    
    local pos = self:GetPos() + self:GetUp() * 60
    local time = CurTime()
    
    -- Rotating holographic elements
    local ang = Angle(0, time * 30, 0)
    
    -- Draw holographic rings
    for i = 1, 3 do
        local radius = 20 + i * 10
        local alpha = 50 + math.sin(time * 2 + i) * 30
        
        render.SetMaterial(Material("effects/select_ring"))
        render.DrawQuadEasy(pos, Vector(0, 0, 1), radius, radius, Color(100, 150, 255, alpha))
    end
end

function ENT:Think()
    -- Update visual effects based on weapon state
    local online = self:GetNWBool("WeaponOnline", true)
    local energy = self:GetNWInt("Energy", 500)
    
    -- Energy particle effects
    if online and energy > 100 and CurTime() - self.LastEffect > 0.5 then
        self:CreateEnergyParticles()
        self.LastEffect = CurTime()
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:CreateEnergyParticles()
    if not self.EnergyParticles then return end
    
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetEntity(self)
    effectdata:SetMagnitude(1)
    util.Effect("asc_ancient_energy", effectdata)
end

function ENT:OnRemove()
    -- Clean up any client-side effects
end

-- Network receivers
net.Receive("ASC_OpenWeaponInterface", function()
    local weapon = net.ReadEntity()
    local weaponName = net.ReadString()
    
    if IsValid(weapon) and weapon:GetClass() == "asc_ancient_drone" then
        ASC.UI.OpenWeaponInterface(weapon, weaponName)
    end
end)

-- UI Interface
if not ASC then ASC = {} end
if not ASC.UI then ASC.UI = {} end

function ASC.UI.OpenWeaponInterface(weapon, weaponName)
    if not IsValid(weapon) then return end
    
    -- Create weapon control interface
    local frame = vgui.Create("DFrame")
    frame:SetSize(400, 300)
    frame:SetTitle("Advanced Space Combat - " .. weaponName)
    frame:Center()
    frame:MakePopup()
    
    -- Weapon status
    local statusLabel = vgui.Create("DLabel", frame)
    statusLabel:SetPos(10, 30)
    statusLabel:SetSize(380, 20)
    statusLabel:SetText("Status: " .. (weapon:GetNWBool("WeaponOnline", true) and "ONLINE" or "OFFLINE"))
    statusLabel:SetFont("DermaDefaultBold")
    
    -- Energy display
    local energyLabel = vgui.Create("DLabel", frame)
    energyLabel:SetPos(10, 50)
    energyLabel:SetSize(380, 20)
    local energy = weapon:GetNWInt("Energy", 500)
    local maxEnergy = weapon:GetNWInt("MaxEnergy", 500)
    energyLabel:SetText("Energy: " .. energy .. "/" .. maxEnergy)
    
    -- Technology info
    local techLabel = vgui.Create("DLabel", frame)
    techLabel:SetPos(10, 70)
    techLabel:SetSize(380, 20)
    techLabel:SetText("Technology: " .. weapon:GetNWString("TechnologyCulture", "Ancient") .. " (Tier " .. weapon:GetNWInt("TechnologyTier", 10) .. ")")
    
    -- Auto-targeting toggle
    local autoToggle = vgui.Create("DCheckBoxLabel", frame)
    autoToggle:SetPos(10, 100)
    autoToggle:SetText("Auto-Targeting")
    autoToggle:SetChecked(weapon:GetNWBool("AutoTargeting", true))
    autoToggle.OnChange = function(self, val)
        net.Start("ASC_WeaponCommand")
        net.WriteEntity(weapon)
        net.WriteString("toggle_auto")
        net.SendToServer()
    end
    
    -- Power toggle
    local powerToggle = vgui.Create("DButton", frame)
    powerToggle:SetPos(10, 130)
    powerToggle:SetSize(100, 30)
    powerToggle:SetText(weapon:GetNWBool("WeaponOnline", true) and "Power Off" or "Power On")
    powerToggle.DoClick = function()
        net.Start("ASC_WeaponCommand")
        net.WriteEntity(weapon)
        net.WriteString("toggle_power")
        net.SendToServer()
    end
    
    -- Manual fire button
    local fireButton = vgui.Create("DButton", frame)
    fireButton:SetPos(120, 130)
    fireButton:SetSize(100, 30)
    fireButton:SetText("Fire Volley")
    fireButton.DoClick = function()
        net.Start("ASC_WeaponCommand")
        net.WriteEntity(weapon)
        net.WriteString("fire_manual")
        net.SendToServer()
    end
    
    -- Features list
    local featuresLabel = vgui.Create("DLabel", frame)
    featuresLabel:SetPos(10, 170)
    featuresLabel:SetSize(380, 20)
    featuresLabel:SetText("Features:")
    featuresLabel:SetFont("DermaDefaultBold")
    
    local features = {
        "• Adaptive Targeting - Learns enemy patterns",
        "• Shield Penetration - Bypasses energy barriers", 
        "• Swarm Intelligence - Coordinated drone attacks",
        "• Multi-Target - Engages multiple enemies"
    }
    
    for i, feature in ipairs(features) do
        local featureLabel = vgui.Create("DLabel", frame)
        featureLabel:SetPos(10, 185 + i * 15)
        featureLabel:SetSize(380, 15)
        featureLabel:SetText(feature)
        featureLabel:SetFont("DermaDefault")
    end
end
