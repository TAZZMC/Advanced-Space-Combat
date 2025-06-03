-- Enhanced Hyperdrive Shield Generator v5.1.0
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED WITH STEAM WORKSHOP
-- Advanced shield system with CAP Steam Workshop integration and visual effects

print("[Hyperdrive Shield] COMPLETE CODE UPDATE v5.1.0 - Ultimate Shield Generator")
print("[Hyperdrive Shield] Enhanced Steam Workshop CAP shield integration active")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Initialize shield generator
function ENT:Initialize()
    self:SetModel("models/props_lab/powerbox02d.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Shield generator properties
    self:SetMaxHealth(1000)
    self:SetHealth(1000)

    -- Shield system integration
    self.ShieldActive = false
    self.ShieldStrength = 0
    self.MaxShieldStrength = 10000
    self.EnergyConsumption = 10 -- Per second
    self.DetectedShip = nil
    self.ShieldEntity = nil

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "Activate",
            "Deactivate",
            "Toggle",
            "SetStrength",
            "UpdateShipDetection"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "ShieldActive",
            "ShieldStrength",
            "MaxShieldStrength",
            "ShieldPercent",
            "EnergyConsumption",
            "ShipDetected",
            "ShipType [STRING]",
            "CAPIntegrated"
        })
    end

    -- Start ship detection
    timer.Simple(1, function()
        if IsValid(self) then
            self:UpdateShipDetection()
        end
    end)

    print("[Hyperdrive Shield Generator] Initialized")
end

-- Update ship detection
function ENT:UpdateShipDetection()
    if not HYPERDRIVE.ShipCore then return end

    -- Find nearby ship core or hyperdrive engine
    local nearbyEnts = ents.FindInSphere(self:GetPos(), 1000)

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            -- Check if this is a ship core
            if ent:GetClass() == "ship_core" then
                local ship = HYPERDRIVE.ShipCore.GetShip(ent)
                if ship then
                    self.DetectedShip = ship
                    self.DetectedCore = ent
                    print("[Shield Generator] Detected ship: " .. (ship:GetShipType() or "Unknown"))
                    self:UpdateWireOutputs()
                    return
                end
            end

            -- Check if this is a hyperdrive engine
            if string.find(ent:GetClass(), "hyperdrive") then
                local ship = HYPERDRIVE.ShipCore.GetShipByEntity(ent)
                if ship then
                    self.DetectedShip = ship
                    self.DetectedCore = ent
                    print("[Shield Generator] Detected ship via engine: " .. (ship:GetShipType() or "Unknown"))
                    self:UpdateWireOutputs()
                    return
                end
            end
        end
    end

    self.DetectedShip = nil
    self.DetectedCore = nil
    self:UpdateWireOutputs()
end

-- Activate shield
function ENT:ActivateShield()
    if not self.DetectedShip then
        return false, "No ship detected"
    end

    if self.ShieldActive then
        return true, "Shield already active"
    end

    -- Try to create shield using the enhanced system
    local shield, message

    if HYPERDRIVE.Shields and HYPERDRIVE.Shields.CreateShield then
        shield, message = HYPERDRIVE.Shields.CreateShield(self, self.DetectedShip)
    end

    -- If that fails, try CAP integration directly
    if not shield and HYPERDRIVE.CAP and HYPERDRIVE.CAP.Shields then
        shield = HYPERDRIVE.CAP.Shields.CreateShield(self, self.DetectedShip, "cap_bubble_shield")
        if shield then
            message = "CAP shield created"
        end
    end

    if shield then
        self.ShieldEntity = shield

        -- Activate the shield
        local activated = false
        if shield.Activate then
            activated = shield:Activate()
        elseif shield.SetActive then
            shield:SetActive(true)
            activated = true
        elseif shield.TurnOn then
            shield:TurnOn()
            activated = true
        end

        if activated then
            self.ShieldActive = true

            -- Play shield activation sound
            if HYPERDRIVE.Sounds and HYPERDRIVE.Sounds.PlayShield then
                HYPERDRIVE.Sounds.PlayShield("engage", self, {
                    volume = 0.8,
                    pitch = 100,
                    soundLevel = 75
                })

                -- Start shield hum sound loop after activation
                timer.Simple(0.5, function()
                    if IsValid(self) and self.ShieldActive then
                        self.shieldHumSoundId = HYPERDRIVE.Sounds.PlayShield("hum", self, {
                            volume = 0.4,
                            pitch = 100,
                            loop = true,
                            soundLevel = 60,
                            category = "shields"
                        })
                    end
                end)
            end

            -- Create shield activation visual effect
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetEntity(self)
            effectData:SetScale(1)
            effectData:SetMagnitude(1)
            util.Effect("shield_activation", effectData)

            -- Notify clients about shield activation
            net.Start("HyperdriveShieldStatus")
            net.WriteEntity(self)
            net.WriteBool(true)
            net.Broadcast()

            print("[Shield Generator] Shield activated for " .. (self.DetectedShip:GetShipType() or "Unknown Ship"))
            self:UpdateWireOutputs()
            return true, "Shield activated"
        else
            return false, "Failed to activate shield"
        end
    else
        return false, message or "Failed to create shield"
    end
