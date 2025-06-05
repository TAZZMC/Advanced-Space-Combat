-- ASC Ship Core Entity - Server v5.0.0 - Enhanced Stargate Hyperspace Edition
-- ENHANCED STARGATE HYPERSPACE UPDATE v5.0.0 - 4-STAGE TRAVEL SYSTEM INTEGRATION
-- Mandatory ship core for Advanced Space Combat with enhanced Stargate hyperspace features
-- Advanced ship core with ARIA-4 AI integration, 4-stage hyperspace support, and complete unification

print("[ASC Ship Core] ENHANCED STARGATE HYPERSPACE UPDATE v5.0.0 - ASC Ship Core Entity being updated")
print("[ASC Ship Core] Enhanced ASC ship core v5.0.0 with 4-stage Stargate hyperspace and ARIA-4 AI initializing...")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Safe function call wrapper to prevent errors from missing functions
local function SafeCall(func, ...)
    if func and type(func) == "function" then
        local success, result = pcall(func, ...)
        if success then
            return result
        else
            print("[ASC Ship Core] Safe call failed: " .. tostring(result))
            return nil
        end
    end
    return nil
end

-- Safe table access wrapper
local function SafeAccess(table, ...)
    local current = table
    local keys = {...}

    for _, key in ipairs(keys) do
        if current and type(current) == "table" and current[key] then
            current = current[key]
        else
            return nil
        end
    end

    return current
end

-- Network strings for UI
util.AddNetworkString("asc_ship_core_open_ui")
util.AddNetworkString("asc_ship_core_update_ui")
util.AddNetworkString("asc_ship_core_command")
util.AddNetworkString("asc_ship_core_open_ui")
util.AddNetworkString("asc_ship_core_close_ui")
util.AddNetworkString("asc_ship_core_update_ui")
util.AddNetworkString("asc_ship_core_name_dialog")
util.AddNetworkString("asc_ship_core_model_selection")
util.AddNetworkString("asc_ship_core_model_change")
util.AddNetworkString("hyperdrive_play_sound")

function ENT:Initialize()
    -- Initialize model selection system with CAP assets
    self.availableModels = self:GetCAPModels()

    -- Set default model (first in list)
    self.selectedModelIndex = 1
    self:ApplySelectedModel()

    -- Load saved model preference
    timer.Simple(0.1, function()
        if IsValid(self) then
            self:LoadModelPreference()
        end
    end)

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(50)
        phys:EnableMotion(true) -- Ensure physics object can be moved/welded
    end

    -- Enable welding and constraints
    self:SetNWBool("CanBeWelded", true)
    self:SetNWBool("AllowConstraints", true)

    -- Auto-weld system removed for performance and simplicity

    -- Set up for tool interactions
    self.CanTool = function(self, ply, trace, mode)
        -- Allow welding and other constraint tools
        if mode == "weld" or mode == "rope" or mode == "axis" or mode == "ballsocket" or mode == "slider" or mode == "hydraulic" then
            return true
        end
        -- Allow other ASC tools
        if string.find(mode, "asc_") then
            return true
        end
        return false
    end

    -- Initialize ship core data
    self.ship = nil
    self.lastUpdate = 0
    self.updateInterval = 2 -- Update every 2 seconds
    self.activeUIs = {} -- Track active UI sessions
    self.shipNameFile = "hyperdrive/ship_names_" .. self:EntIndex() .. ".txt"

    -- Ambient sound system removed per user request

    -- Track spawn time for initialization delay
    self.SpawnTime = CurTime()
    self.InitializationComplete = false

    -- Load ship name from file
    self:LoadShipName()

    -- Initialize systems with longer delay to prevent spawn lag
    timer.Simple(3, function()
        if IsValid(self) then
            self:InitializeSystems()
        end
    end)

    -- Initialize modern UI integration
    self.UIData = {
        lastUpdate = 0,
        updateInterval = 0.5,
        notifications = {},
        theme = "modern",
        activeTab = "overview",
        animationState = {},
        fadeAlpha = 255,
        targetAlpha = 255
    }

    -- v2.2.0 Real-Time Features
    self.FleetID = 0
    self.FleetRole = ""
    self.RealTimeMonitoring = true
    self.LastRealTimeUpdate = 0
    self.RealTimeUpdateRate = 2.0 -- Reduced: 0.5 FPS for real-time updates (was 20 FPS)
    self.PerformanceMetrics = {}
    self.SystemAlerts = {}
    self.AlertCooldowns = {} -- Track cooldowns for different alert types
    self.AlertHistory = {} -- Track alert history to prevent spam
    self.AdminAccess = false

    -- Optimized update system with reduced frequencies to prevent spawn lag
    self.LastEntityScan = 0
    self.EntityScanRate = 2.0 -- Reduced: 0.5 FPS for entity scanning (was 10 FPS)
    self.LastResourceUpdate = 0
    self.ResourceUpdateRate = 1.0 -- Reduced: 1 FPS for resource calculations (was 5 FPS)
    self.LastSystemCheck = 0
    self.SystemCheckRate = 3.0 -- Reduced: 0.33 FPS for system health checks (was 2 FPS)
    self.LastNetworkUpdate = 0
    self.NetworkUpdateRate = 1.0 -- Reduced: 1 FPS for network synchronization (was 10 FPS)

    -- Smart update tracking
    self.UpdatePriorities = {
        entity_scan = 1,     -- High priority
        resource_update = 2, -- Medium priority
        system_check = 3,    -- Low priority
        network_sync = 1     -- High priority
    }

    -- Performance optimization settings
    self.PerformanceMode = false
    self.LastPerformanceCheck = 0
    self.PerformanceCheckInterval = 5.0 -- Check every 5 seconds
    self.FrameTimeHistory = {}
    self.MaxFrameHistory = 30

    -- Adaptive update rates based on activity
    self.AdaptiveRates = {
        entity_scan = {min = 0.05, max = 1.0, current = 0.1},
        resource_update = {min = 0.1, max = 2.0, current = 0.2},
        system_check = {min = 0.25, max = 5.0, current = 0.5},
        network_sync = {min = 0.05, max = 0.5, current = 0.1}
    }

    -- Change detection for smart updates
    self.LastEntityCount = 0
    self.LastResourceState = {}
    self.LastSystemState = {}
    self.ChangeDetectionEnabled = true

    -- Performance tracking
    self.UpdatePerformance = {
        entity_scan = {total_time = 0, call_count = 0, avg_time = 0},
        resource_update = {total_time = 0, call_count = 0, avg_time = 0},
        system_check = {total_time = 0, call_count = 0, avg_time = 0},
        network_sync = {total_time = 0, call_count = 0, avg_time = 0}
    }

    -- Real-time data caches
    self.CachedAttachedEntities = {}
    self.CachedResourceData = {}
    self.CachedSystemStatus = {}
    self.CachedPerformanceData = {}

    -- Initialize v2.2.0 systems with delay to prevent spawn lag
    timer.Simple(5, function()
        if IsValid(self) then
            self:InitializeFleetManagement()
            self:InitializeRealTimeMonitoring()
            self:InitializePerformanceAnalytics()
            self:StartRealTimeUpdates()
        end
    end)

    print("[ASC Ship Core] Enhanced ASC Ship Core v5.1.0 with Stargate hyperspace integration and advanced features initialized at " .. tostring(self:GetPos()))
end

-- Ambient Sound System Functions - REMOVED per user request

function ENT:OnRemove()
    -- Clean up resource system (SB3Resources cleanup is handled automatically by hook)
    if HYPERDRIVE.SB3Resources and HYPERDRIVE.SB3Resources.CoreStorage then
        local coreId = self:EntIndex()
        HYPERDRIVE.SB3Resources.CoreStorage[coreId] = nil
    end

    -- Clean up basic resource timer
    local timerName = "ASC_BasicResourceRegen_" .. self:EntIndex()
    if timer.Exists(timerName) then
        timer.Remove(timerName)
    end

    -- Remove life support from players
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetNWEntity("LifeSupportCore") == self then
            ply:SetNWBool("HasLifeSupport", false)
            ply:SetNWEntity("LifeSupportCore", NULL)
        end
    end

    -- Clean up ship core from ship system
    if HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.Ships then
        local coreId = self:EntIndex()
        HYPERDRIVE.ShipCore.Ships[coreId] = nil
    end

    -- Clean up optimization system resources
    if ASC and ASC.ShipCore and ASC.ShipCore.Optimization then
        local coreId = self:EntIndex()

        -- Clean up incremental detection queue
        if ASC.ShipCore.Optimization.IncrementalDetection.queues[coreId] then
            ASC.ShipCore.Optimization.IncrementalDetection.queues[coreId] = nil
        end

        -- Clean up relationship mapping
        ASC.ShipCore.Optimization.RelationshipMap.dirtyEntities[coreId] = nil
        ASC.ShipCore.Optimization.RelationshipMap.constraints[coreId] = nil
        ASC.ShipCore.Optimization.RelationshipMap.parents[coreId] = nil
        ASC.ShipCore.Optimization.RelationshipMap.children[coreId] = nil

        -- Clean up constraint cache
        local cache = ASC.ShipCore.Optimization.ConstraintCache
        cache.cache[coreId] = nil
        cache.timestamps[coreId] = nil
        cache.accessCount[coreId] = nil

        -- Remove from spatial grid
        local grid = ASC.ShipCore.Optimization.SpatialGrid
        local cellKey = grid.entityToCell[coreId]
        if cellKey and grid.cells[cellKey] then
            for i, ent in ipairs(grid.cells[cellKey]) do
                if ent == self then
                    table.remove(grid.cells[cellKey], i)
                    break
                end
            end
        end
        grid.entityToCell[coreId] = nil
    end

    -- Clean up other resources
    if self.ship then
        print("[ASC Ship Core] ASC ship core removed, cleaning up ship data")
    end

    print("[ASC Ship Core] Resource cleanup completed")
end

function ENT:EmergencyResourceShutdown()
    -- Emergency shutdown of all resource systems
    if HYPERDRIVE.SB3Resources then
        local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
        if storage then
            storage.emergencyMode = true
            storage.lifeSupportActive = false
            print("[ASC Ship Core] Emergency resource shutdown activated")
        end
    elseif self.BasicResourceStorage then
        -- Stop basic resource regeneration
        local timerName = "ASC_BasicResourceRegen_" .. self:EntIndex()
        if timer.Exists(timerName) then
            timer.Remove(timerName)
        end

        self:SetNWBool("ResourceEmergency", true)
        self:SetNWBool("LifeSupportActive", false)
        print("[ASC Ship Core] Emergency shutdown - basic resource system halted")
    end

    -- Notify players
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:GetNWEntity("LifeSupportCore") == self then
            ply:ChatPrint("⚠️ EMERGENCY: Ship core resource systems have been shut down!")
            ply:SetNWBool("HasLifeSupport", false)
        end
    end
end

