-- Enhanced Hyperdrive System - Comprehensive CAP Integration v2.1.0
-- Integrates with Carter Addon Pack (CAP) for shields, stargates, resources, and effects
-- Supports: CAP main addon, CAP resources, Steam Workshop CAP
-- GitHub: https://github.com/RafaelDeJongh/cap
-- Resources: https://github.com/RafaelDeJongh/cap_resources
-- Workshop: https://steamcommunity.com/workshop/filedetails/?id=180077636

if not HYPERDRIVE then return end

HYPERDRIVE.CAP = HYPERDRIVE.CAP or {}
HYPERDRIVE.CAP.Resources = HYPERDRIVE.CAP.Resources or {}
HYPERDRIVE.CAP.Stargates = HYPERDRIVE.CAP.Stargates or {}
HYPERDRIVE.CAP.Shields = HYPERDRIVE.CAP.Shields or {}
HYPERDRIVE.CAP.Effects = HYPERDRIVE.CAP.Effects or {}

print("[Hyperdrive] Comprehensive CAP (Carter Addon Pack) integration v2.1.0 loading...")

-- Enhanced CAP integration configuration
HYPERDRIVE.CAP.Config = {
    -- Core Integration
    Enabled = true,                     -- Enable CAP integration
    AutoDetectCAP = true,               -- Auto-detect CAP installations
    PreferCAPSystems = true,            -- Prefer CAP systems over built-in alternatives

    -- Stargate Integration
    UseStargateNetwork = true,          -- Use Stargate network for destinations
    RequireStargateEnergy = false,      -- Require Stargate energy for hyperdrive
    ShareEnergyWithStargates = true,    -- Share energy between hyperdrive and stargates
    UseStargateAddresses = true,        -- Use Stargate addresses for navigation
    IntegrateWithDHD = true,            -- Integrate with Dial Home Devices
    CheckStargateStatus = true,         -- Check Stargate operational status
    PreventConflicts = true,            -- Prevent conflicts with active Stargate connections
    UseStargateProtection = true,       -- Use Stargate protection systems

    -- Shield Integration
    RespectShields = true,              -- Respect CAP shield systems
    AutoCreateShields = true,           -- Auto-create shields for ships
    UseShieldFrequencies = true,        -- Use shield frequency system
    IntegrateShieldPower = true,        -- Integrate shield power with ship core
    ShieldActivationDelay = 2.0,        -- Delay before shield activation

    -- Resource Integration
    UseCAPResources = true,             -- Use CAP resource systems
    ShareResourceStorage = true,        -- Share resources with CAP entities
    AutoProvisionCAP = true,            -- Auto-provision CAP entities
    UseCAPEnergyTypes = true,           -- Use CAP energy types (ZPM, Naquadah, etc.)

    -- Effects Integration
    UseCAPEffects = true,               -- Use CAP visual/audio effects
    UseStargateEffects = true,          -- Use Stargate-style hyperdrive effects
    UseShieldEffects = true,            -- Use CAP shield effects
    UseTransportEffects = true,         -- Use CAP transport effects
}

-- CAP state tracking
HYPERDRIVE.CAP.State = {
    detectedStargates = {},
    detectedShields = {},
    detectedDHDs = {},
    stargateNetwork = {},
    lastScan = 0,
    energySharing = {},
}

