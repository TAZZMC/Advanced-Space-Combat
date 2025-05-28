-- Master Hyperdrive Engine - ALL FEATURES COMBINED
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_phx/construct/metal_plate_curve360x2.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(250) -- Heavier due to advanced systems
    end

    -- Initialize ALL hyperdrive properties
    self:SetEnergy(HYPERDRIVE.Config.MaxEnergy)
    self:SetCharging(false)
    self:SetCooldown(0)
    self:SetDestination(Vector(0, 0, 0))
    self:SetJumpReady(false)

    -- Spacebuild properties
    self:SetPowerLevel(0)
    self:SetOxygenLevel(0)
    self:SetCoolantLevel(0)
    self:SetTemperature(20)

    -- Stargate properties
    self:SetTechLevel("tau_ri")
    self:SetNaquadahLevel(0)
    self:SetZPMPower(0)
    self:SetGateAddress("")

    -- Master system properties
    self:SetSystemIntegration(0) -- Bitmask: 1=Wire, 2=SB, 4=SG
    self:SetEfficiencyRating(1.0)
    self:SetOperationalMode(1) -- 1=Standard, 2=Enhanced, 3=Maximum

    -- Integration data storage
    self.IntegrationData = {
        wiremod = {active = false, inputs = 0, outputs = 0},
        spacebuild = {active = false, resources = {}, lifesupport = false},
        stargate = {active = false, techLevel = "tau_ri", hasGate = false}
    }

    -- Initialize ALL integration systems
    self:InitializeWiremod()
    self:InitializeSpacebuild()
    self:InitializeStargate()

    -- Master timer for all systems
    timer.Create("hyperdrive_master_" .. self:EntIndex(), 0.5, 0, function()
        if IsValid(self) then
            self:UpdateAllSystems()
        else
            timer.Remove("hyperdrive_master_" .. self:EntIndex())
        end
    end)

    self.LastUse = 0
    self.Owner = nil

    print("[Hyperdrive Master] Engine initialized with ALL features")
end

function ENT:SetupDataTables()
    -- Core properties
    self:NetworkVar("Float", 0, "Energy")
    self:NetworkVar("Bool", 0, "Charging")
    self:NetworkVar("Float", 1, "Cooldown")
    self:NetworkVar("Vector", 0, "Destination")
    self:NetworkVar("Bool", 1, "JumpReady")
    self:NetworkVar("Entity", 0, "AttachedVehicle")

    -- Spacebuild properties
    self:NetworkVar("Float", 2, "PowerLevel")
    self:NetworkVar("Float", 3, "OxygenLevel")
    self:NetworkVar("Float", 4, "CoolantLevel")
    self:NetworkVar("Float", 5, "Temperature")

    -- Stargate properties
    self:NetworkVar("String", 0, "TechLevel")
    self:NetworkVar("Float", 6, "NaquadahLevel")
    self:NetworkVar("Float", 7, "ZPMPower")
    self:NetworkVar("String", 1, "GateAddress")

    -- Master system properties
    self:NetworkVar("Int", 0, "SystemIntegration")
    self:NetworkVar("Float", 8, "EfficiencyRating")
    self:NetworkVar("Int", 1, "OperationalMode")
end

function ENT:InitializeWiremod()
    if not WireLib then return end

    -- Combined inputs from all systems
    self.Inputs = WireLib.CreateInputs(self, {
        -- Core inputs
        "Jump",
        "SetDestination [VECTOR]",
        "Abort",
        "SetEnergy",
        "AttachVehicle [ENTITY]",

        -- Spacebuild inputs
        "PowerInput",
        "OxygenInput",
        "CoolantInput",

        -- Stargate inputs
        "SetGateAddress [STRING]",
        "SetTechLevel [STRING]",
        "ScanNetwork",

        -- Master inputs
        "SetMode",
        "SystemScan",
        "FleetCoordinate"
    })

    -- Combined outputs from all systems
    self.Outputs = WireLib.CreateOutputs(self, {
        -- Core outputs
        "Energy",
        "EnergyPercent",
        "Charging",
        "JumpReady",
        "Status [STRING]",

        -- Spacebuild outputs
        "PowerLevel",
        "OxygenLevel",
        "CoolantLevel",
        "Temperature",
        "LifeSupportStatus [STRING]",

        -- Stargate outputs
        "TechLevel [STRING]",
        "NaquadahLevel",
        "ZPMPower",
        "GateAddress [STRING]",
        "StargateStatus [STRING]",

        -- Master outputs
        "SystemIntegration",
        "EfficiencyRating",
        "OperationalMode",
        "IntegrationCount",
        "MasterStatus [STRING]"
    })

    self.IntegrationData.wiremod.active = true
    self:UpdateSystemIntegration()
