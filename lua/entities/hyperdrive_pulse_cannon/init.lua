-- Enhanced Hyperdrive Pulse Cannon v2.2.1
-- Ship-integrated energy pulse weapon with advanced targeting

print("[Hyperdrive Weapons] Pulse Cannon v2.2.1 - Entity loading...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Use centralized model manager
    if ASC and ASC.Models and ASC.Models.GetModel then
        self:SetModel(ASC.Models.GetModel("pulse_cannon"))
    else
        -- Fallback if model manager not loaded yet
        self:SetModel("models/props_combine/combine_mine01.mdl")
        print("[Hyperdrive Pulse Cannon] Model manager not available, using direct fallback")
    end

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Weapon properties
    self:SetMaxHealth(500)
    self:SetHealth(500)
    
    -- Initialize weapon system
    self.weapon = nil
    self.lastTargetUpdate = 0
    self.targetUpdateRate = 0.1 -- 10 FPS targeting updates
    
    -- Initialize network variables
    self:SetWeaponActive(false)
    self:SetAutoTarget(true)
    self:SetTargetLocked(false)
    self:SetOverheated(false)
    self:SetAmmo(-1) -- Unlimited
    self:SetMaxAmmo(-1)
    self:SetHeat(0)
    self:SetMaxHeat(100)
    self:SetFireRate(2.0)
    self:SetRange(1500)
    self:SetWeaponStatus("Initializing...")

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "Fire",
            "SetTarget",
            "AutoTarget",
            "Activate",
            "Deactivate"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "WeaponActive",
            "TargetLocked",
            "Ammo",
            "Heat",
            "CanFire",
            "Range",
            "Damage",
            "EnergyLevel"
        })
    end

    -- Initialize weapon after short delay
    timer.Simple(1, function()
        if IsValid(self) then
            self:InitializeWeapon()
        end
    end)

    print("[Hyperdrive Weapons] Pulse Cannon initialized")
end

function ENT:InitializeWeapon()
    if not HYPERDRIVE.Weapons then
        self:SetWeaponStatus("Weapons system not loaded")
        return
    end

    -- Create weapon instance
    self.weapon = HYPERDRIVE.Weapons.WeaponClass:New(self, "hyperdrive_pulse_cannon")
    self.weapon:Initialize()
    
    -- Update network variables
    self:SetRange(self.weapon.range)
    self:SetFireRate(self.weapon.fireRate)
    self:SetMaxHeat(self.weapon.maxHeat)
    self:SetShipCore(self.weapon.shipCore)
    
    if self.weapon.shipCore then
        self:SetWeaponStatus("Ready - Linked to ship")
        self:SetWeaponActive(true)
    else
        self:SetWeaponStatus("No ship core detected")
        self:SetWeaponActive(false)
    end
    
    self:UpdateWireOutputs()
end

function ENT:Think()
    if not self.weapon then
        self:NextThink(CurTime() + 1)
        return true
    end
    
    -- Update targeting
    if CurTime() - self.lastTargetUpdate >= self.targetUpdateRate then
        self:UpdateTargeting()
        self.lastTargetUpdate = CurTime()
    end
    
    -- Update heat dissipation
    if self.weapon.heat > 0 and not self.weapon.overheated then
        self.weapon.heat = math.max(0, self.weapon.heat - 2) -- Cool down
        self:SetHeat(self.weapon.heat)
    end
    
    -- Update overheated status
    self:SetOverheated(self.weapon.overheated)
    
    -- Update wire outputs
    self:UpdateWireOutputs()
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:UpdateTargeting()
    if not self.weapon or not self:GetAutoTarget() then return end
    
    self.weapon:UpdateTargeting()
    
    -- Update network variables
    self:SetTarget(self.weapon.target)
    self:SetTargetLocked(self.weapon.targetLock)
    
    -- Auto fire if target locked
    if self.weapon.targetLock and self.weapon.target then
        self:FireWeapon()
    end
end

function ENT:FireWeapon(target)
    if not self.weapon then return false end
    
    target = target or self.weapon.target
    
    local success, reason = self.weapon:Fire(target)
    
    if success then
        -- Update heat
        self:SetHeat(self.weapon.heat)
        
        -- Notify clients
        net.Start("HyperdriveWeaponFire")
        net.WriteEntity(self)
        net.WriteVector(target and target:GetPos() or Vector(0,0,0))
        net.Broadcast()
        
        self:SetWeaponStatus("Firing")
    else
        self:SetWeaponStatus(reason or "Cannot fire")
    end
    
    return success
