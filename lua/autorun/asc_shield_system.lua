--[[
    Advanced Space Combat - Shield System v3.0.0
    
    Comprehensive shield management system with CAP integration
    Features adaptive shielding, tactical AI integration, and multi-layer protection
]]

-- Initialize Shield System namespace
ASC = ASC or {}
ASC.Shields = ASC.Shields or {}
ASC.Shields.Core = ASC.Shields.Core or {}

-- Shield System Configuration
ASC.Shields.Config = {
    -- Core Settings
    Enabled = true,
    UpdateRate = 0.2,
    MaxShieldStrength = 1000,
    RechargeRate = 50, -- Per second
    RechargeDelay = 3, -- Seconds after damage
    
    -- Shield Types (Direct ship core integration - no generators needed)
    ShieldTypes = {
        BASIC = {
            name = "Basic Shield",
            strength = 800,
            rechargeRate = 40,
            energyCost = 15,
            coverage = 0.85,
            builtin = true
        },
        ADVANCED = {
            name = "Advanced Shield",
            strength = 1500,
            rechargeRate = 75,
            energyCost = 25,
            coverage = 0.92,
            builtin = true
        },
        TACTICAL = {
            name = "Tactical Shield",
            strength = 2500,
            rechargeRate = 120,
            energyCost = 40,
            coverage = 0.97,
            builtin = true
        },
        FORTRESS = {
            name = "Fortress Shield",
            strength = 4000,
            rechargeRate = 200,
            energyCost = 60,
            coverage = 0.99,
            builtin = true
        },
        CAP_ENHANCED = {
            name = "CAP Enhanced Shield",
            strength = 3500,
            rechargeRate = 150,
            energyCost = 50,
            coverage = 1.0,
            builtin = true,
            capIntegration = true
        }
    },
    
    -- Visual Effects
    ShieldEffects = {
        HitEffect = "ElectricSpark",
        RechargeEffect = "TeslaHitBoxes",
        OverloadEffect = "Explosion",
        ActivationSound = "ambient/energy/force_field_loop1.wav",
        HitSound = "ambient/energy/spark",
        OverloadSound = "ambient/explosions/explode_7.wav"
    },
    
    -- Integration Settings
    CAPIntegration = true,
    TacticalAIIntegration = true,
    AutoRecharge = true,
    AdaptiveShielding = true
}

