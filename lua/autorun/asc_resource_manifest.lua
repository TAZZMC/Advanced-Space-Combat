-- Advanced Space Combat - Resource Manifest v2.2.1
-- Comprehensive resource loading and management system

print("[Advanced Space Combat] Resource Manifest v2.2.1 - Loading...")

-- Initialize resource namespace
ASC = ASC or {}
ASC.Resources = ASC.Resources or {}

-- Resource configuration
ASC.Resources.Config = {
    EnableResourceLoading = true,
    EnableModelPrecaching = true,
    EnableSoundPrecaching = true,
    EnableMaterialPrecaching = true,
    EnableEffectPrecaching = true,
    LogResourceLoading = true
}

-- Resource lists
ASC.Resources.Models = {
    -- Ship Components
    "models/asc/ship_core.mdl",
    "models/asc/hyperdrive_engine.mdl",
    "models/asc/hyperdrive_master_engine.mdl",
    "models/asc/hyperdrive_computer.mdl",
    
    -- Ancient Technology
    "models/asc/ancient/ancient_drone.mdl",
    "models/asc/ancient/ancient_drone_projectile.mdl",
    "models/asc/ancient/ancient_satellite.mdl",
    "models/asc/ancient/ancient_zpm.mdl",
    "models/asc/ancient/ancient_control_chair.mdl",
    "models/asc/ancient/ancient_stargate.mdl",
    "models/asc/ancient/ancient_shield_generator.mdl",
    "models/asc/ancient/ancient_time_device.mdl",
    "models/asc/ancient/ancient_healing_device.mdl",
    
    -- Asgard Technology
    "models/asc/asgard/asgard_ion_cannon.mdl",
    "models/asc/asgard/asgard_plasma_beam.mdl",
    "models/asc/asgard/asgard_shield_generator.mdl",
    "models/asc/asgard/asgard_hyperdrive.mdl",
    "models/asc/asgard/asgard_beamer.mdl",
    "models/asc/asgard/asgard_computer.mdl",
    "models/asc/asgard/asgard_cloning_facility.mdl",
    "models/asc/asgard/asgard_hologram.mdl",
    "models/asc/asgard/asgard_time_device.mdl",
    
    -- Goa'uld Technology
    "models/asc/goauld/goauld_staff_cannon.mdl",
    "models/asc/goauld/goauld_ribbon_device.mdl",
    "models/asc/goauld/goauld_hand_device.mdl",
    "models/asc/goauld/goauld_shield_generator.mdl",
    "models/asc/goauld/goauld_hyperdrive.mdl",
    "models/asc/goauld/goauld_sarcophagus.mdl",
    "models/asc/goauld/goauld_rings.mdl",
    "models/asc/goauld/goauld_naquadah_reactor.mdl",
    "models/asc/goauld/goauld_cloak.mdl",
    
    -- Wraith Technology
    "models/asc/wraith/wraith_dart_weapon.mdl",
    "models/asc/wraith/wraith_culling_beam.mdl",
    "models/asc/wraith/wraith_shield_generator.mdl",
    "models/asc/wraith/wraith_hyperdrive.mdl",
    "models/asc/wraith/wraith_life_pod.mdl",
    "models/asc/wraith/wraith_enzyme.mdl",
    "models/asc/wraith/wraith_regen_chamber.mdl",
    "models/asc/wraith/wraith_hive_mind.mdl",
    
    -- Ori Technology
    "models/asc/ori/ori_pulse_weapon.mdl",
    "models/asc/ori/ori_beam_weapon.mdl",
    "models/asc/ori/ori_shield_generator.mdl",
    "models/asc/ori/ori_hyperdrive.mdl",
    "models/asc/ori/ori_supergate.mdl",
    "models/asc/ori/ori_prior_staff.mdl",
    "models/asc/ori/ori_satellite.mdl",
    
    -- Tau'ri Technology
    "models/asc/tauri/tauri_railgun.mdl",
    "models/asc/tauri/tauri_nuke_missile.mdl",
    "models/asc/tauri/tauri_shield_generator.mdl",
    "models/asc/tauri/tauri_hyperdrive.mdl",
    "models/asc/tauri/tauri_f302.mdl",
    "models/asc/tauri/tauri_iris.mdl",
    "models/asc/tauri/tauri_prometheus_engine.mdl",
    
    -- Flight and Transport
    "models/asc/flight_console.mdl",
    "models/asc/docking_pad_small.mdl",
    "models/asc/docking_pad_medium.mdl",
    "models/asc/docking_pad_large.mdl",
    "models/asc/docking_pad_shuttle.mdl",
    "models/asc/docking_pad_cargo.mdl",
    "models/asc/shuttle_transport.mdl",
    "models/asc/shuttle_cargo.mdl",
    "models/asc/shuttle_emergency.mdl",
    "models/asc/shuttle_scout.mdl"
}

