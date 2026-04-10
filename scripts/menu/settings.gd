extends Control

@onready var sfx_buttons: AudioStreamPlayer = $SFXButtons

func _on_back_button_pressed() -> void:
	sfx_buttons.play()

	SceneLoader.go_back()
