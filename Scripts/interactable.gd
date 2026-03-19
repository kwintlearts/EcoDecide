extends Area2D

@export var interact_name: String = "Default"
var is_interactable: bool = true

func interact() -> void:
	print("Interacted with: ", interact_name)
