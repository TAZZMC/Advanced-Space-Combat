-- Enhanced Hyperdrive Torpedo Launcher v2.2.1
-- Ship-integrated heavy torpedo launcher with guided projectiles

print("[Hyperdrive Weapons] Torpedo Launcher v2.2.1 - Entity loading...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Use centralized model manager
    if ASC and ASC.Models and ASC.Models.GetModel then
        self:SetModel(ASC.Models.GetModel("torpedo_launcher"))
    else
        -- Fallback if model manager not loaded yet
        self:SetModel("models/props_combine/combine_mine01.mdl")
        print("[Hyperdrive Torpedo Launcher] Model manager not available, using direct fallback")
    end

    self:SetModelScale(1.5)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
    end

    -- Weapon properties
    self:SetMaxHealth(1000)
    self:SetHealth(1000)
    
    -- Initialize weapon system
    self.weapon = nil
    self.lastTargetUpdate = 0
    self.targetUpdateRate = 0.2 -- 5 FPS targeting for torpedo launcher
    self.lockStartTime = 0
    self.lockDuration = 2.0 -- 2 seconds to lock
    self.reloadStartTime = 0
    self.torpedoTypes = {
        [1] = {name = "Standard", damage = 200, speed = 800, blast = 300},
        [2] = {name = "Heavy", damage = 400, speed = 600, blast = 500},
        [3] = {name = "Guided", damage = 150, speed = 1000, blast = 200}
    }
    
    -- Initialize network variables
    self:SetWeaponActive(false)
    self:SetAutoTarget(true)
    self:SetTargetLocked(false)
    self:SetReloading(false)
    self:SetAmmo(6)
    self:SetMaxAmmo(6)
    self:SetTorpedoType(1)
    self:SetRange(3000)
    self:SetReloadTime(3.0)
    self:SetLockTime(2.0)
    self:SetWeaponStatus("Initializing...")

    -- Wire integration
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "Fire",
            "SetTarget",
            "AutoTarget",
            "Activate",
            "Deactivate",
            "TorpedoType",
            "Reload"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "WeaponActive",
            "TargetLocked",
            "Ammo",
            "MaxAmmo",
            "Reloading",
            "Range",
            "Damage",
            "EnergyLevel",
            "LockProgress"
        })
    end

    -- Initialize weapon after short delay
    timer.Simple(1, function()
        if IsValid(self) then
            self:InitializeWeapon()
        end
    end)

    print("[Hyperdrive Weapons] Torpedo Launcher initialized")
end

function ENT:InitializeWeapon()
    if not HYPERDRIVE.Weapons then
        self:SetWeaponStatus("Weapons system not loaded")
        return
    end

    -- Create weapon instance
    self.weapon = HYPERDRIVE.Weapons.WeaponClass:New(self, "hyperdrive_torpedo_launcher")
    self.weapon:Initialize()
    
    -- Override torpedo-specific properties
    self.weapon.fireRate = 0.5 -- 0.5 shots per second
    self.weapon.energyCost = 50
    self.weapon.damage = 200
    self.weapon.ammo = 6
    
    -- Update network variables
    self:SetRange(self.weapon.range)
    self:SetMaxAmmo(self.weapon.ammo)
    self:SetAmmo(self.weapon.ammo)
    self:SetShipCore(self.weapon.shipCore)
    
    if self.weapon.shipCore then
        self:SetWeaponStatus("Ready - Torpedoes loaded")
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
    
    -- Update targeting and locking
    if CurTime() - self.lastTargetUpdate >= self.targetUpdateRate then
        self:UpdateTargeting()
        self.lastTargetUpdate = CurTime()
    end
    
    -- Handle target locking
    self:UpdateTargetLocking()
    
    -- Handle reloading
    self:UpdateReloading()
    
    -- Update wire outputs
    self:UpdateWireOutputs()
    
    self:NextThink(CurTime() + 0.2) -- 5 FPS for torpedo launcher
    return true
end

function ENT:UpdateTargeting()
    if not self.weapon or not self:GetAutoTarget() then return end
    
    self.weapon:UpdateTargeting()
    
    -- Start locking process if new target found
    if self.weapon.target and not self:GetTargetLocked() and self.lockStartTime == 0 then
        self.lockStartTime = CurTime()
        self:SetWeaponStatus("Locking target...")
        
        -- Notify clients
        net.Start("HyperdriveTorpedoLock")
        net.WriteEntity(self)
        net.WriteEntity(self.weapon.target)
        net.WriteBool(true) -- Start lock
        net.Broadcast()
    end
    
    -- Clear lock if target lost
    if not self.weapon.target and self.lockStartTime > 0 then
        self.lockStartTime = 0
        self:SetTargetLocked(false)
        self:SetWeaponStatus("Target lost")
        
        -- Notify clients
        net.Start("HyperdriveTorpedoLock")
        net.WriteEntity(self)
        net.WriteEntity(NULL)
        net.WriteBool(false) -- Stop lock
        net.Broadcast()
    end
    
    -- Update network variables
    self:SetTarget(self.weapon.target)
