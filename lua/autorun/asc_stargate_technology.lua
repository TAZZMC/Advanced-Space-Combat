-- Advanced Space Combat - Stargate Technology Integration v2.2.1
-- Authentic Stargate-inspired technologies and systems

print("[Advanced Space Combat] Stargate Technology Integration v2.2.1 - Loading...")

-- Initialize Stargate technology namespace
ASC = ASC or {}
ASC.Stargate = ASC.Stargate or {}

-- Stargate technology configuration
ASC.Stargate.Config = {
    EnableStargateTech = true,
    EnableAncientTech = true,
    EnableAsgardTech = true,
    EnableGoauldTech = true,
    EnableOriTech = true,
    EnableWraithTech = true,
    EnableTauriTech = true,
    
    -- Technology tiers (1-10, 10 being most advanced)
    TechnologyTiers = {
        Tau_ri = 3,      -- Earth/Human technology
        Goa_uld = 5,     -- Goa'uld technology
        Wraith = 6,      -- Wraith technology
        Asgard = 8,      -- Asgard technology
        Ori = 9,         -- Ori technology
        Ancient = 10     -- Ancient/Lantean technology (most advanced)
    },

    -- Technology descriptions
    TechnologyDescriptions = {
        Tau_ri = "Human reverse-engineered technology with practical engineering",
        Goa_uld = "Naquadah-enhanced technology with pyramid ship integration",
        Wraith = "Organic bio-integrated technology with self-repair capabilities",
        Asgard = "Advanced quantum technology with superior efficiency",
        Ori = "Ascended being technology with massive power output",
        Ancient = "Ultimate technology from the most advanced civilization"
    }
}

