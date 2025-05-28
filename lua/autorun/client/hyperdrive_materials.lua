-- Hyperdrive Materials System
-- Handles material loading and caching for hyperdrive effects

if SERVER then return end

-- Initialize materials system
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.Materials = HYPERDRIVE.Materials or {}

-- Material cache
local materialCache = {}

-- Default materials for hyperdrive effects
local defaultMaterials = {
    -- Engine effects
    ["engine_glow"] = "effects/energyball",
    ["engine_core"] = "sprites/light_glow02_add",
    ["engine_beam"] = "effects/laser1",
    
    -- Jump effects
    ["jump_portal"] = "effects/energyball",
    ["jump_flash"] = "sprites/light_glow02_add",
    ["jump_ring"] = "effects/select_ring",
    
    -- Hyperspace effects
    ["hyperspace_tunnel"] = "effects/energyball",
    ["hyperspace_stream"] = "effects/laser1",
    ["hyperspace_star"] = "sprites/light_glow02_add",
    
    -- UI materials
    ["ui_background"] = "vgui/gradient-d",
    ["ui_button"] = "vgui/gradient-u",
    ["ui_panel"] = "vgui/gradient-d",
    
    -- Particle effects
    ["particle_energy"] = "effects/energyball",
    ["particle_spark"] = "effects/spark",
    ["particle_smoke"] = "particle/smokesprites_0001",
    
    -- Beam effects
    ["beam_main"] = "effects/laser1",
    ["beam_secondary"] = "sprites/physbeam",
    ["beam_charge"] = "effects/energyball",
    
    -- Screen effects
    ["screen_distortion"] = "effects/strider_pinch_dudv",
    ["screen_overlay"] = "effects/combinemuzzle2_dark",
    ["screen_flash"] = "sprites/light_glow02_add"
}

-- Load and cache a material
function HYPERDRIVE.Materials.Get(name)
    -- Check cache first
    if materialCache[name] then
        return materialCache[name]
    end
    
    -- Get material path
    local materialPath = defaultMaterials[name]
    if not materialPath then
        -- Fallback to default material
        materialPath = "effects/energyball"
        print("[Hyperdrive Materials] Warning: Unknown material '" .. name .. "', using fallback")
    end
    
    -- Load and cache material
    local material = Material(materialPath)
    materialCache[name] = material
    
    return material
end

-- Preload all default materials
function HYPERDRIVE.Materials.PreloadAll()
    print("[Hyperdrive Materials] Preloading materials...")
    
    local loaded = 0
    for name, path in pairs(defaultMaterials) do
        HYPERDRIVE.Materials.Get(name)
        loaded = loaded + 1
    end
    
    print("[Hyperdrive Materials] Preloaded " .. loaded .. " materials")
end

-- Clear material cache
function HYPERDRIVE.Materials.ClearCache()
    materialCache = {}
    print("[Hyperdrive Materials] Cache cleared")
end

-- Add custom material
function HYPERDRIVE.Materials.AddCustom(name, path)
    if not name or not path then return false end
    
    defaultMaterials[name] = path
    
    -- Remove from cache to force reload
    if materialCache[name] then
        materialCache[name] = nil
    end
    
    return true
end

-- Get material info
function HYPERDRIVE.Materials.GetInfo(name)
    local path = defaultMaterials[name]
    local cached = materialCache[name] ~= nil
    
    return {
        name = name,
        path = path,
        cached = cached,
        exists = path ~= nil
    }
end

-- List all available materials
function HYPERDRIVE.Materials.ListAll()
    local materials = {}
    for name, path in pairs(defaultMaterials) do
        table.insert(materials, {
            name = name,
            path = path,
            cached = materialCache[name] ~= nil
        })
    end
    return materials
end

-- Validate material exists
function HYPERDRIVE.Materials.Validate(name)
    local path = defaultMaterials[name]
    if not path then return false end
    
    -- Try to load the material
    local success, material = pcall(Material, path)
    return success and material and not material:IsError()
end

-- Get fallback material
function HYPERDRIVE.Materials.GetFallback()
    return Material("effects/energyball")
end

-- Material quality settings
HYPERDRIVE.Materials.Quality = {
    LOW = 1,
    MEDIUM = 2,
    HIGH = 3
}

-- Set material quality (affects which materials are loaded)
function HYPERDRIVE.Materials.SetQuality(quality)
    HYPERDRIVE.Materials.CurrentQuality = quality or HYPERDRIVE.Materials.Quality.HIGH
    
    -- Clear cache to force reload with new quality
    HYPERDRIVE.Materials.ClearCache()
    
    print("[Hyperdrive Materials] Quality set to " .. HYPERDRIVE.Materials.CurrentQuality)
end

-- Get material with quality consideration
function HYPERDRIVE.Materials.GetQuality(name)
    local quality = HYPERDRIVE.Materials.CurrentQuality or HYPERDRIVE.Materials.Quality.HIGH
    
    -- For low quality, use simpler materials
    if quality == HYPERDRIVE.Materials.Quality.LOW then
        if name == "jump_portal" or name == "hyperspace_tunnel" then
            return HYPERDRIVE.Materials.Get("engine_glow")
        end
    end
    
    return HYPERDRIVE.Materials.Get(name)
end

-- Initialize default quality
HYPERDRIVE.Materials.SetQuality(HYPERDRIVE.Materials.Quality.HIGH)

-- Console commands for debugging
concommand.Add("hyperdrive_materials_list", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local materials = HYPERDRIVE.Materials.ListAll()
    ply:ChatPrint("[Hyperdrive Materials] Available materials:")
    
    for _, mat in ipairs(materials) do
        local status = mat.cached and "CACHED" or "NOT CACHED"
        ply:ChatPrint("  " .. mat.name .. " -> " .. mat.path .. " (" .. status .. ")")
    end
end)

concommand.Add("hyperdrive_materials_preload", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    HYPERDRIVE.Materials.PreloadAll()
    ply:ChatPrint("[Hyperdrive Materials] All materials preloaded")
end)

concommand.Add("hyperdrive_materials_clear", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    HYPERDRIVE.Materials.ClearCache()
    ply:ChatPrint("[Hyperdrive Materials] Material cache cleared")
end)

concommand.Add("hyperdrive_materials_quality", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local quality = tonumber(args[1])
    if quality and quality >= 1 and quality <= 3 then
        HYPERDRIVE.Materials.SetQuality(quality)
        ply:ChatPrint("[Hyperdrive Materials] Quality set to " .. quality)
    else
        ply:ChatPrint("[Hyperdrive Materials] Usage: hyperdrive_materials_quality <1-3>")
        ply:ChatPrint("  1 = Low, 2 = Medium, 3 = High")
    end
end)

-- Auto-preload materials on initialization
timer.Simple(1, function()
    HYPERDRIVE.Materials.PreloadAll()
end)

print("[Hyperdrive] Materials system loaded")