function ENT:InitializeSystems()
    -- Detect ship
    self:UpdateShipDetection()

    -- Initialize resource system first (required for other systems)
    if HYPERDRIVE.SB3Resources then
        local success = HYPERDRIVE.SB3Resources.InitializeCoreStorage(self)
        if success then
            self:SetNWBool("ResourceSystemActive", true)
            self:SetNWBool("AutoProvisionEnabled", true)
            self:SetNWBool("WeldDetectionEnabled", true)
            self:SetNWString("LastResourceActivity", "System initialized")
            print("[ASC Ship Core] Resource system initialized")
        else
            -- Try to initialize without Spacebuild 3 integration
            print("[ASC Ship Core] Spacebuild 3 not available, initializing basic resource system")
            self:InitializeBasicResourceSystem()
        end
    else
        print("[ASC Ship Core] SB3Resources not available, initializing basic resource system")
        self:InitializeBasicResourceSystem()
    end

    -- Initialize hull damage system
    if HYPERDRIVE.HullDamage and self.ship then
        local createFunc = SafeAccess(HYPERDRIVE.HullDamage, "CreateHullSystem")
        if createFunc then
            local hull, message = SafeCall(createFunc, self.ship, self)
            if hull then
                self:SetHullSystemActive(true)
                print("[ASC Ship Core] Hull damage system initialized: " .. (message or "Success"))
            else
                print("[ASC Ship Core] Hull damage system failed: " .. (message or "Unknown error"))
            end
        else
            print("[ASC Ship Core] Hull damage CreateHullSystem function not available")
        end
    end

    -- Initialize built-in shield system (no generators needed) - delayed to prevent spawn lag
    if ASC and ASC.Shields and ASC.Shields.Core and ASC.Shields.Core.Initialize then
        timer.Simple(8, function()
            if IsValid(self) then
                local success, message = ASC.Shields.Core.Initialize(self, "ADVANCED")
                if success then
                    self:SetShieldSystemActive(true)
                    print("[ASC Ship Core] Built-in shield system initialized: " .. (message or "Success"))
                else
                    print("[ASC Ship Core] Built-in shield system failed: " .. (message or "Unknown error"))
                end
            end
        end)
    elseif HYPERDRIVE.Shields and self.ship then
        -- Fallback to old shield system
        local createFunc = SafeAccess(HYPERDRIVE.Shields, "CreateShield")
        if createFunc then
            local shield, message = SafeCall(createFunc, self, self.ship)
            if shield then
                self:SetShieldSystemActive(true)
                print("[ASC Ship Core] Legacy shield system initialized: " .. (message or "Success"))
            else
                print("[ASC Ship Core] Legacy shield system failed: " .. (message or "Unknown error"))
            end
        else
            print("[ASC Ship Core] Shield CreateShield function not available")
        end
    end

    -- Initialize flight system - delayed to prevent spawn lag
    if ASC and ASC.Flight and ASC.Flight.Core and ASC.Flight.Core.Initialize then
        timer.Simple(10, function()
            if IsValid(self) then
                local success, message = ASC.Flight.Core.Initialize(self, "STANDARD")
                if success then
                    self:SetNWBool("FlightSystemActive", true)
                    print("[ASC Ship Core] Flight system initialized: " .. (message or "Success"))
                else
                    print("[ASC Ship Core] Flight system failed: " .. (message or "Unknown error"))
                end
            end
        end)
    end

    -- Initialize CAP integration
    self:InitializeCAPIntegration()

    -- v2.2.1 Initialize new systems
    self:InitializeV221Systems()

    -- Activation effects removed per user request
end

-- v2.2.1 Initialize new systems
function ENT:InitializeV221Systems()
    -- Initialize flight system
    if HYPERDRIVE.Flight and self.ship then
        local flightSystem = HYPERDRIVE.Flight.GetFlightSystem(self)
        if not flightSystem then
            flightSystem = HYPERDRIVE.Flight.CreateFlightSystem(self)
        end

        if flightSystem then
            self.flightSystemInitialized = true
            self:SetNWBool("FlightSystemActive", true)
            print("[ASC Ship Core] Flight system initialized")
        end
    end

    -- Initialize weapon systems with delay to prevent spawn lag
    timer.Simple(15, function()
        if IsValid(self) and HYPERDRIVE.Weapons and self.ship then
            -- Find nearby weapons and link them
            local nearbyWeapons = ents.FindInSphere(self:GetPos(), 2000)
            local weaponCount = 0

            for _, ent in ipairs(nearbyWeapons) do
                if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive_") and ent.weapon then
                    ent.shipCore = self
                    weaponCount = weaponCount + 1
                end
            end

            if weaponCount > 0 then
                self.weaponSystemsInitialized = true
                self:SetNWBool("WeaponSystemsActive", true)
                self:SetNWInt("WeaponCount", weaponCount)
                print("[ASC Ship Core] Weapon systems initialized - " .. weaponCount .. " weapons linked")
            end
        end
    end)

    -- Initialize ammunition system
    if HYPERDRIVE.Ammunition and self.ship then
        local storage = HYPERDRIVE.Ammunition.CreateStorage(self, 10000) -- 10kg capacity
        if storage then
            self.ammunitionSystemInitialized = true
            self:SetNWBool("AmmunitionSystemActive", true)
            print("[ASC Ship Core] Ammunition system initialized")
        end
    end

    -- Initialize tactical AI
    if HYPERDRIVE.TacticalAI and self.ship then
        local ai = HYPERDRIVE.TacticalAI.CreateAI(self, "balanced")
        if ai then
            self.tacticalAIInitialized = true
            self:SetNWBool("TacticalAIActive", true)
            print("[ASC Ship Core] Tactical AI initialized")
        end
    end

    -- Initialize docking system compatibility
    self.dockingSystemInitialized = true
    self:SetNWBool("DockingSystemActive", true)

    -- Initialize welding detection system with delay to prevent spawn lag
    timer.Simple(12, function()
        if IsValid(self) then
            self:InitializeWeldingDetection()
        end
    end)

    -- Auto-weld system removed for performance and simplicity

    print("[ASC Ship Core] v2.2.1 systems initialization complete")
end

-- Initialize CAP integration
function ENT:InitializeCAPIntegration()
    -- CAP integration state
    self.CAPIntegrationActive = false
    self.LastCAPUpdate = 0
    self.CAPUpdateInterval = 2.0
    self.CAPIntegration = {}

    -- Enhanced configuration
    self.Config = self.Config or {}
    self.Config.EnableCAPIntegration = true
    self.Config.PreferCAPSystems = true
    self.Config.AutoCreateCAPShields = false
    self.Config.CAPResourceIntegration = true
    self.Config.CAPEffectsEnabled = true
    self.Config.CAPShieldAutoActivation = true

    -- Initialize CAP status network variables with delay to prevent spawn lag
    timer.Simple(7, function()
        if IsValid(self) then
            self:SetNWBool("CAPIntegrationActive", false)
            self:SetNWBool("CAPShieldsDetected", false)
            self:SetNWBool("CAPEnergyDetected", false)
            self:SetNWBool("CAPResourcesDetected", false)
            self:SetNWString("CAPStatus", "Detecting...")
            self:SetNWFloat("CAPEnergyLevel", 0)
            self:SetNWInt("CAPShieldCount", 0)
            self:SetNWInt("CAPEntityCount", 0)
            self:SetNWString("CAPVersion", "Unknown")
        end
    end)

    if not self.Config.EnableCAPIntegration then
        self:SetNWString("CAPStatus", "CAP Integration Disabled")
        return
    end

    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Available then
        self:SetNWString("CAPStatus", "CAP Not Available")
        return
    end

    self.CAPIntegrationActive = true
    self:SetNWBool("CAPIntegrationActive", true)

    -- Get CAP version info
    local detection = HYPERDRIVE.CAP.Detection
    if detection then
        self:SetNWString("CAPVersion", detection.version or "Unknown")
        self:SetNWString("CAPStatus", "CAP Integration Active - " .. detection.version)
    else
        self:SetNWString("CAPStatus", "CAP Integration Active")
    end

    -- Initialize CAP subsystems
    self.CAPIntegration = {
        shields = {},
        energySources = {},
        resources = {},
        lastShieldUpdate = 0,
        lastEnergyUpdate = 0,
        lastResourceUpdate = 0
    }

    print("[ASC Ship Core] CAP integration initialized for core " .. self:EntIndex())
end

function ENT:Think()
    local currentTime = CurTime()

    -- Skip all updates for configurable time after spawn to prevent lag
    local spawnDelay = GetConVar("asc_spawn_delay"):GetFloat()
    if not self.InitializationComplete and currentTime - (self.SpawnTime or 0) < spawnDelay then
        self:NextThink(currentTime + 0.5)
        return true
    end

    if not self.InitializationComplete then
        self.InitializationComplete = true
        print("[ASC Ship Core] Initialization complete, starting normal operations")
    end

    -- Check for performance mode from ConVar and optimization system
    local performanceMode = GetConVar("asc_performance_mode"):GetBool()

    -- Also check if optimization system suggests performance mode
    if ASC and ASC.ShipCore and ASC.ShipCore.Optimization then
        local fps = 1 / FrameTime()
        if fps < 30 and not performanceMode then
            performanceMode = true
            print("[ASC Ship Core] Auto-enabling performance mode due to low FPS: " .. math.floor(fps))
        end
    end

    if performanceMode and not self.PerformanceMode then
        self:EnablePerformanceMode()
    elseif not performanceMode and self.PerformanceMode then
        self:DisablePerformanceMode()
    end

    -- Batch processing to limit updates per think cycle (reduced for performance)
    local updateCount = 0
    local maxUpdatesPerThink = self.PerformanceMode and 1 or 1 -- Reduced from 2 to 1

    -- Real-time entity scanning (optimized with spatial partitioning)
    if updateCount < maxUpdatesPerThink and currentTime - self.LastEntityScan > self.EntityScanRate then
        self:OptimizedEntityScan()
        self.LastEntityScan = currentTime
        updateCount = updateCount + 1
    end

    -- Real-time resource calculations (reduced frequency)
    if updateCount < maxUpdatesPerThink and currentTime - self.LastResourceUpdate > self.ResourceUpdateRate then
        self:RealTimeResourceUpdate()
        self.LastResourceUpdate = currentTime
        updateCount = updateCount + 1
    end

    -- Real-time system health checks (reduced frequency)
    if updateCount < maxUpdatesPerThink and currentTime - self.LastSystemCheck > self.SystemCheckRate then
        self:RealTimeSystemCheck()
        self.LastSystemCheck = currentTime
        updateCount = updateCount + 1
    end

    -- Real-time network synchronization (reduced frequency)
    if updateCount < maxUpdatesPerThink and currentTime - self.LastNetworkUpdate > self.NetworkUpdateRate then
        self:RealTimeNetworkSync()
        self.LastNetworkUpdate = currentTime
        updateCount = updateCount + 1
    end

    -- Real-time monitoring updates - only if no other updates ran
    if updateCount == 0 and currentTime - self.LastRealTimeUpdate > self.RealTimeUpdateRate then
        self:UpdateRealTimeData()
        self.LastRealTimeUpdate = currentTime
    end

    -- Legacy system updates (slower rate for compatibility)
    if currentTime - self.lastUpdate > self.updateInterval then
        self.lastUpdate = currentTime
        self:UpdateSystems()
        self:UpdateUI()
    end

    -- Adaptive think rate based on performance (increased for better performance)
    local thinkRate = self:GetAdaptiveThinkRate()
    self:NextThink(currentTime + math.max(thinkRate, 0.1)) -- Minimum 0.1 second think rate
    return true
end

function ENT:UpdateSystems()
    -- Update ship detection
    self:UpdateShipDetection()

    -- Update enhanced power management system
    self:UpdatePowerManagement()

    -- Update hull damage system
    self:UpdateHullSystem()

    -- Update shield system with power dependency
    self:UpdateShieldSystem()

    -- Update resource system (Spacebuild 3 integration)
    self:UpdateResourceSystem()

    -- Update CAP integration
    self:UpdateCAPStatus()

    -- v2.2.1 Update new systems
    self:UpdateV221Systems()

    -- Update crew efficiency if players are aboard
    self:UpdateCrewEfficiency()

    -- Update core state
    self:UpdateCoreState()
end

