# utility.gd
extends Control

@onready var inventory: TouchScreenButton = $MarginContainer/Inventory
@onready var scene_icon: NinePatchRect = $SceneIcon
@onready var settings_icon: NinePatchRect = $SettingsIcon
@onready var main_menu_icon: NinePatchRect = $MainMenuIcon
@onready var scene_info: NinePatchRect = $SceneInfo
@onready var sfx_buttons: AudioStreamPlayer = $"../../SFXButtons"
@onready var sfx_inventory: AudioStreamPlayer = $"../../SFXInventory"
var pulse_tween: Tween

func _ready():
	# Initially hide scene icon
	scene_icon.visible = false
	print("Scene icon hidden initially")
	
	
	GameState.scenario_completed.connect(_on_scenario_completed)
	print("Connected to scenario_completed signal")

func _on_scenario_completed(scenario_id: int):
	print("SCENARIO COMPLETED SIGNAL RECEIVED! ID: ", scenario_id)
	# Show scene icon after any scenario completes
	scene_icon.visible = true
	_start_pulsing_animation()
	print("Scene icon should now be visible and pulsing")

func _start_pulsing_animation():
	# Kill existing tween if any
	if pulse_tween:
		pulse_tween.kill()
	
	# Reset scale to normal
	scene_icon.scale = Vector2(1.0, 1.0)
	
	# Create pulsing animation
	pulse_tween = create_tween()
	pulse_tween.set_loops()  # Loop indefinitely
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.set_trans(Tween.TRANS_SINE)
	
	# Pulse: scale up and down
	pulse_tween.tween_property(scene_icon, "scale", Vector2(1.2, 1.2), 0.5)
	pulse_tween.tween_property(scene_icon, "scale", Vector2(1.0, 1.0), 0.5)

func _stop_pulsing_animation():
	if pulse_tween:
		pulse_tween.kill()
		pulse_tween = null
	scene_icon.scale = Vector2(1.0, 1.0)

# utility.gd
func _process(delta: float) -> void:
	# Hide controls if there's a dialogue balloon active OR results screen is showing
	var balloons = get_tree().get_nodes_in_group("dialogue_balloon")
	var results_screen = get_tree().get_nodes_in_group("results_screen")
	
	
	if balloons.size() > 0 or results_screen.size() > 0:
		if visible:
			visible = false
			print("Controls hidden")
	else:
		if not visible:
			visible = true
			print("Controls shown")

func _show_prompt(scene: String):
	var canvas = CanvasLayer.new()
	canvas.layer = 200  # Higher than results screen (100)
	get_tree().current_scene.add_child(canvas)
	
	var prompt = load(scene).instantiate()
	canvas.add_child(prompt)

func _on_inventory_pressed() -> void:
	sfx_inventory.play()
	inventory.scale = Vector2(2.7, 2.7)

func _on_inventory_released() -> void:
	inventory.scale = Vector2(2.5, 2.5)

func _on_scene_button_pressed() -> void:	
	sfx_buttons.play()
	
	var tween = create_tween()
	tween.tween_property(scene_icon, "scale", Vector2(1.3, 1.3), 0.02)
	tween.tween_property(scene_icon, "scale", Vector2(1.0, 1.0), 0.02)
	await tween.finished 
	TimerManager._show_results_screen()

func _on_settings_button_pressed() -> void:
	sfx_buttons.play()
	
	var tween = create_tween()
	tween.tween_property(settings_icon, "scale", Vector2(1.3, 1.3), 0.02)
	tween.tween_property(settings_icon, "scale", Vector2(1.0, 1.0), 0.02)
	await tween.finished 
	SceneLoader.load_scene("res://scenes/menu/settings.tscn")


func _on_main_menu_button_pressed() -> void:
	sfx_buttons.play()

	var tween = create_tween()
	tween.tween_property(main_menu_icon, "scale", Vector2(1.3, 1.3), 0.05)
	tween.tween_property(main_menu_icon, "scale", Vector2(1.0, 1.0), 0.05)
	await tween.finished 
	_show_prompt("res://scenes/menu/menu_prompt.tscn")


func _on_scene_info_button_pressed() -> void:
	sfx_buttons.play()
	
	var tween = create_tween()
	tween.tween_property(scene_info, "scale", Vector2(1.3, 1.3), 0.05)
	tween.tween_property(scene_info, "scale", Vector2(1.0, 1.0), 0.05)
	await tween.finished
	_show_prompt("res://scenes/menu/scene_info.tscn")
	
	
