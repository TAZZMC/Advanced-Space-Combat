-- Enhanced Hyperdrive Weapon Upgrades System v2.2.1
-- Advanced weapon modification and enhancement system

print("[Hyperdrive Weapons] Weapon Upgrades System v2.2.1 - Initializing...")

-- Initialize upgrades namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.WeaponUpgrades = HYPERDRIVE.WeaponUpgrades or {}

-- Weapon upgrades configuration
HYPERDRIVE.WeaponUpgrades.Config = {
    MaxUpgradeLevel = 10,
    UpgradeCosts = {
        [1] = {energy = 100, materials = 50},
        [2] = {energy = 200, materials = 100},
        [3] = {energy = 400, materials = 200},
        [4] = {energy = 800, materials = 400},
        [5] = {energy = 1600, materials = 800},
        [6] = {energy = 3200, materials = 1600},
        [7] = {energy = 6400, materials = 3200},
        [8] = {energy = 12800, materials = 6400},
        [9] = {energy = 25600, materials = 12800},
        [10] = {energy = 51200, materials = 25600}
    },
    
    -- Upgrade types and their effects
    UpgradeTypes = {
        damage = {
            name = "Damage Enhancement",
            description = "Increases weapon damage output",
            maxLevel = 10,
            effect = function(level) return 1 + (level * 0.15) end, -- +15% per level
            compatible = {"all"}
        },
        
        fire_rate = {
            name = "Fire Rate Optimization",
            description = "Increases weapon firing rate",
            maxLevel = 8,
            effect = function(level) return 1 + (level * 0.1) end, -- +10% per level
            compatible = {"hyperdrive_pulse_cannon", "hyperdrive_plasma_cannon", "hyperdrive_railgun"}
        },
        
        range = {
            name = "Range Extension",
            description = "Extends weapon effective range",
            maxLevel = 6,
            effect = function(level) return 1 + (level * 0.2) end, -- +20% per level
            compatible = {"all"}
        },
        
        efficiency = {
            name = "Energy Efficiency",
            description = "Reduces energy consumption",
            maxLevel = 8,
            effect = function(level) return 1 - (level * 0.08) end, -- -8% per level
            compatible = {"all"}
        },
        
        heat_management = {
            name = "Heat Management",
            description = "Improves cooling and heat dissipation",
            maxLevel = 6,
            effect = function(level) return 1 + (level * 0.25) end, -- +25% cooling per level
            compatible = {"hyperdrive_beam_weapon", "hyperdrive_plasma_cannon", "hyperdrive_railgun"}
        },
        
        accuracy = {
            name = "Targeting Accuracy",
            description = "Improves weapon accuracy and tracking",
            maxLevel = 5,
            effect = function(level) return 1 + (level * 0.1) end, -- +10% accuracy per level
            compatible = {"all"}
        },
        
        penetration = {
            name = "Armor Penetration",
            description = "Increases armor penetration capability",
            maxLevel = 8,
            effect = function(level) return 1 + (level * 0.12) end, -- +12% penetration per level
            compatible = {"hyperdrive_railgun", "hyperdrive_torpedo_launcher"}
        },
        
        splash_damage = {
            name = "Area Effect Enhancement",
            description = "Increases splash damage and radius",
            maxLevel = 6,
            effect = function(level) return 1 + (level * 0.15) end, -- +15% splash per level
            compatible = {"hyperdrive_plasma_cannon", "hyperdrive_torpedo_launcher"}
        },
        
        beam_focus = {
            name = "Beam Focus",
            description = "Improves beam coherence and damage concentration",
            maxLevel = 7,
            effect = function(level) return 1 + (level * 0.18) end, -- +18% focus per level
            compatible = {"hyperdrive_beam_weapon"}
        },
        
        charge_speed = {
            name = "Charge Acceleration",
            description = "Reduces weapon charge time",
            maxLevel = 5,
            effect = function(level) return 1 - (level * 0.15) end, -- -15% charge time per level
            compatible = {"hyperdrive_railgun", "hyperdrive_plasma_cannon"}
        }
    }
}

