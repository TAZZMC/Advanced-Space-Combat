-- Ship Core Entity - Server
-- Mandatory ship core for Enhanced Hyperdrive System v2.0

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

-- Network strings for UI
util.AddNetworkString("ship_core_open_ui")
util.AddNetworkString("ship_core_update_ui")
util.AddNetworkString("ship_core_command")
util.AddNetworkString("ship_core_close_ui")
util.AddNetworkString("ship_core_name_dialog")

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:SetMaterial("models/debug/debugwhite")
    self:SetColor(Color(50, 150, 255))

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

    -- Load ship name from file
    self:LoadShipName()

    -- Initialize systems
    timer.Simple(1, function()
        if IsValid(self) then
            self:InitializeSystems()
        end
    end)

    print("[Ship Core] Ship core initialized at " .. tostring(self:GetPos()))
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
            print("[Ship Core] Resource system initialized")
        else
            print("[Ship Core] Resource system initialization failed")
        end
    end

    -- Initialize hull damage system
    if HYPERDRIVE.HullDamage and self.ship then
        local hull, message = HYPERDRIVE.HullDamage.CreateHullSystem(self.ship, self)
        if hull then
            self:SetHullSystemActive(true)
            print("[Ship Core] Hull damage system initialized: " .. message)
        else
            print("[Ship Core] Hull damage system failed: " .. message)
        end
    end

    -- Initialize shield system
    if HYPERDRIVE.Shields and self.ship then
        local shield, message = HYPERDRIVE.Shields.CreateShield(self, self.ship)
        if shield then
            self:SetShieldSystemActive(true)
            print("[Ship Core] Shield system initialized: " .. message)
        else
            print("[Ship Core] Shield system failed: " .. message)
        end
    end

    -- Initialize CAP integration
    self:InitializeCAPIntegration()
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

    print("[Ship Core] CAP integration initialized for core " .. self:EntIndex())
end

function ENT:Think()
    local currentTime = CurTime()

    if currentTime - self.lastUpdate > self.updateInterval then
        self.lastUpdate = currentTime
        self:UpdateSystems()
        self:UpdateUI()
    end

    self:NextThink(currentTime + 0.1)
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

    -- Update core state
    self:UpdateCoreState()
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
    if not HYPERDRIVE.ShipCore then return end

    -- Get ship for this core
    local ship = HYPERDRIVE.ShipCore.GetShipByEntity(self)

    if ship then
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
    else
        self.ship = nil
        self:SetShipDetected(false)
        self:SetShipType("No Ship")
        self:SetCoreValid(false)
        self:SetStatusMessage("No ship detected")
    end
end

function ENT:UpdateHullSystem()
    if not HYPERDRIVE.HullDamage or not self.ship then
        self:SetHullSystemActive(false)
        self:SetHullIntegrity(100)
        return
    end

    local hullStatus = HYPERDRIVE.HullDamage.GetHullStatus(self)
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
end

function ENT:UpdateShieldSystem()
    if not HYPERDRIVE.Shields or not self.ship then
        self:SetShieldSystemActive(false)
        self:SetShieldStrength(0)
        return
    end

    local shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(self)
    if shieldStatus then
        self:SetShieldSystemActive(shieldStatus.available)
        self:SetShieldStrength(math.floor(shieldStatus.strengthPercent or 0))
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