-- Technology categories and systems
ASC.Stargate.Technologies = {
    -- Ancient Technology
    Ancient = {
        -- Weapons
        {
            name = "Ancient Drone Weapon",
            class = "asc_ancient_drone",
            description = "Self-guided energy projectiles with adaptive targeting",
            tier = 10,
            energyCost = 500,
            damage = 1000,
            range = 15000,
            features = {"adaptive_targeting", "shield_penetration", "swarm_intelligence"}
        },
        {
            name = "Ancient Defense Satellite",
            class = "asc_ancient_satellite",
            description = "Automated orbital defense platform",
            tier = 10,
            energyCost = 2000,
            damage = 2500,
            range = 25000,
            features = {"orbital_deployment", "automated_targeting", "massive_firepower"}
        },
        
        -- Shields
        {
            name = "Ancient City Shield",
            class = "asc_ancient_city_shield",
            description = "Planetary-scale energy barrier",
            tier = 10,
            energyCost = 5000,
            shieldStrength = 50000,
            coverage = "planetary",
            features = {"atmospheric_protection", "underwater_operation", "selective_permeability"}
        },
        
        -- Hyperdrives
        {
            name = "Ancient Hyperdrive",
            class = "asc_ancient_hyperdrive",
            description = "Instantaneous intergalactic travel system",
            tier = 10,
            energyCost = 1000,
            range = 100000000, -- Intergalactic range
            speed = "instantaneous",
            features = {"intergalactic_travel", "precise_navigation", "zero_travel_time"}
        },
        
        -- Special Systems
        {
            name = "Zero Point Module (ZPM)",
            class = "asc_ancient_zpm",
            description = "Vacuum energy extraction power source",
            tier = 10,
            energyOutput = 100000,
            duration = "indefinite",
            features = {"unlimited_energy", "compact_design", "stable_output"}
        },
        {
            name = "Ancient Control Chair",
            class = "asc_ancient_control_chair",
            description = "Neural interface command and control system",
            tier = 10,
            energyCost = 1000,
            range = 50000,
            features = {"neural_interface", "city_control", "drone_command", "shield_control"}
        },
        {
            name = "Ancient Stargate",
            class = "asc_ancient_stargate",
            description = "Instantaneous matter transportation network",
            tier = 10,
            energyCost = 2000,
            range = "galactic",
            features = {"matter_transport", "wormhole_travel", "network_access", "iris_protection"}
        },
        {
            name = "Ancient Time Dilation Device",
            class = "asc_ancient_time_device",
            description = "Temporal manipulation field generator",
            tier = 10,
            energyCost = 5000,
            effect = "time_acceleration",
            features = {"time_manipulation", "field_generation", "temporal_shielding"}
        },
        {
            name = "Ancient Healing Device",
            class = "asc_ancient_healing_device",
            description = "Advanced medical nanotechnology",
            tier = 10,
            energyCost = 500,
            healingRate = 1000,
            features = {"cellular_repair", "disease_cure", "life_extension", "genetic_enhancement"}
        }
    },
    
    -- Asgard Technology
    Asgard = {
        -- Weapons
        {
            name = "Asgard Ion Cannon",
            class = "asc_asgard_ion_cannon",
            description = "High-energy particle beam weapon",
            tier = 8,
            energyCost = 300,
            damage = 800,
            range = 12000,
            features = {"penetrating_beam", "rapid_fire", "precise_targeting"}
        },
        {
            name = "Asgard Plasma Beam",
            class = "asc_asgard_plasma_beam",
            description = "Continuous plasma energy weapon",
            tier = 8,
            energyCost = 400,
            damage = 600,
            range = 10000,
            features = {"continuous_beam", "shield_disruption", "adaptive_frequency"}
        },
        
        -- Shields
        {
            name = "Asgard Shield Generator",
            class = "asc_asgard_shields",
            description = "Advanced energy barrier system",
            tier = 8,
            energyCost = 1000,
            shieldStrength = 15000,
            rechargeRate = 500,
            features = {"rapid_recharge", "frequency_modulation", "multi_layer_protection"}
        },
        
        -- Hyperdrives
        {
            name = "Asgard Hyperdrive",
            class = "asc_asgard_hyperdrive",
            description = "Advanced faster-than-light propulsion",
            tier = 8,
            energyCost = 500,
            range = 50000000, -- Intergalactic capable
            speed = "very_fast",
            features = {"long_range_travel", "efficient_operation", "reliable_navigation"}
        },
        
        -- Special Systems
        {
            name = "Asgard Beaming Technology",
            class = "asc_asgard_beamer",
            description = "Matter transportation system",
            tier = 8,
            energyCost = 200,
            range = 5000,
            features = {"precise_transport", "living_matter_safe", "rapid_deployment"}
        },
        {
            name = "Asgard Computer Core",
            class = "asc_asgard_computer",
            description = "Advanced quantum computer system",
            tier = 8,
            energyCost = 800,
            processingPower = 50000,
            features = {"quantum_processing", "holographic_storage", "neural_interface", "ship_control"}
        },
        {
            name = "Asgard Cloning Facility",
            class = "asc_asgard_cloning_facility",
            description = "Advanced genetic replication technology",
            tier = 8,
            energyCost = 2000,
            cloningTime = 300, -- seconds
            features = {"genetic_replication", "consciousness_transfer", "body_enhancement", "longevity_extension"}
        },
        {
            name = "Asgard Hologram Projector",
            class = "asc_asgard_hologram",
            description = "Three-dimensional holographic projection system",
            tier = 8,
            energyCost = 300,
            range = 10000,
            features = {"3d_projection", "interactive_interface", "remote_communication", "tactical_display"}
        },
        {
            name = "Asgard Time Dilation Device",
            class = "asc_asgard_time_device",
            description = "Localized time manipulation field",
            tier = 8,
            energyCost = 3000,
            effect = "time_acceleration",
            features = {"localized_time_field", "research_acceleration", "tactical_advantage"}
        }
    },
    
    -- Goa'uld Technology
    Goa_uld = {
        -- Weapons
        {
            name = "Staff Cannon",
            class = "asc_goauld_staff_cannon",
            description = "Plasma-based energy weapon",
            tier = 5,
            energyCost = 150,
            damage = 400,
            range = 8000,
            features = {"plasma_projectile", "explosive_impact", "intimidation_factor"}
        },
        {
            name = "Ribbon Device Weapon",
            class = "asc_goauld_ribbon_device",
            description = "Neural disruption weapon",
            tier = 5,
            energyCost = 100,
            damage = 200,
            range = 2000,
            features = {"neural_disruption", "non_lethal_option", "precise_targeting"}
        },
        
        -- Shields
        {
            name = "Goa'uld Shield Generator",
            class = "asc_goauld_shields",
            description = "Energy barrier protection system",
            tier = 5,
            energyCost = 400,
            shieldStrength = 8000,
            rechargeRate = 200,
            features = {"energy_absorption", "pyramid_design", "naquadah_enhanced"}
        },
        
        -- Hyperdrives
        {
            name = "Goa'uld Hyperdrive",
            class = "asc_goauld_hyperdrive",
            description = "Naquadah-powered FTL system",
            tier = 5,
            energyCost = 300,
            range = 10000000, -- Galactic range
            speed = "moderate",
            features = {"naquadah_powered", "pyramid_ship_integration", "reliable_operation"}
        },

        -- Special Systems
        {
            name = "Goa'uld Sarcophagus",
            class = "asc_goauld_sarcophagus",
            description = "Cellular regeneration and resurrection device",
            tier = 5,
            energyCost = 1000,
            healingRate = 500,
            features = {"cellular_regeneration", "resurrection", "life_extension", "addiction_risk"}
        },
        {
            name = "Goa'uld Hand Device",
            class = "asc_goauld_hand_device",
            description = "Personal energy weapon and torture device",
            tier = 5,
            energyCost = 100,
            damage = 300,
            range = 1000,
            features = {"energy_blast", "torture_mode", "personal_weapon", "intimidation"}
        },
        {
            name = "Goa'uld Ring Transporter",
            class = "asc_goauld_rings",
            description = "Short-range matter transportation system",
            tier = 5,
            energyCost = 150,
            range = 2000,
            features = {"matter_transport", "ship_to_surface", "rapid_deployment", "ring_platform"}
        },
        {
            name = "Goa'uld Naquadah Reactor",
            class = "asc_goauld_naquadah_reactor",
            description = "Naquadah-enhanced power generation",
            tier = 5,
            energyOutput = 5000,
            efficiency = 0.8,
            features = {"naquadah_enhanced", "stable_output", "compact_design", "overload_risk"}
        },
        {
            name = "Goa'uld Cloaking Device",
            class = "asc_goauld_cloak",
            description = "Visual and sensor concealment system",
            tier = 5,
            energyCost = 800,
            effectiveness = 0.9,
            features = {"visual_cloak", "sensor_masking", "energy_intensive", "movement_detection"}
        }
    },
    
    -- Wraith Technology
    Wraith = {
        -- Weapons
        {
            name = "Wraith Dart Weapon",
            class = "asc_wraith_dart_weapon",
            description = "Organic energy weapon system",
            tier = 6,
            energyCost = 200,
            damage = 500,
            range = 9000,
            features = {"organic_technology", "self_repair", "bio_integration"}
        },
        {
            name = "Culling Beam",
            class = "asc_wraith_culling_beam",
            description = "Matter transportation weapon",
            tier = 6,
            energyCost = 400,
            damage = 0, -- Non-lethal transport
            range = 5000,
            features = {"matter_transport", "selective_targeting", "organic_interface"}
        },
        
        -- Shields
        {
            name = "Wraith Hive Shield",
            class = "asc_wraith_shields",
            description = "Organic energy barrier system",
            tier = 6,
            energyCost = 600,
            shieldStrength = 12000,
            rechargeRate = 300,
            features = {"organic_regeneration", "adaptive_frequency", "bio_integration"}
        },

        -- Hyperdrives
        {
            name = "Wraith Hyperdrive",
            class = "asc_wraith_hyperdrive",
            description = "Organic faster-than-light propulsion",
            tier = 6,
            energyCost = 400,
            range = 20000000, -- Intergalactic capable
            speed = "fast",
            features = {"organic_technology", "bio_integration", "self_repair", "efficient_travel"}
        },

        -- Special Systems
        {
            name = "Wraith Life Support Pod",
            class = "asc_wraith_life_pod",
            description = "Organic hibernation and life extension system",
            tier = 6,
            energyCost = 200,
            hibernationTime = "indefinite",
            features = {"hibernation", "life_extension", "organic_interface", "minimal_energy"}
        },
        {
            name = "Wraith Enzyme Extractor",
            class = "asc_wraith_enzyme",
            description = "Life force extraction and enhancement device",
            tier = 6,
            energyCost = 300,
            extractionRate = 100,
            features = {"life_force_extraction", "enhancement_production", "organic_processing"}
        },
        {
            name = "Wraith Regeneration Chamber",
            class = "asc_wraith_regen_chamber",
            description = "Advanced organic healing and restoration",
            tier = 6,
            energyCost = 500,
            healingRate = 800,
            features = {"organic_healing", "rapid_regeneration", "bio_enhancement", "tissue_restoration"}
        },
        {
            name = "Wraith Hive Mind Interface",
            class = "asc_wraith_hive_mind",
            description = "Collective consciousness communication network",
            tier = 6,
            energyCost = 400,
            range = "galactic",
            features = {"collective_consciousness", "telepathic_network", "shared_knowledge", "hive_coordination"}
        }
    },
    
    -- Tau'ri (Earth) Technology
    Tau_ri = {
        -- Weapons
        {
            name = "Railgun Turret",
            class = "asc_tauri_railgun",
            description = "Electromagnetic kinetic weapon",
            tier = 3,
            energyCost = 100,
            damage = 600,
            range = 7000,
            features = {"kinetic_penetration", "no_energy_projectile", "rapid_fire"}
        },
        {
            name = "Nuke-Enhanced Missile",
            class = "asc_tauri_nuke_missile",
            description = "Nuclear-enhanced warhead",
            tier = 3,
            energyCost = 50,
            damage = 1500,
            range = 15000,
            features = {"massive_damage", "area_effect", "single_use"}
        },
        
        -- Shields
        {
            name = "Tau'ri Shield Generator",
            class = "asc_tauri_shields",
            description = "Reverse-engineered energy barrier",
            tier = 3,
            energyCost = 300,
            shieldStrength = 5000,
            rechargeRate = 150,
            features = {"human_engineering", "modular_design", "cost_effective"}
        },

        -- Hyperdrives
        {
            name = "Tau'ri Hyperdrive",
            class = "asc_tauri_hyperdrive",
            description = "Reverse-engineered Asgard hyperdrive",
            tier = 3,
            energyCost = 400,
            range = 5000000, -- Limited galactic range
            speed = "slow",
            features = {"reverse_engineered", "human_modifications", "reliable_operation", "limited_range"}
        },

        -- Special Systems
        {
            name = "Tau'ri F-302 Fighter",
            class = "asc_tauri_f302",
            description = "Space-capable fighter craft",
            tier = 3,
            energyCost = 200,
            speed = 500,
            features = {"space_fighter", "atmospheric_capable", "missile_armed", "human_piloted"}
        },
        {
            name = "Tau'ri Iris",
            class = "asc_tauri_iris",
            description = "Stargate protective barrier system",
            tier = 3,
            energyCost = 50,
            protection = 0.99,
            features = {"stargate_protection", "titanium_construction", "rapid_deployment", "manual_override"}
        },
        {
            name = "Tau'ri Prometheus Engine",
            class = "asc_tauri_prometheus_engine",
            description = "Human-built spacecraft propulsion",
            tier = 3,
            energyCost = 300,
            thrust = 1000,
            features = {"human_engineering", "reliable_operation", "maintenance_friendly", "upgradeable"}
        }
    },

    -- Ori Technology
    Ori = {
        -- Weapons
        {
            name = "Ori Pulse Weapon",
            class = "asc_ori_pulse_weapon",
            description = "Advanced energy pulse cannon",
            tier = 9,
            energyCost = 600,
            damage = 1200,
            range = 18000,
            features = {"energy_pulse", "shield_penetration", "rapid_fire", "ori_enhanced"}
        },
        {
            name = "Ori Beam Weapon",
            class = "asc_ori_beam_weapon",
            description = "Continuous high-energy beam",
            tier = 9,
            energyCost = 800,
            damage = 1000,
            range = 15000,
            features = {"continuous_beam", "precise_targeting", "shield_disruption", "ori_technology"}
        },

        -- Shields
        {
            name = "Ori Shield Generator",
            class = "asc_ori_shields",
            description = "Advanced energy barrier system",
            tier = 9,
            energyCost = 1500,
            shieldStrength = 25000,
            rechargeRate = 800,
            features = {"advanced_shielding", "rapid_recharge", "ori_enhanced", "energy_efficient"}
        },

        -- Hyperdrives
        {
            name = "Ori Hyperdrive",
            class = "asc_ori_hyperdrive",
            description = "Advanced faster-than-light system",
            tier = 9,
            energyCost = 700,
            range = 80000000, -- Superior intergalactic range
            speed = "very_fast",
            features = {"intergalactic_travel", "superior_speed", "ori_technology", "efficient_operation"}
        },

        -- Special Systems
        {
            name = "Ori Supergate",
            class = "asc_ori_supergate",
            description = "Massive intergalactic transportation gate",
            tier = 9,
            energyCost = 10000,
            range = "intergalactic",
            features = {"intergalactic_transport", "massive_scale", "ship_transport", "ori_construction"}
        },
        {
            name = "Ori Prior Staff",
            class = "asc_ori_prior_staff",
            description = "Advanced energy manipulation device",
            tier = 9,
            energyCost = 400,
            damage = 800,
            range = 3000,
            features = {"energy_manipulation", "telekinesis", "shield_generation", "prior_technology"}
        },
        {
            name = "Ori Satellite Weapon",
            class = "asc_ori_satellite",
            description = "Orbital bombardment platform",
            tier = 9,
            energyCost = 3000,
            damage = 5000,
            range = 50000,
            features = {"orbital_bombardment", "planet_killer", "massive_firepower", "ori_construction"}
        }
    }
}

