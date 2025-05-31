-- Advanced Space Combat - Entity Categories v2.2.1
-- Comprehensive entity organization for spawn menu

print("[Advanced Space Combat] Entity Categories v2.2.1 - Loading...")

-- Initialize entity categories namespace
ASC = ASC or {}
ASC.EntityCategories = ASC.EntityCategories or {}

-- Entity category configuration
ASC.EntityCategories.Config = {
    MainCategory = "Advanced Space Combat",
    
    -- Category definitions
    Categories = {
        {
            name = "Ship Components",
            icon = "icon16/cog.png",
            description = "Core ship systems and components",
            entities = {
                "ship_core",
                "hyperdrive_engine", 
                "hyperdrive_master_engine",
                "hyperdrive_computer"
            }
        },
        {
            name = "Weapons - Energy",
            icon = "icon16/lightning.png",
            description = "Energy-based weapon systems",
            entities = {
                "asc_pulse_cannon",
                "asc_beam_weapon",
                "asc_plasma_cannon"
            }
        },
        {
            name = "Weapons - Kinetic",
            icon = "icon16/bomb.png",
            description = "Kinetic and projectile weapons",
            entities = {
                "asc_torpedo_launcher",
                "asc_railgun"
            }
        },
        {
            name = "Flight Systems",
            icon = "icon16/arrow_up.png",
            description = "Flight control and navigation",
            entities = {
                "asc_flight_console"
            }
        },
        {
            name = "Transport - Docking",
            icon = "icon16/building.png",
            description = "Docking pads and landing systems",
            entities = {
                "asc_docking_pad"
            }
        },
        {
            name = "Transport - Shuttles",
            icon = "icon16/car.png",
            description = "Automated transport shuttles",
            entities = {
                "asc_shuttle"
            }
        },
        {
            name = "Defense Systems",
            icon = "icon16/shield.png",
            description = "Shields and defensive systems",
            entities = {
                "asc_shield_generator"
            }
        }
    }
}

-- Entity information database
ASC.EntityCategories.EntityInfo = {
    -- Ship Components
    ship_core = {
        name = "Ship Core",
        description = "Central ship management hub with auto-detection and system coordination",
        icon = "entities/ship_core.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Ship Components",
        subcategory = "Core Systems"
    },
    
    hyperdrive_engine = {
        name = "Hyperdrive Engine",
        description = "Standard hyperdrive propulsion system for space travel",
        icon = "entities/hyperdrive_engine.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Ship Components",
        subcategory = "Propulsion"
    },
    
    hyperdrive_master_engine = {
        name = "Master Hyperdrive Engine",
        description = "Advanced hyperdrive propulsion with enhanced capabilities",
        icon = "entities/hyperdrive_master_engine.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Ship Components",
        subcategory = "Propulsion"
    },
    
    hyperdrive_computer = {
        name = "Hyperdrive Computer",
        description = "Navigation and control computer for hyperdrive operations",
        icon = "entities/hyperdrive_computer.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Ship Components",
        subcategory = "Control Systems"
    },
    
    -- Energy Weapons
    asc_pulse_cannon = {
        name = "Pulse Cannon",
        description = "Fast-firing energy weapon with high rate of fire",
        icon = "entities/asc_pulse_cannon.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Weapons - Energy",
        subcategory = "Direct Energy"
    },
    
    asc_beam_weapon = {
        name = "Beam Weapon",
        description = "Continuous energy beam weapon for sustained damage",
        icon = "entities/asc_beam_weapon.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Weapons - Energy",
        subcategory = "Continuous Energy"
    },
    
    asc_plasma_cannon = {
        name = "Plasma Cannon",
        description = "Area-effect energy weapon with splash damage",
        icon = "entities/asc_plasma_cannon.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Weapons - Energy",
        subcategory = "Area Effect"
    },
    
    -- Kinetic Weapons
    asc_torpedo_launcher = {
        name = "Torpedo Launcher",
        description = "Guided heavy projectile weapon with smart targeting",
        icon = "entities/asc_torpedo_launcher.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Weapons - Kinetic",
        subcategory = "Guided Projectiles"
    },
    
    asc_railgun = {
        name = "Railgun",
        description = "Electromagnetic kinetic weapon with penetrating rounds",
        icon = "entities/asc_railgun.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Weapons - Kinetic",
        subcategory = "Electromagnetic"
    },
    
    -- Flight Systems
    asc_flight_console = {
        name = "Flight Console",
        description = "Ship flight control interface with autopilot and navigation",
        icon = "entities/asc_flight_console.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Flight Systems",
        subcategory = "Control Interfaces"
    },
    
    -- Transport Systems
    asc_docking_pad = {
        name = "Docking Pad",
        description = "Ship landing pad with automated services and guidance",
        icon = "entities/asc_docking_pad.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Transport - Docking",
        subcategory = "Landing Facilities"
    },
    
    asc_shuttle = {
        name = "Shuttle",
        description = "Automated transport shuttle for passengers and cargo",
        icon = "entities/asc_shuttle.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Transport - Shuttles",
        subcategory = "Automated Transport"
    },
    
    -- Defense Systems
    asc_shield_generator = {
        name = "Shield Generator",
        description = "CAP-integrated shield system for ship protection",
        icon = "entities/asc_shield_generator.png",
        spawnable = true,
        admin_spawnable = true,
        category = "Defense Systems",
        subcategory = "Energy Shields"
    }
}

