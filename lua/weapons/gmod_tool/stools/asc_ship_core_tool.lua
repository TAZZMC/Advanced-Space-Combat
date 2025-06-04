-- Advanced Space Combat - Ship Core Tool
-- Comprehensive ship core spawning and management tool

TOOL.Category = "Advanced Space Combat"
TOOL.Name = "ASC Ship Core Tool v5.1.0"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["model"] = "models/asc/ship_core.mdl"
TOOL.ClientConVar["ship_name"] = "New Ship"
TOOL.ClientConVar["auto_link"] = "1"
TOOL.ClientConVar["power_level"] = "100"

if CLIENT then
    language.Add("tool.asc_ship_core_tool.name", "ASC Ship Core Tool v5.1.0")
    language.Add("tool.asc_ship_core_tool.desc", "Spawn and configure Advanced Space Combat ship cores with ARIA-4 AI integration")
    language.Add("tool.asc_ship_core_tool.0", "Left click to spawn ship core, Right click to configure")
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    local model = self:GetClientInfo("model")
    local ship_name = self:GetClientInfo("ship_name")
    local auto_link = self:GetClientNumber("auto_link", 1) == 1
    local power_level = self:GetClientNumber("power_level", 100)
    
    if trace.HitSky then return false end
    
    -- Create ship core entity
    local ent = ents.Create("ship_core")
    if not IsValid(ent) then
        ply:ChatPrint("Failed to create ship core entity!")
        return false
    end
    
    ent:SetModel(model)
    ent:SetPos(trace.HitPos + trace.HitNormal * 50)
    ent:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
    ent:Spawn()
    ent:Activate()
    
    -- Set ownership
    if ent.CPPISetOwner then
        ent:CPPISetOwner(ply)
    else
        ent:SetOwner(ply)
    end
    
    -- Configure ship core
    if ent.SetShipName then
        ent:SetShipName(ship_name)
    end
    
    if ent.SetAutoLink then
        ent:SetAutoLink(auto_link)
    end
    
    if ent.SetPowerLevel then
        ent:SetPowerLevel(power_level)
    end
    
    -- Add to undo
    undo.Create("Ship Core")
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()
    
    ply:ChatPrint("Ship core '" .. ship_name .. "' spawned successfully!")
    
    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local ent = trace.Entity
    
    if not IsValid(ent) or ent:GetClass() ~= "ship_core" then
        ply:ChatPrint("Right click on a ship core to configure it!")
        return false
    end
    
    -- Open configuration menu (would be implemented with net messages)
    ply:ChatPrint("Ship core configuration menu would open here!")
    
    return true
end

function TOOL:Reload(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local ent = trace.Entity
    
    if IsValid(ent) and ent:GetClass() == "ship_core" then
        if ent.Recalculate then
            ent:Recalculate()
            ply:ChatPrint("Ship core recalculated!")
        end
    end
    
    return true
end

if CLIENT then
    function TOOL.BuildCPanel(CPanel)
        CPanel:AddControl("Header", {
            Text = "Ship Core Tool",
            Description = "Spawn and configure ship cores for your vessels"
        })
        
        CPanel:AddControl("ComboBox", {
            MenuButton = 1,
            Folder = "asc_ship_cores",
            Options = {
                ["Default Core"] = {asc_ship_core_tool_model = "models/asc/ship_core.mdl"},
                ["Heavy Core"] = {asc_ship_core_tool_model = "models/asc/ship_core_heavy.mdl"},
                ["Light Core"] = {asc_ship_core_tool_model = "models/asc/ship_core_light.mdl"}
            },
            CVars = {
                [0] = "asc_ship_core_tool_model"
            }
        })
        
        CPanel:AddControl("TextBox", {
            Label = "Ship Name",
            Command = "asc_ship_core_tool_ship_name",
            MaxLength = 32
        })
        
        CPanel:AddControl("CheckBox", {
            Label = "Auto-link components",
            Command = "asc_ship_core_tool_auto_link"
        })
        
        CPanel:AddControl("Slider", {
            Label = "Power Level",
            Command = "asc_ship_core_tool_power_level",
            Type = "Integer",
            Min = 10,
            Max = 1000
        })
        
        CPanel:AddControl("Label", {
            Text = "Left click: Spawn ship core"
        })
        
        CPanel:AddControl("Label", {
            Text = "Right click: Configure ship core"
        })
        
        CPanel:AddControl("Label", {
            Text = "Reload: Recalculate ship systems"
        })
    end
end
