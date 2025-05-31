-- Enhanced Hyperdrive Ammunition System v2.2.1
-- Advanced ammunition management with reloading, supply, and logistics

print("[Hyperdrive Weapons] Ammunition System v2.2.1 - Initializing...")

-- Initialize ammunition namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Ammunition = HYPERDRIVE.Ammunition or {}

-- Ammunition system configuration
HYPERDRIVE.Ammunition.Config = {
    -- Ammunition Types
    AmmoTypes = {
        energy_cell = {
            name = "Energy Cell",
            description = "Standard energy ammunition for pulse weapons",
            maxStack = 100,
            weight = 0.1,
            cost = 5,
            rechargeRate = 2, -- Per second
            compatible = {"hyperdrive_pulse_cannon", "hyperdrive_beam_weapon"}
        },
        torpedo = {
            name = "Torpedo",
            description = "Heavy explosive torpedo warhead",
            maxStack = 20,
            weight = 5.0,
            cost = 50,
            rechargeRate = 0, -- No recharge, must be manufactured
            compatible = {"hyperdrive_torpedo_launcher"}
        },
        railgun_slug = {
            name = "Railgun Slug",
            description = "Dense metal projectile for railguns",
            maxStack = 50,
            weight = 2.0,
            cost = 25,
            rechargeRate = 0, -- No recharge, must be manufactured
            compatible = {"hyperdrive_railgun"}
        },
        plasma_cell = {
            name = "Plasma Cell",
            description = "Contained plasma for plasma weapons",
            maxStack = 30,
            weight = 1.5,
            cost = 30,
            rechargeRate = 1, -- Slow recharge
            compatible = {"hyperdrive_plasma_cannon"}
        },
        point_defense_round = {
            name = "PD Round",
            description = "Small caliber rounds for point defense",
            maxStack = 500,
            weight = 0.05,
            cost = 1,
            rechargeRate = 10, -- Fast recharge
            compatible = {"hyperdrive_point_defense"}
        }
    },
    
    -- Supply System
    AutoSupply = true,
    SupplyRange = 1000,
    SupplyRate = 5, -- Ammo per second
    RequireSupplyLines = false,
    
    -- Manufacturing
    EnableManufacturing = true,
    ManufacturingTime = {
        torpedo = 30, -- 30 seconds per torpedo
        railgun_slug = 15, -- 15 seconds per slug
        plasma_cell = 20, -- 20 seconds per cell
        point_defense_round = 1 -- 1 second per round
    },
    
    -- Logistics
    EnableLogistics = true,
    TransportCapacity = 1000, -- Weight units
    TransportSpeed = 500, -- Units per second
    AutoTransport = true
}

-- Ammunition registry
HYPERDRIVE.Ammunition.Storage = {} -- Ship-based ammunition storage
HYPERDRIVE.Ammunition.Supplies = {} -- Supply depot storage
HYPERDRIVE.Ammunition.Manufacturing = {} -- Manufacturing queues
HYPERDRIVE.Ammunition.Transport = {} -- Active transport operations

-- Ammunition storage class
local AmmoStorage = {}
AmmoStorage.__index = AmmoStorage

function AmmoStorage:New(shipCore, capacity)
    local storage = setmetatable({}, AmmoStorage)
    
    storage.shipCore = shipCore
    storage.capacity = capacity or 1000 -- Weight capacity
    storage.ammo = {}
    storage.totalWeight = 0
    storage.autoRecharge = true
    storage.lastRechargeTime = 0
    storage.rechargeRate = 1.0
    
    -- Initialize ammo types
    for ammoType, _ in pairs(HYPERDRIVE.Ammunition.Config.AmmoTypes) do
        storage.ammo[ammoType] = 0
    end
    
    return storage
end

function AmmoStorage:AddAmmo(ammoType, amount)
    local ammoConfig = HYPERDRIVE.Ammunition.Config.AmmoTypes[ammoType]
    if not ammoConfig then return false, "Invalid ammo type" end
    
    local weight = amount * ammoConfig.weight
    if self.totalWeight + weight > self.capacity then
        return false, "Storage capacity exceeded"
    end
    
    self.ammo[ammoType] = (self.ammo[ammoType] or 0) + amount
    self.totalWeight = self.totalWeight + weight
    
    print("[Ammunition] Added " .. amount .. " " .. ammoConfig.name .. " to storage")
    return true
end

function AmmoStorage:RemoveAmmo(ammoType, amount)
    local ammoConfig = HYPERDRIVE.Ammunition.Config.AmmoTypes[ammoType]
    if not ammoConfig then return false, "Invalid ammo type" end
    
    local currentAmount = self.ammo[ammoType] or 0
    if currentAmount < amount then
        return false, "Insufficient ammunition"
    end
    
    self.ammo[ammoType] = currentAmount - amount
    self.totalWeight = self.totalWeight - (amount * ammoConfig.weight)
    
    return true
