-- Advanced Space Combat - Plasma Cannon Shared
-- Shared definitions for plasma cannon weapon system

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Plasma Cannon"
ENT.Author = "Advanced Space Combat"
ENT.Contact = ""
ENT.Purpose = "High-damage area effect weapon system"
ENT.Instructions = "Use to toggle auto-targeting. Links automatically to ship cores."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Advanced Space Combat - Weapons"

-- Weapon specifications
ENT.WeaponClass = "energy_weapon"
ENT.WeaponTier = 3
ENT.PowerRequirement = 25
ENT.CoolingRequirement = 15

-- Visual properties
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true

-- Network variables
function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsCharging")
    self:NetworkVar("Bool", 1, "Overheated")
    self:NetworkVar("Bool", 2, "AutoTarget")
    self:NetworkVar("Float", 0, "ChargeLevel")
    self:NetworkVar("Float", 1, "HeatLevel")
    self:NetworkVar("Int", 0, "CurrentAmmunition")
    self:NetworkVar("Entity", 0, "TargetEntity")
    self:NetworkVar("Entity", 1, "ShipCore")
end

-- Weapon configuration
ENT.WeaponConfig = {
    -- Damage properties
    BaseDamage = 120,
    SplashDamage = 60,
    SplashRadius = 200,
    ArmorPenetration = 0.7,
    
    -- Firing properties
    FireRate = 0.8, -- Seconds between shots
    Range = 3000,
    Accuracy = 0.95,
    ProjectileSpeed = 1500,
    
    -- Energy properties
    EnergyPerShot = 25,
    HeatPerShot = 25,
    ChargeTime = 2.0,
    CooldownTime = 4.0,
    
    -- Ammunition properties
    AmmunitionType = "plasma_cells",
    MaxAmmunition = 50,
    ReloadTime = 3.0,
    
    -- Targeting properties
    TargetingRange = 3000,
    TargetingFOV = 45,
    AutoTargetEnabled = false,
    
    -- Thermal properties
    MaxHeat = 100,
    CooldownRate = 30,
    OverheatThreshold = 100,
    ThermalEfficiency = 0.85
}

-- Plasma properties
ENT.PlasmaProperties = {
    Temperature = 15000, -- Kelvin
    Density = 1.2, -- kg/m³
    Containment = "magnetic",
    StabilityTime = 5.0, -- Seconds
    DecayRate = 0.1 -- Per second
}

-- Effect definitions
ENT.Effects = {
    MuzzleFlash = "asc_plasma_blast",
    ChargingEffect = "asc_plasma_charge",
    OverheatEffect = "asc_system_sparks",
    ImpactEffect = "asc_plasma_explosion"
}

-- Sound definitions
ENT.Sounds = {
    Fire = "asc/weapons/plasma_cannon_fire.wav",
    Charge = "asc/weapons/plasma_cannon_charge.wav",
    Overheat = "ambient/energy/spark6.wav",
    Cooldown = "ambient/energy/weld2.wav",
    Reload = "asc/weapons/weapon_reload.wav"
}

-- Material definitions
ENT.Materials = {
    Entity = "entities/asc_plasma_cannon",
    Glow = "entities/asc_plasma_cannon_glow",
    Beam = "effects/asc_plasma_beam",
    Projectile = "effects/asc_plasma_bolt"
}

-- Model information
ENT.ModelInfo = {
    Model = "models/asc/weapons/plasma_cannon.mdl",
    Fallback = "models/props_c17/oildrum001.mdl",
    Scale = 1.0,
    Skin = 0,
    Bodygroups = {}
}

-- Attachment points
ENT.Attachments = {
    Muzzle = 1,
    Charge = 2,
    Cooling = 3,
    Power = 4
}

-- Weapon states
ENT.WeaponStates = {
    IDLE = 0,
    CHARGING = 1,
    FIRING = 2,
    RELOADING = 3,
    OVERHEATED = 4,
    COOLDOWN = 5
}

-- Get weapon state
function ENT:GetWeaponState()
    if self:GetOverheated() then
        return self.WeaponStates.OVERHEATED
    elseif self:GetIsCharging() then
        return self.WeaponStates.CHARGING
    else
        return self.WeaponStates.IDLE
    end
end

-- Get weapon status text
function ENT:GetStatusText()
    local state = self:GetWeaponState()
    
    if state == self.WeaponStates.OVERHEATED then
        return "OVERHEATED"
    elseif state == self.WeaponStates.CHARGING then
        return "CHARGING " .. math.floor(self:GetChargeLevel()) .. "%"
    elseif self:GetAutoTarget() then
        return "AUTO-TARGET ACTIVE"
    else
        return "READY"
    end
end

-- Get weapon efficiency
function ENT:GetEfficiency()
    local heatPenalty = self:GetHeatLevel() / 100
    local ammoPenalty = (1 - (self:GetCurrentAmmunition() / 50)) * 0.2
    
    return math.max(0.1, 1 - heatPenalty - ammoPenalty)
end

-- Check if weapon can fire
function ENT:CanFire()
    return not self:GetOverheated() and 
           self:GetCurrentAmmunition() > 0 and
           self:GetChargeLevel() >= 80
end

-- Get weapon range based on charge level
function ENT:GetEffectiveRange()
    local baseRange = self.WeaponConfig.Range
    local chargeMultiplier = self:GetChargeLevel() / 100
    
    return baseRange * (0.5 + chargeMultiplier * 0.5)
end

-- Get weapon damage based on charge level
function ENT:GetEffectiveDamage()
    local baseDamage = self.WeaponConfig.BaseDamage
    local chargeMultiplier = self:GetChargeLevel() / 100
    local efficiency = self:GetEfficiency()
    
    return baseDamage * chargeMultiplier * efficiency
end
