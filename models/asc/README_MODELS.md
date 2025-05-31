# Advanced Space Combat - Model Files

## Model Directory Structure

```
models/asc/
├── ship_core/
│   ├── ship_core.mdl
│   ├── ship_core.phy
│   ├── ship_core.vvd
│   └── ship_core.vtx
├── weapons/
│   ├── pulse_cannon.mdl
│   ├── beam_weapon.mdl
│   ├── torpedo_launcher.mdl
│   ├── railgun.mdl
│   └── plasma_cannon.mdl
├── engines/
│   ├── hyperdrive_engine.mdl
│   ├── master_hyperdrive_engine.mdl
│   └── flight_console.mdl
├── shields/
│   └── shield_generator.mdl
├── transport/
│   ├── docking_pad_small.mdl
│   ├── docking_pad_medium.mdl
│   ├── docking_pad_large.mdl
│   ├── docking_pad_shuttle.mdl
│   ├── docking_pad_cargo.mdl
│   └── shuttle.mdl
├── ancient/
│   ├── zpm.mdl
│   ├── control_chair.mdl
│   ├── stargate.mdl
│   ├── drone_weapon.mdl
│   ├── defense_satellite.mdl
│   ├── city_shield_generator.mdl
│   ├── time_dilation_device.mdl
│   └── healing_device.mdl
├── asgard/
│   ├── ion_cannon.mdl
│   ├── plasma_beam.mdl
│   ├── shield_generator.mdl
│   ├── computer_core.mdl
│   ├── beaming_device.mdl
│   ├── cloning_facility.mdl
│   ├── hologram_projector.mdl
│   └── time_device.mdl
├── goauld/
│   ├── staff_cannon.mdl
│   ├── hand_device.mdl
│   ├── ribbon_device.mdl
│   ├── shield_generator.mdl
│   ├── sarcophagus.mdl
│   ├── ring_transporter.mdl
│   ├── naquadah_reactor.mdl
│   └── cloaking_device.mdl
├── wraith/
│   ├── dart_weapon.mdl
│   ├── culling_beam.mdl
│   ├── hive_shield.mdl
│   ├── life_pod.mdl
│   ├── enzyme_extractor.mdl
│   ├── regeneration_chamber.mdl
│   └── hive_mind_interface.mdl
├── ori/
│   ├── pulse_weapon.mdl
│   ├── beam_weapon.mdl
│   ├── shield_generator.mdl
│   ├── supergate.mdl
│   ├── prior_staff.mdl
│   └── satellite_weapon.mdl
└── tauri/
    ├── railgun.mdl
    ├── nuke_missile.mdl
    ├── shield_generator.mdl
    ├── f302_fighter.mdl
    ├── iris.mdl
    └── prometheus_engine.mdl
```

## Model Requirements

### Technical Specifications:
- **Format**: Source Engine MDL format
- **Polygon Count**: 500-5000 triangles (depending on entity type)
- **Texture Resolution**: 512x512 to 2048x2048
- **LOD Models**: Recommended for complex models
- **Collision Models**: Required for all physics entities

### Quality Standards:
- Clean topology with proper edge flow
- Appropriate polygon density for detail level
- Proper UV mapping without stretching
- Optimized for real-time rendering
- Consistent scale across similar entities

### Cultural Design Guidelines:

#### Ancient Technology:
- **Style**: Sleek, crystalline, ethereal
- **Materials**: Crystal, energy fields, smooth metals
- **Colors**: Blue, white, gold accents
- **Features**: Glowing elements, geometric patterns

#### Asgard Technology:
- **Style**: Minimalist, functional, advanced
- **Materials**: Smooth metals, holographic displays
- **Colors**: Gray, blue, white
- **Features**: Clean lines, technological precision

#### Goa'uld Technology:
- **Style**: Pyramid-based, intimidating, ornate
- **Materials**: Gold, bronze, dark metals
- **Colors**: Gold, bronze, red accents
- **Features**: Egyptian motifs, serpent designs

#### Wraith Technology:
- **Style**: Organic, bio-mechanical, unsettling
- **Materials**: Organic surfaces, bio-metal hybrids
- **Colors**: Dark green, purple, black
- **Features**: Organic curves, living textures

#### Ori Technology:
- **Style**: Massive, imposing, divine
- **Materials**: Stone, metal, energy
- **Colors**: White, gold, orange
- **Features**: Religious symbols, overwhelming scale

#### Tau'ri Technology:
- **Style**: Military, practical, familiar
- **Materials**: Steel, aluminum, composites
- **Colors**: Military gray, blue, black
- **Features**: Human engineering, modular design

## Model Creation Guidelines

### Ship Core:
- Central hub appearance
- Multiple connection points
- Holographic display elements
- Glowing energy core
- Size: ~100x100x50 units

### Weapons:
- Distinct silhouettes for each type
- Clear firing direction
- Mounting points for attachment
- Cultural design elements
- Size: 50x50x100 to 100x100x200 units

### Engines:
- Thrust vector indication
- Energy field effects
- Mounting hardware
- Cultural styling
- Size: 75x75x150 to 150x150x300 units

### Shields:
- Generator appearance
- Energy field projectors
- Control interfaces
- Cultural design
- Size: 50x50x75 to 100x100x150 units

## Placeholder Models

Until custom models are created, the following can be used:
- Modified existing GMod props
- Scaled and retextured HL2 models
- Simple primitive shapes with appropriate materials
- Community-created Stargate models (with permission)

## Model Optimization

### Performance Considerations:
- Keep polygon count reasonable for multiplayer
- Use LOD models for distant viewing
- Optimize collision meshes
- Compress textures appropriately
- Test performance impact in-game

### File Size Management:
- Use appropriate texture compression
- Remove unnecessary model data
- Optimize UV layouts
- Use shared textures where possible
- Consider model complexity vs. visual impact

## Animation Requirements

### Animated Elements:
- Rotating components (engines, reactors)
- Extending/retracting parts (weapons)
- Pulsing energy effects (cores, shields)
- Opening/closing mechanisms (docking pads)

### Animation Guidelines:
- Smooth, looping animations
- Appropriate timing for game feel
- Cultural consistency in movement
- Performance-optimized bone counts
- Clear visual feedback for states
