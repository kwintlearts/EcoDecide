# event_bus.gd (Autoload)
extends Node

signal badge_unlocked(badge_name)
signal scenario_completed(scenario_id, tier)
signal item_disposed(item_name, correct, bin_type)
signal plush_toy_met
signal captain_helped
