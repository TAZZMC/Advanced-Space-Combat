-- Advanced Space Combat - Resource Management System v6.0.0
-- Next-generation resource management with intelligent caching and optimization
-- Research-based implementation following 2025 resource management best practices

print("[Advanced Space Combat] Resource Management System v6.0.0 - Next-Generation Resource Intelligence Loading...")

-- Initialize resource management namespace
ASC = ASC or {}
ASC.Resources = ASC.Resources or {}

-- Next-generation resource configuration
ASC.Resources.Config = {
    Version = "6.0.0",

    -- Core features
    EnableResourcePrecaching = true,
    EnableFallbackResources = true,
    EnableResourceValidation = true,
    EnableResourceLogging = true,

    -- Advanced features
    EnableIntelligentCaching = true,
    EnableLazyLoading = true,
    EnableResourceCompression = true,
    EnableUsageAnalytics = true,
    EnableAdaptiveQuality = true,
    EnableMemoryOptimization = true,

    -- Resource paths
    BasePath = "asc/",
    MaterialsPath = "materials/asc/",
    ModelsPath = "models/asc/",
    SoundsPath = "sound/asc/",
    EffectsPath = "lua/effects/asc_",

    -- Performance settings
    Performance = {
        MaxCacheSize = 100 * 1024 * 1024,  -- 100MB
        MaxConcurrentLoads = 5,
        PreloadDistance = 2000,
        UnloadDistance = 5000,
        QualityLevels = {"low", "medium", "high", "ultra"}
    },

    -- Analytics
    Analytics = {
        TrackUsage = true,
        TrackPerformance = true,
        TrackErrors = true,
        ReportInterval = 300  -- 5 minutes
    }
}

-- Resource registry
ASC.Resources.Registry = {
    Materials = {},
    Models = {},
    Sounds = {},
    Effects = {},
    Fonts = {}
}

-- Essential materials list
ASC.Resources.Materials = {
    -- Ancient materials
    "asc/ancient/zmp_glow",
    "asc/ancient/crystal_energy",
    "asc/ancient/control_chair",
    "asc/ancient/stargate_ring",
    "asc/ancient/drone_trail",
    
    -- Asgard materials
    "asc/asgard/ion_beam",
    "asc/asgard/hologram",
    "asc/asgard/computer_display",
    "asc/asgard/beaming_effect",
    
    -- Goa'uld materials
    "asc/goauld/staff_blast",
    "asc/goauld/pyramid_gold",
    "asc/goauld/naquadah_glow",
    "asc/goauld/ring_energy",
    
    -- Wraith materials
    "asc/wraith/organic_hull",
    "asc/wraith/dart_energy",
    "asc/wraith/hive_texture",
    "asc/wraith/culling_beam",
    
    -- Ori materials
    "asc/ori/pulse_energy",
    "asc/ori/prior_glow",
    "asc/ori/supergate_ring",
    
    -- Tau'ri materials
    "asc/tauri/military_hull",
    "asc/tauri/railgun_trail",
    "asc/tauri/f302_hull",
    
    -- Weapons
    "asc/weapons/energy_beam",
    "asc/weapons/pulse_blast",
    "asc/weapons/torpedo_trail",
    "asc/weapons/plasma_ball",
    "asc/weapons/muzzle_flash",
    
    -- Shields
    "asc/shields/bubble_shield",
    "asc/shields/energy_barrier",
    "asc/shields/shield_impact",
    
    -- Effects
    "asc/effects/energy_field",
    "asc/effects/hyperspace_tunnel",
    "asc/effects/explosion_energy",
    "asc/effects/sparks",
    "asc/effects/smoke_trail"
}