end

function ENT:InitializeSpacebuild()
    if not CAF then return end

    -- Setup Spacebuild resource nodes
    self.SpacebuildNodes = {
        energy = {capacity = 2000, amount = 0},
        oxygen = {capacity = 1000, amount = 0},
        coolant = {capacity = 400, amount = 0}
    }

    self.IntegrationData.spacebuild.active = true
    self:UpdateSystemIntegration()
end

function ENT:InitializeStargate()
    if not StarGate then return end

    self.IntegrationData.stargate.active = true
    self:UpdateSystemIntegration()
end

function ENT:UpdateSystemIntegration()
    local integration = 0
    if self.IntegrationData.wiremod.active then integration = integration + 1 end
    if self.IntegrationData.spacebuild.active then integration = integration + 2 end
    if self.IntegrationData.stargate.active then integration = integration + 4 end

    self:SetSystemIntegration(integration)

    -- Calculate efficiency based on integrations
    local efficiency = 1.0
    local integrationCount = 0

    if self.IntegrationData.wiremod.active then integrationCount = integrationCount + 1 end
    if self.IntegrationData.spacebuild.active then
        integrationCount = integrationCount + 1
        efficiency = efficiency * 1.1 -- Spacebuild efficiency bonus
    end
    if self.IntegrationData.stargate.active then
        integrationCount = integrationCount + 1
        if HYPERDRIVE.Stargate then
            local techBonus = HYPERDRIVE.Stargate.GetTechBonus(self:GetTechLevel())
            efficiency = efficiency * techBonus
        end
    end

    -- Multi-system bonus
    if integrationCount > 1 then
        efficiency = efficiency * (1 + (integrationCount - 1) * 0.15) -- 15% per additional system
    end

    self:SetEfficiencyRating(efficiency)
end

function ENT:UpdateAllSystems()
    -- Update Spacebuild systems
    if self.IntegrationData.spacebuild.active and HYPERDRIVE.Spacebuild then
        self:UpdateSpacebuildSystems()
    end

    -- Update Stargate systems
    if self.IntegrationData.stargate.active and HYPERDRIVE.Stargate then
        self:UpdateStargateSystems()
    end

    -- Update master efficiency
    self:UpdateSystemIntegration()

    -- Update wire outputs
    if self.IntegrationData.wiremod.active then
        self:UpdateAllWireOutputs()
    end

    -- Recharge energy with efficiency bonus
    self:RechargeEnergyMaster()
end

function ENT:UpdateSpacebuildSystems()
    -- Get Spacebuild status
    if CAF and CAF.GetValue then
        self:SetPowerLevel(CAF.GetValue(self, "energy") or 0)
        self:SetOxygenLevel(CAF.GetValue(self, "oxygen") or 0)
        self:SetCoolantLevel(CAF.GetValue(self, "coolant") or 0)
    end

    -- Update temperature
    local currentTemp = self:GetTemperature()
    local targetTemp = 20

    if self:GetCharging() then
        targetTemp = 80
    elseif self:GetPowerLevel() > 0 then
        targetTemp = 40
    end

    if self:GetCoolantLevel() > 10 then
        targetTemp = targetTemp - 20
    end

    local newTemp = Lerp(0.1, currentTemp, targetTemp)
    self:SetTemperature(newTemp)
end