-- Technology detection and integration
function ASC.Stargate.DetectTechnologyLevel(entity)
    if not IsValid(entity) then return 1 end
    
    local class = entity:GetClass()
    
    -- Detect technology tier based on entity class
    for culture, technologies in pairs(ASC.Stargate.Technologies) do
        for _, tech in ipairs(technologies) do
            if tech.class == class then
                return tech.tier
            end
        end
    end
    
    return 1 -- Default to basic technology
end

-- Technology compatibility system
function ASC.Stargate.CheckCompatibility(tech1, tech2)
    local tier1 = ASC.Stargate.DetectTechnologyLevel(tech1)
    local tier2 = ASC.Stargate.DetectTechnologyLevel(tech2)
    
    -- Higher tier technology can interface with lower tier
    -- Same tier technology is fully compatible
    -- Lower tier cannot fully utilize higher tier
    
    if tier1 >= tier2 then
        return math.min(1.0, tier2 / tier1) -- Compatibility ratio
    else
        return math.min(0.5, tier1 / tier2) -- Reduced compatibility
    end
end

-- Enhanced weapon system with Stargate tech
function ASC.Stargate.CreateStargateWeapon(weaponType, culture)
    local technologies = ASC.Stargate.Technologies[culture]
    if not technologies then return nil end
    
    for _, tech in ipairs(technologies) do
        if tech.name:lower():find(weaponType:lower()) then
            return {
                class = tech.class,
                name = tech.name,
                description = tech.description,
                tier = tech.tier,
                energyCost = tech.energyCost,
                damage = tech.damage,
                range = tech.range,
                features = tech.features
            }
        end
    end
    
    return nil
