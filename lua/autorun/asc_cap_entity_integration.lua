-- Advanced Space Combat - CAP Entity Integration System v2.0.0
-- Comprehensive CAP asset integration for all ASC entities
-- Automatic model, material, and sound assignment based on technology

print("[Advanced Space Combat] CAP Entity Integration System v2.0.0 - Loading...")

-- Initialize CAP entity integration namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.EntityIntegration = ASC.CAP.EntityIntegration or {}

-- Enhanced entity-to-CAP mappings
ASC.CAP.EntityIntegration.EntityMappings = {
    -- Ship Core mappings with multiple technology options
    ship_core = {
        Ancient = {
            models = {"console", "console_alt", "crystal", "zpm"},
            materials = {"console", "crystal", "energy"},
            sounds = {"activation", "hum", "power_up"},
            effects = {"energy_field", "zpm_glow"}
        },
        Goauld = {
            models = {"console", "console_pyramid", "sarcophagus"},
            materials = {"console", "gold", "crystal"},
            sounds = {"activation", "hum", "power_up"},
            effects = {"energy_beam", "sarcophagus_glow"}
        },
        Asgard = {
            models = {"console", "console_hologram", "computer_core"},
            materials = {"console", "metal", "hologram"},
            sounds = {"activation", "computer", "hum"},
            effects = {"hologram_active", "energy_beam"}
        },
        Tauri = {
            models = {"console", "computer", "panel"},
            materials = {"console", "metal", "computer"},
            sounds = {"computer_startup", "computer_beep"},
            effects = {"energy_field"}
        },
        Ori = {
            models = {"console", "altar"},
            materials = {"console", "altar", "crystal"},
            sounds = {"activation", "hum"},
            effects = {"energy_beam"}
        },
        Wraith = {
            models = {"console", "cocoon"},
            materials = {"console", "organic", "metal"},
            sounds = {"activation", "organic_sound"},
            effects = {"energy_field"}
        }
    },

    -- Hyperdrive Master Engine mappings
    hyperdrive_master_engine = {
        Ancient = {
            models = {"zpm", "crystal", "platform"},
            materials = {"energy", "crystal", "metal"},
            sounds = {"power_up", "hum", "atlantis_hum"},
            effects = {"energy_field", "zpm_glow"}
        },
        Goauld = {
            models = {"console", "crystal"},
            materials = {"energy", "gold", "crystal"},
            sounds = {"power_up", "hum"},
            effects = {"energy_beam"}
        },
        Asgard = {
            models = {"computer_core", "console"},
            materials = {"energy", "metal", "crystal"},
            sounds = {"hyperdrive_activate", "computer"},
            effects = {"energy_beam"}
        },
        Tauri = {
            models = {"computer", "console"},
            materials = {"metal", "computer"},
            sounds = {"hyperdrive_activate", "computer_startup"},
            effects = {"energy_field"}
        }
    },

    -- Shield Generator mappings
    asc_shield_generator = {
        Ancient = {
            models = {"shield_generator", "shield_emitter", "crystal"},
            materials = {"shield", "shield_bubble", "energy"},
            sounds = {"shield_activate", "shield_deactivate", "hum"},
            effects = {"shield_bubble", "shield_impact"}
        },
        Goauld = {
            models = {"console", "crystal"},
            materials = {"shield", "energy", "gold"},
            sounds = {"shield_activate", "shield_impact"},
            effects = {"shield_bubble"}
        },
        Asgard = {
            models = {"shield_generator", "console"},
            materials = {"shield", "shield_generator", "metal"},
            sounds = {"shield_activate", "shield_impact"},
            effects = {"shield_bubble"}
        },
        Tauri = {
            models = {"console", "computer"},
            materials = {"shield", "metal"},
            sounds = {"shield_activate", "shield_impact"},
            effects = {"shield_bubble"}
        }
    },

    -- Weapon mappings
    asc_pulse_cannon = {
        Ancient = {
            models = {"drone_weapon", "drone_launcher", "satellite"},
            materials = {"drone", "energy", "metal"},
            sounds = {"drone_fire", "drone_launch"},
            effects = {"drone_trail", "energy_beam"}
        },
        Goauld = {
            models = {"staff_cannon", "staff_weapon"},
            materials = {"staff_weapon", "energy", "gold"},
            sounds = {"staff_fire", "staff_charge"},
            effects = {"staff_blast", "energy_beam"}
        },
        Asgard = {
            models = {"beam_weapon", "plasma_beam", "ion_cannon"},
            materials = {"beam", "energy", "metal"},
            sounds = {"beam_fire", "beam_charge"},
            effects = {"energy_beam"}
        },
        Tauri = {
            models = {"plasma_cannon", "railgun"},
            materials = {"plasma", "railgun", "metal"},
            sounds = {"plasma_fire", "railgun_fire"},
            effects = {"energy_beam"}
        }
    },

    -- Beam Weapon mappings
    asc_beam_weapon = {
        Ancient = {
            models = {"satellite", "drone_weapon"},
            materials = {"energy", "crystal"},
            sounds = {"satellite_fire", "drone_fire"},
            effects = {"satellite_beam", "energy_beam"}
        },
        Asgard = {
            models = {"beam_weapon", "plasma_beam"},
            materials = {"beam", "plasma_beam", "energy"},
            sounds = {"beam_fire", "beam_charge"},
            effects = {"energy_beam"}
        },
        Ori = {
            models = {"beam_weapon"},
            materials = {"beam", "energy"},
            sounds = {"beam_fire"},
            effects = {"energy_beam"}
        }
    }
}

