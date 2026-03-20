extends Node2D

@export var trash_scenes: Array[PackedScene]

func spawn_trash():
	if trash_scenes.is_empty():
		print("No trash scenes assigned!")
		return

	var trash_scene = trash_scenes.pick_random()
	var trash = trash_scene.instantiate()

	trash.global_position = global_position + Vector2(0, -40)
	get_parent().add_child(trash)
