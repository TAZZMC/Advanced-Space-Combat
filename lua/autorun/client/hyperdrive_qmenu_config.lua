-- Enhanced Hyperdrive System - Q Menu Configuration Panel
-- Provides easy access to system configuration through the spawn menu

if SERVER then return end

-- Modern theme configuration
local modernTheme = {
    primary = Color(25, 35, 55),
    secondary = Color(45, 65, 95),
    accent = Color(100, 150, 255),
    success = Color(100, 200, 100),
    warning = Color(255, 200, 100),
    error = Color(255, 120, 120),
    text = Color(255, 255, 255),
    textSecondary = Color(200, 200, 200),
    textMuted = Color(150, 150, 150),
    border = Color(80, 120, 180, 100)
}

-- Create the enhanced configuration panel
local function CreateHyperdriveConfigPanel()
    local panel = vgui.Create("DPanel")
    panel:SetSize(800, 650)
    panel:SetPaintBackground(false)

    -- Custom paint function for modern styling
    panel.Paint = function(self, w, h)
        -- Modern glassmorphism background
        draw.RoundedBox(12, 0, 0, w, h, Color(modernTheme.primary.r, modernTheme.primary.g, modernTheme.primary.b, 240))
        draw.RoundedBox(12, 2, 2, w - 4, h - 4, Color(modernTheme.secondary.r, modernTheme.secondary.g, modernTheme.secondary.b, 200))

        -- Subtle border glow
        draw.RoundedBox(12, 0, 0, w, 2, modernTheme.accent)
        draw.RoundedBox(12, 0, h - 2, w, 2, Color(modernTheme.accent.r, modernTheme.accent.g, modernTheme.accent.b, 150))
    end

    -- Enhanced title with modern styling
    local titlePanel = vgui.Create("DPanel", panel)
    titlePanel:SetPos(15, 15)
    titlePanel:SetSize(770, 60)
    titlePanel:SetPaintBackground(false)

    titlePanel.Paint = function(self, w, h)
        -- Title background with gradient
        draw.RoundedBoxEx(8, 0, 0, w, h, modernTheme.accent, true, true, false, false)
        draw.RoundedBoxEx(8, 0, h/2, w, h/2, Color(modernTheme.accent.r * 0.7, modernTheme.accent.g * 0.7, modernTheme.accent.b * 0.7), false, false, true, true)

        -- Title text with shadow
        draw.SimpleText("ENHANCED HYPERDRIVE SYSTEM", "DermaLarge", w/2 + 1, 21, Color(0, 0, 0, 150), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText("ENHANCED HYPERDRIVE SYSTEM", "DermaLarge", w/2, 20, modernTheme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Version and subtitle
        local versionText = "v" .. (HYPERDRIVE.Version or "2.1.0") .. " - Advanced Configuration Panel"
        draw.SimpleText(versionText, "DermaDefault", w/2, 40, Color(255, 255, 255, 200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Create scrollable panel for configuration options
    local scroll = vgui.Create("DScrollPanel", panel)
    scroll:SetPos(10, 50)
    scroll:SetSize(580, 400)

    local configPanel = vgui.Create("DPanel", scroll)
    configPanel:SetSize(560, 800)
    configPanel:SetPaintBackground(false)

    local yPos = 10

    -- Core System Configuration
    local coreLabel = vgui.Create("DLabel", configPanel)
    coreLabel:SetPos(10, yPos)
    coreLabel:SetSize(540, 25)
    coreLabel:SetText("Core System Settings")
    coreLabel:SetFont("DermaDefaultBold")
    coreLabel:SetTextColor(Color(255, 255, 100))
    yPos = yPos + 30

    -- Ship Core Required
    local shipCoreCheck = vgui.Create("DCheckBoxLabel", configPanel)
    shipCoreCheck:SetPos(20, yPos)
    shipCoreCheck:SetSize(520, 20)
    shipCoreCheck:SetText("Require Ship Core for Hyperdrive Operation")
    shipCoreCheck:SetValue(true)
    shipCoreCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "RequireShipCore", val and "true" or "false")
    end
    yPos = yPos + 25

    -- One Core Per Ship
    local oneCoreCheck = vgui.Create("DCheckBoxLabel", configPanel)
    oneCoreCheck:SetPos(20, yPos)
    oneCoreCheck:SetSize(520, 20)
    oneCoreCheck:SetText("Enforce One Ship Core Per Ship")
    oneCoreCheck:SetValue(true)
    oneCoreCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "EnforceOneCorePerShip", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto-detect Ships
    local autoDetectCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoDetectCheck:SetPos(20, yPos)
    autoDetectCheck:SetSize(520, 20)
    autoDetectCheck:SetText("Auto-detect Ship Structures")
    autoDetectCheck:SetValue(true)
    autoDetectCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "AutoDetectShips", val and "true" or "false")
    end
    yPos = yPos + 35

    -- Resource System Configuration
    local resourceLabel = vgui.Create("DLabel", configPanel)
    resourceLabel:SetPos(10, yPos)
    resourceLabel:SetSize(540, 25)
    resourceLabel:SetText("Spacebuild 3 Resource System")
    resourceLabel:SetFont("DermaDefaultBold")
    resourceLabel:SetTextColor(Color(100, 255, 100))
    yPos = yPos + 30

    -- Enable Resource Core
    local resourceCoreCheck = vgui.Create("DCheckBoxLabel", configPanel)
    resourceCoreCheck:SetPos(20, yPos)
    resourceCoreCheck:SetSize(520, 20)
    resourceCoreCheck:SetText("Enable Ship Core Resource System")
    resourceCoreCheck:SetValue(true)
    resourceCoreCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "EnableResourceCore", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto Resource Provision
    local autoProvisionCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoProvisionCheck:SetPos(20, yPos)
    autoProvisionCheck:SetSize(520, 20)
    autoProvisionCheck:SetText("Enable Automatic Resource Provision for Welded Entities")
    autoProvisionCheck:SetValue(true)
    autoProvisionCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "EnableAutoResourceProvision", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Weld Detection
    local weldDetectionCheck = vgui.Create("DCheckBoxLabel", configPanel)
    weldDetectionCheck:SetPos(20, yPos)
    weldDetectionCheck:SetSize(520, 20)
    weldDetectionCheck:SetText("Enable Weld Detection System")
    weldDetectionCheck:SetValue(true)
    weldDetectionCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "EnableWeldDetection", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto-provision percentage slider
    local provisionLabel = vgui.Create("DLabel", configPanel)
    provisionLabel:SetPos(20, yPos)
    provisionLabel:SetSize(200, 20)
    provisionLabel:SetText("Auto-provision Percentage:")
    yPos = yPos + 20

    local provisionSlider = vgui.Create("DNumSlider", configPanel)
    provisionSlider:SetPos(20, yPos)
    provisionSlider:SetSize(520, 20)
    provisionSlider:SetMin(10)
    provisionSlider:SetMax(100)
    provisionSlider:SetDecimals(0)
    provisionSlider:SetValue(50)
    provisionSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "AutoProvisionPercentage", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Shield System Configuration
    local shieldLabel = vgui.Create("DLabel", configPanel)
    shieldLabel:SetPos(10, yPos)
    shieldLabel:SetSize(540, 25)
    shieldLabel:SetText("Shield System Settings")
    shieldLabel:SetFont("DermaDefaultBold")
    shieldLabel:SetTextColor(Color(150, 150, 255))
    yPos = yPos + 30

    -- Enable Shields
    local shieldsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    shieldsCheck:SetPos(20, yPos)
    shieldsCheck:SetSize(520, 20)
    shieldsCheck:SetText("Enable Shield System")
    shieldsCheck:SetValue(true)
    shieldsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "EnableShields", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto-activate Shields
    local autoShieldsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoShieldsCheck:SetPos(20, yPos)
    autoShieldsCheck:SetSize(520, 20)
    autoShieldsCheck:SetText("Auto-activate Shields During Hyperdrive Charge")
    autoShieldsCheck:SetValue(true)
    autoShieldsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "AutoActivateShields", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Enhanced CAP Integration Section
    local capLabel = vgui.Create("DLabel", configPanel)
    capLabel:SetPos(10, yPos)
    capLabel:SetSize(540, 25)
    capLabel:SetText("CAP (Carter Addon Pack) Integration")
    capLabel:SetFont("DermaDefaultBold")
    capLabel:SetTextColor(Color(100, 200, 255))
    yPos = yPos + 30

    -- Enable CAP Integration
    local capCheck = vgui.Create("DCheckBoxLabel", configPanel)
    capCheck:SetPos(20, yPos)
    capCheck:SetSize(520, 20)
    capCheck:SetText("Enable CAP (Carter Addon Pack) Integration")
    capCheck:SetValue(true)
    capCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "EnableCAPIntegration", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Prefer CAP Shields
    local preferCAPCheck = vgui.Create("DCheckBoxLabel", configPanel)
    preferCAPCheck:SetPos(20, yPos)
    preferCAPCheck:SetSize(520, 20)
    preferCAPCheck:SetText("Prefer CAP Shields Over Custom Shields")
    preferCAPCheck:SetValue(true)
    preferCAPCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "CAP", "PreferCAPShields", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto-create CAP Shields
    local autoCreateCAPCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoCreateCAPCheck:SetPos(20, yPos)
    autoCreateCAPCheck:SetSize(520, 20)
    autoCreateCAPCheck:SetText("Auto-create CAP Shields for Ships Without Shields")
    autoCreateCAPCheck:SetValue(false)
    autoCreateCAPCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "CAP", "AutoCreateShields", val and "true" or "false")
    end
    yPos = yPos + 25

    -- CAP Resource Integration
    local capResourcesCheck = vgui.Create("DCheckBoxLabel", configPanel)
    capResourcesCheck:SetPos(20, yPos)
    capResourcesCheck:SetSize(520, 20)
    capResourcesCheck:SetText("Integrate CAP Resource Systems (ZPM, Naquadah, etc.)")
    capResourcesCheck:SetValue(true)
    capResourcesCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "CAP", "IntegrateCAPResources", val and "true" or "false")
    end
    yPos = yPos + 25

    -- CAP Effects Integration
    local capEffectsCheck = vgui.Create("DCheckBoxLabel", configPanel)
    capEffectsCheck:SetPos(20, yPos)
    capEffectsCheck:SetSize(520, 20)
    capEffectsCheck:SetText("Use CAP Visual and Audio Effects")
    capEffectsCheck:SetValue(true)
    capEffectsCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "CAP", "UseCAPEffects", val and "true" or "false")
    end
    yPos = yPos + 35

    -- Hull Damage System Configuration
    local hullLabel = vgui.Create("DLabel", configPanel)
    hullLabel:SetPos(10, yPos)
    hullLabel:SetSize(540, 25)
    hullLabel:SetText("Hull Damage System Settings")
    hullLabel:SetFont("DermaDefaultBold")
    hullLabel:SetTextColor(Color(255, 150, 100))
    yPos = yPos + 30

    -- Enable Hull Damage
    local hullCheck = vgui.Create("DCheckBoxLabel", configPanel)
    hullCheck:SetPos(20, yPos)
    hullCheck:SetSize(520, 20)
    hullCheck:SetText("Enable Hull Damage System")
    hullCheck:SetValue(true)
    hullCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Core", "EnableHullDamage", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Auto Hull Repair
    local autoRepairCheck = vgui.Create("DCheckBoxLabel", configPanel)
    autoRepairCheck:SetPos(20, yPos)
    autoRepairCheck:SetSize(520, 20)
    autoRepairCheck:SetText("Enable Automatic Hull Repair")
    autoRepairCheck:SetValue(true)
    autoRepairCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "HullDamage", "AutoRepairEnabled", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Critical hull threshold slider
    local hullThresholdLabel = vgui.Create("DLabel", configPanel)
    hullThresholdLabel:SetPos(20, yPos)
    hullThresholdLabel:SetSize(200, 20)
    hullThresholdLabel:SetText("Critical Hull Threshold:")
    yPos = yPos + 20

    local hullSlider = vgui.Create("DNumSlider", configPanel)
    hullSlider:SetPos(20, yPos)
    hullSlider:SetSize(520, 20)
    hullSlider:SetMin(5)
    hullSlider:SetMax(50)
    hullSlider:SetDecimals(0)
    hullSlider:SetValue(25)
    hullSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "HullDamage", "CriticalHullThreshold", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Interface System Configuration
    local interfaceLabel = vgui.Create("DLabel", configPanel)
    interfaceLabel:SetPos(10, yPos)
    interfaceLabel:SetSize(540, 25)
    interfaceLabel:SetText("Interface System Settings")
    interfaceLabel:SetFont("DermaDefaultBold")
    interfaceLabel:SetTextColor(Color(255, 200, 100))
    yPos = yPos + 30

    -- Enable USE Key Interfaces
    local useKeyCheck = vgui.Create("DCheckBoxLabel", configPanel)
    useKeyCheck:SetPos(20, yPos)
    useKeyCheck:SetSize(520, 20)
    useKeyCheck:SetText("Enable USE (E) Key Interfaces")
    useKeyCheck:SetValue(true)
    useKeyCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Interface", "EnableUSEKeyInterfaces", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Enable SHIFT Modifier
    local shiftCheck = vgui.Create("DCheckBoxLabel", configPanel)
    shiftCheck:SetPos(20, yPos)
    shiftCheck:SetSize(520, 20)
    shiftCheck:SetText("Enable SHIFT+USE for Ship Core Access")
    shiftCheck:SetValue(true)
    shiftCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Interface", "EnableShiftModifier", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Enable Feedback Messages
    local feedbackCheck = vgui.Create("DCheckBoxLabel", configPanel)
    feedbackCheck:SetPos(20, yPos)
    feedbackCheck:SetSize(520, 20)
    feedbackCheck:SetText("Enable Feedback Messages")
    feedbackCheck:SetValue(true)
    feedbackCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Interface", "EnableFeedbackMessages", val and "true" or "false")
    end
    yPos = yPos + 35

    -- Action buttons at the bottom
    local buttonPanel = vgui.Create("DPanel", panel)
    buttonPanel:SetPos(10, 460)
    buttonPanel:SetSize(580, 35)
    buttonPanel:SetPaintBackground(false)

    -- Status button
    local statusBtn = vgui.Create("DButton", buttonPanel)
    statusBtn:SetPos(0, 0)
    statusBtn:SetSize(120, 30)
    statusBtn:SetText("System Status")
    statusBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_status")
    end

    -- Help button
    local helpBtn = vgui.Create("DButton", buttonPanel)
    helpBtn:SetPos(130, 0)
    helpBtn:SetSize(100, 30)
    helpBtn:SetText("Help")
    helpBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_help")
    end

    -- Resource status button
    local resourceBtn = vgui.Create("DButton", buttonPanel)
    resourceBtn:SetPos(240, 0)
    resourceBtn:SetSize(140, 30)
    resourceBtn:SetText("Resource Status")
    resourceBtn.DoClick = function()
        RunConsoleCommand("hyperdrive_sb3_resources")
    end

    -- Reset to defaults button
    local resetBtn = vgui.Create("DButton", buttonPanel)
    resetBtn:SetPos(390, 0)
    resetBtn:SetSize(120, 30)
    resetBtn:SetText("Reset Defaults")
    resetBtn.DoClick = function()
        Derma_Query(
            "Are you sure you want to reset all Enhanced Hyperdrive settings to defaults?",
            "Reset Configuration",
            "Yes, Reset",
            function()
                RunConsoleCommand("hyperdrive_config_reset")
                chat.AddText(Color(100, 255, 100), "[Hyperdrive] Configuration reset to defaults")
            end,
            "Cancel"
        )
    end

    -- Close button
    local closeBtn = vgui.Create("DButton", buttonPanel)
    closeBtn:SetPos(520, 0)
    closeBtn:SetSize(60, 30)
    closeBtn:SetText("Close")
    closeBtn.DoClick = function()
        panel:GetParent():Close()
    end

    return panel
