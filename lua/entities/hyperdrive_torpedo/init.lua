-- Enhanced Hyperdrive Torpedo v2.2.1
-- Guided torpedo projectile with explosive warhead

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/weapons/w_missile_closed.mdl")
    self:SetModelScale(0.8)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
    
    -- Make it look like a torpedo
    self:SetMaterial("models/props_combine/metal_combinebridge001")
    self:SetColor(Color(200, 200, 200, 255))
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(50)
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0.1)
    end
    
    -- Torpedo properties
    self.startTime = CurTime()
    self.maxLifetime = 30 -- 30 seconds max flight time
    self.hasExploded = false
    self.armingTime = 1.0 -- 1 second arming delay
    self.lastGuidanceUpdate = 0
    self.guidanceRate = 0.1 -- 10 FPS guidance updates
    self.turnRate = 2.0 -- Turning speed
    
    -- Default values
    self:SetDamage(200)
    self:SetSpeed(800)
    self:SetBlastRadius(300)
    self:SetTorpedoType(1)
    self:SetArmed(false)
    self:SetTracking(true)
    
    -- Arm torpedo after delay
    timer.Simple(self.armingTime, function()
        if IsValid(self) then
            self:SetArmed(true)
            print("[Hyperdrive Torpedo] Torpedo armed")
        end
    end)
    
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
        self:SetTracking(true)
    else
        self:SetTracking(false)
    end
end

function ENT:SetBlastRadius(radius)
    self:SetBlastRadius(radius)
end

function ENT:SetTorpedoType(torpedoType)
    self:SetTorpedoType(torpedoType)
    
    -- Adjust properties based on type
    if torpedoType == 1 then -- Standard
        self.turnRate = 2.0
        self.guidanceRate = 0.1
    elseif torpedoType == 2 then -- Heavy
        self.turnRate = 1.0
        self.guidanceRate = 0.2
    elseif torpedoType == 3 then -- Guided
        self.turnRate = 4.0
        self.guidanceRate = 0.05
    end
end

function ENT:StartMovement()
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    local direction = self:GetForward()
    local velocity = direction * self:GetSpeed()
    phys:SetVelocity(velocity)
    
    -- Create exhaust trail
    self:CreateExhaustTrail()
    
    print("[Hyperdrive Torpedo] Torpedo launched with speed " .. self:GetSpeed())
end

function ENT:CreateExhaustTrail()
    if not HYPERDRIVE.Weapons.Config.EnableProjectileTrails then return end
    
    local torpedoType = self:GetTorpedoType()
    local trailColor = Color(255, 200, 100)
    local trailWidth = 12
    
    if torpedoType == 2 then -- Heavy
        trailColor = Color(255, 150, 50)
        trailWidth = 16
    elseif torpedoType == 3 then -- Guided
        trailColor = Color(100, 200, 255)
        trailWidth = 8
    end
    
    util.SpriteTrail(self, 0, trailColor, false, trailWidth, 1, 2.0, 1 / (trailWidth + 1) * 0.5, "trails/smoke")
end

function ENT:Think()
    -- Check lifetime
    if CurTime() - self.startTime > self.maxLifetime then
        self:Explode()
        return
    end
    
    -- Update guidance
    if self:GetTracking() and CurTime() - self.lastGuidanceUpdate >= self.guidanceRate then
        self:UpdateGuidance()
        self.lastGuidanceUpdate = CurTime()
    end
    
    -- Check if we've reached our target
    local target = self:GetTarget()
    if IsValid(target) then
        local distance = self:GetPos():Distance(target:GetPos())
        if distance < 100 then -- Close enough for proximity detonation
            self:Explode()
            return
        end
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:UpdateGuidance()
    local target = self:GetTarget()
    if not IsValid(target) then return end
    
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    local myPos = self:GetPos()
    local targetPos = target:GetPos()
    local currentVel = phys:GetVelocity()
    local currentSpeed = currentVel:Length()
    
    -- Predict target position
    local targetVel = Vector(0, 0, 0)
    if target:IsPlayer() or target:IsNPC() then
        targetVel = target:GetVelocity()
    elseif IsValid(target:GetPhysicsObject()) then
        targetVel = target:GetPhysicsObject():GetVelocity()
    end
    
    local timeToTarget = myPos:Distance(targetPos) / currentSpeed
    local predictedPos = targetPos + targetVel * timeToTarget
    
    -- Calculate desired direction
    local desiredDir = (predictedPos - myPos):GetNormalized()
    local currentDir = currentVel:GetNormalized()
    
    -- Apply turning rate limit
    local turnAmount = math.min(self.turnRate * self.guidanceRate, 1.0)
    local newDir = LerpVector(turnAmount, currentDir, desiredDir):GetNormalized()
    
    -- Apply new velocity
    local newVel = newDir * currentSpeed
    phys:SetVelocity(newVel)
    
    -- Update angles to face movement direction
    self:SetAngles(newDir:Angle())
    
    -- Update target position
    self:SetTargetPos(predictedPos)
