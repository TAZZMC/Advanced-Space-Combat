-- Advanced Space Combat - Ancient Drone Weapon (Server)
-- Self-guided energy projectiles with adaptive targeting and swarm intelligence

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/asc/ancient_drone.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(200)
    end
    
    -- Initialize Ancient drone weapon properties
    self:SetMaxHealth(1500)
    self:SetHealth(1500)
    self:SetNWString("WeaponName", "Ancient Drone Weapon")
    self:SetNWInt("TechnologyTier", 10)
    self:SetNWString("TechnologyCulture", "Ancient")
    self:SetNWInt("Energy", 500)
    self:SetNWInt("MaxEnergy", 500)
    self:SetNWInt("Damage", 1000)
    self:SetNWInt("Range", 15000)
    self:SetNWBool("WeaponOnline", true)
    self:SetNWBool("AutoTargeting", true)
    
    -- Ancient-specific properties
    self.SwarmIntelligence = true
    self.AdaptiveTargeting = true
    self.ShieldPenetration = true
    self.DroneCount = 8
    self.ActiveDrones = {}
    self.TargetList = {}
    self.LastFire = 0
    self.FireRate = 2 -- Seconds between volleys
    
    -- Link to ship core
    self.ShipCore = nil
    timer.Simple(1, function()
        if IsValid(self) then
            self:FindShipCore()
        end
    end)
    
    -- Start targeting system
    timer.Create("AncientDrone_" .. self:EntIndex(), 0.5, 0, function()
        if IsValid(self) then
            self:UpdateTargeting()
        end
    end)
end

function ENT:FindShipCore()
    local shipCores = ents.FindByClass("ship_core")
    local closestCore = nil
    local closestDist = 2000
    
    for _, core in ipairs(shipCores) do
        local dist = self:GetPos():Distance(core:GetPos())
        if dist < closestDist then
            closestCore = core
            closestDist = dist
        end
    end
    
    if IsValid(closestCore) then
        self.ShipCore = closestCore
        self:SetNWEntity("ShipCore", closestCore)
        
        -- Add to ship's weapon list
        if closestCore.LinkedWeapons then
            table.insert(closestCore.LinkedWeapons, self)
        end
    end
end

function ENT:UpdateTargeting()
    if not self:GetNWBool("WeaponOnline", true) then return end
    if not IsValid(self.ShipCore) then return end
    
    -- Find potential targets
    local targets = {}
    local entities = ents.FindInSphere(self:GetPos(), self:GetNWInt("Range", 15000))
    
    for _, ent in ipairs(entities) do
        if self:IsValidTarget(ent) then
            table.insert(targets, ent)
        end
    end
    
    -- Sort targets by priority
    table.sort(targets, function(a, b)
        return self:GetTargetPriority(a) > self:GetTargetPriority(b)
    end)
    
    self.TargetList = targets
    
    -- Auto-fire if targets available
    if #targets > 0 and self:GetNWBool("AutoTargeting", true) then
        if CurTime() - self.LastFire > self.FireRate then
            self:FireDroneVolley(targets)
        end
    end
end

function ENT:IsValidTarget(ent)
    if not IsValid(ent) then return false end
    if ent == self or ent == self.ShipCore then return false end
    
    -- Check if it's a hostile entity
    local class = ent:GetClass()
    if ent:IsPlayer() then return false end -- Don't target players directly
    if ent:IsNPC() then return true end
    
    -- Target other ship cores and weapons
    if string.find(class, "ship_core") or string.find(class, "weapon") or string.find(class, "cannon") then
        -- Check if it belongs to a different ship
        local entShipCore = ent:GetNWEntity("ShipCore", NULL)
        if IsValid(entShipCore) and entShipCore ~= self.ShipCore then
            return true
        end
    end
    
    return false
end

function ENT:GetTargetPriority(target)
    if not IsValid(target) then return 0 end
    
    local priority = 1
    local class = target:GetClass()
    local distance = self:GetPos():Distance(target:GetPos())
    
    -- Priority based on target type
    if string.find(class, "weapon") or string.find(class, "cannon") then
        priority = priority + 3 -- High priority for weapons
    elseif string.find(class, "ship_core") then
        priority = priority + 5 -- Highest priority for ship cores
    elseif target:IsNPC() then
        priority = priority + 2 -- Medium priority for NPCs
    end
    
    -- Distance factor (closer = higher priority)
    priority = priority + (1 - (distance / self:GetNWInt("Range", 15000)))
    
    -- Health factor (lower health = higher priority)
    if target:Health() then
        priority = priority + (1 - (target:Health() / (target:GetMaxHealth() or 1000)))
    end
    
    return priority
end

