-- Advanced Space Combat - Main Tool v3.1.0
-- Comprehensive entity spawning and configuration tool

TOOL.Category = "Advanced Space Combat"
TOOL.Name = "ASC Main Tool"
TOOL.Command = nil
TOOL.ConfigName = ""

-- Tool information
TOOL.Information = {
    { name = "left", text = "Spawn selected entity" },
    { name = "right", text = "Configure entity" },
    { name = "reload", text = "Remove entity" }
}

-- Client variables
if CLIENT then
    TOOL.ClientConVar["entity_type"] = "ship_core"
    TOOL.ClientConVar["auto_link"] = "1"
    TOOL.ClientConVar["spawn_distance"] = "100"
    TOOL.ClientConVar["entity_name"] = ""
    TOOL.ClientConVar["entity_health"] = "1000"
    TOOL.ClientConVar["entity_energy"] = "10000"
end

-- Entity categories and types
local EntityCategories = {
    ["Core Systems"] = {
        {class = "ship_core", name = "Ship Core", desc = "Central ship command system"},
        {class = "hyperdrive_computer", name = "Hyperdrive Computer", desc = "Ship navigation computer"},
        {class = "hyperdrive_wire_controller", name = "Wire Controller", desc = "Wiremod integration controller"}
    },
    ["Engines"] = {
        {class = "hyperdrive_engine", name = "Hyperdrive Engine", desc = "Standard hyperdrive propulsion"},
        {class = "hyperdrive_master_engine", name = "Master Engine", desc = "Advanced hyperdrive system"},
        {class = "hyperdrive_sb_engine", name = "Spacebuild Engine", desc = "Spacebuild compatible engine"}
    },
    ["Weapons"] = {
        {class = "asc_pulse_cannon", name = "Pulse Cannon", desc = "Fast energy weapon"},
        {class = "asc_plasma_cannon", name = "Plasma Cannon", desc = "Area effect weapon"},
        {class = "asc_railgun", name = "Railgun", desc = "Kinetic projectile weapon"},
        {class = "hyperdrive_beam_weapon", name = "Beam Weapon", desc = "Continuous energy beam"},
        {class = "hyperdrive_torpedo_launcher", name = "Torpedo Launcher", desc = "Guided missile system"}
    },
    ["Defense"] = {
        {class = "asc_shield_generator", name = "Shield Generator", desc = "CAP-integrated shields"},
        {class = "hyperdrive_shield_generator", name = "Hyperdrive Shield", desc = "Basic shield system"}
    },
    ["Transport"] = {
        {class = "hyperdrive_docking_pad", name = "Docking Pad", desc = "Ship docking system"},
        {class = "hyperdrive_docking_bay", name = "Docking Bay", desc = "Large ship hangar"},
        {class = "hyperdrive_shuttle", name = "Shuttle", desc = "Small transport craft"},
        {class = "hyperdrive_flight_console", name = "Flight Console", desc = "Pilot control interface"}
    },
    ["Utilities"] = {
        {class = "hyperdrive_beacon", name = "Navigation Beacon", desc = "Hyperspace navigation aid"},
        {class = "asc_ancient_zpm", name = "Ancient ZPM", desc = "Zero Point Module power source"},
        {class = "asc_ancient_drone", name = "Ancient Drone", desc = "Automated defense drone"}
    }
}

-- Get entity list for current category
function TOOL:GetEntityList()
    local category = self:GetClientInfo("entity_category") or "Core Systems"
    return EntityCategories[category] or EntityCategories["Core Systems"]
end

-- Get selected entity info
function TOOL:GetSelectedEntity()
    local entityType = self:GetClientInfo("entity_type")
    for category, entities in pairs(EntityCategories) do
        for _, entity in ipairs(entities) do
            if entity.class == entityType then
                return entity
            end
        end
    end
    return EntityCategories["Core Systems"][1] -- Default to ship core
end

