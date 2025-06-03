-- Advanced Space Combat - Weapon Configuration Tool v3.1.0
-- Specialized tool for weapon setup and targeting

TOOL.Category = "Advanced Space Combat"
TOOL.Name = "Weapon Config"
TOOL.Command = nil
TOOL.ConfigName = ""

-- Tool information
TOOL.Information = {
    { name = "left", text = "Configure weapon" },
    { name = "right", text = "Set target" },
    { name = "reload", text = "Test fire weapon" }
}

-- Client variables
if CLIENT then
    TOOL.ClientConVar["weapon_mode"] = "manual"
    TOOL.ClientConVar["auto_target"] = "0"
    TOOL.ClientConVar["fire_rate"] = "1.0"
    TOOL.ClientConVar["weapon_range"] = "5000"
    TOOL.ClientConVar["target_type"] = "hostile"
end

-- Weapon types and their configurations
local WeaponConfigs = {
    ["asc_pulse_cannon"] = {
        name = "Pulse Cannon",
        damage = {min = 50, max = 150, default = 100},
        range = {min = 1000, max = 8000, default = 5000},
        firerate = {min = 0.1, max = 5.0, default = 1.0},
        energy = {min = 10, max = 100, default = 25}
    },
    ["asc_plasma_cannon"] = {
        name = "Plasma Cannon",
        damage = {min = 80, max = 250, default = 150},
        range = {min = 800, max = 6000, default = 4000},
        firerate = {min = 0.2, max = 3.0, default = 0.8},
        energy = {min = 20, max = 150, default = 50}
    },
    ["asc_railgun"] = {
        name = "Railgun",
        damage = {min = 200, max = 500, default = 300},
        range = {min = 2000, max = 15000, default = 10000},
        firerate = {min = 0.1, max = 1.0, default = 0.3},
        energy = {min = 50, max = 200, default = 100}
    },
    ["hyperdrive_beam_weapon"] = {
        name = "Beam Weapon",
        damage = {min = 30, max = 120, default = 75},
        range = {min = 1500, max = 7000, default = 4500},
        firerate = {min = 0.5, max = 10.0, default = 5.0},
        energy = {min = 15, max = 80, default = 35}
    },
    ["hyperdrive_torpedo_launcher"] = {
        name = "Torpedo Launcher",
        damage = {min = 150, max = 400, default = 250},
        range = {min = 1000, max = 12000, default = 8000},
        firerate = {min = 0.1, max = 2.0, default = 0.5},
        energy = {min = 30, max = 120, default = 75}
    }
}

-- Get weapon configuration
function TOOL:GetWeaponConfig(weapon)
    if not IsValid(weapon) then return nil end
    return WeaponConfigs[weapon:GetClass()]
end

