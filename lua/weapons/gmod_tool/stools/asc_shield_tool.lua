-- Advanced Space Combat - Shield Tool
-- CAP-integrated shield spawning and configuration tool

TOOL.Category = "Advanced Space Combat"
TOOL.Name = "Shield Tool"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["shield_type"] = "bubble"
TOOL.ClientConVar["auto_link"] = "1"
TOOL.ClientConVar["shield_strength"] = "100"
TOOL.ClientConVar["shield_radius"] = "500"

if CLIENT then
    language.Add("tool.asc_shield_tool.name", "Shield Tool")
    language.Add("tool.asc_shield_tool.desc", "Spawn and configure CAP-integrated shields")
    language.Add("tool.asc_shield_tool.0", "Left click to spawn shield, Right click to configure")
end

local ShieldTypes = {
    bubble = {
        entity = "asc_shield_generator",
        model = "models/asc/shield_generator.mdl",
        name = "Bubble Shield"
    },
    iris = {
        entity = "asc_iris_shield",
        model = "models/asc/iris_shield.mdl",
        name = "Iris Shield"
    },
    asgard = {
        entity = "asc_asgard_shield",
        model = "models/asc/asgard_shield.mdl",
        name = "Asgard Shield"
    }
}

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    local shield_type = self:GetClientInfo("shield_type")
    local auto_link = self:GetClientNumber("auto_link", 1) == 1
    local shield_strength = self:GetClientNumber("shield_strength", 100)
    local shield_radius = self:GetClientNumber("shield_radius", 500)
    
    if trace.HitSky then return false end
    
    local shieldData = ShieldTypes[shield_type]
    if not shieldData then
        ply:ChatPrint("Invalid shield type!")
        return false
    end
    
    -- Create shield entity
    local ent = ents.Create(shieldData.entity)
    if not IsValid(ent) then
        ply:ChatPrint("Failed to create shield entity!")
        return false
    end
    
    ent:SetModel(shieldData.model)
    ent:SetPos(trace.HitPos + trace.HitNormal * 40)
    ent:SetAngles(Angle(0, ply:EyeAngles().y, 0))
    ent:Spawn()
    ent:Activate()
    
    -- Set ownership
    if ent.CPPISetOwner then
        ent:CPPISetOwner(ply)
    else
        ent:SetOwner(ply)
    end
    
    -- Configure shield
    if ent.SetShieldStrength then
        ent:SetShieldStrength(shield_strength)
    end
    
    if ent.SetShieldRadius then
        ent:SetShieldRadius(shield_radius)
    end
    
    -- Auto-link to nearest ship core if enabled
    if auto_link then
        local ship_core = ASC.FindNearestShipCore(ent:GetPos(), ply)
        if IsValid(ship_core) and ent.LinkToShipCore then
            ent:LinkToShipCore(ship_core)
            ply:ChatPrint("Shield linked to ship core: " .. (ship_core.GetShipName and ship_core:GetShipName() or "Unknown"))
        end
    end
    
    -- Add to undo
    undo.Create("Shield Generator")
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()
    
    ply:ChatPrint(shieldData.name .. " spawned successfully!")
    
    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local ent = trace.Entity
    
    if not IsValid(ent) then
        ply:ChatPrint("Right click on a shield to configure it!")
        return false
    end
    
    -- Check if it's a shield entity
    local isShield = false
    for _, shieldData in pairs(ShieldTypes) do
        if ent:GetClass() == shieldData.entity then
            isShield = true
            break
        end
    end
    
    if isShield then
        -- Open shield configuration menu
        ply:ChatPrint("Shield configuration menu would open here!")
        return true
    end
    
    return false
end

function TOOL:Reload(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local ent = trace.Entity
    
    if IsValid(ent) then
        -- Check if it's a shield entity
        for _, shieldData in pairs(ShieldTypes) do
            if ent:GetClass() == shieldData.entity then
                if ent.ToggleShield then
                    ent:ToggleShield()
                    ply:ChatPrint("Shield toggled!")
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
            Text = "Shield Tool",
            Description = "Spawn and configure CAP-integrated shield systems"
        })
        
        CPanel:AddControl("ComboBox", {
            MenuButton = 1,
            Folder = "asc_shields",
            Options = {
                ["Bubble Shield"] = {asc_shield_tool_shield_type = "bubble"},
                ["Iris Shield"] = {asc_shield_tool_shield_type = "iris"},
                ["Asgard Shield"] = {asc_shield_tool_shield_type = "asgard"}
            },
            CVars = {
                [0] = "asc_shield_tool_shield_type"
            }
        })
        
        CPanel:AddControl("CheckBox", {
            Label = "Auto-link to ship core",
            Command = "asc_shield_tool_auto_link"
        })
        
        CPanel:AddControl("Slider", {
            Label = "Shield Strength",
            Command = "asc_shield_tool_shield_strength",
            Type = "Integer",
            Min = 10,
            Max = 1000
        })
        
        CPanel:AddControl("Slider", {
            Label = "Shield Radius",
            Command = "asc_shield_tool_shield_radius",
            Type = "Integer",
            Min = 100,
            Max = 2000
        })
        
        CPanel:AddControl("Label", {
            Text = "Left click: Spawn shield generator"
        })
        
        CPanel:AddControl("Label", {
            Text = "Right click: Configure shield"
        })
        
        CPanel:AddControl("Label", {
            Text = "Reload: Toggle shield on/off"
        })
    end
end
