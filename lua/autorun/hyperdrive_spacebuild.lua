-- Hyperdrive Spacebuild 3 Integration
-- This file adds comprehensive Spacebuild 3 support to the hyperdrive system

if not CAF then return end -- Exit if Spacebuild 3 is not installed

HYPERDRIVE.Spacebuild = HYPERDRIVE.Spacebuild or {}

-- Spacebuild integration settings
HYPERDRIVE.Spacebuild.Config = {
    RequireLifeSupport = true,          -- Require life support for jumps
    RequirePower = true,                -- Require power connection
    PowerConsumption = 50,              -- Power units per second during charge
    JumpPowerCost = 500,               -- Power cost per jump
    OxygenConsumption = 2,             -- Oxygen per second during charge
    CoolantRequired = true,            -- Require coolant for engines
    CoolantConsumption = 5,            -- Coolant per jump
    SpaceJumpBonus = 0.5,              -- Energy bonus when jumping in space
    AtmosphereJumpPenalty = 1.5,       -- Energy penalty when jumping in atmosphere
}

-- Resource type mappings for Spacebuild
HYPERDRIVE.Spacebuild.Resources = {
    Power = "energy",
    Oxygen = "oxygen", 
    Coolant = "coolant",
    Fuel = "fuel"
}

-- Check if entity is in space environment
function HYPERDRIVE.Spacebuild.IsInSpace(pos)
    if not CAF or not CAF.GetEnvironment then return false end
    
    local env = CAF.GetEnvironment(pos)
    return env and env.space
end

-- Check if entity has atmosphere
function HYPERDRIVE.Spacebuild.HasAtmosphere(pos)
    if not CAF or not CAF.GetEnvironment then return true end
    
    local env = CAF.GetEnvironment(pos)
    return env and env.atmosphere and env.atmosphere > 0
end

-- Get life support status for entity
function HYPERDRIVE.Spacebuild.GetLifeSupportStatus(ent)
    if not IsValid(ent) or not CAF then return false end
    
    local status = {
        hasLifeSupport = false,
        oxygen = 0,
        power = 0,
        coolant = 0,
        temperature = 20
    }
    
    -- Check for life support system
    if CAF.GetValue then
        status.oxygen = CAF.GetValue(ent, "oxygen") or 0
        status.power = CAF.GetValue(ent, "energy") or 0
        status.coolant = CAF.GetValue(ent, "coolant") or 0
        status.temperature = CAF.GetValue(ent, "temperature") or 20
        
        status.hasLifeSupport = status.oxygen > 0 and status.power > 0
    end
    
    return status
end

-- Consume resources for hyperdrive operation
function HYPERDRIVE.Spacebuild.ConsumeResources(ent, operation)
    if not IsValid(ent) or not CAF then return true end
    
    local config = HYPERDRIVE.Spacebuild.Config
    
    if operation == "charge" then
        -- Consume power and oxygen during charging
        if config.RequirePower then
            local powerConsumed = CAF.ConsumeResource(ent, "energy", config.PowerConsumption)
            if powerConsumed < config.PowerConsumption then
                return false, "Insufficient power"
            end
        end
        
        if config.RequireLifeSupport then
            local oxygenConsumed = CAF.ConsumeResource(ent, "oxygen", config.OxygenConsumption)
            if oxygenConsumed < config.OxygenConsumption then
                return false, "Insufficient oxygen"
            end
        end
        
    elseif operation == "jump" then
        -- Consume resources for jump
        if config.RequirePower then
            local powerConsumed = CAF.ConsumeResource(ent, "energy", config.JumpPowerCost)
            if powerConsumed < config.JumpPowerCost then
                return false, "Insufficient power for jump"
            end
        end
        
        if config.CoolantRequired then
            local coolantConsumed = CAF.ConsumeResource(ent, "coolant", config.CoolantConsumption)
            if coolantConsumed < config.CoolantConsumption then
                return false, "Insufficient coolant"
            end
        end
    end
    
    return true
end

-- Calculate energy cost modifier based on environment
function HYPERDRIVE.Spacebuild.GetEnvironmentModifier(startPos, endPos)
    local modifier = 1.0
    
    -- Check start position environment
    if HYPERDRIVE.Spacebuild.IsInSpace(startPos) then
        modifier = modifier * (1 - HYPERDRIVE.Spacebuild.Config.SpaceJumpBonus)
    elseif HYPERDRIVE.Spacebuild.HasAtmosphere(startPos) then
        modifier = modifier * HYPERDRIVE.Spacebuild.Config.AtmosphereJumpPenalty
    end
    
    -- Check destination environment
    if HYPERDRIVE.Spacebuild.IsInSpace(endPos) then
        modifier = modifier * 0.9 -- Slight bonus for jumping to space
    end
    
    return modifier
end

