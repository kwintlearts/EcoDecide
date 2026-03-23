extends Node2D

@export var trash_scenes : Array[PackedScene]

func spawn_trash():

	# check if time still running
	if get_tree().current_scene.time_left <= 0:
		print("Time finished → no more trash")
		return

	if trash_scenes.is_empty():
		print("no trash assigned")
		return

	var chosen_trash = trash_scenes.pick_random()

	var trash = chosen_trash.instantiate()

	trash.global_position = global_position + Vector2(120,0)

	get_parent().add_child(trash)
	
