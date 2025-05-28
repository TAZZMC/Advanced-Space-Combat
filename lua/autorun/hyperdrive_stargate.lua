-- Hyperdrive Stargate Carter Addon Pack Integration
-- This file adds comprehensive Stargate CAP support to the hyperdrive system

if not StarGate then return end -- Exit if Stargate CAP is not installed

HYPERDRIVE.Stargate = HYPERDRIVE.Stargate or {}

-- Stargate integration settings
HYPERDRIVE.Stargate.Config = {
    RequireNaquadah = true,             -- Require naquadah for enhanced jumps
    NaquadahConsumption = 10,           -- Naquadah per jump
    ZPMBonus = 2.0,                     -- Energy bonus with ZPM power
    IrisProtection = true,              -- Respect iris/shield protection
    DHDIntegration = true,              -- Integrate with DHD systems
    GateNetworkAccess = true,           -- Access gate network coordinates
    AncientTechBonus = 1.5,            -- Bonus for Ancient technology
    GoauldTechPenalty = 0.8,           -- Penalty for Goa'uld technology
    AsgardTechBonus = 1.3,             -- Bonus for Asgard technology
    OriTechBonus = 1.8,                -- Bonus for Ori technology
}

-- Stargate technology types
HYPERDRIVE.Stargate.TechTypes = {
    Ancient = "ancient",
    Goauld = "goauld", 
    Asgard = "asgard",
    Ori = "ori",
    Tau_ri = "tau_ri",
    Wraith = "wraith"
}

-- Check if entity has Stargate technology integration
function HYPERDRIVE.Stargate.HasStargateTech(ent)
    if not IsValid(ent) or not StarGate then return false end
    
    -- Check for nearby Stargate entities
    local nearbyEnts = ents.FindInSphere(ent:GetPos(), 1000)
    local stargateData = {
        hasGate = false,
        hasDHD = false,
        hasZPM = false,
        hasNaquadah = false,
        techLevel = "tau_ri",
        powerLevel = 0
    }
    
    for _, nearEnt in ipairs(nearbyEnts) do
        if IsValid(nearEnt) then
            local class = nearEnt:GetClass()
            
            -- Check for Stargate
            if string.find(class, "stargate") then
                stargateData.hasGate = true
                
                -- Determine technology level
                if string.find(class, "ancient") then
                    stargateData.techLevel = "ancient"
                elseif string.find(class, "ori") then
                    stargateData.techLevel = "ori"
                elseif string.find(class, "asgard") then
                    stargateData.techLevel = "asgard"
                elseif string.find(class, "goauld") then
                    stargateData.techLevel = "goauld"
                end
            end
            
            -- Check for DHD
            if string.find(class, "dhd") then
                stargateData.hasDHD = true
            end
            
            -- Check for ZPM
            if string.find(class, "zpm") then
                stargateData.hasZPM = true
                if nearEnt.GetCharge then
                    stargateData.powerLevel = nearEnt:GetCharge() or 0
                end
            end
            
            -- Check for Naquadah
            if string.find(class, "naquadah") then
                stargateData.hasNaquadah = true
            end
        end
    end
    
    return stargateData
end

-- Get technology bonus based on Stargate tech level
function HYPERDRIVE.Stargate.GetTechBonus(techLevel)
    local config = HYPERDRIVE.Stargate.Config
    
    if techLevel == "ancient" then
        return config.AncientTechBonus
    elseif techLevel == "ori" then
        return config.OriTechBonus
    elseif techLevel == "asgard" then
        return config.AsgardTechBonus
    elseif techLevel == "goauld" then
        return config.GoauldTechPenalty
    else
        return 1.0 -- Tau'ri baseline
    end
end

-- Calculate enhanced energy cost with Stargate factors
function HYPERDRIVE.Stargate.CalculateEnergyCost(ent, startPos, endPos, baseDistance)
    local baseCost = HYPERDRIVE.CalculateEnergyCost(baseDistance)
    local stargateData = HYPERDRIVE.Stargate.HasStargateTech(ent)
    
    if not stargateData.hasGate then
        return baseCost -- No Stargate integration
    end
    
    local modifier = 1.0
    
    -- Technology level bonus/penalty
    modifier = modifier * HYPERDRIVE.Stargate.GetTechBonus(stargateData.techLevel)
    
    -- ZPM power bonus
    if stargateData.hasZPM and stargateData.powerLevel > 50 then
        modifier = modifier * (1 / HYPERDRIVE.Stargate.Config.ZPMBonus)
    end
    
    -- DHD integration bonus
    if stargateData.hasDHD then
        modifier = modifier * 0.9
    end
    
    return baseCost * modifier
