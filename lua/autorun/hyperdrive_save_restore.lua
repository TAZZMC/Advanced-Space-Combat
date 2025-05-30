-- Hyperdrive Save/Restore System
-- Handles safe serialization of hyperdrive entities to prevent save/restore errors

HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.SaveRestore = HYPERDRIVE.SaveRestore or {}

print("[Hyperdrive] Save/Restore system loading...")

-- Safe data types that can be serialized
local SAFE_TYPES = {
    ["string"] = true,
    ["number"] = true,
    ["boolean"] = true,
    ["Vector"] = true,
    ["Angle"] = true,
    ["Color"] = true
}

-- Clean table of nil values and unsafe types
function HYPERDRIVE.SaveRestore.CleanTable(tbl)
    if not istable(tbl) then return tbl end

    local cleaned = {}

    for k, v in pairs(tbl) do
        -- Skip nil keys or values
        if k ~= nil and v ~= nil then
            local keyType = type(k)
            local valueType = type(v)

            -- Only allow safe key types
            if keyType == "string" or keyType == "number" then
                if valueType == "table" then
                    -- Recursively clean nested tables
                    local cleanedTable = HYPERDRIVE.SaveRestore.CleanTable(v)
                    if next(cleanedTable) ~= nil then -- Only add non-empty tables
                        cleaned[k] = cleanedTable
                    end
                elseif SAFE_TYPES[valueType] or (valueType == "userdata" and v.GetClass and SAFE_TYPES[v:GetClass()]) then
                    -- Only add safe types
                    cleaned[k] = v
                end
            end
        end
    end

    return cleaned
end

-- Safe entity data extraction
function HYPERDRIVE.SaveRestore.ExtractEntityData(ent)
    if not IsValid(ent) then return nil end

    local data = {
        -- Basic entity data
        class = ent:GetClass(),
        position = ent:GetPos(),
        angles = ent:GetAngles(),
        model = ent:GetModel(),

        -- Network variables (safe ones only)
        networkVars = {}
    }

    -- Extract safe network variables
    local entClass = ent:GetClass()
    if entClass:find("hyperdrive") then
        -- Common hyperdrive network vars
        if ent.GetEnergy then data.networkVars.energy = ent:GetEnergy() end
        if ent.GetCharging then data.networkVars.charging = ent:GetCharging() end
        if ent.GetCooldown then data.networkVars.cooldown = ent:GetCooldown() end
        if ent.GetDestination then data.networkVars.destination = ent:GetDestination() end
        if ent.GetJumpReady then data.networkVars.jumpReady = ent:GetJumpReady() end
        if ent.GetPowered then data.networkVars.powered = ent:GetPowered() end
        if ent.GetComputerMode then data.networkVars.computerMode = ent:GetComputerMode() end

        -- Spacebuild network vars
        if ent.GetPowerLevel then data.networkVars.powerLevel = ent:GetPowerLevel() end
        if ent.GetOxygenLevel then data.networkVars.oxygenLevel = ent:GetOxygenLevel() end
        if ent.GetCoolantLevel then data.networkVars.coolantLevel = ent:GetCoolantLevel() end
        if ent.GetTemperature then data.networkVars.temperature = ent:GetTemperature() end

        -- Stargate network vars
        if ent.GetTechLevel then data.networkVars.techLevel = ent:GetTechLevel() end
        if ent.GetNaquadahLevel then data.networkVars.naquadahLevel = ent:GetNaquadahLevel() end
        if ent.GetZPMPower then data.networkVars.zpmPower = ent:GetZPMPower() end
        if ent.GetGateAddress then data.networkVars.gateAddress = ent:GetGateAddress() end
    end

    return data
end