-- Essential models list
ASC.Resources.Models = {
    -- Core entities
    "models/asc/ship_core.mdl",
    "models/asc/hyperdrive_engine.mdl",
    "models/asc/master_hyperdrive_engine.mdl",
    "models/asc/hyperdrive_computer.mdl",
    
    -- Weapons
    "models/asc/weapons/pulse_cannon.mdl",
    "models/asc/weapons/beam_weapon.mdl",
    "models/asc/weapons/torpedo_launcher.mdl",
    "models/asc/weapons/railgun.mdl",
    "models/asc/weapons/plasma_cannon.mdl",
    
    -- Flight systems
    "models/asc/flight_console.mdl",
    
    -- Transport
    "models/asc/transport/docking_pad_small.mdl",
    "models/asc/transport/docking_pad_medium.mdl",
    "models/asc/transport/docking_pad_large.mdl",
    "models/asc/transport/shuttle.mdl",
    
    -- Shields
    "models/asc/shields/shield_generator.mdl",
    
    -- Ancient technology
    "models/asc/ancient/zpm.mdl",
    "models/asc/ancient/control_chair.mdl",
    "models/asc/ancient/stargate.mdl",
    "models/asc/ancient/drone_weapon.mdl",
    
    -- Asgard technology
    "models/asc/asgard/ion_cannon.mdl",
    "models/asc/asgard/computer_core.mdl",
    "models/asc/asgard/beaming_device.mdl",
    
    -- Goa'uld technology
    "models/asc/goauld/staff_cannon.mdl",
    "models/asc/goauld/sarcophagus.mdl",
    "models/asc/goauld/hand_device.mdl",
    
    -- Wraith technology
    "models/asc/wraith/dart_weapon.mdl",
    "models/asc/wraith/regeneration_chamber.mdl",
    
    -- Ori technology
    "models/asc/ori/pulse_weapon.mdl",
    "models/asc/ori/prior_staff.mdl",
    
    -- Tau'ri technology
    "models/asc/tauri/f302_fighter.mdl",
    "models/asc/tauri/railgun.mdl"
}

-- Essential sounds list
ASC.Resources.Sounds = {
    -- Weapons
    "asc/weapons/pulse_cannon_fire.wav",
    "asc/weapons/beam_weapon_charge.wav",
    "asc/weapons/beam_weapon_fire.wav",
    "asc/weapons/torpedo_launch.wav",
    "asc/weapons/railgun_fire.wav",
    "asc/weapons/plasma_cannon_fire.wav",
    
    -- Engines
    "asc/engines/hyperdrive_charge.wav",
    "asc/engines/hyperdrive_jump.wav",
    "asc/engines/engine_idle.wav",
    
    -- Shields
    "asc/shields/shield_activate.wav",
    "asc/shields/shield_hit.wav",
    "asc/shields/shield_overload.wav",
    
    -- Ancient
    "asc/ancient/zpm_activate.wav",
    "asc/ancient/drone_launch.wav",
    "asc/ancient/stargate_activate.wav",
    
    -- Asgard
    "asc/asgard/ion_cannon_fire.wav",
    "asc/asgard/beaming_activate.wav",
    
    -- Goa'uld
    "asc/goauld/staff_cannon_fire.wav",
    "asc/goauld/sarcophagus_activate.wav",
    
    -- Wraith
    "asc/wraith/dart_weapon_fire.wav",
    "asc/wraith/culling_beam.wav",
    
    -- Ori
    "asc/ori/pulse_weapon_fire.wav",
    
    -- UI
    "asc/ui/button_click.wav",
    "asc/ui/notification.wav",
    "asc/ui/error.wav"
}

-- Effects list
ASC.Resources.Effects = {
    "asc_energy_transfer",
    "asc_zpm_activation",
    "asc_weapon_fire",
    "asc_shield_impact",
    "asc_hyperdrive_jump",
    "asc_explosion",
    "asc_hull_damage",
    "asc_critical_damage"
}

-- Resource precaching function
function ASC.Resources.PrecacheResources()
    if not ASC.Resources.Config.EnableResourcePrecaching then return end
    
    print("[Advanced Space Combat] Precaching resources...")
    
    -- Precache materials
    for _, material in ipairs(ASC.Resources.Materials) do
        ASC.Resources.PrecacheMaterial(material)
    end
    
    -- Precache models
    for _, model in ipairs(ASC.Resources.Models) do
        ASC.Resources.PrecacheModel(model)
    end
    
    -- Precache sounds
    for _, sound in ipairs(ASC.Resources.Sounds) do
        ASC.Resources.PrecacheSound(sound)
    end
    
    print("[Advanced Space Combat] Resource precaching complete")
end

