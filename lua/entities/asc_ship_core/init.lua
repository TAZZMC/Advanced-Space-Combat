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
util.AddNetworkString("asc_ship_core_close_ui")
util.AddNetworkString("asc_ship_core_name_dialog")
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
    end

    -- Initialize ship core data
    self.ship = nil
    self.lastUpdate = 0
    self.updateInterval = 2 -- Update every 2 seconds
    self.activeUIs = {} -- Track active UI sessions
    self.shipNameFile = "hyperdrive/ship_names_" .. self:EntIndex() .. ".txt"

    -- Initialize ambient sound system with improved sounds
    self.ambientSound = nil
    self.ambientSoundMuted = false
    self.ambientSoundVolume = 0.15  -- Even quieter by default
    self.ambientSoundPath = "ambient/atmosphere/ambience_base.wav" -- Better default sound

    -- Use CAP technology-specific ambient sounds if available
    self:SelectTechnologyAmbientSound()

    -- Load ship name from file
    self:LoadShipName()

    -- Initialize systems
    timer.Simple(1, function()
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
    self.RealTimeUpdateRate = 0.05 -- 20 FPS for real-time updates
    self.PerformanceMetrics = {}
    self.SystemAlerts = {}
    self.AlertCooldowns = {} -- Track cooldowns for different alert types
    self.AlertHistory = {} -- Track alert history to prevent spam
    self.AdminAccess = false

    -- Smart update system with adaptive intervals
    self.LastEntityScan = 0
    self.EntityScanRate = 0.1 -- Base: 10 FPS for entity scanning
    self.LastResourceUpdate = 0
    self.ResourceUpdateRate = 0.2 -- Base: 5 FPS for resource calculations
    self.LastSystemCheck = 0
    self.SystemCheckRate = 0.5 -- Base: 2 FPS for system health checks
    self.LastNetworkUpdate = 0
    self.NetworkUpdateRate = 0.1 -- Base: 10 FPS for network synchronization

    -- Smart update tracking
    self.UpdatePriorities = {
        entity_scan = 1,     -- High priority
        resource_update = 2, -- Medium priority
        system_check = 3,    -- Low priority
        network_sync = 1     -- High priority
    }

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

    -- Initialize v2.2.0 systems
    self:InitializeFleetManagement()
    self:InitializeRealTimeMonitoring()
    self:InitializePerformanceAnalytics()
    self:StartRealTimeUpdates()

    print("[ASC Ship Core] Enhanced ASC Ship Core v5.1.0 with Stargate hyperspace integration and advanced features initialized at " .. tostring(self:GetPos()))
end

-- Ambient Sound System Functions
function ENT:StartAmbientSound()
    if self.ambientSoundMuted then return end

    -- Stop existing sound if any
    self:StopAmbientSound()

    -- Create ambient sound with improved settings
    self.ambientSound = CreateSound(self, self.ambientSoundPath)
    if self.ambientSound then
        self.ambientSound:SetSoundLevel(40) -- Even quieter sound level
        self.ambientSound:PlayEx(self.ambientSoundVolume, 90) -- Lower volume and pitch for less annoyance
        print("[ASC Ship Core] Ambient sound started: " .. self.ambientSoundPath .. " (Volume: " .. self.ambientSoundVolume .. ", Level: 40)")
    end
end

function ENT:StopAmbientSound()
    if self.ambientSound then
        self.ambientSound:Stop()
        self.ambientSound = nil
        print("[ASC Ship Core] Ambient sound stopped")
    end
end

function ENT:SetAmbientSoundMuted(muted)
    self.ambientSoundMuted = muted

    if muted then
        self:StopAmbientSound()
    else
        self:StartAmbientSound()
    end

    -- Update network variable for UI
    self:SetNWBool("AmbientSoundMuted", muted)

    -- Update wire outputs
    if WireLib then
        self:UpdateWireOutputs()
    end
end

function ENT:IsAmbientSoundMuted()
    return self.ambientSoundMuted
end

function ENT:OnRemove()
    -- Clean up ambient sound
    self:StopAmbientSound()

    -- Clean up resource system
    if HYPERDRIVE.SB3Resources then
        HYPERDRIVE.SB3Resources.RemoveCoreStorage(self)
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

    -- Initialize built-in shield system (no generators needed)
    if ASC and ASC.Shields and ASC.Shields.Core and ASC.Shields.Core.Initialize then
        timer.Simple(2, function()
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

    -- Initialize flight system
    if ASC and ASC.Flight and ASC.Flight.Core and ASC.Flight.Core.Initialize then
        timer.Simple(3, function()
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

    -- Create activation effect
    timer.Simple(1, function()
        if IsValid(self) then
            local effectData = EffectData()
            effectData:SetOrigin(self:GetPos())
            effectData:SetEntity(self)
            effectData:SetScale(1)
            effectData:SetMagnitude(1)
            util.Effect("ship_core_activation", effectData)

            -- Play activation sound
            if HYPERDRIVE.Sounds then
                local playFunc = SafeAccess(HYPERDRIVE.Sounds, "PlayEffect")
                if playFunc then
                    SafeCall(playFunc, "power_up", self, {
                        volume = 0.8,
                        pitch = 100,
                        soundLevel = 75
                    })
                end
            end

            -- Start ambient sound
            self:StartAmbientSound()
        end
    end)
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

    -- Initialize weapon systems
    if HYPERDRIVE.Weapons and self.ship then
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

    -- Initialize CAP status network variables
    self:SetNWBool("CAPIntegrationActive", false)
    self:SetNWBool("CAPShieldsDetected", false)
    self:SetNWBool("CAPEnergyDetected", false)
    self:SetNWBool("CAPResourcesDetected", false)
    self:SetNWString("CAPStatus", "Detecting...")
    self:SetNWFloat("CAPEnergyLevel", 0)
    self:SetNWInt("CAPShieldCount", 0)
    self:SetNWInt("CAPEntityCount", 0)
    self:SetNWString("CAPVersion", "Unknown")

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

    -- Real-time entity scanning (10 FPS)
    if currentTime - self.LastEntityScan > self.EntityScanRate then
        self:RealTimeEntityScan()
        self.LastEntityScan = currentTime
    end

    -- Real-time resource calculations (5 FPS)
    if currentTime - self.LastResourceUpdate > self.ResourceUpdateRate then
        self:RealTimeResourceUpdate()
        self.LastResourceUpdate = currentTime
    end

    -- Real-time system health checks (2 FPS)
    if currentTime - self.LastSystemCheck > self.SystemCheckRate then
        self:RealTimeSystemCheck()
        self.LastSystemCheck = currentTime
    end

    -- Real-time network synchronization (10 FPS)
    if currentTime - self.LastNetworkUpdate > self.NetworkUpdateRate then
        self:RealTimeNetworkSync()
        self.LastNetworkUpdate = currentTime
    end

    -- Real-time monitoring updates (20 FPS)
    if currentTime - self.LastRealTimeUpdate > self.RealTimeUpdateRate then
        self:UpdateRealTimeData()
        self.LastRealTimeUpdate = currentTime
    end

    -- Legacy system updates (slower rate for compatibility)
    if currentTime - self.lastUpdate > self.updateInterval then
        self.lastUpdate = currentTime
        self:UpdateSystems()
        self:UpdateUI()
    end

    -- Continue real-time updates with high frequency
    self:NextThink(currentTime + 0.01) -- 100 FPS think rate for smooth real-time updates
    return true
end

function ENT:UpdateSystems()
    -- Update ship detection
    self:UpdateShipDetection()

    -- Update hull damage system
    self:UpdateHullSystem()

    -- Update shield system
    self:UpdateShieldSystem()

    -- Update resource system (Spacebuild 3 integration)
    self:UpdateResourceSystem()

    -- Update CAP integration
    self:UpdateCAPStatus()

    -- v2.2.1 Update new systems
    self:UpdateV221Systems()

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

    -- Get or create ship for this core
    local ship = HYPERDRIVE.ShipCore.GetShip(self)
    if not ship then
        -- Create ship with this core as the center
        ship = HYPERDRIVE.ShipCore.CreateShip(self)
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
        local muted = data.muted or false
        self:SetAmbientSoundMuted(muted)
        ply:ChatPrint("[ASC Ship Core] Ambient sound " .. (muted and "muted" or "unmuted"))

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
        ambientSoundMuted = self:IsAmbientSoundMuted()
    }

    -- Add ship data if available
    if self.ship then
        data.entityCount = #self.ship:GetEntities()
        data.shipMass = self.ship:GetMass()
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

        -- System controls
        elseif iname == "Mute" then
            self:SetAmbientSoundMuted(value > 0)
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
        self:TriggerOutput("AmbientSoundMuted", self:IsAmbientSoundMuted() and 1 or 0)

        if self.ship then
            self:TriggerOutput("EntityCount", #self.ship:GetEntities())
            self:TriggerOutput("ShipMass", self.ship:GetMass())
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

    -- Initialize basic resource storage
    self.BasicResourceStorage = {
        energy = { amount = 1000, capacity = 1000, regenRate = 10 },
        oxygen = { amount = 500, capacity = 500, regenRate = 5 },
        coolant = { amount = 200, capacity = 200, regenRate = 2 },
        fuel = { amount = 300, capacity = 300, regenRate = 0 }, -- Fuel doesn't regenerate
        water = { amount = 150, capacity = 150, regenRate = 1 },
        nitrogen = { amount = 100, capacity = 100, regenRate = 1 }
    }

    -- Set initial network variables
    self:UpdateBasicResourceNetworkVars()

    -- Start basic resource regeneration timer
    self:StartBasicResourceRegeneration()

    self:SetNWString("LastResourceActivity", "Enhanced basic system initialized")
    print("[ASC Ship Core] Enhanced basic resource system initialized")
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
        self:SetNWFloat("ShipMass", self.ship:GetMass())
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
        "models/props_combine/combine_core.mdl",
        "models/hunter/blocks/cube025x025x025.mdl",
        "models/props_lab/huladoll.mdl"
    }

    -- Add CAP models if available
    if HYPERDRIVE.CAP and HYPERDRIVE.CAP.Models then
        local capModels = HYPERDRIVE.CAP.Models.GetShipCoreModels()
        if capModels then
            for _, model in ipairs(capModels) do
                table.insert(models, model)
            end
        end
    end

    return models
end

function ENT:ApplySelectedModel()
    local models = self:GetCAPModels()
    if models and models[self.selectedModelIndex] then
        self:SetModel(models[self.selectedModelIndex])
        print("[ASC Ship Core] Applied model: " .. models[self.selectedModelIndex])
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

-- CAP technology ambient sound selection
function ENT:SelectTechnologyAmbientSound()
    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Sounds then
        return
    end

    -- Try to detect nearby CAP technology
    local nearbyEnts = ents.FindInSphere(self:GetPos(), 1000)
    local detectedTech = nil

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and HYPERDRIVE.CAP.GetEntityCategory then
            local category = HYPERDRIVE.CAP.GetEntityCategory(ent:GetClass())
            if category then
                detectedTech = category
                break
            end
        end
    end

    -- Select appropriate ambient sound based on detected technology
    if detectedTech then
        local techSounds = HYPERDRIVE.CAP.Sounds.GetTechnologySounds(detectedTech)
        if techSounds and techSounds.ambient then
            self.ambientSoundPath = techSounds.ambient
            print("[ASC Ship Core] Selected " .. detectedTech .. " ambient sound: " .. self.ambientSoundPath)
        end
    end
end
