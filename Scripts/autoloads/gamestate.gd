extends Node

signal day_changed(new_day)
signal planting_finished
signal score_changed(new_score)
signal game_over(won: bool)
signal all_trees_grown

var points: int = 0:
	set(value):
		points = value
		score_changed.emit(value)

var planting: String = ""
var plantable_count: int = 0
var total_plantables: int = 0
var day: int = 1

# Win/lose tracking
var fully_grown_trees: int = 0
var dead_saplings: int = 0
var total_saplings: int = 0

func add_fully_grown_tree() -> void:
	fully_grown_trees += 1
	if fully_grown_trees >= total_saplings and total_saplings > 0:
		all_trees_grown.emit()

func sapling_died() -> void:
	dead_saplings += 1

func check_win_condition() -> bool:
	return fully_grown_trees >= total_saplings

func check_lose_condition() -> bool:
	# All saplings dead, or day 5 ended without all grown
	var alive_saplings = total_saplings - dead_saplings
	return alive_saplings == 0 or (day >= 5 and not check_win_condition())

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