-- Comprehensive CAP entity detection system
HYPERDRIVE.CAP.EntityCategories = {
    -- Stargate entities (all variants)
    STARGATES = {
        -- Main CAP Stargates
        "stargate_atlantis", "stargate_milkyway", "stargate_universe",
        "stargate_supergate", "stargate_orlin", "stargate_tollan",
        -- Workshop variants
        "cap_stargate", "cap_stargate_sg1", "cap_stargate_atlantis",
        "cap_stargate_universe", "cap_stargate_destiny",
        -- Legacy variants
        "sg_atlantis", "sg_milkyway", "sg_universe"
    },

    -- Shield entities (all types)
    SHIELDS = {
        -- Main CAP Shields
        "shield", "shield_core_buble", "shield_core_goauld",
        "shield_core_asgard", "shield_core_atlantis",
        -- Workshop variants
        "cap_shield_generator", "cap_bubble_shield", "cap_iris_shield",
        "cap_personal_shield", "cap_asgard_shield", "cap_ancient_shield",
        -- Legacy variants
        "sg_shield", "sg_iris"
    },

    -- DHD and control entities
    DHD = {
        -- Main CAP DHDs
        "dhd_atlantis", "dhd_milkyway", "dhd_universe", "dhd_pegasus",
        -- Workshop variants
        "cap_dhd", "cap_dhd_atlantis", "cap_dhd_milkyway",
        "cap_dhd_universe", "cap_control_crystal",
        -- Control interfaces
        "cap_ancient_console", "cap_computer", "cap_control_chair"
    },

    -- Energy systems (power sources)
    ENERGY_SYSTEMS = {
        -- Main CAP Energy
        "zpm", "zpm_hub", "naquadah_generator", "potentia",
        -- Workshop variants
        "cap_zpm", "cap_zpm_hub", "cap_naquadah_generator",
        "cap_potentia", "cap_energy_crystal",
        -- Advanced power
        "cap_zero_point_module", "cap_power_core", "cap_reactor"
    },

    -- Transportation systems
    TRANSPORTATION = {
        -- Ring transporters
        "rings_ancient", "rings_goauld", "rings_ori", "transporter",
        -- Workshop variants
        "cap_ring_transporter", "cap_asgard_transporter",
        "cap_ancient_transporter", "cap_ori_transporter",
        -- Beam systems
        "cap_beam_transporter", "cap_teleporter"
    },

    -- Weapon systems
    WEAPONS = {
        -- Personal weapons
        "cap_staff_weapon", "cap_zat", "cap_goa_ribbon_device",
        -- Ship weapons
        "cap_drone_weapon", "cap_plasma_cannon", "cap_ion_cannon",
        -- Defense systems
        "cap_defense_drone", "cap_satellite_weapon"
    },

    -- Technology and devices
    TECHNOLOGY = {
        -- Communication
        "cap_long_range_communicator", "cap_subspace_communicator",
        -- Sensors
        "cap_sensor_array", "cap_life_signs_detector",
        -- Medical
        "cap_sarcophagus", "cap_healing_device",
        -- Misc tech
        "cap_hologram_projector", "cap_time_dilation_device"
    },

    -- Resource entities (CAP Resources addon)
    RESOURCES = {
        -- Storage
        "cap_resource_storage", "cap_liquid_storage", "cap_gas_storage",
        -- Processing
        "cap_refinery", "cap_processor", "cap_converter",
        -- Distribution
        "cap_resource_node", "cap_pipe", "cap_conduit"
    }
}

-- Function to get CAP configuration
local function GetCAPConfig(key, default)
    if HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.Get then
        return HYPERDRIVE.EnhancedConfig.Get("CAP", key, HYPERDRIVE.CAP.Config[key] or default)
    end
    return HYPERDRIVE.CAP.Config[key] or default
end

-- Comprehensive CAP Detection System
function HYPERDRIVE.CAP.DetectCAP()
    local detection = {
        main = false,
        resources = false,
        workshop = false,
        stargate = false,
        entities = {},
        version = "Unknown",
        features = {}
    }

    -- Check for main CAP addon (StarGate global)
    if StarGate then
        detection.stargate = true
        detection.main = true
        detection.version = StarGate.Version or StarGate.version or "Unknown"

        -- Check StarGate features
        detection.features.core = StarGate.IsEntityValid and StarGate.GetEntityCentre and true or false
        detection.features.shields = StarGate.IsEntityShielded and true or false
        detection.features.tracing = StarGate.Trace and true or false
        detection.features.eventHorizon = StarGate.EventHorizonTypes and true or false
        detection.features.addresses = StarGate.GetAddresses and true or false
        detection.features.network = StarGate.GetStargateNetwork and true or false

        print("[Hyperdrive CAP] Main CAP addon detected: " .. detection.version)
    end

    -- Check for CAP global (alternative detection)
    if CAP then
        detection.main = true
        if not detection.version or detection.version == "Unknown" then
            detection.version = CAP.Version or CAP.version or "CAP Detected"
        end
        print("[Hyperdrive CAP] CAP global detected: " .. detection.version)
    end

    -- Check for CAP Resources addon
    if CAP_RESOURCES or cap_resources or (CAP and CAP.Resources) then
        detection.resources = true
        print("[Hyperdrive CAP] CAP Resources addon detected")
    end

    -- Check for Workshop/entity-based CAP
    local entityCount = 0
    local storedEnts = scripted_ents.GetStored()
    if storedEnts then
        for category, entities in pairs(HYPERDRIVE.CAP.EntityCategories) do
            for _, entClass in ipairs(entities) do
                if storedEnts[entClass] then
                    detection.entities[entClass] = true
                    detection.workshop = true
                    entityCount = entityCount + 1
                end
            end
        end
    end

    if detection.workshop then
        print("[Hyperdrive CAP] Workshop CAP entities detected: " .. entityCount .. " types")
    end

    -- Store detection results
    HYPERDRIVE.CAP.Detection = detection
    HYPERDRIVE.CAP.Available = detection.main or detection.resources or detection.workshop

    return HYPERDRIVE.CAP.Available, detection