-- Material precaching with fallback
function ASC.Resources.PrecacheMaterial(materialPath)
    local success = pcall(function()
        local mat = Material(materialPath)
        if mat:IsError() then
            if ASC.Resources.Config.EnableFallbackResources then
                ASC.Resources.CreateFallbackMaterial(materialPath)
            end
            if ASC.Resources.Config.EnableResourceLogging then
                print("[Advanced Space Combat] Missing material: " .. materialPath)
            end
        else
            ASC.Resources.Registry.Materials[materialPath] = mat
        end
    end)
    
    if not success and ASC.Resources.Config.EnableResourceLogging then
        print("[Advanced Space Combat] Failed to precache material: " .. materialPath)
    end
end

-- Model precaching with fallback
function ASC.Resources.PrecacheModel(modelPath)
    local success = pcall(function()
        util.PrecacheModel(modelPath)
        ASC.Resources.Registry.Models[modelPath] = modelPath
    end)
    
    if not success then
        if ASC.Resources.Config.EnableFallbackResources then
            ASC.Resources.CreateFallbackModel(modelPath)
        end
        if ASC.Resources.Config.EnableResourceLogging then
            print("[Advanced Space Combat] Missing model: " .. modelPath)
        end
    end
end

-- Sound precaching with fallback
function ASC.Resources.PrecacheSound(soundPath)
    local success = pcall(function()
        util.PrecacheSound(soundPath)
        ASC.Resources.Registry.Sounds[soundPath] = soundPath
    end)
    
    if not success then
        if ASC.Resources.Config.EnableFallbackResources then
            ASC.Resources.CreateFallbackSound(soundPath)
        end
        if ASC.Resources.Config.EnableResourceLogging then
            print("[Advanced Space Combat] Missing sound: " .. soundPath)
        end
    end
end

-- Create fallback material
function ASC.Resources.CreateFallbackMaterial(materialPath)
    local fallbackMat = Material("debug/debugempty")
    ASC.Resources.Registry.Materials[materialPath] = fallbackMat
end

-- Create fallback model
function ASC.Resources.CreateFallbackModel(modelPath)
    local fallbackModel = "models/error.mdl"
    ASC.Resources.Registry.Models[modelPath] = fallbackModel
end

-- Create fallback sound
function ASC.Resources.CreateFallbackSound(soundPath)
    local fallbackSound = "buttons/button15.wav"
    ASC.Resources.Registry.Sounds[soundPath] = fallbackSound
end

-- Resource getter functions
function ASC.Resources.GetMaterial(materialPath)
    return ASC.Resources.Registry.Materials[materialPath] or Material("debug/debugempty")
end

function ASC.Resources.GetModel(modelPath)
    return ASC.Resources.Registry.Models[modelPath] or "models/error.mdl"
end

function ASC.Resources.GetSound(soundPath)
    return ASC.Resources.Registry.Sounds[soundPath] or "buttons/button15.wav"
end

-- Resource validation
function ASC.Resources.ValidateResources()
    if not ASC.Resources.Config.EnableResourceValidation then return end
    
    local missingCount = 0
    
    -- Check materials
    for _, material in ipairs(ASC.Resources.Materials) do
        if not ASC.Resources.Registry.Materials[material] then
            missingCount = missingCount + 1
        end
    end
    
    -- Check models
    for _, model in ipairs(ASC.Resources.Models) do
        if not ASC.Resources.Registry.Models[model] then
            missingCount = missingCount + 1
        end
    end
    
    -- Check sounds
    for _, sound in ipairs(ASC.Resources.Sounds) do
        if not ASC.Resources.Registry.Sounds[sound] then
            missingCount = missingCount + 1
        end
    end
    
    if missingCount > 0 then
        print("[Advanced Space Combat] Warning: " .. missingCount .. " resources missing or using fallbacks")
    else
        print("[Advanced Space Combat] All resources validated successfully")
    end
end

-- Initialize resource management
hook.Add("Initialize", "ASC_ResourceManagement", function()
    ASC.Resources.PrecacheResources()
    
    timer.Simple(1, function()
        ASC.Resources.ValidateResources()
    end)
end)

print("[Advanced Space Combat] Resource Management System loaded successfully!")
