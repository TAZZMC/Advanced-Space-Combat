-- Advanced Space Combat - Railgun Entity
-- High-velocity kinetic weapon system

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Use centralized model manager
    if ASC and ASC.Models and ASC.Models.GetModel then
        self:SetModel(ASC.Models.GetModel("railgun"))
    else
        -- Fallback if model manager not loaded yet
        self:SetModel("models/props_combine/combine_barricade_med02a.mdl")
        print("[ASC Railgun] Model manager not available, using direct fallback")
    end

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(200)
    end
    
    -- Weapon properties
    self:SetMaxHealth(250)
    self:SetHealth(250)
    
    -- Weapon stats
    self.WeaponType = "railgun"
    self.Damage = 200
    self.FireRate = 0.1 -- Slow but powerful
    self.Range = 5000
    self.EnergyConsumption = 100
    self.ProjectileSpeed = 5000
    self.ChargeTime = 2.0
    
    -- State variables
    self.LastFire = 0
    self.Charging = false
    self.ChargeStart = 0
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

function ENT:StartCharge()
    if self.Charging then return false end
    
    -- Check energy
    if IsValid(self.ShipCore) and not self.ShipCore:HasEnergy(self.EnergyConsumption) then
        return false
    end
    
    self.Charging = true
    self.ChargeStart = CurTime()
    self:SetNWBool("Charging", true)
    
    -- Charging sound
    self:EmitSound("asc/weapons/railgun_charge.wav", 75, 100)
    
    return true
end

function ENT:Fire(target)
    if not self.Charging then
        return self:StartCharge()
    end
    
    local chargeTime = CurTime() - self.ChargeStart
    if chargeTime < self.ChargeTime then return false end
    
    if CurTime() - self.LastFire < (1 / self.FireRate) then return false end
    
    -- Consume energy
    if IsValid(self.ShipCore) and not self.ShipCore:ConsumeEnergy(self.EnergyConsumption) then
        return false
    end
    
    self.LastFire = CurTime()
    self.Charging = false
    self:SetNWBool("Charging", false)
    
    -- Create projectile
    local projectile = ents.Create("asc_railgun_projectile")
    if IsValid(projectile) then
        projectile:SetPos(self:GetPos() + self:GetForward() * 60)
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
    self:EmitSound("asc/weapons/railgun_fire.wav", 100, 100)
    
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos() + self:GetForward() * 60)
    effectdata:SetAngles(self:GetAngles())
    effectdata:SetEntity(self)
    util.Effect("asc_railgun_muzzle", effectdata)
    
    return true
end

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

function ENT:FindTargets()
    local targets = {}
    local myPos = self:GetPos()
    
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and ent ~= self and ent:GetOwner() ~= self:GetOwner() then
            local dist = myPos:Distance(ent:GetPos())
            if dist <= self.Range then
                if ent:GetClass() == "ship_core" or string.find(ent:GetClass(), "weapon") then
                    table.insert(targets, ent)
                end
            end
        end
    end
    
    table.sort(targets, function(a, b)
        return myPos:Distance(a:GetPos()) < myPos:Distance(b:GetPos())
    end)
    
    return targets
end

function ENT:OnTakeDamage(dmginfo)
    self:SetHealth(self:Health() - dmginfo:GetDamage())
    
    if self:Health() <= 0 then
        self:Explode()
    end
end

function ENT:Explode()
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(3)
    util.Effect("Explosion", effectdata)
    
    self:EmitSound("ambient/explosions/explode_4.wav", 100, 100)
    self:Remove()
end

function ENT:Use(activator, caller)
    if IsValid(activator) and activator:IsPlayer() then
        self.AutoFire = not self.AutoFire
        activator:ChatPrint("Railgun auto-fire: " .. (self.AutoFire and "ON" or "OFF"))
    end
end
