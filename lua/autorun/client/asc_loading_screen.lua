-- Advanced Space Combat - Loading Screen System v1.0.0
-- Professional loading screen with space combat theme and Stargate-inspired effects

print("[Advanced Space Combat] Loading Screen System v1.0.0 - Initializing...")

-- Initialize namespace
ASC = ASC or {}
ASC.LoadingScreen = ASC.LoadingScreen or {}

-- Configuration
ASC.LoadingScreen.Config = {
    -- Visual Settings
    EnableAnimations = true,
    EnableParticles = true,
    EnableSoundEffects = true,
    ShowProgressDetails = true,
    ShowResourceCounts = true,
    
    -- Animation Settings
    FadeSpeed = 2.0,
    LogoRotationSpeed = 30,
    ParticleCount = 50,
    ProgressBarSpeed = 1.5,
    
    -- Colors (Space Combat Theme)
    BackgroundColor = Color(5, 10, 20, 255),
    PrimaryColor = Color(41, 128, 185, 255),
    AccentColor = Color(155, 89, 182, 255),
    SuccessColor = Color(39, 174, 96, 255),
    TextColor = Color(255, 255, 255, 255),
    ProgressBarColor = Color(100, 150, 255, 255),
    
    -- Layout
    LogoSize = 128,
    ProgressBarWidth = 600,
    ProgressBarHeight = 20,
    TextSpacing = 30
}

-- Loading state
ASC.LoadingScreen.State = {
    Active = false,
    Progress = 0,
    Stage = "Initializing Advanced Space Combat...",
    StartTime = 0,
    FadeAlpha = 0,
    LogoRotation = 0,
    Particles = {},
    
    -- Resource tracking
    Resources = {
        Models = { Loaded = 0, Total = 0 },
        Materials = { Loaded = 0, Total = 0 },
        Sounds = { Loaded = 0, Total = 0 },
        Effects = { Loaded = 0, Total = 0 }
    },
    
    -- Animation states
    Animations = {
        ProgressBar = 0,
        TextFade = 0,
        ParticleTime = 0
    }
}

-- Materials (will be created if missing)
ASC.LoadingScreen.Materials = {
    Background = nil,
    Logo = nil,
    ProgressBar = nil,
    Particle = nil
}

-- Initialize materials
function ASC.LoadingScreen.InitializeMaterials()
    -- Create fallback materials if files don't exist
    ASC.LoadingScreen.Materials.Background = Material("gui/gradient")
    ASC.LoadingScreen.Materials.Logo = Material("icon16/star.png")
    ASC.LoadingScreen.Materials.ProgressBar = Material("gui/gradient_up")
    ASC.LoadingScreen.Materials.Particle = Material("effects/spark")
    
    print("[Advanced Space Combat] Loading screen materials initialized")
end

-- Particle system for background effects
function ASC.LoadingScreen.InitializeParticles()
    ASC.LoadingScreen.State.Particles = {}
    
    for i = 1, ASC.LoadingScreen.Config.ParticleCount do
        table.insert(ASC.LoadingScreen.State.Particles, {
            x = math.random(0, ScrW()),
            y = math.random(0, ScrH()),
            speed = math.random(10, 50),
            size = math.random(1, 3),
            alpha = math.random(50, 150)
        })
    end
end

-- Update particle positions
function ASC.LoadingScreen.UpdateParticles()
    if not ASC.LoadingScreen.Config.EnableParticles then return end
    
    local frameTime = FrameTime()
    
    for _, particle in ipairs(ASC.LoadingScreen.State.Particles) do
        particle.x = particle.x - particle.speed * frameTime
        
        -- Reset particle when it goes off screen
        if particle.x < -10 then
            particle.x = ScrW() + 10
            particle.y = math.random(0, ScrH())
        end
    end
end

-- Show loading screen
function ASC.LoadingScreen.Show()
    ASC.LoadingScreen.State.Active = true
    ASC.LoadingScreen.State.StartTime = CurTime()
    ASC.LoadingScreen.State.FadeAlpha = 0
    ASC.LoadingScreen.State.Progress = 0
    
    ASC.LoadingScreen.InitializeMaterials()
    ASC.LoadingScreen.InitializeParticles()
    
    -- Play loading sound
    if ASC.LoadingScreen.Config.EnableSoundEffects then
        surface.PlaySound("ambient/atmosphere/ambience_base.wav")
    end
    
    print("[Advanced Space Combat] Loading screen activated")