end

function ENT:PhysicsCollide(data, phys)
    if self.hasExploded then return end
    
    local hitEntity = data.HitEntity
    
    if IsValid(hitEntity) then
        self:Explode(hitEntity)
    else
        self:Explode()
    end
end

function ENT:Explode(hitEntity)
    if self.hasExploded then return end
    self.hasExploded = true
    
    local pos = self:GetPos()
    local damage = self:GetDamage()
    local blastRadius = self:GetBlastRadius()
    
    -- Only explode if armed
    if not self:GetArmed() then
        print("[Hyperdrive Torpedo] Torpedo hit but not armed - no explosion")
        self:Remove()
        return
    end
    
    print("[Hyperdrive Torpedo] Torpedo exploding with " .. damage .. " damage, " .. blastRadius .. " blast radius")
    
    -- Create explosion effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetScale(blastRadius / 100)
    effectData:SetMagnitude(damage / 50)
    util.Effect("Explosion", effectData)
    
    -- Deal blast damage
    local entities = ents.FindInSphere(pos, blastRadius)
    for _, ent in ipairs(entities) do
        if IsValid(ent) and ent ~= self then
            local distance = pos:Distance(ent:GetPos())
            local damageScale = 1 - (distance / blastRadius)
            local actualDamage = damage * damageScale
            
            if actualDamage > 0 then
                local dmgInfo = DamageInfo()
                dmgInfo:SetDamage(actualDamage)
                dmgInfo:SetAttacker(self:GetWeapon() or self)
                dmgInfo:SetInflictor(self)
                dmgInfo:SetDamageType(DMG_BLAST)
                dmgInfo:SetDamagePosition(pos)
                dmgInfo:SetDamageForce((ent:GetPos() - pos):GetNormalized() * actualDamage * 10)
                
                ent:TakeDamageInfo(dmgInfo)
            end
        end
    end
    
    -- Create secondary effects based on torpedo type
    self:CreateSecondaryEffects()
    
    -- Explosion sound
    sound.Play("weapons/explode" .. math.random(3, 5) .. ".wav", pos, 100, 100, 1.0)
    
    self:Remove()
end

function ENT:CreateSecondaryEffects()
    local pos = self:GetPos()
    local torpedoType = self:GetTorpedoType()
    
    if torpedoType == 1 then -- Standard
        -- Standard explosion effects
        for i = 1, 5 do
            timer.Simple(i * 0.1, function()
                local secondary = EffectData()
                secondary:SetOrigin(pos + VectorRand() * 100)
                secondary:SetScale(2)
                util.Effect("Explosion", secondary)
            end)
        end
        
    elseif torpedoType == 2 then -- Heavy
        -- Massive explosion with multiple blasts
        for i = 1, 10 do
            timer.Simple(i * 0.05, function()
                local secondary = EffectData()
                secondary:SetOrigin(pos + VectorRand() * 200)
                secondary:SetScale(3)
                util.Effect("Explosion", secondary)
            end)
        end
        
        -- Shockwave effect
        timer.Simple(0.2, function()
            local shockwave = EffectData()
            shockwave:SetOrigin(pos)
            shockwave:SetScale(8)
            util.Effect("Explosion", shockwave)
        end)
        
    elseif torpedoType == 3 then -- Guided
        -- Precise explosion with energy effects
        for i = 1, 8 do
            timer.Simple(i * 0.08, function()
                local energy = EffectData()
                energy:SetOrigin(pos + VectorRand() * 80)
                energy:SetScale(1.5)
                util.Effect("BlueFlash", energy)
            end)
        end
    end
end

function ENT:OnRemove()
    -- Clean up any effects
    if self.exhaustTrail then
        self.exhaustTrail:Remove()
    end
end
