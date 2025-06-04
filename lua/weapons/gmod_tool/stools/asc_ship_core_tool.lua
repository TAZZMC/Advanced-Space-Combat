-- Advanced Space Combat - Ship Core Tool with Model Selection
-- Comprehensive ship core spawning and management tool with CAP integration

TOOL.Category = "Advanced Space Combat"
TOOL.Name = "ASC Ship Core Tool v6.0.0"
TOOL.Command = nil
TOOL.ConfigName = ""

-- Client ConVars for model selection
TOOL.ClientConVar["model_index"] = "1"
TOOL.ClientConVar["ship_name"] = "New Ship"
TOOL.ClientConVar["auto_link"] = "1"
TOOL.ClientConVar["power_level"] = "100"
TOOL.ClientConVar["enable_life_support"] = "1"
TOOL.ClientConVar["enable_shields"] = "1"
TOOL.ClientConVar["enable_hull_system"] = "1"

-- Available models with CAP integration
local function GetAvailableModels()
    local models = {
        {path = "models/props_combine/combine_core.mdl", name = "Combine Core", category = "Default"},
        {path = "models/hunter/blocks/cube025x025x025.mdl", name = "Basic Cube", category = "Default"},
        {path = "models/props_lab/huladoll.mdl", name = "Hula Doll", category = "Default"},
        {path = "models/props_c17/oildrum001.mdl", name = "Oil Drum", category = "Default"},
        {path = "models/props_phx/construct/metal_plate1.mdl", name = "Metal Plate", category = "Default"},
        {path = "models/props_phx/construct/metal_dome360.mdl", name = "Metal Dome", category = "Default"},
        {path = "models/props_phx/construct/metal_tube.mdl", name = "Metal Tube", category = "Default"},
        {path = "models/props_phx/construct/glass/glass_dome360.mdl", name = "Glass Dome", category = "Default"},
        {path = "models/props_phx/construct/windows/window1x1.mdl", name = "Window Panel", category = "Default"},
        {path = "models/props_phx/construct/concrete_pipe001.mdl", name = "Concrete Pipe", category = "Default"},
        {path = "models/props_phx/construct/metal_angle360.mdl", name = "Metal Angle", category = "Default"},
        {path = "models/props_phx/construct/metal_wire1x1x1.mdl", name = "Wire Frame", category = "Default"},
        {path = "models/props_phx/construct/metal_angle90.mdl", name = "Corner Piece", category = "Default"},
        {path = "models/props_phx/construct/metal_plate2x2.mdl", name = "Large Plate", category = "Default"},
        {path = "models/props_phx/construct/metal_plate_curve360.mdl", name = "Curved Plate", category = "Default"}
    }

    -- Add CAP models if available
    if HYPERDRIVE and HYPERDRIVE.CAP and HYPERDRIVE.CAP.Models then
        local capModels = HYPERDRIVE.CAP.Models.GetShipCoreModels()
        if capModels then
            for _, model in ipairs(capModels) do
                if type(model) == "string" then
                    table.insert(models, {path = model, name = "CAP Model", category = "CAP"})
                else
                    table.insert(models, model)
                end
            end
        end
    end

    return models
end

if CLIENT then
    language.Add("tool.asc_ship_core_tool.name", "ASC Ship Core Tool v6.0.0")
    language.Add("tool.asc_ship_core_tool.desc", "Spawn and configure Advanced Space Combat ship cores with model selection and CAP integration")
    language.Add("tool.asc_ship_core_tool.0", "Left click to spawn ship core, Right click to configure, Reload to change model")
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end

    local modelIndex = self:GetClientNumber("model_index", 1)
    local ship_name = self:GetClientInfo("ship_name")
    local auto_link = self:GetClientNumber("auto_link", 1) == 1
    local power_level = self:GetClientNumber("power_level", 100)
    local enable_life_support = self:GetClientNumber("enable_life_support", 1) == 1
    local enable_shields = self:GetClientNumber("enable_shields", 1) == 1
    local enable_hull_system = self:GetClientNumber("enable_hull_system", 1) == 1

    if trace.HitSky then return false end

    -- Get selected model
    local models = GetAvailableModels()
    local selectedModel = models[modelIndex]
    if not selectedModel then
        ply:ChatPrint("Invalid model selected!")
        return false
    end

    local modelPath = selectedModel.path
    local modelName = selectedModel.name

    -- Create ship core entity
    local ent = ents.Create("asc_ship_core")
    if not IsValid(ent) then
        ply:ChatPrint("Failed to create ASC ship core entity!")
        return false
    end

    ent:SetModel(modelPath)
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

    -- Configure ship core with selected model
    if ent.SetShipName then
        ent:SetShipName(ship_name)
    end

    if ent.SetModelByIndex then
        ent:SetModelByIndex(modelIndex)
    else
        -- Fallback: set the selected model index manually
        ent.selectedModelIndex = modelIndex
        if ent.ApplySelectedModel then
            ent:ApplySelectedModel()
        end
    end

    -- Configure systems
    if ent.SetAutoLink then
        ent:SetAutoLink(auto_link)
    end

    if ent.SetPowerLevel then
        ent:SetPowerLevel(power_level)
    end

    -- Enable/disable systems based on tool settings
    if ent.SetLifeSupportEnabled then
        ent:SetLifeSupportEnabled(enable_life_support)
    end

    if ent.SetShieldsEnabled then
        ent:SetShieldsEnabled(enable_shields)
    end

    if ent.SetHullSystemEnabled then
        ent:SetHullSystemEnabled(enable_hull_system)
    end

    -- Add to undo
    undo.Create("ASC Ship Core")
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()

    ply:ChatPrint("ASC ship core '" .. ship_name .. "' spawned with model: " .. modelName)

    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    local ent = trace.Entity

    if not IsValid(ent) or ent:GetClass() ~= "asc_ship_core" then
        ply:ChatPrint("Right click on an ASC ship core to configure it!")
        return false
    end

    -- Open ship core UI
    if ent.OpenUI then
        ent:OpenUI(ply)
        ply:ChatPrint("ASC ship core interface opened!")
    else
        ply:ChatPrint("ASC ship core configuration not available!")
    end

    return true
