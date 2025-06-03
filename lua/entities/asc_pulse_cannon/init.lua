-- Advanced Space Combat - Pulse Cannon Entity
-- High-frequency energy weapon system

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Initialize entity
function ENT:Initialize()
    -- Use centralized model manager
    if ASC and ASC.Models and ASC.Models.GetModel then
        self:SetModel(ASC.Models.GetModel("pulse_cannon"))
    else
        -- Fallback if model manager not loaded yet
        self:SetModel("models/props_c17/oildrum001_explosive.mdl")
        print("[ASC Pulse Cannon] Model manager not available, using direct fallback")
    end

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(150)
    end
    
    -- Weapon properties
    self:SetMaxHealth(200)
    self:SetHealth(200)
    
    -- Weapon stats
    self.WeaponType = "pulse_cannon"
    self.Damage = 75
    self.FireRate = 0.3 -- Shots per second
    self.Range = 3000
    self.EnergyConsumption = 25
    self.ProjectileSpeed = 2500
    
    -- State variables
    self.LastFire = 0
    self.Target = nil
    self.ShipCore = nil
    self.AutoFire = false
    
    -- Find ship core
    timer.Simple(1, function()
        if IsValid(self) then
            self:FindShipCore()
        end
    end)
end

-- Find and link to ship core
function ENT:FindShipCore()
    local cores = ents.FindByClass("ship_core")
    local closestCore = nil
    local closestDist = math.huge
    
    for _, core in ipairs(cores) do
        if IsValid(core) and core:GetOwner() == self:GetOwner() then
            local dist = self:GetPos():Distance(core:GetPos())
            if dist < 2000 and dist < closestDist then
                closestCore = core
                closestDist = dist
            end
        end
    end
    
    if IsValid(closestCore) then
        self.ShipCore = closestCore
        closestCore:AddWeapon(self)
        self:SetNWEntity("ShipCore", closestCore)
    end
end

-- Fire weapon
function ENT:Fire(target)
    if CurTime() - self.LastFire < (1 / self.FireRate) then return false end
    
    -- Check energy
    if IsValid(self.ShipCore) and not self.ShipCore:ConsumeEnergy(self.EnergyConsumption) then
        return false
    end
    
    self.LastFire = CurTime()
    
    -- Create projectile
    local projectile = ents.Create("asc_pulse_projectile")
    if IsValid(projectile) then
        projectile:SetPos(self:GetPos() + self:GetForward() * 50)
        projectile:SetAngles(self:GetAngles())
        projectile:SetOwner(self:GetOwner())
        projectile:SetNWEntity("Weapon", self)
        projectile:Spawn()
        
        -- Set projectile properties
        local phys = projectile:GetPhysicsObject()
        if IsValid(phys) then
            phys:SetVelocity(self:GetForward() * self.ProjectileSpeed)
        end
    end
    
    -- Effects
    self:EmitSound("asc/weapons/pulse_cannon_fire.wav", 75, 100)
    
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos() + self:GetForward() * 50)
    effectdata:SetAngles(self:GetAngles())
    effectdata:SetEntity(self)
    util.Effect("asc_pulse_muzzle", effectdata)
    
    return true
end

-- Auto-targeting system
function ENT:Think()
    if self.AutoFire and IsValid(self.ShipCore) then
        local targets = self:FindTargets()
        if #targets > 0 then
            self:Fire(targets[1])
        end
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

-- Find valid targets
function ENT:FindTargets()
    local targets = {}
    local myPos = self:GetPos()
    
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent ~= self and ent:GetOwner() ~= self:GetOwner() then
            local dist = myPos:Distance(ent:GetPos())
            if dist <= self.Range then
                -- Check if it's a valid target (ship core or weapon)
                if ent:GetClass() == "ship_core" or string.find(ent:GetClass(), "weapon") then
                    table.insert(targets, ent)
                end
            end
        end
    end
    
    -- Sort by distance
    table.sort(targets, function(a, b)
        return myPos:Distance(a:GetPos()) < myPos:Distance(b:GetPos())
    end)
    
    return targets
end

-- Take damage
function ENT:OnTakeDamage(dmginfo)
    self:SetHealth(self:Health() - dmginfo:GetDamage())
    
    if self:Health() <= 0 then
        self:Explode()
    end
end

-- Explode when destroyed
function ENT:Explode()
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(2)
    util.Effect("Explosion", effectdata)
    
    self:EmitSound("ambient/explosions/explode_4.wav", 100, 100)
    self:Remove()
end

-- Use function
function ENT:Use(activator, caller)
    if IsValid(activator) and activator:IsPlayer() then
        self.AutoFire = not self.AutoFire
        activator:ChatPrint("Pulse Cannon auto-fire: " .. (self.AutoFire and "ON" or "OFF"))
    end
end
