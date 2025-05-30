# Enhanced Hyperdrive System - Installation Guide

Complete installation and setup guide for the Enhanced Hyperdrive System v2.1.0.

## 📋 System Requirements

### Minimum Requirements
- **Garry's Mod**: Latest version
- **Operating System**: Windows 7+, macOS 10.12+, or Linux
- **RAM**: 4GB minimum, 8GB recommended
- **Storage**: 100MB free space for addon files
- **Network**: Stable internet connection for multiplayer

### Recommended Specifications
- **RAM**: 16GB for large ships and multiplayer servers
- **CPU**: Multi-core processor for optimal performance
- **GPU**: Dedicated graphics card for enhanced visual effects
- **Storage**: SSD for faster loading times

## 🔧 Installation Methods

### Method 1: Steam Workshop (Recommended)

1. **Open Steam Workshop**
   - Launch Steam and navigate to Garry's Mod
   - Click "Browse the Workshop"
   - Search for "Enhanced Hyperdrive System"

2. **Subscribe to Addon**
   - Click on the Enhanced Hyperdrive System addon
   - Click the "Subscribe" button
   - Wait for automatic download

3. **Launch Garry's Mod**
   - Start Garry's Mod
   - The addon will automatically load
   - Check console for successful loading messages

### Method 2: Manual Installation

1. **Download Addon Files**
   - Download the latest release from GitHub
   - Extract the ZIP file to a temporary location

2. **Install to Addons Directory**
   ```
   Copy extracted folder to:
   Steam/steamapps/common/GarrysMod/garrysmod/addons/
   ```

3. **Verify Installation**
   - Ensure folder structure is correct:
   ```
   garrysmod/addons/enhanced_hyperdrive_system/
   ├── addon.txt
   ├── lua/
   ├── materials/
   └── sound/
   ```

4. **Restart Garry's Mod**
   - Close and restart Garry's Mod
   - Check console for loading confirmation

### Method 3: Git Clone (Developers)

1. **Clone Repository**
   ```bash
   cd "Steam/steamapps/common/GarrysMod/garrysmod/addons/"
   git clone https://github.com/username/enhanced-hyperdrive-system.git
   ```

2. **Verify Installation**
   - Check that all files are present
   - Restart Garry's Mod

## 🔌 Optional Dependencies

### CAP (Carter Addon Pack)
**Highly Recommended** for enhanced Stargate integration

1. **Steam Workshop Installation**
   - Subscribe to "Carter Addon Pack" on Steam Workshop
   - Subscribe to "CAP Resources" addon
   - Restart Garry's Mod

2. **Manual Installation**
   - Download CAP from official sources
   - Install following CAP installation instructions
   - Ensure CAP loads before Enhanced Hyperdrive System

### Spacebuild 3
**Recommended** for advanced resource management

1. **Install Spacebuild 3**
   - Subscribe to Spacebuild 3 on Steam Workshop
   - Install all required Spacebuild components:
     - Spacebuild Model Pack
     - CAF (Community Addon Framework)
     - Resource Distribution (RD)
     - Life Support 2 (LS2)

2. **Verify Compatibility**
   - Check that Spacebuild loads successfully
   - Verify resource systems are functional

### Space Combat 2
**Optional** for enhanced ship physics

1. **Install Space Combat 2**
   - Subscribe to Space Combat 2 gamemode
   - Install required dependencies
   - Configure gamemode settings

### Wiremod
**Optional** for automation and advanced control

1. **Install Wiremod**
   - Subscribe to Wiremod on Steam Workshop
   - Install Expression 2 (E2) if desired
   - Verify Wiremod functionality

## ⚙️ Initial Setup

### First Launch Configuration

1. **Open Configuration Panel**
   - Press Q to open spawn menu
   - Navigate to Options → Enhanced Hyperdrive
   - Review default settings

2. **Configure Basic Settings**
   ```lua
   Core Settings:
   ✓ Enable Ship Core Requirement: true
   ✓ Auto-Activate Shields: true
   ✓ Enable Visual Effects: true
   
   Performance Settings:
   ✓ Effect Quality: medium (adjust based on hardware)
   ✓ Update Intervals: default values
   ✓ Network Optimization: true (for multiplayer)
   ```

3. **Test Basic Functionality**
   - Spawn a ship core from the Enhanced Hyperdrive category
   - Verify the entity appears and functions
   - Check console for any error messages

### CAP Integration Setup

If CAP is installed:

1. **Verify CAP Detection**
   - Open ship core interface
   - Check for CAP tab in interface
   - Verify CAP status shows "Active"

2. **Configure CAP Settings**
   ```lua
   CAP Integration:
   ✓ Enable CAP Integration: true
   ✓ Prefer CAP Systems: true
   ✓ Use CAP Shields: true
   ✓ Stargate Integration: true
   ```

3. **Test CAP Features**
   - Spawn CAP entities on a ship
   - Verify automatic detection
   - Test shield integration

### Spacebuild 3 Setup

If Spacebuild 3 is installed:

1. **Configure Resource Integration**
   ```lua
   SB3 Resources:
   ✓ Enable SB3 Integration: true
   ✓ Auto-Provision: true
   ✓ Weld Detection: true
   ✓ Resource Distribution: true
   ```

2. **Test Resource Systems**
   - Build a ship with SB3 components
   - Verify resource flow
   - Check auto-provisioning

