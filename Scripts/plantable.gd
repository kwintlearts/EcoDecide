extends StaticBody2D

@export var sprout_plant: PackedScene
@onready var sprite: Sprite2D = $Sprite2D	

func plant():
	var sprout = sprout_plant.instantiate()
	sprout.position = position
	get_parent().add_child(sprout)
	queue_free()

func set_highlight(active:bool) -> void:
	if active:
		sprite.modulate = Color("775946ff")
	else:
		sprite.modulate = Color("dfa988")
