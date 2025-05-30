-- Hyperdrive World Effects System
-- Creates immersive 3D effects around ships instead of HUD overlays

HYPERDRIVE = HYPERDRIVE or {}
HYPERDRIVE.WorldEffects = HYPERDRIVE.WorldEffects or {}

print("[Hyperdrive] World Effects system loading...")

-- Effect configuration
HYPERDRIVE.WorldEffects.Config = {
    -- Charging effects
    ChargingParticles = true,
    ChargingLights = true,
    ChargingSound = true,
    ChargingRadius = 500,

    -- Jump effects
    JumpFlash = true,
    JumpRipple = true,
    JumpPortal = true,
    JumpSound = true,

    -- Hyperspace window effects
    WindowSize = 200,
    WindowDuration = 3.0,
    WindowParticles = true,

    -- Starlines effects
    StarlinesCount = 50,
    StarlinesLength = 1000,
    StarlinesSpeed = 2000,

    -- Energy effects
    EnergyArcs = true,
    EnergyGlow = true,
    EnergyPulse = true,

    -- Ship-based effects
    ShipGlow = true,
    ShipTrail = true,
    ShipDistortion = true
}

-- Active effects tracking
HYPERDRIVE.WorldEffects.ActiveEffects = {}
HYPERDRIVE.WorldEffects.EffectEntities = {}

-- Create charging effects around ship
function HYPERDRIVE.WorldEffects.CreateChargingEffects(engine, ship)
    if not IsValid(engine) or not ship then return end

    local effectId = "charging_" .. engine:EntIndex()
    local shipCenter = ship:GetCenter()
    local shipBounds = {ship:GetBounds()}
    local shipSize = (shipBounds[2] - shipBounds[1]):Length()

    -- Store effect data
    HYPERDRIVE.WorldEffects.ActiveEffects[effectId] = {
        type = "charging",
        engine = engine,
        ship = ship,
        startTime = CurTime(),
        center = shipCenter,
        size = shipSize,
        entities = ship:GetEntities(),
        players = ship:GetPlayers()
    }

    -- Create energy buildup particles around ship
    if HYPERDRIVE.WorldEffects.Config.ChargingParticles then
        HYPERDRIVE.WorldEffects.CreateEnergyBuildupParticles(shipCenter, shipSize)
    end

    -- Create energy arcs between ship entities
    if HYPERDRIVE.WorldEffects.Config.EnergyArcs then
        HYPERDRIVE.WorldEffects.CreateEnergyArcs(ship:GetEntities())
    end

    -- Create pulsing glow around ship
    if HYPERDRIVE.WorldEffects.Config.EnergyGlow then
        HYPERDRIVE.WorldEffects.CreateShipGlow(ship, Color(0, 100, 255, 100))
    end

    -- Play charging sound at ship center
    if HYPERDRIVE.WorldEffects.Config.ChargingSound then
        sound.Play("ambient/energy/whiteflash.wav", shipCenter, 75, 80)
    end

    print("[Hyperdrive] Created charging effects for ship at " .. tostring(shipCenter))
end

-- Create hyperspace window effect around ship
function HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(engine, ship, stage)
    if not IsValid(engine) or not ship then return end

    local effectId = "window_" .. engine:EntIndex()
    local shipCenter = ship:GetCenter()
    local shipBounds = {ship:GetBounds()}
    local shipSize = (shipBounds[2] - shipBounds[1]):Length()
    local windowSize = math.max(shipSize * 1.5, HYPERDRIVE.WorldEffects.Config.WindowSize)

    -- Create swirling energy portal
    local portalEffect = ents.Create("env_sprite")
    if IsValid(portalEffect) then
        portalEffect:SetPos(shipCenter + Vector(0, 0, shipSize * 0.3))
        portalEffect:SetKeyValue("model", "sprites/blueglow2.vmt")
        portalEffect:SetKeyValue("scale", tostring(windowSize / 100))
        portalEffect:SetKeyValue("rendermode", "5")
        portalEffect:SetKeyValue("rendercolor", "100 150 255")
        portalEffect:Spawn()

        -- Store for cleanup
        table.insert(HYPERDRIVE.WorldEffects.EffectEntities, portalEffect)

        -- Remove after duration
        timer.Simple(HYPERDRIVE.WorldEffects.Config.WindowDuration, function()
            if IsValid(portalEffect) then
                portalEffect:Remove()
            end
        end)
    end

    -- Create particle effects around the window
    if HYPERDRIVE.WorldEffects.Config.WindowParticles then
        HYPERDRIVE.WorldEffects.CreateWindowParticles(shipCenter, windowSize, stage)
    end

    -- Create energy ripples
    if HYPERDRIVE.WorldEffects.Config.JumpRipple then
        HYPERDRIVE.WorldEffects.CreateEnergyRipples(shipCenter, windowSize)
    end

    -- Play window opening sound
    if HYPERDRIVE.WorldEffects.Config.JumpSound then
        local soundFile = "ambient/levels/labs/electric_explosion1.wav"
        if stage == "enter" then
            soundFile = "ambient/energy/whiteflash.wav"
        elseif stage == "exit" then
            soundFile = "ambient/energy/newspark04.wav"
        end
        sound.Play(soundFile, shipCenter, 85, 100)
    end

    print("[Hyperdrive] Created hyperspace window (" .. stage .. ") at " .. tostring(shipCenter))
