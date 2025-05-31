-- Enhanced Hyperdrive Weapon Groups System v2.2.1
-- Coordinated weapon firing and fleet management

print("[Hyperdrive Weapons] Weapon Groups System v2.2.1 - Initializing...")

-- Initialize weapon groups namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.WeaponGroups = HYPERDRIVE.WeaponGroups or {}

-- Weapon groups configuration
HYPERDRIVE.WeaponGroups.Config = {
    MaxGroups = 10,
    MaxWeaponsPerGroup = 20,
    SalvoDelay = 0.1, -- Delay between weapons in salvo
    GroupCooldown = 2.0, -- Cooldown between group fires
    AutoTargetSharing = true,
    FleetCoordination = true
}

-- Weapon groups registry
HYPERDRIVE.WeaponGroups.Groups = {}
HYPERDRIVE.WeaponGroups.FleetGroups = {}

-- Weapon group class
local WeaponGroup = {}
WeaponGroup.__index = WeaponGroup

function WeaponGroup:New(groupId, shipCore)
    local group = setmetatable({}, WeaponGroup)
    
    group.id = groupId
    group.shipCore = shipCore
    group.weapons = {}
    group.name = "Weapon Group " .. groupId
    group.fireMode = "simultaneous" -- simultaneous, salvo, alternating
    group.targetMode = "shared" -- shared, individual, priority
    group.active = true
    group.lastFireTime = 0
    group.currentWeaponIndex = 1
    group.target = nil
    group.autoFire = false
    
    return group
end

function WeaponGroup:AddWeapon(weapon)
    if #self.weapons >= HYPERDRIVE.WeaponGroups.Config.MaxWeaponsPerGroup then
        return false, "Group full"
    end
    
    -- Check if weapon already in another group
    for groupId, group in pairs(HYPERDRIVE.WeaponGroups.Groups) do
        for _, existingWeapon in ipairs(group.weapons) do
            if existingWeapon == weapon then
                return false, "Weapon already in group " .. groupId
            end
        end
    end
    
    table.insert(self.weapons, weapon)
    print("[Weapon Groups] Added weapon to group " .. self.id)
    return true
end

function WeaponGroup:RemoveWeapon(weapon)
    for i, w in ipairs(self.weapons) do
        if w == weapon then
            table.remove(self.weapons, i)
            print("[Weapon Groups] Removed weapon from group " .. self.id)
            return true
        end
    end
    return false
end

function WeaponGroup:SetTarget(target)
    self.target = target
    
    if self.targetMode == "shared" then
        -- Set target for all weapons in group
        for _, weapon in ipairs(self.weapons) do
            if IsValid(weapon) and weapon.SetTargetEntity then
                weapon:SetTargetEntity(target)
            end
        end
    end
end

function WeaponGroup:Fire()
    if not self.active then return false, "Group inactive" end
    
    -- Check cooldown
    if CurTime() - self.lastFireTime < HYPERDRIVE.WeaponGroups.Config.GroupCooldown then
        return false, "Group cooling down"
    end
    
    local firedWeapons = 0
    
    if self.fireMode == "simultaneous" then
        firedWeapons = self:FireSimultaneous()
    elseif self.fireMode == "salvo" then
        firedWeapons = self:FireSalvo()
    elseif self.fireMode == "alternating" then
        firedWeapons = self:FireAlternating()
    end
    
    if firedWeapons > 0 then
        self.lastFireTime = CurTime()
        print("[Weapon Groups] Group " .. self.id .. " fired " .. firedWeapons .. " weapons")
        return true
    end
    
    return false, "No weapons ready"
end

function WeaponGroup:FireSimultaneous()
    local firedCount = 0
    
    for _, weapon in ipairs(self.weapons) do
        if IsValid(weapon) and weapon.IsWeaponReady and weapon.IsWeaponReady() then
            if weapon.FireWeapon then
                local success = weapon:FireWeapon(self.target)
                if success then
                    firedCount = firedCount + 1
                end
            end
        end
    end
    
    return firedCount