-- Weapon upgrades registry
HYPERDRIVE.WeaponUpgrades.WeaponUpgrades = {} -- weapon entity -> upgrades
HYPERDRIVE.WeaponUpgrades.UpgradeStations = {} -- upgrade station entities

-- Weapon upgrade data class
local WeaponUpgradeData = {}
WeaponUpgradeData.__index = WeaponUpgradeData

function WeaponUpgradeData:New(weapon)
    local data = setmetatable({}, WeaponUpgradeData)
    
    data.weapon = weapon
    data.upgrades = {}
    data.totalLevel = 0
    data.upgradePoints = 0
    
    -- Initialize all upgrade types
    for upgradeType, _ in pairs(HYPERDRIVE.WeaponUpgrades.Config.UpgradeTypes) do
        data.upgrades[upgradeType] = 0
    end
    
    return data
end

function WeaponUpgradeData:CanUpgrade(upgradeType)
    local upgradeConfig = HYPERDRIVE.WeaponUpgrades.Config.UpgradeTypes[upgradeType]
    if not upgradeConfig then return false, "Invalid upgrade type" end
    
    local currentLevel = self.upgrades[upgradeType] or 0
    if currentLevel >= upgradeConfig.maxLevel then
        return false, "Maximum upgrade level reached"
    end
    
    if self.totalLevel >= HYPERDRIVE.WeaponUpgrades.Config.MaxUpgradeLevel then
        return false, "Maximum total upgrade level reached"
    end
    
    -- Check compatibility
    local weaponClass = self.weapon:GetClass()
    local compatible = false
    
    for _, compatibleWeapon in ipairs(upgradeConfig.compatible) do
        if compatibleWeapon == "all" or compatibleWeapon == weaponClass then
            compatible = true
            break
        end
    end
    
    if not compatible then
        return false, "Upgrade not compatible with this weapon"
    end
    
    return true
end

function WeaponUpgradeData:GetUpgradeCost(upgradeType)
    local currentLevel = self.upgrades[upgradeType] or 0
    local nextLevel = currentLevel + 1
    
    local baseCost = HYPERDRIVE.WeaponUpgrades.Config.UpgradeCosts[nextLevel]
    if not baseCost then return nil end
    
    -- Scale cost based on upgrade type complexity
    local upgradeConfig = HYPERDRIVE.WeaponUpgrades.Config.UpgradeTypes[upgradeType]
    local complexity = upgradeConfig.maxLevel / 10 -- Complexity factor
    
    return {
        energy = math.floor(baseCost.energy * (1 + complexity)),
        materials = math.floor(baseCost.materials * (1 + complexity))
    }
end

function WeaponUpgradeData:ApplyUpgrade(upgradeType)
    local canUpgrade, reason = self:CanUpgrade(upgradeType)
    if not canUpgrade then return false, reason end
    
    -- Check resources
    local cost = self:GetUpgradeCost(upgradeType)
    if not cost then return false, "Cannot determine upgrade cost" end
    
    local shipCore = nil
    if self.weapon.weapon and self.weapon.weapon.shipCore then
        shipCore = self.weapon.weapon.shipCore
    end
    
    if IsValid(shipCore) and HYPERDRIVE.SB3Resources then
        local hasEnergy = HYPERDRIVE.SB3Resources.GetResource(shipCore, "energy") >= cost.energy
        local hasMaterials = HYPERDRIVE.SB3Resources.GetResource(shipCore, "materials") >= cost.materials
        
        if not hasEnergy then return false, "Insufficient energy" end
        if not hasMaterials then return false, "Insufficient materials" end
        
        -- Consume resources
        HYPERDRIVE.SB3Resources.ConsumeResource(shipCore, "energy", cost.energy)
        HYPERDRIVE.SB3Resources.ConsumeResource(shipCore, "materials", cost.materials)
    end
    
    -- Apply upgrade
    self.upgrades[upgradeType] = (self.upgrades[upgradeType] or 0) + 1
    self.totalLevel = self.totalLevel + 1
    
    -- Update weapon properties
    self:UpdateWeaponProperties()
    
    local upgradeConfig = HYPERDRIVE.WeaponUpgrades.Config.UpgradeTypes[upgradeType]
    print("[Weapon Upgrades] Applied " .. upgradeConfig.name .. " level " .. self.upgrades[upgradeType] .. " to " .. self.weapon:GetClass())
    
    return true
