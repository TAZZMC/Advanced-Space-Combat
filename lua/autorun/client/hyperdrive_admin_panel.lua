-- Hyperdrive Enhanced Admin Panel
-- This file provides a comprehensive admin interface for managing the hyperdrive system

if SERVER then return end

-- Ensure HYPERDRIVE table exists first
HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.AdminPanel = HYPERDRIVE.AdminPanel or {}
HYPERDRIVE.AdminPanel.Version = "2.0.0"

-- Panel configuration
HYPERDRIVE.AdminPanel.Config = {
    Width = 800,
    Height = 600,
    RefreshRate = 1.0, -- Seconds
    MaxLogEntries = 100
}

-- Create the main admin panel
function HYPERDRIVE.AdminPanel.Create()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:IsAdmin() then
        chat.AddText(Color(255, 100, 100), "[Hyperdrive] ", Color(255, 255, 255), "Admin access required")
        return
    end

    -- Close existing panel
    if IsValid(HYPERDRIVE.AdminPanel.Frame) then
        HYPERDRIVE.AdminPanel.Frame:Close()
    end

    -- Create main frame
    local frame = vgui.Create("DFrame")
    frame:SetTitle("Hyperdrive System Administration V2.0")
    frame:SetSize(HYPERDRIVE.AdminPanel.Config.Width, HYPERDRIVE.AdminPanel.Config.Height)
    frame:Center()
    frame:SetDeleteOnClose(true)
    frame:SetDraggable(true)
    frame:SetSizable(true)
    frame:MakePopup()

    HYPERDRIVE.AdminPanel.Frame = frame

    -- Create tab system
    local tabs = vgui.Create("DPropertySheet", frame)
    tabs:Dock(FILL)
    tabs:SetPadding(5)

    -- System Overview Tab
    HYPERDRIVE.AdminPanel.CreateOverviewTab(tabs)

    -- Entity Management Tab
    HYPERDRIVE.AdminPanel.CreateEntityTab(tabs)

    -- Security Management Tab
    HYPERDRIVE.AdminPanel.CreateSecurityTab(tabs)

    -- Quantum Systems Tab
    HYPERDRIVE.AdminPanel.CreateQuantumTab(tabs)

    -- Navigation AI Tab
    HYPERDRIVE.AdminPanel.CreateNavigationTab(tabs)

    -- Performance Monitor Tab
    HYPERDRIVE.AdminPanel.CreatePerformanceTab(tabs)

    -- Debug Console Tab
    HYPERDRIVE.AdminPanel.CreateDebugTab(tabs)

    -- Start auto-refresh
    HYPERDRIVE.AdminPanel.StartAutoRefresh()
end

-- System Overview Tab
function HYPERDRIVE.AdminPanel.CreateOverviewTab(tabs)
    local panel = vgui.Create("DPanel")
    panel:SetBackgroundColor(Color(40, 40, 40))

    -- System status display
    local statusList = vgui.Create("DListView", panel)
    statusList:SetPos(10, 10)
    statusList:SetSize(380, 200)
    statusList:AddColumn("System")
    statusList:AddColumn("Status")
    statusList:AddColumn("Version")

    -- Quick actions
    local actionsPanel = vgui.Create("DPanel", panel)
    actionsPanel:SetPos(400, 10)
    actionsPanel:SetSize(380, 200)
    actionsPanel:SetBackgroundColor(Color(50, 50, 50))

    local actionsLabel = vgui.Create("DLabel", actionsPanel)
    actionsLabel:SetText("Quick Actions")
    actionsLabel:SetPos(10, 10)
    actionsLabel:SetFont("DermaDefaultBold")
    actionsLabel:SizeToContents()

    -- Emergency lockdown button
    local lockdownBtn = vgui.Create("DButton", actionsPanel)
    lockdownBtn:SetText("Emergency Lockdown All")
    lockdownBtn:SetPos(10, 40)
    lockdownBtn:SetSize(150, 30)
    lockdownBtn:SetIcon("icon16/lock.png")
    lockdownBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_emergency_lockdown")
    end

    -- System restart button
    local restartBtn = vgui.Create("DButton", actionsPanel)
    restartBtn:SetText("Restart Systems")
    restartBtn:SetPos(170, 40)
    restartBtn:SetSize(150, 30)
    restartBtn:SetIcon("icon16/arrow_refresh.png")
    restartBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_restart_systems")
    end

    -- Clear all data button
    local clearBtn = vgui.Create("DButton", actionsPanel)
    clearBtn:SetText("Clear All Data")
    clearBtn:SetPos(10, 80)
    clearBtn:SetSize(150, 30)
    clearBtn:SetIcon("icon16/database_delete.png")
    clearBtn.DoClick = function()
        Derma_Query("This will clear all hyperdrive data. Continue?", "Confirm", "Yes", function()
            RunConsoleCommand("hyperdrive_clear_all_data")
        end, "No")
    end

    -- System statistics
    local statsPanel = vgui.Create("DPanel", panel)
    statsPanel:SetPos(10, 220)
    statsPanel:SetSize(770, 300)
    statsPanel:SetBackgroundColor(Color(50, 50, 50))

    local statsLabel = vgui.Create("DLabel", statsPanel)
    statsLabel:SetText("System Statistics")
    statsLabel:SetPos(10, 10)
    statsLabel:SetFont("DermaDefaultBold")
    statsLabel:SizeToContents()

    -- Store references for updates
    panel.StatusList = statusList
    panel.StatsPanel = statsPanel

    tabs:AddSheet("Overview", panel, "icon16/monitor.png")
    return panel