end

-- Enhanced shield system with Stargate tech
function ASC.Stargate.CreateStargateShield(culture)
    local technologies = ASC.Stargate.Technologies[culture]
    if not technologies then return nil end
    
    for _, tech in ipairs(technologies) do
        if tech.name:lower():find("shield") then
            return {
                class = tech.class,
                name = tech.name,
                description = tech.description,
                tier = tech.tier,
                energyCost = tech.energyCost,
                shieldStrength = tech.shieldStrength,
                rechargeRate = tech.rechargeRate,
                features = tech.features
            }
        end
    end
    
    return nil
end

-- Enhanced hyperdrive system with Stargate tech
function ASC.Stargate.CreateStargateHyperdrive(culture)
    local technologies = ASC.Stargate.Technologies[culture]
    if not technologies then return nil end
    
    for _, tech in ipairs(technologies) do
        if tech.name:lower():find("hyperdrive") then
            return {
                class = tech.class,
                name = tech.name,
                description = tech.description,
                tier = tech.tier,
                energyCost = tech.energyCost,
                range = tech.range,
                speed = tech.speed,
                features = tech.features
            }
        end
    end
    
    return nil
end

-- Technology upgrade system
function ASC.Stargate.UpgradeTechnology(entity, targetCulture)
    if not IsValid(entity) then return false end
    
    local currentTier = ASC.Stargate.DetectTechnologyLevel(entity)
    local targetTier = ASC.Stargate.Config.TechnologyTiers[targetCulture]
    
    if not targetTier or targetTier <= currentTier then
        return false -- Cannot downgrade or same tier
    end
    
    -- Apply upgrade effects
    entity:SetNWInt("TechnologyTier", targetTier)
    entity:SetNWString("TechnologyCulture", targetCulture)
    
    -- Enhance entity capabilities based on new tier
    local multiplier = targetTier / currentTier
    
    if entity.SetMaxHealth then
        entity:SetMaxHealth(entity:GetMaxHealth() * multiplier)
        entity:SetHealth(entity:GetMaxHealth())
    end
    
    if entity.SetNWInt then
        entity:SetNWInt("EnergyCapacity", (entity:GetNWInt("EnergyCapacity", 1000) * multiplier))
        entity:SetNWInt("ShieldStrength", (entity:GetNWInt("ShieldStrength", 1000) * multiplier))
    end
    
    return true