end

-- Check if destination is protected by iris or shield
function HYPERDRIVE.Stargate.IsDestinationProtected(pos)
    if not HYPERDRIVE.Stargate.Config.IrisProtection then return false end
    
    local nearbyEnts = ents.FindInSphere(pos, 500)
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            local class = ent:GetClass()
            
            -- Check for iris or shield
            if string.find(class, "iris") or string.find(class, "shield") then
                if ent.GetActive and ent:GetActive() then
                    return true, "Destination protected by " .. (string.find(class, "iris") and "iris" or "shield")
                end
            end
        end
    end
    
    return false
end

-- Consume Stargate resources for hyperdrive operation
function HYPERDRIVE.Stargate.ConsumeResources(ent, operation)
    if not IsValid(ent) or not StarGate then return true end
    
    local stargateData = HYPERDRIVE.Stargate.HasStargateTech(ent)
    if not stargateData.hasGate then return true end
    
    local config = HYPERDRIVE.Stargate.Config
    
    if operation == "jump" and config.RequireNaquadah then
        -- Find and consume naquadah
        local nearbyEnts = ents.FindInSphere(ent:GetPos(), 1000)
        local naquadahConsumed = 0
        
        for _, nearEnt in ipairs(nearbyEnts) do
            if IsValid(nearEnt) and string.find(nearEnt:GetClass(), "naquadah") then
                if nearEnt.GetAmount and nearEnt.SetAmount then
                    local available = nearEnt:GetAmount() or 0
                    local needed = config.NaquadahConsumption - naquadahConsumed
                    local consume = math.min(available, needed)
                    
                    nearEnt:SetAmount(available - consume)
                    naquadahConsumed = naquadahConsumed + consume
                    
                    if naquadahConsumed >= config.NaquadahConsumption then
                        break
                    end
                end
            end
        end
        
        if naquadahConsumed < config.NaquadahConsumption then
            return false, "Insufficient naquadah (" .. naquadahConsumed .. "/" .. config.NaquadahConsumption .. ")"
        end
    end
    
    return true
end

-- Get gate network coordinates
function HYPERDRIVE.Stargate.GetGateNetworkCoordinates()
    if not StarGate or not HYPERDRIVE.Stargate.Config.GateNetworkAccess then
        return {}
    end
    
    local coordinates = {}
    
    -- Find all active Stargates
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and string.find(ent:GetClass(), "stargate") then
            if ent.GetAddress and ent:GetAddress() then
                local address = ent:GetAddress()
                local name = ent.GetName and ent:GetName() or ("Gate " .. address)
                
                table.insert(coordinates, {
                    name = name,
                    address = address,
                    position = ent:GetPos(),
                    techLevel = HYPERDRIVE.Stargate.GetTechLevel(ent),
                    active = ent.GetActive and ent:GetActive() or false
                })
            end
        end
    end
    
    return coordinates
end

-- Get technology level of Stargate entity
function HYPERDRIVE.Stargate.GetTechLevel(ent)
    if not IsValid(ent) then return "tau_ri" end
    
    local class = ent:GetClass()
    
    if string.find(class, "ancient") then
        return "ancient"
    elseif string.find(class, "ori") then
        return "ori"
    elseif string.find(class, "asgard") then
        return "asgard"
    elseif string.find(class, "goauld") then
        return "goauld"
    elseif string.find(class, "wraith") then
        return "wraith"
    else
        return "tau_ri"
    end
end

-- Create Stargate-enhanced hyperdrive engine
function HYPERDRIVE.Stargate.CreateStargateEngine(pos, ang, ply, techLevel)
    local engine = ents.Create("hyperdrive_sg_engine")
    if not IsValid(engine) then return nil end
    
    engine:SetPos(pos)
    engine:SetAngles(ang)
    engine:Spawn()
    engine:Activate()
    
    if IsValid(ply) then
        engine:SetCreator(ply)
    end
    
    -- Set technology level
    if techLevel then
        engine:SetTechLevel(techLevel)
    end
    
    return engine
end

