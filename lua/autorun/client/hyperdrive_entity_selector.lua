-- Enhanced Hyperdrive System - Modern Entity Selector Interface v2.2.1
-- COMPLETE CODE UPDATE v2.2.1 - ALL SYSTEMS INTEGRATED WITH STEAM WORKSHOP
-- Provides an intuitive interface for selecting and managing hyperdrive entities with Steam Workshop addon support

if SERVER then return end

print("[Hyperdrive Selector] COMPLETE CODE UPDATE v2.2.1 - Entity Selector being updated")
print("[Hyperdrive Selector] Steam Workshop CAP and SB3 entity detection active")

-- Entity Selector System
HYPERDRIVE.EntitySelector = HYPERDRIVE.EntitySelector or {}

local entitySelector = {
    frame = nil,
    isOpen = false,
    selectedEntity = nil,
    entityList = {},
    filterText = "",
    currentCategory = "all",
    lastUpdate = 0,
    updateInterval = 1.0
}

-- Entity Categories
local entityCategories = {
    all = {
        name = "All Entities",
        icon = "📋",
        classes = {}
    },
    engines = {
        name = "Hyperdrive Engines",
        icon = "🚀",
        classes = {"hyperdrive_master_engine"}
    },
    cores = {
        name = "Ship Cores",
        icon = "🏗️",
        classes = {"ship_core"}
    },
    support = {
        name = "Support Systems",
        icon = "🔧",
        classes = {"hyperdrive_computer", "hyperdrive_beacon", "shield_generator"}
    },
    cap = {
        name = "CAP Integration",
        icon = "🌟",
        classes = {"stargate_*", "shield_*", "zpm_*", "dhd_*"}
    }
}

