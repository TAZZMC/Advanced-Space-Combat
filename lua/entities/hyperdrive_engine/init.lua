-- Enhanced Hyperdrive Engine v5.1.0 - Server-side code
-- Uses the new Hyperdrive Ship Core system with comprehensive CAP integration
-- PHASE 3 ENHANCED - Complete system update with advanced targeting and UI improvements

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Initialize CAP asset integration
    self.selectedTechnology = "Tauri" -- Default technology
    self:ApplyCAPModel()

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMaterial("metal")
    end

    -- Initialize hyperdrive properties
    self:SetEnergy(0)
    self:SetCharging(false)
    self:SetCooldown(0)
    self:SetDestination(Vector(0, 0, 0))
    self:SetJumpReady(false)

    -- Enhanced engine configuration
    self.MaxEnergy = 1000
    self.ChargeRate = 50 -- Energy per second
    self.JumpCost = 800
    self.CooldownTime = 5
    self.JumpRange = 50000

    -- Ship detection and integration
    self.LastShipUpdate = 0
    self.ShipUpdateInterval = 1.0
    self.DetectedEntities = {}
    self.DetectedPlayers = {}
    self.Ship = nil
    self.ShipCore = nil

    -- CAP integration state
    self.CAPIntegrationActive = false
    self.CAPShieldsDetected = false
    self.CAPEnergyDetected = false
    self.LastCAPUpdate = 0
    self.CAPUpdateInterval = 2.0

    -- Enhanced configuration
    self.Config = {
        RequireShipCore = true,     -- Require ship core for operation
        AutoActivateShields = true, -- Auto-activate shields during charge
        UseCAPShields = true,       -- Use CAP shields if available
        UseCAPEnergy = true,        -- Use CAP energy sources
        UseCAPEffects = true,       -- Use CAP visual/audio effects
        PreferCAP = true,           -- Prefer CAP systems over custom
        CAPDetectionRange = 2000    -- Range to detect CAP entities
    }

    -- Create ship in our ship core system
    if HYPERDRIVE.ShipCore then
        timer.Simple(0.1, function()
            if IsValid(self) then
                HYPERDRIVE.ShipCore.DetectShipForEngine(self)
                self:InitializeCAPIntegration()
            end
        end)
    end

    -- Initialize modern UI integration
    self.UIData = {
        lastUpdate = 0,
        updateInterval = 1.0,
        notifications = {},
        theme = "modern"
    }

    print("[Hyperdrive] Enhanced Engine v5.1.0 - Phase 3 Enhanced - with CAP integration initialized: " .. self:EntIndex())
end

-- Apply CAP model based on selected technology
function ENT:ApplyCAPModel()
    local fallbackModel = "models/props_phx/construct/metal_plate1.mdl"

    if ASC and ASC.CAP and ASC.CAP.Assets then
        local model = ASC.CAP.Assets.GetEntityModel("hyperdrive_engine", self.selectedTechnology, fallbackModel)
        local color = ASC.CAP.Assets.GetTechnologyColor(self.selectedTechnology)

        self:SetModel(model)
        self:SetColor(color)

        -- Apply technology-specific material
        local material = ASC.CAP.Assets.GetMaterial(self.selectedTechnology, "engine", "")
        if material and material ~= "" then
            self:SetMaterial(material)
        end

        print("[Hyperdrive Engine] Applied " .. self.selectedTechnology .. " technology model: " .. model)
    else
        self:SetModel(fallbackModel)
        self:SetColor(Color(255, 255, 255))
        print("[Hyperdrive Engine] CAP assets not available, using fallback model")
    end
end

-- Change technology type
function ENT:SetTechnology(technology)
    if not technology then return false end

    local availableTechs = ASC and ASC.CAP and ASC.CAP.Assets and ASC.CAP.Assets.GetEntityTechnologies("hyperdrive_engine") or {}

    -- Check if technology is available
    local techAvailable = false
    for _, tech in ipairs(availableTechs) do
        if tech == technology then
            techAvailable = true
            break
        end
    end

    if not techAvailable then
        -- Fallback to standard technologies
        local standardTechs = {"Ancient", "Goauld", "Asgard", "Tauri", "Ori", "Wraith"}
        techAvailable = table.HasValue(standardTechs, technology)
    end

    if techAvailable then
        self.selectedTechnology = technology
        self:ApplyCAPModel()

        -- Update network variables
        self:SetNWString("Technology", technology)

        return true
    end

    return false
