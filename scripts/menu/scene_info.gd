extends Control

@onready var scene_1: Control = $ScenePanel/Scene1
@onready var scene_2: Control = $ScenePanel/Scene2
@onready var sfx_buttons: AudioStreamPlayer = $SFXButtons

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene_1.hide()
	scene_2.hide()
	if GameState.current_scenario == 1:
		scene_1.show()
	else:
		scene_2.show()


func _on_close_button_pressed() -> void:
	if sfx_buttons:
		# Reparent to root so it survives node deletion
		sfx_buttons.get_parent().remove_child(sfx_buttons)
		get_tree().root.add_child(sfx_buttons)
		sfx_buttons.play()
	get_parent().queue_free()  # Remove the CanvasLaye
	queue_free()