end

function TOOL:Reload(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    local ent = trace.Entity

    if IsValid(ent) and ent:GetClass() == "asc_ship_core" then
        -- Change model to next available
        local modelIndex = self:GetClientNumber("model_index", 1)
        local models = GetAvailableModels()

        local nextIndex = modelIndex + 1
        if nextIndex > #models then
            nextIndex = 1
        end

        if ent.SetModelByIndex then
            ent:SetModelByIndex(nextIndex)
            local modelName = models[nextIndex] and models[nextIndex].name or "Unknown"
            ply:ChatPrint("ASC ship core model changed to: " .. modelName)

            -- Update tool's model index
            ply:ConCommand("asc_ship_core_tool_model_index " .. nextIndex)
        else
            ply:ChatPrint("Model changing not supported on this ship core!")
        end
    else
        ply:ChatPrint("Reload: Look at an ASC ship core to change its model!")
    end

    return true
end

if CLIENT then
    -- Model preview panel
    local modelPreviewPanel = nil
    local currentPreviewModel = nil

    function TOOL.BuildCPanel(CPanel)
        CPanel:AddControl("Header", {
            Text = "ASC Ship Core Tool v6.0.0",
            Description = "Spawn and configure Advanced Space Combat ship cores with model selection and CAP integration"
        })

        -- Model Selection Section
        CPanel:AddControl("Label", {
            Text = "Model Selection:"
        })

        -- Model preview
        modelPreviewPanel = vgui.Create("DModelPanel")
        modelPreviewPanel:SetSize(200, 150)
        modelPreviewPanel:SetModel("models/props_combine/combine_core.mdl")
        modelPreviewPanel:SetCamPos(Vector(50, 50, 50))
        modelPreviewPanel:SetLookAt(Vector(0, 0, 0))
        modelPreviewPanel:SetFOV(45)

        -- Mouse controls for model preview
        function modelPreviewPanel:DragMousePress()
            self.PressX, self.PressY = gui.MousePos()
            self.Pressed = true
        end

        function modelPreviewPanel:DragMouseRelease()
            self.Pressed = false
        end

        function modelPreviewPanel:LayoutEntity(ent)
            if self.Pressed then
                local mx, my = gui.MousePos()
                self.Angles = self.Angles or Angle(0, 0, 0)
                self.Angles.y = self.Angles.y + (mx - (self.PressX or mx)) * 0.5
                self.Angles.p = math.Clamp(self.Angles.p + (my - (self.PressY or my)) * 0.5, -90, 90)
                self.PressX, self.PressY = mx, my
            end

            if self.Angles then
                ent:SetAngles(self.Angles)
            end

            self:RunAnimation()
        end

        CPanel:AddItem(modelPreviewPanel)

        -- Model selection dropdown
        local models = GetAvailableModels()
        local modelOptions = {}

        for i, model in ipairs(models) do
            local displayName = model.name .. " (" .. model.category .. ")"
            modelOptions[displayName] = {asc_ship_core_tool_model_index = tostring(i)}
        end

        local modelCombo = CPanel:AddControl("ComboBox", {
            MenuButton = 1,
            Folder = "asc_ship_core_models",
            Options = modelOptions,
            CVars = {
                [0] = "asc_ship_core_tool_model_index"
            }
        })

        -- Update preview when model changes
        cvars.AddChangeCallback("asc_ship_core_tool_model_index", function(name, old, new)
            local index = tonumber(new) or 1
            local model = models[index]
            if model and modelPreviewPanel then
                modelPreviewPanel:SetModel(model.path)
                currentPreviewModel = model
            end
        end)

        -- Model info display
        local modelInfoLabel = vgui.Create("DLabel")
        modelInfoLabel:SetText("Model: " .. (models[1] and models[1].name or "Unknown"))
        modelInfoLabel:SetTextColor(Color(255, 255, 255))
        modelInfoLabel:SizeToContents()
        CPanel:AddItem(modelInfoLabel)

        -- Update model info when selection changes
        cvars.AddChangeCallback("asc_ship_core_tool_model_index", function(name, old, new)
            local index = tonumber(new) or 1
            local model = models[index]
            if model and modelInfoLabel then
                modelInfoLabel:SetText("Model: " .. model.name .. " (" .. model.category .. ")")
                modelInfoLabel:SizeToContents()
            end
        end)

        -- Model navigation buttons
        local buttonPanel = vgui.Create("DPanel")
        buttonPanel:SetSize(200, 30)
        buttonPanel:SetBackgroundColor(Color(0, 0, 0, 0))

        local prevButton = vgui.Create("DButton", buttonPanel)
        prevButton:SetPos(0, 0)
        prevButton:SetSize(60, 25)
        prevButton:SetText("Previous")
        prevButton.DoClick = function()
            local currentIndex = GetConVar("asc_ship_core_tool_model_index"):GetInt()
            local newIndex = currentIndex - 1
            if newIndex < 1 then newIndex = #models end
            RunConsoleCommand("asc_ship_core_tool_model_index", tostring(newIndex))
        end

        local nextButton = vgui.Create("DButton", buttonPanel)
        nextButton:SetPos(70, 0)
        nextButton:SetSize(60, 25)
        nextButton:SetText("Next")
        nextButton.DoClick = function()
            local currentIndex = GetConVar("asc_ship_core_tool_model_index"):GetInt()
            local newIndex = currentIndex + 1
            if newIndex > #models then newIndex = 1 end
            RunConsoleCommand("asc_ship_core_tool_model_index", tostring(newIndex))
        end

        local randomButton = vgui.Create("DButton", buttonPanel)
        randomButton:SetPos(140, 0)
        randomButton:SetSize(60, 25)
        randomButton:SetText("Random")
        randomButton.DoClick = function()
            local randomIndex = math.random(1, #models)
            RunConsoleCommand("asc_ship_core_tool_model_index", tostring(randomIndex))
        end

        CPanel:AddItem(buttonPanel)

        -- Separator
        CPanel:AddControl("Label", {
            Text = ""
        })

        -- Ship Configuration Section
        CPanel:AddControl("Label", {
            Text = "Ship Configuration:"
        })

        CPanel:AddControl("TextBox", {
            Label = "Ship Name",
            Command = "asc_ship_core_tool_ship_name",
            MaxLength = 32
        })

        CPanel:AddControl("Slider", {
            Label = "Power Level",
            Command = "asc_ship_core_tool_power_level",
            Type = "Integer",
            Min = 10,
            Max = 1000
        })

        -- System Configuration Section
        CPanel:AddControl("Label", {
            Text = "System Configuration:"
        })

        CPanel:AddControl("CheckBox", {
            Label = "Auto-link components",
            Command = "asc_ship_core_tool_auto_link"
        })

        CPanel:AddControl("CheckBox", {
            Label = "Enable life support",
            Command = "asc_ship_core_tool_enable_life_support"
        })

        CPanel:AddControl("CheckBox", {
            Label = "Enable shield system",
            Command = "asc_ship_core_tool_enable_shields"
        })

        CPanel:AddControl("CheckBox", {
            Label = "Enable hull damage system",
            Command = "asc_ship_core_tool_enable_hull_system"
        })

        -- Instructions Section
        CPanel:AddControl("Label", {
            Text = ""
        })

        CPanel:AddControl("Label", {
            Text = "Instructions:"
        })

        CPanel:AddControl("Label", {
            Text = "Left click: Spawn ASC ship core with selected model"
        })

        CPanel:AddControl("Label", {
            Text = "Right click: Open ship core configuration UI"
        })

        CPanel:AddControl("Label", {
            Text = "Reload: Change model of existing ship core"
        })

        -- CAP Integration Info
        if HYPERDRIVE and HYPERDRIVE.CAP then
            CPanel:AddControl("Label", {
                Text = ""
            })

            CPanel:AddControl("Label", {
                Text = "CAP Integration: Active ✓"
            })
        else
            CPanel:AddControl("Label", {
                Text = ""
            })

            CPanel:AddControl("Label", {
                Text = "CAP Integration: Not Available"
            })
        end
    end
end
