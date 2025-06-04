-- ASC Ship Core Entity - Client v2.2.0
-- Mandatory ship core for Advanced Space Combat with real-time features

include("shared.lua")

-- Enhanced UI variables with modern design and v2.2.0 features
local shipCoreUI = {
    visible = false,
    entity = nil,
    data = {},
    panelWidth = 1200,
    panelHeight = 900,
    lastUpdate = 0,
    currentTab = "overview", -- overview, resources, systems, cap, fleet, admin, stargate, realtime
    animationTime = 0,
    fadeAlpha = 0,
    targetAlpha = 0,
    tabAnimations = {},

    -- v2.2.0 enhancements
    realTimeMode = true,
    updateRate = 0.05, -- 20 FPS real-time updates
    lastRealTimeUpdate = 0,
    alertSystem = {},
    fleetData = {},
    adminData = {},
    stargateData = {},
    performanceData = {},
    notifications = {},
    lastNotificationTime = 0,
    theme = {
        primary = Color(20, 30, 50, 240),
        secondary = Color(40, 60, 90, 220),
        accent = Color(100, 150, 255),
        success = Color(100, 255, 100),
        warning = Color(255, 200, 100),
        error = Color(255, 100, 100),
        text = Color(255, 255, 255),
        textSecondary = Color(200, 200, 200),
        textMuted = Color(150, 150, 150)
    }
}

function ENT:Initialize()
    self.nextParticle = 0
    self.glowIntensity = 0
    self.pulseTime = 0
    self.lastEffectTime = 0
end

function ENT:Draw()
    self:DrawModel()

    -- Apply dynamic material based on state
    local state = self:GetState()
    local color = self:GetStateColor()

    -- Set material based on state
    if state == 4 or state == 3 then -- EMERGENCY or CRITICAL
        self:SetMaterial("hyperdrive/ship_core_glow")
    else
        self:SetMaterial("hyperdrive/ship_core_base")
    end

    -- Set color based on state
    self:SetColor(Color(color.r, color.g, color.b, 255))

    -- Pulse effect for critical states
    if state == 4 or state == 3 then -- EMERGENCY or CRITICAL
        self.pulseTime = self.pulseTime + FrameTime() * 3
        self.glowIntensity = math.abs(math.sin(self.pulseTime)) * 0.8 + 0.2
    else
        self.glowIntensity = 0.5
    end

    -- Draw enhanced glow effect
    local pos = self:GetPos()
    local size = 32 * self.glowIntensity

    -- Create ship core glow effect periodically
    if CurTime() - self.lastEffectTime > 2 then
        self.lastEffectTime = CurTime()

        local effectData = EffectData()
        effectData:SetOrigin(pos)
        effectData:SetEntity(self)
        effectData:SetScale(1)
        effectData:SetMagnitude(state)
        util.Effect("ship_core_glow", effectData)
    end

    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(pos, size, size, color)

    -- Draw status text above core
    self:DrawStatusText()

    -- Draw model selection info if close enough
    local ply = LocalPlayer()
    if IsValid(ply) then
        local distance = ply:GetPos():Distance(self:GetPos())
        if distance < 200 then
            self:DrawModelInfo()
        end
    end
end