end

-- Check if specific CAP feature is available
function HYPERDRIVE.CAP.HasFeature(feature)
    if not HYPERDRIVE.CAP.Detection then
        HYPERDRIVE.CAP.DetectCAP()
    end

    return HYPERDRIVE.CAP.Detection.features and HYPERDRIVE.CAP.Detection.features[feature] or false
end

-- Get entity category
function HYPERDRIVE.CAP.GetEntityCategory(className)
    for category, entities in pairs(HYPERDRIVE.CAP.EntityCategories) do
        for _, entClass in ipairs(entities) do
            if entClass == className then
                return category
            end
        end
    end
    return nil
end

-- Enhanced CAP Shield System Integration
HYPERDRIVE.CAP.Shields = HYPERDRIVE.CAP.Shields or {}

-- Initialize shield system
function HYPERDRIVE.CAP.Shields.Initialize()
    if not HYPERDRIVE.CAP.Available then return false end

    -- Register shield types with their capabilities
    HYPERDRIVE.CAP.Shields.Types = {
        -- Main CAP shields
        shield = { power = 100, radius = 500, frequency = true, bubble = true },
        shield_core_buble = { power = 150, radius = 750, frequency = true, bubble = true },
        shield_core_goauld = { power = 120, radius = 600, frequency = true, bubble = false },
        shield_core_asgard = { power = 200, radius = 1000, frequency = true, bubble = true },
        shield_core_atlantis = { power = 250, radius = 1200, frequency = true, bubble = true },

        -- Workshop variants
        cap_shield_generator = { power = 100, radius = 500, frequency = false, bubble = true },
        cap_bubble_shield = { power = 150, radius = 750, frequency = true, bubble = true },
        cap_iris_shield = { power = 80, radius = 200, frequency = false, bubble = false },
        cap_personal_shield = { power = 50, radius = 100, frequency = false, bubble = false },
        cap_asgard_shield = { power = 200, radius = 1000, frequency = true, bubble = true },
        cap_ancient_shield = { power = 250, radius = 1200, frequency = true, bubble = true }
    }

    print("[Hyperdrive CAP] Shield system initialized with " .. table.Count(HYPERDRIVE.CAP.Shields.Types) .. " shield types")
    return true
end

-- Find CAP shields on ship
function HYPERDRIVE.CAP.Shields.FindShields(ship)
    if not ship or not ship.GetEntities then return {} end

    local shields = {}
    for _, ent in ipairs(ship:GetEntities()) do
        if IsValid(ent) then
            local category = HYPERDRIVE.CAP.GetEntityCategory(ent:GetClass())
            if category == "SHIELDS" then
                table.insert(shields, ent)
            end
        end
    end

    return shields
end