## 🚀 Quick Start Tutorial

### Building Your First Hyperdrive Ship

1. **Create Ship Foundation**
   - Spawn a large prop for ship hull
   - Use PHX plates or similar for structure
   - Ensure solid, welded construction

2. **Add Ship Core**
   - Spawn "Ship Core" from Enhanced Hyperdrive category
   - Weld to ship structure (important!)
   - Position centrally for best detection

3. **Add Hyperdrive Engine**
   - Spawn "Hyperdrive Engine" 
   - Weld to ship structure
   - Position for aesthetic appeal

4. **Optional Components**
   - Add shield generators for protection
   - Include resource storage (if using SB3)
   - Add CAP components (if using CAP)

5. **Test Ship Systems**
   - Use ship core (E key by default)
   - Verify ship detection
   - Check all systems are active

### First Hyperdrive Jump

1. **Prepare for Jump**
   - Ensure ship core shows "Operational"
   - Check energy levels are sufficient
   - Verify hull integrity is good

2. **Set Destination**
   - Use hyperdrive engine interface
   - Set coordinates or use beacon
   - Confirm destination is valid

3. **Execute Jump**
   - Activate hyperdrive charging
   - Wait for charging completion
   - Enjoy the jump sequence!

## 🔧 Server Setup

### Dedicated Server Installation

1. **Install on Server**
   - Upload addon files to server addons directory
   - Ensure proper file permissions
   - Add to server's addon list

2. **Configure Server Settings**
   ```lua
   // server.cfg additions
   hyperdrive_server_mode 1
   hyperdrive_max_ships_per_player 5
   hyperdrive_enable_logging 1
   ```

3. **Performance Optimization**
   ```lua
   // Performance settings for servers
   hyperdrive_network_optimization 1
   hyperdrive_update_rate 20
   hyperdrive_max_entities 1000
   ```

### Workshop Collection Setup

1. **Create Workshop Collection**
   - Include Enhanced Hyperdrive System
   - Add recommended dependencies
   - Set collection as server's workshop collection

2. **Configure Auto-Download**
   ```lua
   // Force client downloads
   sv_downloadurl "your-fastdl-server"
   sv_allowupload 1
   sv_allowdownload 1
   ```

## 🛠️ Troubleshooting Installation

### Common Installation Issues

#### Addon Not Loading
**Symptoms**: No hyperdrive entities in spawn menu
**Solutions**:
- Verify addon.txt file exists and is valid
- Check file permissions
- Ensure proper folder structure
- Restart Garry's Mod completely

#### Missing Dependencies
**Symptoms**: Error messages about missing functions
**Solutions**:
- Install all required dependencies
- Verify dependency versions are compatible
- Check load order in addon list

#### Performance Issues
**Symptoms**: Low FPS, lag during hyperdrive operations
**Solutions**:
- Reduce effect quality in settings
- Increase update intervals
- Enable network optimization
- Limit ship complexity

#### CAP Integration Not Working
**Symptoms**: No CAP tab in ship core interface
**Solutions**:
- Verify CAP is properly installed
- Check CAP version compatibility
- Enable CAP integration in settings
- Restart after CAP installation

### Diagnostic Commands

```lua
-- Check addon status
hyperdrive_status

-- Verify integration status
hyperdrive_integration_status

-- Test core functionality
hyperdrive_test_core

-- Check for conflicts
hyperdrive_check_conflicts

-- Enable debug mode
hyperdrive_debug 1
```

### Log File Analysis

Check these log files for issues:
```
garrysmod/console.log
garrysmod/data/hyperdrive/debug.log
garrysmod/data/hyperdrive/errors.log
```

## 📞 Getting Help

### Support Resources

1. **Documentation**
   - Read README.md for overview
   - Check CONFIGURATION.md for settings
   - Review API_REFERENCE.md for development

2. **Community Support**
   - Steam Workshop comments
   - GitHub Issues page
   - Discord community server

3. **Reporting Issues**
   - Provide detailed error messages
   - Include console logs
   - Describe reproduction steps
   - List installed addons

### Before Seeking Help

1. **Verify Installation**
   - Confirm all files are present
   - Check addon is enabled
   - Verify dependencies are installed

2. **Check Configuration**
   - Review settings for conflicts
   - Test with default configuration
   - Disable other addons temporarily

3. **Gather Information**
   - Note exact error messages
   - Record steps to reproduce issue
   - Check console for additional details

## ✅ Installation Verification

### Successful Installation Checklist

- [ ] Addon appears in spawn menu under "Enhanced Hyperdrive"
- [ ] Ship core entity can be spawned and used
- [ ] Hyperdrive engines are available and functional
- [ ] Configuration panel is accessible via Q menu
- [ ] No error messages in console during startup
- [ ] CAP integration active (if CAP installed)
- [ ] Spacebuild integration working (if SB3 installed)
- [ ] Wire integration functional (if Wiremod installed)

### Test Ship Checklist

- [ ] Ship core detects ship structure
- [ ] Hyperdrive engine charges successfully
- [ ] Jump sequence completes without errors
- [ ] Visual effects display correctly
- [ ] Sound effects play properly
- [ ] All systems show "Operational" status

Congratulations! Your Enhanced Hyperdrive System is now installed and ready for interstellar adventures!
