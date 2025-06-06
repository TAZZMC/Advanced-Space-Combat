-- Advanced Space Combat - Entity Component System v1.0.0
-- Modern ECS architecture for better modularity and performance

print("[Advanced Space Combat] Entity Component System v1.0.0 - Loading...")

-- Initialize namespace
ASC = ASC or {}
ASC.ECS = ASC.ECS or {}

-- ECS Configuration
ASC.ECS.Config = {
    MaxEntities = 10000,
    MaxComponents = 100,
    UpdateRate = 0.1, -- 10 FPS for ECS updates
    EnableProfiling = true
}

-- Component registry
ASC.ECS.Components = {}
ASC.ECS.ComponentTypes = {}
ASC.ECS.NextComponentID = 1

-- Entity management
ASC.ECS.Entities = {}
ASC.ECS.NextEntityID = 1
ASC.ECS.FreeEntityIDs = {}

-- System registry
ASC.ECS.Systems = {}
ASC.ECS.SystemOrder = {}

-- Performance tracking
ASC.ECS.Performance = {
    ComponentUpdates = 0,
    SystemUpdates = 0,
    LastUpdate = 0
}

-- Register a new component type
function ASC.ECS.RegisterComponent(name, schema)
    if ASC.ECS.ComponentTypes[name] then
        print("[ASC ECS] Warning: Component " .. name .. " already registered")
        return
    end
    
    local componentID = ASC.ECS.NextComponentID
    ASC.ECS.NextComponentID = ASC.ECS.NextComponentID + 1
    
    ASC.ECS.ComponentTypes[name] = {
        id = componentID,
        name = name,
        schema = schema or {},
        instances = {}
    }
    
    print("[ASC ECS] Registered component: " .. name .. " (ID: " .. componentID .. ")")
    return componentID
end

-- Create a new entity
function ASC.ECS.CreateEntity()
    local entityID
    
    if #ASC.ECS.FreeEntityIDs > 0 then
        entityID = table.remove(ASC.ECS.FreeEntityIDs)
    else
        entityID = ASC.ECS.NextEntityID
        ASC.ECS.NextEntityID = ASC.ECS.NextEntityID + 1
    end
    
    ASC.ECS.Entities[entityID] = {
        id = entityID,
        components = {},
        active = true,
        created = CurTime()
    }
    
    return entityID
end

-- Destroy an entity
function ASC.ECS.DestroyEntity(entityID)
    if not ASC.ECS.Entities[entityID] then return false end
    
    -- Remove all components
    for componentName, _ in pairs(ASC.ECS.Entities[entityID].components) do
        ASC.ECS.RemoveComponent(entityID, componentName)
    end
    
    -- Mark entity as inactive
    ASC.ECS.Entities[entityID].active = false
    ASC.ECS.Entities[entityID] = nil
    
    -- Add to free list
    table.insert(ASC.ECS.FreeEntityIDs, entityID)
    
    return true
end

-- Add component to entity
function ASC.ECS.AddComponent(entityID, componentName, data)
    if not ASC.ECS.Entities[entityID] then
        print("[ASC ECS] Error: Entity " .. entityID .. " does not exist")
        return false
    end
    
    if not ASC.ECS.ComponentTypes[componentName] then
        print("[ASC ECS] Error: Component type " .. componentName .. " not registered")
        return false
    end
    
    local componentType = ASC.ECS.ComponentTypes[componentName]
    local componentData = {}
    
    -- Apply schema defaults
    for key, defaultValue in pairs(componentType.schema) do
        componentData[key] = (data and data[key]) or defaultValue
    end
    
    -- Add custom data
    if data then
        for key, value in pairs(data) do
            if not componentType.schema[key] then
                componentData[key] = value
            end
        end
    end
    
    -- Store component
    ASC.ECS.Entities[entityID].components[componentName] = componentData
    componentType.instances[entityID] = componentData
    
    return true
end