ASC.Resources.Materials = {
    -- UI Materials
    "asc/ui/loading_background",
    "asc/ui/loading_logo",
    "asc/ui/loading_elements",

    -- Ancient Materials
    "asc/ancient/ancient_metal",
    "asc/ancient/ancient_crystal",
    "asc/ancient/ancient_energy",
    "asc/ancient/ancient_hologram",
    "asc/ancient/ancient_glow",
    "asc/ancient/ancient_detail",
    
    -- Asgard Materials
    "asc/asgard/asgard_metal",
    "asc/asgard/asgard_crystal",
    "asc/asgard/asgard_energy",
    "asc/asgard/asgard_hologram",
    "asc/asgard/asgard_beam",
    
    -- Goa'uld Materials
    "asc/goauld/goauld_metal",
    "asc/goauld/goauld_gold",
    "asc/goauld/goauld_naquadah",
    "asc/goauld/goauld_energy",
    "asc/goauld/goauld_pyramid",
    
    -- Wraith Materials
    "asc/wraith/wraith_organic",
    "asc/wraith/wraith_bio",
    "asc/wraith/wraith_hive",
    "asc/wraith/wraith_energy",
    "asc/wraith/wraith_cocoon",
    
    -- Ori Materials
    "asc/ori/ori_metal",
    "asc/ori/ori_energy",
    "asc/ori/ori_crystal",
    "asc/ori/ori_fire",
    "asc/ori/ori_light",
    
    -- Tau'ri Materials
    "asc/tauri/tauri_metal",
    "asc/tauri/tauri_composite",
    "asc/tauri/tauri_titanium",
    "asc/tauri/tauri_electronics",
    
    -- UI Materials
    "asc/ui/button_normal",
    "asc/ui/button_hover",
    "asc/ui/button_pressed",
    "asc/ui/panel_background",
    "asc/ui/hologram_overlay",
    "asc/ui/energy_bar",
    "asc/ui/shield_bar",
    "asc/ui/health_bar",
    
    -- Effect Materials
    "asc/effects/energy_ball",
    "asc/effects/plasma_bolt",
    "asc/effects/beam_core",
    "asc/effects/explosion_core",
    "asc/effects/shield_impact",
    "asc/effects/hyperspace_tunnel",
    "asc/effects/stargate_kawoosh",
    "asc/effects/transporter_beam"
}

ASC.Resources.Sounds = {
    -- Ancient Sounds
    "asc/weapons/ancient_drone_fire.wav",
    "asc/weapons/ancient_drone_impact.wav",
    "asc/weapons/ancient_drone_explode.wav",
    "asc/weapons/ancient_explosion.wav",
    "asc/shields/ancient_activate.wav",
    "asc/shields/ancient_hit.wav",
    "asc/engines/ancient_hyperdrive.wav",
    
    -- Asgard Sounds
    "asc/weapons/asgard_ion_fire.wav",
    "asc/weapons/asgard_plasma_fire.wav",
    "asc/weapons/asgard_beam.wav",
    "asc/shields/asgard_activate.wav",
    "asc/engines/asgard_hyperdrive.wav",
    "asc/systems/asgard_beaming.wav",
    
    -- Goa'uld Sounds
    "asc/weapons/goauld_staff_fire.wav",
    "asc/weapons/goauld_ribbon_fire.wav",
    "asc/weapons/goauld_hand_device.wav",
    "asc/shields/goauld_activate.wav",
    "asc/engines/goauld_hyperdrive.wav",
    "asc/systems/goauld_rings.wav",
    "asc/systems/goauld_sarcophagus.wav",
    
    -- Wraith Sounds
    "asc/weapons/wraith_dart_fire.wav",
    "asc/weapons/wraith_culling_beam.wav",
    "asc/shields/wraith_activate.wav",
    "asc/engines/wraith_hyperdrive.wav",
    "asc/systems/wraith_hive_mind.wav",
    
    -- Ori Sounds
    "asc/weapons/ori_pulse_fire.wav",
    "asc/weapons/ori_beam_fire.wav",
    "asc/weapons/ori_satellite_fire.wav",
    "asc/shields/ori_activate.wav",
    "asc/engines/ori_hyperdrive.wav",
    "asc/systems/ori_supergate.wav",
    
    -- Tau'ri Sounds
    "asc/weapons/tauri_railgun_fire.wav",
    "asc/weapons/tauri_nuke_launch.wav",
    "asc/weapons/tauri_nuke_explode.wav",
    "asc/shields/tauri_activate.wav",
    "asc/engines/tauri_hyperdrive.wav",
    "asc/engines/tauri_prometheus.wav",
    
    -- General Sounds
    "asc/engines/hyperdrive_charge.wav",
    "asc/engines/hyperdrive_jump.wav",
    "asc/ui/button_click.wav",
    "asc/ui/interface_open.wav",
    "asc/ui/notification.wav",
    "asc/systems/ship_core_online.wav",
    "asc/systems/ship_core_offline.wav",
    "asc/systems/energy_low.wav",
    "asc/systems/shields_down.wav"
}

