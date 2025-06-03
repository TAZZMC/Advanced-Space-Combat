-- Advanced Space Combat - CAP Effects System v2.0.0
-- Enhanced visual effects using CAP assets and materials
-- Technology-specific particle effects and visual enhancements

print("[Advanced Space Combat] CAP Effects System v2.0.0 - Loading...")

-- Initialize CAP effects namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.Effects = ASC.CAP.Effects or {}

-- Enhanced CAP Effects Configuration
ASC.CAP.Effects.Config = {
    EnableCAPEffects = true,
    EnableParticleEffects = true,
    EnableLightEffects = true,
    EnableMaterialEffects = true,
    EffectQuality = "high", -- low, medium, high, ultra
    MaxActiveEffects = 100,
    EffectDistance = 2000
}

-- Technology-specific effect definitions
ASC.CAP.Effects.TechnologyEffects = {
    Ancient = {
        colors = {
            primary = Color(100, 200, 255),    -- Blue
            secondary = Color(255, 150, 50),   -- Orange
            energy = Color(150, 220, 255),     -- Light blue
            warning = Color(255, 100, 100)     -- Red
        },
        particles = {
            energy_field = "cap_ancient_energy_field",
            activation = "cap_ancient_activation",
            power_surge = "cap_ancient_power_surge",
            shield_bubble = "cap_ancient_shield_bubble",
            teleport = "cap_ancient_teleport"
        },
        materials = {
            energy = "models/cap/atlantis/energy",
            crystal = "models/cap/atlantis/crystal_active",
            shield = "models/cap/atlantis/shield_bubble"
        }
    },
    
    Goauld = {
        colors = {
            primary = Color(255, 200, 50),     -- Gold
            secondary = Color(255, 100, 50),   -- Orange-red
            energy = Color(255, 150, 0),       -- Orange
            warning = Color(255, 50, 50)       -- Red
        },
        particles = {
            energy_field = "cap_goauld_energy_field",
            activation = "cap_goauld_activation",
            power_surge = "cap_goauld_power_surge",
            shield_bubble = "cap_goauld_shield_bubble",
            teleport = "cap_goauld_teleport"
        },
        materials = {
            energy = "models/cap/goauld/energy",
            crystal = "models/cap/goauld/crystal_red",
            shield = "models/cap/goauld/shield_bubble"
        }
    },
    
    Asgard = {
        colors = {
            primary = Color(150, 150, 255),    -- Light blue
            secondary = Color(200, 200, 255),  -- Very light blue
            energy = Color(100, 150, 255),     -- Blue
            warning = Color(255, 200, 100)     -- Yellow
        },
        particles = {
            energy_field = "cap_asgard_energy_field",
            activation = "cap_asgard_activation",
            power_surge = "cap_asgard_power_surge",
            shield_bubble = "cap_asgard_shield_bubble",
            teleport = "cap_asgard_teleport"
        },
        materials = {
            energy = "models/cap/asgard/energy_blue",
            crystal = "models/cap/asgard/crystal_blue",
            shield = "models/cap/asgard/shield_bubble"
        }
    },
    
    Tauri = {
        colors = {
            primary = Color(100, 255, 100),    -- Green
            secondary = Color(150, 200, 255),  -- Light blue
            energy = Color(100, 200, 255),     -- Blue
            warning = Color(255, 255, 100)     -- Yellow
        },
        particles = {
            energy_field = "cap_tauri_energy_field",
            activation = "cap_tauri_activation",
            power_surge = "cap_tauri_power_surge",
            shield_bubble = "cap_tauri_shield_bubble",
            teleport = "cap_tauri_teleport"
        },
        materials = {
            energy = "models/cap/tauri/energy",
            shield = "models/cap/tauri/shield_bubble"
        }
    },
    
    Ori = {
        colors = {
            primary = Color(255, 255, 255),    -- White
            secondary = Color(255, 200, 100),  -- Light orange
            energy = Color(255, 255, 200),     -- Light yellow
            warning = Color(255, 100, 100)     -- Red
        },
        particles = {
            energy_field = "cap_ori_energy_field",
            activation = "cap_ori_activation",
            power_surge = "cap_ori_power_surge",
            shield_bubble = "cap_ori_shield_bubble"
        },
        materials = {
            energy = "models/cap/ori/energy",
            shield = "models/cap/ori/shield_bubble"
        }
    },
    
    Wraith = {
        colors = {
            primary = Color(100, 255, 100),    -- Green
            secondary = Color(150, 255, 150),  -- Light green
            energy = Color(100, 200, 100),     -- Dark green
            warning = Color(255, 150, 100)     -- Orange
        },
        particles = {
            energy_field = "cap_wraith_energy_field",
            activation = "cap_wraith_activation",
            power_surge = "cap_wraith_power_surge",
            shield_bubble = "cap_wraith_shield_bubble"
        },
        materials = {
            energy = "models/cap/wraith/energy",
            organic = "models/cap/wraith/organic",
            shield = "models/cap/wraith/shield_bubble"
        }
    }
}

