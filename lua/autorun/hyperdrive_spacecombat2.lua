-- Hyperdrive Space Combat 2 Integration
-- Enhanced ship movement and entity detection for SC2 compatibility
-- Addresses issues with gyropod integration and optimized ship movement

if CLIENT then return end

-- Initialize SC2 integration
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.SpaceCombat2 = HYPERDRIVE.SpaceCombat2 or {}

print("[Hyperdrive] Space Combat 2 integration loading...")

-- Configuration (uses enhanced config system if available)
HYPERDRIVE.SpaceCombat2.Config = {
    UseGyropodMovement = true,      -- Use SC2 gyropod for ship movement
    UseShipCore = true,             -- Use ship core for entity detection
    OverrideGravity = true,         -- Override SC2 gravity during jumps
    OptimizedMovement = true,       -- Use optimized SetPos/SetAngles method
    GyropodSearchRadius = 2000,     -- Radius to search for gyropods
    ShipCoreSearchRadius = 1500,    -- Radius to search for ship cores
}

-- Function to get configuration value with enhanced config fallback
local function GetConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("SpaceCombat2", key, HYPERDRIVE.SpaceCombat2.Config[key] or default)
    end
    return HYPERDRIVE.SpaceCombat2.Config[key] or default
end

-- Detect if Space Combat 2 is loaded and get version info
local function IsSpaceCombat2Loaded()
    -- Check if we're running SC2 gamemode
    if GAMEMODE and GAMEMODE.Name == "Space Combat 2" then
        return true, "active"
    end

    -- Check if SC2 files exist
    if file.Exists("gamemodes/spacecombat2/gamemode/init.lua", "GAME") then
        return true, "available"
    end

    return false, "not found"
end

-- Check for SC2 specific globals and functions
local function GetSC2Capabilities()
    local capabilities = {
        GetProtector = false,
        GenericPodLink = false,
        EnvironmentSystem = false,
        GyropodSystem = false,
        ShipCoreSystem = false
    }

    -- Check for GetProtector metamethod
    local testEnt = ents.Create("prop_physics")
    if IsValid(testEnt) then
        if testEnt.GetProtector and type(testEnt.GetProtector) == "function" then
            capabilities.GetProtector = true
        end
        testEnt:Remove()
    end

    -- Check for SC2 global functions
    if SC_HasGenericPodLink and type(SC_HasGenericPodLink) == "function" then
        capabilities.GenericPodLink = true
    end

    -- Check for environment system
    if SC_GetEnvironment and type(SC_GetEnvironment) == "function" then
        capabilities.EnvironmentSystem = true
    end

    -- Check for common SC2 entity classes
    local sc2Entities = ents.FindByClass("sc_*")
    if #sc2Entities > 0 then
        capabilities.GyropodSystem = true
        capabilities.ShipCoreSystem = true
    end

    return capabilities
end

-- Check if entity has a ship core using SC2's GetProtector metamethod
local function HasShipCore(ent)
    if not IsValid(ent) then return false end

    -- Use SC2's GetProtector metamethod to check for ship core
    if ent.GetProtector and type(ent.GetProtector) == "function" then
        local protector = ent:GetProtector()
        return IsValid(protector)
    end

    return false
end

-- Check if entity has generic pod link (SC2 function) - kept for compatibility
local function HasGenericPodLink(ent)
    if not IsValid(ent) then return false end

    -- Check for SC_HasGenericPodLink function
    if SC_HasGenericPodLink and type(SC_HasGenericPodLink) == "function" then
        return SC_HasGenericPodLink(ent)
    end

    -- Fallback: check for common SC2 entity types
    local class = ent:GetClass()
    return string.find(class, "sc_") or
           string.find(class, "spacecombat") or
           ent.IsSpaceCombatEntity
end

-- Get ship core using GetProtector metamethod
local function GetShipCoreFromProtector(ent)
    if not IsValid(ent) then return nil end

    if ent.GetProtector and type(ent.GetProtector) == "function" then
        local protector = ent:GetProtector()
        if IsValid(protector) and (protector:GetClass() == "sc_ship_core" or protector:GetClass() == "sb3_ship_core") then
            return protector
        end
    end

    return nil
end