end

-- Create starlines effect during hyperspace travel
function HYPERDRIVE.WorldEffects.CreateStarlinesEffect(engine, ship)
    if not IsValid(engine) or not ship then return end

    local shipCenter = ship:GetCenter()
    local shipVelocity = ship:GetVelocity()
    local shipOrientation = ship:GetOrientation()

    -- Create starlines around ship
    for i = 1, HYPERDRIVE.WorldEffects.Config.StarlinesCount do
        local angle = (i / HYPERDRIVE.WorldEffects.Config.StarlinesCount) * 360
        local radius = math.random(100, 500)
        local height = math.random(-200, 200)

        local startPos = shipCenter + Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            height
        )

        local endPos = startPos + shipOrientation:Forward() * HYPERDRIVE.WorldEffects.Config.StarlinesLength

        -- Create starline effect
        local starline = ents.Create("env_beam")
        if IsValid(starline) then
            starline:SetPos(startPos)
            starline:SetKeyValue("renderamt", "255")
            starline:SetKeyValue("rendercolor", "255 255 255")
            starline:SetKeyValue("life", "0.5")
            starline:SetKeyValue("BoltWidth", "2")
            starline:SetKeyValue("NoiseAmplitude", "0")
            starline:SetKeyValue("texture", "sprites/laserbeam.spr")
            starline:SetKeyValue("TextureScroll", tostring(HYPERDRIVE.WorldEffects.Config.StarlinesSpeed))
            starline:Spawn()

            -- Set end position
            starline:SetKeyValue("LightningEnd", tostring(endPos))

            -- Store for cleanup
            table.insert(HYPERDRIVE.WorldEffects.EffectEntities, starline)

            -- Remove after short duration
            timer.Simple(0.5, function()
                if IsValid(starline) then
                    starline:Remove()
                end
            end)
        end
    end

    print("[Hyperdrive] Created starlines effect around ship")
end

-- Create energy buildup particles
function HYPERDRIVE.WorldEffects.CreateEnergyBuildupParticles(center, size)
    -- Create multiple particle emitters around the ship
    for i = 1, 8 do
        local angle = (i / 8) * 360
        local radius = size * 0.6
        local particlePos = center + Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            math.random(-size * 0.3, size * 0.3)
        )

        -- Create particle effect
        local particle = ents.Create("info_particle_system")
        if IsValid(particle) then
            particle:SetPos(particlePos)
            particle:SetKeyValue("effect_name", "electrical_arc_01_system")
            particle:SetKeyValue("start_active", "1")
            particle:Spawn()
            particle:Activate()

            -- Store for cleanup
            table.insert(HYPERDRIVE.WorldEffects.EffectEntities, particle)

            -- Remove after 3 seconds
            timer.Simple(3, function()
                if IsValid(particle) then
                    particle:Remove()
                end
            end)
        end
    end
end