end

-- Entity Management Tab
function HYPERDRIVE.AdminPanel.CreateEntityTab(tabs)
    local panel = vgui.Create("DPanel")
    panel:SetBackgroundColor(Color(40, 40, 40))

    -- Entity list
    local entityList = vgui.Create("DListView", panel)
    entityList:SetPos(10, 10)
    entityList:SetSize(500, 400)
    entityList:AddColumn("Entity")
    entityList:AddColumn("Type")
    entityList:AddColumn("Owner")
    entityList:AddColumn("Status")
    entityList:AddColumn("Energy")

    -- Entity controls
    local controlsPanel = vgui.Create("DPanel", panel)
    controlsPanel:SetPos(520, 10)
    controlsPanel:SetSize(260, 400)
    controlsPanel:SetBackgroundColor(Color(50, 50, 50))

    local controlsLabel = vgui.Create("DLabel", controlsPanel)
    controlsLabel:SetText("Entity Controls")
    controlsLabel:SetPos(10, 10)
    controlsLabel:SetFont("DermaDefaultBold")
    controlsLabel:SizeToContents()

    -- Control buttons
    local teleportBtn = vgui.Create("DButton", controlsPanel)
    teleportBtn:SetText("Teleport To")
    teleportBtn:SetPos(10, 40)
    teleportBtn:SetSize(120, 30)
    teleportBtn:SetIcon("icon16/arrow_right.png")

    local removeBtn = vgui.Create("DButton", controlsPanel)
    removeBtn:SetText("Remove")
    removeBtn:SetPos(140, 40)
    removeBtn:SetSize(110, 30)
    removeBtn:SetIcon("icon16/delete.png")

    local lockBtn = vgui.Create("DButton", controlsPanel)
    lockBtn:SetText("Lock/Unlock")
    lockBtn:SetPos(10, 80)
    lockBtn:SetSize(120, 30)
    lockBtn:SetIcon("icon16/lock.png")

    local energyBtn = vgui.Create("DButton", controlsPanel)
    energyBtn:SetText("Set Energy")
    energyBtn:SetPos(140, 80)
    energyBtn:SetSize(110, 30)
    energyBtn:SetIcon("icon16/lightning.png")

    -- Entity details
    local detailsPanel = vgui.Create("DPanel", controlsPanel)
    detailsPanel:SetPos(10, 120)
    detailsPanel:SetSize(240, 270)
    detailsPanel:SetBackgroundColor(Color(60, 60, 60))

    local detailsLabel = vgui.Create("DLabel", detailsPanel)
    detailsLabel:SetText("Entity Details")
    detailsLabel:SetPos(10, 10)
    detailsLabel:SetFont("DermaDefaultBold")
    detailsLabel:SizeToContents()

    panel.EntityList = entityList
    panel.DetailsPanel = detailsPanel

    tabs:AddSheet("Entities", panel, "icon16/cog.png")
    return panel
end

