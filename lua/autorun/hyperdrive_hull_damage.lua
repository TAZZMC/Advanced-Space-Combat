-- Enhanced Hyperdrive System - Hull Damage System
-- Comprehensive hull damage mechanics with ship core integration

if not HYPERDRIVE then
    HYPERDRIVE = {}
end

HYPERDRIVE.HullDamage = HYPERDRIVE.HullDamage or {}

-- Hull damage configuration
HYPERDRIVE.HullDamage.Config = {
    EnableHullDamage = true,
    MaxHullIntegrity = 100,
    CriticalHullThreshold = 25,
    EmergencyHullThreshold = 10,
    HullRepairRate = 0.5,
    AutoRepairEnabled = true,
    AutoRepairDelay = 30,
    DamageToShieldsRatio = 0.3,
    HullBreachChance = 0.1,
    SystemFailureChance = 0.05,
    RepairCostMultiplier = 1.0,
    DamageVisualsEnabled = true,
    DamageEffectsEnabled = true,
    HullDamageWireIntegration = true
}

-- Hull damage data storage
HYPERDRIVE.HullDamage.Ships = {}
HYPERDRIVE.HullDamage.DamageHistory = {}

-- Hull damage class
local HullDamageClass = {}
HullDamageClass.__index = HullDamageClass

function HullDamageClass:New(ship, core)
    local hull = setmetatable({}, HullDamageClass)

    hull.ship = ship
    hull.core = core
    hull.integrity = HYPERDRIVE.HullDamage.Config.MaxHullIntegrity
    hull.maxIntegrity = HYPERDRIVE.HullDamage.Config.MaxHullIntegrity
    hull.damagedSections = {}
    hull.breaches = {}
    hull.systemFailures = {}
    hull.repairProgress = 0
    hull.autoRepairActive = false
    hull.lastDamageTime = 0
    hull.totalDamageReceived = 0
    hull.repairCost = 0
    hull.criticalAlerts = {}
    hull.emergencyMode = false
    hull.created = CurTime()

    return hull
end

-- Initialize hull damage system for ship
function HullDamageClass:Initialize()
    if not IsValid(self.core) or not self.ship then
        return false
    end

    -- Register hull damage system
    local hullId = "hull_" .. self.core:EntIndex()
    HYPERDRIVE.HullDamage.Ships[hullId] = self

    -- Initialize damage sections based on ship entities
    self:InitializeDamageSections()

    -- Set up auto-repair if enabled
    if HYPERDRIVE.HullDamage.Config.AutoRepairEnabled then
        self:StartAutoRepair()
    end

    -- Initialize wire integration
    if HYPERDRIVE.HullDamage.Config.HullDamageWireIntegration then
        self:InitializeWireIntegration()
    end

    print("[Hyperdrive Hull] Hull damage system initialized for ship " .. self.ship.shipType)
    return true
end

-- Initialize damage sections based on ship entities
function HullDamageClass:InitializeDamageSections()
    if not self.ship or not self.ship.GetEntities then return end

    local entities = self.ship:GetEntities()
    self.damagedSections = {}

    for i, ent in ipairs(entities) do
        if IsValid(ent) then
            self.damagedSections[ent:EntIndex()] = {
                entity = ent,
                integrity = 100,
                maxIntegrity = 100,
                damageType = "none",
                repairPriority = 1,
                criticalComponent = self:IsCriticalComponent(ent),
                lastDamage = 0
            }
        end
    end

    print("[Hyperdrive Hull] Initialized " .. table.Count(self.damagedSections) .. " damage sections")
end

-- Check if entity is a critical component
function HullDamageClass:IsCriticalComponent(ent)
    if not IsValid(ent) then return false end

    local class = ent:GetClass()
    local criticalClasses = {
        "ship_core",
        "hyperdrive_engine",
        "hyperdrive_master_engine",
        "hyperdrive_computer",
        "hyperdrive_shield_generator"
    }

    for _, criticalClass in ipairs(criticalClasses) do
        if class == criticalClass then
            return true
        end
    end

    return false
end

