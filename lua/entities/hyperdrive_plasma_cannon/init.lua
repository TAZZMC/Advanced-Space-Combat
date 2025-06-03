-- Enhanced Hyperdrive Plasma Cannon v5.1.0
-- Ship-integrated plasma cannon with area-effect damage
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Hyperdrive Weapons] Plasma Cannon v5.1.0 - Ultimate Entity loading...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Use centralized model manager
    if ASC and ASC.Models and ASC.Models.GetModel then
        self:SetModel(ASC.Models.GetModel("plasma_cannon"))
    else
        -- Fallback if model manager not loaded yet
        self:SetModel("models/props_combine/combine_mine01.mdl")
        print("[Hyperdrive Plasma Cannon] Model manager not available, using direct fallback")
    end

    self:SetModelScale(1.3)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Weapon properties
    self:SetMaxHealth(600)
    self:SetHealth(600)
    
    -- Initialize weapon system
    self.weapon = nil
    self.lastTargetUpdate = 0
    self.targetUpdateRate = 0.15
    self.chargeStartTime = 0
    self.chargeTime = 1.5 -- 1.5 seconds charge time
    self.lastReloadTime = 0
    self.reloadTime = 4.0 -- 4 seconds reload
    
    -- Initialize network variables
    self:SetWeaponActive(false)
    self:SetAutoTarget(true)
    self:SetTargetLocked(false)
    self:SetOverheated(false)
    self:SetCharging(false)
    self:SetAmmo(12)
    self:SetMaxAmmo(12)
    self:SetHeat(0)
    self:SetMaxHeat(120)
    self:SetPlasmaTemp(2000) -- 2000 degrees
    self:SetRange(2000)
    self:SetSplashRadius(200)
    self:SetChargeLevel(0)
    self:SetWeaponStatus("Initializing...")

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "Fire",
            "SetTarget",
            "AutoTarget",
            "Activate",
            "Deactivate",
            "PlasmaTemp",
            "SplashRadius"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "WeaponActive",
            "TargetLocked",
            "Charging",
            "ChargeLevel",
            "Ammo",
            "Heat",
            "PlasmaTemp",
            "SplashRadius",
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

    print("[Hyperdrive Weapons] Plasma Cannon initialized")
end

function ENT:InitializeWeapon()
    if not HYPERDRIVE.Weapons then
        self:SetWeaponStatus("Weapons system not loaded")
        return
    end

    -- Create weapon instance
    self.weapon = HYPERDRIVE.Weapons.WeaponClass:New(self, "hyperdrive_plasma_cannon")
    self.weapon:Initialize()
    
    -- Override plasma-specific properties
    self.weapon.fireRate = 1.0 -- 1 shot per second
    self.weapon.energyCost = 40
    self.weapon.damage = 150
    self.weapon.ammo = 12
    self.weapon.projectileSpeed = 900
    
    -- Update network variables
    self:SetRange(self.weapon.range)
    self:SetMaxAmmo(self.weapon.ammo)
    self:SetAmmo(self.weapon.ammo)
    self:SetShipCore(self.weapon.shipCore)
    
    if self.weapon.shipCore then
        self:SetWeaponStatus("Ready - Plasma chamber loaded")
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
        local coolingRate = self:GetCharging() and 1 or 4 -- Slower cooling while charging
        self.weapon.heat = math.max(0, self.weapon.heat - coolingRate)
        self:SetHeat(self.weapon.heat)
    end
    
    -- Update overheated status
    self:SetOverheated(self.weapon.overheated)
    
    -- Update wire outputs
    self:UpdateWireOutputs()
    
    self:NextThink(CurTime() + 0.15)
    return true
end

function ENT:UpdateTargeting()
    if not self.weapon or not self:GetAutoTarget() then return end
    
    self.weapon:UpdateTargeting()
    
    -- Update network variables
    self:SetTarget(self.weapon.target)
    self:SetTargetLocked(self.weapon.targetLock)
    
    -- Auto charge and fire if target locked
    if self.weapon.targetLock and self.weapon.target and not self:GetCharging() and self:GetAmmo() > 0 and not self.weapon.overheated then
        self:StartCharging()
    end
end

function ENT:StartCharging()
    if self:GetCharging() or self:GetAmmo() <= 0 or self.weapon.overheated then return end
    
    self.chargeStartTime = CurTime()
    self:SetCharging(true)
    self:SetChargeLevel(0)
    self:SetWeaponStatus("Charging plasma...")
    
    -- Notify clients
    net.Start("HyperdrivePlaymaCharge")
    net.WriteEntity(self)
    net.WriteBool(true) -- Start charge
    net.Broadcast()
    
    print("[Hyperdrive Plasma] Charging started")
