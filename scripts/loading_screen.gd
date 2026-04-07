# loading_screen.gd
extends CanvasLayer

signal loading_screen_ready

@export var animation_player: AnimationPlayer

func _ready() -> void:
	# Play the transition animation
	animation_player.play("transition")
	await animation_player.animation_finished
	loading_screen_ready.emit()

func _on_progress_changed(new_value: float) -> void:
	# Update progress bar if you have one
	pass

func _on_load_finished() -> void:
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()
