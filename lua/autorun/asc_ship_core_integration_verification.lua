-- Advanced Space Combat - Ship Core Integration Verification v1.0.0
-- Ensures all systems properly integrate with the new ASC ship core

print("[Advanced Space Combat] Ship Core Integration Verification v1.0.0 Loading...")

ASC = ASC or {}
ASC.ShipCoreIntegration = ASC.ShipCoreIntegration or {}

-- Integration verification system
ASC.ShipCoreIntegration.Verifications = {
    -- Core systems
    {
        name = "Ship Detection System",
        check = function()
            return HYPERDRIVE.ShipCore and HYPERDRIVE.ShipCore.DetectShipForEngine
        end,
        fix = function()
            print("[ASC Integration] Ship detection system not available - check hyperdrive_ship_core.lua")
        end
    },
    
    -- AI System
    {
        name = "AI System Integration",
        check = function()
            return ASC.AI and ASC.AI.AddonIntegration and ASC.AI.AddonIntegration.IntegrateWithShipCore
        end,
        fix = function()
            print("[ASC Integration] AI system integration not available - check asc_ai_system_v2.lua")
        end
    },
    
    -- Weapons System
    {
        name = "Weapons System Integration",
        check = function()
            return HYPERDRIVE.Weapons and HYPERDRIVE.Weapons.RegisterWeapon
        end,
        fix = function()
            print("[ASC Integration] Weapons system integration not available - check hyperdrive_weapons_system.lua")
        end
    },
    
    -- Flight System
    {
        name = "Flight System Integration",
        check = function()
            return ASC.Flight and ASC.Flight.Core and ASC.Flight.Core.HasShipPermission
        end,
        fix = function()
            print("[ASC Integration] Flight system integration not available - check asc_flight_system.lua")
        end
    },
    
    -- Shield System
    {
        name = "Shield System Integration",
        check = function()
            return HYPERDRIVE.Shields or (ASC.Shields and ASC.Shields.Core)
        end,
        fix = function()
            print("[ASC Integration] Shield system integration not available - check shield system files")
        end
    },
    
    -- CAP Integration
    {
        name = "CAP Integration",
        check = function()
            return HYPERDRIVE.CAP and HYPERDRIVE.CAP.Available
        end,
        fix = function()
            print("[ASC Integration] CAP integration not available - CAP addon may not be installed")
        end
    },
    
    -- Resource System
    {
        name = "Resource System Integration",
        check = function()
            return HYPERDRIVE.SB3Resources or true -- Basic system always available
        end,
        fix = function()
            print("[ASC Integration] Using basic resource system - Spacebuild 3 not available")
        end
    }
}

-- Verify all integrations
function ASC.ShipCoreIntegration.VerifyAll()
    print("[ASC Integration] Verifying ship core system integrations...")
    
    local passed = 0
    local failed = 0
    local warnings = 0
    
    for _, verification in ipairs(ASC.ShipCoreIntegration.Verifications) do
        local success = verification.check()
        
        if success then
            print("[ASC Integration] ✅ " .. verification.name .. " - OK")
            passed = passed + 1
        else
            print("[ASC Integration] ❌ " .. verification.name .. " - FAILED")
            failed = failed + 1
            if verification.fix then
                verification.fix()
            end
        end
    end
    
    print("[ASC Integration] Verification complete: " .. passed .. " passed, " .. failed .. " failed")
    
    if failed == 0 then
        print("[ASC Integration] ✅ All ship core integrations verified successfully!")
    else
        print("[ASC Integration] ⚠️ Some integrations failed - functionality may be limited")
    end
    
    return failed == 0
end

-- Entity integration verification
function ASC.ShipCoreIntegration.VerifyEntityIntegration(entity)
    if not IsValid(entity) then return false end
    
    local class = entity:GetClass()
    local integrations = {}
    
    -- Check if entity can find ship cores
    if entity.FindShipCore then
        integrations.shipCoreDetection = true
    end
    
    -- Check if entity can link to ship cores
    if entity.SetShipCore or entity.shipCore then
        integrations.shipCoreLinking = true
    end
    
    -- Check if entity supports ASC ship core class
    if entity.FindShipCore then
        -- Test if it looks for the correct class
        local oldFind = ents.FindByClass
        local foundCorrectClass = false
        
        ents.FindByClass = function(className)
            if className == "asc_ship_core" then
                foundCorrectClass = true
            end
            return oldFind(className)
        end
        
        entity:FindShipCore()
        ents.FindByClass = oldFind
        
        integrations.correctClassDetection = foundCorrectClass
    end
    
    return integrations