end

-- Console commands for Stargate technology
concommand.Add("asc_stargate_spawn", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local culture = args[1] or "Ancient"
    local techType = args[2] or "weapon"
    
    if not ASC.Stargate.Technologies[culture] then
        ply:ChatPrint("[Advanced Space Combat] Invalid culture. Available: Ancient, Asgard, Goa_uld, Wraith, Tau_ri")
        return
    end
    
    local tech = nil
    if techType == "weapon" then
        tech = ASC.Stargate.CreateStargateWeapon("cannon", culture)
    elseif techType == "shield" then
        tech = ASC.Stargate.CreateStargateShield(culture)
    elseif techType == "hyperdrive" then
        tech = ASC.Stargate.CreateStargateHyperdrive(culture)
    end
    
    if not tech then
        ply:ChatPrint("[Advanced Space Combat] No " .. techType .. " available for " .. culture)
        return
    end
    
    -- Spawn the technology
    local trace = ply:GetEyeTrace()
    local pos = trace.HitPos + trace.HitNormal * 50
    local ang = ply:EyeAngles()
    ang.pitch = 0
    ang.roll = 0
    
    local entity = ents.Create(tech.class)
    if IsValid(entity) then
        entity:SetPos(pos)
        entity:SetAngles(ang)
        entity:SetNWString("TechnologyCulture", culture)
        entity:SetNWInt("TechnologyTier", tech.tier)
        entity:Spawn()
        
        ply:ChatPrint("[Advanced Space Combat] " .. tech.name .. " (" .. culture .. ") spawned!")
        
        -- Add to undo
        undo.Create("Stargate Technology")
        undo.AddEntity(entity)
        undo.SetPlayer(ply)
        undo.Finish()
    else
        ply:ChatPrint("[Advanced Space Combat] Failed to spawn " .. tech.name)
    end
end)

