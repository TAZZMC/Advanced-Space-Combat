-- Master Hyperdrive Engine v3.0.0 - ULTIMATE COMBINED ENGINE
-- ALL ENGINE TYPES UNIFIED - Standard, Enhanced, Master, and Custom variants
-- Complete integration: CAP, SB3, Wiremod, Ship Core, AI, and all addon systems
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

print("[Hyperdrive Master] ULTIMATE COMBINED ENGINE v3.0.0 - All engine types unified")
print("[Hyperdrive Master] Complete integration: CAP, SB3, Wiremod, Ship Core, AI systems")

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

    -- Engine type and configuration (NEW v3.0.0)
    self:SetEngineType("master") -- master, standard, enhanced, heavy, light, custom
    self:SetEngineClass("hyperdrive") -- hyperdrive, sublight, quantum, dimensional
    self:SetThrustPower(100)
    self:SetMaxThrust(1000)
    self:SetEngineActive(false)

    -- Integration data storage (safe initialization)
    self.IntegrationData = self.IntegrationData or {}
    if not self.IntegrationData.wiremod then
        self.IntegrationData.wiremod = {active = false, inputs = 0, outputs = 0}
    end
    if not self.IntegrationData.spacebuild then
        self.IntegrationData.spacebuild = {active = false, resources = {}, lifesupport = false}
    end
    if not self.IntegrationData.stargate then
        self.IntegrationData.stargate = {active = false, techLevel = "tau_ri", hasGate = false}
    end

    -- Initialize ALL integration systems
    self:InitializeWiremod()
    self:InitializeSpacebuild()
    self:InitializeStargate()

    -- Initialize ship core system
    self:InitializeShipCore()

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

    -- v2.2.0 Initialize new systems
    self:InitializeFleetManagement()
    self:InitializeRealTimeMonitoring()
    self:InitializePerformanceAnalytics()

    -- Configure engine based on type
    self:ConfigureEngineType("master")

    print("[Hyperdrive Master] Ultimate Combined Engine v3.0.0 initialized with ALL features")
end

-- Configure engine based on type (NEW v3.0.0)
function ENT:ConfigureEngineType(engineType)
    engineType = engineType or "master"
    self:SetEngineType(engineType)

    -- Configure properties based on engine type
    if engineType == "master" then
        -- Master engine - all capabilities
        self:SetMaxThrust(1000)
        self:SetThrustPower(200)
        self.MaxEnergy = 2000
        self.ChargeRate = 100
        self.JumpCost = 1000
        self.CooldownTime = 3
        self.JumpRange = 100000
        self:SetEngineClass("hyperdrive")

    elseif engineType == "heavy" then
        -- Heavy engine - high power, slow charge
        self:SetMaxThrust(1500)
        self:SetThrustPower(300)
        self.MaxEnergy = 3000
        self.ChargeRate = 75
        self.JumpCost = 1500
        self.CooldownTime = 8
        self.JumpRange = 150000
        self:SetEngineClass("hyperdrive")

    elseif engineType == "light" then
        -- Light engine - fast charge, lower power
        self:SetMaxThrust(500)
        self:SetThrustPower(100)
        self.MaxEnergy = 1000
        self.ChargeRate = 150
        self.JumpCost = 600
        self.CooldownTime = 2
        self.JumpRange = 75000
        self:SetEngineClass("hyperdrive")

    elseif engineType == "enhanced" then
        -- Enhanced engine - balanced performance
        self:SetMaxThrust(800)
        self:SetThrustPower(150)
        self.MaxEnergy = 1500
        self.ChargeRate = 80
        self.JumpCost = 800
        self.CooldownTime = 4
        self.JumpRange = 80000
        self:SetEngineClass("hyperdrive")

    elseif engineType == "quantum" then
        -- Quantum engine - advanced technology
        self:SetMaxThrust(1200)
        self:SetThrustPower(250)
        self.MaxEnergy = 2500
        self.ChargeRate = 120
        self.JumpCost = 1200
        self.CooldownTime = 2
        self.JumpRange = 200000
        self:SetEngineClass("quantum")

    elseif engineType == "dimensional" then
        -- Dimensional engine - ultimate technology
        self:SetMaxThrust(2000)
        self:SetThrustPower(400)
        self.MaxEnergy = 5000
        self.ChargeRate = 200
        self.JumpCost = 2000
        self.CooldownTime = 1
        self.JumpRange = 500000
        self:SetEngineClass("dimensional")

    else -- standard
        -- Standard engine - basic capabilities
        self:SetMaxThrust(600)
        self:SetThrustPower(100)
        self.MaxEnergy = 1000
        self.ChargeRate = 50
        self.JumpCost = 800
        self.CooldownTime = 5
        self.JumpRange = 50000
        self:SetEngineClass("hyperdrive")
    end

    -- Update efficiency based on engine type
    self:UpdateSystemIntegration()

    print("[Hyperdrive Master] Configured as " .. engineType .. " engine with " .. self:GetEngineClass() .. " class")
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

    -- Engine type properties (NEW v3.0.0)
    self:NetworkVar("String", 2, "EngineType")
    self:NetworkVar("String", 3, "EngineClass")
    self:NetworkVar("Int", 2, "ThrustPower")
    self:NetworkVar("Int", 3, "MaxThrust")
    self:NetworkVar("Bool", 2, "EngineActive")
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
        "FleetCoordinate",

        -- Engine type inputs (NEW v3.0.0)
        "SetEngineType [STRING]",
        "SetEngineClass [STRING]",
        "SetThrustPower",
        "ToggleEngine",
        "ActivateEngine",
        "DeactivateEngine",

        -- Front Indicator inputs
        "ShowFrontIndicator",
        "HideFrontIndicator",
        "SetFrontDirection [VECTOR]",
        "AutoDetectFront",

        -- Shield inputs
        "ActivateShield",
        "DeactivateShield",
        "ToggleShield",
        "SetShieldStrength"
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
        "MasterStatus [STRING]",

        -- Engine type outputs (NEW v3.0.0)
        "EngineType [STRING]",
        "EngineClass [STRING]",
        "ThrustPower",
        "MaxThrust",
        "EngineActive",
        "EngineStatus [STRING]",

        -- Front Indicator outputs
        "FrontIndicatorVisible",
        "ShipFrontDirection [VECTOR]",

        -- Shield outputs
        "ShieldActive",
        "ShieldStrength",
        "ShieldPercent",
        "ShieldRecharging",
        "ShieldOverloaded",
        "CAPIntegrated"
    })

    self.IntegrationData.wiremod.active = true
    self:UpdateSystemIntegration()
