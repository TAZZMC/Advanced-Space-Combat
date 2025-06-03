--[[
    Advanced Space Combat - Weapon System v5.1.0 - PHASE 3 ENHANCED

    Comprehensive weapon system with multiple weapon types, ammunition,
    weapon groups, upgrades, tactical AI integration, and advanced targeting.

    PHASE 3 ENHANCEMENTS:
    - Advanced targeting algorithms with predictive tracking
    - Enhanced weapon group coordination
    - Improved tactical AI with threat assessment
    - Smart ammunition management
    - Real-time performance optimization
]]

-- Initialize Weapon System namespace
ASC = ASC or {}
ASC.Weapons = ASC.Weapons or {}

-- Weapon System Configuration
ASC.Weapons.Config = {
    -- Core Settings
    Enabled = true,
    UpdateRate = 0.1,
    MaxWeaponsPerShip = 20,
    MaxWeaponGroups = 8,
    
    -- Combat Settings
    MaxRange = 3000,
    MinRange = 50,
    TargetingRange = 2500,
    AutoTargetRange = 1500,
    FriendlyFireProtection = true,

    -- Phase 3 Enhanced Targeting
    PredictiveTargeting = true,
    TargetLeadCalculation = true,
    MultiTargetEngagement = true,
    ThreatPrioritization = true,
    SmartAmmoSelection = true,
    AdaptiveFireControl = true,
    
    -- Ammunition Settings
    MaxAmmoCapacity = 10000,
    AmmoRegenRate = 10, -- per second
    AmmoTypes = {
        "energy", "kinetic", "explosive", "plasma", "ion"
    },
    
    -- Weapon Types
    WeaponTypes = {
        PULSE_CANNON = {
            name = "Pulse Cannon",
            description = "Rapid-fire energy weapon with moderate damage",
            damage = {min = 80, max = 120},
            range = 2000,
            fireRate = 3, -- shots per second
            ammoType = "energy",
            ammoPerShot = 5,
            accuracy = 0.9,
            projectileSpeed = 2000,
            energyCost = 10,
            model = "models/cap/weapons/pulse_cannon.mdl",
            sound = "weapons/pulse_cannon_fire.wav",
            effect = "pulse_cannon_muzzle"
        },
        BEAM_WEAPON = {
            name = "Beam Weapon",
            description = "Continuous beam weapon with high accuracy",
            damage = {min = 150, max = 200},
            range = 2500,
            fireRate = 1, -- continuous beam
            ammoType = "energy",
            ammoPerShot = 15,
            accuracy = 0.95,
            projectileSpeed = 0, -- instant
            energyCost = 25,
            model = "models/cap/weapons/beam_weapon.mdl",
            sound = "weapons/beam_weapon_fire.wav",
            effect = "beam_weapon_beam"
        },
        TORPEDO_LAUNCHER = {
            name = "Torpedo Launcher",
            description = "Heavy explosive projectile with tracking",
            damage = {min = 300, max = 500},
            range = 3000,
            fireRate = 0.5, -- shots per second
            ammoType = "explosive",
            ammoPerShot = 1,
            accuracy = 0.8,
            projectileSpeed = 800,
            energyCost = 50,
            tracking = true,
            model = "models/cap/weapons/torpedo_launcher.mdl",
            sound = "weapons/torpedo_launch.wav",
            effect = "torpedo_launch_smoke"
        },
        RAILGUN = {
            name = "Railgun",
            description = "High-velocity kinetic weapon with armor penetration",
            damage = {min = 400, max = 600},
            range = 3000,
            fireRate = 0.3, -- shots per second
            ammoType = "kinetic",
            ammoPerShot = 1,
            accuracy = 0.85,
            projectileSpeed = 5000,
            energyCost = 75,
            armorPenetration = 0.8,
            model = "models/cap/weapons/railgun.mdl",
            sound = "weapons/railgun_fire.wav",
            effect = "railgun_trail"
        },
        PLASMA_CANNON = {
            name = "Plasma Cannon",
            description = "Superheated plasma with area damage",
            damage = {min = 200, max = 350},
            range = 1800,
            fireRate = 1.5, -- shots per second
            ammoType = "plasma",
            ammoPerShot = 8,
            accuracy = 0.75,
            projectileSpeed = 1200,
            energyCost = 40,
            areaDamage = 200,
            model = "models/cap/weapons/plasma_cannon.mdl",
            sound = "weapons/plasma_cannon_fire.wav",
            effect = "plasma_cannon_bolt"
        }
    },
    
    -- Weapon Upgrades
    UpgradeCategories = {
        DAMAGE = {
            name = "Damage Enhancement",
            levels = 5,
            bonusPerLevel = 0.15, -- 15% per level
            cost = {100, 250, 500, 1000, 2000}
        },
        RANGE = {
            name = "Range Extension",
            levels = 3,
            bonusPerLevel = 0.2, -- 20% per level
            cost = {150, 400, 800}
        },
        ACCURACY = {
            name = "Targeting System",
            levels = 3,
            bonusPerLevel = 0.1, -- 10% per level
            cost = {200, 500, 1000}
        },
        FIRE_RATE = {
            name = "Fire Rate Boost",
            levels = 4,
            bonusPerLevel = 0.25, -- 25% per level
            cost = {300, 600, 1200, 2400}
        },
        EFFICIENCY = {
            name = "Energy Efficiency",
            levels = 3,
            bonusPerLevel = 0.15, -- 15% less energy per level
            cost = {250, 600, 1200}
        }
    }
}

