-- Advanced Space Combat - Organization Implementation
-- Ensures proper implementation of all organization systems

print("[Advanced Space Combat] Organization Implementation - Loading...")

-- Initialize ASC namespace
ASC = ASC or {}
ASC.Organization = ASC.Organization or {}

-- Implementation configuration
ASC.Organization.Config = {
    EnableToolOrganization = true,
    EnableSpawnMenuOrganization = true,
    EnableQMenuIntegration = true,
    EnableEntityRegistration = true,
    DebugMode = false
}

-- Debug function
local function DebugPrint(msg)
    if ASC.Organization.Config.DebugMode then
        print("[ASC Organization] " .. msg)
    end
end

-- Server-side implementation
if SERVER then
    -- Create console commands for organization
    concommand.Add("asc_reload_organization", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then return end
        
        -- Reload organization files
        if file.Exists("lua/autorun/client/asc_menu_organization.lua", "LUA") then
            include("autorun/client/asc_menu_organization.lua")
            AddCSLuaFile("autorun/client/asc_menu_organization.lua")
        end

        if file.Exists("lua/autorun/client/asc_spawn_menu_organization.lua", "LUA") then
            include("autorun/client/asc_spawn_menu_organization.lua")
            AddCSLuaFile("autorun/client/asc_spawn_menu_organization.lua")
        end
        
        print("[ASC] Organization systems reloaded")
        if IsValid(ply) then
            ply:PrintMessage(HUD_PRINTTALK, "[ASC] Organization systems reloaded")
        end
    end)
    
    -- Ensure client files are added
    AddCSLuaFile("autorun/client/asc_spawn_menu_organization.lua")
    AddCSLuaFile("autorun/client/asc_menu_organization.lua")
    
    print("[Advanced Space Combat] Server-side organization implementation loaded")
    return
end

-- Client-side implementation
if CLIENT then
    -- Ensure organization systems are loaded
    ASC.Organization.EnsureLoaded = function()
        -- Check if menu organization is loaded
        if not ASC.MenuOrganization then
            DebugPrint("Menu organization not loaded, including file...")
            if file.Exists("lua/autorun/client/asc_menu_organization.lua", "LUA") then
                include("autorun/client/asc_menu_organization.lua")
            end
        end

        -- Check if spawn menu organization is loaded
        if not ASC.SpawnMenu then
            DebugPrint("Spawn menu organization not loaded, including file...")
            if file.Exists("lua/autorun/client/asc_spawn_menu_organization.lua", "LUA") then
                include("autorun/client/asc_spawn_menu_organization.lua")
            end
        end
    end
    
    -- Force registration of all systems
    ASC.Organization.ForceRegistration = function()
        DebugPrint("Force registering all organization systems...")
        
        -- Ensure systems are loaded
        ASC.Organization.EnsureLoaded()
        
        -- Register menu organization
        if ASC.MenuOrganization then
            DebugPrint("Registering menu organization...")
            hook.Run("PopulateToolMenu")
        end
        
        -- Register spawn menu organization
        if ASC.SpawnMenu and ASC.SpawnMenu.RegisterEntities then
            DebugPrint("Registering spawn menu entities...")
            ASC.SpawnMenu.RegisterEntities()
            
            if ASC.SpawnMenu.RegisterTools then
                ASC.SpawnMenu.RegisterTools()
            end
        end
        
        DebugPrint("Force registration complete")
    end
    
    -- Initialize on various hooks to ensure loading
    hook.Add("Initialize", "ASC_OrganizationImplementation", function()
        timer.Simple(0.5, function()
            ASC.Organization.EnsureLoaded()
        end)
    end)
    
    hook.Add("InitPostEntity", "ASC_OrganizationImplementation", function()
        timer.Simple(1, function()
            ASC.Organization.ForceRegistration()
        end)
    end)
    
    hook.Add("OnGamemodeLoaded", "ASC_OrganizationImplementation", function()
        timer.Simple(2, function()
            ASC.Organization.ForceRegistration()
        end)
    end)
    
    -- Menu opening hooks
    hook.Add("SpawnMenuOpen", "ASC_OrganizationSpawnMenu", function()
        if not ASC.SpawnMenu then
            ASC.Organization.EnsureLoaded()
            timer.Simple(0.1, function()
                if ASC.SpawnMenu and ASC.SpawnMenu.RegisterEntities then
                    ASC.SpawnMenu.RegisterEntities()
                end
            end)
        end
    end)
    
    -- Console command for manual reload
    concommand.Add("asc_reload_organization_client", function()
        ASC.Organization.ForceRegistration()
        print("[ASC] Client organization systems reloaded")
    end)
    
    -- Status command
    concommand.Add("asc_organization_status", function()
        print("[ASC] Organization Status:")
        print("  Menu Organization: " .. (ASC.MenuOrganization and "Loaded" or "Not Loaded"))
        print("  Spawn Menu: " .. (ASC.SpawnMenu and "Loaded" or "Not Loaded"))

        if ASC.MenuOrganization then
            local toolCount = 0
            for _ in pairs(ASC.MenuOrganization.Tools or {}) do
                toolCount = toolCount + 1
            end
            print("  Tools Defined: " .. toolCount)
        end
        
        if ASC.SpawnMenu then
            local entityCount = 0
            for _, entities in pairs(ASC.SpawnMenu.Entities or {}) do
                entityCount = entityCount + #entities
            end
            print("  Entities Defined: " .. entityCount)
        end
    end)
    
    print("[Advanced Space Combat] Client-side organization implementation loaded")
end

-- Universal functions
ASC.Organization.GetStatus = function()
    local status = {
        menuOrganization = ASC.MenuOrganization ~= nil,
        spawnMenu = ASC.SpawnMenu ~= nil,
        toolCount = 0,
        entityCount = 0
    }

    if ASC.MenuOrganization and ASC.MenuOrganization.Tools then
        for _ in pairs(ASC.MenuOrganization.Tools) do
            status.toolCount = status.toolCount + 1
        end
    end
    
    if ASC.SpawnMenu and ASC.SpawnMenu.Entities then
        for _, entities in pairs(ASC.SpawnMenu.Entities) do
            status.entityCount = status.entityCount + #entities
        end
    end
    
    return status
end

print("[Advanced Space Combat] Organization Implementation - Loaded successfully!")