-- Create technology-specific particle effect
function ASC.CAP.Effects.CreateParticleEffect(entity, technology, effectType, duration)
    if not IsValid(entity) then return end
    if not ASC.CAP.Effects.Config.EnableCAPEffects then return end
    
    local techEffects = ASC.CAP.Effects.TechnologyEffects[technology]
    if not techEffects or not techEffects.particles then return end
    
    local particleName = techEffects.particles[effectType]
    if not particleName then return end
    
    -- Create particle effect
    local effectData = EffectData()
    effectData:SetOrigin(entity:GetPos())
    effectData:SetEntity(entity)
    effectData:SetScale(duration or 5)
    
    util.Effect(particleName, effectData)
    
    if ASC.CAP.Effects.Config.EnableLightEffects then
        ASC.CAP.Effects.CreateLightEffect(entity, technology, effectType, duration)
    end
end

-- Create technology-specific light effect
function ASC.CAP.Effects.CreateLightEffect(entity, technology, effectType, duration)
    if not IsValid(entity) then return end
    
    local techEffects = ASC.CAP.Effects.TechnologyEffects[technology]
    if not techEffects or not techEffects.colors then return end
    
    local color = techEffects.colors.primary
    if effectType == "energy" then
        color = techEffects.colors.energy
    elseif effectType == "warning" then
        color = techEffects.colors.warning
    end
    
    -- Create dynamic light
    local light = DynamicLight(entity:EntIndex())
    if light then
        light.pos = entity:GetPos()
        light.r = color.r
        light.g = color.g
        light.b = color.b
        light.brightness = 2
        light.decay = 1000
        light.size = 256
        light.dietime = CurTime() + (duration or 5)
    end
end

-- Apply technology-specific material effects
function ASC.CAP.Effects.ApplyMaterialEffect(entity, technology, effectType)
    if not IsValid(entity) then return end
    if not ASC.CAP.Effects.Config.EnableMaterialEffects then return end
    
    local techEffects = ASC.CAP.Effects.TechnologyEffects[technology]
    if not techEffects or not techEffects.materials then return end
    
    local material = techEffects.materials[effectType]
    if material then
        entity:SetMaterial(material)
        
        -- Set color based on technology
        local color = techEffects.colors.primary
        entity:SetColor(color)
        
        return true
    end
    
    return false
end

-- Create shield bubble effect with CAP integration
function ASC.CAP.Effects.CreateShieldBubble(entity, technology, radius)
    if not IsValid(entity) then return end
    
    local techEffects = ASC.CAP.Effects.TechnologyEffects[technology]
    if not techEffects then return end
    
    -- Create shield bubble entity
    local shield = ents.Create("prop_physics")
    if not IsValid(shield) then return end
    
    shield:SetModel("models/hunter/misc/sphere375x375.mdl")
    shield:SetPos(entity:GetPos())
    shield:SetParent(entity)
    shield:Spawn()
    
    -- Apply CAP material
    local shieldMaterial = techEffects.materials.shield
    if shieldMaterial then
        shield:SetMaterial(shieldMaterial)
    end
    
    -- Set color and transparency
    local color = techEffects.colors.primary
    color.a = 100 -- Semi-transparent
    shield:SetColor(color)
    shield:SetRenderMode(RENDERMODE_TRANSALPHA)
    
    -- Scale to desired radius
    local scale = radius / 187.5 -- Default sphere radius
    shield:SetModelScale(scale, 0)
    
    -- Make non-solid
    shield:SetSolid(SOLID_NONE)
    shield:SetCollisionGroup(COLLISION_GROUP_WORLD)
    
    -- Add pulsing effect
    shield.PulseStart = CurTime()
    shield.PulseSpeed = 2
    
    -- Store reference
    entity.CAPShieldBubble = shield
    
    return shield
