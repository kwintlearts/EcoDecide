extends Area2D

@export var bin_type: String

func _on_area_entered(area):
	if area.is_in_group("trash"):
		if area.trash_type == bin_type:
			get_node("/root/Game/ScoreManager").add_score()
			area.queue_free()
			get_node("/root/Game/TrashBox").spawn_trash()
		
