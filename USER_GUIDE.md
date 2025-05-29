# Hyperdrive System - User Guide

## Table of Contents
1. [Getting Started](#getting-started)
2. [Basic Operations](#basic-operations)
3. [Engine Types](#engine-types)
4. [Computer Interface](#computer-interface)
5. [Fleet Management](#fleet-management)
6. [Beacon Networks](#beacon-networks)
7. [Integration Features](#integration-features)
8. [Advanced Features](#advanced-features)
9. [Troubleshooting](#troubleshooting)
10. [Tips and Tricks](#tips-and-tricks)

## Getting Started

### Installation
1. Subscribe to the addon on Steam Workshop or download from GitHub
2. Restart Garry's Mod
3. Find Hyperdrive entities in the spawn menu under "Hyperdrive" category

### First Jump
1. **Spawn a Hyperdrive Engine** from the spawn menu
2. **Spawn a Hyperdrive Computer** for easy control
3. **Right-click the computer** to open the interface
4. **Set a destination** using the coordinate input
5. **Click "Charge Engine"** and wait for charging to complete
6. **Click "Jump"** to initiate travel

### Quick Setup Checklist
- ✅ Engine spawned and positioned
- ✅ Computer spawned and linked to engine
- ✅ Destination coordinates set
- ✅ Engine charged and ready
- ✅ Clear path to destination

## Basic Operations

### Setting Destinations

#### Manual Coordinates
1. Open computer interface
2. Enter X, Y, Z coordinates
3. Click "Set Destination"
4. Verify coordinates are valid

#### Using Waypoints
1. Save frequently used locations as waypoints
2. Select waypoint from dropdown menu
3. Click "Jump to Waypoint"

#### Planet Detection
1. Enable "Auto-Detect Planets" in computer
2. Computer will automatically find nearby planets
3. Select planet from detected list
4. Jump directly to planet

### Energy Management

#### Charging Process
1. **Initiation**: Engine begins energy buildup
2. **Charging**: Energy increases over time
3. **Ready**: Engine reaches full charge
4. **Jump**: Energy is consumed for travel

#### Energy Efficiency
- **Shorter distances** require less energy
- **Beacon networks** provide efficiency bonuses
- **Ship classification** affects energy requirements
- **Integration systems** can modify energy costs

### Jump Process

#### Standard Jump
1. **Charge Phase**: Engine builds up energy (3-5 seconds)
2. **Portal Phase**: Jump portal opens (1-2 seconds)
3. **Travel Phase**: Entities move through hyperspace
4. **Arrival Phase**: Portal closes at destination

#### Stargate 4-Stage Travel
1. **Initiation**: Energy surges, coordinate calculation (3 seconds)
2. **Window Opening**: Blue/purple energy tunnel forms (2 seconds)
3. **Hyperspace Travel**: Stretched starlines effect (5 seconds)
4. **Exit Stabilization**: Light flash, system stabilization (2 seconds)

## Engine Types

### Hyperdrive Engine (Standard)
**Best for**: Basic space travel, learning the system
**Features**: 
- Simple operation
- Moderate energy efficiency
- Compatible with all integrations

**Usage Tips**:
- Good starting engine for new users
- Reliable for short to medium distance travel
- Easy to understand and operate

### Hyperdrive SB Engine (Spacebuild)
**Best for**: Spacebuild 3 ships with resource systems
**Features**:
- Resource consumption (power, oxygen, coolant)
- Life support integration
- Environmental protection

**Requirements**:
- Spacebuild 3 addon installed
- Connected to ship's power grid
- Adequate life support systems

**Usage Tips**:
- Monitor resource levels before jumping
- Ensure life support is active
- Consider environmental hazards at destination

### Hyperdrive SG Engine (Stargate)
**Best for**: Stargate-themed builds and roleplay
**Features**:
- Stargate network integration
- Address-based navigation
- Technology level progression

**Requirements**:
- CAP or Stargate addon installed
- Naquadah fuel (if enabled)
- Compatible technology level

**Usage Tips**:
- Use Stargate addresses for navigation
- Respect shield and iris protections
- Consider technology limitations

### Hyperdrive Master Engine (Advanced)
**Best for**: Large ships, fleet operations, maximum features
**Features**:
- All integration systems combined
- Highest efficiency ratings
- Advanced automation capabilities
- 4-stage travel support

**Usage Tips**:
- Best choice for capital ships
- Excellent for fleet coordination
- Supports all advanced features

## Computer Interface

### Navigation Mode
**Purpose**: Basic navigation and jump control

**Features**:
- Coordinate input
- Waypoint management
- Engine status display
- Jump controls

**Controls**:
- **Destination X/Y/Z**: Manual coordinate entry
- **Set Destination**: Apply coordinates
- **Charge Engine**: Begin charging process
- **Jump**: Initiate travel
- **Abort**: Cancel current operation

### Planets Mode
**Purpose**: Automatic planet detection and navigation

**Features**:
- Auto-detect nearby planets
- Planet information display
- Quick jump to planets
- Planet waypoint saving

**Controls**:
- **Scan for Planets**: Manual planet scan
- **Auto-Detect**: Toggle automatic detection
- **Jump to Planet**: Quick planet travel
- **Save as Waypoint**: Store planet location

### Status Mode
**Purpose**: System monitoring and diagnostics

**Features**:
- Engine status overview
- Integration system status
- Performance metrics
- Error reporting

**Information Displayed**:
- Engine energy levels
- Charging status
- Cooldown timers
- Integration health
- System warnings

## Fleet Management

### Linking Engines
1. **Spawn multiple engines** for your fleet
2. **Use one computer** to control all engines
3. **Engines auto-link** when in range of computer
4. **Manual linking** available in computer interface

### Fleet Operations

#### Synchronized Jumps
1. **Set destination** for entire fleet
2. **Click "Fleet Jump"** in computer
3. **All engines charge simultaneously**
4. **Fleet jumps together** when ready

#### Individual Control
1. **Select specific engine** in computer interface
2. **Set individual destination** if needed
3. **Monitor each engine separately**
4. **Manual override** available for each engine

### Fleet Coordination Benefits
- **Energy efficiency bonus** for coordinated jumps
- **Synchronized arrival** at destination
- **Reduced network traffic** for large fleets
- **Centralized control** from single computer

## Beacon Networks

### Beacon Placement
1. **Spawn Hyperdrive Beacons** at strategic locations
2. **Set beacon names** for easy identification
3. **Configure beacon range** (default: 5000 units)
4. **Activate beacons** to join network

### Network Benefits
- **5% efficiency bonus** when jumping between beacons
- **Automatic waypoint creation** for beacon locations
- **Enhanced navigation** with beacon pathfinding
- **Network status display** in computer interface

### Beacon Management
- **Name your beacons** descriptively (e.g., "Home Base", "Mining Station")
- **Set appropriate ranges** to avoid overlap
- **Monitor beacon status** in computer interface
- **Maintain beacon network** for optimal performance

## Integration Features

### SpaceCombat2 Integration
**When Active**:
- Ships move as unified entities via gyropod system
- Gravity is overridden during hyperspace travel
- Ship cores are used for entity detection
- Optimized movement for better performance

**Usage**:
- Build ships with SC2 gyropods
- Attach hyperdrive to ship core
- Enjoy seamless ship movement

### Spacebuild 3 Integration
**When Active**:
- Engines consume power, oxygen, and coolant
- Life support systems are required
- Environmental hazards are considered
- Resource efficiency affects jump costs

**Usage**:
- Connect engine to ship's power grid
- Ensure adequate life support
- Monitor resource consumption
- Plan jumps based on resource availability

### Wiremod Integration
**When Active**:
- Full wire input/output support
- Automated navigation possible
- Fleet coordination via wires
- Real-time status monitoring

**Usage**:
- Wire engines to control systems
- Create automated jump sequences
- Build complex navigation computers
- Monitor fleet status with displays

### CAP Integration
**When Active**:
- Stargate network compatibility
- Shield system respect
- Energy sharing with Stargates
- Address-based navigation

**Usage**:
- Use Stargate addresses for navigation
- Respect active shields and irises
- Share energy with Stargate systems
- Integrate with existing CAP builds

## Advanced Features

### Quantum Mechanics
- **Relativistic effects** at high velocities
- **Gravitational lensing** near massive objects
- **Quantum tunneling** for experimental jumps
- **Space-time distortion** visualization

### Security System
- **Owner-based access control**
- **Admin override capabilities**
- **Anti-griefing protection**
- **Audit logging** of all actions

### Performance Optimization
- **Dynamic quality adjustment** based on performance
- **Effect culling** for distant objects
- **Network optimization** for large servers
- **Memory management** for long sessions

### Error Recovery
- **Automatic error detection**
- **Recovery procedures** for failed jumps
- **Emergency shutdown** systems
- **Diagnostic reporting**

## Troubleshooting

### Engine Won't Charge
**Possible Causes**:
- Insufficient power (Spacebuild)
- Invalid destination
- Engine in cooldown
- Integration system error

**Solutions**:
- Check power connections
- Verify destination coordinates
- Wait for cooldown to complete
- Restart integration systems

### Jump Failed
**Possible Causes**:
- Destination blocked
- Insufficient energy
- Entity detection failure
- Network error

**Solutions**:
- Clear destination area
- Ensure full charge
- Check entity attachments
- Verify network connection

### Integration Not Working
**Possible Causes**:
- Required addon not installed
- Integration disabled in config
- Version compatibility issue
- Server restrictions

**Solutions**:
- Install required addons
- Enable integration in admin panel
- Update to latest versions
- Check server settings

### Performance Issues
**Possible Causes**:
- Too many active effects
- High entity count
- Network congestion
- Hardware limitations

**Solutions**:
- Reduce effect quality
- Limit active engines
- Optimize network settings
- Upgrade hardware

## Tips and Tricks

### Efficiency Tips
- **Use beacon networks** for 5% energy savings
- **Plan routes** to minimize total distance
- **Coordinate fleet jumps** for bonuses
- **Monitor resource consumption** (Spacebuild)

### Building Tips
- **Place engines centrally** on ships for better entity detection
- **Use computers** for easier control than direct engine interaction
- **Create beacon networks** for frequently traveled routes
- **Test jumps** with small distances first

### Advanced Techniques
- **Chain jumps** through beacon networks for long distances
- **Use waypoints** to save complex navigation routes
- **Automate with Wiremod** for hands-free operation
- **Combine integrations** for maximum functionality

### Roleplay Enhancement
- **Use Stargate engines** for authentic Stargate experience
- **Respect technology levels** in Stargate builds
- **Create jump protocols** for immersive fleet operations
- **Use 4-stage travel** for dramatic effect

### Performance Optimization
- **Adjust effect quality** based on your hardware
- **Limit simultaneous jumps** on busy servers
- **Use LOD settings** for better performance
- **Monitor system resources** during operation

---

This user guide provides comprehensive instructions for using the Hyperdrive System effectively, from basic operations to advanced features and troubleshooting.
