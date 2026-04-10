# main_menu.gd
extends Control

const SCENE_1_WASTE_SEGREGATION = "res://scenes/Scenario 1 WS/scene_1_waste_segregation.tscn"
@onready var sfx_buttons: AudioStreamPlayer = $SFXButtons

func _on_play_pressed() -> void:
	sfx_buttons.play()
	SceneLoader.scene_state.clear()
	GameState.full_reset()
	
	SceneLoader.load_scene(SCENE_1_WASTE_SEGREGATION)


func _on_settings_pressed() -> void:
	sfx_buttons.play()
	
	SceneLoader.load_scene("res://scenes/menu/settings.tscn")
