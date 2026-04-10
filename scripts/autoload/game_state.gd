# GameState.gd
extends Node

# --- VISIBLE STATS ---
var eco_score: int = 0
var env_health: int = 50
var community_trust: int = 50
var energy: float = 100.0

# --- HIDDEN LOGIC STATS ---
var soil_health: int = 50
var waste_generated: int = 0
var correct_disposals: int = 0
var total_disposals: int = 0

# --- SCENARIO RESULTS ---
var final_clarity: int = 0  # Add this for Scenario 2

# --- BADGES ---
var unlocked_badges: Array = []

# --- RESEARCH DATA ---
var disposal_log: Array = []
var decision_log: Array = []

# --- STORY FLAGS ---
var has_met_plush_toy: bool = false
var has_completed_scenario_1: bool = false
var has_completed_scenario_2: bool = false
var has_asked_captain: bool = false
var has_talked_to_lola: bool = false
var has_talked_to_youth: bool = false
var has_talked_to_vendor: bool = false
var has_chosen_sack: bool = false

var scenario_flags: Dictionary = {}

var scenario_active: bool = false
var current_scenario: int = 0
var uses_timer: bool = true

var carry_over_eco_score: int = 0
var carry_over_env_health: int = 50
var carry_over_energy: int = 100
var is_bulk_disposal: bool = false


signal stats_updated
signal scenario_completed(scenario_id)

func add_score(amount: int):
	eco_score += amount
	stats_updated.emit()
	print("Eco Score: ", eco_score, " (", ("+" if amount > 0 else ""), amount, ")")

func modify_env_health(amount: int):
	env_health = clamp(env_health + amount, 0, 100)
	stats_updated.emit()
	print("Env Health: ", env_health, " (", ("+" if amount > 0 else ""), amount, ")")

func modify_community_trust(amount: int):
	community_trust = clamp(community_trust + amount, 0, 100)
	stats_updated.emit()
	print("Community Trust: ", community_trust, " (", ("+" if amount > 0 else ""), amount, ")")

func modify_energy(amount: float):
	energy = clamp(energy + amount, 0.0, 100.0)
	stats_updated.emit()

func modify_soil_health(amount: int):
	soil_health = clamp(soil_health + amount, 0, 100)
	stats_updated.emit()
	print("Soil Health: ", soil_health, " (", ("+" if amount > 0 else ""), amount, ")")

func unlock_badge(badge_name: String):
	if badge_name not in unlocked_badges:
		unlocked_badges.append(badge_name)
		print("BADGE UNLOCKED: ", badge_name)
		EventBus.emit_signal("badge_unlocked", badge_name)

func get_sorting_accuracy() -> float:
	if total_disposals == 0:
		return 0
	return float(correct_disposals) / total_disposals * 100

func get_ending_tier() -> String:
	var accuracy = get_sorting_accuracy()
	if accuracy > 90 and energy > 20:
		return "A"
	elif accuracy >= 50 or energy <= 20:
		return "B"
	else:
		return "C"



func record_bulk_disposal(total: int, regular: int, hazardous: int):
	disposal_log.append({
		"item": "Bulk Truck Disposal",
		"correct": false,
		"bin": "TRUCK",
		"category": "Bulk",
		"total_items": total,
		"regular_items": regular,
		"hazardous_items": hazardous,
		"timestamp": Time.get_ticks_msec()
	})
	stats_updated.emit()

func record_disposal(item_name: String, was_correct: bool, bin_type: String, category: String = "Other"):
	total_disposals += 1
	if was_correct:
		correct_disposals += 1
	disposal_log.append({
		"item": item_name,
		"correct": was_correct,
		"bin": bin_type,
		"category": category,  # Add this
		"timestamp": Time.get_ticks_msec()
	})
	stats_updated.emit()
	print("Disposal recorded: ", item_name, " - ", "CORRECT" if was_correct else "WRONG", " in ", bin_type)

func record_decision(decision: String):
	decision_log.append(decision)
	scenario_flags[decision + "_choice"] = true
	scenario_flags["last_decision"] = decision
	stats_updated.emit()
	print("Decision recorded: ", decision)