-- Create CAP shield for ship
function HYPERDRIVE.CAP.Shields.CreateShield(core, ship, shieldType)
    if not HYPERDRIVE.CAP.Available then return nil end
    if not GetCAPConfig("AutoCreateShields", true) then return nil end

    shieldType = shieldType or "cap_bubble_shield"

    -- Check if shield type is available
    if not HYPERDRIVE.CAP.Shields.Types[shieldType] then
        shieldType = "cap_shield_generator" -- Fallback
    end

    -- Don't create if shields already exist
    local existingShields = HYPERDRIVE.CAP.Shields.FindShields(ship)
    if #existingShields > 0 then
        return existingShields[1]
    end

    -- Create shield entity
    local shield = ents.Create(shieldType)
    if IsValid(shield) then
        -- Position shield near ship core
        local pos = core:GetPos() + Vector(0, 0, 100)
        shield:SetPos(pos)
        shield:SetAngles(core:GetAngles())
        shield:Spawn()
        shield:Activate()

        -- Link to hyperdrive system
        shield.ShipCore = core
        shield.HyperdriveManaged = true
        shield.CreatedBy = "hyperdrive_system"

        -- Configure shield properties
        local shieldConfig = HYPERDRIVE.CAP.Shields.Types[shieldType]
        if shieldConfig then
            if shield.SetShieldStrength then
                shield:SetShieldStrength(shieldConfig.power)
            end

            if shield.SetShieldRadius then
                local shipSize = ship and ship.GetSize and ship:GetSize() or 500
                local radius = math.max(shipSize * 1.2, shieldConfig.radius)
                shield:SetShieldRadius(radius)
            end

            if shield.SetFrequency and shieldConfig.frequency then
                shield:SetFrequency(math.random(1000, 9999))
            end
        end

        print("[Hyperdrive CAP] Created " .. shieldType .. " for ship")
        return shield
    end

    return nil
end

-- Activate CAP shields
function HYPERDRIVE.CAP.Shields.Activate(core, ship, reason)
    if not HYPERDRIVE.CAP.Available then return false end

    local shields = HYPERDRIVE.CAP.Shields.FindShields(ship)
    if #shields == 0 and GetCAPConfig("AutoCreateShields", true) then
        local newShield = HYPERDRIVE.CAP.Shields.CreateShield(core, ship)
        if newShield then
            shields = {newShield}
        end
    end

    local activatedCount = 0
    for _, shield in ipairs(shields) do
        if IsValid(shield) then
            local activated = false

            -- Try multiple activation methods for compatibility
            if shield.Activate then
                shield:Activate()
                activated = true
            elseif shield.TurnOn then
                shield:TurnOn()
                activated = true
            elseif shield.SetActive then
                shield:SetActive(true)
                activated = true
            elseif shield.Enable then
                shield:Enable()
                activated = true
            elseif shield.SetEnabled then
                shield:SetEnabled(true)
                activated = true
            end

            if activated then
                shield.ActivationReason = reason or "hyperdrive"
                shield.ActivatedBy = "hyperdrive_system"
                shield.ActivationTime = CurTime()
                activatedCount = activatedCount + 1

                -- Trigger CAP shield effects
                HYPERDRIVE.CAP.Effects.TriggerShieldActivation(shield)
            end
        end
    end

    if activatedCount > 0 then
        print("[Hyperdrive CAP] Activated " .. activatedCount .. " shields for " .. (reason or "hyperdrive"))
        return true
    end

    return false
end

-- Deactivate CAP shields
function HYPERDRIVE.CAP.Shields.Deactivate(core, ship, reason)
    if not HYPERDRIVE.CAP.Available then return false end

    local shields = HYPERDRIVE.CAP.Shields.FindShields(ship)
    local deactivatedCount = 0

    for _, shield in ipairs(shields) do
        if IsValid(shield) then
            local deactivated = false

            -- Try multiple deactivation methods for compatibility
            if shield.Deactivate then
                shield:Deactivate()
                deactivated = true
            elseif shield.TurnOff then
                shield:TurnOff()
                deactivated = true
            elseif shield.SetActive then
                shield:SetActive(false)
                deactivated = true
            elseif shield.Disable then
                shield:Disable()
                deactivated = true
            elseif shield.SetEnabled then
                shield:SetEnabled(false)
                deactivated = true
            end

            if deactivated then
                shield.DeactivationReason = reason or "hyperdrive"
                shield.DeactivatedBy = "hyperdrive_system"
                shield.DeactivationTime = CurTime()
                deactivatedCount = deactivatedCount + 1

                -- Trigger CAP shield effects
                HYPERDRIVE.CAP.Effects.TriggerShieldDeactivation(shield)
            end
        end
    end

    if deactivatedCount > 0 then
        print("[Hyperdrive CAP] Deactivated " .. deactivatedCount .. " shields for " .. (reason or "hyperdrive"))
        return true
    end

    return false
end