-- Shield System Core
ASC.Shields.Core = {
    -- Active shield systems
    ActiveShields = {},
    
    -- Shield statistics
    ShieldStats = {},
    
    -- Initialize shield system for a ship
    Initialize = function(shipCore, shieldType)
        if not IsValid(shipCore) then
            return false, "Invalid ship core"
        end
        
        local shipID = shipCore:EntIndex()
        shieldType = shieldType or "ADVANCED"
        
        -- Create shield system with built-in shields (no generators needed)
        ASC.Shields.Core.ActiveShields[shipID] = {
            shipCore = shipCore,
            shieldType = shieldType,
            config = ASC.Shields.Config.ShieldTypes[shieldType],

            -- Shield status
            currentStrength = 0,
            maxStrength = ASC.Shields.Config.ShieldTypes[shieldType].strength,
            recharging = false,
            lastDamageTime = 0,
            active = false,
            builtin = true, -- Direct ship core shields

            -- Optional external components (for bonus effects)
            generators = {},
            capShields = {},

            -- Performance tracking
            damageAbsorbed = 0,
            rechargeCount = 0,
            overloadCount = 0,
            efficiency = 1.0,

            -- Tactical integration
            threatLevel = 0,
            adaptiveMode = false,
            prioritySectors = {},

            -- Built-in shield properties
            shieldRadius = 150, -- Shield bubble radius around ship
            shieldColor = Color(100, 150, 255, 100),
            shieldEffect = nil
        }

        -- Optionally detect additional shield generators for bonus strength
        ASC.Shields.Core.DetectBonusGenerators(shipID)

        -- Optionally detect CAP shields for integration
        ASC.Shields.Core.DetectCAPShields(shipID)

        -- Initialize built-in shield strength
        ASC.Shields.Core.ActivateBuiltinShields(shipID)
        
        print("[Shield System] Initialized for ship " .. shipID .. " - Type: " .. shieldType)
        return true, "Shield system initialized"
    end,
    
    -- Detect bonus shield generators (optional enhancement)
    DetectBonusGenerators = function(shipID)
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        if not shield or not IsValid(shield.shipCore) then return end

        shield.generators = {}

        -- Find optional shield generators for bonus strength
        if shield.shipCore.GetEntities then
            for _, ent in ipairs(shield.shipCore:GetEntities()) do
                if IsValid(ent) and (ent:GetClass() == "asc_shield_generator" or ent:GetClass() == "hyperdrive_shield_generator") then
                    table.insert(shield.generators, {
                        entity = ent,
                        active = true,
                        bonusStrength = 300, -- Bonus strength added to built-in shields
                        bonusRecharge = 15,  -- Bonus recharge rate
                        efficiency = 1.0
                    })
                end
            end
        end

        if #shield.generators > 0 then
            print("[Shield System] Detected " .. #shield.generators .. " bonus shield generators for ship " .. shipID)
        end
    end,
    
    -- Detect CAP shields
    DetectCAPShields = function(shipID)
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        if not shield or not IsValid(shield.shipCore) or not ASC.Shields.Config.CAPIntegration then return end
        
        shield.capShields = {}
        
        -- Check for CAP shield integration
        if HYPERDRIVE and HYPERDRIVE.CAP and HYPERDRIVE.CAP.Shields then
            local capShields = HYPERDRIVE.CAP.Shields.FindShields(shield.shipCore.ship or {})
            for _, capShield in ipairs(capShields) do
                if IsValid(capShield) then
                    table.insert(shield.capShields, {
                        entity = capShield,
                        active = true,
                        strength = 500,
                        type = "CAP_BUBBLE"
                    })
                end
            end
        end
        
        print("[Shield System] Detected " .. #shield.capShields .. " CAP shields for ship " .. shipID)
    end,
    
    -- Activate built-in shields (no generators required)
    ActivateBuiltinShields = function(shipID)
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        if not shield then return false end

        -- Start with base shield strength from ship core
        local baseStrength = shield.config.strength
        local totalRechargeRate = shield.config.rechargeRate

        -- Add bonus from optional generators
        local bonusStrength = 0
        local bonusRecharge = 0
        for _, generator in ipairs(shield.generators) do
            if IsValid(generator.entity) and generator.active then
                bonusStrength = bonusStrength + generator.bonusStrength
                bonusRecharge = bonusRecharge + generator.bonusRecharge
            end
        end

        -- Add CAP shield integration bonus
        local capBonus = 0
        for _, capShield in ipairs(shield.capShields) do
            if IsValid(capShield.entity) and capShield.active then
                capBonus = capBonus + capShield.strength
            end
        end

        -- Calculate final shield properties
        local totalStrength = baseStrength + bonusStrength + capBonus
        shield.maxStrength = totalStrength
        shield.currentStrength = totalStrength
        shield.config.rechargeRate = totalRechargeRate + bonusRecharge
        shield.active = true
        shield.recharging = false

        -- Update ship core with shield information
        if IsValid(shield.shipCore) then
            shield.shipCore:SetNWBool("ShieldSystemActive", true)
            shield.shipCore:SetNWFloat("ShieldStrength", 100)
            shield.shipCore:SetNWFloat("MaxShieldStrength", totalStrength)
            shield.shipCore:SetNWString("ShieldType", shield.shieldType)
            shield.shipCore:SetNWBool("BuiltinShields", true)
            shield.shipCore:SetNWInt("BonusGenerators", #shield.generators)
            shield.shipCore:SetNWInt("CAPShields", #shield.capShields)
        end

        -- Create initial shield effect
        ASC.Shields.Core.CreateShieldActivationEffect(shield.shipCore)

        -- Play activation sound
        if IsValid(shield.shipCore) then
            shield.shipCore:EmitSound(ASC.Shields.Config.ShieldEffects.ActivationSound, 60, 100)
        end

        local statusMsg = "Built-in: " .. baseStrength
        if bonusStrength > 0 then statusMsg = statusMsg .. " + Bonus: " .. bonusStrength end
        if capBonus > 0 then statusMsg = statusMsg .. " + CAP: " .. capBonus end

        print("[Shield System] Activated built-in shields for ship " .. shipID .. " - Total: " .. totalStrength .. " (" .. statusMsg .. ")")
        return true
    end,

    -- Create shield activation effect
    CreateShieldActivationEffect = function(shipCore)
        if not IsValid(shipCore) then return end

        local pos = shipCore:GetPos()

        -- Create activation effect
        local effect = EffectData()
        effect:SetOrigin(pos)
        effect:SetScale(5)
        effect:SetMagnitude(2)
        util.Effect("TeslaHitBoxes", effect)

        -- Create shield bubble effect
        timer.Simple(0.5, function()
            if IsValid(shipCore) then
                local bubble = EffectData()
                bubble:SetOrigin(pos)
                bubble:SetScale(3)
                bubble:SetRadius(150)
                util.Effect("ElectricSpark", bubble)
            end
        end)
    end,
    
    -- Update shield system
    Update = function(shipID)
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        if not shield or not IsValid(shield.shipCore) then
            ASC.Shields.Core.ActiveShields[shipID] = nil
            return
        end
        
        local currentTime = CurTime()
        
        -- Handle recharging
        if shield.recharging and shield.currentStrength < shield.maxStrength then
            local rechargeAmount = shield.config.rechargeRate * ASC.Shields.Config.UpdateRate
            shield.currentStrength = math.min(shield.maxStrength, shield.currentStrength + rechargeAmount)
            
            -- Update ship core
            local strengthPercent = (shield.currentStrength / shield.maxStrength) * 100
            shield.shipCore:SetNWFloat("ShieldStrength", strengthPercent)
            
            -- Stop recharging when full
            if shield.currentStrength >= shield.maxStrength then
                shield.recharging = false
                shield.rechargeCount = shield.rechargeCount + 1
            end
        end
        
        -- Start recharging if enough time has passed since damage
        if not shield.recharging and shield.currentStrength < shield.maxStrength then
            if currentTime - shield.lastDamageTime >= ASC.Shields.Config.RechargeDelay then
                shield.recharging = true
            end
        end
        
        -- Update tactical AI integration
        if ASC.Shields.Config.TacticalAIIntegration then
            ASC.Shields.Core.UpdateTacticalIntegration(shipID)
        end
        
        -- Update adaptive shielding
        if ASC.Shields.Config.AdaptiveShielding then
            ASC.Shields.Core.UpdateAdaptiveShielding(shipID)
        end
    end,
    
    -- Handle shield damage
    AbsorbDamage = function(shipID, damage, damageType, attacker)
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        if not shield or not shield.active or shield.currentStrength <= 0 then
            return 0 -- No damage absorbed
        end
        
        local absorbedDamage = math.min(damage, shield.currentStrength)
        shield.currentStrength = shield.currentStrength - absorbedDamage
        shield.lastDamageTime = CurTime()
        shield.recharging = false
        shield.damageAbsorbed = shield.damageAbsorbed + absorbedDamage
        
        -- Update ship core
        local strengthPercent = (shield.currentStrength / shield.maxStrength) * 100
        shield.shipCore:SetNWFloat("ShieldStrength", strengthPercent)
        
        -- Shield effects
        ASC.Shields.Core.CreateShieldHitEffect(shield.shipCore, attacker)
        
        -- Play hit sound
        if IsValid(shield.shipCore) then
            local hitSound = ASC.Shields.Config.ShieldEffects.HitSound .. math.random(1, 6) .. ".wav"
            shield.shipCore:EmitSound(hitSound, 70, math.random(90, 110))
        end
        
        -- Check for shield overload
        if shield.currentStrength <= 0 then
            ASC.Shields.Core.ShieldOverload(shipID)
        end
        
        print("[Shield System] Absorbed " .. absorbedDamage .. " damage - Remaining: " .. shield.currentStrength)
        return absorbedDamage
    end,
    
    -- Handle shield overload
    ShieldOverload = function(shipID)
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        if not shield then return end
        
        shield.active = false
        shield.overloadCount = shield.overloadCount + 1
        
        -- Update ship core
        shield.shipCore:SetNWBool("ShieldSystemActive", false)
        shield.shipCore:SetNWFloat("ShieldStrength", 0)
        
        -- Overload effects
        if IsValid(shield.shipCore) then
            shield.shipCore:EmitSound(ASC.Shields.Config.ShieldEffects.OverloadSound, 80, 80)
            
            local explosion = EffectData()
            explosion:SetOrigin(shield.shipCore:GetPos())
            explosion:SetScale(3)
            util.Effect(ASC.Shields.Config.ShieldEffects.OverloadEffect, explosion)
        end
        
        -- Restart built-in shields after delay
        timer.Simple(5, function()
            if IsValid(shield.shipCore) then
                ASC.Shields.Core.ActivateBuiltinShields(shipID)
            end
        end)
        
        print("[Shield System] Shield overload for ship " .. shipID)
    end,
    
    -- Create shield hit effect
    CreateShieldHitEffect = function(shipCore, attacker)
        if not IsValid(shipCore) then return end
        
        local hitPos = shipCore:GetPos()
        if IsValid(attacker) then
            hitPos = hitPos + (attacker:GetPos() - shipCore:GetPos()):GetNormalized() * 100
        end
        
        local effect = EffectData()
        effect:SetOrigin(hitPos)
        effect:SetStart(shipCore:GetPos())
        effect:SetScale(2)
        effect:SetMagnitude(1)
        util.Effect(ASC.Shields.Config.ShieldEffects.HitEffect, effect)
    end,
    
    -- Update tactical AI integration
    UpdateTacticalIntegration = function(shipID)
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        if not shield or not ASC or not ASC.TacticalAI then return end
        
        local session = ASC.TacticalAI.Core.ActiveSessions[shipID]
        if session then
            local threatCount = table.Count(session.threats)
            shield.threatLevel = threatCount
            
            -- Adaptive shield strength based on threat level
            if threatCount > 3 then
                shield.adaptiveMode = true
                -- Boost recharge rate during high threat
                shield.config.rechargeRate = ASC.Shields.Config.ShieldTypes[shield.shieldType].rechargeRate * 1.5
            else
                shield.adaptiveMode = false
                shield.config.rechargeRate = ASC.Shields.Config.ShieldTypes[shield.shieldType].rechargeRate
            end
        end
    end,
    
    -- Update adaptive shielding
    UpdateAdaptiveShielding = function(shipID)
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        if not shield then return end
        
        -- Adjust efficiency based on performance
        local damageRatio = shield.damageAbsorbed / (shield.maxStrength * (shield.rechargeCount + 1))
        if damageRatio > 0.8 then
            shield.efficiency = math.min(1.2, shield.efficiency + 0.01) -- Learn to be more efficient
        elseif damageRatio < 0.3 then
            shield.efficiency = math.max(0.8, shield.efficiency - 0.005) -- Reduce efficiency if underused
        end
    end,
    
    -- Get shield status
    GetShieldStatus = function(shipID)
        local shield = ASC.Shields.Core.ActiveShields[shipID]
        if not shield then
            return {
                available = false,
                strengthPercent = 0,
                status = "OFFLINE"
            }
        end
        
        local strengthPercent = (shield.currentStrength / shield.maxStrength) * 100
        local status = "OFFLINE"
        
        if shield.active then
            if shield.recharging then
                status = "RECHARGING"
            elseif strengthPercent > 75 then
                status = "STRONG"
            elseif strengthPercent > 25 then
                status = "MODERATE"
            else
                status = "WEAK"
            end
        end
        
        return {
            available = shield.active,
            strengthPercent = strengthPercent,
            currentStrength = shield.currentStrength,
            maxStrength = shield.maxStrength,
            status = status,
            recharging = shield.recharging,
            efficiency = shield.efficiency,
            damageAbsorbed = shield.damageAbsorbed,
            generators = #shield.generators,
            capShields = #shield.capShields
        }
    end
}

-- Initialize system
if SERVER then
    -- Update all shield systems
    timer.Create("ASC_Shields_Update", ASC.Shields.Config.UpdateRate, 0, function()
        if ASC.Shields and ASC.Shields.Core and ASC.Shields.Core.ActiveShields then
            for shipID, shield in pairs(ASC.Shields.Core.ActiveShields) do
                if ASC.Shields.Core.Update then
                    ASC.Shields.Core.Update(shipID)
                end
            end
        end
    end)
    
    -- Update system status
    ASC.SystemStatus = ASC.SystemStatus or {}
    ASC.SystemStatus.ShieldSystem = true

    print("[Advanced Space Combat] Shield System v3.0.0 loaded")
end
