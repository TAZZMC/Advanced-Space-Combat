-- Advanced Space Combat - Enhanced CAP Integration System v2.0.0
-- Dynamic technology selection, asset management, and advanced CAP features
-- Steam Workshop ID: 180077636 - Complete integration with all 32 CAP components

print("[Advanced Space Combat] Enhanced CAP Integration System v2.0.0 - Loading...")

-- Initialize enhanced CAP namespace
ASC = ASC or {}
ASC.CAP = ASC.CAP or {}
ASC.CAP.Enhanced = ASC.CAP.Enhanced or {}

-- Enhanced CAP Configuration
ASC.CAP.Enhanced.Config = {
    -- Core settings
    EnableEnhancedIntegration = true,
    EnableDynamicTechnologySelection = true,
    EnableAssetPreview = true,
    EnableTechnologyProgression = true,
    EnableRandomization = true,
    
    -- Asset management
    EnableAssetCaching = true,
    EnableAssetValidation = true,
    EnableFallbackChaining = true,
    EnableAssetLogging = true,
    
    -- Technology preferences
    DefaultTechnology = "Ancient",
    AllowTechnologyMixing = true,
    EnableTechnologyUpgrades = true,
    
    -- Performance settings
    AssetCacheSize = 1000,
    ValidationInterval = 30,
    PreloadAssets = true
}

-- Technology Progression System
ASC.CAP.Enhanced.TechnologyProgression = {
    -- Technology tiers (1-5, 5 being most advanced)
    TechnologyTiers = {
        Tauri = 2,      -- Earth technology - basic
        Goauld = 3,     -- Goa'uld technology - intermediate
        Asgard = 4,     -- Asgard technology - advanced
        Ancient = 5,    -- Ancient technology - most advanced
        Ori = 5,        -- Ori technology - most advanced
        Wraith = 3      -- Wraith technology - intermediate
    },
    
    -- Unlock requirements (based on player achievements, time, etc.)
    UnlockRequirements = {
        Tauri = {level = 0, time = 0},
        Goauld = {level = 5, time = 300},      -- 5 minutes
        Wraith = {level = 10, time = 600},     -- 10 minutes
        Asgard = {level = 20, time = 1200},    -- 20 minutes
        Ancient = {level = 30, time = 1800},   -- 30 minutes
        Ori = {level = 40, time = 2400}        -- 40 minutes
    },
    
    -- Player progression tracking
    PlayerProgression = {}
}

-- Dynamic Technology Selection System
ASC.CAP.Enhanced.TechnologySelector = {
    -- Available selection modes
    SelectionModes = {
        MANUAL = "manual",           -- Player selects technology
        AUTOMATIC = "automatic",     -- System selects based on progression
        RANDOM = "random",          -- Random technology selection
        MIXED = "mixed",            -- Mix of technologies
        PROGRESSIVE = "progressive"  -- Unlock technologies over time
    },
    
    -- Current selection mode per player
    PlayerSelectionModes = {},
    
    -- Technology preferences per player
    PlayerTechnologyPreferences = {}
}

-- Enhanced Asset Management System
ASC.CAP.Enhanced.AssetManager = {
    -- Asset cache for performance
    AssetCache = {
        models = {},
        materials = {},
        sounds = {},
        effects = {}
    },
    
    -- Asset validation results
    ValidationResults = {
        models = {},
        materials = {},
        sounds = {},
        effects = {}
    },
    
    -- Fallback chains for missing assets
    FallbackChains = {
        models = {
            "Ancient", "Asgard", "Tauri", "Goauld", "Wraith", "Ori"
        },
        materials = {
            "Ancient", "Asgard", "Tauri", "Goauld", "Wraith", "Ori"
        },
        sounds = {
            "Ancient", "Asgard", "Tauri", "Goauld", "Wraith", "Ori"
        }
    }
}

-- Get player's current technology level
function ASC.CAP.Enhanced.GetPlayerTechnologyLevel(player)
    if not IsValid(player) then return 0 end
    
    local steamID = player:SteamID()
    local progression = ASC.CAP.Enhanced.TechnologyProgression.PlayerProgression[steamID]
    
    if not progression then
        -- Initialize new player progression
        progression = {
            level = 0,
            experience = 0,
            playTime = 0,
            unlockedTechnologies = {"Tauri"},
            preferredTechnology = "Tauri"
        }
        ASC.CAP.Enhanced.TechnologyProgression.PlayerProgression[steamID] = progression
    end
    
    return progression.level
end

-- Check if player has unlocked a technology
function ASC.CAP.Enhanced.IsTechnologyUnlocked(player, technology)
    if not IsValid(player) then return false end
    
    local steamID = player:SteamID()
    local progression = ASC.CAP.Enhanced.TechnologyProgression.PlayerProgression[steamID]
    
    if not progression then return false end
    
    return table.HasValue(progression.unlockedTechnologies, technology)
end

-- Unlock technology for player
function ASC.CAP.Enhanced.UnlockTechnology(player, technology)
    if not IsValid(player) then return false end
    
    local steamID = player:SteamID()
    local progression = ASC.CAP.Enhanced.TechnologyProgression.PlayerProgression[steamID]
    
    if not progression then return false end
    
    if not table.HasValue(progression.unlockedTechnologies, technology) then
        table.insert(progression.unlockedTechnologies, technology)
        
        -- Notify player
        if SERVER then
            player:ChatPrint("[Advanced Space Combat] Technology unlocked: " .. technology)
            player:EmitSound("buttons/button15.wav", 75, 120)
        end
        
        return true
    end
    
    return false
end