end

-- Deactivate shield
function ENT:DeactivateShield()
    if not self.ShieldActive then
        return true, "Shield already inactive"
    end

    -- Try to get and deactivate the shield
    local shield = nil
    if HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShield then
        shield = HYPERDRIVE.Shields.GetShield(self)
    elseif self.ShieldEntity then
        shield = self.ShieldEntity
    end

    if shield then
        -- Try multiple deactivation methods
        if shield.Deactivate then
            shield:Deactivate()
        elseif shield.SetActive then
            shield:SetActive(false)
        elseif shield.TurnOff then
            shield:TurnOff()
        elseif shield.Remove then
            shield:Remove()
        end
    end

    -- Remove shield from system
    if HYPERDRIVE.Shields and HYPERDRIVE.Shields.RemoveShield then
        HYPERDRIVE.Shields.RemoveShield(self)
    end

    -- Stop shield hum sound and play deactivation sound
    if HYPERDRIVE.Sounds then
        if self.shieldHumSoundId then
            if HYPERDRIVE.Sounds.StopSound then
                HYPERDRIVE.Sounds.StopSound(self.shieldHumSoundId)
            end
            self.shieldHumSoundId = nil
        end

        if HYPERDRIVE.Sounds.PlayShield then
            HYPERDRIVE.Sounds.PlayShield("disengage", self, {
                volume = 0.7,
                pitch = 100,
                soundLevel = 75
            })
        end
    end

    self.ShieldActive = false
    self.ShieldEntity = nil

    -- Notify clients about shield deactivation
    net.Start("HyperdriveShieldStatus")
    net.WriteEntity(self)
    net.WriteBool(false)
    net.Broadcast()

    print("[Shield Generator] Shield deactivated")
    self:UpdateWireOutputs()
    return true, "Shield deactivated"
end

-- Toggle shield
function ENT:ToggleShield()
    if self.ShieldActive then
        return self:DeactivateShield()
    else
        return self:ActivateShield()
    end
end

-- Wire input handling
function ENT:TriggerInput(iname, value)
    if iname == "Activate" and value > 0 then
        self:ActivateShield()
    elseif iname == "Deactivate" and value > 0 then
        self:DeactivateShield()
    elseif iname == "Toggle" and value > 0 then
        self:ToggleShield()
    elseif iname == "SetStrength" and value > 0 then
        self.MaxShieldStrength = math.max(1000, value)
        local shield = HYPERDRIVE.Shields.GetShield(self)
        if shield then
            shield.maxStrength = self.MaxShieldStrength
            if shield.strength > shield.maxStrength then
                shield.strength = shield.maxStrength
            end
        end
    elseif iname == "UpdateShipDetection" and value > 0 then
        self:UpdateShipDetection()
    end

    self:UpdateWireOutputs()
end

