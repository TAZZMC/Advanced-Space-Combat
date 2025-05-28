-- Hyperdrive Tool
TOOL.Category = "Hyperdrive"
TOOL.Name = "#tool.hyperdrive.name"
TOOL.Command = nil
TOOL.ConfigName = ""

TOOL.Information = {
    { name = "left", text = "#tool.hyperdrive.left" },
    { name = "right", text = "#tool.hyperdrive.right" },
    { name = "reload", text = "#tool.hyperdrive.reload" }
}

if CLIENT then
    language.Add("tool.hyperdrive.name", "Easy Hyperdrive Tool")
    language.Add("tool.hyperdrive.desc", "Simple hyperdrive system - just place Master Engine and Computer!")
    language.Add("tool.hyperdrive.0", "Left click to place. Press E on Computer to use. Reload to remove.")
    language.Add("tool.hyperdrive.left", "Place Item")
    language.Add("tool.hyperdrive.right", "Use Item")
    language.Add("tool.hyperdrive.reload", "Remove Item")

    -- Tool ConVars
    TOOL.ClientConVar["entity_type"] = "hyperdrive_master_engine"

    -- Create ConVar for ComboBox
    CreateClientConVar("hyperdrive_entity_type", "hyperdrive_master_engine", true, false, "Selected hyperdrive entity type")

    -- Sync the ConVars
    cvars.AddChangeCallback("hyperdrive_entity_type", function(name, old, new)
        RunConsoleCommand("hyperdrive_entity_type", new)
    end)
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end

    local entityType = GetConVar("hyperdrive_entity_type"):GetString()
    if not entityType or entityType == "" then
        entityType = "hyperdrive_master_engine"
    end

    if trace.Hit and not trace.HitSky then
        local entity = ents.Create(entityType)
        if not IsValid(entity) then return false end

        entity:SetPos(trace.HitPos + trace.HitNormal * 10)
        entity:SetAngles(trace.HitNormal:Angle() + Angle(90, 0, 0))
        entity:Spawn()
        entity:Activate()

        -- Set owner
        entity:SetCreator(ply)

        -- Weld to surface if it's a prop
        if IsValid(trace.Entity) and trace.Entity:GetClass() ~= "worldspawn" then
            local weld = constraint.Weld(entity, trace.Entity, 0, 0, 0, true, false)
            if IsValid(weld) then
                ply:ChatPrint("[Hyperdrive] " .. entity.PrintName .. " welded to " .. trace.Entity:GetClass())
            end
        end

        ply:ChatPrint("[Hyperdrive] " .. entity.PrintName .. " placed successfully!")
        return true
    end

    return false
end

function TOOL:RightClick(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end

    if IsValid(trace.Entity) then
        if trace.Entity:GetClass() == "hyperdrive_master_engine" then
            -- Configure existing hyperdrive
            self:ConfigureHyperdrive(trace.Entity, ply)
            return true
        elseif trace.Entity:IsVehicle() then
            -- Attach hyperdrive to vehicle
            self:AttachToVehicle(trace.Entity, ply)
            return true
        end
    end

    return false
end

function TOOL:Reload(trace)
    if CLIENT then return true end

    local ply = self:GetOwner()
    if not IsValid(ply) then return false end

    if IsValid(trace.Entity) and
       (trace.Entity:GetClass() == "hyperdrive_master_engine" or
        trace.Entity:GetClass() == "hyperdrive_computer") then

        -- Check ownership or admin
        if trace.Entity:GetCreator() == ply or ply:IsAdmin() then
            local entityName = trace.Entity.PrintName or trace.Entity:GetClass()
            trace.Entity:Remove()
            ply:ChatPrint("[Hyperdrive] " .. entityName .. " removed!")
            return true
        else
            ply:ChatPrint("[Hyperdrive] You don't own this entity!")
        end
    end

    return false
end

function TOOL:ConfigureHyperdrive(hyperdrive, ply)
    -- Open configuration menu
    ply:ChatPrint("[Hyperdrive] Use the engine to access its interface!")
end

function TOOL:AttachToVehicle(vehicle, ply)
    -- Find nearby hyperdrive engines
    local hyperdrives = ents.FindInSphere(vehicle:GetPos(), 500)
    local closestHyperdrive = nil
    local closestDistance = math.huge

    for _, ent in ipairs(hyperdrives) do
        if ent:GetClass() == "hyperdrive_master_engine" and (ent:GetCreator() == ply or ply:IsAdmin()) then
            local distance = ent:GetPos():Distance(vehicle:GetPos())
            if distance < closestDistance then
                closestDistance = distance
                closestHyperdrive = ent
            end
        end
    end

    if IsValid(closestHyperdrive) then
        closestHyperdrive:SetAttachedVehicle(vehicle)

        -- Create visual connection
        local weld = constraint.Weld(closestHyperdrive, vehicle, 0, 0, 0, true, false)
        if IsValid(weld) then
            ply:ChatPrint("[Hyperdrive] Engine attached to vehicle!")
        else
            ply:ChatPrint("[Hyperdrive] Failed to attach engine to vehicle!")
        end
    else
        ply:ChatPrint("[Hyperdrive] No hyperdrive engines found nearby!")
    end
end

function TOOL:Think()
    -- Tool thinking
end

if CLIENT then
    function TOOL.BuildCPanel(CPanel)
        CPanel:AddControl("Header", { Description = "#tool.hyperdrive.desc" })

        -- Entity type selection (simplified)
        local entityTypes = {
            ["hyperdrive_master_engine"] = "Master Engine (ALL FEATURES)",
            ["hyperdrive_computer"] = "Easy Computer"
        }

        CPanel:AddControl("Label", { Text = "Entity Type:" })

        local entityCombo = vgui.Create("DComboBox")
        entityCombo:SetSize(200, 20)
        entityCombo:SetValue("Master Engine (ALL FEATURES)")

        for class, name in pairs(entityTypes) do
            entityCombo:AddChoice(name, class)
        end

        entityCombo.OnSelect = function(self, index, value, data)
            RunConsoleCommand("hyperdrive_entity_type", data or "hyperdrive_master_engine")
        end

        CPanel:AddItem(entityCombo)

        CPanel:AddControl("Label", { Text = "" })
        CPanel:AddControl("Label", { Text = "How to Use:" })
        CPanel:AddControl("Label", { Text = "1. Select Master Engine or Computer" })
        CPanel:AddControl("Label", { Text = "2. Left click to place" })
        CPanel:AddControl("Label", { Text = "3. Press E on Computer to open interface" })
        CPanel:AddControl("Label", { Text = "4. Reload to remove items" })

        CPanel:AddControl("Label", { Text = "" })
        CPanel:AddControl("Label", { Text = "What Each Does:" })
        CPanel:AddControl("Label", { Text = "• Master Engine: The hyperdrive itself" })
        CPanel:AddControl("Label", { Text = "• Easy Computer: Simple control interface" })

        CPanel:AddControl("Label", { Text = "" })
        CPanel:AddControl("Label", { Text = "Features:" })
        CPanel:AddControl("Label", { Text = "• Auto-detects Spacebuild planets" })
        CPanel:AddControl("Label", { Text = "• One-click planet jumping" })
        CPanel:AddControl("Label", { Text = "• Easy-to-use interface" })
        CPanel:AddControl("Label", { Text = "• Automatic planet linking" })
        CPanel:AddControl("Label", { Text = "• Wiremod support" })
    end
end
