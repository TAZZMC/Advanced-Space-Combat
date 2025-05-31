-- Enhanced Hyperdrive System - Spawn Menu Integration
-- Adds hyperdrive entities to the spawn menu for easy access

if SERVER then return end

-- Add hyperdrive entities to spawn menu
hook.Add("PopulateEntities", "HyperdriveSpawnMenu", function(pnlContent, tree, node)
    if not IsValid(pnlContent) or not IsValid(tree) then return end

    -- Create Enhanced Hyperdrive category
    local hyperdriveNode = tree:AddNode("Enhanced Hyperdrive", "icon16/star.png")

    -- Ship Core
    local shipCoreIcon = vgui.Create("SpawnIcon")
    if IsValid(shipCoreIcon) then
        shipCoreIcon:SetModel("models/props_phx/construct/metal_plate1.mdl")
        shipCoreIcon.DoClick = function()
            RunConsoleCommand("gm_spawnsent", "ship_core")
        end
        shipCoreIcon:SetTooltip("Ship Core\nCentral management system for ships\nHandles entity detection, resources, and systems")

        -- Safely add to content panel
        if pnlContent.AddItem then
            pnlContent:AddItem(shipCoreIcon)
        elseif pnlContent.Add then
            pnlContent:Add(shipCoreIcon)
        end
    end

    -- Hyperdrive Engine
    local engineIcon = vgui.Create("SpawnIcon")
    if IsValid(engineIcon) then
        engineIcon:SetModel("models/props_phx/construct/metal_plate2.mdl")
        engineIcon.DoClick = function()
            RunConsoleCommand("gm_spawnsent", "hyperdrive_engine")
        end
        engineIcon:SetTooltip("Hyperdrive Engine\nAdvanced FTL propulsion system\nSupports Stargate-style 4-stage travel")

        -- Safely add to content panel
        if pnlContent.AddItem then
            pnlContent:AddItem(engineIcon)
        elseif pnlContent.Add then
            pnlContent:Add(engineIcon)
        end
    end
end)

-- Add hyperdrive tools to spawn menu
hook.Add("PopulateTools", "HyperdriveToolsMenu", function(pnlContent, tree, node)
    if not IsValid(pnlContent) or not IsValid(tree) then return end

    -- Create Enhanced Hyperdrive tools category
    local hyperdriveNode = tree:AddNode("Enhanced Hyperdrive", "icon16/wrench.png")

    -- Enhanced Hyperdrive Tool (Integrated)
    local hyperdriveToolIcon = vgui.Create("SpawnIcon")
    if IsValid(hyperdriveToolIcon) then
        hyperdriveToolIcon:SetModel("models/weapons/w_toolgun.mdl")
        hyperdriveToolIcon.DoClick = function()
            RunConsoleCommand("gmod_tool", "hyperdrive")
        end
        hyperdriveToolIcon:SetTooltip("Enhanced Hyperdrive Tool\nComprehensive tool for spawning and configuring:\n• Ship Cores\n• Hyperdrive Engines\n• Shield Generators\n• CAP Integration\n• Advanced Configuration")

        -- Safely add to content panel
        if pnlContent.AddItem then
            pnlContent:AddItem(hyperdriveToolIcon)
        elseif pnlContent.Add then
            pnlContent:Add(hyperdriveToolIcon)
        end
    end
end)

-- Add context menu options for hyperdrive entities
hook.Add("OnEntityContextMenuOpen", "HyperdriveContextMenu", function(entity, menu)
    if not IsValid(entity) then return end

    local class = entity:GetClass()

    -- Ship Core context menu
    if class == "ship_core" then
        menu:AddOption("Open Ship Core Interface", function()
            if entity.OpenUI then
                entity:OpenUI(LocalPlayer())
            else
                LocalPlayer():ChatPrint("[Ship Core] Interface not available")
            end
        end):SetIcon("icon16/cog.png")

        menu:AddOption("Detect Ship Entities", function()
            net.Start("ship_core_command")
            net.WriteEntity(entity)
            net.WriteString("detect_entities")
            net.WriteTable({})
            net.SendToServer()
        end):SetIcon("icon16/magnifier.png")

        menu:AddOption("Show Ship Status", function()
            local shipName = entity:GetNWString("ShipName", "Unknown Ship")
            local shipType = entity:GetNWString("ShipType", "Unknown Type")
            local coreState = entity:GetNWInt("CoreState", 0)
            local stateText = coreState == 0 and "Operational" or coreState == 1 and "Warning" or coreState == 2 and "Critical" or "Emergency"

            LocalPlayer():ChatPrint("[Ship Core] Ship: " .. shipName .. " (" .. shipType .. ")")
            LocalPlayer():ChatPrint("[Ship Core] Status: " .. stateText)
        end):SetIcon("icon16/information.png")
    end

    -- Hyperdrive Engine context menu
    if class == "hyperdrive_engine" then
        menu:AddOption("Open Engine Interface", function()
            if entity.OpenEngineInterface then
                entity:OpenEngineInterface(LocalPlayer())
            else
                LocalPlayer():ChatPrint("[Hyperdrive Engine] Interface not available")
            end
        end):SetIcon("icon16/cog.png")

        menu:AddOption("Charge Engine", function()
            net.Start("hyperdrive_command")
            net.WriteEntity(entity)
            net.WriteString("charge")
            net.WriteTable({})
            net.SendToServer()
        end):SetIcon("icon16/lightning.png")

        menu:AddOption("Show Engine Status", function()
            local energy = entity:GetNWFloat("Energy", 0)
            local maxEnergy = entity:GetNWFloat("MaxEnergy", 1000)
            local charging = entity:GetNWBool("Charging", false)
            local cooldown = entity:GetNWBool("OnCooldown", false)

            LocalPlayer():ChatPrint("[Hyperdrive Engine] Energy: " .. math.floor(energy) .. "/" .. maxEnergy)
            LocalPlayer():ChatPrint("[Hyperdrive Engine] Status: " .. (charging and "Charging" or cooldown and "Cooldown" or "Ready"))
        end):SetIcon("icon16/information.png")
    end

    -- Shield Generator context menu (for CAP shields)
    if class:find("shield") then
        menu:AddOption("Toggle Shield", function()
            -- Try multiple activation methods for compatibility
            if entity.Toggle then
                entity:Toggle()
            elseif entity.Activate and entity.Deactivate then
                if entity:GetNWBool("Active", false) then
                    entity:Deactivate()
                else
                    entity:Activate()
                end
            end
        end):SetIcon("icon16/shield.png")

        menu:AddOption("Show Shield Status", function()
            local active = entity:GetNWBool("Active", false)
            local strength = entity:GetNWFloat("ShieldStrength", 0)
            local maxStrength = entity:GetNWFloat("MaxShieldStrength", 100)
            local frequency = entity:GetNWInt("Frequency", 0)

            LocalPlayer():ChatPrint("[Shield] Status: " .. (active and "Active" or "Inactive"))
            LocalPlayer():ChatPrint("[Shield] Strength: " .. math.floor(strength) .. "/" .. maxStrength)
            if frequency > 0 then
                LocalPlayer():ChatPrint("[Shield] Frequency: " .. frequency)
            end
        end):SetIcon("icon16/information.png")
    end
end)

