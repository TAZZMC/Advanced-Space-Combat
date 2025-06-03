-- Advanced Space Combat - Enhanced Stargate Hyperspace Visual Effects
-- Client-side visual enhancements for the 4-stage Stargate hyperspace system

if SERVER then return end

HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.StargateVisuals = HYPERDRIVE.StargateVisuals or {}

-- Configuration for visual effects
HYPERDRIVE.StargateVisuals.Config = {
    EnableHyperspaceHUD = true,
    EnableScreenEffects = true,
    EnableParticleEffects = true,
    EnableSoundEffects = true,
    
    -- Effect intensities
    ScreenDistortionIntensity = 0.3,
    ColorModIntensity = 0.4,
    ParticleIntensity = 1.0,
    
    -- Stargate-specific settings
    WindowGlowIntensity = 0.8,
    StarlinesIntensity = 1.0,
    ExitFlashIntensity = 0.9
}

-- Current hyperspace state
local hyperspaceState = {
    inHyperspace = false,
    stage = 0,
    startTime = 0,
    travelTime = 0,
    destination = Vector(0, 0, 0)
}

-- Network message handlers
net.Receive("hyperdrive_hyperspace_enter", function()
    local travelTime = net.ReadFloat()
    local destination = net.ReadVector()
    
    hyperspaceState.inHyperspace = true
    hyperspaceState.stage = 1
    hyperspaceState.startTime = CurTime()
    hyperspaceState.travelTime = travelTime
    hyperspaceState.destination = destination
    
    HYPERDRIVE.StargateVisuals.StartHyperspaceSequence()
end)

net.Receive("hyperdrive_hyperspace_exit", function()
    hyperspaceState.inHyperspace = false
    hyperspaceState.stage = 0
    
    HYPERDRIVE.StargateVisuals.EndHyperspaceSequence()
end)

-- Start hyperspace visual sequence
function HYPERDRIVE.StargateVisuals.StartHyperspaceSequence()
    if not HYPERDRIVE.StargateVisuals.Config.EnableScreenEffects then return end
    
    -- Stage-specific visual effects
    timer.Simple(0, function() HYPERDRIVE.StargateVisuals.Stage1Effects() end)
    timer.Simple(3, function() HYPERDRIVE.StargateVisuals.Stage2Effects() end)
    timer.Simple(5, function() HYPERDRIVE.StargateVisuals.Stage3Effects() end)
end

-- Stage 1: Initiation effects
function HYPERDRIVE.StargateVisuals.Stage1Effects()
    hyperspaceState.stage = 1
    
    -- Screen shake for energy buildup
    util.ScreenShake(LocalPlayer():GetPos(), 5, 5, 3, 1000)
    
    -- Blue energy glow effect
    if HYPERDRIVE.StargateVisuals.Config.EnableScreenEffects then
        HYPERDRIVE.StargateVisuals.ApplyEnergyBuildupEffect()
    end
    
    -- Sound effect
    if HYPERDRIVE.StargateVisuals.Config.EnableSoundEffects then
        surface.PlaySound("asc/hyperspace/initiation_hum.wav")
    end
end

-- Stage 2: Window opening effects
function HYPERDRIVE.StargateVisuals.Stage2Effects()
    hyperspaceState.stage = 2
    
    -- Window opening visual distortion
    if HYPERDRIVE.StargateVisuals.Config.EnableScreenEffects then
        HYPERDRIVE.StargateVisuals.ApplyWindowOpeningEffect()
    end
    
    -- Sound effect
    if HYPERDRIVE.StargateVisuals.Config.EnableSoundEffects then
        surface.PlaySound("asc/hyperspace/window_opening.wav")
    end
end

-- Stage 3: Hyperspace travel effects
function HYPERDRIVE.StargateVisuals.Stage3Effects()
    hyperspaceState.stage = 3
    
    -- Starlines and dimensional effects
    if HYPERDRIVE.StargateVisuals.Config.EnableScreenEffects then
        HYPERDRIVE.StargateVisuals.ApplyHyperspaceTravel()
    end
    
    -- Sound effect
    if HYPERDRIVE.StargateVisuals.Config.EnableSoundEffects then
        surface.PlaySound("asc/hyperspace/travel_whoosh.wav")
    end
end

-- End hyperspace sequence
function HYPERDRIVE.StargateVisuals.EndHyperspaceSequence()
    -- Exit flash effect
    if HYPERDRIVE.StargateVisuals.Config.EnableScreenEffects then
        HYPERDRIVE.StargateVisuals.ApplyExitFlash()
    end
    
    -- Sound effect
    if HYPERDRIVE.StargateVisuals.Config.EnableSoundEffects then
        surface.PlaySound("asc/hyperspace/exit_flash.wav")
    end
    
    -- Clear effects after a delay
    timer.Simple(2, function()
        HYPERDRIVE.StargateVisuals.ClearAllEffects()
    end)
end

-- Apply energy buildup screen effect
function HYPERDRIVE.StargateVisuals.ApplyEnergyBuildupEffect()
    local effectData = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0.1,
        ["$pp_colour_addb"] = 0.2,
        ["$pp_colour_brightness"] = 0.1,
        ["$pp_colour_contrast"] = 1.1,
        ["$pp_colour_colour"] = 0.9,
        ["$pp_colour_mulr"] = 0.9,
        ["$pp_colour_mulg"] = 0.95,
        ["$pp_colour_mulb"] = 1.1
    }
    
    DrawColorModify(effectData)
