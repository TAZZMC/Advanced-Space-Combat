--[[
    Advanced Space Combat - Point Defense Turret Entity (Shared)
    
    Shared entity definition for point defense turrets.
]]

ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "ASC Point Defense Turret"
ENT.Author = "Advanced Space Combat"
ENT.Contact = ""
ENT.Purpose = "Automated point defense system for intercepting incoming threats"
ENT.Instructions = "Place near ship core for automated defense. Use to toggle on/off."

ENT.Category = "Advanced Space Combat"
ENT.Spawnable = true
ENT.AdminSpawnable = true

-- Model and appearance
ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"
ENT.RenderGroup = RENDERGROUP_OPAQUE

-- Physics properties
ENT.PhysicsType = MOVETYPE_VPHYSICS
ENT.Solid = SOLID_VPHYSICS

-- Health and damage
ENT.MaxHealth = 200
ENT.AutomaticFrameAdvance = true

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("Float", 0, "Energy")
    self:NetworkVar("Float", 1, "Heat")
    self:NetworkVar("Int", 0, "TargetCount")
    self:NetworkVar("Float", 2, "FireRate")
    self:NetworkVar("Float", 3, "Range")
    self:NetworkVar("Int", 1, "Ammo")
    self:NetworkVar("Int", 2, "MaxAmmo")
    self:NetworkVar("String", 0, "Status")
    self:NetworkVar("Entity", 0, "CurrentTarget")
end

-- Shared utility functions
function ENT:GetStatusColor()
    if not self:GetActive() then
        return Color(100, 100, 100) -- Gray - Offline
    elseif self:GetHeat() >= 100 then
        return Color(255, 0, 0) -- Red - Overheated
    elseif self:GetAmmo() <= 0 then
        return Color(255, 165, 0) -- Orange - No ammo
    elseif self:GetEnergy() < 20 then
        return Color(255, 255, 0) -- Yellow - Low energy
    elseif IsValid(self:GetCurrentTarget()) then
        return Color(255, 0, 0) -- Red - Engaging
    else
        return Color(0, 255, 0) -- Green - Ready
    end
end

function ENT:GetStatusText()
    local status = self:GetStatus()
    if status and status ~= "" then
        return status
    end
    
    if not self:GetActive() then
        return "OFFLINE"
    elseif self:GetHeat() >= 100 then
        return "OVERHEATED"
    elseif self:GetAmmo() <= 0 then
        return "NO AMMO"
    elseif self:GetEnergy() < 20 then
        return "LOW ENERGY"
    elseif IsValid(self:GetCurrentTarget()) then
        return "ENGAGING TARGET"
    else
        return "READY"
    end
end

function ENT:GetEfficiencyRating()
    if not self.pointDefense then return 100 end
    
    local shotsFired = self.pointDefense.shotsFired or 0
    local targetsDestroyed = self.pointDefense.targetsDestroyed or 0
    
    if shotsFired == 0 then return 100 end
    
    return math.floor((targetsDestroyed / shotsFired) * 100)
end

function ENT:GetHeatLevel()
    local heat = self:GetHeat()
    if heat >= 90 then
        return "CRITICAL"
    elseif heat >= 70 then
        return "HIGH"
    elseif heat >= 40 then
        return "MODERATE"
    else
        return "NORMAL"
    end
end

function ENT:GetEnergyLevel()
    local energy = self:GetEnergy()
    if energy >= 80 then
        return "FULL"
    elseif energy >= 50 then
        return "GOOD"
    elseif energy >= 20 then
        return "LOW"
    else
        return "CRITICAL"
    end
end

function ENT:GetAmmoPercentage()
    local maxAmmo = self:GetMaxAmmo()
    if maxAmmo == 0 then return 0 end
    
    return math.floor((self:GetAmmo() / maxAmmo) * 100)
end

function ENT:IsOperational()
    return self:GetActive() and 
           self:GetHeat() < 100 and 
           self:GetAmmo() > 0 and 
           self:GetEnergy() > 0
end

function ENT:GetOperationalStatus()
    if not self:GetActive() then
        return "OFFLINE", Color(100, 100, 100)
    elseif not self:IsOperational() then
        return "MALFUNCTION", Color(255, 0, 0)
    elseif IsValid(self:GetCurrentTarget()) then
        return "COMBAT", Color(255, 100, 0)
    else
        return "STANDBY", Color(0, 255, 0)
    end
end

-- Shared constants
ENT.PointDefenseConstants = {
    MAX_RANGE = 1500,
    MIN_RANGE = 50,
    MAX_TARGETS = 8,
    FIRE_RATE_MIN = 0.1,
    FIRE_RATE_MAX = 2.0,
    HEAT_THRESHOLD = 100,
    ENERGY_THRESHOLD = 5,
    AMMO_CAPACITY = 1000
}