function ENT:UpdateStargateSystems()
    if not HYPERDRIVE.Stargate then return end

    local sgData = HYPERDRIVE.Stargate.HasStargateTech(self)
    self.IntegrationData.stargate = sgData

    self:SetTechLevel(sgData.techLevel)
    self:SetNaquadahLevel(sgData.hasNaquadah and 100 or 0)
    self:SetZPMPower(sgData.powerLevel)

    -- Find gate address
    if sgData.hasGate then
        local nearbyGates = ents.FindInSphere(self:GetPos(), 1000)
        for _, ent in ipairs(nearbyGates) do
            if IsValid(ent) and string.find(ent:GetClass(), "stargate") then
                if ent.GetAddress then
                    self:SetGateAddress(ent:GetAddress() or "")
                    break
                end
            end
        end
    end
end

function ENT:RechargeEnergyMaster()
    if self:GetCharging() or self:GetCooldown() > CurTime() then return end

    local currentEnergy = self:GetEnergy()
    local maxEnergy = (HYPERDRIVE.Config and HYPERDRIVE.Config.MaxEnergy) or 1000

    if currentEnergy < maxEnergy then
        local rechargeRate = (HYPERDRIVE.Config and HYPERDRIVE.Config.RechargeRate) or 5

        -- Apply efficiency bonus
        rechargeRate = rechargeRate * self:GetEfficiencyRating()

        -- Spacebuild power requirement
        if self.IntegrationData.spacebuild.active and self:GetPowerLevel() < 10 then
            rechargeRate = rechargeRate * 0.1 -- Severely reduced without power
        end

        -- ZPM bonus
        if self.IntegrationData.stargate.active and self:GetZPMPower() > 50 then
            rechargeRate = rechargeRate * 2
        end

        local newEnergy = math.min(maxEnergy, currentEnergy + rechargeRate)
        self:SetEnergy(newEnergy)
    end
end

function ENT:CanOperateMaster()
    local issues = {}

    -- Core checks
    if self:GetEnergy() <= 0 then
        table.insert(issues, "No energy")
    end

    if self:GetDestination() == Vector(0, 0, 0) then
        table.insert(issues, "No destination")
    end

    -- Spacebuild checks
    if self.IntegrationData.spacebuild.active and HYPERDRIVE.Spacebuild then
        local canOperate, reason = HYPERDRIVE.Spacebuild.CanOperate(self)
        if not canOperate then
            table.insert(issues, "SB: " .. reason)
        end
    end

    -- Stargate checks
    if self.IntegrationData.stargate.active and HYPERDRIVE.Stargate then
        if HYPERDRIVE.Stargate.Config.RequireNaquadah and self:GetNaquadahLevel() <= 0 then
            table.insert(issues, "SG: No naquadah")
        end
    end

    if #issues > 0 then
        return false, table.concat(issues, "; ")
    end

    return true, "All systems operational"
end

function ENT:StartJumpMaster()
    local canOperate, reason = self:CanOperateMaster()
    if not canOperate then
        return false, reason
    end

    if self:GetCharging() then return false, "Already charging" end
    if self:GetCooldown() > CurTime() then return false, "Cooldown active" end

    -- Calculate distance and energy cost (simplified)
    local destination = self:GetDestination()
    local distance = self:GetPos():Distance(destination)
    local energyCost = math.max(10, distance * 0.1)

    -- Apply Master Engine efficiency bonus
    if self.GetEfficiencyRating and type(self.GetEfficiencyRating) == "function" then
        local success, efficiency = pcall(self.GetEfficiencyRating, self)
        if success and efficiency and efficiency > 0 then
            energyCost = energyCost / efficiency
        else
            energyCost = energyCost / 1.2 -- Default 20% efficiency bonus
        end
    else
        energyCost = energyCost / 1.2 -- Default 20% efficiency bonus
    end

    if self:GetEnergy() < energyCost then
        return false, string.format("Insufficient energy (need %.0f, have %.0f)", energyCost, self:GetEnergy())
    end

    -- Start charging with efficiency bonus
    self:SetCharging(true)
    self:SetJumpReady(false)

    -- Enhanced charging effects
    self:EmitSound("ambient/energy/whiteflash.wav", 75, 100)

    -- Calculate charge time with all bonuses
    local chargeTime = (HYPERDRIVE.Config and HYPERDRIVE.Config.JumpChargeTime) or 3
    chargeTime = chargeTime / self:GetEfficiencyRating()

    timer.Create("hyperdrive_master_jump_" .. self:EntIndex(), chargeTime, 1, function()
        if IsValid(self) then
            self:ExecuteJumpMaster()
        end
    end)

    return true, string.format("Master jump initiated (%.1fx efficiency)", self:GetEfficiencyRating())