ASC.Resources.Effects = {
    "asc_ancient_drone_fire",
    "asc_ancient_drone_impact",
    "asc_ancient_drone_explosion",
    "asc_ancient_explosion",
    "asc_ancient_energy",
    "asc_ancient_damage",
    "asc_asgard_ion_fire",
    "asc_asgard_plasma_fire",
    "asc_asgard_beam",
    "asc_asgard_beaming",
    "asc_goauld_staff_fire",
    "asc_goauld_ribbon_fire",
    "asc_goauld_rings",
    "asc_wraith_dart_fire",
    "asc_wraith_culling_beam",
    "asc_ori_pulse_fire",
    "asc_ori_beam_fire",
    "asc_ori_satellite_fire",
    "asc_tauri_railgun_fire",
    "asc_tauri_nuke_explosion",
    "asc_shield_hit",
    "asc_hull_hit",
    "asc_ship_explosion",
    "asc_hyperdrive_charge",
    "asc_hyperdrive_jump",
    "asc_hyperspace_tunnel"
}

-- Resource loading functions with loading screen integration
function ASC.Resources.LoadModels()
    if not ASC.Resources.Config.EnableModelPrecaching then return end

    local totalModels = #ASC.Resources.Models

    for i, model in ipairs(ASC.Resources.Models) do
        if ASC.Resources.Config.LogResourceLoading then
            print("[Advanced Space Combat] Precaching model: " .. model)
        end
        util.PrecacheModel(model)

        -- Update loading screen progress
        if CLIENT and ASC.LoadingScreen then
            local progress = (i / totalModels) * 25 -- Models are 25% of total loading
            ASC.LoadingScreen.SetProgress(progress, "Loading models... (" .. i .. "/" .. totalModels .. ")",
                "Models", {loaded = i, total = totalModels})
        end
    end
end

function ASC.Resources.LoadSounds()
    if not ASC.Resources.Config.EnableSoundPrecaching then return end

    local totalSounds = #ASC.Resources.Sounds

    for i, sound in ipairs(ASC.Resources.Sounds) do
        if ASC.Resources.Config.LogResourceLoading then
            print("[Advanced Space Combat] Precaching sound: " .. sound)
        end
        util.PrecacheSound(sound)

        -- Update loading screen progress
        if CLIENT and ASC.LoadingScreen then
            local progress = 25 + (i / totalSounds) * 25 -- Sounds are 25-50% of total loading
            ASC.LoadingScreen.SetProgress(progress, "Loading sounds... (" .. i .. "/" .. totalSounds .. ")",
                "Sounds", {loaded = i, total = totalSounds})
        end
    end
end

function ASC.Resources.LoadMaterials()
    if not ASC.Resources.Config.EnableMaterialPrecaching then return end

    local totalMaterials = #ASC.Resources.Materials

    for i, material in ipairs(ASC.Resources.Materials) do
        if ASC.Resources.Config.LogResourceLoading then
            print("[Advanced Space Combat] Precaching material: " .. material)
        end
        Material(material)

        -- Update loading screen progress
        if CLIENT and ASC.LoadingScreen then
            local progress = 50 + (i / totalMaterials) * 25 -- Materials are 50-75% of total loading
            ASC.LoadingScreen.SetProgress(progress, "Loading materials... (" .. i .. "/" .. totalMaterials .. ")",
                "Materials", {loaded = i, total = totalMaterials})
        end
    end
