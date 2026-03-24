extends Node2D

@export var initial_scene: StringName = &""
@export var play_button: Button

func _on_play_pressed() -> void:
	SceneLoader.load_scene(initial_scene)
