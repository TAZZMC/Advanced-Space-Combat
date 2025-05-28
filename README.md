# Garry's Mod Hyperdrive Addon

A comprehensive hyperdrive system for Garry's Mod that allows players to travel through hyperspace with their ships, featuring a separate hyperspace dimension where players can move around during transit.

## Features

### 🚀 Core Hyperdrive System
- **Master Hyperdrive Engine** - Advanced engine with all features integrated
- **Hyperdrive Computer** - Central control system for navigation and fleet coordination
- **Hyperspace Dimension** - Separate dimension where players can move during travel
- **Fleet Coordination** - Multiple engines can jump together in formation

### 🌌 Hyperspace Experience
- **Interactive Hyperspace** - Players can move around inside their ships during travel
- **Visual Effects** - Stunning hyperspace window animations and effects
- **Hyperspace Physics** - Reduced gravity and special physics in hyperspace
- **Energy Boundaries** - Visible walls that contain the hyperspace area
- **Emergency Exit** - Safety system to exit hyperspace if needed

### 🔧 Integration Support
- **Wiremod Integration** - Full wire input/output support for automation
- **Spacebuild 3 Support** - Compatible with Spacebuild ships and components
- **Stargate Integration** - Works with Stargate Carter Addon Pack
- **Auto-Detection** - Automatically finds and links to Spacebuild planets

### 🎮 User-Friendly Features
- **Easy Controls** - Press E to interact with computers and engines
- **Waypoint System** - Save and manage jump destinations
- **Planet Detection** - Automatically scans for nearby planets
- **Quick Jump** - Instant jumps to saved locations
- **Safety Checks** - Prevents dangerous jumps and collisions

## Installation

1. Download the addon files
2. Extract to your `garrysmod/addons/` directory
3. Restart Garry's Mod
4. The addon will automatically load on server start

## Quick Start Guide

### Basic Setup
1. **Spawn a Hyperdrive Master Engine** from the Entities menu
2. **Spawn a Hyperdrive Computer** near your engine
3. **Press E on the computer** to open the interface
4. **Auto-link engines** using the computer interface
5. **Set a destination** by clicking on the map or entering coordinates
6. **Press "Execute Jump"** to begin hyperspace travel

### During Hyperspace Travel
- **Move around freely** inside your ship
- **Watch the progress bar** to see travel time remaining
- **Use emergency exit** if needed (F4 key or emergency button)
- **Enjoy the hyperspace effects** and visual experience

## Controls

### Hyperdrive Computer
- **E Key** - Open computer interface
- **Left Click** - Interact with interface buttons
- **Mouse Wheel** - Scroll through waypoints and options

### During Hyperspace
- **WASD** - Move around normally
- **F4** - Emergency exit from hyperspace
- **Emergency Exit Button** - Click the red button in bottom-right corner

### Console Commands
- `hyperdrive_debug_test` - Test system status
- `hyperdrive_debug_force_exit` - Force exit all hyperspace travels
- `hyperdrive_emergency_exit` - Emergency exit for current player
- `hyperdrive_visual_disable_all` - Disable visual effects (if experiencing issues)

## Configuration

### Visual Effects
The addon includes a visual configuration system to adjust effects intensity:

```
hyperdrive_visual_set ScreenEffectsIntensity 0.5
hyperdrive_visual_set FlashIntensity 0.3
hyperdrive_visual_disable_all  // Disable all effects
hyperdrive_visual_reset        // Reset to safe defaults
```

### Hyperspace Settings
Key configuration options in the code:
- **Transit Time** - 3-30 seconds based on distance
- **Energy Cost** - Based on distance and engine efficiency
- **Search Radius** - 500-1000 units for entity detection
- **Hyperspace Bounds** - 10,000 unit hyperspace area

## Troubleshooting

### Common Issues

**White Screen During Jump**
```bash
hyperdrive_debug_fix_white_screen
hyperdrive_visual_disable_all
```

**Stuck in Hyperspace**
```bash
hyperdrive_debug_force_exit
hyperdrive_emergency_exit
```

**Ships Not Transporting**
```bash
hyperdrive_debug_test
hyperdrive_debug_status
```

**Computer Not Linking to Engine**
- Make sure engine and computer are within 500 units
- Try using "Auto-Link Engines" button
- Check that engine has sufficient energy

### Debug Commands
- `hyperdrive_debug_test` - Comprehensive system test
- `hyperdrive_debug_status` - Show current hyperspace status
- `hyperdrive_debug_force_exit` - Emergency exit all travels

## Integration Guides

### Wiremod Integration
The addon provides extensive Wiremod support:

**Inputs:**
- Jump, SetDestination, Abort, SetEnergy
- FleetJump, SetMode, ScanEngines
- QuickJumpToPlanet, EmergencyAbort

**Outputs:**
- Powered, LinkedEngines, TotalEnergy
- FleetStatus, JumpCost, EstimatedTime
- PlanetsDetected, NearestPlanet

### Spacebuild Integration
- Automatically detects Spacebuild planets
- Compatible with SB3 life support systems
- Works with Spacebuild ship components
- Auto-links to nearby planets as waypoints

## Performance Notes

- **Entity Limit** - System handles up to 500 entities per jump
- **Update Rate** - Effects update at 0.1 second intervals
- **Memory Usage** - Minimal impact on server performance
- **Network Traffic** - Optimized for multiplayer servers

## Version History

- **v2.0** - Added hyperspace dimension system
- **v1.5** - Integrated Wiremod, Spacebuild, and Stargate support
- **v1.0** - Initial release with basic hyperdrive functionality

## Support

For issues, suggestions, or contributions:
1. Check the troubleshooting section above
2. Use debug commands to diagnose issues
3. Report bugs with console output and steps to reproduce

## License

This addon is provided as-is for Garry's Mod. Feel free to modify and distribute according to Garry's Mod addon guidelines.