-- Get comprehensive shield status
function HYPERDRIVE.CAP.Shields.GetStatus(core, ship)
    if not HYPERDRIVE.CAP.Available then return nil end

    local shields = HYPERDRIVE.CAP.Shields.FindShields(ship)
    if #shields == 0 then return nil end

    local status = {
        count = #shields,
        active = 0,
        totalStrength = 0,
        maxStrength = 0,
        averagePercentage = 0,
        shields = {}
    }

    for i, shield in ipairs(shields) do
        if IsValid(shield) then
            local shieldStatus = {
                entity = shield,
                class = shield:GetClass(),
                active = false,
                strength = 0,
                maxStrength = 100,
                percentage = 0,
                frequency = 0,
                radius = 0,
                overloaded = false,
                recharging = false
            }

            -- Get shield status using multiple methods
            if shield.GetActive then
                shieldStatus.active = shield:GetActive()
            elseif shield.IsActive then
                shieldStatus.active = shield:IsActive()
            elseif shield.GetEnabled then
                shieldStatus.active = shield:GetEnabled()
            end

            if shield.GetShieldStrength then
                shieldStatus.strength = shield:GetShieldStrength()
            elseif shield.GetHealth then
                shieldStatus.strength = shield:GetHealth()
            end

            if shield.GetMaxShieldStrength then
                shieldStatus.maxStrength = shield:GetMaxShieldStrength()
            elseif shield.GetMaxHealth then
                shieldStatus.maxStrength = shield:GetMaxHealth()
            end

            if shieldStatus.maxStrength > 0 then
                shieldStatus.percentage = (shieldStatus.strength / shieldStatus.maxStrength) * 100
            end

            if shield.GetFrequency then
                shieldStatus.frequency = shield:GetFrequency()
            end

            if shield.GetShieldRadius then
                shieldStatus.radius = shield:GetShieldRadius()
            end

            if shield.GetOverloaded then
                shieldStatus.overloaded = shield:GetOverloaded()
            end

            if shield.GetRecharging then
                shieldStatus.recharging = shield:GetRecharging()
            end

            -- Add to totals
            if shieldStatus.active then
                status.active = status.active + 1
            end
            status.totalStrength = status.totalStrength + shieldStatus.strength
            status.maxStrength = status.maxStrength + shieldStatus.maxStrength

            status.shields[i] = shieldStatus
        end
    end

    -- Calculate average percentage
    if status.maxStrength > 0 then
        status.averagePercentage = (status.totalStrength / status.maxStrength) * 100
    end

    return status
end

-- CAP Effects System Integration
HYPERDRIVE.CAP.Effects = HYPERDRIVE.CAP.Effects or {}

-- Initialize effects system
function HYPERDRIVE.CAP.Effects.Initialize()
    if not HYPERDRIVE.CAP.Available then return false end

    print("[Hyperdrive CAP] Effects system initialized")
    return true
end

-- Trigger shield activation effects
function HYPERDRIVE.CAP.Effects.TriggerShieldActivation(shield)
    if not IsValid(shield) then return end

    -- Play CAP shield activation sound
    if shield.EmitSound then
        shield:EmitSound("stargate/shield_activate.wav", 75, 100)
    end

    -- Create visual effect
    if CLIENT then return end

    local effectData = EffectData()
    effectData:SetOrigin(shield:GetPos())
    effectData:SetEntity(shield)
    util.Effect("cap_shield_activate", effectData)
end

-- Trigger shield deactivation effects
function HYPERDRIVE.CAP.Effects.TriggerShieldDeactivation(shield)
    if not IsValid(shield) then return end

    -- Play CAP shield deactivation sound
    if shield.EmitSound then
        shield:EmitSound("stargate/shield_deactivate.wav", 75, 100)
    end

    -- Create visual effect
    if CLIENT then return end

    local effectData = EffectData()
    effectData:SetOrigin(shield:GetPos())
    effectData:SetEntity(shield)
    util.Effect("cap_shield_deactivate", effectData)
end

-- CAP Resource Integration
HYPERDRIVE.CAP.Resources = HYPERDRIVE.CAP.Resources or {}

