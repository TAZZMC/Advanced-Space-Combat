-- Master Hyperdrive Jump Effect - ALL FEATURES COMBINED

function EFFECT:Init(data)
    local pos = data:GetOrigin()
    local magnitude = data:GetMagnitude() -- 1 for origin, 2 for destination, 3 for Stargate initiation, 4 for window opening, 5 for exit
    local scale = data:GetScale() -- Efficiency multiplier

    self.Position = pos
    self.IsOrigin = magnitude == 1
    self.IsDestination = magnitude == 2
    self.IsStargateInitiation = magnitude == 3
    self.IsStargateWindow = magnitude == 4
    self.IsStargateExit = magnitude == 5
    self.EfficiencyScale = scale or 1

    -- Adjust lifetime based on effect type
    if self.IsStargateInitiation then
        self.LifeTime = 3 * self.EfficiencyScale -- Initiation phase
    elseif self.IsStargateWindow then
        self.LifeTime = 2 * self.EfficiencyScale -- Window opening phase
    elseif self.IsStargateExit then
        self.LifeTime = 1.5 * self.EfficiencyScale -- Exit phase
    else
        self.LifeTime = 4 * self.EfficiencyScale -- Standard effect
    end

    self.DieTime = CurTime() + self.LifeTime

    -- Create massive dynamic light for master effect
    local dlight = DynamicLight(self:EntIndex())
    if dlight then
        dlight.pos = pos
        dlight.r = 200
        dlight.g = 220
        dlight.b = 255
        dlight.brightness = 12 * self.EfficiencyScale
        dlight.decay = 2000
        dlight.size = 1200 * self.EfficiencyScale
        dlight.dietime = CurTime() + 2
    end

    -- Create master particle effects
    self:CreateMasterParticles()

    -- Enhanced screen shake
    for _, ply in ipairs(player.GetAll()) do
        if ply:GetPos():Distance(pos) < 2000 then
            local intensity = math.max(0.1, 1 - (ply:GetPos():Distance(pos) / 2000))
            util.ScreenShake(pos, intensity * 20 * self.EfficiencyScale, 10, 4, 2000)
        end
    end

    -- Master sound effects based on stage
    if self.IsStargateInitiation then
        -- Stage 1: Initiation/Charging sounds
        sound.Play("ambient/energy/whiteflash.wav", pos, 75, 60)
        timer.Simple(0.5, function()
            sound.Play("ambient/energy/spark6.wav", pos, 70, 40)
        end)
        timer.Simple(1.5, function()
            sound.Play("ambient/energy/zap7.wav", pos, 65, 35)
        end)
    elseif self.IsStargateWindow then
        -- Stage 2: Window opening sounds
        sound.Play("ambient/energy/zap9.wav", pos, 85, 120)
        timer.Simple(0.5, function()
            sound.Play("ambient/explosions/explode_4.wav", pos, 75, 150)
        end)
        timer.Simple(1.0, function()
            sound.Play("ambient/energy/spark6.wav", pos, 70, 90)
        end)
    elseif self.IsStargateExit then
        -- Stage 4: Exit sounds
        sound.Play("ambient/energy/whiteflash.wav", pos, 90, 140)
        timer.Simple(0.3, function()
            sound.Play("ambient/energy/spark6.wav", pos, 80, 100)
        end)
        timer.Simple(1.0, function()
            sound.Play("ambient/energy/zap7.wav", pos, 70, 110)
        end)
    elseif self.IsOrigin then
        -- Standard origin sounds
        sound.Play("ambient/energy/whiteflash.wav", pos, 100, 60)
        timer.Simple(0.2, function()
            sound.Play("ambient/energy/spark6.wav", pos, 100, 40)
        end)
        timer.Simple(0.5, function()
            sound.Play("ambient/energy/zap7.wav", pos, 100, 30)
        end)
        timer.Simple(1.0, function()
            sound.Play("ambient/explosions/explode_4.wav", pos, 90, 200)
        end)
    else
        -- Standard destination sounds
        sound.Play("ambient/energy/zap9.wav", pos, 100, 150)
        sound.Play("ambient/explosions/explode_4.wav", pos, 95, 190)
        timer.Simple(0.1, function()
            sound.Play("ambient/energy/whiteflash.wav", pos, 90, 130)
        end)
        timer.Simple(0.3, function()
            sound.Play("ambient/energy/spark6.wav", pos, 85, 140)
        end)
    end
