-- Master Hyperdrive Engine Entity - Client Side
include("shared.lua")

function ENT:Initialize()
    self.NextParticle = 0
    self.ChargeEffect = nil
    self.GlowSprite = nil
    self.TechGlow = 0
    self.IntegrationRings = {}
    self.EfficiencyPulse = 0
end

function ENT:Draw()
    self:DrawModel()
    
    -- Draw master effects combining all systems
    if self:GetEnergy() > 0 then
        self:DrawMasterGlow()
    end
    
    if self:GetCharging() then
        self:DrawMasterChargingEffect()
    end
    
    -- Draw integration status
    if LocalPlayer():GetPos():Distance(self:GetPos()) < 500 then
        self:DrawMasterStatus()
    end
end

function ENT:DrawMasterGlow()
    local energyPercent = self:GetEnergyPercent() / 100
    local efficiency = self:GetEfficiencyRating()
    local integrations = self:GetIntegrationCount()
    
    -- Base energy glow with efficiency enhancement
    local glowIntensity = energyPercent * efficiency * 0.8 + 0.2
    local baseColor = Color(100, 150, 255, 200 * glowIntensity)
    
    local pos = self:GetPos() + self:GetUp() * 20
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, 100 * glowIntensity, 100 * glowIntensity, baseColor)
    
    -- Integration rings
    if self:HasWiremodIntegration() then
        -- Wiremod: Blue electric rings
        for i = 1, 3 do
            local ringSize = 80 + i * 20
            local ringAlpha = glowIntensity * 100 * (1 - i * 0.2)
            local ringColor = Color(0, 100, 255, ringAlpha)
            render.DrawSprite(pos + Vector(0, 0, i * 10), ringSize, ringSize, ringColor)
        end
    end
    
    if self:HasSpacebuildIntegration() then
        -- Spacebuild: Resource-colored indicators
        local powerPercent = self:GetResourcePercent("power") / 100
        local oxygenPercent = self:GetResourcePercent("oxygen") / 100
        local coolantPercent = self:GetResourcePercent("coolant") / 100
        
        -- Power ring (yellow)
        if powerPercent > 0 then
            local powerColor = Color(255, 255, 0, 150 * powerPercent * glowIntensity)
            render.DrawSprite(pos + Vector(30, 0, 0), 40, 40, powerColor)
        end
        
        -- Oxygen ring (cyan)
        if oxygenPercent > 0 then
            local oxygenColor = Color(0, 255, 255, 150 * oxygenPercent * glowIntensity)
            render.DrawSprite(pos + Vector(-30, 0, 0), 40, 40, oxygenColor)
        end
        
        -- Coolant ring (blue)
        if coolantPercent > 0 then
            local coolantColor = Color(100, 150, 255, 150 * coolantPercent * glowIntensity)
            render.DrawSprite(pos + Vector(0, 30, 0), 40, 40, coolantColor)
        end
    end
    
    if self:HasStargateIntegration() then
        -- Stargate: Technology-specific effects
        local techColor = self:GetTechLevelColor()
        local techLevel = self:GetTechLevel()
        
        if techLevel == "ancient" then
            -- Ancient golden spirals
            local time = CurTime()
            for i = 1, 6 do
                local angle = (time * 60 + i * 60) % 360
                local spiralPos = pos + Vector(
                    math.cos(math.rad(angle)) * 50,
                    math.sin(math.rad(angle)) * 50,
                    math.sin(time * 2 + i) * 15
                )
                local spiralColor = Color(255, 215, 0, 180 * glowIntensity)
                render.DrawSprite(spiralPos, 20, 20, spiralColor)
            end
        elseif techLevel == "asgard" then
            -- Asgard precise pulses
            local pulseIntensity = math.sin(CurTime() * 5) * 0.5 + 0.5
            local pulseColor = Color(100, 150, 255, 200 * pulseIntensity * glowIntensity)
            render.DrawSprite(pos, 120 * pulseIntensity, 120 * pulseIntensity, pulseColor)
        end
        
        -- ZPM power enhancement
        if self:GetZPMPower() > 50 then
            local zpmIntensity = self:GetZPMPower() / 100
            for i = 1, 4 do
                local ringSize = 70 + i * 25
                local ringAlpha = zmpIntensity * 120 * (1 - i * 0.15)
                local ringColor = Color(255, 255, 100, ringAlpha)
                render.DrawSprite(pos + Vector(0, 0, i * 12), ringSize, ringSize, ringColor)
            end
        end
    end
    
    -- Efficiency pulse effect
    self.EfficiencyPulse = self.EfficiencyPulse + FrameTime() * efficiency
    local efficiencyGlow = math.sin(self.EfficiencyPulse * 3) * 0.3 + 0.7
    local efficiencyColor = Color(255, 255, 255, 100 * efficiencyGlow * efficiency)
    render.DrawSprite(pos, 150 * efficiencyGlow, 150 * efficiencyGlow, efficiencyColor)
