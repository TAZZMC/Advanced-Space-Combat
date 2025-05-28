-- Hyperdrive CAP (Carter Addon Pack) Integration
-- Advanced integration with Carter Addon Pack Stargate systems
-- Based on official CAP repository: https://github.com/RafaelDeJongh/cap

if CLIENT then return end

-- Initialize CAP integration
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.CAP = HYPERDRIVE.CAP or {}

print("[Hyperdrive] CAP (Carter Addon Pack) integration loading...")

-- CAP integration configuration
HYPERDRIVE.CAP.Config = {
    Enabled = true,                     -- Enable CAP integration
    UseStargateNetwork = true,          -- Use Stargate network for destinations
    RequireStargateEnergy = false,      -- Require Stargate energy for hyperdrive
    ShareEnergyWithStargates = true,    -- Share energy between hyperdrive and stargates
    RespectShields = true,              -- Respect CAP shield systems
    UseStargateAddresses = true,        -- Use Stargate addresses for navigation
    IntegrateWithDHD = true,            -- Integrate with Dial Home Devices
    CheckStargateStatus = true,         -- Check Stargate operational status
    PreventConflicts = true,            -- Prevent conflicts with active Stargate connections
    UseStargateProtection = true,       -- Use Stargate protection systems
}

-- CAP state tracking
HYPERDRIVE.CAP.State = {
    detectedStargates = {},
    detectedShields = {},
    detectedDHDs = {},
    stargateNetwork = {},
    lastScan = 0,
    energySharing = {},
}

-- CAP entity categories
HYPERDRIVE.CAP.EntityCategories = {
    STARGATES = {
        "stargate_atlantis",
        "stargate_milkyway",
        "stargate_universe",
        "stargate_supergate",
        "stargate_orlin",
        "stargate_tollan"
    },
    SHIELDS = {
        "shield",
        "shield_core_buble",
        "shield_core_goauld",
        "shield_core_asgard",
        "shield_core_atlantis"
    },
    DHD = {
        "dhd_atlantis",
        "dhd_milkyway",
        "dhd_universe",
        "dhd_pegasus"
    },
    ENERGY_SYSTEMS = {
        "zpm",
        "zpm_hub",
        "naquadah_generator",
        "potentia"
    },
    TRANSPORTATION = {
        "rings_ancient",
        "rings_goauld",
        "rings_ori",
        "transporter"
    }
}

-- Function to get CAP configuration
local function GetCAPConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("CAP", key, HYPERDRIVE.CAP.Config[key] or default)
    end
    return HYPERDRIVE.CAP.Config[key] or default
end

-- Check if CAP is loaded and functional
function HYPERDRIVE.CAP.IsCAP_Loaded()
    if not StarGate then return false, "StarGate global not found" end
    if not StarGate.CheckModule then return false, "StarGate.CheckModule not available" end

    -- Check for core CAP functionality
    local hasCore = StarGate.IsEntityValid and StarGate.GetEntityCentre and true or false
    if not hasCore then return false, "Core StarGate functions missing" end

    -- Check for specific CAP features
    local hasShields = StarGate.IsEntityShielded and true or false
    local hasTracing = StarGate.Trace and true or false
    local hasEventHorizon = StarGate.EventHorizonTypes and true or false

    return true, "CAP fully loaded", {
        core = true,
        shields = hasShields,
        tracing = hasTracing,
        eventHorizon = hasEventHorizon,
        version = StarGate.Version or "unknown"
    }
end

