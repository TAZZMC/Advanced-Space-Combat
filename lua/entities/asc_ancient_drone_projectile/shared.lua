-- Advanced Space Combat - Ancient Drone Projectile Shared
-- Shared definitions for Ancient drone weapon projectiles

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Ancient Drone"
ENT.Author = "Advanced Space Combat Team"
ENT.Contact = ""
ENT.Purpose = "Ancient technology guided projectile"
ENT.Instructions = "Autonomous guided weapon with adaptive targeting"

ENT.Spawnable = false
ENT.AdminSpawnable = false
ENT.Category = "Advanced Space Combat - Ancient"

ENT.RenderGroup = RENDERGROUP_BOTH

-- Drone specifications
ENT.MaxSpeed = 800
ENT.Acceleration = 400
ENT.TurnRate = 180
ENT.Damage = 150
ENT.BlastRadius = 100
ENT.LifeTime = 15
ENT.TrackingRange = 2000
ENT.LockOnTime = 0.5

-- Ancient technology properties
ENT.TechnologyTier = 10
ENT.TechnologyCulture = "Ancient"
ENT.EnergySignature = "Ancient_Drone"

function ENT:SetupDataTables()
    self:NetworkVar("Entity", 0, "Target")
    self:NetworkVar("Entity", 1, "Owner")
    self:NetworkVar("Vector", 0, "TargetPos")
    self:NetworkVar("Float", 0, "LaunchTime")
    self:NetworkVar("Float", 1, "LockOnProgress")
    self:NetworkVar("Bool", 0, "HasTarget")
    self:NetworkVar("Bool", 1, "IsTracking")
    self:NetworkVar("Int", 0, "DroneID")
end

-- Drone states
ENT.STATE_SEEKING = 1
ENT.STATE_TRACKING = 2
ENT.STATE_INTERCEPTING = 3
ENT.STATE_EXPLODING = 4

-- Get current drone state
function ENT:GetDroneState()
    if not self:GetHasTarget() then
        return self.STATE_SEEKING
    elseif self:GetLockOnProgress() < 1 then
        return self.STATE_TRACKING
    else
        return self.STATE_INTERCEPTING
    end
end

-- Check if target is valid
function ENT:IsValidTarget(target)
    if not IsValid(target) then return false end
    
    -- Don't target the owner or friendly entities
    if target == self:GetOwner() then return false end
    
    -- Check if target is in range
    local distance = self:GetPos():Distance(target:GetPos())
    if distance > self.TrackingRange then return false end
    
    -- Check line of sight
    local trace = util.TraceLine({
        start = self:GetPos(),
        endpos = target:GetPos(),
        filter = {self, self:GetOwner()}
    })
    
    if trace.Hit and trace.Entity ~= target then return false end
    
    return true
end

-- Get damage multiplier based on target type
function ENT:GetDamageMultiplier(target)
    if not IsValid(target) then return 1 end
    
    -- Ancient drones are more effective against certain targets
    local class = target:GetClass()
    
    if string.find(class, "ship_core") then
        return 0.5 -- Reduced damage to ship cores
    elseif string.find(class, "shield") then
        return 1.5 -- Increased damage to shields
    elseif target:IsPlayer() then
        return 0.3 -- Reduced damage to players
    elseif target:IsNPC() then
        return 1.2 -- Increased damage to NPCs
    end
    
    return 1
end

-- Calculate intercept course
function ENT:CalculateInterceptCourse(target)
    if not IsValid(target) then return self:GetAngles():Forward() end
    
    local targetPos = target:GetPos()
    local targetVel = target:GetVelocity()
    local dronePos = self:GetPos()
    local droneSpeed = self.MaxSpeed
    
    -- Predict target position
    local timeToIntercept = dronePos:Distance(targetPos) / droneSpeed
    local predictedPos = targetPos + targetVel * timeToIntercept
    
    -- Calculate direction to intercept point
    local direction = (predictedPos - dronePos):GetNormalized()
    
    return direction
end

-- Get visual effect color based on state
function ENT:GetEffectColor()
    local state = self:GetDroneState()
    
    if state == self.STATE_SEEKING then
        return Color(100, 150, 255) -- Blue for seeking
    elseif state == self.STATE_TRACKING then
        return Color(255, 255, 100) -- Yellow for tracking
    elseif state == self.STATE_INTERCEPTING then
        return Color(255, 100, 100) -- Red for intercepting
    else
        return Color(255, 255, 255) -- White default
    end
end

-- Get engine thrust level
function ENT:GetThrustLevel()
    local velocity = self:GetVelocity()
    local speed = velocity:Length()
    
    return math.min(1, speed / self.MaxSpeed)
end
