# Advanced Space Combat - Loading Screen and Theme System

## Overview

The Advanced Space Combat addon now features a comprehensive loading screen and enhanced theme system for in-game elements, providing a professional and immersive experience with space combat aesthetics.

## Features

### 🚀 Loading Screen System

**File:** `lua/autorun/client/asc_loading_screen.lua`

- **Professional Space Combat Theme**: Dark space background with animated particles
- **Real-time Progress Tracking**: Shows loading progress for models, materials, sounds, and effects
- **Animated Elements**: Pulsing logo, smooth progress bars, and particle effects
- **Resource Counters**: Displays detailed loading information for each resource type
- **Stargate-inspired Aesthetics**: Consistent with the addon's space theme

**Features:**
- Animated background with moving star particles
- Pulsing ASC logo with space combat colors
- Smooth progress bar with percentage display
- Real-time resource loading counters
- Professional glassmorphism design
- Sound effects integration

### 🎨 Comprehensive Theme System

**File:** `lua/autorun/client/asc_comprehensive_theme.lua`

- **Master Theme Configuration**: Unified color palette and styling across all elements
- **Component-based Theming**: Modular system for different UI components
- **Automatic Element Detection**: Smart detection of ASC-related interfaces
- **Performance Optimized**: Efficient rendering with configurable update rates
- **Accessibility Support**: High contrast and large text options

**Features:**
- Master color palette with space combat theme
- Automatic theming of frames, buttons, panels
- Custom font system with consistent typography
- Animation system with configurable speeds
- Sound effect integration
- Glassmorphism and holographic effects

### 🎨 Character Theme System

**File:** `lua/autorun/client/asc_character_theme.lua`

- **Space Suit Mode**: Enhanced HUD for space environments
- **Character Selection Menu**: Professional UI for choosing player models
- **Enhanced Health/Armor Display**: Modern bars with animations
- **Environmental Status**: Oxygen, energy, and environmental readings

**Features:**
- Space-themed character selection with 5 different roles
- Animated health and armor bars
- Space suit HUD with oxygen and energy levels
- Environmental status display (pressure, temperature)
- Professional glassmorphism UI design

### 🎯 Enhanced HUD Theme

**File:** `lua/autorun/client/asc_player_hud_theme.lua`

- **Modern HUD Design**: Professional space combat interface
- **Animated Elements**: Smooth transitions and real-time updates
- **Custom Crosshair**: Space-themed targeting reticle
- **Weapon Information**: Enhanced weapon display with ammo bars
- **Damage Indicators**: Visual feedback for taking damage

**Features:**
- Custom animated health/armor bars
- Professional weapon information panel
- Animated crosshair with pulse effect
- Damage flash effects
- Scalable HUD elements
- Consistent space combat color scheme

### ⚔️ Weapon Interface Theme

**File:** `lua/autorun/client/asc_weapon_interface_theme.lua`

- **Weapon-specific Styling**: Different colors for each weapon type
- **Real-time Status Display**: Live weapon status, ammo, and targeting information
- **Interactive Controls**: Themed buttons for weapon operations
- **Targeting System**: Visual targeting display with distance and health
- **Holographic Effects**: Optional holographic styling for immersion

**Features:**
- Weapon type color coding (pulse, beam, torpedo, railgun, plasma)
- Real-time ammo and charge displays
- Targeting system with enemy information
- Interactive fire controls and power management
- Status indicators for online/offline/charging states
- Professional control panel design

### ✈️ Flight Interface Theme

**File:** `lua/autorun/client/asc_flight_interface_theme.lua`

- **Comprehensive Flight HUD**: Speed, thrust, navigation, and status displays
- **Real-time Flight Data**: Live updates of ship position, heading, and velocity
- **Navigation System**: Compass, waypoints, and coordinate display
- **Thrust Vector Display**: Visual representation of ship movement
- **Flight Status Panel**: Engine status, fuel, and integrity monitoring

**Features:**
- Speed indicator with color-coded danger levels
- 3D thrust vector visualization
- Navigation compass with heading display
- Waypoint management system
- Flight status monitoring
- Velocity vector indicator on crosshair

### 🤖 AI Interface Theme

**File:** `lua/autorun/client/asc_ai_interface_theme.lua`

- **ARIA-4 Chat Interface**: Professional AI communication panel
- **Real-time Status Display**: AI online/offline/processing indicators
- **Message Type Styling**: Different colors for user, AI, and system messages
- **Typing Indicators**: Visual feedback when AI is responding
- **Command Integration**: Seamless integration with AI command system

