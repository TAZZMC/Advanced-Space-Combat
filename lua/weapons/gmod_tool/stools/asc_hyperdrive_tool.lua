-- Advanced Space Combat - Hyperdrive Engine Tool
-- Comprehensive hyperdrive engine spawning and configuration tool

TOOL.Category = "Advanced Space Combat"
TOOL.Name = "Ultimate Hyperdrive Engine Tool v4.0.0"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.ClientConVar["model"] = "models/asc/hyperdrive_engine.mdl"
TOOL.ClientConVar["engine_type"] = "standard"
TOOL.ClientConVar["auto_link"] = "1"
TOOL.ClientConVar["thrust_power"] = "100"

if CLIENT then
    language.Add("tool.asc_hyperdrive_tool.name", "Hyperdrive Engine Tool")
    language.Add("tool.asc_hyperdrive_tool.desc", "Spawn and configure hyperdrive engines")
    language.Add("tool.asc_hyperdrive_tool.0", "Left click to spawn engine, Right click to link to ship core")
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    local model = self:GetClientInfo("model")
    local engine_type = self:GetClientInfo("engine_type")
    local auto_link = self:GetClientNumber("auto_link", 1) == 1
    local thrust_power = self:GetClientNumber("thrust_power", 100)
    
    if trace.HitSky then return false end
    
    -- Create ultimate hyperdrive engine entity
    local ent = ents.Create("hyperdrive_master_engine")
    if not IsValid(ent) then
        ply:ChatPrint("Failed to create hyperdrive engine entity!")
        return false
    end
    
    ent:SetModel(model)
    ent:SetPos(trace.HitPos + trace.HitNormal * 25)
    ent:SetAngles(trace.HitNormal:Angle() + Angle(90, 0, 0))
    ent:Spawn()
    ent:Activate()
    
    -- Set ownership
    if ent.CPPISetOwner then
        ent:CPPISetOwner(ply)
    else
        ent:SetOwner(ply)
    end
    
    -- Configure engine
    if ent.ConfigureEngineType then
        ent:ConfigureEngineType(engine_type)
    end

    if ent.SetThrustPower then
        ent:SetThrustPower(thrust_power)
    end
    
    -- Auto-link to nearest ship core if enabled
    if auto_link then
        local ship_core = ASC.FindNearestShipCore(ent:GetPos(), ply)
        if IsValid(ship_core) and ent.LinkToShipCore then
            ent:LinkToShipCore(ship_core)
            ply:ChatPrint("Engine linked to ship core: " .. (ship_core.GetShipName and ship_core:GetShipName() or "Unknown"))
        end
    end
    
    -- Add to undo
    undo.Create("Hyperdrive Engine")
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()
    
    ply:ChatPrint("Hyperdrive engine spawned successfully!")
    
    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local ent = trace.Entity
    
    if not IsValid(ent) then
        ply:ChatPrint("Right click on an entity to link it!")
        return false
    end
    
    if ent:GetClass() == "ship_core" then
        -- Store ship core for linking
        self.SelectedShipCore = ent
        ply:ChatPrint("Ship core selected! Now left click on engines to link them.")
        return true
    elseif ent:GetClass() == "hyperdrive_master_engine" then
        -- Link engine to selected ship core
        if IsValid(self.SelectedShipCore) and ent.LinkToShipCore then
            ent:LinkToShipCore(self.SelectedShipCore)
            ply:ChatPrint("Engine linked to ship core!")
        else
            ply:ChatPrint("Select a ship core first by right-clicking it!")
        end
        return true
    end
    
    return false
end

function TOOL:Reload(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local ent = trace.Entity
    
    if IsValid(ent) and ent:GetClass() == "hyperdrive_master_engine" then
        if ent.ToggleEngine then
            ent:ToggleEngine()
            ply:ChatPrint("Engine toggled!")
        end
    end
    
    return true
end

if CLIENT then
    function TOOL.BuildCPanel(CPanel)
        CPanel:AddControl("Header", {
            Text = "Ultimate Hyperdrive Engine Tool",
            Description = "Spawn and configure the ultimate hyperdrive engine with all engine types unified"
        })
        
        CPanel:AddControl("ComboBox", {
            MenuButton = 1,
            Folder = "asc_engines",
            Options = {
                ["Master Engine"] = {
                    asc_hyperdrive_tool_model = "models/props_phx/construct/metal_plate_curve360x2.mdl",
                    asc_hyperdrive_tool_engine_type = "master"
                },
                ["Standard Engine"] = {
                    asc_hyperdrive_tool_model = "models/props_phx/construct/metal_plate1.mdl",
                    asc_hyperdrive_tool_engine_type = "standard"
                },
                ["Heavy Engine"] = {
                    asc_hyperdrive_tool_model = "models/props_phx/construct/metal_plate2.mdl",
                    asc_hyperdrive_tool_engine_type = "heavy"
                },
                ["Light Engine"] = {
                    asc_hyperdrive_tool_model = "models/props_phx/construct/metal_plate_curve.mdl",
                    asc_hyperdrive_tool_engine_type = "light"
                },
                ["Enhanced Engine"] = {
                    asc_hyperdrive_tool_model = "models/props_phx/construct/metal_plate_curve180.mdl",
                    asc_hyperdrive_tool_engine_type = "enhanced"
                },
                ["Quantum Engine"] = {
                    asc_hyperdrive_tool_model = "models/props_phx/construct/metal_plate_curve360.mdl",
                    asc_hyperdrive_tool_engine_type = "quantum"
                },
                ["Dimensional Engine"] = {
                    asc_hyperdrive_tool_model = "models/props_phx/construct/metal_plate_curve360x2.mdl",
                    asc_hyperdrive_tool_engine_type = "dimensional"
                }
            },
            CVars = {
                [0] = "asc_hyperdrive_tool_model",
                [1] = "asc_hyperdrive_tool_engine_type"
            }
        })
        
        CPanel:AddControl("CheckBox", {
            Label = "Auto-link to ship core",
            Command = "asc_hyperdrive_tool_auto_link"
        })
        
        CPanel:AddControl("Slider", {
            Label = "Thrust Power",
            Command = "asc_hyperdrive_tool_thrust_power",
            Type = "Integer",
            Min = 10,
            Max = 500
        })
        
        CPanel:AddControl("Label", {
            Text = "Left click: Spawn engine"
        })
        
        CPanel:AddControl("Label", {
            Text = "Right click: Link engine to ship core"
        })
        
        CPanel:AddControl("Label", {
            Text = "Reload: Toggle engine on/off"
        })
    end
end