-- Left click - Spawn entity
function TOOL:LeftClick(trace)
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    local entityInfo = self:GetSelectedEntity()
    if not entityInfo then return false end
    
    -- Check if entity class exists
    if not scripted_ents.GetStored(entityInfo.class) then
        ply:ChatPrint("[ASC] Entity class '" .. entityInfo.class .. "' not found!")
        return false
    end
    
    -- Calculate spawn position
    local spawnDistance = math.Clamp(self:GetClientNumber("spawn_distance"), 50, 500)
    local spawnPos = trace.HitPos + trace.HitNormal * 10
    
    -- Adjust position if too close to player
    local playerPos = ply:GetPos()
    if spawnPos:Distance(playerPos) < spawnDistance then
        spawnPos = playerPos + ply:GetAimVector() * spawnDistance
    end
    
    -- Create entity
    local ent = ents.Create(entityInfo.class)
    if not IsValid(ent) then
        ply:ChatPrint("[ASC] Failed to create entity!")
        return false
    end
    
    -- Set basic properties
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
    
    -- Set custom properties
    local entityName = self:GetClientInfo("entity_name")
    if entityName and entityName ~= "" then
        if ent.SetEntityName then
            ent:SetEntityName(entityName)
        end
    end
    
    local health = math.Clamp(self:GetClientNumber("entity_health"), 100, 10000)
    if ent.SetMaxHealth then
        ent:SetMaxHealth(health)
        ent:SetHealth(health)
    end
    
    local energy = math.Clamp(self:GetClientNumber("entity_energy"), 1000, 100000)
    if ent.SetMaxEnergy then
        ent:SetMaxEnergy(energy)
        ent:SetEnergy(energy)
    end
    
    -- Auto-link to nearby ship core if enabled
    if self:GetClientNumber("auto_link") == 1 then
        self:AutoLinkToShipCore(ent, ply)
    end
    
    -- Undo support
    undo.Create("ASC " .. entityInfo.name)
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()
    
    ply:ChatPrint("[ASC] Spawned " .. entityInfo.name .. " successfully!")
    return true
end

-- Auto-link entity to nearby ship core
function TOOL:AutoLinkToShipCore(ent, ply)
    if not IsValid(ent) or not IsValid(ply) then return end
    
    -- Find nearby ship cores
    local shipCores = ents.FindByClass("ship_core")
    local closestCore = nil
    local closestDistance = math.huge
    
    for _, core in ipairs(shipCores) do
        if IsValid(core) then
            local owner = core.CPPIGetOwner and core:CPPIGetOwner() or core:GetOwner()
            if IsValid(owner) and owner == ply then
                local distance = ent:GetPos():Distance(core:GetPos())
                if distance < 2000 and distance < closestDistance then
                    closestDistance = distance
                    closestCore = core
                end
            end
        end
    end
    
    -- Link to closest ship core
    if IsValid(closestCore) then
        if ent.SetShipCore then
            ent:SetShipCore(closestCore)
        end
        if closestCore.AddComponent then
            closestCore:AddComponent(ent)
        end
        ply:ChatPrint("[ASC] Auto-linked to ship core at " .. math.floor(closestDistance) .. " units")
    end
end

-- Right click - Configure entity
function TOOL:RightClick(trace)
    if CLIENT then return true end
    
    local ent = trace.Entity
    if not IsValid(ent) then return false end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    -- Check ownership
    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetOwner()
    if IsValid(owner) and owner ~= ply and not ply:IsAdmin() then
        ply:ChatPrint("[ASC] You don't own this entity!")
        return false
    end
    
    -- Open configuration interface
    if ent.OpenConfigInterface then
        ent:OpenConfigInterface(ply)
    elseif ent.ShowInfo then
        ent:ShowInfo(ply)
    else
        -- Default info display
        local info = "Entity: " .. (ent:GetClass() or "Unknown")
        if ent.GetEntityName then
            info = info .. "\nName: " .. (ent:GetEntityName() or "Unnamed")
        end
        if ent.GetHealth then
            info = info .. "\nHealth: " .. (ent:GetHealth() or 0) .. "/" .. (ent:GetMaxHealth() or 0)
        end
        if ent.GetEnergy then
            info = info .. "\nEnergy: " .. (ent:GetEnergy() or 0) .. "/" .. (ent:GetMaxEnergy() or 0)
        end
        ply:ChatPrint("[ASC] " .. info)
    end
    
    return true
end

