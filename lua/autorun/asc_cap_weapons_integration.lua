-- Advanced Space Combat - CAP Weapons Integration System v2.0.0
-- Technology-specific weapon models, sounds, and effects using CAP assets
-- Enhanced weapon behavior based on Stargate technologies

print("[Advanced Space Combat] CAP Weapons Integration System v2.0.0 - Loading...")

-- Initialize CAP weapons namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.Weapons = ASC.CAP.Weapons or {}

-- Technology-specific weapon configurations
ASC.CAP.Weapons.TechnologyWeapons = {
    Ancient = {
        pulse_cannon = {
            model = "drone_weapon",
            sound_fire = "drone_fire",
            sound_charge = "drone_launch",
            projectile_model = "drone",
            damage_multiplier = 1.5,
            energy_cost_multiplier = 0.8,
            fire_rate_multiplier = 1.2,
            effect = "drone_trail",
            color = Color(100, 200, 255)
        },
        beam_weapon = {
            model = "satellite",
            sound_fire = "satellite_fire",
            sound_charge = "power_up",
            damage_multiplier = 2.0,
            energy_cost_multiplier = 1.0,
            fire_rate_multiplier = 1.0,
            effect = "satellite_beam",
            color = Color(150, 220, 255)
        },
        torpedo_launcher = {
            model = "drone_launcher",
            sound_fire = "drone_launch",
            sound_charge = "power_up",
            projectile_model = "drone",
            damage_multiplier = 1.8,
            energy_cost_multiplier = 1.2,
            fire_rate_multiplier = 0.9,
            effect = "drone_trail",
            color = Color(255, 150, 50)
        }
    },
    
    Goauld = {
        pulse_cannon = {
            model = "staff_cannon",
            sound_fire = "staff_fire",
            sound_charge = "staff_charge",
            damage_multiplier = 1.2,
            energy_cost_multiplier = 1.0,
            fire_rate_multiplier = 1.0,
            effect = "staff_blast",
            color = Color(255, 200, 50)
        },
        beam_weapon = {
            model = "staff_weapon",
            sound_fire = "staff_fire",
            sound_charge = "staff_charge",
            damage_multiplier = 1.3,
            energy_cost_multiplier = 0.9,
            fire_rate_multiplier = 1.1,
            effect = "staff_blast",
            color = Color(255, 150, 0)
        },
        torpedo_launcher = {
            model = "shock_grenade",
            sound_fire = "staff_fire",
            sound_charge = "power_up",
            damage_multiplier = 1.4,
            energy_cost_multiplier = 1.1,
            fire_rate_multiplier = 0.8,
            effect = "energy_beam",
            color = Color(255, 100, 50)
        }
    },
    
    Asgard = {
        pulse_cannon = {
            model = "beam_weapon",
            sound_fire = "beam_fire",
            sound_charge = "beam_charge",
            damage_multiplier = 1.6,
            energy_cost_multiplier = 0.7,
            fire_rate_multiplier = 1.3,
            effect = "energy_beam",
            color = Color(150, 150, 255)
        },
        beam_weapon = {
            model = "plasma_beam",
            sound_fire = "beam_fire",
            sound_charge = "beam_charge",
            damage_multiplier = 2.2,
            energy_cost_multiplier = 1.1,
            fire_rate_multiplier = 1.0,
            effect = "energy_beam",
            color = Color(100, 150, 255)
        },
        railgun = {
            model = "ion_cannon",
            sound_fire = "beam_fire",
            sound_charge = "beam_charge",
            damage_multiplier = 2.5,
            energy_cost_multiplier = 1.5,
            fire_rate_multiplier = 0.7,
            effect = "energy_beam",
            color = Color(200, 200, 255)
        }
    },
    
    Tauri = {
        pulse_cannon = {
            model = "plasma_cannon",
            sound_fire = "plasma_fire",
            sound_charge = "computer_beep",
            damage_multiplier = 1.0,
            energy_cost_multiplier = 1.0,
            fire_rate_multiplier = 1.0,
            effect = "energy_beam",
            color = Color(100, 255, 100)
        },
        railgun = {
            model = "railgun",
            sound_fire = "railgun_fire",
            sound_charge = "railgun_charge",
            damage_multiplier = 1.8,
            energy_cost_multiplier = 1.3,
            fire_rate_multiplier = 0.8,
            effect = "energy_beam",
            color = Color(150, 200, 255)
        },
        torpedo_launcher = {
            model = "missile",
            sound_fire = "missile_launch",
            sound_charge = "computer_confirm",
            damage_multiplier = 1.5,
            energy_cost_multiplier = 1.2,
            fire_rate_multiplier = 0.9,
            effect = "energy_beam",
            color = Color(100, 200, 255)
        }
    },
    
    Ori = {
        beam_weapon = {
            model = "beam_weapon",
            sound_fire = "beam_fire",
            sound_charge = "power_up",
            damage_multiplier = 2.5,
            energy_cost_multiplier = 1.2,
            fire_rate_multiplier = 0.9,
            effect = "energy_beam",
            color = Color(255, 255, 255)
        }
    },
    
    Wraith = {
        pulse_cannon = {
            model = "stunner",
            sound_fire = "stunner_fire",
            sound_charge = "organic_sound",
            damage_multiplier = 1.1,
            energy_cost_multiplier = 0.9,
            fire_rate_multiplier = 1.1,
            effect = "energy_field",
            color = Color(100, 255, 100)
        }
    }
}