end

-- Update shield bubble effects
function ASC.CAP.Effects.UpdateShieldBubble(shield)
    if not IsValid(shield) then return end
    
    -- Pulsing transparency effect
    local time = CurTime() - (shield.PulseStart or 0)
    local pulse = math.sin(time * (shield.PulseSpeed or 2)) * 0.3 + 0.7
    
    local color = shield:GetColor()
    color.a = math.floor(pulse * 150)
    shield:SetColor(color)
end

-- Create hyperspace effect with CAP integration
function ASC.CAP.Effects.CreateHyperspaceEffect(entity, technology, stage)
    if not IsValid(entity) then return end
    
    local techEffects = ASC.CAP.Effects.TechnologyEffects[technology]
    if not techEffects then return end
    
    if stage == "initiation" then
        ASC.CAP.Effects.CreateParticleEffect(entity, technology, "power_surge", 3)
        ASC.CAP.Effects.ApplyMaterialEffect(entity, technology, "energy")
        
    elseif stage == "window_opening" then
        ASC.CAP.Effects.CreateParticleEffect(entity, technology, "teleport", 2)
        
    elseif stage == "travel" then
        ASC.CAP.Effects.CreateParticleEffect(entity, technology, "energy_field", 10)
        
    elseif stage == "exit" then
        ASC.CAP.Effects.CreateParticleEffect(entity, technology, "activation", 2)
        ASC.CAP.Effects.CreateLightEffect(entity, technology, "energy", 3)
    end
end

-- Initialize CAP effects system
function ASC.CAP.Effects.Initialize()
    print("[ASC CAP Effects] Initializing CAP Effects System...")
    
    -- Set up effect update timer
    timer.Create("ASC_CAP_Effects_Update", 0.1, 0, function()
        -- Update all shield bubbles
        for _, entity in ipairs(ents.GetAll()) do
            if IsValid(entity) and IsValid(entity.CAPShieldBubble) then
                ASC.CAP.Effects.UpdateShieldBubble(entity.CAPShieldBubble)
            end
        end
    end)
    
    print("[ASC CAP Effects] CAP Effects System initialized successfully!")
end

-- Console commands for CAP effects
if SERVER then
    concommand.Add("asc_cap_test_effect", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        
        local technology = args[1] or "Ancient"
        local effectType = args[2] or "activation"
        
        ASC.CAP.Effects.CreateParticleEffect(ply, technology, effectType, 5)
        ply:ChatPrint("Created " .. technology .. " " .. effectType .. " effect")
    end)
    
    concommand.Add("asc_cap_test_shield", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        
        local technology = args[1] or "Ancient"
        local radius = tonumber(args[2]) or 200
        
        local shield = ASC.CAP.Effects.CreateShieldBubble(ply, technology, radius)
        if IsValid(shield) then
            ply:ChatPrint("Created " .. technology .. " shield bubble")
            
            -- Remove after 10 seconds
            timer.Simple(10, function()
                if IsValid(shield) then
                    shield:Remove()
                end
            end)
        end
    end)
end

-- Initialize when ready
hook.Add("Initialize", "ASC_CAP_Effects_Init", function()
    timer.Simple(3, function()
        ASC.CAP.Effects.Initialize()
    end)
end)

print("[Advanced Space Combat] CAP Effects System v2.0.0 - Loaded successfully!")
