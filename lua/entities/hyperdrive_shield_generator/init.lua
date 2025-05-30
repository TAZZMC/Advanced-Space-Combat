AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Initialize shield generator
function ENT:Initialize()
    self:SetModel("models/props_lab/powerbox02d.mdl")
    self:PhysicsInit(SOLID_VBBOX)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VBBOX)
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
            local ship = HYPERDRIVE.ShipCore.GetShipByEntity(ent)
            if ship then
                self.DetectedShip = ship
                print("[Shield Generator] Detected ship: " .. ship:GetShipType())
                self:UpdateWireOutputs()
                return
            end
        end
    end

    self.DetectedShip = nil
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

    -- Create shield using our enhanced system
    local shield, message = HYPERDRIVE.Shields.CreateShield(self, self.DetectedShip)
    if shield then
        self.ShieldEntity = shield
        shield:Activate()
        self.ShieldActive = true

        print("[Shield Generator] Shield activated for " .. self.DetectedShip:GetShipType())
        self:UpdateWireOutputs()
        return true, "Shield activated"
    else
        return false, message or "Failed to create shield"
    end
end

-- Deactivate shield
function ENT:DeactivateShield()
    if not self.ShieldActive then
        return true, "Shield already inactive"
    end

    local shield = HYPERDRIVE.Shields.GetShield(self)
    if shield then
        shield:Deactivate()
    end

    HYPERDRIVE.Shields.RemoveShield(self)

    self.ShieldActive = false
    self.ShieldEntity = nil

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

    local shield = HYPERDRIVE.Shields.GetShield(self)
    local shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(self)

    WireLib.TriggerOutput(self, "ShieldActive", self.ShieldActive and 1 or 0)
    WireLib.TriggerOutput(self, "ShieldStrength", shieldStatus.strength or 0)
    WireLib.TriggerOutput(self, "MaxShieldStrength", shieldStatus.maxStrength or self.MaxShieldStrength)
    WireLib.TriggerOutput(self, "ShieldPercent", shieldStatus.strengthPercent or 0)
    WireLib.TriggerOutput(self, "EnergyConsumption", self.EnergyConsumption)
    WireLib.TriggerOutput(self, "ShipDetected", self.DetectedShip and 1 or 0)
    WireLib.TriggerOutput(self, "ShipType", self.DetectedShip and self.DetectedShip:GetShipType() or "none")
    WireLib.TriggerOutput(self, "CAPIntegrated", shieldStatus.capIntegrated and 1 or 0)
end

-- Think function
function ENT:Think()
    -- Update shield status
    if self.ShieldActive then
        local shield = HYPERDRIVE.Shields.GetShield(self)
        if not shield or not shield.active then
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
    local shield = HYPERDRIVE.Shields.GetShield(self)
    if shield then
        activator:ChatPrint("Shield Status: " .. (shield.active and "Active" or "Inactive"))
        activator:ChatPrint("Shield Strength: " .. math.floor(shield.strength) .. "/" .. math.floor(shield.maxStrength))
    else
        activator:ChatPrint("Shield Status: Not deployed")
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
