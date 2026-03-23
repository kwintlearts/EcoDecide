extends Area2D

@export var bin_type : String

func _on_area_entered(area):

	if area.has_method("get"):

		if area.trash_type == bin_type:

			get_tree().current_scene.get_node("scoremanager").add_score()

			area.queue_free()

			get_tree().current_scene.get_node("trashbox").spawn_trash()