end

function WeaponUpgradeData:UpdateWeaponProperties()
    if not IsValid(self.weapon) or not self.weapon.weapon then return end
    
    local weapon = self.weapon.weapon
    local baseStats = self:GetBaseStats()
    
    -- Apply all upgrades
    local damageMultiplier = 1
    local fireRateMultiplier = 1
    local rangeMultiplier = 1
    local efficiencyMultiplier = 1
    local heatMultiplier = 1
    local accuracyMultiplier = 1
    local penetrationMultiplier = 1
    local splashMultiplier = 1
    local beamFocusMultiplier = 1
    local chargeSpeedMultiplier = 1
    
    for upgradeType, level in pairs(self.upgrades) do
        if level > 0 then
            local upgradeConfig = HYPERDRIVE.WeaponUpgrades.Config.UpgradeTypes[upgradeType]
            local effect = upgradeConfig.effect(level)
            
            if upgradeType == "damage" then
                damageMultiplier = damageMultiplier * effect
            elseif upgradeType == "fire_rate" then
                fireRateMultiplier = fireRateMultiplier * effect
            elseif upgradeType == "range" then
                rangeMultiplier = rangeMultiplier * effect
            elseif upgradeType == "efficiency" then
                efficiencyMultiplier = efficiencyMultiplier * effect
            elseif upgradeType == "heat_management" then
                heatMultiplier = heatMultiplier * effect
            elseif upgradeType == "accuracy" then
                accuracyMultiplier = accuracyMultiplier * effect
            elseif upgradeType == "penetration" then
                penetrationMultiplier = penetrationMultiplier * effect
            elseif upgradeType == "splash_damage" then
                splashMultiplier = splashMultiplier * effect
            elseif upgradeType == "beam_focus" then
                beamFocusMultiplier = beamFocusMultiplier * effect
            elseif upgradeType == "charge_speed" then
                chargeSpeedMultiplier = chargeSpeedMultiplier * effect
            end
        end
    end
    
    -- Update weapon properties
    weapon.damage = baseStats.damage * damageMultiplier
    weapon.fireRate = baseStats.fireRate * fireRateMultiplier
    weapon.range = baseStats.range * rangeMultiplier
    weapon.energyCost = baseStats.energyCost * efficiencyMultiplier
    weapon.accuracy = baseStats.accuracy * accuracyMultiplier
    
    -- Update weapon-specific properties
    if self.weapon.SetRange then self.weapon:SetRange(weapon.range) end
    if self.weapon.SetDamage then self.weapon:SetDamage(weapon.damage) end
    if self.weapon.SetFireRate then self.weapon:SetFireRate(weapon.fireRate) end
    
    -- Special properties
    if self.weapon.SetPenetrationPower and penetrationMultiplier > 1 then
        local basePenetration = self.weapon:GetPenetrationPower() or 1
        self.weapon:SetPenetrationPower(math.floor(basePenetration * penetrationMultiplier))
    end
    
    if self.weapon.SetSplashRadius and splashMultiplier > 1 then
        local baseSplash = self.weapon:GetSplashRadius() or 100
        self.weapon:SetSplashRadius(math.floor(baseSplash * splashMultiplier))
    end
    
    if self.weapon.SetChargeTime and chargeSpeedMultiplier < 1 then
        local baseCharge = self.weapon:GetChargeTime() or 3.0
        self.weapon:SetChargeTime(baseCharge * chargeSpeedMultiplier)
    end
end

