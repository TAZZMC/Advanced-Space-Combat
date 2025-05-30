# Enhanced Hyperdrive System v2.1.0

A comprehensive space travel addon for Garry's Mod featuring advanced hyperdrive technology, ship management systems, and extensive integration support.

## 🚀 Features

### Core Systems
- **Advanced Hyperdrive Engines**: Multiple engine types with unique capabilities
- **Ship Core Management**: Centralized ship control and monitoring
- **Hull Damage System**: Realistic ship damage and repair mechanics
- **Shield Systems**: Protective energy shields with multiple types
- **Resource Management**: Integrated Spacebuild 3 resource systems
- **Navigation AI**: Intelligent route planning and obstacle avoidance

### Integration Support
- **CAP (Carter Addon Pack)**: Full integration with Stargate systems, shields, and energy
- **Spacebuild 3**: Complete resource system integration
- **Space Combat 2**: Enhanced ship movement and combat systems
- **Wiremod**: Comprehensive automation and monitoring support

### Visual Effects
- **4-Stage Stargate Hyperdrive**: Cinematic jump sequences with energy buildup, window opening, hyperspace travel, and exit
- **Enhanced Particle Effects**: Immersive visual feedback for all systems
- **Ship-Based Effects**: Effects play around the ship rather than on player HUDs
- **CAP Effects Integration**: Seamless integration with CAP visual systems

## 📋 Requirements

### Minimum Requirements
- Garry's Mod
- Basic understanding of Garry's Mod mechanics

### Optional Dependencies
- **CAP (Carter Addon Pack)**: For Stargate integration and enhanced effects
- **Spacebuild 3**: For advanced resource management
- **Space Combat 2**: For enhanced ship physics
- **Wiremod**: For automation and advanced control

## 🔧 Installation

1. **Download** the Enhanced Hyperdrive System addon
2. **Extract** to your `garrysmod/addons/` directory
3. **Restart** Garry's Mod or change map
4. **Configure** settings via Q menu → Options → Enhanced Hyperdrive

### Steam Workshop Installation
1. Subscribe to the Enhanced Hyperdrive System on Steam Workshop
2. Restart Garry's Mod
3. The addon will automatically download and install

## 🎮 Quick Start Guide

### Basic Setup
1. **Spawn a Ship Core** from the Enhanced Hyperdrive category
2. **Build your ship** around the core (welded entities are automatically detected)
3. **Add Hyperdrive Engines** to your ship
4. **Configure systems** through the ship core interface (USE key)

### First Jump
1. **Open ship core interface** (USE key on ship core)
2. **Set destination** coordinates in the hyperdrive engine
3. **Ensure sufficient energy** and resources
4. **Activate hyperdrive** and enjoy the journey!

## 🏗️ Entity Guide

### Ship Core
- **Purpose**: Central management hub for all ship systems
- **Features**: Hull monitoring, resource management, shield control, CAP integration
- **Interface**: Comprehensive tabbed interface with real-time status

### Hyperdrive Engines
- **Standard Engine**: Basic hyperdrive with configurable energy requirements
- **Master Engine**: Advanced engine with fleet coordination capabilities
- **Stargate Engine**: CAP-integrated engine with Stargate-style effects
- **Spacebuild Engine**: Optimized for Spacebuild 3 integration

### Support Entities
- **Hyperdrive Computer**: Fleet management and coordination
- **Hyperdrive Beacon**: Navigation waypoints and ship detection
- **Shield Generator**: Energy shield projection and management
- **Wire Controller**: Advanced Wiremod integration hub

## ⚙️ Configuration

### Q Menu Configuration
Access configuration through: **Q Menu → Options → Enhanced Hyperdrive**

#### Core Settings
- **Enable Ship Core Requirement**: Require ship core for hyperdrive operation
- **Auto-Activate Shields**: Automatically activate shields during hyperdrive charging
- **Use CAP Systems**: Prefer CAP systems when available
- **Enable Visual Effects**: Control visual effect intensity

#### CAP Integration
- **Enable CAP Integration**: Master toggle for CAP features
- **Prefer CAP Shields**: Use CAP bubble shields over built-in shields
- **CAP Energy Integration**: Share energy between CAP and hyperdrive systems
- **Stargate Network**: Enable Stargate address system integration

#### Performance Settings
- **Update Intervals**: Adjust system update frequencies
- **Effect Quality**: Control visual effect detail levels
- **Network Optimization**: Enable optimized networking for large ships

