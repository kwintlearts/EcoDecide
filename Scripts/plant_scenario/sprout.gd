# sprout.gd
extends Node2D

@export var sapling: PackedScene
@export var days_to_grow: int = 1

var planted_day: int = 0

func _ready():
	planted_day = Gamestate.day
	Gamestate.day_changed.connect(_on_day_changed)

func _on_day_changed(new_day: int) -> void:
	if new_day >= planted_day + days_to_grow:
		grow_tree()

func grow_tree() -> void:
	var tree = sapling.instantiate()
	tree.position = position
	get_parent().add_child(tree)
	tree.check_weed_spawn(Gamestate.day)
	queue_free()