-- Get best available technology for player
function ASC.CAP.Enhanced.GetBestAvailableTechnology(player)
    if not IsValid(player) then return "Tauri" end
    
    local steamID = player:SteamID()
    local progression = ASC.CAP.Enhanced.TechnologyProgression.PlayerProgression[steamID]
    
    if not progression then return "Tauri" end
    
    -- Find highest tier unlocked technology
    local bestTech = "Tauri"
    local bestTier = 0
    
    for _, tech in ipairs(progression.unlockedTechnologies) do
        local tier = ASC.CAP.Enhanced.TechnologyProgression.TechnologyTiers[tech] or 0
        if tier > bestTier then
            bestTier = tier
            bestTech = tech
        end
    end
    
    return bestTech
end

-- Enhanced asset retrieval with fallback chains
function ASC.CAP.Enhanced.GetAssetWithFallback(assetType, technology, assetName, fallback)
    if not ASC.CAP.Assets then return fallback end
    
    -- Try primary technology first
    local primaryAsset = ASC.CAP.Assets.GetAsset(assetType, technology, assetName)
    if primaryAsset and primaryAsset ~= fallback then
        return primaryAsset
    end
    
    -- Try fallback chain
    local fallbackChain = ASC.CAP.Enhanced.AssetManager.FallbackChains[assetType]
    if fallbackChain then
        for _, fallbackTech in ipairs(fallbackChain) do
            if fallbackTech ~= technology then
                local fallbackAsset = ASC.CAP.Assets.GetAsset(assetType, fallbackTech, assetName)
                if fallbackAsset and fallbackAsset ~= fallback then
                    if ASC.CAP.Enhanced.Config.EnableAssetLogging then
                        print("[ASC CAP Enhanced] Using fallback " .. fallbackTech .. " " .. assetType .. " for " .. assetName)
                    end
                    return fallbackAsset
                end
            end
        end
    end
    
    return fallback
end

-- Technology selection UI for players
function ASC.CAP.Enhanced.OpenTechnologySelector(player)
    if not IsValid(player) or not player:IsPlayer() then return end
    
    -- Send technology selection data to client
    if SERVER then
        local steamID = player:SteamID()
        local progression = ASC.CAP.Enhanced.TechnologyProgression.PlayerProgression[steamID]
        
        net.Start("ASC_CAP_TechnologySelector")
        net.WriteTable(progression.unlockedTechnologies)
        net.WriteString(progression.preferredTechnology)
        net.Send(player)
    end
end

-- Update player progression
function ASC.CAP.Enhanced.UpdatePlayerProgression(player)
    if not IsValid(player) or not player:IsPlayer() then return end
    
    local steamID = player:SteamID()
    local progression = ASC.CAP.Enhanced.TechnologyProgression.PlayerProgression[steamID]
    
    if not progression then return end
    
    -- Update play time
    progression.playTime = progression.playTime + 1
    
    -- Check for technology unlocks
    for tech, requirements in pairs(ASC.CAP.Enhanced.TechnologyProgression.UnlockRequirements) do
        if not table.HasValue(progression.unlockedTechnologies, tech) then
            if progression.level >= requirements.level and progression.playTime >= requirements.time then
                ASC.CAP.Enhanced.UnlockTechnology(player, tech)
            end
        end
    end
end

-- Initialize enhanced CAP integration
function ASC.CAP.Enhanced.Initialize()
    print("[ASC CAP Enhanced] Initializing Enhanced CAP Integration System...")
    
    -- Set up networking
    if SERVER then
        util.AddNetworkString("ASC_CAP_TechnologySelector")
        util.AddNetworkString("ASC_CAP_SetTechnology")
        util.AddNetworkString("ASC_CAP_ProgressionUpdate")
        
        -- Player progression update timer
        timer.Create("ASC_CAP_ProgressionUpdate", 60, 0, function()
            for _, player in ipairs(player.GetAll()) do
                ASC.CAP.Enhanced.UpdatePlayerProgression(player)
            end
        end)
    end
    
    print("[ASC CAP Enhanced] Enhanced CAP Integration System initialized successfully!")
end

-- Console commands for enhanced CAP system
if SERVER then
    concommand.Add("asc_cap_enhanced_status", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        print("=== Advanced Space Combat - Enhanced CAP Integration Status ===")
        print("Enhanced Integration: " .. tostring(ASC.CAP.Enhanced.Config.EnableEnhancedIntegration))
        print("Dynamic Technology Selection: " .. tostring(ASC.CAP.Enhanced.Config.EnableDynamicTechnologySelection))
        print("Technology Progression: " .. tostring(ASC.CAP.Enhanced.Config.EnableTechnologyProgression))
        
        if IsValid(ply) then
            local level = ASC.CAP.Enhanced.GetPlayerTechnologyLevel(ply)
            local bestTech = ASC.CAP.Enhanced.GetBestAvailableTechnology(ply)
            print("Player Level: " .. level)
            print("Best Available Technology: " .. bestTech)
        end
    end)
    
    concommand.Add("asc_cap_unlock_all", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then return end
        
        if IsValid(ply) then
            for tech, _ in pairs(ASC.CAP.Enhanced.TechnologyProgression.TechnologyTiers) do
                ASC.CAP.Enhanced.UnlockTechnology(ply, tech)
            end
            ply:ChatPrint("All technologies unlocked!")
        end
    end)
end

-- Initialize when CAP assets are available
hook.Add("Initialize", "ASC_CAP_Enhanced_Init", function()
    timer.Simple(2, function()
        ASC.CAP.Enhanced.Initialize()
    end)
end)

print("[Advanced Space Combat] Enhanced CAP Integration System v2.0.0 - Loaded successfully!")