end

function ENT:UpdateTargetLocking()
    if self.lockStartTime == 0 then return end
    
    local lockProgress = (CurTime() - self.lockStartTime) / self.lockDuration
    
    if lockProgress >= 1.0 then
        -- Lock complete
        self:SetTargetLocked(true)
        self:SetWeaponStatus("Target locked - Ready to fire")
        
        -- Auto fire if target locked and ammo available
        if self:GetAutoTarget() and self:GetAmmo() > 0 and not self:GetReloading() then
            self:FireTorpedo()
        end
    end
end

function ENT:UpdateReloading()
    if not self:GetReloading() then return end
    
    local reloadProgress = (CurTime() - self.reloadStartTime) / self:GetReloadTime()
    
    if reloadProgress >= 1.0 then
        -- Reload complete
        self:SetReloading(false)
        self:SetAmmo(self:GetMaxAmmo())
        self.weapon.ammo = self:GetMaxAmmo()
        self:SetWeaponStatus("Reload complete - Ready")
        
        -- Notify clients
        net.Start("HyperdriveTorpedoReload")
        net.WriteEntity(self)
        net.WriteBool(false) -- Reload complete
        net.Broadcast()
    end
end

function ENT:FireTorpedo(target)
    if not self.weapon then return false end
    
    target = target or self.weapon.target
    
    -- Check if we can fire
    if self:GetAmmo() <= 0 then
        self:StartReload()
        return false
    end
    
    if self:GetReloading() then
        return false, "Reloading"
    end
    
    local canFire, reason = self.weapon:CanFire()
    if not canFire then
        self:SetWeaponStatus(reason or "Cannot fire")
        return false
    end
    
    -- Consume ammo and energy
    self:SetAmmo(self:GetAmmo() - 1)
    self.weapon.ammo = self:GetAmmo()
    
    if self.weapon.shipCore and HYPERDRIVE.SB3Resources then
        HYPERDRIVE.SB3Resources.ConsumeResource(self.weapon.shipCore, "energy", self.weapon.energyCost)
    end
    
    -- Create torpedo projectile
    self:CreateTorpedo(target)
    
    -- Reset lock for next target
    self.lockStartTime = 0
    self:SetTargetLocked(false)
    
    -- Start reload if out of ammo
    if self:GetAmmo() <= 0 then
        self:StartReload()
    else
        self:SetWeaponStatus("Torpedo fired - " .. self:GetAmmo() .. " remaining")
    end
    
    -- Notify clients
    net.Start("HyperdriveTorpedoFire")
    net.WriteEntity(self)
    net.WriteVector(target and target:GetPos() or Vector(0,0,0))
    net.WriteInt(self:GetTorpedoType(), 8)
    net.Broadcast()
    
    self.weapon.lastFireTime = CurTime()
    return true
end

function ENT:CreateTorpedo(target)
    local torpedo = ents.Create("hyperdrive_torpedo")
    if IsValid(torpedo) then
        local pos = self:GetPos() + self:GetForward() * 60 + self:GetUp() * 10
        torpedo:SetPos(pos)
        torpedo:SetAngles(self:GetAngles())
        torpedo:Spawn()
        
        -- Set torpedo properties
        local torpedoData = self.torpedoTypes[self:GetTorpedoType()]
        torpedo:SetWeapon(self.weapon)
        torpedo:SetTarget(target)
        torpedo:SetDamage(torpedoData.damage)
        torpedo:SetSpeed(torpedoData.speed)
        torpedo:SetBlastRadius(torpedoData.blast)
        torpedo:SetTorpedoType(self:GetTorpedoType())
        
        print("[Hyperdrive Torpedo] " .. torpedoData.name .. " torpedo launched")
    end
end

function ENT:StartReload()
    if self:GetReloading() then return end
    
    self:SetReloading(true)
    self.reloadStartTime = CurTime()
    self:SetWeaponStatus("Reloading torpedoes...")
    
    -- Notify clients
    net.Start("HyperdriveTorpedoReload")
    net.WriteEntity(self)
    net.WriteBool(true) -- Start reload
    net.Broadcast()
end