end

-- Hide loading screen
function ASC.LoadingScreen.Hide()
    ASC.LoadingScreen.State.Active = false
    print("[Advanced Space Combat] Loading screen deactivated")
end

-- Update progress
function ASC.LoadingScreen.SetProgress(progress, stage, resourceType, resourceCount)
    ASC.LoadingScreen.State.Progress = math.Clamp(progress or 0, 0, 100)
    ASC.LoadingScreen.State.Stage = stage or ASC.LoadingScreen.State.Stage
    
    -- Update resource counts
    if resourceType and resourceCount then
        if ASC.LoadingScreen.State.Resources[resourceType] then
            ASC.LoadingScreen.State.Resources[resourceType].Loaded = resourceCount.loaded or 0
            ASC.LoadingScreen.State.Resources[resourceType].Total = resourceCount.total or 0
        end
    end
end

-- Draw background with space theme
function ASC.LoadingScreen.DrawBackground()
    local config = ASC.LoadingScreen.Config
    local scrW, scrH = ScrW(), ScrH()
    
    -- Draw gradient background
    surface.SetMaterial(ASC.LoadingScreen.Materials.Background)
    surface.SetDrawColor(config.BackgroundColor)
    surface.DrawTexturedRect(0, 0, scrW, scrH)
    
    -- Draw animated particles
    if config.EnableParticles then
        ASC.LoadingScreen.UpdateParticles()
        
        for _, particle in ipairs(ASC.LoadingScreen.State.Particles) do
            surface.SetDrawColor(255, 255, 255, particle.alpha)
            surface.DrawRect(particle.x, particle.y, particle.size, particle.size)
        end
    end
end

-- Draw logo with rotation animation
function ASC.LoadingScreen.DrawLogo()
    if not ASC.LoadingScreen.Config.EnableAnimations then return end
    
    local config = ASC.LoadingScreen.Config
    local state = ASC.LoadingScreen.State
    local scrW, scrH = ScrW(), ScrH()
    
    -- Update rotation
    state.LogoRotation = state.LogoRotation + config.LogoRotationSpeed * FrameTime()
    if state.LogoRotation >= 360 then
        state.LogoRotation = 0
    end
    
    -- Draw rotating logo
    local logoX = scrW / 2
    local logoY = scrH / 2 - 100
    
    surface.SetMaterial(ASC.LoadingScreen.Materials.Logo)
    surface.SetDrawColor(config.PrimaryColor.r, config.PrimaryColor.g, config.PrimaryColor.b, state.FadeAlpha)
    
    -- Simple rotation effect (GMod doesn't have easy texture rotation, so we'll use a pulsing effect instead)
    local pulse = math.sin(CurTime() * 3) * 0.2 + 1
    local size = config.LogoSize * pulse
    
    surface.DrawTexturedRect(logoX - size/2, logoY - size/2, size, size)
end

-- Draw progress bar
function ASC.LoadingScreen.DrawProgressBar()
    local config = ASC.LoadingScreen.Config
    local state = ASC.LoadingScreen.State
    local scrW, scrH = ScrW(), ScrH()
    
    local barX = (scrW - config.ProgressBarWidth) / 2
    local barY = scrH / 2 + 50
    
    -- Animate progress bar
    state.Animations.ProgressBar = Lerp(FrameTime() * config.ProgressBarSpeed, 
        state.Animations.ProgressBar, state.Progress)
    
    -- Draw background
    draw.RoundedBox(8, barX - 2, barY - 2, config.ProgressBarWidth + 4, config.ProgressBarHeight + 4, 
        Color(0, 0, 0, state.FadeAlpha))
    
    -- Draw progress
    local progressWidth = (config.ProgressBarWidth * state.Animations.ProgressBar) / 100
    draw.RoundedBox(6, barX, barY, progressWidth, config.ProgressBarHeight, 
        Color(config.ProgressBarColor.r, config.ProgressBarColor.g, config.ProgressBarColor.b, state.FadeAlpha))
    
    -- Draw progress text
    local progressText = string.format("%.0f%%", state.Progress)
    surface.SetFont("DermaLarge")
    surface.SetTextColor(config.TextColor.r, config.TextColor.g, config.TextColor.b, state.FadeAlpha)
    
    local textW, textH = surface.GetTextSize(progressText)
    surface.SetTextPos(scrW / 2 - textW / 2, barY + config.ProgressBarHeight + 10)
    surface.DrawText(progressText)
