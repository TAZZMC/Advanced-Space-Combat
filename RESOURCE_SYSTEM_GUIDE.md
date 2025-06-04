# 🔋 ASC Ship Core Resource System - Complete Guide

## 📋 Overview

The Advanced Space Combat ship core features a comprehensive resource management system that provides energy, life support, and ship operations. The system works in two modes:

- **🚀 Spacebuild 3 Integration Mode** - Full integration with Spacebuild 3 resource systems
- **⚡ Enhanced Basic Mode** - Standalone resource system when Spacebuild 3 is not available

---

## 🔧 Resource Types

### **Primary Resources**

| Resource | Purpose | Regeneration | Color |
|----------|---------|--------------|-------|
| **⚡ Energy** | Powers all ship systems | ✅ Yes | 🟡 Yellow |
| **🫁 Oxygen** | Life support for players | ✅ Yes | 🔵 Cyan |
| **❄️ Coolant** | System cooling | ✅ Yes | 🟢 Green |
| **⛽ Fuel** | Propulsion systems | ❌ No | 🟠 Orange |
| **💧 Water** | Life support backup | ✅ Yes | 🔵 Blue |
| **🌪️ Nitrogen** | Atmosphere regulation | ✅ Yes | ⚪ White |

---

## 🎮 Basic Usage

### **1. Automatic Operation**
- Ship core automatically manages resources
- Life support activates when players are nearby
- Resources regenerate based on ship size
- Emergency alerts when resources are low

### **2. Manual Control**
```bash
asc_resource_status          # Check resource levels
asc_distribute_resources     # Distribute to ship entities
asc_collect_resources        # Collect from ship entities
asc_balance_resources        # Auto-balance resources
```

### **3. Emergency Controls**
```bash
asc_emergency_shutdown       # Emergency resource shutdown
```

---

## ⚙️ Advanced Features

### **🔄 Smart Resource Scaling**
- **Small Ships**: Fast regeneration, lower capacity
- **Large Ships**: High capacity, slower regeneration
- **Automatic Scaling**: Based on ship entity count

### **🫁 Life Support System**
- **Range**: 1000-2000 units from ship core
- **Effects**: Healing, oxygen supply, temperature regulation
- **Requirements**: Oxygen resources must be available
- **Status**: Players get life support indicators

### **📊 Real-Time Monitoring**
- Live resource level updates
- Emergency mode detection
- Player count tracking
- System performance metrics

---

## 🔌 Wire Integration

### **📥 Wire Inputs**
```
Resource Management:
- AddEnergy, AddOxygen, AddCoolant, AddFuel, AddWater, AddNitrogen
- DistributeResources, CollectResources, BalanceResources
- ToggleLifeSupport, EmergencyResourceShutdown

System Control:
- RepairHull, ActivateShields, DeactivateShields
- Recalculate, Mute
```

### **📤 Wire Outputs**
```
Resource Levels:
- EnergyLevel, OxygenLevel, CoolantLevel, FuelLevel, WaterLevel, NitrogenLevel

Resource Capacities:
- EnergyCapacity, OxygenCapacity, CoolantCapacity, FuelCapacity, WaterCapacity, NitrogenCapacity

Resource Percentages:
- EnergyPercent, OxygenPercent, CoolantPercent, FuelPercent, WaterPercent, NitrogenPercent

System Status:
- ResourceEmergency, ResourceSystemActive, LifeSupportActive
- TotalResourceCapacity, TotalResourceAmount, PlayersSupported
```

---

## 🛠️ Admin Commands

### **Resource Management (Superadmin Only)**
```bash
asc_add_resource <type> <amount>     # Add resources
asc_remove_resource <type> <amount>  # Remove resources
asc_fill_resources                   # Fill all to capacity

# Examples:
asc_add_resource energy 500
asc_add_resource oxygen 200
asc_fill_resources
```

### **System Diagnostics**
```bash
asc_resource_help                    # Show all commands
asc_resource_status                  # Detailed status report
```

---

## 🔧 Configuration

### **Spacebuild 3 Integration**
When Spacebuild 3 is available:
- Full RD (Resource Distribution) system integration
- LS2 (Life Support 2) compatibility
- CAF (Custom Addon Framework) support
- Automatic entity detection and linking

### **Enhanced Basic Mode**
When Spacebuild 3 is not available:
- Standalone resource management
- Built-in life support system
- Smart regeneration based on ship size
- Emergency protocols

---

## 📊 Resource Scaling Formula

### **Capacity Scaling**
```
Base Capacity × Ship Size Multiplier
Ship Size Multiplier = max(0.5, min(2.0, EntityCount / 50))
```

### **Regeneration Scaling**
```
Base Regeneration × (2.0 - Size Multiplier)
Small ships: Fast regen, low capacity
Large ships: Slow regen, high capacity
```

---

## ⚠️ Emergency Protocols

### **Automatic Emergency Mode**
Triggers when:
- 2+ resource types below 25%
- Life support oxygen depleted
- System malfunction detected

### **Emergency Effects**
- Resource regeneration stops
- Life support deactivated
- Emergency alerts to all players
- System status changes to emergency

### **Recovery**
- Add resources manually
- Use `asc_fill_resources` (admin)
- Restart ship core
- Use wire inputs to restore

---

## 🔍 Troubleshooting

### **Resources Not Regenerating**
1. Check if emergency mode is active
2. Verify ship core is not damaged
3. Ensure ship is properly detected
4. Use `asc_resource_status` for diagnostics

### **Life Support Not Working**
1. Check oxygen levels (must be > 50)
2. Verify players are within range
3. Ensure life support is enabled
4. Check for emergency shutdown

### **Spacebuild Integration Issues**
1. Verify Spacebuild 3 is installed
2. Check RD system compatibility
3. Use basic mode as fallback
4. Restart ship core system

---

## 🎯 Best Practices

### **Ship Design**
- Place ship core centrally
- Keep all entities within 2000 units
- Add multiple resource sources
- Plan for emergency scenarios

### **Resource Management**
- Monitor levels regularly
- Set up wire automation
- Plan fuel consumption
- Maintain oxygen reserves

### **Performance**
- Avoid oversized ships
- Use efficient designs
- Monitor system performance
- Regular maintenance checks

---

## 📈 Performance Metrics

The system tracks:
- Resource consumption rates
- Distribution efficiency
- Life support coverage
- System response times
- Emergency incidents

Access via `asc_resource_status` command or wire outputs.

---

**🎉 The ASC Ship Core Resource System provides comprehensive ship management with intelligent scaling, emergency protocols, and seamless integration!** 🚀
