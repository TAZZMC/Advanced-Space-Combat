# Enhanced Hyperdrive System - Models Directory

## 📦 **Required Models for Enhanced Hyperdrive System**

This directory should contain the 3D models for the Enhanced Hyperdrive System entities. Since I cannot create actual .mdl files, here are the specifications for the required models:

## 🚀 **Ship Core Models**

### **1. Ship Core Main Model** (`ship_core.mdl`)
**Specifications:**
- **Size:** Approximately 64x64x32 units
- **Style:** Futuristic control console with holographic displays
- **Components:**
  - Central processing unit with glowing core
  - Holographic display panels (4 sides)
  - Control interface panels
  - Energy conduits and cables
  - Status indicator lights
  - Front orientation arrow/indicator

**Materials Needed:**
- `hyperdrive/ship_core_base` - Main hull material
- `hyperdrive/ship_core_glow` - Glowing core elements
- `hyperdrive/ship_core_hologram` - Holographic displays
- `hyperdrive/holographic_display` - Interface panels

### **2. Ship Core Hologram Model** (`ship_core_hologram.mdl`)
**Specifications:**
- **Size:** 32x32x48 units (floating above core)
- **Style:** Translucent holographic ship representation
- **Components:**
  - Basic ship outline
  - Animated data streams
  - Status indicators
  - Rotating elements

## 🛡️ **Shield Generator Models**

### **1. Shield Generator Main Model** (`shield_generator.mdl`)
**Specifications:**
- **Size:** Approximately 48x48x64 units
- **Style:** Cylindrical generator with energy coils
- **Components:**
  - Central energy core
  - Electromagnetic coils (3-4 rings)
  - Power coupling ports
  - Status display panel
  - Cooling vents
  - Mounting base

**Materials Needed:**
- `hyperdrive/shield_generator` - Main generator material
- `hyperdrive/energy_field` - Energy coil effects
- `hyperdrive/ship_core_glow` - Core glow elements

### **2. Shield Bubble Model** (`shield_bubble.mdl`)
**Specifications:**
- **Size:** Variable radius (100-500 units)
- **Style:** Translucent energy dome
- **Components:**
  - Spherical energy field
  - Hexagonal pattern overlay
  - Energy ripple effects
  - Impact distortion areas

## ⚡ **Effect Models**

### **1. Energy Beam Model** (`energy_beam.mdl`)
**Specifications:**
- **Size:** Variable length beam
- **Style:** Cylindrical energy beam with core and outer glow
- **Components:**
  - Inner energy core
  - Outer energy field
  - Particle effects
  - Pulsing animation

### **2. Holographic Interface Model** (`holographic_interface.mdl`)
**Specifications:**
- **Size:** 64x64x2 units (flat panel)
- **Style:** Translucent interface panel
- **Components:**
  - Text display areas
  - Button elements
  - Status indicators
  - Data visualization

## 🎨 **Model Creation Guidelines**

### **For 3D Artists:**
1. **Use Source Engine compatible formats** (.mdl, .vvd, .vtx, .phy)
2. **Include proper collision models** for interaction
3. **Add attachment points** for effects and sounds
4. **Use appropriate LOD levels** for performance
5. **Include proper UV mapping** for materials
6. **Add bone structure** for animated elements

### **Recommended Tools:**
- **Blender** with Source Engine export plugins
- **3ds Max** with Wall Worm plugin
- **Maya** with Source Engine tools
- **Crowbar** for model decompilation/compilation

### **Animation Requirements:**
- **Ship Core:** Rotating hologram, pulsing lights, data stream animations
- **Shield Generator:** Rotating coils, energy field fluctuations
- **Effects:** Beam pulsing, particle emission points

## 🔧 **Model Integration**

### **Entity Model Assignment:**
```lua
// Ship Core
ENT.Model = "models/hyperdrive/ship_core.mdl"

// Shield Generator  
ENT.Model = "models/hyperdrive/shield_generator.mdl"

// Effects
self:SetModel("models/hyperdrive/energy_beam.mdl")
```

### **Material Override:**
```lua
// Dynamic material changes
self:SetMaterial("hyperdrive/ship_core_glow")
self:SetColor(Color(100, 150, 255, 200))
```

## 📋 **Fallback Models**

Until custom models are created, the system uses these fallback models:
- **Ship Core:** `models/props_lab/monitor01b.mdl`
- **Shield Generator:** `models/props_combine/combine_generator01.mdl`
- **Effects:** Built-in Source Engine sprites and beams

## 🎯 **Priority Order**

1. **Ship Core Main Model** - Most important for gameplay
2. **Shield Generator Model** - Essential for shield system
3. **Shield Bubble Model** - Visual feedback for shields
4. **Holographic Models** - Enhanced visual appeal
5. **Effect Models** - Polish and immersion

## 📞 **Model Requests**

If you need custom models created, please provide:
- **Detailed specifications** and reference images
- **Size requirements** in Hammer units
- **Animation requirements** and bone structure needs
- **Material requirements** and UV layout preferences
- **Performance constraints** and LOD requirements

The Enhanced Hyperdrive System is designed to work with placeholder models initially and can be upgraded with custom models as they become available.

---

**Status:** 📋 **SPECIFICATIONS READY**  
**Models Created:** 🔄 **PENDING** (Specifications provided)  
**Fallbacks:** ✅ **ACTIVE** (Using Source Engine models)  
**Integration:** ✅ **READY** (Code supports custom models)
