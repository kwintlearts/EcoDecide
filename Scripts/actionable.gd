extends Area2D

const Balloon = preload("res://dialogue/Balloon/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export_enum("dialogue", "plant") var action_type: String = "dialogue"


func interact():
	match action_type:
		"dialogue":
			start_dialogue()
		"plant":
			var parent = get_parent()
			if parent.has_method("plant"):
				parent.plant()

func start_dialogue() -> void:
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)
