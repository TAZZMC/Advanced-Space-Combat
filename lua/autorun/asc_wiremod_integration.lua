-- Advanced Space Combat - Wiremod Integration System
-- Comprehensive wire-based ship control and automation

print("[Advanced Space Combat] Wiremod Integration v3.0.0 - Loading...")

-- Initialize ASC Wiremod integration
ASC = ASC or {}
ASC.Wiremod = ASC.Wiremod or {}
ASC.Wiremod.Version = "3.0.0"

-- Configuration
ASC.Wiremod.Config = {
    -- Wire interface settings
    EnableShipCoreWires = true,
    EnableWeaponWires = true,
    EnableHyperdriveWires = true,
    EnableShieldWires = true,
    
    -- Automation settings
    EnableAutoPilot = true,
    EnableCombatAI = true,
    EnableEmergencyProtocols = true,
    
    -- Safety settings
    RequireOwnership = true,
    EnableSafetyLimits = true,
    MaxWireDistance = 5000,
    
    -- Performance settings
    UpdateRate = 0.1, -- 10 Hz
    MaxWiredEntities = 100
}

-- Check if Wiremod is available
ASC.Wiremod.IsAvailable = function()
    return WireLib ~= nil and WireLib.CreateSpecialOutputs ~= nil
end

-- Get Wiremod version
ASC.Wiremod.GetVersion = function()
    if not ASC.Wiremod.IsAvailable() then return "Not Available" end
    return WireLib.Version or "Unknown"
end

-- Ship Core Wire Interface
ASC.Wiremod.SetupShipCoreWires = function(shipCore)
    if not IsValid(shipCore) or not ASC.Wiremod.IsAvailable() then return false end
    
    -- Setup wire outputs
    WireLib.CreateSpecialOutputs(shipCore, {
        "Ship Health",      -- Current ship condition (0-1)
        "Component Count",  -- Number of attached components
        "Power Level",      -- Current power status (0-1)
        "Shield Status",    -- Shield system status (0-1)
        "Hyperdrive Ready", -- Hyperdrive charge status (0/1)
        "Weapon Count",     -- Number of weapons attached
        "Threat Level",     -- Current threat assessment (0-1)
        "AI Status",        -- AI system operational status (0/1)
        "Position X",       -- Ship X coordinate
        "Position Y",       -- Ship Y coordinate
        "Position Z",       -- Ship Z coordinate
        "Velocity",         -- Ship velocity magnitude
        "Mass",             -- Total ship mass
        "Energy",           -- Current energy level
        "Temperature"       -- Ship core temperature
    }, {
        "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL",
        "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL"
    })
    
    -- Setup wire inputs
    WireLib.CreateSpecialInputs(shipCore, {
        "Activate Hyperdrive",  -- Trigger hyperdrive jump (0/1)
        "Set Destination X",    -- Hyperdrive destination X coordinate
        "Set Destination Y",    -- Hyperdrive destination Y coordinate
        "Set Destination Z",    -- Hyperdrive destination Z coordinate
        "Shield Override",      -- Manual shield control (0/1)
        "Weapon Fire",          -- Trigger weapon systems (0/1)
        "AI Mode",              -- Set AI operational mode (0-3)
        "Emergency Stop",       -- Emergency system shutdown (0/1)
        "Power Override",       -- Manual power control (0-1)
        "Navigation Mode",      -- Set navigation mode (0-2)
        "Combat Mode",          -- Set combat readiness (0-2)
        "Stealth Mode",         -- Enable stealth systems (0/1)
        "Formation Position",   -- Formation flying position (0-8)
        "Docking Mode",         -- Enable docking procedures (0/1)
        "Maintenance Mode"      -- Enable maintenance mode (0/1)
    }, {
        "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL",
        "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL", "NORMAL"
    })
    
    -- Initialize wire data
    shipCore.WireData = {
        outputs = {},
        inputs = {},
        lastUpdate = 0,
        updateRate = ASC.Wiremod.Config.UpdateRate
    }
    
    -- Setup update timer
    timer.Create("ASC_Wire_" .. shipCore:EntIndex(), ASC.Wiremod.Config.UpdateRate, 0, function()
        if IsValid(shipCore) then
            ASC.Wiremod.UpdateShipCoreWires(shipCore)
        else
            timer.Remove("ASC_Wire_" .. shipCore:EntIndex())
        end
    end)
    
    shipCore.WireEnabled = true
    return true
end