end

function AmmoStorage:GetAmmo(ammoType)
    return self.ammo[ammoType] or 0
end

function AmmoStorage:GetCapacity()
    return self.capacity - self.totalWeight
end

function AmmoStorage:UpdateRecharge()
    if not self.autoRecharge then return end
    
    local currentTime = CurTime()
    if currentTime - self.lastRechargeTime < 1.0 then return end
    
    for ammoType, config in pairs(HYPERDRIVE.Ammunition.Config.AmmoTypes) do
        if config.rechargeRate > 0 then
            local rechargeAmount = config.rechargeRate * self.rechargeRate
            local maxAmount = math.floor(self.capacity / config.weight)
            local currentAmount = self.ammo[ammoType] or 0
            
            if currentAmount < maxAmount then
                local actualRecharge = math.min(rechargeAmount, maxAmount - currentAmount)
                if actualRecharge > 0 then
                    self:AddAmmo(ammoType, actualRecharge)
                end
            end
        end
    end
    
    self.lastRechargeTime = currentTime
end

function AmmoStorage:GetStatus()
    return {
        capacity = self.capacity,
        used = self.totalWeight,
        free = self.capacity - self.totalWeight,
        ammo = table.Copy(self.ammo),
        autoRecharge = self.autoRecharge
    }
end

-- Main ammunition functions
function HYPERDRIVE.Ammunition.CreateStorage(shipCore, capacity)
    if not IsValid(shipCore) then return nil end
    
    local coreId = shipCore:EntIndex()
    local storage = AmmoStorage:New(shipCore, capacity)
    HYPERDRIVE.Ammunition.Storage[coreId] = storage
    
    print("[Ammunition] Created storage for ship core " .. coreId .. " with capacity " .. capacity)
    return storage
end

function HYPERDRIVE.Ammunition.GetStorage(shipCore)
    if not IsValid(shipCore) then return nil end
    
    local coreId = shipCore:EntIndex()
    return HYPERDRIVE.Ammunition.Storage[coreId]
end

function HYPERDRIVE.Ammunition.RemoveStorage(shipCore)
    if not IsValid(shipCore) then return end
    
    local coreId = shipCore:EntIndex()
    HYPERDRIVE.Ammunition.Storage[coreId] = nil
    print("[Ammunition] Removed storage for ship core " .. coreId)
end

function HYPERDRIVE.Ammunition.SupplyWeapon(weapon, ammoType, amount)
    if not IsValid(weapon) then return false, "Invalid weapon" end
    
    -- Find weapon's ship core
    local shipCore = nil
    if weapon.weapon and weapon.weapon.shipCore then
        shipCore = weapon.weapon.shipCore
    end
    
    if not IsValid(shipCore) then return false, "No ship core found" end
    
    -- Get storage
    local storage = HYPERDRIVE.Ammunition.GetStorage(shipCore)
    if not storage then
        -- Create default storage
        storage = HYPERDRIVE.Ammunition.CreateStorage(shipCore, 1000)
    end
    
    -- Check if weapon is compatible with ammo type
    local ammoConfig = HYPERDRIVE.Ammunition.Config.AmmoTypes[ammoType]
    if not ammoConfig then return false, "Invalid ammo type" end
    
    local weaponClass = weapon:GetClass()
    local compatible = false
    for _, compatibleWeapon in ipairs(ammoConfig.compatible) do
        if weaponClass == compatibleWeapon then
            compatible = true
            break
        end
    end
    
    if not compatible then return false, "Incompatible ammunition" end
    
    -- Supply ammunition
    local success, reason = storage:RemoveAmmo(ammoType, amount)
    if success then
        -- Add ammo to weapon
        if weapon.SetAmmo then
            local currentAmmo = weapon:GetAmmo() or 0
            weapon:SetAmmo(currentAmmo + amount)
        end
        
        print("[Ammunition] Supplied " .. amount .. " " .. ammoConfig.name .. " to " .. weaponClass)
        return true
    end
    
    return false, reason
end

function HYPERDRIVE.Ammunition.AutoSupplyWeapons(shipCore)
    if not IsValid(shipCore) then return end
    
    local storage = HYPERDRIVE.Ammunition.GetStorage(shipCore)
    if not storage then return end
    
    -- Find weapons on this ship
    local weapons = {}
    if HYPERDRIVE.Weapons and HYPERDRIVE.Weapons.ActiveWeapons then
        for weaponId, weapon in pairs(HYPERDRIVE.Weapons.ActiveWeapons) do
            if IsValid(weapon.entity) and weapon.shipCore == shipCore then
                table.insert(weapons, weapon.entity)
            end
        end
    end
    
    -- Supply each weapon
    for _, weapon in ipairs(weapons) do
        if weapon.GetAmmo and weapon.GetMaxAmmo then
            local currentAmmo = weapon:GetAmmo()
            local maxAmmo = weapon:GetMaxAmmo()
            
            if currentAmmo < maxAmmo then
                local needed = maxAmmo - currentAmmo
                local weaponClass = weapon:GetClass()
                
                -- Determine ammo type for weapon
                local ammoType = nil
                if string.find(weaponClass, "pulse") or string.find(weaponClass, "beam") then
                    ammoType = "energy_cell"
                elseif string.find(weaponClass, "torpedo") then
                    ammoType = "torpedo"
                elseif string.find(weaponClass, "railgun") then
                    ammoType = "railgun_slug"
                elseif string.find(weaponClass, "plasma") then
                    ammoType = "plasma_cell"
                elseif string.find(weaponClass, "point_defense") then
                    ammoType = "point_defense_round"
                end
                
                if ammoType then
                    HYPERDRIVE.Ammunition.SupplyWeapon(weapon, ammoType, needed)
                end
            end
        end
    end
