-- Advanced Space Combat v5.1.0 - Sound Definitions
-- Professional Lua-based sound system with Stargate technology integration
-- COMPLETE CODE UPDATE v5.1.0 - ALL SYSTEMS UPDATED, OPTIMIZED AND INTEGRATED

print("[Advanced Space Combat] Sound Definitions v5.1.0 - Ultimate Edition Loading...")

-- Initialize sound definitions namespace
ASC = ASC or {}
ASC.SoundDefs = ASC.SoundDefs or {}

-- Sound definition structure
ASC.SoundDefs.Sounds = {
    -- Ancient Technology Sounds (Tier 10)
    Ancient = {
        weapons = {
            drone_fire = {
                path = "asc/weapons/ancient_drone_fire.wav",
                channel = CHAN_WEAPON,
                volume = 0.8,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            },
            drone_impact = {
                path = "asc/weapons/ancient_drone_impact.wav",
                channel = CHAN_STATIC,
                volume = 0.7,
                pitch = 100,
                level = SNDLVL_NORM
            },
            drone_explode = {
                path = "asc/weapons/ancient_drone_explode.wav",
                channel = CHAN_STATIC,
                volume = 0.6,
                pitch = 100,
                level = SNDLVL_NORM
            },
            explosion = {
                path = "asc/weapons/ancient_explosion.wav",
                channel = CHAN_STATIC,
                volume = 1.0,
                pitch = 100,
                level = SNDLVL_120dB
            }
        },
        technology = {
            zpm_activate = {
                path = "asc/ancient/zpm_activate.wav",
                channel = CHAN_STATIC,
                volume = 0.8,
                pitch = 100,
                level = SNDLVL_NORM
            },
            zpm_hum = {
                path = "asc/ancient/zpm_hum.wav",
                channel = CHAN_STATIC,
                volume = 0.3,
                pitch = 100,
                level = SNDLVL_IDLE
            },
            control_chair_activate = {
                path = "asc/ancient/control_chair_activate.wav",
                channel = CHAN_STATIC,
                volume = 0.7,
                pitch = 100,
                level = SNDLVL_NORM
            }
        },
        shields = {
            activate = {
                path = "asc/shields/ancient_activate.wav",
                channel = CHAN_STATIC,
                volume = 0.7,
                pitch = 100,
                level = SNDLVL_NORM
            },
            hit = {
                path = "asc/shields/ancient_hit.wav",
                channel = CHAN_STATIC,
                volume = 0.6,
                pitch = 100,
                level = SNDLVL_NORM
            }
        }
    },
    
    -- Asgard Technology Sounds (Tier 8)
    Asgard = {
        weapons = {
            ion_fire = {
                path = "asc/weapons/asgard_ion_fire.wav",
                channel = CHAN_WEAPON,
                volume = 0.9,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            },
            plasma_fire = {
                path = "asc/weapons/asgard_plasma_fire.wav",
                channel = CHAN_WEAPON,
                volume = 0.8,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            },
            beam = {
                path = "asc/weapons/asgard_beam.wav",
                channel = CHAN_WEAPON,
                volume = 0.7,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            }
        },
        shields = {
            activate = {
                path = "asc/shields/asgard_activate.wav",
                channel = CHAN_STATIC,
                volume = 0.7,
                pitch = 100,
                level = SNDLVL_NORM
            }
        }
    },
    
    -- Goa'uld Technology Sounds (Tier 5)
    Goauld = {
        weapons = {
            staff_fire = {
                path = "asc/weapons/goauld_staff_fire.wav",
                channel = CHAN_WEAPON,
                volume = 0.8,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            },
            ribbon_fire = {
                path = "asc/weapons/goauld_ribbon_fire.wav",
                channel = CHAN_WEAPON,
                volume = 0.6,
                pitch = 100,
                level = SNDLVL_TALKING
            },
            hand_device = {
                path = "asc/weapons/goauld_hand_device.wav",
                channel = CHAN_WEAPON,
                volume = 0.7,
                pitch = 100,
                level = SNDLVL_TALKING
            }
        },
        shields = {
            activate = {
                path = "asc/shields/goauld_activate.wav",
                channel = CHAN_STATIC,
                volume = 0.6,
                pitch = 100,
                level = SNDLVL_NORM
            }
        }
    },
    
    -- Wraith Technology Sounds (Tier 6)
    Wraith = {
        weapons = {
            dart_fire = {
                path = "asc/weapons/wraith_dart_fire.wav",
                channel = CHAN_WEAPON,
                volume = 0.8,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            },
            culling_beam = {
                path = "asc/weapons/wraith_culling_beam.wav",
                channel = CHAN_WEAPON,
                volume = 0.9,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            }
        }
    },
    
    -- Ori Technology Sounds (Tier 9)
    Ori = {
        weapons = {
            pulse_fire = {
                path = "asc/weapons/ori_pulse_fire.wav",
                channel = CHAN_WEAPON,
                volume = 0.9,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            },
            beam_fire = {
                path = "asc/weapons/ori_beam_fire.wav",
                channel = CHAN_WEAPON,
                volume = 0.8,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            },
            satellite_fire = {
                path = "asc/weapons/ori_satellite_fire.wav",
                channel = CHAN_WEAPON,
                volume = 1.0,
                pitch = 100,
                level = SNDLVL_120dB
            }
        }
    },
    
    -- Tau'ri Technology Sounds (Tier 3)
    Tauri = {
        weapons = {
            railgun_fire = {
                path = "asc/weapons/tauri_railgun_fire.wav",
                channel = CHAN_WEAPON,
                volume = 0.9,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            },
            nuke_launch = {
                path = "asc/weapons/tauri_nuke_launch.wav",
                channel = CHAN_WEAPON,
                volume = 0.8,
                pitch = 100,
                level = SNDLVL_GUNFIRE
            },
            nuke_explode = {
                path = "asc/weapons/tauri_nuke_explode.wav",
                channel = CHAN_STATIC,
                volume = 1.0,
                pitch = 100,
                level = SNDLVL_120dB
            }
        }
    },
    
    -- Generic Weapon Sounds
    Weapons = {
        pulse_cannon_fire = {
            path = "asc/weapons/pulse_cannon_fire.wav",
            channel = CHAN_WEAPON,
            volume = 0.8,
            pitch = 100,
            level = SNDLVL_GUNFIRE
        },
        beam_weapon_charge = {
            path = "asc/weapons/beam_weapon_charge.wav",
            channel = CHAN_WEAPON,
            volume = 0.7,
            pitch = 100,
            level = SNDLVL_NORM
        },
        beam_weapon_fire = {
            path = "asc/weapons/beam_weapon_fire.wav",
            channel = CHAN_WEAPON,
            volume = 0.8,
            pitch = 100,
            level = SNDLVL_GUNFIRE
        },
        torpedo_launch = {
            path = "asc/weapons/torpedo_launch.wav",
            channel = CHAN_WEAPON,
            volume = 0.7,
            pitch = 100,
            level = SNDLVL_GUNFIRE
        },
        plasma_cannon_fire = {
            path = "asc/weapons/plasma_cannon_fire.wav",
            channel = CHAN_WEAPON,
            volume = 0.9,
            pitch = 100,
            level = SNDLVL_GUNFIRE
        },
        railgun_fire = {
            path = "asc/weapons/railgun_fire.wav",
            channel = CHAN_WEAPON,
            volume = 0.9,
            pitch = 100,
            level = SNDLVL_GUNFIRE
        }
    },
    
    -- Engine Sounds
    Engines = {
        hyperdrive_charge = {
            path = "asc/engines/hyperdrive_charge.wav",
            channel = CHAN_STATIC,
            volume = 0.8,
            pitch = 100,
            level = SNDLVL_NORM
        },
        hyperdrive_jump = {
            path = "asc/engines/hyperdrive_jump.wav",
            channel = CHAN_STATIC,
            volume = 1.0,
            pitch = 100,
            level = SNDLVL_120dB
        },
        ancient_hyperdrive = {
            path = "asc/engines/ancient_hyperdrive.wav",
            channel = CHAN_STATIC,
            volume = 0.9,
            pitch = 100,
            level = SNDLVL_NORM
        },
        engine_idle = {
            path = "asc/engines/engine_idle.wav",
            channel = CHAN_STATIC,
            volume = 0.4,
            pitch = 100,
            level = SNDLVL_IDLE
        },
        engine_thrust = {
            path = "asc/engines/engine_thrust.wav",
            channel = CHAN_STATIC,
            volume = 0.7,
            pitch = 100,
            level = SNDLVL_NORM
        }
    },
    
    -- UI Sounds
    UI = {
        button_click = {
            path = "asc/ui/button_click.wav",
            channel = CHAN_STATIC,
            volume = 0.5,
            pitch = 100,
            level = SNDLVL_TALKING
        },
        interface_open = {
            path = "asc/ui/interface_open.wav",
            channel = CHAN_STATIC,
            volume = 0.6,
            pitch = 100,
            level = SNDLVL_TALKING
        },
        notification = {
            path = "asc/ui/notification.wav",
            channel = CHAN_STATIC,
            volume = 0.4,
            pitch = 100,
            level = SNDLVL_TALKING
        },
        error = {
            path = "asc/ui/error.wav",
            channel = CHAN_STATIC,
            volume = 0.6,
            pitch = 100,
            level = SNDLVL_TALKING
        },
        success = {
            path = "asc/ui/success.wav",
            channel = CHAN_STATIC,
            volume = 0.5,
            pitch = 100,
            level = SNDLVL_TALKING
        }
    },
    
    -- ARIA-2 AI Sounds
    AI = {
        response = {
            path = "asc/ai/aria_response.wav",
            channel = CHAN_VOICE,
            volume = 0.6,
            pitch = 100,
            level = SNDLVL_TALKING
        },
        notification = {
            path = "asc/ai/aria_notification.wav",
            channel = CHAN_STATIC,
            volume = 0.5,
            pitch = 100,
            level = SNDLVL_TALKING
        },
        startup = {
            path = "asc/ai/aria_startup.wav",
            channel = CHAN_VOICE,
            volume = 0.7,
            pitch = 100,
            level = SNDLVL_TALKING
        },
        help = {
            path = "asc/ai/aria_help.wav",
            channel = CHAN_VOICE,
            volume = 0.6,
            pitch = 100,
            level = SNDLVL_TALKING
        }
    }
}

