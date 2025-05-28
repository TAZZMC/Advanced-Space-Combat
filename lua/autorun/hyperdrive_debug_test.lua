-- Hyperdrive Debug Test System
-- This file helps debug hyperspace transportation issues

if CLIENT then return end

-- Debug command to test hyperspace system
concommand.Add("hyperdrive_debug_test", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        ply:ChatPrint("[Hyperdrive Debug] Admin only command")
        return
    end

    print("[Hyperdrive Debug] Running hyperspace system test...")

    -- Check if hyperspace dimension system is loaded
    if HYPERDRIVE and HYPERDRIVE.HyperspaceDimension then
        print("[Hyperdrive Debug] ✓ Hyperspace dimension system loaded")
        print("[Hyperdrive Debug] ✓ StartHyperspaceTravel function: " .. tostring(HYPERDRIVE.HyperspaceDimension.StartHyperspaceTravel))
        print("[Hyperdrive Debug] ✓ EndHyperspaceTravel function: " .. tostring(HYPERDRIVE.HyperspaceDimension.EndHyperspaceTravel))

        -- Count active travels (need to access the local variables)
        local activeCount = 0
        local hyperspaceCount = 0

        -- Try to get counts if possible
        if HYPERDRIVE.HyperspaceDimension.GetActiveCount then
            activeCount = HYPERDRIVE.HyperspaceDimension.GetActiveCount()
        end
        if HYPERDRIVE.HyperspaceDimension.GetHyperspaceEntityCount then
            hyperspaceCount = HYPERDRIVE.HyperspaceDimension.GetHyperspaceEntityCount()
        end

        print("[Hyperdrive Debug] ✓ Active travels: " .. activeCount)
        print("[Hyperdrive Debug] ✓ Hyperspace entities: " .. hyperspaceCount)
    else
        print("[Hyperdrive Debug] ✗ Hyperspace dimension system NOT loaded")
    end

    -- Check if newer hyperspace system is loaded
    if HYPERDRIVE and HYPERDRIVE.Hyperspace then
        print("[Hyperdrive Debug] ✓ Newer hyperspace system also loaded")
        print("[Hyperdrive Debug] ✓ Active transits: " .. table.Count(HYPERDRIVE.Hyperspace.ActiveTransits))
        print("[Hyperdrive Debug] ✓ Hyperspace entities: " .. table.Count(HYPERDRIVE.Hyperspace.HyperspaceEntities))
    else
        print("[Hyperdrive Debug] ✓ Newer hyperspace system not loaded (using dimension system)")
    end

    -- Find nearby engines
    local engines = {}
    for _, ent in ipairs(ents.FindInSphere(ply:GetPos(), 1000)) do
        if IsValid(ent) and ent:GetClass() == "hyperdrive_master_engine" then
            table.insert(engines, ent)
        end
    end

    print("[Hyperdrive Debug] Found " .. #engines .. " master engines nearby")

    for i, engine in ipairs(engines) do
        print("[Hyperdrive Debug] Engine " .. i .. ":")
        print("  Position: " .. tostring(engine:GetPos()))
        print("  Energy: " .. tostring(engine:GetEnergy()))
        print("  In Hyperspace: " .. tostring(engine.InHyperspace))
        print("  Active Transit: " .. tostring(HYPERDRIVE.Hyperspace.ActiveTransits[engine:EntIndex()] ~= nil))
    end

    ply:ChatPrint("[Hyperdrive Debug] Test completed - check console for results")
end)

-- Debug command to force exit hyperspace
concommand.Add("hyperdrive_debug_force_exit", function(ply, cmd, args)
    if not IsValid(ply) or not ply:IsAdmin() then
        ply:ChatPrint("[Hyperdrive Debug] Admin only command")
        return
    end

    local exitCount = 0

    -- Force exit all active hyperspace dimension travels
    if HYPERDRIVE and HYPERDRIVE.HyperspaceDimension then
        local activeTravels = HYPERDRIVE.HyperspaceDimension.GetActiveTravels()
        for travelId, travelData in pairs(activeTravels) do
            if IsValid(travelData.engine) then
                HYPERDRIVE.HyperspaceDimension.EndHyperspaceTravel(travelId)
                exitCount = exitCount + 1
            end
        end

        -- Clear any stuck entities in hyperspace dimension
        local hyperspaceEntities = HYPERDRIVE.HyperspaceDimension.GetHyperspaceEntities()
        for ent, travelId in pairs(hyperspaceEntities) do
            if IsValid(ent) then
                ent.HyperspaceOriginalPos = nil
                ent.HyperspaceOriginalAng = nil
                ent.HyperspaceTravelId = nil

                if ent:IsPlayer() then
                    ent:SetGravity(1)
                    ent:ChatPrint("[Hyperdrive Debug] Forced exit from hyperspace dimension")
                end
            end
        end
    end

    -- Also force exit newer hyperspace system if present
    if HYPERDRIVE and HYPERDRIVE.Hyperspace and HYPERDRIVE.Hyperspace.ActiveTransits then
        for entIndex, transitData in pairs(HYPERDRIVE.Hyperspace.ActiveTransits) do
            if IsValid(transitData.engine) then
                HYPERDRIVE.Hyperspace.ExitHyperspace(transitData.engine)
                exitCount = exitCount + 1
            end
        end

        -- Clear any stuck entities
        for entIndex, ent in pairs(HYPERDRIVE.Hyperspace.HyperspaceEntities) do
            if IsValid(ent) then
                ent.InHyperspace = false
                ent.HyperspaceTransitData = nil
                ent.HyperspaceOriginalPos = nil
                ent.HyperspaceOriginalAng = nil
                HYPERDRIVE.Hyperspace.HyperspaceEntities[entIndex] = nil

                if ent:IsPlayer() then
                    ent:SetGravity(1)
                    ent:ChatPrint("[Hyperdrive Debug] Forced exit from hyperspace")
                end
            end
        end
    end

    ply:ChatPrint("[Hyperdrive Debug] Forced exit of " .. exitCount .. " hyperspace transits")
    print("[Hyperdrive Debug] Force exit completed")
end)

-- Debug command to show hyperspace status
concommand.Add("hyperdrive_debug_status", function(ply, cmd, args)
    if not IsValid(ply) then return end

    local status = {}
    table.insert(status, "=== Hyperdrive Status ===")

    if HYPERDRIVE and HYPERDRIVE.Hyperspace then
        table.insert(status, "Hyperspace System: LOADED")
        table.insert(status, "Active Transits: " .. table.Count(HYPERDRIVE.Hyperspace.ActiveTransits))
        table.insert(status, "Hyperspace Entities: " .. table.Count(HYPERDRIVE.Hyperspace.HyperspaceEntities))

        -- Show active transits
        for entIndex, transitData in pairs(HYPERDRIVE.Hyperspace.ActiveTransits) do
            local engine = transitData.engine
            if IsValid(engine) then
                table.insert(status, "  Transit " .. entIndex .. ": " .. engine:GetClass() .. " -> " .. tostring(transitData.destination))
            end
        end

        -- Show entities in hyperspace
        for entIndex, ent in pairs(HYPERDRIVE.Hyperspace.HyperspaceEntities) do
            if IsValid(ent) then
                table.insert(status, "  Entity " .. entIndex .. ": " .. ent:GetClass() .. " (" .. tostring(ent) .. ")")
            end
        end
    else
        table.insert(status, "Hyperspace System: NOT LOADED")
    end

    -- Player status
    if ply.InHyperspace then
        table.insert(status, "Player Status: IN HYPERSPACE")
    else
        table.insert(status, "Player Status: Normal Space")
    end

    for _, line in ipairs(status) do
        ply:ChatPrint(line)
    end
end)

-- Debug command to fix white screen issues
concommand.Add("hyperdrive_debug_fix_white_screen", function(ply, cmd, args)
    if CLIENT then
        -- Stop all hyperspace animations
        if HYPERDRIVE and HYPERDRIVE.HyperspaceWindow then
            HYPERDRIVE.HyperspaceWindow.Stop()
            print("[Hyperdrive Debug] Stopped hyperspace window animations")
        end

        -- Disable hyperspace effects
        if HYPERDRIVE and HYPERDRIVE.Hyperspace and HYPERDRIVE.Hyperspace.Effects then
            HYPERDRIVE.Hyperspace.Effects.ExitHyperspace()
            print("[Hyperdrive Debug] Disabled hyperspace effects")
        end

        -- Remove any screen modification hooks
        hook.Remove("RenderScreenspaceEffects", "HyperdriveDistortion")
        hook.Remove("RenderScreenspaceEffects", "HyperdriveHyperspaceEffects")

        -- Reset color modification
        local resetColorMod = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 1,
            ["$pp_colour_contrast"] = 1,
            ["$pp_colour_colour"] = 1,
            ["$pp_colour_mulr"] = 1,
            ["$pp_colour_mulg"] = 1,
            ["$pp_colour_mulb"] = 1
        }
        DrawColorModify(resetColorMod)

        -- Remove any flash panels
        for _, panel in ipairs(vgui.GetWorldPanel():GetChildren()) do
            if IsValid(panel) and panel:GetZPos() >= 1000 then
                panel:Remove()
            end
        end

        chat.AddText(Color(100, 255, 100), "[Hyperdrive Debug] White screen fix applied")
        print("[Hyperdrive Debug] White screen fix completed")
    end
end)

print("[Hyperdrive Debug] Debug test system loaded")