-- Enhanced entity detection using CAP framework
function HYPERDRIVE.CAP.DetectCAPEntities(engine, searchRadius)
    if not GetCAPConfig("Enabled", true) then return {} end

    searchRadius = searchRadius or 2000
    local entities = {}
    local enginePos = engine:GetPos()

    -- Get all entities in radius
    local nearbyEnts = ents.FindInSphere(enginePos, searchRadius)

    -- Categorize CAP entities
    local categorizedEntities = {
        stargates = {},
        shields = {},
        dhds = {},
        energySystems = {},
        transportation = {},
        other = {}
    }

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            local entClass = ent:GetClass()
            local category = HYPERDRIVE.CAP.GetEntityCategory(entClass)

            if category then
                local entityData = {
                    entity = ent,
                    class = entClass,
                    position = ent:GetPos(),
                    distance = enginePos:Distance(ent:GetPos()),
                    category = category
                }

                -- Add CAP-specific data
                if category == "stargates" and ent.IsStargate then
                    entityData.isOpen = StarGate.IsStargateOpen(ent)
                    entityData.isDialling = StarGate.IsStargateDialling(ent)
                    entityData.address = ent.GetGateAddress and ent:GetGateAddress() or ""
                    entityData.energy = ent.GetEnergy and ent:GetEnergy() or 0
                    entityData.hasIris = StarGate.IsIrisClosed(ent)
                elseif category == "shields" then
                    entityData.active = not ent:GetNWBool("depleted", false)
                    entityData.size = ent:GetNWInt("size", 0)
                    entityData.energy = ent:GetNWInt("energy", 0)
                elseif category == "energySystems" then
                    entityData.energy = ent.GetEnergy and ent:GetEnergy() or 0
                    entityData.maxEnergy = ent.GetMaxEnergy and ent:GetMaxEnergy() or 0
                end

                table.insert(categorizedEntities[category], entityData)
                table.insert(entities, ent)
            end
        end
    end

    -- Store categorized data
    HYPERDRIVE.CAP.State.detectedStargates = categorizedEntities.stargates
    HYPERDRIVE.CAP.State.detectedShields = categorizedEntities.shields
    HYPERDRIVE.CAP.State.detectedDHDs = categorizedEntities.dhds
    HYPERDRIVE.CAP.State.lastScan = CurTime()

    return entities
end

-- Get entity category based on class name
function HYPERDRIVE.CAP.GetEntityCategory(className)
    for categoryName, classes in pairs(HYPERDRIVE.CAP.EntityCategories) do
        for _, class in ipairs(classes) do
            if className == class then
                return string.lower(categoryName)
            end
        end
    end
    return nil
end

-- Check if position is protected by CAP shields
function HYPERDRIVE.CAP.IsPositionShielded(position)
    if not GetCAPConfig("RespectShields", true) then return false end
    if not StarGate or not StarGate.IsEntityShielded then return false end

    -- Create a temporary entity at the position for shield checking
    local testEnt = ents.Create("prop_physics")
    if IsValid(testEnt) then
        testEnt:SetPos(position)
        testEnt:Spawn()

        local isShielded = StarGate.IsEntityShielded(testEnt)
        testEnt:Remove()

        return isShielded
    end

    return false
end

-- Check if hyperdrive jump would conflict with active Stargate operations
function HYPERDRIVE.CAP.CheckStargateConflicts(engine, destination)
    if not GetCAPConfig("PreventConflicts", true) then return false, {} end

    local conflicts = {}
    local categorized = HYPERDRIVE.CAP.State.detectedStargates

    for _, stargateData in ipairs(categorized) do
        local stargate = stargateData.entity
        if IsValid(stargate) then
            -- Check if Stargate is currently active
            if stargateData.isOpen or stargateData.isDialling then
                local distance = engine:GetPos():Distance(stargate:GetPos())
                if distance < 1000 then -- Within interference range
                    table.insert(conflicts, {
                        type = "active_stargate",
                        entity = stargate,
                        distance = distance,
                        status = stargateData.isOpen and "open" or "dialling",
                        message = "Active Stargate within interference range"
                    })
                end
            end

            -- Check if destination is near a Stargate
            local destDistance = destination:Distance(stargate:GetPos())
            if destDistance < 500 then -- Too close to destination
                table.insert(conflicts, {
                    type = "destination_conflict",
                    entity = stargate,
                    distance = destDistance,
                    message = "Destination too close to Stargate"
                })
            end
        end
    end

    return #conflicts > 0, conflicts