-- v2.2.1 Update new systems
function ENT:UpdateV221Systems()
    if not self.ship then return end

    -- Update flight system status
    if self.flightSystemInitialized and HYPERDRIVE.Flight then
        local flightSystem = HYPERDRIVE.Flight.GetFlightSystem(self)
        if flightSystem then
            local status = flightSystem:GetStatus()
            self:SetNWBool("FlightActive", status.active)
            self:SetNWFloat("FlightSpeed", status.velocity)
            self:SetNWString("FlightMode", status.flightMode)
        end
    end

    -- Update weapon systems status
    if self.weaponSystemsInitialized and HYPERDRIVE.Weapons then
        local weaponCount = 0
        local activeWeapons = 0

        for _, ent in ipairs(ents.FindInSphere(self:GetPos(), 2000)) do
            if IsValid(ent) and string.find(ent:GetClass(), "hyperdrive_") and ent.weapon then
                weaponCount = weaponCount + 1
                if ent.weapon.active then
                    activeWeapons = activeWeapons + 1
                end
            end
        end

        self:SetNWInt("WeaponCount", weaponCount)
        self:SetNWInt("ActiveWeapons", activeWeapons)
    end

    -- Update ammunition system status
    if self.ammunitionSystemInitialized and HYPERDRIVE.Ammunition then
        local storage = HYPERDRIVE.Ammunition.GetStorage(self)
        if storage and storage.ammunition then
            local totalAmmo = 0
            for ammoType, amount in pairs(storage.ammunition) do
                totalAmmo = totalAmmo + amount
            end
            self:SetNWInt("TotalAmmunition", totalAmmo)
            self:SetNWFloat("AmmoCapacity", storage.capacity or 0)
        else
            -- Set defaults if no ammunition storage
            self:SetNWInt("TotalAmmunition", 0)
            self:SetNWFloat("AmmoCapacity", 0)
        end
    end

    -- Update tactical AI status
    if self.tacticalAIInitialized and HYPERDRIVE.TacticalAI then
        local ai = HYPERDRIVE.TacticalAI.GetAI(self)
        if ai then
            local status = ai:GetStatus()
            self:SetNWBool("TacticalAIActive", status.active)
            self:SetNWString("TacticalState", status.tacticalState)
            self:SetNWInt("ThreatCount", status.threatCount)
        end
    end
end

