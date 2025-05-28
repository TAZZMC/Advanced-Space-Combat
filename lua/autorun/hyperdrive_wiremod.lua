-- Hyperdrive Wiremod Integration
-- This file adds comprehensive Wiremod support to all hyperdrive entities

if not WireLib then return end -- Exit if Wiremod is not installed

HYPERDRIVE.Wire = HYPERDRIVE.Wire or {}

-- Wire input/output definitions for each entity type
HYPERDRIVE.Wire.Definitions = {
    hyperdrive_engine = {
        inputs = {
            "Jump [NORMAL]",
            "SetDestinationX [NORMAL]",
            "SetDestinationY [NORMAL]",
            "SetDestinationZ [NORMAL]",
            "SetDestination [VECTOR]",
            "Abort [NORMAL]",
            "SetEnergy [NORMAL]",
            "AttachVehicle [ENTITY]"
        },
        outputs = {
            "Energy [NORMAL]",
            "EnergyPercent [NORMAL]",
            "Charging [NORMAL]",
            "Cooldown [NORMAL]",
            "JumpReady [NORMAL]",
            "Destination [VECTOR]",
            "AttachedVehicle [ENTITY]",
            "Status [STRING]"
        }
    },

    hyperdrive_computer = {
        inputs = {
            "FleetJump [NORMAL]",
            "SetMode [NORMAL]",
            "SetDestination [VECTOR]",
            "PowerToggle [NORMAL]",
            "ScanEngines [NORMAL]"
        },
        outputs = {
            "Powered [NORMAL]",
            "Mode [NORMAL]",
            "LinkedEngines [NORMAL]",
            "OnlineEngines [NORMAL]",
            "ChargingEngines [NORMAL]",
            "ReadyEngines [NORMAL]",
            "TotalEnergy [NORMAL]",
            "MaxEnergy [NORMAL]",
            "FleetStatus [STRING]"
        }
    },

    hyperdrive_beacon = {
        inputs = {
            "SetActive [NORMAL]",
            "SetRange [NORMAL]",
            "SetName [STRING]",
            "Pulse [NORMAL]"
        },
        outputs = {
            "Active [NORMAL]",
            "Range [NORMAL]",
            "BeaconName [STRING]",
            "BeaconID [NORMAL]",
            "NearbyEngines [NORMAL]"
        }
    }
}

-- Initialize wire support for an entity
function HYPERDRIVE.Wire.Initialize(ent)
    if not IsValid(ent) or not WireLib then return end

    local class = ent:GetClass()
    local def = HYPERDRIVE.Wire.Definitions[class]
    if not def then return end

    -- Set up inputs
    if def.inputs then
        WireLib.CreateInputs(ent, def.inputs)
    end

    -- Set up outputs
    if def.outputs then
        WireLib.CreateOutputs(ent, def.outputs)
    end

    -- Store wire data
    ent.WireInputs = ent.WireInputs or {}
    ent.WireOutputs = ent.WireOutputs or {}

    print("[Hyperdrive Wire] Initialized wire support for " .. class)
end

-- Handle wire input triggers
function HYPERDRIVE.Wire.TriggerInput(ent, iname, value)
    if not IsValid(ent) or not WireLib then return end

    local class = ent:GetClass()

    if class == "hyperdrive_engine" then
        HYPERDRIVE.Wire.HandleEngineInput(ent, iname, value)
    elseif class == "hyperdrive_computer" then
        HYPERDRIVE.Wire.HandleComputerInput(ent, iname, value)
    elseif class == "hyperdrive_beacon" then
        HYPERDRIVE.Wire.HandleBeaconInput(ent, iname, value)
    end
end

-- Hyperdrive Engine wire input handlers
function HYPERDRIVE.Wire.HandleEngineInput(ent, iname, value)
    if iname == "Jump" and value > 0 then
        local success, message = ent:StartJump()
        WireLib.TriggerOutput(ent, "Status", success and "JUMPING" or message)

    elseif iname == "SetDestinationX" then
        local dest = ent:GetDestination()
        dest.x = value
        ent:SetDestinationPos(dest)

    elseif iname == "SetDestinationY" then
        local dest = ent:GetDestination()
        dest.y = value
        ent:SetDestinationPos(dest)

    elseif iname == "SetDestinationZ" then
        local dest = ent:GetDestination()
        dest.z = value
        ent:SetDestinationPos(dest)

    elseif iname == "SetDestination" and isvector(value) then
        ent:SetDestinationPos(value)

    elseif iname == "Abort" and value > 0 then
        ent:AbortJump("Wire abort signal")
        WireLib.TriggerOutput(ent, "Status", "ABORTED")

    elseif iname == "SetEnergy" then
        local maxEnergy = (HYPERDRIVE.Config and HYPERDRIVE.Config.MaxEnergy) or 1000
        ent:SetEnergy(math.Clamp(value, 0, maxEnergy))

    elseif iname == "AttachVehicle" and IsValid(value) and value:IsVehicle() then
        ent:SetAttachedVehicle(value)
    end
end