-- Register entities in organized categories
function ASC.EntityCategories.RegisterEntities()
    -- Register category headers
    for _, categoryData in ipairs(ASC.EntityCategories.Config.Categories) do
        local headerName = "asc_header_" .. string.lower(string.gsub(categoryData.name, "[%s%-]", "_"))
        
        list.Set("SpawnableEntities", headerName, {
            PrintName = "=== " .. string.upper(categoryData.name) .. " ===",
            ClassName = "",
            Category = ASC.EntityCategories.Config.MainCategory,
            Spawnable = false,
            AdminSpawnable = false,
            IconOverride = categoryData.icon
        })
    end
    
    -- Register entities by category
    for _, categoryData in ipairs(ASC.EntityCategories.Config.Categories) do
        local categoryName = ASC.EntityCategories.Config.MainCategory .. " - " .. categoryData.name
        
        for _, entityClass in ipairs(categoryData.entities) do
            local entityInfo = ASC.EntityCategories.EntityInfo[entityClass]
            
            if entityInfo then
                list.Set("SpawnableEntities", entityClass, {
                    PrintName = entityInfo.name,
                    ClassName = entityClass,
                    Category = categoryName,
                    Spawnable = entityInfo.spawnable,
                    AdminSpawnable = entityInfo.admin_spawnable,
                    IconOverride = entityInfo.icon,
                    Description = entityInfo.description
                })
            end
        end
    end
end

-- Create custom spawn menu tabs
function ASC.EntityCategories.CreateCustomTabs()
    -- Add custom spawn menu tab
    hook.Add("SpawnMenuOpen", "ASC_SpawnMenuOpen", function()
        -- Custom tab implementation would go here
        -- This is a placeholder for future custom tab features
    end)
    
    -- Add context menu options
    hook.Add("SpawnMenuOpen", "ASC_AddContextMenu", function()
        -- Add right-click context menu options for ASC entities
    end)
end

-- Entity search and filtering
function ASC.EntityCategories.CreateSearchSystem()
    -- Add search functionality for ASC entities
    hook.Add("Think", "ASC_EntitySearch", function()
        -- Search system implementation would go here
        -- This allows players to search for specific ASC entities
    end)
end

-- Entity favorites system
function ASC.EntityCategories.CreateFavoritesSystem()
    -- Allow players to favorite ASC entities
    ASC.EntityCategories.Favorites = ASC.EntityCategories.Favorites or {}
    
    -- Load favorites from file
    function ASC.EntityCategories.LoadFavorites()
        local favoritesData = file.Read("asc_favorites.txt", "DATA")
        if favoritesData then
            ASC.EntityCategories.Favorites = util.JSONToTable(favoritesData) or {}
        end
    end
    
    -- Save favorites to file
    function ASC.EntityCategories.SaveFavorites()
        local favoritesData = util.TableToJSON(ASC.EntityCategories.Favorites)
        file.Write("asc_favorites.txt", favoritesData)
    end
    
    -- Add entity to favorites
    function ASC.EntityCategories.AddFavorite(entityClass)
        if not table.HasValue(ASC.EntityCategories.Favorites, entityClass) then
            table.insert(ASC.EntityCategories.Favorites, entityClass)
            ASC.EntityCategories.SaveFavorites()
        end
    end
    
    -- Remove entity from favorites
    function ASC.EntityCategories.RemoveFavorite(entityClass)
        for i, favorite in ipairs(ASC.EntityCategories.Favorites) do
            if favorite == entityClass then
                table.remove(ASC.EntityCategories.Favorites, i)
                ASC.EntityCategories.SaveFavorites()
                break
            end
        end
    end
end