-- Update CAP integration status
function ENT:UpdateCAPStatus()
    if not self.CAPIntegrationActive then return end

    local currentTime = CurTime()
    if currentTime - self.LastCAPUpdate < self.CAPUpdateInterval then return end
    self.LastCAPUpdate = currentTime

    -- Get ship
    if not self.ship then return end

    local capEntityCount = 0

    -- Update CAP shield status
    if HYPERDRIVE.CAP.Shields then
        local shields = HYPERDRIVE.CAP.Shields.FindShields(self.ship)
        self.CAPIntegration.shields = shields
        self:SetNWBool("CAPShieldsDetected", #shields > 0)
        self:SetNWInt("CAPShieldCount", #shields)
        capEntityCount = capEntityCount + #shields

        if #shields > 0 then
            local shieldStatus = HYPERDRIVE.CAP.Shields.GetStatus(self, self.ship)
            if shieldStatus then
                self:SetNWFloat("ShieldStrength", shieldStatus.averageStrength or 0)
                self:SetNWBool("ShieldSystemActive", shieldStatus.activeShields > 0)
            end
        end
    end

    -- Update CAP energy status
    if HYPERDRIVE.CAP.Resources then
        local energySources = HYPERDRIVE.CAP.Resources.FindEnergySources(self.ship)
        self.CAPIntegration.energySources = energySources
        self:SetNWBool("CAPEnergyDetected", #energySources > 0)
        capEntityCount = capEntityCount + #energySources

        if #energySources > 0 then
            local totalEnergy = HYPERDRIVE.CAP.Resources.GetTotalEnergy(self.ship)
            self:SetNWFloat("CAPEnergyLevel", totalEnergy)
        end
    end

    -- Update CAP resource detection
    if self.ship.entities then
        for _, ent in ipairs(self.ship.entities) do
            if IsValid(ent) and HYPERDRIVE.CAP.GetEntityCategory then
                local category = HYPERDRIVE.CAP.GetEntityCategory(ent:GetClass())
                if category then
                    capEntityCount = capEntityCount + 1
                end
            end
        end
    end

    self:SetNWBool("CAPResourcesDetected", capEntityCount > 0)
    self:SetNWInt("CAPEntityCount", capEntityCount)
end

function ENT:UpdateShipDetection()
    if not HYPERDRIVE.ShipCore then
        self:SetShipDetected(false)
        self:SetShipType("Ship Core System Not Available")
        self:SetCoreValid(false)
        self:SetStatusMessage("Ship Core system not loaded")
        return
    end

    -- Get or create ship for this core (optimized)
    local ship = HYPERDRIVE.ShipCore.GetShip(self)
    if not ship then
        -- Create ship with this core as the center using optimized detection
        ship = self:CreateOptimizedShip()
    end

    if ship then
        -- Update ship data
        ship:Update()

        self.ship = ship
        self:SetShipDetected(true)
        self:SetShipType(ship:GetShipType())
        self:SetShipCenter(ship:GetCenter())
        self:SetFrontDirection(ship:GetFrontDirection())

        -- Validate core uniqueness
        if HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness then
            local valid, message = HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness(self)
            self:SetCoreValid(valid)
            if not valid then
                self:SetStatusMessage("DUPLICATE CORE: " .. message)
                self:SetState(self.States.INVALID)
                return
            end
        end

        self:SetStatusMessage("Ship detected: " .. ship:GetShipType())
        print("[ASC Ship Core] Ship detected: " .. ship:GetShipType() .. " with " .. #ship:GetEntities() .. " entities")
    else
        self.ship = nil
        self:SetShipDetected(false)
        self:SetShipType("No Ship")
        self:SetCoreValid(false)
        self:SetStatusMessage("Ship detection failed")
        print("[ASC Ship Core] Failed to create or detect ship")
    end
end

function ENT:UpdateHullSystem()
    if not HYPERDRIVE.HullDamage or not self.ship then
        self:SetHullSystemActive(false)
        self:SetHullIntegrity(100)
        return
    end

    local getStatusFunc = SafeAccess(HYPERDRIVE.HullDamage, "GetHullStatus")
    if getStatusFunc then
        local hullStatus = SafeCall(getStatusFunc, self)
        if hullStatus then
            self:SetHullSystemActive(true)
            self:SetHullIntegrity(math.floor(hullStatus.integrityPercent or 100))

            -- Update status based on hull integrity
            if hullStatus.emergencyMode then
                self:SetState(self.States.EMERGENCY)
                self:SetStatusMessage("HULL EMERGENCY: " .. math.floor(hullStatus.integrityPercent) .. "%")
            elseif hullStatus.criticalMode then
                self:SetState(self.States.CRITICAL)
                self:SetStatusMessage("HULL CRITICAL: " .. math.floor(hullStatus.integrityPercent) .. "%")
            end
        else
            self:SetHullSystemActive(false)
            self:SetHullIntegrity(100)
        end
    else
        self:SetHullSystemActive(false)
        self:SetHullIntegrity(100)
    end
end

function ENT:UpdateShieldSystem()
    if not HYPERDRIVE.Shields or not self.ship then
        self:SetShieldSystemActive(false)
        self:SetShieldStrength(0)
        return
    end

    local getStatusFunc = SafeAccess(HYPERDRIVE.Shields, "GetShieldStatus")
    if getStatusFunc then
        local shieldStatus = SafeCall(getStatusFunc, self)
        if shieldStatus then
            self:SetShieldSystemActive(shieldStatus.available)
            self:SetShieldStrength(math.floor(shieldStatus.strengthPercent or 0))
        else
            self:SetShieldSystemActive(false)
            self:SetShieldStrength(0)
        end
    else
        self:SetShieldSystemActive(false)
        self:SetShieldStrength(0)
    end
end

function ENT:UpdateResourceSystem()
    -- Update Spacebuild 3 resource system if available
    if HYPERDRIVE.SB3Resources and HYPERDRIVE.SB3Resources.UpdateCoreResources then
        HYPERDRIVE.SB3Resources.UpdateCoreResources(self)
    end

    -- Update resource-related network variables
    self:UpdateResourceNetworkVars()
end

-- Handle UI commands
function ENT:HandleUICommand(ply, command, data)
    if not IsValid(ply) then return end

    if command == "set_ship_name" then
        local newName = data.name or "Unnamed Ship"
        self:SetShipName(newName)
        self:SaveShipName()
        ply:ChatPrint("[ASC Ship Core] Ship name set to: " .. newName)

    elseif command == "repair_hull" then
        if HYPERDRIVE.HullDamage and HYPERDRIVE.HullDamage.RepairHull then
            local success, message = HYPERDRIVE.HullDamage.RepairHull(self, data.amount or 25)
            if success then
                ply:ChatPrint("[ASC Ship Core] Hull repaired: " .. (message or "Success"))
            else
                ply:ChatPrint("[ASC Ship Core] Hull repair failed: " .. (message or "Unknown error"))
            end
        end

    elseif command == "toggle_shields" then
        if HYPERDRIVE.Shields and HYPERDRIVE.Shields.ToggleShields then
            local success, message = HYPERDRIVE.Shields.ToggleShields(self)
            if success then
                ply:ChatPrint("[ASC Ship Core] Shields toggled: " .. (message or "Success"))
            else
                ply:ChatPrint("[ASC Ship Core] Shield toggle failed: " .. (message or "Unknown error"))
            end
        end

    elseif command == "mute_ambient" then
        -- Ambient sound system removed per user request
        ply:ChatPrint("[ASC Ship Core] Ambient sound system has been removed")

    elseif command == "next_model" then
        self:NextModel()
        local modelName = self:GetNWString("SelectedModelName", "Unknown")
        ply:ChatPrint("[ASC Ship Core] Model changed to: " .. modelName)

    elseif command == "previous_model" then
        self:PreviousModel()
        local modelName = self:GetNWString("SelectedModelName", "Unknown")
        ply:ChatPrint("[ASC Ship Core] Model changed to: " .. modelName)

    elseif command == "set_model" then
        local index = data.index or 1
        if self:SetModelByIndex(index) then
            local modelName = self:GetNWString("SelectedModelName", "Unknown")
            ply:ChatPrint("[ASC Ship Core] Model changed to: " .. modelName)
        else
            ply:ChatPrint("[ASC Ship Core] Invalid model index: " .. index)
        end

    elseif command == "get_model_info" then
        local info = self:GetModelInfo()
        net.Start("asc_ship_core_model_selection")
        net.WriteEntity(self)
        net.WriteTable(info)

    -- Auto-weld commands removed

    elseif command == "close_ui" then
        self:CloseUI(ply)
    end
end

-- Network message handlers
net.Receive("asc_ship_core_command", function(len, ply)
    local core = net.ReadEntity()
    local command = net.ReadString()
    local data = net.ReadTable()

    if not IsValid(core) or not IsValid(ply) then return end
    if core:GetClass() ~= "asc_ship_core" then return end

    core:HandleUICommand(ply, command, data)
end)

-- Ship name management
function ENT:SetShipName(name)
    self:SetNWString("ShipName", name or "Unnamed Ship")
end

function ENT:GetShipName()
    return self:GetNWString("ShipName", "Unnamed Ship")
end

function ENT:SaveShipName()
    local name = self:GetShipName()
    if name and name ~= "" then
        file.Write(self.shipNameFile, name)
    end
end

function ENT:LoadShipName()
    if file.Exists(self.shipNameFile, "DATA") then
        local name = file.Read(self.shipNameFile, "DATA")
        if name and name ~= "" then
            self:SetShipName(name)
        end
    end
end

-- Use function
function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Open UI
    self:OpenUI(activator)
end

function ENT:OpenUI(ply)
    if not IsValid(ply) then return end

    -- Track active UI
    self.activeUIs[ply] = true

    -- Send UI data
    net.Start("asc_ship_core_open_ui")
    net.WriteEntity(self)
    net.WriteTable(self:GetUIData())
    net.Send(ply)

    print("[ASC Ship Core] UI opened for " .. ply:Nick())
end

function ENT:CloseUI(ply)
    if IsValid(ply) then
        self.activeUIs[ply] = nil
        net.Start("asc_ship_core_close_ui")
        net.Send(ply)
    end
end

function ENT:UpdateUI()
    if table.Count(self.activeUIs) == 0 then return end

    local data = self:GetUIData()

    for ply, _ in pairs(self.activeUIs) do
        if IsValid(ply) then
            net.Start("asc_ship_core_update_ui")
            net.WriteTable(data)
            net.Send(ply)
        else
            self.activeUIs[ply] = nil
        end
    end
end

function ENT:GetUIData()
    local data = {
        coreState = self:GetState(),
        coreStateName = self:GetStateName(),
        shipDetected = self:GetShipDetected(),
        shipType = self:GetShipType(),
        shipName = self:GetShipName(),
        hullIntegrity = self:GetHullIntegrity(),
        shieldStrength = self:GetShieldStrength(),
        hullSystemActive = self:GetHullSystemActive(),
        shieldSystemActive = self:GetShieldSystemActive(),
        statusMessage = self:GetStatusMessage(),
        -- ambientSoundMuted removed per user request
        modelInfo = self:GetModelInfo()
    }

    -- Add enhanced power management data
    if self.PowerManagement then
        data.powerManagement = {
            totalPower = self.PowerManagement.totalPower,
            availablePower = self.PowerManagement.availablePower,
            powerDistribution = self.PowerManagement.powerDistribution,
            emergencyMode = self.PowerManagement.emergencyMode,
            powerEfficiency = self.PowerManagement.powerEfficiency,
            heatGeneration = self.PowerManagement.heatGeneration
        }
    end

    -- Add thermal management data
    if self.ThermalManagement then
        data.thermalManagement = {
            coreTemperature = self.ThermalManagement.coreTemperature,
            maxTemperature = self.ThermalManagement.maxTemperature,
            overheating = self.ThermalManagement.overheating,
            coolingRate = self.ThermalManagement.coolingRate,
            thermalEfficiency = self.ThermalManagement.thermalEfficiency
        }
    end

    -- Add subsystem data
    if self.SubsystemManagement then
        data.subsystems = {}
        for name, subsystem in pairs(self.SubsystemManagement.subsystems) do
            data.subsystems[name] = {
                health = subsystem.health,
                efficiency = subsystem.efficiency,
                priority = subsystem.priority,
                critical = subsystem.critical
            }
        end
        data.autoRepair = self.SubsystemManagement.autoRepair
        data.repairRate = self.SubsystemManagement.repairRate
    end

    -- Add crew efficiency data
    if self.CrewEfficiency then
        data.crewEfficiency = {
            totalCrew = self.CrewEfficiency.totalCrew,
            overallEfficiency = self.CrewEfficiency.overallEfficiency,
            systemBonuses = self.CrewEfficiency.systemBonuses
        }
    end

    -- Add enhanced resource data
    if self.BasicResourceStorage then
        data.resources = {}
        for resourceType, resource in pairs(self.BasicResourceStorage) do
            data.resources[resourceType] = {
                amount = resource.amount,
                capacity = resource.capacity,
                percentage = (resource.amount / resource.capacity) * 100,
                regenRate = resource.regenRate,
                critical = resource.critical,
                priority = resource.priority
            }
        end
    end

    -- Add ship data if available
    if self.ship then
        data.entityCount = #self.ship:GetEntities()
        data.shipMass = self.ship.mass or 0
        data.shipCenter = self.ship:GetCenter()
        data.frontDirection = self.ship:GetFrontDirection()
    end

    return data
end

-- Wire integration
if WireLib then
    function ENT:TriggerInput(iname, value)
        -- Resource management inputs
        if iname == "AddEnergy" and value > 0 then
            self:AddResource("energy", value)
        elseif iname == "AddOxygen" and value > 0 then
            self:AddResource("oxygen", value)
        elseif iname == "AddCoolant" and value > 0 then
            self:AddResource("coolant", value)
        elseif iname == "AddFuel" and value > 0 then
            self:AddResource("fuel", value)
        elseif iname == "AddWater" and value > 0 then
            self:AddResource("water", value)
        elseif iname == "AddNitrogen" and value > 0 then
            self:AddResource("nitrogen", value)

        -- Resource system controls
        elseif iname == "DistributeResources" and value > 0 then
            if HYPERDRIVE.SB3Resources then
                HYPERDRIVE.SB3Resources.DistributeResources(self)
            end
        elseif iname == "CollectResources" and value > 0 then
            if HYPERDRIVE.SB3Resources then
                HYPERDRIVE.SB3Resources.CollectResources(self)
            end
        elseif iname == "BalanceResources" and value > 0 then
            if HYPERDRIVE.SB3Resources then
                HYPERDRIVE.SB3Resources.AutoBalanceResources(self)
            end
        elseif iname == "ToggleLifeSupport" then
            if HYPERDRIVE.SB3Resources then
                local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
                if storage then
                    storage.lifeSupportActive = value > 0
                end
            end

        -- System controls (ambient sound removed per user request)
        elseif iname == "Mute" then
            -- Ambient sound system removed
        elseif iname == "RepairHull" and value > 0 then
            if HYPERDRIVE.HullDamage and HYPERDRIVE.HullDamage.RepairHull then
                HYPERDRIVE.HullDamage.RepairHull(self, 25)
            end
        elseif iname == "ActivateShields" and value > 0 then
            if HYPERDRIVE.Shields and HYPERDRIVE.Shields.ActivateShields then
                HYPERDRIVE.Shields.ActivateShields(self)
            end
        elseif iname == "DeactivateShields" and value > 0 then
            if HYPERDRIVE.Shields and HYPERDRIVE.Shields.DeactivateShields then
                HYPERDRIVE.Shields.DeactivateShields(self)
            end
        elseif iname == "Recalculate" and value > 0 then
            self:Recalculate()
        elseif iname == "EmergencyResourceShutdown" and value > 0 then
            self:EmergencyResourceShutdown()
        end
    end

    function ENT:UpdateWireOutputs()
        if not WireLib then return end

        -- Core system outputs
        self:TriggerOutput("ShipDetected", self:GetShipDetected() and 1 or 0)
        self:TriggerOutput("ShipType", self:GetShipType())
        self:TriggerOutput("ShipName", self:GetShipName())
        self:TriggerOutput("CoreValid", self:GetCoreValid() and 1 or 0)
        self:TriggerOutput("CoreState", self:GetState())
        self:TriggerOutput("CoreStateName", self:GetStateName())
        self:TriggerOutput("StatusMessage", self:GetStatusMessage())

        -- Hull and shield outputs
        self:TriggerOutput("HullIntegrity", self:GetHullIntegrity())
        self:TriggerOutput("HullSystemActive", self:GetHullSystemActive() and 1 or 0)
        self:TriggerOutput("ShieldStrength", self:GetShieldStrength())
        self:TriggerOutput("ShieldSystemActive", self:GetShieldSystemActive() and 1 or 0)

        -- Ship information outputs
        self:TriggerOutput("ShipCenter", self:GetShipCenter())
        self:TriggerOutput("FrontDirection", self:GetFrontDirection())
        -- AmbientSoundMuted output removed per user request

        if self.ship then
            self:TriggerOutput("EntityCount", #self.ship:GetEntities())
            self:TriggerOutput("ShipMass", self.ship.mass or 0)
        else
            self:TriggerOutput("EntityCount", 0)
            self:TriggerOutput("ShipMass", 0)
        end

        -- Resource system outputs
        self:UpdateResourceWireOutputs()
    end
end

-- Additional functions for system integration
function ENT:UpdateCoreState()
    local currentState = self:GetState()
    local newState = currentState

    -- Determine state based on systems
    if not self:GetShipDetected() then
        newState = self.States.INACTIVE
    elseif not self:GetCoreValid() then
        newState = self.States.INVALID
    elseif self:GetHullIntegrity() < 25 then
        newState = self.States.EMERGENCY
    elseif self:GetHullIntegrity() < 50 then
        newState = self.States.CRITICAL
    else
        newState = self.States.ACTIVE
    end

    if newState ~= currentState then
        self:SetState(newState)
        self:SetStatusMessage(self:GetStateName())
    end
end

function ENT:UpdateResourceNetworkVars()
    -- Update resource-related network variables for UI
    if HYPERDRIVE.SB3Resources then
        local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
        if storage and storage.resources then
            -- Update individual resource levels
            self:SetNWFloat("EnergyLevel", storage.resources.energy or 0)
            self:SetNWFloat("OxygenLevel", storage.resources.oxygen or 0)
            self:SetNWFloat("CoolantLevel", storage.resources.coolant or 0)
            self:SetNWFloat("FuelLevel", storage.resources.fuel or 0)
            self:SetNWFloat("WaterLevel", storage.resources.water or 0)
            self:SetNWFloat("NitrogenLevel", storage.resources.nitrogen or 0)

            -- Update capacity information
            self:SetNWFloat("EnergyCapacity", storage.capacity.energy or 0)
            self:SetNWFloat("OxygenCapacity", storage.capacity.oxygen or 0)
            self:SetNWFloat("CoolantCapacity", storage.capacity.coolant or 0)
            self:SetNWFloat("FuelCapacity", storage.capacity.fuel or 0)
            self:SetNWFloat("WaterCapacity", storage.capacity.water or 0)
            self:SetNWFloat("NitrogenCapacity", storage.capacity.nitrogen or 0)

            -- Calculate percentages
            local energyPercent = storage.capacity.energy > 0 and (storage.resources.energy / storage.capacity.energy * 100) or 0
            local oxygenPercent = storage.capacity.oxygen > 0 and (storage.resources.oxygen / storage.capacity.oxygen * 100) or 0
            local fuelPercent = storage.capacity.fuel > 0 and (storage.resources.fuel / storage.capacity.fuel * 100) or 0

            self:SetNWFloat("EnergyPercent", energyPercent)
            self:SetNWFloat("OxygenPercent", oxygenPercent)
            self:SetNWFloat("FuelPercent", fuelPercent)

            -- Update system status
            self:SetNWBool("ResourceEmergency", storage.emergencyMode or false)
            self:SetNWBool("LifeSupportActive", storage.lifeSupportActive or false)
            self:SetNWInt("PlayersSupported", storage.playersSupported or 0)
            self:SetNWFloat("ShipSizeMultiplier", storage.sizeMultiplier or 1.0)

            -- Calculate total resources
            local totalAmount = (storage.resources.energy or 0) + (storage.resources.oxygen or 0) +
                               (storage.resources.coolant or 0) + (storage.resources.fuel or 0) +
                               (storage.resources.water or 0) + (storage.resources.nitrogen or 0)
            local totalCapacity = (storage.capacity.energy or 0) + (storage.capacity.oxygen or 0) +
                                 (storage.capacity.coolant or 0) + (storage.capacity.fuel or 0) +
                                 (storage.capacity.water or 0) + (storage.capacity.nitrogen or 0)

            self:SetNWFloat("TotalResourceAmount", totalAmount)
            self:SetNWFloat("TotalResourceCapacity", totalCapacity)

            -- Update activity status
            local lastActivity = storage.lastUpdate and (CurTime() - storage.lastUpdate < 5) and "Active" or "Inactive"
            self:SetNWString("LastResourceActivity", lastActivity)

            return
        end
    end

    -- Fallback to basic resource system
    self:UpdateBasicResourceNetworkVars()
end

function ENT:InitializeBasicResourceSystem()
    -- Initialize enhanced basic resource system when Spacebuild 3 is not available
    self:SetNWBool("ResourceSystemActive", true)
    self:SetNWBool("AutoProvisionEnabled", false)
    self:SetNWBool("WeldDetectionEnabled", false)
    -- Auto-weld system removed

    -- Initialize enhanced power management system
    self.PowerManagement = {
        totalPower = 1000,
        availablePower = 1000,
        powerDistribution = {
            weapons = { allocated = 200, priority = 1, efficiency = 1.0, active = true },
            shields = { allocated = 250, priority = 2, efficiency = 1.0, active = true },
            engines = { allocated = 150, priority = 3, efficiency = 1.0, active = true },
            lifesupport = { allocated = 100, priority = 4, efficiency = 1.0, active = true },
            sensors = { allocated = 50, priority = 5, efficiency = 1.0, active = true },
            communications = { allocated = 50, priority = 6, efficiency = 1.0, active = true },
            auxiliary = { allocated = 200, priority = 7, efficiency = 1.0, active = true }
        },
        emergencyMode = false,
        powerEfficiency = 1.0,
        heatGeneration = 0,
        coolingCapacity = 100
    }

    -- Initialize thermal management system
    self.ThermalManagement = {
        coreTemperature = 20, -- Celsius
        maxTemperature = 100,
        criticalTemperature = 150,
        coolingRate = 5,
        heatSources = {},
        thermalEfficiency = 1.0,
        overheating = false
    }

    -- Initialize subsystem management
    self.SubsystemManagement = {
        subsystems = {
            reactor = { health = 100, efficiency = 1.0, priority = 1, critical = true },
            powerGrid = { health = 100, efficiency = 1.0, priority = 2, critical = true },
            lifesupport = { health = 100, efficiency = 1.0, priority = 3, critical = true },
            navigation = { health = 100, efficiency = 1.0, priority = 4, critical = false },
            communications = { health = 100, efficiency = 1.0, priority = 5, critical = false },
            sensors = { health = 100, efficiency = 1.0, priority = 6, critical = false }
        },
        autoRepair = true,
        repairRate = 1.0,
        maintenanceSchedule = {}
    }

    -- Initialize basic resource storage with enhanced mechanics
    self.BasicResourceStorage = {
        energy = { amount = 1000, capacity = 1000, regenRate = 10, priority = 1, critical = true },
        oxygen = { amount = 500, capacity = 500, regenRate = 5, priority = 2, critical = true },
        coolant = { amount = 200, capacity = 200, regenRate = 2, priority = 3, critical = true },
        fuel = { amount = 300, capacity = 300, regenRate = 0, priority = 4, critical = false }, -- Fuel doesn't regenerate
        water = { amount = 150, capacity = 150, regenRate = 1, priority = 5, critical = false },
        nitrogen = { amount = 100, capacity = 100, regenRate = 1, priority = 6, critical = false }
    }

    -- Set initial network variables
    self:UpdateBasicResourceNetworkVars()

    -- Start basic resource regeneration timer
    self:StartBasicResourceRegeneration()

    self:SetNWString("LastResourceActivity", "Enhanced basic system initialized")
    print("[ASC Ship Core] Enhanced basic resource system initialized")
end

-- Ensure PowerManagement is initialized (safety function)
function ENT:EnsurePowerManagementInitialized()
    if not self.PowerManagement then
        print("[ASC Ship Core] PowerManagement not initialized, creating default...")
        self.PowerManagement = {
            totalPower = 1000,
            availablePower = 1000,
            powerDistribution = {
                weapons = { allocated = 200, priority = 1, efficiency = 1.0, active = true },
                shields = { allocated = 250, priority = 2, efficiency = 1.0, active = true },
                engines = { allocated = 150, priority = 3, efficiency = 1.0, active = true },
                lifesupport = { allocated = 100, priority = 4, efficiency = 1.0, active = true },
                sensors = { allocated = 50, priority = 5, efficiency = 1.0, active = true },
                communications = { allocated = 50, priority = 6, efficiency = 1.0, active = true },
                auxiliary = { allocated = 200, priority = 7, efficiency = 1.0, active = true }
            },
            emergencyMode = false,
            powerEfficiency = 1.0,
            heatGeneration = 0,
            coolingCapacity = 100
        }
    end
    return self.PowerManagement
end

-- Ensure ThermalManagement is initialized (safety function)
function ENT:EnsureThermalManagementInitialized()
    if not self.ThermalManagement then
        print("[ASC Ship Core] ThermalManagement not initialized, creating default...")
        self.ThermalManagement = {
            coreTemperature = 20, -- Celsius
            maxTemperature = 100,
            criticalTemperature = 150,
            coolingRate = 5,
            heatSources = {},
            thermalEfficiency = 1.0,
            overheating = false
        }
    end
    return self.ThermalManagement
end

-- Ensure SubsystemManagement is initialized (safety function)
function ENT:EnsureSubsystemManagementInitialized()
    if not self.SubsystemManagement then
        print("[ASC Ship Core] SubsystemManagement not initialized, creating default...")
        self.SubsystemManagement = {
            subsystems = {
                reactor = { health = 100, efficiency = 1.0, priority = 1, critical = true },
                powerGrid = { health = 100, efficiency = 1.0, priority = 2, critical = true },
                lifesupport = { health = 100, efficiency = 1.0, priority = 3, critical = true },
                navigation = { health = 100, efficiency = 1.0, priority = 4, critical = false },
                communications = { health = 100, efficiency = 1.0, priority = 5, critical = false },
                sensors = { health = 100, efficiency = 1.0, priority = 6, critical = false }
            },
            autoRepair = true,
            repairRate = 1.0,
            maintenanceSchedule = {}
        }
    end
    return self.SubsystemManagement
end

function ENT:UpdateBasicResourceNetworkVars()
    if not self.BasicResourceStorage then return end

    -- Update individual resource levels
    for resourceType, data in pairs(self.BasicResourceStorage) do
        local percent = data.capacity > 0 and (data.amount / data.capacity * 100) or 0

        self:SetNWFloat(string.upper(string.sub(resourceType, 1, 1)) .. string.sub(resourceType, 2) .. "Level", data.amount)
        self:SetNWFloat(string.upper(string.sub(resourceType, 1, 1)) .. string.sub(resourceType, 2) .. "Capacity", data.capacity)
        self:SetNWFloat(string.upper(string.sub(resourceType, 1, 1)) .. string.sub(resourceType, 2) .. "Percent", percent)
    end

    -- Calculate totals
    local totalAmount = 0
    local totalCapacity = 0
    local emergencyResources = 0

    for _, data in pairs(self.BasicResourceStorage) do
        totalAmount = totalAmount + data.amount
        totalCapacity = totalCapacity + data.capacity

        local percent = data.capacity > 0 and (data.amount / data.capacity * 100) or 0
        if percent < 25 then
            emergencyResources = emergencyResources + 1
        end
    end

    self:SetNWFloat("TotalResourceAmount", totalAmount)
    self:SetNWFloat("TotalResourceCapacity", totalCapacity)
    self:SetNWBool("ResourceEmergency", emergencyResources >= 2)
    self:SetNWBool("LifeSupportActive", self.BasicResourceStorage.oxygen.amount > 50)
    self:SetNWString("LastResourceActivity", "Basic system active - " .. os.date("%H:%M:%S"))
end

function ENT:StartBasicResourceRegeneration()
    -- Create timer for basic resource regeneration
    local timerName = "ASC_BasicResourceRegen_" .. self:EntIndex()

    timer.Create(timerName, 1, 0, function()
        if not IsValid(self) or not self.BasicResourceStorage then
            timer.Remove(timerName)
            return
        end

        self:UpdateBasicResourceRegeneration()
    end)
end

function ENT:UpdateBasicResourceRegeneration()
    if not self.BasicResourceStorage then return end

    local shipSize = self:GetShipSize()
    local sizeMultiplier = math.max(0.5, math.min(2.0, shipSize / 50)) -- Scale based on ship size

    -- Regenerate resources based on ship size (inverse scaling for balance)
    for resourceType, data in pairs(self.BasicResourceStorage) do
        if data.regenRate > 0 then
            -- Small ships regenerate faster but hold less
            -- Large ships hold more but regenerate slower
            local regenAmount = data.regenRate * (2.0 - sizeMultiplier) -- Inverse scaling
            local newAmount = math.min(data.capacity, data.amount + regenAmount)

            if newAmount ~= data.amount then
                data.amount = newAmount
                self:SetNWFloat(string.upper(string.sub(resourceType, 1, 1)) .. string.sub(resourceType, 2) .. "Level", data.amount)
            end
        end
    end

    -- Update network variables
    self:UpdateBasicResourceNetworkVars()

    -- Provide basic life support
    self:ProvideBasicLifeSupport()
end

function ENT:GetShipSize()
    if self.ship and self.ship.GetEntities then
        return #self.ship:GetEntities()
    end
    return 10 -- Default size
end

function ENT:ProvideBasicLifeSupport()
    if not self.BasicResourceStorage or self.BasicResourceStorage.oxygen.amount <= 0 then return end

    local corePos = self:GetPos()
    local lifeSupportRange = 1000 -- Basic life support range

    -- Find players within range
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() then
            local distance = corePos:Distance(ply:GetPos())
            if distance <= lifeSupportRange then
                -- Provide basic life support
                if ply:Health() < ply:GetMaxHealth() and ply:Health() > 0 then
                    local healAmount = math.min(1, ply:GetMaxHealth() - ply:Health())
                    ply:SetHealth(ply:Health() + healAmount)
                end

                -- Remove drowning effects
                if ply:WaterLevel() >= 3 then
                    ply:SetAir(ply:GetMaxAir())
                end

                -- Consume oxygen
                self.BasicResourceStorage.oxygen.amount = math.max(0, self.BasicResourceStorage.oxygen.amount - 0.1)

                -- Set life support status
                ply:SetNWBool("HasLifeSupport", true)
                ply:SetNWEntity("LifeSupportCore", self)
            else
                -- Remove life support status if out of range
                if ply:GetNWEntity("LifeSupportCore") == self then
                    ply:SetNWBool("HasLifeSupport", false)
                    ply:SetNWEntity("LifeSupportCore", NULL)
                end
            end
        end
    end
end

-- Resource management functions for both basic and SB3 systems
function ENT:GetResourceLevel(resourceType)
    if HYPERDRIVE.SB3Resources then
        local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
        if storage and storage.resources then
            return storage.resources[resourceType] or 0
        end
    elseif self.BasicResourceStorage then
        return self.BasicResourceStorage[resourceType] and self.BasicResourceStorage[resourceType].amount or 0
    end
    return 0
end

function ENT:GetResourceCapacity(resourceType)
    if HYPERDRIVE.SB3Resources then
        local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
        if storage and storage.capacity then
            return storage.capacity[resourceType] or 0
        end
    elseif self.BasicResourceStorage then
        return self.BasicResourceStorage[resourceType] and self.BasicResourceStorage[resourceType].capacity or 0
    end
    return 0
end

function ENT:GetResourcePercent(resourceType)
    local level = self:GetResourceLevel(resourceType)
    local capacity = self:GetResourceCapacity(resourceType)
    return capacity > 0 and (level / capacity * 100) or 0
end

function ENT:AddResource(resourceType, amount)
    if HYPERDRIVE.SB3Resources then
        return HYPERDRIVE.SB3Resources.AddResource(self, resourceType, amount)
    elseif self.BasicResourceStorage and self.BasicResourceStorage[resourceType] then
        local data = self.BasicResourceStorage[resourceType]
        local maxAdd = data.capacity - data.amount
        local actualAdd = math.min(amount, maxAdd)

        if actualAdd > 0 then
            data.amount = data.amount + actualAdd
            self:UpdateBasicResourceNetworkVars()
            return true, "Added " .. actualAdd .. " " .. resourceType
        end
        return false, "Storage full"
    end
    return false, "Resource system not available"
end

function ENT:RemoveResource(resourceType, amount)
    if HYPERDRIVE.SB3Resources then
        return HYPERDRIVE.SB3Resources.RemoveResource(self, resourceType, amount)
    elseif self.BasicResourceStorage and self.BasicResourceStorage[resourceType] then
        local data = self.BasicResourceStorage[resourceType]
        local actualRemove = math.min(amount, data.amount)

        if actualRemove > 0 then
            data.amount = data.amount - actualRemove
            self:UpdateBasicResourceNetworkVars()
            return true, "Removed " .. actualRemove .. " " .. resourceType
        end
        return false, "Insufficient resources"
    end
    return false, "Resource system not available"
end

function ENT:HasSufficientResources(requirements)
    for resourceType, amount in pairs(requirements) do
        if self:GetResourceLevel(resourceType) < amount then
            return false, "Insufficient " .. resourceType
        end
    end
    return true, "Sufficient resources"
end

function ENT:ConsumeResources(requirements)
    -- Check if we have sufficient resources first
    local sufficient, message = self:HasSufficientResources(requirements)
    if not sufficient then
        return false, message
    end

    -- Consume the resources
    for resourceType, amount in pairs(requirements) do
        local success, msg = self:RemoveResource(resourceType, amount)
        if not success then
            return false, "Failed to consume " .. resourceType .. ": " .. msg
        end
    end

    return true, "Resources consumed successfully"
end

function ENT:GetResourceStatus()
    local status = {
        systemActive = self:GetNWBool("ResourceSystemActive", false),
        emergencyMode = self:GetNWBool("ResourceEmergency", false),
        lifeSupportActive = self:GetNWBool("LifeSupportActive", false),
        totalAmount = self:GetNWFloat("TotalResourceAmount", 0),
        totalCapacity = self:GetNWFloat("TotalResourceCapacity", 0),
        resources = {}
    }

    local resourceTypes = {"energy", "oxygen", "coolant", "fuel", "water", "nitrogen"}
    for _, resourceType in ipairs(resourceTypes) do
        status.resources[resourceType] = {
            level = self:GetResourceLevel(resourceType),
            capacity = self:GetResourceCapacity(resourceType),
            percent = self:GetResourcePercent(resourceType)
        }
    end

    return status
end

-- Wire integration for resources
function ENT:UpdateResourceWireOutputs()
    if not WireLib then return end

    -- Output individual resource levels
    self:TriggerOutput("EnergyLevel", self:GetResourceLevel("energy"))
    self:TriggerOutput("OxygenLevel", self:GetResourceLevel("oxygen"))
    self:TriggerOutput("CoolantLevel", self:GetResourceLevel("coolant"))
    self:TriggerOutput("FuelLevel", self:GetResourceLevel("fuel"))
    self:TriggerOutput("WaterLevel", self:GetResourceLevel("water"))
    self:TriggerOutput("NitrogenLevel", self:GetResourceLevel("nitrogen"))

    -- Output resource percentages
    self:TriggerOutput("EnergyPercent", self:GetResourcePercent("energy"))
    self:TriggerOutput("OxygenPercent", self:GetResourcePercent("oxygen"))
    self:TriggerOutput("FuelPercent", self:GetResourcePercent("fuel"))

    -- Output system status
    self:TriggerOutput("ResourceEmergency", self:GetNWBool("ResourceEmergency", false) and 1 or 0)
    self:TriggerOutput("ResourceSystemActive", self:GetNWBool("ResourceSystemActive", false) and 1 or 0)
    self:TriggerOutput("LifeSupportActive", self:GetNWBool("LifeSupportActive", false) and 1 or 0)
    self:TriggerOutput("TotalResourceCapacity", self:GetNWFloat("TotalResourceCapacity", 0))
    self:TriggerOutput("TotalResourceAmount", self:GetNWFloat("TotalResourceAmount", 0))

    -- Output activity status
    self:TriggerOutput("LastResourceActivity", self:GetNWString("LastResourceActivity", "Unknown"))
end

-- Functions expected by other systems
function ENT:AddShield(shieldEntity)
    if not self.LinkedShields then
        self.LinkedShields = {}
    end
    table.insert(self.LinkedShields, shieldEntity)
    print("[ASC Ship Core] Shield generator linked: " .. tostring(shieldEntity))
end

function ENT:AddWeapon(weaponEntity)
    if not self.LinkedWeapons then
        self.LinkedWeapons = {}
    end
    table.insert(self.LinkedWeapons, weaponEntity)
    print("[ASC Ship Core] Weapon linked: " .. tostring(weaponEntity))
end

function ENT:AddComponent(componentEntity)
    if not self.LinkedComponents then
        self.LinkedComponents = {}
    end
    table.insert(self.LinkedComponents, componentEntity)
    print("[ASC Ship Core] Component linked: " .. tostring(componentEntity))
end

function ENT:AutoLinkComponents()
    -- Auto-link nearby components
    local nearbyEnts = ents.FindInSphere(self:GetPos(), 2000)
    local linkedCount = 0

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent ~= self then
            local class = ent:GetClass()

            -- Link weapons
            if string.find(class, "weapon_") or string.find(class, "hyperdrive_") or
               string.find(class, "railgun") or string.find(class, "cannon") or
               string.find(class, "turret") or string.find(class, "launcher") then
                self:AddWeapon(ent)
                if ent.SetShipCore then
                    ent:SetShipCore(self)
                end
                linkedCount = linkedCount + 1

            -- Link shields
            elseif string.find(class, "shield") then
                self:AddShield(ent)
                if ent.SetShipCore then
                    ent:SetShipCore(self)
                end
                linkedCount = linkedCount + 1

            -- Link other components
            elseif string.find(class, "asc_") or string.find(class, "hyperdrive_") then
                self:AddComponent(ent)
                if ent.SetShipCore then
                    ent:SetShipCore(self)
                end
                linkedCount = linkedCount + 1
            end
        end
    end

    print("[ASC Ship Core] Auto-linked " .. linkedCount .. " components")
    return linkedCount
end

function ENT:Recalculate()
    -- Force recalculation of all systems
    self:UpdateShipDetection()
    self:UpdateSystems()
    self:AutoLinkComponents()
    print("[ASC Ship Core] Systems recalculated")
end

-- Handle when entities are welded to this ship core
function ENT:OnEntityWelded(entity)
    if not IsValid(entity) then return end

    print("[ASC Ship Core] Entity welded to ship: " .. entity:GetClass())

    -- Add to ship detection
    if self.ship then
        table.insert(self.ship.entities, entity)
    end

    -- Auto-link if it's an ASC component
    local class = entity:GetClass()
    if string.find(class, "asc_") or string.find(class, "hyperdrive_") then
        self:AddComponent(entity)
        if entity.SetShipCore then
            entity:SetShipCore(self)
        end
        print("[ASC Ship Core] Auto-linked component: " .. class)
    end

    -- Provide resources if resource system is active
    if self:GetNWBool("ResourceSystemActive", false) and self:GetNWBool("AutoProvisionEnabled", false) then
        timer.Simple(0.5, function()
            if IsValid(self) and IsValid(entity) then
                self:ProvideResourcesTo(entity)
            end
        end)
    end

    -- Update ship detection
    timer.Simple(1, function()
        if IsValid(self) then
            self:UpdateShipDetection()
        end
    end)
end

-- Provide resources to a newly welded entity
function ENT:ProvideResourcesTo(entity)
    if not IsValid(entity) then return end

    -- Check if entity has resource capacity
    local hasResources = false
    local resourceTypes = {"energy", "oxygen", "coolant", "fuel", "water", "nitrogen"}

    for _, resourceType in ipairs(resourceTypes) do
        local capacityMethod = "Get" .. string.upper(string.sub(resourceType, 1, 1)) .. string.sub(resourceType, 2) .. "Capacity"
        local setMethod = "Set" .. string.upper(string.sub(resourceType, 1, 1)) .. string.sub(resourceType, 2)

        if entity[capacityMethod] and entity[setMethod] then
            local capacity = entity[capacityMethod](entity)
            if capacity and capacity > 0 then
                local amount = math.min(capacity * 0.5, 100) -- Provide 50% or 100 units, whichever is smaller
                entity[setMethod](entity, amount)
                hasResources = true
                print("[ASC Ship Core] Provided " .. amount .. " " .. resourceType .. " to " .. entity:GetClass())
            end
        end
    end

    if hasResources then
        self:SetNWString("LastResourceActivity", "Provided resources to " .. entity:GetClass())
    end
end

-- Initialize welding detection system
function ENT:InitializeWeldingDetection()
    -- Set up constraint detection hook for this specific ship core
    local hookName = "ASC_ShipCore_WeldDetection_" .. self:EntIndex()

    hook.Add("OnEntityCreated", hookName, function(ent)
        if not IsValid(ent) or not IsValid(self) then
            hook.Remove("OnEntityCreated", hookName)
            return
        end

        -- Check if this is a constraint
        if ent:GetClass() == "phys_constraint" or string.find(ent:GetClass(), "constraint") then
            timer.Simple(0.1, function()
                if IsValid(ent) and IsValid(self) then
                    self:CheckConstraintForWelding(ent)
                end
            end)
        end
    end)

    print("[ASC Ship Core] Welding detection system initialized")
end

-- Check if a constraint involves this ship core
function ENT:CheckConstraintForWelding(constraint)
    if not IsValid(constraint) then return end

    -- Get the entities involved in the constraint
    local ent1 = constraint.Ent1
    local ent2 = constraint.Ent2

    if not IsValid(ent1) or not IsValid(ent2) then return end

    -- Check if one of the entities is this ship core
    if ent1 == self then
        self:OnEntityWelded(ent2)
    elseif ent2 == self then
        self:OnEntityWelded(ent1)
    end
end

-- Auto-weld system removed for performance and simplicity

-- Auto-weld on spawn removed

-- Auto-weld functions removed

-- Auto-weld entity checking removed

-- Auto-weld constraint checking removed

-- Auto-weld configuration functions removed

-- Override the Remove function to clean up hooks and timers
local originalRemove = ENT.Remove or function() end
function ENT:Remove()
    -- Clean up welding detection hook
    local hookName = "ASC_ShipCore_WeldDetection_" .. self:EntIndex()
    hook.Remove("OnEntityCreated", hookName)

    -- Auto-weld timer cleanup removed

    -- Call original remove function
    originalRemove(self)
end

-- Auto-weld system implementation removed

-- All auto-weld functions removed for performance and simplicity

-- Real-time update functions
function ENT:RealTimeEntityScan()
    if not self.ship then return end

    local entities = self.ship:GetEntities()
    self.CachedAttachedEntities = {
        entities = entities,
        count = #entities,
        lastUpdate = CurTime()
    }
end

function ENT:RealTimeResourceUpdate()
    self:UpdateResourceSystem()
end

function ENT:RealTimeSystemCheck()
    self:UpdateSystems()
end

function ENT:RealTimeNetworkSync()
    if WireLib then
        self:UpdateWireOutputs()
    end
    self:UpdateUI()
end

function ENT:UpdateRealTimeData()
    -- Update real-time monitoring data
    if self.ship then
        self:SetNWInt("EntityCount", #self.ship:GetEntities())
        self:SetNWFloat("ShipMass", self.ship.mass or 0)
    end
end

-- Fleet management functions
function ENT:InitializeFleetManagement()
    self.FleetID = 0
    self.FleetRole = "INDEPENDENT"
    print("[ASC Ship Core] Fleet management initialized")
end

function ENT:InitializeRealTimeMonitoring()
    self.RealTimeMonitoring = true
    print("[ASC Ship Core] Real-time monitoring initialized")
end

function ENT:InitializePerformanceAnalytics()
    self.PerformanceMetrics = {}
    print("[ASC Ship Core] Performance analytics initialized")
end

function ENT:StartRealTimeUpdates()
    -- Real-time updates are handled in Think function
    print("[ASC Ship Core] Real-time updates started")
end

-- Model selection system
function ENT:GetCAPModels()
    local models = {
        {path = "models/props_combine/combine_core.mdl", name = "Combine Core", category = "Default"},
        {path = "models/hunter/blocks/cube025x025x025.mdl", name = "Basic Cube", category = "Default"},
        {path = "models/props_lab/huladoll.mdl", name = "Hula Doll", category = "Default"},
        {path = "models/props_c17/oildrum001.mdl", name = "Oil Drum", category = "Default"},
        {path = "models/props_phx/construct/metal_plate1.mdl", name = "Metal Plate", category = "Default"},
        {path = "models/props_phx/construct/metal_dome360.mdl", name = "Metal Dome", category = "Default"},
        {path = "models/props_phx/construct/metal_tube.mdl", name = "Metal Tube", category = "Default"},
        {path = "models/props_phx/construct/glass/glass_dome360.mdl", name = "Glass Dome", category = "Default"},
        {path = "models/props_phx/construct/windows/window1x1.mdl", name = "Window Panel", category = "Default"},
        {path = "models/props_phx/construct/concrete_pipe001.mdl", name = "Concrete Pipe", category = "Default"}
    }

    -- Add CAP models if available
    if HYPERDRIVE.CAP and HYPERDRIVE.CAP.Models then
        local capModels = HYPERDRIVE.CAP.Models.GetShipCoreModels()
        if capModels then
            for _, model in ipairs(capModels) do
                if type(model) == "string" then
                    table.insert(models, {path = model, name = "CAP Model", category = "CAP"})
                else
                    table.insert(models, model)
                end
            end
        end
    end

    return models
end

function ENT:ApplySelectedModel()
    local models = self:GetCAPModels()
    if models and models[self.selectedModelIndex] then
        local modelData = models[self.selectedModelIndex]
        local modelPath = type(modelData) == "table" and modelData.path or modelData
        local modelName = type(modelData) == "table" and modelData.name or "Unknown Model"

        self:SetModel(modelPath)
        self:SetNWString("SelectedModelName", modelName)
        self:SetNWInt("SelectedModelIndex", self.selectedModelIndex)
        self:SetNWInt("TotalModels", #models)

        print("[ASC Ship Core] Applied model: " .. modelName .. " (" .. modelPath .. ")")

        -- Save preference
        self:SaveModelPreference()
    end
end

function ENT:LoadModelPreference()
    -- Load saved model preference from file
    local prefFile = "asc_ship_core_model_" .. self:EntIndex() .. ".txt"
    if file.Exists(prefFile, "DATA") then
        local savedIndex = tonumber(file.Read(prefFile, "DATA"))
        if savedIndex and savedIndex > 0 then
            self.selectedModelIndex = savedIndex
            self:ApplySelectedModel()
        end
    end
end

function ENT:SaveModelPreference()
    -- Save model preference to file
    local prefFile = "asc_ship_core_model_" .. self:EntIndex() .. ".txt"
    file.Write(prefFile, tostring(self.selectedModelIndex))
end

-- Model selection functions for player interaction
function ENT:NextModel()
    local models = self:GetCAPModels()
    self.selectedModelIndex = self.selectedModelIndex + 1
    if self.selectedModelIndex > #models then
        self.selectedModelIndex = 1
    end
    self:ApplySelectedModel()
end

function ENT:PreviousModel()
    local models = self:GetCAPModels()
    self.selectedModelIndex = self.selectedModelIndex - 1
    if self.selectedModelIndex < 1 then
        self.selectedModelIndex = #models
    end
    self:ApplySelectedModel()
end

function ENT:SetModelByIndex(index)
    local models = self:GetCAPModels()
    if index >= 1 and index <= #models then
        self.selectedModelIndex = index
        self:ApplySelectedModel()
        return true
    end
    return false
end

function ENT:GetModelInfo()
    local models = self:GetCAPModels()
    local info = {
        currentIndex = self.selectedModelIndex,
        totalModels = #models,
        models = {}
    }

    for i, modelData in ipairs(models) do
        local name = type(modelData) == "table" and modelData.name or "Model " .. i
        local category = type(modelData) == "table" and modelData.category or "Default"
        table.insert(info.models, {
            index = i,
            name = name,
            category = category,
            selected = (i == self.selectedModelIndex)
        })
    end

    return info
end

-- Optimized entity scanning using advanced optimization system
function ENT:OptimizedEntityScan()
    if not self.ship then return end

    -- Use optimization system if available
    if ASC and ASC.ShipCore and ASC.ShipCore.Optimization then
        local entities = ASC.ShipCore.Optimization.FindEntitiesInRadius(self:GetPos(), 2000)

        -- Queue entities for incremental processing
        local coreId = self:EntIndex()
        if not ASC.ShipCore.Optimization.IncrementalDetection.queues[coreId] then
            ASC.ShipCore.Optimization.IncrementalDetection.queues[coreId] = {}
        end

        -- Add new entities to queue (avoid duplicates)
        local queue = ASC.ShipCore.Optimization.IncrementalDetection.queues[coreId]
        for _, entity in ipairs(entities) do
            if IsValid(entity) and entity ~= self then
                local found = false
                for _, queuedEnt in ipairs(queue) do
                    if queuedEnt == entity then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(queue, entity)
                end
            end
        end
    else
        -- Fallback to standard scanning
        self:RealTimeEntityScan()
    end
end

-- Create optimized ship using advanced detection algorithms
function ENT:CreateOptimizedShip()
    if not HYPERDRIVE.ShipCore then return nil end

    -- Use optimization system for initial ship creation
    if ASC and ASC.ShipCore and ASC.ShipCore.Optimization then
        -- Create ship with optimized entity detection
        local ship = HYPERDRIVE.ShipCore.CreateShip(self)

        if ship then
            -- Initialize incremental detection queue for this ship
            local coreId = self:EntIndex()
            ASC.ShipCore.Optimization.IncrementalDetection.queues[coreId] = {}

            -- Mark this core's relationships as dirty for mapping
            ASC.ShipCore.Optimization.RelationshipMap.dirtyEntities[coreId] = true

            print("[ASC Ship Core] Ship created with optimization system - Core ID: " .. coreId)
        end

        return ship
    else
        -- Fallback to standard ship creation
        return HYPERDRIVE.ShipCore.CreateShip(self)
    end
end

-- Optimized constraint checking using cache
function ENT:IsEntityConstrainedToShip(entity)
    if not IsValid(entity) then return false end

    -- Use optimization system if available
    if ASC and ASC.ShipCore and ASC.ShipCore.Optimization then
        return ASC.ShipCore.Optimization.IsEntityPartOfShip(self, entity)
    else
        -- Fallback to standard constraint checking
        if not self.ship or not self.ship.entities then return false end

        local constraints = constraint.GetAllConstrainedEntities(entity)
        if not constraints then return false end

        for constrainedEnt, _ in pairs(constraints) do
            if IsValid(constrainedEnt) then
                if constrainedEnt == self then return true end

                for _, shipEnt in ipairs(self.ship.entities) do
                    if constrainedEnt == shipEnt then return true end
                end
            end
        end

        return false
    end
end

-- CAP technology ambient sound selection - REMOVED per user request

-- Enhanced Power Management System
function ENT:UpdatePowerManagement()
    if not self.PowerManagement then return end

    local pm = self.PowerManagement
    local totalAllocated = 0

    -- Calculate total power allocation with error handling
    for system, data in pairs(pm.powerDistribution or {}) do
        if data and data.active and data.allocated then
            totalAllocated = totalAllocated + (data.allocated or 0)
        end
    end

    -- Ensure valid power values
    pm.availablePower = pm.availablePower or pm.totalPower or 1000
    pm.powerEfficiency = math.max(0.1, math.min(2.0, pm.powerEfficiency or 1.0))

    -- Handle power shortage
    if totalAllocated > pm.availablePower then
        self:HandlePowerShortage()
    end

    -- Update heat generation based on power usage
    pm.heatGeneration = totalAllocated * 0.1 * (2 - pm.powerEfficiency)

    -- Update thermal management
    self:UpdateThermalManagement()

    -- Update subsystem efficiency based on power and heat
    self:UpdateSubsystemEfficiency()
end

function ENT:HandlePowerShortage()
    local pm = self.PowerManagement
    local totalAllocated = 0

    -- Calculate current allocation
    for system, data in pairs(pm.powerDistribution) do
        if data.active then
            totalAllocated = totalAllocated + data.allocated
        end
    end

    if totalAllocated <= pm.availablePower then return end

    -- Sort systems by priority (lower number = higher priority)
    local sortedSystems = {}
    for system, data in pairs(pm.powerDistribution) do
        if data.active then
            table.insert(sortedSystems, {name = system, data = data})
        end
    end

    table.sort(sortedSystems, function(a, b) return a.data.priority < b.data.priority end)

    -- Reduce power to lower priority systems
    local powerToReduce = totalAllocated - pm.availablePower

    for i = #sortedSystems, 1, -1 do
        local system = sortedSystems[i]
        local reduction = math.min(powerToReduce, system.data.allocated * 0.5)
        system.data.allocated = system.data.allocated - reduction
        powerToReduce = powerToReduce - reduction

        if powerToReduce <= 0 then break end
    end

    -- Enter emergency mode if still insufficient power
    if powerToReduce > 0 then
        pm.emergencyMode = true
        self:SetStatusMessage("EMERGENCY: Insufficient power for critical systems!")
    end
end

function ENT:UpdateThermalManagement()
    if not self.ThermalManagement or not self.PowerManagement then return end

    local tm = self.ThermalManagement
    local pm = self.PowerManagement

    -- Calculate heat generation with error handling
    local heatGenerated = pm.heatGeneration or 0

    -- Add heat from damaged subsystems
    if self.SubsystemManagement and self.SubsystemManagement.subsystems then
        for name, subsystem in pairs(self.SubsystemManagement.subsystems) do
            if subsystem and subsystem.health and subsystem.health < 100 then
                heatGenerated = heatGenerated + (100 - subsystem.health) * 0.2
            end
        end
    end

    -- Calculate cooling with safe values
    local coolingEffective = (tm.coolingRate or 5) * (tm.thermalEfficiency or 1.0)

    -- Update temperature with bounds checking
    local tempChange = (heatGenerated - coolingEffective) * 0.1
    tm.coreTemperature = math.max(20, (tm.coreTemperature or 20) + tempChange)

    -- Ensure valid temperature values
    tm.maxTemperature = tm.maxTemperature or 100
    tm.criticalTemperature = tm.criticalTemperature or 150

    -- Handle overheating
    if tm.coreTemperature > tm.maxTemperature then
        tm.overheating = true
        pm.powerEfficiency = math.max(0.5, 1.0 - (tm.coreTemperature - tm.maxTemperature) / 100)

        if tm.coreTemperature > tm.criticalTemperature then
            self:HandleCriticalOverheating()
        end
    else
        tm.overheating = false
        pm.powerEfficiency = math.min(pm.powerEfficiency or 1.0, 1.0)
    end
end

function ENT:HandleCriticalOverheating()
    -- Emergency shutdown of non-critical systems
    local pm = self.PowerManagement

    for system, data in pairs(pm.powerDistribution) do
        if system ~= "lifesupport" and system ~= "shields" then
            data.allocated = data.allocated * 0.5
        end
    end

    self:SetStatusMessage("CRITICAL: Core overheating! Emergency power reduction!")
    self:SetState(4) -- Emergency state
end

function ENT:UpdateSubsystemEfficiency()
    if not self.SubsystemManagement then return end

    local sm = self.SubsystemManagement
    local tm = self.ThermalManagement

    for name, subsystem in pairs(sm.subsystems) do
        -- Calculate efficiency based on health and temperature
        local healthFactor = subsystem.health / 100
        local tempFactor = math.max(0.5, 1.0 - math.max(0, tm.coreTemperature - 50) / 100)

        subsystem.efficiency = healthFactor * tempFactor

        -- Auto-repair if enabled
        if sm.autoRepair and subsystem.health < 100 then
            subsystem.health = math.min(100, subsystem.health + sm.repairRate * 0.1)
        end
    end
end

function ENT:SetPowerAllocation(system, amount)
    if not self.PowerManagement or not self.PowerManagement.powerDistribution[system] then
        return false
    end

    self.PowerManagement.powerDistribution[system].allocated = math.max(0, amount)
    self:UpdatePowerManagement()
    return true
end

function ENT:GetPowerAllocation(system)
    if not self.PowerManagement or not self.PowerManagement.powerDistribution[system] then
        return 0
    end

    return self.PowerManagement.powerDistribution[system].allocated
end

function ENT:SetSystemPriority(system, priority)
    if not self.PowerManagement or not self.PowerManagement.powerDistribution[system] then
        return false
    end

    self.PowerManagement.powerDistribution[system].priority = priority
    return true
end

function ENT:GetSystemEfficiency(system)
    if not self.SubsystemManagement or not self.SubsystemManagement.subsystems[system] then
        return 1.0
    end

    return self.SubsystemManagement.subsystems[system].efficiency
end

function ENT:DamageSubsystem(system, damage)
    if not self.SubsystemManagement or not self.SubsystemManagement.subsystems[system] then
        return false
    end

    local subsystem = self.SubsystemManagement.subsystems[system]
    subsystem.health = math.max(0, subsystem.health - damage)

    if subsystem.health <= 0 and subsystem.critical then
        self:HandleCriticalSystemFailure(system)
    end

    return true
end

function ENT:HandleCriticalSystemFailure(system)
    if system == "reactor" then
        self:SetState(4) -- Emergency
        self:SetStatusMessage("CRITICAL: Reactor failure! Emergency protocols activated!")
    elseif system == "powerGrid" then
        if self.PowerManagement and self.PowerManagement.availablePower then
            self.PowerManagement.availablePower = self.PowerManagement.availablePower * 0.5
        end
        self:SetStatusMessage("CRITICAL: Power grid failure! Power reduced!")
    elseif system == "lifesupport" then
        self:SetStatusMessage("CRITICAL: Life support failure! Seek immediate assistance!")
    end
end

-- Crew Efficiency System (inspired by FTL and Star Citizen)
function ENT:UpdateCrewEfficiency()
    if not self.ship then return end

    -- Initialize crew efficiency system if not exists
    if not self.CrewEfficiency then
        self.CrewEfficiency = {
            totalCrew = 0,
            skillLevels = {},
            systemBonuses = {},
            overallEfficiency = 1.0,
            experienceGain = 0.1
        }
    end

    local crew = self.CrewEfficiency
    local playersOnShip = {}

    -- Find players on ship
    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and self:IsPlayerOnShip(ply) then
            table.insert(playersOnShip, ply)
        end
    end

    crew.totalCrew = #playersOnShip

    -- Calculate crew bonuses based on player skills and presence
    if crew.totalCrew > 0 then
        -- Engineering bonus (improves power efficiency)
        local engineeringBonus = math.min(1.5, 1.0 + (crew.totalCrew * 0.1))
        if self.PowerManagement and self.PowerManagement.powerEfficiency then
            self.PowerManagement.powerEfficiency = self.PowerManagement.powerEfficiency * engineeringBonus
        end

        -- Repair bonus (improves subsystem repair rate)
        local repairBonus = math.min(2.0, 1.0 + (crew.totalCrew * 0.15))
        if self.SubsystemManagement and self.SubsystemManagement.repairRate then
            self.SubsystemManagement.repairRate = self.SubsystemManagement.repairRate * repairBonus
        end

        -- Tactical bonus (improves system response time)
        local tacticalBonus = math.min(1.3, 1.0 + (crew.totalCrew * 0.05))

        -- Store bonuses for UI display
        crew.systemBonuses = {
            engineering = engineeringBonus,
            repair = repairBonus,
            tactical = tacticalBonus
        }

        crew.overallEfficiency = (engineeringBonus + repairBonus + tacticalBonus) / 3
    else
        -- No crew penalties
        crew.systemBonuses = {
            engineering = 0.8, -- Reduced efficiency without crew
            repair = 0.5,      -- Slower repairs
            tactical = 0.7     -- Slower response
        }
        crew.overallEfficiency = 0.67
    end

    -- Update network variables for UI
    self:SetNWInt("CrewCount", crew.totalCrew)
    self:SetNWFloat("CrewEfficiency", crew.overallEfficiency)
end

function ENT:IsPlayerOnShip(ply)
    if not IsValid(ply) or not self.ship then return false end

    local playerPos = ply:GetPos()
    local shipCenter = self.ship:GetCenter()

    -- Calculate ship radius from entities if GetRadius doesn't exist
    local shipRadius = 1000 -- Default radius
    if self.ship.GetRadius then
        shipRadius = self.ship:GetRadius()
    elseif self.ship.GetEntities then
        -- Calculate radius from ship entities
        local entities = self.ship:GetEntities()
        if entities and #entities > 0 then
            local maxDist = 0
            for _, ent in ipairs(entities) do
                if IsValid(ent) then
                    local dist = shipCenter:Distance(ent:GetPos())
                    if dist > maxDist then
                        maxDist = dist
                    end
                end
            end
            shipRadius = math.max(500, maxDist + 200) -- Add buffer
        end
    end

    -- Check if player is within ship bounds
    if playerPos:Distance(shipCenter) > shipRadius then return false end

    -- Check if player is on a ship entity
    local standingOn = ply:GetGroundEntity()
    if IsValid(standingOn) then
        if self.ship.GetEntities then
            for _, shipEnt in ipairs(self.ship:GetEntities()) do
                if standingOn == shipEnt then
                    return true
                end
            end
        end
    end

    -- Alternative check: if player is close to ship core
    if playerPos:Distance(self:GetPos()) < 500 then
        return true
    end

    return false
end

-- Advanced Resource Management with Power Dependencies
function ENT:UpdateBasicResourceRegeneration()
    if not self.BasicResourceStorage then return end

    local powerEfficiency = self.PowerManagement and self.PowerManagement.powerEfficiency or 1.0
    local crewEfficiency = self.CrewEfficiency and self.CrewEfficiency.overallEfficiency or 1.0

    for resourceType, resource in pairs(self.BasicResourceStorage) do
        if resource.regenRate > 0 then
            -- Apply power and crew efficiency to regeneration
            local effectiveRegenRate = resource.regenRate * powerEfficiency * crewEfficiency

            -- Reduce regeneration if systems are damaged
            if self.SubsystemManagement then
                local systemHealth = self.SubsystemManagement.subsystems.lifesupport and
                                   self.SubsystemManagement.subsystems.lifesupport.health or 100
                effectiveRegenRate = effectiveRegenRate * (systemHealth / 100)
            end

            resource.amount = math.min(resource.capacity, resource.amount + effectiveRegenRate)
        end

        -- Handle critical resource shortages
        if resource.critical and resource.amount < resource.capacity * 0.1 then
            self:HandleCriticalResourceShortage(resourceType)
        end
    end
end

function ENT:HandleCriticalResourceShortage(resourceType)
    if resourceType == "energy" then
        self:SetStatusMessage("CRITICAL: Energy reserves depleted!")
        if self.PowerManagement and self.PowerManagement.availablePower then
            self.PowerManagement.availablePower = self.PowerManagement.availablePower * 0.7
        end
    elseif resourceType == "oxygen" then
        self:SetStatusMessage("CRITICAL: Oxygen shortage detected!")
        -- Damage life support system
        if self.SubsystemManagement and self.SubsystemManagement.subsystems and
           self.SubsystemManagement.subsystems.lifesupport and
           self.SubsystemManagement.subsystems.lifesupport.health then
            self.SubsystemManagement.subsystems.lifesupport.health =
                self.SubsystemManagement.subsystems.lifesupport.health - 5
        end
    elseif resourceType == "coolant" then
        self:SetStatusMessage("CRITICAL: Coolant shortage! Overheating risk!")
        if self.ThermalManagement and self.ThermalManagement.coolingRate then
            self.ThermalManagement.coolingRate = self.ThermalManagement.coolingRate * 0.5
        end
    end
end

-- Console commands for model selection
concommand.Add("aria_ship_core_next_model", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local core = ply:GetEyeTrace().Entity
    if IsValid(core) and core:GetClass() == "asc_ship_core" then
        core:NextModel()
        local modelName = core:GetNWString("SelectedModelName", "Unknown")
        ply:ChatPrint("[ASC Ship Core] Model changed to: " .. modelName)
    else
        ply:ChatPrint("[ASC Ship Core] Look at a ship core to change its model")
    end
end, nil, "Change ship core to next model")

concommand.Add("aria_ship_core_prev_model", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local core = ply:GetEyeTrace().Entity
    if IsValid(core) and core:GetClass() == "asc_ship_core" then
        core:PreviousModel()
        local modelName = core:GetNWString("SelectedModelName", "Unknown")
        ply:ChatPrint("[ASC Ship Core] Model changed to: " .. modelName)
    else
        ply:ChatPrint("[ASC Ship Core] Look at a ship core to change its model")
    end
end, nil, "Change ship core to previous model")

concommand.Add("aria_ship_core_set_model", function(ply, cmd, args)
    if not IsValid(ply) then return end
    if #args < 1 then
        ply:ChatPrint("[ASC Ship Core] Usage: aria_ship_core_set_model <model_index>")
        return
    end

    local index = tonumber(args[1])
    if not index then
        ply:ChatPrint("[ASC Ship Core] Invalid model index")
        return
    end

    local core = ply:GetEyeTrace().Entity
    if IsValid(core) and core:GetClass() == "asc_ship_core" then
        if core:SetModelByIndex(index) then
            local modelName = core:GetNWString("SelectedModelName", "Unknown")
            ply:ChatPrint("[ASC Ship Core] Model changed to: " .. modelName)
        else
            ply:ChatPrint("[ASC Ship Core] Invalid model index: " .. index)
        end
    else
        ply:ChatPrint("[ASC Ship Core] Look at a ship core to change its model")
    end
end, nil, "Set ship core model by index")

concommand.Add("aria_ship_core_list_models", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local core = ply:GetEyeTrace().Entity
    if IsValid(core) and core:GetClass() == "asc_ship_core" then
        local info = core:GetModelInfo()
        ply:ChatPrint("[ASC Ship Core] Available models (" .. info.totalModels .. " total):")

        for _, modelData in ipairs(info.models) do
            local prefix = modelData.selected and ">>> " or "    "
            ply:ChatPrint(prefix .. modelData.index .. ". " .. modelData.name .. " (" .. modelData.category .. ")")
        end
    else
        ply:ChatPrint("[ASC Ship Core] Look at a ship core to list its models")
    end
end, nil, "List available ship core models")

-- Performance optimization functions
function ENT:GetAdaptiveThinkRate()
    -- Check performance every few seconds
    local currentTime = CurTime()
    if currentTime - self.LastPerformanceCheck > self.PerformanceCheckInterval then
        self:CheckPerformance()
        self.LastPerformanceCheck = currentTime
    end

    -- Adaptive think rates based on performance
    if self.PerformanceMode then
        return 0.1 -- 10 FPS in performance mode
    else
        local fps = self:GetCurrentFPS()
        if fps < 30 then
            return 0.05 -- 20 FPS for low performance
        elseif fps < 45 then
            return 0.033 -- 30 FPS for medium performance
        else
            return 0.02 -- 50 FPS for good performance
        end
    end
end

function ENT:CheckPerformance()
    local frameTime = FrameTime()

    -- Track frame time history
    table.insert(self.FrameTimeHistory, frameTime)
    if #self.FrameTimeHistory > self.MaxFrameHistory then
        table.remove(self.FrameTimeHistory, 1)
    end

    -- Calculate average FPS
    local avgFrameTime = 0
    for _, ft in ipairs(self.FrameTimeHistory) do
        avgFrameTime = avgFrameTime + ft
    end
    avgFrameTime = avgFrameTime / #self.FrameTimeHistory

    local avgFPS = 1 / avgFrameTime

    -- Enable performance mode if FPS is consistently low
    if avgFPS < 25 and not self.PerformanceMode then
        self:EnablePerformanceMode()
    elseif avgFPS > 40 and self.PerformanceMode then
        self:DisablePerformanceMode()
    end
end

function ENT:GetCurrentFPS()
    if #self.FrameTimeHistory > 0 then
        local avgFrameTime = 0
        for _, ft in ipairs(self.FrameTimeHistory) do
            avgFrameTime = avgFrameTime + ft
        end
        avgFrameTime = avgFrameTime / #self.FrameTimeHistory
        return 1 / avgFrameTime
    end
    return 60 -- Default assumption
end

function ENT:EnablePerformanceMode()
    if self.PerformanceMode then return end

    self.PerformanceMode = true

    -- Reduce update frequencies even further for performance mode
    self.EntityScanRate = 5.0 -- 0.2 FPS
    self.ResourceUpdateRate = 3.0 -- 0.33 FPS
    self.SystemCheckRate = 10.0 -- 0.1 FPS
    self.NetworkUpdateRate = 2.0 -- 0.5 FPS

    -- Auto-weld system removed

    print("[ASC Ship Core] Performance mode enabled - reduced update rates")

    -- Notify owner
    local owner = self.CPPIGetOwner and self:CPPIGetOwner() or nil
    if IsValid(owner) then
        owner:ChatPrint("[ASC Ship Core] Performance mode enabled due to low FPS")
    end
end

function ENT:DisablePerformanceMode()
    if not self.PerformanceMode then return end

    self.PerformanceMode = false

    -- Restore optimized update frequencies (still reduced from original for better performance)
    self.EntityScanRate = 2.0 -- 0.5 FPS
    self.ResourceUpdateRate = 1.0 -- 1 FPS
    self.SystemCheckRate = 3.0 -- 0.33 FPS
    self.NetworkUpdateRate = 1.0 -- 1 FPS

    print("[ASC Ship Core] Performance mode disabled - restored optimized update rates")

    -- Notify owner
    local owner = self.CPPIGetOwner and self:CPPIGetOwner() or nil
    if IsValid(owner) then
        owner:ChatPrint("[ASC Ship Core] Performance mode disabled - using optimized rates")
    end
end