-- Hyperdrive Computer wire input handlers
function HYPERDRIVE.Wire.HandleComputerInput(ent, iname, value)
    if iname == "FleetJump" and value > 0 then
        local dest = ent.WireInputs.SetDestination or Vector(0, 0, 0)
        if dest ~= Vector(0, 0, 0) then
            local success, message = ent:ExecuteFleetJump(dest)
            WireLib.TriggerOutput(ent, "FleetStatus", message)
        end

    elseif iname == "SetMode" then
        local mode = math.Clamp(math.floor(value), 1, 3)
        ent:SetComputerMode(mode)

    elseif iname == "SetDestination" and isvector(value) then
        ent.WireInputs.SetDestination = value

    elseif iname == "PowerToggle" and value > 0 then
        ent:SetPowered(not ent:GetPowered())

    elseif iname == "ScanEngines" and value > 0 then
        ent:AutoLinkEngines()
    end
end

-- Hyperdrive Beacon wire input handlers
function HYPERDRIVE.Wire.HandleBeaconInput(ent, iname, value)
    if iname == "SetActive" then
        ent:SetActive(value > 0)

    elseif iname == "SetRange" then
        ent:SetRange(math.Clamp(value, 500, 10000))

    elseif iname == "SetName" and isstring(value) then
        ent:SetBeaconName(value)

    elseif iname == "Pulse" and value > 0 then
        ent:SendPulse()
    end
end

-- Update wire outputs for an entity
function HYPERDRIVE.Wire.UpdateOutputs(ent)
    if not IsValid(ent) or not WireLib then return end

    local class = ent:GetClass()

    if class == "hyperdrive_engine" then
        HYPERDRIVE.Wire.UpdateEngineOutputs(ent)
    elseif class == "hyperdrive_computer" then
        HYPERDRIVE.Wire.UpdateComputerOutputs(ent)
    elseif class == "hyperdrive_beacon" then
        HYPERDRIVE.Wire.UpdateBeaconOutputs(ent)
    end
end

-- Update hyperdrive engine outputs
function HYPERDRIVE.Wire.UpdateEngineOutputs(ent)
    WireLib.TriggerOutput(ent, "Energy", ent:GetEnergy())
    WireLib.TriggerOutput(ent, "EnergyPercent", ent:GetEnergyPercent())
    WireLib.TriggerOutput(ent, "Charging", ent:GetCharging() and 1 or 0)
    WireLib.TriggerOutput(ent, "Cooldown", ent:GetCooldownRemaining())
    WireLib.TriggerOutput(ent, "JumpReady", ent:CanJump() and 1 or 0)
    WireLib.TriggerOutput(ent, "Destination", ent:GetDestination())
    WireLib.TriggerOutput(ent, "AttachedVehicle", ent:GetAttachedVehicle())

    local status = "READY"
    if ent:GetCharging() then
        status = "CHARGING"
    elseif ent:IsOnCooldown() then
        status = "COOLDOWN"
    elseif ent:GetDestination() == Vector(0, 0, 0) then
        status = "NO_DESTINATION"
    elseif ent:GetEnergy() <= 0 then
        status = "NO_ENERGY"
    end
    WireLib.TriggerOutput(ent, "Status", status)
end

-- Update hyperdrive computer outputs
function HYPERDRIVE.Wire.UpdateComputerOutputs(ent)
    WireLib.TriggerOutput(ent, "Powered", ent:GetPowered() and 1 or 0)
    WireLib.TriggerOutput(ent, "Mode", ent:GetComputerMode())

    local status = ent:GetEngineStatus()
    WireLib.TriggerOutput(ent, "LinkedEngines", status.total)
    WireLib.TriggerOutput(ent, "OnlineEngines", status.online)
    WireLib.TriggerOutput(ent, "ChargingEngines", status.charging)
    WireLib.TriggerOutput(ent, "ReadyEngines", status.ready)
    WireLib.TriggerOutput(ent, "TotalEnergy", status.totalEnergy)
    WireLib.TriggerOutput(ent, "MaxEnergy", status.maxEnergy)

    local fleetStatus = string.format("%d/%d READY", status.ready, status.total)
    WireLib.TriggerOutput(ent, "FleetStatus", fleetStatus)
end

-- Update hyperdrive beacon outputs
function HYPERDRIVE.Wire.UpdateBeaconOutputs(ent)
    WireLib.TriggerOutput(ent, "Active", ent:GetActive() and 1 or 0)
    WireLib.TriggerOutput(ent, "Range", ent:GetRange())
    WireLib.TriggerOutput(ent, "BeaconName", ent:GetBeaconName())
    WireLib.TriggerOutput(ent, "BeaconID", ent:GetBeaconID())

    -- Count nearby engines
    local nearbyEngines = 0
    local engines = ents.FindInSphere(ent:GetPos(), ent:GetRange())
    for _, engine in ipairs(engines) do
        if engine:GetClass() == "hyperdrive_engine" then
            nearbyEngines = nearbyEngines + 1
        end
    end
    WireLib.TriggerOutput(ent, "NearbyEngines", nearbyEngines)
end

-- Hook into entity initialization
hook.Add("OnEntityCreated", "HyperdriveWireInit", function(ent)
    timer.Simple(0.1, function()
        if IsValid(ent) and HYPERDRIVE.Wire.Definitions[ent:GetClass()] then
            HYPERDRIVE.Wire.Initialize(ent)
        end
    end)
end)

-- Regular output updates
timer.Create("HyperdriveWireUpdates", 0.5, 0, function()
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and HYPERDRIVE.Wire.Definitions[ent:GetClass()] then
            HYPERDRIVE.Wire.UpdateOutputs(ent)
        end
    end
end)

print("[Hyperdrive] Wiremod integration loaded")