-- Initialize resource system
function HYPERDRIVE.CAP.Resources.Initialize()
    if not HYPERDRIVE.CAP.Available then return false end

    -- Define CAP resource types and their SB3 equivalents
    HYPERDRIVE.CAP.Resources.Types = {
        -- CAP energy types
        zpm_energy = { sb3_type = "energy", multiplier = 10, capacity = 50000 },
        naquadah_energy = { sb3_type = "energy", multiplier = 5, capacity = 25000 },
        potentia_energy = { sb3_type = "energy", multiplier = 3, capacity = 15000 },

        -- CAP resource types (if CAP Resources addon is present)
        naquadah = { sb3_type = "fuel", multiplier = 2, capacity = 5000 },
        trinium = { sb3_type = "coolant", multiplier = 1.5, capacity = 3000 },
        neutronium = { sb3_type = "nitrogen", multiplier = 1, capacity = 2000 }
    }

    print("[Hyperdrive CAP] Resource system initialized with " .. table.Count(HYPERDRIVE.CAP.Resources.Types) .. " resource types")
    return true
end

-- Find CAP energy sources on ship
function HYPERDRIVE.CAP.Resources.FindEnergySources(ship)
    if not ship or not ship.GetEntities then return {} end

    local energySources = {}
    for _, ent in ipairs(ship:GetEntities()) do
        if IsValid(ent) then
            local category = HYPERDRIVE.CAP.GetEntityCategory(ent:GetClass())
            if category == "ENERGY_SYSTEMS" then
                table.insert(energySources, ent)
            end
        end
    end

    return energySources
end

-- Get total CAP energy available
function HYPERDRIVE.CAP.Resources.GetTotalEnergy(ship)
    local energySources = HYPERDRIVE.CAP.Resources.FindEnergySources(ship)
    local totalEnergy = 0

    for _, source in ipairs(energySources) do
        if IsValid(source) then
            local energy = 0

            -- Try different methods to get energy
            if source.GetEnergy then
                energy = source:GetEnergy()
            elseif source.GetPower then
                energy = source:GetPower()
            elseif source.GetCharge then
                energy = source:GetCharge()
            elseif source.GetStoredEnergy then
                energy = source:GetStoredEnergy()
            end

            totalEnergy = totalEnergy + energy
        end
    end

    return totalEnergy
end

-- Transfer CAP energy to SB3 system
function HYPERDRIVE.CAP.Resources.TransferToSB3(ship, core, amount)
    if not HYPERDRIVE.SB3Resources then return false end
    if not GetCAPConfig("ShareResourceStorage", true) then return false end

    local energySources = HYPERDRIVE.CAP.Resources.FindEnergySources(ship)
    local transferred = 0

    for _, source in ipairs(energySources) do
        if IsValid(source) and transferred < amount then
            local available = 0

            -- Get available energy
            if source.GetEnergy then
                available = source:GetEnergy()
            elseif source.GetPower then
                available = source:GetPower()
            elseif source.GetCharge then
                available = source:GetCharge()
            end

            if available > 0 then
                local toTransfer = math.min(available, amount - transferred)

                -- Remove from CAP source
                if source.SetEnergy then
                    source:SetEnergy(available - toTransfer)
                elseif source.SetPower then
                    source:SetPower(available - toTransfer)
                elseif source.SetCharge then
                    source:SetCharge(available - toTransfer)
                end

                -- Add to SB3 system
                HYPERDRIVE.SB3Resources.AddResource(core, "energy", toTransfer)
                transferred = transferred + toTransfer
            end
        end
    end

    return transferred
end

