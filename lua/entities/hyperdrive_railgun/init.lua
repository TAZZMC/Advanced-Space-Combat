-- Enhanced Hyperdrive Railgun v2.2.1
-- Ship-integrated electromagnetic railgun with penetrating projectiles

print("[Hyperdrive Weapons] Railgun v2.2.1 - Entity loading...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Use centralized model manager
    if ASC and ASC.Models and ASC.Models.GetModel then
        self:SetModel(ASC.Models.GetModel("railgun"))
    else
        -- Fallback if model manager not loaded yet
        self:SetModel("models/props_combine/combine_interface002.mdl")
        print("[Hyperdrive Railgun] Model manager not available, using direct fallback")
    end

    self:SetModelScale(1.2)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Weapon properties
    self:SetMaxHealth(800)
    self:SetHealth(800)
    
    -- Initialize weapon system
    self.weapon = nil
    self.lastTargetUpdate = 0
    self.targetUpdateRate = 0.1
    self.chargeStartTime = 0
    self.maxChargeTime = 3.0 -- 3 seconds to full charge
    self.lastReloadTime = 0
    self.reloadTime = 5.0 -- 5 seconds reload
    
    -- Initialize network variables
    self:SetWeaponActive(false)
    self:SetAutoTarget(true)
    self:SetTargetLocked(false)
    self:SetCharging(false)
    self:SetOverheated(false)
    self:SetAmmo(8)
    self:SetMaxAmmo(8)
    self:SetChargeLevel(0)
    self:SetHeat(0)
    self:SetRange(4000)
    self:SetChargeTime(3.0)
    self:SetPenetrationPower(5) -- Can penetrate 5 targets
    self:SetWeaponStatus("Initializing...")

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "Fire",
            "StartCharge",
            "StopCharge",
            "SetTarget",
            "AutoTarget",
            "Activate",
            "Deactivate",
            "ChargeLevel"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "WeaponActive",
            "TargetLocked",
            "Charging",
            "ChargeLevel",
            "Ammo",
            "Heat",
            "PenetrationPower",
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

    print("[Hyperdrive Weapons] Railgun initialized")
end

function ENT:InitializeWeapon()
    if not HYPERDRIVE.Weapons then
        self:SetWeaponStatus("Weapons system not loaded")
        return
    end

    -- Create weapon instance
    self.weapon = HYPERDRIVE.Weapons.WeaponClass:New(self, "hyperdrive_railgun")
    self.weapon:Initialize()
    
    -- Override railgun-specific properties
    self.weapon.fireRate = 0.3 -- 0.3 shots per second
    self.weapon.energyCost = 75
    self.weapon.damage = 300
    self.weapon.ammo = 8
    self.weapon.projectileSpeed = 2000
    
    -- Update network variables
    self:SetRange(self.weapon.range)
    self:SetMaxAmmo(self.weapon.ammo)
    self:SetAmmo(self.weapon.ammo)
    self:SetShipCore(self.weapon.shipCore)
    
    if self.weapon.shipCore then
        self:SetWeaponStatus("Ready - Railgun loaded")
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
    
    -- Handle charging
    self:UpdateCharging()
    
    -- Handle reloading
    self:UpdateReloading()
    
    -- Update heat dissipation
    if self.weapon.heat > 0 and not self.weapon.overheated then
        self.weapon.heat = math.max(0, self.weapon.heat - 1)
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
    
    -- Auto charge and fire if target locked
    if self.weapon.targetLock and self.weapon.target and not self:GetCharging() and self:GetAmmo() > 0 then
        self:StartCharging()
    end
end

function ENT:StartCharging()
    if self:GetCharging() or self:GetAmmo() <= 0 then return end
    
    self.chargeStartTime = CurTime()
    self:SetCharging(true)
    self:SetChargeLevel(0)
    self:SetWeaponStatus("Charging railgun...")
    
    -- Notify clients
    net.Start("HyperdriveRailgunCharge")
    net.WriteEntity(self)
    net.WriteBool(true) -- Start charge
    net.Broadcast()
    
    print("[Hyperdrive Railgun] Charging started")
end

function ENT:StopCharging()
    if not self:GetCharging() then return end
    
    self:SetCharging(false)
    self:SetChargeLevel(0)
    self:SetWeaponStatus("Charge stopped")
    
    -- Notify clients
    net.Start("HyperdriveRailgunCharge")
    net.WriteEntity(self)
    net.WriteBool(false) -- Stop charge
    net.Broadcast()
end

function ENT:UpdateCharging()
    if not self:GetCharging() then return end
    
    local chargeProgress = (CurTime() - self.chargeStartTime) / self.maxChargeTime
    local chargeLevel = math.Clamp(chargeProgress * 100, 0, 100)
    self:SetChargeLevel(chargeLevel)
    
    if chargeProgress >= 1.0 then
        -- Full charge reached - auto fire
        self:FireRailgun()
    end
end

function ENT:UpdateReloading()
    if self:GetAmmo() > 0 then return end
    
    if self.lastReloadTime == 0 then
        self.lastReloadTime = CurTime()
        self:SetWeaponStatus("Reloading...")
    end
    
    local reloadProgress = (CurTime() - self.lastReloadTime) / self.reloadTime
    
    if reloadProgress >= 1.0 then
        -- Reload complete
        self:SetAmmo(self:GetMaxAmmo())
        self.weapon.ammo = self:GetMaxAmmo()
        self.lastReloadTime = 0
        self:SetWeaponStatus("Reload complete")
    end
end

function ENT:FireRailgun()
    if not self.weapon then return false end
    
    -- Check if we can fire
    if self:GetAmmo() <= 0 then
        return false, "No ammunition"
    end
    
    local canFire, reason = self.weapon:CanFire()
    if not canFire then
        self:SetWeaponStatus(reason or "Cannot fire")
        return false
    end
    
    -- Calculate damage based on charge level
    local chargeMultiplier = math.max(0.3, self:GetChargeLevel() / 100)
    local actualDamage = self.weapon.damage * chargeMultiplier
    
    -- Consume ammo and energy
    self:SetAmmo(self:GetAmmo() - 1)
    self.weapon.ammo = self:GetAmmo()
    
    local energyCost = self.weapon.energyCost * chargeMultiplier
    if self.weapon.shipCore and HYPERDRIVE.SB3Resources then
        HYPERDRIVE.SB3Resources.ConsumeResource(self.weapon.shipCore, "energy", energyCost)
    end
    
    -- Add heat
    self.weapon.heat = math.min(100, self.weapon.heat + 25)
    if self.weapon.heat >= 100 then
        self.weapon.overheated = true
        timer.Simple(4, function()
            if IsValid(self) then
                self.weapon.overheated = false
                self.weapon.heat = 0
            end
        end)
    end
    
    -- Create railgun projectile
    self:CreateRailgunSlug(actualDamage, chargeMultiplier)
    
    -- Stop charging
    self:StopCharging()
    
    self:SetWeaponStatus("Railgun fired - " .. self:GetAmmo() .. " rounds remaining")
    
    -- Notify clients
    net.Start("HyperdriveRailgunFire")
    net.WriteEntity(self)
    net.WriteFloat(chargeMultiplier)
    net.WriteVector(self.weapon.target and self.weapon.target:GetPos() or Vector(0,0,0))
    net.Broadcast()
    
    self.weapon.lastFireTime = CurTime()
    return true
end

function ENT:CreateRailgunSlug(damage, chargeMultiplier)
    local slug = ents.Create("hyperdrive_railgun_slug")
    if IsValid(slug) then
        local pos = self:GetPos() + self:GetForward() * 50
        slug:SetPos(pos)
        slug:SetAngles(self:GetAngles())
        slug:Spawn()
        
        -- Set slug properties
        slug:SetWeapon(self.weapon)
        slug:SetTarget(self.weapon.target)
        slug:SetDamage(damage)
        slug:SetSpeed(self.weapon.projectileSpeed * chargeMultiplier)
        slug:SetPenetrationPower(self:GetPenetrationPower())
        slug:SetChargeLevel(chargeMultiplier)
        
        print("[Hyperdrive Railgun] Slug fired with " .. math.floor(damage) .. " damage")
    end
end

function ENT:TriggerInput(iname, value)
    if not self.weapon then return end
    
    if iname == "Fire" and value > 0 then
        if self:GetCharging() then
            self:FireRailgun()
        else
            self:StartCharging()
        end
    elseif iname == "StartCharge" and value > 0 then
        self:StartCharging()
    elseif iname == "StopCharge" and value > 0 then
        self:StopCharging()
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
        self:StopCharging()
    elseif iname == "ChargeLevel" and value > 0 then
        -- Manual charge level setting
        if self:GetCharging() then
            local targetCharge = math.Clamp(value, 0, 100)
            self:SetChargeLevel(targetCharge)
        end
    end
    
    self:UpdateWireOutputs()
end

function ENT:UpdateWireOutputs()
    if not WireLib or not self.weapon then return end
    
    local energyLevel = 100 -- Default
    
    if self.weapon.shipCore and HYPERDRIVE.SB3Resources then
        energyLevel = HYPERDRIVE.SB3Resources.GetResourcePercent(self.weapon.shipCore, "energy")
    end
    
    local chargeMultiplier = math.max(0.3, self:GetChargeLevel() / 100)
    local currentDamage = self.weapon.damage * chargeMultiplier
    
    WireLib.TriggerOutput(self, "WeaponActive", self:GetWeaponActive() and 1 or 0)
    WireLib.TriggerOutput(self, "TargetLocked", self:GetTargetLocked() and 1 or 0)
    WireLib.TriggerOutput(self, "Charging", self:GetCharging() and 1 or 0)
    WireLib.TriggerOutput(self, "ChargeLevel", self:GetChargeLevel())
    WireLib.TriggerOutput(self, "Ammo", self:GetAmmo())
    WireLib.TriggerOutput(self, "Heat", self:GetHeat())
    WireLib.TriggerOutput(self, "PenetrationPower", self:GetPenetrationPower())
    WireLib.TriggerOutput(self, "Range", self:GetRange())
    WireLib.TriggerOutput(self, "Damage", currentDamage)
    WireLib.TriggerOutput(self, "EnergyLevel", energyLevel)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Railgun] Too far away to access controls")
        return
    end
    
    activator:ChatPrint("[Railgun] Electromagnetic Railgun System")
    activator:ChatPrint("Status: " .. self:GetWeaponStatus())
    
    if self.weapon then
        activator:ChatPrint("Charge Level: " .. self:GetChargeLevel() .. "%")
        activator:ChatPrint("Penetration: " .. self:GetPenetrationPower() .. " targets")
        activator:ChatPrint("Ammo: " .. self:GetAmmo() .. "/" .. self:GetMaxAmmo())
        activator:ChatPrint("Range: " .. self.weapon.range)
        activator:ChatPrint("Heat: " .. self:GetHeat() .. "/100")
        
        if self:GetCharging() then
            activator:ChatPrint("Status: CHARGING")
        elseif self:GetTargetLocked() then
            activator:ChatPrint("Target: LOCKED")
        else
            activator:ChatPrint("Target: Searching...")
        end
        
        -- Toggle charging
        if self:GetCharging() then
            self:StopCharging()
            activator:ChatPrint("Charging stopped")
        else
            self:StartCharging()
            activator:ChatPrint("Charging started")
        end
    else
        activator:ChatPrint("Weapon system not initialized")
    end
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    
    -- Stop charging if taking damage
    if self:GetCharging() then
        self:StopCharging()
    end
    
    -- Reduce damage if shields are active
    if self.weapon and self.weapon.shipCore then
        local shieldStatus = {}
        if HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShieldStatus then
            shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(self.weapon.shipCore) or {}
        end
        
        if shieldStatus.active then
            damage = damage * 0.5 -- Shields absorb 50% of damage
        end
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Create explosion effect
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetScale(4)
        util.Effect("Explosion", effectData)
        
        self:Remove()
    end
end

function ENT:OnRemove()
    self:StopCharging()
    
    if self.weapon then
        HYPERDRIVE.Weapons.UnregisterWeapon(self:EntIndex())
    end
    
    if WireLib then
        Wire_Remove(self)
    end
    
    print("[Hyperdrive Weapons] Railgun removed")
end