-- Update wire outputs
function ENT:UpdateWireOutputs()
    if not WireLib then return end

    local shield = nil
    local shieldStatus = {}

    -- Safely get shield and status
    if HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShield then
        shield = HYPERDRIVE.Shields.GetShield(self)
    end

    if HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShieldStatus then
        shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(self) or {}
    end

    -- Safe wire outputs
    WireLib.TriggerOutput(self, "ShieldActive", self.ShieldActive and 1 or 0)
    WireLib.TriggerOutput(self, "ShieldStrength", shieldStatus.strength or 0)
    WireLib.TriggerOutput(self, "MaxShieldStrength", shieldStatus.maxStrength or self.MaxShieldStrength)
    WireLib.TriggerOutput(self, "ShieldPercent", shieldStatus.strengthPercent or 0)
    WireLib.TriggerOutput(self, "EnergyConsumption", self.EnergyConsumption)
    WireLib.TriggerOutput(self, "ShipDetected", self.DetectedShip and 1 or 0)

    -- Safe ship type access
    local shipType = "none"
    if self.DetectedShip then
        if self.DetectedShip.GetShipType then
            shipType = self.DetectedShip:GetShipType() or "Unknown"
        elseif self.DetectedShip.shipType then
            shipType = self.DetectedShip.shipType
        end
    end
    WireLib.TriggerOutput(self, "ShipType", shipType)
    WireLib.TriggerOutput(self, "CAPIntegrated", shieldStatus.capIntegrated and 1 or 0)
end

-- Think function
function ENT:Think()
    -- Update shield status
    if self.ShieldActive then
        local shield = nil
        if HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShield then
            shield = HYPERDRIVE.Shields.GetShield(self)
        elseif self.ShieldEntity then
            shield = self.ShieldEntity
        end

        if not shield or (shield.active ~= nil and not shield.active) then
            self.ShieldActive = false
            self.ShieldEntity = nil
        end
    end

    -- Update wire outputs periodically
    if not self.lastWireUpdate or CurTime() - self.lastWireUpdate > 1 then
        self:UpdateWireOutputs()
        self.lastWireUpdate = CurTime()
    end

    self:NextThink(CurTime() + 0.5)
    return true
end

-- Use function
function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Shield Generator] Too far away to access interface")
        return
    end

    -- Show shield status and toggle
    activator:ChatPrint("[Shield Generator] Opening shield control interface...")

    -- Show current status
    local shield = nil
    if HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShield then
        shield = HYPERDRIVE.Shields.GetShield(self)
    elseif self.ShieldEntity then
        shield = self.ShieldEntity
    end

    if shield then
        local active = shield.active or false
        local strength = shield.strength or 0
        local maxStrength = shield.maxStrength or self.MaxShieldStrength

        activator:ChatPrint("Shield Status: " .. (active and "Active" or "Inactive"))
        activator:ChatPrint("Shield Strength: " .. math.floor(strength) .. "/" .. math.floor(maxStrength))
    else
        activator:ChatPrint("Shield Status: Not deployed")
    end

    -- Show ship detection status
    if self.DetectedShip then
        local shipType = "Unknown"
        if self.DetectedShip.GetShipType then
            shipType = self.DetectedShip:GetShipType() or "Unknown"
        elseif self.DetectedShip.shipType then
            shipType = self.DetectedShip.shipType
        end
        activator:ChatPrint("Detected Ship: " .. shipType)
    else
        activator:ChatPrint("No ship detected - place near ship core or hyperdrive engine")
    end

    -- Toggle shield
    local success, message = self:ToggleShield()
    activator:ChatPrint(message or (success and "Shield toggled" or "Shield operation failed"))
end

-- Take damage
function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()

    -- If shield is active, it should protect the generator
    if self.ShieldActive then
        local shield = HYPERDRIVE.Shields.GetShield(self)
        if shield and shield.active then
            local remainingDamage = shield:TakeDamage(damage, dmginfo:GetAttacker(), dmginfo:GetDamagePosition())
            dmginfo:SetDamage(remainingDamage * 0.1) -- Generator takes reduced damage
        end
    end

    -- Take damage normally
    self:SetHealth(self:Health() - dmginfo:GetDamage())

    if self:Health() <= 0 then
        self:DeactivateShield()
        self:Remove()
    end
end

-- Clean up
function ENT:OnRemove()
    self:DeactivateShield()

    if WireLib then
        Wire_Remove(self)
    end
end

-- Get shield status for external access
function ENT:GetShieldStatus()
    return HYPERDRIVE.Shields.GetShieldStatus(self)
end

-- Manual shield control
function ENT:SetShieldActive(active)
    if active then
        return self:ActivateShield()
    else
        return self:DeactivateShield()
    end
end

function ENT:IsShieldActive()
    return self.ShieldActive
end

function ENT:GetShieldStrength()
    local status = self:GetShieldStatus()
    return status.strength or 0
end

function ENT:GetMaxShieldStrength()
    local status = self:GetShieldStatus()
    return status.maxStrength or self.MaxShieldStrength
end