-- Override entity OnSave functions to prevent save/restore errors
local function OverrideEntitySave(entClass)
    -- Check if scripted_ents system is available
    if not scripted_ents or not scripted_ents.GetStored then
        return false
    end

    local stored = scripted_ents.GetStored()
    if not stored then
        return false
    end

    local entTable = stored[entClass]
    if not entTable or not entTable.t then
        return false
    end

    -- Store original OnSave if it exists
    local originalOnSave = entTable.t.OnSave

    -- Override OnSave with safe version
    entTable.t.OnSave = function(self)
        local safeData = {}

        -- Extract only safe data
        if self.SavedWaypoints then
            safeData.savedWaypoints = HYPERDRIVE.SaveRestore.CleanTable(self.SavedWaypoints)
        end

        if self.LocationHistory then
            safeData.locationHistory = HYPERDRIVE.SaveRestore.CleanTable(self.LocationHistory)
        end

        if self.DetectedPlanets then
            safeData.detectedPlanets = HYPERDRIVE.SaveRestore.CleanTable(self.DetectedPlanets)
        end

        if self.CurrentCoordinates then
            safeData.currentCoordinates = self.CurrentCoordinates
        end

        if self.SafetyChecks ~= nil then
            safeData.safetyChecks = self.SafetyChecks
        end

        if self.AutoDetectPlanets ~= nil then
            safeData.autoDetectPlanets = self.AutoDetectPlanets
        end

        if self.AutoLinkPlanets ~= nil then
            safeData.autoLinkPlanets = self.AutoLinkPlanets
        end

        if self.PlanetLinkRadius then
            safeData.planetLinkRadius = self.PlanetLinkRadius
        end

        -- Clean the data before saving
        safeData = HYPERDRIVE.SaveRestore.CleanTable(safeData)

        return safeData
    end

    -- Store original OnRestore if it exists
    local originalOnRestore = entTable.t.OnRestore

    -- Override OnRestore with safe version
    entTable.t.OnRestore = function(self, data)
        if not data then return end

        -- Safely restore data
        if data.savedWaypoints then
            self.SavedWaypoints = data.savedWaypoints
        end

        if data.locationHistory then
            self.LocationHistory = data.locationHistory
        end

        if data.detectedPlanets then
            self.DetectedPlanets = data.detectedPlanets
        end

        if data.currentCoordinates then
            self.CurrentCoordinates = data.currentCoordinates
        end

        if data.safetyChecks ~= nil then
            self.SafetyChecks = data.safetyChecks
        end

        if data.autoDetectPlanets ~= nil then
            self.AutoDetectPlanets = data.autoDetectPlanets
        end

        if data.autoLinkPlanets ~= nil then
            self.AutoLinkPlanets = data.autoLinkPlanets
        end

        if data.planetLinkRadius then
            self.PlanetLinkRadius = data.planetLinkRadius
        end

        -- Initialize empty tables if they don't exist
        self.SavedWaypoints = self.SavedWaypoints or {}
        self.LocationHistory = self.LocationHistory or {}
        self.DetectedPlanets = self.DetectedPlanets or {}
        self.LinkedEngines = self.LinkedEngines or {}
        self.JumpQueue = self.JumpQueue or {}
        self.LinkedPlanets = self.LinkedPlanets or {}
        self.QuickJumpTargets = self.QuickJumpTargets or {}

        -- Call original restore if it exists
        if originalOnRestore then
            originalOnRestore(self, data)
        end
    end

    return true
end

-- Apply safe save/restore to all hyperdrive entities (delayed until entities are loaded)
local hyperdriveEntities = {
    "hyperdrive_engine",
    "hyperdrive_sb_engine",
    "hyperdrive_sg_engine",
    "hyperdrive_master_engine",
    "hyperdrive_computer",
    "hyperdrive_wire_controller",
    "hyperdrive_beacon"
}

-- Function to apply overrides when entities are ready
local function ApplyEntityOverrides()
    local overridden = 0
    local total = #hyperdriveEntities

    for _, entClass in ipairs(hyperdriveEntities) do
        if OverrideEntitySave(entClass) then
            overridden = overridden + 1
        end
    end

    print("[Hyperdrive] Applied save/restore overrides to " .. overridden .. "/" .. total .. " entity classes")
    return overridden == total
end

