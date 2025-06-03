-- Enhanced Hyperdrive Projectile v2.2.1
-- Universal projectile for hyperdrive weapons

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/hunter/misc/sphere025.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    
    -- Make it small and glowing
    self:SetModelScale(0.1)
    self:SetMaterial("models/effects/vol_light001")
    self:SetColor(Color(100, 200, 255, 255))
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(1)
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
    end
    
    -- Projectile properties
    self.startTime = CurTime()
    self.maxLifetime = 10 -- 10 seconds max flight time
    self.hasHit = false
    self.trailEffect = nil
    
    -- Default values
    self:SetDamage(50)
    self:SetSpeed(1000)
    self:SetProjectileType("energy_pulse")
    
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
        
        local config = HYPERDRIVE.Weapons.GetWeaponConfig(weapon.weaponType)
        if config then
            self:SetProjectileType(config.projectileType or "energy_pulse")
        end
    end
end

function ENT:SetTarget(target)
    if IsValid(target) then
        self:SetTarget(target)
        self:SetTargetPos(target:GetPos())
    end
end

function ENT:StartMovement()
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    local direction
    local target = self:GetTarget()
    
    if IsValid(target) then
        -- Aim at target with prediction
        local targetPos = target:GetPos()
        local targetVel = Vector(0, 0, 0)
        
        if target:IsPlayer() or target:IsNPC() then
            targetVel = target:GetVelocity()
        elseif IsValid(target:GetPhysicsObject()) then
            targetVel = target:GetPhysicsObject():GetVelocity()
        end
        
        -- Predict target position
        local distance = self:GetPos():Distance(targetPos)
        local timeToTarget = distance / self:GetSpeed()
        local predictedPos = targetPos + targetVel * timeToTarget
        
        direction = (predictedPos - self:GetPos()):GetNormalized()
        self:SetTargetPos(predictedPos)
    else
        -- Use forward direction
        direction = self:GetForward()
    end
    
    -- Set velocity
    local velocity = direction * self:GetSpeed()
    phys:SetVelocity(velocity)
    
    -- Set angles to face movement direction
    self:SetAngles(direction:Angle())
    
    -- Create trail effect
    self:CreateTrailEffect()
end

function ENT:CreateTrailEffect()
    if not HYPERDRIVE.Weapons.Config.EnableProjectileTrails then return end
    
    local projectileType = self:GetProjectileType()
    
    if projectileType == "energy_pulse" then
        util.SpriteTrail(self, 0, Color(100, 200, 255), false, 8, 1, 0.5, 1 / (8 + 1) * 0.5, "trails/laser")
    elseif projectileType == "plasma_bolt" then
        util.SpriteTrail(self, 0, Color(255, 150, 100), false, 12, 1, 0.8, 1 / (12 + 1) * 0.5, "trails/plasma")
    elseif projectileType == "torpedo" then
        util.SpriteTrail(self, 0, Color(255, 255, 100), false, 16, 1, 1.0, 1 / (16 + 1) * 0.5, "trails/smoke")
    elseif projectileType == "railgun_slug" then
        util.SpriteTrail(self, 0, Color(200, 200, 255), false, 4, 1, 0.3, 1 / (4 + 1) * 0.5, "trails/laser")
    end
end

function ENT:Think()
    -- Check lifetime
    if CurTime() - self.startTime > self.maxLifetime then
        self:Explode()
        return
    end
    
    -- Check if we've hit our target
    local target = self:GetTarget()
    if IsValid(target) then
        local distance = self:GetPos():Distance(target:GetPos())
        if distance < 50 then -- Close enough
            self:HitTarget(target)
            return
        end
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:PhysicsCollide(data, phys)
    if self.hasHit then return end
    
    local hitEntity = data.HitEntity
    
    if IsValid(hitEntity) then
        self:HitTarget(hitEntity)
    else
        self:Explode()
    end
end

function ENT:HitTarget(target)
    if self.hasHit then return end
    self.hasHit = true
    
    -- Deal damage
    local damage = self:GetDamage()
    local weapon = self:GetWeapon()
    
    if IsValid(target) and damage > 0 then
        local dmgInfo = DamageInfo()
        dmgInfo:SetDamage(damage)
        dmgInfo:SetAttacker(IsValid(weapon) and weapon or self)
        dmgInfo:SetInflictor(self)
        dmgInfo:SetDamageType(DMG_ENERGYBEAM)
        dmgInfo:SetDamagePosition(self:GetPos())
        
        target:TakeDamageInfo(dmgInfo)
        
        print("[Hyperdrive Projectile] Hit " .. tostring(target) .. " for " .. damage .. " damage")
    end
    
    -- Create impact effect
    self:CreateImpactEffect(target)
    
    -- Remove projectile
    self:Remove()
end

function ENT:CreateImpactEffect(target)
    if not HYPERDRIVE.Weapons.Config.EnableImpactEffects then return end
    
    local pos = self:GetPos()
    local projectileType = self:GetProjectileType()
    
    -- Impact effect based on projectile type
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetScale(2)
    effectData:SetMagnitude(1)
    
    if projectileType == "energy_pulse" then
        effectData:SetScale(1.5)
        util.Effect("BlueFlash", effectData)
        
        -- Electric sparks
        for i = 1, 5 do
            local spark = EffectData()
            spark:SetOrigin(pos + VectorRand() * 20)
            spark:SetScale(0.5)
            util.Effect("Sparks", spark)
        end
        
    elseif projectileType == "plasma_bolt" then
        effectData:SetScale(2)
        util.Effect("Explosion", effectData)
        
        -- Plasma burn effect
        local burn = EffectData()
        burn:SetOrigin(pos)
        burn:SetScale(1)
        util.Effect("HelicopterMegaBomb", burn)
        
    elseif projectileType == "torpedo" then
        effectData:SetScale(4)
        util.Effect("Explosion", effectData)
        
        -- Secondary explosions
        for i = 1, 3 do
            timer.Simple(i * 0.1, function()
                local secondary = EffectData()
                secondary:SetOrigin(pos + VectorRand() * 50)
                secondary:SetScale(2)
                util.Effect("Explosion", secondary)
            end)
        end
        
    elseif projectileType == "railgun_slug" then
        effectData:SetScale(1)
        util.Effect("MetalSpark", effectData)
        
        -- Penetration sparks
        for i = 1, 10 do
            local spark = EffectData()
            spark:SetOrigin(pos + VectorRand() * 30)
            spark:SetScale(0.3)
            util.Effect("Sparks", spark)
        end
    end
    
    -- Impact sound
    local soundFile = "weapons/fx/nearmiss/bulletLtoR" .. math.random(1, 16) .. ".wav"
    sound.Play(soundFile, pos, 75, 100, 0.8)
end

function ENT:Explode()
    if self.hasHit then return end
    self.hasHit = true
    
    -- Create explosion effect
    local effectData = EffectData()
    effectData:SetOrigin(self:GetPos())
    effectData:SetScale(1)
    util.Effect("Explosion", effectData)
    
    self:Remove()
end

function ENT:OnRemove()
    -- Clean up any effects
    if self.trailEffect then
        self.trailEffect:Remove()
    end
end
