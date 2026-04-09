# scene_1_waste_segregation.gd
extends Node2D

var truck_decision_shown: bool = false
var scenario_ending: bool = false
const SCENE_1_DIALOGUE = preload("uid://d2oa8p14f0cqt")
@onready var player: CharacterBody2D = $Characters/Player
@onready var plush_toy: CharacterBody2D = $"Characters/Plush Toy"

@onready var spawner: Area2D = $"Trash Objects/Spawner"

func _ready():
	GameState.current_scenario = 1
	print("Current Scenario: ", GameState.current_scenario)
	
	TimerManager.time_expired.connect(_on_time_expired)
	GameState.stats_updated.connect(_on_stats_updated)

func _on_time_expired():
	scenario_ending = true
	GameState.complete_scenario(1)  # Add this line
	
	_close_all_dialogues()
	_show_ending()

func _on_stats_updated():
	if scenario_ending:
		return
	
	if GameState.total_disposals >= 10 and not truck_decision_shown:
		truck_decision_shown = true
		show_truck_decision()
	
	_check_scenario_completion()

func _check_scenario_completion():
	if GameState.total_disposals >= 20 and not scenario_ending:
		scenario_ending = true
		GameState.complete_scenario(1)  # Add this line
		TimerManager.end_scenario()
		_close_all_dialogues()
		_show_ending()

func _show_ending():
	if scenario_ending and has_node("Balloon"):
		return
	
	var balloon = preload("res://dialogue/Balloon/balloon.tscn").instantiate()
	balloon.add_to_group("dialogue_balloon")  # Make sure this line exists!
	add_child(balloon)
	balloon.start(SCENE_1_DIALOGUE, "ending_check")

func _close_all_dialogues():
	var balloons = get_tree().get_nodes_in_group("dialogue_balloon")
	for balloon in balloons:
		if balloon and balloon.has_method("force_close"):
			balloon.force_close()
		elif balloon and balloon.has_method("queue_free"):
			balloon.queue_free()

func show_truck_decision():
	if scenario_ending:
		return
		
	var balloon = preload("res://dialogue/Balloon/balloon.tscn").instantiate()
	add_child(balloon)
	balloon.start(SCENE_1_DIALOGUE, "decision_missing_truck")

func save_state() -> Dictionary:
	print("Saving Scene 1 state...")
	
	# Save inventory state
	var inventory_state = []
	if player and player.inv:
		for slot in player.inv.slots:
			print("items in player inv: ", slot)
			inventory_state.append({
				"item_id": slot.item.id if slot.item else null,
				"has_item": slot.item != null
			})
	var inv_ui = get_tree().get_first_node_in_group("inventory_ui")
	
	var state = {
		"total_disposals": GameState.total_disposals,
		"eco_score": GameState.eco_score,
		"env_health": GameState.env_health,
		"energy": GameState.energy,
		"time_remaining": TimerManager.time_remaining,
		"truck_decision_shown": truck_decision_shown,
		"scenario_flags": GameState.scenario_flags.duplicate(),
		"player_position": player.global_position if player else Vector2.ZERO,
		"plush_toy_position": plush_toy.global_position if plush_toy else Vector2.ZERO,
		"spawner_state": spawner.save_state() if spawner else {},  # ADD THIS LINE
		"inventory_state": inventory_state,  # Save inventory
	}
	return state

func load_state(state: Dictionary) -> void:
	print("Loading Scene 1 state...")
	GameState.total_disposals = state.get("total_disposals", 0)
	GameState.eco_score = state.get("eco_score", 0)
	GameState.env_health = state.get("env_health", 50)
	GameState.energy = state.get("energy", 100)
	TimerManager.time_remaining = state.get("time_remaining", 300)
	truck_decision_shown = state.get("truck_decision_shown", false)
	GameState.scenario_flags = state.get("scenario_flags", {})
	
	if player:
		player.global_position = state.get("player_position", Vector2.ZERO)
	
	if plush_toy:
		plush_toy.global_position = state.get("plush_toy_position", Vector2.ZERO)
	
	# Restore spawner state FIRST
	if spawner and state.has("spawner_state"):
		print("Loading spawner state")
		spawner.load_state(state["spawner_state"])
	else:
		# If no saved state, spawn fresh items
		spawner.spawn_items()
	
	# Wait for spawner to finish
	await get_tree().process_frame
	
	# Then restore inventory
	if player and player.inv:
		var inventory_state = state.get("inventory_state", [])
		print(inventory_state)
		
		for i in range(player.inv.slots.size()):
			player.inv.slots[i].item = null
			
		for i in range(min(inventory_state.size(), player.inv.slots.size())):
			var slot_data = inventory_state[i]
			if slot_data.get("has_item", false) and slot_data.has("item_id"):
				var item_id = slot_data["item_id"]
				for inv_item in spawner.items:
					if inv_item.id == item_id:
						await get_tree().create_timer(0.3).timeout
						player.inv.slots[i].item = inv_item
						print("Restored item to slot ", i, ": ", inv_item.name)
						break
	
	# Refresh UI
	GameState.stats_updated.emit()
	get_tree().call_group("inventory_ui", "update_slots")
	
	# Check completion after everything is loaded
	_check_scenario_completion()
	
	if TimerManager.time_remaining <= 0:
		_on_time_expired()
