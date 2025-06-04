-- Advanced Space Combat - Shield Generator Entity
-- CAP-integrated shield system

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    -- Initialize CAP asset integration
    self.selectedTechnology = "Ancient" -- Default to Ancient for shields
    self:ApplyCAPModel()

    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(100)
    end
    
    -- Shield properties
    self:SetMaxHealth(150)
    self:SetHealth(150)
    
    -- Shield stats
    self.ShieldType = "bubble_shield"
    self.MaxShieldStrength = 1000
    self.ShieldStrength = 1000
    self.RechargeRate = 50 -- Per second
    self.EnergyConsumption = 30 -- Per second when active
    self.ShieldRadius = 500
    
    -- State variables
    self.ShieldActive = false
    self.LastRecharge = CurTime()
    self.ShipCore = nil
    self.CAPShield = nil
    
    -- Network variables
    self:SetNWBool("ShieldActive", false)
    self:SetNWFloat("ShieldStrength", self.ShieldStrength)
    self:SetNWFloat("MaxShieldStrength", self.MaxShieldStrength)
    
    -- Find ship core and initialize CAP shield
    timer.Simple(1, function()
        if IsValid(self) then
            self:FindShipCore()
            self:InitializeCAPShield()
        end
    end)
end

function ENT:FindShipCore()
    local cores = ents.FindByClass("asc_ship_core")
    local closestCore = nil
    local closestDist = math.huge

    for _, core in ipairs(cores) do
        if IsValid(core) and core:GetOwner() == self:GetOwner() then
            local dist = self:GetPos():Distance(core:GetPos())
            if dist < 2000 and dist < closestDist then
                closestCore = core
                closestDist = dist
            end
        end
    end

    if IsValid(closestCore) then
        self.ShipCore = closestCore
        closestCore:AddShield(self)
        self:SetNWEntity("ShipCore", closestCore)
    end
end

function ENT:InitializeCAPShield()
    -- Try to create CAP bubble shield
    if CAP and CAP.CreateBubbleShield then
        self.CAPShield = CAP.CreateBubbleShield(self:GetPos(), self.ShieldRadius, self:GetOwner())
        if IsValid(self.CAPShield) then
            self.CAPShield:SetParent(self)
            self.CAPShield:SetNWEntity("Generator", self)
        end
    else
        -- Fallback to custom shield system
        self:CreateCustomShield()
    end
end

function ENT:CreateCustomShield()
    -- Create custom shield bubble effect
    local shield = ents.Create("asc_shield_bubble")
    if IsValid(shield) then
        shield:SetPos(self:GetPos())
        shield:SetOwner(self:GetOwner())
        shield:SetParent(self)
        shield:SetNWEntity("Generator", self)
        shield:SetNWFloat("Radius", self.ShieldRadius)
        shield:Spawn()
        self.CAPShield = shield
    end
end

function ENT:ActivateShield()
    if self.ShieldActive then return end
    
    -- Check energy
    if IsValid(self.ShipCore) and not self.ShipCore:HasEnergy(self.EnergyConsumption) then
        return false
    end
    
    self.ShieldActive = true
    self:SetNWBool("ShieldActive", true)
    
    -- Activate CAP shield
    if IsValid(self.CAPShield) then
        if self.CAPShield.Activate then
            self.CAPShield:Activate()
        end
        self.CAPShield:SetNWBool("Active", true)
    end
    
    -- Effects
    self:EmitSound("asc/shields/shield_activate.wav", 75, 100)
    
    return true
end

function ENT:DeactivateShield()
    if not self.ShieldActive then return end
    
    self.ShieldActive = false
    self:SetNWBool("ShieldActive", false)
    
    -- Deactivate CAP shield
    if IsValid(self.CAPShield) then
        if self.CAPShield.Deactivate then
            self.CAPShield:Deactivate()
        end
        self.CAPShield:SetNWBool("Active", false)
    end
    
    -- Effects
    self:EmitSound("asc/shields/shield_deactivate.wav", 75, 100)
end

function ENT:Think()
    -- Energy consumption
    if self.ShieldActive and IsValid(self.ShipCore) then
        if not self.ShipCore:ConsumeEnergy(self.EnergyConsumption * 0.1) then
            self:DeactivateShield()
        end
    end
    
    -- Shield recharge
    if CurTime() - self.LastRecharge >= 1 then
        if self.ShieldStrength < self.MaxShieldStrength then
            self.ShieldStrength = math.min(self.MaxShieldStrength, self.ShieldStrength + self.RechargeRate)
            self:SetNWFloat("ShieldStrength", self.ShieldStrength)
        end
        self.LastRecharge = CurTime()
    end
    
    self:NextThink(CurTime() + 0.1)
    return true
end

function ENT:TakeShieldDamage(damage)
    if not self.ShieldActive then return damage end
    
    if self.ShieldStrength > 0 then
        local absorbed = math.min(damage, self.ShieldStrength)
        self.ShieldStrength = self.ShieldStrength - absorbed
        self:SetNWFloat("ShieldStrength", self.ShieldStrength)
        
        -- Shield impact effect
        local effectdata = EffectData()
        effectdata:SetOrigin(self:GetPos())
        effectdata:SetMagnitude(absorbed / 10)
        util.Effect("asc_shield_impact", effectdata)
        
        self:EmitSound("asc/shields/shield_impact.wav", 60, 100)
        
        if self.ShieldStrength <= 0 then
            self:DeactivateShield()
            self:EmitSound("asc/shields/shield_down.wav", 80, 100)
        end
        
        return damage - absorbed
    end
    
    return damage