-- Apply CAP assets to entity based on technology
function ASC.CAP.EntityIntegration.ApplyCAPAssets(entity, technology, assetType)
    if not IsValid(entity) then return false end
    if not ASC.CAP.Assets then return false end
    
    local entityClass = entity:GetClass()
    local mapping = ASC.CAP.EntityIntegration.EntityMappings[entityClass]
    
    if not mapping or not mapping[technology] then
        -- Try fallback technology
        technology = ASC.CAP.Enhanced and ASC.CAP.Enhanced.GetBestAvailableTechnology(entity:GetOwner()) or "Ancient"
        mapping = ASC.CAP.EntityIntegration.EntityMappings[entityClass]
        if not mapping or not mapping[technology] then
            return false
        end
    end
    
    local techMapping = mapping[technology]
    local success = false
    
    -- Apply models
    if assetType == "all" or assetType == "model" then
        if techMapping.models and #techMapping.models > 0 then
            local modelName = techMapping.models[math.random(#techMapping.models)]
            local model = ASC.CAP.Assets.GetModel(technology, modelName, entity:GetModel())
            if model and model ~= entity:GetModel() then
                entity:SetModel(model)
                success = true
                
                if ASC.CAP.Assets.Config.EnableAssetLogging then
                    print("[ASC CAP Entity] Applied " .. technology .. " model " .. modelName .. " to " .. entityClass)
                end
            end
        end
    end
    
    -- Apply materials
    if assetType == "all" or assetType == "material" then
        if techMapping.materials and #techMapping.materials > 0 then
            local materialName = techMapping.materials[math.random(#techMapping.materials)]
            local material = ASC.CAP.Assets.GetMaterial(technology, materialName, "")
            if material and material ~= "" then
                entity:SetMaterial(material)
                success = true
                
                if ASC.CAP.Assets.Config.EnableAssetLogging then
                    print("[ASC CAP Entity] Applied " .. technology .. " material " .. materialName .. " to " .. entityClass)
                end
            end
        end
    end
    
    -- Apply sounds (store for later use)
    if assetType == "all" or assetType == "sound" then
        if techMapping.sounds and #techMapping.sounds > 0 then
            entity.CAPSounds = entity.CAPSounds or {}
            entity.CAPSounds[technology] = techMapping.sounds
            success = true
        end
    end
    
    -- Apply effects (store for later use)
    if assetType == "all" or assetType == "effect" then
        if techMapping.effects and #techMapping.effects > 0 then
            entity.CAPEffects = entity.CAPEffects or {}
            entity.CAPEffects[technology] = techMapping.effects
            success = true
        end
    end
    
    return success
end

-- Get CAP sound for entity
function ASC.CAP.EntityIntegration.GetCAPSound(entity, technology, soundType, fallback)
    if not IsValid(entity) then return fallback end
    if not entity.CAPSounds or not entity.CAPSounds[technology] then return fallback end
    
    -- Find matching sound type
    for _, soundName in ipairs(entity.CAPSounds[technology]) do
        if string.find(soundName, soundType) then
            return ASC.CAP.Assets.GetSound(technology, soundName, fallback)
        end
    end
    
    -- Return first available sound as fallback
    if #entity.CAPSounds[technology] > 0 then
        local soundName = entity.CAPSounds[technology][1]
        return ASC.CAP.Assets.GetSound(technology, soundName, fallback)
    end
    
    return fallback
end

-- Play CAP sound for entity
function ASC.CAP.EntityIntegration.PlayCAPSound(entity, technology, soundType, fallback, volume, pitch)
    if not IsValid(entity) then return false end
    
    local sound = ASC.CAP.EntityIntegration.GetCAPSound(entity, technology, soundType, fallback)
    if sound and sound ~= "" then
        entity:EmitSound(sound, volume or 75, pitch or 100)
        return true
    end
    
    return false
end

-- Auto-apply CAP assets when entity spawns
function ASC.CAP.EntityIntegration.OnEntitySpawned(entity)
    if not IsValid(entity) then return end
    if not ASC.CAP.Assets or not ASC.CAP.Assets.Config.EnableCAPAssets then return end
    
    local entityClass = entity:GetClass()
    if not ASC.CAP.EntityIntegration.EntityMappings[entityClass] then return end
    
    -- Determine technology to use
    local technology = "Ancient" -- Default
    
    -- Try to get technology from owner
    local owner = entity:GetOwner()
    if IsValid(owner) and owner:IsPlayer() then
        if ASC.CAP.Enhanced then
            technology = ASC.CAP.Enhanced.GetBestAvailableTechnology(owner)
        end
    end
    
    -- Try to get technology from ship core
    local shipCore = entity.ShipCore or entity:GetNWEntity("ShipCore")
    if IsValid(shipCore) and shipCore.GetTechnology then
        technology = shipCore:GetTechnology() or technology
    end
    
    -- Apply CAP assets with slight delay to ensure entity is fully initialized
    timer.Simple(0.1, function()
        if IsValid(entity) then
            ASC.CAP.EntityIntegration.ApplyCAPAssets(entity, technology, "all")
            
            -- Store technology for later reference
            entity.CAPTechnology = technology
            entity:SetNWString("CAPTechnology", technology)
        end
    end)
end

-- Hook into entity spawning
hook.Add("OnEntityCreated", "ASC_CAP_EntityIntegration", function(entity)
    -- Small delay to ensure entity is fully created
    timer.Simple(0.05, function()
        ASC.CAP.EntityIntegration.OnEntitySpawned(entity)
    end)
end)

-- Console commands for CAP entity integration
if SERVER then
    concommand.Add("asc_cap_apply_to_entity", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        
        local trace = ply:GetEyeTrace()
        local entity = trace.Entity
        
        if not IsValid(entity) then
            ply:ChatPrint("No valid entity found")
            return
        end
        
        local technology = args[1] or "Ancient"
        local assetType = args[2] or "all"
        
        local success = ASC.CAP.EntityIntegration.ApplyCAPAssets(entity, technology, assetType)
        if success then
            ply:ChatPrint("Applied " .. technology .. " " .. assetType .. " assets to " .. entity:GetClass())
        else
            ply:ChatPrint("Failed to apply CAP assets")
        end
    end)
    
    concommand.Add("asc_cap_refresh_all_entities", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        
        local count = 0
        for _, entity in ipairs(ents.GetAll()) do
            if ASC.CAP.EntityIntegration.EntityMappings[entity:GetClass()] then
                local technology = entity.CAPTechnology or "Ancient"
                if ASC.CAP.EntityIntegration.ApplyCAPAssets(entity, technology, "all") then
                    count = count + 1
                end
            end
        end
        
        ply:ChatPrint("Refreshed CAP assets for " .. count .. " entities")
    end)
end

print("[Advanced Space Combat] CAP Entity Integration System v2.0.0 - Loaded successfully!")