-- Apply CAP weapon configuration to entity
function ASC.CAP.Weapons.ApplyWeaponConfiguration(weapon, technology, weaponType)
    if not IsValid(weapon) then return false end
    
    local techWeapons = ASC.CAP.Weapons.TechnologyWeapons[technology]
    if not techWeapons or not techWeapons[weaponType] then
        return false
    end
    
    local config = techWeapons[weaponType]
    
    -- Apply model
    if config.model and ASC.CAP.Assets then
        local model = ASC.CAP.Assets.GetModel(technology, config.model, weapon:GetModel())
        if model then
            weapon:SetModel(model)
        end
    end
    
    -- Store weapon configuration
    weapon.CAPWeaponConfig = config
    weapon.CAPTechnology = technology
    weapon.CAPWeaponType = weaponType
    
    -- Apply damage multiplier
    if config.damage_multiplier and weapon.SetDamageMultiplier then
        weapon:SetDamageMultiplier(config.damage_multiplier)
    elseif config.damage_multiplier then
        weapon.CAPDamageMultiplier = config.damage_multiplier
    end
    
    -- Apply energy cost multiplier
    if config.energy_cost_multiplier then
        weapon.CAPEnergyCostMultiplier = config.energy_cost_multiplier
    end
    
    -- Apply fire rate multiplier
    if config.fire_rate_multiplier then
        weapon.CAPFireRateMultiplier = config.fire_rate_multiplier
    end
    
    -- Set color
    if config.color then
        weapon:SetColor(config.color)
    end
    
    print("[ASC CAP Weapons] Applied " .. technology .. " " .. weaponType .. " configuration")
    return true
end

-- Play CAP weapon sound
function ASC.CAP.Weapons.PlayWeaponSound(weapon, soundType)
    if not IsValid(weapon) then return false end
    if not weapon.CAPWeaponConfig then return false end
    
    local config = weapon.CAPWeaponConfig
    local technology = weapon.CAPTechnology
    
    local soundName = config["sound_" .. soundType]
    if not soundName then return false end
    
    if ASC.CAP.Assets then
        local sound = ASC.CAP.Assets.GetSound(technology, soundName, "")
        if sound and sound ~= "" then
            weapon:EmitSound(sound, 75, 100)
            return true
        end
    end
    
    return false
end