-- Find gyropod for a ship using GetProtector method
function HYPERDRIVE.SpaceCombat2.FindGyropod(engine)
    if not IsValid(engine) then return nil end

    -- First try to get ship core using GetProtector
    local shipCore = GetShipCoreFromProtector(engine)
    if IsValid(shipCore) then
        -- Look for gyropod connected to the same ship core
        local searchRadius = GetConfig("GyropodSearchRadius", 2000)
        local nearbyEnts = ents.FindInSphere(shipCore:GetPos(), searchRadius)

        for _, ent in ipairs(nearbyEnts) do
            if IsValid(ent) and ent:GetClass() == "sc_gyropod" then
                -- Check if this gyropod has the same protector (ship core)
                local gyropodCore = GetShipCoreFromProtector(ent)
                if IsValid(gyropodCore) and gyropodCore == shipCore then
                    return ent
                end
            end
        end
    end

    -- Fallback: search by proximity and generic pod link
    local searchRadius = GetConfig("GyropodSearchRadius", 2000)
    local nearbyEnts = ents.FindInSphere(engine:GetPos(), searchRadius)

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == "sc_gyropod" then
            -- Check if this gyropod is connected to our ship using legacy method
            if HasGenericPodLink(engine) and HasGenericPodLink(ent) then
                return ent
            end
        end
    end

    return nil
end

-- Find ship core for entity detection using GetProtector method
function HYPERDRIVE.SpaceCombat2.FindShipCore(engine)
    if not IsValid(engine) then return nil end

    -- First try to get ship core directly using GetProtector
    local shipCore = GetShipCoreFromProtector(engine)
    if IsValid(shipCore) then
        return shipCore
    end

    -- Fallback: search by proximity
    local searchRadius = GetConfig("ShipCoreSearchRadius", 1500)
    local nearbyEnts = ents.FindInSphere(engine:GetPos(), searchRadius)

    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and (ent:GetClass() == "sc_ship_core" or ent:GetClass() == "sb3_ship_core") then
            return ent
        end
    end

    return nil
end

-- Get all attached entities using ship core and GetProtector method
function HYPERDRIVE.SpaceCombat2.GetAttachedEntities(engine)
    local entities = {}
    local shipCore = nil

    -- Try to find ship core using GetProtector first
    shipCore = GetShipCoreFromProtector(engine)

    -- If not found, try the traditional search method
    if not IsValid(shipCore) then
        shipCore = HYPERDRIVE.SpaceCombat2.FindShipCore(engine)
    end

    if IsValid(shipCore) then
        -- Use ship core's attached entities list
        if shipCore.GetAttachedEntities then
            local attached = shipCore:GetAttachedEntities()
            if attached then
                for _, ent in ipairs(attached) do
                    if IsValid(ent) then
                        table.insert(entities, ent)
                    end
                end
            end
        end

        -- Also get players in the ship
        if shipCore.GetPlayersInShip then
            local players = shipCore:GetPlayersInShip()
            if players then
                for _, ply in ipairs(players) do
                    if IsValid(ply) then
                        table.insert(entities, ply)
                    end
                end
            end
        end

        -- If ship core doesn't have these methods, find entities by GetProtector
        if #entities == 0 then
            local searchRadius = GetConfig("ShipCoreSearchRadius", 1500)
            local nearbyEnts = ents.FindInSphere(shipCore:GetPos(), searchRadius)

            for _, ent in ipairs(nearbyEnts) do
                if IsValid(ent) then
                    local entCore = GetShipCoreFromProtector(ent)
                    if IsValid(entCore) and entCore == shipCore then
                        table.insert(entities, ent)
                    end
                end
            end
        end
    end

    -- Fallback: use constraint system
    if #entities == 0 then
        local constrainedEnts = constraint.GetAllConstrainedEntities(engine)
        if constrainedEnts then
            for _, ent in ipairs(constrainedEnts) do
                if IsValid(ent) and ent ~= engine then
                    table.insert(entities, ent)
                end
            end
        end
    end

    -- Always include the engine itself
    table.insert(entities, engine)

    return entities
end

