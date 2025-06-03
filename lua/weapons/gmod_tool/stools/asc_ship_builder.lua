-- Advanced Space Combat - Ship Builder Tool v3.1.0
-- Specialized tool for ship construction and management

TOOL.Category = "Advanced Space Combat"
TOOL.Name = "Ship Builder"
TOOL.Command = nil
TOOL.ConfigName = ""

-- Tool information
TOOL.Information = {
    { name = "left", text = "Place ship component" },
    { name = "right", text = "Link to ship core" },
    { name = "reload", text = "Show ship status" }
}

-- Client variables
if CLIENT then
    TOOL.ClientConVar["component_type"] = "hyperdrive_engine"
    TOOL.ClientConVar["auto_wire"] = "1"
    TOOL.ClientConVar["ship_name"] = "New Ship"
    TOOL.ClientConVar["build_mode"] = "standard"
    TOOL.ClientConVar["component_spacing"] = "150"
end

-- Ship component templates
local ShipTemplates = {
    ["Fighter"] = {
        {class = "ship_core", pos = Vector(0, 0, 0)},
        {class = "hyperdrive_engine", pos = Vector(-100, 0, 0)},
        {class = "asc_pulse_cannon", pos = Vector(50, 30, 0)},
        {class = "asc_pulse_cannon", pos = Vector(50, -30, 0)},
        {class = "asc_shield_generator", pos = Vector(0, 0, 50)}
    },
    ["Cruiser"] = {
        {class = "ship_core", pos = Vector(0, 0, 0)},
        {class = "hyperdrive_master_engine", pos = Vector(-200, 0, 0)},
        {class = "hyperdrive_engine", pos = Vector(-150, 50, 0)},
        {class = "hyperdrive_engine", pos = Vector(-150, -50, 0)},
        {class = "asc_railgun", pos = Vector(100, 0, 0)},
        {class = "asc_plasma_cannon", pos = Vector(80, 60, 0)},
        {class = "asc_plasma_cannon", pos = Vector(80, -60, 0)},
        {class = "asc_shield_generator", pos = Vector(0, 0, 80)},
        {class = "hyperdrive_docking_pad", pos = Vector(-50, 0, -50)}
    },
    ["Carrier"] = {
        {class = "ship_core", pos = Vector(0, 0, 0)},
        {class = "hyperdrive_master_engine", pos = Vector(-300, 0, 0)},
        {class = "hyperdrive_engine", pos = Vector(-250, 100, 0)},
        {class = "hyperdrive_engine", pos = Vector(-250, -100, 0)},
        {class = "hyperdrive_docking_bay", pos = Vector(0, 0, -100)},
        {class = "hyperdrive_docking_pad", pos = Vector(-100, 150, -50)},
        {class = "hyperdrive_docking_pad", pos = Vector(-100, -150, -50)},
        {class = "asc_shield_generator", pos = Vector(0, 0, 120)},
        {class = "asc_shield_generator", pos = Vector(-150, 0, 80)}
    }
}

-- Component categories
local ComponentCategories = {
    ["Core"] = {"ship_core", "hyperdrive_computer", "hyperdrive_wire_controller"},
    ["Propulsion"] = {"hyperdrive_engine", "hyperdrive_master_engine", "hyperdrive_sb_engine"},
    ["Weapons"] = {"asc_pulse_cannon", "asc_plasma_cannon", "asc_railgun", "hyperdrive_beam_weapon", "hyperdrive_torpedo_launcher"},
    ["Defense"] = {"asc_shield_generator", "hyperdrive_shield_generator"},
    ["Utility"] = {"hyperdrive_docking_pad", "hyperdrive_docking_bay", "hyperdrive_flight_console", "hyperdrive_beacon"}
}

-- Get ship core for player
function TOOL:GetPlayerShipCore(ply)
    local shipCores = ents.FindByClass("ship_core")
    local closestCore = nil
    local closestDistance = math.huge
    
    for _, core in ipairs(shipCores) do
        if IsValid(core) then
            local owner = core.CPPIGetOwner and core:CPPIGetOwner() or core:GetOwner()
            if IsValid(owner) and owner == ply then
                local distance = ply:GetPos():Distance(core:GetPos())
                if distance < closestDistance then
                    closestDistance = distance
                    closestCore = core
                end
            end
        end
    end
    
    return closestCore, closestDistance