-- Create CAP weapon projectile
function ASC.CAP.Weapons.CreateProjectile(weapon, target)
    if not IsValid(weapon) then return end
    if not weapon.CAPWeaponConfig then return end
    
    local config = weapon.CAPWeaponConfig
    local technology = weapon.CAPTechnology
    
    -- Create projectile entity
    local projectile = ents.Create("asc_cap_projectile")
    if not IsValid(projectile) then return end
    
    projectile:SetPos(weapon:GetPos() + weapon:GetForward() * 50)
    projectile:SetAngles(weapon:GetAngles())
    projectile:SetOwner(weapon:GetOwner())
    projectile:Spawn()
    
    -- Apply CAP configuration
    if config.projectile_model and ASC.CAP.Assets then
        local model = ASC.CAP.Assets.GetModel(technology, config.projectile_model, projectile:GetModel())
        if model then
            projectile:SetModel(model)
        end
    end
    
    if config.color then
        projectile:SetColor(config.color)
    end
    
    -- Set damage
    local baseDamage = weapon.Damage or 75
    local damage = baseDamage * (config.damage_multiplier or 1.0)
    projectile:SetDamage(damage)
    
    -- Set velocity
    local phys = projectile:GetPhysicsObject()
    if IsValid(phys) then
        local speed = weapon.ProjectileSpeed or 1000
        phys:SetVelocity(weapon:GetForward() * speed)
    end
    
    -- Store effect information
    projectile.CAPEffect = config.effect
    projectile.CAPTechnology = technology
    
    return projectile
end

-- Create CAP weapon effects
function ASC.CAP.Weapons.CreateWeaponEffects(weapon, effectType)
    if not IsValid(weapon) then return end
    if not weapon.CAPWeaponConfig then return end
    
    local config = weapon.CAPWeaponConfig
    local technology = weapon.CAPTechnology
    
    -- Create particle effect
    if ASC.CAP.Effects then
        ASC.CAP.Effects.CreateParticleEffect(weapon, technology, effectType, 2)
    end
    
    -- Create muzzle flash
    local effectData = EffectData()
    effectData:SetOrigin(weapon:GetPos() + weapon:GetForward() * 30)
    effectData:SetNormal(weapon:GetForward())
    effectData:SetEntity(weapon)
    
    if config.effect then
        util.Effect(config.effect, effectData)
    end
end

-- Hook into weapon firing
hook.Add("ASC_WeaponFired", "ASC_CAP_Weapons", function(weapon, target, damage)
    if not IsValid(weapon) then return end
    
    -- Play firing sound
    ASC.CAP.Weapons.PlayWeaponSound(weapon, "fire")
    
    -- Create effects
    ASC.CAP.Weapons.CreateWeaponEffects(weapon, "fire")
    
    -- Apply damage multiplier
    if weapon.CAPDamageMultiplier then
        return damage * weapon.CAPDamageMultiplier
    end
end)

-- Auto-configure weapons when spawned
hook.Add("OnEntityCreated", "ASC_CAP_Weapons", function(entity)
    timer.Simple(0.1, function()
        if not IsValid(entity) then return end
        
        local class = entity:GetClass()
        local weaponType = nil
        
        -- Determine weapon type
        if string.find(class, "pulse_cannon") then
            weaponType = "pulse_cannon"
        elseif string.find(class, "beam_weapon") then
            weaponType = "beam_weapon"
        elseif string.find(class, "torpedo") then
            weaponType = "torpedo_launcher"
        elseif string.find(class, "railgun") then
            weaponType = "railgun"
        end
        
        if weaponType then
            -- Get technology from owner or ship core
            local technology = "Ancient"
            local owner = entity:GetOwner()
            
            if IsValid(owner) and owner:IsPlayer() then
                if ASC.CAP.Enhanced then
                    technology = ASC.CAP.Enhanced.GetBestAvailableTechnology(owner)
                end
            end
            
            -- Apply CAP weapon configuration
            ASC.CAP.Weapons.ApplyWeaponConfiguration(entity, technology, weaponType)
        end
    end)
end)

-- Console commands
if SERVER then
    concommand.Add("asc_cap_configure_weapon", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        
        local trace = ply:GetEyeTrace()
        local weapon = trace.Entity
        
        if not IsValid(weapon) then
            ply:ChatPrint("No valid weapon found")
            return
        end
        
        local technology = args[1] or "Ancient"
        local weaponType = args[2] or "pulse_cannon"
        
        local success = ASC.CAP.Weapons.ApplyWeaponConfiguration(weapon, technology, weaponType)
        if success then
            ply:ChatPrint("Applied " .. technology .. " " .. weaponType .. " configuration")
        else
            ply:ChatPrint("Failed to apply weapon configuration")
        end
    end)
end

print("[Advanced Space Combat] CAP Weapons Integration System v2.0.0 - Loaded successfully!")
