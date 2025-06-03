-- Advanced Space Combat - Plasma Cannon
-- High-damage area effect weapon system

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_c17/oildrum001.mdl") -- Placeholder model
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(150)
    end
    
    -- Weapon properties
    self.WeaponType = "plasma_cannon"
    self.WeaponName = "Plasma Cannon"
    self.Damage = 120
    self.FireRate = 0.8 -- Seconds between shots
    self.Range = 3000
    self.EnergyConsumption = 25
    self.AmmunitionType = "plasma_cells"
    self.AmmunitionCapacity = 50
    self.CurrentAmmunition = 50
    
    -- Plasma properties
    self.PlasmaTemperature = 15000 -- Kelvin
    self.SplashRadius = 200
    self.SplashDamage = 60
    
    -- System state
    self.IsCharging = false
    self.ChargeLevel = 0
    self.MaxChargeLevel = 100
    self.ChargeRate = 50 -- Per second
    self.LastFired = 0
    self.Overheated = false
    self.HeatLevel = 0
    self.MaxHeat = 100
    self.CooldownRate = 30 -- Per second
    
    -- Ship integration
    self.ShipCore = nil
    self.AutoTarget = false
    self.TargetEntity = nil
    
    -- Effects
    self.MuzzleAttachment = 1
    self.ChargeEffect = nil
    
    -- Initialize weapon systems
    self:InitializeWeaponSystems()
    
    -- Auto-link to ship core
    timer.Simple(1, function()
        if IsValid(self) then
            self:FindAndLinkShipCore()
        end
    end)
end

function ENT:InitializeWeaponSystems()
    -- Set up weapon targeting
    self.TargetingRange = self.Range
    self.TargetingFOV = 45 -- Degrees
    
    -- Set up thermal management
    self.ThermalEfficiency = 0.85
    self.CoolantLevel = 100
    
    -- Set up ammunition system
    self.ReloadTime = 3.0
    self.IsReloading = false
    
    print("[ASC] Plasma Cannon initialized: " .. tostring(self))
end

function ENT:Think()
    local curTime = CurTime()
    
    -- Heat management
    if self.HeatLevel > 0 then
        self.HeatLevel = math.max(0, self.HeatLevel - self.CooldownRate * FrameTime())
        
        if self.Overheated and self.HeatLevel < 30 then
            self.Overheated = false
            self:EmitSound("ambient/energy/weld2.wav", 60, 120)
        end
    end
    
    -- Charging system
    if self.IsCharging and not self.Overheated then
        self.ChargeLevel = math.min(self.MaxChargeLevel, self.ChargeLevel + self.ChargeRate * FrameTime())
        
        -- Charging effects
        if math.random() < 0.3 then
            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos() + self:GetUp() * 20)
            effectdata:SetMagnitude(self.ChargeLevel / 100)
            util.Effect("asc_plasma_charge", effectdata)
        end
    end
    
    -- Auto-targeting
    if self.AutoTarget and IsValid(self.ShipCore) then
        self:UpdateAutoTargeting()
    end
    
    -- Update ship core link
    if not IsValid(self.ShipCore) then
        self:FindAndLinkShipCore()
    end
    
    self:NextThink(curTime + 0.1)
    return true
end

function ENT:FindAndLinkShipCore()
    local cores = ents.FindByClass("ship_core")
    local closestCore = nil
    local closestDist = 2000
    
    for _, core in ipairs(cores) do
        if IsValid(core) then
            local dist = self:GetPos():Distance(core:GetPos())
            if dist < closestDist then
                closestCore = core
                closestDist = dist
            end
        end
    end
    
    if IsValid(closestCore) then
        self.ShipCore = closestCore
        closestCore:AddWeapon(self)
        print("[ASC] Plasma Cannon linked to ship core: " .. tostring(closestCore))
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Check ownership
    local owner = self:CPPIGetOwner()
    if IsValid(owner) and owner ~= activator and not activator:IsAdmin() then
        activator:ChatPrint("You don't own this plasma cannon!")
        return
    end
    
    -- Toggle auto-targeting
    self.AutoTarget = not self.AutoTarget
    activator:ChatPrint("Plasma Cannon auto-targeting: " .. (self.AutoTarget and "ENABLED" or "DISABLED"))
    
    if self.AutoTarget then
        self:EmitSound("buttons/button9.wav", 50, 120)
    else
        self:EmitSound("buttons/button10.wav", 50, 80)
    end