-- Remove component from entity
function ASC.ECS.RemoveComponent(entityID, componentName)
    if not ASC.ECS.Entities[entityID] then return false end
    if not ASC.ECS.ComponentTypes[componentName] then return false end
    
    ASC.ECS.Entities[entityID].components[componentName] = nil
    ASC.ECS.ComponentTypes[componentName].instances[entityID] = nil
    
    return true
end

-- Get component from entity
function ASC.ECS.GetComponent(entityID, componentName)
    if not ASC.ECS.Entities[entityID] then return nil end
    return ASC.ECS.Entities[entityID].components[componentName]
end

-- Check if entity has component
function ASC.ECS.HasComponent(entityID, componentName)
    if not ASC.ECS.Entities[entityID] then return false end
    return ASC.ECS.Entities[entityID].components[componentName] ~= nil
end

-- Register a system
function ASC.ECS.RegisterSystem(name, system)
    ASC.ECS.Systems[name] = system
    table.insert(ASC.ECS.SystemOrder, name)
    
    -- Initialize system if it has an Init function
    if system.Init then
        system.Init()
    end
    
    print("[ASC ECS] Registered system: " .. name)
end

-- Query entities with specific components
function ASC.ECS.Query(componentNames)
    local results = {}
    
    for entityID, entity in pairs(ASC.ECS.Entities) do
        if entity.active then
            local hasAllComponents = true
            
            for _, componentName in ipairs(componentNames) do
                if not entity.components[componentName] then
                    hasAllComponents = false
                    break
                end
            end
            
            if hasAllComponents then
                table.insert(results, entityID)
            end
        end
    end
    
    return results
end

-- Update all systems
function ASC.ECS.Update()
    local startTime = SysTime()
    
    for _, systemName in ipairs(ASC.ECS.SystemOrder) do
        local system = ASC.ECS.Systems[systemName]
        
        if system.Update then
            local systemStartTime = SysTime()
            system.Update()
            
            if ASC.ECS.Config.EnableProfiling then
                local systemTime = SysTime() - systemStartTime
                system.LastUpdateTime = systemTime
            end
        end
    end
    
    ASC.ECS.Performance.SystemUpdates = ASC.ECS.Performance.SystemUpdates + 1
    ASC.ECS.Performance.LastUpdate = SysTime() - startTime
end

-- Built-in components for ASC
ASC.ECS.RegisterComponent("Transform", {
    position = Vector(0, 0, 0),
    angles = Angle(0, 0, 0),
    scale = Vector(1, 1, 1)
})

ASC.ECS.RegisterComponent("Health", {
    current = 100,
    maximum = 100,
    regeneration = 0
})

ASC.ECS.RegisterComponent("Energy", {
    current = 100,
    maximum = 100,
    regeneration = 1,
    consumption = 0
})

ASC.ECS.RegisterComponent("ShipCore", {
    name = "Unnamed Ship",
    owner = "",
    hull_integrity = 100,
    shield_active = false,
    life_support = true
})

ASC.ECS.RegisterComponent("Weapon", {
    type = "pulse_cannon",
    damage = 50,
    range = 2000,
    cooldown = 1.0,
    last_fired = 0,
    ammunition = 100
})

ASC.ECS.RegisterComponent("Shield", {
    strength = 100,
    maximum = 100,
    regeneration = 5,
    active = false,
    bubble_radius = 500
})

-- Built-in systems for ASC
ASC.ECS.RegisterSystem("HealthSystem", {
    Update = function()
        local entities = ASC.ECS.Query({"Health"})
        
        for _, entityID in ipairs(entities) do
            local health = ASC.ECS.GetComponent(entityID, "Health")
            
            if health.regeneration > 0 and health.current < health.maximum then
                health.current = math.min(health.maximum, health.current + health.regeneration * ASC.ECS.Config.UpdateRate)
            end
        end
    end
})