end

function ENT:StopCharging()
    if not self:GetCharging() then return end
    
    self:SetCharging(false)
    self:SetChargeLevel(0)
    self:SetWeaponStatus("Charge stopped")
    
    -- Notify clients
    net.Start("HyperdrivePlaymaCharge")
    net.WriteEntity(self)
    net.WriteBool(false) -- Stop charge
    net.Broadcast()
end

function ENT:UpdateCharging()
    if not self:GetCharging() then return end
    
    local chargeProgress = (CurTime() - self.chargeStartTime) / self.chargeTime
    local chargeLevel = math.Clamp(chargeProgress * 100, 0, 100)
    self:SetChargeLevel(chargeLevel)
    
    -- Add heat while charging
    self.weapon.heat = math.min(self:GetMaxHeat(), self.weapon.heat + 3)
    
    if chargeProgress >= 1.0 then
        -- Full charge reached - auto fire
        self:FirePlasma()
    end
end

function ENT:UpdateReloading()
    if self:GetAmmo() > 0 then return end
    
    if self.lastReloadTime == 0 then
        self.lastReloadTime = CurTime()
        self:SetWeaponStatus("Reloading plasma cells...")
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

function ENT:FirePlasma()
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
    
    -- Calculate damage based on charge level and temperature
    local chargeMultiplier = math.max(0.5, self:GetChargeLevel() / 100)
    local tempMultiplier = self:GetPlasmaTemp() / 2000 -- Base temp is 2000
    local actualDamage = self.weapon.damage * chargeMultiplier * tempMultiplier
    
    -- Consume ammo and energy
    self:SetAmmo(self:GetAmmo() - 1)
    self.weapon.ammo = self:GetAmmo()
    
    local energyCost = self.weapon.energyCost * chargeMultiplier
    if self.weapon.shipCore and HYPERDRIVE.SB3Resources then
        HYPERDRIVE.SB3Resources.ConsumeResource(self.weapon.shipCore, "energy", energyCost)
    end
    
    -- Add significant heat
    self.weapon.heat = math.min(self:GetMaxHeat(), self.weapon.heat + 30)
    if self.weapon.heat >= self:GetMaxHeat() then
        self.weapon.overheated = true
        self:SetWeaponStatus("OVERHEATED - Cooling down")
        
        -- Notify clients of overheat
        net.Start("HyperdrivePlaymaOverheat")
        net.WriteEntity(self)
        net.Broadcast()
        
        timer.Simple(6, function()
            if IsValid(self) then
                self.weapon.overheated = false
                self.weapon.heat = 0
                self:SetWeaponStatus("Cooling complete")
            end
        end)
    end
    
    -- Create plasma bolt
    self:CreatePlasmaBolt(actualDamage, chargeMultiplier, tempMultiplier)
    
    -- Stop charging
    self:StopCharging()
    
    self:SetWeaponStatus("Plasma fired - " .. self:GetAmmo() .. " cells remaining")
    
    -- Notify clients
    net.Start("HyperdrivePlasmaFire")
    net.WriteEntity(self)
    net.WriteFloat(chargeMultiplier)
    net.WriteFloat(tempMultiplier)
    net.WriteVector(self.weapon.target and self.weapon.target:GetPos() or Vector(0,0,0))
    net.Broadcast()
    
    self.weapon.lastFireTime = CurTime()
    return true
end

function ENT:CreatePlasmaBolt(damage, chargeMultiplier, tempMultiplier)
    local bolt = ents.Create("hyperdrive_plasma_bolt")
    if IsValid(bolt) then
        local pos = self:GetPos() + self:GetForward() * 40
        bolt:SetPos(pos)
        bolt:SetAngles(self:GetAngles())
        bolt:Spawn()
        
        -- Set bolt properties
        bolt:SetWeapon(self.weapon)
        bolt:SetTarget(self.weapon.target)
        bolt:SetDamage(damage)
        bolt:SetSpeed(self.weapon.projectileSpeed * chargeMultiplier)
        bolt:SetSplashRadius(self:GetSplashRadius())
        bolt:SetPlasmaTemp(self:GetPlasmaTemp())
        bolt:SetChargeLevel(chargeMultiplier)
        
        print("[Hyperdrive Plasma] Bolt fired with " .. math.floor(damage) .. " damage")
    end
end