end

function ENT:StartCharging()
    if self.Overheated or self.CurrentAmmunition <= 0 then return false end
    
    self.IsCharging = true
    self.ChargeLevel = 0
    
    -- Charging sound
    self:EmitSound("ambient/energy/weld1.wav", 70, 80)
    
    return true
end

function ENT:Fire(target)
    if self.Overheated or self.CurrentAmmunition <= 0 then return false end
    if CurTime() - self.LastFired < self.FireRate then return false end
    
    local firePos = self:GetPos() + self:GetUp() * 25
    local fireDir = self:GetForward()
    
    if IsValid(target) then
        fireDir = (target:GetPos() - firePos):GetNormalized()
    end
    
    -- Create plasma projectile
    local projectile = ents.Create("asc_plasma_projectile")
    if IsValid(projectile) then
        projectile:SetPos(firePos)
        projectile:SetAngles(fireDir:Angle())
        projectile:SetOwner(self:GetOwner())
        projectile:Spawn()
        projectile:Activate()
        
        -- Set projectile properties
        projectile:SetDamage(self.Damage)
        projectile:SetSplashRadius(self.SplashRadius)
        projectile:SetSplashDamage(self.SplashDamage)
        projectile:SetVelocity(fireDir * 1500)
    end
    
    -- Consume ammunition
    self.CurrentAmmunition = self.CurrentAmmunition - 1
    
    -- Generate heat
    self.HeatLevel = math.min(self.MaxHeat, self.HeatLevel + 25)
    if self.HeatLevel >= self.MaxHeat then
        self.Overheated = true
        self:EmitSound("ambient/energy/spark6.wav", 80, 60)
    end
    
    -- Fire effects
    local effectdata = EffectData()
    effectdata:SetOrigin(firePos)
    effectdata:SetNormal(fireDir)
    effectdata:SetMagnitude(self.Damage)
    util.Effect("asc_plasma_blast", effectdata)
    
    -- Fire sound
    self:EmitSound("weapons/physcannon/energy_sing_explosion2.wav", 85, 90)
    
    -- Reset charging
    self.IsCharging = false
    self.ChargeLevel = 0
    self.LastFired = CurTime()
    
    return true
end

function ENT:UpdateAutoTargeting()
    if not self.AutoTarget then return end
    
    local targets = {}
    
    -- Find potential targets
    for _, ent in ipairs(ents.FindInSphere(self:GetPos(), self.TargetingRange)) do
        if IsValid(ent) and ent ~= self and ent ~= self.ShipCore then
            if ent:IsPlayer() or ent:IsNPC() or ent:IsVehicle() then
                -- Check if target is in firing arc
                local toTarget = (ent:GetPos() - self:GetPos()):GetNormalized()
                local dot = self:GetForward():Dot(toTarget)
                local angle = math.deg(math.acos(dot))
                
                if angle <= self.TargetingFOV then
                    table.insert(targets, {
                        entity = ent,
                        distance = self:GetPos():Distance(ent:GetPos()),
                        angle = angle
                    })
                end
            end
        end
    end
    
    -- Select best target (closest)
    if #targets > 0 then
        table.sort(targets, function(a, b) return a.distance < b.distance end)
        self.TargetEntity = targets[1].entity
        
        -- Auto-fire if charged
        if self.ChargeLevel >= 80 then
            self:Fire(self.TargetEntity)
        elseif not self.IsCharging then
            self:StartCharging()
        end
    else
        self.TargetEntity = nil
        self.IsCharging = false
    end
end

function ENT:GetWeaponInfo()
    return {
        type = self.WeaponType,
        name = self.WeaponName,
        damage = self.Damage,
        range = self.Range,
        ammunition = self.CurrentAmmunition,
        max_ammunition = self.AmmunitionCapacity,
        heat_level = self.HeatLevel,
        max_heat = self.MaxHeat,
        overheated = self.Overheated,
        auto_target = self.AutoTarget,
        charging = self.IsCharging,
        charge_level = self.ChargeLevel
    }
end

function ENT:OnRemove()
    if IsValid(self.ShipCore) then
        self.ShipCore:RemoveWeapon(self)
    end
end