end

-- Apply window opening effect
function HYPERDRIVE.StargateVisuals.ApplyWindowOpeningEffect()
    local effectData = {
        ["$pp_colour_addr"] = 0.1,
        ["$pp_colour_addg"] = 0.15,
        ["$pp_colour_addb"] = 0.3,
        ["$pp_colour_brightness"] = 0.2,
        ["$pp_colour_contrast"] = 1.2,
        ["$pp_colour_colour"] = 0.8,
        ["$pp_colour_mulr"] = 0.8,
        ["$pp_colour_mulg"] = 0.9,
        ["$pp_colour_mulb"] = 1.2
    }
    
    DrawColorModify(effectData)
end

-- Apply hyperspace travel effects
function HYPERDRIVE.StargateVisuals.ApplyHyperspaceTravel()
    local age = CurTime() - hyperspaceState.startTime
    local intensity = math.sin(age * 2) * 0.5 + 0.5
    
    local effectData = {
        ["$pp_colour_addr"] = 0.05,
        ["$pp_colour_addg"] = 0.1,
        ["$pp_colour_addb"] = 0.25,
        ["$pp_colour_brightness"] = 0.15 + intensity * 0.1,
        ["$pp_colour_contrast"] = 1.3,
        ["$pp_colour_colour"] = 0.7,
        ["$pp_colour_mulr"] = 0.7,
        ["$pp_colour_mulg"] = 0.85,
        ["$pp_colour_mulb"] = 1.3
    }
    
    DrawColorModify(effectData)
    
    -- Motion blur effect
    DrawMotionBlur(0.4, 0.8, 0.01)
end

-- Apply exit flash effect
function HYPERDRIVE.StargateVisuals.ApplyExitFlash()
    local flashIntensity = HYPERDRIVE.StargateVisuals.Config.ExitFlashIntensity
    
    local effectData = {
        ["$pp_colour_addr"] = 0.5 * flashIntensity,
        ["$pp_colour_addg"] = 0.5 * flashIntensity,
        ["$pp_colour_addb"] = 0.5 * flashIntensity,
        ["$pp_colour_brightness"] = 0.8 * flashIntensity,
        ["$pp_colour_contrast"] = 1.5,
        ["$pp_colour_colour"] = 0.5,
        ["$pp_colour_mulr"] = 1.5,
        ["$pp_colour_mulg"] = 1.5,
        ["$pp_colour_mulb"] = 1.5
    }
    
    DrawColorModify(effectData)
end

-- Clear all visual effects
function HYPERDRIVE.StargateVisuals.ClearAllEffects()
    -- Reset color modification
    local normalEffect = {
        ["$pp_colour_addr"] = 0,
        ["$pp_colour_addg"] = 0,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 1,
        ["$pp_colour_mulr"] = 1,
        ["$pp_colour_mulg"] = 1,
        ["$pp_colour_mulb"] = 1
    }
    
    DrawColorModify(normalEffect)
end

-- HUD rendering
hook.Add("HUDPaint", "HyperdriveStargateHUD", function()
    if not HYPERDRIVE.StargateVisuals.Config.EnableHyperspaceHUD then return end
    if not hyperspaceState.inHyperspace then return end
    
    local scrW, scrH = ScrW(), ScrH()
    local age = CurTime() - hyperspaceState.startTime
    local progress = age / hyperspaceState.travelTime
    
    -- Stage indicator
    local stageText = "Hyperspace Stage " .. hyperspaceState.stage
    local stageNames = {
        [1] = "Initiation",
        [2] = "Window Opening", 
        [3] = "Dimensional Transit",
        [4] = "Exit Sequence"
    }
    
    if stageNames[hyperspaceState.stage] then
        stageText = stageText .. ": " .. stageNames[hyperspaceState.stage]
    end
    
    draw.SimpleText(stageText, "DermaLarge", scrW * 0.5, scrH * 0.1, 
        Color(100, 150, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    
    -- Progress bar
    local barW, barH = 400, 20
    local barX, barY = scrW * 0.5 - barW * 0.5, scrH * 0.15
    
    draw.RoundedBox(4, barX, barY, barW, barH, Color(0, 0, 0, 150))
    draw.RoundedBox(4, barX + 2, barY + 2, (barW - 4) * progress, barH - 4, Color(100, 150, 255, 200))
    
    -- Travel time remaining
    local timeRemaining = math.max(0, hyperspaceState.travelTime - age)
    local timeText = string.format("Time Remaining: %.1fs", timeRemaining)
    
    draw.SimpleText(timeText, "DermaDefault", scrW * 0.5, scrH * 0.2,
        Color(150, 200, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)

-- Screen effect rendering
hook.Add("RenderScreenspaceEffects", "HyperdriveStargateEffects", function()
    if not HYPERDRIVE.StargateVisuals.Config.EnableScreenEffects then return end
    if not hyperspaceState.inHyperspace then return end
    
    local stage = hyperspaceState.stage
    
    if stage == 1 then
        HYPERDRIVE.StargateVisuals.ApplyEnergyBuildupEffect()
    elseif stage == 2 then
        HYPERDRIVE.StargateVisuals.ApplyWindowOpeningEffect()
    elseif stage == 3 then
        HYPERDRIVE.StargateVisuals.ApplyHyperspaceTravel()
    end
end)

print("[Advanced Space Combat] Stargate Hyperspace Visual Effects loaded")
