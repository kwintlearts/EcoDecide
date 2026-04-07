extends Node2D

var truck_decision_shown: bool = false
var scenario_ending: bool = false  # Add this flag
const SCENE_1_DIALOGUE = preload("uid://d2oa8p14f0cqt")

func _ready():
	GameState.current_scenario = 1
	print("Current Scenario: ", GameState.current_scenario)
	
	# Connect to timer expiration
	TimerManager.time_expired.connect(_on_time_expired)
	GameState.stats_updated.connect(_on_stats_updated)
	
func _on_time_expired():
	scenario_ending = true
	_close_all_dialogues()  # Close any open dialogues
	_show_ending()

func _on_stats_updated():
	# Don't show truck decision if scenario is ending
	if scenario_ending:
		return
	
	# Check if 10 items have been disposed and decision not shown yet
	if GameState.total_disposals >= 10 and not truck_decision_shown:
		truck_decision_shown = true
		show_truck_decision()
	
	# Check for scenario completion (all items collected)
	_check_scenario_completion()

func _check_scenario_completion():
	if GameState.total_disposals >= 20 and not scenario_ending:
		scenario_ending = true
		TimerManager.end_scenario()
		_close_all_dialogues()  # Close any open dialogues
		_show_ending()

func _show_ending():
	# Don't show ending if already showing
	if scenario_ending and has_node("Balloon"):
		return
	
	var balloon = preload("res://dialogue/Balloon/balloon.tscn").instantiate()
	add_child(balloon)
	balloon.start(SCENE_1_DIALOGUE, "ending_check")
	
	
func _close_all_dialogues():
	var balloons = get_tree().get_nodes_in_group("dialogue_balloon")
	for balloon in balloons:
		if balloon and balloon.has_method("force_close"):
			balloon.force_close()
		elif balloon and balloon.has_method("queue_free"):
			balloon.queue_free()
	
	# Also disconnect any active dialogue signals

func show_truck_decision():
	# Don't show truck decision if scenario is ending
	if scenario_ending:
		return
		
	var balloon = preload("res://dialogue/Balloon/balloon.tscn").instantiate()
	add_child(balloon)
	balloon.start(SCENE_1_DIALOGUE, "decision_missing_truck")
	
