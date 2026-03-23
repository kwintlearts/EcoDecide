extends Area2D

@export var bin_type : String

func _on_area_entered(area):

	if area.is_in_group("trash"):

		var score_manager = get_tree().current_scene.get_node("scoremanager")

		# if correct bin
		if area.trash_type == bin_type:

			score_manager.add_score(10)
			print("correct bin +10")

		# if wrong bin
		else:

			score_manager.add_score(-5)
			print("wrong bin -5")

		# remove trash after drop
		area.queue_free()

		# spawn next trash
		get_tree().current_scene.get_node("trashbox").spawn_trash()
