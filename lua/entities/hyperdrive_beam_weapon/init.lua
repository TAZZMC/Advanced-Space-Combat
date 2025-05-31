-- Enhanced Hyperdrive Beam Weapon v2.2.1
-- Ship-integrated continuous energy beam weapon

print("[Hyperdrive Weapons] Beam Weapon v2.2.1 - Entity loading...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_interface001.mdl")
    self:PhysicsInit(SOLID_VBBOX)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VBBOX)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Weapon properties
    self:SetMaxHealth(750)
    self:SetHealth(750)
    
    -- Initialize weapon system
    self.weapon = nil
    self.lastTargetUpdate = 0
    self.targetUpdateRate = 0.05 -- 20 FPS targeting for beam weapons
    self.beamActive = false
    self.beamStartTime = 0
    self.lastEnergyDrain = 0
    self.energyDrainRate = 0.1 -- 10 FPS energy drain
    
    -- Initialize network variables
    self:SetWeaponActive(false)
    self:SetAutoTarget(true)
    self:SetTargetLocked(false)
    self:SetBeamFiring(false)
    self:SetOverheated(false)
    self:SetHeat(0)
    self:SetMaxHeat(150)
    self:SetBeamPower(50)
    self:SetRange(2500)
    self:SetBeamDamage(5) -- Damage per tick
    self:SetWeaponStatus("Initializing...")

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "Fire",
            "StopFire",
            "SetTarget",
            "AutoTarget",
            "Activate",
            "Deactivate",
            "BeamPower"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "WeaponActive",
            "TargetLocked",
            "BeamFiring",
            "Heat",
            "BeamPower",
            "Range",
            "DamagePerTick",
            "EnergyLevel",
            "Overheated"
        })
    end

    -- Initialize weapon after short delay
    timer.Simple(1, function()
        if IsValid(self) then
            self:InitializeWeapon()
        end
    end)

    print("[Hyperdrive Weapons] Beam Weapon initialized")
end

function ENT:InitializeWeapon()
    if not HYPERDRIVE.Weapons then
        self:SetWeaponStatus("Weapons system not loaded")
        return
    end

    -- Create weapon instance
    self.weapon = HYPERDRIVE.Weapons.WeaponClass:New(self, "hyperdrive_beam_weapon")
    self.weapon:Initialize()
    
    -- Override beam-specific properties
    self.weapon.fireRate = 20.0 -- 20 ticks per second for beam
    self.weapon.energyCost = 5 -- Per tick
    self.weapon.damage = 5 -- Per tick
    
    -- Update network variables
    self:SetRange(self.weapon.range)
    self:SetBeamDamage(self.weapon.damage)
    self:SetMaxHeat(self.weapon.maxHeat)
    self:SetShipCore(self.weapon.shipCore)
    
    if self.weapon.shipCore then
        self:SetWeaponStatus("Ready - Beam weapon online")
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
    
    -- Handle beam firing
    if self.beamActive then
        self:UpdateBeamFiring()
    end
    
    -- Update heat dissipation
    if self.weapon.heat > 0 and not self.weapon.overheated then
        local coolingRate = self.beamActive and 1 or 3 -- Slower cooling while firing
        self.weapon.heat = math.max(0, self.weapon.heat - coolingRate)
        self:SetHeat(self.weapon.heat)
    end
    
    -- Update overheated status
    self:SetOverheated(self.weapon.overheated)
    
    -- Update wire outputs
    self:UpdateWireOutputs()
    
    self:NextThink(CurTime() + 0.05) -- 20 FPS for beam weapons
    return true
end

function ENT:UpdateTargeting()
    if not self.weapon or not self:GetAutoTarget() then return end
    
    self.weapon:UpdateTargeting()
    
    -- Update network variables
    self:SetTarget(self.weapon.target)
    self:SetTargetLocked(self.weapon.targetLock)
    
    -- Auto fire if target locked and not overheated
    if self.weapon.targetLock and self.weapon.target and not self.weapon.overheated then
        if not self.beamActive then
            self:StartBeamFiring()
        end
    else
        if self.beamActive then
            self:StopBeamFiring()
        end
    end
end

function ENT:StartBeamFiring()
    if self.beamActive or not self.weapon then return end
    
    local canFire, reason = self.weapon:CanFire()
    if not canFire then
        self:SetWeaponStatus(reason or "Cannot fire")
        return
    end
    
    self.beamActive = true
    self.beamStartTime = CurTime()
    self:SetBeamFiring(true)
    self:SetWeaponStatus("Beam firing")
    
    -- Notify clients to start beam effect
    net.Start("HyperdriveBeamFire")
    net.WriteEntity(self)
    net.WriteEntity(self.weapon.target or NULL)
    net.Broadcast()
    
    print("[Hyperdrive Beam] Beam firing started")
end

function ENT:StopBeamFiring()
    if not self.beamActive then return end
    
    self.beamActive = false
    self:SetBeamFiring(false)
    self:SetWeaponStatus("Beam stopped")
    
    -- Notify clients to stop beam effect
    net.Start("HyperdriveBeamStop")
    net.WriteEntity(self)
    net.Broadcast()
    
    print("[Hyperdrive Beam] Beam firing stopped")