end

-- Get current technology
function ENT:GetTechnology()
    return self.selectedTechnology or "Tauri"
end

-- Initialize CAP integration
function ENT:InitializeCAPIntegration()
    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Available then
        return
    end

    self.CAPIntegrationActive = true
    self:UpdateCAPStatus()

    print("[Hyperdrive Engine] CAP integration initialized for engine " .. self:EntIndex())
end

-- Update CAP integration status
function ENT:UpdateCAPStatus()
    if not self.CAPIntegrationActive then return end

    local currentTime = CurTime()
    if currentTime - self.LastCAPUpdate < self.CAPUpdateInterval then return end
    self.LastCAPUpdate = currentTime

    -- Get ship and ship core
    self.Ship = self:GetShip()
    self.ShipCore = self:GetShipCore()

    if self.Ship and HYPERDRIVE.CAP.Shields then
        -- Check for CAP shields
        local shields = HYPERDRIVE.CAP.Shields.FindShields(self.Ship)
        self.CAPShieldsDetected = #shields > 0

        -- Check for CAP energy sources
        if HYPERDRIVE.CAP.Resources then
            local energySources = HYPERDRIVE.CAP.Resources.FindEnergySources(self.Ship)
            self.CAPEnergyDetected = #energySources > 0
        end
    end
end

function ENT:Think()
    local currentTime = CurTime()

    -- Update CAP integration status
    self:UpdateCAPStatus()

    -- Update energy and charging
    self:UpdateEnergy(currentTime)

    -- Update cooldown
    self:UpdateCooldown(currentTime)

    -- Update ship detection
    self:UpdateShipDetection(currentTime)

    -- Update resource integration
    self:UpdateResourceIntegration()

    -- Update wire outputs
    self:UpdateWireOutputs()

    self:NextThink(currentTime + 0.1)
    return true
end

function ENT:UpdateEnergy(currentTime)
    if self:GetCharging() then
        local energy = self:GetEnergy()
        local newEnergy = math.min(energy + (self.ChargeRate * 0.1), self.MaxEnergy)
        self:SetEnergy(newEnergy)

        -- Check if fully charged
        if newEnergy >= self.MaxEnergy then
            self:SetCharging(false)
            self:SetJumpReady(true)
            print("[Hyperdrive] Engine " .. self:EntIndex() .. " fully charged")
        end
    end
end

function ENT:UpdateCooldown(currentTime)
    local cooldown = self:GetCooldown()
    if cooldown > 0 then
        local newCooldown = math.max(cooldown - 0.1, 0)
        self:SetCooldown(newCooldown)

        if newCooldown <= 0 then
            print("[Hyperdrive] Engine " .. self:EntIndex() .. " cooldown complete")
        end
    end
end

function ENT:UpdateShipDetection(currentTime)
    if currentTime - self.LastShipUpdate < self.ShipUpdateInterval then
        return
    end

    self.LastShipUpdate = currentTime

    -- Update ship data using our ship core system
    if HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShip(self)
        if ship then
            ship:Update()
            self.DetectedEntities = ship:GetEntities()
            self.DetectedPlayers = ship:GetPlayers()
        end
    else
        -- Fallback detection
        self.DetectedEntities = self:GetNearbyEntities()
        self.DetectedPlayers = self:GetPlayersInShip()
    end
end

-- Get nearby entities for jumping (using our ship core system)
function ENT:GetNearbyEntities(radius)
    if HYPERDRIVE.ShipCore then
        -- Use our advanced ship detection system
        return HYPERDRIVE.ShipCore.GetAttachedEntities(self, radius)
    else
        -- Fallback to basic sphere detection
        radius = radius or 1500
        local pos = self:GetPos()
        local entities = {}

        for _, ent in ipairs(ents.FindInSphere(pos, radius)) do
            if IsValid(ent) and ent ~= self and not ent:IsPlayer() then
                table.insert(entities, ent)
            end
        end

        return entities
    end
end

-- Get players in ship
function ENT:GetPlayersInShip()
    if HYPERDRIVE.ShipCore then
        return HYPERDRIVE.ShipCore.GetPlayersInShip(self)
    else
        -- Fallback to basic sphere detection
        local pos = self:GetPos()
        local players = {}

        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() and ply:GetPos():Distance(pos) <= 2000 then
                table.insert(players, ply)
            end
        end

        return players
    end