function ENT:DrawStatusText()
    local pos = self:GetPos() + Vector(0, 0, 20)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    -- Check if ship name should be shown above core
    local config = HYPERDRIVE.EnhancedConfig and HYPERDRIVE.EnhancedConfig.ShipNaming or {}
    local showNameAboveCore = config.ShowNameAboveCore ~= false

    cam.Start3D2D(pos, ang, 0.1)
        -- Background (adjust height based on whether ship name is shown)
        local bgHeight = showNameAboveCore and 90 or 60
        local bgY = showNameAboveCore and -45 or -30
        draw.RoundedBox(8, -120, bgY, 240, bgHeight, Color(0, 0, 0, 150))

        local textY = bgY + 10

        -- Ship name (if enabled)
        if showNameAboveCore then
            local shipName = self:GetShipName() or (config.DefaultShipName or "Unnamed Ship")
            draw.SimpleText(shipName, "DermaDefaultBold", 0, textY, Color(100, 200, 255), TEXT_ALIGN_CENTER)
            textY = textY + 15
        end

        -- Core status
        local stateName = self:GetStateName()
        local stateColor = self:GetStateColor()
        draw.SimpleText("ASC SHIP CORE", "DermaDefaultBold", 0, textY, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        textY = textY + 15
        draw.SimpleText(stateName, "DermaDefault", 0, textY, stateColor, TEXT_ALIGN_CENTER)
        textY = textY + 20

        -- Hull and shield status
        if self:GetHullSystemActive() then
            local hullColor = self:GetHullColor()
            draw.SimpleText("Hull: " .. self:GetHullIntegrity() .. "%", "DermaDefault", -50, textY, hullColor, TEXT_ALIGN_CENTER)
        end

        if self:GetShieldSystemActive() then
            local shieldColor = self:GetShieldColor()
            draw.SimpleText("Shield: " .. self:GetShieldStrength() .. "%", "DermaDefault", 50, textY, shieldColor, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

-- Enhanced UI Functions with animations
function shipCoreUI:Open(entity, data)
    self.visible = true
    self.entity = entity
    self.data = data or {}
    self.targetAlpha = 255
    self.animationTime = CurTime()
    self.currentTab = "overview"

    -- Initialize tab animations
    self.tabAnimations = {}
    for _, tab in ipairs({"overview", "resources", "systems", "cap"}) do
        self.tabAnimations[tab] = {
            scale = 1.0,
            targetScale = 1.0,
            lastClick = 0
        }
    end

    gui.EnableScreenClicker(true)

    -- Play opening sound using sound system
    if HYPERDRIVE.Sounds and HYPERDRIVE.Sounds.UI then
        HYPERDRIVE.Sounds.UI.PlayOpen()
    else
        surface.PlaySound("buttons/button15.wav")
    end

    -- Add opening notification
    self:AddNotification("ASC Ship Core Interface Activated", "success")

    print("[ASC Ship Core UI] Enhanced interface opened")
end

function shipCoreUI:Close()
    self.targetAlpha = 0

    -- Animate close
    timer.Simple(0.3, function()
        if not self.visible then return end

        self.visible = false
        self.entity = nil
        self.data = {}
        self.notifications = {}
        gui.EnableScreenClicker(false)

        -- Send close command to server
        if IsValid(self.entity) then
            net.Start("asc_ship_core_command")
            net.WriteEntity(self.entity)
            net.WriteString("close_ui")
            net.WriteTable({})
            net.SendToServer()
        end
    end)

    -- Play closing sound using sound system
    if HYPERDRIVE.Sounds and HYPERDRIVE.Sounds.UI then
        HYPERDRIVE.Sounds.UI.PlayClose()
    else
        surface.PlaySound("buttons/button10.wav")
    end

    print("[ASC Ship Core UI] Enhanced interface closed")
end

function shipCoreUI:Update(data)
    self.data = data or {}
    self.lastUpdate = CurTime()

    -- Add update notification for critical changes
    -- Define states locally to avoid ENT context issues
    local States = {
        INACTIVE = 0,
        ACTIVE = 1,
        INVALID = 2,
        CRITICAL = 3,
        EMERGENCY = 4
    }

    if data.coreState == States.EMERGENCY and self.data.coreState ~= States.EMERGENCY then
        self:AddNotification("EMERGENCY: Core System Critical!", "error")
    elseif data.resourceEmergencyMode and not self.data.resourceEmergencyMode then
        self:AddNotification("WARNING: Resource Emergency Detected", "warning")
    end
end

-- Animation and notification system
function shipCoreUI:AddNotification(text, type)
    local notification = {
        text = text,
        type = type or "info",
        time = CurTime(),
        alpha = 255,
        y = 0
    }

    table.insert(self.notifications, notification)
    self.lastNotificationTime = CurTime()

    -- Limit notifications
    if #self.notifications > 5 then
        table.remove(self.notifications, 1)
    end

    -- Play notification sound using sound system
    if HYPERDRIVE.Sounds and HYPERDRIVE.Sounds.UI then
        if type == "error" then
            HYPERDRIVE.Sounds.UI.PlayError()
        elseif type == "warning" then
            HYPERDRIVE.Sounds.UI.PlayWarning()
        elseif type == "success" then
            HYPERDRIVE.Sounds.UI.PlaySuccess()
        else
            HYPERDRIVE.Sounds.UI.PlayNotification()
        end
    else
        -- Fallback to default sounds
        if type == "error" then
            surface.PlaySound("buttons/button11.wav")
        elseif type == "warning" then
            surface.PlaySound("buttons/button8.wav")
        else
            surface.PlaySound("buttons/button17.wav")
        end
    end
end

-- Model selection functionality
function ENT:DrawModelInfo()
    local modelName = self:GetNWString("SelectedModelName", "Unknown Model")
    local currentIndex = self:GetNWInt("SelectedModelIndex", 1)
    local totalModels = self:GetNWInt("TotalModels", 1)

    local pos = self:GetPos() + Vector(0, 0, 60)
    local ang = LocalPlayer():EyeAngles()
    ang:RotateAroundAxis(ang:Forward(), 90)
    ang:RotateAroundAxis(ang:Right(), 90)

    cam.Start3D2D(pos, ang, 0.08)
        -- Background
        surface.SetDrawColor(0, 0, 0, 200)
        surface.DrawRect(-200, -40, 400, 80)

        -- Border
        surface.SetDrawColor(100, 150, 255, 255)
        surface.DrawOutlinedRect(-200, -40, 400, 80)

        -- Text
        draw.SimpleText("Model: " .. modelName, "DermaDefaultBold", 0, -20, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(currentIndex .. " / " .. totalModels, "DermaDefault", 0, 0, Color(200, 200, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("F1: Menu | F2: Next | F3: Previous", "DermaDefault", 0, 20, Color(150, 150, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    cam.End3D2D()
end

-- Network message handlers for model selection
net.Receive("asc_ship_core_model_selection", function()
    local core = net.ReadEntity()
    local modelInfo = net.ReadTable()

    if IsValid(core) then
        OpenModelSelectionMenu(core, modelInfo)
    end
end)

-- Model selection menu
function OpenModelSelectionMenu(core, modelInfo)
    if IsValid(ASC_ModelSelectionFrame) then
        ASC_ModelSelectionFrame:Close()
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(500, 600)
    frame:Center()
    frame:SetTitle("ASC Ship Core - Model Selection")
    frame:SetVisible(true)
    frame:SetDraggable(true)
    frame:ShowCloseButton(true)
    frame:MakePopup()

    ASC_ModelSelectionFrame = frame

    -- Current model info
    local currentLabel = vgui.Create("DLabel", frame)
    currentLabel:SetPos(10, 30)
    currentLabel:SetSize(480, 20)
    currentLabel:SetText("Current Model: " .. (modelInfo.models[modelInfo.currentIndex] and modelInfo.models[modelInfo.currentIndex].name or "Unknown"))
    currentLabel:SetTextColor(Color(255, 255, 255))

    -- Model list
    local modelList = vgui.Create("DListView", frame)
    modelList:SetPos(10, 60)
    modelList:SetSize(480, 450)
    modelList:SetMultiSelect(false)
    modelList:AddColumn("Index"):SetFixedWidth(60)
    modelList:AddColumn("Name"):SetFixedWidth(250)
    modelList:AddColumn("Category"):SetFixedWidth(120)

    -- Populate model list
    for _, modelData in ipairs(modelInfo.models) do
        local line = modelList:AddLine(modelData.index, modelData.name, modelData.category)
        if modelData.selected then
            line:SetSelected(true)
            modelList:SetSelectedItem(line)
        end
    end

    -- Double-click to select model
    modelList.OnRowSelected = function(panel, index, row)
        local modelIndex = tonumber(row:GetColumnText(1))
        if modelIndex then
            net.Start("asc_ship_core_command")
            net.WriteEntity(core)
            net.WriteString("set_model")
            net.WriteTable({index = modelIndex})
            net.SendToServer()

            frame:Close()
        end
    end

    -- Buttons
    local buttonPanel = vgui.Create("DPanel", frame)
    buttonPanel:SetPos(10, 520)
    buttonPanel:SetSize(480, 40)
    buttonPanel:SetBackgroundColor(Color(0, 0, 0, 0))

    local prevButton = vgui.Create("DButton", buttonPanel)
    prevButton:SetPos(0, 0)
    prevButton:SetSize(100, 30)
    prevButton:SetText("Previous")
    prevButton.DoClick = function()
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("previous_model")
        net.WriteTable({})
        net.SendToServer()

        frame:Close()
    end

    local nextButton = vgui.Create("DButton", buttonPanel)
    nextButton:SetPos(110, 0)
    nextButton:SetSize(100, 30)
    nextButton:SetText("Next")
    nextButton.DoClick = function()
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("next_model")
        net.WriteTable({})
        net.SendToServer()

        frame:Close()
    end

    local randomButton = vgui.Create("DButton", buttonPanel)
    randomButton:SetPos(220, 0)
    randomButton:SetSize(100, 30)
    randomButton:SetText("Random")
    randomButton.DoClick = function()
        local randomIndex = math.random(1, modelInfo.totalModels)
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("set_model")
        net.WriteTable({index = randomIndex})
        net.SendToServer()

        frame:Close()
    end

    local closeButton = vgui.Create("DButton", buttonPanel)
    closeButton:SetPos(380, 0)
    closeButton:SetSize(100, 30)
    closeButton:SetText("Close")
    closeButton.DoClick = function()
        frame:Close()
    end
end

-- Console command for opening model selection
concommand.Add("aria_ship_core_model_menu", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local core = ply:GetEyeTrace().Entity
    if IsValid(core) and core:GetClass() == "asc_ship_core" then
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("get_model_info")
        net.WriteTable({})
        net.SendToServer()
    else
        chat.AddText(Color(255, 100, 100), "[ASC Ship Core] Look at a ship core to open model selection")
    end
end, nil, "Open ship core model selection menu")

-- Key bindings help
hook.Add("HUDPaint", "ASC_ShipCore_ModelSelectionHelp", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local trace = ply:GetEyeTrace()
    if IsValid(trace.Entity) and trace.Entity:GetClass() == "asc_ship_core" and trace.HitPos:Distance(ply:GetPos()) < 200 then
        local x, y = ScrW() / 2, ScrH() - 120

        draw.SimpleText("Ship Core Model Selection", "DermaDefaultBold", x, y - 40, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        draw.SimpleText("E - Open UI  |  F1 - Model Menu  |  F2 - Next Model  |  F3 - Previous Model", "DermaDefault", x, y - 20, Color(200, 200, 200), TEXT_ALIGN_CENTER)
    end
end)

-- Bind keys for quick model switching
hook.Add("PlayerButtonDown", "ASC_ShipCore_ModelKeys", function(ply, button)
    if ply ~= LocalPlayer() then return end

    local core = ply:GetEyeTrace().Entity
    if not IsValid(core) or core:GetClass() ~= "asc_ship_core" then return end
    if ply:GetPos():Distance(core:GetPos()) > 200 then return end

    if button == KEY_F1 then
        -- Open model selection menu
        RunConsoleCommand("aria_ship_core_model_menu")
    elseif button == KEY_F2 then
        -- Next model
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("next_model")
        net.WriteTable({})
        net.SendToServer()
    elseif button == KEY_F3 then
        -- Previous model
        net.Start("asc_ship_core_command")
        net.WriteEntity(core)
        net.WriteString("previous_model")
        net.WriteTable({})
        net.SendToServer()
    end
end)
