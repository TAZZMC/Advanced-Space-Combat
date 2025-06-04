AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--[[
    Advanced Space Combat - Point Defense Turret Entity
    
    Automated point defense turret for intercepting incoming projectiles,
    missiles, and small craft.
]]

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(100)
    end
    
    -- Point Defense Properties
    self:SetMaxHealth(200)
    self:SetHealth(200)
    
    -- Network variables
    self:SetupDataTables()
    
    -- Initialize point defense system
    self:InitializePointDefense()
    
    -- Set default values
    self:SetActive(false)
    self:SetEnergy(100)
    self:SetHeat(0)
    self:SetTargetCount(0)
    self:SetFireRate(10) -- shots per second
    self:SetRange(1500)
    self:SetAmmo(1000)
    self:SetMaxAmmo(1000)
    
    -- Point defense data
    self.pointDefense = {
        -- Targeting system
        currentTarget = nil,
        targetHistory = {},
        lastTargetScan = 0,
        scanRate = 0.1,
        
        -- Weapon system
        lastShot = 0,
        fireRate = 0.1, -- Time between shots
        projectileSpeed = 2000,
        accuracy = 0.9,
        
        -- Performance tracking
        shotsFired = 0,
        targetsDestroyed = 0,
        missedShots = 0,
        
        -- Status
        overheated = false,
        malfunction = false,
        lastMaintenance = CurTime()
    }
    
    -- Start point defense system
    self:StartPointDefense()
    
    print("[Point Defense] Point defense turret initialized at " .. tostring(self:GetPos()))
end

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("Float", 0, "Energy")
    self:NetworkVar("Float", 1, "Heat")
    self:NetworkVar("Int", 0, "TargetCount")
    self:NetworkVar("Float", 2, "FireRate")
    self:NetworkVar("Float", 3, "Range")
    self:NetworkVar("Int", 1, "Ammo")
    self:NetworkVar("Int", 2, "MaxAmmo")
    self:NetworkVar("String", 0, "Status")
    self:NetworkVar("Entity", 0, "CurrentTarget")
end

function ENT:InitializePointDefense()
    -- Find nearby ship core for integration
    self:FindShipCore()
    
    -- Set up CAP integration if available
    if ASC.CAP and ASC.CAP.IsAvailable() then
        self:SetupCAPIntegration()
    end
    
    -- Initialize weapon systems
    self:InitializeWeaponSystems()
end

function ENT:FindShipCore()
    local nearbyEntities = ents.FindInSphere(self:GetPos(), 2000)
    
    for _, ent in ipairs(nearbyEntities) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            self.shipCore = ent
            self:SetStatus("Linked to ship core")
            
            -- Register with ship core's point defense system
            if ASC.PointDefense and ASC.PointDefense.Core then
                local shipID = ent:EntIndex()
                if not ASC.PointDefense.Core.DefenseSystems[shipID] then
                    ASC.PointDefense.Core.Initialize(ent, "STANDARD")
                end
            end
            
            print("[Point Defense] Linked to ship core " .. ent:EntIndex())
            break
        end
    end
    
    if not self.shipCore then
        self:SetStatus("No ship core detected")
    end
end

function ENT:SetupCAPIntegration()
    -- Use CAP models and materials if available
    local capModel = ASC.CAP.GetModel("point_defense_turret")
    if capModel then
        self:SetModel(capModel)
    end
    
    local capMaterial = ASC.CAP.GetMaterial("point_defense_turret")
    if capMaterial then
        self:SetMaterial(capMaterial)
    end
end

function ENT:InitializeWeaponSystems()
    -- Set up weapon configuration
    self.weaponConfig = {
        projectileType = "asc_defense_projectile",
        damage = 50,
        speed = 2000,
        lifetime = 3.0,
        explosive = false,
        penetration = 1
    }
end

function ENT:StartPointDefense()
    if self.pointDefenseActive then return end
    
    self.pointDefenseActive = true
    self:SetActive(true)
    self:SetStatus("Point defense active")
    
    -- Start main update loop
    timer.Create("ASC_PointDefense_" .. self:EntIndex(), 0.05, 0, function()
        if IsValid(self) and self:GetActive() then
            self:UpdatePointDefense()
        else
            timer.Remove("ASC_PointDefense_" .. self:EntIndex())
        end
    end)
    
    print("[Point Defense] Point defense system started")
end

