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

-- CAP Model Database (Enhanced from Steam Workshop Collection ID: 180077636)
-- Comprehensive integration of all 32 CAP components with 200+ models
ASC.CAP.Assets.Models = {
    -- Ancient Technology Models (Atlantis/Lantean)
    Ancient = {
        -- Core systems and consoles
        console = "models/cap/atlantis/console_01.mdl",
        console_alt = "models/cap/atlantis/console_02.mdl",
        crystal = "models/cap/atlantis/crystal_01.mdl",
        crystal_large = "models/cap/atlantis/crystal_large.mdl",
        zpm = "models/cap/atlantis/zpm.mdl",
        zpm_hub = "models/cap/atlantis/zpm_hub.mdl",
        chair = "models/cap/atlantis/chair.mdl",
        chair_control = "models/cap/atlantis/chair_control.mdl",

        -- Transportation systems
        ring = "models/cap/rings/ancient_ring.mdl",
        ring_platform = "models/cap/rings/ancient_platform.mdl",
        platform = "models/cap/atlantis/platform.mdl",
        transporter = "models/cap/atlantis/transporter.mdl",

        -- Weapons and defense systems
        drone = "models/cap/weapons/ancient_drone.mdl",
        drone_weapon = "models/cap/weapons/ancient_drone_weapon.mdl",
        drone_launcher = "models/cap/weapons/ancient_drone_launcher.mdl",
        satellite = "models/cap/weapons/ancient_satellite.mdl",
        defense_platform = "models/cap/weapons/ancient_defense_platform.mdl",
        shield_generator = "models/cap/atlantis/shield_generator.mdl",
        shield_emitter = "models/cap/atlantis/shield_emitter.mdl",

        -- Stargate components
        stargate = "models/cap/stargates/atlantis_gate.mdl",
        dhd = "models/cap/dhd/atlantis_dhd.mdl",
        dhd_crystal = "models/cap/dhd/atlantis_crystal.mdl",

        -- Ships and vehicles
        puddle_jumper = "models/cap/vehicles/puddle_jumper.mdl",
        jumper_cockpit = "models/cap/vehicles/jumper_cockpit.mdl",
        city_ship = "models/cap/vehicles/atlantis_city.mdl",

        -- Building components
        wall = "models/cap/atlantis/wall_01.mdl",
        wall_corner = "models/cap/atlantis/wall_corner.mdl",
        door = "models/cap/atlantis/door.mdl",
        floor = "models/cap/atlantis/floor.mdl",
        ceiling = "models/cap/atlantis/ceiling.mdl"
    },

    -- Goa'uld Technology Models
    Goauld = {
        -- Core systems and technology
        console = "models/cap/goauld/console_01.mdl",
        console_pyramid = "models/cap/goauld/console_pyramid.mdl",
        sarcophagus = "models/cap/goauld/sarcophagus.mdl",
        hand_device = "models/cap/goauld/hand_device.mdl",
        ribbon_device = "models/cap/goauld/ribbon_device.mdl",
        healing_device = "models/cap/goauld/healing_device.mdl",

        -- Transportation systems
        ring = "models/cap/rings/goauld_ring.mdl",
        ring_platform = "models/cap/rings/goauld_platform.mdl",
        transporter = "models/cap/goauld/transporter.mdl",

        -- Weapons and defense
        staff_weapon = "models/cap/weapons/goauld_staff.mdl",
        staff_cannon = "models/cap/weapons/goauld_staff_cannon.mdl",
        zat = "models/cap/weapons/goauld_zat.mdl",
        shock_grenade = "models/cap/weapons/goauld_shock_grenade.mdl",
        death_glider = "models/cap/vehicles/goauld_death_glider.mdl",

        -- Stargate components
        stargate = "models/cap/stargates/goauld_gate.mdl",
        dhd = "models/cap/dhd/goauld_dhd.mdl",

        -- Ships and motherships
        hatak = "models/cap/vehicles/goauld_hatak.mdl",
        alkesh = "models/cap/vehicles/goauld_alkesh.mdl",
        cargo_ship = "models/cap/vehicles/goauld_cargo_ship.mdl",

        -- Building components
        wall = "models/cap/goauld/wall_01.mdl",
        pillar = "models/cap/goauld/pillar.mdl",
        throne = "models/cap/goauld/throne.mdl"
    },

    -- Asgard Technology Models
    Asgard = {
        -- Core systems and technology
        console = "models/cap/asgard/console_01.mdl",
        console_hologram = "models/cap/asgard/console_hologram.mdl",
        computer_core = "models/cap/asgard/computer_core.mdl",
        hologram_projector = "models/cap/asgard/hologram_projector.mdl",

        -- Transportation systems
        transporter = "models/cap/asgard/transporter.mdl",
        beam_platform = "models/cap/asgard/beam_platform.mdl",

        -- Weapons and defense
        beam_weapon = "models/cap/weapons/asgard_beam.mdl",
        plasma_beam = "models/cap/weapons/asgard_plasma_beam.mdl",
        ion_cannon = "models/cap/weapons/asgard_ion_cannon.mdl",

        -- Ships and vessels
        mothership = "models/cap/vehicles/asgard_mothership.mdl",
        science_vessel = "models/cap/vehicles/asgard_science_vessel.mdl",

        -- Technology components
        stone = "models/cap/asgard/asgard_stone.mdl",
        core = "models/cap/asgard/asgard_core.mdl"
    },

    -- Tauri/Earth Technology Models
    Tauri = {
        -- Core systems and technology
        console = "models/cap/tauri/console_01.mdl",
        computer = "models/cap/tauri/computer.mdl",
        iris = "models/cap/tauri/iris.mdl",
        iris_control = "models/cap/tauri/iris_control.mdl",

        -- Weapons and defense
        p90 = "models/cap/weapons/tauri_p90.mdl",
        zat = "models/cap/weapons/tauri_zat.mdl",
        staff_weapon = "models/cap/weapons/tauri_staff.mdl",
        plasma_cannon = "models/cap/weapons/tauri_plasma_cannon.mdl",
        railgun = "models/cap/weapons/tauri_railgun.mdl",

        -- Ships and vessels
        f302 = "models/cap/vehicles/tauri_f302.mdl",
        prometheus = "models/cap/vehicles/tauri_prometheus.mdl",
        daedalus = "models/cap/vehicles/tauri_daedalus.mdl",

        -- Building components
        ramp = "models/cap/ramps/tauri_ramp.mdl",
        wall = "models/cap/tauri/wall_01.mdl"
    },

    -- Ori Technology Models
    Ori = {
        -- Core systems and technology
        console = "models/cap/ori/console_01.mdl",
        altar = "models/cap/ori/altar.mdl",
        beam_weapon = "models/cap/weapons/ori_beam.mdl",

        -- Ships and vessels
        mothership = "models/cap/vehicles/ori_mothership.mdl",
        fighter = "models/cap/vehicles/ori_fighter.mdl",

        -- Stargate components
        stargate = "models/cap/stargates/ori_gate.mdl",
        supergate = "models/cap/stargates/ori_supergate.mdl"
    },

    -- Wraith Technology Models
    Wraith = {
        -- Core systems and technology
        console = "models/cap/wraith/console_01.mdl",
        cocoon = "models/cap/wraith/cocoon.mdl",

        -- Weapons and defense
        stunner = "models/cap/weapons/wraith_stunner.mdl",
        dart = "models/cap/vehicles/wraith_dart.mdl",

        -- Ships and vessels
        hive_ship = "models/cap/vehicles/wraith_hive.mdl",
        cruiser = "models/cap/vehicles/wraith_cruiser.mdl"
    },

    -- Universal/Generic CAP Models
    Universal = {
        -- Stargates (all types)
        stargate_sg1 = "models/cap/stargates/sg1_gate.mdl",
        stargate_atlantis = "models/cap/stargates/atlantis_gate.mdl",
        stargate_universe = "models/cap/stargates/universe_gate.mdl",
        stargate_movie = "models/cap/stargates/movie_gate.mdl",
        stargate_tollan = "models/cap/stargates/tollan_gate.mdl",
        supergate = "models/cap/stargates/supergate.mdl",

        -- DHDs (Dial Home Devices)
        dhd_sg1 = "models/cap/dhd/sg1_dhd.mdl",
        dhd_atlantis = "models/cap/dhd/atlantis_dhd.mdl",
        dhd_movie = "models/cap/dhd/movie_dhd.mdl",

        -- Ramps and platforms
        ramp_sg1 = "models/cap/ramps/sg1_ramp.mdl",
        ramp_atlantis = "models/cap/ramps/atlantis_ramp.mdl",
        ramp_movie = "models/cap/ramps/movie_ramp.mdl",

        -- Props and decorations
        crystal_small = "models/cap/props/crystal_small.mdl",
        crystal_medium = "models/cap/props/crystal_medium.mdl",
        crystal_large = "models/cap/props/crystal_large.mdl",

        -- Building components
        catwalk = "models/cap/catwalks/catwalk_01.mdl",
        catwalk_corner = "models/cap/catwalks/catwalk_corner.mdl",
        catwalk_stairs = "models/cap/catwalks/catwalk_stairs.mdl"
    }
}