-- Apply damage to hull
function HullDamageClass:ApplyDamage(damage, damageType, attacker, hitPos)
    if not HYPERDRIVE.HullDamage.Config.EnableHullDamage then return end
    if damage <= 0 then return end

    -- Calculate actual hull damage
    local hullDamage = damage * (1 - HYPERDRIVE.HullDamage.Config.DamageToShieldsRatio)

    -- Apply damage to overall hull integrity
    self.integrity = math.max(0, self.integrity - hullDamage)
    self.totalDamageReceived = self.totalDamageReceived + hullDamage
    self.lastDamageTime = CurTime()

    -- Apply damage to specific sections
    self:ApplySectionDamage(hullDamage, damageType, hitPos)

    -- Check for hull breaches
    self:CheckForHullBreaches(hullDamage, hitPos)

    -- Check for system failures
    self:CheckForSystemFailures(hullDamage, damageType)

    -- Update hull status
    self:UpdateHullStatus()

    -- Log damage
    self:LogDamage(damage, hullDamage, damageType, attacker)

    -- Trigger damage effects
    if HYPERDRIVE.HullDamage.Config.DamageEffectsEnabled then
        self:TriggerDamageEffects(hullDamage, hitPos)
    end

    print("[Hyperdrive Hull] Applied " .. string.format("%.1f", hullDamage) .. " hull damage, integrity: " .. string.format("%.1f", self.integrity) .. "%")
end

-- Apply damage to specific ship sections
function HullDamageClass:ApplySectionDamage(damage, damageType, hitPos)
    if not hitPos or not self.ship or not self.ship.GetEntities then return end

    local entities = self.ship:GetEntities()
    local closestEnt = nil
    local closestDist = math.huge

    -- Find closest entity to hit position
    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            local dist = hitPos:Distance(ent:GetPos())
            if dist < closestDist then
                closestDist = dist
                closestEnt = ent
            end
        end
    end

    if closestEnt and self.damagedSections[closestEnt:EntIndex()] then
        local section = self.damagedSections[closestEnt:EntIndex()]
        local sectionDamage = damage * 0.5 -- 50% of damage goes to specific section

        section.integrity = math.max(0, section.integrity - sectionDamage)
        section.damageType = damageType
        section.lastDamage = CurTime()

        -- Increase repair priority for damaged sections
        if section.integrity < 50 then
            section.repairPriority = 3
        elseif section.integrity < 75 then
            section.repairPriority = 2
        end

        print("[Hyperdrive Hull] Section damage: " .. closestEnt:GetClass() .. " integrity: " .. string.format("%.1f", section.integrity) .. "%")
    end
end

-- Check for hull breaches
function HullDamageClass:CheckForHullBreaches(damage, hitPos)
    if damage < 10 then return end -- Only significant damage can cause breaches

    local breachChance = HYPERDRIVE.HullDamage.Config.HullBreachChance * (damage / 50)
    if math.random() < breachChance then
        self:CreateHullBreach(hitPos)
    end
end

-- Create hull breach
function HullDamageClass:CreateHullBreach(pos)
    local breach = {
        position = pos,
        severity = math.random(1, 3),
        created = CurTime(),
        repaired = false,
        effects = {}
    }

    table.insert(self.breaches, breach)

    -- Create breach effects
    if HYPERDRIVE.HullDamage.Config.DamageEffectsEnabled then
        self:CreateBreachEffects(breach)
    end

    print("[Hyperdrive Hull] Hull breach created at " .. tostring(pos) .. " severity: " .. breach.severity)

    -- Trigger hull breach alert
    self:TriggerCriticalAlert("Hull breach detected! Severity: " .. breach.severity)
end

-- Check for system failures
function HullDamageClass:CheckForSystemFailures(damage, damageType)
    if self.integrity > HYPERDRIVE.HullDamage.Config.CriticalHullThreshold then return end

    local failureChance = HYPERDRIVE.HullDamage.Config.SystemFailureChance * (1 - (self.integrity / 100))
    if math.random() < failureChance then
        self:TriggerSystemFailure(damageType)
    end
end

