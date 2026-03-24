extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
var sapling_parent: Node = null  # Add this line

func remove_weed() -> void:
	# Optional: notify parent when removed
	if sapling_parent and sapling_parent.has_method("remove_weed"):
		sapling_parent.remove_weed()
	
	Gamestate.points += 5
	queue_free()


func _on_actionable_area_entered(area: Area2D) -> void:
	sprite.modulate = Color("75b9acff")


func _on_actionable_area_exited(area: Area2D) -> void:
	sprite.modulate = Color("ffffff")