-- Hook into hyperdrive engine initialization for Stargate integration
hook.Add("OnEntityCreated", "HyperdriveStargateInit", function(ent)
    if not IsValid(ent) then return end
    
    local class = ent:GetClass()
    if class == "hyperdrive_engine" or class == "hyperdrive_sb_engine" then
        timer.Simple(0.1, function()
            if IsValid(ent) and StarGate then
                HYPERDRIVE.Stargate.SetupStargateIntegration(ent)
            end
        end)
    end
end)

-- Setup Stargate integration for existing engines
function HYPERDRIVE.Stargate.SetupStargateIntegration(ent)
    if not IsValid(ent) or not StarGate then return end
    
    -- Store original functions
    ent.OriginalSetDestinationPos = ent.OriginalSetDestinationPos or ent.SetDestinationPos
    ent.OriginalStartJump = ent.OriginalStartJump or ent.StartJump
    
    -- Override SetDestinationPos with Stargate checks
    ent.SetDestinationPos = function(self, pos)
        -- Check for iris/shield protection
        local protected, reason = HYPERDRIVE.Stargate.IsDestinationProtected(pos)
        if protected then
            return false, reason
        end
        
        return self:OriginalSetDestinationPos(pos)
    end
    
    -- Override StartJump with Stargate integration
    ent.StartJump = function(self)
        -- Check Stargate resource requirements
        local success, message = HYPERDRIVE.Stargate.ConsumeResources(self, "jump")
        if not success then
            return false, message
        end
        
        return self:OriginalStartJump()
    end
    
    -- Add Stargate status function
    ent.GetStargateStatus = function(self)
        return HYPERDRIVE.Stargate.HasStargateTech(self)
    end
end

-- Console commands for Stargate integration
concommand.Add("hyperdrive_sg_status", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or 
       (trace.Entity:GetClass() ~= "hyperdrive_engine" and 
        trace.Entity:GetClass() ~= "hyperdrive_sb_engine" and
        trace.Entity:GetClass() ~= "hyperdrive_sg_engine") then
        ply:ChatPrint("[Hyperdrive] Look at a hyperdrive engine")
        return
    end
    
    local stargateData = HYPERDRIVE.Stargate.HasStargateTech(trace.Entity)
    
    ply:ChatPrint("[Hyperdrive] Stargate Integration Status:")
    ply:ChatPrint("  • Stargate Present: " .. (stargateData.hasGate and "Yes" or "No"))
    ply:ChatPrint("  • Technology Level: " .. string.upper(stargateData.techLevel))
    ply:ChatPrint("  • DHD Present: " .. (stargateData.hasDHD and "Yes" or "No"))
    ply:ChatPrint("  • ZPM Present: " .. (stargateData.hasZPM and "Yes" or "No"))
    ply:ChatPrint("  • ZPM Power: " .. math.floor(stargateData.powerLevel) .. "%")
    ply:ChatPrint("  • Naquadah Available: " .. (stargateData.hasNaquadah and "Yes" or "No"))
    
    local techBonus = HYPERDRIVE.Stargate.GetTechBonus(stargateData.techLevel)
    ply:ChatPrint("  • Technology Bonus: " .. string.format("%.1fx", techBonus))
end)

concommand.Add("hyperdrive_sg_network", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local coordinates = HYPERDRIVE.Stargate.GetGateNetworkCoordinates()
    
    if #coordinates == 0 then
        ply:ChatPrint("[Hyperdrive] No Stargate network access available")
        return
    end
    
    ply:ChatPrint("[Hyperdrive] Stargate Network Coordinates:")
    for i, coord in ipairs(coordinates) do
        if i > 10 then break end -- Limit display
        local status = coord.active and "ACTIVE" or "INACTIVE"
        ply:ChatPrint(string.format("  • %s (%s) - %s - %s", 
            coord.name, coord.address, string.upper(coord.techLevel), status))
    end
end)

concommand.Add("hyperdrive_sg_config", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end
    
    ply:ChatPrint("[Hyperdrive] Stargate Configuration:")
    for key, value in pairs(HYPERDRIVE.Stargate.Config) do
        ply:ChatPrint("  • " .. key .. ": " .. tostring(value))
    end
end)

-- Network strings for Stargate integration
if SERVER then
    util.AddNetworkString("hyperdrive_sg_status")
    util.AddNetworkString("hyperdrive_sg_network")
    util.AddNetworkString("hyperdrive_sg_coordinates")
end

print("[Hyperdrive] Stargate Carter Addon Pack integration loaded")