end

function ENT:UpdateBeamFiring()
    if not self.beamActive or not self.weapon then return end
    
    -- Check if we can continue firing
    local canFire, reason = self.weapon:CanFire()
    if not canFire then
        self:StopBeamFiring()
        return
    end
    
    -- Check if target is still valid and in range
    local target = self.weapon.target
    if not IsValid(target) then
        self:StopBeamFiring()
        return
    end
    
    local distance = self:GetPos():Distance(target:GetPos())
    if distance > self.weapon.range then
        self:StopBeamFiring()
        return
    end
    
    -- Drain energy and add heat
    if CurTime() - self.lastEnergyDrain >= self.energyDrainRate then
        -- Consume energy
        if self.weapon.shipCore and HYPERDRIVE.SB3Resources then
            local consumed = HYPERDRIVE.SB3Resources.ConsumeResource(self.weapon.shipCore, "energy", self.weapon.energyCost)
            if not consumed then
                self:StopBeamFiring()
                return
            end
        end
        
        -- Add heat
        self.weapon.heat = math.min(self.weapon.maxHeat, self.weapon.heat + 8)
        if self.weapon.heat >= self.weapon.maxHeat then
            self.weapon.overheated = true
            self:StopBeamFiring()
            timer.Simple(5, function()
                if IsValid(self) then
                    self.weapon.overheated = false
                    self.weapon.heat = 0
                end
            end)
        end
        
        -- Deal damage
        self:DealBeamDamage(target)
        
        self.lastEnergyDrain = CurTime()
    end
    
    -- Update beam end position
    self:SetBeamEnd(target:GetPos())
end

function ENT:DealBeamDamage(target)
    if not IsValid(target) then return end
    
    local damage = self.weapon.damage
    
    local dmgInfo = DamageInfo()
    dmgInfo:SetDamage(damage)
    dmgInfo:SetAttacker(self)
    dmgInfo:SetInflictor(self)
    dmgInfo:SetDamageType(DMG_ENERGYBEAM)
    dmgInfo:SetDamagePosition(target:GetPos())
    
    target:TakeDamageInfo(dmgInfo)
    
    -- Notify clients of hit effect
    net.Start("HyperdriveBeamHit")
    net.WriteEntity(self)
    net.WriteVector(target:GetPos())
    net.Broadcast()
end

function ENT:TriggerInput(iname, value)
    if not self.weapon then return end
    
    if iname == "Fire" and value > 0 then
        self:StartBeamFiring()
    elseif iname == "StopFire" and value > 0 then
        self:StopBeamFiring()
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
        self:StopBeamFiring()
    elseif iname == "BeamPower" and value > 0 then
        self:SetBeamPower(math.Clamp(value, 10, 100))
        self.weapon.damage = self:GetBeamPower() * 0.1 -- Scale damage with power
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
    WireLib.TriggerOutput(self, "BeamFiring", self:GetBeamFiring() and 1 or 0)
    WireLib.TriggerOutput(self, "Heat", self:GetHeat())
    WireLib.TriggerOutput(self, "BeamPower", self:GetBeamPower())
    WireLib.TriggerOutput(self, "Range", self:GetRange())
    WireLib.TriggerOutput(self, "DamagePerTick", self:GetBeamDamage())
    WireLib.TriggerOutput(self, "EnergyLevel", energyLevel)
    WireLib.TriggerOutput(self, "Overheated", self:GetOverheated() and 1 or 0)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Beam Weapon] Too far away to access controls")
        return
    end
    
    activator:ChatPrint("[Beam Weapon] Continuous Energy Beam Control")
    activator:ChatPrint("Status: " .. self:GetWeaponStatus())
    
    if self.weapon then
        activator:ChatPrint("Beam Power: " .. self:GetBeamPower() .. "%")
        activator:ChatPrint("Damage/Tick: " .. self:GetBeamDamage())
        activator:ChatPrint("Range: " .. self.weapon.range)
        activator:ChatPrint("Heat: " .. self:GetHeat() .. "/" .. self:GetMaxHeat())
        
        if self:GetBeamFiring() then
            activator:ChatPrint("Beam: FIRING")
        elseif self:GetTargetLocked() then
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
    
    -- Stop beam if taking damage
    if self.beamActive then
        self:StopBeamFiring()
    end
    
    -- Reduce damage if shields are active
    if self.weapon and self.weapon.shipCore then
        local shieldStatus = {}
        if HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShieldStatus then
            shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(self.weapon.shipCore) or {}
        end
        
        if shieldStatus.active then
            damage = damage * 0.2 -- Shields absorb 80% of damage for beam weapons
        end
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Create explosion effect
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetScale(3)
        util.Effect("Explosion", effectData)
        
        self:Remove()
    end
end

function ENT:OnRemove()
    self:StopBeamFiring()
    
    if self.weapon then
        HYPERDRIVE.Weapons.UnregisterWeapon(self:EntIndex())
    end
    
    if WireLib then
        Wire_Remove(self)
    end
    
    print("[Hyperdrive Weapons] Beam Weapon removed")
end
