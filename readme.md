# Advanced Space Combat v5.1.0 - Ultimate Edition

**Professional-grade space combat simulation for Garry's Mod with enhanced Stargate hyperspace technology, ARIA-4 AI assistant, and comprehensive ship management systems.**

[![Version](https://img.shields.io/badge/Version-5.1.0-blue.svg)](https://github.com/your-repo/advanced-space-combat)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Garry's Mod](https://img.shields.io/badge/Garry's%20Mod-Compatible-orange.svg)](https://store.steampowered.com/app/4000/Garrys_Mod/)
[![Quality](https://img.shields.io/badge/Quality-Enterprise%20Grade-gold.svg)](README.md)

## 🌌 Overview

Advanced Space Combat is a comprehensive space simulation addon that transforms Garry's Mod into a professional-grade space combat environment. Featuring authentic 4-stage Stargate hyperspace travel, advanced weapon systems, intelligent AI assistance, and complete ship management capabilities.

### 🎯 Key Highlights

- **🚀 4-Stage Stargate Hyperspace System** - Authentic travel mechanics with visual effects
- **🤖 ARIA-4 AI Assistant** - Next-generation intelligence with web access and natural language processing
- **⚔️ Advanced Combat Systems** - 5 weapon types with predictive targeting and tactical AI
- **🛸 Complete Ship Management** - Ship cores, flight systems, docking, and resource management
- **🎨 CAP Integration** - Full Carter Addon Pack asset integration with 60+ technologies
- **🔧 Professional Tools** - Comprehensive spawn menu organization and Q menu configuration

---

## 📋 Table of Contents

1. [Installation & Setup](#-installation--setup)
2. [Core Systems](#-core-systems)
3. [Ship Management](#-ship-management)
4. [Hyperspace System](#-hyperspace-system)
5. [Combat Systems](#-combat-systems)
6. [AI Assistant (ARIA-4)](#-ai-assistant-aria-4)
7. [Configuration](#-configuration)
8. [Technical Documentation](#-technical-documentation)
9. [API Reference](#-api-reference)
10. [Troubleshooting](#-troubleshooting)

---

## 🚀 Installation & Setup

### Prerequisites

- **Garry's Mod** (Latest version recommended)
- **Wiremod** (Optional but recommended for advanced features)
- **Carter Addon Pack (CAP)** (Steam Workshop ID: 180077636) - Optional for enhanced assets
- **Spacebuild 3** (Optional for resource integration)

### Installation Steps

1. **Download the Addon**
   ```
   Extract to: garrysmod/addons/advanced-space-combat/
   ```

2. **Server Configuration**
   ```lua
   -- Add to server.cfg for optimal performance
   sv_allowcslua 1
   wire_expression2_quotamax 100000
   wire_expression2_quotatime 0.02
   ```

3. **First Launch**
   - Restart your server/game
   - Check console for successful loading messages
   - Access Q menu → Advanced Space Combat for configuration

### Quick Start Guide

1. **Spawn a Ship Core** - Essential for all ship operations
2. **Configure Settings** - Use Q menu → Advanced Space Combat → Configuration
3. **Build Your Ship** - Attach components within 2000 units of ship core
4. **Test Systems** - Use `aria help` for AI assistance

---

## 🔧 Core Systems

### System Architecture

Advanced Space Combat uses a modular architecture with the following core namespaces:

```lua
ASC = {
    VERSION = "5.1.0",
    AI = {},           -- ARIA-4 AI Assistant
    Weapons = {},      -- Combat systems
    UI = {},           -- User interface
    Diagnostics = {},  -- System monitoring
    Commands = {},     -- Console commands
    Debug = {}         -- Debug utilities
}

HYPERDRIVE = {
    Core = {},         -- Hyperdrive engine
    ShipCore = {},     -- Ship management
    WeaponGroups = {}, -- Weapon coordination
    UI = {}            -- Legacy UI support
}
```

### Initialization Sequence

1. **Main Initialization** (`advanced_space_combat_init.lua`)
   - Creates core namespaces and ConVars
   - Loads system configuration
   - Initializes diagnostic systems

2. **Component Loading** (Autorun files)
   - AI system initialization
   - Weapon system setup
   - UI system configuration
   - Entity registration

3. **Client-Side Setup** (Client autorun files)
   - Spawn menu organization
   - Q menu configuration
   - UI system initialization

### ConVar System

The addon uses 25+ ConVars for comprehensive configuration:

```lua
-- Core System ConVars
asc_enabled                 -- Master enable/disable
asc_debug_mode             -- Debug mode toggle
asc_max_range              -- Maximum jump range
asc_require_ship_core      -- Ship core requirements

-- Phase 2 Enhanced ConVars
asc_show_front_indicators  -- Ship direction arrows
asc_auto_show_arrows       -- Auto-display indicators
asc_indicator_distance     -- Indicator positioning
asc_ship_core_volume       -- Audio volume control
```

---

## 🛸 Ship Management

### Ship Core System

The ship core is the central command system for all vessels, providing:

#### Core Functions
- **Ship Detection** - Automatically detects connected ship structure
- **Resource Management** - Handles energy and resource distribution
- **Component Coordination** - Links all ship systems together
- **Life Support** - Provides atmosphere and environmental control

#### Technical Implementation

```lua
-- Ship Core Entity Structure
ENT.Type = "asc_ship_core"
ENT.Base = "base_gmodentity"

-- Core Properties
self.ShipID = unique_identifier
self.DetectedEntities = {}
self.ResourceStorage = {
    energy = 10000,
    oxygen = 1000,
    water = 500
}

-- Real-time Updates (0.05s interval)
function ENT:Think()
    self:UpdateShipDetection()
    self:UpdateResourceDistribution()
    self:UpdateLifeSupport()
    self:NextThink(CurTime() + 0.05)
end
```

#### Visual Indicators

**Enhanced Front Indicator System (Phase 2)**
- **Green Arrow Display** - Shows ship orientation
- **Configurable Distance** - 50-300 units from core
- **Auto-Show Option** - Automatically displays on spawn
- **Smart Positioning** - Cone-shaped arrow for better visibility

```lua
-- Front Indicator Configuration
CreateFrontIndicator = function(shipCore)
    local indicator = ents.Create("prop_physics")
    indicator:SetModel("models/hunter/misc/cone1x1.mdl")
    indicator:SetPos(shipCore:GetPos() + shipCore:GetForward() * 150)
    indicator:SetColor(Color(0, 255, 0, 220))
    indicator:SetParent(shipCore)
end
```

### Audio System

**Enhanced Sound Management (Phase 2)**
- **Quieter Defaults** - 0.15 volume (was 0.2)
- **Pleasant Sounds** - Atmospheric ambience instead of machine noise
- **Mute Wire Input** - Wiremod integration for sound control
- **CAP Integration** - Technology-specific ambient sounds

```lua
-- Sound Priority System
local fallbackSounds = {
    "ambient/atmosphere/ambience_base.wav",  -- Most pleasant
    "ambient/atmosphere/tone_quiet.wav",     -- Quiet atmospheric
    "ambient/water/water_flow_loop1.wav",    -- Gentle water flow
    "ambient/atmosphere/wind_quiet.wav",     -- Quiet wind
    "ambient/machines/machine_hum1.wav"      -- Last resort
}
```

### Resource System

**Spacebuild 3 Integration**
- **Energy Distribution** - Automatic power management
- **Resource Scaling** - Inverse scaling based on ship size
- **Real-time Updates** - Smart recalculation system
- **Auto-Distribution** - Resources flow to newly welded entities

#### Resource Scaling Logic

```lua
-- Small ships: Fast regen, low capacity
-- Large ships: Slow regen, high capacity
local shipSize = #detectedEntities
local regenRate = math.max(10 - (shipSize / 100), 1)
local capacity = math.min(1000 + (shipSize * 10), 50000)
```

---

## 🌌 Hyperspace System

### 4-Stage Stargate Hyperspace Travel

The hyperspace system implements authentic Stargate travel mechanics with four distinct stages:

#### Stage 1: Initiation (3-5 seconds)
- **Energy Surge** - Power builds up across ship systems
- **Coordinate Calculation** - Navigation computer calculates jump coordinates
- **System Checks** - All ship systems verified for hyperspace compatibility
- **Visual Effects** - Blue energy patterns begin forming around ship

```lua
-- Stage 1 Implementation
function HYPERDRIVE.Core.InitiateHyperspace(shipCore, destination)
    local stage1Duration = math.random(3, 5)

    -- Energy surge effects
    HYPERDRIVE.Effects.CreateEnergySurge(shipCore)

    -- Coordinate calculation
    local coordinates = HYPERDRIVE.Navigation.CalculateCoordinates(destination)

    -- System verification
    local systemsReady = HYPERDRIVE.Core.VerifyShipSystems(shipCore)

    if systemsReady then
        timer.Simple(stage1Duration, function()
            HYPERDRIVE.Core.OpenHyperspaceWindow(shipCore, coordinates)
        end)
    end
end
```

#### Stage 2: Window Opening (2-3 seconds)
- **Hyperspace Window** - Blue/purple swirling energy tunnel opens
- **Dimensional Breach** - Reality tears open to reveal hyperspace
- **Gravitational Effects** - Space-time distortion around ship
- **Sound Effects** - Deep, resonant hyperspace activation sounds

#### Stage 3: Hyperspace Travel (5-15 seconds)
- **Stretched Starlines** - Stars become elongated light streaks
- **Dimensional Visuals** - Swirling energy patterns and cosmic phenomena
- **Time Dilation** - Subjective time distortion effects
- **Navigation Hazards** - Gravitational anomalies and energy storms

#### Stage 4: Exit (2-4 seconds)
- **Light Flash** - Brilliant white light as ship exits hyperspace
- **System Stabilization** - All ship systems return to normal operation
- **Coordinate Verification** - Confirm arrival at intended destination
- **Status Updates** - Ship systems report successful jump completion

### Technical Implementation

```lua
-- Hyperspace Core System
HYPERDRIVE.Core = {
    -- Active hyperspace sessions
    ActiveJumps = {},

    -- Jump calculation
    CalculateJumpTime = function(distance, shipMass)
        local baseTime = 5
        local distanceModifier = math.min(distance / 10000, 10)
        local massModifier = math.min(shipMass / 1000, 5)
        return baseTime + distanceModifier + massModifier
    end,

    -- Energy requirements
    CalculateEnergyCost = function(distance, shipMass)
        local baseCost = 1000
        local distanceCost = distance * 0.1
        local massCost = shipMass * 0.5
        return baseCost + distanceCost + massCost
    end
}
```

### Navigation System

**Advanced Coordinate System**
- **3D Coordinate Grid** - Full 3D space navigation
- **Bookmark System** - Save frequently used destinations
- **Auto-Navigation** - AI-assisted route planning
- **Hazard Detection** - Automatic obstacle avoidance

```lua
-- Navigation Implementation
HYPERDRIVE.Navigation = {
    -- Coordinate validation
    ValidateCoordinates = function(coords)
        -- Check for obstacles
        local obstacles = ents.FindInSphere(coords, 500)

        -- Verify safe landing zone
        local safeZone = HYPERDRIVE.Navigation.CheckSafeZone(coords)

        return #obstacles == 0 and safeZone
    end,

    -- Bookmark management
    Bookmarks = {},

    SaveBookmark = function(name, coordinates)
        HYPERDRIVE.Navigation.Bookmarks[name] = coordinates
    end
}
```

---

## ⚔️ Combat Systems

### Advanced Weapon System (Phase 3 Enhanced)

The combat system features 5 distinct weapon types with advanced targeting and tactical AI:

#### Weapon Types

1. **Pulse Cannons**
   - **Damage**: 75 per shot
   - **Range**: 1,500 units
   - **Fire Rate**: 2.0 shots/second
   - **Energy Cost**: 15 per shot
   - **Projectile**: Fast-moving energy pulses

2. **Beam Weapons**
   - **Damage**: 50 per tick (continuous)
   - **Range**: 2,500 units
   - **Fire Rate**: 0.1 second intervals
   - **Energy Cost**: 5 per tick
   - **Projectile**: Instant beam

3. **Torpedo Launchers**
   - **Damage**: 200 per torpedo
   - **Range**: 3,000 units
   - **Fire Rate**: 0.5 shots/second
   - **Energy Cost**: 50 per torpedo
   - **Projectile**: Guided missiles

4. **Railguns**
   - **Damage**: 150 per shot
   - **Range**: 4,000 units
   - **Fire Rate**: 1.0 shots/second
   - **Energy Cost**: 75 per shot
   - **Projectile**: High-velocity kinetic

5. **Plasma Cannons**
   - **Damage**: 125 per shot
   - **Range**: 2,000 units
   - **Fire Rate**: 1.5 shots/second
   - **Energy Cost**: 100 per shot
   - **Projectile**: Plasma bolts

### Enhanced Targeting System (Phase 3)

**Predictive Targeting Algorithm**
```lua
-- Advanced targeting with lead calculation
function ASC.Weapons.Core.PredictTargetPosition(target, distance)
    if not ASC.Weapons.Config.PredictiveTargeting then
        return target:GetPos()
    end

    local velocity = ASC.Weapons.Core.GetEntityVelocity(target)
    local projectileSpeed = 1000 -- Average projectile speed
    local timeToTarget = distance / projectileSpeed

    return target:GetPos() + velocity * timeToTarget
end
```

**Multi-Target Engagement**
- **Primary Target** - Main threat with highest priority
- **Secondary Targets** - Up to 2 additional targets tracked simultaneously
- **Threat Assessment** - Dynamic priority calculation based on distance, weapons, and behavior

**Smart Target Scoring**
```lua
function ASC.Weapons.Core.CalculateTargetScore(target, distance, weaponSystem)
    local score = 1000 - distance -- Base score inversely related to distance

    -- Threat assessment bonuses
    if target:IsPlayer() then score = score + 500 end
    if target:GetClass() == "asc_ship_core" then score = score + 300 end
    if target.GetWeaponCount and target:GetWeaponCount() > 0 then score = score + 200 end

    return math.max(score, 0)
end
```

### Weapon Groups

**Coordinated Fire Control**
- **Simultaneous Fire** - All weapons fire at once
- **Sequential Fire** - Weapons fire one after another
- **Alternating Fire** - Weapons fire in alternating pattern
- **Salvo Fire** - Timed sequential firing with delays

```lua
-- Weapon Group Implementation
WeaponGroup = {
    weapons = {},
    fireMode = "SIMULTANEOUS", -- SEQUENTIAL, ALTERNATING, SALVO
    target = nil,

    Fire = function(self)
        if self.fireMode == "SIMULTANEOUS" then
            for _, weapon in ipairs(self.weapons) do
                weapon:FireWeapon(self.target)
            end
        elseif self.fireMode == "SEQUENTIAL" then
            -- Sequential firing logic
        end
    end
}
```

### Tactical AI System

**AI Behavior Modes**
- **DEFENSIVE** - Prioritize ship protection, conservative engagement
- **AGGRESSIVE** - Active threat hunting, maximum firepower
- **SUPPORT** - Coordinate with allied ships, provide covering fire

**Threat Assessment Matrix**
```lua
-- AI threat evaluation
function ASC.TacticalAI.EvaluateThreat(entity, aiData)
    local threat = {
        entity = entity,
        distance = aiData.shipPos:Distance(entity:GetPos()),
        weaponCount = entity.GetWeaponCount and entity:GetWeaponCount() or 0,
        shieldStrength = entity.GetShieldStrength and entity:GetShieldStrength() or 0,
        velocity = ASC.Weapons.Core.GetEntityVelocity(entity)
    }

    -- Calculate threat level (1-10)
    threat.level = math.min(
        (threat.weaponCount * 2) +
        (1000 / math.max(threat.distance, 100)) +
        (threat.velocity:Length() / 100),
        10
    )

    return threat
end
```

---

## 🤖 AI Assistant (ARIA-4)

### Next-Generation Intelligence System

ARIA-4 is an advanced AI assistant that provides comprehensive support for all addon features:

#### Core Capabilities

**Natural Language Processing**
- **Context Understanding** - Interprets user intent from natural language
- **Multi-language Support** - Czech, English, and other languages via web integration
- **Conversation Memory** - Maintains context across multiple interactions
- **Sentiment Analysis** - Adapts responses based on user mood and situation

**Web Integration**
- **Real-time Web Access** - Searches for current information
- **Content Filtering** - Blocks harmful or inappropriate content
- **Knowledge Updates** - Continuously learns from web sources
- **Fact Verification** - Cross-references information for accuracy

#### Command System

**Ship Management Commands**
```
aria show front indicator    - Activates ship direction arrow
aria green arrow            - Alternative front indicator command
aria ship direction         - Shows ship orientation
aria jump my ship to me     - Teleports ship to player location
aria take me to my ship     - Teleports player to ship
```

**System Commands**
```
aria help                   - Comprehensive help system
aria system status         - Overall system health report
aria diagnostic            - Run system diagnostics
aria fix                   - Automatic problem resolution
aria kill me               - Emergency player respawn
```

**Information Commands**
```
aria search web <topic>     - Web search functionality
aria look up <info>         - Information lookup
aria cap info              - CAP integration information
aria find stargates        - Locate nearby stargates
```

#### Technical Implementation

```lua
-- ARIA-4 Core System
ASC.AI = {
    Config = {
        Name = "ARIA-4",
        Version = "5.1.0",
        Personality = "Advanced AI assistant with deep space combat expertise",
        WebAccess = true,
        ContentFilter = true,
        LanguageSupport = {"en", "cs", "de", "fr", "es"}
    },

    -- Natural language processing
    ProcessQuery = function(player, query)
        local queryLower = string.lower(query)
        local context = ASC.AI.GetPlayerContext(player)

        -- Intent recognition
        local intent = ASC.AI.RecognizeIntent(queryLower, context)

        -- Generate response
        return ASC.AI.GenerateResponse(intent, player, query)
    end,

    -- Context awareness
    GetPlayerContext = function(player)
        return {
            position = player:GetPos(),
            shipCore = ASC.AI.FindPlayerShipCore(player),
            recentActions = ASC.AI.GetRecentActions(player),
            currentTool = player:GetActiveWeapon():GetClass()
        }
    end
}
```

#### Advanced Features

**Proactive Assistance**
- **Entity Spawn Detection** - Automatically offers help when spawning entities
- **Error Detection** - Identifies and suggests fixes for common problems
- **Performance Monitoring** - Alerts users to performance issues
- **Learning System** - Adapts to user preferences and behavior patterns

**Stargate Integration**
- **Gate Detection** - Automatically finds and identifies stargates
- **Address Resolution** - Converts player names to gate addresses
- **Dialing Assistance** - Helps with gate dialing and connection
- **Technology Information** - Comprehensive database of Stargate technologies

```lua
-- Stargate integration example
function ASC.AI.HandleStargateQuery(player, query)
    if string.find(query, "dial") then
        local targetName = string.match(query, "dial (%w+)")
        if targetName then
            local gate = ASC.AI.FindPlayerGate(targetName)
            if gate then
                local address = gate:GetGateAddress()
                return "Dialing " .. targetName .. "'s gate at address: " .. address
            end
        end
    end
end
```

---

## ⚙️ Configuration

### Q Menu Configuration (Phase 3 Enhanced)

Access comprehensive configuration through **Q Menu → Advanced Space Combat → Configuration**:

#### Ship Core Visual Settings
- **Show Front Indicators** - Enable/disable ship direction arrows
- **Auto-Show Front Arrows** - Automatically display indicators on spawn
- **Indicator Distance** - Adjust arrow distance (50-300 units)

#### Ship Core Audio Settings
- **Enable Ship Core Sounds** - Master audio control
- **Ship Core Volume** - Volume adjustment (0.0-1.0)
- **Default Ship Sound** - Select from 4 pleasant ambient sounds

#### System Settings
- **Enable Auto-linking** - Automatic component connection
- **Enable CAP Integration** - Carter Addon Pack asset usage
- **Enable AI System** - ARIA-4 assistant functionality
- **Default Ship Range** - Ship detection range (500-5000 units)

### Console Commands

#### Diagnostic Commands
```
asc_diagnostics             - Run full system diagnostics
asc_health                  - Quick health check
asc_status                  - System status report
asc_quick_fix               - Automatic problem resolution
```

#### Ship Core Commands
```
asc_ship_core_volume <0.0-1.0>    - Adjust volume for all ship cores
asc_ship_core_sound <path>        - Change sound for all ship cores
asc_ship_core_mute               - Mute all ship cores
asc_ship_core_randomize          - Randomize sounds with improved selection
```

#### Weapon System Commands
```
asc_weapon_status               - Display weapon system status
asc_weapon_groups               - List all weapon groups
asc_tactical_ai <mode>          - Set tactical AI mode (DEFENSIVE/AGGRESSIVE/SUPPORT)
```

### Performance Optimization

#### Server Configuration
```lua
-- Recommended server.cfg settings
sv_allowcslua 1                    -- Enable client-side Lua
wire_expression2_quotamax 100000   -- Increase E2 quota for complex ships
wire_expression2_quotatime 0.02    -- Reduce E2 execution time limit
gmod_physiterations 4              -- Improve physics stability
sv_maxrate 30000                   -- Increase network rate for large ships
```

#### ConVar Optimization
```lua
-- Performance-focused settings
asc_performance_mode 1             -- Enable performance optimizations
asc_debug_mode 0                   -- Disable debug mode for better performance
asc_ui_animations 0                -- Disable UI animations on low-end systems
asc_sound_volume 0.5               -- Reduce sound processing load
```

---

## 📚 Technical Documentation

### File Structure

```
advanced-space-combat/
├── addon.txt                     -- Addon manifest
├── lua/
│   ├── autorun/
│   │   ├── advanced_space_combat_init.lua      -- Main initialization
│   │   ├── asc_ai_system_v2.lua               -- ARIA-4 AI system
│   │   ├── asc_weapon_system.lua              -- Weapon management
│   │   ├── asc_tactical_ai_system.lua         -- Tactical AI
│   │   ├── asc_system_diagnostics.lua         -- Diagnostic system
│   │   ├── hyperdrive_init.lua                -- Hyperdrive initialization
│   │   ├── hyperdrive_core_v2.lua             -- Hyperdrive core system
│   │   └── hyperdrive_ship_core.lua           -- Ship core management
│   │   └── client/
│   │       ├── asc_spawn_menu_complete.lua    -- Spawn menu organization
│   │       ├── asc_ui_system.lua              -- UI system
│   │       └── hyperdrive_qmenu_config.lua    -- Q menu configuration
│   ├── entities/                  -- Entity definitions
│   │   ├── ship_core/            -- Ship core entity
│   │   ├── asc_ship_core/        -- Advanced ship core
│   │   ├── hyperdrive_*/         -- Hyperdrive components
│   │   └── asc_*/                -- Combat entities
│   ├── effects/                   -- Visual effects
│   └── weapons/                   -- Weapon definitions
├── materials/                     -- Textures and materials
├── models/                        -- 3D models
└── sound/                         -- Audio files
```

### Entity System

#### Base Entity Structure
```lua
-- Standard entity template
ENT.Type = "asc_entity_base"
ENT.Base = "base_gmodentity"
ENT.Category = "Advanced Space Combat"
ENT.Spawnable = true
ENT.AdminOnly = false

-- Required functions
function ENT:Initialize()
    -- Entity initialization
end

function ENT:Think()
    -- Real-time updates
    self:NextThink(CurTime() + 0.1)
    return true
end
```

#### Ship Core Integration
```lua
-- Ship core detection and integration
function ENT:FindShipCore()
    local shipCores = ents.FindByClass("asc_ship_core")
    for _, core in ipairs(shipCores) do
        if core:GetPos():Distance(self:GetPos()) <= 2000 then
            return core
        end
    end
    return nil
end

function ENT:RegisterWithShipCore(shipCore)
    if IsValid(shipCore) then
        shipCore:AddComponent(self)
        self.ShipCore = shipCore
    end
end
```

### Networking System

#### Client-Server Communication
```lua
-- Network message registration
util.AddNetworkString("ASC_ShipCoreUpdate")
util.AddNetworkString("ASC_WeaponFire")
util.AddNetworkString("ASC_HyperspaceJump")
util.AddNetworkString("ASC_AIResponse")

-- Server to client updates
net.Start("ASC_ShipCoreUpdate")
net.WriteEntity(shipCore)
net.WriteTable(shipData)
net.Broadcast()

-- Client to server commands
net.Start("ASC_WeaponFire")
net.WriteEntity(weapon)
net.WriteVector(targetPos)
net.SendToServer()
```

---

## 🔧 API Reference

### Core API Functions

#### Ship Core Management
```lua
-- Create ship core system
ASC.ShipCore.CreateShipCore(position, angles, owner)

-- Get ship core by ID
local shipCore = ASC.ShipCore.GetShipCore(shipID)

-- Register component with ship core
ASC.ShipCore.RegisterComponent(shipCore, component)

-- Update ship detection
ASC.ShipCore.UpdateShipDetection(shipCore)
```

#### Weapon System API
```lua
-- Create weapon system for ship
ASC.Weapons.Core.CreateWeaponSystem(shipCore)

-- Add weapon to ship
ASC.Weapons.Core.AddWeapon(shipID, weaponType, position, angles)

-- Create weapon group
ASC.Weapons.Core.CreateWeaponGroup(shipID, groupName, weaponIDs)

-- Fire weapon group
ASC.Weapons.Core.FireWeaponGroup(shipID, groupIndex, target)

-- Get weapon system status
local status = ASC.Weapons.Core.GetWeaponStatus(shipID)
```

#### Hyperspace System API
```lua
-- Initiate hyperspace jump
HYPERDRIVE.Core.InitiateJump(shipCore, destination)

-- Calculate jump requirements
local energy, time = HYPERDRIVE.Core.CalculateJumpRequirements(distance, mass)

-- Validate coordinates
local valid = HYPERDRIVE.Navigation.ValidateCoordinates(coordinates)

-- Save bookmark
HYPERDRIVE.Navigation.SaveBookmark(name, coordinates)
```

#### AI System API
```lua
-- Process AI query
local response = ASC.AI.ProcessQuery(player, query)

-- Get player context
local context = ASC.AI.GetPlayerContext(player)

-- Find player's ship core
local shipCore = ASC.AI.FindPlayerShipCore(player)

-- Register AI command
ASC.AI.RegisterCommand(pattern, handler)
```

### Event Hooks

#### Ship Events
```lua
-- Ship core spawned
hook.Add("ASC_ShipCoreSpawned", "MyAddon", function(shipCore, owner)
    -- Handle ship core creation
end)

-- Ship detected
hook.Add("ASC_ShipDetected", "MyAddon", function(shipCore, entities)
    -- Handle ship detection update
end)

-- Component added to ship
hook.Add("ASC_ComponentAdded", "MyAddon", function(shipCore, component)
    -- Handle component registration
end)
```

#### Combat Events
```lua
-- Weapon fired
hook.Add("ASC_WeaponFired", "MyAddon", function(weapon, target, damage)
    -- Handle weapon firing
end)

-- Target acquired
hook.Add("ASC_TargetAcquired", "MyAddon", function(weaponSystem, target)
    -- Handle target acquisition
end)

-- Weapon group created
hook.Add("ASC_WeaponGroupCreated", "MyAddon", function(shipID, groupName)
    -- Handle weapon group creation
end)
```

#### Hyperspace Events
```lua
-- Hyperspace jump initiated
hook.Add("ASC_HyperspaceInitiated", "MyAddon", function(shipCore, destination)
    -- Handle jump initiation
end)

-- Hyperspace jump completed
hook.Add("ASC_HyperspaceCompleted", "MyAddon", function(shipCore, success)
    -- Handle jump completion
end)
```

---

## 🛠️ Troubleshooting

### Common Issues

#### Ship Core Not Detecting Ship
**Symptoms**: Ship core doesn't recognize attached components
**Solutions**:
1. Ensure components are within 2000 units of ship core
2. Check that entities are properly welded/constrained
3. Verify ship core is not damaged or disabled
4. Use `aria diagnostic` for automated detection

```lua
-- Manual ship detection refresh
local shipCore = ASC.AI.FindPlayerShipCore(LocalPlayer())
if IsValid(shipCore) then
    shipCore:UpdateShipDetection()
end
```

#### Weapons Not Firing
**Symptoms**: Weapons don't respond to fire commands
**Solutions**:
1. Check energy levels in ship core
2. Verify weapon is registered with ship core
3. Ensure target is within weapon range
4. Check weapon group configuration

```lua
-- Debug weapon status
local status = ASC.Weapons.Core.GetWeaponStatus(shipID)
print("Weapons: " .. status.weapons)
print("Energy: " .. status.ammo.energy)
```

#### Hyperspace Jump Failures
**Symptoms**: Hyperspace jumps fail to initiate or complete
**Solutions**:
1. Verify sufficient energy for jump
2. Check destination coordinates are valid
3. Ensure ship core is functional
4. Validate ship mass is within limits

```lua
-- Check jump requirements
local distance = startPos:Distance(endPos)
local mass = HYPERDRIVE.Core.CalculateShipMass(shipCore)
local energy, time = HYPERDRIVE.Core.CalculateJumpRequirements(distance, mass)
print("Required energy: " .. energy .. ", Available: " .. shipCore:GetEnergy())
```

#### AI Assistant Not Responding
**Symptoms**: ARIA-4 doesn't respond to commands
**Solutions**:
1. Check if AI system is enabled (`asc_enable_ai_system 1`)
2. Verify web access is working (`asc_ai_web_access 1`)
3. Ensure content filter is not blocking responses
4. Try basic commands first (`aria help`)

### Performance Issues

#### Low FPS with Large Ships
**Solutions**:
1. Enable performance mode (`asc_performance_mode 1`)
2. Reduce update rates for non-critical systems
3. Disable UI animations (`asc_ui_animations 0`)
4. Limit number of active weapon systems

#### Network Lag in Multiplayer
**Solutions**:
1. Increase server network rates
2. Reduce ship detection frequency
3. Optimize weapon firing rates
4. Use weapon groups instead of individual weapons

### Debug Commands

#### System Diagnostics
```
asc_diagnostics              - Full system health check
asc_debug_mode 1             - Enable debug output
asc_status                   - System status overview
asc_health                   - Quick health check
```

#### Entity Debugging
```
asc_list_ships               - List all detected ships
asc_list_weapons             - List all weapon systems
asc_entity_info <entity>     - Get detailed entity information
```

### Log Analysis

#### Important Log Messages
```
[Advanced Space Combat] System initialized successfully
[Ship Core] Ship detected with X entities
[Weapon System] Weapon group created: GroupName
[Hyperspace] Jump initiated to coordinates: X, Y, Z
[ARIA-4] AI response generated for player: PlayerName
```

#### Error Patterns
```
[ERROR] Ship core not found          - Ship detection issue
[ERROR] Insufficient energy          - Power management problem
[ERROR] Invalid coordinates          - Navigation issue
[ERROR] Weapon system offline        - Combat system problem
```

---

## 📄 License & Credits

### License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Credits
- **Development Team**: Advanced Space Combat Team
- **AI System**: ARIA-4 Next-Generation Intelligence
- **Stargate Integration**: Based on Stargate SG-1 universe
- **CAP Integration**: Carter Addon Pack compatibility
- **Community**: Garry's Mod space simulation community

### Version History
- **v5.1.0** - Phase 3 Enhanced (Current)
  - Advanced weapon targeting system
  - Enhanced UI configuration
  - Improved ship core indicators
  - Professional code quality

- **v5.0.0** - Phase 2 Complete
  - Enhanced ship core system
  - Improved sound management
  - AI command enhancements

- **v4.0.0** - Phase 1 Foundation
  - Core system architecture
  - Basic functionality implementation
  - Initial AI integration

### Support
For support, bug reports, or feature requests:
- **GitHub Issues**: [Create an issue](https://github.com/your-repo/advanced-space-combat/issues)
- **Community Discord**: [Join our server](https://discord.gg/your-server)
- **Documentation**: [Wiki pages](https://github.com/your-repo/advanced-space-combat/wiki)

---

**🌌 Advanced Space Combat v5.1.0 - The Ultimate Space Simulation Experience for Garry's Mod 🚀**

*Professional-grade space combat • Authentic Stargate hyperspace • ARIA-4 AI assistant • Enterprise quality*