-- Entity information panel
function ASC.EntityCategories.CreateInfoPanel()
    -- Create detailed information panel for entities
    function ASC.EntityCategories.ShowEntityInfo(entityClass)
        local entityInfo = ASC.EntityCategories.EntityInfo[entityClass]
        if not entityInfo then return end
        
        -- Create info panel
        local frame = vgui.Create("DFrame")
        frame:SetSize(400, 300)
        frame:SetTitle("Advanced Space Combat - " .. entityInfo.name)
        frame:Center()
        frame:MakePopup()
        
        -- Entity icon
        local icon = vgui.Create("DImage", frame)
        icon:SetPos(10, 30)
        icon:SetSize(64, 64)
        icon:SetImage(entityInfo.icon or "icon16/cog.png")
        
        -- Entity name
        local nameLabel = vgui.Create("DLabel", frame)
        nameLabel:SetPos(84, 30)
        nameLabel:SetSize(300, 20)
        nameLabel:SetText(entityInfo.name)
        nameLabel:SetFont("DermaDefaultBold")
        
        -- Entity description
        local descLabel = vgui.Create("DLabel", frame)
        descLabel:SetPos(84, 50)
        descLabel:SetSize(300, 40)
        descLabel:SetText(entityInfo.description)
        descLabel:SetWrap(true)
        descLabel:SetAutoStretchVertical(true)
        
        -- Category information
        local categoryLabel = vgui.Create("DLabel", frame)
        categoryLabel:SetPos(10, 100)
        categoryLabel:SetSize(380, 20)
        categoryLabel:SetText("Category: " .. entityInfo.category)
        
        -- Subcategory information
        local subcategoryLabel = vgui.Create("DLabel", frame)
        subcategoryLabel:SetPos(10, 120)
        subcategoryLabel:SetSize(380, 20)
        subcategoryLabel:SetText("Subcategory: " .. entityInfo.subcategory)
        
        -- Spawn button
        local spawnButton = vgui.Create("DButton", frame)
        spawnButton:SetPos(10, 250)
        spawnButton:SetSize(100, 30)
        spawnButton:SetText("Spawn Entity")
        spawnButton.DoClick = function()
            RunConsoleCommand("gmod_tool", "advanced_space_combat")
            RunConsoleCommand("asc_entity_type", entityClass)
            frame:Close()
        end
        
        -- Favorite button
        local favoriteButton = vgui.Create("DButton", frame)
        favoriteButton:SetPos(120, 250)
        favoriteButton:SetSize(100, 30)
        favoriteButton:SetText("Add to Favorites")
        favoriteButton.DoClick = function()
            ASC.EntityCategories.AddFavorite(entityClass)
            favoriteButton:SetText("Added!")
            timer.Simple(1, function()
                if IsValid(favoriteButton) then
                    favoriteButton:SetText("Add to Favorites")
                end
            end)
        end
        
        -- Close button
        local closeButton = vgui.Create("DButton", frame)
        closeButton:SetPos(290, 250)
        closeButton:SetSize(100, 30)
        closeButton:SetText("Close")
        closeButton.DoClick = function()
            frame:Close()
        end
    end
end

-- Console commands for entity management
concommand.Add("asc_entity_info", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local entityClass = args[1]
    if entityClass and ASC.EntityCategories.EntityInfo[entityClass] then
        ASC.EntityCategories.ShowEntityInfo(entityClass)
    else
        ply:ChatPrint("[Advanced Space Combat] Usage: asc_entity_info <entity_class>")
    end
end)

concommand.Add("asc_list_entities", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    ply:ChatPrint("[Advanced Space Combat] Available Entities:")
    
    for _, categoryData in ipairs(ASC.EntityCategories.Config.Categories) do
        ply:ChatPrint("=== " .. categoryData.name .. " ===")
        
        for _, entityClass in ipairs(categoryData.entities) do
            local entityInfo = ASC.EntityCategories.EntityInfo[entityClass]
            if entityInfo then
                ply:ChatPrint("- " .. entityInfo.name .. " (" .. entityClass .. ")")
            end
        end
    end
end)

-- Initialize entity categories
hook.Add("Initialize", "ASC_InitializeEntityCategories", function()
    ASC.EntityCategories.RegisterEntities()
    ASC.EntityCategories.CreateCustomTabs()
    ASC.EntityCategories.CreateSearchSystem()
    ASC.EntityCategories.CreateFavoritesSystem()
    ASC.EntityCategories.CreateInfoPanel()
    
    -- Load favorites
    ASC.EntityCategories.LoadFavorites()
end)

print("[Advanced Space Combat] Entity Categories loaded successfully!")
