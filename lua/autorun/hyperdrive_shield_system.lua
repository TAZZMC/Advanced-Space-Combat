-- Hyperdrive Shield System - CAP Integration with Enhanced Audio
-- Integrates with Ship Core system and CAP bubble shields

if not HYPERDRIVE then
    HYPERDRIVE = {}
end

HYPERDRIVE.Shields = {}
HYPERDRIVE.Shields.ActiveShields = {}
HYPERDRIVE.Shields.ShieldEntities = {}
HYPERDRIVE.Shields.SoundChannels = {}

-- Enhanced Configuration
HYPERDRIVE.Shields.Config = {
    -- Shield strength settings
    MaxShieldStrength = 10000,
    RechargeRate = 100, -- Per second
    RechargeDelay = 2, -- Seconds after damage before recharge starts
    DamageReduction = 0.8, -- 80% damage reduction

    -- Visual settings
    BubbleAlpha = 80,
    BubbleColor = Color(0, 150, 255, 80), -- Blue shield
    DamageColor = Color(255, 100, 0, 120), -- Orange when damaged
    CriticalColor = Color(255, 0, 0, 150), -- Red when critical
    OverloadColor = Color(255, 255, 255, 200), -- White when overloaded

    -- Enhanced CAP Integration
    UseCapBubbles = true,
    PreferCAPShields = true,
    AutoDetectCAPShields = true,
    IntegrateWithCAPResources = true,
    CapShieldClasses = {
        -- Main CAP shields
        "shield", "shield_core_buble", "shield_core_goauld",
        "shield_core_asgard", "shield_core_atlantis",
        -- Workshop variants
        "cap_shield_generator", "cap_bubble_shield", "cap_iris_shield",
        "cap_personal_shield", "cap_asgard_shield", "cap_ancient_shield",
        -- Legacy variants
        "stargate_shield_bubble", "sg_shield_bubble", "bubble_shield"
    },
    FallbackToCustom = true,
    CAPIntegrationEnabled = true,

    -- Enhanced Sound System
    Sounds = {
        Activation = "ambient/energy/whiteflash.wav",
        Deactivation = "ambient/energy/newspark04.wav",
        Hit = {
            "ambient/energy/spark1.wav",
            "ambient/energy/spark2.wav",
            "ambient/energy/spark3.wav"
        },
        Recharge = "ambient/energy/electric_loop.wav",
        Critical = "ambient/alarms/warningbell1.wav",
        Overload = "ambient/energy/zap1.wav",
        Stabilize = "ambient/energy/newspark07.wav"
    },

    -- Audio settings
    SoundLevels = {
        Activation = 80,
        Deactivation = 75,
        Hit = 70,
        Recharge = 60,
        Critical = 85,
        Overload = 90
    },

    -- Effect settings
    HitEffectCount = 8,
    RechargeEffectCount = 5,
    CriticalEffectCount = 12,
    OverloadEffectCount = 20,

    -- Performance settings
    UpdateInterval = 0.1,
    EffectCullingDistance = 2500,
    MaxActiveShields = 25,
    SoundCullingDistance = 1500,

    -- Auto-activation settings
    AutoActivateOnCharge = true,
    AutoActivateOnJump = true,
    AutoDeactivateOnCooldown = false,
    AutoCreateShieldOnDetection = false
}

-- Shield class for individual ship shields
local ShieldClass = {}
ShieldClass.__index = ShieldClass

function ShieldClass:New(ship, generator)
    local shield = setmetatable({}, ShieldClass)

    shield.ship = ship
    shield.generator = generator
    shield.active = false
    shield.strength = HYPERDRIVE.Shields.Config.MaxShieldStrength
    shield.maxStrength = HYPERDRIVE.Shields.Config.MaxShieldStrength
    shield.lastDamageTime = 0
    shield.recharging = false
    shield.overloaded = false

    -- Visual components
    shield.bubbleEntity = nil
    shield.effectEntities = {}

    -- CAP integration
    shield.capShield = nil
    shield.capIntegrated = false

    -- Enhanced sound management
    shield.soundChannels = {}
    shield.lastSoundTime = {}
    shield.rechargeSoundChannel = nil

    return shield
end