-- Update ship core wire outputs
ASC.Wiremod.UpdateShipCoreWires = function(shipCore)
    if not IsValid(shipCore) or not shipCore.WireEnabled then return end
    
    -- Calculate ship health
    local health = 1.0
    if shipCore.AIHealthScore then
        health = shipCore.AIHealthScore
    end
    
    -- Count components
    local componentCount = 0
    local weaponCount = 0
    local totalMass = 0
    
    for _, ent in ipairs(ents.FindInSphere(shipCore:GetPos(), 2000)) do
        if IsValid(ent) and ent ~= shipCore then
            local owner = nil
            if ent.CPPIGetOwner then
                owner = ent:CPPIGetOwner()
            else
                owner = ent:GetOwner()
            end

            local shipOwner = nil
            if shipCore.CPPIGetOwner then
                shipOwner = shipCore:CPPIGetOwner()
            else
                shipOwner = shipCore:GetOwner()
            end
            
            if IsValid(owner) and IsValid(shipOwner) and owner == shipOwner then
                componentCount = componentCount + 1
                
                local class = ent:GetClass()
                if string.find(class, "weapon") or string.find(class, "cannon") or string.find(class, "railgun") then
                    weaponCount = weaponCount + 1
                end
                
                if ent:GetPhysicsObject():IsValid() then
                    totalMass = totalMass + ent:GetPhysicsObject():GetMass()
                end
            end
        end
    end
    
    -- Calculate other values
    local powerLevel = 1.0 -- Default power level
    local shieldStatus = 0.0 -- Default no shields
    local hyperdriveReady = 0 -- Default not ready
    local threatLevel = 0.0 -- Default no threats
    local aiStatus = 0 -- Default AI off
    
    -- Check for AI integration
    if shipCore.AIMonitored then
        aiStatus = 1
        if shipCore.AIPerformanceMetrics then
            powerLevel = shipCore.AIPerformanceMetrics.efficiency or 1.0
        end
    end
    
    -- Get position and velocity
    local pos = shipCore:GetPos()
    local vel = shipCore:GetVelocity()
    local velocity = vel:Length()
    
    -- Update wire outputs
    WireLib.TriggerOutput(shipCore, "Ship Health", health)
    WireLib.TriggerOutput(shipCore, "Component Count", componentCount)
    WireLib.TriggerOutput(shipCore, "Power Level", powerLevel)
    WireLib.TriggerOutput(shipCore, "Shield Status", shieldStatus)
    WireLib.TriggerOutput(shipCore, "Hyperdrive Ready", hyperdriveReady)
    WireLib.TriggerOutput(shipCore, "Weapon Count", weaponCount)
    WireLib.TriggerOutput(shipCore, "Threat Level", threatLevel)
    WireLib.TriggerOutput(shipCore, "AI Status", aiStatus)
    WireLib.TriggerOutput(shipCore, "Position X", pos.x)
    WireLib.TriggerOutput(shipCore, "Position Y", pos.y)
    WireLib.TriggerOutput(shipCore, "Position Z", pos.z)
    WireLib.TriggerOutput(shipCore, "Velocity", velocity)
    WireLib.TriggerOutput(shipCore, "Mass", totalMass)
    WireLib.TriggerOutput(shipCore, "Energy", powerLevel * 100)
    WireLib.TriggerOutput(shipCore, "Temperature", 20 + (1 - health) * 80) -- Temperature based on health
end

-- Process ship core wire inputs
ASC.Wiremod.ProcessShipCoreInputs = function(shipCore)
    if not IsValid(shipCore) or not shipCore.WireEnabled then return end
    
    -- Get wire input values
    local activateHyperdrive = shipCore.Inputs and shipCore.Inputs["Activate Hyperdrive"] and shipCore.Inputs["Activate Hyperdrive"].Value or 0
    local destX = shipCore.Inputs and shipCore.Inputs["Set Destination X"] and shipCore.Inputs["Set Destination X"].Value or 0
    local destY = shipCore.Inputs and shipCore.Inputs["Set Destination Y"] and shipCore.Inputs["Set Destination Y"].Value or 0
    local destZ = shipCore.Inputs and shipCore.Inputs["Set Destination Z"] and shipCore.Inputs["Set Destination Z"].Value or 0
    local shieldOverride = shipCore.Inputs and shipCore.Inputs["Shield Override"] and shipCore.Inputs["Shield Override"].Value or 0
    local weaponFire = shipCore.Inputs and shipCore.Inputs["Weapon Fire"] and shipCore.Inputs["Weapon Fire"].Value or 0
    local aiMode = shipCore.Inputs and shipCore.Inputs["AI Mode"] and shipCore.Inputs["AI Mode"].Value or 0
    local emergencyStop = shipCore.Inputs and shipCore.Inputs["Emergency Stop"] and shipCore.Inputs["Emergency Stop"].Value or 0
    
    -- Process hyperdrive activation
    if activateHyperdrive > 0 and destX ~= 0 and destY ~= 0 and destZ ~= 0 then
        local destination = Vector(destX, destY, destZ)
        ASC.Wiremod.TriggerHyperdrive(shipCore, destination)
    end
    
    -- Process emergency stop
    if emergencyStop > 0 then
        ASC.Wiremod.EmergencyStop(shipCore)
    end
    
    -- Process AI mode changes
    if aiMode ~= (shipCore.LastAIMode or 0) then
        ASC.Wiremod.SetAIMode(shipCore, aiMode)
        shipCore.LastAIMode = aiMode
    end
