# Contributing to Hyperdrive System

Thank you for your interest in contributing to the Hyperdrive System! This document provides guidelines and information for contributors.

## Table of Contents
1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [Contribution Guidelines](#contribution-guidelines)
4. [Code Standards](#code-standards)
5. [Testing](#testing)
6. [Documentation](#documentation)
7. [Pull Request Process](#pull-request-process)
8. [Issue Reporting](#issue-reporting)
9. [Community Guidelines](#community-guidelines)
10. [Recognition](#recognition)

## Getting Started

### Ways to Contribute
- **Code Contributions**: Bug fixes, new features, optimizations
- **Documentation**: Improve guides, add examples, fix typos
- **Testing**: Report bugs, test new features, performance testing
- **Integration**: Add support for new addons
- **Localization**: Translate interface and documentation
- **Community Support**: Help other users, answer questions

### Prerequisites
- **Garry's Mod**: Latest version installed
- **Git**: Version control system
- **Text Editor**: VS Code, Sublime Text, or similar
- **Basic Lua Knowledge**: Understanding of Lua scripting
- **Addon Development**: Familiarity with GMod addon structure

## Development Setup

### 1. Fork and Clone
```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/yourusername/hyperdrive-addon.git
cd hyperdrive-addon
```

### 2. Development Environment
```bash
# Create symbolic link to GMod addons folder (Windows)
mklink /D "C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod\addons\hyperdrive-dev" "C:\path\to\your\clone"

# Or copy files for testing
cp -r . "path/to/garrysmod/addons/hyperdrive-dev/"
```

### 3. Testing Setup
```bash
# Enable debug mode
hyperdrive_debug 1

# Load test environment
hyperdrive_test_environment
```

### 4. Required Tools
- **Lua Language Server**: For code completion and error checking
- **GMod Lua Formatter**: For consistent code formatting
- **Git Hooks**: Pre-commit hooks for code quality

## Contribution Guidelines

### Types of Contributions

#### Bug Fixes
- **Small Fixes**: Typos, minor logic errors, simple optimizations
- **Major Fixes**: System-breaking bugs, performance issues, security vulnerabilities
- **Integration Fixes**: Compatibility issues with other addons

#### New Features
- **Core Features**: New engine types, navigation systems, effects
- **Integration Features**: Support for new addons
- **Quality of Life**: User interface improvements, convenience features
- **Performance Features**: Optimization systems, monitoring tools

#### Documentation
- **User Documentation**: Guides, tutorials, examples
- **Technical Documentation**: API references, architecture docs
- **Code Documentation**: Inline comments, function documentation
- **Translation**: Localization for different languages

### Contribution Process
1. **Check Existing Issues**: Look for related issues or feature requests
2. **Create Issue**: Discuss your idea before starting work
3. **Fork Repository**: Create your own copy for development
4. **Create Branch**: Use descriptive branch names
5. **Develop**: Write code following our standards
6. **Test**: Thoroughly test your changes
7. **Document**: Update documentation as needed
8. **Submit PR**: Create pull request with detailed description

## Code Standards

### Lua Style Guide

#### Naming Conventions
```lua
-- Variables: camelCase
local energyLevel = 100
local maxDistance = 5000

-- Constants: UPPER_SNAKE_CASE
local MAX_ENGINES = 100
local DEFAULT_ENERGY = 1000

-- Functions: PascalCase for global, camelCase for local
function HYPERDRIVE.CalculateDistance(pos1, pos2)
    -- Global function
end

local function calculateEnergy(distance)
    -- Local function
end

-- Tables: PascalCase
HYPERDRIVE.Config = {}
HYPERDRIVE.Effects = {}
```

#### Code Structure
```lua
-- File header with description
-- Hyperdrive Engine Entity - Core functionality
-- Handles energy management and jump operations

-- Namespace check
if not HYPERDRIVE then return end

-- Local variables
local math = math
local table = table
local util = util

-- Configuration
local CONFIG = {
    maxEnergy = 1000,
    chargeRate = 10
}

-- Main implementation
function HYPERDRIVE.Engine.Initialize(ent)
    -- Function implementation
end
```

#### Error Handling
```lua
-- Always validate inputs
function HYPERDRIVE.SetDestination(engine, pos)
    if not IsValid(engine) then
        return false, "Invalid engine entity"
    end
    
    if not isvector(pos) then
        return false, "Invalid position vector"
    end
    
    -- Implementation
    return true, "Destination set successfully"
end

-- Use pcall for risky operations
local success, result = pcall(function()
    return HYPERDRIVE.ComplexOperation(data)
end)

if not success then
    print("[Hyperdrive] Error:", result)
    return false
end
```

### Performance Guidelines

#### Optimization Principles
```lua
-- Cache frequently used values
local CurTime = CurTime
local IsValid = IsValid

-- Avoid repeated calculations
local distance = pos1:Distance(pos2)
local energyCost = distance * ENERGY_MULTIPLIER

-- Use efficient data structures
local entityCache = {}  -- Better than repeated ents.FindByClass

-- Limit expensive operations
if CurTime() - lastUpdate > UPDATE_INTERVAL then
    -- Expensive operation
    lastUpdate = CurTime()
end
```

#### Memory Management
```lua
-- Clean up timers
timer.Remove("hyperdrive_" .. self:EntIndex())

-- Remove hooks
hook.Remove("Think", "Hyperdrive_" .. self:EntIndex())

-- Clear references
self.LinkedEntities = nil
self.EffectData = nil
```

### Integration Standards

#### Integration Template
```lua
-- Integration check
if not ADDON_NAMESPACE then return end

-- Integration namespace
HYPERDRIVE.AddonName = HYPERDRIVE.AddonName or {}

-- Configuration
local function GetConfig(key, default)
    return HYPERDRIVE.EnhancedConfig.Get("AddonName", key, default)
end

-- Integration functions
function HYPERDRIVE.AddonName.Initialize()
    -- Setup integration
end

function HYPERDRIVE.AddonName.IsLoaded()
    return ADDON_NAMESPACE ~= nil
end

-- Register integration
if HYPERDRIVE.EnhancedConfig then
    HYPERDRIVE.EnhancedConfig.RegisterIntegration("AddonName", {
        name = "Addon Display Name",
        version = "1.0.0",
        checkFunction = HYPERDRIVE.AddonName.IsLoaded
    })
end
```

## Testing

### Testing Requirements
- **Functionality Testing**: All features work as expected
- **Integration Testing**: Compatible with target addons
- **Performance Testing**: No significant performance degradation
- **Error Testing**: Graceful handling of error conditions

### Test Environment Setup
```lua
-- Enable debug mode
hyperdrive_debug 1

-- Create test entities
local engine = ents.Create("hyperdrive_engine")
engine:Spawn()

-- Test basic functionality
engine:SetDestinationPos(Vector(1000, 0, 0))
engine:SetEnergy(1000)
local success = engine:StartJump()

-- Verify results
assert(success, "Jump should succeed with valid parameters")
```

### Performance Testing
```lua
-- Measure performance impact
local startTime = SysTime()
-- Your code here
local endTime = SysTime()
print("Operation took:", (endTime - startTime) * 1000, "ms")

-- Memory usage testing
collectgarbage("collect")
local memBefore = collectgarbage("count")
-- Your code here
collectgarbage("collect")
local memAfter = collectgarbage("count")
print("Memory used:", memAfter - memBefore, "KB")
```

### Integration Testing
```lua
-- Test with different addon combinations
local integrations = {
    "SpaceCombat2",
    "Spacebuild3", 
    "Wiremod",
    "CAP"
}

for _, integration in ipairs(integrations) do
    if HYPERDRIVE[integration] and HYPERDRIVE[integration].IsLoaded() then
        -- Test integration functionality
        print("Testing", integration, "integration")
        -- Integration-specific tests
    end
end
```

## Documentation

### Code Documentation
```lua
--- Calculates energy cost for hyperdrive jump
-- @param distance Number The distance to travel
-- @param shipType Table Ship classification data
-- @param modifiers Table Optional energy modifiers
-- @return Number Energy cost in units
-- @return String Status message
function HYPERDRIVE.CalculateEnergyCost(distance, shipType, modifiers)
    -- Implementation
end
```

### User Documentation
- **Clear Examples**: Provide working code examples
- **Step-by-Step**: Break complex procedures into steps
- **Screenshots**: Include visual aids where helpful
- **Common Issues**: Document known problems and solutions

### API Documentation
- **Function Signatures**: Complete parameter and return information
- **Usage Examples**: Show how to use each function
- **Integration Points**: Document how systems interact
- **Event Hooks**: List all available hooks and their parameters

## Pull Request Process

### Before Submitting
1. **Test Thoroughly**: Ensure your changes work correctly
2. **Update Documentation**: Include relevant documentation updates
3. **Follow Standards**: Adhere to code style guidelines
4. **Check Compatibility**: Test with different addon combinations
5. **Performance Check**: Verify no performance regressions

### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Performance improvement
- [ ] Documentation update
- [ ] Integration addition

## Testing
- [ ] Tested in single-player
- [ ] Tested on dedicated server
- [ ] Tested with integrations
- [ ] Performance tested

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No breaking changes
```

### Review Process
1. **Automated Checks**: Code style and basic functionality
2. **Maintainer Review**: Code quality and design review
3. **Community Testing**: Beta testing with community feedback
4. **Final Approval**: Merge approval from maintainers

## Issue Reporting

### Bug Reports
```markdown
**Bug Description**
Clear description of the bug

**Steps to Reproduce**
1. Step one
2. Step two
3. Step three

**Expected Behavior**
What should happen

**Actual Behavior**
What actually happens

**Environment**
- Garry's Mod version:
- Server/Client:
- Other addons:
- Console errors:
```

### Feature Requests
```markdown
**Feature Description**
Clear description of the requested feature

**Use Case**
Why this feature would be useful

**Proposed Implementation**
Ideas for how it could be implemented

**Alternatives**
Other ways to achieve the same goal
```

## Community Guidelines

### Code of Conduct
- **Be Respectful**: Treat all contributors with respect
- **Be Constructive**: Provide helpful feedback and suggestions
- **Be Patient**: Remember that everyone is learning
- **Be Inclusive**: Welcome contributors of all skill levels

### Communication
- **GitHub Issues**: Technical discussions and bug reports
- **Pull Requests**: Code review and implementation discussion
- **Discord**: Real-time community chat and support
- **Steam Workshop**: User feedback and general discussion

## Recognition

### Contributor Recognition
- **Contributors List**: All contributors listed in README
- **Changelog Credits**: Major contributions credited in changelog
- **Special Thanks**: Outstanding contributors recognized specially
- **Maintainer Status**: Active contributors may become maintainers

### Types of Recognition
- **Code Contributors**: Bug fixes, features, optimizations
- **Documentation Contributors**: Guides, examples, translations
- **Community Contributors**: Support, testing, feedback
- **Integration Contributors**: New addon integrations

---

Thank you for contributing to the Hyperdrive System! Your contributions help make space travel in Garry's Mod more exciting and accessible for everyone.