-- Enhanced gyropod movement with SC2-specific optimizations
function HYPERDRIVE.SpaceCombat2.MoveShipViaGyropod(engine, destination, gyropod)
    if not IsValid(engine) or not IsValid(gyropod) then return false end

    local currentPos = gyropod:GetPos()
    local offset = destination - engine:GetPos()
    local newGyropodPos = currentPos + offset

    -- Get current gyropod state for restoration
    local originalVelocity = Vector(0, 0, 0)
    local originalAngularVelocity = Vector(0, 0, 0)

    if gyropod:GetPhysicsObject():IsValid() then
        originalVelocity = gyropod:GetPhysicsObject():GetVelocity()
        originalAngularVelocity = gyropod:GetPhysicsObject():GetAngularVelocity()
    end

    -- Use SC2's optimized gyropod movement methods
    local success = false

    -- Try SC2-specific movement methods in order of preference
    if gyropod.SetTargetPosition and type(gyropod.SetTargetPosition) == "function" then
        gyropod:SetTargetPosition(newGyropodPos)
        success = true
    elseif gyropod.MoveTo and type(gyropod.MoveTo) == "function" then
        gyropod:MoveTo(newGyropodPos)
        success = true
    elseif gyropod.SetPosOptimized and type(gyropod.SetPosOptimized) == "function" then
        gyropod:SetPosOptimized(newGyropodPos)
        success = true
    else
        -- Fallback to direct position setting with velocity clearing
        gyropod:SetPos(newGyropodPos)
        if gyropod:GetPhysicsObject():IsValid() then
            gyropod:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
            gyropod:GetPhysicsObject():SetAngularVelocity(Vector(0, 0, 0))
        end
        success = true
    end

    -- Notify gyropod of teleportation if method exists
    if success and gyropod.OnTeleport and type(gyropod.OnTeleport) == "function" then
        gyropod:OnTeleport(newGyropodPos, originalVelocity)
    end

    return success
end

-- Optimized ship movement using gyropod integration
function HYPERDRIVE.SpaceCombat2.MoveShip(engine, destination)
    if not IsValid(engine) then return false end
    if not GetConfig("Enabled", true) then return false end

    local gyropod = HYPERDRIVE.SpaceCombat2.FindGyropod(engine)

    if IsValid(gyropod) and GetConfig("UseGyropodMovement", true) then
        -- Use enhanced gyropod movement system
        local success = HYPERDRIVE.SpaceCombat2.MoveShipViaGyropod(engine, destination, gyropod)

        if success then
            -- Update ship core if it exists
            local shipCore = GetShipCoreFromProtector(engine)
            if IsValid(shipCore) and shipCore.OnShipMoved and type(shipCore.OnShipMoved) == "function" then
                shipCore:OnShipMoved(destination)
            end

            return true
        end
    end

    -- Fallback to standard movement
    return HYPERDRIVE.SpaceCombat2.MoveShipStandard(engine, destination)
end

-- Standard ship movement with optimization
function HYPERDRIVE.SpaceCombat2.MoveShipStandard(engine, destination)
    if not IsValid(engine) then return false end

    local entities = HYPERDRIVE.SpaceCombat2.GetAttachedEntities(engine)
    local enginePos = engine:GetPos()

    -- Use optimized movement method if available
    if GetConfig("OptimizedMovement", true) then
        -- Batch movement to reduce network overhead
        for _, ent in ipairs(entities) do
            if IsValid(ent) then
                local offset = ent:GetPos() - enginePos
                local newPos = destination + offset

                -- Use the SC2 optimized method if available
                if ent.SetPosOptimized then
                    ent:SetPosOptimized(newPos)
                else
                    ent:SetPos(newPos)
                end

                -- Clear velocity to prevent physics issues
                if ent:GetPhysicsObject():IsValid() then
                    ent:GetPhysicsObject():SetVelocity(Vector(0, 0, 0))
                    ent:GetPhysicsObject():SetAngularVelocity(Vector(0, 0, 0))
                end
            end
        end
    else
        -- Standard movement
        for _, ent in ipairs(entities) do
            if IsValid(ent) then
                local offset = ent:GetPos() - enginePos
                ent:SetPos(destination + offset)
            end
        end
    end

    return true
end

-- Get SC2 environment information for a position
function HYPERDRIVE.SpaceCombat2.GetEnvironmentInfo(pos)
    local envInfo = {
        inSpace = false,
        hasAtmosphere = false,
        gravity = 1.0,
        temperature = 20,
        pressure = 1.0
    }

    -- Use SC2 environment system if available
    if SC_GetEnvironment and type(SC_GetEnvironment) == "function" then
        local env = SC_GetEnvironment(pos)
        if env then
            envInfo.inSpace = env.space or false
            envInfo.hasAtmosphere = env.atmosphere or false
            envInfo.gravity = env.gravity or 1.0
            envInfo.temperature = env.temperature or 20
            envInfo.pressure = env.pressure or 1.0
        end
    else
        -- Fallback: basic space detection
        local trace = util.TraceLine({
            start = pos,
            endpos = pos + Vector(0, 0, 10000),
            mask = MASK_SOLID_BRUSHONLY
        })

        envInfo.inSpace = not trace.Hit
    end

    return envInfo