-- Security Management Tab
function HYPERDRIVE.AdminPanel.CreateSecurityTab(tabs)
    local panel = vgui.Create("DPanel")
    panel:SetBackgroundColor(Color(40, 40, 40))

    -- Security log
    local logList = vgui.Create("DListView", panel)
    logList:SetPos(10, 10)
    logList:SetSize(500, 300)
    logList:AddColumn("Time")
    logList:AddColumn("Event")
    logList:AddColumn("Player")
    logList:AddColumn("Entity")

    -- Security controls
    local securityPanel = vgui.Create("DPanel", panel)
    securityPanel:SetPos(520, 10)
    securityPanel:SetSize(260, 300)
    securityPanel:SetBackgroundColor(Color(50, 50, 50))

    local securityLabel = vgui.Create("DLabel", securityPanel)
    securityLabel:SetText("Security Controls")
    securityLabel:SetPos(10, 10)
    securityLabel:SetFont("DermaDefaultBold")
    securityLabel:SizeToContents()

    -- Security settings
    local settingsPanel = vgui.Create("DPanel", panel)
    settingsPanel:SetPos(10, 320)
    settingsPanel:SetSize(770, 200)
    settingsPanel:SetBackgroundColor(Color(50, 50, 50))

    local settingsLabel = vgui.Create("DLabel", settingsPanel)
    settingsLabel:SetText("Security Settings")
    settingsLabel:SetPos(10, 10)
    settingsLabel:SetFont("DermaDefaultBold")
    settingsLabel:SizeToContents()

    panel.LogList = logList
    panel.SecurityPanel = securityPanel
    panel.SettingsPanel = settingsPanel

    tabs:AddSheet("Security", panel, "icon16/shield.png")
    return panel
end

-- Quantum Systems Tab
function HYPERDRIVE.AdminPanel.CreateQuantumTab(tabs)
    local panel = vgui.Create("DPanel")
    panel:SetBackgroundColor(Color(40, 40, 40))

    -- Quantum state display
    local quantumList = vgui.Create("DListView", panel)
    quantumList:SetPos(10, 10)
    quantumList:SetSize(500, 250)
    quantumList:AddColumn("Entity")
    quantumList:AddColumn("State")
    quantumList:AddColumn("Probability")
    quantumList:AddColumn("Entangled")

    -- Quantum controls
    local quantumPanel = vgui.Create("DPanel", panel)
    quantumPanel:SetPos(520, 10)
    quantumPanel:SetSize(260, 250)
    quantumPanel:SetBackgroundColor(Color(50, 50, 50))

    local quantumLabel = vgui.Create("DLabel", quantumPanel)
    quantumLabel:SetText("Quantum Controls")
    quantumLabel:SetPos(10, 10)
    quantumLabel:SetFont("DermaDefaultBold")
    quantumLabel:SizeToContents()

    -- Quantum experiments
    local experimentsPanel = vgui.Create("DPanel", panel)
    experimentsPanel:SetPos(10, 270)
    experimentsPanel:SetSize(770, 250)
    experimentsPanel:SetBackgroundColor(Color(50, 50, 50))

    local experimentsLabel = vgui.Create("DLabel", experimentsPanel)
    experimentsLabel:SetText("Quantum Experiments")
    experimentsLabel:SetPos(10, 10)
    experimentsLabel:SetFont("DermaDefaultBold")
    experimentsLabel:SizeToContents()

    panel.QuantumList = quantumList
    panel.QuantumPanel = quantumPanel
    panel.ExperimentsPanel = experimentsPanel

    tabs:AddSheet("Quantum", panel, "icon16/atom.png")
    return panel
end