-- Alternative approach: Hook-based protection that doesn't require immediate entity override
local function ProtectEntityOnSave(ent)
    if not IsValid(ent) or not ent:GetClass():find("hyperdrive") then return end

    -- Store original OnSave if it exists
    local originalOnSave = ent.OnSave

    -- Override OnSave with safe version
    ent.OnSave = function(self)
        local safeData = {}

        -- Extract only safe data
        if self.SavedWaypoints then
            safeData.savedWaypoints = HYPERDRIVE.SaveRestore.CleanTable(self.SavedWaypoints)
        end

        if self.LocationHistory then
            safeData.locationHistory = HYPERDRIVE.SaveRestore.CleanTable(self.LocationHistory)
        end

        if self.DetectedPlanets then
            safeData.detectedPlanets = HYPERDRIVE.SaveRestore.CleanTable(self.DetectedPlanets)
        end

        if self.CurrentCoordinates then
            safeData.currentCoordinates = self.CurrentCoordinates
        end

        if self.SafetyChecks ~= nil then
            safeData.safetyChecks = self.SafetyChecks
        end

        if self.AutoDetectPlanets ~= nil then
            safeData.autoDetectPlanets = self.AutoDetectPlanets
        end

        if self.AutoLinkPlanets ~= nil then
            safeData.autoLinkPlanets = self.AutoLinkPlanets
        end

        if self.PlanetLinkRadius then
            safeData.planetLinkRadius = self.PlanetLinkRadius
        end

        -- Clean the data before saving
        safeData = HYPERDRIVE.SaveRestore.CleanTable(safeData)

        return safeData
    end

    -- Store original OnRestore if it exists
    local originalOnRestore = ent.OnRestore

    -- Override OnRestore with safe version
    ent.OnRestore = function(self, data)
        if not data then return end

        -- Safely restore data
        if data.savedWaypoints then
            self.SavedWaypoints = data.savedWaypoints
        end

        if data.locationHistory then
            self.LocationHistory = data.locationHistory
        end

        if data.detectedPlanets then
            self.DetectedPlanets = data.detectedPlanets
        end

        if data.currentCoordinates then
            self.CurrentCoordinates = data.currentCoordinates
        end

        if data.safetyChecks ~= nil then
            self.SafetyChecks = data.safetyChecks
        end

        if data.autoDetectPlanets ~= nil then
            self.AutoDetectPlanets = data.autoDetectPlanets
        end

        if data.autoLinkPlanets ~= nil then
            self.AutoLinkPlanets = data.autoLinkPlanets
        end

        if data.planetLinkRadius then
            self.PlanetLinkRadius = data.planetLinkRadius
        end

        -- Initialize empty tables if they don't exist
        self.SavedWaypoints = self.SavedWaypoints or {}
        self.LocationHistory = self.LocationHistory or {}
        self.DetectedPlanets = self.DetectedPlanets or {}
        self.LinkedEngines = self.LinkedEngines or {}
        self.JumpQueue = self.JumpQueue or {}
        self.LinkedPlanets = self.LinkedPlanets or {}
        self.QuickJumpTargets = self.QuickJumpTargets or {}

        -- Call original restore if it exists
        if originalOnRestore then
            originalOnRestore(self, data)
        end
    end
end