end

function ENT:DrawMasterChargingEffect()
    local time = CurTime()
    local intensity = math.sin(time * 25) * 0.5 + 0.5
    local efficiency = self:GetEfficiencyRating()
    
    -- Enhanced charging effects
    if time > self.NextParticle then
        self.NextParticle = time + (0.02 / efficiency) -- Faster particles with higher efficiency
        
        local pos = self:GetPos()
        local effectdata = EffectData()
        effectdata:SetOrigin(pos)
        effectdata:SetMagnitude(intensity * efficiency)
        effectdata:SetScale(efficiency)
        util.Effect("hyperdrive_master_charge", effectdata)
    end
    
    -- Master charging glow
    local chargeColor = Color(255, 255, 255, 250 * intensity)
    local pos = self:GetPos() + self:GetUp() * 25
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, 150 * intensity * efficiency, 150 * intensity * efficiency, chargeColor)
    
    -- Integration-specific charging effects
    if self:HasWiremodIntegration() then
        -- Electric arcs
        for i = 1, 5 do
            local arcPos = pos + VectorRand() * 60
            local arcColor = Color(0, 150, 255, 200 * intensity)
            render.DrawSprite(arcPos, 15, 15, arcColor)
        end
    end
    
    if self:HasSpacebuildIntegration() then
        -- Resource consumption indicators
        local powerLevel = self:GetPowerLevel()
        local oxygenLevel = self:GetOxygenLevel()
        
        if powerLevel > 0 then
            local powerColor = Color(255, 255, 0, 180 * intensity)
            render.DrawSprite(pos + Vector(40, 0, 0), 35, 35, powerColor)
        end
        
        if oxygenLevel > 0 then
            local oxygenColor = Color(0, 255, 255, 180 * intensity)
            render.DrawSprite(pos + Vector(-40, 0, 0), 35, 35, oxygenColor)
        end
    end
    
    if self:HasStargateIntegration() then
        -- Stargate energy vortex
        for i = 1, 8 do
            local angle = (time * 120 + i * 45) % 360
            local vortexPos = pos + Vector(
                math.cos(math.rad(angle)) * (70 * intensity),
                math.sin(math.rad(angle)) * (70 * intensity),
                0
            )
            local techColor = self:GetTechLevelColor()
            local vortexColor = Color(techColor.r, techColor.g, techColor.b, 220 * intensity)
            render.DrawSprite(vortexPos, 25, 25, vortexColor)
        end
    end
end