end

function ENT:TriggerInput(iname, value)
    if not self.weapon then return end
    
    if iname == "Fire" and value > 0 then
        self:FireWeapon()
    elseif iname == "SetTarget" and IsValid(value) then
        self.weapon.target = value
        self:SetTarget(value)
    elseif iname == "AutoTarget" then
        self:SetAutoTarget(value > 0)
        self.weapon.autoTarget = value > 0
    elseif iname == "Activate" and value > 0 then
        self:SetWeaponActive(true)
        self.weapon.active = true
    elseif iname == "Deactivate" and value > 0 then
        self:SetWeaponActive(false)
        self.weapon.active = false
    end
    
    self:UpdateWireOutputs()
end

function ENT:UpdateWireOutputs()
    if not WireLib or not self.weapon then return end
    
    local canFire, _ = self.weapon:CanFire()
    local energyLevel = 100 -- Default
    
    if self.weapon.shipCore and HYPERDRIVE.SB3Resources then
        energyLevel = HYPERDRIVE.SB3Resources.GetResourcePercent(self.weapon.shipCore, "energy")
    end
    
    WireLib.TriggerOutput(self, "WeaponActive", self:GetWeaponActive() and 1 or 0)
    WireLib.TriggerOutput(self, "TargetLocked", self:GetTargetLocked() and 1 or 0)
    WireLib.TriggerOutput(self, "Ammo", self:GetAmmo())
    WireLib.TriggerOutput(self, "Heat", self:GetHeat())
    WireLib.TriggerOutput(self, "CanFire", canFire and 1 or 0)
    WireLib.TriggerOutput(self, "Range", self:GetRange())
    WireLib.TriggerOutput(self, "Damage", self.weapon.damage)
    WireLib.TriggerOutput(self, "EnergyLevel", energyLevel)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Pulse Cannon] Too far away to access controls")
        return
    end
    
    activator:ChatPrint("[Pulse Cannon] Weapon Control Interface")
    activator:ChatPrint("Status: " .. self:GetWeaponStatus())
    
    if self.weapon then
        activator:ChatPrint("Damage: " .. self.weapon.damage)
        activator:ChatPrint("Range: " .. self.weapon.range)
        activator:ChatPrint("Fire Rate: " .. self.weapon.fireRate .. " shots/sec")
        activator:ChatPrint("Heat: " .. self:GetHeat() .. "/" .. self:GetMaxHeat())
        
        if self:GetTargetLocked() then
            activator:ChatPrint("Target: LOCKED")
        else
            activator:ChatPrint("Target: Searching...")
        end
        
        -- Toggle auto-targeting
        self:SetAutoTarget(not self:GetAutoTarget())
        activator:ChatPrint("Auto-targeting: " .. (self:GetAutoTarget() and "ENABLED" or "DISABLED"))
    else
        activator:ChatPrint("Weapon system not initialized")
    end
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    
    -- Reduce damage if shields are active
    if self.weapon and self.weapon.shipCore then
        local shieldStatus = {}
        if HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShieldStatus then
            shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(self.weapon.shipCore) or {}
        end
        
        if shieldStatus.active then
            damage = damage * 0.3 -- Shields absorb 70% of damage
        end
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Create explosion effect
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetScale(2)
        util.Effect("Explosion", effectData)
        
        self:Remove()
    end
end

function ENT:OnRemove()
    if self.weapon then
        HYPERDRIVE.Weapons.UnregisterWeapon(self:EntIndex())
    end

    -- Unlink from ship core
    if self.shipCore and IsValid(self.shipCore) then
        self.shipCore = nil
    end

    if WireLib then
        Wire_Remove(self)
    end

    -- Support undo system
    if self.UndoID then
        undo.ReplaceEntity(self.UndoID, NULL)
    end

    print("[Hyperdrive Weapons] Pulse Cannon removed")
end

-- Manual weapon control functions
function ENT:SetTargetEntity(target)
    if self.weapon then
        self.weapon.target = target
        self:SetTarget(target)
    end
end

function ENT:GetWeaponDamage()
    return self.weapon and self.weapon.damage or 0
end

function ENT:GetWeaponRange()
    return self.weapon and self.weapon.range or 0
end

function ENT:IsWeaponReady()
    if not self.weapon then return false end
    local canFire, _ = self.weapon:CanFire()
    return canFire
end