-- Reload - Remove entity
function TOOL:Reload(trace)
    if CLIENT then return true end
    
    local ent = trace.Entity
    if not IsValid(ent) then return false end
    
    local ply = self:GetOwner()
    if not IsValid(ply) then return false end
    
    -- Check ownership
    local owner = ent.CPPIGetOwner and ent:CPPIGetOwner() or ent:GetOwner()
    if IsValid(owner) and owner ~= ply and not ply:IsAdmin() then
        ply:ChatPrint("[ASC] You don't own this entity!")
        return false
    end
    
    -- Remove entity
    local className = ent:GetClass()
    ent:Remove()
    ply:ChatPrint("[ASC] Removed " .. className)
    
    return true
end

-- Think function for updates
function TOOL:Think()
    -- Tool updates can go here
end

if CLIENT then
    language.Add("tool.asc_main_tool.name", "ASC Main Tool")
    language.Add("tool.asc_main_tool.desc", "Advanced Space Combat entity spawning tool")
    language.Add("tool.asc_main_tool.0", "Left click to spawn, right click to configure, reload to remove")

    -- Create tool control panel
    function TOOL.BuildCPanel(CPanel)
        CPanel:AddControl("Header", {
            Text = "Advanced Space Combat Tool",
            Description = "Spawn and configure space combat entities"
        })

        -- Entity category selection
        local categoryCombo = CPanel:AddControl("ComboBox", {
            Label = "Entity Category",
            MenuButton = 1,
            Folder = "asc_tool",
            Options = {
                ["Core Systems"] = {asc_entity_category = "Core Systems"},
                ["Engines"] = {asc_entity_category = "Engines"},
                ["Weapons"] = {asc_entity_category = "Weapons"},
                ["Defense"] = {asc_entity_category = "Defense"},
                ["Transport"] = {asc_entity_category = "Transport"},
                ["Utilities"] = {asc_entity_category = "Utilities"}
            },
            CVars = {asc_entity_category = "Core Systems"}
        })

        -- Entity type selection
        CPanel:AddControl("ComboBox", {
            Label = "Entity Type",
            MenuButton = 1,
            Folder = "asc_tool",
            Options = {
                ["Ship Core"] = {entity_type = "ship_core"},
                ["Hyperdrive Engine"] = {entity_type = "hyperdrive_engine"},
                ["Master Engine"] = {entity_type = "hyperdrive_master_engine"},
                ["Pulse Cannon"] = {entity_type = "asc_pulse_cannon"},
                ["Plasma Cannon"] = {entity_type = "asc_plasma_cannon"},
                ["Railgun"] = {entity_type = "asc_railgun"},
                ["Shield Generator"] = {entity_type = "asc_shield_generator"},
                ["Docking Pad"] = {entity_type = "hyperdrive_docking_pad"}
            },
            CVars = {entity_type = "ship_core"}
        })

        CPanel:AddControl("Slider", {
            Label = "Spawn Distance",
            Type = "Float",
            Min = "50",
            Max = "500",
            Command = "asc_main_tool_spawn_distance"
        })

        CPanel:AddControl("CheckBox", {
            Label = "Auto-link to Ship Core",
            Command = "asc_main_tool_auto_link"
        })

        CPanel:AddControl("TextBox", {
            Label = "Entity Name",
            Command = "asc_main_tool_entity_name",
            MaxLength = 50
        })

        CPanel:AddControl("Slider", {
            Label = "Entity Health",
            Type = "Float",
            Min = "100",
            Max = "10000",
            Command = "asc_main_tool_entity_health"
        })

        CPanel:AddControl("Slider", {
            Label = "Entity Energy",
            Type = "Float",
            Min = "1000",
            Max = "100000",
            Command = "asc_main_tool_entity_energy"
        })

        CPanel:AddControl("Button", {
            Label = "Spawn Ship Core",
            Command = "asc_main_tool_entity_type ship_core"
        })

        CPanel:AddControl("Button", {
            Label = "Spawn Engine",
            Command = "asc_main_tool_entity_type hyperdrive_engine"
        })

        CPanel:AddControl("Button", {
            Label = "Spawn Weapon",
            Command = "asc_main_tool_entity_type asc_pulse_cannon"
        })
    end
end
