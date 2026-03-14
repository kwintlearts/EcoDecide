extends Node

var points = 0
var planting = ""
var plantable_count: int = 0

func start_planting():
	# Count unplanted plantables when starting
	plantable_count = get_tree().get_nodes_in_group("plantable").size()
	print("Planting started! Trees to plant: ", plantable_count)

func plant_completed():
	plantable_count -= 1
	points += 10
	print("Tree planted! Remaining: ", plantable_count)
	
	if plantable_count <= 0:
		print("All trees planted!")
		planting = "planting_finished"
