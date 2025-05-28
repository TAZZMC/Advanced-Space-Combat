-- Hyperdrive Wire Controller Entity - Server Side
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_lab/binderblue.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(30)
    end
    
    -- Initialize controller properties
    self:SetControllerMode(1) -- 1 = Engine Control, 2 = Fleet Control, 3 = Beacon Control
    self:SetTargetEntity(NULL)
    self:SetControlRange(2000)
    
    -- Initialize Wiremod support
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "TargetEngine [ENTITY]",
            "TargetComputer [ENTITY]",
            "TargetBeacon [ENTITY]",
            "SetMode",
            "Execute",
            "SetDestination [VECTOR]",
            "SetEnergy",
            "SetRange",
            "SetActive",
            "ScanRange"
        })
        
        self.Outputs = WireLib.CreateOutputs(self, {
            "Mode",
            "TargetValid",
            "TargetType [STRING]",
            "TargetEnergy",
            "TargetStatus [STRING]",
            "NearbyEngines",
            "NearbyComputers", 
            "NearbyBeacons",
            "LastCommand [STRING]",
            "CommandSuccess"
        })
    end
    
    self.LastUse = 0
    self.Owner = nil
    self.LastCommand = ""
    self.CommandSuccess = false
end

function ENT:SetupDataTables()
    self:NetworkVar("Int", 0, "ControllerMode")
    self:NetworkVar("Entity", 0, "TargetEntity")
    self:NetworkVar("Float", 0, "ControlRange")
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if CurTime() - self.LastUse < 0.5 then return end
    
    self.LastUse = CurTime()
    self.Owner = activator
    
    activator:ChatPrint("[Hyperdrive Controller] Use wire inputs to control hyperdrive systems")
    activator:ChatPrint("Mode: " .. self:GetModeString())
    if IsValid(self:GetTargetEntity()) then
        activator:ChatPrint("Target: " .. self:GetTargetEntity():GetClass())
    else
        activator:ChatPrint("No target selected")
    end
end

function ENT:GetModeString()
    local mode = self:GetControllerMode()
    if mode == 1 then return "Engine Control"
    elseif mode == 2 then return "Fleet Control"
    elseif mode == 3 then return "Beacon Control"
    else return "Unknown" end
end

-- Wiremod support functions
function ENT:TriggerInput(iname, value)
    if not WireLib then return end
    
    if iname == "TargetEngine" and IsValid(value) and value:GetClass() == "hyperdrive_engine" then
        self:SetTargetEntity(value)
        self:SetControllerMode(1)
        self.LastCommand = "Target Engine Set"
        self.CommandSuccess = true
        
    elseif iname == "TargetComputer" and IsValid(value) and value:GetClass() == "hyperdrive_computer" then
        self:SetTargetEntity(value)
        self:SetControllerMode(2)
        self.LastCommand = "Target Computer Set"
        self.CommandSuccess = true
        
    elseif iname == "TargetBeacon" and IsValid(value) and value:GetClass() == "hyperdrive_beacon" then
        self:SetTargetEntity(value)
        self:SetControllerMode(3)
        self.LastCommand = "Target Beacon Set"
        self.CommandSuccess = true
        
    elseif iname == "SetMode" then
        local mode = math.Clamp(math.floor(value), 1, 3)
        self:SetControllerMode(mode)
        self.LastCommand = "Mode Changed"
        self.CommandSuccess = true
        
    elseif iname == "Execute" and value > 0 then
        self:ExecuteCommand()
        
    elseif iname == "SetDestination" and isvector(value) then
        self.WireDestination = value
        self.LastCommand = "Destination Set"
        self.CommandSuccess = true
        
    elseif iname == "SetEnergy" then
        self.WireEnergy = math.max(0, value)
        self.LastCommand = "Energy Value Set"
        self.CommandSuccess = true
        
    elseif iname == "SetRange" then
        self.WireRange = math.Clamp(value, 500, 10000)
        self.LastCommand = "Range Value Set"
        self.CommandSuccess = true
        
    elseif iname == "SetActive" then
        self.WireActive = value > 0
        self.LastCommand = "Active State Set"
        self.CommandSuccess = true
        
    elseif iname == "ScanRange" then
        self:SetControlRange(math.Clamp(value, 500, 5000))
        self.LastCommand = "Scan Range Set"
        self.CommandSuccess = true
    end
    
    self:UpdateWireOutputs()