end

-- Override gravity for players during hyperspace travel with SC2 integration
function HYPERDRIVE.SpaceCombat2.OverrideGravity(player, override)
    if not IsValid(player) or not player:IsPlayer() then return end
    if not GetConfig("OverrideGravity", true) then return end

    -- Store original gravity override function
    if not player.OriginalGravityOverride then
        player.OriginalGravityOverride = player.GravityOverride
    end

    if override then
        -- Get environment info for hyperspace gravity calculation
        local envInfo = HYPERDRIVE.SpaceCombat2.GetEnvironmentInfo(player:GetPos())

        -- Override SC2 gravity system
        player.HyperdriveGravityOverride = true

        -- Calculate hyperspace gravity based on environment
        local gravityValue = 0.5
        if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
            gravityValue = HYPERDRIVE.EnhancedConfig.Get("Gravity", "HyperspaceGravity", 0.5)
        end

        -- Adjust for space environment
        if envInfo.inSpace then
            gravityValue = gravityValue * 0.5 -- Even less gravity in space
        end

        player:SetGravity(gravityValue)

        -- Store environment info for restoration
        player.HyperspaceEnvironment = envInfo
    else
        -- Restore SC2 gravity system
        player.HyperdriveGravityOverride = nil

        -- Restore gravity based on original environment
        if player.HyperspaceEnvironment then
            player:SetGravity(player.HyperspaceEnvironment.gravity)
            player.HyperspaceEnvironment = nil
        else
            player:SetGravity(1.0) -- Default fallback
        end

        if player.OriginalGravityOverride then
            player.OriginalGravityOverride = nil
        end
    end
end

-- Hook into SC2 gravity system
if IsSpaceCombat2Loaded() then
    hook.Add("PlayerThink", "HyperdriveSpaceCombat2Gravity", function(ply)
        if not IsValid(ply) then return end

        -- Skip gravity override if player is in hyperspace
        if ply.HyperdriveGravityOverride then
            return
        end
    end)
end