end

function ASC.Resources.LoadEffects()
    if not ASC.Resources.Config.EnableEffectPrecaching then return end

    local totalEffects = #ASC.Resources.Effects

    for i, effect in ipairs(ASC.Resources.Effects) do
        if ASC.Resources.Config.LogResourceLoading then
            print("[Advanced Space Combat] Registering effect: " .. effect)
        end
        -- Effects are registered by their lua files

        -- Update loading screen progress
        if CLIENT and ASC.LoadingScreen then
            local progress = 75 + (i / totalEffects) * 25 -- Effects are 75-100% of total loading
            ASC.LoadingScreen.SetProgress(progress, "Loading effects... (" .. i .. "/" .. totalEffects .. ")",
                "Effects", {loaded = i, total = totalEffects})
        end
    end
end

-- Resource validation
function ASC.Resources.ValidateResources()
    local missingResources = {}
    
    -- Check models
    for _, model in ipairs(ASC.Resources.Models) do
        if not file.Exists(model, "GAME") then
            table.insert(missingResources, "Model: " .. model)
        end
    end
    
    -- Check sounds
    for _, sound in ipairs(ASC.Resources.Sounds) do
        if not file.Exists("sound/" .. sound, "GAME") then
            table.insert(missingResources, "Sound: " .. sound)
        end
    end
    
    -- Check materials
    for _, material in ipairs(ASC.Resources.Materials) do
        if not file.Exists("materials/" .. material .. ".vmt", "GAME") then
            table.insert(missingResources, "Material: " .. material)
        end
    end
    
    if #missingResources > 0 then
        print("[Advanced Space Combat] Warning: Missing resources detected:")
        for _, resource in ipairs(missingResources) do
            print("  - " .. resource)
        end
        print("[Advanced Space Combat] Some features may not work correctly without these resources.")
    else
        print("[Advanced Space Combat] All resources validated successfully!")
    end
    
    return #missingResources == 0
end

-- Resource download for clients
function ASC.Resources.AddClientDownloads()
    if SERVER then
        -- Add models to download
        for _, model in ipairs(ASC.Resources.Models) do
            resource.AddFile(model)
        end
        
        -- Add materials to download
        for _, material in ipairs(ASC.Resources.Materials) do
            resource.AddFile("materials/" .. material .. ".vmt")
            -- Also add texture files if they exist
            local textures = {".vtf", "_normal.vtf", "_glow.vtf", "_detail.vtf"}
            for _, ext in ipairs(textures) do
                local texFile = "materials/" .. material .. ext
                if file.Exists(texFile, "GAME") then
                    resource.AddFile(texFile)
                end
            end
        end
        
        -- Add sounds to download
        for _, sound in ipairs(ASC.Resources.Sounds) do
            resource.AddFile("sound/" .. sound)
        end
        
        print("[Advanced Space Combat] Added " .. (#ASC.Resources.Models + #ASC.Resources.Materials + #ASC.Resources.Sounds) .. " resources for client download")
    end
end

-- Initialize resource loading
function ASC.Resources.Initialize()
    if not ASC.Resources.Config.EnableResourceLoading then
        print("[Advanced Space Combat] Resource loading disabled")
        return
    end
    
    print("[Advanced Space Combat] Loading resources...")
    
    -- Load all resource types
    ASC.Resources.LoadModels()
    ASC.Resources.LoadSounds()
    ASC.Resources.LoadMaterials()
    ASC.Resources.LoadEffects()
    
    -- Validate resources
    ASC.Resources.ValidateResources()
    
    -- Add client downloads
    ASC.Resources.AddClientDownloads()
    
    print("[Advanced Space Combat] Resource loading complete!")

    -- Hide loading screen when complete
    if CLIENT and ASC.LoadingScreen then
        ASC.LoadingScreen.SetProgress(100, "Advanced Space Combat loaded successfully!")
        timer.Simple(2, function()
            ASC.LoadingScreen.Hide()
        end)
    end
end

-- Initialize on addon load
hook.Add("Initialize", "ASC_ResourceInit", function()
    ASC.Resources.Initialize()
end)

print("[Advanced Space Combat] Resource Manifest loaded successfully!")
