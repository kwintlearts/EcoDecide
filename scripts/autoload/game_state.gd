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

# --- BADGES ---
var unlocked_badges: Array = []

# --- RESEARCH DATA ---
var disposal_log: Array = []
var decision_log: Array = []

# --- STORY FLAGS ---
var has_met_plush_toy: bool = false
var has_completed_scenario_1: bool = false
var has_asked_captain: bool = false  # Add this line
var has_talked_to_lola: bool = false
var has_talked_to_youth: bool = false
var has_talked_to_vendor: bool = false
var has_chosen_sack: bool = false

var scenario_flags: Dictionary = {}

var scenario_active: bool = false
var current_scenario: int = 0  # 1, 2, or 3
var uses_timer: bool = true    # Whether current scenario uses timer

signal stats_updated

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
	#print("Energy: ", round(energy), " (", ("+" if amount > 0 else ""), amount, ")")

func modify_soil_health(amount: int):
	soil_health = clamp(soil_health + amount, 0, 100)
	stats_updated.emit()
	print("Soil Health: ", soil_health, " (", ("+" if amount > 0 else ""), amount, ")")


func unlock_badge(badge_name: String):
	if badge_name not in unlocked_badges:
		unlocked_badges.append(badge_name)
		print("BADGE UNLOCKED: ", badge_name)
		# Show badge notification
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

# Then add the function:
func record_disposal(item_name: String, was_correct: bool, bin_type: String):
	total_disposals += 1
	if was_correct:
		correct_disposals += 1
	disposal_log.append({
		"item": item_name,
		"correct": was_correct,
		"bin": bin_type,
		"timestamp": Time.get_ticks_msec()
	})
	stats_updated.emit()
	print("Disposal recorded: ", item_name, " - ", "CORRECT" if was_correct else "WRONG", " in ", bin_type)

func record_decision(decision: String):
	decision_log.append(decision)
	# Also save as a flag for easy checking
	scenario_flags[decision + "_choice"] = true
	scenario_flags["last_decision"] = decision
	stats_updated.emit()
	print("Decision recorded: ", decision)

# Add this helper function
func did_choose(decision_name: String) -> bool:
	return scenario_flags.get(decision_name + "_choice", false)

func get_scenario_flag(flag: String, default = null):
	return scenario_flags.get(flag, default)

# GameState.gd
func start_scenario(scenario_id: int, use_timer: bool = true):
	current_scenario = scenario_id
	scenario_active = true
	uses_timer = use_timer
	
	# Small delay to ensure all nodes are ready
	await get_tree().process_frame
	EventBus.scenario_started.emit(scenario_id)
	
	print("Scenario ", scenario_id, " started! (Timer: ", use_timer, ")")

func end_scenario():
	scenario_active = false
	print("Scenario ended!")

func reset_scenario_1():
	eco_score = 0
	env_health = 50
	community_trust = 50
	energy = 100
	soil_health = 50
	waste_generated = 0
	correct_disposals = 0
	total_disposals = 0

func full_reset():
	reset_scenario_1()
	unlocked_badges.clear()
	has_met_plush_toy = false
	has_completed_scenario_1 = false