ASC.ECS.RegisterSystem("EnergySystem", {
    Update = function()
        local entities = ASC.ECS.Query({"Energy"})
        
        for _, entityID in ipairs(entities) do
            local energy = ASC.ECS.GetComponent(entityID, "Energy")
            
            -- Apply consumption
            energy.current = math.max(0, energy.current - energy.consumption * ASC.ECS.Config.UpdateRate)
            
            -- Apply regeneration
            if energy.regeneration > 0 and energy.current < energy.maximum then
                energy.current = math.min(energy.maximum, energy.current + energy.regeneration * ASC.ECS.Config.UpdateRate)
            end
        end
    end
})

ASC.ECS.RegisterSystem("ShieldSystem", {
    Update = function()
        local entities = ASC.ECS.Query({"Shield", "Energy"})
        
        for _, entityID in ipairs(entities) do
            local shield = ASC.ECS.GetComponent(entityID, "Shield")
            local energy = ASC.ECS.GetComponent(entityID, "Energy")
            
            if shield.active and energy.current > 0 then
                -- Consume energy for shields
                energy.current = math.max(0, energy.current - 2 * ASC.ECS.Config.UpdateRate)
                
                -- Regenerate shields
                if shield.regeneration > 0 and shield.strength < shield.maximum then
                    shield.strength = math.min(shield.maximum, shield.strength + shield.regeneration * ASC.ECS.Config.UpdateRate)
                end
            else
                shield.active = false
            end
        end
    end
})

-- Integration with existing ASC entities
function ASC.ECS.IntegrateEntity(gmodEntity)
    if not IsValid(gmodEntity) then return nil end
    
    local entityID = ASC.ECS.CreateEntity()
    
    -- Add Transform component
    ASC.ECS.AddComponent(entityID, "Transform", {
        position = gmodEntity:GetPos(),
        angles = gmodEntity:GetAngles()
    })
    
    -- Add components based on entity class
    local class = gmodEntity:GetClass()
    
    if class == "ship_core" then
        ASC.ECS.AddComponent(entityID, "Health", {
            current = gmodEntity:Health(),
            maximum = gmodEntity:GetMaxHealth()
        })
        
        ASC.ECS.AddComponent(entityID, "ShipCore", {
            name = gmodEntity:GetNWString("ShipName", "Unnamed Ship"),
            owner = gmodEntity:GetNWString("Owner", ""),
            hull_integrity = gmodEntity:GetNWFloat("HullIntegrity", 100)
        })
    elseif class:find("weapon") then
        ASC.ECS.AddComponent(entityID, "Weapon", {
            type = class,
            damage = gmodEntity.Damage or 50,
            range = gmodEntity.Range or 2000
        })
    end
    
    -- Store reference
    gmodEntity.ECSEntityID = entityID
    
    return entityID
end

-- Register ECS with master scheduler
if SERVER then
    timer.Simple(4, function()
        if ASC and ASC.MasterScheduler then
            ASC.MasterScheduler.RegisterTask("ASC_ECS", "Medium", function()
                ASC.ECS.Update()
            end, ASC.ECS.Config.UpdateRate)
        else
            -- Fallback timer if master scheduler not available
            timer.Create("ASC_ECS_Update", ASC.ECS.Config.UpdateRate, 0, function()
                ASC.ECS.Update()
            end)
        end
    end)
end

-- Console commands
concommand.Add("asc_ecs_stats", function(ply, cmd, args)
    local stats = {
        "Entity Count: " .. table.Count(ASC.ECS.Entities),
        "Component Types: " .. table.Count(ASC.ECS.ComponentTypes),
        "Systems: " .. table.Count(ASC.ECS.Systems),
        "System Updates: " .. ASC.ECS.Performance.SystemUpdates,
        "Last Update Time: " .. string.format("%.3f ms", ASC.ECS.Performance.LastUpdate * 1000)
    }
    
    if IsValid(ply) then
        ply:ChatPrint("[Advanced Space Combat] ECS Statistics:")
        for _, stat in ipairs(stats) do
            ply:ChatPrint("• " .. stat)
        end
    else
        print("[Advanced Space Combat] ECS Statistics:")
        for _, stat in ipairs(stats) do
            print("• " .. stat)
        end
    end
end, nil, "Show ECS statistics")

print("[Advanced Space Combat] Entity Component System loaded successfully!")
