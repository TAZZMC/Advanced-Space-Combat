-- Advanced Space Combat - CAP Entity Communication System v3.0
-- Direct communication and control interface for CAP entities
-- Provides unified API for interacting with different CAP entity types

print("[Advanced Space Combat] CAP Entity Communication System v3.0 - Loading...")

-- Initialize communication namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.Communication = ASC.CAP.Communication or {}

-- Communication protocols for different CAP entity types
ASC.CAP.Communication.Protocols = {
    -- Stargate communication protocol
    STARGATE = {
        methods = {
            dial = {"Dial", "DialAddress", "StartDial"},
            abort = {"AbortDial", "StopDial", "CancelDial"},
            getAddress = {"GetAddress", "GetGateAddress", "GetMyAddress"},
            setAddress = {"SetAddress", "SetGateAddress", "SetMyAddress"},
            getStatus = {"GetStatus", "GetGateStatus", "IsDialing"},
            close = {"CloseGate", "Close", "Disconnect"}
        },
        properties = {
            address = {"Address", "GateAddress", "MyAddress"},
            network = {"Network", "GateNetwork"},
            locked = {"Locked", "IsLocked", "GateLocked"}
        }
    },
    
    -- Shield communication protocol
    SHIELD = {
        methods = {
            activate = {"Activate", "TurnOn", "Enable", "SetActive"},
            deactivate = {"Deactivate", "TurnOff", "Disable", "SetActive"},
            setStrength = {"SetShieldStrength", "SetStrength", "SetPower"},
            getStrength = {"GetShieldStrength", "GetStrength", "GetPower"},
            setFrequency = {"SetFrequency", "SetShieldFrequency"},
            getFrequency = {"GetFrequency", "GetShieldFrequency"}
        },
        properties = {
            strength = {"ShieldStrength", "Strength", "Power"},
            frequency = {"Frequency", "ShieldFrequency"},
            active = {"Active", "Enabled", "On"}
        }
    },
    
    -- Energy system communication protocol
    ENERGY = {
        methods = {
            getEnergy = {"GetEnergy", "GetPower", "GetStoredEnergy"},
            setEnergy = {"SetEnergy", "SetPower", "SetStoredEnergy"},
            getCapacity = {"GetCapacity", "GetMaxEnergy", "GetMaxPower"},
            transfer = {"TransferEnergy", "TransferPower", "GiveEnergy"}
        },
        properties = {
            energy = {"Energy", "Power", "StoredEnergy"},
            capacity = {"Capacity", "MaxEnergy", "MaxPower"},
            efficiency = {"Efficiency", "PowerEfficiency"}
        }
    },
    
    -- Transportation system communication protocol
    TRANSPORT = {
        methods = {
            transport = {"Transport", "Beam", "Teleport"},
            setTarget = {"SetTarget", "SetDestination", "SetBeamTarget"},
            getTarget = {"GetTarget", "GetDestination", "GetBeamTarget"},
            activate = {"Activate", "StartTransport", "BeginBeam"}
        },
        properties = {
            target = {"Target", "Destination", "BeamTarget"},
            range = {"Range", "TransportRange", "BeamRange"},
            active = {"Active", "Transporting", "Beaming"}
        }
    }
}

-- Universal CAP entity communication function
function ASC.CAP.Communication.SendCommand(entity, command, parameters)
    if not IsValid(entity) then return false, "Invalid entity" end
    
    local entityClass = entity:GetClass()
    local category = HYPERDRIVE.CAP.GetEntityCategory and HYPERDRIVE.CAP.GetEntityCategory(entityClass)
    
    if not category then
        return false, "Entity is not a recognized CAP entity"
    end
    
    local protocol = ASC.CAP.Communication.Protocols[category]
    if not protocol then
        return false, "No communication protocol for category: " .. category
    end
    
    -- Find the appropriate method for this command
    local methods = protocol.methods[command]
    if not methods then
        return false, "Unknown command: " .. command
    end
    
    -- Try each method until one works
    for _, methodName in ipairs(methods) do
        if entity[methodName] then
            local success, result = pcall(entity[methodName], entity, unpack(parameters or {}))
            if success then
                return true, result
            end
        end
    end
    
    return false, "No compatible method found for command: " .. command
end

-- Get property from CAP entity
function ASC.CAP.Communication.GetProperty(entity, property)
    if not IsValid(entity) then return nil, "Invalid entity" end
    
    local entityClass = entity:GetClass()
    local category = HYPERDRIVE.CAP.GetEntityCategory and HYPERDRIVE.CAP.GetEntityCategory(entityClass)
    
    if not category then
        return nil, "Entity is not a recognized CAP entity"
    end
    
    local protocol = ASC.CAP.Communication.Protocols[category]
    if not protocol then
        return nil, "No communication protocol for category: " .. category
    end
    
    -- Find the appropriate property
    local properties = protocol.properties[property]
    if not properties then
        return nil, "Unknown property: " .. property
    end
    
    -- Try each property name until one works
    for _, propName in ipairs(properties) do
        if entity[propName] ~= nil then
            return entity[propName], nil
        end
        
        -- Try getter method
        local getterName = "Get" .. propName
        if entity[getterName] then
            local success, result = pcall(entity[getterName], entity)
            if success then
                return result, nil
            end
        end
    end
    
    return nil, "Property not found: " .. property
end