-- Try to apply class-based overrides (may fail if entities aren't loaded)
local classOverridesApplied = ApplyEntityOverrides()

-- If class overrides failed, use hook-based approach
if not classOverridesApplied then
    print("[Hyperdrive] Class-based overrides failed, using hook-based protection")

    -- Try again with delays
    timer.Simple(2, function()
        if not ApplyEntityOverrides() then
            timer.Simple(5, function()
                ApplyEntityOverrides()
            end)
        end
    end)
end

-- Hook into entity spawning to protect individual entities
hook.Add("OnEntityCreated", "HyperdriveSaveRestoreEntityCreated", function(ent)
    if IsValid(ent) and ent:GetClass():find("hyperdrive") then
        -- Apply protection to individual entity
        timer.Simple(0.1, function()
            if IsValid(ent) then
                ProtectEntityOnSave(ent)
            end
        end)

        -- Also try class-based overrides
        timer.Simple(0.5, function()
            ApplyEntityOverrides()
        end)
    end
end)

-- Global save/restore hooks
hook.Add("PreSaveGameLoaded", "HyperdriveSaveRestore", function()
    print("[Hyperdrive] Preparing for save game load...")

    -- Clear any problematic data before loading
    if HYPERDRIVE.Network and HYPERDRIVE.Network.State then
        HYPERDRIVE.Network.State.deltaStates = {}
        HYPERDRIVE.Network.State.priorityQueue = {}
    end

    if HYPERDRIVE.SimpleNetwork and HYPERDRIVE.SimpleNetwork.State then
        HYPERDRIVE.SimpleNetwork.State.lastUpdateTime = {}
        HYPERDRIVE.SimpleNetwork.State.updatesThisSecond = {}
    end
end)

hook.Add("PostSaveGameLoaded", "HyperdriveSaveRestore", function()
    print("[Hyperdrive] Save game loaded, reinitializing systems...")

    -- Reinitialize hyperdrive entities
    timer.Simple(1, function()
        for _, ent in ipairs(ents.FindByClass("hyperdrive_*")) do
            if IsValid(ent) then
                -- Reinitialize empty tables
                if ent.SavedWaypoints == nil then ent.SavedWaypoints = {} end
                if ent.LocationHistory == nil then ent.LocationHistory = {} end
                if ent.DetectedPlanets == nil then ent.DetectedPlanets = {} end
                if ent.LinkedEngines == nil then ent.LinkedEngines = {} end
                if ent.JumpQueue == nil then ent.JumpQueue = {} end
                if ent.LinkedPlanets == nil then ent.LinkedPlanets = {} end
                if ent.QuickJumpTargets == nil then ent.QuickJumpTargets = {} end
                if ent.IntegrationData == nil then ent.IntegrationData = {} end

                -- Restart timers if needed
                if ent.GetClass and ent:GetClass():find("hyperdrive") then
                    local entIndex = ent:EntIndex()
                    timer.Remove("hyperdrive_" .. entIndex)
                    timer.Remove("hyperdrive_master_" .. entIndex)

                    -- Restart appropriate timer based on entity type
                    if ent:GetClass() == "hyperdrive_master_engine" then
                        timer.Create("hyperdrive_master_" .. entIndex, 0.5, 0, function()
                            if IsValid(ent) and ent.UpdateAllSystems then
                                ent:UpdateAllSystems()
                            else
                                timer.Remove("hyperdrive_master_" .. entIndex)
                            end
                        end)
                    elseif ent.Think then
                        timer.Create("hyperdrive_" .. entIndex, 0.1, 0, function()
                            if IsValid(ent) and ent.Think then
                                ent:Think()
                            else
                                timer.Remove("hyperdrive_" .. entIndex)
                            end
                        end)
                    end
                end
            end
        end
    end)
end)

-- Console command to clean save data
concommand.Add("hyperdrive_clean_save_data", function(ply, cmd, args)
    if IsValid(ply) and not ply:IsAdmin() then
        ply:ChatPrint("[Hyperdrive] Admin access required!")
        return
    end

    local cleaned = 0

    for _, ent in ipairs(ents.FindByClass("hyperdrive_*")) do
        if IsValid(ent) then
            -- Clean entity data
            if ent.SavedWaypoints then
                ent.SavedWaypoints = HYPERDRIVE.SaveRestore.CleanTable(ent.SavedWaypoints)
            end
            if ent.LocationHistory then
                ent.LocationHistory = HYPERDRIVE.SaveRestore.CleanTable(ent.LocationHistory)
            end
            if ent.DetectedPlanets then
                ent.DetectedPlanets = HYPERDRIVE.SaveRestore.CleanTable(ent.DetectedPlanets)
            end
            if ent.IntegrationData then
                ent.IntegrationData = HYPERDRIVE.SaveRestore.CleanTable(ent.IntegrationData)
            end

            cleaned = cleaned + 1
        end
    end

    local message = "[Hyperdrive] Cleaned save data for " .. cleaned .. " entities"
    if IsValid(ply) then
        ply:ChatPrint(message)
    else
        print(message)
    end
end)

print("[Hyperdrive] Save/Restore system loaded - entities protected from save errors")
