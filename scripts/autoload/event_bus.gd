# event_bus.gd (Autoload)
extends Node

signal badge_unlocked(badge_name)
signal scenario_completed(scenario_id, tier)
signal item_disposed(item_name, correct, bin_type)
signal plush_toy_met
signal captain_helped
signal vendor_confronted  # Add this
signal scenario_started(scenario_id)  # Add this line
signal ripple_glow
signal npc_collected_battery(npc_name)