function WeaponUpgradeData:GetBaseStats()
    -- Get base weapon stats (before upgrades)
    local weaponClass = self.weapon:GetClass()
    local config = HYPERDRIVE.Weapons.GetWeaponConfig(weaponClass)
    
    if config then
        return {
            damage = config.damage or 100,
            fireRate = config.fireRate or 1.0,
            range = config.range or 1000,
            energyCost = config.energyCost or 25,
            accuracy = 0.95
        }
    end
    
    -- Fallback defaults
    return {
        damage = 100,
        fireRate = 1.0,
        range = 1000,
        energyCost = 25,
        accuracy = 0.95
    }
end

function WeaponUpgradeData:GetStatus()
    return {
        weapon = self.weapon:GetClass(),
        upgrades = table.Copy(self.upgrades),
        totalLevel = self.totalLevel,
        upgradePoints = self.upgradePoints
    }
end

-- Main upgrade functions
function HYPERDRIVE.WeaponUpgrades.RegisterWeapon(weapon)
    if not IsValid(weapon) then return nil end
    
    local weaponId = weapon:EntIndex()
    local upgradeData = WeaponUpgradeData:New(weapon)
    HYPERDRIVE.WeaponUpgrades.WeaponUpgrades[weaponId] = upgradeData
    
    print("[Weapon Upgrades] Registered weapon: " .. weapon:GetClass())
    return upgradeData
end

function HYPERDRIVE.WeaponUpgrades.UnregisterWeapon(weapon)
    if not IsValid(weapon) then return end
    
    local weaponId = weapon:EntIndex()
    HYPERDRIVE.WeaponUpgrades.WeaponUpgrades[weaponId] = nil
    print("[Weapon Upgrades] Unregistered weapon: " .. weapon:GetClass())
end

function HYPERDRIVE.WeaponUpgrades.GetWeaponUpgrades(weapon)
    if not IsValid(weapon) then return nil end
    
    local weaponId = weapon:EntIndex()
    return HYPERDRIVE.WeaponUpgrades.WeaponUpgrades[weaponId]
end

function HYPERDRIVE.WeaponUpgrades.UpgradeWeapon(weapon, upgradeType)
    local upgradeData = HYPERDRIVE.WeaponUpgrades.GetWeaponUpgrades(weapon)
    if not upgradeData then
        upgradeData = HYPERDRIVE.WeaponUpgrades.RegisterWeapon(weapon)
    end
    
    return upgradeData:ApplyUpgrade(upgradeType)
end

function HYPERDRIVE.WeaponUpgrades.GetUpgradeOptions(weapon)
    local upgradeData = HYPERDRIVE.WeaponUpgrades.GetWeaponUpgrades(weapon)
    if not upgradeData then return {} end
    
    local options = {}
    local weaponClass = weapon:GetClass()
    
    for upgradeType, config in pairs(HYPERDRIVE.WeaponUpgrades.Config.UpgradeTypes) do
        local canUpgrade, reason = upgradeData:CanUpgrade(upgradeType)
        local cost = upgradeData:GetUpgradeCost(upgradeType)
        local currentLevel = upgradeData.upgrades[upgradeType] or 0
        
        table.insert(options, {
            type = upgradeType,
            name = config.name,
            description = config.description,
            currentLevel = currentLevel,
            maxLevel = config.maxLevel,
            canUpgrade = canUpgrade,
            reason = reason,
            cost = cost,
            effect = config.effect(currentLevel + 1)
        })
    end
    
    return options
end

-- Auto-register weapons when they're created
hook.Add("OnEntityCreated", "HyperdriveWeaponUpgradesAutoRegister", function(ent)
    timer.Simple(1, function()
        if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive_") and ent.weapon then
            HYPERDRIVE.WeaponUpgrades.RegisterWeapon(ent)
        end
    end)
end)

-- Clean up when weapons are removed
hook.Add("EntityRemoved", "HyperdriveWeaponUpgradesCleanup", function(ent)
    if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive_") then
        HYPERDRIVE.WeaponUpgrades.UnregisterWeapon(ent)
    end
end)

print("[Hyperdrive Weapons] Weapon Upgrades System loaded successfully!")
