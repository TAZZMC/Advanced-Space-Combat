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
            "Status [STRING]",
            "ShipDetected [NORMAL]",
            "ShipType [STRING]",
            "ShipEntityCount [NORMAL]",
            "ShipPlayerCount [NORMAL]",
            "ShipMass [NORMAL]",
            "ShipCoreValid [NORMAL]",
            "ShipCoreStatus [STRING]",
            "ShipName [STRING]",
            "ShipNameValid [NORMAL]",
            "ShieldActive [NORMAL]",
            "ShieldStrength [NORMAL]",
            "ShieldPercent [NORMAL]",
            "ShieldRecharging [NORMAL]",
            "ShieldOverloaded [NORMAL]",
            "CAPIntegrated [NORMAL]",
            "HullIntegrity [NORMAL]",
            "HullIntegrityPercent [NORMAL]",
            "HullCriticalMode [NORMAL]",
            "HullEmergencyMode [NORMAL]",
            "HullBreaches [NORMAL]",
            "HullSystemFailures [NORMAL]",
            "HullAutoRepairActive [NORMAL]",
            "HullRepairProgress [NORMAL]",
            "HullTotalDamage [NORMAL]",
            "HullDamagedSections [NORMAL]"
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
    },

    ship_core = {
        inputs = {
            "SetShipName [STRING]",
            "RepairHull [NORMAL]",
            "EmergencyRepair [NORMAL]",
            "ActivateShields [NORMAL]",
            "DeactivateShields [NORMAL]",
            "ToggleFrontIndicator [NORMAL]",
            "DistributeResources [NORMAL]",
            "CollectResources [NORMAL]",
            "BalanceResources [NORMAL]",
            "SetEnergyCapacity [NORMAL]",
            "SetOxygenCapacity [NORMAL]",
            "SetCoolantCapacity [NORMAL]",
            "SetFuelCapacity [NORMAL]"
        },
        outputs = {
            "CoreState [NORMAL]",
            "CoreValid [NORMAL]",
            "ShipDetected [NORMAL]",
            "ShipType [STRING]",
            "ShipName [STRING]",
            "ShipNameValid [NORMAL]",
            "EntityCount [NORMAL]",
            "PlayerCount [NORMAL]",
            "ShipMass [NORMAL]",
            "HullIntegrity [NORMAL]",
            "HullSystemActive [NORMAL]",
            "ShieldStrength [NORMAL]",
            "ShieldSystemActive [NORMAL]",
            "StatusMessage [STRING]",
            "EnergyLevel [NORMAL]",
            "OxygenLevel [NORMAL]",
            "CoolantLevel [NORMAL]",
            "FuelLevel [NORMAL]",
            "WaterLevel [NORMAL]",
            "NitrogenLevel [NORMAL]",
            "ResourceEmergency [NORMAL]",
            "ResourceSystemActive [NORMAL]",
            "TotalResourceCapacity [NORMAL]",
            "TotalResourceAmount [NORMAL]",

            -- CAP Integration Outputs
            "CAPIntegrationActive [NORMAL]",
            "CAPShieldsDetected [NORMAL]",
            "CAPEnergyDetected [NORMAL]",
            "CAPResourcesDetected [NORMAL]",
            "CAPEnergyLevel [NORMAL]",
            "CAPShieldCount [NORMAL]",
            "CAPEntityCount [NORMAL]",
            "CAPVersion [STRING]",
            "CAPStatus [STRING]"
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
    elseif class == "ship_core" then
        HYPERDRIVE.Wire.HandleShipCoreInput(ent, iname, value)
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

-- Ship Core wire input handlers
function HYPERDRIVE.Wire.HandleShipCoreInput(ent, iname, value)
    if iname == "SetShipName" and isstring(value) then
        local success, result = ent:SetShipNameSafe(value)
        WireLib.TriggerOutput(ent, "ShipNameValid", success and 1 or 0)
        if success then
            WireLib.TriggerOutput(ent, "ShipName", result)
        end

    elseif iname == "RepairHull" and value > 0 then
        if HYPERDRIVE.HullDamage then
            local amount = math.Clamp(value, 1, 100)
            HYPERDRIVE.HullDamage.RepairHull(ent, amount)
        end

    elseif iname == "EmergencyRepair" and value > 0 then
        if HYPERDRIVE.HullDamage then
            HYPERDRIVE.HullDamage.RepairHull(ent, 50)
        end

    elseif iname == "ActivateShields" and value > 0 then
        if HYPERDRIVE.Shields and ent.ship then
            HYPERDRIVE.Shields.ActivateShield(ent, ent.ship)
        end

    elseif iname == "DeactivateShields" and value > 0 then
        if HYPERDRIVE.Shields then
            HYPERDRIVE.Shields.DeactivateShield(ent)
        end

    elseif iname == "ToggleFrontIndicator" and value > 0 then
        if ent.ship then
            local visible = ent.ship:IsFrontIndicatorVisible()
            if visible then
                ent.ship:HideFrontIndicator()
            else
                ent.ship:ShowFrontIndicator()
            end
        end

    -- Resource management inputs
    elseif iname == "DistributeResources" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.DistributeResources(ent)
        end

    elseif iname == "CollectResources" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.CollectResources(ent)
        end

    elseif iname == "BalanceResources" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.AutoBalanceResources(ent)
        end

    elseif iname == "SetEnergyCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(ent, "energy", value)
        end

    elseif iname == "SetOxygenCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(ent, "oxygen", value)
        end

    elseif iname == "SetCoolantCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(ent, "coolant", value)
        end

    elseif iname == "SetFuelCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(ent, "fuel", value)
        end
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
    elseif class == "ship_core" then
        HYPERDRIVE.Wire.UpdateShipCoreOutputs(ent)
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

-- Update ship core outputs
function HYPERDRIVE.Wire.UpdateShipCoreOutputs(ent)
    WireLib.TriggerOutput(ent, "CoreState", ent:GetState())
    WireLib.TriggerOutput(ent, "CoreValid", ent:GetCoreValid() and 1 or 0)
    WireLib.TriggerOutput(ent, "ShipDetected", ent:GetShipDetected() and 1 or 0)
    WireLib.TriggerOutput(ent, "ShipType", ent:GetShipType())
    WireLib.TriggerOutput(ent, "ShipName", ent:GetShipName())
    WireLib.TriggerOutput(ent, "HullIntegrity", ent:GetHullIntegrity())
    WireLib.TriggerOutput(ent, "HullSystemActive", ent:GetHullSystemActive() and 1 or 0)
    WireLib.TriggerOutput(ent, "ShieldStrength", ent:GetShieldStrength())
    WireLib.TriggerOutput(ent, "ShieldSystemActive", ent:GetShieldSystemActive() and 1 or 0)

    -- Ambient sound outputs
    if ent.IsAmbientSoundMuted then
        WireLib.TriggerOutput(ent, "AmbientSoundMuted", ent:IsAmbientSoundMuted() and 1 or 0)
    else
        WireLib.TriggerOutput(ent, "AmbientSoundMuted", 0)
    end
    WireLib.TriggerOutput(ent, "StatusMessage", ent:GetStatusMessage())

    -- Validate ship name
    local shipName = ent:GetShipName()
    local valid, _ = ent:ValidateShipName(shipName)
    WireLib.TriggerOutput(ent, "ShipNameValid", valid and 1 or 0)

    -- Get ship data if available
    if ent.ship then
        WireLib.TriggerOutput(ent, "EntityCount", #ent.ship:GetEntities())
        WireLib.TriggerOutput(ent, "PlayerCount", #ent.ship:GetPlayers())
        WireLib.TriggerOutput(ent, "ShipMass", ent.ship:GetMass())
    else
        WireLib.TriggerOutput(ent, "EntityCount", 0)
        WireLib.TriggerOutput(ent, "PlayerCount", 0)
        WireLib.TriggerOutput(ent, "ShipMass", 0)
    end

    -- Resource system outputs
    if HYPERDRIVE.SB3Resources then
        local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(ent)
        if storage then
            WireLib.TriggerOutput(ent, "ResourceSystemActive", 1)
            WireLib.TriggerOutput(ent, "EnergyLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ent, "energy"))
            WireLib.TriggerOutput(ent, "OxygenLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ent, "oxygen"))
            WireLib.TriggerOutput(ent, "CoolantLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ent, "coolant"))
            WireLib.TriggerOutput(ent, "FuelLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ent, "fuel"))
            WireLib.TriggerOutput(ent, "WaterLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ent, "water"))
            WireLib.TriggerOutput(ent, "NitrogenLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ent, "nitrogen"))
            WireLib.TriggerOutput(ent, "ResourceEmergency", storage.emergencyMode and 1 or 0)

            -- Calculate total resource capacity and amount
            local totalCapacity = 0
            local totalAmount = 0
            for resourceType, capacity in pairs(storage.capacity) do
                totalCapacity = totalCapacity + capacity
                totalAmount = totalAmount + storage.resources[resourceType]
            end
            WireLib.TriggerOutput(ent, "TotalResourceCapacity", totalCapacity)
            WireLib.TriggerOutput(ent, "TotalResourceAmount", totalAmount)
        else
            WireLib.TriggerOutput(ent, "ResourceSystemActive", 0)
            WireLib.TriggerOutput(ent, "EnergyLevel", 0)
            WireLib.TriggerOutput(ent, "OxygenLevel", 0)
            WireLib.TriggerOutput(ent, "CoolantLevel", 0)
            WireLib.TriggerOutput(ent, "FuelLevel", 0)
            WireLib.TriggerOutput(ent, "WaterLevel", 0)
            WireLib.TriggerOutput(ent, "NitrogenLevel", 0)
            WireLib.TriggerOutput(ent, "ResourceEmergency", 0)
            WireLib.TriggerOutput(ent, "TotalResourceCapacity", 0)
            WireLib.TriggerOutput(ent, "TotalResourceAmount", 0)
        end
    else
        WireLib.TriggerOutput(ent, "ResourceSystemActive", 0)
        WireLib.TriggerOutput(ent, "EnergyLevel", 0)
        WireLib.TriggerOutput(ent, "OxygenLevel", 0)
        WireLib.TriggerOutput(ent, "CoolantLevel", 0)
        WireLib.TriggerOutput(ent, "FuelLevel", 0)
        WireLib.TriggerOutput(ent, "WaterLevel", 0)
        WireLib.TriggerOutput(ent, "NitrogenLevel", 0)
        WireLib.TriggerOutput(ent, "ResourceEmergency", 0)
        WireLib.TriggerOutput(ent, "TotalResourceCapacity", 0)
        WireLib.TriggerOutput(ent, "TotalResourceAmount", 0)
    end

    -- CAP integration outputs
    WireLib.TriggerOutput(ent, "CAPIntegrationActive", ent:GetNWBool("CAPIntegrationActive", false) and 1 or 0)
    WireLib.TriggerOutput(ent, "CAPShieldsDetected", ent:GetNWBool("CAPShieldsDetected", false) and 1 or 0)
    WireLib.TriggerOutput(ent, "CAPEnergyDetected", ent:GetNWBool("CAPEnergyDetected", false) and 1 or 0)
    WireLib.TriggerOutput(ent, "CAPResourcesDetected", ent:GetNWBool("CAPResourcesDetected", false) and 1 or 0)
    WireLib.TriggerOutput(ent, "CAPEnergyLevel", ent:GetNWFloat("CAPEnergyLevel", 0))
    WireLib.TriggerOutput(ent, "CAPShieldCount", ent:GetNWInt("CAPShieldCount", 0))
    WireLib.TriggerOutput(ent, "CAPEntityCount", ent:GetNWInt("CAPEntityCount", 0))
    WireLib.TriggerOutput(ent, "CAPVersion", ent:GetNWString("CAPVersion", "Unknown"))
    WireLib.TriggerOutput(ent, "CAPStatus", ent:GetNWString("CAPStatus", "Unknown"))
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