end

function ENT:ExecuteJumpMaster()
    local destination = self:GetDestination()

    -- Calculate energy cost (simplified)
    local distance = self:GetPos():Distance(destination)
    local energyCost = math.max(10, distance * 0.1)

    -- Apply Master Engine efficiency bonus
    if self.GetEfficiencyRating and type(self.GetEfficiencyRating) == "function" then
        local success, efficiency = pcall(self.GetEfficiencyRating, self)
        if success and efficiency and efficiency > 0 then
            energyCost = energyCost / efficiency
        else
            energyCost = energyCost / 1.2 -- Default 20% efficiency bonus
        end
    else
        energyCost = energyCost / 1.2 -- Default 20% efficiency bonus
    end

    -- Consume energy
    self:SetEnergy(self:GetEnergy() - energyCost)

    if GetConVar("developer"):GetInt() > 0 then
        print("[Hyperdrive Master] Executing jump:")
        print("  From: " .. tostring(self:GetPos()))
        print("  To: " .. tostring(destination))
        print("  Distance: " .. tostring(distance))
        print("  Energy consumed: " .. tostring(energyCost))
    end

    -- Check if we're already in a hyperspace transit (managed by computer or dimension system)
    if self.InHyperspace or
       (HYPERDRIVE.Hyperspace and HYPERDRIVE.Hyperspace.ActiveTransits and HYPERDRIVE.Hyperspace.ActiveTransits[self:EntIndex()]) or
       (HYPERDRIVE.HyperspaceDimension and self.HyperspaceTravelId) then
        if GetConVar("developer"):GetInt() > 0 then
            print("[Hyperdrive Master] Already in hyperspace transit, skipping direct transport")
        end

        -- Set cooldown and cleanup charging state
        local cooldownTime = (HYPERDRIVE.Config and HYPERDRIVE.Config.CooldownTime) or 10
        cooldownTime = cooldownTime / self:GetEfficiencyRating()
        self:SetCooldown(CurTime() + cooldownTime)
        self:SetCharging(false)
        self:SetJumpReady(false)
        return
    end

    -- Enhanced transport range based on integrations
    local transportRange = 200
    if self.IntegrationData.stargate.active and self:GetTechLevel() == "ancient" then
        transportRange = 400
    elseif self.IntegrationData.spacebuild.active then
        transportRange = 300
    end

    -- Transport entities (only if not using hyperspace system)
    local entitiesToMove = {self}

    local vehicle = self:GetAttachedVehicle()
    if IsValid(vehicle) then
        table.insert(entitiesToMove, vehicle)
        for i = 0, vehicle:GetPassengerCount() - 1 do
            local passenger = vehicle:GetPassenger(i)
            if IsValid(passenger) then
                table.insert(entitiesToMove, passenger)
            end
        end
    else
        local nearbyEnts = ents.FindInSphere(self:GetPos(), transportRange)
        for _, ent in ipairs(nearbyEnts) do
            if ent ~= self and (ent:IsPlayer() or ent:IsVehicle()) then
                table.insert(entitiesToMove, ent)
            end
        end
    end

    -- Create master jump effect
    self:CreateMasterJumpEffect(self:GetPos(), true)

    -- Send hyperspace window animation to nearby players
    for _, ply in ipairs(player.GetAll()) do
        local distance = ply:GetPos():Distance(self:GetPos())
        local inVehicle = IsValid(self:GetAttachedVehicle()) and ply:GetVehicle() == self:GetAttachedVehicle()

        if inVehicle or distance < 500 then
            net.Start("hyperdrive_hyperspace_window")
            net.WriteString("enter")
            net.Send(ply)
        end
    end

    -- Use timer for hyperspace travel effect (3 seconds)
    local travelTime = 3

    if GetConVar("developer"):GetInt() > 0 then
        print("[Hyperdrive Master] Starting direct hyperspace travel for " .. travelTime .. " seconds")
        print("  Entities to transport: " .. #entitiesToMove)
    end

    timer.Simple(travelTime, function()
        if IsValid(self) then
            if GetConVar("developer"):GetInt() > 0 then
                print("[Hyperdrive Master] Completing direct hyperspace travel - transporting entities")
            end

            -- Transport all entities after travel time
            for _, ent in ipairs(entitiesToMove) do
                if IsValid(ent) then
                    local offset = ent:GetPos() - self:GetPos()
                    ent:SetPos(destination + offset)

                    if ent:IsPlayer() then
                        ent:SetVelocity(Vector(0, 0, 0))
                    elseif ent:GetPhysicsObject():IsValid() then
                        ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
                    end

                    if GetConVar("developer"):GetInt() > 0 then
                        print("  Transported " .. tostring(ent) .. " to " .. tostring(destination + offset))
                    end
                end
            end

            -- Create arrival effect
            self:CreateMasterJumpEffect(destination, false)

            -- Send hyperspace exit animation to transported players
            for _, ent in ipairs(entitiesToMove) do
                if IsValid(ent) and ent:IsPlayer() then
                    net.Start("hyperdrive_hyperspace_window")
                    net.WriteString("exit")
                    net.Send(ent)
                end
            end

            if GetConVar("developer"):GetInt() > 0 then
                print("[Hyperdrive Master] Direct hyperspace travel completed successfully")
            end
        end
    end)

    -- Set cooldown with efficiency bonus
    local cooldownTime = (HYPERDRIVE.Config and HYPERDRIVE.Config.CooldownTime) or 10
    cooldownTime = cooldownTime / self:GetEfficiencyRating()

    self:SetCooldown(CurTime() + cooldownTime)
    self:SetCharging(false)
    self:SetJumpReady(false)

    -- Enhanced arrival sound
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:EmitSound("ambient/energy/zap9.wav", 85, 140)
        end
    end)