end

-- Left click - Place component
function TOOL:LeftClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    local componentType = self:GetClientInfo("component_type")
    local buildMode = self:GetClientInfo("build_mode")
    
    if buildMode == "template" then
        return self:BuildShipTemplate(trace, ply)
    else
        return self:PlaceComponent(trace, ply, componentType)
    end
end

-- Place single component
function TOOL:PlaceComponent(trace, ply, componentType)
    -- Check if entity class exists
    if not scripted_ents.GetStored(componentType) then
        ply:ChatPrint("[Ship Builder] Component '" .. componentType .. "' not found!")
        return false
    end
    
    -- Calculate spawn position
    local spawnPos = trace.HitPos + trace.HitNormal * 10
    
    -- Create component
    local ent = ents.Create(componentType)
    if not IsValid(ent) then
        ply:ChatPrint("[Ship Builder] Failed to create component!")
        return false
    end
    
    ent:SetPos(spawnPos)
    ent:SetAngles(ply:EyeAngles())
    ent:Spawn()
    ent:Activate()
    
    -- Set ownership
    if ent.CPPISetOwner then
        ent:CPPISetOwner(ply)
    elseif ent.SetOwner then
        ent:SetOwner(ply)
    end
    
    -- Auto-link to ship core
    local shipCore = self:GetPlayerShipCore(ply)
    if IsValid(shipCore) then
        if ent.SetShipCore then
            ent:SetShipCore(shipCore)
        end
        if shipCore.AddComponent then
            shipCore:AddComponent(ent)
        end
        
        -- Auto-wire if enabled
        if self:GetClientNumber("auto_wire") == 1 and WireLib then
            self:AutoWireComponent(ent, shipCore)
        end
    end
    
    -- Undo support
    undo.Create("Ship Component")
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()
    
    ply:ChatPrint("[Ship Builder] Placed " .. componentType .. " successfully!")
    return true
end