**Features:**
- Professional chat interface with glassmorphism design
- AI status indicators with pulsing animations
- Message bubbles with type-specific colors
- Typing animation with dots
- Sound effects for message sending/receiving
- Holographic AI glow effects

### 🔧 VGUI Theme Integration

**File:** `lua/autorun/client/asc_vgui_theme_integration.lua`

- **Automatic Element Detection**: Smart detection of ASC-related UI elements
- **Universal VGUI Theming**: Applies theme to all standard VGUI components
- **Performance Optimized**: Efficient processing with queue system
- **Backward Compatibility**: Maintains original functionality while adding theming
- **Configurable Scope**: Option to theme all elements or only ASC-related ones

**Features:**
- Automatic theming of DFrame, DButton, DPanel, DTextEntry, DLabel
- Smart ASC element detection using pattern matching
- Performance-optimized processing queue
- Original function preservation for compatibility
- Scrollbar and combo box theming
- Checkbox and slider theming

## Console Commands

### Loading Screen Commands
```
asc_show_loading        - Show the loading screen
asc_hide_loading        - Hide the loading screen
asc_test_loading        - Test loading screen with simulated progress
```

### Character Theme Commands
```
asc_character_menu      - Open character selection menu
```

### HUD Theme Commands
```
asc_toggle_hud          - Toggle custom HUD on/off
asc_hud_reset_errors    - Reset HUD theme error tracking
asc_hud_status          - Check HUD theme system status
```

### Comprehensive Theme Commands
```
asc_theme_test          - Test comprehensive theme system with sample panel
```

### Weapon Interface Commands
```
asc_weapon_interface    - Open weapon interface for targeted weapon
```

### Flight Interface Commands
```
asc_flight_hud_test     - Test flight HUD display
asc_flight_hud_hide     - Hide flight HUD
```

### AI Interface Commands
```
asc_ai_chat             - Open ARIA-4 AI chat interface
asc_ai_status [status]  - Set AI status (ONLINE/OFFLINE/PROCESSING/ERROR)
asc_ai_test_message     - Send test message from AI
```

### VGUI Theme Commands
```
asc_vgui_rescan         - Rescan all VGUI elements for theming
asc_vgui_clear_theme    - Clear VGUI theme cache
asc_vgui_reset_errors   - Reset error count and re-enable system
asc_vgui_status         - Show VGUI theme system status
```

## Configuration ConVars

### Loading Screen
```
// No specific ConVars - controlled by resource loading system
```

### Character Theme
```
asc_character_theme_enabled "1"    // Enable character theme system
asc_spacesuit_mode "0"             // Enable space suit mode
asc_show_character_stats "1"       // Show character statistics
```

### HUD Theme
```
asc_hud_enabled "1"                // Enable custom HUD
asc_hud_scale "1.0"               // HUD scale factor
asc_hud_animations "1"            // Enable HUD animations
asc_crosshair_enabled "1"         // Enable custom crosshair
```

### Comprehensive Theme
```
asc_theme_enabled "1"             // Enable comprehensive theme system
asc_theme_animations "1"          // Enable theme animations
asc_theme_sounds "1"              // Enable theme sound effects
asc_theme_entity_interfaces "1"   // Enable entity interface theming
asc_theme_tool_panels "1"         // Enable tool panel theming
asc_theme_spawn_menu "1"          // Enable spawn menu theming
```

### Weapon Interface Theme
```
asc_weapon_theme_enabled "1"      // Enable weapon interface theming
asc_weapon_holo_style "1"         // Enable holographic weapon displays
asc_weapon_animations "1"         // Enable weapon interface animations
```

### Flight Interface Theme
```
asc_flight_hud_enabled "1"        // Enable flight HUD
asc_flight_holo_style "1"         // Enable holographic flight displays
asc_flight_animations "1"         // Enable flight interface animations
asc_flight_sounds "1"             // Enable flight sound feedback
```

### AI Interface Theme
```
asc_ai_chat_enabled "1"           // Enable AI chat interface
asc_ai_holo_style "1"             // Enable holographic AI displays
asc_ai_animations "1"             // Enable AI interface animations
asc_ai_sounds "1"                 // Enable AI sound effects
```

### VGUI Theme Integration
```
asc_vgui_theme_enabled "0"        // Enable VGUI auto-theming (disabled by default for safety)
asc_vgui_theme_all "0"            // Theme all VGUI elements (not just ASC)
asc_vgui_performance_mode "1"     // Enable performance optimizations
asc_vgui_safe_mode "1"            // Enable safe mode with error protection
```

## Color Scheme

The theme system uses a consistent space combat color palette:

- **Primary**: Space Blue (#2980B9)
- **Secondary**: Dark Blue-Gray (#34495E)
- **Accent**: Purple (#9B59B6)
- **Success**: Green (#27AE60)
- **Warning**: Orange (#F39C12)
- **Danger**: Red (#E74C3C)
- **Background**: Dark Space (#17202A)
- **Text**: White (#FFFFFF)

## Materials

### UI Materials
- `materials/asc/ui/loading_background.vmt` - Loading screen background
- `materials/asc/ui/loading_logo.vmt` - ASC logo material
- `materials/asc/ui/loading_elements.vmt` - UI element materials

## Integration

### Resource Loading Integration

The loading screen automatically integrates with the resource loading system:

1. **Models Loading**: 0-25% progress
2. **Sounds Loading**: 25-50% progress  
3. **Materials Loading**: 50-75% progress
4. **Effects Loading**: 75-100% progress

### Automatic Display

- Loading screen shows automatically when the addon initializes
- Progress updates in real-time during resource loading
- Automatically hides when loading is complete
- 2-second delay before hiding for user feedback

## Technical Details

### Loading Screen Architecture

```lua
ASC.LoadingScreen = {
    State = {
        Active = false,
        Progress = 0,
        Stage = "Initializing...",
        Resources = { Models, Materials, Sounds, Effects },
        Animations = { ProgressBar, TextFade, ParticleTime }
    },
    Config = {
        EnableAnimations = true,
        EnableParticles = true,
        Colors = { ... },
        Layout = { ... }
    }
}
```

### Theme System Architecture

```lua
ASC.CharacterTheme = {
    Config = { Colors, Fonts, Features },
    State = { Animations, PlayerModelMenuOpen, SpaceSuitMode },
    PlayerModels = { SpaceMarine, Pilot, Engineer, Commander, Scientist }
}

ASC.HUDTheme = {
    Config = { Colors, Layout, Features },
    State = { Health, Armor, Ammo, Animations },
    UpdateInterval = 0.1 // 10 FPS for smooth animations
}
```

## Performance Considerations

- **Optimized Updates**: HUD updates at 10 FPS for smooth animations without performance impact
- **Conditional Rendering**: Elements only draw when enabled via ConVars
- **Efficient Animations**: Lerp-based animations for smooth transitions
- **Resource Management**: Materials are precached and reused

## Accessibility Features

- **High Contrast Mode**: Available through existing accessibility system
- **Scalable Elements**: HUD scale factor for different screen sizes
- **Color Blind Friendly**: Alternative color schemes available
- **Reduced Motion**: Option to disable animations

## Future Enhancements

- **Custom Loading Screen Backgrounds**: Support for different space environments
- **More Character Models**: Additional space-themed player models
- **Advanced HUD Elements**: Minimap, radar, and tactical displays
- **Sound Integration**: Enhanced audio feedback for UI interactions
- **Localization**: Multi-language support for UI text

## Troubleshooting

### Loading Screen Not Showing
1. Check if `ASC.LoadingScreen` exists in console
2. Verify resource loading is enabled
3. Use `asc_test_loading` to test manually

### Theme Not Applied
1. Check ConVar settings
2. Verify client-side files are loaded
3. Check console for error messages

### VGUI Theme Errors
**Symptoms**: Errors like "attempt to index field 'btnClose' (a nil value)"
**Solutions**:
1. VGUI theming is disabled by default for safety
2. Enable carefully: `asc_vgui_theme_enabled 1`
3. If errors occur, reset: `asc_vgui_reset_errors`
4. Check status: `asc_vgui_status`
5. Disable if problematic: `asc_vgui_theme_enabled 0`

**Error Protection Features**:
- Automatic error counting and system disable after 5 errors
- Safe mode with pcall protection around all theming functions
- Fallback rendering when theming fails
- Console commands to reset and monitor system status

### HUD Theme Errors
**Symptoms**: Errors like "attempt to index global 'config' (a nil value)"
**Solutions**:
1. Check HUD status: `asc_hud_status`
2. Reset error tracking: `asc_hud_reset_errors`
3. Toggle HUD: `asc_toggle_hud`
4. Disable if problematic: `asc_hud_enabled 0`

**Error Protection Features**:
- Config existence checks in all drawing functions
- pcall protection around main HUD drawing
- Error rate limiting (max 1 error per 5 seconds in console)
- Graceful degradation when config is missing

### Performance Issues
1. Disable animations: `asc_hud_animations 0`
2. Reduce HUD scale: `asc_hud_scale 0.8`
3. Disable particles in loading screen
4. Disable VGUI theming: `asc_vgui_theme_enabled 0`

## Support

For issues or suggestions regarding the loading screen and theme system, please check the console output for error messages and verify all ConVar settings are correct.