end

function ENT:ExecuteCommand()
    local target = self:GetTargetEntity()
    if not IsValid(target) then
        self.LastCommand = "No Target"
        self.CommandSuccess = false
        return
    end
    
    local mode = self:GetControllerMode()
    
    if mode == 1 and target:GetClass() == "hyperdrive_engine" then
        -- Engine control
        if self.WireDestination then
            local success, message = target:SetDestinationPos(self.WireDestination)
            if success then
                target:StartJump()
                self.LastCommand = "Jump Executed"
                self.CommandSuccess = true
            else
                self.LastCommand = message
                self.CommandSuccess = false
            end
        elseif self.WireEnergy then
            target:SetEnergy(self.WireEnergy)
            self.LastCommand = "Energy Set"
            self.CommandSuccess = true
        end
        
    elseif mode == 2 and target:GetClass() == "hyperdrive_computer" then
        -- Computer control
        if self.WireDestination then
            local success, message = target:ExecuteFleetJump(self.WireDestination)
            self.LastCommand = message
            self.CommandSuccess = success
        end
        
    elseif mode == 3 and target:GetClass() == "hyperdrive_beacon" then
        -- Beacon control
        if self.WireRange then
            target:SetRange(self.WireRange)
            self.LastCommand = "Beacon Range Set"
            self.CommandSuccess = true
        end
        if self.WireActive ~= nil then
            target:SetActive(self.WireActive)
            self.LastCommand = "Beacon State Set"
            self.CommandSuccess = true
        end
    end
end

function ENT:UpdateWireOutputs()
    if not WireLib then return end
    
    WireLib.TriggerOutput(self, "Mode", self:GetControllerMode())
    
    local target = self:GetTargetEntity()
    WireLib.TriggerOutput(self, "TargetValid", IsValid(target) and 1 or 0)
    
    if IsValid(target) then
        WireLib.TriggerOutput(self, "TargetType", target:GetClass())
        
        if target:GetClass() == "hyperdrive_engine" then
            WireLib.TriggerOutput(self, "TargetEnergy", target:GetEnergy())
            local status = target:GetCharging() and "CHARGING" or target:CanJump() and "READY" or "NOT_READY"
            WireLib.TriggerOutput(self, "TargetStatus", status)
        elseif target:GetClass() == "hyperdrive_computer" then
            local status = target:GetEngineStatus()
            WireLib.TriggerOutput(self, "TargetEnergy", status.totalEnergy)
            WireLib.TriggerOutput(self, "TargetStatus", string.format("%d/%d READY", status.ready, status.total))
        elseif target:GetClass() == "hyperdrive_beacon" then
            WireLib.TriggerOutput(self, "TargetEnergy", 0)
            WireLib.TriggerOutput(self, "TargetStatus", target:GetActive() and "ACTIVE" or "INACTIVE")
        end
    else
        WireLib.TriggerOutput(self, "TargetType", "")
        WireLib.TriggerOutput(self, "TargetEnergy", 0)
        WireLib.TriggerOutput(self, "TargetStatus", "NO_TARGET")
    end
    
    -- Count nearby entities
    local range = self:GetControlRange()
    local nearbyEnts = ents.FindInSphere(self:GetPos(), range)
    
    local engines, computers, beacons = 0, 0, 0
    for _, ent in ipairs(nearbyEnts) do
        if ent:GetClass() == "hyperdrive_engine" then
            engines = engines + 1
        elseif ent:GetClass() == "hyperdrive_computer" then
            computers = computers + 1
        elseif ent:GetClass() == "hyperdrive_beacon" then
            beacons = beacons + 1
        end
    end
    
    WireLib.TriggerOutput(self, "NearbyEngines", engines)
    WireLib.TriggerOutput(self, "NearbyComputers", computers)
    WireLib.TriggerOutput(self, "NearbyBeacons", beacons)
    WireLib.TriggerOutput(self, "LastCommand", self.LastCommand)
    WireLib.TriggerOutput(self, "CommandSuccess", self.CommandSuccess and 1 or 0)
end

function ENT:Think()
    self:UpdateWireOutputs()
    self:NextThink(CurTime() + 1)
    return true
end