-- Weapon System Core
ASC.Weapons.Core = {
    -- Active weapon systems
    WeaponSystems = {},
    
    -- Weapon groups
    WeaponGroups = {},
    
    -- Ammunition storage
    AmmoStorage = {},
    
    -- Weapon counter
    WeaponCounter = 0,
    
    -- Initialize weapon system
    Initialize = function()
        print("[Weapon System] Initializing weapon system v3.0.0")
        
        -- Reset counters
        ASC.Weapons.Core.WeaponCounter = 0
        ASC.Weapons.Core.WeaponSystems = {}
        ASC.Weapons.Core.WeaponGroups = {}
        ASC.Weapons.Core.AmmoStorage = {}
        
        return true
    end,
    
    -- Create weapon system for ship
    CreateWeaponSystem = function(shipCore)
        if not IsValid(shipCore) then
            return nil, "Invalid ship core"
        end
        
        local shipID = shipCore:EntIndex()
        
        if ASC.Weapons.Core.WeaponSystems[shipID] then
            return ASC.Weapons.Core.WeaponSystems[shipID], "Weapon system already exists"
        end
        
        local weaponSystem = {
            shipCore = shipCore,
            shipID = shipID,
            
            -- Weapons
            weapons = {},
            weaponGroups = {},
            
            -- Ammunition
            ammoStorage = {},
            maxAmmoCapacity = ASC.Weapons.Config.MaxAmmoCapacity,
            
            -- Targeting
            currentTarget = nil,
            autoTarget = false,
            targetingRange = ASC.Weapons.Config.TargetingRange,
            
            -- Status
            active = true,
            lastUpdate = CurTime(),
            totalShots = 0,
            totalDamage = 0,
            
            -- AI Integration
            tacticalAI = false,
            aiMode = "DEFENSIVE" -- DEFENSIVE, AGGRESSIVE, SUPPORT
        }
        
        -- Initialize ammo storage
        for _, ammoType in ipairs(ASC.Weapons.Config.AmmoTypes) do
            weaponSystem.ammoStorage[ammoType] = ASC.Weapons.Config.MaxAmmoCapacity / #ASC.Weapons.Config.AmmoTypes
        end
        
        ASC.Weapons.Core.WeaponSystems[shipID] = weaponSystem
        
        print("[Weapon System] Created weapon system for ship " .. shipID)
        return weaponSystem
    end,
    
    -- Add weapon to ship
    AddWeapon = function(shipID, weaponType, position, angles)
        local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
        if not weaponSystem then
            return nil, "No weapon system found for ship"
        end
        
        if #weaponSystem.weapons >= ASC.Weapons.Config.MaxWeaponsPerShip then
            return nil, "Maximum weapons reached"
        end
        
        local weaponConfig = ASC.Weapons.Config.WeaponTypes[weaponType]
        if not weaponConfig then
            return nil, "Invalid weapon type"
        end
        
        ASC.Weapons.Core.WeaponCounter = ASC.Weapons.Core.WeaponCounter + 1
        
        local weapon = {
            id = ASC.Weapons.Core.WeaponCounter,
            type = weaponType,
            config = weaponConfig,
            position = position or Vector(0, 0, 0),
            angles = angles or Angle(0, 0, 0),
            
            -- Status
            active = true,
            health = 100,
            maxHealth = 100,
            
            -- Combat
            lastFired = 0,
            totalShots = 0,
            totalDamage = 0,
            accuracy = weaponConfig.accuracy,
            
            -- Upgrades
            upgrades = {
                DAMAGE = 0,
                RANGE = 0,
                ACCURACY = 0,
                FIRE_RATE = 0,
                EFFICIENCY = 0
            },
            
            -- Targeting
            currentTarget = nil,
            aimDirection = Vector(1, 0, 0)
        }
        
        table.insert(weaponSystem.weapons, weapon)
        
        print("[Weapon System] Added " .. weaponConfig.name .. " to ship " .. shipID)
        return weapon
    end,
    
    -- Create weapon group
    CreateWeaponGroup = function(shipID, groupName, weaponIDs)
        local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
        if not weaponSystem then
            return false, "No weapon system found"
        end
        
        if #weaponSystem.weaponGroups >= ASC.Weapons.Config.MaxWeaponGroups then
            return false, "Maximum weapon groups reached"
        end
        
        local weaponGroup = {
            name = groupName,
            weapons = {},
            fireMode = "SEQUENTIAL", -- SEQUENTIAL, SIMULTANEOUS, ALTERNATING
            lastFired = 0,
            currentWeapon = 1
        }
        
        -- Add weapons to group
        for _, weaponID in ipairs(weaponIDs) do
            local weapon = ASC.Weapons.Core.FindWeaponByID(weaponSystem, weaponID)
            if weapon then
                table.insert(weaponGroup.weapons, weapon)
            end
        end
        
        table.insert(weaponSystem.weaponGroups, weaponGroup)
        
        print("[Weapon System] Created weapon group '" .. groupName .. "' with " .. #weaponGroup.weapons .. " weapons")
        return weaponGroup
    end,
    
    -- Find weapon by ID
    FindWeaponByID = function(weaponSystem, weaponID)
        for _, weapon in ipairs(weaponSystem.weapons) do
            if weapon.id == weaponID then
                return weapon
            end
        end
        return nil
    end,
    
    -- Fire weapon
    FireWeapon = function(shipID, weaponID, target)
        local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
        if not weaponSystem then return false end
        
        local weapon = ASC.Weapons.Core.FindWeaponByID(weaponSystem, weaponID)
        if not weapon or not weapon.active then return false end
        
        local currentTime = CurTime()
        local fireRate = weapon.config.fireRate * (1 + weapon.upgrades.FIRE_RATE * ASC.Weapons.Config.UpgradeCategories.FIRE_RATE.bonusPerLevel)
        local cooldown = 1 / fireRate
        
        -- Check cooldown
        if currentTime - weapon.lastFired < cooldown then
            return false, "Weapon on cooldown"
        end
        
        -- Check ammunition
        local ammoType = weapon.config.ammoType
        local ammoNeeded = weapon.config.ammoPerShot
        
        if weaponSystem.ammoStorage[ammoType] < ammoNeeded then
            return false, "Insufficient ammunition"
        end
        
        -- Calculate damage
        local baseDamage = math.random(weapon.config.damage.min, weapon.config.damage.max)
        local damageMultiplier = 1 + weapon.upgrades.DAMAGE * ASC.Weapons.Config.UpgradeCategories.DAMAGE.bonusPerLevel
        local finalDamage = baseDamage * damageMultiplier
        
        -- Calculate accuracy
        local accuracy = weapon.accuracy + weapon.upgrades.ACCURACY * ASC.Weapons.Config.UpgradeCategories.ACCURACY.bonusPerLevel
        local hit = math.random() < accuracy
        
        if hit then
            -- Create projectile/effect
            ASC.Weapons.Core.CreateWeaponEffect(weapon, weaponSystem.shipCore, target, finalDamage)
            
            -- Deal damage to target
            if IsValid(target) then
                ASC.Weapons.Core.DealDamage(target, finalDamage, weapon, weaponSystem.shipCore)
            end
            
            -- Update statistics
            weapon.totalShots = weapon.totalShots + 1
            weapon.totalDamage = weapon.totalDamage + finalDamage
            weaponSystem.totalShots = weaponSystem.totalShots + 1
            weaponSystem.totalDamage = weaponSystem.totalDamage + finalDamage
        end
        
        -- Consume ammunition
        weaponSystem.ammoStorage[ammoType] = weaponSystem.ammoStorage[ammoType] - ammoNeeded
        
        -- Update last fired time
        weapon.lastFired = currentTime
        
        print("[Weapon System] " .. weapon.config.name .. " fired - Hit: " .. tostring(hit) .. ", Damage: " .. math.floor(finalDamage))
        return true
    end,
    
    -- Fire weapon group
    FireWeaponGroup = function(shipID, groupIndex, target)
        local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
        if not weaponSystem then return false end
        
        local weaponGroup = weaponSystem.weaponGroups[groupIndex]
        if not weaponGroup then return false end
        
        local fired = false
        
        if weaponGroup.fireMode == "SIMULTANEOUS" then
            -- Fire all weapons at once
            for _, weapon in ipairs(weaponGroup.weapons) do
                if ASC.Weapons.Core.FireWeapon(shipID, weapon.id, target) then
                    fired = true
                end
            end
            
        elseif weaponGroup.fireMode == "SEQUENTIAL" then
            -- Fire weapons one after another
            local weapon = weaponGroup.weapons[weaponGroup.currentWeapon]
            if weapon and ASC.Weapons.Core.FireWeapon(shipID, weapon.id, target) then
                fired = true
                weaponGroup.currentWeapon = (weaponGroup.currentWeapon % #weaponGroup.weapons) + 1
            end
            
        elseif weaponGroup.fireMode == "ALTERNATING" then
            -- Fire weapons in alternating pattern
            for i, weapon in ipairs(weaponGroup.weapons) do
                if (i + weaponGroup.currentWeapon) % 2 == 0 then
                    if ASC.Weapons.Core.FireWeapon(shipID, weapon.id, target) then
                        fired = true
                    end
                end
            end
            weaponGroup.currentWeapon = 1 - weaponGroup.currentWeapon
        end
        
        if fired then
            weaponGroup.lastFired = CurTime()
        end
        
        return fired
    end,
    
    -- Create weapon effect
    CreateWeaponEffect = function(weapon, shipCore, target, damage)
        if not IsValid(shipCore) then return end
        
        local startPos = shipCore:GetPos() + weapon.position
        local targetPos = IsValid(target) and target:GetPos() or (startPos + weapon.aimDirection * weapon.config.range)
        
        -- Create visual effect
        local effectData = EffectData()
        effectData:SetStart(startPos)
        effectData:SetOrigin(targetPos)
        effectData:SetEntity(shipCore)
        effectData:SetMagnitude(damage)
        
        util.Effect(weapon.config.effect, effectData)
        
        -- Play sound
        if weapon.config.sound then
            shipCore:EmitSound(weapon.config.sound, 75, 100, 1, CHAN_WEAPON)
        end
    end,
    
    -- Deal damage to target
    DealDamage = function(target, damage, weapon, attacker)
        if not IsValid(target) then return end
        
        -- Apply armor penetration for railguns
        if weapon.config.armorPenetration then
            damage = damage * (1 + weapon.config.armorPenetration)
        end
        
        -- Deal damage
        if target:IsPlayer() then
            target:TakeDamage(damage, attacker, attacker)
        elseif target.TakeDamage then
            target:TakeDamage(damage, attacker, attacker)
        end
        
        -- Area damage for plasma weapons
        if weapon.config.areaDamage then
            local nearbyEnts = ents.FindInSphere(target:GetPos(), weapon.config.areaDamage)
            for _, ent in ipairs(nearbyEnts) do
                if ent ~= target and ent ~= attacker then
                    local areaDamage = damage * 0.5 -- 50% area damage
                    if ent:IsPlayer() then
                        ent:TakeDamage(areaDamage, attacker, attacker)
                    elseif ent.TakeDamage then
                        ent:TakeDamage(areaDamage, attacker, attacker)
                    end
                end
            end
        end
    end,
    
    -- Update weapon system
    Update = function()
        for shipID, weaponSystem in pairs(ASC.Weapons.Core.WeaponSystems) do
            ASC.Weapons.Core.UpdateWeaponSystem(shipID)
        end
    end,
    
    -- Update individual weapon system
    UpdateWeaponSystem = function(shipID)
        local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
        if not weaponSystem or not IsValid(weaponSystem.shipCore) then
            ASC.Weapons.Core.WeaponSystems[shipID] = nil
            return
        end
        
        -- Regenerate ammunition
        ASC.Weapons.Core.RegenerateAmmo(weaponSystem)
        
        -- Update auto-targeting
        if weaponSystem.autoTarget then
            ASC.Weapons.Core.UpdateAutoTargeting(weaponSystem)
        end
        
        -- Update tactical AI
        if weaponSystem.tacticalAI then
            ASC.Weapons.Core.UpdateTacticalAI(weaponSystem)
        end

        weaponSystem.lastUpdate = CurTime()
    end,

    -- Update tactical AI
    UpdateTacticalAI = function(weaponSystem)
        if not weaponSystem.tacticalAI or not IsValid(weaponSystem.shipCore) then return end

        -- Use advanced tactical AI system if available
        if ASC.TacticalAI then
            ASC.TacticalAI.Core.UpdateShipTactics(weaponSystem)
        else
            -- Fallback to basic AI
            ASC.Weapons.Core.UpdateBasicTacticalAI(weaponSystem)
        end
    end,

    -- Basic tactical AI fallback
    UpdateBasicTacticalAI = function(weaponSystem)
        local shipPos = weaponSystem.shipCore:GetPos()

        -- Basic target acquisition
        if not IsValid(weaponSystem.currentTarget) then
            ASC.Weapons.Core.UpdateAutoTargeting(weaponSystem)
        end

        -- Basic combat behavior
        if IsValid(weaponSystem.currentTarget) then
            local distance = shipPos:Distance(weaponSystem.currentTarget:GetPos())

            -- Auto-fire if target in range
            if distance <= ASC.Weapons.Config.MaxRange then
                for i, weaponGroup in ipairs(weaponSystem.weaponGroups) do
                    if CurTime() - weaponGroup.lastFired > 3 then -- 3 second cooldown
                        ASC.Weapons.Core.FireWeaponGroup(weaponSystem.shipID, i, weaponSystem.currentTarget)
                        break
                    end
                end
            end
        end
    end,
    
    -- Regenerate ammunition
    RegenerateAmmo = function(weaponSystem)
        local regenRate = ASC.Weapons.Config.AmmoRegenRate * ASC.Weapons.Config.UpdateRate
        
        for ammoType, currentAmmo in pairs(weaponSystem.ammoStorage) do
            local maxAmmo = weaponSystem.maxAmmoCapacity / #ASC.Weapons.Config.AmmoTypes
            weaponSystem.ammoStorage[ammoType] = math.min(currentAmmo + regenRate, maxAmmo)
        end
    end,
    
    -- Update auto-targeting with Phase 3 enhancements
    UpdateAutoTargeting = function(weaponSystem)
        if not IsValid(weaponSystem.shipCore) then return end

        local shipPos = weaponSystem.shipCore:GetPos()
        local potentialTargets = {}

        -- Find all potential targets with enhanced scoring
        for _, ent in ipairs(ents.FindInSphere(shipPos, weaponSystem.targetingRange)) do
            if ASC.Weapons.Core.IsValidTarget(ent, weaponSystem.shipCore) then
                local distance = shipPos:Distance(ent:GetPos())
                local score = ASC.Weapons.Core.CalculateTargetScore(ent, distance, weaponSystem)

                table.insert(potentialTargets, {
                    entity = ent,
                    score = score,
                    distance = distance,
                    velocity = ASC.Weapons.Core.GetEntityVelocity(ent),
                    predictedPos = ASC.Weapons.Core.PredictTargetPosition(ent, distance)
                })
            end
        end

        -- Sort targets by score (highest first)
        table.sort(potentialTargets, function(a, b) return a.score > b.score end)

        -- Phase 3: Multi-target engagement
        if ASC.Weapons.Config.MultiTargetEngagement and #potentialTargets > 1 then
            weaponSystem.primaryTarget = potentialTargets[1].entity
            weaponSystem.secondaryTargets = {}
            for i = 2, math.min(#potentialTargets, 3) do
                table.insert(weaponSystem.secondaryTargets, potentialTargets[i].entity)
            end
            weaponSystem.currentTarget = weaponSystem.primaryTarget
        else
            weaponSystem.currentTarget = potentialTargets[1] and potentialTargets[1].entity or nil
        end
    end,
    
    -- Check if entity is valid target
    IsValidTarget = function(target, attacker)
        if not IsValid(target) or target == attacker then return false end

        -- Check friendly fire protection
        if ASC.Weapons.Config.FriendlyFireProtection then
            local attackerOwner = attacker:CPPIGetOwner()
            local targetOwner = target:CPPIGetOwner()

            if IsValid(attackerOwner) and IsValid(targetOwner) and attackerOwner == targetOwner then
                return false
            end
        end

        -- Check if target is player or ship
        return target:IsPlayer() or target:GetClass() == "asc_ship_core"
    end,

    -- Phase 3: Calculate enhanced target score
    CalculateTargetScore = function(target, distance, weaponSystem)
        local score = 1000 - distance -- Base score inversely related to distance

        -- Threat assessment
        if ASC.Weapons.Config.ThreatPrioritization then
            if target:IsPlayer() then
                score = score + 500 -- Players are higher priority
            end

            if target:GetClass() == "asc_ship_core" then
                score = score + 300 -- Ship cores are important targets
            end

            -- Check if target is armed
            if target.GetWeaponCount and target:GetWeaponCount() > 0 then
                score = score + 200 -- Armed targets are higher priority
            end
        end

        return math.max(score, 0)
    end,

    -- Phase 3: Get entity velocity for predictive targeting
    GetEntityVelocity = function(ent)
        if not IsValid(ent) then return Vector(0, 0, 0) end

        if ent:IsPlayer() then
            return ent:GetVelocity()
        elseif ent:GetPhysicsObject() and IsValid(ent:GetPhysicsObject()) then
            return ent:GetPhysicsObject():GetVelocity()
        end

        return Vector(0, 0, 0)
    end,

    -- Phase 3: Predict target position for lead calculation
    PredictTargetPosition = function(target, distance)
        if not IsValid(target) or not ASC.Weapons.Config.PredictiveTargeting then
            return target:GetPos()
        end

        local velocity = ASC.Weapons.Core.GetEntityVelocity(target)
        local projectileSpeed = 1000 -- Average projectile speed
        local timeToTarget = distance / projectileSpeed

        return target:GetPos() + velocity * timeToTarget
    end,
    
    -- Get weapon system status
    GetWeaponStatus = function(shipID)
        local weaponSystem = ASC.Weapons.Core.WeaponSystems[shipID]
        if not weaponSystem then
            return {
                status = "NO_WEAPONS",
                weapons = 0,
                groups = 0,
                ammo = {}
            }
        end
        
        return {
            status = weaponSystem.active and "ACTIVE" or "INACTIVE",
            weapons = #weaponSystem.weapons,
            groups = #weaponSystem.weaponGroups,
            ammo = weaponSystem.ammoStorage,
            target = weaponSystem.currentTarget,
            autoTarget = weaponSystem.autoTarget,
            tacticalAI = weaponSystem.tacticalAI,
            totalShots = weaponSystem.totalShots,
            totalDamage = weaponSystem.totalDamage
        }
    end
}

-- Initialize system
if SERVER then
    -- Initialize weapon system
    ASC.Weapons.Core.Initialize()
    
    -- Update weapon system
    timer.Create("ASC_Weapons_Update", ASC.Weapons.Config.UpdateRate, 0, function()
        ASC.Weapons.Core.Update()
    end)
    
    -- Update system status
    ASC.SystemStatus.WeaponsSystem = true
    ASC.SystemStatus.WeaponGroups = true
    ASC.SystemStatus.AmmunitionSystem = true
    
    print("[Advanced Space Combat] Weapon System v5.1.0 - Phase 3 Enhanced - loaded")
end