-- Sound registration function
function ASC.SoundDefs.RegisterSounds()
    print("[Advanced Space Combat] Registering sound definitions...")
    
    local soundCount = 0
    
    -- Register all sounds for precaching
    for category, sounds in pairs(ASC.SoundDefs.Sounds) do
        for subcategory, subsounds in pairs(sounds) do
            if type(subsounds) == "table" and subsounds.path then
                -- Direct sound definition
                util.PrecacheSound(subsounds.path)
                soundCount = soundCount + 1
            else
                -- Nested sound definitions
                for soundName, soundDef in pairs(subsounds) do
                    if soundDef.path then
                        util.PrecacheSound(soundDef.path)
                        soundCount = soundCount + 1
                    end
                end
            end
        end
    end
    
    print("[Advanced Space Combat] Registered " .. soundCount .. " sound definitions")
end

-- Get sound definition function
function ASC.SoundDefs.GetSound(category, subcategory, soundName)
    if not ASC.SoundDefs.Sounds[category] then return nil end
    
    if soundName then
        -- Three-level lookup (category.subcategory.soundName)
        if ASC.SoundDefs.Sounds[category][subcategory] and ASC.SoundDefs.Sounds[category][subcategory][soundName] then
            return ASC.SoundDefs.Sounds[category][subcategory][soundName]
        end
    else
        -- Two-level lookup (category.subcategory)
        if ASC.SoundDefs.Sounds[category][subcategory] then
            return ASC.SoundDefs.Sounds[category][subcategory]
        end
    end
    
    return nil
end

-- Play sound with definition
function ASC.SoundDefs.PlaySound(category, subcategory, soundName, entity, volumeMultiplier, pitchMultiplier)
    local soundDef = ASC.SoundDefs.GetSound(category, subcategory, soundName)
    if not soundDef then return false end
    
    local volume = (soundDef.volume or 1.0) * (volumeMultiplier or 1.0)
    local pitch = (soundDef.pitch or 100) * (pitchMultiplier or 1.0)
    
    if IsValid(entity) then
        entity:EmitSound(soundDef.path, soundDef.level or SNDLVL_NORM, pitch, volume, soundDef.channel or CHAN_AUTO)
    else
        sound.Play(soundDef.path, Vector(0, 0, 0), soundDef.level or SNDLVL_NORM, pitch, volume)
    end
    
    return true
end

-- Initialize sound definitions
hook.Add("Initialize", "ASC_SoundDefinitions", function()
    ASC.SoundDefs.RegisterSounds()
    print("[Advanced Space Combat] Sound Definitions system initialized")
end)

print("[Advanced Space Combat] Sound Definitions loaded successfully!")