## 🔌 CAP Integration

### Automatic Detection
The system automatically detects CAP installation and enables enhanced features:

- **Stargate Hyperdrive Effects**: 4-stage jump sequence with authentic Stargate visuals
- **Bubble Shield Integration**: CAP shields automatically integrate with ship systems
- **Energy System Sharing**: CAP energy sources power hyperdrive systems
- **DHD Integration**: Dial Home Device compatibility for address-based travel

### CAP-Specific Features
- **Stargate Addresses**: Use 6-symbol addresses for navigation
- **ZPM Integration**: Zero Point Module energy sources
- **Iris Protection**: Automated iris control during hyperdrive operations
- **Asgard Beam Integration**: Enhanced transport effects

## 🔧 Wiremod Integration

### Engine Outputs
- **Energy**: Current energy level
- **Charging**: Charging status (0/1)
- **JumpReady**: Ready to jump (0/1)
- **ShipDetected**: Ship core detected (0/1)
- **CAPIntegrated**: CAP systems active (0/1)

### Ship Core Outputs
- **CoreState**: Current core state
- **HullIntegrity**: Hull damage percentage
- **ShieldStrength**: Shield power level
- **ResourceLevels**: All resource percentages
- **CAP Status**: CAP integration information

### Control Inputs
- **Jump**: Initiate hyperdrive sequence
- **SetDestination**: Set target coordinates
- **ActivateShields**: Enable protective shields
- **EmergencyRepair**: Initiate emergency hull repair

## 🛠️ Advanced Features

### Hull Damage System
- **Realistic Damage**: Hull integrity affects ship performance
- **Breach Detection**: Automatic detection of hull breaches
- **Emergency Repair**: Quick repair systems for critical situations
- **Auto-Repair**: Gradual hull regeneration over time

### Resource Management
- **Automatic Distribution**: Resources automatically flow to ship components
- **Emergency Mode**: Critical resource level management
- **Weld Detection**: Newly welded components automatically receive resources
- **Surplus Collection**: Automatic collection of excess resources

### Navigation AI
- **Obstacle Avoidance**: Intelligent pathfinding around obstacles
- **Route Optimization**: Efficient travel path calculation
- **Emergency Protocols**: Automatic safety measures during travel
- **Fleet Coordination**: Multi-ship formation management

## 🎯 Best Practices

### Ship Design
1. **Place ship core centrally** for optimal detection
2. **Use symmetrical designs** for better stability
3. **Include redundant systems** for reliability
4. **Plan resource distribution** efficiently

### Performance Optimization
1. **Limit entity count** on large ships
2. **Use appropriate update intervals** for your server
3. **Enable network optimization** for multiplayer
4. **Monitor resource usage** regularly

### Safety Guidelines
1. **Always check hull integrity** before long jumps
2. **Maintain adequate energy reserves** for emergencies
3. **Test systems** before critical missions
4. **Keep backup navigation data** available

## 🐛 Troubleshooting

### Common Issues

#### Ship Not Detected
- Ensure ship core is properly welded to ship structure
- Check that entities are physically connected
- Verify ship core is not duplicated

#### Hyperdrive Won't Charge
- Confirm ship core is present and valid
- Check energy levels and resource availability
- Verify hull integrity is above critical threshold

#### CAP Integration Not Working
- Ensure CAP is properly installed and updated
- Check CAP integration settings in configuration
- Verify CAP entities are detected on ship

### Performance Issues
- Reduce visual effect quality in settings
- Increase update intervals for better performance
- Enable network optimization features
- Limit ship size and complexity

## 📞 Support

### Getting Help
- **GitHub Issues**: Report bugs and request features
- **Steam Workshop**: Community discussions and support
- **Discord**: Real-time community support (link in workshop)

### Contributing
- **Bug Reports**: Detailed reproduction steps appreciated
- **Feature Requests**: Describe use cases and benefits
- **Code Contributions**: Pull requests welcome on GitHub

## 📄 License

This addon is released under the MIT License. See LICENSE file for details.

## 🙏 Credits

- **Original Concept**: Inspired by science fiction hyperdrive technology
- **CAP Integration**: Thanks to the Carter Addon Pack development team
- **Community**: Special thanks to all testers and contributors
- **Spacebuild Team**: For the excellent Spacebuild framework

---

**Version**: 2.1.0  
**Last Updated**: 2024  
**Compatibility**: Garry's Mod (Latest)
