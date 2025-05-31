-- Advanced Space Combat - Ancient Drone Projectile (Server)
-- Self-guided energy projectile with adaptive targeting

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/asc/ancient_drone_projectile.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(1)
        phys:EnableGravity(false)
        phys:SetDragCoefficient(0)
    end
    
    -- Initialize drone properties
    self:SetNWInt("Damage", 1000)
    self:SetNWBool("ShieldPenetration", true)
    self:SetNWBool("AdaptiveTargeting", true)
    
    -- Drone behavior
    self.Speed = 800
    self.TurnRate = 5
    self.MaxLifetime = 30
    self.StartTime = CurTime()
    self.Target = NULL
    self.Weapon = NULL
    self.LastTargetPos = Vector(0, 0, 0)
    self.PredictedPos = Vector(0, 0, 0)
    
    -- Adaptive targeting
    self.TargetVelocity = Vector(0, 0, 0)
    self.LastTargetUpdate = 0
    self.TargetHistory = {}
    
    -- Start guidance system
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:StartGuidance()
        end
    end)
end

function ENT:StartGuidance()
    self.Target = self:GetNWEntity("Target", NULL)
    self.Weapon = self:GetNWEntity("Weapon", NULL)
    
    if not IsValid(self.Target) then
        self:Remove()
        return
    end
    
    -- Start guidance timer
    timer.Create("DroneGuidance_" .. self:EntIndex(), 0.05, 0, function()
        if IsValid(self) then
            self:UpdateGuidance()
        end
    end)
end

function ENT:UpdateGuidance()
    if not IsValid(self.Target) then
        self:Explode()
        return
    end
    
    -- Check lifetime
    if CurTime() - self.StartTime > self.MaxLifetime then
        self:Remove()
        return
    end
    
    -- Update target tracking
    self:UpdateTargetTracking()
    
    -- Calculate intercept course
    local interceptPos = self:CalculateInterceptCourse()
    
    -- Apply guidance
    self:ApplyGuidance(interceptPos)
    
    -- Check for impact
    self:CheckImpact()
end

function ENT:UpdateTargetTracking()
    local currentPos = self.Target:GetPos()
    local currentTime = CurTime()
    
    -- Calculate target velocity
    if self.LastTargetUpdate > 0 then
        local deltaTime = currentTime - self.LastTargetUpdate
        if deltaTime > 0 then
            self.TargetVelocity = (currentPos - self.LastTargetPos) / deltaTime
        end
    end
    
    -- Store target history for adaptive targeting
    if self:GetNWBool("AdaptiveTargeting", true) then
        table.insert(self.TargetHistory, {
            pos = currentPos,
            vel = self.TargetVelocity,
            time = currentTime
        })
        
        -- Keep only recent history
        if #self.TargetHistory > 10 then
            table.remove(self.TargetHistory, 1)
        end
    end
    
    self.LastTargetPos = currentPos
    self.LastTargetUpdate = currentTime
end

function ENT:CalculateInterceptCourse()
    local targetPos = self.Target:GetPos()
    local targetVel = self.TargetVelocity
    local dronePos = self:GetPos()
    local droneSpeed = self.Speed
    
    -- Basic intercept calculation
    local relativePos = targetPos - dronePos
    local distance = relativePos:Length()
    
    if distance < 50 then
        return targetPos -- Close enough, go direct
    end
    
    -- Predict target position
    local timeToIntercept = distance / droneSpeed
    local predictedPos = targetPos + targetVel * timeToIntercept
    
    -- Adaptive targeting - learn from target behavior
    if self:GetNWBool("AdaptiveTargeting", true) and #self.TargetHistory > 3 then
        predictedPos = self:AdaptivePrediction(predictedPos, timeToIntercept)
    end
    
    self.PredictedPos = predictedPos
    return predictedPos
end