-- Trigger system failure
function HullDamageClass:TriggerSystemFailure(damageType)
    local systems = {"hyperdrive", "shields", "navigation", "life_support", "power"}
    local failedSystem = systems[math.random(1, #systems)]

    local failure = {
        system = failedSystem,
        severity = math.random(1, 3),
        created = CurTime(),
        repaired = false,
        cause = damageType
    }

    table.insert(self.systemFailures, failure)

    print("[Hyperdrive Hull] System failure: " .. failedSystem .. " severity: " .. failure.severity)

    -- Apply system failure effects
    self:ApplySystemFailureEffects(failure)

    -- Trigger system failure alert
    self:TriggerCriticalAlert("System failure: " .. failedSystem .. " (Severity: " .. failure.severity .. ")")
end

-- Apply system failure effects
function HullDamageClass:ApplySystemFailureEffects(failure)
    if failure.system == "hyperdrive" then
        -- Disable hyperdrive operations
        if self.ship and self.ship.engines then
            for _, engine in ipairs(self.ship.engines) do
                if IsValid(engine) and engine.SetDisabled then
                    engine:SetDisabled(true)
                end
            end
        end
    elseif failure.system == "shields" then
        -- Disable shields
        if HYPERDRIVE.Shields and HYPERDRIVE.Shields.DeactivateShield then
            HYPERDRIVE.Shields.DeactivateShield(self.core)
        end
    end
end

-- Update hull status
function HullDamageClass:UpdateHullStatus()
    -- Check for critical hull damage
    if self.integrity <= HYPERDRIVE.HullDamage.Config.CriticalHullThreshold then
        if not self.criticalMode then
            self.criticalMode = true
            self:TriggerCriticalAlert("Critical hull damage! Integrity: " .. string.format("%.1f", self.integrity) .. "%")
        end
    end

    -- Check for emergency hull damage
    if self.integrity <= HYPERDRIVE.HullDamage.Config.EmergencyHullThreshold then
        if not self.emergencyMode then
            self.emergencyMode = true
            self:TriggerCriticalAlert("EMERGENCY: Hull integrity critical! Immediate repair required!")

            -- Emergency systems activation
            self:ActivateEmergencySystems()
        end
    end
end

-- Start auto-repair system
function HullDamageClass:StartAutoRepair()
    if self.autoRepairActive then return end

    self.autoRepairActive = true

    timer.Create("HullAutoRepair_" .. self.core:EntIndex(), 1, 0, function()
        if not IsValid(self.core) or not self.ship then
            timer.Remove("HullAutoRepair_" .. self.core:EntIndex())
            return
        end

        self:ProcessAutoRepair()
    end)

    print("[Hyperdrive Hull] Auto-repair system activated")
end

-- Process auto-repair
function HullDamageClass:ProcessAutoRepair()
    if not HYPERDRIVE.HullDamage.Config.AutoRepairEnabled then return end
    if CurTime() - self.lastDamageTime < HYPERDRIVE.HullDamage.Config.AutoRepairDelay then return end

    local repairAmount = HYPERDRIVE.HullDamage.Config.HullRepairRate

    -- Repair overall hull integrity
    if self.integrity < self.maxIntegrity then
        self.integrity = math.min(self.maxIntegrity, self.integrity + repairAmount)
        self.repairProgress = self.repairProgress + repairAmount

        print("[Hyperdrive Hull] Auto-repair progress: " .. string.format("%.1f", self.integrity) .. "%")
    end

    -- Repair damaged sections
    self:RepairDamagedSections(repairAmount)

    -- Repair hull breaches
    self:RepairHullBreaches()

    -- Repair system failures
    self:RepairSystemFailures()

    -- Update status
    if self.integrity > HYPERDRIVE.HullDamage.Config.CriticalHullThreshold then
        self.criticalMode = false
        self.emergencyMode = false
    end
end

-- Get hull damage status
function HullDamageClass:GetStatus()
    return {
        integrity = self.integrity,
        maxIntegrity = self.maxIntegrity,
        integrityPercent = (self.integrity / self.maxIntegrity) * 100,
        criticalMode = self.criticalMode or false,
        emergencyMode = self.emergencyMode or false,
        breaches = #self.breaches,
        systemFailures = #self.systemFailures,
        autoRepairActive = self.autoRepairActive,
        repairProgress = self.repairProgress,
        totalDamageReceived = self.totalDamageReceived,
        lastDamageTime = self.lastDamageTime,
        damagedSections = table.Count(self.damagedSections)
    }
end

-- Main hull damage system functions
function HYPERDRIVE.HullDamage.CreateHullSystem(ship, core)
    if not IsValid(core) or not ship then
        return nil, "Invalid ship or core"
    end

    -- Check if hull system already exists
    local hullId = "hull_" .. core:EntIndex()
    if HYPERDRIVE.HullDamage.Ships[hullId] then
        return HYPERDRIVE.HullDamage.Ships[hullId], "Hull system already exists"
    end

    -- Create new hull system
    local hull = HullDamageClass:New(ship, core)
    if hull:Initialize() then
        return hull, "Hull damage system created successfully"
    else
        return nil, "Failed to initialize hull damage system"
    end
end

-- Get hull system for ship
function HYPERDRIVE.HullDamage.GetHullSystem(core)
    if not IsValid(core) then return nil end

    local hullId = "hull_" .. core:EntIndex()
    return HYPERDRIVE.HullDamage.Ships[hullId]
end

-- Apply damage to ship hull
function HYPERDRIVE.HullDamage.ApplyDamage(core, damage, damageType, attacker, hitPos)
    local hull = HYPERDRIVE.HullDamage.GetHullSystem(core)
    if not hull then return false end

    hull:ApplyDamage(damage, damageType or "generic", attacker, hitPos)
    return true
end

-- Get hull status
function HYPERDRIVE.HullDamage.GetHullStatus(core)
    local hull = HYPERDRIVE.HullDamage.GetHullSystem(core)
    if not hull then return nil end

    return hull:GetStatus()
end

-- Repair damaged sections
function HullDamageClass:RepairDamagedSections(repairAmount)
    for entIndex, section in pairs(self.damagedSections) do
        if section.integrity < section.maxIntegrity then
            local sectionRepair = repairAmount * section.repairPriority
            section.integrity = math.min(section.maxIntegrity, section.integrity + sectionRepair)

            if section.integrity >= section.maxIntegrity then
                section.repairPriority = 1
                section.damageType = "none"
            end
        end
    end
end

-- Repair hull breaches
function HullDamageClass:RepairHullBreaches()
    for i = #self.breaches, 1, -1 do
        local breach = self.breaches[i]
        if not breach.repaired and CurTime() - breach.created > 60 then -- Auto-repair after 60 seconds
            breach.repaired = true
            table.remove(self.breaches, i)
            print("[Hyperdrive Hull] Hull breach repaired")
        end
    end
end

-- Repair system failures
function HullDamageClass:RepairSystemFailures()
    for i = #self.systemFailures, 1, -1 do
        local failure = self.systemFailures[i]
        if not failure.repaired and CurTime() - failure.created > 120 then -- Auto-repair after 2 minutes
            failure.repaired = true
            self:RestoreSystemFunction(failure)
            table.remove(self.systemFailures, i)
            print("[Hyperdrive Hull] System failure repaired: " .. failure.system)
        end
    end
end

-- Restore system function after repair
function HullDamageClass:RestoreSystemFunction(failure)
    if failure.system == "hyperdrive" then
        -- Re-enable hyperdrive operations
        if self.ship and self.ship.engines then
            for _, engine in ipairs(self.ship.engines) do
                if IsValid(engine) and engine.SetDisabled then
                    engine:SetDisabled(false)
                end
            end
        end
    elseif failure.system == "shields" then
        -- Re-enable shields
        if HYPERDRIVE.Shields and HYPERDRIVE.Shields.ActivateShield then
            HYPERDRIVE.Shields.ActivateShield(self.core, self.ship)
        end
    end
end

-- Trigger critical alert
function HullDamageClass:TriggerCriticalAlert(message)
    table.insert(self.criticalAlerts, {
        message = message,
        time = CurTime(),
        acknowledged = false
    })

    print("[Hyperdrive Hull] CRITICAL ALERT: " .. message)

    -- Trigger hook for other systems
    hook.Run("HyperdriveHullCriticalAlert", self.core, self.ship, message)
end

-- Activate emergency systems
function HullDamageClass:ActivateEmergencySystems()
    print("[Hyperdrive Hull] Emergency systems activated")

    -- Emergency shield activation
    if HYPERDRIVE.Shields and HYPERDRIVE.Shields.ActivateShield then
        HYPERDRIVE.Shields.ActivateShield(self.core, self.ship)
    end

    -- Emergency power rerouting
    self:ReroutePower()

    -- Trigger emergency hook
    hook.Run("HyperdriveHullEmergency", self.core, self.ship, self.integrity)
end

-- Reroute power for emergency systems
function HullDamageClass:ReroutePower()
    -- Disable non-essential systems to preserve power for critical functions
    print("[Hyperdrive Hull] Power rerouted to critical systems")
end

-- Create breach effects
function HullDamageClass:CreateBreachEffects(breach)
    if not IsValid(self.core) then return end

    -- Create visual effects for hull breach
    local effectData = EffectData()
    effectData:SetOrigin(breach.position)
    effectData:SetMagnitude(breach.severity)
    util.Effect("hyperdrive_hull_breach", effectData)

    -- Create sound effects
    self.core:EmitSound("ambient/levels/labs/electric_explosion" .. math.random(1, 4) .. ".wav", 75, 100)
end

-- Trigger damage effects
function HullDamageClass:TriggerDamageEffects(damage, hitPos)
    if not IsValid(self.core) or not hitPos then return end

    -- Create damage effects based on damage amount
    local effectData = EffectData()
    effectData:SetOrigin(hitPos)
    effectData:SetMagnitude(damage)
    util.Effect("hyperdrive_hull_damage", effectData)

    -- Create impact sound
    self.core:EmitSound("physics/metal/metal_box_impact_hard" .. math.random(1, 3) .. ".wav", 70, math.random(90, 110))
end

-- Log damage for analysis
function HullDamageClass:LogDamage(originalDamage, hullDamage, damageType, attacker)
    local logEntry = {
        time = CurTime(),
        originalDamage = originalDamage,
        hullDamage = hullDamage,
        damageType = damageType,
        attacker = IsValid(attacker) and attacker:GetClass() or "unknown",
        integrityAfter = self.integrity
    }

    if not HYPERDRIVE.HullDamage.DamageHistory[self.core:EntIndex()] then
        HYPERDRIVE.HullDamage.DamageHistory[self.core:EntIndex()] = {}
    end

    table.insert(HYPERDRIVE.HullDamage.DamageHistory[self.core:EntIndex()], logEntry)

    -- Keep only last 50 damage entries
    local history = HYPERDRIVE.HullDamage.DamageHistory[self.core:EntIndex()]
    if #history > 50 then
        table.remove(history, 1)
    end
end

-- Initialize wire integration
function HullDamageClass:InitializeWireIntegration()
    if not self.core.Inputs then return end

    -- Add hull damage wire outputs
    local outputs = {
        "HullIntegrity",
        "HullIntegrityPercent",
        "HullCriticalMode",
        "HullEmergencyMode",
        "HullBreaches",
        "HullSystemFailures",
        "HullAutoRepairActive",
        "HullRepairProgress",
        "HullTotalDamage",
        "HullDamagedSections"
    }

    for _, output in ipairs(outputs) do
        if not self.core.Outputs[output] then
            self.core.Outputs[output] = 0
        end
    end
end

-- Update wire outputs
function HullDamageClass:UpdateWireOutputs()
    if not self.core.Outputs or not HYPERDRIVE.HullDamage.Config.HullDamageWireIntegration then return end

    local status = self:GetStatus()

    self.core.Outputs["HullIntegrity"] = status.integrity
    self.core.Outputs["HullIntegrityPercent"] = status.integrityPercent
    self.core.Outputs["HullCriticalMode"] = status.criticalMode and 1 or 0
    self.core.Outputs["HullEmergencyMode"] = status.emergencyMode and 1 or 0
    self.core.Outputs["HullBreaches"] = status.breaches
    self.core.Outputs["HullSystemFailures"] = status.systemFailures
    self.core.Outputs["HullAutoRepairActive"] = status.autoRepairActive and 1 or 0
    self.core.Outputs["HullRepairProgress"] = status.repairProgress
    self.core.Outputs["HullTotalDamage"] = status.totalDamageReceived
    self.core.Outputs["HullDamagedSections"] = status.damagedSections

    -- Trigger wire outputs
    if self.core.TriggerOutput then
        for output, _ in pairs(self.core.Outputs) do
            if string.StartWith(output, "Hull") then
                self.core:TriggerOutput(output, self.core.Outputs[output])
            end
        end
    end
end

-- Manual repair function
function HYPERDRIVE.HullDamage.RepairHull(core, repairAmount)
    local hull = HYPERDRIVE.HullDamage.GetHullSystem(core)
    if not hull then return false end

    repairAmount = repairAmount or 10
    hull.integrity = math.min(hull.maxIntegrity, hull.integrity + repairAmount)
    hull.repairProgress = hull.repairProgress + repairAmount

    print("[Hyperdrive Hull] Manual repair applied: +" .. repairAmount .. " integrity")
    return true
end

-- Get damage history
function HYPERDRIVE.HullDamage.GetDamageHistory(core)
    if not IsValid(core) then return {} end
    return HYPERDRIVE.HullDamage.DamageHistory[core:EntIndex()] or {}
end

-- Clear damage history
function HYPERDRIVE.HullDamage.ClearDamageHistory(core)
    if not IsValid(core) then return false end
    HYPERDRIVE.HullDamage.DamageHistory[core:EntIndex()] = {}
    return true
end

-- Console commands for hull damage management
if SERVER then
    -- Hull damage status command
    concommand.Add("hyperdrive_hull_status", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core or hyperdrive engine to check hull status")
            return
        end

        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship or not ship.core then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        local hull = HYPERDRIVE.HullDamage.GetHullSystem(ship.core)
        if not hull then
            ply:ChatPrint("No hull damage system found for this ship")
            return
        end

        local status = hull:GetStatus()
        ply:ChatPrint("Hull Status for " .. ship.shipType .. ":")
        ply:ChatPrint("Integrity: " .. string.format("%.1f", status.integrityPercent) .. "%")
        ply:ChatPrint("Breaches: " .. status.breaches)
        ply:ChatPrint("System Failures: " .. status.systemFailures)
        ply:ChatPrint("Auto-Repair: " .. (status.autoRepairActive and "Active" or "Inactive"))
    end)

    -- Hull repair command
    concommand.Add("hyperdrive_repair_hull", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core or hyperdrive engine to repair hull")
            return
        end

        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship or not ship.core then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        local repairAmount = tonumber(args[1]) or 25
        local success = HYPERDRIVE.HullDamage.RepairHull(ship.core, repairAmount)

        if success then
            ply:ChatPrint("Hull repaired by " .. repairAmount .. " points")
        else
            ply:ChatPrint("Failed to repair hull")
        end
    end)

    -- Hull damage command (admin only)
    concommand.Add("hyperdrive_damage_hull", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then
            ply:ChatPrint("Only admins can use this command")
            return
        end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            if IsValid(ply) then
                ply:ChatPrint("Look at a ship core or hyperdrive engine to damage hull")
            end
            return
        end

        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship or not ship.core then
            if IsValid(ply) then
                ply:ChatPrint("No ship detected for this entity")
            end
            return
        end

        local damage = tonumber(args[1]) or 10
        local damageType = args[2] or "admin"
        local success = HYPERDRIVE.HullDamage.ApplyDamage(ship.core, damage, damageType, ply, trace.Entity:GetPos())

        if success then
            local message = "Applied " .. damage .. " hull damage"
            if IsValid(ply) then
                ply:ChatPrint(message)
            else
                print(message)
            end
        else
            local message = "Failed to apply hull damage"
            if IsValid(ply) then
                ply:ChatPrint(message)
            else
                print(message)
            end
        end
    end)

    -- Hull damage history command
    concommand.Add("hyperdrive_hull_history", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core or hyperdrive engine to view hull damage history")
            return
        end

        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship or not ship.core then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        local history = HYPERDRIVE.HullDamage.GetDamageHistory(ship.core)
        if #history == 0 then
            ply:ChatPrint("No damage history for this ship")
            return
        end

        ply:ChatPrint("Hull Damage History (last " .. math.min(#history, 10) .. " entries):")
        for i = math.max(1, #history - 9), #history do
            local entry = history[i]
            local timeStr = string.format("%.1f", CurTime() - entry.time) .. "s ago"
            local damageStr = string.format("%.1f", entry.hullDamage) .. " damage"
            ply:ChatPrint(timeStr .. ": " .. damageStr .. " from " .. entry.attacker)
        end
    end)

    -- Ship core UI command
    concommand.Add("hyperdrive_ship_core_ui", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core, hyperdrive engine, or computer to open ship core UI")
            return
        end

        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship or not ship.core then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        if not IsValid(ship.core) then
            ply:ChatPrint("Ship core not found or invalid")
            return
        end

        ship.core:OpenUI(ply)
        ply:ChatPrint("Opening ship core management interface...")
    end)

    -- Ship core info command
    concommand.Add("hyperdrive_ship_core_info", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a ship core, hyperdrive engine, or computer to get ship info")
            return
        end

        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship or not ship.core then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        ply:ChatPrint("Ship Core Information:")
        ply:ChatPrint("  Ship Type: " .. ship:GetShipType())
        ply:ChatPrint("  Entities: " .. #ship:GetEntities())
        ply:ChatPrint("  Players: " .. #ship:GetPlayers())
        ply:ChatPrint("  Mass: " .. math.floor(ship:GetMass()))
        ply:ChatPrint("  Core Position: " .. tostring(ship.core:GetPos()))

        if HYPERDRIVE.HullDamage then
            local hullStatus = HYPERDRIVE.HullDamage.GetHullStatus(ship.core)
            if hullStatus then
                ply:ChatPrint("  Hull Integrity: " .. string.format("%.1f", hullStatus.integrityPercent) .. "%")
                ply:ChatPrint("  Hull Breaches: " .. (hullStatus.breaches or 0))
                ply:ChatPrint("  System Failures: " .. (hullStatus.systemFailures or 0))
            end
        end

        if HYPERDRIVE.Shields then
            local shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(ship.core)
            if shieldStatus and shieldStatus.available then
                ply:ChatPrint("  Shield Status: " .. (shieldStatus.active and "Active" or "Inactive"))
                ply:ChatPrint("  Shield Strength: " .. string.format("%.1f", shieldStatus.strengthPercent or 0) .. "%")
            end
        end
    end)
end

-- Initialize hull damage system
if SERVER then
    print("[Hyperdrive] Hull Damage system loaded with auto-repair, breach detection, wire integration, and console commands")

    -- Hook into entity damage
    hook.Add("EntityTakeDamage", "HyperdriveHullDamage", function(ent, dmginfo)
        if not IsValid(ent) then return end

        -- Check if entity is part of a ship with hull damage system
        if HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity then
            local ship = HYPERDRIVE.ShipCore.GetShipByEntity(ent)
            if ship and ship.core and IsValid(ship.core) then
                local hull = HYPERDRIVE.HullDamage.GetHullSystem(ship.core)
                if hull then
                    local damage = dmginfo:GetDamage()
                    local damageType = dmginfo:GetDamageType()
                    local attacker = dmginfo:GetAttacker()
                    local hitPos = dmginfo:GetDamagePosition()

                    hull:ApplyDamage(damage, damageType, attacker, hitPos)
                    hull:UpdateWireOutputs()
                end
            end
        end
    end)

    -- Update timer for hull systems
    timer.Create("HyperdriveHullUpdate", 5, 0, function()
        for hullId, hull in pairs(HYPERDRIVE.HullDamage.Ships) do
            if IsValid(hull.core) and hull.ship then
                hull:UpdateWireOutputs()
            else
                HYPERDRIVE.HullDamage.Ships[hullId] = nil
            end
        end
    end)
end