end

function EFFECT:CreateMasterParticles()
    local emitter = ParticleEmitter(self.Position)
    if not emitter then return end

    -- Massive energy burst particles
    for i = 1, 120 * self.EfficiencyScale do
        local particle = emitter:Add("effects/spark", self.Position)
        if particle then
            particle:SetVelocity(VectorRand() * 500 * self.EfficiencyScale)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(2, 4))
            particle:SetStartAlpha(255)
            particle:SetEndAlpha(0)
            particle:SetStartSize(math.Rand(4, 15) * self.EfficiencyScale)
            particle:SetEndSize(0)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-10, 10))
            particle:SetColor(200, 220, 255)
            particle:SetGravity(Vector(0, 0, -100))
            particle:SetAirResistance(40)
        end
    end

    -- Master energy vortex (combining Stargate-style with enhanced effects)
    for i = 1, 80 * self.EfficiencyScale do
        local angle = (i / 80) * 360 * 4 -- Multiple spirals
        local radius = math.Rand(30, 150) * self.EfficiencyScale
        local height = math.Rand(-80, 80) * self.EfficiencyScale

        local dir = Vector(
            math.cos(math.rad(angle)) * radius,
            math.sin(math.rad(angle)) * radius,
            height
        ):GetNormalized()

        local particle = emitter:Add("effects/energyball", self.Position + dir * 40)
        if particle then
            particle:SetVelocity(dir * 400 * self.EfficiencyScale)
            particle:SetLifeTime(0)
            particle:SetDieTime(3)
            particle:SetStartAlpha(220)
            particle:SetEndAlpha(0)
            particle:SetStartSize(10 * self.EfficiencyScale)
            particle:SetEndSize(25 * self.EfficiencyScale)
            particle:SetColor(150, 200, 255)
            particle:SetGravity(Vector(0, 0, 0))
            particle:SetAirResistance(25)
        end
    end

    -- Wiremod-style electric arcs
    for i = 1, 60 * self.EfficiencyScale do
        local particle = emitter:Add("effects/spark", self.Position + VectorRand() * 80)
        if particle then
            particle:SetVelocity(VectorRand() * 300)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 2.5))
            particle:SetStartAlpha(200)
            particle:SetEndAlpha(0)
            particle:SetStartSize(3)
            particle:SetEndSize(12)
            particle:SetColor(0, 150, 255) -- Blue electric
            particle:SetGravity(Vector(0, 0, 0))
        end
    end

    -- Spacebuild-style resource particles
    for i = 1, 40 * self.EfficiencyScale do
        local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 60)
        if particle then
            particle:SetVelocity(VectorRand() * 200)
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(2, 3.5))
            particle:SetStartAlpha(180)
            particle:SetEndAlpha(0)
            particle:SetStartSize(6)
            particle:SetEndSize(18)

            -- Cycle through resource colors
            if i % 3 == 0 then
                particle:SetColor(255, 255, 0) -- Power (yellow)
            elseif i % 3 == 1 then
                particle:SetColor(0, 255, 255) -- Oxygen (cyan)
            else
                particle:SetColor(100, 150, 255) -- Coolant (blue)
            end

            particle:SetGravity(Vector(0, 0, -50))
            particle:SetAirResistance(30)
        end
    end

    -- Ancient/Stargate golden particles (efficiency bonus)
    if self.EfficiencyScale > 1.2 then
        for i = 1, 50 do
            local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 70)
            if particle then
                particle:SetVelocity(VectorRand() * 250)
                particle:SetLifeTime(0)
                particle:SetDieTime(math.Rand(3, 5))
                particle:SetStartAlpha(200)
                particle:SetEndAlpha(0)
                particle:SetStartSize(8)
                particle:SetEndSize(20)
                particle:SetColor(255, 215, 0) -- Ancient gold
                particle:SetGravity(Vector(0, 0, -40))
                particle:SetAirResistance(35)
            end
        end
    end

    -- Master energy column
    for i = 1, 50 * self.EfficiencyScale do
        local particle = emitter:Add("effects/energyball", self.Position + VectorRand() * 30)
        if particle then
            particle:SetVelocity(Vector(
                math.Rand(-50, 50),
                math.Rand(-50, 50),
                math.Rand(400, 800) * self.EfficiencyScale
            ))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(3, 5))
            particle:SetStartAlpha(240)
            particle:SetEndAlpha(0)
            particle:SetStartSize(8 * self.EfficiencyScale)
            particle:SetEndSize(22 * self.EfficiencyScale)
            particle:SetColor(180, 200, 255)
            particle:SetGravity(Vector(0, 0, -60))
            particle:SetAirResistance(20)
        end
    end

    emitter:Finish()
