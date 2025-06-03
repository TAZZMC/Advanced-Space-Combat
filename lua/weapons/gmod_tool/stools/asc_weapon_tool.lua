-- Advanced Space Combat - Weapon Tool
-- Comprehensive weapon spawning and configuration tool

TOOL.Category = "Advanced Space Combat"
TOOL.Name = "Weapon Tool"
TOOL.Command = nil
TOOL.ConfigName = ""

-- Initialize ASC namespace if not exists
ASC = ASC or {}

-- Function to find nearest ship core
ASC.FindNearestShipCore = function(pos, owner)
    local cores = ents.FindByClass("ship_core")
    local closestCore = nil
    local closestDist = math.huge

    for _, core in ipairs(cores) do
        if IsValid(core) then
            -- Check ownership if owner is provided
            if not owner or core:GetOwner() == owner or (core.CPPIGetOwner and core:CPPIGetOwner() == owner) then
                local dist = pos:Distance(core:GetPos())
                if dist < 2000 and dist < closestDist then
                    closestCore = core
                    closestDist = dist
                end
            end
        end
    end

    return closestCore
end

TOOL.ClientConVar["weapon_type"] = "pulse_cannon"
TOOL.ClientConVar["auto_link"] = "1"
TOOL.ClientConVar["damage"] = "100"
TOOL.ClientConVar["fire_rate"] = "1"

if CLIENT then
    language.Add("tool.asc_weapon_tool.name", "Weapon Tool")
    language.Add("tool.asc_weapon_tool.desc", "Spawn and configure ship weapons")
    language.Add("tool.asc_weapon_tool.0", "Left click to spawn weapon, Right click to configure")
end

-- Get weapon model using centralized model manager
local function GetWeaponModel(weaponType)
    if ASC and ASC.Models and ASC.Models.GetModel then
        return ASC.Models.GetModel(weaponType)
    else
        -- Fallback mapping if model manager not available
        local fallbacks = {
            pulse_cannon = "models/props_c17/oildrum001_explosive.mdl",
            beam_weapon = "models/props_combine/combine_mine01.mdl",
            torpedo_launcher = "models/props_combine/combine_barricade_short01a.mdl",
            railgun = "models/props_combine/combine_barricade_med02a.mdl",
            plasma_cannon = "models/props_combine/combine_barricade_short02a.mdl"
        }
        return fallbacks[weaponType] or "models/error.mdl"
    end
end