-- Navigation AI Tab
function HYPERDRIVE.AdminPanel.CreateNavigationTab(tabs)
    local panel = vgui.Create("DPanel")
    panel:SetBackgroundColor(Color(40, 40, 40))

    -- Navigation nodes
    local nodesList = vgui.Create("DListView", panel)
    nodesList:SetPos(10, 10)
    nodesList:SetSize(380, 300)
    nodesList:AddColumn("Node ID")
    nodesList:AddColumn("Position")
    nodesList:AddColumn("Type")
    nodesList:AddColumn("Usage")

    -- AI statistics
    local aiPanel = vgui.Create("DPanel", panel)
    aiPanel:SetPos(400, 10)
    aiPanel:SetSize(380, 300)
    aiPanel:SetBackgroundColor(Color(50, 50, 50))

    local aiLabel = vgui.Create("DLabel", aiPanel)
    aiLabel:SetText("AI Statistics")
    aiLabel:SetPos(10, 10)
    aiLabel:SetFont("DermaDefaultBold")
    aiLabel:SizeToContents()

    -- Path visualization
    local pathPanel = vgui.Create("DPanel", panel)
    pathPanel:SetPos(10, 320)
    pathPanel:SetSize(770, 200)
    pathPanel:SetBackgroundColor(Color(50, 50, 50))

    local pathLabel = vgui.Create("DLabel", pathPanel)
    pathLabel:SetText("Path Visualization")
    pathLabel:SetPos(10, 10)
    pathLabel:SetFont("DermaDefaultBold")
    pathLabel:SizeToContents()

    panel.NodesList = nodesList
    panel.AIPanel = aiPanel
    panel.PathPanel = pathPanel

    tabs:AddSheet("Navigation", panel, "icon16/map.png")
    return panel
end

-- Performance Monitor Tab
function HYPERDRIVE.AdminPanel.CreatePerformanceTab(tabs)
    local panel = vgui.Create("DPanel")
    panel:SetBackgroundColor(Color(40, 40, 40))

    -- Performance graphs would go here
    local perfLabel = vgui.Create("DLabel", panel)
    perfLabel:SetText("Performance Monitoring")
    perfLabel:SetPos(10, 10)
    perfLabel:SetFont("DermaLarge")
    perfLabel:SizeToContents()

    -- Performance metrics
    local metricsPanel = vgui.Create("DPanel", panel)
    metricsPanel:SetPos(10, 50)
    metricsPanel:SetSize(770, 470)
    metricsPanel:SetBackgroundColor(Color(50, 50, 50))

    panel.MetricsPanel = metricsPanel

    tabs:AddSheet("Performance", panel, "icon16/chart_line.png")
    return panel
end

-- Debug Console Tab
function HYPERDRIVE.AdminPanel.CreateDebugTab(tabs)
    local panel = vgui.Create("DPanel")
    panel:SetBackgroundColor(Color(40, 40, 40))

    -- Debug log
    local logPanel = vgui.Create("DListView", panel)
    logPanel:SetPos(10, 10)
    logPanel:SetSize(770, 400)
    logPanel:AddColumn("Time")
    logPanel:AddColumn("Level")
    logPanel:AddColumn("Category")
    logPanel:AddColumn("Message")

    -- Debug controls
    local controlsPanel = vgui.Create("DPanel", panel)
    controlsPanel:SetPos(10, 420)
    controlsPanel:SetSize(770, 100)
    controlsPanel:SetBackgroundColor(Color(50, 50, 50))

    local controlsLabel = vgui.Create("DLabel", controlsPanel)
    controlsLabel:SetText("Debug Controls")
    controlsLabel:SetPos(10, 10)
    controlsLabel:SetFont("DermaDefaultBold")
    controlsLabel:SizeToContents()

    -- Debug level slider
    local levelSlider = vgui.Create("DNumSlider", controlsPanel)
    levelSlider:SetPos(10, 40)
    levelSlider:SetSize(200, 20)
    levelSlider:SetText("Debug Level")
    levelSlider:SetMin(0)
    levelSlider:SetMax(4)
    levelSlider:SetDecimals(0)
    levelSlider:SetValue(2)

    panel.LogPanel = logPanel
    panel.ControlsPanel = controlsPanel

    tabs:AddSheet("Debug", panel, "icon16/bug.png")
    return panel
end

-- Auto-refresh system
function HYPERDRIVE.AdminPanel.StartAutoRefresh()
    timer.Create("HyperdriveAdminRefresh", HYPERDRIVE.AdminPanel.Config.RefreshRate, 0, function()
        if IsValid(HYPERDRIVE.AdminPanel.Frame) then
            HYPERDRIVE.AdminPanel.RefreshData()
        else
            timer.Remove("HyperdriveAdminRefresh")
        end
    end)
end

-- Refresh panel data
function HYPERDRIVE.AdminPanel.RefreshData()
    -- This would update all the panels with current data
    -- Implementation would depend on network messages from server
end

-- Console command to open admin panel
concommand.Add("hyperdrive_admin", function()
    HYPERDRIVE.AdminPanel.Create()
end)

print("[Hyperdrive] Enhanced admin panel loaded")