end

function ENT:CreateMasterJumpEffect(pos, isOrigin)
    local effectdata = EffectData()
    effectdata:SetOrigin(pos)
    effectdata:SetMagnitude(isOrigin and 1 or 2)
    effectdata:SetScale(self:GetEfficiencyRating()) -- Scale effect with efficiency
    util.Effect("hyperdrive_master_jump", effectdata)
end

function ENT:OnRemove()
    timer.Remove("hyperdrive_master_" .. self:EntIndex())
    timer.Remove("hyperdrive_master_jump_" .. self:EntIndex())
end

-- Wire input handling for ALL systems
function ENT:TriggerInput(iname, value)
    if not WireLib then return end

    -- Core inputs
    if iname == "Jump" and value > 0 then
        local success, message = self:StartJumpMaster()

    elseif iname == "SetDestination" and isvector(value) then
        self:SetDestinationPos(value)

    elseif iname == "Abort" and value > 0 then
        self:AbortJump("Wire abort signal")

    elseif iname == "SetEnergy" then
        local maxEnergy = (HYPERDRIVE.Config and HYPERDRIVE.Config.MaxEnergy) or 1000
        self:SetEnergy(math.Clamp(value, 0, maxEnergy))

    -- Spacebuild inputs
    elseif iname == "PowerInput" then
        self:SetPowerLevel(math.max(0, value))

    elseif iname == "OxygenInput" then
        self:SetOxygenLevel(math.max(0, value))

    elseif iname == "CoolantInput" then
        self:SetCoolantLevel(math.max(0, value))

    -- Stargate inputs
    elseif iname == "SetGateAddress" and isstring(value) then
        self:SetDestinationByAddress(value)

    elseif iname == "SetTechLevel" and isstring(value) then
        self:SetTechLevel(value)

    elseif iname == "ScanNetwork" and value > 0 then
        self:UpdateStargateSystems()

    -- Master inputs
    elseif iname == "SetMode" then
        self:SetOperationalMode(math.Clamp(math.floor(value), 1, 3))

    elseif iname == "SystemScan" and value > 0 then
        self:UpdateAllSystems()
    end

    self:UpdateAllWireOutputs()
end

