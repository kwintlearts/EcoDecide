# plantable.gd
extends StaticBody2D

@export var sprout_plant: PackedScene
@onready var sprite: Sprite2D = $Sprite2D

func plant():
	var sprout = sprout_plant.instantiate()
	sprout.position = position
	get_parent().add_child(sprout)
	Gamestate.add_points(10)
	queue_free()

func _on_actionable_area_entered(area: Area2D) -> void:
	sprite.modulate = Color("775946ff")


func _on_actionable_area_exited(area: Area2D) -> void:
	sprite.modulate = Color("dfa988")