-- Set property on CAP entity
function ASC.CAP.Communication.SetProperty(entity, property, value)
    if not IsValid(entity) then return false, "Invalid entity" end
    
    local entityClass = entity:GetClass()
    local category = HYPERDRIVE.CAP.GetEntityCategory and HYPERDRIVE.CAP.GetEntityCategory(entityClass)
    
    if not category then
        return false, "Entity is not a recognized CAP entity"
    end
    
    local protocol = ASC.CAP.Communication.Protocols[category]
    if not protocol then
        return false, "No communication protocol for category: " .. category
    end
    
    -- Find the appropriate property
    local properties = protocol.properties[property]
    if not properties then
        return false, "Unknown property: " .. property
    end
    
    -- Try each property name until one works
    for _, propName in ipairs(properties) do
        -- Try direct assignment
        if entity[propName] ~= nil then
            entity[propName] = value
            return true, nil
        end
        
        -- Try setter method
        local setterName = "Set" .. propName
        if entity[setterName] then
            local success, result = pcall(entity[setterName], entity, value)
            if success then
                return true, result
            end
        end
    end
    
    return false, "Property cannot be set: " .. property
end

-- High-level CAP entity control functions
ASC.CAP.Communication.Control = {}

-- Control stargate
function ASC.CAP.Communication.Control.Stargate(entity, action, parameters)
    if not IsValid(entity) then return false, "Invalid stargate" end
    
    parameters = parameters or {}
    
    if action == "dial" then
        local address = parameters.address or parameters[1]
        if not address then return false, "No address specified" end
        
        return ASC.CAP.Communication.SendCommand(entity, "dial", {address})
        
    elseif action == "abort" then
        return ASC.CAP.Communication.SendCommand(entity, "abort", {})
        
    elseif action == "close" then
        return ASC.CAP.Communication.SendCommand(entity, "close", {})
        
    elseif action == "get_address" then
        return ASC.CAP.Communication.GetProperty(entity, "address")
        
    elseif action == "set_address" then
        local address = parameters.address or parameters[1]
        if not address then return false, "No address specified" end
        
        return ASC.CAP.Communication.SetProperty(entity, "address", address)
        
    elseif action == "get_status" then
        return ASC.CAP.Communication.GetProperty(entity, "status")
        
    else
        return false, "Unknown stargate action: " .. action
    end
end

-- Control shield
function ASC.CAP.Communication.Control.Shield(entity, action, parameters)
    if not IsValid(entity) then return false, "Invalid shield" end
    
    parameters = parameters or {}
    
    if action == "activate" then
        return ASC.CAP.Communication.SendCommand(entity, "activate", {true})
        
    elseif action == "deactivate" then
        return ASC.CAP.Communication.SendCommand(entity, "deactivate", {false})
        
    elseif action == "set_strength" then
        local strength = parameters.strength or parameters[1]
        if not strength then return false, "No strength specified" end
        
        return ASC.CAP.Communication.SendCommand(entity, "setStrength", {strength})
        
    elseif action == "get_strength" then
        return ASC.CAP.Communication.SendCommand(entity, "getStrength", {})
        
    elseif action == "set_frequency" then
        local frequency = parameters.frequency or parameters[1]
        if not frequency then return false, "No frequency specified" end
        
        return ASC.CAP.Communication.SendCommand(entity, "setFrequency", {frequency})
        
    elseif action == "get_frequency" then
        return ASC.CAP.Communication.SendCommand(entity, "getFrequency", {})
        
    else
        return false, "Unknown shield action: " .. action
    end
end

-- Control energy system
function ASC.CAP.Communication.Control.Energy(entity, action, parameters)
    if not IsValid(entity) then return false, "Invalid energy system" end
    
    parameters = parameters or {}
    
    if action == "get_energy" then
        return ASC.CAP.Communication.SendCommand(entity, "getEnergy", {})
        
    elseif action == "set_energy" then
        local energy = parameters.energy or parameters[1]
        if not energy then return false, "No energy amount specified" end
        
        return ASC.CAP.Communication.SendCommand(entity, "setEnergy", {energy})
        
    elseif action == "get_capacity" then
        return ASC.CAP.Communication.SendCommand(entity, "getCapacity", {})
        
    elseif action == "transfer" then
        local target = parameters.target or parameters[1]
        local amount = parameters.amount or parameters[2]
        if not target or not amount then return false, "Target and amount required" end
        
        return ASC.CAP.Communication.SendCommand(entity, "transfer", {target, amount})
        
    else
        return false, "Unknown energy system action: " .. action
    end
end

-- Universal CAP entity control function
function ASC.CAP.Communication.ControlEntity(entity, action, parameters)
    if not IsValid(entity) then return false, "Invalid entity" end
    
    local entityClass = entity:GetClass()
    local category = HYPERDRIVE.CAP.GetEntityCategory and HYPERDRIVE.CAP.GetEntityCategory(entityClass)
    
    if not category then
        return false, "Entity is not a recognized CAP entity"
    end
    
    -- Route to appropriate control function
    if category == "STARGATES" then
        return ASC.CAP.Communication.Control.Stargate(entity, action, parameters)
    elseif category == "SHIELDS" then
        return ASC.CAP.Communication.Control.Shield(entity, action, parameters)
    elseif category == "ENERGY_SYSTEMS" then
        return ASC.CAP.Communication.Control.Energy(entity, action, parameters)
    else
        return false, "No control interface for category: " .. category
    end
end

-- Batch control multiple entities
function ASC.CAP.Communication.BatchControl(entities, action, parameters)
    if not entities or #entities == 0 then return false, "No entities specified" end
    
    local results = {}
    local successCount = 0
    
    for i, entity in ipairs(entities) do
        local success, result = ASC.CAP.Communication.ControlEntity(entity, action, parameters)
        results[i] = {
            entity = entity,
            success = success,
            result = result
        }
        
        if success then
            successCount = successCount + 1
        end
    end
    
    return successCount > 0, results
end

print("[Advanced Space Combat] CAP Entity Communication System v3.0 - Loaded")