function ENT:UpdateAllWireOutputs()
    if not WireLib then return end

    -- Core outputs
    WireLib.TriggerOutput(self, "Energy", self:GetEnergy())
    WireLib.TriggerOutput(self, "EnergyPercent", self:GetEnergyPercent())
    WireLib.TriggerOutput(self, "Charging", self:GetCharging() and 1 or 0)
    WireLib.TriggerOutput(self, "JumpReady", self:CanJump() and 1 or 0)

    -- Spacebuild outputs
    WireLib.TriggerOutput(self, "PowerLevel", self:GetPowerLevel())
    WireLib.TriggerOutput(self, "OxygenLevel", self:GetOxygenLevel())
    WireLib.TriggerOutput(self, "CoolantLevel", self:GetCoolantLevel())
    WireLib.TriggerOutput(self, "Temperature", self:GetTemperature())

    -- Stargate outputs
    WireLib.TriggerOutput(self, "TechLevel", self:GetTechLevel())
    WireLib.TriggerOutput(self, "NaquadahLevel", self:GetNaquadahLevel())
    WireLib.TriggerOutput(self, "ZPMPower", self:GetZPMPower())
    WireLib.TriggerOutput(self, "GateAddress", self:GetGateAddress())

    -- Master outputs
    WireLib.TriggerOutput(self, "SystemIntegration", self:GetSystemIntegration())
    WireLib.TriggerOutput(self, "EfficiencyRating", self:GetEfficiencyRating())
    WireLib.TriggerOutput(self, "OperationalMode", self:GetOperationalMode())

    local integrationCount = 0
    if self.IntegrationData.wiremod.active then integrationCount = integrationCount + 1 end
    if self.IntegrationData.spacebuild.active then integrationCount = integrationCount + 1 end
    if self.IntegrationData.stargate.active then integrationCount = integrationCount + 1 end
    WireLib.TriggerOutput(self, "IntegrationCount", integrationCount)

    -- Status strings
    local canOperate, reason = self:CanOperateMaster()
    WireLib.TriggerOutput(self, "Status", canOperate and "READY" or "NOT_READY")
    WireLib.TriggerOutput(self, "MasterStatus", reason)
end

-- Standard functions with master enhancements
function ENT:SetDestinationPos(pos)
    -- Basic validation
    if not pos or not isvector(pos) then
        return false, "Invalid destination vector"
    end

    -- Validate engine position
    local enginePos = self:GetPos()
    if GetConVar("developer"):GetInt() > 0 then
        print("[Hyperdrive Master] Position validation:")
        print("  Engine position: " .. tostring(enginePos))
        print("  Is vector: " .. tostring(isvector(enginePos)))
        if isvector(enginePos) then
            print("  X: " .. tostring(enginePos.x) .. " (abs: " .. tostring(math.abs(enginePos.x)) .. ")")
            print("  Y: " .. tostring(enginePos.y) .. " (abs: " .. tostring(math.abs(enginePos.y)) .. ")")
            print("  Z: " .. tostring(enginePos.z))
        end
    end

    if not enginePos or not isvector(enginePos) then
        return false, "Invalid origin vector"
    end

    -- Check for crazy positions (outside normal map bounds) - relaxed bounds
    if math.abs(enginePos.x) > 50000 or math.abs(enginePos.y) > 50000 or enginePos.z < -10000 or enginePos.z > 50000 then
        if GetConVar("developer"):GetInt() > 0 then
            print("[Hyperdrive Master] Engine at crazy position: " .. tostring(enginePos))
            print("[Hyperdrive Master] Attempting to fix position...")
        end

        -- Try to fix the position by moving to a safe location
        local safePos = Vector(0, 0, 100) -- Safe position above ground
        self:SetPos(safePos)

        -- Verify the fix worked
        local newPos = self:GetPos()
        if math.abs(newPos.x) > 50000 or math.abs(newPos.y) > 50000 or newPos.z < -20000 or newPos.z > 20000 then
            return false, "Engine position out of bounds (fix failed)"
        end

        enginePos = newPos -- Update enginePos for calculations
        if GetConVar("developer"):GetInt() > 0 then
            print("[Hyperdrive Master] Position fixed to: " .. tostring(enginePos))
        end
    end

    -- Enhanced destination validation with fallback
    local validDest = true
    local validReason = "Valid"

    if HYPERDRIVE.IsValidDestination then
        validDest, validReason = HYPERDRIVE.IsValidDestination(pos)
        if not validDest then
            return false, validReason or "Invalid destination"
        end
    else
        -- Fallback validation
        local distance = enginePos:Distance(pos)
        if distance < 100 then
            return false, "Destination too close"
        elseif distance > 100000 then
            return false, "Destination too far"
        end
    end

    -- Calculate energy cost with fallback (simplified to avoid external function calls)
    local distance = enginePos:Distance(pos)
    local energyCost = math.max(10, distance * 0.1)

    -- Apply Master Engine efficiency bonus
    if self.GetEfficiencyRating and type(self.GetEfficiencyRating) == "function" then
        local success, efficiency = pcall(self.GetEfficiencyRating, self)
        if success and efficiency and efficiency > 0 then
            energyCost = energyCost / efficiency
        else
            energyCost = energyCost / 1.2 -- Default 20% efficiency bonus
        end
    else
        energyCost = energyCost / 1.2 -- Default 20% efficiency bonus
    end

    -- Check energy with current level
    local currentEnergy = self:GetEnergy()
    if currentEnergy < energyCost then
        return false, string.format("Insufficient energy (need %.0f, have %.0f)", energyCost, currentEnergy)
    end

    -- Set destination
    self:SetDestination(pos)
    return true, string.format("Destination set (cost: %.0f EU)", energyCost)
