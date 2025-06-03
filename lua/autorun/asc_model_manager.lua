-- Advanced Space Combat - Model Manager
-- Centralized model management with fallback system

ASC = ASC or {}
ASC.Models = ASC.Models or {}

-- Model registry with primary and fallback models
ASC.Models.Registry = {
    -- Core entities (these exist)
    ship_core = {
        primary = "models/asc/ship_core.mdl",
        fallback = "models/props_lab/monitor01b.mdl"
    },
    hyperdrive_engine = {
        primary = "models/asc/hyperdrive_engine.mdl", 
        fallback = "models/props_combine/combine_generator01.mdl"
    },
    
    -- Weapons (missing - use fallbacks)
    pulse_cannon = {
        primary = "models/asc/weapons/pulse_cannon.mdl",
        fallback = "models/props_c17/oildrum001_explosive.mdl"
    },
    beam_weapon = {
        primary = "models/asc/weapons/beam_weapon.mdl",
        fallback = "models/props_combine/combine_mine01.mdl"
    },
    torpedo_launcher = {
        primary = "models/asc/weapons/torpedo_launcher.mdl",
        fallback = "models/props_combine/combine_barricade_short01a.mdl"
    },
    railgun = {
        primary = "models/asc/weapons/railgun.mdl",
        fallback = "models/props_combine/combine_barricade_med02a.mdl"
    },
    plasma_cannon = {
        primary = "models/asc/weapons/plasma_cannon.mdl",
        fallback = "models/props_combine/combine_barricade_short02a.mdl"
    },
    
    -- Systems (missing - use fallbacks)
    shield_generator = {
        primary = "models/asc/systems/shield_generator.mdl",
        fallback = "models/props_combine/combine_generator01.mdl"
    },
    flight_console = {
        primary = "models/asc/systems/flight_console.mdl",
        fallback = "models/props_lab/monitor02.mdl"
    },
    docking_pad = {
        primary = "models/asc/systems/docking_pad.mdl",
        fallback = "models/props_c17/concrete_barrier001a.mdl"
    },
    shuttle = {
        primary = "models/asc/systems/shuttle.mdl",
        fallback = "models/props_vehicles/airboat.mdl"
    }
}

-- Get the appropriate model for an entity type
function ASC.Models.GetModel(entityType)
    local modelData = ASC.Models.Registry[entityType]
    if not modelData then
        print("[ASC Models] Warning: No model data for entity type: " .. tostring(entityType))
        return "models/error.mdl"
    end
    
    -- Check if primary model exists
    if util.IsValidModel(modelData.primary) then
        return modelData.primary
    else
        print("[ASC Models] Primary model missing for " .. entityType .. ", using fallback: " .. modelData.fallback)
        return modelData.fallback
    end
end

-- Check if a model exists and is valid
function ASC.Models.IsModelAvailable(modelPath)
    return util.IsValidModel(modelPath)
end

-- Get model status for debugging
function ASC.Models.GetModelStatus(entityType)
    local modelData = ASC.Models.Registry[entityType]
    if not modelData then
        return "UNKNOWN"
    end
    
    local primaryExists = util.IsValidModel(modelData.primary)
    local fallbackExists = util.IsValidModel(modelData.fallback)
    
    if primaryExists then
        return "PRIMARY_AVAILABLE"
    elseif fallbackExists then
        return "FALLBACK_ONLY"
    else
        return "NO_MODELS"
    end
end

-- Print model status report
function ASC.Models.PrintStatusReport()
    print("\n[ASC Models] Model Status Report:")
    print("================================")
    
    for entityType, _ in pairs(ASC.Models.Registry) do
        local status = ASC.Models.GetModelStatus(entityType)
        local model = ASC.Models.GetModel(entityType)
        print(string.format("%-20s: %-20s (%s)", entityType, status, model))
    end
    
    print("================================\n")
end

-- Initialize model checking
hook.Add("Initialize", "ASC_ModelManager_Init", function()
    timer.Simple(1, function()
        print("[ASC Models] Model Manager initialized")
        if GetConVar("developer"):GetInt() > 0 then
            ASC.Models.PrintStatusReport()
        end
    end)
end)

-- Console command for model status
if SERVER then
    concommand.Add("asc_model_status", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then
            ply:ChatPrint("You must be an admin to use this command.")
            return
        end
        
        ASC.Models.PrintStatusReport()
    end, nil, "Print ASC model status report")
end

print("[ASC Models] Model Manager loaded")