func did_choose(decision_name: String) -> bool:
	return scenario_flags.get(decision_name + "_choice", false)

func get_scenario_flag(flag: String, default = null):
	return scenario_flags.get(flag, default)

func start_scenario(scenario_id: int, use_timer: bool = true):
	current_scenario = scenario_id
	scenario_active = true
	uses_timer = use_timer
	
	await get_tree().process_frame
	EventBus.scenario_started.emit(scenario_id)
	
	print("Scenario ", scenario_id, " started! (Timer: ", use_timer, ")")

func complete_scenario(scenario_id: int):
	match scenario_id:
		1:
			has_completed_scenario_1 = true
		2:
			has_completed_scenario_2 = true
	scenario_completed.emit(scenario_id)
	print("Scenario ", scenario_id, " completed!")

func end_scenario():
	scenario_active = false	
	print("Scenario ended!")

# GameState.gd
func clear_scenario_1_flags():
	var scene1_flags = ["rinsed_bottle_choice", "dirty_recycle_choice", "residual_waste_choice", 
						"stored_home_choice", "mixed_waste_choice", "asked_help_choice"]
	for flag in scene1_flags:
		scenario_flags.erase(flag)

func clear_scenario_2_flags():
	var scene2_flags = ["plastic_bag_choice", "woven_bag_choice", "educated_vendor_choice", 
						"confront_vendor_choice", "ignore_vendor_choice", "battery_recycled_choice",
						"battery_trashed_choice", "battery_ignored_choice", "grandson_help_choice",
						"comforted_lola_choice", "asked_lola_choice", "blamed_lola_choice",
						"youth_joined_choice", "youth_inspired_choice", "youth_asked_choice", "youth_lectured_choice"]
	for flag in scene2_flags:
		scenario_flags.erase(flag)

func reset_scenario_1():
	eco_score = 0
	env_health = 50
	energy = 100
	soil_health = 50
	waste_generated = 0
	correct_disposals = 0
	total_disposals = 0
	final_clarity = 0
	has_met_plush_toy = false
	has_completed_scenario_1 = false
	total_disposals = 0
	unlocked_badges.clear()


func save_carry_over_from_scene_1():
	carry_over_eco_score = eco_score
	carry_over_env_health = env_health
	carry_over_energy = energy


func load_carry_over_to_scene_2():
	eco_score = carry_over_eco_score
	env_health = carry_over_env_health
	energy = carry_over_energy


func reset_scenario_2():
	# Restore carry-over values
	eco_score = carry_over_eco_score
	env_health = carry_over_env_health
	energy = carry_over_energy
	
	# Reset Scenario 2 specific stats
	community_trust = 50
	waste_generated = 0
	correct_disposals = 0
	total_disposals = 0
	final_clarity = 0
	has_completed_scenario_2 = false

func full_reset():
	# Reset all story flags
	has_met_plush_toy = false
	has_completed_scenario_1 = false
	has_completed_scenario_2 = false
	has_asked_captain = false
	has_talked_to_lola = false
	has_talked_to_youth = false
	has_talked_to_vendor = false
	has_chosen_sack = false
	
	# Reset all stats (not using reset_scenario_1 or 2)
	eco_score = 0
	env_health = 50
	community_trust = 50
	energy = 100
	soil_health = 50
	waste_generated = 0
	correct_disposals = 0
	total_disposals = 0
	final_clarity = 0
	
	# Reset carry-over values
	carry_over_eco_score = 0
	carry_over_env_health = 50
	carry_over_energy = 100
	
	# Clear flags and logs
	scenario_flags.clear()
	unlocked_badges.clear()
	disposal_log.clear()
	decision_log.clear()
	
	# Reset scenario state
	scenario_active = false
	current_scenario = 0
	
	print("Full game reset complete!")
	
func set_mid_clean_visuals():
	var clogged = get_tree().get_first_node_in_group("clogged_area")
	if clogged and clogged.has_method("set_mid_clean_visuals"):
		clogged.set_mid_clean_visuals()