end

-- Validate CAP ship configuration
function HYPERDRIVE.CAP.ValidateShipConfiguration(engine)
    if not GetCAPConfig("Enabled", true) then return true, {} end
    if not IsValid(engine) then return false, {"Invalid engine"} end

    local issues = {}
    local warnings = {}

    -- Detect CAP entities
    local entities = HYPERDRIVE.CAP.DetectCAPEntities(engine)

    -- Check for shield conflicts
    if GetCAPConfig("RespectShields", true) then
        local engineShielded = HYPERDRIVE.CAP.IsPositionShielded(engine:GetPos())
        if engineShielded then
            table.insert(warnings, "Hyperdrive engine is inside a shield - may affect jump performance")
        end
    end

    -- Check for Stargate conflicts
    if GetCAPConfig("CheckStargateStatus", true) then
        local hasConflicts, conflicts = HYPERDRIVE.CAP.CheckStargateConflicts(engine, engine:GetPos() + Vector(1000, 0, 0))
        if hasConflicts then
            for _, conflict in ipairs(conflicts) do
                if conflict.type == "active_stargate" then
                    table.insert(issues, conflict.message)
                else
                    table.insert(warnings, conflict.message)
                end
            end
        end
    end

    -- Check energy systems integration
    if GetCAPConfig("ShareEnergyWithStargates", true) then
        local energySystems = 0
        for _, entData in ipairs(HYPERDRIVE.CAP.State.detectedStargates) do
            if entData.energy and entData.energy > 0 then
                energySystems = energySystems + 1
            end
        end

        if energySystems == 0 then
            table.insert(warnings, "No active Stargate energy systems detected for energy sharing")
        end
    end

    local isValid = #issues == 0
    local allIssues = {}

    for _, issue in ipairs(issues) do
        table.insert(allIssues, {type = "error", message = issue})
    end
    for _, warning in ipairs(warnings) do
        table.insert(allIssues, {type = "warning", message = warning})
    end

    return isValid, allIssues
end

-- Enhanced gravity override with CAP shield integration
function HYPERDRIVE.CAP.OverrideGravity(player, override)
    if not IsValid(player) or not player:IsPlayer() then return end
    if not GetCAPConfig("Enabled", true) then return end

    if override then
        -- Store original gravity state
        player.HyperdriveOriginalGravity = player:GetGravity()

        -- Check if player is in a shield
        local isShielded = GetCAPConfig("RespectShields", true) and
                          StarGate and StarGate.IsEntityShielded and
                          StarGate.IsEntityShielded(player)

        -- Set appropriate gravity based on shield status
        local gravityValue = isShielded and 0.8 or 0.3
        player:SetGravity(gravityValue)

        player.HyperdriveInCAP_Shield = isShielded
    else
        -- Restore original gravity
        if player.HyperdriveOriginalGravity then
            player:SetGravity(player.HyperdriveOriginalGravity)
            player.HyperdriveOriginalGravity = nil
        end

        player.HyperdriveInCAP_Shield = nil
    end
end

-- Get Stargate network destinations
function HYPERDRIVE.CAP.GetStargateDestinations()
    if not GetCAPConfig("UseStargateNetwork", true) then return {} end

    local destinations = {}
    local allStargates = ents.FindByClass("stargate_*")

    for _, stargate in ipairs(allStargates) do
        if IsValid(stargate) and stargate.IsStargate then
            local address = stargate.GetGateAddress and stargate:GetGateAddress() or ""
            if address ~= "" then
                table.insert(destinations, {
                    name = "Stargate " .. address,
                    address = address,
                    position = stargate:GetPos(),
                    entity = stargate,
                    type = "stargate"
                })
            end
        end
    end

    return destinations
end

