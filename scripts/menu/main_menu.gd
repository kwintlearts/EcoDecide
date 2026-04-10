# main_menu.gd
extends Control

const SCENE_1_WASTE_SEGREGATION = "res://scenes/Scenario 1 WS/scene_1_waste_segregation.tscn"
@onready var sfx_buttons: AudioStreamPlayer = $SFXButtons
@onready var quit: Button = $NinePatchRect/VBoxContainer/Quit


func _ready() -> void:
	if OS.has_feature("web") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		quit.hide()


func _on_play_pressed() -> void:
	sfx_buttons.play()
	SceneLoader.scene_state.clear()
	GameState.full_reset()
	
	SceneLoader.load_scene(SCENE_1_WASTE_SEGREGATION)


func _on_settings_pressed() -> void:
	sfx_buttons.play()
	
	SceneLoader.load_scene("res://scenes/menu/settings.tscn")


func _on_quit_pressed() -> void:
	sfx_buttons.play()
	await sfx_buttons.finished
	get_tree().quit()