-- Create energy arcs between ship entities
function HYPERDRIVE.WorldEffects.CreateEnergyArcs(entities)
    if #entities < 2 then return end

    -- Create arcs between random pairs of entities
    local arcCount = math.min(10, #entities / 2)

    for i = 1, arcCount do
        local ent1 = entities[math.random(1, #entities)]
        local ent2 = entities[math.random(1, #entities)]

        if IsValid(ent1) and IsValid(ent2) and ent1 ~= ent2 then
            local arc = ents.Create("env_beam")
            if IsValid(arc) then
                arc:SetPos(ent1:GetPos())
                arc:SetKeyValue("renderamt", "150")
                arc:SetKeyValue("rendercolor", "100 150 255")
                arc:SetKeyValue("life", "0.3")
                arc:SetKeyValue("BoltWidth", "3")
                arc:SetKeyValue("NoiseAmplitude", "10")
                arc:SetKeyValue("texture", "sprites/physbeam.spr")
                arc:Spawn()

                -- Set end entity
                arc:SetKeyValue("LightningEnd", tostring(ent2:GetPos()))

                -- Store for cleanup
                table.insert(HYPERDRIVE.WorldEffects.EffectEntities, arc)

                -- Remove after duration
                timer.Simple(0.3, function()
                    if IsValid(arc) then
                        arc:Remove()
                    end
                end)
            end
        end
    end
end

-- Create glowing effect around ship
function HYPERDRIVE.WorldEffects.CreateShipGlow(ship, color)
    local entities = ship:GetEntities()

    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            -- Create glow sprite above entity
            local glow = ents.Create("env_sprite")
            if IsValid(glow) then
                local entPos = ent:GetPos()
                local entBounds = ent:OBBMaxs() - ent:OBBMins()
                local glowPos = entPos + Vector(0, 0, entBounds.z + 20)

                glow:SetPos(glowPos)
                glow:SetKeyValue("model", "sprites/glow04.vmt")
                glow:SetKeyValue("scale", "0.5")
                glow:SetKeyValue("rendermode", "5")
                glow:SetKeyValue("rendercolor", color.r .. " " .. color.g .. " " .. color.b)
                glow:SetKeyValue("renderamt", tostring(color.a))
                glow:Spawn()

                -- Parent to entity so it follows
                glow:SetParent(ent)

                -- Store for cleanup
                table.insert(HYPERDRIVE.WorldEffects.EffectEntities, glow)

                -- Remove after 5 seconds
                timer.Simple(5, function()
                    if IsValid(glow) then
                        glow:Remove()
                    end
                end)
            end
        end
    end
end

-- Create window particles
function HYPERDRIVE.WorldEffects.CreateWindowParticles(center, size, stage)
    local particleCount = math.min(20, size / 10)

    for i = 1, particleCount do
        local angle = (i / particleCount) * 360
        local radius = size * 0.8
        local particlePos = center + Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            math.random(-size * 0.2, size * 0.2)
        )

        -- Create swirling particle effect
        local particle = ents.Create("info_particle_system")
        if IsValid(particle) then
            particle:SetPos(particlePos)

            local effectName = "electrical_arc_01_system"
            if stage == "travel" then
                effectName = "fire_medium_01"
            elseif stage == "exit" then
                effectName = "explosion_turret_break"
            end

            particle:SetKeyValue("effect_name", effectName)
            particle:SetKeyValue("start_active", "1")
            particle:Spawn()
            particle:Activate()

            -- Store for cleanup
            table.insert(HYPERDRIVE.WorldEffects.EffectEntities, particle)

            -- Remove after duration
            timer.Simple(HYPERDRIVE.WorldEffects.Config.WindowDuration, function()
                if IsValid(particle) then
                    particle:Remove()
                end
            end)
        end
    end
end

-- Create energy ripples
function HYPERDRIVE.WorldEffects.CreateEnergyRipples(center, size)
    -- Create expanding energy rings
    for i = 1, 3 do
        timer.Simple(i * 0.3, function()
            local ripple = ents.Create("env_sprite")
            if IsValid(ripple) then
                ripple:SetPos(center)
                ripple:SetKeyValue("model", "sprites/blueglow2.vmt")
                ripple:SetKeyValue("scale", "1")
                ripple:SetKeyValue("rendermode", "5")
                ripple:SetKeyValue("rendercolor", "100 150 255")
                ripple:SetKeyValue("renderamt", "100")
                ripple:Spawn()

                -- Animate expansion
                local startTime = CurTime()
                local duration = 1.0

                timer.Create("ripple_" .. ripple:EntIndex(), 0.05, 0, function()
                    if not IsValid(ripple) then
                        timer.Remove("ripple_" .. ripple:EntIndex())
                        return
                    end

                    local elapsed = CurTime() - startTime
                    local progress = elapsed / duration

                    if progress >= 1 then
                        ripple:Remove()
                        timer.Remove("ripple_" .. ripple:EntIndex())
                        return
                    end

                    local scale = 1 + (progress * size / 50)
                    local alpha = 100 * (1 - progress)

                    ripple:SetKeyValue("scale", tostring(scale))
                    ripple:SetKeyValue("renderamt", tostring(alpha))
                end)

                -- Store for cleanup
                table.insert(HYPERDRIVE.WorldEffects.EffectEntities, ripple)
            end
        end)
    end
end

-- Clean up all effects
function HYPERDRIVE.WorldEffects.CleanupEffects()
    for _, ent in ipairs(HYPERDRIVE.WorldEffects.EffectEntities) do
        if IsValid(ent) then
            ent:Remove()
        end
    end

    HYPERDRIVE.WorldEffects.EffectEntities = {}
    HYPERDRIVE.WorldEffects.ActiveEffects = {}

    print("[Hyperdrive] Cleaned up all world effects")
end

-- Stop specific effect
function HYPERDRIVE.WorldEffects.StopEffect(effectId)
    if HYPERDRIVE.WorldEffects.ActiveEffects[effectId] then
        HYPERDRIVE.WorldEffects.ActiveEffects[effectId] = nil
        print("[Hyperdrive] Stopped effect: " .. effectId)
    end
end

-- Create Stargate-style 4-stage effects
function HYPERDRIVE.WorldEffects.CreateStargateEffects(engine, ship, stage)
    if not IsValid(engine) or not ship then return end

    local shipCenter = ship:GetCenter()
    local shipBounds = {ship:GetBounds()}
    local shipSize = (shipBounds[2] - shipBounds[1]):Length()

    if stage == "initiation" then
        -- Stage 1: Energy buildup and coordinate calculation
        HYPERDRIVE.WorldEffects.CreateChargingEffects(engine, ship)

        -- Add coordinate calculation effects
        for i = 1, 5 do
            timer.Simple(i * 0.2, function()
                if IsValid(engine) then
                    local coord = ents.Create("env_sprite")
                    if IsValid(coord) then
                        local angle = (i / 5) * 360
                        local radius = shipSize * 0.4
                        local pos = shipCenter + Vector(
                            math.cos(math.rad(angle)) * radius,
                            math.sin(math.rad(angle)) * radius,
                            shipSize * 0.2
                        )

                        coord:SetPos(pos)
                        coord:SetKeyValue("model", "sprites/yellowglow2.vmt")
                        coord:SetKeyValue("scale", "0.3")
                        coord:SetKeyValue("rendermode", "5")
                        coord:SetKeyValue("rendercolor", "255 255 0")
                        coord:Spawn()

                        table.insert(HYPERDRIVE.WorldEffects.EffectEntities, coord)

                        timer.Simple(2, function()
                            if IsValid(coord) then coord:Remove() end
                        end)
                    end
                end
            end)
        end

    elseif stage == "window" then
        -- Stage 2: Blue/purple swirling energy tunnel
        local portal = ents.Create("env_sprite")
        if IsValid(portal) then
            portal:SetPos(shipCenter + Vector(0, 0, shipSize * 0.4))
            portal:SetKeyValue("model", "sprites/blueglow2.vmt")
            portal:SetKeyValue("scale", tostring(shipSize / 80))
            portal:SetKeyValue("rendermode", "5")
            portal:SetKeyValue("rendercolor", "100 50 255")
            portal:Spawn()

            table.insert(HYPERDRIVE.WorldEffects.EffectEntities, portal)

            -- Animate swirling
            local startTime = CurTime()
            timer.Create("portal_swirl_" .. portal:EntIndex(), 0.1, 0, function()
                if not IsValid(portal) then
                    timer.Remove("portal_swirl_" .. portal:EntIndex())
                    return
                end

                local elapsed = CurTime() - startTime
                if elapsed > 3 then
                    portal:Remove()
                    timer.Remove("portal_swirl_" .. portal:EntIndex())
                    return
                end

                local angle = elapsed * 180
                portal:SetAngles(Angle(0, angle, 0))
            end)
        end

        -- Create swirling particles
        HYPERDRIVE.WorldEffects.CreateWindowParticles(shipCenter, shipSize, "window")

    elseif stage == "travel" then
        -- Stage 3: Hyperspace travel with stretched starlines
        HYPERDRIVE.WorldEffects.CreateStarlinesEffect(engine, ship)

        -- Add dimensional distortion effects
        for i = 1, 10 do
            timer.Simple(i * 0.1, function()
                if IsValid(engine) then
                    local distortion = ents.Create("env_sprite")
                    if IsValid(distortion) then
                        local pos = shipCenter + VectorRand() * shipSize * 0.3
                        distortion:SetPos(pos)
                        distortion:SetKeyValue("model", "sprites/purpleglow1.vmt")
                        distortion:SetKeyValue("scale", "0.2")
                        distortion:SetKeyValue("rendermode", "5")
                        distortion:SetKeyValue("rendercolor", "150 0 255")
                        distortion:Spawn()

                        table.insert(HYPERDRIVE.WorldEffects.EffectEntities, distortion)

                        timer.Simple(0.5, function()
                            if IsValid(distortion) then distortion:Remove() end
                        end)
                    end
                end
            end)
        end

    elseif stage == "exit" then
        -- Stage 4: Light flash and system stabilization
        local flash = ents.Create("env_sprite")
        if IsValid(flash) then
            flash:SetPos(shipCenter)
            flash:SetKeyValue("model", "sprites/light_glow02.vmt")
            flash:SetKeyValue("scale", tostring(shipSize / 50))
            flash:SetKeyValue("rendermode", "5")
            flash:SetKeyValue("rendercolor", "255 255 255")
            flash:Spawn()

            table.insert(HYPERDRIVE.WorldEffects.EffectEntities, flash)

            -- Fade out flash
            local startTime = CurTime()
            timer.Create("exit_flash_" .. flash:EntIndex(), 0.05, 0, function()
                if not IsValid(flash) then
                    timer.Remove("exit_flash_" .. flash:EntIndex())
                    return
                end

                local elapsed = CurTime() - startTime
                if elapsed > 1 then
                    flash:Remove()
                    timer.Remove("exit_flash_" .. flash:EntIndex())
                    return
                end

                local alpha = 255 * (1 - elapsed)
                flash:SetKeyValue("renderamt", tostring(alpha))
            end)
        end

        -- System stabilization effects
        HYPERDRIVE.WorldEffects.CreateShipGlow(ship, Color(0, 255, 0, 100))

        -- Play exit sound
        sound.Play("ambient/energy/newspark04.wav", shipCenter, 85, 120)
    end
end

-- Create jump flash effect
function HYPERDRIVE.WorldEffects.CreateJumpFlash(center, size)
    if not HYPERDRIVE.WorldEffects.Config.JumpFlash then return end

    local flash = ents.Create("env_sprite")
    if IsValid(flash) then
        flash:SetPos(center)
        flash:SetKeyValue("model", "sprites/light_glow02.vmt")
        flash:SetKeyValue("scale", tostring(size / 100))
        flash:SetKeyValue("rendermode", "5")
        flash:SetKeyValue("rendercolor", "255 255 255")
        flash:SetKeyValue("renderamt", "255")
        flash:Spawn()

        table.insert(HYPERDRIVE.WorldEffects.EffectEntities, flash)

        -- Quick fade
        timer.Simple(0.1, function()
            if IsValid(flash) then
                flash:SetKeyValue("renderamt", "0")
                timer.Simple(0.1, function()
                    if IsValid(flash) then flash:Remove() end
                end)
            end
        end)
    end
end

-- Console command to test effects
concommand.Add("hyperdrive_test_effects", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end

    local trace = ply:GetEyeTrace()
    local ent = trace.Entity

    if not IsValid(ent) then
        ply:ChatPrint("[Hyperdrive] No entity found")
        return
    end

    -- Try to get ship for this entity
    local ship = nil
    if HYPERDRIVE.ShipCore then
        ship = HYPERDRIVE.ShipCore.GetShipByEntity(ent) or HYPERDRIVE.ShipCore.DetectShipForEngine(ent)
    end

    if not ship then
        ply:ChatPrint("[Hyperdrive] No ship detected for this entity")
        return
    end

    local effectType = args[1] or "charging"

    ply:ChatPrint("[Hyperdrive] Testing " .. effectType .. " effects...")

    if effectType == "charging" then
        HYPERDRIVE.WorldEffects.CreateChargingEffects(ent, ship)
    elseif effectType == "window" then
        HYPERDRIVE.WorldEffects.CreateHyperspaceWindow(ent, ship, "enter")
    elseif effectType == "starlines" then
        HYPERDRIVE.WorldEffects.CreateStarlinesEffect(ent, ship)
    elseif effectType == "glow" then
        HYPERDRIVE.WorldEffects.CreateShipGlow(ship, Color(0, 255, 100, 150))
    elseif effectType == "stargate" then
        local stage = args[2] or "initiation"
        HYPERDRIVE.WorldEffects.CreateStargateEffects(ent, ship, stage)
    elseif effectType == "flash" then
        HYPERDRIVE.WorldEffects.CreateJumpFlash(ship:GetCenter(), (ship:GetBounds()[2] - ship:GetBounds()[1]):Length())
    else
        ply:ChatPrint("[Hyperdrive] Available effects: charging, window, starlines, glow, stargate, flash")
        ply:ChatPrint("[Hyperdrive] Stargate stages: initiation, window, travel, exit")
    end
end)

-- Cleanup on server shutdown
hook.Add("ShutDown", "HyperdriveWorldEffectsCleanup", function()
    HYPERDRIVE.WorldEffects.CleanupEffects()
end)

print("[Hyperdrive] World Effects system loaded")