function ENT:DrawMasterStatus()
    local pos = self:GetPos() + Vector(0, 0, 60)
    local ang = (LocalPlayer():GetPos() - pos):Angle()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)
    
    cam.Start3D2D(pos, ang, 0.07)
        -- Background
        draw.RoundedBox(4, -150, -70, 300, 140, Color(0, 0, 0, 150))
        draw.RoundedBox(4, -148, -68, 296, 136, Color(20, 40, 80, 200))
        
        -- Title
        draw.SimpleText("MASTER HYPERDRIVE ENGINE", "DermaLarge", 0, -60, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        
        -- Integration status
        local integrationString = self:GetIntegrationString()
        local integrationColor = Color(100, 255, 100)
        if self:GetIntegrationCount() == 0 then
            integrationColor = Color(255, 100, 100)
        elseif self:GetIntegrationCount() == 1 then
            integrationColor = Color(255, 255, 100)
        end
        draw.SimpleText("Integrations: " .. integrationString, "DermaDefaultBold", 0, -40, integrationColor, TEXT_ALIGN_CENTER)
        
        -- Efficiency rating
        local efficiencyString = self:GetEfficiencyString()
        local efficiencyColor = Color(0, 255, 0)
        if self:GetEfficiencyRating() < 1.2 then
            efficiencyColor = Color(255, 255, 0)
        elseif self:GetEfficiencyRating() < 1.0 then
            efficiencyColor = Color(255, 100, 0)
        end
        draw.SimpleText("Efficiency: " .. efficiencyString, "DermaDefaultBold", 0, -25, efficiencyColor, TEXT_ALIGN_CENTER)
        
        -- System status sections
        local yOffset = -5
        
        -- Core status
        local energyPercent = self:GetEnergyPercent()
        local energyColor = energyPercent > 50 and Color(0, 255, 0) or energyPercent > 20 and Color(255, 255, 0) or Color(255, 0, 0)
        draw.SimpleText("Energy: " .. math.floor(energyPercent) .. "%", "DermaDefault", -120, yOffset, energyColor, TEXT_ALIGN_LEFT)
        
        -- Operational mode
        local modeString = self:GetOperationalModeString()
        local modeColor = Color(200, 200, 255)
        draw.SimpleText("Mode: " .. modeString, "DermaDefault", 120, yOffset, modeColor, TEXT_ALIGN_RIGHT)
        
        yOffset = yOffset + 15
        
        -- Integration-specific status
        if self:HasSpacebuildIntegration() then
            local lsStatus, lsColor = self:GetLifeSupportStatus()
            draw.SimpleText("Life Support: " .. lsStatus, "DermaDefault", -120, yOffset, lsColor, TEXT_ALIGN_LEFT)
            yOffset = yOffset + 15
        end
        
        if self:HasStargateIntegration() then
            local sgStatus, sgColor = self:GetStargateStatus()
            local techName = self:GetTechLevelName()
            draw.SimpleText("Stargate: " .. techName .. " (" .. sgStatus .. ")", "DermaDefault", -120, yOffset, sgColor, TEXT_ALIGN_LEFT)
            yOffset = yOffset + 15
        end
        
        -- Master status
        local masterStatus, masterColor = self:GetMasterStatus()
        draw.SimpleText("Master Status: " .. masterStatus, "DermaDefaultBold", 0, yOffset + 10, masterColor, TEXT_ALIGN_CENTER)
        
        -- Operational status
        local status = "READY"
        local statusColor = Color(0, 255, 0)
        
        if self:GetCharging() then
            status = "CHARGING..."
            statusColor = Color(255, 255, 0)
        elseif self:IsOnCooldown() then
            status = "Cooldown: " .. string.format("%.1fs", self:GetCooldownRemaining())
            statusColor = Color(255, 100, 0)
        elseif not self:CanJump() then
            status = "NOT READY"
            statusColor = Color(255, 0, 0)
        end
        
        draw.SimpleText("Status: " .. status, "DermaDefault", 0, yOffset + 30, statusColor, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

function ENT:Think()
    -- Enhanced sound effects based on integrations
    if self:GetCharging() then
        if not self.ChargingSound then
            local soundFile = "ambient/energy/electric_loop.wav"
            
            -- Choose sound based on highest priority integration
            if self:HasStargateIntegration() and self:GetTechLevel() == "ancient" then
                soundFile = "ambient/energy/spark6.wav"
            elseif self:HasStargateIntegration() and self:GetTechLevel() == "asgard" then
                soundFile = "ambient/energy/zap7.wav"
            elseif self:HasSpacebuildIntegration() then
                soundFile = "ambient/energy/whiteflash.wav"
            end
            
            self.ChargingSound = CreateSound(self, soundFile)
            self.ChargingSound:Play()
        end
        
        -- Additional integration sounds
        if self:HasSpacebuildIntegration() and self:GetPowerLevel() > 50 and not self.PowerSound then
            self.PowerSound = CreateSound(self, "ambient/energy/spark6.wav")
            self.PowerSound:Play()
        end
        
        if self:HasStargateIntegration() and self:GetZPMPower() > 50 and not self.ZPMSound then
            self.ZPMSound = CreateSound(self, "ambient/energy/whiteflash.wav")
            self.ZPMSound:Play()
        end
    else
        if self.ChargingSound then
            self.ChargingSound:Stop()
            self.ChargingSound = nil
        end
        if self.PowerSound then
            self.PowerSound:Stop()
            self.PowerSound = nil
        end
        if self.ZPMSound then
            self.ZPMSound:Stop()
            self.ZPMSound = nil
        end
    end
    
    -- Temperature warning for Spacebuild integration
    if self:HasSpacebuildIntegration() then
        local temp = self:GetTemperature()
        if temp > 80 and not self.OverheatSound then
            self.OverheatSound = CreateSound(self, "ambient/alarms/warningbell1.wav")
            self.OverheatSound:Play()
        elseif temp <= 80 and self.OverheatSound then
            self.OverheatSound:Stop()
            self.OverheatSound = nil
        end
    end
end

function ENT:OnRemove()
    if self.ChargingSound then self.ChargingSound:Stop() end
    if self.PowerSound then self.PowerSound:Stop() end
    if self.ZPMSound then self.ZPMSound:Stop() end
    if self.OverheatSound then self.OverheatSound:Stop() end
end

-- Master interface system
local masterInterface = {
    entity = nil,
    visible = false,
    lastUpdate = 0
}

function ENT:OpenMasterInterface()
    masterInterface.entity = self
    masterInterface.visible = true
    gui.EnableScreenClicker(true)
end

function ENT:CloseMasterInterface()
    masterInterface.visible = false
    gui.EnableScreenClicker(false)
end

-- Network message handler
net.Receive("hyperdrive_master_interface", function()
    local ent = net.ReadEntity()
    local energy = net.ReadFloat()
    local cooldown = net.ReadFloat()
    local charging = net.ReadBool()
    local jumpReady = net.ReadBool()
    local destination = net.ReadVector()
    local efficiency = net.ReadFloat()
    local integration = net.ReadInt(8)
    
    if IsValid(ent) and ent:GetClass() == "hyperdrive_master_engine" then
        ent:OpenMasterInterface()
    end
end)

-- Master HUD interface
hook.Add("HUDPaint", "MasterHyperdriveInterface", function()
    if not masterInterface.visible or not IsValid(masterInterface.entity) then return end
    
    local ent = masterInterface.entity
    local scrW, scrH = ScrW(), ScrH()
    local panelW, panelH = 700, 600
    local x, y = (scrW - panelW) / 2, (scrH - panelH) / 2
    
    -- Enhanced background
    draw.RoundedBox(8, x, y, panelW, panelH, Color(5, 10, 25, 240))
    draw.RoundedBox(8, x + 4, y + 4, panelW - 8, panelH - 8, Color(15, 25, 50, 220))
    
    -- Title with efficiency indicator
    local efficiency = ent:GetEfficiencyRating()
    local titleColor = Color(255, 255, 255)
    if efficiency >= 2.0 then
        titleColor = Color(0, 255, 0)
    elseif efficiency >= 1.5 then
        titleColor = Color(255, 255, 0)
    end
    
    draw.RoundedBox(8, x + 4, y + 4, panelW - 8, 50, Color(titleColor.r * 0.2, titleColor.g * 0.2, titleColor.b * 0.2, 255))
    draw.SimpleText("MASTER HYPERDRIVE CONTROL", "DermaLarge", x + panelW/2, y + 29, titleColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Integration status section
    local integY = y + 70
    draw.SimpleText("SYSTEM INTEGRATIONS", "DermaDefaultBold", x + 20, integY, Color(100, 200, 255))
    
    local integrationString = ent:GetIntegrationString()
    local integrationCount = ent:GetIntegrationCount()
    local integColor = integrationCount >= 2 and Color(0, 255, 0) or integrationCount == 1 and Color(255, 255, 0) or Color(255, 100, 0)
    draw.SimpleText("Active: " .. integrationString .. " (" .. integrationCount .. "/3)", "DermaDefault", x + 20, integY + 25, integColor)
    
    local efficiencyString = ent:GetEfficiencyString()
    draw.SimpleText("Efficiency Rating: " .. efficiencyString, "DermaDefault", x + 20, integY + 45, titleColor)
    
    -- System status sections
    local statusY = integY + 80
    
    -- Core system
    draw.SimpleText("CORE HYPERDRIVE", "DermaDefaultBold", x + 20, statusY, Color(100, 200, 255))
    local energyPercent = ent:GetEnergyPercent()
    draw.SimpleText("Energy: " .. math.floor(ent:GetEnergy()) .. " EU (" .. math.floor(energyPercent) .. "%)", "DermaDefault", x + 20, statusY + 25, Color(255, 255, 255))
    
    statusY = statusY + 60
    
    -- Integration-specific sections
    if ent:HasSpacebuildIntegration() then
        draw.SimpleText("SPACEBUILD INTEGRATION", "DermaDefaultBold", x + 20, statusY, Color(100, 255, 200))
        
        local powerPercent = ent:GetResourcePercent("power")
        local oxygenPercent = ent:GetResourcePercent("oxygen")
        local coolantPercent = ent:GetResourcePercent("coolant")
        
        draw.SimpleText("Power: " .. math.floor(powerPercent) .. "%", "DermaDefault", x + 20, statusY + 25, powerPercent > 20 and Color(0, 255, 0) or Color(255, 100, 0))
        draw.SimpleText("Oxygen: " .. math.floor(oxygenPercent) .. "%", "DermaDefault", x + 200, statusY + 25, oxygenPercent > 20 and Color(0, 255, 255) or Color(255, 100, 0))
        draw.SimpleText("Coolant: " .. math.floor(coolantPercent) .. "%", "DermaDefault", x + 380, statusY + 25, coolantPercent > 20 and Color(100, 150, 255) or Color(255, 100, 0))
        
        local tempStatus, tempColor = ent:GetTemperatureStatus()
        draw.SimpleText("Temperature: " .. math.floor(ent:GetTemperature()) .. "°C (" .. tempStatus .. ")", "DermaDefault", x + 20, statusY + 45, tempColor)
        
        statusY = statusY + 80
    end
    
    if ent:HasStargateIntegration() then
        draw.SimpleText("STARGATE INTEGRATION", "DermaDefaultBold", x + 20, statusY, Color(255, 200, 100))
        
        local techName = ent:GetTechLevelName()
        local techColor = ent:GetTechLevelColor()
        draw.SimpleText("Technology: " .. techName, "DermaDefault", x + 20, statusY + 25, techColor)
        
        local naqLevel = ent:GetNaquadahLevel()
        local zmpPower = ent:GetZPMPower()
        draw.SimpleText("Naquadah: " .. (naqLevel > 0 and "Available" or "None"), "DermaDefault", x + 200, statusY + 25, naqLevel > 0 and Color(0, 255, 0) or Color(255, 100, 0))
        draw.SimpleText("ZPM Power: " .. math.floor(zmpPower) .. "%", "DermaDefault", x + 380, statusY + 25, zmpPower > 50 and Color(0, 255, 0) or zmpPower > 0 and Color(255, 255, 0) or Color(255, 100, 0))
        
        local gateAddress = ent:GetGateAddress()
        if gateAddress and gateAddress ~= "" then
            draw.SimpleText("Gate Address: " .. gateAddress, "DermaDefault", x + 20, statusY + 45, Color(200, 200, 255))
        end
        
        statusY = statusY + 80
    end
    
    -- Overall status
    draw.SimpleText("OPERATIONAL STATUS", "DermaDefaultBold", x + 20, statusY, Color(100, 200, 255))
    
    local status = "Ready"
    local statusColor = Color(0, 255, 0)
    
    if ent:GetCharging() then
        status = "CHARGING..."
        statusColor = Color(255, 255, 0)
    elseif ent:IsOnCooldown() then
        status = "Cooldown: " .. string.format("%.1fs", ent:GetCooldownRemaining())
        statusColor = Color(255, 100, 0)
    elseif not ent:CanJump() then
        status = "NOT READY"
        statusColor = Color(255, 0, 0)
    end
    
    draw.SimpleText("Status: " .. status, "DermaDefault", x + 20, statusY + 25, statusColor)
    
    local masterStatus, masterColor = ent:GetMasterStatus()
    draw.SimpleText("Master Status: " .. masterStatus, "DermaDefault", x + 20, statusY + 45, masterColor)
    
    -- Close button
    local closeX, closeY = x + panelW - 80, y + panelH - 40
    local closeColor = Color(200, 0, 0)
    
    if input.IsMouseDown(MOUSE_LEFT) and 
       gui.MouseX() >= closeX and gui.MouseX() <= closeX + 60 and
       gui.MouseY() >= closeY and gui.MouseY() <= closeY + 25 then
        closeColor = Color(255, 0, 0)
        
        if CurTime() - masterInterface.lastUpdate > 0.2 then
            masterInterface.lastUpdate = CurTime()
            ent:CloseMasterInterface()
        end
    end
    
    draw.RoundedBox(4, closeX, closeY, 60, 25, closeColor)
    draw.SimpleText("CLOSE", "DermaDefault", closeX + 30, closeY + 12.5, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)