-- Check if entity is a weapon
function TOOL:IsWeapon(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    return WeaponConfigs[class] ~= nil
end

-- Left click - Configure weapon
function TOOL:LeftClick(trace)
    if CLIENT then return true end
    
    local weapon = trace.Entity
    if not IsValid(weapon) then return false end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    -- Check if it's a weapon
    if not self:IsWeapon(weapon) then
        ply:ChatPrint("[Weapon Config] This is not a configurable weapon!")
        return false
    end
    
    -- Check ownership
    local owner = weapon.CPPIGetOwner and weapon:CPPIGetOwner() or weapon:GetOwner()
    if IsValid(owner) and owner ~= ply and not ply:IsAdmin() then
        ply:ChatPrint("[Weapon Config] You don't own this weapon!")
        return false
    end
    
    -- Apply configuration
    self:ConfigureWeapon(weapon, ply)
    return true
end

-- Configure weapon with current settings
function TOOL:ConfigureWeapon(weapon, ply)
    local config = self:GetWeaponConfig(weapon)
    if not config then return end
    
    local weaponMode = self:GetClientInfo("weapon_mode")
    local autoTarget = self:GetClientNumber("auto_target") == 1
    local fireRate = math.Clamp(self:GetClientNumber("fire_rate"), config.firerate.min, config.firerate.max)
    local weaponRange = math.Clamp(self:GetClientNumber("weapon_range"), config.range.min, config.range.max)
    local targetType = self:GetClientInfo("target_type")
    
    -- Apply settings to weapon
    if weapon.SetWeaponMode then
        weapon:SetWeaponMode(weaponMode)
    end
    
    if weapon.SetAutoTarget then
        weapon:SetAutoTarget(autoTarget)
    end
    
    if weapon.SetFireRate then
        weapon:SetFireRate(fireRate)
    end
    
    if weapon.SetRange then
        weapon:SetRange(weaponRange)
    end
    
    if weapon.SetTargetType then
        weapon:SetTargetType(targetType)
    end
    
    -- Set damage if configurable
    if weapon.SetDamage then
        weapon:SetDamage(config.damage.default)
    end
    
    -- Set energy consumption
    if weapon.SetEnergyConsumption then
        weapon:SetEnergyConsumption(config.energy.default)
    end
    
    ply:ChatPrint("[Weapon Config] Configured " .. config.name .. ":")
    ply:ChatPrint("Mode: " .. weaponMode .. ", Auto-target: " .. (autoTarget and "Yes" or "No"))
    ply:ChatPrint("Fire rate: " .. fireRate .. ", Range: " .. weaponRange)
    ply:ChatPrint("Target type: " .. targetType)
end

-- Right click - Set target
function TOOL:RightClick(trace)
    if CLIENT then return true end
    
    local target = trace.Entity
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    -- Store target position or entity
    if IsValid(target) then
        -- Set entity target
        ply.WeaponTarget = target
        ply.WeaponTargetPos = nil
        ply:ChatPrint("[Weapon Config] Target set to: " .. target:GetClass())
    else
        -- Set position target
        ply.WeaponTarget = nil
        ply.WeaponTargetPos = trace.HitPos
        ply:ChatPrint("[Weapon Config] Target position set")
    end
    
    -- Apply target to nearby weapons
    self:SetWeaponTargets(ply)
    return true
end

-- Set targets for player's weapons
function TOOL:SetWeaponTargets(ply)
    local weapons = {}
    
    -- Find all weapon types
    for weaponClass, _ in pairs(WeaponConfigs) do
        local foundWeapons = ents.FindByClass(weaponClass)
        for _, weapon in ipairs(foundWeapons) do
            if IsValid(weapon) then
                local owner = weapon.CPPIGetOwner and weapon:CPPIGetOwner() or weapon:GetOwner()
                if IsValid(owner) and owner == ply then
                    table.insert(weapons, weapon)
                end
            end
        end
    end
    
    -- Set targets
    local targetCount = 0
    for _, weapon in ipairs(weapons) do
        if weapon.SetTarget and ply.WeaponTarget then
            weapon:SetTarget(ply.WeaponTarget)
            targetCount = targetCount + 1
        elseif weapon.SetTargetPos and ply.WeaponTargetPos then
            weapon:SetTargetPos(ply.WeaponTargetPos)
            targetCount = targetCount + 1
        end
    end
    
    if targetCount > 0 then
        ply:ChatPrint("[Weapon Config] Updated " .. targetCount .. " weapons with new target")
    end
end

-- Reload - Test fire weapon
function TOOL:Reload(trace)
    if CLIENT then return true end
    
    local weapon = trace.Entity
    if not IsValid(weapon) then return false end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    -- Check if it's a weapon
    if not self:IsWeapon(weapon) then
        ply:ChatPrint("[Weapon Config] This is not a weapon!")
        return false
    end
    
    -- Check ownership
    local owner = weapon.CPPIGetOwner and weapon:CPPIGetOwner() or weapon:GetOwner()
    if IsValid(owner) and owner ~= ply and not ply:IsAdmin() then
        ply:ChatPrint("[Weapon Config] You don't own this weapon!")
        return false
    end
    
    -- Test fire
    if weapon.TestFire then
        weapon:TestFire()
        ply:ChatPrint("[Weapon Config] Test firing " .. weapon:GetClass())
    elseif weapon.Fire then
        weapon:Fire()
        ply:ChatPrint("[Weapon Config] Firing " .. weapon:GetClass())
    else
        ply:ChatPrint("[Weapon Config] This weapon doesn't support test firing")
    end
    
    return true
end

-- Get weapon status
function TOOL:GetWeaponStatus(weapon)
    if not IsValid(weapon) then return "Invalid weapon" end
    
    local status = {}
    
    if weapon.GetWeaponMode then
        table.insert(status, "Mode: " .. (weapon:GetWeaponMode() or "Unknown"))
    end
    
    if weapon.GetAutoTarget then
        table.insert(status, "Auto-target: " .. (weapon:GetAutoTarget() and "Yes" or "No"))
    end
    
    if weapon.GetFireRate then
        table.insert(status, "Fire rate: " .. (weapon:GetFireRate() or 0))
    end
    
    if weapon.GetRange then
        table.insert(status, "Range: " .. (weapon:GetRange() or 0))
    end
    
    if weapon.GetAmmo then
        table.insert(status, "Ammo: " .. (weapon:GetAmmo() or 0))
    end
    
    if weapon.GetEnergy then
        table.insert(status, "Energy: " .. (weapon:GetEnergy() or 0))
    end
    
    return table.concat(status, ", ")
end

-- Think function
function TOOL:Think()
    -- Update weapon status display
end

if CLIENT then
    language.Add("tool.asc_weapon_config.name", "Weapon Config")
    language.Add("tool.asc_weapon_config.desc", "Configure and control space combat weapons")
    language.Add("tool.asc_weapon_config.0", "Left click to configure, right click to set target, reload to test fire")
    
    -- Create tool control panel
    function TOOL.BuildCPanel(CPanel)
        CPanel:AddControl("Header", {
            Text = "Weapon Configuration Tool",
            Description = "Configure space combat weapons and targeting"
        })
        
        CPanel:AddControl("ComboBox", {
            Label = "Weapon Mode",
            MenuButton = 1,
            Folder = "asc_weapon",
            Options = {
                ["Manual"] = {weapon_mode = "manual"},
                ["Auto"] = {weapon_mode = "auto"},
                ["Defensive"] = {weapon_mode = "defensive"},
                ["Aggressive"] = {weapon_mode = "aggressive"}
            },
            CVars = {weapon_mode = "manual"}
        })
        
        CPanel:AddControl("CheckBox", {
            Label = "Auto-targeting",
            Command = "asc_weapon_config_auto_target"
        })
        
        CPanel:AddControl("Slider", {
            Label = "Fire Rate",
            Type = "Float",
            Min = "0.1",
            Max = "10.0",
            Command = "asc_weapon_config_fire_rate"
        })
        
        CPanel:AddControl("Slider", {
            Label = "Weapon Range",
            Type = "Float",
            Min = "500",
            Max = "15000",
            Command = "asc_weapon_config_weapon_range"
        })
        
        CPanel:AddControl("ComboBox", {
            Label = "Target Type",
            MenuButton = 1,
            Folder = "asc_weapon",
            Options = {
                ["Hostile"] = {target_type = "hostile"},
                ["All"] = {target_type = "all"},
                ["Players"] = {target_type = "players"},
                ["NPCs"] = {target_type = "npcs"},
                ["Vehicles"] = {target_type = "vehicles"}
            },
            CVars = {target_type = "hostile"}
        })
        
        CPanel:AddControl("Button", {
            Label = "Configure All Weapons",
            Command = "asc_weapon_config_all"
        })
        
        CPanel:AddControl("Button", {
            Label = "Clear All Targets",
            Command = "asc_weapon_clear_targets"
        })
    end
end
