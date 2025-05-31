-- Enhanced Hyperdrive Weapons System v2.2.1
-- COMPLETE WEAPONS FRAMEWORK - Ship-integrated weapon systems
-- Advanced targeting, energy management, and ship core integration

print("[Hyperdrive Weapons] COMPLETE WEAPONS SYSTEM v2.2.1 - Initializing...")
print("[Hyperdrive Weapons] Ship-integrated weapon systems loading...")

-- Initialize weapons namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Weapons = HYPERDRIVE.Weapons or {}

-- Weapons system configuration
HYPERDRIVE.Weapons.Config = {
    -- Core Integration
    RequireShipCore = true,
    AutoDetectWeapons = true,
    IntegrateWithShipSystems = true,
    
    -- Energy Management
    UseEnergySystem = true,
    EnergyPerShot = {
        pulse = 10,
        beam = 25,
        torpedo = 50,
        railgun = 75,
        plasma = 100
    },
    
    -- Targeting System
    AutoTargeting = true,
    TargetingRange = 5000,
    FriendlyFire = false,
    RequireLineOfSight = true,
    
    -- Weapon Types
    WeaponTypes = {
        "hyperdrive_pulse_cannon",
        "hyperdrive_beam_weapon",
        "hyperdrive_torpedo_launcher",
        "hyperdrive_railgun",
        "hyperdrive_plasma_cannon",
        "hyperdrive_point_defense"
    },
    
    -- Damage System
    DamageMultipliers = {
        hull = 1.0,
        shields = 0.8,
        armor = 1.2
    },
    
    -- Effects
    EnableMuzzleFlash = true,
    EnableProjectileTrails = true,
    EnableImpactEffects = true,
    EnableSounds = true
}

-- Weapons registry
HYPERDRIVE.Weapons.Registry = {}
HYPERDRIVE.Weapons.ActiveWeapons = {}
HYPERDRIVE.Weapons.TargetingData = {}

-- Weapon class template
local WeaponClass = {}
WeaponClass.__index = WeaponClass

function WeaponClass:New(entity, weaponType)
    local weapon = setmetatable({}, WeaponClass)
    
    weapon.entity = entity
    weapon.weaponType = weaponType
    weapon.ship = nil
    weapon.shipCore = nil
    
    -- Weapon properties
    weapon.damage = 100
    weapon.range = 2000
    weapon.fireRate = 1.0 -- shots per second
    weapon.energyCost = 25
    weapon.accuracy = 0.95
    weapon.projectileSpeed = 1000
    
    -- State
    weapon.active = false
    weapon.target = nil
    weapon.lastFireTime = 0
    weapon.ammo = -1 -- -1 = unlimited
    weapon.overheated = false
    weapon.heat = 0
    weapon.maxHeat = 100
    
    -- Targeting
    weapon.autoTarget = false
    weapon.targetLock = false
    weapon.targetingRange = weapon.range
    
    return weapon
end

function WeaponClass:Initialize()
    -- Find ship core
    self:FindShipCore()
    
    -- Register with weapons system
    HYPERDRIVE.Weapons.RegisterWeapon(self)
    
    -- Setup weapon-specific properties
    self:SetupWeaponType()
    
    print("[Hyperdrive Weapons] Weapon initialized: " .. self.weaponType)
end

function WeaponClass:FindShipCore()
    if not HYPERDRIVE.ShipCore then return end
    
    -- Search for nearby ship core
    local nearbyEnts = ents.FindInSphere(self.entity:GetPos(), 2000)
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            local ship = HYPERDRIVE.ShipCore.GetShip(ent)
            if ship then
                self.ship = ship
                self.shipCore = ent
                print("[Hyperdrive Weapons] Weapon linked to ship: " .. (ship:GetShipType() or "Unknown"))
                return
            end
        end
    end
end

function WeaponClass:SetupWeaponType()
    local config = HYPERDRIVE.Weapons.GetWeaponConfig(self.weaponType)
    if config then
        self.damage = config.damage or self.damage
        self.range = config.range or self.range
        self.fireRate = config.fireRate or self.fireRate
        self.energyCost = config.energyCost or self.energyCost
        self.projectileSpeed = config.projectileSpeed or self.projectileSpeed
    end
end