end

function EFFECT:Think()
    return self.DieTime > CurTime()
end

function EFFECT:Render()
    local timeLeft = self.DieTime - CurTime()
    local progress = 1 - (timeLeft / self.LifeTime)
    local alpha = timeLeft / self.LifeTime

    if alpha <= 0 then return end

    -- Draw master energy portal effect
    local size = (200 * (1 - progress) + 120) * self.EfficiencyScale
    local color = Color(180, 210, 255, 255 * alpha)

    render.SetMaterial(Material("effects/energyball"))
    render.DrawSprite(self.Position, size, size, color)

    -- Draw enhanced event horizon
    local horizonSize = size * 1.8
    local horizonColor = Color(150, 180, 255, 180 * alpha)
    render.SetMaterial(Material("hyperdrive/jump_portal"))
    render.DrawSprite(self.Position, horizonSize, horizonSize, horizonColor)

    -- Draw multiple glow layers
    render.SetMaterial(Material("sprites/light_glow02_add"))
    render.DrawSprite(self.Position, size * 3, size * 3, Color(100, 140, 255, 60 * alpha))
    render.DrawSprite(self.Position, size * 2, size * 2, Color(150, 180, 255, 100 * alpha))

    -- Draw master distortion rings
    for i = 1, 8 do
        local ringSize = size * (1 + i * 0.3) * (1 - alpha * 0.2)
        local ringAlpha = alpha * (1 - i * 0.1)
        local ringColor = Color(120, 160, 255, 30 * ringAlpha)
        render.DrawSprite(self.Position + Vector(0, 0, i * 30), ringSize, ringSize, ringColor)
    end

    -- Efficiency-based enhancement effects
    if self.EfficiencyScale > 1.2 then
        -- Ancient technology golden spirals
        local time = CurTime()
        for i = 1, 6 do
            local angle = (time * 120 + i * 60) % 360
            local spiralRadius = size * 0.9
            local spiralPos = self.Position + Vector(
                math.cos(math.rad(angle)) * spiralRadius,
                math.sin(math.rad(angle)) * spiralRadius,
                math.sin(time * 3 + i) * 25
            )
            local spiralColor = Color(255, 215, 0, 220 * alpha)
            render.DrawSprite(spiralPos, 30, 30, spiralColor)
        end

        -- Central master symbol effect
        local symbolSize = size * 0.7
        local symbolColor = Color(255, 255, 255, 200 * alpha)
        render.SetMaterial(Material("hyperdrive/engine_glow"))
        render.DrawSprite(self.Position, symbolSize, symbolSize, symbolColor)
    end

    -- Wiremod electric effects
    local time = CurTime()
    for i = 1, 4 do
        local arcAngle = (time * 200 + i * 90) % 360
        local arcRadius = size * 0.6
        local arcPos = self.Position + Vector(
            math.cos(math.rad(arcAngle)) * arcRadius,
            math.sin(math.rad(arcAngle)) * arcRadius,
            math.sin(time * 5 + i) * 15
        )
        local arcColor = Color(0, 150, 255, 180 * alpha)
        render.DrawSprite(arcPos, 20, 20, arcColor)
    end

    -- Spacebuild resource indicators
    if self.EfficiencyScale > 1.0 then
        local resourcePositions = {
            Vector(size * 0.4, 0, 0), -- Power
            Vector(-size * 0.4, 0, 0), -- Oxygen
            Vector(0, size * 0.4, 0), -- Coolant
        }
        local resourceColors = {
            Color(255, 255, 0, 150 * alpha), -- Power (yellow)
            Color(0, 255, 255, 150 * alpha), -- Oxygen (cyan)
            Color(100, 150, 255, 150 * alpha), -- Coolant (blue)
        }

        for i, pos in ipairs(resourcePositions) do
            render.DrawSprite(self.Position + pos, 40, 40, resourceColors[i])
        end
    end
end