-- Build ship template
function TOOL:BuildShipTemplate(trace, ply)
    local templateName = self:GetClientInfo("template_name") or "Fighter"
    local template = ShipTemplates[templateName]
    
    if not template then
        ply:ChatPrint("[Ship Builder] Template '" .. templateName .. "' not found!")
        return false
    end
    
    local basePos = trace.HitPos + trace.HitNormal * 50
    local baseAngles = ply:EyeAngles()
    local createdEntities = {}
    local shipCore = nil
    
    -- Create all components
    for _, component in ipairs(template) do
        if scripted_ents.GetStored(component.class) then
            local ent = ents.Create(component.class)
            if IsValid(ent) then
                local worldPos = basePos + baseAngles:Forward() * component.pos.x + 
                                baseAngles:Right() * component.pos.y + 
                                baseAngles:Up() * component.pos.z
                
                ent:SetPos(worldPos)
                ent:SetAngles(baseAngles)
                ent:Spawn()
                ent:Activate()
                
                -- Set ownership
                if ent.CPPISetOwner then
                    ent:CPPISetOwner(ply)
                elseif ent.SetOwner then
                    ent:SetOwner(ply)
                end
                
                table.insert(createdEntities, ent)
                
                if component.class == "ship_core" then
                    shipCore = ent
                    if ent.SetEntityName then
                        ent:SetEntityName(self:GetClientInfo("ship_name"))
                    end
                end
            end
        end
    end
    
    -- Link all components to ship core
    if IsValid(shipCore) then
        for _, ent in ipairs(createdEntities) do
            if IsValid(ent) and ent ~= shipCore then
                if ent.SetShipCore then
                    ent:SetShipCore(shipCore)
                end
                if shipCore.AddComponent then
                    shipCore:AddComponent(ent)
                end
            end
        end
    end
    
    -- Undo support
    undo.Create("Ship Template: " .. templateName)
    for _, ent in ipairs(createdEntities) do
        undo.AddEntity(ent)
    end
    undo.SetPlayer(ply)
    undo.Finish()
    
    ply:ChatPrint("[Ship Builder] Built " .. templateName .. " template with " .. #createdEntities .. " components!")
    return true
end

-- Auto-wire component to ship core
function TOOL:AutoWireComponent(component, shipCore)
    if not WireLib or not IsValid(component) or not IsValid(shipCore) then return end
    
    -- Basic wire connections based on component type
    local componentClass = component:GetClass()
    
    if string.find(componentClass, "engine") then
        -- Wire engines for thrust control
        if component.Inputs and shipCore.Outputs then
            WireLib.Link_Start(LocalPlayer(), shipCore, shipCore:GetPos(), "Thrust", "normal", LocalPlayer(), component, component:GetPos(), "Thrust", "normal")
        end
    elseif string.find(componentClass, "weapon") or string.find(componentClass, "cannon") then
        -- Wire weapons for firing control
        if component.Inputs and shipCore.Outputs then
            WireLib.Link_Start(LocalPlayer(), shipCore, shipCore:GetPos(), "Fire", "normal", LocalPlayer(), component, component:GetPos(), "Fire", "normal")
        end
    elseif string.find(componentClass, "shield") then
        -- Wire shields for power control
        if component.Inputs and shipCore.Outputs then
            WireLib.Link_Start(LocalPlayer(), shipCore, shipCore:GetPos(), "Shield", "normal", LocalPlayer(), component, component:GetPos(), "Active", "normal")
        end
    end
end

-- Right click - Link to ship core
function TOOL:RightClick(trace)
    if CLIENT then return true end
    
    local ent = trace.Entity
    if not IsValid(ent) then return false end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    -- Check ownership
    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetOwner()
    if IsValid(owner) and owner ~= ply and not ply:IsAdmin() then
        ply:ChatPrint("[Ship Builder] You don't own this entity!")
        return false
    end
    
    -- Find ship core and link
    local shipCore = self:GetPlayerShipCore(ply)
    if IsValid(shipCore) then
        if ent.SetShipCore then
            ent:SetShipCore(shipCore)
        end
        if shipCore.AddComponent then
            shipCore:AddComponent(ent)
        end
        
        local distance = ent:GetPos():Distance(shipCore:GetPos())
        ply:ChatPrint("[Ship Builder] Linked " .. ent:GetClass() .. " to ship core (" .. math.floor(distance) .. " units)")
    else
        ply:ChatPrint("[Ship Builder] No ship core found! Spawn a ship core first.")
    end
    
    return true
end

-- Reload - Show ship status
function TOOL:Reload(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    local shipCore, distance = self:GetPlayerShipCore(ply)
    if IsValid(shipCore) then
        local componentCount = 0
        if shipCore.GetComponents then
            local components = shipCore:GetComponents()
            componentCount = #components
        end
        
        local shipName = "Unnamed Ship"
        if shipCore.GetEntityName then
            shipName = shipCore:GetEntityName() or shipName
        end
        
        ply:ChatPrint("[Ship Builder] Ship Status:")
        ply:ChatPrint("Name: " .. shipName)
        ply:ChatPrint("Components: " .. componentCount)
        ply:ChatPrint("Distance: " .. math.floor(distance) .. " units")
        
        if shipCore.GetHealth then
            ply:ChatPrint("Health: " .. (shipCore:GetHealth() or 0) .. "/" .. (shipCore:GetMaxHealth() or 0))
        end
        if shipCore.GetEnergy then
            ply:ChatPrint("Energy: " .. (shipCore:GetEnergy() or 0) .. "/" .. (shipCore:GetMaxEnergy() or 0))
        end
    else
        ply:ChatPrint("[Ship Builder] No ship found! Spawn a ship core to start building.")
    end
    
    return true
end

if CLIENT then
    language.Add("tool.asc_ship_builder.name", "Ship Builder")
    language.Add("tool.asc_ship_builder.desc", "Advanced ship construction and management tool")
    language.Add("tool.asc_ship_builder.0", "Left click to place component, right click to link, reload for status")
end
