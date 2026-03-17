extends Area2D

const Balloon = preload("res://dialogue/Balloon/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func action() -> void:
	var balloon = Balloon.instantiate()
	balloon.add_to_group("dialogue_balloon")
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)
	
	if Gamestate.planting == "start":
		var parent = get_parent()
		if parent.has_method("plant"):
			parent.plant()
	