end

-- Create advanced configuration panel
local function CreateAdvancedConfigPanel()
    local panel = vgui.Create("DPanel")
    panel:SetSize(600, 400)

    local scroll = vgui.Create("DScrollPanel", panel)
    scroll:SetPos(5, 5)
    scroll:SetSize(590, 390)

    local configPanel = vgui.Create("DPanel", scroll)
    configPanel:SetSize(570, 600)
    configPanel:SetPaintBackground(false)

    local yPos = 10

    -- Resource Capacities Section
    local capacityLabel = vgui.Create("DLabel", configPanel)
    capacityLabel:SetPos(10, yPos)
    capacityLabel:SetSize(550, 25)
    capacityLabel:SetText("Default Resource Capacities")
    capacityLabel:SetFont("DermaDefaultBold")
    capacityLabel:SetTextColor(Color(100, 255, 200))
    yPos = yPos + 30

    -- Energy capacity
    local energyCapLabel = vgui.Create("DLabel", configPanel)
    energyCapLabel:SetPos(20, yPos)
    energyCapLabel:SetSize(150, 20)
    energyCapLabel:SetText("Energy Capacity (kW):")

    local energyCapSlider = vgui.Create("DNumSlider", configPanel)
    energyCapSlider:SetPos(180, yPos)
    energyCapSlider:SetSize(370, 20)
    energyCapSlider:SetMin(1000)
    energyCapSlider:SetMax(50000)
    energyCapSlider:SetDecimals(0)
    energyCapSlider:SetValue(10000)
    energyCapSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "DefaultEnergyCapacity", tostring(math.floor(val)))
    end
    yPos = yPos + 25

    -- Oxygen capacity
    local oxygenCapLabel = vgui.Create("DLabel", configPanel)
    oxygenCapLabel:SetPos(20, yPos)
    oxygenCapLabel:SetSize(150, 20)
    oxygenCapLabel:SetText("Oxygen Capacity (L):")

    local oxygenCapSlider = vgui.Create("DNumSlider", configPanel)
    oxygenCapSlider:SetPos(180, yPos)
    oxygenCapSlider:SetSize(370, 20)
    oxygenCapSlider:SetMin(500)
    oxygenCapSlider:SetMax(20000)
    oxygenCapSlider:SetDecimals(0)
    oxygenCapSlider:SetValue(5000)
    oxygenCapSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "DefaultOxygenCapacity", tostring(math.floor(val)))
    end
    yPos = yPos + 25

    -- Fuel capacity
    local fuelCapLabel = vgui.Create("DLabel", configPanel)
    fuelCapLabel:SetPos(20, yPos)
    fuelCapLabel:SetSize(150, 20)
    fuelCapLabel:SetText("Fuel Capacity (L):")

    local fuelCapSlider = vgui.Create("DNumSlider", configPanel)
    fuelCapSlider:SetPos(180, yPos)
    fuelCapSlider:SetSize(370, 20)
    fuelCapSlider:SetMin(500)
    fuelCapSlider:SetMax(15000)
    fuelCapSlider:SetDecimals(0)
    fuelCapSlider:SetValue(3000)
    fuelCapSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "DefaultFuelCapacity", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Transfer Rates Section
    local transferLabel = vgui.Create("DLabel", configPanel)
    transferLabel:SetPos(10, yPos)
    transferLabel:SetSize(550, 25)
    transferLabel:SetText("Resource Transfer Rates (Per Second)")
    transferLabel:SetFont("DermaDefaultBold")
    transferLabel:SetTextColor(Color(255, 200, 100))
    yPos = yPos + 30

    -- Energy transfer rate
    local energyTransferLabel = vgui.Create("DLabel", configPanel)
    energyTransferLabel:SetPos(20, yPos)
    energyTransferLabel:SetSize(150, 20)
    energyTransferLabel:SetText("Energy Rate (kW/s):")

    local energyTransferSlider = vgui.Create("DNumSlider", configPanel)
    energyTransferSlider:SetPos(180, yPos)
    energyTransferSlider:SetSize(370, 20)
    energyTransferSlider:SetMin(100)
    energyTransferSlider:SetMax(5000)
    energyTransferSlider:SetDecimals(0)
    energyTransferSlider:SetValue(1000)
    energyTransferSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "EnergyTransferRate", tostring(math.floor(val)))
    end
    yPos = yPos + 25

    -- Oxygen transfer rate
    local oxygenTransferLabel = vgui.Create("DLabel", configPanel)
    oxygenTransferLabel:SetPos(20, yPos)
    oxygenTransferLabel:SetSize(150, 20)
    oxygenTransferLabel:SetText("Oxygen Rate (L/s):")

    local oxygenTransferSlider = vgui.Create("DNumSlider", configPanel)
    oxygenTransferSlider:SetPos(180, yPos)
    oxygenTransferSlider:SetSize(370, 20)
    oxygenTransferSlider:SetMin(50)
    oxygenTransferSlider:SetMax(2000)
    oxygenTransferSlider:SetDecimals(0)
    oxygenTransferSlider:SetValue(500)
    oxygenTransferSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "OxygenTransferRate", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Auto-provision Settings Section
    local provisionLabel = vgui.Create("DLabel", configPanel)
    provisionLabel:SetPos(10, yPos)
    provisionLabel:SetSize(550, 25)
    provisionLabel:SetText("Auto-provision Settings")
    provisionLabel:SetFont("DermaDefaultBold")
    provisionLabel:SetTextColor(Color(200, 100, 255))
    yPos = yPos + 30

    -- Provision delay
    local delayLabel = vgui.Create("DLabel", configPanel)
    delayLabel:SetPos(20, yPos)
    delayLabel:SetSize(150, 20)
    delayLabel:SetText("Provision Delay (s):")

    local delaySlider = vgui.Create("DNumSlider", configPanel)
    delaySlider:SetPos(180, yPos)
    delaySlider:SetSize(370, 20)
    delaySlider:SetMin(0.1)
    delaySlider:SetMax(5.0)
    delaySlider:SetDecimals(1)
    delaySlider:SetValue(0.5)
    delaySlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "AutoProvisionDelay", tostring(val))
    end
    yPos = yPos + 25

    -- Min provision amount
    local minAmountLabel = vgui.Create("DLabel", configPanel)
    minAmountLabel:SetPos(20, yPos)
    minAmountLabel:SetSize(150, 20)
    minAmountLabel:SetText("Min Provision Amount:")

    local minAmountSlider = vgui.Create("DNumSlider", configPanel)
    minAmountSlider:SetPos(180, yPos)
    minAmountSlider:SetSize(370, 20)
    minAmountSlider:SetMin(1)
    minAmountSlider:SetMax(100)
    minAmountSlider:SetDecimals(0)
    minAmountSlider:SetValue(25)
    minAmountSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "MinAutoProvisionAmount", tostring(math.floor(val)))
    end
    yPos = yPos + 25

    -- Max provision amount
    local maxAmountLabel = vgui.Create("DLabel", configPanel)
    maxAmountLabel:SetPos(20, yPos)
    maxAmountLabel:SetSize(150, 20)
    maxAmountLabel:SetText("Max Provision Amount:")

    local maxAmountSlider = vgui.Create("DNumSlider", configPanel)
    maxAmountSlider:SetPos(180, yPos)
    maxAmountSlider:SetSize(370, 20)
    maxAmountSlider:SetMin(100)
    maxAmountSlider:SetMax(2000)
    maxAmountSlider:SetDecimals(0)
    maxAmountSlider:SetValue(500)
    maxAmountSlider.OnValueChanged = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "MaxAutoProvisionAmount", tostring(math.floor(val)))
    end
    yPos = yPos + 35

    -- Debug Options Section
    local debugLabel = vgui.Create("DLabel", configPanel)
    debugLabel:SetPos(10, yPos)
    debugLabel:SetSize(550, 25)
    debugLabel:SetText("Debug and Logging Options")
    debugLabel:SetFont("DermaDefaultBold")
    debugLabel:SetTextColor(Color(255, 100, 100))
    yPos = yPos + 30

    -- Log resource transfers
    local logTransfersCheck = vgui.Create("DCheckBoxLabel", configPanel)
    logTransfersCheck:SetPos(20, yPos)
    logTransfersCheck:SetSize(520, 20)
    logTransfersCheck:SetText("Log Resource Transfers (Debug)")
    logTransfersCheck:SetValue(false)
    logTransfersCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "LogResourceTransfers", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Log weld detection
    local logWeldCheck = vgui.Create("DCheckBoxLabel", configPanel)
    logWeldCheck:SetPos(20, yPos)
    logWeldCheck:SetSize(520, 20)
    logWeldCheck:SetText("Log Weld Detection Events (Debug)")
    logWeldCheck:SetValue(false)
    logWeldCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "SB3Resources", "LogWeldDetection", val and "true" or "false")
    end
    yPos = yPos + 25

    -- Log hull damage
    local logHullCheck = vgui.Create("DCheckBoxLabel", configPanel)
    logHullCheck:SetPos(20, yPos)
    logHullCheck:SetSize(520, 20)
    logHullCheck:SetText("Log Hull Damage Operations (Debug)")
    logHullCheck:SetValue(false)
    logHullCheck.OnChange = function(self, val)
        RunConsoleCommand("hyperdrive_config_set", "Debug", "LogHullDamage", val and "true" or "false")
    end

    return panel
