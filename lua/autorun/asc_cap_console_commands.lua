-- Advanced Space Combat - CAP Console Commands v2.0.0
-- Comprehensive console commands for managing enhanced CAP integration
-- Steam Workshop ID: 180077636 asset management and configuration

print("[Advanced Space Combat] CAP Console Commands v2.0.0 - Loading...")

-- Initialize console commands namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.Commands = ASC.CAP.Commands or {}

-- Console command registration
if SERVER then
    -- Enhanced CAP status command
    concommand.Add("asc_cap_enhanced_status", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        print("================================================================================")
        print("=== Advanced Space Combat - Enhanced CAP Integration Status ===")
        print("================================================================================")
        
        -- Basic CAP integration status
        if ASC and ASC.CAP and ASC.CAP.Assets then
            local detection = ASC.CAP.Assets.DetectCAP()
            print("CAP Asset System: Available")
            print("CAP Integration: " .. (detection.available and "Active" or "Inactive"))
            print("Models Available: " .. detection.models)
            print("Materials Available: " .. detection.materials)
            print("Sounds Available: " .. detection.sounds)
            print("Version: " .. detection.version)
        else
            print("CAP Asset System: Not Available")
        end
        
        print("--------------------------------------------------------------------------------")
        
        -- Enhanced CAP integration status
        if ASC.CAP.Enhanced then
            print("Enhanced CAP Integration: Available")
            print("Dynamic Technology Selection: " .. tostring(ASC.CAP.Enhanced.Config.EnableDynamicTechnologySelection))
            print("Technology Progression: " .. tostring(ASC.CAP.Enhanced.Config.EnableTechnologyProgression))
            print("Asset Preview: " .. tostring(ASC.CAP.Enhanced.Config.EnableAssetPreview))
            print("Asset Caching: " .. tostring(ASC.CAP.Enhanced.Config.EnableAssetCaching))
        else
            print("Enhanced CAP Integration: Not Available")
        end
        
        print("--------------------------------------------------------------------------------")
        
        -- Entity integration status
        if ASC.CAP.EntityIntegration then
            local entityCount = 0
            for class, _ in pairs(ASC.CAP.EntityIntegration.EntityMappings) do
                entityCount = entityCount + 1
            end
            print("Entity Integration: Available")
            print("Supported Entity Types: " .. entityCount)
        else
            print("Entity Integration: Not Available")
        end
        
        print("--------------------------------------------------------------------------------")
        
        -- Effects system status
        if ASC.CAP.Effects then
            local techCount = 0
            for tech, _ in pairs(ASC.CAP.Effects.TechnologyEffects) do
                techCount = techCount + 1
            end
            print("Effects System: Available")
            print("Technology Effects: " .. techCount .. " technologies")
            print("Effect Quality: " .. (ASC.CAP.Effects.Config.EffectQuality or "unknown"))
        else
            print("Effects System: Not Available")
        end
        
        print("--------------------------------------------------------------------------------")
        
        -- Weapons integration status
        if ASC.CAP.Weapons then
            local weaponCount = 0
            for tech, weapons in pairs(ASC.CAP.Weapons.TechnologyWeapons) do
                for weapon, _ in pairs(weapons) do
                    weaponCount = weaponCount + 1
                end
            end
            print("Weapons Integration: Available")
            print("Technology Weapons: " .. weaponCount .. " configurations")
        else
            print("Weapons Integration: Not Available")
        end
        
        print("================================================================================")
        
        -- Player-specific information
        if IsValid(ply) then
            print("=== Player Information ===")
            if ASC.CAP.Enhanced then
                local level = ASC.CAP.Enhanced.GetPlayerTechnologyLevel(ply)
                local bestTech = ASC.CAP.Enhanced.GetBestAvailableTechnology(ply)
                print("Player Level: " .. level)
                print("Best Available Technology: " .. bestTech)
                
                local steamID = ply:SteamID()
                local progression = ASC.CAP.Enhanced.TechnologyProgression.PlayerProgression[steamID]
                if progression then
                    print("Unlocked Technologies: " .. table.concat(progression.unlockedTechnologies, ", "))
                    print("Play Time: " .. math.floor(progression.playTime / 60) .. " minutes")
                end
            end
            print("================================================================================")
        end
    end)
    
    -- Technology management commands
    concommand.Add("asc_cap_set_technology", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        local technology = args[1]
        if not technology then
            ply:ChatPrint("Usage: asc_cap_set_technology <technology>")
            ply:ChatPrint("Available: Ancient, Goauld, Asgard, Tauri, Ori, Wraith")
            return
        end
        
        local trace = ply:GetEyeTrace()
        local entity = trace.Entity
        
        if not IsValid(entity) then
            ply:ChatPrint("No valid entity found")
            return
        end
        
        -- Apply technology to entity
        if entity.SetTechnology then
            entity:SetTechnology(technology)
            ply:ChatPrint("Set " .. entity:GetClass() .. " technology to " .. technology)
        elseif ASC.CAP.EntityIntegration then
            local success = ASC.CAP.EntityIntegration.ApplyCAPAssets(entity, technology, "all")
            if success then
                ply:ChatPrint("Applied " .. technology .. " assets to " .. entity:GetClass())
            else
                ply:ChatPrint("Failed to apply technology assets")
            end
        else
            ply:ChatPrint("Entity does not support technology setting")
        end
    end)
    
    -- Asset testing commands
    concommand.Add("asc_cap_test_assets", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        local technology = args[1] or "Ancient"
        local assetType = args[2] or "all"
        
        print("Testing CAP assets for technology: " .. technology)
        
        if ASC.CAP.Assets then
            local models = ASC.CAP.Assets.Models[technology]
            local materials = ASC.CAP.Assets.Materials[technology]
            local sounds = ASC.CAP.Assets.Sounds[technology]
            
            if models then
                print("Models available: " .. table.Count(models))
                for name, path in pairs(models) do
                    local exists = file.Exists(path, "GAME")
                    print("  " .. name .. ": " .. path .. " (" .. (exists and "EXISTS" or "MISSING") .. ")")
                end
            end
            
            if materials then
                print("Materials available: " .. table.Count(materials))
                for name, path in pairs(materials) do
                    local fullPath = "materials/" .. path .. ".vmt"
                    local exists = file.Exists(fullPath, "GAME")
                    print("  " .. name .. ": " .. fullPath .. " (" .. (exists and "EXISTS" or "MISSING") .. ")")
                end
            end
            
            if sounds then
                print("Sounds available: " .. table.Count(sounds))
                for name, path in pairs(sounds) do
                    local fullPath = "sound/" .. path
                    local exists = file.Exists(fullPath, "GAME")
                    print("  " .. name .. ": " .. fullPath .. " (" .. (exists and "EXISTS" or "MISSING") .. ")")
                end
            end
        end
        
        if IsValid(ply) then
            ply:ChatPrint("CAP asset test completed for " .. technology .. " - check console for details")
        end
    end)
    
    -- Bulk entity operations
    concommand.Add("asc_cap_apply_to_all", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        local technology = args[1] or "Ancient"
        local entityClass = args[2]
        
        local count = 0
        for _, entity in ipairs(ents.GetAll()) do
            if IsValid(entity) then
                local shouldApply = false
                
                if entityClass then
                    shouldApply = entity:GetClass() == entityClass
                else
                    shouldApply = ASC.CAP.EntityIntegration and ASC.CAP.EntityIntegration.EntityMappings[entity:GetClass()]
                end
                
                if shouldApply then
                    if entity.SetTechnology then
                        entity:SetTechnology(technology)
                        count = count + 1
                    elseif ASC.CAP.EntityIntegration then
                        if ASC.CAP.EntityIntegration.ApplyCAPAssets(entity, technology, "all") then
                            count = count + 1
                        end
                    end
                end
            end
        end
        
        if IsValid(ply) then
            ply:ChatPrint("Applied " .. technology .. " technology to " .. count .. " entities")
        end
        print("Applied " .. technology .. " technology to " .. count .. " entities")
    end)
    
    -- Effect testing commands
    concommand.Add("asc_cap_test_effects", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        local technology = args[1] or "Ancient"
        local effectType = args[2] or "activation"
        
        if ASC.CAP.Effects then
            ASC.CAP.Effects.CreateParticleEffect(ply, technology, effectType, 5)
            ply:ChatPrint("Created " .. technology .. " " .. effectType .. " effect")
        else
            ply:ChatPrint("CAP Effects system not available")
        end
    end)
    
    -- Asset cache management
    concommand.Add("asc_cap_clear_cache", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        if ASC.CAP.Enhanced and ASC.CAP.Enhanced.AssetManager then
            ASC.CAP.Enhanced.AssetManager.AssetCache = {
                models = {},
                materials = {},
                sounds = {},
                effects = {}
            }
            print("CAP asset cache cleared")
            if IsValid(ply) then
                ply:ChatPrint("CAP asset cache cleared")
            end
        end
    end)
    
    -- Technology progression commands
    concommand.Add("asc_cap_unlock_technology", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        local targetPlayer = ply
        local technology = args[1]
        
        if args[2] then
            targetPlayer = player.GetByName(args[2])
            if not IsValid(targetPlayer) then
                ply:ChatPrint("Player not found: " .. args[2])
                return
            end
        end
        
        if not technology then
            ply:ChatPrint("Usage: asc_cap_unlock_technology <technology> [player]")
            ply:ChatPrint("Available: Ancient, Goauld, Asgard, Tauri, Ori, Wraith")
            return
        end
        
        if ASC.CAP.Enhanced then
            local success = ASC.CAP.Enhanced.UnlockTechnology(targetPlayer, technology)
            if success then
                ply:ChatPrint("Unlocked " .. technology .. " technology for " .. targetPlayer:Name())
            else
                ply:ChatPrint("Technology already unlocked or invalid")
            end
        end
    end)
    
    -- Help command
    concommand.Add("asc_cap_help", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        print("================================================================================")
        print("=== Advanced Space Combat - CAP Console Commands Help ===")
        print("================================================================================")
        print("asc_cap_enhanced_status          - Show comprehensive CAP integration status")
        print("asc_cap_set_technology <tech>    - Set technology for entity you're looking at")
        print("asc_cap_test_assets <tech>       - Test asset availability for technology")
        print("asc_cap_apply_to_all <tech> [class] - Apply technology to all entities")
        print("asc_cap_test_effects <tech> <type> - Test particle effects")
        print("asc_cap_clear_cache              - Clear asset cache")
        print("asc_cap_unlock_technology <tech> [player] - Unlock technology for player")
        print("asc_cap_help                     - Show this help")
        print("================================================================================")
        print("Available Technologies: Ancient, Goauld, Asgard, Tauri, Ori, Wraith")
        print("Effect Types: activation, power_surge, energy_field, shield_bubble, teleport")
        print("================================================================================")
        
        if IsValid(ply) then
            ply:ChatPrint("CAP console commands help printed to console")
        end
    end)
end

print("[Advanced Space Combat] CAP Console Commands v2.0.0 - Loaded successfully!")
