-- Advanced Space Combat - CAP Fallback System v3.0
-- Provides fallback functionality when CAP is not available
-- Ensures ASC features work regardless of CAP installation status

print("[Advanced Space Combat] CAP Fallback System v3.0 - Loading...")

-- Initialize fallback namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.Fallback = ASC.CAP.Fallback or {}

-- Fallback configuration
ASC.CAP.Fallback.Config = {
    EnableFallbackSystems = true,
    EnableFallbackSounds = true,
    EnableFallbackMaterials = true,
    EnableFallbackEffects = true,
    EnableVirtualEntities = true,
    
    -- Fallback resource paths
    FallbackSoundPath = "ambient/",
    FallbackMaterialPath = "models/debug/",
    FallbackModelPath = "models/props_c17/",
    
    -- Virtual entity settings
    VirtualEntityLifetime = 300, -- 5 minutes
    MaxVirtualEntities = 50
}

-- Fallback resource definitions
ASC.CAP.Fallback.Resources = {
    -- Fallback sounds
    sounds = {
        stargate_dial = "ambient/wind1.wav",
        stargate_open = "ambient/energy/weld1.wav",
        stargate_close = "ambient/energy/weld2.wav",
        shield_activate = "ambient/energy/electric_loop.wav",
        shield_deactivate = "ambient/energy/electric_loop.wav",
        energy_charge = "ambient/energy/electric_loop.wav",
        transport_beam = "ambient/energy/weld1.wav",
        weapon_fire = "weapons/physcannon/energy_sing_loop4.wav",
        ancient_tech = "ambient/atmosphere/cave_hit1.wav",
        asgard_tech = "ambient/energy/electric_loop.wav",
        goauld_tech = "ambient/energy/weld1.wav"
    },
    
    -- Fallback materials
    materials = {
        stargate_ring = "models/debug/debugwhite",
        stargate_chevron = "models/debug/debugwhite",
        shield_bubble = "models/debug/debugwhite",
        energy_core = "models/debug/debugwhite",
        ancient_tech = "models/debug/debugwhite",
        asgard_tech = "models/debug/debugwhite",
        goauld_tech = "models/debug/debugwhite",
        event_horizon = "models/debug/debugwhite"
    },
    
    -- Fallback models
    models = {
        stargate = "models/props_c17/oildrum001.mdl",
        shield_generator = "models/props_c17/oildrum001.mdl",
        energy_core = "models/props_c17/oildrum001.mdl",
        dhd = "models/props_c17/computer01_keyboard.mdl",
        zpm = "models/props_c17/canister01a.mdl",
        naquadah_generator = "models/props_c17/oildrum001.mdl",
        transport_rings = "models/props_c17/oildrum001.mdl"
    }
}

-- Virtual CAP entity system
ASC.CAP.Fallback.VirtualEntities = {}

-- Create virtual CAP entity
function ASC.CAP.Fallback.CreateVirtualEntity(entityType, position, owner)
    if not ASC.CAP.Fallback.Config.EnableVirtualEntities then return nil end
    
    local virtualEntity = {
        type = entityType,
        position = position,
        owner = owner,
        created = CurTime(),
        active = false,
        properties = {},
        methods = {}
    }
    
    -- Set up entity based on type
    if entityType == "stargate" then
        virtualEntity.properties = {
            address = "000-000-000",
            network = "milkyway",
            locked = false,
            dialing = false,
            connected = false
        }
        
        virtualEntity.methods = {
            Dial = function(address) 
                virtualEntity.properties.dialing = true
                virtualEntity.properties.connected = true
                return true
            end,
            AbortDial = function() 
                virtualEntity.properties.dialing = false
                virtualEntity.properties.connected = false
                return true
            end,
            GetAddress = function() return virtualEntity.properties.address end,
            SetAddress = function(addr) virtualEntity.properties.address = addr end
        }
        
    elseif entityType == "shield" then
        virtualEntity.properties = {
            strength = 100,
            maxStrength = 100,
            frequency = 1000,
            active = false
        }
        
        virtualEntity.methods = {
            Activate = function() virtualEntity.properties.active = true return true end,
            Deactivate = function() virtualEntity.properties.active = false return true end,
            SetShieldStrength = function(str) virtualEntity.properties.strength = str end,
            GetShieldStrength = function() return virtualEntity.properties.strength end,
            SetFrequency = function(freq) virtualEntity.properties.frequency = freq end,
            GetFrequency = function() return virtualEntity.properties.frequency end
        }
        
    elseif entityType == "energy" then
        virtualEntity.properties = {
            energy = 1000,
            maxEnergy = 10000,
            efficiency = 1.0,
            active = true
        }
        
        virtualEntity.methods = {
            GetEnergy = function() return virtualEntity.properties.energy end,
            SetEnergy = function(energy) virtualEntity.properties.energy = energy end,
            GetCapacity = function() return virtualEntity.properties.maxEnergy end,
            TransferEnergy = function(target, amount)
                if virtualEntity.properties.energy >= amount then
                    virtualEntity.properties.energy = virtualEntity.properties.energy - amount
                    return true, amount
                end
                return false, 0
            end
        }
    end
    
    -- Add to virtual entity list
    table.insert(ASC.CAP.Fallback.VirtualEntities, virtualEntity)
    
    -- Clean up old virtual entities
    ASC.CAP.Fallback.CleanupVirtualEntities()
    
    return virtualEntity