-- Check if hyperdrive can operate safely
function HYPERDRIVE.Spacebuild.CanOperate(ent)
    if not IsValid(ent) or not CAF then return true, "No Spacebuild integration" end
    
    local config = HYPERDRIVE.Spacebuild.Config
    local status = HYPERDRIVE.Spacebuild.GetLifeSupportStatus(ent)
    
    -- Check life support requirements
    if config.RequireLifeSupport and not status.hasLifeSupport then
        return false, "Life support required"
    end
    
    -- Check power requirements
    if config.RequirePower and status.power < config.PowerConsumption then
        return false, "Insufficient power"
    end
    
    -- Check oxygen requirements
    if config.RequireLifeSupport and status.oxygen < config.OxygenConsumption then
        return false, "Insufficient oxygen"
    end
    
    -- Check coolant requirements
    if config.CoolantRequired and status.coolant < config.CoolantConsumption then
        return false, "Insufficient coolant"
    end
    
    -- Check temperature limits
    if status.temperature > 100 then
        return false, "Engine overheating"
    elseif status.temperature < -50 then
        return false, "Engine too cold"
    end
    
    return true, "All systems nominal"
end

-- Enhanced energy calculation with Spacebuild factors
function HYPERDRIVE.Spacebuild.CalculateEnergyCost(startPos, endPos, baseDistance)
    local baseCost = HYPERDRIVE.CalculateEnergyCost(baseDistance)
    local envModifier = HYPERDRIVE.Spacebuild.GetEnvironmentModifier(startPos, endPos)
    
    return baseCost * envModifier
end

-- Create Spacebuild-compatible hyperdrive engine
function HYPERDRIVE.Spacebuild.CreateSpacebuildEngine(pos, ang, ply)
    local engine = ents.Create("hyperdrive_engine")
    if not IsValid(engine) then return nil end
    
    engine:SetPos(pos)
    engine:SetAngles(ang)
    engine:Spawn()
    engine:Activate()
    
    if IsValid(ply) then
        engine:SetCreator(ply)
    end
    
    -- Add Spacebuild resource nodes
    if CAF and CAF.AddResourceNode then
        -- Add power input
        CAF.AddResourceNode(engine, "energy", "input", {
            capacity = 1000,
            rate = 100
        })
        
        -- Add oxygen input
        CAF.AddResourceNode(engine, "oxygen", "input", {
            capacity = 500,
            rate = 50
        })
        
        -- Add coolant input
        CAF.AddResourceNode(engine, "coolant", "input", {
            capacity = 200,
            rate = 20
        })
    end
    
    return engine
end

-- Hook into hyperdrive engine initialization
hook.Add("OnEntityCreated", "HyperdriveSpacebuildInit", function(ent)
    if not IsValid(ent) or ent:GetClass() ~= "hyperdrive_engine" then return end
    
    timer.Simple(0.1, function()
        if IsValid(ent) and CAF then
            -- Add Spacebuild resource support
            HYPERDRIVE.Spacebuild.SetupResourceNodes(ent)
        end
    end)
end)

-- Setup resource nodes for existing engines
function HYPERDRIVE.Spacebuild.SetupResourceNodes(ent)
    if not IsValid(ent) or not CAF then return end
    
    -- Store original functions
    ent.OriginalStartJump = ent.OriginalStartJump or ent.StartJump
    ent.OriginalRechargeEnergy = ent.OriginalRechargeEnergy or ent.RechargeEnergy
    
    -- Override StartJump with Spacebuild checks
    ent.StartJump = function(self)
        local canOperate, reason = HYPERDRIVE.Spacebuild.CanOperate(self)
        if not canOperate then
            return false, reason
        end
        
        -- Consume resources for charging
        local success, message = HYPERDRIVE.Spacebuild.ConsumeResources(self, "charge")
        if not success then
            return false, message
        end
        
        return self:OriginalStartJump()
    end
    
    -- Override energy recharge with power consumption
    ent.RechargeEnergy = function(self)
        if HYPERDRIVE.Spacebuild.Config.RequirePower then
            local status = HYPERDRIVE.Spacebuild.GetLifeSupportStatus(self)
            if status.power < 10 then
                return -- No power, no recharge
            end
        end
        
        return self:OriginalRechargeEnergy()
    end
end

-- Console commands for Spacebuild integration
concommand.Add("hyperdrive_sb_status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "hyperdrive_engine" then
        ply:ChatPrint("[Hyperdrive] Look at a hyperdrive engine")
        return
    end
    
    local status = HYPERDRIVE.Spacebuild.GetLifeSupportStatus(trace.Entity)
    local canOperate, reason = HYPERDRIVE.Spacebuild.CanOperate(trace.Entity)
    
    ply:ChatPrint("[Hyperdrive] Spacebuild Status:")
    ply:ChatPrint("  • Power: " .. math.floor(status.power))
    ply:ChatPrint("  • Oxygen: " .. math.floor(status.oxygen))
    ply:ChatPrint("  • Coolant: " .. math.floor(status.coolant))
    ply:ChatPrint("  • Temperature: " .. math.floor(status.temperature) .. "°C")
    ply:ChatPrint("  • Status: " .. reason)
    ply:ChatPrint("  • Environment: " .. (HYPERDRIVE.Spacebuild.IsInSpace(trace.Entity:GetPos()) and "Space" or "Atmosphere"))
end)

concommand.Add("hyperdrive_sb_config", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    ply:ChatPrint("[Hyperdrive] Spacebuild Configuration:")
    for key, value in pairs(HYPERDRIVE.Spacebuild.Config) do
        ply:ChatPrint("  • " .. key .. ": " .. tostring(value))
    end
end)

-- Network strings for Spacebuild integration
if SERVER then
    util.AddNetworkString("hyperdrive_sb_status")
    util.AddNetworkString("hyperdrive_sb_warning")
end

print("[Hyperdrive] Spacebuild 3 integration loaded")
