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
var scene_info_pulse_tween: Tween
var scene_info_clicked: bool = false
var rainbow_tween: Tween

func _ready():
	add_to_group("utility")
	# Initially hide scene icon
	scene_icon.visible = false
	print("Scene icon hidden initially")
	
	# Connect to scenario started signal to reset pulse
	EventBus.scenario_started.connect(_on_scenario_started)
	GameState.scenario_completed.connect(_on_scenario_completed)
	print("Connected to signals")

func _on_scenario_started(scenario_id: int):
	print("Scenario started: ", scenario_id)
	# Reset the flag for this scenario
	var flag_name = "scene_info_clicked_scenario_" + str(scenario_id)
	if not GameState.scenario_flags.get(flag_name, false):
		# Flag doesn't exist, so start pulsing
		scene_info_clicked = false
		_start_scene_info_pulsing()
	else:
		scene_info_clicked = true
		_stop_scene_info_pulsing()

func reset_for_new_game():
	scene_info_clicked = false
	_stop_scene_info_pulsing()
	_check_and_pulse_scene_info()

func _check_and_pulse_scene_info():
	# Check if scene info has been clicked in current scenario
	var flag_name = "scene_info_clicked_scenario_" + str(GameState.current_scenario)
	if not GameState.scenario_flags.get(flag_name, false):
		_start_scene_info_pulsing()
	else:
		scene_info_clicked = true
		_stop_scene_info_pulsing()

func _start_scene_info_pulsing():
	if scene_info_pulse_tween:
		scene_info_pulse_tween.kill()
	
	scene_info.scale = Vector2(1.0, 1.0)
	scene_info.modulate = Color.WHITE
	
	# Start rainbow color cycling
	_start_rainbow_cycle()
	
	# Scale pulsing
	scene_info_pulse_tween = create_tween()
	scene_info_pulse_tween.set_loops()
	scene_info_pulse_tween.set_ease(Tween.EASE_IN_OUT)
	scene_info_pulse_tween.set_trans(Tween.TRANS_SINE)
	
	scene_info_pulse_tween.tween_property(scene_info, "scale", Vector2(1.15, 1.15), 0.4)
	scene_info_pulse_tween.tween_property(scene_info, "scale", Vector2(1.0, 1.0), 0.4)

func _start_rainbow_cycle():
	if rainbow_tween:
		rainbow_tween.kill()
	
	# Create a sequential rainbow color cycle
	rainbow_tween = create_tween()
	rainbow_tween.set_loops()
	
	# Cycle through colors sequentially
	rainbow_tween.tween_property(scene_info, "modulate", Color(1, 0, 0), 0.3)      # Red
	rainbow_tween.tween_property(scene_info, "modulate", Color(1, 0.5, 0), 0.3)    # Orange
	rainbow_tween.tween_property(scene_info, "modulate", Color(1, 1, 0), 0.3)      # Yellow
	rainbow_tween.tween_property(scene_info, "modulate", Color(0, 1, 0), 0.3)      # Green
	rainbow_tween.tween_property(scene_info, "modulate", Color(0, 0, 1), 0.3)      # Blue
	rainbow_tween.tween_property(scene_info, "modulate", Color(0.5, 0, 1), 0.3)    # Indigo
	rainbow_tween.tween_property(scene_info, "modulate", Color(0.8, 0, 1), 0.3)    # Violet

func _stop_rainbow_cycle():
	if rainbow_tween:
		rainbow_tween.kill()
		rainbow_tween = null
	
	# Smoothly transition back to white
	var tween = create_tween()
	tween.tween_property(scene_info, "modulate", Color.WHITE, 0.3)

func _stop_scene_info_pulsing():
	if scene_info_pulse_tween:
		scene_info_pulse_tween.kill()
		scene_info_pulse_tween = null
	
	_stop_rainbow_cycle()
	scene_info.scale = Vector2(1.0, 1.0)

func _on_scenario_completed(scenario_id: int):
	print("SCENARIO COMPLETED SIGNAL RECEIVED! ID: ", scenario_id)
	scene_icon.visible = true
	_start_pulsing_animation()
	print("Scene icon should now be visible and pulsing")

func _start_pulsing_animation():
	if pulse_tween:
		pulse_tween.kill()
	
	scene_icon.scale = Vector2(1.0, 1.0)
	
	pulse_tween = create_tween()
	pulse_tween.set_loops()
	pulse_tween.set_ease(Tween.EASE_IN_OUT)
	pulse_tween.set_trans(Tween.TRANS_SINE)
	
	pulse_tween.tween_property(scene_icon, "scale", Vector2(1.2, 1.2), 0.5)
	pulse_tween.tween_property(scene_icon, "scale", Vector2(1.0, 1.0), 0.5)

func _stop_pulsing_animation():
	if pulse_tween:
		pulse_tween.kill()
		pulse_tween = null
	scene_icon.scale = Vector2(1.0, 1.0)

func _process(delta: float) -> void:
	var balloons = get_tree().get_nodes_in_group("dialogue_balloon")
	var results_screen = get_tree().get_nodes_in_group("results_screen")
	
	if balloons.size() > 0 or results_screen.size() > 0:
		if visible:
			visible = false
			print("Controls hidden")
			var inv_ui = get_tree().get_first_node_in_group("inventory_ui")
			if inv_ui and inv_ui.is_open:
				inv_ui.close()
	else:
		if not visible:
			visible = true
			print("Controls shown")

func _show_prompt(scene: String):
	var canvas = CanvasLayer.new()
	canvas.layer = 200
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
	
	# Mark as clicked for current scenario
	if not scene_info_clicked:
		scene_info_clicked = true
		_stop_scene_info_pulsing()
		var flag_name = "scene_info_clicked_scenario_" + str(GameState.current_scenario)
		GameState.scenario_flags[flag_name] = true
	
	var tween = create_tween()
	tween.tween_property(scene_info, "scale", Vector2(1.3, 1.3), 0.05)
	tween.tween_property(scene_info, "scale", Vector2(1.0, 1.0), 0.05)
	await tween.finished
	_show_prompt("res://scenes/menu/scene_info.tscn")
