-- Enhanced Hyperdrive System - Shield System v2.2.1
-- Advanced shield system with CAP integration

print("[Hyperdrive] Loading Shield System v2.2.1...")

-- Initialize shield system namespace
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Shields = HYPERDRIVE.Shields or {}

-- Shield system configuration
HYPERDRIVE.Shields.Config = {
    EnableShields = true,
    AutoActivateOnCharge = true,
    AutoDeactivateOnCooldown = false,
    DamageReduction = 0.8,
    MaintenanceCost = 5,
    RechargeRate = 10,
    MaxShieldStrength = 1000,
    ShieldRegenDelay = 5,
    ShieldEfficiency = 0.9
}

-- Shield registry
HYPERDRIVE.Shields.ActiveShields = {}
HYPERDRIVE.Shields.ShieldData = {}

-- Initialize shield for entity
function HYPERDRIVE.Shields.InitializeShield(entity, maxStrength)
    if not IsValid(entity) then return false end
    
    local entIndex = entity:EntIndex()
    maxStrength = maxStrength or HYPERDRIVE.Shields.Config.MaxShieldStrength
    
    HYPERDRIVE.Shields.ShieldData[entIndex] = {
        entity = entity,
        maxStrength = maxStrength,
        currentStrength = maxStrength,
        active = false,
        lastDamage = 0,
        recharging = false,
        efficiency = HYPERDRIVE.Shields.Config.ShieldEfficiency
    }
    
    -- Set up entity shield functions
    entity.GetShieldStrength = function(self)
        local data = HYPERDRIVE.Shields.ShieldData[self:EntIndex()]
        return data and data.currentStrength or 0
    end
    
    entity.GetMaxShieldStrength = function(self)
        local data = HYPERDRIVE.Shields.ShieldData[self:EntIndex()]
        return data and data.maxStrength or 0
    end
    
    entity.SetShieldActive = function(self, active)
        local data = HYPERDRIVE.Shields.ShieldData[self:EntIndex()]
        if data then
            data.active = active
            if active then
                HYPERDRIVE.Shields.ActiveShields[self:EntIndex()] = self
            else
                HYPERDRIVE.Shields.ActiveShields[self:EntIndex()] = nil
            end
        end
    end
    
    entity.IsShieldActive = function(self)
        local data = HYPERDRIVE.Shields.ShieldData[self:EntIndex()]
        return data and data.active or false
    end
    
    return true
end

-- Process shield damage
function HYPERDRIVE.Shields.ProcessDamage(entity, damage)
    if not IsValid(entity) then return damage end
    
    local entIndex = entity:EntIndex()
    local shieldData = HYPERDRIVE.Shields.ShieldData[entIndex]
    
    if not shieldData or not shieldData.active or shieldData.currentStrength <= 0 then
        return damage
    end
    
    -- Calculate shield absorption
    local absorbedDamage = damage * HYPERDRIVE.Shields.Config.DamageReduction
    local remainingDamage = damage - absorbedDamage
    
    -- Apply damage to shields
    shieldData.currentStrength = math.max(0, shieldData.currentStrength - absorbedDamage)
    shieldData.lastDamage = CurTime()
    shieldData.recharging = false
    
    -- Deactivate shields if depleted
    if shieldData.currentStrength <= 0 then
        shieldData.active = false
        HYPERDRIVE.Shields.ActiveShields[entIndex] = nil
        
        -- Trigger shield down effect
        if entity.OnShieldDown then
            entity:OnShieldDown()
        end
    end
    
    return remainingDamage
end