function ENT:TriggerInput(iname, value)
    if not self.weapon then return end
    
    if iname == "Fire" and value > 0 then
        self:FireTorpedo()
    elseif iname == "SetTarget" and IsValid(value) then
        self.weapon.target = value
        self:SetTarget(value)
        self.lockStartTime = CurTime() -- Start locking new target
    elseif iname == "AutoTarget" then
        self:SetAutoTarget(value > 0)
        self.weapon.autoTarget = value > 0
    elseif iname == "Activate" and value > 0 then
        self:SetWeaponActive(true)
        self.weapon.active = true
    elseif iname == "Deactivate" and value > 0 then
        self:SetWeaponActive(false)
        self.weapon.active = false
    elseif iname == "TorpedoType" and value > 0 then
        self:SetTorpedoType(math.Clamp(value, 1, 3))
    elseif iname == "Reload" and value > 0 then
        self:StartReload()
    end
    
    self:UpdateWireOutputs()
end

function ENT:UpdateWireOutputs()
    if not WireLib or not self.weapon then return end
    
    local energyLevel = 100 -- Default
    local lockProgress = 0
    
    if self.weapon.shipCore and HYPERDRIVE.SB3Resources then
        energyLevel = HYPERDRIVE.SB3Resources.GetResourcePercent(self.weapon.shipCore, "energy")
    end
    
    if self.lockStartTime > 0 then
        lockProgress = math.Clamp((CurTime() - self.lockStartTime) / self.lockDuration * 100, 0, 100)
    end
    
    local torpedoData = self.torpedoTypes[self:GetTorpedoType()]
    
    WireLib.TriggerOutput(self, "WeaponActive", self:GetWeaponActive() and 1 or 0)
    WireLib.TriggerOutput(self, "TargetLocked", self:GetTargetLocked() and 1 or 0)
    WireLib.TriggerOutput(self, "Ammo", self:GetAmmo())
    WireLib.TriggerOutput(self, "MaxAmmo", self:GetMaxAmmo())
    WireLib.TriggerOutput(self, "Reloading", self:GetReloading() and 1 or 0)
    WireLib.TriggerOutput(self, "Range", self:GetRange())
    WireLib.TriggerOutput(self, "Damage", torpedoData.damage)
    WireLib.TriggerOutput(self, "EnergyLevel", energyLevel)
    WireLib.TriggerOutput(self, "LockProgress", lockProgress)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Torpedo Launcher] Too far away to access controls")
        return
    end
    
    activator:ChatPrint("[Torpedo Launcher] Heavy Torpedo System")
    activator:ChatPrint("Status: " .. self:GetWeaponStatus())
    
    if self.weapon then
        local torpedoData = self.torpedoTypes[self:GetTorpedoType()]
        activator:ChatPrint("Torpedo Type: " .. torpedoData.name)
        activator:ChatPrint("Damage: " .. torpedoData.damage)
        activator:ChatPrint("Speed: " .. torpedoData.speed)
        activator:ChatPrint("Blast Radius: " .. torpedoData.blast)
        activator:ChatPrint("Ammo: " .. self:GetAmmo() .. "/" .. self:GetMaxAmmo())
        activator:ChatPrint("Range: " .. self.weapon.range)
        
        if self:GetReloading() then
            local reloadProgress = (CurTime() - self.reloadStartTime) / self:GetReloadTime() * 100
            activator:ChatPrint("Reloading: " .. math.floor(reloadProgress) .. "%")
        elseif self:GetTargetLocked() then
            activator:ChatPrint("Target: LOCKED")
        elseif self.lockStartTime > 0 then
            local lockProgress = (CurTime() - self.lockStartTime) / self.lockDuration * 100
            activator:ChatPrint("Locking: " .. math.floor(lockProgress) .. "%")
        else
            activator:ChatPrint("Target: Searching...")
        end
        
        -- Cycle torpedo type
        local newType = self:GetTorpedoType() + 1
        if newType > 3 then newType = 1 end
        self:SetTorpedoType(newType)
        activator:ChatPrint("Torpedo type changed to: " .. self.torpedoTypes[newType].name)
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
            damage = damage * 0.4 -- Shields absorb 60% of damage
        end
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Create massive explosion effect
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetScale(5)
        util.Effect("Explosion", effectData)
        
        -- Secondary explosions from remaining torpedoes
        for i = 1, self:GetAmmo() do
            timer.Simple(i * 0.2, function()
                if IsValid(self) then
                    local secondary = EffectData()
                    secondary:SetOrigin(self:GetPos() + VectorRand() * 100)
                    secondary:SetScale(3)
                    util.Effect("Explosion", secondary)
                end
            end)
        end
        
        self:Remove()
    end
end

function ENT:OnRemove()
    if self.weapon then
        HYPERDRIVE.Weapons.UnregisterWeapon(self:EntIndex())
    end
    
    if WireLib then
        Wire_Remove(self)
    end
    
    print("[Hyperdrive Weapons] Torpedo Launcher removed")
end
