-- Advanced Space Combat - Advanced Theme Effects System v1.0.0
-- Enhanced visual effects, animations, and advanced theming features

print("[Advanced Space Combat] Advanced Theme Effects System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.AdvancedEffects = ASC.AdvancedEffects or {}

-- Advanced effects configuration
ASC.AdvancedEffects.Config = {
    -- Enable/Disable Features
    EnableParticleEffects = true,
    EnableAdvancedAnimations = true,
    EnableHolographicEffects = true,
    EnableScanlineEffects = true,
    EnableEnergyEffects = true,
    EnableMatrixEffects = false, -- Performance intensive
    EnableAudioVisualizer = true,
    EnableDynamicLighting = true,
    
    -- Performance Settings
    MaxParticles = 50,
    AnimationQuality = "high", -- low, medium, high, ultra
    EffectUpdateRate = 0.05, -- 20 FPS for effects
    
    -- Visual Settings
    HologramAlpha = 0.8,
    ScanlineSpeed = 2.0,
    EnergyPulseSpeed = 1.5,
    GlowIntensity = 0.7,
    
    -- Colors for advanced effects
    EffectColors = {
        Hologram = Color(100, 200, 255, 200),
        Energy = Color(0, 255, 255, 180),
        Scanline = Color(100, 255, 100, 100),
        Matrix = Color(0, 255, 0, 150),
        Warning = Color(255, 100, 100, 200),
        Critical = Color(255, 0, 0, 255)
    }
}

-- Advanced effects state
ASC.AdvancedEffects.State = {
    ActiveEffects = {},
    ParticleEmitters = {},
    AnimationTimers = {},
    LastUpdate = 0,
    EffectCounter = 0,
    
    -- Animation states
    Animations = {
        HologramFlicker = 0,
        ScanlinePosition = 0,
        EnergyPulse = 0,
        MatrixRain = {},
        GlowIntensity = 1
    }
}

-- Initialize advanced effects system
function ASC.AdvancedEffects.Initialize()
    print("[Advanced Space Combat] Advanced effects system initialized")

    -- ConVars are now managed centrally by ASC.ConVarManager
    
    -- Initialize hooks
    ASC.AdvancedEffects.InitializeHooks()
    
    -- Initialize effect systems
    ASC.AdvancedEffects.InitializeParticleSystem()
    ASC.AdvancedEffects.InitializeHologramSystem()
    ASC.AdvancedEffects.InitializeScanlineSystem()
    ASC.AdvancedEffects.InitializeEnergySystem()
end

-- Initialize hooks
function ASC.AdvancedEffects.InitializeHooks()
    -- Hook into HUD painting for overlay effects
    hook.Add("HUDPaint", "ASC_AdvancedEffects_HUD", function()
        if GetConVar("asc_effects_enabled"):GetBool() then
            ASC.AdvancedEffects.DrawOverlayEffects()
        end
    end)
    
    -- Hook into Think for animations
    hook.Add("Think", "ASC_AdvancedEffects_Think", function()
        if GetConVar("asc_effects_enabled"):GetBool() then
            ASC.AdvancedEffects.UpdateAnimations()
        end
    end)
    
    -- Hook into panel painting for enhanced effects
    hook.Add("VGUIElementCreated", "ASC_AdvancedEffects_VGUI", function(element)
        if GetConVar("asc_effects_enabled"):GetBool() then
            timer.Simple(0.1, function()
                if IsValid(element) then
                    ASC.AdvancedEffects.EnhanceVGUIElement(element)
                end
            end)
        end
    end)
end

-- Initialize particle system
function ASC.AdvancedEffects.InitializeParticleSystem()
    print("[Advanced Space Combat] Particle system initialized")
end

-- Initialize hologram system
function ASC.AdvancedEffects.InitializeHologramSystem()
    print("[Advanced Space Combat] Hologram system initialized")
end

-- Initialize scanline system
function ASC.AdvancedEffects.InitializeScanlineSystem()
    print("[Advanced Space Combat] Scanline system initialized")
end

-- Initialize energy system
function ASC.AdvancedEffects.InitializeEnergySystem()
    print("[Advanced Space Combat] Energy system initialized")
end

-- Draw overlay effects
function ASC.AdvancedEffects.DrawOverlayEffects()
    local config = ASC.AdvancedEffects.Config
    local state = ASC.AdvancedEffects.State
    
    -- Draw scanlines if enabled
    if GetConVar("asc_effects_scanlines"):GetBool() then
        ASC.AdvancedEffects.DrawScanlines()
    end
    
    -- Draw holographic overlay if enabled
    if GetConVar("asc_effects_holograms"):GetBool() then
        ASC.AdvancedEffects.DrawHolographicOverlay()
    end
    
    -- Draw energy effects if enabled
    if GetConVar("asc_effects_energy"):GetBool() then
        ASC.AdvancedEffects.DrawEnergyEffects()
    end
end

-- Draw scanlines effect
function ASC.AdvancedEffects.DrawScanlines()
    local config = ASC.AdvancedEffects.Config
    local state = ASC.AdvancedEffects.State
    
    local scrW, scrH = ScrW(), ScrH()
    local lineHeight = 2
    local spacing = 4
    
    surface.SetDrawColor(config.EffectColors.Scanline)
    
    for y = 0, scrH, spacing do
        local alpha = math.sin((y + state.Animations.ScanlinePosition) * 0.1) * 50 + 50
        surface.SetDrawColor(Color(config.EffectColors.Scanline.r, config.EffectColors.Scanline.g, config.EffectColors.Scanline.b, alpha))
        surface.DrawRect(0, y, scrW, lineHeight)
    end
end

-- Draw holographic overlay
function ASC.AdvancedEffects.DrawHolographicOverlay()
    local config = ASC.AdvancedEffects.Config
    local state = ASC.AdvancedEffects.State
    
    local scrW, scrH = ScrW(), ScrH()
    
    -- Holographic flicker effect
    local flickerAlpha = math.sin(CurTime() * 10) * 20 + 30
    surface.SetDrawColor(Color(config.EffectColors.Hologram.r, config.EffectColors.Hologram.g, config.EffectColors.Hologram.b, flickerAlpha))
    surface.DrawRect(0, 0, scrW, scrH)
    
    -- Holographic grid lines
    surface.SetDrawColor(Color(100, 200, 255, 30))
    local gridSize = 50
    
    for x = 0, scrW, gridSize do
        surface.DrawLine(x, 0, x, scrH)
    end
    
    for y = 0, scrH, gridSize do
        surface.DrawLine(0, y, scrW, y)
    end
end

-- Draw energy effects
function ASC.AdvancedEffects.DrawEnergyEffects()
    local config = ASC.AdvancedEffects.Config
    local state = ASC.AdvancedEffects.State
    
    -- Energy pulse around screen edges
    local scrW, scrH = ScrW(), ScrH()
    local pulseWidth = 5
    local pulseAlpha = math.sin(CurTime() * config.EnergyPulseSpeed) * 100 + 100
    
    surface.SetDrawColor(Color(config.EffectColors.Energy.r, config.EffectColors.Energy.g, config.EffectColors.Energy.b, pulseAlpha))
    
    -- Top edge
    surface.DrawRect(0, 0, scrW, pulseWidth)
    -- Bottom edge
    surface.DrawRect(0, scrH - pulseWidth, scrW, pulseWidth)
    -- Left edge
    surface.DrawRect(0, 0, pulseWidth, scrH)
    -- Right edge
    surface.DrawRect(scrW - pulseWidth, 0, pulseWidth, scrH)
end

-- Update animations
function ASC.AdvancedEffects.UpdateAnimations()
    local currentTime = CurTime()
    local config = ASC.AdvancedEffects.Config
    local state = ASC.AdvancedEffects.State
    
    if currentTime - state.LastUpdate < config.EffectUpdateRate then
        return
    end
    
    -- Update scanline position
    state.Animations.ScanlinePosition = state.Animations.ScanlinePosition + config.ScanlineSpeed
    if state.Animations.ScanlinePosition > 100 then
        state.Animations.ScanlinePosition = 0
    end
    
    -- Update hologram flicker
    state.Animations.HologramFlicker = math.sin(currentTime * 8) * 0.3 + 0.7
    
    -- Update energy pulse
    state.Animations.EnergyPulse = math.sin(currentTime * config.EnergyPulseSpeed) * 0.5 + 0.5
    
    -- Update glow intensity
    state.Animations.GlowIntensity = math.sin(currentTime * 2) * 0.3 + config.GlowIntensity
    
    state.LastUpdate = currentTime
end

-- Enhance VGUI element with advanced effects
function ASC.AdvancedEffects.EnhanceVGUIElement(element)
    if not IsValid(element) then return end
    if element.ASCAdvancedEffects then return end -- Already enhanced
    
    local config = ASC.AdvancedEffects.Config
    element.ASCAdvancedEffects = true
    
    -- Store original paint function
    local originalPaint = element.Paint
    
    -- Apply enhanced paint function
    element.Paint = function(self, w, h)
        -- Call original paint first
        if originalPaint then
            originalPaint(self, w, h)
        end
        
        -- Apply advanced effects
        if GetConVar("asc_effects_enabled"):GetBool() then
            ASC.AdvancedEffects.ApplyElementEffects(self, w, h)
        end
    end
end

-- Apply effects to specific element
function ASC.AdvancedEffects.ApplyElementEffects(element, w, h)
    local config = ASC.AdvancedEffects.Config
    local state = ASC.AdvancedEffects.State
    
    -- Holographic border effect
    if GetConVar("asc_effects_holograms"):GetBool() then
        local glowAlpha = state.Animations.GlowIntensity * 100
        surface.SetDrawColor(Color(config.EffectColors.Hologram.r, config.EffectColors.Hologram.g, config.EffectColors.Hologram.b, glowAlpha))
        surface.DrawOutlinedRect(-1, -1, w + 2, h + 2, 1)
        surface.DrawOutlinedRect(-2, -2, w + 4, h + 4, 1)
    end
    
    -- Energy corner effects
    if GetConVar("asc_effects_energy"):GetBool() then
        local cornerSize = 10
        local energyAlpha = state.Animations.EnergyPulse * 150
        surface.SetDrawColor(Color(config.EffectColors.Energy.r, config.EffectColors.Energy.g, config.EffectColors.Energy.b, energyAlpha))
        
        -- Top-left corner
        surface.DrawRect(0, 0, cornerSize, 2)
        surface.DrawRect(0, 0, 2, cornerSize)
        
        -- Top-right corner
        surface.DrawRect(w - cornerSize, 0, cornerSize, 2)
        surface.DrawRect(w - 2, 0, 2, cornerSize)
        
        -- Bottom-left corner
        surface.DrawRect(0, h - 2, cornerSize, 2)
        surface.DrawRect(0, h - cornerSize, 2, cornerSize)
        
        -- Bottom-right corner
        surface.DrawRect(w - cornerSize, h - 2, cornerSize, 2)
        surface.DrawRect(w - 2, h - cornerSize, 2, cornerSize)
    end
end

-- Console commands
concommand.Add("asc_effects_reload", function()
    ASC.AdvancedEffects.Initialize()
    print("[Advanced Space Combat] Advanced effects system reloaded")
end)

concommand.Add("asc_effects_test", function()
    print("[Advanced Space Combat] Testing advanced effects...")
    -- Create a test panel with effects
    local testFrame = vgui.Create("DFrame")
    testFrame:SetSize(400, 300)
    testFrame:SetTitle("Advanced Effects Test")
    testFrame:Center()
    testFrame:MakePopup()
    
    ASC.AdvancedEffects.EnhanceVGUIElement(testFrame)
end)

-- Initialize on client
hook.Add("Initialize", "ASC_AdvancedEffects_Init", function()
    ASC.AdvancedEffects.Initialize()
end)

print("[Advanced Space Combat] Advanced Theme Effects System loaded successfully!")