end

-- Trigger hyperdrive via wire
ASC.Wiremod.TriggerHyperdrive = function(shipCore, destination)
    if not IsValid(shipCore) then return end
    
    -- Check if hyperdrive system exists
    if HYPERDRIVE and HYPERDRIVE.JumpToPosition then
        HYPERDRIVE.JumpToPosition(shipCore, destination)
    end
end

-- Emergency stop all ship systems
ASC.Wiremod.EmergencyStop = function(shipCore)
    if not IsValid(shipCore) then return end
    
    -- Stop all ship movement
    if shipCore:GetPhysicsObject():IsValid() then
        shipCore:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
        shipCore:GetPhysicsObject():SetAngleVelocity(Vector(0, 0, 0))
    end
    
    -- Disable AI systems
    if shipCore.AIMonitored then
        shipCore.AIStatus = "emergency_stop"
    end
    
    -- Notify owner
    local owner = nil
    if shipCore.CPPIGetOwner then
        owner = shipCore:CPPIGetOwner()
    else
        owner = shipCore:GetOwner()
    end
    if IsValid(owner) then
        owner:ChatPrint("[ASC] Emergency stop activated on ship!")
    end
end

-- Set AI mode via wire
ASC.Wiremod.SetAIMode = function(shipCore, mode)
    if not IsValid(shipCore) then return end
    
    local modes = {"disabled", "passive", "defensive", "aggressive"}
    local modeName = modes[math.Clamp(mode + 1, 1, #modes)]
    
    if shipCore.AIMonitored then
        shipCore.AIMode = modeName
    end
end

-- Hook into ship core creation
hook.Add("OnEntityCreated", "ASC_Wiremod_ShipCore", function(entity)
    timer.Simple(0.1, function()
        if IsValid(entity) and entity:GetClass() == "ship_core" and ASC.Wiremod.Config.EnableShipCoreWires then
            ASC.Wiremod.SetupShipCoreWires(entity)
        end
    end)
end)

-- Wire input processing
hook.Add("Think", "ASC_Wiremod_InputProcessing", function()
    for _, shipCore in ipairs(ents.FindByClass("ship_core")) do
        if IsValid(shipCore) and shipCore.WireEnabled then
            ASC.Wiremod.ProcessShipCoreInputs(shipCore)
        end
    end
end)

-- Console commands
if SERVER then
    concommand.Add("asc_wire_ship", function(player, cmd, args)
        if not IsValid(player) then return end
        
        local trace = player:GetEyeTrace()
        if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "ship_core" then
            player:ChatPrint("[ASC] Look at a ship core to setup wire interface")
            return
        end
        
        if ASC.Wiremod.SetupShipCoreWires(trace.Entity) then
            player:ChatPrint("[ASC] Wire interface setup successfully")
        else
            player:ChatPrint("[ASC] Failed to setup wire interface")
        end
    end)
    
    concommand.Add("asc_wire_status", function(player, cmd, args)
        if not IsValid(player) then return end
        
        local wiredShips = 0
        for _, shipCore in ipairs(ents.FindByClass("ship_core")) do
            if IsValid(shipCore) and shipCore.WireEnabled then
                wiredShips = wiredShips + 1
            end
        end
        
        player:ChatPrint("[ASC] Wire Status: " .. wiredShips .. " ships with wire interfaces")
        player:ChatPrint("[ASC] Wiremod Available: " .. (ASC.Wiremod.IsAvailable() and "Yes" or "No"))
    end)
end

-- Initialize integration
hook.Add("Initialize", "ASC_Wiremod_Initialize", function()
    if ASC.Wiremod.IsAvailable() then
        print("[Advanced Space Combat] Wiremod integration active - Version: " .. ASC.Wiremod.GetVersion())
    else
        print("[Advanced Space Combat] Wiremod not detected - Wire control disabled")
    end
end)

print("[Advanced Space Combat] Wiremod Integration loaded successfully")
