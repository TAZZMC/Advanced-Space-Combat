-- Hyperdrive Network Strings - Consolidated
-- This file contains all network string declarations to prevent duplicates

if CLIENT then return end

print("[Hyperdrive] Loading consolidated network strings...")

-- Core hyperdrive network strings
util.AddNetworkString("hyperdrive_jump")
util.AddNetworkString("hyperdrive_status")
util.AddNetworkString("hyperdrive_destination")
util.AddNetworkString("hyperdrive_open_interface")
util.AddNetworkString("hyperdrive_set_destination")
util.AddNetworkString("hyperdrive_start_jump")

-- Enhanced effects network strings
util.AddNetworkString("hyperdrive_effect")
util.AddNetworkString("hyperdrive_quantum_event")
util.AddNetworkString("hyperdrive_security_alert")
util.AddNetworkString("hyperdrive_navigation_update")

-- Hyperspace network strings
util.AddNetworkString("hyperdrive_hyperspace_effect")
util.AddNetworkString("hyperdrive_hyperspace_enter")
util.AddNetworkString("hyperdrive_hyperspace_exit")
util.AddNetworkString("hyperdrive_hyperspace_window")

-- Computer network strings
util.AddNetworkString("hyperdrive_computer")
util.AddNetworkString("hyperdrive_computer_mode")
util.AddNetworkString("hyperdrive_fleet_jump")
util.AddNetworkString("hyperdrive_manual_jump")
util.AddNetworkString("hyperdrive_save_waypoint")
util.AddNetworkString("hyperdrive_load_waypoint")
util.AddNetworkString("hyperdrive_delete_waypoint")
util.AddNetworkString("hyperdrive_emergency_abort")
util.AddNetworkString("hyperdrive_scan_planets")
util.AddNetworkString("hyperdrive_toggle_planet_detection")
util.AddNetworkString("hyperdrive_clear_planets")
util.AddNetworkString("hyperdrive_auto_link_planets")
util.AddNetworkString("hyperdrive_toggle_auto_link")
util.AddNetworkString("hyperdrive_quick_jump_planet")

-- Master engine network strings
util.AddNetworkString("hyperdrive_master_interface")

-- Beacon network strings
util.AddNetworkString("hyperdrive_beacon_config")
util.AddNetworkString("hyperdrive_beacon_update")
util.AddNetworkString("hyperdrive_beacon_pulse")
util.AddNetworkString("hyperdrive_beacon_list")

-- Stargate integration network strings
util.AddNetworkString("hyperdrive_sg_status")
util.AddNetworkString("hyperdrive_sg_network")
util.AddNetworkString("hyperdrive_sg_coordinates")
util.AddNetworkString("hyperdrive_sg_starlines")
util.AddNetworkString("hyperdrive_sg_stage_update")

-- Network optimization strings
util.AddNetworkString("hyperdrive_batch_movement")
util.AddNetworkString("hyperdrive_delta_update")
util.AddNetworkString("hyperdrive_priority_sync")
util.AddNetworkString("hyperdrive_compression_data")

-- Sound system network strings
util.AddNetworkString("hyperdrive_play_sound")
util.AddNetworkString("hyperdrive_play_sequence")
util.AddNetworkString("hyperdrive_stop_sound")
util.AddNetworkString("hyperdrive_ambient_sound")
util.AddNetworkString("hyperdrive_stargate_sound")
util.AddNetworkString("hyperdrive_beacon_sound")
util.AddNetworkString("hyperdrive_fleet_sound")

print("[Hyperdrive] Network strings loaded successfully")