-- Console commands for CAP integration
concommand.Add("hyperdrive_cap_validate", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local engine = ply:GetEyeTrace().Entity
    if not IsValid(engine) or not string.find(engine:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive CAP] Please look at a hyperdrive engine")
        return
    end

    local isValid, issues = HYPERDRIVE.CAP.ValidateShipConfiguration(engine)

    ply:ChatPrint("[Hyperdrive CAP] Ship Validation Results:")
    ply:ChatPrint("  • Status: " .. (isValid and "VALID" or "INVALID"))
    ply:ChatPrint("  • Issues Found: " .. #issues)

    for i, issue in ipairs(issues) do
        if i <= 10 then -- Limit output
            local prefix = issue.type == "error" and "ERROR" or "WARNING"
            ply:ChatPrint("  • [" .. prefix .. "] " .. issue.message)
        end
    end

    if #issues > 10 then
        ply:ChatPrint("  • ... and " .. (#issues - 10) .. " more issues")
    end
end)

concommand.Add("hyperdrive_cap_status", function(ply, cmd, args)
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end

    local isLoaded, status, details = HYPERDRIVE.CAP.IsCAP_Loaded()

    sendMessage("[Hyperdrive CAP] Integration Status:")
    sendMessage("  • CAP Loaded: " .. (isLoaded and "Yes" or "No"))
    sendMessage("  • Status: " .. status)

    if details then
        sendMessage("  • Core Functions: " .. (details.core and "Available" or "Missing"))
        sendMessage("  • Shield System: " .. (details.shields and "Available" or "Missing"))
        sendMessage("  • Tracing System: " .. (details.tracing and "Available" or "Missing"))
        sendMessage("  • Event Horizon: " .. (details.eventHorizon and "Available" or "Missing"))
        sendMessage("  • Version: " .. (details.version or "unknown"))
    end

    -- Entity statistics
    local totalStargates = #ents.FindByClass("stargate_*")
    local totalShields = #ents.FindByClass("shield*")
    local totalDHDs = #ents.FindByClass("dhd_*")

    sendMessage("[Hyperdrive CAP] Entity Counts:")
    sendMessage("  • Stargates: " .. totalStargates)
    sendMessage("  • Shields: " .. totalShields)
    sendMessage("  • DHDs: " .. totalDHDs)

    -- Stargate network
    local destinations = HYPERDRIVE.CAP.GetStargateDestinations()
    sendMessage("  • Network Destinations: " .. #destinations)
end)

concommand.Add("hyperdrive_cap_destinations", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local destinations = HYPERDRIVE.CAP.GetStargateDestinations()

    ply:ChatPrint("[Hyperdrive CAP] Stargate Network Destinations:")
    ply:ChatPrint("  • Total Destinations: " .. #destinations)

    for i, dest in ipairs(destinations) do
        if i <= 10 then -- Limit output
            ply:ChatPrint("  • " .. dest.name .. " (" .. dest.address .. ")")
        end
    end

    if #destinations > 10 then
        ply:ChatPrint("  • ... and " .. (#destinations - 10) .. " more destinations")
    end
end)

-- Integration with enhanced configuration system
if HYPERDRIVE.EnhancedConfig then
    HYPERDRIVE.EnhancedConfig.RegisterIntegration("CAP", {
        name = "Carter Addon Pack",
        description = "Advanced Stargate systems integration",
        version = "2.0.0",
        checkFunction = HYPERDRIVE.CAP.IsCAP_Loaded,
        validateFunction = HYPERDRIVE.CAP.ValidateShipConfiguration,
        configCategories = {
            "UseStargateNetwork",
            "RespectShields",
            "ShareEnergyWithStargates",
            "PreventConflicts",
            "UseStargateAddresses"
        }
    })
end

-- Advanced CAP entity movement integration
function HYPERDRIVE.CAP.MoveEntitiesWithCAP_Awareness(entities, destination, engine)
    if not GetCAPConfig("Enabled", true) then
        return HYPERDRIVE.MoveEntities(entities, destination, engine)
    end

    local movedEntities = {}
    local failedEntities = {}
    local shieldConflicts = {}

    -- Pre-movement validation
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            local targetPos = destination + (ent:GetPos() - engine:GetPos())

            -- Check if destination is shielded
            if GetCAPConfig("RespectShields", true) then
                local isShielded = HYPERDRIVE.CAP.IsPositionShielded(targetPos)
                if isShielded then
                    table.insert(shieldConflicts, {
                        entity = ent,
                        position = targetPos,
                        reason = "Destination protected by shield"
                    })
                    continue
                end
            end

            -- Check for Stargate conflicts at destination
            if GetCAPConfig("PreventConflicts", true) then
                local hasConflicts, conflicts = HYPERDRIVE.CAP.CheckStargateConflicts(ent, targetPos)
                if hasConflicts then
                    table.insert(failedEntities, {
                        entity = ent,
                        conflicts = conflicts,
                        reason = "Stargate interference"
                    })
                    continue
                end
            end

            -- Perform the movement
            local success = HYPERDRIVE.CAP.MoveEntitySafely(ent, targetPos)
            if success then
                table.insert(movedEntities, ent)
            else
                table.insert(failedEntities, {
                    entity = ent,
                    reason = "Movement failed"
                })
            end
        end
    end

    return {
        success = #movedEntities > 0,
        movedEntities = movedEntities,
        failedEntities = failedEntities,
        shieldConflicts = shieldConflicts,
        totalMoved = #movedEntities,
        totalFailed = #failedEntities + #shieldConflicts
    }
end

-- Safe entity movement with CAP integration
function HYPERDRIVE.CAP.MoveEntitySafely(entity, destination)
    if not IsValid(entity) then return false end

    -- Store original position for rollback
    local originalPos = entity:GetPos()
    local originalAng = entity:GetAngles()

    -- Check if entity is a CAP entity that needs special handling
    local entityClass = entity:GetClass()
    local category = HYPERDRIVE.CAP.GetEntityCategory(entityClass)

    if category == "stargates" then
        -- Special handling for Stargates
        if entity.IsStargate and (StarGate.IsStargateOpen(entity) or StarGate.IsStargateDialling(entity)) then
            -- Don't move active Stargates
            return false
        end

        -- Safely move Stargate
        entity:SetPos(destination)

        -- Update Stargate network if needed
        if entity.UpdateNetworkPosition then
            entity:UpdateNetworkPosition()
        end

    elseif category == "shields" then
        -- Special handling for shields
        local wasActive = not entity:GetNWBool("depleted", false)

        -- Temporarily disable shield during movement
        if wasActive then
            entity:SetNWBool("depleted", true)
        end

        entity:SetPos(destination)

        -- Re-enable shield after movement
        if wasActive then
            timer.Simple(0.1, function()
                if IsValid(entity) then
                    entity:SetNWBool("depleted", false)
                end
            end)
        end

    else
        -- Standard movement for other entities
        entity:SetPos(destination)
    end

    return true
end

-- Enhanced energy sharing system
function HYPERDRIVE.CAP.ManageEnergySharing(engine, energyRequired)
    if not GetCAPConfig("ShareEnergyWithStargates", true) then return false, 0 end

    local availableEnergy = 0
    local energySources = {}

    -- Find nearby energy sources
    local nearbyEnts = ents.FindInSphere(engine:GetPos(), 1500)

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            local category = HYPERDRIVE.CAP.GetEntityCategory(ent:GetClass())

            if category == "energySystems" or category == "stargates" then
                local energy = 0

                -- Get energy from different CAP entities
                if ent.GetEnergy then
                    energy = ent:GetEnergy()
                elseif ent:GetClass() == "zpm" then
                    energy = ent:GetNWInt("energy", 0)
                elseif ent:GetClass() == "zpm_hub" then
                    energy = ent:GetNWInt("energy", 0)
                elseif ent.IsStargate then
                    energy = ent:GetNWInt("energy", 0)
                end

                if energy > 1000 then -- Minimum threshold
                    table.insert(energySources, {
                        entity = ent,
                        available = energy,
                        type = category
                    })
                    availableEnergy = availableEnergy + energy
                end
            end
        end
    end

    -- Check if we have enough energy
    if availableEnergy < energyRequired then
        return false, availableEnergy
    end

    -- Distribute energy consumption
    local remainingRequired = energyRequired
    local consumedSources = {}

    for _, source in ipairs(energySources) do
        if remainingRequired <= 0 then break end

        local toConsume = math.min(remainingRequired, source.available * 0.8) -- Don't drain completely

        -- Consume energy from source
        if source.entity.SetEnergy then
            source.entity:SetEnergy(source.available - toConsume)
        elseif source.entity:GetClass() == "zpm" or source.entity:GetClass() == "zpm_hub" then
            source.entity:SetNWInt("energy", source.available - toConsume)
        elseif source.entity.IsStargate then
            source.entity:SetNWInt("energy", source.available - toConsume)
        end

        table.insert(consumedSources, {
            entity = source.entity,
            consumed = toConsume,
            remaining = source.available - toConsume
        })

        remainingRequired = remainingRequired - toConsume
    end

    -- Store energy sharing data for monitoring
    HYPERDRIVE.CAP.State.energySharing[engine:EntIndex()] = {
        timestamp = CurTime(),
        required = energyRequired,
        consumed = energyRequired - remainingRequired,
        sources = consumedSources
    }

    return remainingRequired <= 0, energyRequired - remainingRequired
end

-- Advanced Stargate address resolution
function HYPERDRIVE.CAP.ResolveStargateAddress(address)
    if not GetCAPConfig("UseStargateAddresses", true) then return nil end
    if not address or address == "" then return nil end

    -- Find Stargate by address
    local allStargates = ents.FindByClass("stargate_*")

    for _, stargate in ipairs(allStargates) do
        if IsValid(stargate) and stargate.IsStargate then
            local gateAddress = stargate.GetGateAddress and stargate:GetGateAddress() or ""

            if gateAddress == address then
                return {
                    entity = stargate,
                    position = stargate:GetPos(),
                    address = address,
                    status = StarGate.IsStargateOpen(stargate) and "open" or "closed",
                    available = not StarGate.IsStargateDialling(stargate)
                }
            end
        end
    end

    return nil
end

-- CAP-aware destination validation
function HYPERDRIVE.CAP.ValidateDestination(destination, engine)
    if not GetCAPConfig("Enabled", true) then return true, {} end

    local issues = {}
    local warnings = {}

    -- Check for shield conflicts
    if GetCAPConfig("RespectShields", true) then
        local isShielded = HYPERDRIVE.CAP.IsPositionShielded(destination)
        if isShielded then
            table.insert(issues, "Destination is protected by a shield")
        end
    end

    -- Check for Stargate conflicts
    if GetCAPConfig("PreventConflicts", true) then
        local hasConflicts, conflicts = HYPERDRIVE.CAP.CheckStargateConflicts(engine, destination)
        if hasConflicts then
            for _, conflict in ipairs(conflicts) do
                if conflict.type == "active_stargate" then
                    table.insert(issues, "Active Stargate interference: " .. conflict.message)
                else
                    table.insert(warnings, "Potential conflict: " .. conflict.message)
                end
            end
        end
    end

    -- Check for transportation system conflicts
    local nearbyTransporters = ents.FindInSphere(destination, 200)
    for _, ent in ipairs(nearbyTransporters) do
        if IsValid(ent) then
            local category = HYPERDRIVE.CAP.GetEntityCategory(ent:GetClass())
            if category == "transportation" then
                table.insert(warnings, "Destination near transportation system: " .. ent:GetClass())
            end
        end
    end

    local isValid = #issues == 0
    local allIssues = {}

    for _, issue in ipairs(issues) do
        table.insert(allIssues, {type = "error", message = issue})
    end
    for _, warning in ipairs(warnings) do
        table.insert(allIssues, {type = "warning", message = warning})
    end

    return isValid, allIssues
end

print("[Hyperdrive] CAP (Carter Addon Pack) integration loaded successfully")