end

function ENT:InitializeSpacebuild()
    if not CAF then return end

    -- Setup Spacebuild resource nodes (safe initialization)
    self.SpacebuildNodes = self.SpacebuildNodes or {}
    if not self.SpacebuildNodes.energy then
        self.SpacebuildNodes.energy = {capacity = 2000, amount = 0}
    end
    if not self.SpacebuildNodes.oxygen then
        self.SpacebuildNodes.oxygen = {capacity = 1000, amount = 0}
    end
    if not self.SpacebuildNodes.coolant then
        self.SpacebuildNodes.coolant = {capacity = 400, amount = 0}
    end

    if self.IntegrationData and self.IntegrationData.spacebuild then
        self.IntegrationData.spacebuild.active = true
    end
    self:UpdateSystemIntegration()
end

function ENT:InitializeStargate()
    if not StarGate then return end

    self.IntegrationData.stargate.active = true
    self:UpdateSystemIntegration()
end

function ENT:InitializeShipCore()
    -- Initialize with our new ship core system
    if HYPERDRIVE.ShipCore then
        timer.Simple(0.1, function()
            if IsValid(self) then
                local ship = HYPERDRIVE.ShipCore.DetectShipForEngine(self)
                if ship then
                    print("[Hyperdrive Master] Ship detected: " .. ship:GetShipType() .. " with " .. #ship:GetEntities() .. " entities")

                    -- Store ship reference
                    self.Ship = ship

                    -- Update integration data with ship info
                    local classification = ship:GetClassification()
                    self.IntegrationData.shipcore = {
                        active = true,
                        shipType = ship:GetShipType(),
                        entityCount = classification.entityCount,
                        playerCount = classification.playerCount,
                        mass = classification.mass,
                        volume = classification.volume
                    }
                else
                    print("[Hyperdrive Master] No ship detected")
                end
            end
        end)
    else
        print("[Hyperdrive Master] Ship Core system not available")
    end
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
            -- Calculate tech bonus based on tech level
            local techLevel = self:GetTechLevel() or 0
            local techBonus = 1.0

            -- Use GetTechBonus if available, otherwise calculate manually
            if HYPERDRIVE.Stargate.GetTechBonus and type(HYPERDRIVE.Stargate.GetTechBonus) == "function" then
                local success, result = pcall(HYPERDRIVE.Stargate.GetTechBonus, techLevel)
                if success and result then
                    techBonus = result
                else
                    -- Fallback calculation
                    techBonus = 1.0 + (techLevel * 0.1) -- 10% bonus per tech level
                end
            else
                -- Manual tech bonus calculation
                if techLevel >= 5 then
                    techBonus = 1.5 -- Ancient tech level
                elseif techLevel >= 3 then
                    techBonus = 1.3 -- Advanced tech level
                elseif techLevel >= 1 then
                    techBonus = 1.1 -- Basic tech level
                else
                    techBonus = 1.0 -- No tech bonus
                end
            end

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

    -- Safely get Stargate tech data
    local sgData = {}
    if HYPERDRIVE.Stargate.HasStargateTech and type(HYPERDRIVE.Stargate.HasStargateTech) == "function" then
        local success, result = pcall(HYPERDRIVE.Stargate.HasStargateTech, self)
        if success and result then
            sgData = result
        else
            -- Fallback data structure
            sgData = {
                active = false,
                techLevel = 0,
                hasNaquadah = false,
                powerLevel = 0,
                hasGate = false
            }
        end
    else
        -- Manual detection fallback
        sgData = {
            active = StarGate ~= nil,
            techLevel = 0,
            hasNaquadah = false,
            powerLevel = 0,
            hasGate = false
        }
    end

    self.IntegrationData.stargate = sgData

    self:SetTechLevel(sgData.techLevel or 0)
    self:SetNaquadahLevel(sgData.hasNaquadah and 100 or 0)
    self:SetZPMPower(sgData.powerLevel or 0)

    -- Find gate address
    if sgData.hasGate then
        local nearbyGates = ents.FindInSphere(self:GetPos(), 1000)
        for _, ent in ipairs(nearbyGates) do
            if IsValid(ent) and string.find(ent:GetClass(), "stargate") then
                if ent.GetAddress and type(ent.GetAddress) == "function" then
                    local success, address = pcall(ent.GetAddress, ent)
                    if success and address then
                        self:SetGateAddress(address)
                        break
                    end
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

    -- MANDATORY: Ship core validation (REQUIRED for all hyperdrive operations)
    if HYPERDRIVE.Core and HYPERDRIVE.Core.ValidateShipForJump then
        local valid, message = HYPERDRIVE.Core.ValidateShipForJump(self)
        if not valid then
            table.insert(issues, "SHIP CORE: " .. message)
        end
    else
        -- Fallback validation if core system not available
        if not HYPERDRIVE.ShipCore then
            table.insert(issues, "SHIP CORE: System not loaded")
        else
            local ship = HYPERDRIVE.ShipCore.GetShipByEntity(self)
            if not ship then
                table.insert(issues, "SHIP CORE: No ship detected")
            elseif not ship.core or not IsValid(ship.core) then
                table.insert(issues, "SHIP CORE: Core missing or invalid")
            end
        end
    end

    -- Hull integrity validation
    if HYPERDRIVE.Core and HYPERDRIVE.Core.Config.EnableHullDamage and HYPERDRIVE.Core.CheckHullIntegrityForJump then
        local hullValid, hullMessage = HYPERDRIVE.Core.CheckHullIntegrityForJump(self)
        if not hullValid then
            table.insert(issues, "HULL: " .. hullMessage)
        end
    end

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
        -- Safely check Stargate configuration
        local requireNaquadah = false
        if HYPERDRIVE.Stargate.Config and HYPERDRIVE.Stargate.Config.RequireNaquadah then
            requireNaquadah = HYPERDRIVE.Stargate.Config.RequireNaquadah
        end

        if requireNaquadah and self:GetNaquadahLevel() <= 0 then
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

    -- Enhanced validation using core system
    local destination = self:GetDestination()
    if HYPERDRIVE.Core and HYPERDRIVE.Core.PrepareForJump then
        local issues, warnings = HYPERDRIVE.Core.PrepareForJump(self, destination)

        if #issues > 0 then
            return false, "Jump preparation failed: " .. table.concat(issues, ", ")
        end

        if #warnings > 0 then
            print("[Hyperdrive Master] Warnings: " .. table.concat(warnings, ", "))
        end
    end

    -- Calculate distance and energy cost with enhanced core
    local distance = self:GetPos():Distance(destination)
    local energyCost

    if HYPERDRIVE.Core and HYPERDRIVE.Core.CalculateEnergyCost then
        local ship = HYPERDRIVE.Core.GetShipFromEngine(self)
        local mass = ship and ship:GetMass() or 1000
        energyCost = HYPERDRIVE.Core.CalculateEnergyCost(distance, mass, self:GetEfficiencyRating(), 1.0)
    else
        energyCost = math.max(10, distance * 0.1)
    end

    -- Use ship detection for optimized energy calculation if available
    if HYPERDRIVE.ShipDetection and HYPERDRIVE.ShipDetection.CalculateOptimizedEnergyCost then
        local entities = entitiesToMove or {}
        energyCost = HYPERDRIVE.ShipDetection.CalculateOptimizedEnergyCost(self, destination, entities)
        if GetConVar("developer"):GetInt() > 0 then
            print("[Hyperdrive Master] Using ship-optimized energy calculation")
        end
    else
        -- Apply Master Engine efficiency bonus (fallback)
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
    end

    if self:GetEnergy() < energyCost then
        return false, string.format("Insufficient energy (need %.0f, have %.0f)", energyCost, self:GetEnergy())
    end

    -- Start charging with efficiency bonus
    self:SetCharging(true)
    self:SetJumpReady(false)

    -- Play charging start sound
    if HYPERDRIVE.Sounds then
        HYPERDRIVE.Sounds.PlayHyperdrive("charge_start", self, {
            volume = 0.8,
            pitch = 100,
            soundLevel = 80
        })

        -- Start charge loop sound after a brief delay
        timer.Simple(1, function()
            if IsValid(self) and self:GetCharging() then
                self.chargeLoopSoundId = HYPERDRIVE.Sounds.PlayHyperdrive("charge_loop", self, {
                    volume = 0.6,
                    pitch = 100,
                    loop = true,
                    soundLevel = 75,
                    category = "hyperdrive"
                })
            end
        end)
    end

    -- Auto-activate shields if available
    if HYPERDRIVE.Core and HYPERDRIVE.Core.ActivateShieldsForJump then
        HYPERDRIVE.Core.ActivateShieldsForJump(self)
    end

    -- Get ship for effects
    local ship = HYPERDRIVE.Core and HYPERDRIVE.Core.GetShipFromEngine(self) or self.Ship

    -- Create world effects around ship
    if HYPERDRIVE.WorldEffects and ship then
        HYPERDRIVE.WorldEffects.CreateChargingEffects(self, ship)
    else
        -- Fallback sound effect (only if sound system not available)
        if not HYPERDRIVE.Sounds then
            self:EmitSound("ambient/energy/whiteflash.wav", 75, 100)
        end
    end

    -- Call hook for other systems
    hook.Call("HyperdriveChargingStart", nil, self, ship)

    -- Calculate charge time with all bonuses
    local chargeTime = (HYPERDRIVE.Config and HYPERDRIVE.Config.JumpChargeTime) or 3
    chargeTime = chargeTime / self:GetEfficiencyRating()

    timer.Create("hyperdrive_master_jump_" .. self:EntIndex(), chargeTime, 1, function()
        if IsValid(self) then
            -- Stop charge loop sound and play charge complete
            if HYPERDRIVE.Sounds then
                if self.chargeLoopSoundId then
                    HYPERDRIVE.Sounds.StopSound(self.chargeLoopSoundId)
                    self.chargeLoopSoundId = nil
                end

                HYPERDRIVE.Sounds.PlayHyperdrive("charge_complete", self, {
                    volume = 0.9,
                    pitch = 100,
                    soundLevel = 85
                })
            end

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

    -- Apply Stargate energy cost calculation if available
    if self.IntegrationData.stargate.active and HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.CalculateEnergyCost then
        energyCost = HYPERDRIVE.Stargate.CalculateEnergyCost(self, self:GetPos(), destination, distance)
    end

    -- Consume energy
    self:SetEnergy(self:GetEnergy() - energyCost)

    if GetConVar("developer"):GetInt() > 0 then
        print("[Hyperdrive Master] Executing jump:")
        print("  From: " .. tostring(self:GetPos()))
        print("  To: " .. tostring(destination))
        print("  Distance: " .. tostring(distance))
        print("  Energy consumed: " .. tostring(energyCost))
        print("  Stargate integration: " .. tostring(self.IntegrationData.stargate.active))
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

    -- Check for Enhanced Hyperspace System v3.0 (priority over legacy systems)
    if ASC and ASC.EnhancedHyperspace and ASC.EnhancedHyperspace.StartAdvanced4StageTravel then
        -- Get entities to transport
        local entitiesToMove = self:GetEntitiesToTransport()

        -- Register engine for coordination if not already registered
        if ASC.MasterEngineCoord and ASC.MasterEngineCoord.RegisterEngine then
            ASC.MasterEngineCoord.RegisterEngine(self)
        end

        -- Find and coordinate with nearby engines
        local coordinatedEngines = {self}
        if ASC.MasterEngineCoord and ASC.MasterEngineCoord.CoordinateMasterEngines then
            coordinatedEngines = ASC.MasterEngineCoord.CoordinateMasterEngines(self, destination)
        end

        -- Calculate efficiency bonus from coordination
        local efficiencyBonus = 1.0
        if ASC.MasterEngineCoord and ASC.MasterEngineCoord.CalculateEfficiencyBonus then
            efficiencyBonus = ASC.MasterEngineCoord.CalculateEfficiencyBonus(coordinatedEngines)
        end

        -- Try enhanced 4-stage Stargate travel
        local success, message = ASC.EnhancedHyperspace.StartAdvanced4StageTravel(self, destination, entitiesToMove)
        if success then
            if GetConVar("developer"):GetInt() > 0 then
                print("[Hyperdrive Master] Using Enhanced Hyperspace System v3.0")
                print("[Hyperdrive Master] Coordinated engines: " .. #coordinatedEngines)
                print("[Hyperdrive Master] Efficiency bonus: " .. math.floor(efficiencyBonus * 100) .. "%")
                if self.IntegrationData.stargate.active then
                    print("[Hyperdrive Master] Enhanced with Stargate technology bonuses")
                else
                    print("[Hyperdrive Master] Using enhanced 4-stage travel system")
                end
            end

            -- Apply efficiency bonus to cooldown
            local cooldownTime = (HYPERDRIVE.Config and HYPERDRIVE.Config.CooldownTime) or 10
            cooldownTime = cooldownTime / (self:GetEfficiencyRating() * efficiencyBonus)
            self:SetCooldown(CurTime() + cooldownTime)
            self:SetCharging(false)
            self:SetJumpReady(false)
            return
        else
            if GetConVar("developer"):GetInt() > 0 then
                print("[Hyperdrive Master] Enhanced hyperspace travel failed: " .. (message or "Unknown error"))
                print("[Hyperdrive Master] Falling back to legacy systems")
            end
        end
    end

    -- Fallback: Check for legacy Stargate 4-stage travel system
    if HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.StartFourStageTravel then
        -- Get entities to transport
        local entitiesToMove = self:GetEntitiesToTransport()

        -- Try legacy 4-stage Stargate travel
        local success, message = HYPERDRIVE.Stargate.StartFourStageTravel(self, destination, entitiesToMove)
        if success then
            if GetConVar("developer"):GetInt() > 0 then
                print("[Hyperdrive Master] Using legacy 4-stage Stargate travel system")
                if self.IntegrationData.stargate.active then
                    print("[Hyperdrive Master] Enhanced with Stargate technology bonuses")
                else
                    print("[Hyperdrive Master] Using standard 4-stage travel")
                end
            end

            -- Set cooldown with efficiency bonus
            local cooldownTime = (HYPERDRIVE.Config and HYPERDRIVE.Config.CooldownTime) or 10
            cooldownTime = cooldownTime / self:GetEfficiencyRating()
            self:SetCooldown(CurTime() + cooldownTime)
            self:SetCharging(false)
            self:SetJumpReady(false)
            return
        else
            if GetConVar("developer"):GetInt() > 0 then
                print("[Hyperdrive Master] Legacy 4-stage travel failed: " .. (message or "Unknown error"))
                print("[Hyperdrive Master] Falling back to direct travel")
            end
        end
    end

    -- Get entities to transport using the new function
    local entitiesToMove = self:GetEntitiesToTransport()

    -- Create world effects around ship instead of HUD effects
    if HYPERDRIVE.WorldEffects and self.Ship then
        -- Entry window effect
        HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(self, self.Ship, "enter")

        -- Starlines during travel
        timer.Simple(0.5, function()
            if IsValid(self) and self.Ship then
                HYPERDRIVE.WorldEffects.CreateStarlinesEffect(self, self.Ship)
            end
        end)

        -- Exit window at destination
        timer.Simple(2.5, function()
            if IsValid(self) and self.Ship then
                -- Update ship position for exit effect
                self.Ship.center = destination
                HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(self, self.Ship, "exit")
            end
        end)
    else
        -- Fallback to old effect system
        self:CreateMasterJumpEffect(self:GetPos(), true)
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

            -- Create backup before movement
            local backupId = nil
            if HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.CreateBackup then
                backupId = HYPERDRIVE.ErrorRecovery.CreateBackup(self, entitiesToMove)
            end

            -- Use network-optimized batch movement if available and appropriate
            if self.UseBatchMovement and HYPERDRIVE.Network and HYPERDRIVE.Network.BatchMoveEntities then
                local players = player.GetAll()
                local success, result = HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.SafeExecute(
                    function(context)
                        return HYPERDRIVE.Network.BatchMoveEntities(context.entities, context.destination, context.enginePos, context.players)
                    end,
                    {entities = entitiesToMove, destination = destination, enginePos = self:GetPos(), players = players, engineId = self:EntIndex()},
                    "NetworkBatchMovement"
                ) or HYPERDRIVE.Network.BatchMoveEntities(entitiesToMove, destination, self:GetPos(), players)

                if success then
                    if GetConVar("developer"):GetInt() > 0 then
                        print("[Hyperdrive Master] Used network-optimized batch movement")
                    end
                    -- Apply gravity overrides for players
                    for _, ent in ipairs(entitiesToMove) do
                        if IsValid(ent) and ent:IsPlayer() then
                            if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.OverrideGravity then
                                HYPERDRIVE.SpaceCombat2.OverrideGravity(ent, true)
                                timer.Simple(3, function()
                                    if IsValid(ent) then
                                        HYPERDRIVE.SpaceCombat2.OverrideGravity(ent, false)
                                    end
                                end)
                            elseif HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity then
                                HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity(ent, true)
                                timer.Simple(3, function()
                                    if IsValid(ent) then
                                        HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity(ent, false)
                                    end
                                end)
                            end
                        end
                    end
                    return -- Skip individual entity movement
                else
                    -- Log network movement failure and try fallback
                    if HYPERDRIVE.ErrorRecovery then
                        HYPERDRIVE.ErrorRecovery.LogError("Network batch movement failed: " .. tostring(result),
                            HYPERDRIVE.ErrorRecovery.Severity.MEDIUM, {engineId = self:EntIndex(), entityCount = #entitiesToMove})
                    end
                end
            end

            -- Fallback to performance-optimized batch movement
            if self.UseBatchMovement and HYPERDRIVE.Performance and HYPERDRIVE.Performance.BatchMoveEntities then
                local success, result = HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.SafeExecute(
                    function(context)
                        return HYPERDRIVE.Performance.BatchMoveEntities(context.entities, context.destination, context.enginePos)
                    end,
                    {entities = entitiesToMove, destination = destination, enginePos = self:GetPos(), engineId = self:EntIndex()},
                    "PerformanceBatchMovement"
                ) or HYPERDRIVE.Performance.BatchMoveEntities(entitiesToMove, destination, self:GetPos())

                if success then
                    if GetConVar("developer"):GetInt() > 0 then
                        print("[Hyperdrive Master] Used performance-optimized batch movement")
                    end
                    -- Apply gravity overrides for players
                    for _, ent in ipairs(entitiesToMove) do
                        if IsValid(ent) and ent:IsPlayer() then
                            if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.OverrideGravity then
                                HYPERDRIVE.SpaceCombat2.OverrideGravity(ent, true)
                                timer.Simple(3, function()
                                    if IsValid(ent) then
                                        HYPERDRIVE.SpaceCombat2.OverrideGravity(ent, false)
                                    end
                                end)
                            elseif HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity then
                                HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity(ent, true)
                                timer.Simple(3, function()
                                    if IsValid(ent) then
                                        HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity(ent, false)
                                    end
                                end)
                            end
                        end
                    end
                    return -- Skip individual entity movement
                else
                    -- Log performance movement failure
                    if HYPERDRIVE.ErrorRecovery then
                        HYPERDRIVE.ErrorRecovery.LogError("Performance batch movement failed: " .. tostring(result),
                            HYPERDRIVE.ErrorRecovery.Severity.MEDIUM, {engineId = self:EntIndex(), entityCount = #entitiesToMove})
                    end
                end
            end

            -- Use optimized movement if Space Combat 2 integration is available
            if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.MoveShip then
                local success, result = HYPERDRIVE.ErrorRecovery and HYPERDRIVE.ErrorRecovery.SafeExecute(
                    function(context)
                        return HYPERDRIVE.SpaceCombat2.MoveShip(context.engine, context.destination)
                    end,
                    {engine = self, destination = destination, engineId = self:EntIndex()},
                    "SC2Movement"
                ) or HYPERDRIVE.SpaceCombat2.MoveShip(self, destination)

                if success then
                    if GetConVar("developer"):GetInt() > 0 then
                        print("[Hyperdrive Master] Used SC2 optimized movement")
                    end
                    return -- Skip fallback movement
                else
                    if GetConVar("developer"):GetInt() > 0 then
                        print("[Hyperdrive Master] SC2 movement failed: " .. tostring(result))
                    end
                    -- Log SC2 movement failure
                    if HYPERDRIVE.ErrorRecovery then
                        HYPERDRIVE.ErrorRecovery.LogError("SC2 movement failed: " .. tostring(result),
                            HYPERDRIVE.ErrorRecovery.Severity.MEDIUM, {engineId = self:EntIndex()})
                    end
                end
            end

            -- Transport all entities after travel time (fallback or additional entities)
            for _, ent in ipairs(entitiesToMove) do
                if IsValid(ent) then
                    local offset = ent:GetPos() - self:GetPos()
                    local newPos = destination + offset

                    -- Use optimized movement if available
                    if self.UseOptimizedMovement and ent.SetPosOptimized then
                        ent:SetPosOptimized(newPos)
                    elseif HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.Config and HYPERDRIVE.SpaceCombat2.Config.OptimizedMovement and ent.SetPosOptimized then
                        ent:SetPosOptimized(newPos)
                    else
                        ent:SetPos(newPos)
                    end

                    if ent:IsPlayer() then
                        ent:SetVelocity(Vector(0, 0, 0))
                        -- Apply SC2 gravity override if available
                        if HYPERDRIVE.SpaceCombat2 and HYPERDRIVE.SpaceCombat2.OverrideGravity then
                            HYPERDRIVE.SpaceCombat2.OverrideGravity(ent, true)
                            timer.Simple(3, function()
                                if IsValid(ent) then
                                    HYPERDRIVE.SpaceCombat2.OverrideGravity(ent, false)
                                end
                            end)
                        elseif HYPERDRIVE.Spacebuild and HYPERDRIVE.Spacebuild.Enhanced and HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity then
                            HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity(ent, true)
                            timer.Simple(3, function()
                                if IsValid(ent) then
                                    HYPERDRIVE.Spacebuild.Enhanced.OverrideGravity(ent, false)
                                end
                            end)
                        end
                    elseif ent:GetPhysicsObject():IsValid() then
                        ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
                        ent:GetPhysicsObject():SetAngularVelocity(Vector(0, 0, 0))
                    end

                    if GetConVar("developer"):GetInt() > 0 then
                        print("  Transported " .. tostring(ent) .. " to " .. tostring(newPos))
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

    -- Auto-deactivate shields if configured
    if HYPERDRIVE.Core and HYPERDRIVE.Core.DeactivateShieldsAfterJump then
        timer.Simple(2, function()
            if IsValid(self) then
                HYPERDRIVE.Core.DeactivateShieldsAfterJump(self)
            end
        end)
    end

    -- Call hook for other systems
    local ship = HYPERDRIVE.Core and HYPERDRIVE.Core.GetShipFromEngine(self)
    hook.Call("HyperdriveJumpComplete", nil, self, ship)

    -- Enhanced arrival sound and effects
    timer.Simple(0.1, function()
        if IsValid(self) then
            if HYPERDRIVE.Sounds then
                HYPERDRIVE.Sounds.PlayHyperdrive("jump_exit", self, {
                    volume = 1.0,
                    pitch = 100,
                    soundLevel = 90
                })
            else
                -- Fallback sound
                self:EmitSound("ambient/energy/zap9.wav", 85, 140)
            end

            -- Create arrival visual effect
            if HYPERDRIVE.WorldEffects and HYPERDRIVE.WorldEffects.CreateArrivalEffects then
                local ship = HYPERDRIVE.Core and HYPERDRIVE.Core.GetShipFromEngine(self) or self.Ship
                if ship then
                    HYPERDRIVE.WorldEffects.CreateArrivalEffects(self, ship)
                end
            end
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

    -- Engine type inputs (NEW v3.0.0)
    elseif iname == "SetEngineType" and isstring(value) then
        self:ConfigureEngineType(value)

    elseif iname == "SetEngineClass" and isstring(value) then
        self:SetEngineClass(value)

    elseif iname == "SetThrustPower" then
        self:SetThrustPower(math.Clamp(math.floor(value), 10, 1000))

    elseif iname == "ToggleEngine" and value > 0 then
        self:SetEngineActive(not self:GetEngineActive())

    elseif iname == "ActivateEngine" and value > 0 then
        self:SetEngineActive(true)

    elseif iname == "DeactivateEngine" and value > 0 then
        self:SetEngineActive(false)

    -- Front Indicator inputs
    elseif iname == "ShowFrontIndicator" and value > 0 then
        if HYPERDRIVE.ShipCore then
            HYPERDRIVE.ShipCore.ShowFrontIndicator(self)
        end
    elseif iname == "HideFrontIndicator" and value > 0 then
        if HYPERDRIVE.ShipCore then
            HYPERDRIVE.ShipCore.HideFrontIndicator(self)
        end
    elseif iname == "SetFrontDirection" and isvector(value) then
        if HYPERDRIVE.ShipCore then
            HYPERDRIVE.ShipCore.SetFrontDirection(self, value)
        end
    elseif iname == "AutoDetectFront" and value > 0 then
        if HYPERDRIVE.ShipCore then
            HYPERDRIVE.ShipCore.AutoDetectFrontDirection(self)
            -- Show indicator temporarily
            HYPERDRIVE.ShipCore.ShowFrontIndicator(self)
            timer.Simple(5, function()
                if IsValid(self) then
                    HYPERDRIVE.ShipCore.HideFrontIndicator(self)
                end
            end)
        end
    elseif iname == "ActivateShield" and value > 0 then
        if HYPERDRIVE.Shields and HYPERDRIVE.ShipCore then
            local ship = HYPERDRIVE.ShipCore.GetShipByEntity(self)
            if ship then
                HYPERDRIVE.Shields.ActivateShield(self, ship)
            end
        end
    elseif iname == "DeactivateShield" and value > 0 then
        if HYPERDRIVE.Shields then
            HYPERDRIVE.Shields.DeactivateShield(self)
        end
    elseif iname == "ToggleShield" and value > 0 then
        if HYPERDRIVE.Shields and HYPERDRIVE.ShipCore then
            local ship = HYPERDRIVE.ShipCore.GetShipByEntity(self)
            if ship then
                if HYPERDRIVE.Shields.IsShieldActive(self) then
                    HYPERDRIVE.Shields.DeactivateShield(self)
                else
                    HYPERDRIVE.Shields.ActivateShield(self, ship)
                end
            end
        end
    elseif iname == "SetShieldStrength" and value > 0 then
        if HYPERDRIVE.Shields then
            local shield = HYPERDRIVE.Shields.GetShield(self)
            if shield then
                shield.maxStrength = math.max(1000, value)
                if shield.strength > shield.maxStrength then
                    shield.strength = shield.maxStrength
                end
            end
        end
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

    -- Engine type outputs (NEW v3.0.0)
    WireLib.TriggerOutput(self, "EngineType", self:GetEngineType())
    WireLib.TriggerOutput(self, "EngineClass", self:GetEngineClass())
    WireLib.TriggerOutput(self, "ThrustPower", self:GetThrustPower())
    WireLib.TriggerOutput(self, "MaxThrust", self:GetMaxThrust())
    WireLib.TriggerOutput(self, "EngineActive", self:GetEngineActive() and 1 or 0)

    local engineStatus = self:GetEngineActive() and "ACTIVE" or "INACTIVE"
    if self:GetCharging() then
        engineStatus = "CHARGING"
    elseif self:IsOnCooldown() then
        engineStatus = "COOLDOWN"
    end
    WireLib.TriggerOutput(self, "EngineStatus", engineStatus)

    -- Status strings
    local canOperate, reason = self:CanOperateMaster()
    WireLib.TriggerOutput(self, "Status", canOperate and "READY" or "NOT_READY")
    WireLib.TriggerOutput(self, "MasterStatus", reason)

    -- Front indicator outputs
    if HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(self)
        if ship then
            WireLib.TriggerOutput(self, "FrontIndicatorVisible", ship.showFrontIndicator and 1 or 0)
            WireLib.TriggerOutput(self, "ShipFrontDirection", ship:GetFrontDirection())
        else
            WireLib.TriggerOutput(self, "FrontIndicatorVisible", 0)
            WireLib.TriggerOutput(self, "ShipFrontDirection", Vector(1, 0, 0))
        end
    else
        WireLib.TriggerOutput(self, "FrontIndicatorVisible", 0)
        WireLib.TriggerOutput(self, "ShipFrontDirection", Vector(1, 0, 0))
    end

    -- Shield outputs
    if HYPERDRIVE.Shields then
        local shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(self)
        WireLib.TriggerOutput(self, "ShieldActive", shieldStatus.active and 1 or 0)
        WireLib.TriggerOutput(self, "ShieldStrength", shieldStatus.strength or 0)
        WireLib.TriggerOutput(self, "ShieldPercent", shieldStatus.strengthPercent or 0)
        WireLib.TriggerOutput(self, "ShieldRecharging", shieldStatus.recharging and 1 or 0)
        WireLib.TriggerOutput(self, "ShieldOverloaded", shieldStatus.overloaded and 1 or 0)
        WireLib.TriggerOutput(self, "CAPIntegrated", shieldStatus.capIntegrated and 1 or 0)
    else
        WireLib.TriggerOutput(self, "ShieldActive", 0)
        WireLib.TriggerOutput(self, "ShieldStrength", 0)
        WireLib.TriggerOutput(self, "ShieldPercent", 0)
        WireLib.TriggerOutput(self, "ShieldRecharging", 0)
        WireLib.TriggerOutput(self, "ShieldOverloaded", 0)
        WireLib.TriggerOutput(self, "CAPIntegrated", 0)
    end
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

-- Get entities to transport for master engine
function ENT:GetEntitiesToTransport()
    local entitiesToMove = {}

    -- Use our new ship core system first
    if HYPERDRIVE.ShipCore and self.Ship then
        -- Get all entities from ship
        entitiesToMove = self.Ship:GetEntities()

        -- Add players in ship
        local players = self.Ship:GetPlayers()
        for _, ply in ipairs(players) do
            if IsValid(ply) then
                table.insert(entitiesToMove, ply)
            end
        end

        local shipInfo = self.Ship:GetClassification()
        print("[Hyperdrive Master] Using Ship Core system - found " .. #entitiesToMove .. " entities")
        print("[Hyperdrive Master] Ship type: " .. self.Ship:GetShipType() .. " (" .. shipInfo.entityCount .. " entities, " .. shipInfo.playerCount .. " players)")

        -- Set movement strategy based on ship size
        if shipInfo.entityCount > 100 then
            self.UseBatchMovement = true
        elseif shipInfo.entityCount > 50 then
            self.UseOptimizedMovement = true
        end

        return entitiesToMove
    end

    -- Fallback: Use ship core detection without stored ship
    if HYPERDRIVE.ShipCore then
        local entities = HYPERDRIVE.ShipCore.GetAttachedEntities(self)
        local players = HYPERDRIVE.ShipCore.GetPlayersInShip(self)

        for _, ent in ipairs(entities) do
            if IsValid(ent) then
                table.insert(entitiesToMove, ent)
            end
        end

        for _, ply in ipairs(players) do
            if IsValid(ply) then
                table.insert(entitiesToMove, ply)
            end
        end

        if #entitiesToMove > 0 then
            print("[Hyperdrive Master] Using Ship Core fallback detection - found " .. #entitiesToMove .. " entities")
            return entitiesToMove
        end
    end

    -- Enhanced transport range based on integrations
    local transportRange = 200
    if self.IntegrationData.stargate.active and self:GetTechLevel() == "ancient" then
        transportRange = 400
    elseif self.IntegrationData.spacebuild.active then
        transportRange = 300
    end

    -- Final fallback to sphere detection
    table.insert(entitiesToMove, self)

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

    print("[Hyperdrive Master] Using fallback sphere detection - found " .. #entitiesToMove .. " entities")
    return entitiesToMove
end

-- Console command for testing 4-stage Stargate travel with master engine
concommand.Add("hyperdrive_master_sg_test", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive Master] Admin access required!")
        end
        return
    end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "hyperdrive_master_engine" then
        ply:ChatPrint("[Hyperdrive Master] Look at a master hyperdrive engine")
        return
    end

    local engine = trace.Entity
    local destination = ply:GetPos() + ply:GetForward() * 1000

    ply:ChatPrint("[Hyperdrive Master] Testing 4-stage Stargate travel with master engine...")

    -- Check if 4-stage system is available
    if not HYPERDRIVE.Stargate or not HYPERDRIVE.Stargate.StartFourStageTravel then
        ply:ChatPrint("[Hyperdrive Master] Stargate 4-stage system not available")
        return
    end

    -- Get entities to transport
    local entitiesToMove = engine:GetEntitiesToTransport()

    -- Try 4-stage Stargate travel (works with or without Stargate technology)
    local success, message = HYPERDRIVE.Stargate.StartFourStageTravel(engine, destination, entitiesToMove)

    if success then
        ply:ChatPrint("[Hyperdrive Master] 4-stage Stargate travel initiated successfully!")
        ply:ChatPrint("[Hyperdrive Master] Watch the HUD for stage progress indicators!")

        if engine.IntegrationData.stargate.active then
            ply:ChatPrint("[Hyperdrive Master] Enhanced with Stargate technology bonuses!")
        else
            ply:ChatPrint("[Hyperdrive Master] Using standard 4-stage travel system")
        end
    else
        ply:ChatPrint("[Hyperdrive Master] 4-stage travel failed: " .. (message or "Unknown error"))
    end
end)

-- Enhanced status command showing all integration features
concommand.Add("hyperdrive_master_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "hyperdrive_master_engine" then
        ply:ChatPrint("[Hyperdrive Master] Look at a master hyperdrive engine")
        return
    end

    local engine = trace.Entity

    ply:ChatPrint("[Hyperdrive Master] Enhanced Status Report:")
    ply:ChatPrint("  • Engine Class: " .. engine:GetClass())
    ply:ChatPrint("  • Energy: " .. math.floor(engine:GetEnergy()) .. "/" .. (HYPERDRIVE.Config and HYPERDRIVE.Config.MaxEnergy or 1000))
    ply:ChatPrint("  • Efficiency Rating: " .. string.format("%.1fx", engine:GetEfficiencyRating()))
    ply:ChatPrint("  • Operational Mode: " .. engine:GetOperationalMode())

    -- Integration status
    ply:ChatPrint("  • Integrations Active:")
    if engine.IntegrationData.wiremod.active then
        ply:ChatPrint("    - Wiremod: ✓ (" .. engine.IntegrationData.wiremod.inputs .. " inputs, " .. engine.IntegrationData.wiremod.outputs .. " outputs)")
    end
    if engine.IntegrationData.spacebuild.active then
        ply:ChatPrint("    - Spacebuild: ✓ (Power: " .. math.floor(engine:GetPowerLevel()) .. ", O2: " .. math.floor(engine:GetOxygenLevel()) .. ")")
    end
    if engine.IntegrationData.stargate.active then
        ply:ChatPrint("    - Stargate: ✓ (Tech: " .. string.upper(engine:GetTechLevel()) .. ", ZPM: " .. math.floor(engine:GetZPMPower()) .. "%)")
    end

    -- 4-Stage Travel System (works with or without Stargate technology)
    local fourStageStatus = "DISABLED"
    if HYPERDRIVE.Stargate and HYPERDRIVE.Stargate.Config.StageSystem.EnableFourStageTravel then
        if engine.IntegrationData.stargate.active then
            fourStageStatus = "ENABLED (Enhanced)"
        else
            fourStageStatus = "ENABLED (Standard)"
        end
    end
    ply:ChatPrint("    - 4-Stage Travel: " .. fourStageStatus)

    -- Current status
    local canOperate, reason = engine:CanOperateMaster()
    ply:ChatPrint("  • Status: " .. (canOperate and "READY" or "NOT READY"))
    if not canOperate then
        ply:ChatPrint("  • Issue: " .. reason)
    end

    -- Destination info
    local dest = engine:GetDestination()
    if dest ~= Vector(0, 0, 0) then
        local distance = engine:GetPos():Distance(dest)
        ply:ChatPrint("  • Destination: " .. tostring(dest) .. " (" .. math.floor(distance) .. " units)")
    else
        ply:ChatPrint("  • Destination: Not set")
    end
end)

-- Use function for master engine interface
function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Hyperdrive Master] Too far away to access interface")
        return
    end

    -- Check if player is holding shift for ship core UI
    if activator:KeyDown(IN_WALK) then
        -- Try to open ship core UI if available
        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(self)
        if ship and ship.core and IsValid(ship.core) then
            ship.core:OpenUI(activator)
            activator:ChatPrint("[Hyperdrive Master] Opening ship core management interface...")
            return
        else
            activator:ChatPrint("[Hyperdrive Master] No ship core detected. Ship core required for management interface.")
            return
        end
    end

    -- Default USE action - open master engine interface
    self:OpenMasterEngineInterface(activator)
end

-- Open master engine interface
function ENT:OpenMasterEngineInterface(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Show comprehensive engine info
    activator:ChatPrint("[Hyperdrive Master Engine] Advanced Status Report:")
    activator:ChatPrint("Energy: " .. math.floor(self:GetEnergy()) .. "/" .. self.MaxEnergy)
    activator:ChatPrint("Status: " .. (self:GetCharging() and "Charging" or "Ready"))
    activator:ChatPrint("Integration Level: " .. self:GetSystemIntegration())
    activator:ChatPrint("Hold SHIFT + USE for ship core management interface")

    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(self)
    if ship then
        activator:ChatPrint("Ship: " .. ship:GetShipType() .. " (" .. #ship:GetEntities() .. " entities)")
        if ship.core and IsValid(ship.core) then
            local hullStatus = HYPERDRIVE.HullDamage and HYPERDRIVE.HullDamage.GetHullStatus(ship.core)
            if hullStatus then
                local hullColor = hullStatus.integrityPercent >= 75 and "Good" or
                                 hullStatus.integrityPercent >= 50 and "Damaged" or
                                 hullStatus.integrityPercent >= 25 and "Critical" or "Emergency"
                activator:ChatPrint("Hull: " .. string.format("%.1f", hullStatus.integrityPercent) .. "% (" .. hullColor .. ")")
            end

            local shieldStatus = HYPERDRIVE.Shields and HYPERDRIVE.Shields.GetShieldStatus(self)
            if shieldStatus and shieldStatus.available then
                activator:ChatPrint("Shields: " .. (shieldStatus.active and "Active" or "Inactive") ..
                                  " (" .. string.format("%.1f", shieldStatus.strengthPercent or 0) .. "%)")
            end
        end
    else
        activator:ChatPrint("No ship detected - ship core required for operation")
    end

    -- Show integration status
    if self.IntegrationData then
        local integrations = {}
        if self.IntegrationData.wiremod.active then table.insert(integrations, "Wiremod") end
        if self.IntegrationData.spacebuild.active then table.insert(integrations, "Spacebuild") end
        if self.IntegrationData.stargate.active then table.insert(integrations, "Stargate") end
        if self.IntegrationData.shipcore.active then table.insert(integrations, "Ship Core") end

        if #integrations > 0 then
            activator:ChatPrint("Active Integrations: " .. table.concat(integrations, ", "))
        end
    end
end

-- Simple 4-stage travel command for all players
concommand.Add("hyperdrive_4stage", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or trace.Entity:GetClass() ~= "hyperdrive_master_engine" then
        ply:ChatPrint("[Hyperdrive] Look at a master hyperdrive engine")
        return
    end

    local engine = trace.Entity

    -- Check if 4-stage system is available
    if not HYPERDRIVE.Stargate or not HYPERDRIVE.Stargate.Config.StageSystem.EnableFourStageTravel then
        ply:ChatPrint("[Hyperdrive] 4-stage travel system is disabled")
        return
    end

    -- Check if engine can operate
    local canOperate, reason = engine:CanOperateMaster()
    if not canOperate then
        ply:ChatPrint("[Hyperdrive] Engine cannot operate: " .. reason)
        return
    end

    -- Check if destination is set
    local destination = engine:GetDestination()
    if destination == Vector(0, 0, 0) then
        ply:ChatPrint("[Hyperdrive] No destination set. Use the engine interface to set a destination first.")
        return
    end

    ply:ChatPrint("[Hyperdrive] Initiating 4-stage hyperdrive travel...")
    ply:ChatPrint("[Hyperdrive] Destination: " .. tostring(destination))

    -- Start the jump using the engine's normal method (which will use 4-stage if available)
    engine:ExecuteJumpMaster()
end)

-- Network strings are loaded from hyperdrive_network_strings.lua
if SERVER then

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

-- v2.2.0 New initialization functions
function ENT:InitializeFleetManagement()
    -- Initialize fleet management capabilities
    self.FleetID = 0
    self.FleetRole = ""
    self.FleetData = {}

    -- Set up fleet network variables
    self:SetNWInt("FleetID", 0)
    self:SetNWString("FleetRole", "")
    self:SetNWBool("FleetCapable", true)

    print("[Hyperdrive Master] Fleet management initialized")
end

function ENT:InitializeRealTimeMonitoring()
    -- Initialize real-time monitoring system
    self.RealTimeMonitoring = true
    self.LastRealTimeUpdate = 0
    self.RealTimeUpdateRate = 0.05 -- 20 FPS
    self.SystemAlerts = {}

    -- Set up real-time network variables
    self:SetNWBool("RealTimeMonitoring", true)
    self:SetNWFloat("LastUpdate", CurTime())
    self:SetNWString("SystemStatus", "Operational")

    -- Start real-time monitoring timer
    timer.Create("hyperdrive_realtime_" .. self:EntIndex(), self.RealTimeUpdateRate, 0, function()
        if IsValid(self) then
            self:UpdateRealTimeData()
        else
            timer.Remove("hyperdrive_realtime_" .. self:EntIndex())
        end
    end)

    print("[Hyperdrive Master] Real-time monitoring initialized")
end

function ENT:InitializePerformanceAnalytics()
    -- Initialize performance analytics
    self.PerformanceMetrics = {
        jumpsCompleted = 0,
        totalEnergyUsed = 0,
        averageJumpTime = 0,
        systemUptime = CurTime(),
        lastJumpTime = 0,
        efficiency = 1.0
    }

    -- Set up performance network variables
    self:SetNWInt("JumpsCompleted", 0)
    self:SetNWFloat("TotalEnergyUsed", 0)
    self:SetNWFloat("AverageJumpTime", 0)
    self:SetNWFloat("SystemUptime", CurTime())

    print("[Hyperdrive Master] Performance analytics initialized")
end

function ENT:UpdateRealTimeData()
    -- Update real-time monitoring data
    local currentTime = CurTime()

    -- Update system status
    local status = "Operational"
    if self:GetCharging() then
        status = "Charging"
    elseif self:GetCooldown() > currentTime then
        status = "Cooldown"
    elseif self:GetEnergy() < 100 then
        status = "Low Energy"
    end

    self:SetNWString("SystemStatus", status)
    self:SetNWFloat("LastUpdate", currentTime)

    -- Update performance metrics
    local uptime = currentTime - self.PerformanceMetrics.systemUptime
    self:SetNWFloat("SystemUptime", uptime)

    -- Check for system alerts
    self:CheckSystemAlerts()

    self.LastRealTimeUpdate = currentTime
end

function ENT:CheckSystemAlerts()
    -- Check for various system alerts
    local alerts = {}

    -- Energy alerts
    local energyPercent = (self:GetEnergy() / 1000) * 100
    if energyPercent < 10 then
        table.insert(alerts, {type = "critical", message = "Energy critically low"})
    elseif energyPercent < 25 then
        table.insert(alerts, {type = "warning", message = "Energy low"})
    end

    -- Temperature alerts
    if self:GetTemperature() > 90 then
        table.insert(alerts, {type = "critical", message = "Temperature critical"})
    elseif self:GetTemperature() > 70 then
        table.insert(alerts, {type = "warning", message = "Temperature high"})
    end

    -- Coolant alerts
    if self:GetCoolantLevel() < 10 then
        table.insert(alerts, {type = "warning", message = "Coolant low"})
    end

    -- Update alerts
    self.SystemAlerts = alerts
    self:SetNWInt("AlertCount", #alerts)

    -- Send critical alerts to admins
    if #alerts > 0 then
        for _, alert in ipairs(alerts) do
            if alert.type == "critical" and HYPERDRIVE.Admin then
                HYPERDRIVE.Admin.NotifyAdmins("Hyperdrive Engine Alert: " .. alert.message, "error")
            end
        end
    end
end

print("[Hyperdrive Master] Master Engine with ALL features including v2.2.0 loaded")