end

function HYPERDRIVE.Ammunition.CreateSupplyDepot(pos, capacity)
    local depot = {
        pos = pos,
        capacity = capacity or 10000,
        ammo = {},
        totalWeight = 0,
        active = true
    }
    
    -- Initialize ammo types
    for ammoType, _ in pairs(HYPERDRIVE.Ammunition.Config.AmmoTypes) do
        depot.ammo[ammoType] = 0
    end
    
    table.insert(HYPERDRIVE.Ammunition.Supplies, depot)
    print("[Ammunition] Created supply depot at " .. tostring(pos) .. " with capacity " .. capacity)
    
    return depot
end

function HYPERDRIVE.Ammunition.FindNearestSupplyDepot(pos)
    local nearestDepot = nil
    local nearestDistance = math.huge
    
    for _, depot in ipairs(HYPERDRIVE.Ammunition.Supplies) do
        if depot.active then
            local distance = pos:Distance(depot.pos)
            if distance < nearestDistance then
                nearestDepot = depot
                nearestDistance = distance
            end
        end
    end
    
    return nearestDepot, nearestDistance
end

function HYPERDRIVE.Ammunition.StartManufacturing(shipCore, ammoType, amount)
    if not IsValid(shipCore) then return false, "Invalid ship core" end
    
    local ammoConfig = HYPERDRIVE.Ammunition.Config.AmmoTypes[ammoType]
    if not ammoConfig then return false, "Invalid ammo type" end
    
    local manufacturingTime = HYPERDRIVE.Ammunition.Config.ManufacturingTime[ammoType]
    if not manufacturingTime then return false, "Cannot manufacture this ammo type" end
    
    local coreId = shipCore:EntIndex()
    if not HYPERDRIVE.Ammunition.Manufacturing[coreId] then
        HYPERDRIVE.Ammunition.Manufacturing[coreId] = {}
    end
    
    local job = {
        ammoType = ammoType,
        amount = amount,
        startTime = CurTime(),
        duration = manufacturingTime * amount,
        shipCore = shipCore
    }
    
    table.insert(HYPERDRIVE.Ammunition.Manufacturing[coreId], job)
    print("[Ammunition] Started manufacturing " .. amount .. " " .. ammoConfig.name)
    
    return true
end

function HYPERDRIVE.Ammunition.UpdateManufacturing()
    local currentTime = CurTime()
    
    for coreId, jobs in pairs(HYPERDRIVE.Ammunition.Manufacturing) do
        for i = #jobs, 1, -1 do
            local job = jobs[i]
            
            if currentTime - job.startTime >= job.duration then
                -- Manufacturing complete
                local storage = HYPERDRIVE.Ammunition.GetStorage(job.shipCore)
                if storage then
                    local success = storage:AddAmmo(job.ammoType, job.amount)
                    if success then
                        local ammoConfig = HYPERDRIVE.Ammunition.Config.AmmoTypes[job.ammoType]
                        print("[Ammunition] Manufacturing complete: " .. job.amount .. " " .. ammoConfig.name)
                    end
                end
                
                table.remove(jobs, i)
            end
        end
    end
end

-- Think function for ammunition system
timer.Create("HyperdriveAmmunitionThink", 1, 0, function()
    -- Update recharging
    for coreId, storage in pairs(HYPERDRIVE.Ammunition.Storage) do
        if IsValid(storage.shipCore) then
            storage:UpdateRecharge()
        else
            HYPERDRIVE.Ammunition.Storage[coreId] = nil
        end
    end
    
    -- Update manufacturing
    HYPERDRIVE.Ammunition.UpdateManufacturing()
    
    -- Auto-supply weapons
    if HYPERDRIVE.Ammunition.Config.AutoSupply then
        for coreId, storage in pairs(HYPERDRIVE.Ammunition.Storage) do
            if IsValid(storage.shipCore) then
                HYPERDRIVE.Ammunition.AutoSupplyWeapons(storage.shipCore)
            end
        end
    end
end)

print("[Hyperdrive Weapons] Ammunition System loaded successfully!")