end

-- Auto-fix entity integrations
function ASC.ShipCoreIntegration.AutoFixEntityIntegrations()
    print("[ASC Integration] Auto-fixing entity integrations...")
    
    local fixedCount = 0
    local entities = ents.GetAll()
    
    for _, ent in ipairs(entities) do
        if IsValid(ent) and ent.FindShipCore then
            local class = ent:GetClass()
            
            -- Check if entity is looking for old ship_core class
            if string.find(class, "hyperdrive_") or string.find(class, "asc_") then
                local integration = ASC.ShipCoreIntegration.VerifyEntityIntegration(ent)
                
                if not integration.correctClassDetection then
                    -- Try to fix the entity's ship core detection
                    if ent.FindShipCore then
                        -- Override the FindShipCore function to look for asc_ship_core
                        local oldFindShipCore = ent.FindShipCore
                        ent.FindShipCore = function(self)
                            local cores = ents.FindByClass("asc_ship_core")
                            local closestCore = nil
                            local closestDist = math.huge
                            
                            for _, core in ipairs(cores) do
                                if IsValid(core) then
                                    local dist = self:GetPos():Distance(core:GetPos())
                                    if dist < 2000 and dist < closestDist then
                                        closestCore = core
                                        closestDist = dist
                                    end
                                end
                            end
                            
                            if IsValid(closestCore) then
                                self.shipCore = closestCore
                                if self.SetShipCore then
                                    self:SetShipCore(closestCore)
                                end
                                return closestCore
                            end
                            
                            return nil
                        end
                        
                        -- Re-run ship core detection
                        ent:FindShipCore()
                        fixedCount = fixedCount + 1
                        
                        print("[ASC Integration] Fixed ship core detection for " .. class .. " (" .. ent:EntIndex() .. ")")
                    end
                end
            end
        end
    end
    
    print("[ASC Integration] Auto-fixed " .. fixedCount .. " entity integrations")
    return fixedCount
end

-- Hook into entity creation to ensure proper integration
hook.Add("OnEntityCreated", "ASC_ShipCoreIntegrationVerification", function(entity)
    timer.Simple(0.5, function()
        if not IsValid(entity) then return end
        
        local class = entity:GetClass()
        
        -- Auto-fix entities that should integrate with ship cores
        if string.find(class, "hyperdrive_") or string.find(class, "asc_") or 
           string.find(class, "weapon_") or string.find(class, "shield") then
            
            local integration = ASC.ShipCoreIntegration.VerifyEntityIntegration(entity)
            
            if entity.FindShipCore and not integration.correctClassDetection then
                print("[ASC Integration] Auto-fixing integration for new entity: " .. class)
                ASC.ShipCoreIntegration.AutoFixEntityIntegration(entity)
            end
        end
    end)
end)

-- Console commands for verification
if SERVER then
    concommand.Add("asc_verify_ship_core_integration", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then
            ply:ChatPrint("You must be a superadmin to use this command")
            return
        end
        
        local success = ASC.ShipCoreIntegration.VerifyAll()
        local message = success and "All integrations verified successfully!" or "Some integrations failed - check console for details"
        
        if IsValid(ply) then
            ply:ChatPrint("[ASC Integration] " .. message)
        else
            print("[ASC Integration] " .. message)
        end
    end, nil, "Verify all ship core system integrations")
    
    concommand.Add("asc_fix_ship_core_integration", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsSuperAdmin() then
            ply:ChatPrint("You must be a superadmin to use this command")
            return
        end
        
        local fixedCount = ASC.ShipCoreIntegration.AutoFixEntityIntegrations()
        local message = "Auto-fixed " .. fixedCount .. " entity integrations"
        
        if IsValid(ply) then
            ply:ChatPrint("[ASC Integration] " .. message)
        else
            print("[ASC Integration] " .. message)
        end
    end, nil, "Auto-fix entity integrations with ship cores")
end

-- Run verification on startup
timer.Simple(5, function()
    ASC.ShipCoreIntegration.VerifyAll()
    
    -- Auto-fix existing entities
    timer.Simple(2, function()
        ASC.ShipCoreIntegration.AutoFixEntityIntegrations()
    end)
end)

print("[Advanced Space Combat] Ship Core Integration Verification System Loaded Successfully!")
