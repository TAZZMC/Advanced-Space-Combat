-- Advanced Space Combat - Resource System Commands v1.0.0
-- Comprehensive resource management commands for ASC ship cores

print("[Advanced Space Combat] Resource System Commands v1.0.0 Loading...")

ASC = ASC or {}
ASC.ResourceCommands = ASC.ResourceCommands or {}

-- Resource management commands
if SERVER then
    -- Get nearby ship core for player
    local function GetPlayerShipCore(ply)
        local nearbyEnts = ents.FindInSphere(ply:GetPos(), 2000)
        for _, ent in ipairs(nearbyEnts) do
            if IsValid(ent) and ent:GetClass() == "asc_ship_core" then
                return ent
            end
        end
        return nil
    end
    
    -- Resource status command
    concommand.Add("asc_resource_status", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local shipCore = GetPlayerShipCore(ply)
        if not IsValid(shipCore) then
            ply:ChatPrint("[ASC Resources] No ship core found nearby")
            return
        end
        
        local status = shipCore:GetResourceStatus()
        
        ply:ChatPrint("=== ASC Ship Core Resource Status ===")
        ply:ChatPrint("System Active: " .. (status.systemActive and "YES" or "NO"))
        ply:ChatPrint("Emergency Mode: " .. (status.emergencyMode and "YES" or "NO"))
        ply:ChatPrint("Life Support: " .. (status.lifeSupportActive and "ACTIVE" or "INACTIVE"))
        ply:ChatPrint("Total Resources: " .. math.floor(status.totalAmount) .. "/" .. math.floor(status.totalCapacity))
        ply:ChatPrint("")
        
        for resourceType, data in pairs(status.resources) do
            local percent = math.floor(data.percent)
            local statusIcon = "🔴"
            if percent > 75 then statusIcon = "🟢"
            elseif percent > 50 then statusIcon = "🟡"
            elseif percent > 25 then statusIcon = "🟠"
            end
            
            ply:ChatPrint(statusIcon .. " " .. string.upper(resourceType) .. ": " .. 
                         math.floor(data.level) .. "/" .. math.floor(data.capacity) .. 
                         " (" .. percent .. "%)")
        end
    end, nil, "Check resource status of nearby ship core")
    
    -- Add resource command
    concommand.Add("asc_add_resource", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then
            if IsValid(ply) then
                ply:ChatPrint("You must be a superadmin to use this command")
            end
            return
        end
        
        if #args < 2 then
            ply:ChatPrint("Usage: asc_add_resource <type> <amount>")
            ply:ChatPrint("Types: energy, oxygen, coolant, fuel, water, nitrogen")
            return
        end
        
        local resourceType = string.lower(args[1])
        local amount = tonumber(args[2])
        
        if not amount or amount <= 0 then
            ply:ChatPrint("Amount must be a positive number")
            return
        end
        
        local shipCore = GetPlayerShipCore(ply)
        if not IsValid(shipCore) then
            ply:ChatPrint("[ASC Resources] No ship core found nearby")
            return
        end
        
        local success, message = shipCore:AddResource(resourceType, amount)
        if success then
            ply:ChatPrint("[ASC Resources] ✅ " .. message)
        else
            ply:ChatPrint("[ASC Resources] ❌ " .. message)
        end
    end, nil, "Add resources to nearby ship core (Admin only)")
    
    -- Remove resource command
    concommand.Add("asc_remove_resource", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then
            if IsValid(ply) then
                ply:ChatPrint("You must be a superadmin to use this command")
            end
            return
        end
        
        if #args < 2 then
            ply:ChatPrint("Usage: asc_remove_resource <type> <amount>")
            ply:ChatPrint("Types: energy, oxygen, coolant, fuel, water, nitrogen")
            return
        end
        
        local resourceType = string.lower(args[1])
        local amount = tonumber(args[2])
        
        if not amount or amount <= 0 then
            ply:ChatPrint("Amount must be a positive number")
            return
        end
        
        local shipCore = GetPlayerShipCore(ply)
        if not IsValid(shipCore) then
            ply:ChatPrint("[ASC Resources] No ship core found nearby")
            return
        end
        
        local success, message = shipCore:RemoveResource(resourceType, amount)
        if success then
            ply:ChatPrint("[ASC Resources] ✅ " .. message)
        else
            ply:ChatPrint("[ASC Resources] ❌ " .. message)
        end
    end, nil, "Remove resources from nearby ship core (Admin only)")
    
    -- Fill all resources command
    concommand.Add("asc_fill_resources", function(ply, cmd, args)
        if not IsValid(ply) or not ply:IsSuperAdmin() then
            if IsValid(ply) then
                ply:ChatPrint("You must be a superadmin to use this command")
            end
            return
        end
        
        local shipCore = GetPlayerShipCore(ply)
        if not IsValid(shipCore) then
            ply:ChatPrint("[ASC Resources] No ship core found nearby")
            return
        end
        
        local resourceTypes = {"energy", "oxygen", "coolant", "fuel", "water", "nitrogen"}
        local filled = 0
        
        for _, resourceType in ipairs(resourceTypes) do
            local capacity = shipCore:GetResourceCapacity(resourceType)
            local current = shipCore:GetResourceLevel(resourceType)
            local needed = capacity - current
            
            if needed > 0 then
                local success, message = shipCore:AddResource(resourceType, needed)
                if success then
                    filled = filled + 1
                end
            end
        end
        
        ply:ChatPrint("[ASC Resources] ✅ Filled " .. filled .. " resource types to capacity")
    end, nil, "Fill all resources to capacity (Admin only)")
    
    -- Emergency shutdown command
    concommand.Add("asc_emergency_shutdown", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local shipCore = GetPlayerShipCore(ply)
        if not IsValid(shipCore) then
            ply:ChatPrint("[ASC Resources] No ship core found nearby")
            return
        end
        
        -- Check if player owns the ship core
        local owner = shipCore:CPPIGetOwner()
        if IsValid(owner) and owner ~= ply and not ply:IsSuperAdmin() then
            ply:ChatPrint("[ASC Resources] You don't have permission to shut down this ship core")
            return
        end
        
        shipCore:EmergencyResourceShutdown()
        ply:ChatPrint("[ASC Resources] ⚠️ Emergency shutdown activated!")
    end, nil, "Emergency shutdown of ship core resource systems")
    
    -- Resource distribution command
    concommand.Add("asc_distribute_resources", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local shipCore = GetPlayerShipCore(ply)
        if not IsValid(shipCore) then
            ply:ChatPrint("[ASC Resources] No ship core found nearby")
            return
        end
        
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.DistributeResources(shipCore)
            ply:ChatPrint("[ASC Resources] ✅ Resource distribution initiated")
        else
            ply:ChatPrint("[ASC Resources] Resource distribution not available (basic mode)")
        end
    end, nil, "Distribute resources to ship entities")
    
    -- Resource collection command
    concommand.Add("asc_collect_resources", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local shipCore = GetPlayerShipCore(ply)
        if not IsValid(shipCore) then
            ply:ChatPrint("[ASC Resources] No ship core found nearby")
            return
        end
        
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.CollectResources(shipCore)
            ply:ChatPrint("[ASC Resources] ✅ Resource collection initiated")
        else
            ply:ChatPrint("[ASC Resources] Resource collection not available (basic mode)")
        end
    end, nil, "Collect resources from ship entities")
    
    -- Balance resources command
    concommand.Add("asc_balance_resources", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        local shipCore = GetPlayerShipCore(ply)
        if not IsValid(shipCore) then
            ply:ChatPrint("[ASC Resources] No ship core found nearby")
            return
        end
        
        if HYPERDRIVE.SB3Resources then
            HYPERDRIVE.SB3Resources.AutoBalanceResources(shipCore)
            ply:ChatPrint("[ASC Resources] ✅ Resource balancing initiated")
        else
            ply:ChatPrint("[ASC Resources] Resource balancing not available (basic mode)")
        end
    end, nil, "Auto-balance resources across ship")
    
    -- Resource help command
    concommand.Add("asc_resource_help", function(ply, cmd, args)
        if not IsValid(ply) then return end
        
        ply:ChatPrint("=== ASC Resource System Commands ===")
        ply:ChatPrint("asc_resource_status - Check resource levels")
        ply:ChatPrint("asc_distribute_resources - Distribute to ship entities")
        ply:ChatPrint("asc_collect_resources - Collect from ship entities")
        ply:ChatPrint("asc_balance_resources - Auto-balance resources")
        ply:ChatPrint("asc_emergency_shutdown - Emergency shutdown")
        ply:ChatPrint("")
        ply:ChatPrint("=== Admin Commands ===")
        ply:ChatPrint("asc_add_resource <type> <amount> - Add resources")
        ply:ChatPrint("asc_remove_resource <type> <amount> - Remove resources")
        ply:ChatPrint("asc_fill_resources - Fill all to capacity")
        ply:ChatPrint("")
        ply:ChatPrint("Resource Types: energy, oxygen, coolant, fuel, water, nitrogen")
    end, nil, "Show resource system help")
end

print("[Advanced Space Combat] Resource System Commands Loaded Successfully!")
