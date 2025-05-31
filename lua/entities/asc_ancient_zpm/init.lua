-- Advanced Space Combat - Ancient ZPM Entity (Server)
-- Zero Point Module - Unlimited energy source

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/asc/ancient/zpm.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(100)
    end
    
    -- ZPM Properties
    self:SetNWInt("EnergyOutput", 100000)
    self:SetNWInt("EnergyStored", 100000)
    self:SetNWInt("MaxEnergy", 100000)
    self:SetNWBool("Active", true)
    self:SetNWInt("TechnologyTier", 10)
    self:SetNWString("TechnologyCulture", "Ancient")
    
    -- ZPM specific properties
    self.EnergyRegenRate = 1000 -- Energy per second
    self.Overloaded = false
    self.CriticalThreshold = 0.1
    
    -- Visual effects
    self:SetNWBool("Glowing", true)
    
    -- Start energy generation
    timer.Create("ZPM_Energy_" .. self:EntIndex(), 1, 0, function()
        if IsValid(self) then
            self:GenerateEnergy()
        end
    end)
    
    -- Set health
    self:SetMaxHealth(5000)
    self:SetHealth(5000)
end

function ENT:GenerateEnergy()
    if not self:GetNWBool("Active") then return end
    
    local currentEnergy = self:GetNWInt("EnergyStored")
    local maxEnergy = self:GetNWInt("MaxEnergy")
    
    -- ZPM generates unlimited energy
    if currentEnergy < maxEnergy then
        local newEnergy = math.min(maxEnergy, currentEnergy + self.EnergyRegenRate)
        self:SetNWInt("EnergyStored", newEnergy)
    end
    
    -- Supply energy to nearby ship core
    local shipCore = self:FindNearbyShipCore()
    if IsValid(shipCore) then
        self:SupplyEnergyToShip(shipCore)
    end
end

function ENT:FindNearbyShipCore()
    local nearbyEnts = ents.FindInSphere(self:GetPos(), 2000)
    
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent:GetClass() == "ship_core" then
            return ent
        end
    end
    
    return nil
end

function ENT:SupplyEnergyToShip(shipCore)
    local shipEnergy = shipCore:GetNWInt("Energy")
    local shipMaxEnergy = shipCore:GetNWInt("MaxEnergy")
    local energyNeeded = shipMaxEnergy - shipEnergy
    
    if energyNeeded > 0 then
        local energyToSupply = math.min(energyNeeded, self.EnergyRegenRate)
        shipCore:SetNWInt("Energy", shipEnergy + energyToSupply)
        
        -- Create energy transfer effect
        local effectdata = EffectData()
        effectdata:SetStart(self:GetPos())
        effectdata:SetOrigin(shipCore:GetPos())
        effectdata:SetMagnitude(energyToSupply)
        util.Effect("asc_energy_transfer", effectdata)
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    
    -- Toggle ZPM active state
    local active = not self:GetNWBool("Active")
    self:SetNWBool("Active", active)
    self:SetNWBool("Glowing", active)
    
    local status = active and "activated" or "deactivated"
    activator:ChatPrint("[Ancient ZPM] ZPM " .. status)
    
    -- Create activation effect
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(active and 1 or 0)
    util.Effect("asc_zpm_activation", effectdata)
end

function ENT:OnTakeDamage(dmginfo)
    local damage = dmginfo:GetDamage()
    
    -- ZPMs are very durable
    damage = damage * 0.1
    
    local newHealth = math.max(0, self:Health() - damage)
    self:SetHealth(newHealth)
    
    -- Check for critical damage
    if newHealth / self:GetMaxHealth() < self.CriticalThreshold then
        self:CriticalFailure()
    end
end

function ENT:CriticalFailure()
    if self.Overloaded then return end
    
    self.Overloaded = true
    self:SetNWBool("Active", false)
    self:SetNWBool("Glowing", false)
    
    -- Create massive explosion
    local explosion = ents.Create("env_explosion")
    explosion:SetPos(self:GetPos())
    explosion:SetKeyValue("iMagnitude", "500")
    explosion:Spawn()
    explosion:Activate()
    
    -- Damage nearby entities
    local nearbyEnts = ents.FindInSphere(self:GetPos(), 1000)
    for _, ent in ipairs(nearbyEnts) do
        if IsValid(ent) and ent ~= self then
            local dmginfo = DamageInfo()
            dmginfo:SetDamage(1000)
            dmginfo:SetAttacker(self)
            dmginfo:SetInflictor(self)
            dmginfo:SetDamageType(DMG_ENERGYBEAM)
            ent:TakeDamageInfo(dmginfo)
        end
    end
    
    -- Remove after explosion
    timer.Simple(2, function()
        if IsValid(self) then
            self:Remove()
        end
    end)
end

function ENT:OnRemove()
    timer.Remove("ZPM_Energy_" .. self:EntIndex())
end