local WeaponTypes = {
    pulse_cannon = {
        entity = "asc_pulse_cannon",
        model = GetWeaponModel("pulse_cannon"),
        name = "Pulse Cannon"
    },
    beam_weapon = {
        entity = "asc_beam_weapon",
        model = GetWeaponModel("beam_weapon"),
        name = "Beam Weapon"
    },
    torpedo_launcher = {
        entity = "asc_torpedo_launcher",
        model = GetWeaponModel("torpedo_launcher"),
        name = "Torpedo Launcher"
    },
    railgun = {
        entity = "asc_railgun",
        model = GetWeaponModel("railgun"),
        name = "Railgun"
    },
    plasma_cannon = {
        entity = "asc_plasma_cannon",
        model = GetWeaponModel("plasma_cannon"),
        name = "Plasma Cannon"
    }
}

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    local weapon_type = self:GetClientInfo("weapon_type")
    local auto_link = self:GetClientNumber("auto_link", 1) == 1
    local damage = self:GetClientNumber("damage", 100)
    local fire_rate = self:GetClientNumber("fire_rate", 1)
    
    if trace.HitSky then return false end
    
    local weaponData = WeaponTypes[weapon_type]
    if not weaponData then
        ply:ChatPrint("Invalid weapon type!")
        return false
    end
    
    -- Create weapon entity
    local ent = ents.Create(weaponData.entity)
    if not IsValid(ent) then
        ply:ChatPrint("Failed to create weapon entity!")
        return false
    end
    
    ent:SetModel(weaponData.model)
    ent:SetPos(trace.HitPos + trace.HitNormal * 30)
    ent:SetAngles(trace.HitNormal:Angle())
    ent:Spawn()
    ent:Activate()
    
    -- Set ownership
    if ent.CPPISetOwner then
        ent:CPPISetOwner(ply)
    else
        ent:SetOwner(ply)
    end
    
    -- Configure weapon
    if ent.SetDamage then
        ent:SetDamage(damage)
    end
    
    if ent.SetFireRate then
        ent:SetFireRate(fire_rate)
    end
    
    -- Auto-link to nearest ship core if enabled
    if auto_link then
        local ship_core = ASC.FindNearestShipCore(ent:GetPos(), ply)
        if IsValid(ship_core) and ent.LinkToShipCore then
            ent:LinkToShipCore(ship_core)
            ply:ChatPrint("Weapon linked to ship core: " .. (ship_core.GetShipName and ship_core:GetShipName() or "Unknown"))
        end
    end
    
    -- Add to undo
    undo.Create("Ship Weapon")
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()
    
    ply:ChatPrint(weaponData.name .. " spawned successfully!")
    
    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local ent = trace.Entity
    
    if not IsValid(ent) then
        ply:ChatPrint("Right click on a weapon to configure it!")
        return false
    end
    
    -- Check if it's a weapon entity
    local isWeapon = false
    for _, weaponData in pairs(WeaponTypes) do
        if ent:GetClass() == weaponData.entity then
            isWeapon = true
            break
        end
    end
    
    if isWeapon then
        -- Open weapon configuration menu
        ply:ChatPrint("Weapon configuration menu would open here!")
        return true
    end
    
    return false
end

function TOOL:Reload(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local ent = trace.Entity
    
    if IsValid(ent) then
        -- Check if it's a weapon entity
        for _, weaponData in pairs(WeaponTypes) do
            if ent:GetClass() == weaponData.entity then
                if ent.TestFire then
                    ent:TestFire()
                    ply:ChatPrint("Weapon test fired!")
                end
                return true
            end
        end
    end
    
    return true
end

if CLIENT then
    function TOOL.BuildCPanel(CPanel)
        CPanel:AddControl("Header", {
            Text = "Weapon Tool",
            Description = "Spawn and configure ship weapons for combat"
        })
        
        CPanel:AddControl("ComboBox", {
            MenuButton = 1,
            Folder = "asc_weapons",
            Options = {
                ["Pulse Cannon"] = {asc_weapon_tool_weapon_type = "pulse_cannon"},
                ["Beam Weapon"] = {asc_weapon_tool_weapon_type = "beam_weapon"},
                ["Torpedo Launcher"] = {asc_weapon_tool_weapon_type = "torpedo_launcher"},
                ["Railgun"] = {asc_weapon_tool_weapon_type = "railgun"},
                ["Plasma Cannon"] = {asc_weapon_tool_weapon_type = "plasma_cannon"}
            },
            CVars = {
                [0] = "asc_weapon_tool_weapon_type"
            }
        })
        
        CPanel:AddControl("CheckBox", {
            Label = "Auto-link to ship core",
            Command = "asc_weapon_tool_auto_link"
        })
        
        CPanel:AddControl("Slider", {
            Label = "Damage",
            Command = "asc_weapon_tool_damage",
            Type = "Integer",
            Min = 10,
            Max = 1000
        })
        
        CPanel:AddControl("Slider", {
            Label = "Fire Rate",
            Command = "asc_weapon_tool_fire_rate",
            Type = "Float",
            Min = 0.1,
            Max = 10
        })
        
        CPanel:AddControl("Label", {
            Text = "Left click: Spawn weapon"
        })
        
        CPanel:AddControl("Label", {
            Text = "Right click: Configure weapon"
        })
        
        CPanel:AddControl("Label", {
            Text = "Reload: Test fire weapon"
        })
    end
end
