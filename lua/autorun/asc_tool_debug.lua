-- Advanced Space Combat - Tool Debug System
-- Helps debug tool usage issues on ship cores

print("[ASC Tool Debug] Tool debugging system loaded")

if SERVER then
    -- Debug hook for CanTool
    hook.Add("CanTool", "ASC_ToolDebug", function(ply, tr, tool)
        if IsValid(tr.Entity) and tr.Entity:GetClass() == "asc_ship_core" then
            print("[ASC Tool Debug] CanTool called:")
            print("  Player: " .. (IsValid(ply) and ply:Name() or "Invalid"))
            print("  Tool: " .. (tool or "nil"))
            print("  Entity: " .. tr.Entity:GetClass())
            print("  Entity Owner: " .. (IsValid(tr.Entity:CPPIGetOwner()) and tr.Entity:CPPIGetOwner():Name() or "No owner"))
            print("  Player is Admin: " .. tostring(ply:IsAdmin()))
            
            -- Check if entity has CanTool function
            if tr.Entity.CanTool then
                local result = tr.Entity:CanTool(ply, tr, tool)
                print("  Entity CanTool result: " .. tostring(result))
                return result
            else
                print("  Entity has no CanTool function")
            end
        end
    end)
    
    -- Debug hook for tool usage
    hook.Add("CanProperty", "ASC_PropertyDebug", function(ply, property, ent)
        if IsValid(ent) and ent:GetClass() == "asc_ship_core" then
            print("[ASC Tool Debug] CanProperty called:")
            print("  Player: " .. (IsValid(ply) and ply:Name() or "Invalid"))
            print("  Property: " .. (property or "nil"))
            print("  Entity: " .. ent:GetClass())
        end
    end)
    
    -- Console command to test tool access
    concommand.Add("asc_test_tool_access", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local tr = ply:GetEyeTrace()
        if not IsValid(tr.Entity) or tr.Entity:GetClass() ~= "asc_ship_core" then
            ply:ChatPrint("Look at an ASC ship core to test tool access")
            return
        end
        
        local tool = args[1] or "weld"
        local shipCore = tr.Entity
        
        ply:ChatPrint("Testing tool access for: " .. tool)
        
        -- Test entity CanTool
        if shipCore.CanTool then
            local result = shipCore:CanTool(ply, tr, tool)
            ply:ChatPrint("Entity CanTool result: " .. tostring(result))
        else
            ply:ChatPrint("Entity has no CanTool function")
        end
        
        -- Test global CanTool hook
        local hookResult = hook.Run("CanTool", ply, tr, tool)
        ply:ChatPrint("Global CanTool hook result: " .. tostring(hookResult))
        
        -- Check ownership
        local owner = shipCore:CPPIGetOwner()
        if IsValid(owner) then
            ply:ChatPrint("Ship core owner: " .. owner:Name())
            ply:ChatPrint("You are owner: " .. tostring(owner == ply))
        else
            ply:ChatPrint("Ship core has no owner")
        end
        
        ply:ChatPrint("You are admin: " .. tostring(ply:IsAdmin()))
    end)
    
    -- Console command to toggle tool debugging
    concommand.Add("asc_toggle_tool_debug", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsAdmin() then return end
        
        local enabled = GetConVar("asc_tool_debug_enabled")
        if enabled then
            enabled:SetBool(not enabled:GetBool())
            ply:ChatPrint("ASC Tool Debug: " .. (enabled:GetBool() and "Enabled" or "Disabled"))
        end
    end)
    
    -- Create ConVar for debug control
    CreateConVar("asc_tool_debug_enabled", "1", FCVAR_ARCHIVE, "Enable ASC tool debugging")
end

print("[ASC Tool Debug] Tool debugging system initialized")