-- Target priority levels
ENT.TargetPriority = {
    MISSILE = 10,
    TORPEDO = 8,
    ROCKET = 6,
    PROJECTILE = 4,
    UNKNOWN = 1
}

-- System states
ENT.SystemStates = {
    OFFLINE = 0,
    STANDBY = 1,
    SCANNING = 2,
    TRACKING = 3,
    ENGAGING = 4,
    RELOADING = 5,
    OVERHEATED = 6,
    MALFUNCTION = 7
}

-- Get current system state
function ENT:GetSystemState()
    if not self:GetActive() then
        return self.SystemStates.OFFLINE
    elseif self:GetHeat() >= 100 then
        return self.SystemStates.OVERHEATED
    elseif self:GetAmmo() <= 0 then
        return self.SystemStates.RELOADING
    elseif IsValid(self:GetCurrentTarget()) then
        return self.SystemStates.ENGAGING
    elseif self:GetTargetCount() > 0 then
        return self.SystemStates.TRACKING
    else
        return self.SystemStates.SCANNING
    end
end

-- Get system state name
function ENT:GetSystemStateName()
    local state = self:GetSystemState()
    
    for name, value in pairs(self.SystemStates) do
        if value == state then
            return name
        end
    end
    
    return "UNKNOWN"
end

-- Performance metrics
function ENT:GetPerformanceMetrics()
    if not self.pointDefense then
        return {
            shotsFired = 0,
            targetsDestroyed = 0,
            missedShots = 0,
            accuracy = 100,
            efficiency = 100,
            uptime = 0
        }
    end
    
    local shotsFired = self.pointDefense.shotsFired or 0
    local targetsDestroyed = self.pointDefense.targetsDestroyed or 0
    local missedShots = self.pointDefense.missedShots or 0
    
    local accuracy = shotsFired > 0 and ((shotsFired - missedShots) / shotsFired * 100) or 100
    local efficiency = shotsFired > 0 and (targetsDestroyed / shotsFired * 100) or 100
    
    return {
        shotsFired = shotsFired,
        targetsDestroyed = targetsDestroyed,
        missedShots = missedShots,
        accuracy = math.floor(accuracy),
        efficiency = math.floor(efficiency),
        uptime = CurTime() - (self.startTime or CurTime())
    }
end

-- Diagnostic information
function ENT:GetDiagnosticInfo()
    local metrics = self:GetPerformanceMetrics()
    local status, statusColor = self:GetOperationalStatus()
    
    return {
        -- Basic status
        active = self:GetActive(),
        operational = self:IsOperational(),
        status = status,
        statusColor = statusColor,
        
        -- Resource levels
        energy = self:GetEnergy(),
        energyLevel = self:GetEnergyLevel(),
        heat = self:GetHeat(),
        heatLevel = self:GetHeatLevel(),
        ammo = self:GetAmmo(),
        maxAmmo = self:GetMaxAmmo(),
        ammoPercentage = self:GetAmmoPercentage(),
        
        -- Combat status
        currentTarget = IsValid(self:GetCurrentTarget()) and self:GetCurrentTarget():GetClass() or "None",
        targetCount = self:GetTargetCount(),
        range = self:GetRange(),
        fireRate = self:GetFireRate(),
        
        -- Performance
        shotsFired = metrics.shotsFired,
        targetsDestroyed = metrics.targetsDestroyed,
        accuracy = metrics.accuracy,
        efficiency = metrics.efficiency,
        uptime = metrics.uptime,
        
        -- System state
        systemState = self:GetSystemStateName(),
        lastMaintenance = self.pointDefense and self.pointDefense.lastMaintenance or CurTime()
    }
end

-- Shared validation functions
function ENT:IsValidTargetClass(class)
    local validClasses = {
        "missile", "torpedo", "rocket", "projectile", "grenade", "rpg"
    }
    
    for _, validClass in ipairs(validClasses) do
        if string.find(class:lower(), validClass) then
            return true
        end
    end
    
    return false
end

function ENT:CalculateTargetPriority(targetClass, distance, velocity)
    local basePriority = self.TargetPriority.UNKNOWN
    
    -- Determine base priority by class
    for priorityType, priority in pairs(self.TargetPriority) do
        if string.find(targetClass:upper(), priorityType) then
            basePriority = priority
            break
        end
    end
    
    -- Modify priority based on distance (closer = higher priority)
    local distanceModifier = 1.0
    if distance < 300 then
        distanceModifier = 2.0
    elseif distance < 600 then
        distanceModifier = 1.5
    elseif distance > 1200 then
        distanceModifier = 0.5
    end
    
    -- Modify priority based on velocity (faster = higher priority)
    local velocityModifier = 1.0
    if velocity > 800 then
        velocityModifier = 1.5
    elseif velocity > 400 then
        velocityModifier = 1.2
    elseif velocity < 100 then
        velocityModifier = 0.8
    end
    
    return basePriority * distanceModifier * velocityModifier
end
