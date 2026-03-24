extends Node

signal day_changed(new_day)
signal planting_finished
signal score_changed(new_score)

var points: int = 0:
	set(value):
		points = value
		score_changed.emit(value)

var planting: String = ""
var plantable_count: int = 0
var total_plantables: int = 0
var day: int = 1

func add_points(amount: int):
	points += amount

func start_planting():
	total_plantables = get_tree().get_nodes_in_group("plantable").size()
	plantable_count = total_plantables
	print("Day ", day, " - Planting started! Trees: ", plantable_count)

func plant_completed():
	plantable_count -= 1
	add_points(10)
	print("Tree planted! Remaining: ", plantable_count)
	
	if plantable_count <= 0:
		print("All trees planted!")
		planting = "finished"
		planting_finished.emit()
