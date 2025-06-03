-- Advanced Space Combat - CAP Asset Integration System
-- Integrates CAP (Community Addon Pack) assets from Steam Workshop ID: 180077636

print("[Advanced Space Combat] CAP Asset Integration System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.Assets = ASC.CAP.Assets or {}

-- CAP Asset Configuration
ASC.CAP.Assets.Config = {
    EnableCAPAssets = true,
    EnableAssetValidation = true,
    EnableFallbackAssets = true,
    EnableAssetLogging = true,
    WorkshopID = "180077636", -- CAP Steam Workshop Collection
    
    -- Asset quality settings
    PreferCAPAssets = true,
    ValidateBeforeUse = true,
    CacheAssets = true
}

-- CAP Asset Registry
ASC.CAP.Assets.Registry = {
    Models = {},
    Materials = {},
    Sounds = {},
    Effects = {},
    LoadedAssets = 0,
    FailedAssets = {},
    CAPAvailable = false
}

-- CAP Model Database (from Steam Workshop Collection ID: 180077636)
ASC.CAP.Assets.Models = {
    -- Ancient Technology Models
    Ancient = {
        -- Core systems
        console = "models/cap/props/cap_console_01.mdl",
        crystal = "models/cap/props/cap_crystal_01.mdl",
        zpm = "models/cap/props/cap_zpm_01.mdl",
        chair = "models/cap/props/cap_chair_01.mdl",
        ring = "models/cap/props/cap_ring_01.mdl",
        platform = "models/cap/props/cap_platform_01.mdl",

        -- Weapons and defense
        drone = "models/cap/weapons/cap_drone_01.mdl",
        drone_weapon = "models/cap/weapons/cap_drone_weapon_01.mdl",
        satellite = "models/cap/weapons/cap_satellite_01.mdl",
        shield_generator = "models/cap/props/cap_shield_generator_01.mdl",

        -- Ships and vehicles
        puddle_jumper = "models/cap/vehicles/cap_puddle_jumper_01.mdl",
        ancient_ship = "models/cap/vehicles/cap_ancient_ship_01.mdl",

        -- Engines and propulsion
        hyperdrive = "models/cap/props/cap_hyperdrive_01.mdl",
        engine = "models/cap/props/cap_engine_01.mdl",
        thruster = "models/cap/props/cap_thruster_01.mdl"
    },

    -- Goa'uld Technology Models
    Goauld = {
        -- Core systems
        console = "models/cap/props/cap_goauld_console_01.mdl",
        sarcophagus = "models/cap/props/cap_sarcophagus_01.mdl",
        throne = "models/cap/props/cap_throne_01.mdl",
        panel = "models/cap/props/cap_goauld_panel_01.mdl",

        -- Weapons
        staff = "models/cap/weapons/cap_staff_01.mdl",
        staff_cannon = "models/cap/weapons/cap_staff_cannon_01.mdl",
        ribbon_device = "models/cap/weapons/cap_ribbon_device_01.mdl",

        -- Ships and vehicles
        death_glider = "models/cap/vehicles/cap_death_glider_01.mdl",
        mothership = "models/cap/vehicles/cap_mothership_01.mdl",

        -- Engines and propulsion
        hyperdrive = "models/cap/props/cap_goauld_hyperdrive_01.mdl",
        engine = "models/cap/props/cap_goauld_engine_01.mdl"
    },

    -- Asgard Technology Models
    Asgard = {
        -- Core systems
        console = "models/cap/props/cap_asgard_console_01.mdl",
        core = "models/cap/props/cap_asgard_core_01.mdl",
        hologram = "models/cap/props/cap_hologram_01.mdl",

        -- Weapons and defense
        beam = "models/cap/weapons/cap_asgard_beam_01.mdl",
        shield = "models/cap/props/cap_asgard_shield_01.mdl",

        -- Ships and vehicles
        ship = "models/cap/vehicles/cap_asgard_ship_01.mdl",

        -- Engines and propulsion
        hyperdrive = "models/cap/props/cap_asgard_hyperdrive_01.mdl",
        engine = "models/cap/props/cap_asgard_engine_01.mdl"
    },

    -- Tau'ri (Earth) Technology Models
    Tauri = {
        -- Core systems
        console = "models/cap/props/cap_tauri_console_01.mdl",
        computer = "models/cap/props/cap_computer_01.mdl",
        panel = "models/cap/props/cap_panel_01.mdl",
        chair = "models/cap/props/cap_tauri_chair_01.mdl",

        -- Weapons
        railgun = "models/cap/weapons/cap_railgun_01.mdl",
        missile = "models/cap/weapons/cap_missile_01.mdl",
        plasma_cannon = "models/cap/weapons/cap_plasma_cannon_01.mdl",

        -- Ships and vehicles
        f302 = "models/cap/vehicles/cap_f302_01.mdl",
        prometheus = "models/cap/vehicles/cap_prometheus_01.mdl",

        -- Engines and propulsion
        hyperdrive = "models/cap/props/cap_tauri_hyperdrive_01.mdl",
        engine = "models/cap/props/cap_tauri_engine_01.mdl",
        thruster = "models/cap/props/cap_tauri_thruster_01.mdl"
    },

    -- Ori Technology Models
    Ori = {
        -- Core systems
        console = "models/cap/props/cap_ori_console_01.mdl",
        altar = "models/cap/props/cap_altar_01.mdl",

        -- Weapons
        staff = "models/cap/weapons/cap_ori_staff_01.mdl",
        beam = "models/cap/weapons/cap_ori_beam_01.mdl",

        -- Ships and vehicles
        ship = "models/cap/vehicles/cap_ori_ship_01.mdl",

        -- Engines and propulsion
        engine = "models/cap/props/cap_ori_engine_01.mdl"
    },

    -- Wraith Technology Models
    Wraith = {
        -- Core systems
        console = "models/cap/props/cap_wraith_console_01.mdl",
        cocoon = "models/cap/props/cap_cocoon_01.mdl",

        -- Weapons
        stunner = "models/cap/weapons/cap_stunner_01.mdl",

        -- Ships and vehicles
        dart = "models/cap/vehicles/cap_dart_01.mdl",
        hive = "models/cap/vehicles/cap_hive_01.mdl",

        -- Engines and propulsion
        engine = "models/cap/props/cap_wraith_engine_01.mdl"
    }
}

-- CAP Material Database (Complete from Steam Workshop Collection)
ASC.CAP.Assets.Materials = {
    -- Ancient Materials
    Ancient = {
        -- Core materials
        console = "models/cap/ancient/console",
        crystal = "models/cap/ancient/crystal",
        zpm = "models/cap/ancient/zpm",
        metal = "models/cap/ancient/metal",
        energy = "models/cap/ancient/energy",

        -- Additional materials
        chair = "models/cap/ancient/chair",
        platform = "models/cap/ancient/platform",
        drone = "models/cap/ancient/drone",
        shield = "models/cap/ancient/shield",
        ring = "models/cap/ancient/ring",

        -- Atlantis specific
        atlantis_metal = "models/cap/atlantis/metal",
        atlantis_crystal = "models/cap/atlantis/crystal",
        atlantis_console = "models/cap/atlantis/console",
        city_shield = "models/cap/atlantis/city_shield"
    },

    -- Goa'uld Materials
    Goauld = {
        -- Core materials
        console = "models/cap/goauld/console",
        gold = "models/cap/goauld/gold",
        metal = "models/cap/goauld/metal",
        crystal = "models/cap/goauld/crystal",

        -- Additional materials
        sarcophagus = "models/cap/goauld/sarcophagus",
        throne = "models/cap/goauld/throne",
        staff = "models/cap/goauld/staff",
        ribbon_device = "models/cap/goauld/ribbon_device",
        death_glider = "models/cap/goauld/death_glider",
        mothership = "models/cap/goauld/mothership",

        -- Weapon materials
        staff_weapon = "models/cap/goauld/staff_weapon",
        zat = "models/cap/goauld/zat",
        hand_device = "models/cap/goauld/hand_device"
    },

    -- Asgard Materials
    Asgard = {
        -- Core materials
        console = "models/cap/asgard/console",
        metal = "models/cap/asgard/metal",
        crystal = "models/cap/asgard/crystal",
        hologram = "models/cap/asgard/hologram",

        -- Additional materials
        beam = "models/cap/asgard/beam",
        shield = "models/cap/asgard/shield",
        ship = "models/cap/asgard/ship",
        core = "models/cap/asgard/core",

        -- Technology materials
        transport = "models/cap/asgard/transport",
        computer = "models/cap/asgard/computer"
    },

    -- Tau'ri (Earth) Materials
    Tauri = {
        -- Core materials
        console = "models/cap/tauri/console",
        metal = "models/cap/tauri/metal",
        computer = "models/cap/tauri/computer",
        panel = "models/cap/tauri/panel",

        -- Military materials
        f302 = "models/cap/tauri/f302",
        prometheus = "models/cap/tauri/prometheus",
        daedalus = "models/cap/tauri/daedalus",

        -- Weapon materials
        railgun = "models/cap/tauri/railgun",
        missile = "models/cap/tauri/missile",
        plasma = "models/cap/tauri/plasma",

        -- Base materials
        sgc = "models/cap/tauri/sgc",
        hangar = "models/cap/tauri/hangar",
        catwalk = "models/cap/tauri/catwalk"
    },

    -- Ori Materials
    Ori = {
        -- Core materials
        console = "models/cap/ori/console",
        altar = "models/cap/ori/altar",
        metal = "models/cap/ori/metal",
        crystal = "models/cap/ori/crystal",

        -- Additional materials
        staff = "models/cap/ori/staff",
        beam = "models/cap/ori/beam",
        ship = "models/cap/ori/ship",
        supergate = "models/cap/ori/supergate"
    },

    -- Wraith Materials
    Wraith = {
        -- Core materials
        console = "models/cap/wraith/console",
        cocoon = "models/cap/wraith/cocoon",
        metal = "models/cap/wraith/metal",
        organic = "models/cap/wraith/organic",

        -- Additional materials
        stunner = "models/cap/wraith/stunner",
        dart = "models/cap/wraith/dart",
        hive = "models/cap/wraith/hive",
        culling_beam = "models/cap/wraith/culling_beam"
    },

    -- Universal CAP Materials
    Universal = {
        -- Event horizons
        event_horizon_sg1 = "models/cap/eventhorizon/sg1",
        event_horizon_atlantis = "models/cap/eventhorizon/atlantis",
        event_horizon_universe = "models/cap/eventhorizon/universe",
        event_horizon_movie = "models/cap/eventhorizon/movie",

        -- Shield effects
        shield_bubble = "models/cap/shields/bubble",
        shield_iris = "models/cap/shields/iris",
        shield_energy = "models/cap/shields/energy",

        -- Energy effects
        energy_beam = "models/cap/effects/energy_beam",
        energy_burst = "models/cap/effects/energy_burst",
        energy_field = "models/cap/effects/energy_field",

        -- Ramp materials
        ramp_metal = "models/cap/ramps/metal",
        ramp_ancient = "models/cap/ramps/ancient",
        ramp_goauld = "models/cap/ramps/goauld"
    }
}

-- CAP Sound Database (Complete from CAP: Sounds pack)
ASC.CAP.Assets.Sounds = {
    -- Ancient Sounds
    Ancient = {
        -- Core sounds
        activation = "cap/ancient/activation.wav",
        hum = "cap/ancient/hum.wav",
        power_up = "cap/ancient/power_up.wav",
        power_down = "cap/ancient/power_down.wav",

        -- Weapon sounds
        drone_fire = "cap/ancient/drone_fire.wav",
        drone_launch = "cap/ancient/drone_launch.wav",
        satellite_fire = "cap/ancient/satellite_fire.wav",

        -- Technology sounds
        chair_activate = "cap/ancient/chair_activate.wav",
        chair_deactivate = "cap/ancient/chair_deactivate.wav",
        zpm_activate = "cap/ancient/zpm_activate.wav",
        zpm_deactivate = "cap/ancient/zpm_deactivate.wav",

        -- Transport sounds
        ring_transport = "cap/ancient/ring_transport.wav",
        ring_activate = "cap/ancient/ring_activate.wav",

        -- Shield sounds
        shield_activate = "cap/ancient/shield_activate.wav",
        shield_deactivate = "cap/ancient/shield_deactivate.wav",
        shield_impact = "cap/ancient/shield_impact.wav",

        -- Atlantis specific
        atlantis_hum = "cap/atlantis/hum.wav",
        atlantis_shield = "cap/atlantis/shield.wav",
        city_shield_activate = "cap/atlantis/city_shield_activate.wav"
    },

    -- Goa'uld Sounds
    Goauld = {
        -- Core sounds
        activation = "cap/goauld/activation.wav",
        hum = "cap/goauld/hum.wav",
        power_up = "cap/goauld/power_up.wav",
        power_down = "cap/goauld/power_down.wav",

        -- Weapon sounds
        staff_fire = "cap/goauld/staff_fire.wav",
        staff_charge = "cap/goauld/staff_charge.wav",
        zat_fire = "cap/goauld/zat_fire.wav",
        ribbon_device = "cap/goauld/ribbon_device.wav",

        -- Technology sounds
        sarcophagus_open = "cap/goauld/sarcophagus_open.wav",
        sarcophagus_close = "cap/goauld/sarcophagus_close.wav",
        sarcophagus_activate = "cap/goauld/sarcophagus_activate.wav",

        -- Transport sounds
        ring_transport = "cap/goauld/ring_transport.wav",
        ring_activate = "cap/goauld/ring_activate.wav",

        -- Ship sounds
        death_glider_engine = "cap/goauld/death_glider_engine.wav",
        mothership_engine = "cap/goauld/mothership_engine.wav",

        -- Shield sounds
        shield_activate = "cap/goauld/shield_activate.wav",
        shield_impact = "cap/goauld/shield_impact.wav"
    },

    -- Asgard Sounds
    Asgard = {
        -- Core sounds
        activation = "cap/asgard/activation.wav",
        hum = "cap/asgard/hum.wav",
        computer = "cap/asgard/computer.wav",

        -- Weapon sounds
        beam_fire = "cap/asgard/beam_fire.wav",
        beam_charge = "cap/asgard/beam_charge.wav",

        -- Technology sounds
        transport_activate = "cap/asgard/transport_activate.wav",
        transport_beam = "cap/asgard/transport_beam.wav",
        hologram_activate = "cap/asgard/hologram_activate.wav",
        hologram_deactivate = "cap/asgard/hologram_deactivate.wav",

        -- Ship sounds
        ship_engine = "cap/asgard/ship_engine.wav",
        hyperdrive_activate = "cap/asgard/hyperdrive_activate.wav",

        -- Shield sounds
        shield_activate = "cap/asgard/shield_activate.wav",
        shield_impact = "cap/asgard/shield_impact.wav"
    },

    -- Tau'ri (Earth) Sounds
    Tauri = {
        -- Core sounds
        computer_startup = "cap/tauri/computer_startup.wav",
        computer_beep = "cap/tauri/computer_beep.wav",
        computer_error = "cap/tauri/computer_error.wav",
        computer_confirm = "cap/tauri/computer_confirm.wav",

        -- Weapon sounds
        railgun_fire = "cap/tauri/railgun_fire.wav",
        railgun_charge = "cap/tauri/railgun_charge.wav",
        missile_launch = "cap/tauri/missile_launch.wav",
        plasma_fire = "cap/tauri/plasma_fire.wav",

        -- Technology sounds
        hyperdrive_activate = "cap/tauri/hyperdrive_activate.wav",
        hyperdrive_deactivate = "cap/tauri/hyperdrive_deactivate.wav",

        -- Ship sounds
        f302_engine = "cap/tauri/f302_engine.wav",
        prometheus_engine = "cap/tauri/prometheus_engine.wav",
        daedalus_engine = "cap/tauri/daedalus_engine.wav",

        -- Base sounds
        sgc_alarm = "cap/tauri/sgc_alarm.wav",
        hangar_door = "cap/tauri/hangar_door.wav",

        -- Shield sounds
        shield_activate = "cap/tauri/shield_activate.wav",
        shield_impact = "cap/tauri/shield_impact.wav"
    },

    -- Ori Sounds
    Ori = {
        -- Core sounds
        activation = "cap/ori/activation.wav",
        hum = "cap/ori/hum.wav",
        power_up = "cap/ori/power_up.wav",

        -- Weapon sounds
        staff_fire = "cap/ori/staff_fire.wav",
        beam_fire = "cap/ori/beam_fire.wav",

        -- Technology sounds
        supergate_activate = "cap/ori/supergate_activate.wav",

        -- Ship sounds
        ship_engine = "cap/ori/ship_engine.wav",

        -- Shield sounds
        shield_activate = "cap/ori/shield_activate.wav",
        shield_impact = "cap/ori/shield_impact.wav"
    },

    -- Wraith Sounds
    Wraith = {
        -- Core sounds
        activation = "cap/wraith/activation.wav",
        hum = "cap/wraith/hum.wav",
        organic_sound = "cap/wraith/organic_sound.wav",

        -- Weapon sounds
        stunner_fire = "cap/wraith/stunner_fire.wav",
        culling_beam = "cap/wraith/culling_beam.wav",

        -- Technology sounds
        cocoon_activate = "cap/wraith/cocoon_activate.wav",

        -- Ship sounds
        dart_engine = "cap/wraith/dart_engine.wav",
        hive_engine = "cap/wraith/hive_engine.wav",

        -- Shield sounds
        shield_activate = "cap/wraith/shield_activate.wav",
        shield_impact = "cap/wraith/shield_impact.wav"
    },

    -- Universal CAP Sounds
    Universal = {
        -- Stargate sounds
        gate_activate = "cap/stargate/gate_activate.wav",
        gate_deactivate = "cap/stargate/gate_deactivate.wav",
        gate_travel = "cap/stargate/gate_travel.wav",
        gate_close = "cap/stargate/gate_close.wav",

        -- DHD sounds
        dhd_button = "cap/dhd/button_press.wav",
        dhd_dial = "cap/dhd/dial.wav",
        dhd_activate = "cap/dhd/activate.wav",

        -- Event horizon sounds
        event_horizon_form = "cap/eventhorizon/form.wav",
        event_horizon_travel = "cap/eventhorizon/travel.wav",
        event_horizon_collapse = "cap/eventhorizon/collapse.wav",

        -- General technology sounds
        energy_buildup = "cap/general/energy_buildup.wav",
        energy_discharge = "cap/general/energy_discharge.wav",
        technology_hum = "cap/general/technology_hum.wav",

        -- Alert sounds
        red_alert = "cap/alerts/red_alert.wav",
        yellow_alert = "cap/alerts/yellow_alert.wav",
        incoming_wormhole = "cap/alerts/incoming_wormhole.wav"
    }
}

-- CAP Effects and Particles Database
ASC.CAP.Assets.Effects = {
    -- Ancient Effects
    Ancient = {
        -- Energy effects
        energy_beam = "cap_ancient_energy_beam",
        energy_burst = "cap_ancient_energy_burst",
        energy_field = "cap_ancient_energy_field",

        -- Weapon effects
        drone_trail = "cap_ancient_drone_trail",
        drone_explosion = "cap_ancient_drone_explosion",
        satellite_beam = "cap_ancient_satellite_beam",

        -- Technology effects
        zpm_glow = "cap_ancient_zpm_glow",
        chair_activation = "cap_ancient_chair_activation",
        ring_transport = "cap_ancient_ring_transport",

        -- Shield effects
        shield_bubble = "cap_ancient_shield_bubble",
        shield_impact = "cap_ancient_shield_impact",
        shield_flicker = "cap_ancient_shield_flicker",

        -- Atlantis effects
        city_shield = "cap_atlantis_city_shield",
        atlantis_energy = "cap_atlantis_energy"
    },

    -- Goa'uld Effects
    Goauld = {
        -- Energy effects
        energy_beam = "cap_goauld_energy_beam",
        energy_burst = "cap_goauld_energy_burst",

        -- Weapon effects
        staff_blast = "cap_goauld_staff_blast",
        staff_impact = "cap_goauld_staff_impact",
        zat_blast = "cap_goauld_zat_blast",
        ribbon_device_effect = "cap_goauld_ribbon_device",

        -- Technology effects
        sarcophagus_glow = "cap_goauld_sarcophagus_glow",
        ring_transport = "cap_goauld_ring_transport",

        -- Ship effects
        death_glider_engine = "cap_goauld_death_glider_engine",
        mothership_engine = "cap_goauld_mothership_engine",

        -- Shield effects
        shield_bubble = "cap_goauld_shield_bubble",
        shield_impact = "cap_goauld_shield_impact"
    },

    -- Asgard Effects
    Asgard = {
        -- Energy effects
        energy_beam = "cap_asgard_energy_beam",
        energy_field = "cap_asgard_energy_field",

        -- Weapon effects
        beam_weapon = "cap_asgard_beam_weapon",
        beam_impact = "cap_asgard_beam_impact",

        -- Technology effects
        transport_beam = "cap_asgard_transport_beam",
        hologram_effect = "cap_asgard_hologram",

        -- Ship effects
        ship_engine = "cap_asgard_ship_engine",
        hyperdrive_effect = "cap_asgard_hyperdrive",

        -- Shield effects
        shield_bubble = "cap_asgard_shield_bubble",
        shield_impact = "cap_asgard_shield_impact"
    },

    -- Tau'ri Effects
    Tauri = {
        -- Energy effects
        energy_beam = "cap_tauri_energy_beam",
        plasma_field = "cap_tauri_plasma_field",

        -- Weapon effects
        railgun_trail = "cap_tauri_railgun_trail",
        railgun_impact = "cap_tauri_railgun_impact",
        missile_trail = "cap_tauri_missile_trail",
        missile_explosion = "cap_tauri_missile_explosion",
        plasma_blast = "cap_tauri_plasma_blast",

        -- Technology effects
        hyperdrive_effect = "cap_tauri_hyperdrive",

        -- Ship effects
        f302_engine = "cap_tauri_f302_engine",
        prometheus_engine = "cap_tauri_prometheus_engine",
        daedalus_engine = "cap_tauri_daedalus_engine",

        -- Shield effects
        shield_bubble = "cap_tauri_shield_bubble",
        shield_impact = "cap_tauri_shield_impact"
    },

    -- Ori Effects
    Ori = {
        -- Energy effects
        energy_beam = "cap_ori_energy_beam",
        energy_burst = "cap_ori_energy_burst",

        -- Weapon effects
        staff_blast = "cap_ori_staff_blast",
        beam_weapon = "cap_ori_beam_weapon",

        -- Technology effects
        supergate_effect = "cap_ori_supergate",

        -- Ship effects
        ship_engine = "cap_ori_ship_engine",

        -- Shield effects
        shield_bubble = "cap_ori_shield_bubble",
        shield_impact = "cap_ori_shield_impact"
    },

    -- Wraith Effects
    Wraith = {
        -- Energy effects
        energy_beam = "cap_wraith_energy_beam",
        organic_glow = "cap_wraith_organic_glow",

        -- Weapon effects
        stunner_blast = "cap_wraith_stunner_blast",
        culling_beam = "cap_wraith_culling_beam",

        -- Technology effects
        cocoon_effect = "cap_wraith_cocoon",

        -- Ship effects
        dart_engine = "cap_wraith_dart_engine",
        hive_engine = "cap_wraith_hive_engine",

        -- Shield effects
        shield_bubble = "cap_wraith_shield_bubble",
        shield_impact = "cap_wraith_shield_impact"
    },

    -- Universal Effects
    Universal = {
        -- Stargate effects
        event_horizon = "cap_event_horizon",
        gate_activation = "cap_gate_activation",
        gate_travel = "cap_gate_travel",
        gate_shutdown = "cap_gate_shutdown",

        -- Energy effects
        energy_discharge = "cap_energy_discharge",
        energy_buildup = "cap_energy_buildup",
        energy_field = "cap_energy_field",

        -- Explosion effects
        small_explosion = "cap_small_explosion",
        medium_explosion = "cap_medium_explosion",
        large_explosion = "cap_large_explosion",

        -- Environmental effects
        sparks = "cap_sparks",
        smoke = "cap_smoke",
        fire = "cap_fire"
    }
}

-- Asset Detection and Validation Functions
function ASC.CAP.Assets.DetectCAP()
    local detection = {
        available = false,
        models = 0,
        materials = 0,
        sounds = 0,
        version = "Unknown"
    }
    
    -- Check for CAP availability
    if HYPERDRIVE and HYPERDRIVE.CAP and HYPERDRIVE.CAP.Available then
        detection.available = true
        detection.version = HYPERDRIVE.CAP.Detection and HYPERDRIVE.CAP.Detection.version or "Detected"
    end
    
    -- Validate CAP models
    for category, models in pairs(ASC.CAP.Assets.Models) do
        for name, modelPath in pairs(models) do
            if file.Exists(modelPath, "GAME") then
                detection.models = detection.models + 1
            end
        end
    end
    
    -- Validate CAP materials
    for category, materials in pairs(ASC.CAP.Assets.Materials) do
        for name, materialPath in pairs(materials) do
            local fullPath = "materials/" .. materialPath .. ".vmt"
            if file.Exists(fullPath, "GAME") then
                detection.materials = detection.materials + 1
            end
        end
    end
    
    -- Validate CAP sounds
    for category, sounds in pairs(ASC.CAP.Assets.Sounds) do
        for name, soundPath in pairs(sounds) do
            local fullPath = "sound/" .. soundPath
            if file.Exists(fullPath, "GAME") then
                detection.sounds = detection.sounds + 1
            end
        end
    end
    
    ASC.CAP.Assets.Registry.CAPAvailable = detection.available
    
    print("[ASC CAP Assets] Detection complete:")
    print("  - CAP Available: " .. tostring(detection.available))
    print("  - Models Found: " .. detection.models)
    print("  - Materials Found: " .. detection.materials)
    print("  - Sounds Found: " .. detection.sounds)
    print("  - Version: " .. detection.version)
    
    return detection
end

-- Asset Loading Functions
function ASC.CAP.Assets.GetModel(technology, modelType, fallback)
    if not ASC.CAP.Assets.Config.EnableCAPAssets then
        return fallback
    end
    
    local models = ASC.CAP.Assets.Models[technology]
    if not models or not models[modelType] then
        return fallback
    end
    
    local modelPath = models[modelType]
    
    -- Validate model if enabled
    if ASC.CAP.Assets.Config.ValidateBeforeUse then
        if not file.Exists(modelPath, "GAME") then
            if ASC.CAP.Assets.Config.EnableAssetLogging then
                print("[ASC CAP Assets] Model not found: " .. modelPath .. ", using fallback")
            end
            return fallback
        end
    end
    
    if ASC.CAP.Assets.Config.EnableAssetLogging then
        print("[ASC CAP Assets] Using CAP model: " .. modelPath)
    end
    
    return modelPath
end

function ASC.CAP.Assets.GetMaterial(technology, materialType, fallback)
    if not ASC.CAP.Assets.Config.EnableCAPAssets then
        return fallback
    end
    
    local materials = ASC.CAP.Assets.Materials[technology]
    if not materials or not materials[materialType] then
        return fallback
    end
    
    local materialPath = materials[materialType]
    
    -- Validate material if enabled
    if ASC.CAP.Assets.Config.ValidateBeforeUse then
        local fullPath = "materials/" .. materialPath .. ".vmt"
        if not file.Exists(fullPath, "GAME") then
            if ASC.CAP.Assets.Config.EnableAssetLogging then
                print("[ASC CAP Assets] Material not found: " .. fullPath .. ", using fallback")
            end
            return fallback
        end
    end
    
    if ASC.CAP.Assets.Config.EnableAssetLogging then
        print("[ASC CAP Assets] Using CAP material: " .. materialPath)
    end
    
    return materialPath
end

function ASC.CAP.Assets.GetSound(technology, soundType, fallback)
    if not ASC.CAP.Assets.Config.EnableCAPAssets then
        return fallback
    end
    
    local sounds = ASC.CAP.Assets.Sounds[technology]
    if not sounds or not sounds[soundType] then
        return fallback
    end
    
    local soundPath = sounds[soundType]
    
    -- Validate sound if enabled
    if ASC.CAP.Assets.Config.ValidateBeforeUse then
        local fullPath = "sound/" .. soundPath
        if not file.Exists(fullPath, "GAME") then
            if ASC.CAP.Assets.Config.EnableAssetLogging then
                print("[ASC CAP Assets] Sound not found: " .. fullPath .. ", using fallback")
            end
            return fallback
        end
    end
    
    if ASC.CAP.Assets.Config.EnableAssetLogging then
        print("[ASC CAP Assets] Using CAP sound: " .. soundPath)
    end
    
    return soundPath
end

-- Entity-specific CAP model mappings
ASC.CAP.Assets.EntityMappings = {
    -- Ship Core mappings
    ship_core = {
        Ancient = {model = "Ancient", type = "console", fallback = "models/hunter/blocks/cube025x025x025.mdl"},
        Goauld = {model = "Goauld", type = "console", fallback = "models/props_combine/combine_core.mdl"},
        Asgard = {model = "Asgard", type = "console", fallback = "models/props_lab/monitor01a.mdl"},
        Tauri = {model = "Tauri", type = "console", fallback = "models/props_lab/servers.mdl"},
        Ori = {model = "Ori", type = "console", fallback = "models/props_combine/combine_core.mdl"},
        Wraith = {model = "Wraith", type = "console", fallback = "models/props_combine/combine_core.mdl"}
    },

    -- Hyperdrive Engine mappings
    hyperdrive_engine = {
        Ancient = {model = "Ancient", type = "hyperdrive", fallback = "models/props_combine/combine_generator01.mdl"},
        Goauld = {model = "Goauld", type = "hyperdrive", fallback = "models/props_combine/combine_generator01.mdl"},
        Asgard = {model = "Asgard", type = "hyperdrive", fallback = "models/props_combine/combine_generator01.mdl"},
        Tauri = {model = "Tauri", type = "hyperdrive", fallback = "models/props_combine/combine_generator01.mdl"},
        Ori = {model = "Ori", type = "engine", fallback = "models/props_combine/combine_generator01.mdl"},
        Wraith = {model = "Wraith", type = "engine", fallback = "models/props_combine/combine_generator01.mdl"}
    },

    -- Master Hyperdrive Engine mappings
    hyperdrive_master_engine = {
        Ancient = {model = "Ancient", type = "engine", fallback = "models/props_combine/combine_generator01.mdl"},
        Goauld = {model = "Goauld", type = "engine", fallback = "models/props_combine/combine_generator01.mdl"},
        Asgard = {model = "Asgard", type = "engine", fallback = "models/props_combine/combine_generator01.mdl"},
        Tauri = {model = "Tauri", type = "engine", fallback = "models/props_combine/combine_generator01.mdl"},
        Ori = {model = "Ori", type = "engine", fallback = "models/props_combine/combine_generator01.mdl"},
        Wraith = {model = "Wraith", type = "engine", fallback = "models/props_combine/combine_generator01.mdl"}
    },

    -- Shield Generator mappings
    asc_shield_generator = {
        Ancient = {model = "Ancient", type = "shield_generator", fallback = "models/props_combine/combine_mine01.mdl"},
        Goauld = {model = "Goauld", type = "console", fallback = "models/props_combine/combine_mine01.mdl"},
        Asgard = {model = "Asgard", type = "shield", fallback = "models/props_combine/combine_mine01.mdl"},
        Tauri = {model = "Tauri", type = "console", fallback = "models/props_combine/combine_mine01.mdl"},
        Ori = {model = "Ori", type = "console", fallback = "models/props_combine/combine_mine01.mdl"},
        Wraith = {model = "Wraith", type = "console", fallback = "models/props_combine/combine_mine01.mdl"}
    },

    -- Weapon mappings
    asc_pulse_cannon = {
        Ancient = {model = "Ancient", type = "drone_weapon", fallback = "models/props_c17/oildrum001_explosive.mdl"},
        Goauld = {model = "Goauld", type = "staff_cannon", fallback = "models/props_c17/oildrum001_explosive.mdl"},
        Asgard = {model = "Asgard", type = "beam", fallback = "models/props_c17/oildrum001_explosive.mdl"},
        Tauri = {model = "Tauri", type = "plasma_cannon", fallback = "models/props_c17/oildrum001_explosive.mdl"},
        Ori = {model = "Ori", type = "beam", fallback = "models/props_c17/oildrum001_explosive.mdl"},
        Wraith = {model = "Wraith", type = "stunner", fallback = "models/props_c17/oildrum001_explosive.mdl"}
    },

    asc_railgun = {
        Ancient = {model = "Ancient", type = "drone_weapon", fallback = "models/props_combine/combine_barricade_short01a.mdl"},
        Goauld = {model = "Goauld", type = "staff_cannon", fallback = "models/props_combine/combine_barricade_short01a.mdl"},
        Asgard = {model = "Asgard", type = "beam", fallback = "models/props_combine/combine_barricade_short01a.mdl"},
        Tauri = {model = "Tauri", type = "railgun", fallback = "models/props_combine/combine_barricade_short01a.mdl"},
        Ori = {model = "Ori", type = "beam", fallback = "models/props_combine/combine_barricade_short01a.mdl"},
        Wraith = {model = "Wraith", type = "stunner", fallback = "models/props_combine/combine_barricade_short01a.mdl"}
    },

    asc_plasma_cannon = {
        Ancient = {model = "Ancient", type = "drone_weapon", fallback = "models/props_combine/combine_mine01.mdl"},
        Goauld = {model = "Goauld", type = "staff_cannon", fallback = "models/props_combine/combine_mine01.mdl"},
        Asgard = {model = "Asgard", type = "beam", fallback = "models/props_combine/combine_mine01.mdl"},
        Tauri = {model = "Tauri", type = "plasma_cannon", fallback = "models/props_combine/combine_mine01.mdl"},
        Ori = {model = "Ori", type = "beam", fallback = "models/props_combine/combine_mine01.mdl"},
        Wraith = {model = "Wraith", type = "stunner", fallback = "models/props_combine/combine_mine01.mdl"}
    }
}

-- Get CAP model for specific entity and technology
function ASC.CAP.Assets.GetEntityModel(entityClass, technology, fallback)
    if not ASC.CAP.Assets.Config.EnableCAPAssets then
        return fallback
    end

    local mapping = ASC.CAP.Assets.EntityMappings[entityClass]
    if not mapping or not mapping[technology] then
        return fallback
    end

    local modelInfo = mapping[technology]
    return ASC.CAP.Assets.GetModel(modelInfo.model, modelInfo.type, modelInfo.fallback or fallback)
end

-- Get all available technologies for an entity
function ASC.CAP.Assets.GetEntityTechnologies(entityClass)
    local mapping = ASC.CAP.Assets.EntityMappings[entityClass]
    if not mapping then return {} end

    local technologies = {}
    for tech, _ in pairs(mapping) do
        table.insert(technologies, tech)
    end

    return technologies
end

-- Technology color schemes
ASC.CAP.Assets.TechnologyColors = {
    Ancient = Color(100, 200, 255),    -- Blue
    Goauld = Color(255, 200, 100),     -- Gold
    Asgard = Color(200, 200, 255),     -- Light Blue
    Tauri = Color(150, 150, 150),      -- Gray
    Ori = Color(255, 255, 200),        -- Light Yellow
    Wraith = Color(150, 255, 150),     -- Green
    Standard = Color(255, 255, 255)    -- White
}

-- Get technology color
function ASC.CAP.Assets.GetTechnologyColor(technology)
    return ASC.CAP.Assets.TechnologyColors[technology] or ASC.CAP.Assets.TechnologyColors.Standard
end

-- Get CAP effect for specific technology and type
function ASC.CAP.Assets.GetEffect(technology, effectType, fallback)
    if not ASC.CAP.Assets.Config.EnableCAPAssets then
        return fallback
    end

    local effects = ASC.CAP.Assets.Effects[technology]
    if not effects or not effects[effectType] then
        return fallback
    end

    local effectName = effects[effectType]

    if ASC.CAP.Assets.Config.EnableAssetLogging then
        print("[ASC CAP Assets] Using CAP effect: " .. effectName)
    end

    return effectName
end

-- Play CAP sound with technology-specific fallback
function ASC.CAP.Assets.PlaySound(entity, technology, soundType, fallbackSound, volume, pitch)
    if not IsValid(entity) then return false end

    local sound = ASC.CAP.Assets.GetSound(technology, soundType, fallbackSound)

    if sound and sound ~= "" then
        entity:EmitSound(sound, volume or 75, pitch or 100)
        return true
    end

    return false
end

-- Create CAP effect with technology-specific fallback
function ASC.CAP.Assets.CreateEffect(entity, technology, effectType, fallbackEffect)
    if not IsValid(entity) then return false end

    local effect = ASC.CAP.Assets.GetEffect(technology, effectType, fallbackEffect)

    if effect and effect ~= "" then
        local effectData = EffectData()
        effectData:SetOrigin(entity:GetPos())
        effectData:SetEntity(entity)
        util.Effect(effect, effectData)
        return true
    end

    return false
end

-- Get technology-specific ambient sound for entities
function ASC.CAP.Assets.GetAmbientSound(technology, fallback)
    local sounds = {
        Ancient = ASC.CAP.Assets.GetSound("Ancient", "hum", fallback),
        Goauld = ASC.CAP.Assets.GetSound("Goauld", "hum", fallback),
        Asgard = ASC.CAP.Assets.GetSound("Asgard", "hum", fallback),
        Tauri = ASC.CAP.Assets.GetSound("Tauri", "computer_startup", fallback),
        Ori = ASC.CAP.Assets.GetSound("Ori", "hum", fallback),
        Wraith = ASC.CAP.Assets.GetSound("Wraith", "organic_sound", fallback)
    }

    return sounds[technology] or fallback
end

-- Get technology-specific activation sound
function ASC.CAP.Assets.GetActivationSound(technology, fallback)
    local sounds = {
        Ancient = ASC.CAP.Assets.GetSound("Ancient", "activation", fallback),
        Goauld = ASC.CAP.Assets.GetSound("Goauld", "activation", fallback),
        Asgard = ASC.CAP.Assets.GetSound("Asgard", "activation", fallback),
        Tauri = ASC.CAP.Assets.GetSound("Tauri", "computer_startup", fallback),
        Ori = ASC.CAP.Assets.GetSound("Ori", "activation", fallback),
        Wraith = ASC.CAP.Assets.GetSound("Wraith", "activation", fallback)
    }

    return sounds[technology] or fallback
end

-- Get technology-specific shield sound
function ASC.CAP.Assets.GetShieldSound(technology, soundType, fallback)
    local sounds = {
        Ancient = ASC.CAP.Assets.GetSound("Ancient", "shield_" .. soundType, fallback),
        Goauld = ASC.CAP.Assets.GetSound("Goauld", "shield_" .. soundType, fallback),
        Asgard = ASC.CAP.Assets.GetSound("Asgard", "shield_" .. soundType, fallback),
        Tauri = ASC.CAP.Assets.GetSound("Tauri", "shield_" .. soundType, fallback),
        Ori = ASC.CAP.Assets.GetSound("Ori", "shield_" .. soundType, fallback),
        Wraith = ASC.CAP.Assets.GetSound("Wraith", "shield_" .. soundType, fallback)
    }

    return sounds[technology] or fallback
end

-- Console commands for CAP technology management
if SERVER then
    concommand.Add("asc_set_technology", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end

        local entityClass = args[1]
        local technology = args[2]

        if not entityClass or not technology then
            print("Usage: asc_set_technology <entity_class> <technology>")
            print("Entity classes: ship_core, hyperdrive_engine, hyperdrive_master_engine, asc_shield_generator, asc_pulse_cannon, asc_railgun, asc_plasma_cannon")
            print("Technologies: Ancient, Goauld, Asgard, Tauri, Ori, Wraith")
            return
        end

        local entities = ents.FindByClass(entityClass)
        local updated = 0

        for _, ent in ipairs(entities) do
            if IsValid(ent) and ent.SetTechnology then
                if ent:SetTechnology(technology) then
                    updated = updated + 1
                end
            end
        end

        print("Updated " .. updated .. " " .. entityClass .. " entities to " .. technology .. " technology")
    end)

    concommand.Add("asc_technology_status", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end

        print("=== Advanced Space Combat - Technology Status ===")

        local entityClasses = {"ship_core", "hyperdrive_engine", "hyperdrive_master_engine", "asc_shield_generator", "asc_pulse_cannon", "asc_railgun", "asc_plasma_cannon"}

        for _, entityClass in ipairs(entityClasses) do
            local entities = ents.FindByClass(entityClass)
            if #entities > 0 then
                print("\n" .. entityClass .. " (" .. #entities .. " entities):")

                local techCounts = {}
                for _, ent in ipairs(entities) do
                    if IsValid(ent) and ent.GetTechnology then
                        local tech = ent:GetTechnology()
                        techCounts[tech] = (techCounts[tech] or 0) + 1
                    end
                end

                for tech, count in pairs(techCounts) do
                    print("  " .. tech .. ": " .. count)
                end
            end
        end

        print("===============================================")
    end)

    concommand.Add("asc_randomize_technology", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end

        local entityClass = args[1]
        if not entityClass then
            print("Usage: asc_randomize_technology <entity_class>")
            print("Entity classes: ship_core, hyperdrive_engine, hyperdrive_master_engine, asc_shield_generator, asc_pulse_cannon, asc_railgun, asc_plasma_cannon")
            print("Use 'all' to randomize all entity types")
            return
        end

        local technologies = {"Ancient", "Goauld", "Asgard", "Tauri", "Ori", "Wraith"}
        local entityClasses = {}

        if entityClass == "all" then
            entityClasses = {"ship_core", "hyperdrive_engine", "hyperdrive_master_engine", "asc_shield_generator", "asc_pulse_cannon", "asc_railgun", "asc_plasma_cannon"}
        else
            entityClasses = {entityClass}
        end

        local totalUpdated = 0

        for _, class in ipairs(entityClasses) do
            local entities = ents.FindByClass(class)
            local updated = 0

            for _, ent in ipairs(entities) do
                if IsValid(ent) and ent.SetTechnology then
                    local randomTech = technologies[math.random(1, #technologies)]
                    if ent:SetTechnology(randomTech) then
                        updated = updated + 1
                        print("[" .. class .. "] Entity " .. ent:EntIndex() .. " randomized to: " .. randomTech)
                    end
                end
            end

            if updated > 0 then
                print("Randomized " .. updated .. " " .. class .. " entities")
                totalUpdated = totalUpdated + updated
            end
        end

        print("Total entities randomized: " .. totalUpdated)
    end)
end

-- Initialize CAP Asset System
timer.Simple(1, function()
    ASC.CAP.Assets.DetectCAP()
    print("[Advanced Space Combat] CAP Asset Integration System v1.0.0 - Ready!")
    print("[ASC CAP Assets] Entity mappings loaded for " .. table.Count(ASC.CAP.Assets.EntityMappings) .. " entity types")
    print("[ASC CAP Assets] Use 'asc_technology_status' to view current technology assignments")
    print("[ASC CAP Assets] Use 'asc_set_technology <entity> <tech>' to change technologies")
end)
