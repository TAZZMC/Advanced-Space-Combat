-- Master Hyperdrive Engine Entity - Shared
ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Master Hyperdrive Engine"
ENT.Author = "Hyperdrive Team"
ENT.Contact = ""
ENT.Purpose = "Ultimate hyperdrive engine combining ALL features: Wiremod, Spacebuild, and Stargate integration"
ENT.Instructions = "The most advanced hyperdrive engine with unified integration of all systems. Use to access master control interface."

ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Hyperdrive"

ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
    -- Core properties
    self:NetworkVar("Float", 0, "Energy")
    self:NetworkVar("Bool", 0, "Charging")
    self:NetworkVar("Float", 1, "Cooldown")
    self:NetworkVar("Vector", 0, "Destination")
    self:NetworkVar("Bool", 1, "JumpReady")
    self:NetworkVar("Entity", 0, "AttachedVehicle")
    
    -- Spacebuild properties
    self:NetworkVar("Float", 2, "PowerLevel")
    self:NetworkVar("Float", 3, "OxygenLevel")
    self:NetworkVar("Float", 4, "CoolantLevel")
    self:NetworkVar("Float", 5, "Temperature")
    
    -- Stargate properties
    self:NetworkVar("String", 0, "TechLevel")
    self:NetworkVar("Float", 6, "NaquadahLevel")
    self:NetworkVar("Float", 7, "ZPMPower")
    self:NetworkVar("String", 1, "GateAddress")
    
    -- Master system properties
    self:NetworkVar("Int", 0, "SystemIntegration")
    self:NetworkVar("Float", 8, "EfficiencyRating")
    self:NetworkVar("Int", 1, "OperationalMode")
end

function ENT:GetEnergyPercent()
    local maxEnergy = (HYPERDRIVE.Config and HYPERDRIVE.Config.MaxEnergy) or 1000
    return (self:GetEnergy() / maxEnergy) * 100
end

function ENT:GetCooldownRemaining()
    return math.max(0, self:GetCooldown() - CurTime())
end

function ENT:IsOnCooldown()
    return self:GetCooldown() > CurTime()
end

function ENT:CanJump()
    return not self:GetCharging() and 
           not self:IsOnCooldown() and 
           self:GetDestination() ~= Vector(0, 0, 0) and
           self:GetEnergy() > 0
end

-- Integration status functions
function ENT:HasWiremodIntegration()
    return bit.band(self:GetSystemIntegration(), 1) ~= 0
end

function ENT:HasSpacebuildIntegration()
    return bit.band(self:GetSystemIntegration(), 2) ~= 0
end

function ENT:HasStargateIntegration()
    return bit.band(self:GetSystemIntegration(), 4) ~= 0
end

function ENT:GetIntegrationCount()
    local count = 0
    if self:HasWiremodIntegration() then count = count + 1 end
    if self:HasSpacebuildIntegration() then count = count + 1 end
    if self:HasStargateIntegration() then count = count + 1 end
    return count
end

function ENT:GetIntegrationString()
    local integrations = {}
    if self:HasWiremodIntegration() then table.insert(integrations, "WIRE") end
    if self:HasSpacebuildIntegration() then table.insert(integrations, "SB") end
    if self:HasStargateIntegration() then table.insert(integrations, "SG") end
    
    if #integrations == 0 then
        return "CORE ONLY"
    else
        return table.concat(integrations, "+")
    end
end

-- Spacebuild status functions
function ENT:GetResourcePercent(resource)
    if resource == "power" then
        return math.min(100, (self:GetPowerLevel() / 100) * 100)
    elseif resource == "oxygen" then
        return math.min(100, (self:GetOxygenLevel() / 50) * 100)
    elseif resource == "coolant" then
        return math.min(100, (self:GetCoolantLevel() / 20) * 100)
    end
    return 0
end