function WeaponClass:CanFire()
    -- Check cooldown
    if CurTime() - self.lastFireTime < (1 / self.fireRate) then
        return false, "Weapon cooling down"
    end
    
    -- Check overheating
    if self.overheated then
        return false, "Weapon overheated"
    end
    
    -- Check ammo
    if self.ammo == 0 then
        return false, "No ammunition"
    end
    
    -- Check energy
    if self.shipCore and HYPERDRIVE.SB3Resources then
        local energy = HYPERDRIVE.SB3Resources.GetResource(self.shipCore, "energy")
        if energy < self.energyCost then
            return false, "Insufficient energy"
        end
    end
    
    -- Check ship core requirement
    if HYPERDRIVE.Weapons.Config.RequireShipCore and not self.shipCore then
        return false, "No ship core detected"
    end
    
    return true
end

function WeaponClass:Fire(target)
    local canFire, reason = self:CanFire()
    if not canFire then
        return false, reason
    end
    
    -- Consume energy
    if self.shipCore and HYPERDRIVE.SB3Resources then
        HYPERDRIVE.SB3Resources.ConsumeResource(self.shipCore, "energy", self.energyCost)
    end
    
    -- Consume ammo
    if self.ammo > 0 then
        self.ammo = self.ammo - 1
    end
    
    -- Add heat
    self.heat = math.min(self.maxHeat, self.heat + 10)
    if self.heat >= self.maxHeat then
        self.overheated = true
        timer.Simple(3, function()
            if IsValid(self.entity) then
                self.overheated = false
                self.heat = 0
            end
        end)
    end
    
    -- Create projectile
    self:CreateProjectile(target)
    
    -- Effects
    self:CreateMuzzleFlash()
    self:PlayFireSound()
    
    self.lastFireTime = CurTime()
    return true
end

function WeaponClass:CreateProjectile(target)
    -- This will be overridden by specific weapon types
    local projectile = ents.Create("hyperdrive_projectile")
    if IsValid(projectile) then
        projectile:SetPos(self.entity:GetPos() + self.entity:GetForward() * 50)
        projectile:SetAngles(self.entity:GetAngles())
        projectile:Spawn()
        
        -- Set projectile properties
        projectile:SetWeapon(self)
        projectile:SetTarget(target)
        projectile:SetDamage(self.damage)
        projectile:SetSpeed(self.projectileSpeed)
    end
end

function WeaponClass:CreateMuzzleFlash()
    if not HYPERDRIVE.Weapons.Config.EnableMuzzleFlash then return end
    
    local effectData = EffectData()
    effectData:SetOrigin(self.entity:GetPos() + self.entity:GetForward() * 30)
    effectData:SetAngles(self.entity:GetAngles())
    effectData:SetEntity(self.entity)
    effectData:SetScale(1)
    util.Effect("weapon_muzzle_flash", effectData)
end

function WeaponClass:PlayFireSound()
    if not HYPERDRIVE.Weapons.Config.EnableSounds then return end
    
    local soundFile = "weapons/" .. self.weaponType .. "_fire.wav"
    self.entity:EmitSound(soundFile, 75, 100, 0.8)
end

function WeaponClass:UpdateTargeting()
    if not self.autoTarget then return end
    
    -- Find targets in range
    local targets = self:FindTargets()
    if #targets > 0 then
        self.target = targets[1] -- Select closest target
        self.targetLock = true
    else
        self.target = nil
        self.targetLock = false
    end
end

function WeaponClass:FindTargets()
    local targets = {}
    local myPos = self.entity:GetPos()
    
    for _, ent in ipairs(ents.FindInSphere(myPos, self.targetingRange)) do
        if self:IsValidTarget(ent) then
            local distance = myPos:Distance(ent:GetPos())
            table.insert(targets, {entity = ent, distance = distance})
        end
    end
    
    -- Sort by distance
    table.sort(targets, function(a, b) return a.distance < b.distance end)
    
    local result = {}
    for _, target in ipairs(targets) do
        table.insert(result, target.entity)
    end
    
    return result
end