end

-- Get ship information
function ENT:GetShipInfo()
    if HYPERDRIVE.ShipCore then
        return HYPERDRIVE.ShipCore.GetShipInfo(self)
    else
        return {
            entities = self:GetNearbyEntities(),
            players = self:GetPlayersInShip(),
            center = self:GetPos(),
            orientation = self:GetAngles(),
            shipType = "unknown"
        }
    end
end

-- Get ship object
function ENT:GetShip()
    if self.Ship then return self.Ship end

    if HYPERDRIVE.ShipCore then
        self.Ship = HYPERDRIVE.ShipCore.GetShipByEntity(self)
        return self.Ship
    end

    return nil
end

-- Get ship core
function ENT:GetShipCore()
    if self.ShipCore then return self.ShipCore end

    local ship = self:GetShip()
    if ship and ship.core and IsValid(ship.core) then
        self.ShipCore = ship.core
        return self.ShipCore
    end

    return nil
end

-- Start charging the engine with enhanced integration (REQUIRES SHIP CORE)
function ENT:StartCharging()
    if self:GetCooldown() > 0 then
        return false, "Engine is on cooldown"
    end

    if self:GetCharging() then
        return false, "Engine is already charging"
    end

    if self:GetEnergy() >= self.MaxEnergy then
        self:SetJumpReady(true)
        return true, "Engine already charged"
    end

    -- MANDATORY: Ship core validation (REQUIRED for all hyperdrive operations)
    if HYPERDRIVE.Core and HYPERDRIVE.Core.ValidateShipForJump then
        local valid, message = HYPERDRIVE.Core.ValidateShipForJump(self)
        if not valid then
            return false, "Ship core required: " .. message
        end
    else
        -- Fallback validation if core system not available
        if not HYPERDRIVE.ShipCore then
            return false, "Ship core system required but not loaded"
        end

        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(self)
        if not ship then
            return false, "No ship detected - hyperdrive requires ship core"
        end

        if not ship.core or not IsValid(ship.core) then
            return false, "Ship core missing or invalid - hyperdrive requires functional ship core"
        end

        -- Check resource requirements if SB3 resource system is active
        if HYPERDRIVE.SB3Resources then
            local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(ship.core)
            if storage then
                -- Check if in emergency mode
                if storage.emergencyMode then
                    return false, "Cannot activate hyperdrive: Ship in emergency mode"
                end

                -- Check energy requirements
                local energyPercent = HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "energy")
                if energyPercent < 25 then
                    return false, "Insufficient ship energy (" .. string.format("%.1f", energyPercent) .. "% - need 25%)"
                end

                -- Check fuel requirements
                local fuelPercent = HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "fuel")
                if fuelPercent < 15 then
                    return false, "Insufficient ship fuel (" .. string.format("%.1f", fuelPercent) .. "% - need 15%)"
                end
            end
        end
    end

    -- Hull integrity validation
    if HYPERDRIVE.Core and HYPERDRIVE.Core.Config.EnableHullDamage and HYPERDRIVE.Core.CheckHullIntegrityForJump then
        local hullValid, hullMessage = HYPERDRIVE.Core.CheckHullIntegrityForJump(self)
        if not hullValid then
            return false, "Hull damage critical: " .. hullMessage
        end
    end

    self:SetCharging(true)
    self:SetJumpReady(false)

    -- Auto-activate shields if available (enhanced with CAP integration)
    if self.Config.AutoActivateShields then
        local ship = self:GetShip()
        local core = self:GetShipCore()

        if ship and core then
            -- Try CAP shields first if preferred
            if self.Config.UseCAPShields and HYPERDRIVE.Shields and HYPERDRIVE.Shields.ActivateForHyperdrive then
                HYPERDRIVE.Shields.ActivateForHyperdrive(core, ship, "hyperdrive_charge")
            elseif HYPERDRIVE.Core and HYPERDRIVE.Core.ActivateShieldsForJump then
                HYPERDRIVE.Core.ActivateShieldsForJump(self)
            end
        end
    end

    -- Get ship using enhanced core or fallback
    local ship
    if HYPERDRIVE.Core and HYPERDRIVE.Core.GetShipFromEngine then
        ship = HYPERDRIVE.Core.GetShipFromEngine(self)
    elseif HYPERDRIVE.ShipCore then
        ship = HYPERDRIVE.ShipCore.GetShipByEntity(self)
    end

    -- Create world effects around ship
    if HYPERDRIVE.WorldEffects and ship then
        HYPERDRIVE.WorldEffects.CreateChargingEffects(self, ship)
    end

    -- Call hook for other systems
    hook.Call("HyperdriveChargingStart", nil, self, ship)

    print("[Hyperdrive] Engine " .. self:EntIndex() .. " started charging with ship core")
    return true, "Charging started"