-- Add admin commands to context menu
hook.Add("OnPlayerContextMenuOpen", "HyperdriveAdminMenu", function(ply, menu)
    if not LocalPlayer():IsSuperAdmin() then return end

    local adminMenu = menu:AddSubMenu("Enhanced Hyperdrive Admin")
    adminMenu:SetIcon("icon16/star.png")

    adminMenu:AddOption("Validate System", function()
        RunConsoleCommand("hyperdrive_validate")
    end):SetIcon("icon16/tick.png")

    adminMenu:AddOption("Auto-Fix Issues", function()
        RunConsoleCommand("hyperdrive_autofix")
    end):SetIcon("icon16/wrench.png")

    adminMenu:AddOption("Run Startup Test", function()
        RunConsoleCommand("hyperdrive_startup_test")
    end):SetIcon("icon16/cog.png")

    adminMenu:AddOption("Check CAP Status", function()
        RunConsoleCommand("hyperdrive_cap_status")
    end):SetIcon("icon16/information.png")

    adminMenu:AddOption("Open Entity Selector", function()
        if HYPERDRIVE and HYPERDRIVE.EntitySelector then
            HYPERDRIVE.EntitySelector.Open(function(entity)
                LocalPlayer():ChatPrint("[Hyperdrive] Selected: " .. entity:GetClass())
            end)
        else
            LocalPlayer():ChatPrint("[Hyperdrive] Entity selector not available")
        end
    end):SetIcon("icon16/application_view_list.png")
end)

-- Add quick spawn buttons to HUD (optional)
local function CreateQuickSpawnHUD()
    if not GetConVar("hyperdrive_quick_spawn_hud"):GetBool() then return end
    if not LocalPlayer():IsSuperAdmin() then return end

    local frame = vgui.Create("DPanel")
    frame:SetSize(200, 120)
    frame:SetPos(ScrW() - 220, 50)
    frame:SetPaintBackground(false)

    frame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 150))
        draw.SimpleText("Quick Spawn", "DermaDefaultBold", w/2, 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    end

    local shipCoreBtn = vgui.Create("DButton", frame)
    shipCoreBtn:SetPos(10, 25)
    shipCoreBtn:SetSize(180, 25)
    shipCoreBtn:SetText("Spawn Ship Core")
    shipCoreBtn.DoClick = function()
        RunConsoleCommand("gm_spawnsent", "ship_core")
    end

    local engineBtn = vgui.Create("DButton", frame)
    engineBtn:SetPos(10, 55)
    engineBtn:SetSize(180, 25)
    engineBtn:SetText("Spawn Hyperdrive Engine")
    engineBtn.DoClick = function()
        RunConsoleCommand("gm_spawnsent", "hyperdrive_engine")
    end

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(10, 85)
    closeBtn:SetSize(180, 25)
    closeBtn:SetText("Close")
    closeBtn.DoClick = function()
        frame:Remove()
    end

    return frame
end

-- Console command to show quick spawn HUD
concommand.Add("hyperdrive_quick_spawn", function()
    if LocalPlayer():IsSuperAdmin() then
        CreateQuickSpawnHUD()
    else
        LocalPlayer():ChatPrint("[Hyperdrive] Admin privileges required")
    end
end)

-- Create ConVar for quick spawn HUD
CreateClientConVar("hyperdrive_quick_spawn_hud", "0", true, false, "Enable quick spawn HUD for hyperdrive entities")

print("[Hyperdrive] Spawn menu integration loaded")