end

-- Clean up expired virtual entities
function ASC.CAP.Fallback.CleanupVirtualEntities()
    local currentTime = CurTime()
    local lifetime = ASC.CAP.Fallback.Config.VirtualEntityLifetime
    
    for i = #ASC.CAP.Fallback.VirtualEntities, 1, -1 do
        local entity = ASC.CAP.Fallback.VirtualEntities[i]
        if currentTime - entity.created > lifetime then
            table.remove(ASC.CAP.Fallback.VirtualEntities, i)
        end
    end
    
    -- Limit total virtual entities
    local maxEntities = ASC.CAP.Fallback.Config.MaxVirtualEntities
    while #ASC.CAP.Fallback.VirtualEntities > maxEntities do
        table.remove(ASC.CAP.Fallback.VirtualEntities, 1)
    end
end

-- Get fallback sound
function ASC.CAP.Fallback.GetSound(soundType, technology)
    if not ASC.CAP.Fallback.Config.EnableFallbackSounds then return nil end
    
    technology = technology or "ancient"
    local techSound = soundType .. "_" .. string.lower(technology)
    
    -- Try technology-specific sound first
    local sound = ASC.CAP.Fallback.Resources.sounds[techSound]
    if sound then return sound end
    
    -- Fall back to generic sound
    sound = ASC.CAP.Fallback.Resources.sounds[soundType]
    if sound then return sound end
    
    -- Ultimate fallback
    return "ambient/wind1.wav"
end

-- Get fallback material
function ASC.CAP.Fallback.GetMaterial(materialType, technology)
    if not ASC.CAP.Fallback.Config.EnableFallbackMaterials then return nil end
    
    technology = technology or "ancient"
    local techMaterial = materialType .. "_" .. string.lower(technology)
    
    -- Try technology-specific material first
    local material = ASC.CAP.Fallback.Resources.materials[techMaterial]
    if material then return Material(material) end
    
    -- Fall back to generic material
    material = ASC.CAP.Fallback.Resources.materials[materialType]
    if material then return Material(material) end
    
    -- Ultimate fallback
    return Material("models/debug/debugwhite")
end

-- Get fallback model
function ASC.CAP.Fallback.GetModel(modelType, technology)
    technology = technology or "ancient"
    local techModel = modelType .. "_" .. string.lower(technology)
    
    -- Try technology-specific model first
    local model = ASC.CAP.Fallback.Resources.models[techModel]
    if model then return model end
    
    -- Fall back to generic model
    model = ASC.CAP.Fallback.Resources.models[modelType]
    if model then return model end
    
    -- Ultimate fallback
    return "models/props_c17/oildrum001.mdl"
end

-- Fallback effect system
ASC.CAP.Fallback.Effects = {}

