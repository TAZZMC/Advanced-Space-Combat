-- Advanced Space Combat - Web Resource Manager v1.0.0
-- Handles downloading and caching of web-based resources for the theme system

print("[Advanced Space Combat] Web Resource Manager v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.WebResources = ASC.WebResources or {}

-- Configuration
ASC.WebResources.Config = {
    EnableWebResources = true,
    EnableResourceCaching = true,
    EnableFallbackGeneration = true,
    CacheDirectory = "asc_cache/",
    
    -- Web resource URLs (placeholder - would need actual CDN)
    ResourceURLs = {
        Fonts = {
            ["Orbitron"] = "https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&display=swap",
            ["Exo 2"] = "https://fonts.googleapis.com/css2?family=Exo+2:wght@400;600;800&display=swap",
            ["Rajdhani"] = "https://fonts.googleapis.com/css2?family=Rajdhani:wght@400;600;700&display=swap"
        },
        
        Materials = {
            ["space_background"] = "https://example.com/space_bg.jpg",
            ["starfield"] = "https://example.com/starfield.jpg",
            ["nebula"] = "https://example.com/nebula.jpg",
            ["ui_glow"] = "https://example.com/ui_glow.png"
        },
        
        Textures = {
            ["particle_star"] = "https://example.com/particle_star.png",
            ["particle_glow"] = "https://example.com/particle_glow.png",
            ["ui_border"] = "https://example.com/ui_border.png"
        }
    },
    
    -- Fallback generation settings
    FallbackGeneration = {
        EnableProceduralTextures = true,
        EnableGradientGeneration = true,
        EnablePatternGeneration = true
    }
}

-- State management
ASC.WebResources.State = {
    CachedResources = {},
    DownloadQueue = {},
    GeneratedFallbacks = {},
    LastCacheCheck = 0
}

-- Initialize web resource manager
function ASC.WebResources.Initialize()
    print("[Advanced Space Combat] Initializing web resource manager...")

    local success, err = pcall(function()
        -- Create cache directory
        ASC.WebResources.CreateCacheDirectory()

        -- Load cached resources
        ASC.WebResources.LoadCachedResources()

        -- Generate fallback resources
        ASC.WebResources.GenerateFallbackResources()
    end)

    if success then
        print("[Advanced Space Combat] Web resource manager initialized successfully")
    else
        print("[Advanced Space Combat] Web resource manager initialization failed: " .. tostring(err))
        print("[Advanced Space Combat] Using minimal fallback mode")
    end
end

-- Create cache directory
function ASC.WebResources.CreateCacheDirectory()
    if not file.Exists(ASC.WebResources.Config.CacheDirectory, "DATA") then
        file.CreateDir(ASC.WebResources.Config.CacheDirectory)
        print("[ASC Web Resources] Created cache directory: " .. ASC.WebResources.Config.CacheDirectory)
    end
end

-- Load cached resources
function ASC.WebResources.LoadCachedResources()
    local cacheFile = ASC.WebResources.Config.CacheDirectory .. "resource_cache.json"
    
    if file.Exists(cacheFile, "DATA") then
        local cacheData = file.Read(cacheFile, "DATA")
        if cacheData then
            local success, cache = pcall(util.JSONToTable, cacheData)
            if success and cache then
                ASC.WebResources.State.CachedResources = cache
                print("[ASC Web Resources] Loaded " .. table.Count(cache) .. " cached resources")
            end
        end
    end
end

-- Generate fallback resources when web resources are unavailable
function ASC.WebResources.GenerateFallbackResources()
    if not ASC.WebResources.Config.FallbackGeneration.EnableProceduralTextures then
        return
    end

    print("[ASC Web Resources] Generating fallback resources...")

    -- Generate each resource type with error handling
    local generators = {
        {"Space Background", ASC.WebResources.GenerateSpaceBackground},
        {"UI Elements", ASC.WebResources.GenerateUIElements},
        {"Particle Textures", ASC.WebResources.GenerateParticleTextures}
    }

    for _, generator in ipairs(generators) do
        local name, func = generator[1], generator[2]
        local success, err = pcall(func)

        if success then
            print("[ASC Web Resources] Generated " .. name .. " successfully")
        else
            print("[ASC Web Resources] Failed to generate " .. name .. ": " .. tostring(err))
        end
    end

    print("[ASC Web Resources] Fallback resource generation complete")
end

-- Generate procedural space background
function ASC.WebResources.GenerateSpaceBackground()
    local rt = GetRenderTarget("asc_space_background", 1024, 1024)
    
    render.PushRenderTarget(rt)
    render.Clear(5, 10, 20, 255) -- Dark space blue
    
    -- Generate stars
    for i = 1, 200 do
        local x = math.random(0, 1024)
        local y = math.random(0, 1024)
        local brightness = math.random(100, 255)
        local size = math.random(1, 3)
        
        surface.SetDrawColor(brightness, brightness, brightness, 255)
        surface.DrawRect(x, y, size, size)
    end
    
    -- Generate nebula effect
    for i = 1, 50 do
        local x = math.random(0, 1024)
        local y = math.random(0, 1024)
        local size = math.random(20, 100)
        local alpha = math.random(10, 30)
        
        surface.SetDrawColor(100, 50, 150, alpha)
        surface.DrawRect(x - size/2, y - size/2, size, size)
    end
    
    render.PopRenderTarget()
    
    -- Create material from render target
    local mat = CreateMaterial("asc_generated_space_bg", "UnlitGeneric", {
        ["$basetexture"] = rt:GetName(),
        ["$translucent"] = "0",
        ["$vertexcolor"] = "1"
    })
    
    ASC.WebResources.State.GeneratedFallbacks["space_background"] = mat
    print("[ASC Web Resources] Generated space background material")
end

-- Generate UI elements
function ASC.WebResources.GenerateUIElements()
    -- Generate glow texture
    local rt = GetRenderTarget("asc_ui_glow", 256, 256)
    
    render.PushRenderTarget(rt)
    render.Clear(0, 0, 0, 0)
    
    -- Create radial gradient glow
    local centerX, centerY = 128, 128
    local maxRadius = 128
    
    for radius = maxRadius, 1, -2 do
        local alpha = math.max(0, 255 - (radius * 2))
        surface.SetDrawColor(100, 150, 255, alpha)

        -- Create circle using polygon approximation since DrawOutlinedCircle doesn't exist
        local points = {}
        local segments = 16 -- Fewer segments for performance
        for i = 0, segments do
            local angle = (i / segments) * math.pi * 2
            local x = centerX + math.cos(angle) * radius
            local y = centerY + math.sin(angle) * radius
            table.insert(points, {x = x, y = y})
        end

        if #points > 2 then
            surface.DrawPoly(points)
        end
    end
    
    render.PopRenderTarget()
    
    local glowMat = CreateMaterial("asc_generated_ui_glow", "UnlitGeneric", {
        ["$basetexture"] = rt:GetName(),
        ["$translucent"] = "1",
        ["$vertexcolor"] = "1",
        ["$additive"] = "1"
    })
    
    ASC.WebResources.State.GeneratedFallbacks["ui_glow"] = glowMat
    print("[ASC Web Resources] Generated UI glow material")
end

-- Generate particle textures
function ASC.WebResources.GenerateParticleTextures()
    -- Generate star particle
    local rt = GetRenderTarget("asc_particle_star", 64, 64)
    
    render.PushRenderTarget(rt)
    render.Clear(0, 0, 0, 0)
    
    -- Create star shape
    local centerX, centerY = 32, 32
    local points = {
        {32, 10}, {38, 22}, {52, 22}, {42, 32},
        {46, 46}, {32, 38}, {18, 46}, {22, 32},
        {12, 22}, {26, 22}
    }
    
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawPoly(points)
    
    render.PopRenderTarget()
    
    local starMat = CreateMaterial("asc_generated_particle_star", "UnlitGeneric", {
        ["$basetexture"] = rt:GetName(),
        ["$translucent"] = "1",
        ["$vertexcolor"] = "1",
        ["$additive"] = "1"
    })
    
    ASC.WebResources.State.GeneratedFallbacks["particle_star"] = starMat
    print("[ASC Web Resources] Generated star particle material")
end

-- Get resource with fallback
function ASC.WebResources.GetResource(resourceType, resourceName)
    -- Check cached resources first
    local cacheKey = resourceType .. "_" .. resourceName
    if ASC.WebResources.State.CachedResources[cacheKey] then
        return ASC.WebResources.State.CachedResources[cacheKey]
    end
    
    -- Check generated fallbacks
    if ASC.WebResources.State.GeneratedFallbacks[resourceName] then
        return ASC.WebResources.State.GeneratedFallbacks[resourceName]
    end
    
    -- Return default fallback
    return ASC.WebResources.GetDefaultFallback(resourceType)
end

-- Get default fallback for resource type
function ASC.WebResources.GetDefaultFallback(resourceType)
    if resourceType == "material" then
        return Material("debug/debugempty")
    elseif resourceType == "texture" then
        return Material("effects/energyball")
    else
        return nil
    end
end

-- Save cache
function ASC.WebResources.SaveCache()
    local cacheFile = ASC.WebResources.Config.CacheDirectory .. "resource_cache.json"
    local cacheData = util.TableToJSON(ASC.WebResources.State.CachedResources)
    
    if cacheData then
        file.Write(cacheFile, cacheData)
        print("[ASC Web Resources] Cache saved")
    end
end

-- Console commands for debugging
if CLIENT then
    concommand.Add("asc_web_resources_debug", function()
        print("[ASC Web Resources] Debug Information:")
        print("Config exists: " .. tostring(ASC.WebResources.Config ~= nil))
        print("State exists: " .. tostring(ASC.WebResources.State ~= nil))

        if ASC.WebResources.State then
            print("Cached resources: " .. table.Count(ASC.WebResources.State.CachedResources))
            print("Generated fallbacks: " .. table.Count(ASC.WebResources.State.GeneratedFallbacks))

            print("Available fallbacks:")
            for name, resource in pairs(ASC.WebResources.State.GeneratedFallbacks) do
                print("  - " .. name .. ": " .. tostring(resource))
            end
        end
    end, nil, "Show web resource debug information")

    concommand.Add("asc_web_resources_regenerate", function()
        print("[ASC Web Resources] Regenerating fallback resources...")

        local success, err = pcall(function()
            ASC.WebResources.GenerateFallbackResources()
        end)

        if success then
            print("[ASC Web Resources] Regeneration completed successfully")
        else
            print("[ASC Web Resources] Regeneration failed: " .. tostring(err))
        end
    end, nil, "Regenerate web resource fallbacks")
end

-- Initialize on client
if CLIENT then
    hook.Add("InitPostEntity", "ASC_WebResources_Init", function()
        timer.Simple(2, function()
            local success, err = pcall(function()
                ASC.WebResources.Initialize()
            end)

            if not success then
                print("[Advanced Space Combat] Web Resource Manager initialization failed: " .. tostring(err))
            end
        end)
    end)
end

print("[Advanced Space Combat] Web Resource Manager v1.0.0 - Loaded")