end

function ENT:GetEnergyPercent()
    local maxEnergy = (HYPERDRIVE.Config and HYPERDRIVE.Config.MaxEnergy) or 1000
    return (self:GetEnergy() / maxEnergy) * 100
end

function ENT:CanJump()
    local canOperate, reason = self:CanOperateMaster()
    return not self:GetCharging() and
           not self:IsOnCooldown() and
           canOperate
end

-- Compatibility function for computer interface
function ENT:StartJump()
    return self:StartJumpMaster()
end

function ENT:IsOnCooldown()
    return self:GetCooldown() > CurTime()
end

function ENT:AbortJump(reason)
    self:SetCharging(false)
    self:SetJumpReady(false)
    timer.Remove("hyperdrive_master_jump_" .. self:EntIndex())

    if IsValid(self.Owner) then
        self.Owner:ChatPrint("[Hyperdrive Master] Jump aborted: " .. (reason or "Unknown error"))
    end
end

function ENT:SetDestinationByAddress(address)
    if not StarGate or not address or address == "" then
        return false, "Invalid gate address"
    end

    -- Find gate by address
    for _, ent in ipairs(ents.GetAll()) do
        if IsValid(ent) and string.find(ent:GetClass(), "stargate") then
            if ent.GetAddress and ent:GetAddress() == address then
                local pos = ent:GetPos() + Vector(0, 0, 100) -- Above the gate
                return self:SetDestinationPos(pos)
            end
        end
    end

    return false, "Gate address not found"
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if CurTime() - self.LastUse < 0.5 then return end

    self.LastUse = CurTime()
    self.Owner = activator

    -- Send simple interface for now (can be upgraded later)
    net.Start("hyperdrive_open_interface")
    net.WriteEntity(self)
    net.Send(activator)
end

function ENT:GetCooldownRemaining()
    return math.max(0, self:GetCooldown() - CurTime())
end

-- Network strings
if SERVER then
    util.AddNetworkString("hyperdrive_master_interface")
    util.AddNetworkString("hyperdrive_hyperspace_window")

    -- Simple interface network handlers
    net.Receive("hyperdrive_set_destination", function(len, ply)
        local ent = net.ReadEntity()
        local pos = net.ReadVector()

        if not IsValid(ent) or ent:GetClass() ~= "hyperdrive_master_engine" then return end
        if ent:GetPos():Distance(ply:GetPos()) > 500 then return end

        local success, message = ent:SetDestinationPos(pos)
        ply:ChatPrint("[Hyperdrive Master] " .. message)
    end)

    net.Receive("hyperdrive_start_jump", function(len, ply)
        local ent = net.ReadEntity()

        if not IsValid(ent) or ent:GetClass() ~= "hyperdrive_master_engine" then return end
        if ent:GetPos():Distance(ply:GetPos()) > 500 then return end

        local success, message = ent:StartJumpMaster()
        ply:ChatPrint("[Hyperdrive Master] " .. message)
    end)
end