-- Create fallback effect
function ASC.CAP.Fallback.Effects.Create(effectType, position, technology)
    if not ASC.CAP.Fallback.Config.EnableFallbackEffects then return false end
    
    technology = technology or "ancient"
    
    -- Create basic particle effect
    local effectData = EffectData()
    effectData:SetOrigin(position)
    effectData:SetScale(1.0)
    
    if effectType == "stargate_dial" then
        util.Effect("sparks", effectData)
        
    elseif effectType == "shield_activate" then
        util.Effect("cball_explode", effectData)
        
    elseif effectType == "energy_charge" then
        util.Effect("TeslaHitBoxes", effectData)
        
    elseif effectType == "transport_beam" then
        util.Effect("TeleportSplash", effectData)
        
    else
        util.Effect("sparks", effectData)
    end
    
    return true
end

-- Fallback integration with main CAP system
function ASC.CAP.Fallback.IntegrateWithMainSystem()
    -- Override CAP functions when CAP is not available
    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Available then
        
        -- Create fallback CAP namespace
        HYPERDRIVE.CAP = HYPERDRIVE.CAP or {}
        HYPERDRIVE.CAP.Available = true -- Mark as available through fallback
        HYPERDRIVE.CAP.Fallback = true -- Mark as fallback system
        
        -- Fallback entity detection
        HYPERDRIVE.CAP.GetEntityCategory = function(className)
            -- Simple pattern matching for common CAP entity names
            local lowerClass = string.lower(className)
            
            if string.find(lowerClass, "stargate") or string.find(lowerClass, "gate") then
                return "STARGATES"
            elseif string.find(lowerClass, "shield") then
                return "SHIELDS"
            elseif string.find(lowerClass, "zpm") or string.find(lowerClass, "generator") or string.find(lowerClass, "power") then
                return "ENERGY_SYSTEMS"
            elseif string.find(lowerClass, "ring") or string.find(lowerClass, "transport") then
                return "TRANSPORTATION"
            end
            
            return nil
        end
        
        -- Fallback shield system
        HYPERDRIVE.CAP.Shields = HYPERDRIVE.CAP.Shields or {}
        HYPERDRIVE.CAP.Shields.FindShields = function(ship)
            -- Return virtual shields if no real ones exist
            local virtualShields = {}
            for _, vEntity in ipairs(ASC.CAP.Fallback.VirtualEntities) do
                if vEntity.type == "shield" then
                    table.insert(virtualShields, vEntity)
                end
            end
            return virtualShields
        end
        
        HYPERDRIVE.CAP.Shields.Activate = function(core, ship, reason)
            -- Create virtual shield if none exists
            if ship and ship.GetCenter then
                local center = ship:GetCenter()
                local virtualShield = ASC.CAP.Fallback.CreateVirtualEntity("shield", center, core:GetOwner())
                if virtualShield then
                    virtualShield.methods.Activate()
                    ASC.CAP.Fallback.Effects.Create("shield_activate", center)
                    return true
                end
            end
            return false
        end
        
        -- Fallback resource system
        HYPERDRIVE.CAP.Resources = HYPERDRIVE.CAP.Resources or {}
        HYPERDRIVE.CAP.Resources.FindEnergySources = function(ship)
            local virtualSources = {}
            for _, vEntity in ipairs(ASC.CAP.Fallback.VirtualEntities) do
                if vEntity.type == "energy" then
                    table.insert(virtualSources, vEntity)
                end
            end
            return virtualSources
        end
        
        print("[ASC CAP Fallback] Fallback system integrated with main CAP system")
    end
end

-- Initialize fallback system
function ASC.CAP.Fallback.Initialize()
    if not ASC.CAP.Fallback.Config.EnableFallbackSystems then
        print("[ASC CAP Fallback] Fallback systems disabled")
        return false
    end
    
    -- Integrate with main system
    ASC.CAP.Fallback.IntegrateWithMainSystem()
    
    -- Start cleanup timer
    timer.Create("ASC_CAP_Fallback_Cleanup", 60, 0, function()
        ASC.CAP.Fallback.CleanupVirtualEntities()
    end)
    
    print("[ASC CAP Fallback] Fallback system initialized")
    return true
end

-- Initialize when ready
hook.Add("Initialize", "ASC_CAP_Fallback_Init", function()
    timer.Simple(1, function()
        ASC.CAP.Fallback.Initialize()
    end)
end)

print("[Advanced Space Combat] CAP Fallback System v3.0 - Loaded")