function ENT:AdaptivePrediction(basicPrediction, timeToIntercept)
    -- Analyze target movement patterns
    local avgAcceleration = Vector(0, 0, 0)
    local patternCount = 0
    
    for i = 2, #self.TargetHistory do
        local prev = self.TargetHistory[i-1]
        local curr = self.TargetHistory[i]
        local deltaTime = curr.time - prev.time
        
        if deltaTime > 0 then
            local acceleration = (curr.vel - prev.vel) / deltaTime
            avgAcceleration = avgAcceleration + acceleration
            patternCount = patternCount + 1
        end
    end
    
    if patternCount > 0 then
        avgAcceleration = avgAcceleration / patternCount
        
        -- Apply learned acceleration to prediction
        local adaptedPrediction = basicPrediction + avgAcceleration * (timeToIntercept * timeToIntercept * 0.5)
        return adaptedPrediction
    end
    
    return basicPrediction
end

function ENT:ApplyGuidance(targetPos)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return end
    
    local currentPos = self:GetPos()
    local currentVel = phys:GetVelocity()
    
    -- Calculate desired direction
    local desiredDir = (targetPos - currentPos):GetNormalized()
    local currentDir = currentVel:GetNormalized()
    
    -- Apply turn rate limitation
    local turnAmount = math.min(self.TurnRate * FrameTime(), 1)
    local newDir = LerpVector(turnAmount, currentDir, desiredDir)
    
    -- Apply velocity
    local newVel = newDir * self.Speed
    phys:SetVelocity(newVel)
    
    -- Orient drone to face movement direction
    local angles = newDir:Angle()
    self:SetAngles(angles)
end

function ENT:CheckImpact()
    local trace = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos() + self:GetVelocity() * FrameTime(),
        filter = {self, self.Weapon}
    })
    
    if trace.Hit then
        if trace.Entity == self.Target then
            self:ImpactTarget(trace.Entity, trace.HitPos)
        else
            self:Explode(trace.HitPos)
        end
    end
    
    -- Check proximity to target
    if IsValid(self.Target) then
        local distance = self:GetPos():Distance(self.Target:GetPos())
        if distance < 30 then
            self:ImpactTarget(self.Target, self.Target:GetPos())
        end
    end
end

function ENT:ImpactTarget(target, hitPos)
    if not IsValid(target) then return end
    
    local damage = self:GetNWInt("Damage", 1000)
    local shieldPenetration = self:GetNWBool("ShieldPenetration", true)
    
    -- Create damage info
    local dmginfo = DamageInfo()
    dmginfo:SetDamage(damage)
    dmginfo:SetAttacker(self.Weapon or self)
    dmginfo:SetInflictor(self)
    dmginfo:SetDamageType(DMG_ENERGYBEAM)
    dmginfo:SetDamagePosition(hitPos)
    
    -- Shield penetration
    if shieldPenetration then
        dmginfo:SetDamageCustom(1) -- Custom flag for shield penetration
    end
    
    -- Apply damage
    target:TakeDamageInfo(dmginfo)
    
    -- Create impact effect
    local effectdata = EffectData()
    effectdata:SetOrigin(hitPos)
    effectdata:SetMagnitude(damage)
    effectdata:SetEntity(target)
    util.Effect("asc_ancient_drone_impact", effectdata)
    
    -- Play impact sound
    sound.Play("asc/weapons/ancient_drone_impact.wav", hitPos, 75, 100)
    
    -- Remove drone
    self:Remove()
end

function ENT:Explode(pos)
    pos = pos or self:GetPos()
    
    -- Create explosion effect
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    effectdata:SetMagnitude(200)
    util.Effect("asc_ancient_drone_explosion", effectdata)
    
    -- Play explosion sound
    sound.Play("asc/weapons/ancient_drone_explode.wav", pos, 75, 100)
    
    -- Small area damage
    util.BlastDamage(self, self.Weapon or self, pos, 100, 200)
    
    -- Remove drone
    self:Remove()
end

function ENT:OnRemove()
    -- Clean up timer
    timer.Remove("DroneGuidance_" .. self:EntIndex())
end

function ENT:PhysicsCollide(data, phys)
    local hitEnt = data.HitEntity
    
    if IsValid(hitEnt) and hitEnt == self.Target then
        self:ImpactTarget(hitEnt, data.HitPos)
    else
        self:Explode(data.HitPos)
    end
end