function ShieldClass:Initialize()
    if not IsValid(self.ship) or not IsValid(self.generator) then
        return false
    end

    -- Calculate shield strength based on ship size
    local shipEntities = self.ship:GetEntities()
    local shipMass = self.ship:GetMass()

    -- Scale shield strength with ship size
    local strengthMultiplier = 1 + (#shipEntities * 0.1) + (shipMass / 10000)
    self.maxStrength = HYPERDRIVE.Shields.Config.MaxShieldStrength * strengthMultiplier
    self.strength = self.maxStrength

    -- Try to integrate with CAP shields
    self:InitializeCAPIntegration()

    -- Create shield bubble if CAP not available
    if not self.capIntegrated then
        self:CreateShieldBubble()
    end

    -- Register shield
    local shieldId = "shield_" .. self.generator:EntIndex()
    HYPERDRIVE.Shields.ActiveShields[shieldId] = self

    print("[Hyperdrive Shields] Shield initialized for " .. self.ship:GetShipType() ..
          " (Strength: " .. math.floor(self.maxStrength) .. ", CAP: " .. tostring(self.capIntegrated) .. ")")
    return true
end

function ShieldClass:InitializeCAPIntegration()
    if not HYPERDRIVE.Shields.Config.UseCapBubbles then
        return false
    end

    -- Check for CAP availability
    if not (CAP or StarGate) then
        return false
    end

    -- Try to find or create CAP shield
    local pos = self.generator:GetPos()
    local shipCenter = self.ship:GetCenter()

    -- Look for existing CAP shields nearby
    local nearbyEnts = ents.FindInSphere(shipCenter, 500)
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) then
            local class = string.lower(ent:GetClass())
            for _, capClass in ipairs(HYPERDRIVE.Shields.Config.CapShieldClasses) do
                if string.find(class, string.lower(capClass)) then
                    self.capShield = ent
                    self.capIntegrated = true
                    print("[Hyperdrive Shields] Found existing CAP shield: " .. ent:GetClass())
                    return true
                end
            end
        end
    end

    -- Try to create new CAP shield
    for _, capClass in ipairs(HYPERDRIVE.Shields.Config.CapShieldClasses) do
        if scripted_ents.GetStored(capClass) then
            local shield = ents.Create(capClass)
            if IsValid(shield) then
                shield:SetPos(shipCenter)
                shield:Spawn()

                -- Configure CAP shield
                self:ConfigureCAPShield(shield)

                self.capShield = shield
                self.capIntegrated = true

                print("[Hyperdrive Shields] Created CAP shield: " .. capClass)
                return true
            end
        end
    end

    return false
end

function ShieldClass:ConfigureCAPShield(shield)
    if not IsValid(shield) then return end

    -- Calculate shield radius based on ship bounds
    local shipBounds = {self.ship:GetBounds()}
    local shipSize = (shipBounds[2] - shipBounds[1]):Length()
    local shieldRadius = math.max(shipSize * 0.8, 100)

    -- Configure shield properties
    if shield.SetShieldRadius then
        shield:SetShieldRadius(shieldRadius)
    end

    if shield.SetShieldStrength then
        shield:SetShieldStrength(self.maxStrength)
    end

    if shield.SetShieldColor then
        local color = HYPERDRIVE.Shields.Config.BubbleColor
        shield:SetShieldColor(Vector(color.r/255, color.g/255, color.b/255))
    end

    if shield.SetShieldEnabled then
        shield:SetShieldEnabled(true)
    end

    -- Set owner if possible
    if shield.SetOwner and IsValid(self.generator.Owner) then
        shield:SetOwner(self.generator.Owner)
    end

    -- Store reference for cleanup
    table.insert(HYPERDRIVE.Shields.ShieldEntities, shield)
end

function ShieldClass:CreateShieldBubble()
    if IsValid(self.bubbleEntity) then
        self.bubbleEntity:Remove()
    end

    local shipCenter = self.ship:GetCenter()
    local shipBounds = {self.ship:GetBounds()}
    local shieldRadius = (shipBounds[2] - shipBounds[1]):Length() * 0.9

    -- Create enhanced bubble entity
    self.bubbleEntity = ents.Create("env_sprite")
    if IsValid(self.bubbleEntity) then
        self.bubbleEntity:SetPos(shipCenter)
        self.bubbleEntity:SetKeyValue("model", "sprites/bubble.vmt")
        self.bubbleEntity:SetKeyValue("scale", tostring(shieldRadius / 80))
        self.bubbleEntity:SetKeyValue("rendermode", "5")
        self.bubbleEntity:SetKeyValue("renderamt", tostring(HYPERDRIVE.Shields.Config.BubbleAlpha))

        local color = HYPERDRIVE.Shields.Config.BubbleColor
        self.bubbleEntity:SetKeyValue("rendercolor", color.r .. " " .. color.g .. " " .. color.b)

        self.bubbleEntity:Spawn()
        self.bubbleEntity:SetParent(self.generator)

        -- Store for cleanup
        table.insert(HYPERDRIVE.Shields.ShieldEntities, self.bubbleEntity)

        print("[Hyperdrive Shields] Created custom shield bubble with radius " .. math.floor(shieldRadius))
    end
end

function ShieldClass:Activate()
    if self.active then return true end

    self.active = true

    -- Activate CAP shield if integrated
    if self.capIntegrated and IsValid(self.capShield) then
        if self.capShield.Activate then
            self.capShield:Activate()
        elseif self.capShield.SetActive then
            self.capShield:SetActive(true)
        elseif self.capShield.SetShieldEnabled then
            self.capShield:SetShieldEnabled(true)
        end
    end

    -- Show bubble
    if IsValid(self.bubbleEntity) then
        self.bubbleEntity:SetNoDraw(false)
    end

    -- Enhanced activation sound and effects
    self:PlaySound("Activation")
    self:CreateActivationEffects()

    print("[Hyperdrive Shields] Shield activated for " .. self.ship:GetShipType())
    return true
end

function ShieldClass:Deactivate()
    if not self.active then return true end

    self.active = false

    -- Deactivate CAP shield if integrated
    if self.capIntegrated and IsValid(self.capShield) then
        if self.capShield.Deactivate then
            self.capShield:Deactivate()
        elseif self.capShield.SetActive then
            self.capShield:SetActive(false)
        elseif self.capShield.SetShieldEnabled then
            self.capShield:SetShieldEnabled(false)
        end
    end

    -- Hide bubble
    if IsValid(self.bubbleEntity) then
        self.bubbleEntity:SetNoDraw(true)
    end

    -- Stop all sounds
    self:StopAllSounds()

    -- Enhanced deactivation sound and effects
    self:PlaySound("Deactivation")
    self:CreateDeactivationEffects()

    print("[Hyperdrive Shields] Shield deactivated for " .. self.ship:GetShipType())
    return true