concommand.Add("asc_stargate_upgrade", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local targetCulture = args[1] or "Ancient"
    
    if not ASC.Stargate.Config.TechnologyTiers[targetCulture] then
        ply:ChatPrint("[Advanced Space Combat] Invalid culture. Available: Ancient, Asgard, Goa_uld, Wraith, Tau_ri")
        return
    end
    
    local trace = ply:GetEyeTrace()
    local entity = trace.Entity
    
    if not IsValid(entity) then
        ply:ChatPrint("[Advanced Space Combat] No valid entity found")
        return
    end
    
    local success = ASC.Stargate.UpgradeTechnology(entity, targetCulture)
    
    if success then
        ply:ChatPrint("[Advanced Space Combat] Entity upgraded to " .. targetCulture .. " technology!")
    else
        ply:ChatPrint("[Advanced Space Combat] Cannot upgrade entity to " .. targetCulture .. " technology")
    end
end)

concommand.Add("asc_stargate_info", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[Advanced Space Combat] Stargate Technology Information:")
    ply:ChatPrint("Available Cultures:")
    
    for culture, tier in pairs(ASC.Stargate.Config.TechnologyTiers) do
        ply:ChatPrint("• " .. culture .. " (Tier " .. tier .. ")")
    end
    
    ply:ChatPrint("Commands:")
    ply:ChatPrint("• asc_stargate_spawn <culture> <type> - Spawn Stargate technology")
    ply:ChatPrint("• asc_stargate_upgrade <culture> - Upgrade entity to culture's tech")
    ply:ChatPrint("• asc_stargate_info - Show this information")
end)

-- Initialize Stargate technology integration
hook.Add("Initialize", "ASC_StargateInit", function()
    print("[Advanced Space Combat] Stargate Technology Integration initialized")
    print("[Advanced Space Combat] Available cultures: Ancient, Asgard, Goa'uld, Wraith, Tau'ri")
    print("[Advanced Space Combat] Technology tiers: 1-10 (10 = Ancient level)")
end)

print("[Advanced Space Combat] Stargate Technology Integration loaded successfully!")
