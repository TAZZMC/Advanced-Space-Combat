-- Advanced Space Combat - Character Selection System v1.0.0
-- Professional character selection with player model customization

print("[Advanced Space Combat] Character Selection System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.CharacterSelection = ASC.CharacterSelection or {}

-- Configuration
ASC.CharacterSelection.Config = {
    -- Available player models
    Models = {
        {
            name = "Alyx Vance",
            model = "models/player/alyx.mdl",
            description = "Resistance fighter and scientist",
            category = "Half-Life"
        },
        {
            name = "Barney Calhoun", 
            model = "models/player/barney.mdl",
            description = "Civil Protection officer turned rebel",
            category = "Half-Life"
        },
        {
            name = "Dr. Breen",
            model = "models/player/breen.mdl", 
            description = "Former administrator of City 17",
            category = "Half-Life"
        },
        {
            name = "Eli Vance",
            model = "models/player/eli.mdl",
            description = "Resistance leader and scientist",
            category = "Half-Life"
        },
        {
            name = "G-Man",
            model = "models/player/gman.mdl",
            description = "Mysterious government agent",
            category = "Half-Life"
        },
        {
            name = "Dr. Kleiner",
            model = "models/player/kleiner.mdl",
            description = "Theoretical physicist",
            category = "Half-Life"
        },
        {
            name = "Father Grigori",
            model = "models/player/monk.mdl",
            description = "Ravenholm's guardian priest",
            category = "Half-Life"
        },
        {
            name = "Dr. Mossman",
            model = "models/player/mossman.mdl",
            description = "Research scientist",
            category = "Half-Life"
        }
    },
    
    -- Visual settings
    PanelWidth = 800,
    PanelHeight = 600,
    ModelPreviewSize = 200,
    
    -- Colors
    BackgroundColor = Color(20, 30, 50, 240),
    HeaderColor = Color(41, 128, 185, 255),
    ButtonColor = Color(52, 152, 219, 255),
    ButtonHoverColor = Color(74, 174, 241, 255),
    TextColor = Color(255, 255, 255, 255),
    DescriptionColor = Color(200, 200, 200, 255)
}

-- State
ASC.CharacterSelection.State = {
    Panel = nil,
    SelectedModel = nil,
    ModelPanel = nil,
    IsOpen = false
}

-- Create character selection panel
function ASC.CharacterSelection.CreatePanel()
    if IsValid(ASC.CharacterSelection.State.Panel) then
        ASC.CharacterSelection.State.Panel:Remove()
    end
    
    local config = ASC.CharacterSelection.Config

    -- Use the safe themed panel creation
    local frame
    if ASC.ComprehensiveTheme and ASC.ComprehensiveTheme.CreateThemedFrame then
        frame = ASC.ComprehensiveTheme.CreateThemedFrame("Advanced Space Combat - Character Selection", config.PanelWidth, config.PanelHeight)
    else
        frame = vgui.Create("DFrame")
        frame:SetSize(config.PanelWidth, config.PanelHeight)
        frame:Center()
        frame:SetTitle("Advanced Space Combat - Character Selection")
        frame:SetDraggable(true)
        frame:SetDeleteOnClose(true)
        frame.ASCThemed = true
    end

    frame:MakePopup()
    
    -- Header
    local header = vgui.Create("DLabel", frame)
    header:SetPos(20, 30)
    header:SetSize(config.PanelWidth - 40, 30)
    header:SetText("Select Your Character")
    header:SetFont("DermaLarge")
    header:SetTextColor(config.HeaderColor)
    
    -- Model preview panel
    local modelPanel = vgui.Create("DModelPanel", frame)
    modelPanel:SetPos(20, 70)
    modelPanel:SetSize(config.ModelPreviewSize, config.ModelPreviewSize + 50)
    modelPanel:SetModel("models/player/alyx.mdl")
    
    -- Set up model panel
    local mn, mx = modelPanel.Entity:GetRenderBounds()
    local size = 0
    size = math.max(size, math.abs(mn.x) + math.abs(mx.x))
    size = math.max(size, math.abs(mn.y) + math.abs(mx.y))
    size = math.max(size, math.abs(mn.z) + math.abs(mx.z))
    
    modelPanel:SetFOV(45)
    modelPanel:SetCamPos(Vector(size, size, size))
    modelPanel:SetLookAt((mn + mx) * 0.5)
    
    ASC.CharacterSelection.State.ModelPanel = modelPanel
    
    -- Character list
    local listPanel = vgui.Create("DScrollPanel", frame)
    listPanel:SetPos(config.ModelPreviewSize + 40, 70)
    listPanel:SetSize(config.PanelWidth - config.ModelPreviewSize - 80, config.PanelHeight - 150)
    
    -- Create character buttons
    local yPos = 0
    for i, character in ipairs(config.Models) do
        local charButton = vgui.Create("DButton", listPanel)
        charButton:SetPos(0, yPos)
        charButton:SetSize(listPanel:GetWide() - 20, 80)
        charButton:SetText("")
        
        -- Custom paint function
        charButton.Paint = function(self, w, h)
            local bgColor = config.ButtonColor
            if self:IsHovered() then
                bgColor = config.ButtonHoverColor
            end
            if ASC.CharacterSelection.State.SelectedModel == character.model then
                bgColor = Color(100, 200, 100, 255)
            end
            
            draw.RoundedBox(8, 0, 0, w, h, bgColor)
            
            -- Character name
            draw.SimpleText(character.name, "DermaDefaultBold", 10, 10, config.TextColor)
            
            -- Description
            draw.SimpleText(character.description, "DermaDefault", 10, 30, config.DescriptionColor)
            
            -- Category
            draw.SimpleText("Category: " .. character.category, "DermaDefault", 10, 50, config.DescriptionColor)
        end
        
        charButton.DoClick = function()
            ASC.CharacterSelection.SelectCharacter(character)
        end
        
        yPos = yPos + 90
    end
    
    -- Buttons
    local buttonY = config.PanelHeight - 60
    
    -- Apply button
    local applyButton = vgui.Create("DButton", frame)
    applyButton:SetPos(config.PanelWidth - 220, buttonY)
    applyButton:SetSize(100, 30)
    applyButton:SetText("Apply")
    applyButton.DoClick = function()
        ASC.CharacterSelection.ApplySelection()
    end
    
    -- Cancel button
    local cancelButton = vgui.Create("DButton", frame)
    cancelButton:SetPos(config.PanelWidth - 110, buttonY)
    cancelButton:SetSize(80, 30)
    cancelButton:SetText("Cancel")
    cancelButton.DoClick = function()
        frame:Close()
        ASC.CharacterSelection.State.IsOpen = false
    end
    
    -- Random button
    local randomButton = vgui.Create("DButton", frame)
    randomButton:SetPos(20, buttonY)
    randomButton:SetSize(100, 30)
    randomButton:SetText("Random")
    randomButton.DoClick = function()
        local randomChar = config.Models[math.random(1, #config.Models)]
        ASC.CharacterSelection.SelectCharacter(randomChar)
    end
    
    ASC.CharacterSelection.State.Panel = frame
    ASC.CharacterSelection.State.IsOpen = true
    
    -- Select first character by default
    ASC.CharacterSelection.SelectCharacter(config.Models[1])
    
    print("[Advanced Space Combat] Character selection panel created")
end

-- Select a character
function ASC.CharacterSelection.SelectCharacter(character)
    ASC.CharacterSelection.State.SelectedModel = character.model
    
    -- Update model preview
    if IsValid(ASC.CharacterSelection.State.ModelPanel) then
        ASC.CharacterSelection.State.ModelPanel:SetModel(character.model)
    end
    
    print("[Advanced Space Combat] Selected character: " .. character.name)
end

-- Apply character selection
function ASC.CharacterSelection.ApplySelection()
    if not ASC.CharacterSelection.State.SelectedModel then
        chat.AddText(Color(255, 100, 100), "[Advanced Space Combat] No character selected!")
        return
    end
    
    -- Send model change to server
    net.Start("ASC_ChangePlayerModel")
    net.WriteString(ASC.CharacterSelection.State.SelectedModel)
    net.SendToServer()
    
    -- Close panel
    if IsValid(ASC.CharacterSelection.State.Panel) then
        ASC.CharacterSelection.State.Panel:Close()
    end
    ASC.CharacterSelection.State.IsOpen = false
    
    chat.AddText(Color(100, 255, 100), "[Advanced Space Combat] Character applied successfully!")
end

-- Open character selection
function ASC.CharacterSelection.Open()
    if ASC.CharacterSelection.State.IsOpen then
        if IsValid(ASC.CharacterSelection.State.Panel) then
            ASC.CharacterSelection.State.Panel:SetVisible(true)
            ASC.CharacterSelection.State.Panel:MakePopup()
        end
        return
    end
    
    ASC.CharacterSelection.CreatePanel()
end

-- Console command
concommand.Add("asc_character_menu", function()
    ASC.CharacterSelection.Open()
end, nil, "Open character selection menu")

print("[Advanced Space Combat] Character Selection System loaded successfully!")