-- Main CAP Integration System
function HYPERDRIVE.CAP.Initialize()
    if not GetCAPConfig("Enabled", true) then
        print("[Hyperdrive CAP] CAP integration disabled in configuration")
        return false
    end

    local available, detection = HYPERDRIVE.CAP.DetectCAP()
    if not available then
        print("[Hyperdrive CAP] CAP not detected - integration disabled")
        return false
    end

    -- Initialize subsystems
    HYPERDRIVE.CAP.Shields.Initialize()
    HYPERDRIVE.CAP.Effects.Initialize()
    HYPERDRIVE.CAP.Resources.Initialize()

    -- Register with hyperdrive system
    if HYPERDRIVE.Shields and HYPERDRIVE.Shields.RegisterProvider then
        HYPERDRIVE.Shields.RegisterProvider("CAP", {
            CreateShield = HYPERDRIVE.CAP.Shields.CreateShield,
            ActivateShields = HYPERDRIVE.CAP.Shields.Activate,
            DeactivateShields = HYPERDRIVE.CAP.Shields.Deactivate,
            GetShieldStatus = HYPERDRIVE.CAP.Shields.GetStatus,
            FindShields = HYPERDRIVE.CAP.Shields.FindShields
        })
        print("[Hyperdrive CAP] Registered as shield provider")
    else
        -- Create the shield provider registration system if it doesn't exist
        HYPERDRIVE.Shields = HYPERDRIVE.Shields or {}
        HYPERDRIVE.Shields.Providers = HYPERDRIVE.Shields.Providers or {}
        HYPERDRIVE.Shields.Providers["CAP"] = {
            CreateShield = HYPERDRIVE.CAP.Shields.CreateShield,
            ActivateShields = HYPERDRIVE.CAP.Shields.Activate,
            DeactivateShields = HYPERDRIVE.CAP.Shields.Deactivate,
            GetShieldStatus = HYPERDRIVE.CAP.Shields.GetStatus,
            FindShields = HYPERDRIVE.CAP.Shields.FindShields
        }
        print("[Hyperdrive CAP] Created shield provider system and registered CAP")
    end

    -- Initialize modern UI integration for CAP
    HYPERDRIVE.CAP.UI = {
        theme = "modern",
        notifications = {},
        lastUpdate = 0,
        updateInterval = 1.0
    }

    print("[Hyperdrive CAP] Comprehensive CAP integration with modern UI initialized successfully!")
    print("[Hyperdrive CAP] Detection results:")
    print("  - Main CAP: " .. tostring(detection.main))
    print("  - CAP Resources: " .. tostring(detection.resources))
    print("  - Workshop CAP: " .. tostring(detection.workshop))
    print("  - Version: " .. detection.version)
    print("  - Modern UI: Enabled")

    return true
end

-- Enhanced entity detection using CAP framework and Ship Core system
function HYPERDRIVE.CAP.DetectCAPEntities(engine, searchRadius)
    if not GetCAPConfig("Enabled", true) then return {} end

    -- Use our ship core system first
    if HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(engine)
        if ship and ship.GetEntities then
            local shipEntities = ship:GetEntities()
            if #shipEntities > 0 then
                print("[Hyperdrive CAP] Using Ship Core system - found " .. #shipEntities .. " entities")

                -- Filter for CAP entities only
                local capEntities = {}
                for _, ent in ipairs(shipEntities) do
                    if IsValid(ent) then
                        local category = HYPERDRIVE.CAP.GetEntityCategory(ent:GetClass())
                        if category then
                            table.insert(capEntities, ent)
                        end
                    end
                end

                if #capEntities > 0 then
                    print("[Hyperdrive CAP] Found " .. #capEntities .. " CAP entities in ship")
                    return capEntities
                end
            end
        end
    end

    -- Fallback to radius search
    local entities = ents.FindInSphere(engine:GetPos(), searchRadius or 2000)
    local capEntities = {}

    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            local category = HYPERDRIVE.CAP.GetEntityCategory(ent:GetClass())
            if category then
                table.insert(capEntities, ent)
            end
        end
    end

    return capEntities
end

-- Hook integration
hook.Add("Initialize", "HyperdriveCAP", function()
    timer.Simple(1, function() -- Delay to ensure other addons load first
        HYPERDRIVE.CAP.Initialize()
    end)
end)

-- Console command for CAP status
concommand.Add("hyperdrive_cap_status", function(ply, cmd, args)
    if not HYPERDRIVE.CAP then
        print("CAP integration not loaded")
        return
    end

    local detection = HYPERDRIVE.CAP.Detection
    if detection then
        print("=== Enhanced Hyperdrive CAP Integration Status ===")
        print("Main CAP: " .. tostring(detection.main))
        print("CAP Resources: " .. tostring(detection.resources))
        print("Workshop CAP: " .. tostring(detection.workshop))
        print("Version: " .. detection.version)
        print("Available: " .. tostring(HYPERDRIVE.CAP.Available))

        if detection.features then
            print("Features:")
            for feature, available in pairs(detection.features) do
                print("  " .. feature .. ": " .. tostring(available))
            end
        end

        if detection.entities then
            print("Detected entities: " .. table.Count(detection.entities))
        end
    else
        print("CAP detection not run yet")
    end
end)

print("[Hyperdrive] Comprehensive CAP Integration v2.1.0 loaded successfully!")
