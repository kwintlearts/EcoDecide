# main_menu.gd
extends Control

const SCENE_1_WASTE_SEGREGATION = "res://scenes/Scenario 1 WS/scene_1_waste_segregation.tscn"

func _on_play_pressed() -> void:
	SceneLoader.load_scene(SCENE_1_WASTE_SEGREGATION)


func _on_settings_pressed() -> void:
	SceneLoader.load_scene("")