-- Shield recharge system
function HYPERDRIVE.Shields.RechargeShields()
    local currentTime = CurTime()
    
    for entIndex, data in pairs(HYPERDRIVE.Shields.ShieldData) do
        if IsValid(data.entity) and data.currentStrength < data.maxStrength then
            -- Check if enough time has passed since last damage
            if currentTime - data.lastDamage >= HYPERDRIVE.Shields.Config.ShieldRegenDelay then
                data.recharging = true
                
                -- Recharge shields
                local rechargeAmount = HYPERDRIVE.Shields.Config.RechargeRate * data.efficiency
                data.currentStrength = math.min(data.maxStrength, data.currentStrength + rechargeAmount)
                
                -- Auto-activate if configured and shields are recharged
                if HYPERDRIVE.Shields.Config.AutoActivateOnCharge and data.currentStrength >= data.maxStrength * 0.25 then
                    if not data.active then
                        data.active = true
                        HYPERDRIVE.Shields.ActiveShields[entIndex] = data.entity
                        
                        if data.entity.OnShieldUp then
                            data.entity:OnShieldUp()
                        end
                    end
                end
            end
        end
    end
end

-- Clean up removed entities
function HYPERDRIVE.Shields.CleanupShields()
    for entIndex, data in pairs(HYPERDRIVE.Shields.ShieldData) do
        if not IsValid(data.entity) then
            HYPERDRIVE.Shields.ShieldData[entIndex] = nil
            HYPERDRIVE.Shields.ActiveShields[entIndex] = nil
        end
    end
end

-- CAP Integration
function HYPERDRIVE.Shields.IntegrateWithCAP()
    -- Check for CAP shield entities
    local capShields = ents.FindByClass("cap_shield_generator")
    
    for _, shield in ipairs(capShields) do
        if IsValid(shield) and not HYPERDRIVE.Shields.ShieldData[shield:EntIndex()] then
            -- Initialize CAP shield with hyperdrive system
            HYPERDRIVE.Shields.InitializeShield(shield, 2000) -- Higher strength for CAP shields
            
            -- Override CAP shield functions if they exist
            if shield.SetShieldStrength then
                local originalSetStrength = shield.SetShieldStrength
                shield.SetShieldStrength = function(self, strength)
                    originalSetStrength(self, strength)
                    local data = HYPERDRIVE.Shields.ShieldData[self:EntIndex()]
                    if data then
                        data.currentStrength = strength
                    end
                end
            end
        end
    end
end

-- Server-side initialization
if SERVER then
    -- Shield recharge timer
    timer.Create("HyperdriveShieldRecharge", 1, 0, function()
        HYPERDRIVE.Shields.RechargeShields()
    end)
    
    -- Shield cleanup timer
    timer.Create("HyperdriveShieldCleanup", 30, 0, function()
        HYPERDRIVE.Shields.CleanupShields()
    end)
    
    -- CAP integration timer
    timer.Create("HyperdriveShieldCAPIntegration", 10, 0, function()
        HYPERDRIVE.Shields.IntegrateWithCAP()
    end)
    
    -- Hook into damage system
    hook.Add("EntityTakeDamage", "HyperdriveShieldDamage", function(target, dmginfo)
        if IsValid(target) and HYPERDRIVE.Shields.ShieldData[target:EntIndex()] then
            local originalDamage = dmginfo:GetDamage()
            local reducedDamage = HYPERDRIVE.Shields.ProcessDamage(target, originalDamage)
            dmginfo:SetDamage(reducedDamage)
        end
    end)
    
    -- Console command for shield status
    concommand.Add("hyperdrive_shield_status", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local activeCount = table.Count(HYPERDRIVE.Shields.ActiveShields)
        local totalCount = table.Count(HYPERDRIVE.Shields.ShieldData)
        
        ply:ChatPrint("[Shields] Active: " .. activeCount .. "/" .. totalCount)
        
        for entIndex, data in pairs(HYPERDRIVE.Shields.ShieldData) do
            if IsValid(data.entity) then
                local percentage = math.floor((data.currentStrength / data.maxStrength) * 100)
                local status = data.active and "ACTIVE" or "INACTIVE"
                ply:ChatPrint("• " .. data.entity:GetClass() .. " - " .. percentage .. "% - " .. status)
            end
        end
    end)
end

print("[Hyperdrive] Shield System v2.2.1 loaded successfully!")