end

-- Stop charging
function ENT:StopCharging()
    self:SetCharging(false)
    print("[Hyperdrive] Engine " .. self:EntIndex() .. " stopped charging")
end

-- Set destination with enhanced validation
function ENT:SetDestinationPos(pos)
    if not isvector(pos) then
        return false, "Invalid destination"
    end

    -- Enhanced validation using core system
    if HYPERDRIVE.Core and HYPERDRIVE.Core.IsValidDestination then
        local valid, message = HYPERDRIVE.Core.IsValidDestination(pos, self:GetPos(), self)
        if not valid then
            return false, message
        end
    else
        -- Fallback validation
        local distance = self:GetPos():Distance(pos)
        if distance > self.JumpRange then
            return false, "Destination too far (max: " .. self.JumpRange .. ")"
        end
    end

    self:SetDestination(pos)
    return true, "Destination set"
end

-- Perform hyperdrive jump
function ENT:StartJump()
    if not self:GetJumpReady() then
        return false, "Engine not ready"
    end

    if self:GetEnergy() < self.JumpCost then
        return false, "Insufficient energy"
    end

    local destination = self:GetDestination()
    if destination == Vector(0, 0, 0) then
        return false, "No destination set"
    end

    -- Get entities and players to move
    local entities = self.DetectedEntities or self:GetNearbyEntities()
    local players = self.DetectedPlayers or self:GetPlayersInShip()

    print("[Hyperdrive] Starting jump with " .. #entities .. " entities and " .. #players .. " players")

    -- Perform the jump
    local success = self:PerformJump(entities, players, destination)

    if success then
        -- Consume energy and start cooldown
        self:SetEnergy(self:GetEnergy() - self.JumpCost)
        self:SetJumpReady(false)
        self:SetCooldown(self.CooldownTime)

        -- Consume ship resources if SB3 resource system is active
        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(self)
        if ship and ship.core and IsValid(ship.core) and HYPERDRIVE.SB3Resources then
            local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(ship.core)
            if storage then
                -- Calculate resource consumption based on jump distance
                local distance = self:GetPos():Distance(destination)
                local distanceFactor = math.min(distance / self.JumpRange, 1.0)

                -- Base consumption amounts
                local energyConsumption = 500 + (distanceFactor * 1000) -- 500-1500 energy
                local fuelConsumption = 200 + (distanceFactor * 400)    -- 200-600 fuel

                -- Consume resources
                HYPERDRIVE.SB3Resources.RemoveResource(ship.core, "energy", energyConsumption)
                HYPERDRIVE.SB3Resources.RemoveResource(ship.core, "fuel", fuelConsumption)

                print("[Hyperdrive] Consumed " .. math.floor(energyConsumption) .. " energy and " .. math.floor(fuelConsumption) .. " fuel for jump")
            end
        end

        print("[Hyperdrive] Jump completed successfully")
        return true, "Jump successful"
    else
        return false, "Jump failed"
    end
end

-- Perform the actual jump
function ENT:PerformJump(entities, players, destination)
    local currentPos = self:GetPos()
    local currentAng = self:GetAngles()

    -- Create hyperspace window effect
    if HYPERDRIVE.WorldEffects and HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShip(self)
        if ship then
            -- Entry window
            HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(self, ship, "enter")

            -- Starlines during travel
            timer.Simple(0.5, function()
                if IsValid(self) and ship then
                    HYPERDRIVE.WorldEffects.CreateStarlinesEffect(self, ship)
                end
            end)

            -- Exit window at destination
            timer.Simple(2.5, function()
                if IsValid(self) and ship then
                    -- Update ship position for exit effect
                    ship.center = destination
                    HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(self, ship, "exit")
                end
            end)
        end
    end

    -- Delay actual movement to sync with effects
    timer.Simple(1.0, function()
        if not IsValid(self) then return end

        -- Use ship core system for coordinated movement
        if HYPERDRIVE.ShipCore then
            HYPERDRIVE.ShipCore.MoveShip(self, destination, currentAng)
        else
            -- Fallback: move entities individually
            local offset = destination - currentPos

            -- Move entities
            for _, ent in ipairs(entities) do
                if IsValid(ent) then
                    local entPos = ent:GetPos()
                    local newPos = entPos + offset
                    ent:SetPos(newPos)

                    local phys = ent:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:SetPos(newPos)
                        phys:Wake()
                    end
                end
            end

            -- Move players
            for _, ply in ipairs(players) do
                if IsValid(ply) then
                    local plyPos = ply:GetPos()
                    local newPos = plyPos + offset
                    ply:SetPos(newPos)
                end
            end
        end
    end)

    return true
end

-- Wire inputs
function ENT:TriggerInput(iname, value)
    if iname == "Jump" and value > 0 then
        self:StartJump()
    elseif iname == "SetDestinationX" then
        local dest = self:GetDestination()
        self:SetDestinationPos(Vector(value, dest.y, dest.z))
    elseif iname == "SetDestinationY" then
        local dest = self:GetDestination()
        self:SetDestinationPos(Vector(dest.x, value, dest.z))
    elseif iname == "SetDestinationZ" then
        local dest = self:GetDestination()
        self:SetDestinationPos(Vector(dest.x, dest.y, value))
    elseif iname == "SetDestination" and isvector(value) then
        self:SetDestinationPos(value)
    elseif iname == "Abort" and value > 0 then
        self:StopCharging()
    elseif iname == "SetEnergy" then
        self:SetEnergy(math.Clamp(value, 0, self.MaxEnergy))
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
                HYPERDRIVE.Shields.ManualActivate(self, ship)
            end
        end
    elseif iname == "DeactivateShield" and value > 0 then
        if HYPERDRIVE.Shields and HYPERDRIVE.ShipCore then
            local ship = HYPERDRIVE.ShipCore.GetShipByEntity(self)
            if ship then
                HYPERDRIVE.Shields.ManualDeactivate(self, ship)
            end
        end
    end

    -- Update wire outputs
    self:UpdateWireOutputs()
end

-- Update wire outputs
function ENT:UpdateWireOutputs()
    if not WireLib then return end

    WireLib.TriggerOutput(self, "Energy", self:GetEnergy())
    WireLib.TriggerOutput(self, "EnergyPercent", (self:GetEnergy() / self.MaxEnergy) * 100)
    WireLib.TriggerOutput(self, "Charging", self:GetCharging() and 1 or 0)
    WireLib.TriggerOutput(self, "Cooldown", self:GetCooldown())
    WireLib.TriggerOutput(self, "JumpReady", self:GetJumpReady() and 1 or 0)
    WireLib.TriggerOutput(self, "Destination", self:GetDestination())

    -- Status string
    local status = "IDLE"
    if self:GetCooldown() > 0 then
        status = "COOLDOWN"
    elseif self:GetCharging() then
        status = "CHARGING"
    elseif self:GetJumpReady() then
        status = "READY"
    end
    WireLib.TriggerOutput(self, "Status", status)

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

    -- Hull damage outputs
    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(self)
    if HYPERDRIVE.HullDamage and ship and ship.core and IsValid(ship.core) then
        local hullStatus = HYPERDRIVE.HullDamage.GetHullStatus(ship.core)
        if hullStatus then
            WireLib.TriggerOutput(self, "HullIntegrity", hullStatus.integrity or 100)
            WireLib.TriggerOutput(self, "HullIntegrityPercent", hullStatus.integrityPercent or 100)
            WireLib.TriggerOutput(self, "HullCriticalMode", hullStatus.criticalMode and 1 or 0)
            WireLib.TriggerOutput(self, "HullEmergencyMode", hullStatus.emergencyMode and 1 or 0)
            WireLib.TriggerOutput(self, "HullBreaches", hullStatus.breaches or 0)
            WireLib.TriggerOutput(self, "HullSystemFailures", hullStatus.systemFailures or 0)
            WireLib.TriggerOutput(self, "HullAutoRepairActive", hullStatus.autoRepairActive and 1 or 0)
            WireLib.TriggerOutput(self, "HullRepairProgress", hullStatus.repairProgress or 0)
            WireLib.TriggerOutput(self, "HullTotalDamage", hullStatus.totalDamageReceived or 0)
            WireLib.TriggerOutput(self, "HullDamagedSections", hullStatus.damagedSections or 0)
        else
            WireLib.TriggerOutput(self, "HullIntegrity", 100)
            WireLib.TriggerOutput(self, "HullIntegrityPercent", 100)
            WireLib.TriggerOutput(self, "HullCriticalMode", 0)
            WireLib.TriggerOutput(self, "HullEmergencyMode", 0)
            WireLib.TriggerOutput(self, "HullBreaches", 0)
            WireLib.TriggerOutput(self, "HullSystemFailures", 0)
            WireLib.TriggerOutput(self, "HullAutoRepairActive", 0)
            WireLib.TriggerOutput(self, "HullRepairProgress", 0)
            WireLib.TriggerOutput(self, "HullTotalDamage", 0)
            WireLib.TriggerOutput(self, "HullDamagedSections", 0)
        end
    else
        WireLib.TriggerOutput(self, "HullIntegrity", 100)
        WireLib.TriggerOutput(self, "HullIntegrityPercent", 100)
        WireLib.TriggerOutput(self, "HullCriticalMode", 0)
        WireLib.TriggerOutput(self, "HullEmergencyMode", 0)
        WireLib.TriggerOutput(self, "HullBreaches", 0)
        WireLib.TriggerOutput(self, "HullSystemFailures", 0)
        WireLib.TriggerOutput(self, "HullAutoRepairActive", 0)
        WireLib.TriggerOutput(self, "HullRepairProgress", 0)
        WireLib.TriggerOutput(self, "HullTotalDamage", 0)
        WireLib.TriggerOutput(self, "HullDamagedSections", 0)
    end

    -- Ship core validation outputs
    if ship and ship.core and IsValid(ship.core) and HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness then
        local coreValid, coreMessage = HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness(ship.core)
        WireLib.TriggerOutput(self, "ShipCoreValid", coreValid and 1 or 0)
        WireLib.TriggerOutput(self, "ShipCoreStatus", coreMessage or "Unknown")
    else
        WireLib.TriggerOutput(self, "ShipCoreValid", 0)
        WireLib.TriggerOutput(self, "ShipCoreStatus", ship and "No ship core" or "No ship detected")
    end

    -- Resource system outputs
    if ship and ship.core and IsValid(ship.core) and HYPERDRIVE.SB3Resources then
        local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(ship.core)
        if storage then
            WireLib.TriggerOutput(self, "ResourceSystemActive", 1)
            WireLib.TriggerOutput(self, "ResourceEnergyLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "energy"))
            WireLib.TriggerOutput(self, "ResourceOxygenLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "oxygen"))
            WireLib.TriggerOutput(self, "ResourceCoolantLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "coolant"))
            WireLib.TriggerOutput(self, "ResourceFuelLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "fuel"))
            WireLib.TriggerOutput(self, "ResourceWaterLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "water"))
            WireLib.TriggerOutput(self, "ResourceNitrogenLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "nitrogen"))
            WireLib.TriggerOutput(self, "ResourceEmergencyMode", storage.emergencyMode and 1 or 0)

            -- Calculate if hyperdrive can activate based on resources
            local canActivate = 1
            if storage.emergencyMode then
                canActivate = 0
            elseif HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "energy") < 25 then
                canActivate = 0
            elseif HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "fuel") < 15 then
                canActivate = 0
            end
            WireLib.TriggerOutput(self, "ResourcesReady", canActivate)
        else
            WireLib.TriggerOutput(self, "ResourceSystemActive", 0)
            WireLib.TriggerOutput(self, "ResourceEnergyLevel", 0)
            WireLib.TriggerOutput(self, "ResourceOxygenLevel", 0)
            WireLib.TriggerOutput(self, "ResourceCoolantLevel", 0)
            WireLib.TriggerOutput(self, "ResourceFuelLevel", 0)
            WireLib.TriggerOutput(self, "ResourceWaterLevel", 0)
            WireLib.TriggerOutput(self, "ResourceNitrogenLevel", 0)
            WireLib.TriggerOutput(self, "ResourceEmergencyMode", 0)
            WireLib.TriggerOutput(self, "ResourcesReady", 0)
        end
    else
        WireLib.TriggerOutput(self, "ResourceSystemActive", 0)
        WireLib.TriggerOutput(self, "ResourceEnergyLevel", 0)
        WireLib.TriggerOutput(self, "ResourceOxygenLevel", 0)
        WireLib.TriggerOutput(self, "ResourceCoolantLevel", 0)
        WireLib.TriggerOutput(self, "ResourceFuelLevel", 0)
        WireLib.TriggerOutput(self, "ResourceWaterLevel", 0)
        WireLib.TriggerOutput(self, "ResourceNitrogenLevel", 0)
        WireLib.TriggerOutput(self, "ResourceEmergencyMode", 0)
        WireLib.TriggerOutput(self, "ResourcesReady", 0)
    end

    -- CAP integration outputs
    WireLib.TriggerOutput(self, "CAPIntegrationActive", self.CAPIntegrationActive and 1 or 0)
    WireLib.TriggerOutput(self, "CAPShieldsDetected", self.CAPShieldsDetected and 1 or 0)
    WireLib.TriggerOutput(self, "CAPEnergyDetected", self.CAPEnergyDetected and 1 or 0)

    -- CAP resource levels if available
    if self.CAPIntegrationActive and ship and HYPERDRIVE.CAP and HYPERDRIVE.CAP.Resources then
        local totalCAPEnergy = HYPERDRIVE.CAP.Resources.GetTotalEnergy(ship)
        WireLib.TriggerOutput(self, "CAPEnergyLevel", totalCAPEnergy)
    else
        WireLib.TriggerOutput(self, "CAPEnergyLevel", 0)
    end
end

-- Use function for engine interface
function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Use the new interface system for validation
    local valid, message = HYPERDRIVE.Interface and HYPERDRIVE.Interface.ValidateInteraction(self, activator, {
        sessionType = "hyperdrive_engine",
        maxDistance = 200
    })

    if not valid then
        valid, message = true, ""
    end

    if not valid then
        if HYPERDRIVE.Interface then
            HYPERDRIVE.Interface.SendFeedback(activator, message, "error")
        else
            activator:ChatPrint("[Hyperdrive Engine] " .. message)
        end
        return
    end

    -- Check if player is holding shift for ship core UI
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or {}
    if config.EnableShiftModifier and activator:KeyDown(IN_WALK) then
        -- Try to open ship core UI if available
        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(self)
        if ship and ship.core and IsValid(ship.core) then
            ship.core:OpenUI(activator)
            if HYPERDRIVE.Interface then
                HYPERDRIVE.Interface.SendFeedback(activator, "Opening ship core management interface...", "success")
            else
                activator:ChatPrint("[Hyperdrive Engine] Opening ship core management interface...")
            end
            return
        else
            if HYPERDRIVE.Interface then
                HYPERDRIVE.Interface.SendFeedback(activator, "No ship core detected. Ship core required for management interface.", "warning")
            else
                activator:ChatPrint("[Hyperdrive Engine] No ship core detected. Ship core required for management interface.")
            end
            return
        end
    end

    -- Start interface session
    if HYPERDRIVE.Interface then
        HYPERDRIVE.Interface.StartSession(self, activator, "hyperdrive_engine")
    end

    -- Default USE action - open engine interface
    self:OpenEngineInterface(activator)
end

-- Open engine interface
function ENT:OpenEngineInterface(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or {}

    -- Show basic engine info
    if HYPERDRIVE.Interface and config.EnableStatusDisplay then
        HYPERDRIVE.Interface.SendFeedback(activator, "Engine Status: " .. (self:GetCharging() and "Charging" or "Ready"), "info")
        HYPERDRIVE.Interface.SendFeedback(activator, "Energy: " .. math.floor(self:GetEnergy()) .. "/" .. self.MaxEnergy, "info")
    else
        activator:ChatPrint("[Hyperdrive Engine] Status: " .. (self:GetCharging() and "Charging" or "Ready"))
        activator:ChatPrint("Energy: " .. math.floor(self:GetEnergy()) .. "/" .. self.MaxEnergy)
    end

    -- Show ship core info if available
    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(self)
    if ship and ship.core and IsValid(ship.core) then
        if HYPERDRIVE.Interface and config.EnableStatusDisplay then
            HYPERDRIVE.Interface.SendFeedback(activator, "Ship: " .. (ship:GetShipName() or "Unnamed Ship"), "info")
            HYPERDRIVE.Interface.SendFeedback(activator, "Type: " .. ship:GetShipType() .. " (" .. #ship:GetEntities() .. " entities)", "info")
        else
            activator:ChatPrint("Ship: " .. (ship:GetShipName() or "Unnamed Ship"))
            activator:ChatPrint("Type: " .. ship:GetShipType() .. " (" .. #ship:GetEntities() .. " entities)")
        end

        -- Show hull status if available
        local hullStatus = HYPERDRIVE.HullDamage and HYPERDRIVE.HullDamage.GetHullStatus(ship.core)
        if hullStatus then
            local hullColor = hullStatus.integrityPercent >= 75 and "success" or
                             hullStatus.integrityPercent >= 50 and "info" or
                             hullStatus.integrityPercent >= 25 and "warning" or "error"

            if HYPERDRIVE.Interface and config.EnableStatusDisplay then
                HYPERDRIVE.Interface.SendFeedback(activator, "Hull: " .. string.format("%.1f", hullStatus.integrityPercent) .. "%", hullColor)
            else
                activator:ChatPrint("Hull: " .. string.format("%.1f", hullStatus.integrityPercent) .. "%")
            end
        end

        -- Show resource status if available
        if HYPERDRIVE.SB3Resources then
            local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(ship.core)
            if storage then
                local energyPercent = HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "energy")
                local fuelPercent = HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "fuel")

                local energyColor = energyPercent >= 50 and "success" or energyPercent >= 25 and "warning" or "error"
                local fuelColor = fuelPercent >= 50 and "success" or fuelPercent >= 25 and "warning" or "error"

                if HYPERDRIVE.Interface and config.EnableStatusDisplay then
                    HYPERDRIVE.Interface.SendFeedback(activator, "Energy: " .. string.format("%.1f", energyPercent) .. "%", energyColor)
                    HYPERDRIVE.Interface.SendFeedback(activator, "Fuel: " .. string.format("%.1f", fuelPercent) .. "%", fuelColor)

                    if storage.emergencyMode then
                        HYPERDRIVE.Interface.SendFeedback(activator, "EMERGENCY MODE ACTIVE", "error")
                    end
                else
                    activator:ChatPrint("Energy: " .. string.format("%.1f", energyPercent) .. "%")
                    activator:ChatPrint("Fuel: " .. string.format("%.1f", fuelPercent) .. "%")

                    if storage.emergencyMode then
                        activator:ChatPrint("EMERGENCY MODE ACTIVE")
                    end
                end
            end
        end

        if config.EnableShiftModifier then
            if HYPERDRIVE.Interface then
                HYPERDRIVE.Interface.SendFeedback(activator, "Hold SHIFT + USE to open ship management interface", "info")
            else
                activator:ChatPrint("Hold SHIFT + USE to open ship management interface")
            end
        end
    else
        if HYPERDRIVE.Interface and config.EnableStatusDisplay then
            HYPERDRIVE.Interface.SendFeedback(activator, "No ship core detected - place a ship core for full functionality", "warning")
        else
            activator:ChatPrint("No ship core detected - place a ship core for full functionality")
        end
    end

    -- End interface session after showing info
    if HYPERDRIVE.Interface then
        HYPERDRIVE.Interface.EndSession(self, activator, "hyperdrive_engine")
    end
end

-- Update resource integration
function ENT:UpdateResourceIntegration()
    if not HYPERDRIVE.SB3Resources then return end

    local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(self)
    if not ship or not ship.core or not IsValid(ship.core) then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(ship.core)
    if not storage then return end

    -- Update network variables for resource status
    self:SetNWBool("ResourceSystemActive", true)
    self:SetNWFloat("ShipEnergyLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "energy"))
    self:SetNWFloat("ShipFuelLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "fuel"))
    self:SetNWBool("ResourceEmergencyMode", storage.emergencyMode or false)

    -- Check if hyperdrive can activate based on resources
    local canActivate = true
    if storage.emergencyMode then
        canActivate = false
    elseif HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "energy") < 25 then
        canActivate = false
    elseif HYPERDRIVE.SB3Resources.GetResourcePercentage(ship.core, "fuel") < 15 then
        canActivate = false
    end

    self:SetNWBool("ResourcesReady", canActivate)
end

-- Clean up
function ENT:OnRemove()
    if HYPERDRIVE.ShipCore then
        HYPERDRIVE.ShipCore.RemoveShip(self)
    end

    print("[Hyperdrive] Engine removed: " .. self:EntIndex())
end