function ENT:UpdatePointDefense()
    local currentTime = CurTime()
    
    -- Update system status
    self:UpdateSystemStatus(currentTime)
    
    -- Scan for targets
    if currentTime - self.pointDefense.lastTargetScan > self.pointDefense.scanRate then
        self:ScanForTargets(currentTime)
        self.pointDefense.lastTargetScan = currentTime
    end
    
    -- Engage current target
    if self.pointDefense.currentTarget and IsValid(self.pointDefense.currentTarget) then
        self:EngageTarget(currentTime)
    end
    
    -- Update heat and energy
    self:UpdateHeatAndEnergy(currentTime)
end

function ENT:UpdateSystemStatus(currentTime)
    -- Check for overheating
    if self:GetHeat() >= 100 then
        self.pointDefense.overheated = true
        self:SetStatus("OVERHEATED - Cooling down")
    elseif self:GetHeat() < 50 then
        self.pointDefense.overheated = false
    end
    
    -- Check ammunition
    if self:GetAmmo() <= 0 then
        self:SetStatus("OUT OF AMMO - Reloading")
        self:StartReload()
    end
    
    -- Check energy
    if self:GetEnergy() < 10 then
        self:SetStatus("LOW ENERGY - Reduced performance")
    end
end

function ENT:ScanForTargets(currentTime)
    local myPos = self:GetPos()
    local range = self:GetRange()
    local potentialTargets = {}
    
    -- Find entities in range
    for _, ent in ipairs(ents.FindInSphere(myPos, range)) do
        if self:IsValidTarget(ent) then
            local distance = myPos:Distance(ent:GetPos())
            local threat = self:CalculateThreatLevel(ent, distance)
            
            table.insert(potentialTargets, {
                entity = ent,
                distance = distance,
                threat = threat,
                velocity = ent:GetVelocity(),
                timeToImpact = distance / math.max(ent:GetVelocity():Length(), 1)
            })
        end
    end
    
    -- Sort by threat level
    table.sort(potentialTargets, function(a, b)
        return a.threat > b.threat
    end)
    
    -- Select highest priority target
    if #potentialTargets > 0 then
        local newTarget = potentialTargets[1].entity
        if newTarget ~= self.pointDefense.currentTarget then
            self.pointDefense.currentTarget = newTarget
            self:SetCurrentTarget(newTarget)
            self:SetStatus("Engaging " .. newTarget:GetClass())
        end
    else
        self.pointDefense.currentTarget = nil
        self:SetCurrentTarget(NULL)
        self:SetStatus("Scanning for targets")
    end
    
    self:SetTargetCount(#potentialTargets)
end

function ENT:IsValidTarget(ent)
    if not IsValid(ent) then return false end
    if ent == self then return false end
    if ent == self.shipCore then return false end
    
    local class = ent:GetClass()
    
    -- Check for valid target types
    local validTypes = {
        "missile", "torpedo", "projectile", "rocket", "grenade"
    }
    
    for _, targetType in ipairs(validTypes) do
        if string.find(class, targetType) then
            return true
        end
    end
    
    -- Check for fast-moving physics objects (potential projectiles)
    if ent:GetClass() == "prop_physics" then
        local velocity = ent:GetVelocity():Length()
        if velocity > 200 then -- Fast-moving object
            return true
        end
    end
    
    return false
end

function ENT:CalculateThreatLevel(ent, distance)
    local threat = 1.0
    local class = ent:GetClass()
    local velocity = ent:GetVelocity():Length()
    
    -- Base threat by type
    if string.find(class, "missile") then
        threat = 10.0
    elseif string.find(class, "torpedo") then
        threat = 8.0
    elseif string.find(class, "rocket") then
        threat = 6.0
    elseif string.find(class, "projectile") then
        threat = 4.0
    end
    
    -- Increase threat for fast objects
    if velocity > 500 then
        threat = threat * 1.5
    end
    
    -- Increase threat for close objects
    if distance < 300 then
        threat = threat * 2.0
    end
    
    -- Decrease threat for distant objects
    if distance > 1000 then
        threat = threat * 0.5
    end
    
    return threat
end

function ENT:EngageTarget(currentTime)
    if not self:CanFire(currentTime) then return end
    
    local target = self.pointDefense.currentTarget
    if not IsValid(target) then return end
    
    -- Calculate intercept point
    local interceptPoint = self:CalculateInterceptPoint(target)
    
    -- Aim at intercept point
    local aimDir = (interceptPoint - self:GetPos()):GetNormalized()
    
    -- Fire projectile
    if self:FireProjectile(aimDir, target) then
        self.pointDefense.lastShot = currentTime
        self.pointDefense.shotsFired = self.pointDefense.shotsFired + 1
        
        -- Consume resources
        self:SetAmmo(self:GetAmmo() - 1)
        self:SetEnergy(self:GetEnergy() - 2)
        self:SetHeat(self:GetHeat() + 5)
        
        -- Create muzzle flash effect
        self:CreateMuzzleFlash()
    end
end

function ENT:CanFire(currentTime)
    if self.pointDefense.overheated then return false end
    if self:GetAmmo() <= 0 then return false end
    if self:GetEnergy() < 5 then return false end
    if currentTime - self.pointDefense.lastShot < self.pointDefense.fireRate then return false end
    
    return true
end

function ENT:CalculateInterceptPoint(target)
    local targetPos = target:GetPos()
    local targetVel = target:GetVelocity()
    local myPos = self:GetPos()
    
    -- Simple lead calculation
    local distance = myPos:Distance(targetPos)
    local timeToTarget = distance / self.weaponConfig.speed
    
    return targetPos + (targetVel * timeToTarget)
end

function ENT:FireProjectile(direction, target)
    local projectile = ents.Create(self.weaponConfig.projectileType)
    if not IsValid(projectile) then
        -- Fallback to generic projectile
        projectile = ents.Create("prop_physics")
        if not IsValid(projectile) then return false end
        
        projectile:SetModel("models/hunter/misc/sphere025x025.mdl")
        projectile:SetMaterial("models/debug/debugwhite")
        projectile:SetColor(Color(255, 100, 100))
    end
    
    -- Position and orient projectile
    local startPos = self:GetPos() + direction * 30
    projectile:SetPos(startPos)
    projectile:SetAngles(direction:Angle())
    projectile:Spawn()
    projectile:Activate()
    
    -- Set projectile properties
    local phys = projectile:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(direction * self.weaponConfig.speed)
        phys:SetMass(1)
    end
    
    -- Set damage and target
    projectile.Damage = self.weaponConfig.damage
    projectile.Target = target
    projectile.Owner = self
    
    -- Remove projectile after lifetime
    timer.Simple(self.weaponConfig.lifetime, function()
        if IsValid(projectile) then
            projectile:Remove()
        end
    end)
    
    return true
end

function ENT:CreateMuzzleFlash()
    local effectData = EffectData()
    effectData:SetOrigin(self:GetPos())
    effectData:SetNormal(self:GetForward())
    effectData:SetScale(0.5)
    util.Effect("MuzzleFlash", effectData)
end

function ENT:UpdateHeatAndEnergy(currentTime)
    -- Cool down heat
    if self:GetHeat() > 0 then
        self:SetHeat(math.max(0, self:GetHeat() - 2)) -- 2% per update
    end
    
    -- Regenerate energy if ship core provides it
    if IsValid(self.shipCore) and self.shipCore.GetEnergy then
        local shipEnergy = self.shipCore:GetEnergy()
        if shipEnergy > 50 then
            self:SetEnergy(math.min(100, self:GetEnergy() + 1))
        end
    else
        -- Slow energy regeneration without ship core
        self:SetEnergy(math.min(100, self:GetEnergy() + 0.1))
    end
end

function ENT:StartReload()
    if self.reloading then return end
    
    self.reloading = true
    self:SetStatus("Reloading ammunition...")
    
    timer.Simple(5, function() -- 5 second reload
        if IsValid(self) then
            self:SetAmmo(self:GetMaxAmmo())
            self.reloading = false
            self:SetStatus("Reload complete")
        end
    end)
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Toggle point defense system
    if self:GetActive() then
        self:StopPointDefense()
        activator:ChatPrint("[Point Defense] Point defense system deactivated")
    else
        self:StartPointDefense()
        activator:ChatPrint("[Point Defense] Point defense system activated")
    end
end

function ENT:StopPointDefense()
    self.pointDefenseActive = false
    self:SetActive(false)
    self:SetStatus("Point defense offline")
    
    timer.Remove("ASC_PointDefense_" .. self:EntIndex())
    
    print("[Point Defense] Point defense system stopped")
end

function ENT:OnRemove()
    timer.Remove("ASC_PointDefense_" .. self:EntIndex())
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    
    -- Reduce damage if shields are active
    if IsValid(self.shipCore) and self.shipCore.GetShieldStatus then
        local shieldStatus = self.shipCore:GetShieldStatus()
        if shieldStatus and shieldStatus.active then
            damage = damage * 0.5 -- Shields absorb 50% of damage
        end
    end
    
    self:SetHealth(self:Health() - damage)
    
    if self:Health() <= 0 then
        -- Create explosion effect
        local effectData = EffectData()
        effectData:SetOrigin(self:GetPos())
        effectData:SetScale(1)
        util.Effect("Explosion", effectData)
        
        self:Remove()
    end
end
