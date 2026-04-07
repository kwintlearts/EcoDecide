extends Node2D

var truck_decision_shown: bool = false
const SCENE_1_DIALOGUE = preload("uid://d2oa8p14f0cqt")

func _ready():
	GameState.current_scenario = 1
	print("Current Scenario: ", GameState.current_scenario)

	GameState.stats_updated.connect(_on_stats_updated)

func _on_stats_updated():
	# Check if 10 items have been disposed and decision not shown yet
	if GameState.total_disposals >= 10 and not truck_decision_shown:
		truck_decision_shown = true
		show_truck_decision()
	
	# Check for scenario completion
	_check_scenario_completion()

func _check_scenario_completion():
	# Check if all items disposed OR timer expired
	#if GameState.total_disposals >= 20 or TimerManager.time_remaining <= 0:
		#_show_ending()
	pass
	
func _show_ending():
	# Trigger the ending dialogue
	var balloon = preload("res://dialogue/Balloon/balloon.tscn").instantiate()
	add_child(balloon)
	balloon.start(SCENE_1_DIALOGUE, "ending_check")

func show_truck_decision():
	var balloon = preload("res://dialogue/Balloon/balloon.tscn").instantiate()
	add_child(balloon)
	balloon.start(SCENE_1_DIALOGUE, "decision_missing_truck")
