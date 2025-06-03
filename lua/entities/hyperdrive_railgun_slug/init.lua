-- Enhanced Hyperdrive Railgun Slug v2.2.1
-- High-velocity penetrating projectile

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/misc/sphere025.mdl")
    self:SetModelScale(0.05)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    
    -- Make it look like a metal slug
    self:SetMaterial("models/props_combine/metal_combinebridge001")
    self:SetColor(Color(200, 200, 255, 255))
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(0.1)
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
    end
    
    -- Slug properties
    self.startTime = CurTime()
    self.maxLifetime = 15 -- 15 seconds max flight time
    self.hasHit = false
    self.penetrationsLeft = 5
    self.hitTargets = {}
    
    -- Default values
    self:SetDamage(300)
    self:SetSpeed(2000)
    self:SetPenetrationPower(5)
    self:SetChargeLevel(1.0)
    
    -- Start movement
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:StartMovement()
        end
    end)
end

function ENT:SetWeapon(weapon)
    self:SetWeapon(weapon.entity)
    
    -- Copy weapon properties
    if weapon then
        self:SetDamage(weapon.damage)
        self:SetSpeed(weapon.projectileSpeed)
    end
end

function ENT:SetTarget(target)
    if IsValid(target) then
        self:SetTarget(target)
        self:SetTargetPos(target:GetPos())
    end
end

function ENT:SetPenetrationPower(power)
    self:SetPenetrationPower(power)
    self.penetrationsLeft = power
end

function ENT:SetChargeLevel(level)
    self:SetChargeLevel(level)
end

function ENT:StartMovement()
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    local direction = self:GetForward()
    local velocity = direction * self:GetSpeed()
    phys:SetVelocity(velocity)
    
    -- Set angles to face movement direction
    self:SetAngles(direction:Angle())
    
    -- Create electromagnetic trail
    self:CreateEMTrail()
    
    print("[Hyperdrive Railgun Slug] Slug launched at " .. self:GetSpeed() .. " units/sec")
end

function ENT:CreateEMTrail()
    if not HYPERDRIVE.Weapons.Config.EnableProjectileTrails then return end
    
    local trailColor = Color(200, 200, 255)
    local trailWidth = 4
    
    util.SpriteTrail(self, 0, trailColor, false, trailWidth, 1, 0.3, 1 / (trailWidth + 1) * 0.5, "trails/laser")
end

function ENT:Think()
    -- Check lifetime
    if CurTime() - self.startTime > self.maxLifetime then
        self:Remove()
        return
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:PhysicsCollide(data, phys)
    if self.hasHit then return end
    
    local hitEntity = data.HitEntity
    local hitPos = data.HitPos
    local hitNormal = data.HitNormal
    
    if IsValid(hitEntity) then
        self:HitTarget(hitEntity, hitPos, hitNormal)
    else
        self:HitWorld(hitPos, hitNormal)
    end
end

function ENT:HitTarget(target, hitPos, hitNormal)
    -- Check if we already hit this target
    for _, hitTarget in ipairs(self.hitTargets) do
        if hitTarget == target then
            return -- Skip duplicate hits
        end
    end
    
    table.insert(self.hitTargets, target)
    
    -- Deal damage
    local damage = self:GetDamage()
    local weapon = self:GetWeapon()
    
    if IsValid(target) and damage > 0 then
        local dmgInfo = DamageInfo()
        dmgInfo:SetDamage(damage)
        dmgInfo:SetAttacker(IsValid(weapon) and weapon or self)
        dmgInfo:SetInflictor(self)
        dmgInfo:SetDamageType(DMG_BULLET)
        dmgInfo:SetDamagePosition(hitPos)
        dmgInfo:SetDamageForce(self:GetForward() * damage * 50)
        
        target:TakeDamageInfo(dmgInfo)
        
        print("[Hyperdrive Railgun Slug] Hit " .. tostring(target) .. " for " .. damage .. " damage")
    end
    
    -- Create impact effect
    self:CreateImpactEffect(hitPos, hitNormal)
    
    -- Notify clients of penetration
    net.Start("HyperdriveRailgunPenetration")
    net.WriteEntity(self)
    net.WriteVector(hitPos)
    net.WriteVector(hitNormal)
    net.WriteEntity(target)
    net.Broadcast()
    
    -- Check penetration
    self.penetrationsLeft = self.penetrationsLeft - 1
    
    if self.penetrationsLeft <= 0 then
        -- No more penetrations left
        self:Remove()
    else
        -- Continue through target with reduced damage
        self:SetDamage(self:GetDamage() * 0.8) -- 20% damage reduction per penetration
        print("[Hyperdrive Railgun Slug] Penetrated target, " .. self.penetrationsLeft .. " penetrations remaining")
    end
end

function ENT:HitWorld(hitPos, hitNormal)
    self.hasHit = true
    
    -- Create impact effect
    self:CreateImpactEffect(hitPos, hitNormal)
    
    -- Remove slug
    self:Remove()
end

function ENT:CreateImpactEffect(pos, normal)
    if not HYPERDRIVE.Weapons.Config.EnableImpactEffects then return end
    
    -- Metal spark effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetNormal(normal)
    effectData:SetScale(2)
    effectData:SetMagnitude(1)
    util.Effect("MetalSpark", effectData)
    
    -- Penetration sparks
    for i = 1, 8 do
        local spark = EffectData()
        spark:SetOrigin(pos + VectorRand() * 20)
        spark:SetScale(0.5)
        util.Effect("Sparks", spark)
    end
    
    -- Electromagnetic discharge
    local discharge = EffectData()
    discharge:SetOrigin(pos)
    discharge:SetScale(1.5)
    util.Effect("BlueFlash", discharge)
    
    -- Impact sound
    local soundFile = "weapons/fx/nearmiss/bulletLtoR" .. math.random(1, 16) .. ".wav"
    sound.Play(soundFile, pos, 75, 120, 0.8)
    
    -- Metal impact sound
    sound.Play("physics/metal/metal_solid_impact_bullet" .. math.random(1, 4) .. ".wav", pos, 70, 100, 0.6)
end

function ENT:OnRemove()
    -- Clean up any effects
    if self.emTrail then
        self.emTrail:Remove()
    end
end
