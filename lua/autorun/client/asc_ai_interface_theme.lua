-- Advanced Space Combat - AI Interface Theme System v1.0.0
-- Professional theming for AI chat interfaces and command panels

print("[Advanced Space Combat] AI Interface Theme System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.AITheme = ASC.AITheme or {}

-- AI interface theme configuration
ASC.AITheme.Config = {
    -- Enable/Disable Features
    EnableAIChatTheming = true,
    EnableCommandPanels = true,
    EnableStatusDisplays = true,
    EnableVoiceVisualizer = true,
    EnableTypingIndicator = true,
    
    -- Visual Settings
    UseHolographicStyle = true,
    EnableAnimations = true,
    EnableSoundEffects = true,
    EnableParticleEffects = true,
    
    -- AI-specific Colors
    Colors = {
        -- AI Status Colors
        AIOnline = Color(39, 174, 96, 255),         -- Green
        AIOffline = Color(231, 76, 60, 255),        -- Red
        AIProcessing = Color(243, 156, 18, 255),    -- Orange
        AIResponding = Color(52, 152, 219, 255),    -- Blue
        AIError = Color(231, 76, 60, 255),          -- Red
        
        -- Message Type Colors
        UserMessage = Color(100, 150, 255, 255),    -- Blue
        AIMessage = Color(255, 100, 255, 255),      -- Magenta
        SystemMessage = Color(100, 255, 100, 255),  -- Green
        ErrorMessage = Color(255, 100, 100, 255),   -- Red
        CommandMessage = Color(255, 200, 100, 255), -- Orange
        
        -- Interface Colors
        ChatBackground = Color(23, 32, 42, 240),
        ChatSurface = Color(30, 39, 46, 220),
        MessageBubble = Color(37, 46, 56, 200),
        InputField = Color(44, 62, 80, 220),
        
        -- Text Colors
        Text = Color(255, 255, 255, 255),
        TextSecondary = Color(178, 190, 195, 200),
        TextMuted = Color(150, 150, 150, 150),
        
        -- Special Effects
        AIGlow = Color(255, 100, 255, 100),
        ProcessingGlow = Color(255, 200, 100, 100),
        Border = Color(99, 110, 114, 150),
        Accent = Color(155, 89, 182, 255)
    },
    
    -- Chat Layout
    ChatPanel = {
        Width = 500,
        Height = 400,
        MessageHeight = 30,
        InputHeight = 40,
        Spacing = 5,
        BorderRadius = 8
    },
    
    -- Animation Settings
    Animations = {
        FadeSpeed = 3.0,
        TypeSpeed = 50.0, -- Characters per second
        PulseSpeed = 2.0,
        GlowSpeed = 1.5
    }
}

-- AI interface state
ASC.AITheme.State = {
    ChatPanelOpen = false,
    ChatMessages = {},
    CurrentInput = "",
    AIStatus = "OFFLINE",
    IsTyping = false,
    TypingAnimation = 0,
    LastUpdate = 0,
    UpdateInterval = 0.05,
    
    -- Animation states
    Animations = {
        StatusPulse = 0,
        TypingDots = 0,
        MessageFade = {},
        GlowIntensity = 0
    }
}

-- Initialize AI theme system
function ASC.AITheme.Initialize()
    print("[Advanced Space Combat] AI interface theme initialized")
    
    -- Create ConVars
    CreateClientConVar("asc_ai_chat_enabled", "1", true, false, "Enable AI chat interface")
    CreateClientConVar("asc_ai_holo_style", "1", true, false, "Enable holographic AI displays")
    CreateClientConVar("asc_ai_animations", "1", true, false, "Enable AI interface animations")
    CreateClientConVar("asc_ai_sounds", "1", true, false, "Enable AI sound effects")
    
    -- Initialize hooks
    ASC.AITheme.InitializeHooks()
end

-- Initialize hooks for AI interfaces
function ASC.AITheme.InitializeHooks()
    -- Hook into AI chat messages
    hook.Add("ASC_AIChatMessage", "ASC_AITheme", function(message, messageType, sender)
        ASC.AITheme.AddChatMessage(message, messageType, sender)
    end)
    
    -- Hook into AI status changes
    hook.Add("ASC_AIStatusChange", "ASC_AITheme", function(status)
        ASC.AITheme.UpdateAIStatus(status)
    end)
    
    -- Hook into AI typing indicator
    hook.Add("ASC_AITyping", "ASC_AITheme", function(isTyping)
        ASC.AITheme.SetTypingIndicator(isTyping)
    end)
end

-- Create AI chat interface
function ASC.AITheme.CreateChatInterface()
    if ASC.AITheme.State.ChatPanelOpen then return end
    
    local config = ASC.AITheme.Config
    
    -- Create main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(config.ChatPanel.Width, config.ChatPanel.Height)
    frame:SetTitle("")
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:SetDeleteOnClose(true)
    
    -- Custom paint function
    frame.Paint = function(self, w, h)
        ASC.AITheme.DrawChatFrame(self, w, h)
    end
    
    -- Create chat display
    ASC.AITheme.CreateChatDisplay(frame)
    
    -- Create input field
    ASC.AITheme.CreateChatInput(frame)
    
    -- Create status display
    ASC.AITheme.CreateStatusDisplay(frame)
    
    ASC.AITheme.State.ChatPanelOpen = true
    
    -- Close handler
    frame.OnClose = function()
        ASC.AITheme.State.ChatPanelOpen = false
    end
    
    -- Play opening sound
    if GetConVar("asc_ai_sounds"):GetBool() then
        surface.PlaySound("ambient/machines/machine_whine1.wav")
    end
    
    return frame
end

-- Draw chat frame
function ASC.AITheme.DrawChatFrame(panel, w, h)
    local config = ASC.AITheme.Config
    
    -- Background with glassmorphism
    draw.RoundedBox(config.ChatPanel.BorderRadius + 2, 0, 0, w, h, config.Colors.ChatBackground)
    draw.RoundedBox(config.ChatPanel.BorderRadius, 2, 2, w - 4, h - 4, config.Colors.ChatSurface)
    
    -- AI-themed border
    surface.SetDrawColor(config.Colors.AIGlow)
    surface.DrawOutlinedRect(0, 0, w, h, 2)
    
    -- Title bar
    draw.RoundedBox(config.ChatPanel.BorderRadius - 2, 5, 5, w - 10, 35, config.Colors.Accent)
    
    -- Title text
    surface.SetFont("ASC_Subtitle")
    surface.SetTextColor(config.Colors.Text)
    local titleText = "ARIA-4 AI INTERFACE"
    local titleW, titleH = surface.GetTextSize(titleText)
    surface.SetTextPos(w/2 - titleW/2, 12)
    surface.DrawText(titleText)
    
    -- AI status indicator
    local statusColor = ASC.AITheme.GetStatusColor()
    local statusSize = 10
    local statusX = w - 25
    local statusY = 15
    
    -- Pulsing status indicator
    if GetConVar("asc_ai_animations"):GetBool() then
        local pulse = math.sin(CurTime() * 3) * 0.3 + 0.7
        statusSize = statusSize * pulse
        statusColor = Color(statusColor.r, statusColor.g, statusColor.b, statusColor.a * pulse)
    end
    
    draw.RoundedBox(statusSize/2, statusX - statusSize/2, statusY - statusSize/2, statusSize, statusSize, statusColor)
    
    -- Holographic effect
    if GetConVar("asc_ai_holo_style"):GetBool() then
        local glowAlpha = math.sin(CurTime() * 2) * 30 + 50
        draw.RoundedBox(config.ChatPanel.BorderRadius + 3, -2, -2, w + 4, h + 4,
            Color(config.Colors.AIGlow.r, config.Colors.AIGlow.g, config.Colors.AIGlow.b, glowAlpha))
    end
end

-- Create chat display area
function ASC.AITheme.CreateChatDisplay(frame)
    local config = ASC.AITheme.Config
    
    -- Chat scroll panel
    local chatPanel = vgui.Create("DScrollPanel", frame)
    chatPanel:SetPos(10, 50)
    chatPanel:SetSize(config.ChatPanel.Width - 20, config.ChatPanel.Height - 110)
    
    chatPanel.Paint = function(self, w, h)
        draw.RoundedBox(config.ChatPanel.BorderRadius - 2, 0, 0, w, h, config.Colors.MessageBubble)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    
    -- Store reference for message updates
    frame.chatPanel = chatPanel
    
    -- Populate with existing messages
    ASC.AITheme.RefreshChatDisplay(frame)
end

-- Create chat input field
function ASC.AITheme.CreateChatInput(frame)
    local config = ASC.AITheme.Config
    local inputY = config.ChatPanel.Height - 50
    
    -- Input field
    local inputField = vgui.Create("DTextEntry", frame)
    inputField:SetPos(10, inputY)
    inputField:SetSize(config.ChatPanel.Width - 120, config.ChatPanel.InputHeight)
    inputField:SetPlaceholderText("Type your message to ARIA-4...")
    inputField:SetFont("ASC_Body")
    
    inputField.Paint = function(self, w, h)
        draw.RoundedBox(config.ChatPanel.BorderRadius - 2, 0, 0, w, h, config.Colors.InputField)
        surface.SetDrawColor(config.Colors.Border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        
        -- Draw text
        self:DrawTextEntryText(config.Colors.Text, config.Colors.Accent, config.Colors.Text)
    end
    
    -- Send button
    local sendButton = vgui.Create("DButton", frame)
    sendButton:SetPos(config.ChatPanel.Width - 100, inputY)
    sendButton:SetSize(90, config.ChatPanel.InputHeight)
    sendButton:SetText("SEND")
    sendButton:SetFont("ASC_Button")
    
    sendButton.Paint = function(self, w, h)
        local bgColor = config.Colors.Accent
        if self:IsHovered() then
            bgColor = Color(bgColor.r + 20, bgColor.g + 20, bgColor.b + 20, bgColor.a)
        end
        if self:IsDown() then
            bgColor = Color(bgColor.r - 20, bgColor.g - 20, bgColor.b - 20, bgColor.a)
        end
        
        draw.RoundedBox(config.ChatPanel.BorderRadius - 2, 0, 0, w, h, bgColor)
        
        surface.SetFont("ASC_Button")
        surface.SetTextColor(config.Colors.Text)
        local textW, textH = surface.GetTextSize(self:GetText())
        surface.SetTextPos(w/2 - textW/2, h/2 - textH/2)
        surface.DrawText(self:GetText())
    end
    
    -- Handle input
    local function SendMessage()
        local message = inputField:GetValue()
        if message and message ~= "" then
            ASC.AITheme.SendChatMessage(message)
            inputField:SetValue("")
        end
    end
    
    sendButton.DoClick = SendMessage
    inputField.OnEnter = SendMessage
    
    -- Store references
    frame.inputField = inputField
    frame.sendButton = sendButton
end

-- Create status display
function ASC.AITheme.CreateStatusDisplay(frame)
    local config = ASC.AITheme.Config
    
    -- Status panel
    local statusPanel = vgui.Create("DPanel", frame)
    statusPanel:SetPos(10, config.ChatPanel.Height - 100)
    statusPanel:SetSize(config.ChatPanel.Width - 20, 40)
    
    statusPanel.Paint = function(self, w, h)
        -- Status text
        local statusText = "AI Status: " .. ASC.AITheme.State.AIStatus
        local statusColor = ASC.AITheme.GetStatusColor()
        
        surface.SetFont("ASC_Small")
        surface.SetTextColor(statusColor)
        surface.SetTextPos(10, 10)
        surface.DrawText(statusText)
        
        -- Typing indicator
        if ASC.AITheme.State.IsTyping then
            local typingText = "ARIA-4 is typing"
            local dots = string.rep(".", math.floor(ASC.AITheme.State.Animations.TypingDots) % 4)
            typingText = typingText .. dots
            
            surface.SetTextColor(config.Colors.AIMessage)
            surface.SetTextPos(10, 25)
            surface.DrawText(typingText)
        end
    end
    
    frame.statusPanel = statusPanel
end

-- Add chat message
function ASC.AITheme.AddChatMessage(message, messageType, sender)
    local messageData = {
        text = message,
        type = messageType or "ai",
        sender = sender or "ARIA-4",
        timestamp = CurTime(),
        fadeAlpha = 0
    }
    
    table.insert(ASC.AITheme.State.ChatMessages, messageData)
    
    -- Limit message history
    if #ASC.AITheme.State.ChatMessages > 50 then
        table.remove(ASC.AITheme.State.ChatMessages, 1)
    end
    
    -- Play message sound
    if GetConVar("asc_ai_sounds"):GetBool() then
        if messageType == "user" then
            surface.PlaySound("buttons/button15.wav")
        else
            surface.PlaySound("ambient/machines/machine_whine2.wav")
        end
    end
    
    -- Refresh display if chat is open
    ASC.AITheme.RefreshChatDisplay()
end

-- Refresh chat display
function ASC.AITheme.RefreshChatDisplay(frame)
    -- This would update the chat display with new messages
    -- For now, we'll just trigger a repaint
    if frame and IsValid(frame.chatPanel) then
        frame.chatPanel:InvalidateLayout()
    end
end

-- Send chat message
function ASC.AITheme.SendChatMessage(message)
    -- Add user message to chat
    ASC.AITheme.AddChatMessage(message, "user", LocalPlayer():Name())
    
    -- Send to AI system (this would be a network message in real implementation)
    -- For now, we'll simulate an AI response
    timer.Simple(1, function()
        ASC.AITheme.SetTypingIndicator(true)
        timer.Simple(2, function()
            ASC.AITheme.SetTypingIndicator(false)
            local responses = {
                "Acknowledged. Processing your request.",
                "Command received. Executing protocols.",
                "Understanding your query. Analyzing data.",
                "Request processed. Standing by for further instructions.",
                "Affirmative. Systems operational."
            }
            local response = responses[math.random(#responses)]
            ASC.AITheme.AddChatMessage(response, "ai", "ARIA-4")
        end)
    end)
end

-- Update AI status
function ASC.AITheme.UpdateAIStatus(status)
    ASC.AITheme.State.AIStatus = status or "OFFLINE"
end

-- Set typing indicator
function ASC.AITheme.SetTypingIndicator(isTyping)
    ASC.AITheme.State.IsTyping = isTyping
    
    if isTyping then
        ASC.AITheme.State.TypingAnimation = CurTime()
    end
end

-- Get status color
function ASC.AITheme.GetStatusColor()
    local config = ASC.AITheme.Config
    local status = ASC.AITheme.State.AIStatus
    
    if status == "ONLINE" then
        return config.Colors.AIOnline
    elseif status == "PROCESSING" then
        return config.Colors.AIProcessing
    elseif status == "RESPONDING" then
        return config.Colors.AIResponding
    elseif status == "ERROR" then
        return config.Colors.AIError
    else
        return config.Colors.AIOffline
    end
end

-- Update animations
function ASC.AITheme.UpdateAnimations()
    if not GetConVar("asc_ai_animations"):GetBool() then return end
    
    local state = ASC.AITheme.State
    
    -- Typing dots animation
    if state.IsTyping then
        state.Animations.TypingDots = (CurTime() - state.TypingAnimation) * 2
    end
    
    -- Status pulse
    state.Animations.StatusPulse = math.sin(CurTime() * 2) * 0.5 + 0.5
    
    -- Glow intensity
    state.Animations.GlowIntensity = math.sin(CurTime() * 1.5) * 0.3 + 0.7
end

-- Hook into Think for animations
hook.Add("Think", "ASC_AITheme_Animations", function()
    if ASC.AITheme.State.ChatPanelOpen then
        ASC.AITheme.UpdateAnimations()
    end
end)

-- Console commands
concommand.Add("asc_ai_chat", function()
    ASC.AITheme.CreateChatInterface()
end)

concommand.Add("asc_ai_status", function(ply, cmd, args)
    local status = args[1] or "ONLINE"
    ASC.AITheme.UpdateAIStatus(status)
    print("[Advanced Space Combat] AI status set to: " .. status)
end)

concommand.Add("asc_ai_test_message", function(ply, cmd, args)
    local message = table.concat(args, " ") or "Test message from ARIA-4"
    ASC.AITheme.AddChatMessage(message, "ai", "ARIA-4")
end)

-- Initialize on client
hook.Add("Initialize", "ASC_AITheme_Init", function()
    ASC.AITheme.Initialize()
end)

print("[Advanced Space Combat] AI Interface Theme System loaded successfully!")