-- Enhanced entity detection for SC2
function HYPERDRIVE.SpaceCombat2.EnhancedEntityDetection(engine, searchRadius)
    local entities = {}
    searchRadius = searchRadius or GetConfig("ShipCoreSearchRadius", 1500)

    if GetConfig("Debug", false) and HYPERDRIVE.EnhancedConfig then
        print("[SC2 Integration] Starting enhanced entity detection for " .. tostring(engine))
    end

    -- Use ship core method first
    local coreEntities = HYPERDRIVE.SpaceCombat2.GetAttachedEntities(engine)
    for _, ent in ipairs(coreEntities) do
        table.insert(entities, ent)
    end

    if GetConfig("Debug", false) and HYPERDRIVE.EnhancedConfig then
        print("[SC2 Integration] Found " .. #coreEntities .. " entities from ship core")
    end

    -- Add nearby SC2-specific entities if enabled, using GetProtector method
    if GetConfig("IncludeSCEntities", true) then
        local engineCore = GetShipCoreFromProtector(engine)

        if IsValid(engineCore) then
            -- Find entities with the same ship core using GetProtector
            local nearbyEnts = ents.FindInSphere(engine:GetPos(), searchRadius)
            for _, ent in ipairs(nearbyEnts) do
                if IsValid(ent) and not table.HasValue(entities, ent) then
                    local entCore = GetShipCoreFromProtector(ent)
                    if IsValid(entCore) and entCore == engineCore then
                        table.insert(entities, ent)
                    end
                end
            end
        else
            -- Fallback to legacy method if GetProtector not available
            local nearbyEnts = ents.FindInSphere(engine:GetPos(), searchRadius)
            for _, ent in ipairs(nearbyEnts) do
                if IsValid(ent) and not table.HasValue(entities, ent) then
                    -- Include SC2 entities using legacy detection
                    if HasGenericPodLink(ent) or
                       string.find(ent:GetClass(), "sc_") or
                       string.find(ent:GetClass(), "spacecombat") then
                        table.insert(entities, ent)
                    end
                end
            end
        end
    end

    if GetConfig("Debug", false) and HYPERDRIVE.EnhancedConfig then
        print("[SC2 Integration] Total entities detected: " .. #entities)
    end

    return entities
end

-- Integration setup for existing engines
function HYPERDRIVE.SpaceCombat2.SetupSC2Integration(ent)
    if not IsValid(ent) or not IsSpaceCombat2Loaded() then return end

    -- Store original functions
    ent.OriginalStartJump = ent.OriginalStartJump or ent.StartJump
    ent.OriginalExecuteJump = ent.OriginalExecuteJump or ent.ExecuteJump

    -- Override jump execution with SC2 enhancements
    ent.ExecuteJump = function(self)
        local destination = self:GetDestination()

        -- Use SC2 enhanced movement
        local success = HYPERDRIVE.SpaceCombat2.MoveShip(self, destination)

        if success then
            -- Override gravity for players
            local entities = HYPERDRIVE.SpaceCombat2.GetAttachedEntities(self)
            for _, entity in ipairs(entities) do
                if IsValid(entity) and entity:IsPlayer() then
                    HYPERDRIVE.SpaceCombat2.OverrideGravity(entity, true)

                    -- Restore gravity after a delay
                    timer.Simple(5, function()
                        if IsValid(entity) then
                            HYPERDRIVE.SpaceCombat2.OverrideGravity(entity, false)
                        end
                    end)
                end
            end
        end

        return success
    end
end

-- Hook into engine creation
hook.Add("OnEntityCreated", "HyperdriveSpaceCombat2Init", function(ent)
    if not IsValid(ent) then return end

    local class = ent:GetClass()
    if string.find(class, "hyperdrive") and string.find(class, "engine") then
        timer.Simple(0.1, function()
            if IsValid(ent) and IsSpaceCombat2Loaded() then
                HYPERDRIVE.SpaceCombat2.SetupSC2Integration(ent)
            end
        end)
    end
end)

-- Advanced SC2 integration functions
function HYPERDRIVE.SpaceCombat2.GetShipMass(engine)
    local totalMass = 0
    local entities = HYPERDRIVE.SpaceCombat2.GetAttachedEntities(engine)

    for _, ent in ipairs(entities) do
        if IsValid(ent) and ent:GetPhysicsObject():IsValid() then
            totalMass = totalMass + ent:GetPhysicsObject():GetMass()
        end
    end

    return totalMass
end

-- Calculate energy cost based on ship mass and SC2 factors
function HYPERDRIVE.SpaceCombat2.CalculateEnergyCost(engine, destination)
    local distance = engine:GetPos():Distance(destination)
    local baseCost = distance * 0.1

    -- Factor in ship mass
    local shipMass = HYPERDRIVE.SpaceCombat2.GetShipMass(engine)
    local massFactor = math.max(1, shipMass / 1000) -- Scale based on mass

    -- SC2 efficiency bonuses
    local gyropod = HYPERDRIVE.SpaceCombat2.FindGyropod(engine)
    local gyropodBonus = IsValid(gyropod) and 0.8 or 1.0 -- 20% bonus with gyropod

    return baseCost * massFactor * gyropodBonus
end

-- Check if ship is properly configured for SC2 using GetProtector method
function HYPERDRIVE.SpaceCombat2.ValidateShipConfiguration(engine)
    local issues = {}
    local warnings = {}

    -- Check if engine has a ship core using GetProtector
    local shipCore = GetShipCoreFromProtector(engine)
    if not IsValid(shipCore) then
        -- Try fallback method
        shipCore = HYPERDRIVE.SpaceCombat2.FindShipCore(engine)
        if not IsValid(shipCore) then
            table.insert(issues, "No ship core found - engine not protected")
        else
            table.insert(warnings, "Ship core found via proximity search (GetProtector not working)")
        end
    end

    -- Check gyropod connectivity
    if GetConfig("UseGyropodMovement", true) then
        local gyropod = HYPERDRIVE.SpaceCombat2.FindGyropod(engine)
        if not IsValid(gyropod) then
            table.insert(issues, "No gyropod found (recommended for SC2)")
        else
            -- Verify gyropod has same ship core
            local gyropodCore = GetShipCoreFromProtector(gyropod)
            if IsValid(shipCore) and IsValid(gyropodCore) and gyropodCore ~= shipCore then
                table.insert(warnings, "Gyropod and engine have different ship cores")
            end
        end
    end

    -- Check attached entities
    local entities = HYPERDRIVE.SpaceCombat2.GetAttachedEntities(engine)
    if #entities < 2 then
        table.insert(issues, "Ship appears to have no attached entities")
    end

    -- Check if entities are properly protected
    if IsValid(shipCore) then
        local protectedCount = 0
        for _, ent in ipairs(entities) do
            if IsValid(ent) then
                local entCore = GetShipCoreFromProtector(ent)
                if IsValid(entCore) and entCore == shipCore then
                    protectedCount = protectedCount + 1
                end
            end
        end

        if protectedCount < #entities * 0.8 then -- 80% threshold
            table.insert(warnings, string.format("Only %d/%d entities are properly protected by ship core", protectedCount, #entities))
        end
    end

    -- Combine issues and warnings
    local allIssues = {}
    for _, issue in ipairs(issues) do
        table.insert(allIssues, "ERROR: " .. issue)
    end
    for _, warning in ipairs(warnings) do
        table.insert(allIssues, "WARNING: " .. warning)
    end

    return #issues == 0, allIssues
end

-- Console command for SC2 ship validation
concommand.Add("hyperdrive_sc2_validate", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if not IsValid(trace.Entity) or not string.find(trace.Entity:GetClass(), "hyperdrive") then
        ply:ChatPrint("[Hyperdrive SC2] Look at a hyperdrive engine")
        return
    end

    local engine = trace.Entity
    local isValid, issues = HYPERDRIVE.SpaceCombat2.ValidateShipConfiguration(engine)

    ply:ChatPrint("[Hyperdrive SC2] Ship Configuration:")
    ply:ChatPrint("  • Ship Core: " .. (HYPERDRIVE.SpaceCombat2.FindShipCore(engine) and "✓ Found" or "✗ Missing"))
    ply:ChatPrint("  • Gyropod: " .. (HYPERDRIVE.SpaceCombat2.FindGyropod(engine) and "✓ Found" or "✗ Missing"))
    ply:ChatPrint("  • Attached Entities: " .. #HYPERDRIVE.SpaceCombat2.GetAttachedEntities(engine))
    ply:ChatPrint("  • Ship Mass: " .. math.floor(HYPERDRIVE.SpaceCombat2.GetShipMass(engine)) .. " kg")

    if not isValid then
        ply:ChatPrint("  • Issues:")
        for _, issue in ipairs(issues) do
            ply:ChatPrint("    - " .. issue)
        end
    else
        ply:ChatPrint("  • Status: ✓ Ship properly configured for SC2")
    end
end)

-- Initialize SC2 integration with capability detection
local sc2Loaded, sc2Status = IsSpaceCombat2Loaded()
local sc2Capabilities = GetSC2Capabilities()

-- Log integration status
if sc2Loaded then
    print("[Hyperdrive] Space Combat 2 integration loaded (" .. sc2Status .. ")")
    print("[Hyperdrive] SC2 Capabilities detected:")
    for capability, available in pairs(sc2Capabilities) do
        print("  • " .. capability .. ": " .. (available and "✓" or "✗"))
    end
else
    print("[Hyperdrive] Space Combat 2 integration ready (SC2 not detected)")
end

-- Store capabilities for runtime access
HYPERDRIVE.SpaceCombat2.Capabilities = sc2Capabilities
HYPERDRIVE.SpaceCombat2.Status = {
    loaded = sc2Loaded,
    status = sc2Status,
    lastCheck = CurTime()
}

-- Console command to check SC2 integration status
concommand.Add("hyperdrive_sc2_status", function(ply, cmd, args)
    local target = IsValid(ply) and ply or nil
    local function sendMessage(msg)
        if target then
            target:ChatPrint(msg)
        else
            print(msg)
        end
    end

    local status = HYPERDRIVE.SpaceCombat2.Status
    local capabilities = HYPERDRIVE.SpaceCombat2.Capabilities

    sendMessage("[Hyperdrive SC2] Integration Status:")
    sendMessage("  • Loaded: " .. (status.loaded and "Yes" or "No"))
    sendMessage("  • Status: " .. status.status)
    sendMessage("  • Last Check: " .. string.format("%.1fs ago", CurTime() - status.lastCheck))

    sendMessage("[Hyperdrive SC2] Capabilities:")
    for capability, available in pairs(capabilities) do
        sendMessage("  • " .. capability .. ": " .. (available and "✓ Available" or "✗ Not Available"))
    end

    -- Additional runtime checks
    local gyropods = ents.FindByClass("sc_gyropod")
    local shipCores = ents.FindByClass("sc_ship_core")

    sendMessage("[Hyperdrive SC2] Current Entities:")
    sendMessage("  • Gyropods: " .. #gyropods)
    sendMessage("  • Ship Cores: " .. #shipCores)
end)
