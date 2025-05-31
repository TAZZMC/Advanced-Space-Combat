-- Enhanced Hyperdrive System - Spacebuild 3 Steam Workshop Integration v2.2.1
-- COMPLETE CODE UPDATE v2.2.1 - ALL SYSTEMS INTEGRATED WITH ENHANCED STEAM WORKSHOP
-- Full integration with Official Spacebuild 3 (3.2.0) from Steam Workshop
-- Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=693838486
-- GitHub: https://github.com/spacebuild/spacebuild

if not HYPERDRIVE then return end

print("[Hyperdrive SB3] COMPLETE CODE UPDATE v2.2.1 - SB3 Steam Workshop Integration being updated")
print("[Hyperdrive SB3] Official Spacebuild 3 (3.2.0) Enhanced Steam Workshop Support Active")

HYPERDRIVE.SB3Steam = HYPERDRIVE.SB3Steam or {}
HYPERDRIVE.SB3Steam.Resources = HYPERDRIVE.SB3Steam.Resources or {}

-- Spacebuild 3 Steam Workshop Detection System
function HYPERDRIVE.SB3Steam.DetectSB3Installation()
    local detection = {
        steamWorkshop = false,
        github = false,
        manual = false,
        version = "Unknown",
        source = "Unknown",
        components = {},
        features = {}
    }

    -- Steam Workshop Spacebuild 3 Detection (ID: 693838486)
    local steamWorkshopFiles = {
        -- Core SB3 Files
        "lua/autorun/spacebuild_loader.lua",
        "lua/autorun/server/spacebuild_init.lua",
        "lua/autorun/client/spacebuild_client.lua",

        -- Life Support System
        "lua/caf/addons/server/lifesupport.lua",
        "lua/caf/addons/client/lifesupport.lua",
        "lua/entities/sb3_life_support/init.lua",

        -- Resource System
        "lua/caf/addons/server/resource.lua",
        "lua/caf/addons/client/resource.lua",
        "lua/entities/sb3_resource_node/init.lua",

        -- Environment System
        "lua/caf/addons/server/environment.lua",
        "lua/caf/addons/client/environment.lua",

        -- Gravity System
        "lua/caf/addons/server/gravity.lua",
        "lua/caf/addons/client/gravity.lua",

        -- Atmosphere System
        "lua/caf/addons/server/atmosphere.lua",
        "lua/caf/addons/client/atmosphere.lua",

        -- Energy System
        "lua/entities/sb3_energy_node/init.lua",
        "lua/entities/sb3_generator/init.lua",
        "lua/entities/sb3_battery/init.lua",

        -- Gyropod System
        "lua/entities/gyropod/init.lua",
        "lua/entities/gyropod_wireless/init.lua",

        -- Storage System
        "lua/entities/sb3_storage/init.lua",
        "lua/entities/sb3_liquid_storage/init.lua",
        "lua/entities/sb3_gas_storage/init.lua",

        -- Processing System
        "lua/entities/sb3_processor/init.lua",
        "lua/entities/sb3_refinery/init.lua",
        "lua/entities/sb3_converter/init.lua",

        -- Distribution System
        "lua/entities/sb3_pipe/init.lua",
        "lua/entities/sb3_valve/init.lua",
        "lua/entities/sb3_pump/init.lua",

        -- Models and Materials
        "models/spacebuild/",
        "materials/spacebuild/"
    }

    -- Check Steam Workshop components
    local workshopDetected = 0
    for _, filePath in ipairs(steamWorkshopFiles) do
        if file.Exists(filePath, "LUA") or file.Exists(filePath, "GAME") then
            workshopDetected = workshopDetected + 1
            detection.steamWorkshop = true
            table.insert(detection.components, filePath)
        end
    end

    if detection.steamWorkshop then
        detection.source = "Steam Workshop (Official)"
        detection.version = string.format("SB3 v3.2.0 Workshop (%d/%d components)", workshopDetected, #steamWorkshopFiles)
        print("[Hyperdrive SB3] Steam Workshop Spacebuild 3 detected: " .. workshopDetected .. "/" .. #steamWorkshopFiles .. " components")
    end

    -- Check for GitHub/Manual installation
    if file.Exists("lua/autorun/spacebuild3.lua", "LUA") or
       file.Exists("lua/spacebuild/", "LUA") then
        detection.github = true
        if detection.source == "Unknown" then
            detection.source = "GitHub/Manual"
            detection.version = "SB3 GitHub/Manual"
        else
            detection.source = detection.source .. " + GitHub/Manual"
        end
        print("[Hyperdrive SB3] GitHub/Manual Spacebuild 3 detected")
    end

    -- Check for CAF (Core Addon Framework) - Required for SB3
    if file.Exists("lua/caf/", "LUA") then
        detection.features.caf = true
        print("[Hyperdrive SB3] CAF (Core Addon Framework) detected")
    end

    -- Check for specific SB3 features
    if detection.steamWorkshop or detection.github then
        -- Life Support System
        if file.Exists("lua/caf/addons/server/lifesupport.lua", "LUA") then
            detection.features.lifesupport = true
        end

        -- Resource System
        if file.Exists("lua/caf/addons/server/resource.lua", "LUA") then
            detection.features.resources = true
        end

        -- Environment System
        if file.Exists("lua/caf/addons/server/environment.lua", "LUA") then
            detection.features.environment = true
        end

        -- Gravity System
        if file.Exists("lua/caf/addons/server/gravity.lua", "LUA") then
            detection.features.gravity = true
        end

        -- Atmosphere System
        if file.Exists("lua/caf/addons/server/atmosphere.lua", "LUA") then
            detection.features.atmosphere = true
        end
    end

    -- Store detection results
    HYPERDRIVE.SB3Steam.Detection = detection
    HYPERDRIVE.SB3Steam.Available = detection.steamWorkshop or detection.github or detection.manual

    -- Log final detection results
    if HYPERDRIVE.SB3Steam.Available then
        print("[Hyperdrive SB3] Spacebuild 3 Integration Active - Source: " .. detection.source)
        print("[Hyperdrive SB3] Version: " .. detection.version)
        if detection.features and table.Count(detection.features) > 0 then
            local featureList = {}
            for feature, available in pairs(detection.features) do
                if available then
                    table.insert(featureList, feature)
                end
            end
            if #featureList > 0 then
                print("[Hyperdrive SB3] Available Features: " .. table.concat(featureList, ", "))
            end
        end
    else
        print("[Hyperdrive SB3] No Spacebuild 3 installation detected")
    end

    return HYPERDRIVE.SB3Steam.Available, detection
end

-- Enhanced Resource System Integration for Steam Workshop SB3
function HYPERDRIVE.SB3Steam.InitializeResourceSystem()
    if not HYPERDRIVE.SB3Steam.Available then return false end

    -- Resource types supported by Steam Workshop SB3 v3.2.0
    HYPERDRIVE.SB3Steam.ResourceTypes = {
        -- Energy Resources
        energy = { name = "Energy", unit = "kW", color = Color(255, 255, 0), category = "power" },

        -- Life Support Resources
        oxygen = { name = "Oxygen", unit = "L", color = Color(0, 255, 255), category = "lifesupport" },
        nitrogen = { name = "Nitrogen", unit = "L", color = Color(255, 0, 255), category = "lifesupport" },
        hydrogen = { name = "Hydrogen", unit = "L", color = Color(255, 100, 100), category = "lifesupport" },

        -- Coolant Resources
        coolant = { name = "Coolant", unit = "L", color = Color(0, 255, 0), category = "cooling" },
        water = { name = "Water", unit = "L", color = Color(0, 100, 255), category = "cooling" },

        -- Fuel Resources
        fuel = { name = "Fuel", unit = "L", color = Color(255, 150, 0), category = "fuel" },
        heavy_water = { name = "Heavy Water", unit = "L", color = Color(100, 150, 255), category = "fuel" },

        -- Raw Materials
        iron = { name = "Iron", unit = "kg", color = Color(150, 150, 150), category = "material" },
        carbon = { name = "Carbon", unit = "kg", color = Color(50, 50, 50), category = "material" },
        silicon = { name = "Silicon", unit = "kg", color = Color(200, 200, 255), category = "material" }
    }

    print("[Hyperdrive SB3] Resource system initialized with " .. table.Count(HYPERDRIVE.SB3Steam.ResourceTypes) .. " resource types")
    return true
end

-- Check if specific SB3 feature is available
function HYPERDRIVE.SB3Steam.HasFeature(feature)
    if not HYPERDRIVE.SB3Steam.Detection then
        HYPERDRIVE.SB3Steam.DetectSB3Installation()
    end

    return HYPERDRIVE.SB3Steam.Detection.features and HYPERDRIVE.SB3Steam.Detection.features[feature] or false
end

-- Get SB3 entity category
function HYPERDRIVE.SB3Steam.GetEntityCategory(className)
    local categories = {
        ENERGY = { "sb3_energy_node", "sb3_generator", "sb3_battery", "sb3_solar_panel" },
        STORAGE = { "sb3_storage", "sb3_liquid_storage", "sb3_gas_storage", "sb3_tank" },
        PROCESSING = { "sb3_processor", "sb3_refinery", "sb3_converter", "sb3_assembler" },
        DISTRIBUTION = { "sb3_pipe", "sb3_valve", "sb3_pump", "sb3_splitter" },
        LIFESUPPORT = { "sb3_life_support", "sb3_air_exchanger", "sb3_scrubber" },
        MOVEMENT = { "gyropod", "gyropod_wireless", "sb3_thruster" },
        CONTROL = { "sb3_computer", "sb3_console", "sb3_monitor" }
    }

    for category, entities in pairs(categories) do
        for _, entClass in ipairs(entities) do
            if entClass == className then
                return category
            end
        end
    end
    return nil
end

-- Enhanced Ship Core Integration with Steam Workshop SB3
function HYPERDRIVE.SB3Steam.IntegrateWithShipCore(shipCore)
    if not HYPERDRIVE.SB3Steam.Available or not IsValid(shipCore) then return false end

    -- Initialize SB3 resource storage for ship core
    if not shipCore.SB3Resources then
        shipCore.SB3Resources = {}
        for resourceType, config in pairs(HYPERDRIVE.SB3Steam.ResourceTypes) do
            shipCore.SB3Resources[resourceType] = {
                amount = 0,
                capacity = 1000, -- Default capacity
                rate = 0,
                lastUpdate = CurTime()
            }
        end
    end

    -- Set up SB3 integration hooks
    shipCore.SB3Integrated = true
    shipCore.SB3Version = "Steam Workshop v3.2.0"
    shipCore.SB3Features = HYPERDRIVE.SB3Steam.Detection.features

    print("[Hyperdrive SB3] Ship core integrated with Steam Workshop SB3 v3.2.0")
    return true
end

-- Initialize Steam Workshop SB3 integration
hook.Add("Initialize", "HYPERDRIVE_SB3Steam_Init", function()
    timer.Simple(2, function()
        local available, detection = HYPERDRIVE.SB3Steam.DetectSB3Installation()
        if available then
            HYPERDRIVE.SB3Steam.InitializeResourceSystem()

            -- Register with main hyperdrive system
            if HYPERDRIVE.SB3Resources then
                HYPERDRIVE.SB3Resources.SteamWorkshopIntegration = true
                HYPERDRIVE.SB3Resources.SteamWorkshopVersion = detection.version
            end
        end
    end)
end)

print("[Hyperdrive SB3] Steam Workshop Spacebuild 3 integration v2.2.0 loaded")