end

function ShieldClass:TakeDamage(damage, attacker, damagePos)
    if not self.active then return damage end

    -- Calculate damage reduction
    local reducedDamage = damage * (1 - HYPERDRIVE.Shields.Config.DamageReduction)
    local shieldDamage = damage - reducedDamage

    -- Apply damage to shields
    local actualShieldDamage = math.min(shieldDamage, self.strength)
    self.strength = math.max(0, self.strength - actualShieldDamage)
    self.lastDamageTime = CurTime()
    self.recharging = false

    -- Stop recharge sound
    self:StopSound("Recharge")

    -- Update CAP shield if integrated
    if self.capIntegrated and IsValid(self.capShield) then
        if self.capShield.SetShieldStrength then
            self.capShield:SetShieldStrength(self.strength)
        end
    end

    -- Enhanced hit effects and sounds
    self:CreateHitEffects(damagePos or self.ship:GetCenter(), actualShieldDamage)
    self:PlaySound("Hit")

    -- Update bubble color based on shield strength
    self:UpdateBubbleColor()

    -- Check shield status
    local strengthPercent = self.strength / self.maxStrength

    if self.strength <= 0 then
        self:OnShieldsDown()
        return reducedDamage + (shieldDamage - actualShieldDamage)
    elseif strengthPercent < 0.1 then
        self:OnShieldsOverloaded()
    elseif strengthPercent < 0.25 then
        self:OnShieldsCritical()
    end

    return reducedDamage
end

