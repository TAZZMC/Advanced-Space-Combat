# Sound Integration Setup

## Manual Setup Required

The sound integration system has been created, but you need to manually copy the sound file to the correct location:

### Step 1: Copy Sound File
Copy the file from:
```
sond/ship_in_hyperspace.wav
```

To:
```
sound/hyperdrive/ship_in_hyperspace.wav
```

### Step 2: Verify Integration
The sound system is now integrated with:

1. **Custom Sound**: `ship_in_hyperspace.wav` for hyperspace travel
2. **Network Integration**: Server can trigger client sounds
3. **Enhanced Sound Functions**: Multiple sound sequences and effects
4. **Automatic Download**: Sound file will be downloaded to clients

## Sound Integration Features

### Custom Sounds Added
- `hyperspace_travel` - Main hyperspace travel sound
- `hyperspace_ambient` - Ambient hyperspace sound
- `sg_hyperspace` - Stargate hyperspace travel sound

### New Sound Functions

#### Client-Side (hyperdrive_sounds.lua)
- `HYPERDRIVE.Sounds.PlayStargateSequence()` - 4-stage Stargate travel
- `HYPERDRIVE.Sounds.PlayHyperspaceAmbient()` - Ambient hyperspace sound
- `HYPERDRIVE.Sounds.PlayBeaconSound()` - Beacon sounds
- `HYPERDRIVE.Sounds.PlayFleetSound()` - Fleet coordination sounds
- `HYPERDRIVE.Sounds.PlayEnhancedChargeSequence()` - Enhanced charging with completion

#### Server-Side (hyperdrive_sound_server.lua)
- `HYPERDRIVE.ServerSounds.JumpSequence()` - Trigger jump sounds
- `HYPERDRIVE.ServerSounds.StargateJump()` - Trigger Stargate sounds
- `HYPERDRIVE.ServerSounds.HyperspaceAmbient()` - Trigger ambient sounds
- `HYPERDRIVE.ServerSounds.FleetSync()` - Fleet coordination sounds
- `HYPERDRIVE.ServerSounds.BeaconPulse()` - Beacon pulse sounds

### Usage Examples

#### In Engine Code
```lua
-- When starting a jump
HYPERDRIVE.ServerSounds.EngineCharging(engine)

-- When jumping
HYPERDRIVE.ServerSounds.JumpSequence(engine, destination, "standard")

-- For Stargate travel
HYPERDRIVE.ServerSounds.StargateJump(engine, destination)

-- For hyperspace ambient
HYPERDRIVE.ServerSounds.HyperspaceAmbient(engine, 5.0)
```

#### In Computer Code
```lua
-- Computer feedback
HYPERDRIVE.ServerSounds.ComputerBeep(computer)
HYPERDRIVE.ServerSounds.ComputerConfirm(computer)
HYPERDRIVE.ServerSounds.ComputerError(computer)
```

#### In Beacon Code
```lua
-- Beacon pulse
HYPERDRIVE.ServerSounds.BeaconPulse(beacon)
```

### Network Messages
The following network messages are available:
- `hyperdrive_play_sound` - Play single sound
- `hyperdrive_play_sequence` - Play sound sequence
- `hyperdrive_stargate_sound` - Stargate sequence
- `hyperdrive_beacon_sound` - Beacon sounds
- `hyperdrive_fleet_sound` - Fleet sounds
- `hyperdrive_ambient_sound` - Ambient sounds
- `hyperdrive_stop_sound` - Stop sounds

### Sound Library Additions
The sound library now includes:
- **Custom Hyperdrive Sounds**: Using your `ship_in_hyperspace.wav`
- **Stargate 4-Stage Sounds**: Complete sequence for authentic experience
- **Beacon Sounds**: Pulse, activate, deactivate
- **Fleet Sounds**: Sync, ready, jump coordination
- **Enhanced Engine Sounds**: Startup, charging, completion
- **Computer Sounds**: Beep, error, confirm, startup, shutdown
- **Alert Sounds**: Warning, critical, success, low energy

## Testing Commands
Use these console commands to test sounds:
- `hyperdrive_test_sound hyperspace_travel` - Test hyperspace sound
- `hyperdrive_test_sound sg_hyperspace` - Test Stargate hyperspace
- `hyperdrive_list_sounds` - List all available sounds

## Integration Points
The sound system is automatically integrated with:
- Engine charging and jumping
- Stargate 4-stage travel system
- Beacon network operations
- Fleet coordination
- Computer interface feedback
- Alert and warning systems

After copying the sound file, restart your server to ensure proper integration.
