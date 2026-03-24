extends StaticBody2D

@export var sprout_plant: PackedScene
@onready var sprite: Sprite2D = $Sprite2D

var is_planted: bool = false  # Prevent double plant

func _ready():
	add_to_group("plantable")

func plant():
	if is_planted:
		return
	
	is_planted = true
	
	if sprout_plant:
		var sprout = sprout_plant.instantiate()
		sprout.position = position
		get_parent().add_child(sprout)
	
	Gamestate.plant_completed()
	queue_free()

func _on_actionable_area_entered(_area: Area2D) -> void:
	sprite.modulate = Color("775946ff")

func _on_actionable_area_exited(_area: Area2D) -> void:
	sprite.modulate = Color("dfa988")