end

-- Draw stage text and resource information
function ASC.LoadingScreen.DrawText()
    local config = ASC.LoadingScreen.Config
    local state = ASC.LoadingScreen.State
    local scrW, scrH = ScrW(), ScrH()
    
    -- Main stage text
    surface.SetFont("DermaDefaultBold")
    surface.SetTextColor(config.TextColor.r, config.TextColor.g, config.TextColor.b, state.FadeAlpha)
    
    local stageW, stageH = surface.GetTextSize(state.Stage)
    surface.SetTextPos(scrW / 2 - stageW / 2, scrH / 2 + 100)
    surface.DrawText(state.Stage)
    
    -- Resource counts (if enabled)
    if config.ShowResourceCounts then
        local yOffset = 130
        surface.SetFont("DermaDefault")
        
        for resourceType, data in pairs(state.Resources) do
            if data.Total > 0 then
                local resourceText = string.format("%s: %d/%d", resourceType, data.Loaded, data.Total)
                local resW, resH = surface.GetTextSize(resourceText)
                
                surface.SetTextPos(scrW / 2 - resW / 2, scrH / 2 + yOffset)
                surface.DrawText(resourceText)
                
                yOffset = yOffset + 20
            end
        end
    end
end

-- Main drawing function
function ASC.LoadingScreen.Draw()
    if not ASC.LoadingScreen.State.Active then return end
    
    local state = ASC.LoadingScreen.State
    
    -- Update fade animation
    state.FadeAlpha = Lerp(FrameTime() * ASC.LoadingScreen.Config.FadeSpeed, state.FadeAlpha, 255)
    
    -- Draw all elements
    ASC.LoadingScreen.DrawBackground()
    ASC.LoadingScreen.DrawLogo()
    ASC.LoadingScreen.DrawProgressBar()
    ASC.LoadingScreen.DrawText()
end

-- Hook into HUD painting
hook.Add("HUDPaint", "ASC_LoadingScreen", function()
    ASC.LoadingScreen.Draw()
end)

-- Integration with resource loading
hook.Add("Initialize", "ASC_LoadingScreen_Init", function()
    timer.Simple(0.1, function()
        if ASC and ASC.Resources then
            -- Show loading screen when resources start loading
            ASC.LoadingScreen.Show()
            ASC.LoadingScreen.SetProgress(0, "Loading Advanced Space Combat resources...")
        end
    end)
end)

-- Console commands for testing
concommand.Add("asc_show_loading", function()
    ASC.LoadingScreen.Show()
    print("[Advanced Space Combat] Loading screen shown")
end)

concommand.Add("asc_hide_loading", function()
    ASC.LoadingScreen.Hide()
    print("[Advanced Space Combat] Loading screen hidden")
end)

concommand.Add("asc_test_loading", function()
    ASC.LoadingScreen.Show()

    -- Simulate loading progress
    local progress = 0
    local timer_name = "asc_loading_test"

    timer.Create(timer_name, 0.1, 100, function()
        progress = progress + 1

        local stage = "Initializing..."
        if progress > 25 then stage = "Loading models..."
        elseif progress > 50 then stage = "Loading materials..."
        elseif progress > 75 then stage = "Loading effects..."
        elseif progress > 90 then stage = "Finalizing..."
        end

        ASC.LoadingScreen.SetProgress(progress, stage)

        if progress >= 100 then
            timer.Remove(timer_name)
            timer.Simple(2, function()
                ASC.LoadingScreen.Hide()
            end)
        end
    end)
end)

print("[Advanced Space Combat] Loading Screen System loaded successfully!")