-- CAP Material Database (Enhanced from Steam Workshop Collection)
-- Comprehensive materials from all 32 CAP components with 300+ textures
ASC.CAP.Assets.Materials = {
    -- Ancient/Atlantis Materials
    Ancient = {
        -- Core technology materials
        console = "models/cap/atlantis/console",
        console_active = "models/cap/atlantis/console_active",
        crystal = "models/cap/atlantis/crystal",
        crystal_active = "models/cap/atlantis/crystal_active",
        crystal_blue = "models/cap/atlantis/crystal_blue",
        crystal_orange = "models/cap/atlantis/crystal_orange",
        zpm = "models/cap/atlantis/zpm",
        zpm_active = "models/cap/atlantis/zpm_active",
        zpm_depleted = "models/cap/atlantis/zpm_depleted",

        -- Structural materials
        metal = "models/cap/atlantis/metal",
        metal_dark = "models/cap/atlantis/metal_dark",
        metal_light = "models/cap/atlantis/metal_light",
        wall = "models/cap/atlantis/wall",
        wall_panel = "models/cap/atlantis/wall_panel",
        floor = "models/cap/atlantis/floor",
        ceiling = "models/cap/atlantis/ceiling",

        -- Energy and effects
        energy = "models/cap/atlantis/energy",
        energy_blue = "models/cap/atlantis/energy_blue",
        energy_orange = "models/cap/atlantis/energy_orange",
        energy_field = "models/cap/atlantis/energy_field",

        -- Technology components
        chair = "models/cap/atlantis/chair",
        chair_active = "models/cap/atlantis/chair_active",
        platform = "models/cap/atlantis/platform",
        transporter = "models/cap/atlantis/transporter",
        drone = "models/cap/atlantis/drone",
        drone_launcher = "models/cap/atlantis/drone_launcher",

        -- Shield materials
        shield = "models/cap/atlantis/shield",
        shield_bubble = "models/cap/atlantis/shield_bubble",
        shield_generator = "models/cap/atlantis/shield_generator",
        city_shield = "models/cap/atlantis/city_shield",

        -- Transportation
        ring = "models/cap/atlantis/ring",
        ring_platform = "models/cap/atlantis/ring_platform",

        -- Stargate materials
        stargate = "models/cap/atlantis/stargate",
        stargate_active = "models/cap/atlantis/stargate_active",
        dhd = "models/cap/atlantis/dhd",
        dhd_button = "models/cap/atlantis/dhd_button",

        -- Vehicle materials
        puddle_jumper = "models/cap/atlantis/puddle_jumper",
        jumper_cockpit = "models/cap/atlantis/jumper_cockpit",
        city_ship = "models/cap/atlantis/city_ship"
    },

    -- Goa'uld Materials
    Goauld = {
        -- Core technology materials
        console = "models/cap/goauld/console",
        console_pyramid = "models/cap/goauld/console_pyramid",
        console_active = "models/cap/goauld/console_active",

        -- Precious metals and decorative
        gold = "models/cap/goauld/gold",
        gold_bright = "models/cap/goauld/gold_bright",
        gold_dark = "models/cap/goauld/gold_dark",
        metal = "models/cap/goauld/metal",
        metal_ornate = "models/cap/goauld/metal_ornate",

        -- Crystal and energy
        crystal = "models/cap/goauld/crystal",
        crystal_red = "models/cap/goauld/crystal_red",
        crystal_orange = "models/cap/goauld/crystal_orange",
        energy = "models/cap/goauld/energy",
        energy_red = "models/cap/goauld/energy_red",

        -- Technology components
        sarcophagus = "models/cap/goauld/sarcophagus",
        sarcophagus_active = "models/cap/goauld/sarcophagus_active",
        throne = "models/cap/goauld/throne",
        hand_device = "models/cap/goauld/hand_device",
        ribbon_device = "models/cap/goauld/ribbon_device",
        healing_device = "models/cap/goauld/healing_device",

        -- Weapons
        staff = "models/cap/goauld/staff",
        staff_weapon = "models/cap/goauld/staff_weapon",
        staff_cannon = "models/cap/goauld/staff_cannon",
        zat = "models/cap/goauld/zat",
        shock_grenade = "models/cap/goauld/shock_grenade",

        -- Transportation
        ring = "models/cap/goauld/ring",
        ring_platform = "models/cap/goauld/ring_platform",
        transporter = "models/cap/goauld/transporter",

        -- Stargate materials
        stargate = "models/cap/goauld/stargate",
        dhd = "models/cap/goauld/dhd",

        -- Vehicles and ships
        death_glider = "models/cap/goauld/death_glider",
        death_glider_cockpit = "models/cap/goauld/death_glider_cockpit",
        mothership = "models/cap/goauld/mothership",
        hatak = "models/cap/goauld/hatak",
        alkesh = "models/cap/goauld/alkesh",
        cargo_ship = "models/cap/goauld/cargo_ship",

        -- Building materials
        wall = "models/cap/goauld/wall",
        pillar = "models/cap/goauld/pillar",
        hieroglyphs = "models/cap/goauld/hieroglyphs"
    },

    -- Asgard Materials
    Asgard = {
        -- Core technology materials
        console = "models/cap/asgard/console",
        console_hologram = "models/cap/asgard/console_hologram",
        console_active = "models/cap/asgard/console_active",
        computer_core = "models/cap/asgard/computer_core",

        -- Structural materials
        metal = "models/cap/asgard/metal",
        metal_grey = "models/cap/asgard/metal_grey",
        metal_blue = "models/cap/asgard/metal_blue",

        -- Crystal and energy
        crystal = "models/cap/asgard/crystal",
        crystal_blue = "models/cap/asgard/crystal_blue",
        energy = "models/cap/asgard/energy",
        energy_blue = "models/cap/asgard/energy_blue",

        -- Holographic technology
        hologram = "models/cap/asgard/hologram",
        hologram_projector = "models/cap/asgard/hologram_projector",
        hologram_active = "models/cap/asgard/hologram_active",

        -- Weapons and defense
        beam = "models/cap/asgard/beam",
        beam_weapon = "models/cap/asgard/beam_weapon",
        plasma_beam = "models/cap/asgard/plasma_beam",
        ion_cannon = "models/cap/asgard/ion_cannon",
        shield = "models/cap/asgard/shield",
        shield_generator = "models/cap/asgard/shield_generator",

        -- Transportation
        transporter = "models/cap/asgard/transporter",
        beam_platform = "models/cap/asgard/beam_platform",
        transport = "models/cap/asgard/transport",

        -- Ships and vessels
        ship = "models/cap/asgard/ship",
        mothership = "models/cap/asgard/mothership",
        science_vessel = "models/cap/asgard/science_vessel",

        -- Technology components
        core = "models/cap/asgard/core",
        stone = "models/cap/asgard/stone",
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