function ENT:UpdateResourceNetworkVars()
    if not HYPERDRIVE.SB3Resources then return end

    local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
    if not storage then return end

    -- Update energy levels for wire outputs
    local energyAmount = HYPERDRIVE.SB3Resources.GetResourceAmount(self, "energy")
    local energyCapacity = storage.capacity.energy or 1
    local energyPercentage = (energyAmount / energyCapacity) * 100

    -- Set network variables for resource levels
    self:SetNWFloat("ResourceEnergy", energyPercentage)
    self:SetNWFloat("ResourceOxygen", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "oxygen"))
    self:SetNWFloat("ResourceCoolant", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "coolant"))
    self:SetNWFloat("ResourceFuel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "fuel"))
    self:SetNWFloat("ResourceWater", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "water"))
    self:SetNWFloat("ResourceNitrogen", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "nitrogen"))

    -- Check for emergency mode
    local emergencyMode = storage.emergencyMode and 1 or 0
    self:SetNWInt("ResourceEmergencyMode", emergencyMode)

    -- Update wire outputs if wiremod is available
    if WireLib then
        WireLib.TriggerOutput(self, "EnergyLevel", energyPercentage)
        WireLib.TriggerOutput(self, "OxygenLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "oxygen"))
        WireLib.TriggerOutput(self, "CoolantLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "coolant"))
        WireLib.TriggerOutput(self, "FuelLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "fuel"))
        WireLib.TriggerOutput(self, "WaterLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "water"))
        WireLib.TriggerOutput(self, "NitrogenLevel", HYPERDRIVE.SB3Resources.GetResourcePercentage(self, "nitrogen"))
        WireLib.TriggerOutput(self, "ResourceEmergency", emergencyMode)
        WireLib.TriggerOutput(self, "ResourceSystemActive", self:GetNWBool("ResourceSystemActive", false) and 1 or 0)
        WireLib.TriggerOutput(self, "AutoProvisionEnabled", self:GetNWBool("AutoProvisionEnabled", true) and 1 or 0)
        WireLib.TriggerOutput(self, "WeldDetectionEnabled", self:GetNWBool("WeldDetectionEnabled", true) and 1 or 0)
        WireLib.TriggerOutput(self, "LastResourceActivity", self:GetNWString("LastResourceActivity", ""))

        -- Calculate total resource capacity and amount
        local totalCapacity = 0
        local totalAmount = 0
        local distributionRate = 0
        local collectionRate = 0
        for _, resourceType in ipairs({"energy", "oxygen", "coolant", "fuel", "water", "nitrogen"}) do
            totalCapacity = totalCapacity + (storage.capacity[resourceType] or 0)
            totalAmount = totalAmount + (storage.resources[resourceType] or 0)
        end
        distributionRate = storage.distributionRate or 0
        collectionRate = storage.collectionRate or 0

        WireLib.TriggerOutput(self, "TotalResourceCapacity", totalCapacity)
        WireLib.TriggerOutput(self, "TotalResourceAmount", totalAmount)
        WireLib.TriggerOutput(self, "ResourceDistributionRate", distributionRate)
        WireLib.TriggerOutput(self, "ResourceCollectionRate", collectionRate)
    end
end

function ENT:UpdateCoreState()
    if not self:GetCoreValid() then
        self:SetState(self.States.INVALID)
        return
    end

    if not self:GetShipDetected() then
        self:SetState(self.States.INACTIVE)
        self:SetStatusMessage("No ship detected")
        return
    end

    local hullIntegrity = self:GetHullIntegrity()

    if hullIntegrity < 10 then
        self:SetState(self.States.EMERGENCY)
        self:SetStatusMessage("EMERGENCY: Hull " .. hullIntegrity .. "%")
    elseif hullIntegrity < 25 then
        self:SetState(self.States.CRITICAL)
        self:SetStatusMessage("CRITICAL: Hull " .. hullIntegrity .. "%")
    else
        self:SetState(self.States.ACTIVE)
        self:SetStatusMessage("Operational")
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Get interface configuration
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or {}

    -- Check if USE key interfaces are enabled
    if not config.EnableUSEKeyInterfaces then
        if config.EnableFeedbackMessages then
            activator:ChatPrint("[Ship Core] Interface access is disabled")
        end
        return
    end

    -- Check distance
    local maxDistance = config.MaxInteractionDistance or 200
    if config.EnableDistanceChecking and self:GetPos():Distance(activator:GetPos()) > maxDistance then
        if config.EnableFeedbackMessages then
            activator:ChatPrint("[Ship Core] Too far away to access interface (max " .. maxDistance .. " units)")
        end
        return
    end

    -- Check session limits
    if config.EnableSessionTracking then
        local activeSessions = HYPERDRIVE.Interface.ActiveSessions[activator] or 0
        local maxSessions = config.MaxConcurrentSessions or 10
        if activeSessions >= maxSessions then
            if config.EnableFeedbackMessages then
                activator:ChatPrint("[Ship Core] Too many active interface sessions")
            end
            return
        end
    end

    -- Open ship core UI
    self:OpenUI(activator)

    -- Provide feedback
    if config.EnableFeedbackMessages then
        activator:ChatPrint("[Ship Core] Opening ship management interface...")
    end

    -- Track session
    if config.EnableSessionTracking then
        HYPERDRIVE.Interface.ActiveSessions[activator] = (HYPERDRIVE.Interface.ActiveSessions[activator] or 0) + 1
    end
end

function ENT:OpenUI(ply)
    if not IsValid(ply) then return end

    -- Track active UI
    self.activeUIs[ply] = true

    -- Send UI data
    net.Start("ship_core_open_ui")
    net.WriteEntity(self)
    net.WriteTable(self:GetUIData())
    net.Send(ply)

    print("[Ship Core] UI opened for " .. ply:Nick())
end

function ENT:GetUIData()
    local data = {
        -- Core information
        corePos = self:GetPos(),
        coreState = self:GetState(),
        coreStateName = self:GetStateName(),
        coreValid = self:GetCoreValid(),
        statusMessage = self:GetStatusMessage(),

        -- Ship information
        shipDetected = self:GetShipDetected(),
        shipType = self:GetShipType(),
        shipName = self:GetShipName(),
        shipCenter = self:GetShipCenter(),
        frontDirection = self:GetFrontDirection(),

        -- Hull system
        hullSystemActive = self:GetHullSystemActive(),
        hullIntegrity = self:GetHullIntegrity(),

        -- Shield system
        shieldSystemActive = self:GetShieldSystemActive(),
        shieldStrength = self:GetShieldStrength(),

        -- Resource system (Spacebuild 3)
        resourceSystemActive = HYPERDRIVE.SB3Resources ~= nil and self:GetNWBool("ResourceSystemActive", false),
        resourceEnergy = self:GetNWFloat("ResourceEnergy", 0),
        resourceOxygen = self:GetNWFloat("ResourceOxygen", 0),
        resourceCoolant = self:GetNWFloat("ResourceCoolant", 0),
        resourceFuel = self:GetNWFloat("ResourceFuel", 0),
        resourceWater = self:GetNWFloat("ResourceWater", 0),
        resourceNitrogen = self:GetNWFloat("ResourceNitrogen", 0),
        resourceEmergencyMode = self:GetNWInt("ResourceEmergencyMode", 0) == 1,

        -- Resource system settings
        autoProvisionEnabled = self:GetNWBool("AutoProvisionEnabled", true),
        weldDetectionEnabled = self:GetNWBool("WeldDetectionEnabled", true),
        lastResourceActivity = self:GetNWString("LastResourceActivity", ""),

        -- CAP integration data
        capIntegrationActive = self:GetNWBool("CAPIntegrationActive", false),
        capShieldsDetected = self:GetNWBool("CAPShieldsDetected", false),
        capEnergyDetected = self:GetNWBool("CAPEnergyDetected", false),
        capResourcesDetected = self:GetNWBool("CAPResourcesDetected", false),
        capStatus = self:GetNWString("CAPStatus", "Unknown"),
        capEnergyLevel = self:GetNWFloat("CAPEnergyLevel", 0),
        capShieldCount = self:GetNWInt("CAPShieldCount", 0),
        capEntityCount = self:GetNWInt("CAPEntityCount", 0),
        capVersion = self:GetNWString("CAPVersion", "Unknown"),

        -- Additional data
        entityCount = 0,
        playerCount = 0,
        mass = 0
    }

    -- Get detailed ship information
    if self.ship then
        data.entityCount = #self.ship:GetEntities()
        data.playerCount = #self.ship:GetPlayers()
        data.mass = self.ship:GetMass()

        -- Get hull damage details
        if HYPERDRIVE.HullDamage then
            local hullStatus = HYPERDRIVE.HullDamage.GetHullStatus(self)
            if hullStatus then
                data.hullBreaches = hullStatus.breaches or 0
                data.hullSystemFailures = hullStatus.systemFailures or 0
                data.hullAutoRepair = hullStatus.autoRepairActive or false
                data.hullCriticalMode = hullStatus.criticalMode or false
                data.hullEmergencyMode = hullStatus.emergencyMode or false
            end
        end

        -- Get shield details
        if HYPERDRIVE.Shields then
            local shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(self)
            if shieldStatus then
                data.shieldActive = shieldStatus.active or false
                data.shieldRecharging = shieldStatus.recharging or false
                data.shieldOverloaded = shieldStatus.overloaded or false
                data.shieldType = shieldStatus.shieldType or "None"
            end
        end
    end

    return data
end

function ENT:UpdateUI()
    if table.Count(self.activeUIs) == 0 then return end

    local data = self:GetUIData()

    for ply, _ in pairs(self.activeUIs) do
        if IsValid(ply) then
            net.Start("ship_core_update_ui")
            net.WriteTable(data)
            net.Send(ply)
        else
            self.activeUIs[ply] = nil
        end
    end
end

function ENT:CloseUI(ply)
    if IsValid(ply) then
        self.activeUIs[ply] = nil
        net.Start("ship_core_close_ui")
        net.Send(ply)

        -- Update session tracking
        local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Interface or {}
        if config.EnableSessionTracking then
            HYPERDRIVE.Interface.ActiveSessions[ply] = math.max(0, (HYPERDRIVE.Interface.ActiveSessions[ply] or 1) - 1)
        end
    end
end

-- Handle UI commands
net.Receive("ship_core_command", function(len, ply)
    local core = net.ReadEntity()
    local command = net.ReadString()
    local data = net.ReadTable()

    if not IsValid(core) or not IsValid(ply) then return end
    if core:GetClass() ~= "ship_core" then return end

    core:HandleUICommand(ply, command, data)
end)

-- Ship name management functions
function ENT:LoadShipName()
    if file.Exists(self.shipNameFile, "DATA") then
        local nameData = file.Read(self.shipNameFile, "DATA")
        if nameData and nameData ~= "" then
            local success, result = pcall(util.JSONToTable, nameData)
            if success and result and result.shipName then
                self:SetShipName(result.shipName)
                print("[Ship Core] Loaded ship name: " .. result.shipName)
                return
            end
        end
    end

    -- Default name if no file or invalid data
    self:SetShipName("Unnamed Ship")
    print("[Ship Core] Using default ship name")
end

function ENT:SaveShipName()
    local data = {
        shipName = self:GetShipName(),
        timestamp = os.time(),
        coreIndex = self:EntIndex()
    }

    local jsonData = util.TableToJSON(data)
    if jsonData then
        file.CreateDir("hyperdrive")
        file.Write(self.shipNameFile, jsonData)
        return true
    end
    return false
end

function ENT:ValidateShipName(name)
    if not name or type(name) ~= "string" then
        return false, "Invalid name type"
    end

    -- Get configuration
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.ShipNaming or {}
    local maxLength = config.MaxNameLength or 32
    local minLength = config.MinNameLength or 1
    local pattern = config.NameValidationPattern or "^[%w%s%-_]+$"
    local reservedNames = config.ReservedNames or {}

    -- Remove whitespace
    name = string.Trim(name)

    -- Check length
    if string.len(name) < minLength then
        return false, "Name too short (minimum " .. minLength .. " characters)"
    end

    if string.len(name) > maxLength then
        return false, "Name too long (maximum " .. maxLength .. " characters)"
    end

    -- Check for valid characters
    if not string.match(name, pattern) then
        return false, "Invalid characters (use letters, numbers, spaces, hyphens, underscores only)"
    end

    -- Check reserved names
    local lowerName = string.lower(name)
    for _, reserved in ipairs(reservedNames) do
        if string.lower(reserved) == lowerName then
            return false, "Name '" .. name .. "' is reserved and cannot be used"
        end
    end

    -- Check uniqueness if enabled
    if config.ValidateNameUniqueness then
        for _, ent in ipairs(ents.GetAll()) do
            if IsValid(ent) and ent:GetClass() == "ship_core" and ent ~= self then
                if ent.GetShipName and string.lower(ent:GetShipName()) == lowerName then
                    return false, "Ship name '" .. name .. "' is already in use"
                end
            end
        end
    end

    return true, name
end

function ENT:SetShipNameSafe(name, player)
    local valid, result = self:ValidateShipName(name)
    if valid then
        local oldName = self:GetShipName()
        self:SetShipName(result)
        self:SaveShipName()

        -- Update ship object if it exists
        if self.ship and self.ship.SetShipName then
            self.ship:SetShipName(result)
        end

        -- Register with global naming system
        if HYPERDRIVE.ShipNames and HYPERDRIVE.ShipNames.RegisterShip then
            HYPERDRIVE.ShipNames.RegisterShip(self, result)
        end

        -- Log name change if enabled
        local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.ShipNaming or {}
        if config.LogNameChanges then
            local playerName = IsValid(player) and player:Nick() or "System"
            print("[Ship Core] Ship renamed from '" .. oldName .. "' to '" .. result .. "' by " .. playerName)
        end

        -- Broadcast name change if enabled
        if config.BroadcastNameChanges and IsValid(player) then
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) then
                    ply:ChatPrint("[Ship Core] " .. player:Nick() .. " renamed ship '" .. oldName .. "' to '" .. result .. "'")
                end
            end
        end

        return true, result
    else
        return false, result
    end
end

function ENT:HandleUICommand(ply, command, data)
    if command == "repair_hull" then
        if HYPERDRIVE.HullDamage then
            local amount = data.amount or 25
            local success = HYPERDRIVE.HullDamage.RepairHull(self, amount)
            if success then
                ply:ChatPrint("[Ship Core] Hull repaired by " .. amount .. " points")
                -- Log repair action
                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Hull repaired by " .. ply:Nick() .. " (+" .. amount .. ")", "repair", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Hull repair failed")
            end
        end

    elseif command == "activate_shields" then
        if HYPERDRIVE.Shields and self.ship then
            local success = HYPERDRIVE.Shields.ActivateShield(self, self.ship)
            if success then
                ply:ChatPrint("[Ship Core] Shields activated")
                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Shields activated by " .. ply:Nick(), "shield", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Shield activation failed")
            end
        end

    elseif command == "deactivate_shields" then
        if HYPERDRIVE.Shields then
            local success = HYPERDRIVE.Shields.DeactivateShield(self)
            if success then
                ply:ChatPrint("[Ship Core] Shields deactivated")
                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Shields deactivated by " .. ply:Nick(), "shield", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Shield deactivation failed")
            end
        end

    elseif command == "toggle_front_indicator" then
        if self.ship then
            local visible = self.ship:IsFrontIndicatorVisible()
            if visible then
                self.ship:HideFrontIndicator()
                ply:ChatPrint("[Ship Core] Front indicator hidden")
            else
                self.ship:ShowFrontIndicator()
                ply:ChatPrint("[Ship Core] Front indicator shown")
            end
            if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                HYPERDRIVE.UI.AddLogEntry("Front indicator toggled by " .. ply:Nick(), "info", self:EntIndex())
            end
        end

    elseif command == "emergency_repair" then
        if HYPERDRIVE.HullDamage then
            local amount = 50 -- Emergency repair amount
            local success = HYPERDRIVE.HullDamage.RepairHull(self, amount)
            if success then
                ply:ChatPrint("[Ship Core] Emergency hull repair applied: +" .. amount .. " points")
                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Emergency repair by " .. ply:Nick() .. " (+" .. amount .. ")", "emergency", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Emergency repair failed")
            end
        end

    elseif command == "hull_status" then
        if HYPERDRIVE.HullDamage then
            local hullStatus = HYPERDRIVE.HullDamage.GetHullStatus(self)
            if hullStatus then
                ply:ChatPrint("[Ship Core] Hull Status:")
                ply:ChatPrint("  Integrity: " .. string.format("%.1f", hullStatus.integrityPercent) .. "%")
                ply:ChatPrint("  Breaches: " .. (hullStatus.breaches or 0))
                ply:ChatPrint("  System Failures: " .. (hullStatus.systemFailures or 0))
                ply:ChatPrint("  Auto-Repair: " .. (hullStatus.autoRepairActive and "Active" or "Inactive"))
            else
                ply:ChatPrint("[Ship Core] Hull damage system not available")
            end
        end

    elseif command == "ship_info" then
        if self.ship then
            ply:ChatPrint("[Ship Core] Ship Information:")
            ply:ChatPrint("  Type: " .. self.ship:GetShipType())
            ply:ChatPrint("  Entities: " .. #self.ship:GetEntities())
            ply:ChatPrint("  Players: " .. #self.ship:GetPlayers())
            ply:ChatPrint("  Mass: " .. math.floor(self.ship:GetMass()))
            local center = self.ship:GetCenter()
            ply:ChatPrint("  Center: " .. math.floor(center.x) .. ", " .. math.floor(center.y) .. ", " .. math.floor(center.z))
        else
            ply:ChatPrint("[Ship Core] No ship detected")
        end

    elseif command == "set_ship_name" then
        local newName = data.name
        if newName then
            -- Check permissions if required
            local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.ShipNaming or {}
            if config.RequireOwnershipToRename then
                -- TODO: Add ownership check when ownership system is implemented
                -- For now, allow all players to rename
            end

            local success, result = self:SetShipNameSafe(newName, ply)
            if success then
                ply:ChatPrint("[Ship Core] Ship name changed to: " .. result)
                if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                    HYPERDRIVE.UI.AddLogEntry("Ship renamed to '" .. result .. "' by " .. ply:Nick(), "info", self:EntIndex())
                end
            else
                ply:ChatPrint("[Ship Core] Name change failed: " .. result)
            end
        else
            ply:ChatPrint("[Ship Core] Invalid name provided")
        end

    elseif command == "open_name_dialog" then
        -- Send current name to client for editing
        net.Start("ship_core_name_dialog")
        net.WriteEntity(self)
        net.WriteString(self:GetShipName())
        net.Send(ply)

    elseif command == "resource_status" then
        if HYPERDRIVE.SB3Resources then
            local storage = HYPERDRIVE.SB3Resources.GetCoreStorage(self)
            if storage then
                ply:ChatPrint("[Ship Core] Resource Status:")
                for resourceType, amount in pairs(storage.resources) do
                    local capacity = storage.capacity[resourceType]
                    local percentage = (amount / capacity) * 100
                    local resourceConfig = HYPERDRIVE.SB3Resources.ResourceTypes[resourceType]
                    ply:ChatPrint("  " .. resourceConfig.name .. ": " .. math.floor(amount) .. "/" .. capacity .. " " .. resourceConfig.unit .. " (" .. string.format("%.1f", percentage) .. "%)")
                end
                if storage.emergencyMode then
                    ply:ChatPrint("  STATUS: EMERGENCY MODE ACTIVE")
                end
            else
                ply:ChatPrint("[Ship Core] Resource system not initialized")
            end
        else
            ply:ChatPrint("[Ship Core] Spacebuild 3 resource system not available")
        end

    elseif command == "resource_distribute" then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.DistributeResources(self)
            ply:ChatPrint("[Ship Core] Resource distribution initiated")
            if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                HYPERDRIVE.UI.AddLogEntry("Resource distribution by " .. ply:Nick(), "resource", self:EntIndex())
            end
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "resource_collect" then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.CollectResources(self)
            ply:ChatPrint("[Ship Core] Resource collection initiated")
            if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                HYPERDRIVE.UI.AddLogEntry("Resource collection by " .. ply:Nick(), "resource", self:EntIndex())
            end
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "resource_balance" then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.AutoBalanceResources(self)
            ply:ChatPrint("[Ship Core] Resource auto-balance initiated")
            if HYPERDRIVE.UI and HYPERDRIVE.UI.AddLogEntry then
                HYPERDRIVE.UI.AddLogEntry("Resource auto-balance by " .. ply:Nick(), "resource", self:EntIndex())
            end
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "toggle_auto_provision" then
        if HYPERDRIVE.SB3Resources then
            local currentState = self:GetNWBool("AutoProvisionEnabled", true)
            local newState = not currentState
            self:SetNWBool("AutoProvisionEnabled", newState)

            -- Update configuration if available
            if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.SB3Resources then
                HYPERDRIVE.EnhancedConfig.SB3Resources.EnableAutoResourceProvision = newState
            end

            local message = "Auto-provision " .. (newState and "enabled" or "disabled")
            ply:ChatPrint("[Ship Core] " .. message)
            self:SetNWString("LastResourceActivity", message)
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "toggle_weld_detection" then
        if HYPERDRIVE.SB3Resources then
            local currentState = self:GetNWBool("WeldDetectionEnabled", true)
            local newState = not currentState
            self:SetNWBool("WeldDetectionEnabled", newState)

            -- Update configuration if available
            if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.SB3Resources then
                HYPERDRIVE.EnhancedConfig.SB3Resources.EnableWeldDetection = newState
            end

            local message = "Weld detection " .. (newState and "enabled" or "disabled")
            ply:ChatPrint("[Ship Core] " .. message)
            self:SetNWString("LastResourceActivity", message)
        else
            ply:ChatPrint("[Ship Core] Resource system not available")
        end

    elseif command == "close_ui" then
        self:CloseUI(ply)
    end
end

-- Wire input handling
function ENT:TriggerInput(iname, value)
    if iname == "DistributeResources" and value > 0 then
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
    elseif iname == "SetEnergyCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "energy", value)
        end
    elseif iname == "SetOxygenCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "oxygen", value)
        end
    elseif iname == "SetCoolantCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "coolant", value)
        end
    elseif iname == "SetFuelCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "fuel", value)
        end
    elseif iname == "SetWaterCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "water", value)
        end
    elseif iname == "SetNitrogenCapacity" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.SetResourceCapacity(self, "nitrogen", value)
        end
    elseif iname == "ToggleAutoProvision" and value > 0 then
        local currentState = self:GetNWBool("AutoProvisionEnabled", true)
        self:SetNWBool("AutoProvisionEnabled", not currentState)
        self:SetNWString("LastResourceActivity", "Auto-provision " .. (not currentState and "enabled" or "disabled"))
    elseif iname == "ToggleWeldDetection" and value > 0 then
        local currentState = self:GetNWBool("WeldDetectionEnabled", true)
        self:SetNWBool("WeldDetectionEnabled", not currentState)
        self:SetNWString("LastResourceActivity", "Weld detection " .. (not currentState and "enabled" or "disabled"))
    elseif iname == "EmergencyResourceShutdown" and value > 0 then
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.EmergencyShutdown(self)
            self:SetNWString("LastResourceActivity", "Emergency shutdown activated")
        end
    elseif iname == "RepairHull" and value > 0 then
        if HYPERDRIVE.HullDamage then
            HYPERDRIVE.HullDamage.RepairHull(self, 25)
        end
    elseif iname == "ActivateShields" and value > 0 then
        if HYPERDRIVE.Shields and self.ship then
            HYPERDRIVE.Shields.ManualActivate(self, self.ship)
        end
    elseif iname == "DeactivateShields" and value > 0 then
        if HYPERDRIVE.Shields and self.ship then
            HYPERDRIVE.Shields.ManualDeactivate(self, self.ship)
        end
    end

    -- Update wire outputs after input processing
    if WireLib then
        self:UpdateWireOutputs()
    end
end

function ENT:OnRemove()
    -- Close all active UIs
    for ply, _ in pairs(self.activeUIs) do
        if IsValid(ply) then
            self:CloseUI(ply)
        end
    end

    -- Unregister from ship naming system
    if HYPERDRIVE.ShipNames and HYPERDRIVE.ShipNames.UnregisterShip then
        HYPERDRIVE.ShipNames.UnregisterShip(self)
    end

    -- Clean up resource storage
    if HYPERDRIVE.SB3Resources then
        local coreId = self:EntIndex()
        HYPERDRIVE.SB3Resources.CoreStorage[coreId] = nil
    end

    print("[Ship Core] Ship core removed")
end