end

function ENT:OnTakeDamage(dmginfo)
    local remainingDamage = self:TakeShieldDamage(dmginfo:GetDamage())
    
    if remainingDamage > 0 then
        self:SetHealth(self:Health() - remainingDamage)
        
        if self:Health() <= 0 then
            self:Explode()
        end
    end
end

function ENT:Explode()
    self:DeactivateShield()
    
    if IsValid(self.CAPShield) then
        self.CAPShield:Remove()
    end
    
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(2)
    util.Effect("Explosion", effectdata)
    
    self:EmitSound("ambient/explosions/explode_4.wav", 100, 100)
    self:Remove()
end

function ENT:Use(activator, caller)
    if IsValid(activator) and activator:IsPlayer() then
        if self.ShieldActive then
            self:DeactivateShield()
            activator:ChatPrint("Shield deactivated")
        else
            if self:ActivateShield() then
                activator:ChatPrint("Shield activated")
            else
                activator:ChatPrint("Insufficient energy to activate shield")
            end
        end
    end
end

-- Apply CAP model based on selected technology
function ENT:ApplyCAPModel()
    local fallbackModel = "models/props_combine/combine_mine01.mdl"

    if ASC and ASC.CAP and ASC.CAP.Assets then
        local model = ASC.CAP.Assets.GetEntityModel("asc_shield_generator", self.selectedTechnology, fallbackModel)
        local color = ASC.CAP.Assets.GetTechnologyColor(self.selectedTechnology)

        self:SetModel(model)
        self:SetColor(color)

        -- Apply technology-specific material
        local material = ASC.CAP.Assets.GetMaterial(self.selectedTechnology, "shield", "")
        if material and material ~= "" then
            self:SetMaterial(material)
        end

        print("[Shield Generator] Applied " .. self.selectedTechnology .. " technology model: " .. model)
    else
        self:SetModel(fallbackModel)
        self:SetColor(Color(100, 200, 255))
        print("[Shield Generator] CAP assets not available, using fallback model")
    end
end

-- Change technology type
function ENT:SetTechnology(technology)
    if not technology then return false end

    local availableTechs = ASC and ASC.CAP and ASC.CAP.Assets and ASC.CAP.Assets.GetEntityTechnologies("asc_shield_generator") or {}

    -- Check if technology is available
    local techAvailable = false
    for _, tech in ipairs(availableTechs) do
        if tech == technology then
            techAvailable = true
            break
        end
    end

    if not techAvailable then
        -- Fallback to standard technologies
        local standardTechs = {"Ancient", "Goauld", "Asgard", "Tauri", "Ori", "Wraith"}
        techAvailable = table.HasValue(standardTechs, technology)
    end

    if techAvailable then
        self.selectedTechnology = technology
        self:ApplyCAPModel()

        -- Update network variables
        self:SetNWString("Technology", technology)

        -- Update shield properties based on technology
        self:UpdateTechnologyProperties()

        return true
    end

    return false
end

-- Update shield properties based on technology
function ENT:UpdateTechnologyProperties()
    local tech = self.selectedTechnology

    -- Technology-specific shield properties
    if tech == "Ancient" then
        self.MaxShieldStrength = 2000
        self.RechargeRate = 100
        self.EnergyConsumption = 20
        self.ShieldRadius = 600
    elseif tech == "Asgard" then
        self.MaxShieldStrength = 1800
        self.RechargeRate = 120
        self.EnergyConsumption = 25
        self.ShieldRadius = 550
    elseif tech == "Goauld" then
        self.MaxShieldStrength = 1200
        self.RechargeRate = 60
        self.EnergyConsumption = 40
        self.ShieldRadius = 450
    elseif tech == "Tauri" then
        self.MaxShieldStrength = 1000
        self.RechargeRate = 50
        self.EnergyConsumption = 30
        self.ShieldRadius = 500
    elseif tech == "Ori" then
        self.MaxShieldStrength = 2500
        self.RechargeRate = 80
        self.EnergyConsumption = 15
        self.ShieldRadius = 700
    elseif tech == "Wraith" then
        self.MaxShieldStrength = 1500
        self.RechargeRate = 70
        self.EnergyConsumption = 35
        self.ShieldRadius = 520
    end

    -- Update current shield strength if it exceeds new max
    if self.ShieldStrength > self.MaxShieldStrength then
        self.ShieldStrength = self.MaxShieldStrength
    end

    -- Update network variables
    self:SetNWFloat("MaxShieldStrength", self.MaxShieldStrength)
    self:SetNWFloat("ShieldStrength", self.ShieldStrength)

    print("[Shield Generator] Updated properties for " .. tech .. " technology")
end

-- Get current technology
function ENT:GetTechnology()
    return self.selectedTechnology or "Ancient"
end
