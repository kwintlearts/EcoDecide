extends Node2D

var truck_decision_shown: bool = false
const SCENE_1___WASTE_SEGREGATION = preload("uid://d2oa8p14f0cqt")

func _ready():
	# Connect to disposal signal or check periodically
	GameState.stats_updated.connect(_on_stats_updated)

func _on_stats_updated():
	# Check if 10 items have been disposed and decision not shown yet
	if GameState.total_disposals >= 10 and not truck_decision_shown:
		truck_decision_shown = true
		show_truck_decision()

func show_truck_decision():
	# Trigger the dialogue
	var balloon = preload("res://dialogue/Balloon/balloon.tscn").instantiate()
	add_child(balloon)
	balloon.start(SCENE_1___WASTE_SEGREGATION, "decision_missing_truck")