end

-- Add to spawn menu
hook.Add("PopulateToolMenu", "HyperdriveConfigMenu", function()
    spawnmenu.AddToolMenuOption("Utilities", "Enhanced Hyperdrive", "hyperdrive_config", "Configuration", "", "", function(panel)
        panel:ClearControls()

        -- Add description
        panel:Help("Enhanced Hyperdrive System Configuration")
        panel:Help("Configure all aspects of the hyperdrive system including ship cores, resources, shields, and hull damage.")
        panel:Help("")

        -- Add the configuration panel
        local configPanel = CreateHyperdriveConfigPanel()
        panel:AddPanel(configPanel)
    end)

    spawnmenu.AddToolMenuOption("Utilities", "Enhanced Hyperdrive", "hyperdrive_advanced", "Advanced Settings", "", "", function(panel)
        panel:ClearControls()

        -- Add description
        panel:Help("Advanced Configuration Options")
        panel:Help("Fine-tune resource capacities, transfer rates, and debug options.")
        panel:Help("")

        -- Add the advanced configuration panel
        local advancedPanel = CreateAdvancedConfigPanel()
        panel:AddPanel(advancedPanel)
    end)

    spawnmenu.AddToolMenuOption("Utilities", "Enhanced Hyperdrive", "hyperdrive_status", "System Status", "", "", function(panel)
        panel:ClearControls()

        panel:Help("Enhanced Hyperdrive System Status")
        panel:Help("View current system status and integration information.")
        panel:Help("")

        -- System status button
        panel:Button("View System Status", "hyperdrive_status")

        -- Resource status button
        panel:Button("View Resource Status", "hyperdrive_sb3_resources")

        -- Integration status button
        panel:Button("View Integration Status", "hyperdrive_integration_status")

        -- List integrations button
        panel:Button("List Registered Integrations", "hyperdrive_list_integrations")

        -- CAP status button
        panel:Button("View CAP Integration Status", "hyperdrive_cap_status")

        panel:Help("")
        panel:Help("Console Commands:")
        panel:Help("hyperdrive_help - Show help information")
        panel:Help("hyperdrive_status - Show system status")
        panel:Help("hyperdrive_sb3_resources - Show resource system status")
        panel:Help("hyperdrive_config_show <category> - Show configuration")
        panel:Help("hyperdrive_config_set <category> <key> <value> - Set configuration")
        panel:Help("hyperdrive_config_reset - Reset to defaults")
    end)
end)

print("[Hyperdrive] Q Menu configuration panel loaded")
