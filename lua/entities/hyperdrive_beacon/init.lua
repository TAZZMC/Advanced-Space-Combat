-- Hyperdrive Beacon Entity - Server Side
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel("models/props_combine/combine_mine01.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:Wake()
        phys:SetMass(25)
    end

    -- Initialize beacon properties
    self:SetBeaconName("Beacon")
    self:SetActive(true)
    self:SetRange(5000)
    self:SetBeaconID(math.random(1000, 9999))

    -- Initialize Wiremod support
    if WireLib then
        self.Inputs = WireLib.CreateInputs(self, {
            "SetActive",
            "SetRange",
            "SetName [STRING]",
            "Pulse"
        })

        self.Outputs = WireLib.CreateOutputs(self, {
            "Active",
            "Range",
            "BeaconName [STRING]",
            "BeaconID",
            "NearbyEngines"
        })
    end

    -- Register beacon in global system
    HYPERDRIVE.RegisterBeacon(self)

    self.LastUse = 0
    self.Owner = nil

    -- Start beacon pulse
    timer.Create("beacon_pulse_" .. self:EntIndex(), 2, 0, function()
        if IsValid(self) and self:GetActive() then
            self:SendPulse()
            self:UpdateWireOutputs()
        else
            timer.Remove("beacon_pulse_" .. self:EntIndex())
        end
    end)
end

function ENT:SetupDataTables()
    self:NetworkVar("String", 0, "BeaconName")
    self:NetworkVar("Bool", 0, "Active")
    self:NetworkVar("Float", 0, "Range")
    self:NetworkVar("Int", 0, "BeaconID")
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if CurTime() - self.LastUse < 0.5 then return end

    -- Check distance
    if self:GetPos():Distance(activator:GetPos()) > 200 then
        activator:ChatPrint("[Hyperdrive Beacon] Too far away to access interface")
        return
    end

    self.LastUse = CurTime()
    self.Owner = activator

    -- Open beacon configuration interface
    activator:ChatPrint("[Hyperdrive Beacon] Opening beacon configuration interface...")

    net.Start("hyperdrive_beacon_config")
    net.WriteEntity(self)
    net.WriteString(self:GetBeaconName())
    net.WriteBool(self:GetActive())
    net.WriteFloat(self:GetRange())
    net.WriteInt(self:GetBeaconID(), 16)
    net.Send(activator)
end

function ENT:SendPulse()
    -- Create pulse effect
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetMagnitude(self:GetRange())
    util.Effect("hyperdrive_beacon_pulse", effectdata)

    -- Send pulse to nearby engines
    local engines = ents.FindInSphere(self:GetPos(), self:GetRange())
    for _, ent in ipairs(engines) do
        if ent:GetClass() == "hyperdrive_engine" then
            net.Start("hyperdrive_beacon_pulse")
            net.WriteEntity(self)
            net.WriteVector(self:GetPos())
            net.Broadcast()
            break
        end
    end
end

function ENT:SetBeaconConfiguration(name, active, range)
    self:SetBeaconName(name or "Beacon")
    self:SetActive(active ~= false)
    self:SetRange(math.Clamp(range or 5000, 500, 10000))

    -- Update global beacon registry
    HYPERDRIVE.UpdateBeacon(self)
end

function ENT:OnRemove()
    timer.Remove("beacon_pulse_" .. self:EntIndex())
    HYPERDRIVE.UnregisterBeacon(self)
end

-- Wiremod support functions
function ENT:TriggerInput(iname, value)
    if not WireLib then return end

    if iname == "SetActive" then
        self:SetActive(value > 0)

    elseif iname == "SetRange" then
        self:SetRange(math.Clamp(value, 500, 10000))

    elseif iname == "SetName" and isstring(value) then
        self:SetBeaconName(value)

    elseif iname == "Pulse" and value > 0 then
        self:SendPulse()
    end

    self:UpdateWireOutputs()
end

function ENT:UpdateWireOutputs()
    if not WireLib then return end

    WireLib.TriggerOutput(self, "Active", self:GetActive() and 1 or 0)
    WireLib.TriggerOutput(self, "Range", self:GetRange())
    WireLib.TriggerOutput(self, "BeaconName", self:GetBeaconName())
    WireLib.TriggerOutput(self, "BeaconID", self:GetBeaconID())

    -- Count nearby engines
    local nearbyEngines = 0
    local engines = ents.FindInSphere(self:GetPos(), self:GetRange())
    for _, engine in ipairs(engines) do
        if engine:GetClass() == "hyperdrive_engine" then
            nearbyEngines = nearbyEngines + 1
        end
    end
    WireLib.TriggerOutput(self, "NearbyEngines", nearbyEngines)
end

-- Global beacon management
HYPERDRIVE.Beacons = HYPERDRIVE.Beacons or {}

function HYPERDRIVE.RegisterBeacon(beacon)
    if not IsValid(beacon) then return end
    HYPERDRIVE.Beacons[beacon:EntIndex()] = beacon
    print("[Hyperdrive] Beacon registered: " .. beacon:GetBeaconName())
end

function HYPERDRIVE.UnregisterBeacon(beacon)
    if not IsValid(beacon) then return end
    HYPERDRIVE.Beacons[beacon:EntIndex()] = nil
    print("[Hyperdrive] Beacon unregistered: " .. beacon:GetBeaconName())
end

function HYPERDRIVE.UpdateBeacon(beacon)
    if not IsValid(beacon) then return end
    HYPERDRIVE.Beacons[beacon:EntIndex()] = beacon
end

function HYPERDRIVE.GetBeaconsInRange(position, range)
    local beacons = {}
    for _, beacon in pairs(HYPERDRIVE.Beacons) do
        if IsValid(beacon) and beacon:GetActive() then
            local distance = position:Distance(beacon:GetPos())
            if distance <= range then
                table.insert(beacons, {
                    entity = beacon,
                    distance = distance,
                    name = beacon:GetBeaconName(),
                    id = beacon:GetBeaconID()
                })
            end
        end
    end

    -- Sort by distance
    table.sort(beacons, function(a, b) return a.distance < b.distance end)
    return beacons
end

function HYPERDRIVE.GetBeaconByID(id)
    for _, beacon in pairs(HYPERDRIVE.Beacons) do
        if IsValid(beacon) and beacon:GetBeaconID() == id then
            return beacon
        end
    end
    return nil
end

-- Network strings are loaded from hyperdrive_network_strings.lua

-- Network handlers
net.Receive("hyperdrive_beacon_update", function(len, ply)
    local beacon = net.ReadEntity()
    local name = net.ReadString()
    local active = net.ReadBool()
    local range = net.ReadFloat()

    if not IsValid(beacon) or beacon:GetClass() ~= "hyperdrive_beacon" then return end
    if beacon:GetPos():Distance(ply:GetPos()) > 200 then return end

    beacon:SetBeaconConfiguration(name, active, range)
    ply:ChatPrint("[Hyperdrive] Beacon updated: " .. name)
end)

-- Console commands
concommand.Add("hyperdrive_list_beacons", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local beacons = HYPERDRIVE.GetBeaconsInRange(ply:GetPos(), 50000)

    if #beacons == 0 then
        ply:ChatPrint("[Hyperdrive] No beacons found")
        return
    end

    ply:ChatPrint("[Hyperdrive] Nearby beacons:")
    for _, beaconData in ipairs(beacons) do
        local status = beaconData.entity:GetActive() and "ACTIVE" or "INACTIVE"
        ply:ChatPrint(string.format("  • %s (ID: %d) - %s - %.0fm",
            beaconData.name, beaconData.id, status, beaconData.distance))
    end
end)

concommand.Add("hyperdrive_goto_beacon", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        if IsValid(ply) then
            ply:ChatPrint("[Hyperdrive] Admin access required!")
        end
        return
    end

    if #args < 1 then
        ply:ChatPrint("[Hyperdrive] Usage: hyperdrive_goto_beacon <beacon_id>")
        return
    end

    local beaconID = tonumber(args[1])
    if not beaconID then
        ply:ChatPrint("[Hyperdrive] Invalid beacon ID")
        return
    end

    local beacon = HYPERDRIVE.GetBeaconByID(beaconID)
    if not beacon then
        ply:ChatPrint("[Hyperdrive] Beacon not found")
        return
    end

    ply:SetPos(beacon:GetPos() + Vector(0, 0, 50))
    ply:ChatPrint("[Hyperdrive] Teleported to beacon: " .. beacon:GetBeaconName())
end)
