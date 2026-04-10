# menu_prompt.gd
extends Control

@onready var sfx_buttons: AudioStreamPlayer = $SFXButtons

func _on_yes_button_pressed() -> void:
	if sfx_buttons:
		sfx_buttons.play()
		await sfx_buttons.finished
	
	# Clear all saved states
	SceneLoader.scene_state.clear()
	
	# Reset game state
	GameState.full_reset()
	
	# Stop any ongoing timers
	TimerManager.stop_timer()
	
	# Close any open inventories
	var inv_ui = get_tree().get_first_node_in_group("inventory_ui")
	if inv_ui:
		inv_ui.close()
	
	# Load main menu
	SceneLoader.load_scene("res://scenes/menu/main_menu.tscn")
	

func _on_no_button_pressed() -> void:
	if sfx_buttons:
		# Reparent to root so it survives node deletion
		sfx_buttons.get_parent().remove_child(sfx_buttons)
		get_tree().root.add_child(sfx_buttons)
		sfx_buttons.play()
	get_parent().queue_free()  # Remove the CanvasLaye
	queue_free()