-- Create the modern entity selector interface
function HYPERDRIVE.EntitySelector.Open(callback)
    if entitySelector.isOpen then
        HYPERDRIVE.EntitySelector.Close()
        return
    end

    entitySelector.callback = callback
    entitySelector.isOpen = true

    -- Create main frame
    local frame = vgui.Create("DFrame")
    frame:SetSize(900, 700)
    frame:SetTitle("")
    frame:Center()
    frame:MakePopup()
    frame:SetDraggable(true)
    frame:SetSizable(false)
    frame:SetDeleteOnClose(true)

    entitySelector.frame = frame

    -- Custom paint for modern styling
    frame.Paint = function(self, w, h)
        HYPERDRIVE.UI.DrawModernPanel(0, 0, w, h, "Primary", 12)

        -- Title bar
        HYPERDRIVE.UI.DrawModernPanel(10, 10, w - 20, 50, "Accent", 8)
        draw.SimpleText("HYPERDRIVE ENTITY SELECTOR", "DermaLarge", w/2, 35, HYPERDRIVE.UI.GetColor("Text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Version info
        draw.SimpleText("v2.1.0 Enhanced", "DermaDefault", w - 20, 55, HYPERDRIVE.UI.GetColor("TextMuted"), TEXT_ALIGN_RIGHT)
    end

    -- Close button
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(frame:GetWide() - 40, 15)
    closeBtn:SetSize(30, 30)
    closeBtn:SetText("")
    closeBtn.DoClick = function()
        HYPERDRIVE.EntitySelector.Close()
    end
    closeBtn.Paint = function(self, w, h)
        local isHovered = self:IsHovered()
        local color = isHovered and HYPERDRIVE.UI.GetColor("Error") or HYPERDRIVE.UI.GetColor("TextMuted")
        draw.SimpleText("✕", "DermaLarge", w/2, h/2, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- Create category tabs
    entitySelector:CreateCategoryTabs(frame)

    -- Create search bar
    entitySelector:CreateSearchBar(frame)

    -- Create entity list
    entitySelector:CreateEntityList(frame)

    -- Create info panel
    entitySelector:CreateInfoPanel(frame)

    -- Create action buttons
    entitySelector:CreateActionButtons(frame)

    -- Initial entity scan
    entitySelector:UpdateEntityList()

    -- Play opening sound
    surface.PlaySound("buttons/button15.wav")
end

function HYPERDRIVE.EntitySelector.Close()
    if IsValid(entitySelector.frame) then
        entitySelector.frame:Close()
    end

    entitySelector.isOpen = false
    entitySelector.selectedEntity = nil
    entitySelector.frame = nil

    -- Play closing sound
    surface.PlaySound("buttons/button10.wav")
end

-- Create category tabs
function entitySelector:CreateCategoryTabs(parent)
    local tabPanel = vgui.Create("DPanel", parent)
    tabPanel:SetPos(20, 80)
    tabPanel:SetSize(parent:GetWide() - 40, 40)
    tabPanel:SetPaintBackground(false)

    local tabWidth = (tabPanel:GetWide() - 20) / table.Count(entityCategories)
    local x = 0

    for categoryId, category in pairs(entityCategories) do
        local tab = vgui.Create("DButton", tabPanel)
        tab:SetPos(x, 0)
        tab:SetSize(tabWidth, 35)
        tab:SetText("")

        tab.Paint = function(self, w, h)
            local isActive = entitySelector.currentCategory == categoryId
            local isHovered = self:IsHovered()
            HYPERDRIVE.UI.DrawModernTab(0, 0, w, h, category.name, category.icon, isActive, isHovered)
        end

        tab.DoClick = function()
            entitySelector.currentCategory = categoryId
            entitySelector:UpdateEntityList()
            surface.PlaySound("buttons/button14.wav")
        end

        x = x + tabWidth + 4
    end
end

-- Create search bar
function entitySelector:CreateSearchBar(parent)
    local searchPanel = vgui.Create("DPanel", parent)
    searchPanel:SetPos(20, 130)
    searchPanel:SetSize(parent:GetWide() - 40, 35)
    searchPanel:SetPaintBackground(false)

    -- Search icon
    local searchIcon = vgui.Create("DLabel", searchPanel)
    searchIcon:SetPos(10, 0)
    searchIcon:SetSize(30, 35)
    searchIcon:SetText("🔍")
    searchIcon:SetContentAlignment(5)
    searchIcon:SetTextColor(HYPERDRIVE.UI.GetColor("TextMuted"))

    -- Search text entry
    local searchEntry = vgui.Create("DTextEntry", searchPanel)
    searchEntry:SetPos(45, 5)
    searchEntry:SetSize(searchPanel:GetWide() - 55, 25)
    searchEntry:SetPlaceholderText("Search entities...")

    searchEntry.Paint = function(self, w, h)
        HYPERDRIVE.UI.DrawModernPanel(0, 0, w, h, "BackgroundSecondary", 4)
        self:DrawTextEntryText(HYPERDRIVE.UI.GetColor("Text"), HYPERDRIVE.UI.GetColor("Accent"), HYPERDRIVE.UI.GetColor("Text"))
    end

    searchEntry.OnValueChange = function(self, value)
        entitySelector.filterText = value:lower()
        entitySelector:UpdateEntityList()
    end

    entitySelector.searchEntry = searchEntry
end

-- Create entity list
function entitySelector:CreateEntityList(parent)
    local listPanel = vgui.Create("DScrollPanel", parent)
    listPanel:SetPos(20, 175)
    listPanel:SetSize(550, 450)

    listPanel.Paint = function(self, w, h)
        HYPERDRIVE.UI.DrawModernPanel(0, 0, w, h, "BackgroundSecondary", 8)
    end

    -- Custom scrollbar styling
    local vbar = listPanel:GetVBar()
    vbar:SetHideButtons(true)
    vbar.Paint = function(self, w, h)
        draw.RoundedBox(4, 0, 0, w, h, HYPERDRIVE.UI.GetColor("BackgroundTertiary"))
    end
    vbar.btnGrip.Paint = function(self, w, h)
        local color = self:IsHovered() and HYPERDRIVE.UI.GetColor("Accent") or HYPERDRIVE.UI.GetColor("Border")
        draw.RoundedBox(4, 2, 0, w - 4, h, color)
    end

    entitySelector.listPanel = listPanel
end

-- Create info panel
function entitySelector:CreateInfoPanel(parent)
    local infoPanel = vgui.Create("DPanel", parent)
    infoPanel:SetPos(580, 175)
    infoPanel:SetSize(300, 450)

    infoPanel.Paint = function(self, w, h)
        HYPERDRIVE.UI.DrawModernPanel(0, 0, w, h, "BackgroundSecondary", 8)

        if entitySelector.selectedEntity and IsValid(entitySelector.selectedEntity) then
            local ent = entitySelector.selectedEntity
            local y = 20

            -- Entity name
            draw.SimpleText("ENTITY INFORMATION", "DermaDefaultBold", w/2, y, HYPERDRIVE.UI.GetColor("Accent"), TEXT_ALIGN_CENTER)
            y = y + 30

            -- Basic info
            draw.SimpleText("Class: " .. ent:GetClass(), "DermaDefault", 15, y, HYPERDRIVE.UI.GetColor("Text"))
            y = y + 20

            local distance = math.floor(ent:GetPos():Distance(LocalPlayer():GetPos()))
            draw.SimpleText("Distance: " .. distance .. "m", "DermaDefault", 15, y, HYPERDRIVE.UI.GetColor("TextSecondary"))
            y = y + 20

            -- Entity-specific info
            if ent:GetClass():find("hyperdrive_engine") then
                local energy = (ent.GetEnergy and ent:GetEnergy()) and ent:GetEnergy() or 0
                local maxEnergy = (ent.GetMaxEnergy and ent:GetMaxEnergy()) and ent:GetMaxEnergy() or 1000
                local energyPercent = (energy / maxEnergy) * 100

                draw.SimpleText("Energy: " .. math.floor(energyPercent) .. "%", "DermaDefault", 15, y, HYPERDRIVE.UI.GetColor("Success"))
                HYPERDRIVE.UI.DrawProgressBar(15, y + 15, w - 30, 12, energyPercent, 100, "Success")
                y = y + 40

                local status = "Ready"
                if ent.GetCharging and ent:GetCharging() then
                    status = "Charging"
                elseif ent.IsOnCooldown and ent:IsOnCooldown() then
                    status = "Cooldown"
                end
                draw.SimpleText("Status: " .. status, "DermaDefault", 15, y, HYPERDRIVE.UI.GetColor("Info"))
                y = y + 20
            elseif ent:GetClass() == "ship_core" then
                local coreState = ent:GetNWInt("CoreState", 0)
                local stateText = "Operational"
                local stateColor = "Success"

                if coreState == 3 then
                    stateText = "Emergency"
                    stateColor = "Error"
                elseif coreState == 2 then
                    stateText = "Critical"
                    stateColor = "Warning"
                end

                draw.SimpleText("Core Status: " .. stateText, "DermaDefault", 15, y, HYPERDRIVE.UI.GetColor(stateColor))
                y = y + 20

                local shipName = ent:GetNWString("ShipName", "Unnamed Ship")
                draw.SimpleText("Ship: " .. shipName, "DermaDefault", 15, y, HYPERDRIVE.UI.GetColor("TextSecondary"))
                y = y + 20
            end

            -- CAP integration info
            if ent:GetNWBool("CAPIntegrationActive", false) then
                draw.SimpleText("CAP Integration: Active", "DermaDefault", 15, y, HYPERDRIVE.UI.GetColor("Accent"))
                y = y + 20
            end
        else
            draw.SimpleText("Select an entity to view details", "DermaDefault", w/2, h/2, HYPERDRIVE.UI.GetColor("TextMuted"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    entitySelector.infoPanel = infoPanel
end

-- Create action buttons
function entitySelector:CreateActionButtons(parent)
    local buttonPanel = vgui.Create("DPanel", parent)
    buttonPanel:SetPos(20, 635)
    buttonPanel:SetSize(parent:GetWide() - 40, 50)
    buttonPanel:SetPaintBackground(false)

    -- Select button
    local selectBtn = vgui.Create("DButton", buttonPanel)
    selectBtn:SetPos(0, 10)
    selectBtn:SetSize(120, 30)
    selectBtn:SetText("")
    selectBtn.DoClick = function()
        if entitySelector.selectedEntity and entitySelector.callback then
            entitySelector.callback(entitySelector.selectedEntity)
            HYPERDRIVE.EntitySelector.Close()
        end
    end
    selectBtn.Paint = function(self, w, h)
        local isEnabled = entitySelector.selectedEntity ~= nil
        local isHovered = self:IsHovered() and isEnabled
        local color = isEnabled and "Success" or "TextDisabled"
        HYPERDRIVE.UI.DrawModernButton(0, 0, w, h, "SELECT", isHovered, false, color)
    end

    -- Refresh button
    local refreshBtn = vgui.Create("DButton", buttonPanel)
    refreshBtn:SetPos(130, 10)
    refreshBtn:SetSize(120, 30)
    refreshBtn:SetText("")
    refreshBtn.DoClick = function()
        entitySelector:UpdateEntityList()
        surface.PlaySound("buttons/button9.wav")
    end
    refreshBtn.Paint = function(self, w, h)
        local isHovered = self:IsHovered()
        HYPERDRIVE.UI.DrawModernButton(0, 0, w, h, "REFRESH", isHovered, false, "Info")
    end

    -- Cancel button
    local cancelBtn = vgui.Create("DButton", buttonPanel)
    cancelBtn:SetPos(buttonPanel:GetWide() - 120, 10)
    cancelBtn:SetSize(120, 30)
    cancelBtn:SetText("")
    cancelBtn.DoClick = function()
        HYPERDRIVE.EntitySelector.Close()
    end
    cancelBtn.Paint = function(self, w, h)
        local isHovered = self:IsHovered()
        HYPERDRIVE.UI.DrawModernButton(0, 0, w, h, "CANCEL", isHovered, false, "Error")
    end
end

-- Update entity list based on current category and filter
function entitySelector:UpdateEntityList()
    if not IsValid(self.listPanel) then return end

    -- Clear existing list
    self.listPanel:Clear()
    self.entityList = {}

    -- Get entities based on category
    local entities = {}
    local category = entityCategories[self.currentCategory]

    if self.currentCategory == "all" then
        -- Get all hyperdrive-related entities
        for _, cat in pairs(entityCategories) do
            if cat.classes then
                for _, class in ipairs(cat.classes) do
                    if class:find("*") then
                        -- Wildcard search
                        local pattern = class:gsub("*", "")
                        for _, ent in ipairs(ents.GetAll()) do
                            if IsValid(ent) and ent:GetClass():find(pattern) then
                                table.insert(entities, ent)
                            end
                        end
                    else
                        -- Exact class match
                        for _, ent in ipairs(ents.FindByClass(class)) do
                            if IsValid(ent) then
                                table.insert(entities, ent)
                            end
                        end
                    end
                end
            end
        end
    else
        -- Get entities for specific category
        if category and category.classes then
            for _, class in ipairs(category.classes) do
                if class:find("*") then
                    -- Wildcard search
                    local pattern = class:gsub("*", "")
                    for _, ent in ipairs(ents.GetAll()) do
                        if IsValid(ent) and ent:GetClass():find(pattern) then
                            table.insert(entities, ent)
                        end
                    end
                else
                    -- Exact class match
                    for _, ent in ipairs(ents.FindByClass(class)) do
                        if IsValid(ent) then
                            table.insert(entities, ent)
                        end
                    end
                end
            end
        end
    end

    -- Filter entities by search text
    if self.filterText ~= "" then
        local filteredEntities = {}
        for _, ent in ipairs(entities) do
            local className = ent:GetClass():lower()
            local shipName = ent:GetNWString("ShipName", ""):lower()

            if className:find(self.filterText) or shipName:find(self.filterText) then
                table.insert(filteredEntities, ent)
            end
        end
        entities = filteredEntities
    end

    -- Sort entities by distance
    local ply = LocalPlayer()
    table.sort(entities, function(a, b)
        local distA = a:GetPos():Distance(ply:GetPos())
        local distB = b:GetPos():Distance(ply:GetPos())
        return distA < distB
    end)

    -- Create list items
    for i, ent in ipairs(entities) do
        self:CreateEntityListItem(ent, i)
        table.insert(self.entityList, ent)
    end

    -- Update count display
    local countText = #entities .. " entities found"
    if self.countLabel then
        self.countLabel:SetText(countText)
    end
end

-- Create individual entity list item
function entitySelector:CreateEntityListItem(entity, index)
    local item = vgui.Create("DButton", self.listPanel)
    item:SetSize(self.listPanel:GetWide() - 20, 60)
    item:SetText("")
    item:Dock(TOP)
    item:DockMargin(5, 2, 5, 2)

    item.Paint = function(self, w, h)
        local isSelected = entitySelector.selectedEntity == entity
        local isHovered = self:IsHovered()

        local bgColor = "BackgroundTertiary"
        if isSelected then
            bgColor = "Accent"
        elseif isHovered then
            bgColor = "BackgroundSecondary"
        end

        HYPERDRIVE.UI.DrawModernPanel(0, 0, w, h, bgColor, 6)

        -- Entity icon based on class
        local icon = "📦"
        if entity:GetClass():find("engine") then
            icon = "🚀"
        elseif entity:GetClass():find("core") then
            icon = "🏗️"
        elseif entity:GetClass():find("shield") then
            icon = "🛡️"
        elseif entity:GetClass():find("stargate") then
            icon = "🌟"
        end

        -- Draw icon
        draw.SimpleText(icon, "DermaLarge", 20, h/2, HYPERDRIVE.UI.GetColor("Text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        -- Entity name and class
        local entityName = entity:GetNWString("ShipName", "")
        if entityName == "" then
            entityName = entity:GetClass():gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest) return first:upper()..rest:lower() end)
        end

        draw.SimpleText(entityName, "DermaDefaultBold", 50, h/2 - 10, HYPERDRIVE.UI.GetColor("Text"))
        draw.SimpleText(entity:GetClass(), "DermaDefault", 50, h/2 + 8, HYPERDRIVE.UI.GetColor("TextSecondary"))

        -- Distance
        local distance = math.floor(entity:GetPos():Distance(LocalPlayer():GetPos()))
        draw.SimpleText(distance .. "m", "DermaDefault", w - 20, h/2 - 5, HYPERDRIVE.UI.GetColor("TextMuted"), TEXT_ALIGN_RIGHT)

        -- Status indicator
        local statusColor = HYPERDRIVE.UI.GetColor("Success")
        local statusText = "●"

        if entity:GetClass():find("engine") then
            if entity.GetCharging and entity:GetCharging() then
                statusColor = HYPERDRIVE.UI.GetColor("Warning")
            elseif entity.IsOnCooldown and entity:IsOnCooldown() then
                statusColor = HYPERDRIVE.UI.GetColor("Error")
            end
        elseif entity:GetClass() == "ship_core" then
            local coreState = entity:GetNWInt("CoreState", 0)
            if coreState == 3 then
                statusColor = HYPERDRIVE.UI.GetColor("Error")
            elseif coreState == 2 then
                statusColor = HYPERDRIVE.UI.GetColor("Warning")
            end
        end

        draw.SimpleText(statusText, "DermaLarge", w - 20, h/2 + 10, statusColor, TEXT_ALIGN_RIGHT)
    end

    item.DoClick = function()
        entitySelector.selectedEntity = entity
        surface.PlaySound("buttons/button17.wav")
    end

    return item
end

-- Console command to open entity selector
concommand.Add("hyperdrive_entity_selector", function()
    HYPERDRIVE.EntitySelector.Open(function(entity)
        LocalPlayer():ChatPrint("[Hyperdrive] Selected entity: " .. entity:GetClass() .. " at " .. tostring(entity:GetPos()))
    end)
end)

-- Hook for automatic updates
hook.Add("Think", "HyperdriveEntitySelectorUpdate", function()
    if entitySelector.isOpen and CurTime() - entitySelector.lastUpdate > entitySelector.updateInterval then
        entitySelector.lastUpdate = CurTime()
        if IsValid(entitySelector.listPanel) then
            entitySelector:UpdateEntityList()
        end
    end
end)

-- Initialize the entity selector system
timer.Simple(0.1, function()
    if HYPERDRIVE and HYPERDRIVE.EntitySelector then
        HYPERDRIVE.EntitySelector.Initialized = true
        print("[Hyperdrive] Enhanced Entity Selector v2.2.0 initialized successfully")
    else
        print("[Hyperdrive] Warning: Entity selector system failed to initialize - HYPERDRIVE.EntitySelector not available")
    end
end)

print("[Hyperdrive] Enhanced Entity Selector v2.2.0 loaded")