end

function WeaponGroup:FireSalvo()
    local firedCount = 0
    local delay = 0
    
    for _, weapon in ipairs(self.weapons) do
        if IsValid(weapon) and weapon.IsWeaponReady and weapon.IsWeaponReady() then
            timer.Simple(delay, function()
                if IsValid(weapon) and weapon.FireWeapon then
                    weapon:FireWeapon(self.target)
                end
            end)
            
            firedCount = firedCount + 1
            delay = delay + HYPERDRIVE.WeaponGroups.Config.SalvoDelay
        end
    end
    
    return firedCount
end

function WeaponGroup:FireAlternating()
    local readyWeapons = {}
    
    -- Find ready weapons
    for _, weapon in ipairs(self.weapons) do
        if IsValid(weapon) and weapon.IsWeaponReady and weapon.IsWeaponReady() then
            table.insert(readyWeapons, weapon)
        end
    end
    
    if #readyWeapons == 0 then return 0 end
    
    -- Fire next weapon in sequence
    local weaponIndex = ((self.currentWeaponIndex - 1) % #readyWeapons) + 1
    local weapon = readyWeapons[weaponIndex]
    
    if weapon.FireWeapon then
        local success = weapon:FireWeapon(self.target)
        if success then
            self.currentWeaponIndex = weaponIndex + 1
            return 1
        end
    end
    
    return 0
end

function WeaponGroup:GetStatus()
    local readyWeapons = 0
    local totalWeapons = #self.weapons
    
    for _, weapon in ipairs(self.weapons) do
        if IsValid(weapon) and weapon.IsWeaponReady and weapon.IsWeaponReady() then
            readyWeapons = readyWeapons + 1
        end
    end
    
    return {
        id = self.id,
        name = self.name,
        active = self.active,
        totalWeapons = totalWeapons,
        readyWeapons = readyWeapons,
        fireMode = self.fireMode,
        targetMode = self.targetMode,
        hasTarget = IsValid(self.target),
        lastFireTime = self.lastFireTime
    }
end

-- Main weapon groups functions
function HYPERDRIVE.WeaponGroups.CreateGroup(shipCore, groupId)
    groupId = groupId or (#HYPERDRIVE.WeaponGroups.Groups + 1)
    
    if groupId > HYPERDRIVE.WeaponGroups.Config.MaxGroups then
        return nil, "Maximum groups reached"
    end
    
    if HYPERDRIVE.WeaponGroups.Groups[groupId] then
        return nil, "Group already exists"
    end
    
    local group = WeaponGroup:New(groupId, shipCore)
    HYPERDRIVE.WeaponGroups.Groups[groupId] = group
    
    print("[Weapon Groups] Created weapon group " .. groupId)
    return group
end

function HYPERDRIVE.WeaponGroups.GetGroup(groupId)
    return HYPERDRIVE.WeaponGroups.Groups[groupId]
end

function HYPERDRIVE.WeaponGroups.RemoveGroup(groupId)
    HYPERDRIVE.WeaponGroups.Groups[groupId] = nil
    print("[Weapon Groups] Removed weapon group " .. groupId)
end

function HYPERDRIVE.WeaponGroups.AddWeaponToGroup(weapon, groupId)
    local group = HYPERDRIVE.WeaponGroups.GetGroup(groupId)
    if not group then
        return false, "Group not found"
    end
    
    return group:AddWeapon(weapon)
end

function HYPERDRIVE.WeaponGroups.RemoveWeaponFromGroup(weapon, groupId)
    local group = HYPERDRIVE.WeaponGroups.GetGroup(groupId)
    if not group then
        return false, "Group not found"
    end
    
    return group:RemoveWeapon(weapon)
end

function HYPERDRIVE.WeaponGroups.FireGroup(groupId)
    local group = HYPERDRIVE.WeaponGroups.GetGroup(groupId)
    if not group then
        return false, "Group not found"
    end
    
    return group:Fire()
end

function HYPERDRIVE.WeaponGroups.SetGroupTarget(groupId, target)
    local group = HYPERDRIVE.WeaponGroups.GetGroup(groupId)
    if not group then
        return false, "Group not found"
    end
    
    group:SetTarget(target)
    return true
end

function HYPERDRIVE.WeaponGroups.GetGroupStatus(groupId)
    local group = HYPERDRIVE.WeaponGroups.GetGroup(groupId)
    if not group then
        return nil
    end
    
    return group:GetStatus()
end

function HYPERDRIVE.WeaponGroups.GetAllGroupsStatus()
    local status = {}
    
    for groupId, group in pairs(HYPERDRIVE.WeaponGroups.Groups) do
        status[groupId] = group:GetStatus()
    end
    
    return status
end

-- Fleet coordination functions
function HYPERDRIVE.WeaponGroups.CreateFleetGroup(fleetId, shipCores)
    local fleetGroup = {
        id = fleetId,
        ships = {},
        coordinated = true,
        target = nil,
        fireMode = "coordinated" -- coordinated, sequential, simultaneous
    }
    
    for _, shipCore in ipairs(shipCores) do
        if IsValid(shipCore) then
            table.insert(fleetGroup.ships, shipCore)
        end
    end
    
    HYPERDRIVE.WeaponGroups.FleetGroups[fleetId] = fleetGroup
    print("[Weapon Groups] Created fleet group " .. fleetId .. " with " .. #fleetGroup.ships .. " ships")
    
    return fleetGroup
end

function HYPERDRIVE.WeaponGroups.FireFleetGroup(fleetId)
    local fleetGroup = HYPERDRIVE.WeaponGroups.FleetGroups[fleetId]
    if not fleetGroup then
        return false, "Fleet group not found"
    end
    
    local firedShips = 0
    
    for _, shipCore in ipairs(fleetGroup.ships) do
        if IsValid(shipCore) then
            -- Fire all weapon groups on this ship
            for groupId, group in pairs(HYPERDRIVE.WeaponGroups.Groups) do
                if group.shipCore == shipCore then
                    local success = group:Fire()
                    if success then
                        firedShips = firedShips + 1
                        break -- Only count ship once
                    end
                end
            end
        end
    end
    
    print("[Weapon Groups] Fleet group " .. fleetId .. " fired weapons from " .. firedShips .. " ships")
    return firedShips > 0
end

-- Auto-targeting system for groups
function HYPERDRIVE.WeaponGroups.UpdateAutoTargeting()
    for groupId, group in pairs(HYPERDRIVE.WeaponGroups.Groups) do
        if group.autoFire and group.active then
            -- Find targets for auto-firing groups
            local target = HYPERDRIVE.WeaponGroups.FindBestTarget(group)
            if target then
                group:SetTarget(target)
                group:Fire()
            end
        end
    end
end

function HYPERDRIVE.WeaponGroups.FindBestTarget(group)
    if not IsValid(group.shipCore) then return nil end
    
    local shipPos = group.shipCore:GetPos()
    local bestTarget = nil
    local bestDistance = math.huge
    
    -- Find closest hostile entity
    for _, ent in ipairs(ents.FindInSphere(shipPos, 5000)) do
        if IsValid(ent) and ent ~= group.shipCore then
            -- Check if it's a valid target
            if ent:IsPlayer() or ent:IsNPC() or string.find(ent:GetClass(), "ship_core") then
                local distance = shipPos:Distance(ent:GetPos())
                if distance < bestDistance then
                    bestTarget = ent
                    bestDistance = distance
                end
            end
        end
    end
    
    return bestTarget
end

-- Think function for weapon groups
timer.Create("HyperdriveWeaponGroupsThink", 1, 0, function()
    if HYPERDRIVE.WeaponGroups.Config.AutoTargetSharing then
        HYPERDRIVE.WeaponGroups.UpdateAutoTargeting()
    end
end)

print("[Hyperdrive Weapons] Weapon Groups System loaded successfully!")