function ENT:GetTemperatureStatus()
    local temp = self:GetTemperature()
    if temp > 80 then
        return "OVERHEATING", Color(255, 0, 0)
    elseif temp > 60 then
        return "HOT", Color(255, 150, 0)
    elseif temp < 0 then
        return "FROZEN", Color(0, 150, 255)
    elseif temp < 10 then
        return "COLD", Color(100, 200, 255)
    else
        return "NORMAL", Color(0, 255, 0)
    end
end

function ENT:GetLifeSupportStatus()
    if not self:HasSpacebuildIntegration() then
        return "NO_SB", Color(100, 100, 100)
    end
    
    local hasMinPower = self:GetPowerLevel() >= 10
    local hasMinOxygen = self:GetOxygenLevel() >= 5
    local hasMinCoolant = self:GetCoolantLevel() >= 2
    local tempOK = self:GetTemperature() > -50 and self:GetTemperature() < 100
    
    if hasMinPower and hasMinOxygen and hasMinCoolant and tempOK then
        return "NOMINAL", Color(0, 255, 0)
    elseif hasMinPower and tempOK then
        return "LIMITED", Color(255, 255, 0)
    else
        return "CRITICAL", Color(255, 0, 0)
    end
end

-- Stargate status functions
function ENT:GetTechLevelName()
    local techLevel = self:GetTechLevel()
    if techLevel == "ancient" then
        return "Ancient"
    elseif techLevel == "ori" then
        return "Ori"
    elseif techLevel == "asgard" then
        return "Asgard"
    elseif techLevel == "goauld" then
        return "Goa'uld"
    elseif techLevel == "wraith" then
        return "Wraith"
    else
        return "Tau'ri"
    end
end

function ENT:GetTechLevelColor()
    local techLevel = self:GetTechLevel()
    if techLevel == "ancient" then
        return Color(255, 215, 0) -- Gold
    elseif techLevel == "ori" then
        return Color(255, 100, 0) -- Orange
    elseif techLevel == "asgard" then
        return Color(100, 150, 255) -- Light Blue
    elseif techLevel == "goauld" then
        return Color(255, 215, 0) -- Gold
    elseif techLevel == "wraith" then
        return Color(150, 0, 150) -- Purple
    else
        return Color(200, 200, 200) -- Gray
    end
end

function ENT:GetStargateStatus()
    if not self:HasStargateIntegration() then
        return "NO_SG", Color(100, 100, 100)
    end
    
    local hasNaquadah = self:GetNaquadahLevel() > 0
    local hasZPM = self:GetZPMPower() > 0
    local techLevel = self:GetTechLevel()
    
    if hasZPM and hasNaquadah then
        return "OPTIMAL", Color(0, 255, 0)
    elseif hasZPM or hasNaquadah then
        return "ENHANCED", Color(255, 255, 0)
    elseif techLevel ~= "tau_ri" then
        return "BASIC", Color(255, 150, 0)
    else
        return "STANDARD", Color(200, 200, 200)
    end
end

-- Master status functions
function ENT:GetOperationalModeString()
    local mode = self:GetOperationalMode()
    if mode == 1 then
        return "STANDARD"
    elseif mode == 2 then
        return "ENHANCED"
    elseif mode == 3 then
        return "MAXIMUM"
    else
        return "UNKNOWN"
    end
end

function ENT:GetMasterStatus()
    local efficiency = self:GetEfficiencyRating()
    local integrations = self:GetIntegrationCount()
    
    if efficiency >= 2.0 and integrations >= 2 then
        return "OPTIMAL", Color(0, 255, 0)
    elseif efficiency >= 1.5 or integrations >= 2 then
        return "ENHANCED", Color(255, 255, 0)
    elseif efficiency >= 1.2 or integrations >= 1 then
        return "IMPROVED", Color(255, 150, 0)
    else
        return "STANDARD", Color(200, 200, 200)
    end
end

function ENT:GetEfficiencyString()
    return string.format("%.2fx", self:GetEfficiencyRating())
end