function WeaponClass:IsValidTarget(ent)
    if not IsValid(ent) then return false end
    
    -- Don't target friendly entities
    if not HYPERDRIVE.Weapons.Config.FriendlyFire then
        if ent:IsPlayer() or ent:IsNPC() then
            return false
        end
        
        -- Don't target same ship
        if self.ship and HYPERDRIVE.ShipCore then
            local targetShip = HYPERDRIVE.ShipCore.GetShipByEntity(ent)
            if targetShip == self.ship then
                return false
            end
        end
    end
    
    -- Check line of sight
    if HYPERDRIVE.Weapons.Config.RequireLineOfSight then
        local trace = util.TraceLine({
            start = self.entity:GetPos(),
            endpos = ent:GetPos(),
            filter = {self.entity, self.shipCore}
        })
        
        if trace.Hit and trace.Entity ~= ent then
            return false
        end
    end
    
    return true
end

-- Main weapons system functions
function HYPERDRIVE.Weapons.RegisterWeapon(weapon)
    local weaponId = weapon.entity:EntIndex()
    HYPERDRIVE.Weapons.ActiveWeapons[weaponId] = weapon
    
    print("[Hyperdrive Weapons] Registered weapon: " .. weapon.weaponType .. " (ID: " .. weaponId .. ")")
end

function HYPERDRIVE.Weapons.UnregisterWeapon(weaponId)
    HYPERDRIVE.Weapons.ActiveWeapons[weaponId] = nil
    print("[Hyperdrive Weapons] Unregistered weapon ID: " .. weaponId)
end

function HYPERDRIVE.Weapons.GetWeapon(entity)
    if not IsValid(entity) then return nil end
    return HYPERDRIVE.Weapons.ActiveWeapons[entity:EntIndex()]
end

function HYPERDRIVE.Weapons.GetWeaponConfig(weaponType)
    return HYPERDRIVE.Weapons.Registry[weaponType]
end

function HYPERDRIVE.Weapons.RegisterWeaponType(weaponType, config)
    HYPERDRIVE.Weapons.Registry[weaponType] = config
    print("[Hyperdrive Weapons] Registered weapon type: " .. weaponType)
end

-- Export weapon class for entities to use
HYPERDRIVE.Weapons.WeaponClass = WeaponClass

-- Initialize weapon type configurations
timer.Simple(0.1, function()
    HYPERDRIVE.Weapons.InitializeWeaponTypes()
end)

function HYPERDRIVE.Weapons.InitializeWeaponTypes()
    -- Pulse Cannon
    HYPERDRIVE.Weapons.RegisterWeaponType("hyperdrive_pulse_cannon", {
        damage = 75,
        range = 1500,
        fireRate = 2.0,
        energyCost = 15,
        projectileSpeed = 1200,
        projectileType = "energy_pulse"
    })
    
    -- Beam Weapon
    HYPERDRIVE.Weapons.RegisterWeaponType("hyperdrive_beam_weapon", {
        damage = 50,
        range = 2500,
        fireRate = 0.1, -- Continuous beam
        energyCost = 5, -- Per tick
        projectileSpeed = 0, -- Instant
        projectileType = "energy_beam"
    })
    
    -- Torpedo Launcher
    HYPERDRIVE.Weapons.RegisterWeaponType("hyperdrive_torpedo_launcher", {
        damage = 200,
        range = 3000,
        fireRate = 0.5,
        energyCost = 50,
        projectileSpeed = 800,
        projectileType = "torpedo"
    })
    
    -- Railgun
    HYPERDRIVE.Weapons.RegisterWeaponType("hyperdrive_railgun", {
        damage = 300,
        range = 4000,
        fireRate = 0.3,
        energyCost = 75,
        projectileSpeed = 2000,
        projectileType = "railgun_slug"
    })
    
    -- Plasma Cannon
    HYPERDRIVE.Weapons.RegisterWeaponType("hyperdrive_plasma_cannon", {
        damage = 150,
        range = 2000,
        fireRate = 1.0,
        energyCost = 40,
        projectileSpeed = 900,
        projectileType = "plasma_bolt"
    })
    
    -- Point Defense
    HYPERDRIVE.Weapons.RegisterWeaponType("hyperdrive_point_defense", {
        damage = 25,
        range = 800,
        fireRate = 10.0,
        energyCost = 5,
        projectileSpeed = 1500,
        projectileType = "point_defense"
    })
    
    print("[Hyperdrive Weapons] All weapon types initialized")
end

print("[Hyperdrive Weapons] Weapons system framework loaded successfully!")