function ENT:FireDroneVolley(targets)
    if not IsValid(self.ShipCore) then return end
    
    local energy = self.ShipCore:GetNWInt("Energy", 0)
    local energyCost = self:GetNWInt("Energy", 500)
    
    if energy < energyCost then return end
    
    -- Consume energy
    self.ShipCore:SetNWInt("Energy", energy - energyCost)
    
    -- Fire drones at multiple targets
    local dronesPerTarget = math.min(2, math.ceil(self.DroneCount / #targets))
    local dronesFired = 0
    
    for i, target in ipairs(targets) do
        if dronesFired >= self.DroneCount then break end
        
        for j = 1, dronesPerTarget do
            if dronesFired >= self.DroneCount then break end
            
            self:FireDrone(target, dronesFired)
            dronesFired = dronesFired + 1
        end
    end
    
    self.LastFire = CurTime()
    
    -- Play firing sound
    self:EmitSound("asc/weapons/ancient_drone_fire.wav", 75, 100)
    
    -- Create firing effect
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetEntity(self)
    util.Effect("asc_ancient_drone_fire", effectdata)
end

function ENT:FireDrone(target, droneIndex)
    if not IsValid(target) then return end
    
    -- Create drone projectile
    local drone = ents.Create("asc_ancient_drone_projectile")
    if not IsValid(drone) then return end
    
    -- Position drone at weapon
    local pos = self:GetPos() + self:GetUp() * 20 + self:GetRight() * (droneIndex - 4) * 10
    drone:SetPos(pos)
    drone:SetAngles(self:GetAngles())
    
    -- Set drone properties
    drone:SetNWEntity("Target", target)
    drone:SetNWEntity("Weapon", self)
    drone:SetNWInt("Damage", self:GetNWInt("Damage", 1000))
    drone:SetNWBool("ShieldPenetration", self.ShieldPenetration)
    drone:SetNWBool("AdaptiveTargeting", self.AdaptiveTargeting)
    
    drone:Spawn()
    drone:Activate()
    
    -- Add to active drones list
    table.insert(self.ActiveDrones, drone)
    
    -- Clean up drone reference when it's removed
    timer.Simple(30, function()
        if IsValid(drone) then
            drone:Remove()
        end
        
        for i, activeDrone in ipairs(self.ActiveDrones) do
            if activeDrone == drone then
                table.remove(self.ActiveDrones, i)
                break
            end
        end
    end)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Open weapon interface
    net.Start("ASC_OpenWeaponInterface")
    net.WriteEntity(self)
    net.WriteString("Ancient Drone Weapon")
    net.Send(activator)
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    
    -- Ancient technology is more resistant to damage
    damage = damage * 0.7
    
    self:SetHealth(self:Health() - damage)
    
    -- Create damage effect
    local effectdata = EffectData()
    effectdata:SetOrigin(dmginfo:GetDamagePosition())
    effectdata:SetMagnitude(damage)
    util.Effect("asc_ancient_damage", effectdata)
    
    -- Check for destruction
    if self:Health() <= 0 then
        self:Explode()
    end
end

function ENT:Explode()
    -- Create Ancient explosion effect
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(500)
    util.Effect("asc_ancient_explosion", effectdata)
    
    -- Play explosion sound
    self:EmitSound("asc/weapons/ancient_explosion.wav", 100, 100)
    
    -- Damage nearby entities
    util.BlastDamage(self, self, self:GetPos(), 300, 300)
    
    -- Remove entity
    self:Remove()
end

function ENT:OnRemove()
    -- Clean up timer
    timer.Remove("AncientDrone_" .. self:EntIndex())
    
    -- Remove from ship core's weapon list
    if IsValid(self.ShipCore) and self.ShipCore.LinkedWeapons then
        for i, weapon in ipairs(self.ShipCore.LinkedWeapons) do
            if weapon == self then
                table.remove(self.ShipCore.LinkedWeapons, i)
                break
            end
        end
    end
    
    -- Clean up active drones
    for _, drone in ipairs(self.ActiveDrones) do
        if IsValid(drone) then
            drone:Remove()
        end
    end
end

-- Network strings
util.AddNetworkString("ASC_OpenWeaponInterface")
util.AddNetworkString("ASC_WeaponCommand")

-- Network receivers
net.Receive("ASC_WeaponCommand", function(len, ply)
    local weapon = net.ReadEntity()
    local command = net.ReadString()
    
    if IsValid(weapon) and weapon:GetClass() == "asc_ancient_drone" then
        if command == "toggle_auto" then
            weapon:SetNWBool("AutoTargeting", not weapon:GetNWBool("AutoTargeting", true))
        elseif command == "fire_manual" then
            if #weapon.TargetList > 0 then
                weapon:FireDroneVolley(weapon.TargetList)
            end
        elseif command == "toggle_power" then
            weapon:SetNWBool("WeaponOnline", not weapon:GetNWBool("WeaponOnline", true))
        end
    end
end)