function ENT:TriggerInput(iname, value)
    if not self.weapon then return end
    
    if iname == "Fire" and value > 0 then
        if self:GetCharging() then
            self:FirePlasma()
        else
            self:StartCharging()
        end
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
    elseif iname == "PlasmaTemp" and value > 0 then
        self:SetPlasmaTemp(math.Clamp(value, 1000, 5000))
    elseif iname == "SplashRadius" and value > 0 then
        self:SetSplashRadius(math.Clamp(value, 50, 500))
    end
    
    self:UpdateWireOutputs()
end

function ENT:UpdateWireOutputs()
    if not WireLib or not self.weapon then return end
    
    local energyLevel = 100 -- Default
    
    if self.weapon.shipCore and HYPERDRIVE.SB3Resources then
        energyLevel = HYPERDRIVE.SB3Resources.GetResourcePercent(self.weapon.shipCore, "energy")
    end
    
    local chargeMultiplier = math.max(0.5, self:GetChargeLevel() / 100)
    local tempMultiplier = self:GetPlasmaTemp() / 2000
    local currentDamage = self.weapon.damage * chargeMultiplier * tempMultiplier
    
    WireLib.TriggerOutput(self, "WeaponActive", self:GetWeaponActive() and 1 or 0)
    WireLib.TriggerOutput(self, "TargetLocked", self:GetTargetLocked() and 1 or 0)
    WireLib.TriggerOutput(self, "Charging", self:GetCharging() and 1 or 0)
    WireLib.TriggerOutput(self, "ChargeLevel", self:GetChargeLevel())
    WireLib.TriggerOutput(self, "Ammo", self:GetAmmo())
    WireLib.TriggerOutput(self, "Heat", self:GetHeat())
    WireLib.TriggerOutput(self, "PlasmaTemp", self:GetPlasmaTemp())
    WireLib.TriggerOutput(self, "SplashRadius", self:GetSplashRadius())
    WireLib.TriggerOutput(self, "Range", self:GetRange())
    WireLib.TriggerOutput(self, "Damage", currentDamage)
    WireLib.TriggerOutput(self, "EnergyLevel", energyLevel)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Plasma Cannon] Too far away to access controls")
        return
    end
    
    activator:ChatPrint("[Plasma Cannon] Superheated Plasma System")
    activator:ChatPrint("Status: " .. self:GetWeaponStatus())
    
    if self.weapon then
        activator:ChatPrint("Charge Level: " .. self:GetChargeLevel() .. "%")
        activator:ChatPrint("Plasma Temp: " .. self:GetPlasmaTemp() .. "°C")
        activator:ChatPrint("Splash Radius: " .. self:GetSplashRadius() .. " units")
        activator:ChatPrint("Ammo: " .. self:GetAmmo() .. "/" .. self:GetMaxAmmo())
        activator:ChatPrint("Heat: " .. self:GetHeat() .. "/" .. self:GetMaxHeat())
        
        if self:GetOverheated() then
            activator:ChatPrint("Status: OVERHEATED")
        elseif self:GetCharging() then
            activator:ChatPrint("Status: CHARGING")
        elseif self:GetTargetLocked() then
            activator:ChatPrint("Target: LOCKED")
        else
            activator:ChatPrint("Target: Searching...")
        end
        
        -- Cycle plasma temperature
        local newTemp = self:GetPlasmaTemp() + 500
        if newTemp > 5000 then newTemp = 1000 end
        self:SetPlasmaTemp(newTemp)
        activator:ChatPrint("Plasma temperature set to: " .. newTemp .. "°C")
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
    
    -- Risk of overheating when damaged
    if math.random() < 0.3 then
        self.weapon.heat = math.min(self:GetMaxHeat(), self.weapon.heat + 20)
    end
    
    -- Reduce damage if shields are active
    if self.weapon and self.weapon.shipCore then
        local shieldStatus = {}
        if HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShieldStatus then
            shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(self.weapon.shipCore) or {}
        end
        
        if shieldStatus.active then
            damage = damage * 0.4 -- Shields absorb 60% of damage
        end
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Create massive plasma explosion
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetScale(6)
        util.Effect("Explosion", effectData)
        
        -- Plasma discharge
        for i = 1, 8 do
            timer.Simple(i * 0.1, function()
                if IsValid(self) then
                    local plasma = EffectData()
                    plasma:SetOrigin(self:GetPos() + VectorRand() * 150)
                    plasma:SetScale(3)
                    util.Effect("HelicopterMegaBomb", plasma)
                end
            end)
        end
        
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
    
    print("[Hyperdrive Weapons] Plasma Cannon removed")
end