-- Enhanced sound system
function ShieldClass:PlaySound(soundType, pitch)
    local soundConfig = HYPERDRIVE.Shields.Config.Sounds[soundType]
    local levelConfig = HYPERDRIVE.Shields.Config.SoundLevels[soundType]

    if not soundConfig or not levelConfig then return end

    -- Prevent sound spam
    local currentTime = CurTime()
    if self.lastSoundTime[soundType] and currentTime - self.lastSoundTime[soundType] < 0.1 then
        return
    end
    self.lastSoundTime[soundType] = currentTime

    -- Get sound file
    local soundFile = soundConfig
    if type(soundConfig) == "table" then
        soundFile = soundConfig[math.random(#soundConfig)]
    end

    -- Play sound at ship center
    local pos = self.ship:GetCenter()
    local level = levelConfig
    local soundPitch = pitch or math.random(90, 110)

    -- Distance culling for performance
    local players = player.GetAll()
    local playSound = false
    for _, ply in ipairs(players) do
        if IsValid(ply) and ply:GetPos():DistToSqr(pos) < HYPERDRIVE.Shields.Config.SoundCullingDistance^2 then
            playSound = true
            break
        end
    end

    if playSound then
        sound.Play(soundFile, pos, level, soundPitch)
    end
end

function ShieldClass:PlayLoopingSound(soundType)
    if self.soundChannels[soundType] then return end -- Already playing

    local soundConfig = HYPERDRIVE.Shields.Config.Sounds[soundType]
    if not soundConfig then return end

    local soundFile = soundConfig
    if type(soundConfig) == "table" then
        soundFile = soundConfig[1] -- Use first sound for looping
    end

    local soundChannel = CreateSound(self.generator, soundFile)
    if soundChannel then
        soundChannel:Play()
        soundChannel:SetSoundLevel(HYPERDRIVE.Shields.Config.SoundLevels[soundType] or 70)
        self.soundChannels[soundType] = soundChannel
    end
end

function ShieldClass:StopSound(soundType)
    if self.soundChannels[soundType] then
        self.soundChannels[soundType]:Stop()
        self.soundChannels[soundType] = nil
    end
end

function ShieldClass:StopAllSounds()
    for soundType, channel in pairs(self.soundChannels) do
        if channel then
            channel:Stop()
        end
    end
    self.soundChannels = {}
end

function ShieldClass:Update()
    if not self.active then return end

    -- Handle recharging
    if self.strength < self.maxStrength then
        local timeSinceDamage = CurTime() - self.lastDamageTime

        if timeSinceDamage >= HYPERDRIVE.Shields.Config.RechargeDelay then
            if not self.recharging then
                self.recharging = true
                self:StartRechargeEffects()
            end

            -- Recharge shields
            local rechargeAmount = HYPERDRIVE.Shields.Config.RechargeRate * HYPERDRIVE.Shields.Config.UpdateInterval
            self.strength = math.min(self.maxStrength, self.strength + rechargeAmount)

            -- Update CAP shield if integrated
            if self.capIntegrated and IsValid(self.capShield) then
                if self.capShield.SetShieldStrength then
                    self.capShield:SetShieldStrength(self.strength)
                end
            end

            -- Update bubble color
            self:UpdateBubbleColor()

            -- Check if fully recharged
            if self.strength >= self.maxStrength then
                self.recharging = false
                self:StopSound("Recharge")
                self:PlaySound("Stabilize")
                self:CreateStabilizeEffects()
            end
        end
    end

    -- Update bubble position
    if IsValid(self.bubbleEntity) and self.ship then
        local shipCenter = self.ship:GetCenter()
        self.bubbleEntity:SetPos(shipCenter)
    end

    -- Clear overloaded state if shields recovered
    if self.overloaded and self.strength > self.maxStrength * 0.25 then
        self.overloaded = false
    end
end

function ShieldClass:UpdateBubbleColor()
    if not IsValid(self.bubbleEntity) then return end

    local strengthPercent = self.strength / self.maxStrength
    local color

    if self.overloaded then
        color = HYPERDRIVE.Shields.Config.OverloadColor
    elseif strengthPercent > 0.5 then
        color = HYPERDRIVE.Shields.Config.BubbleColor
    elseif strengthPercent > 0.25 then
        color = HYPERDRIVE.Shields.Config.DamageColor
    else
        color = HYPERDRIVE.Shields.Config.CriticalColor
    end

    self.bubbleEntity:SetKeyValue("rendercolor", color.r .. " " .. color.g .. " " .. color.b)
    self.bubbleEntity:SetKeyValue("renderamt", tostring(math.max(20, color.a * strengthPercent)))
end

-- Shield event handlers
function ShieldClass:OnShieldsDown()
    self:PlaySound("Critical", 80)
    self:CreateShieldsDownEffects()
    print("[Hyperdrive Shields] Shields down for " .. self.ship:GetShipType())
end

function ShieldClass:OnShieldsCritical()
    if not self.lastCriticalSound or CurTime() - self.lastCriticalSound > 3 then
        self:PlaySound("Critical")
        self.lastCriticalSound = CurTime()
    end
    self:CreateCriticalEffects()
end

function ShieldClass:OnShieldsOverloaded()
    if not self.overloaded then
        self.overloaded = true
        self:PlaySound("Overload")
        self:CreateOverloadEffects()
        print("[Hyperdrive Shields] Shields overloaded for " .. self.ship:GetShipType())
    end
end

function ShieldClass:StartRechargeEffects()
    self:PlayLoopingSound("Recharge")
    self:CreateRechargeEffects()
end

-- Enhanced effect methods
function ShieldClass:CreateActivationEffects()
    local pos = self.ship:GetCenter()
    local shipBounds = {self.ship:GetBounds()}
    local radius = (shipBounds[2] - shipBounds[1]):Length() * 0.5

    -- Energy surge effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetRadius(radius)
    effectData:SetMagnitude(3)
    util.Effect("TeslaHitBoxes", effectData)

    -- Blue energy particles
    for i = 1, 15 do
        local particlePos = pos + VectorRand() * radius * 0.8
        local effectData = EffectData()
        effectData:SetOrigin(particlePos)
        effectData:SetStart(pos)
        effectData:SetScale(2)
        util.Effect("BlueFlash", effectData)
    end

    -- Shield ripple effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetRadius(radius)
    effectData:SetScale(1)
    util.Effect("AR2Explosion", effectData)
end

function ShieldClass:CreateDeactivationEffects()
    local pos = self.ship:GetCenter()
    local shipBounds = {self.ship:GetBounds()}
    local radius = (shipBounds[2] - shipBounds[1]):Length() * 0.4

    -- Shield collapse effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetRadius(radius)
    effectData:SetMagnitude(2)
    util.Effect("Explosion", effectData)

    -- Sparks
    for i = 1, 8 do
        local sparkPos = pos + VectorRand() * radius * 0.6
        local effectData = EffectData()
        effectData:SetOrigin(sparkPos)
        effectData:SetNormal(VectorRand())
        effectData:SetScale(1)
        util.Effect("Sparks", effectData)
    end
end

function ShieldClass:CreateHitEffects(hitPos, damage)
    local effectCount = math.min(HYPERDRIVE.Shields.Config.HitEffectCount, math.ceil(damage / 100))

    for i = 1, effectCount do
        -- Impact sparks
        local effectData = EffectData()
        effectData:SetOrigin(hitPos + VectorRand() * 50)
        effectData:SetNormal(VectorRand())
        effectData:SetScale(math.random(1, 3))
        util.Effect("Sparks", effectData)

        -- Energy discharge
        local effectData = EffectData()
        effectData:SetOrigin(hitPos)
        effectData:SetStart(hitPos + VectorRand() * 100)
        effectData:SetScale(2)
        util.Effect("BlueFlash", effectData)
    end

    -- Shield ripple at hit location
    local effectData = EffectData()
    effectData:SetOrigin(hitPos)
    effectData:SetRadius(100)
    effectData:SetMagnitude(1)
    util.Effect("TeslaHitBoxes", effectData)
end

function ShieldClass:CreateRechargeEffects()
    local pos = self.ship:GetCenter()

    for i = 1, HYPERDRIVE.Shields.Config.RechargeEffectCount do
        local effectPos = pos + VectorRand() * 200
        local effectData = EffectData()
        effectData:SetOrigin(effectPos)
        effectData:SetStart(pos)
        effectData:SetScale(1)
        util.Effect("BlueFlash", effectData)
    end
end

function ShieldClass:CreateCriticalEffects()
    local pos = self.ship:GetCenter()

    for i = 1, HYPERDRIVE.Shields.Config.CriticalEffectCount do
        local effectPos = pos + VectorRand() * 150
        local effectData = EffectData()
        effectData:SetOrigin(effectPos)
        effectData:SetNormal(VectorRand())
        effectData:SetScale(2)
        util.Effect("Sparks", effectData)
    end
end

function ShieldClass:CreateOverloadEffects()
    local pos = self.ship:GetCenter()
    local shipBounds = {self.ship:GetBounds()}
    local radius = (shipBounds[2] - shipBounds[1]):Length() * 0.6

    -- Massive energy discharge
    for i = 1, HYPERDRIVE.Shields.Config.OverloadEffectCount do
        local effectPos = pos + VectorRand() * radius
        local effectData = EffectData()
        effectData:SetOrigin(effectPos)
        effectData:SetStart(pos)
        effectData:SetScale(3)
        util.Effect("BlueFlash", effectData)
    end

    -- Tesla effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetRadius(radius)
    effectData:SetMagnitude(5)
    util.Effect("TeslaHitBoxes", effectData)
end

function ShieldClass:CreateStabilizeEffects()
    local pos = self.ship:GetCenter()

    -- Gentle energy flow
    for i = 1, 5 do
        local effectPos = pos + VectorRand() * 100
        local effectData = EffectData()
        effectData:SetOrigin(effectPos)
        effectData:SetStart(pos)
        effectData:SetScale(1)
        util.Effect("BlueFlash", effectData)
    end
end

function ShieldClass:CreateShieldsDownEffects()
    local pos = self.ship:GetCenter()
    local shipBounds = {self.ship:GetBounds()}
    local radius = (shipBounds[2] - shipBounds[1]):Length() * 0.7

    -- Catastrophic failure effect
    local effectData = EffectData()
    effectData:SetOrigin(pos)
    effectData:SetRadius(radius)
    effectData:SetMagnitude(4)
    util.Effect("Explosion", effectData)

    -- Lots of sparks
    for i = 1, 20 do
        local sparkPos = pos + VectorRand() * radius
        local effectData = EffectData()
        effectData:SetOrigin(sparkPos)
        effectData:SetNormal(VectorRand())
        effectData:SetScale(3)
        util.Effect("Sparks", effectData)
    end
end

-- Main shield system functions (VALIDATES ONE CORE PER SHIP)
function HYPERDRIVE.Shields.CreateShield(generator, ship)
    if not IsValid(generator) or not ship then
        return nil, "Invalid generator or ship"
    end

    -- ENFORCE: Validate ship core uniqueness before creating shield
    if ship.core and IsValid(ship.core) and HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness then
        local valid, message = HYPERDRIVE.ShipCore.ValidateShipCoreUniqueness(ship.core)
        if not valid then
            return nil, "Cannot create shield: " .. message
        end
    end

    -- Check if shield already exists
    local shieldId = "shield_" .. generator:EntIndex()
    if HYPERDRIVE.Shields.ActiveShields[shieldId] then
        return HYPERDRIVE.Shields.ActiveShields[shieldId], "Shield already exists"
    end

    -- Create new shield
    local shield = ShieldClass:New(ship, generator)
    if shield:Initialize() then
        -- Mark shield as validated for one core per ship
        shield.coreValidated = true
        return shield, "Shield created successfully"
    else
        return nil, "Failed to initialize shield"
    end
end

function HYPERDRIVE.Shields.GetShield(generator)
    if not IsValid(generator) then return nil end

    local shieldId = "shield_" .. generator:EntIndex()
    return HYPERDRIVE.Shields.ActiveShields[shieldId]
end

function HYPERDRIVE.Shields.RemoveShield(generator)
    if not IsValid(generator) then return false end

    local shieldId = "shield_" .. generator:EntIndex()
    local shield = HYPERDRIVE.Shields.ActiveShields[shieldId]

    if shield then
        shield:Deactivate()

        -- Clean up entities
        if IsValid(shield.bubbleEntity) then
            shield.bubbleEntity:Remove()
        end

        if IsValid(shield.capShield) then
            shield.capShield:Remove()
        end

        -- Stop all sounds
        shield:StopAllSounds()

        -- Remove from active shields
        HYPERDRIVE.Shields.ActiveShields[shieldId] = nil

        return true
    end

    return false
end

function HYPERDRIVE.Shields.UpdateAllShields()
    for shieldId, shield in pairs(HYPERDRIVE.Shields.ActiveShields) do
        if not IsValid(shield.generator) or not shield.ship then
            -- Clean up invalid shields
            HYPERDRIVE.Shields.ActiveShields[shieldId] = nil
            continue
        end

        shield:Update()
    end
end

function HYPERDRIVE.Shields.GetShieldStatus(generator)
    local shield = HYPERDRIVE.Shields.GetShield(generator)

    if not shield then
        return {
            active = false,
            strength = 0,
            maxStrength = 0,
            strengthPercent = 0,
            recharging = false,
            overloaded = false,
            capIntegrated = false
        }
    end

    return {
        active = shield.active,
        strength = shield.strength,
        maxStrength = shield.maxStrength,
        strengthPercent = (shield.strength / shield.maxStrength) * 100,
        recharging = shield.recharging,
        overloaded = shield.overloaded,
        capIntegrated = shield.capIntegrated
    }
end

-- Damage handling hook
hook.Add("EntityTakeDamage", "HyperdriveShields", function(target, dmginfo)
    if not IsValid(target) then return end

    -- Check if target is part of a ship with shields
    if HYPERDRIVE.ShipCore then
        local ship = HYPERDRIVE.ShipCore.GetShipByEntity(target)
        if ship and ship.core then
            local shield = HYPERDRIVE.Shields.GetShield(ship.core)
            if shield and shield.active then
                local damage = dmginfo:GetDamage()
                local attacker = dmginfo:GetAttacker()
                local damagePos = dmginfo:GetDamagePosition()

                -- Let shield handle damage
                local remainingDamage = shield:TakeDamage(damage, attacker, damagePos)

                -- Reduce actual damage
                dmginfo:SetDamage(remainingDamage)

                -- If shields absorbed all damage, prevent damage
                if remainingDamage <= 0 then
                    dmginfo:SetDamage(0)
                    return true
                end
            end
        end
    end
end)

-- Initialize shield system
function HYPERDRIVE.Shields.Initialize()
    print("[Hyperdrive Shields] Initializing enhanced shield system...")

    -- Check for CAP integration
    if CAP or StarGate then
        print("[Hyperdrive Shields] CAP detected - CAP bubble shields available")
    else
        print("[Hyperdrive Shields] CAP not detected - using custom shield system")
    end

    -- Set up automatic shield activation hooks
    HYPERDRIVE.Shields.SetupHooks()

    -- Start update timer
    timer.Create("HyperdriveShieldsUpdate", HYPERDRIVE.Shields.Config.UpdateInterval, 0, function()
        HYPERDRIVE.Shields.UpdateAllShields()
    end)

    print("[Hyperdrive Shields] Enhanced shield system initialized")
end

-- Set up hooks for automatic shield activation
function HYPERDRIVE.Shields.SetupHooks()
    -- Hook into hyperdrive charging
    hook.Add("HyperdriveChargingStart", "HyperdriveShieldsAutoActivate", function(engine, ship)
        if HYPERDRIVE.Shields.Config.AutoActivateOnCharge then
            local shield = HYPERDRIVE.Shields.GetShield(engine)
            if not shield then
                HYPERDRIVE.Shields.ActivateShield(engine, ship)
                print("[Hyperdrive Shields] Auto-activated shields for charging")
            end
        end
    end)

    -- Hook into hyperdrive jump start
    hook.Add("HyperdriveJumpStart", "HyperdriveShieldsAutoActivate", function(engine, ship)
        if HYPERDRIVE.Shields.Config.AutoActivateOnJump then
            local shield = HYPERDRIVE.Shields.GetShield(engine)
            if not shield then
                HYPERDRIVE.Shields.ActivateShield(engine, ship)
                print("[Hyperdrive Shields] Auto-activated shields for jump")
            end
        end
    end)

    -- Hook into hyperdrive cooldown
    hook.Add("HyperdriveJumpComplete", "HyperdriveShieldsAutoDeactivate", function(engine, ship)
        if HYPERDRIVE.Shields.Config.AutoDeactivateOnCooldown then
            local shield = HYPERDRIVE.Shields.GetShield(engine)
            if shield and shield.active then
                shield:Deactivate()
                print("[Hyperdrive Shields] Auto-deactivated shields after jump")
            end
        end
    end)

    -- Hook into hyperdrive abort
    hook.Add("HyperdriveChargingAbort", "HyperdriveShieldsAutoDeactivate", function(engine, ship)
        if HYPERDRIVE.Shields.Config.AutoDeactivateOnCooldown then
            local shield = HYPERDRIVE.Shields.GetShield(engine)
            if shield and shield.active then
                shield:Deactivate()
                print("[Hyperdrive Shields] Auto-deactivated shields after abort")
            end
        end
    end)
end

-- Console commands for shield control
if SERVER then
    concommand.Add("hyperdrive_activate_shield", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a hyperdrive engine to activate shield")
            return
        end

        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(trace.Entity)
        if not ship then
            ply:ChatPrint("No ship detected for this entity")
            return
        end

        local shield, message = HYPERDRIVE.Shields.CreateShield(trace.Entity, ship)
        if shield then
            shield:Activate()
            ply:ChatPrint("Shield activated for " .. ship:GetShipType())
        else
            ply:ChatPrint("Failed to create shield: " .. (message or "Unknown error"))
        end
    end)

    concommand.Add("hyperdrive_deactivate_shield", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a hyperdrive engine to deactivate shield")
            return
        end

        local shield = HYPERDRIVE.Shields.GetShield(trace.Entity)
        if shield then
            shield:Deactivate()
            ply:ChatPrint("Shield deactivated")
        else
            ply:ChatPrint("No active shield found")
        end
    end)

    concommand.Add("hyperdrive_shield_status", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a hyperdrive engine to check shield status")
            return
        end

        local status = HYPERDRIVE.Shields.GetShieldStatus(trace.Entity)

        ply:ChatPrint("=== Shield Status ===")
        ply:ChatPrint("Active: " .. tostring(status.active))
        ply:ChatPrint("Strength: " .. math.floor(status.strength) .. "/" .. math.floor(status.maxStrength))
        ply:ChatPrint("Strength %: " .. math.floor(status.strengthPercent) .. "%")
        ply:ChatPrint("Recharging: " .. tostring(status.recharging))
        ply:ChatPrint("Overloaded: " .. tostring(status.overloaded))
        ply:ChatPrint("CAP Integrated: " .. tostring(status.capIntegrated))
    end)

    concommand.Add("hyperdrive_test_shield_damage", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local damage = tonumber(args[1]) or 1000

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a hyperdrive engine to test shield damage")
            return
        end

        local shield = HYPERDRIVE.Shields.GetShield(trace.Entity)
        if shield and shield.active then
            local remainingDamage = shield:TakeDamage(damage, ply, trace.HitPos)
            ply:ChatPrint("Applied " .. damage .. " damage, " .. remainingDamage .. " passed through")
        else
            ply:ChatPrint("No active shield found")
        end
    end)

    concommand.Add("hyperdrive_test_all_systems", function(ply, cmd, args)
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        if not IsValid(trace.Entity) then
            ply:ChatPrint("Look at a hyperdrive engine to test all systems")
            return
        end

        local engine = trace.Entity
        local engineClass = engine:GetClass()

        if not string.find(engineClass, "hyperdrive") then
            ply:ChatPrint("Entity is not a hyperdrive engine")
            return
        end

        ply:ChatPrint("=== Hyperdrive System Test ===")
        ply:ChatPrint("Engine: " .. engineClass)

        -- Test ship detection
        local ship = HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.GetShipByEntity(engine)
        if ship then
            ply:ChatPrint("✓ Ship Detection: " .. ship:GetShipType())
            ply:ChatPrint("  Entities: " .. #ship:GetEntities())
            ply:ChatPrint("  Players: " .. #ship:GetPlayers())
        else
            ply:ChatPrint("✗ Ship Detection: Failed")
        end

        -- Test shield system
        if HYPERDRIVE.Shields then
            local shieldStatus = HYPERDRIVE.Shields.GetShieldStatus(engine)
            ply:ChatPrint("✓ Shield System: Available")
            ply:ChatPrint("  Active: " .. (shieldStatus.active and "YES" or "NO"))
            ply:ChatPrint("  CAP Integration: " .. (HYPERDRIVE.Shields.IsCapAvailable() and "YES" or "NO"))
        else
            ply:ChatPrint("✗ Shield System: Not loaded")
        end

        -- Test world effects
        if HYPERDRIVE.WorldEffects then
            ply:ChatPrint("✓ World Effects: Available")
        else
            ply:ChatPrint("✗ World Effects: Not loaded")
        end

        -- Test wire integration
        if WireLib and engine.Inputs and engine.Outputs then
            ply:ChatPrint("✓ Wire Integration: Available")
            ply:ChatPrint("  Inputs: " .. table.Count(engine.Inputs))
            ply:ChatPrint("  Outputs: " .. table.Count(engine.Outputs))
        else
            ply:ChatPrint("✗ Wire Integration: Not available")
        end

        -- Test energy system
        if engine.GetEnergy then
            local energy = engine:GetEnergy()
            local maxEnergy = HYPERDRIVE.Config and HYPERDRIVE.Config.MaxEnergy or 1000
            ply:ChatPrint("✓ Energy System: " .. energy .. "/" .. maxEnergy)
        else
            ply:ChatPrint("✗ Energy System: Not available")
        end

        ply:ChatPrint("=== Test Complete ===")
    end)
end

-- API functions for other systems
function HYPERDRIVE.Shields.ActivateShield(generator, ship)
    local shield, message = HYPERDRIVE.Shields.CreateShield(generator, ship)
    if shield then
        return shield:Activate()
    end
    return false, message
end

function HYPERDRIVE.Shields.DeactivateShield(generator)
    local shield = HYPERDRIVE.Shields.GetShield(generator)
    if shield then
        return shield:Deactivate()
    end
    return false
end

function HYPERDRIVE.Shields.IsShieldActive(generator)
    local shield = HYPERDRIVE.Shields.GetShield(generator)
    return shield and shield.active or false
end

function HYPERDRIVE.Shields.GetShieldStrength(generator)
    local shield = HYPERDRIVE.Shields.GetShield(generator)
    return shield and shield.strength or 0
end

function HYPERDRIVE.Shields.GetMaxShieldStrength(generator)
    local shield = HYPERDRIVE.Shields.GetShield(generator)
    return shield and shield.maxStrength or 0
end

function HYPERDRIVE.Shields.IsCapAvailable()
    return CAP ~= nil or StarGate ~= nil
end

-- Initialize on load
HYPERDRIVE.Shields.Initialize()

-- Enhanced CAP Integration Functions
function HYPERDRIVE.Shields.IntegrateWithCAP()
    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Available then
        print("[Hyperdrive Shields] CAP not available - using fallback shield system")
        return false
    end

    -- Register with CAP system
    if HYPERDRIVE.CAP.Shields and HYPERDRIVE.CAP.Shields.RegisterProvider then
        HYPERDRIVE.CAP.Shields.RegisterProvider("HyperdriveShields", {
            FindShields = HYPERDRIVE.Shields.FindCAPShields,
            CreateShield = HYPERDRIVE.Shields.CreateCAPShield,
            ActivateShields = HYPERDRIVE.Shields.ActivateCAPShields,
            DeactivateShields = HYPERDRIVE.Shields.DeactivateCAPShields,
            GetShieldStatus = HYPERDRIVE.Shields.GetCAPShieldStatus
        })
    end

    print("[Hyperdrive Shields] Successfully integrated with CAP system")
    return true
end

-- Find CAP shields on ship
function HYPERDRIVE.Shields.FindCAPShields(ship)
    if not ship or not ship.GetEntities then return {} end

    local capShields = {}
    local entities = ship:GetEntities()

    for _, ent in ipairs(entities) do
        if IsValid(ent) then
            local entClass = ent:GetClass()

            -- Check if entity is a CAP shield
            for _, shieldClass in ipairs(HYPERDRIVE.Shields.Config.CapShieldClasses) do
                if entClass == shieldClass then
                    table.insert(capShields, ent)
                    break
                end
            end
        end
    end

    return capShields
end

-- Create CAP shield for ship
function HYPERDRIVE.Shields.CreateCAPShield(core, ship, shieldType)
    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Shields then return nil end

    -- Use CAP's shield creation system
    return HYPERDRIVE.CAP.Shields.CreateShield(core, ship, shieldType)
end

-- Activate CAP shields
function HYPERDRIVE.Shields.ActivateCAPShields(core, ship, reason)
    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Shields then return false end

    -- Use CAP's shield activation system
    return HYPERDRIVE.CAP.Shields.Activate(core, ship, reason or "hyperdrive")
end

-- Deactivate CAP shields
function HYPERDRIVE.Shields.DeactivateCAPShields(core, ship, reason)
    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Shields then return false end

    -- Use CAP's shield deactivation system
    return HYPERDRIVE.CAP.Shields.Deactivate(core, ship, reason or "hyperdrive")
end

-- Get CAP shield status
function HYPERDRIVE.Shields.GetCAPShieldStatus(core, ship)
    if not HYPERDRIVE.CAP or not HYPERDRIVE.CAP.Shields then return nil end

    -- Use CAP's shield status system
    return HYPERDRIVE.CAP.Shields.GetStatus(core, ship)
end

-- Enhanced shield activation for hyperdrive system
function HYPERDRIVE.Shields.ActivateForHyperdrive(core, ship, reason)
    if not HYPERDRIVE.Shields.Config.CAPIntegrationEnabled then
        return HYPERDRIVE.Shields.ActivateShields(core, ship)
    end

    -- Try CAP shields first if preferred
    if HYPERDRIVE.Shields.Config.PreferCAPShields then
        local success = HYPERDRIVE.Shields.ActivateCAPShields(core, ship, reason)
        if success then
            print("[Hyperdrive Shields] Activated CAP shields for hyperdrive")
            return true
        end
    end

    -- Fallback to custom shields
    if HYPERDRIVE.Shields.Config.FallbackToCustom then
        local success = HYPERDRIVE.Shields.ActivateShields(core, ship)
        if success then
            print("[Hyperdrive Shields] Activated custom shields for hyperdrive")
            return true
        end
    end

    return false
end

-- Enhanced shield deactivation for hyperdrive system
function HYPERDRIVE.Shields.DeactivateForHyperdrive(core, ship, reason)
    if not HYPERDRIVE.Shields.Config.CAPIntegrationEnabled then
        return HYPERDRIVE.Shields.DeactivateShields(core, ship)
    end

    local deactivated = false

    -- Deactivate CAP shields
    if HYPERDRIVE.CAP and HYPERDRIVE.CAP.Shields then
        local success = HYPERDRIVE.Shields.DeactivateCAPShields(core, ship, reason)
        if success then
            deactivated = true
        end
    end

    -- Deactivate custom shields
    local customSuccess = HYPERDRIVE.Shields.DeactivateShields(core, ship)
    if customSuccess then
        deactivated = true
    end

    return deactivated
end

-- Get comprehensive shield status
function HYPERDRIVE.Shields.GetComprehensiveStatus(core, ship)
    local status = {
        capShields = nil,
        customShields = nil,
        totalShields = 0,
        activeShields = 0,
        averageStrength = 0,
        hasShields = false
    }

    -- Get CAP shield status
    if HYPERDRIVE.CAP and HYPERDRIVE.CAP.Shields then
        status.capShields = HYPERDRIVE.Shields.GetCAPShieldStatus(core, ship)
        if status.capShields then
            status.totalShields = status.totalShields + status.capShields.count
            status.activeShields = status.activeShields + status.capShields.active
            status.hasShields = true
        end
    end

    -- Get custom shield status
    local coreIndex = IsValid(core) and core:EntIndex() or 0
    if HYPERDRIVE.Shields.ActiveShields[coreIndex] then
        local shieldObj = HYPERDRIVE.Shields.ActiveShields[coreIndex]
        status.customShields = {
            active = shieldObj.active,
            strength = shieldObj.strength,
            maxStrength = shieldObj.maxStrength,
            percentage = (shieldObj.strength / shieldObj.maxStrength) * 100,
            recharging = shieldObj.recharging,
            overloaded = shieldObj.overloaded
        }
        status.totalShields = status.totalShields + 1
        if shieldObj.active then
            status.activeShields = status.activeShields + 1
        end
        status.hasShields = true
    end

    -- Calculate average strength
    if status.hasShields then
        local totalStrength = 0
        local maxStrength = 0

        if status.capShields then
            totalStrength = totalStrength + status.capShields.totalStrength
            maxStrength = maxStrength + status.capShields.maxStrength
        end

        if status.customShields then
            totalStrength = totalStrength + status.customShields.strength
            maxStrength = maxStrength + status.customShields.maxStrength
        end

        if maxStrength > 0 then
            status.averageStrength = (totalStrength / maxStrength) * 100
        end
    end

    return status
end

-- Initialize CAP integration when available
hook.Add("Initialize", "HyperdriveShieldsCAP", function()
    timer.Simple(2, function() -- Delay to ensure CAP loads first
        HYPERDRIVE.Shields.IntegrateWithCAP()
    end)
end)

print("[Hyperdrive] Enhanced Shield System with CAP Integration v2.1.0 loaded successfully")