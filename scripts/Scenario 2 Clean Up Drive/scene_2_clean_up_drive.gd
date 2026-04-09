# scene_2_clean_up_drive.gd
extends Node2D

@onready var wall: TileMapLayer = $TileMapLayers/Market/Wall
@onready var player: CharacterBody2D = $Characters/Player
@onready var plush_toy: CharacterBody2D = $"Characters/Plush Toy"
@onready var clogged: Area2D = $TileMapLayers/Canal/Clogged
@onready var spawner: Area2D = $TileMapLayers/Canal/Spawner
@onready var hazardous: StaticBody2D = $Hazardous

const SCENE_2_DIALOGUE = preload("uid://tyjr7142kuca")

var crate_cells: Array[Vector2i] = []
var CRATE_ATLAS := Vector2i(1, 1)
var SOURCE_ID := 0
var scenario_ended: bool = false
var crates_removed: bool = false  # Add this variable

var total_items_processed: int = 0
var total_items_to_process: int = 30
const GARBAGE_TRUCK_SCENE = preload("uid://bvco8ogotk1jd")
var battery_ignored: bool = false

func _ready():
	GameState.current_scenario = 2
	if GameState.did_choose("asked_help"):
		_spawn_second_truck()
	_remove_crates_at_start()
	
	hazardous.hide()
	
	
	print("Current Scenario: ", GameState.current_scenario)
	
	EventBus.vendor_confronted.connect(_on_vendor_confronted)
	
	if spawner:
		spawner.add_to_group("spawner")
		spawner.item_collected.connect(_on_item_collected)
		await get_tree().process_frame
		clogged.update_clarity()
	
	TimerManager.time_expired.connect(_on_scenario_end)	
	var truck = get_tree().get_first_node_in_group("garbage_truck")
	if truck:
		truck.items_disposed.connect(_on_truck_disposal)
	GameState.stats_updated.connect(_on_stats_updated)

func _on_stats_updated():
	# Update battery choice when it's made
	if not battery_ignored and GameState.did_choose("battery_ignored"):
		update_battery_choice()
		
	if GameState.did_choose("battery_recycled"):
		hazardous.show()
		print("Hazardous bin shown for battery disposal")
	
func update_battery_choice():
	battery_ignored = GameState.did_choose("battery_ignored")
	if battery_ignored:
		total_items_to_process = 29
		print("Battery ignored - need to process 29 items")
	else:
		total_items_to_process = 30
		print("Battery will be processed - need to process 30 items")

func _spawn_second_truck():
	var second_truck = GARBAGE_TRUCK_SCENE.instantiate()
	second_truck.global_position = Vector2(-155.0, -418.0)
	second_truck.z_index = 1
	add_child(second_truck)
	second_truck.add_to_group("garbage_truck")

func _remove_crates_at_start():
	for cell in wall.get_used_cells():
		var tile_data = wall.get_cell_tile_data(cell)
		if tile_data and tile_data.get_custom_data("is_crate"):
			crate_cells.append(cell)
			wall.set_cell(cell, -1)
	crates_removed = true
	print("Removed ", crate_cells.size(), " crates at start. Path is OPEN.")

func _on_vendor_confronted():
	print("Vendor confronted - blocking path!")
	spawn_crates()

func spawn_crates():
	print("Spawning ", crate_cells.size(), " crates to block path")
	for cell in crate_cells:
		wall.set_cell(cell, SOURCE_ID, CRATE_ATLAS, 0)
	crates_removed = false
	print("Crates spawned - path BLOCKED")

func save_scenario_results():
	var remaining = spawner.get_remaining_items()
	var final_clarity = int((30 - remaining) / 30.0 * 100)
	GameState.scenario_flags["canal_clarity"] = final_clarity
	GameState.final_clarity = final_clarity  # Add this line
	print("Saved scenario results - Clarity: ", final_clarity, "%")

func _on_scenario_end():
	print("_on_scenario_end called! scenario_ended: ", scenario_ended)
	if not scenario_ended:
		scenario_ended = true
		GameState.complete_scenario(2)  # Add this
		save_scenario_results()
		print("Calling TimerManager.end_scenario()")
		TimerManager.end_scenario()
		var balloon = preload("res://dialogue/Balloon/balloon.tscn").instantiate()
		balloon.add_to_group("dialogue_balloon")
		add_child(balloon)
		balloon.start(SCENE_2_DIALOGUE, "ending_check")

func _on_item_collected():
	if clogged:
		clogged.update_clarity()
	
	_check_completion()

func update_clogged_clarity():
	if clogged:
		clogged.update_clarity()

func check_cell():
	var local_pos = wall.to_local(player.global_position)
	var cell = wall.local_to_map(local_pos)
	var tile_data = wall.get_cell_tile_data(cell)
	if tile_data and tile_data.get_custom_data("is_crate"):
		print("Standing on a CRATE at:", cell)

func _on_truck_disposal(count: int):
	total_items_processed += count
	print("Items disposed in truck: ", count, " Total: ", total_items_processed)
	_check_completion()

func _check_completion():
	if GameState.total_disposals >= total_items_to_process and not scenario_ended:
		print("All items disposed! Total disposals: ", GameState.total_disposals)
		_on_scenario_end()

# scene_2_clean_up_drive.gd
func save_state() -> Dictionary:
	# Save inventory state
	var inventory_state = []
	var inventory_type = "default"  # Track which inventory the player has
	
	if player and player.inv:
		# Determine inventory type by slot count
		if player.inv.slots.size() == 10:
			inventory_type = "plastic"
		elif player.inv.slots.size() == 15:
			inventory_type = "woven"
		else:
			inventory_type = "default"
		
		for slot in player.inv.slots:
			inventory_state.append({
				"item_id": slot.item.id if slot.item else null,
				"has_item": slot.item != null
			})
	
	return {
		"total_items_processed": total_items_processed,
		"eco_score": GameState.eco_score,
		"env_health": GameState.env_health,
		"energy": GameState.energy,
		"community_trust": GameState.community_trust,
		"scenario_flags": GameState.scenario_flags.duplicate(),
		"crates_removed": crates_removed,
		"player_position": player.global_position if player else Vector2.ZERO,
		"plush_toy_position": plush_toy.global_position if plush_toy else Vector2.ZERO,
		"spawner_state": spawner.save_state() if spawner else {},
		"inventory_state": inventory_state,
		"inventory_type": inventory_type  # Save which inventory the player has
	}

# scene_2_clean_up_drive.gd
func load_state(state: Dictionary) -> void:
	scenario_ended = false
	total_items_processed = state.get("total_items_processed", 0)
	GameState.eco_score = state.get("eco_score", 0)
	GameState.env_health = state.get("env_health", 50)
	GameState.energy = state.get("energy", 100)
	GameState.community_trust = state.get("community_trust", 50)
	GameState.scenario_flags = state.get("scenario_flags", {})
	crates_removed = state.get("crates_removed", false)
	
	if player:
		player.global_position = state.get("player_position", Vector2.ZERO)
	
	if plush_toy:
		plush_toy.global_position = state.get("plush_toy_position", Vector2.ZERO)
	
	# Restore inventory type first
	var inventory_type = state.get("inventory_type", "default")
	match inventory_type:
		"plastic":
			player.switch_to_plastic_sack()
		"woven":
			player.switch_to_woven_sack()
		_:
			# Default inventory (3 slots) - already set
			pass
	
	# Wait for inventory to be set up
	await get_tree().process_frame
	
	if spawner and state.has("spawner_state"):
		spawner.load_state(state["spawner_state"])
	
	# Restore inventory items
	if player and player.inv:
		var inventory_state = state.get("inventory_state", [])
		print(inventory_state)
		
		# Clear all slots first
		for i in range(player.inv.slots.size()):
			player.inv.slots[i].item = null
			
		# Restore items to slots
		for i in range(min(inventory_state.size(), player.inv.slots.size())):
			var slot_data = inventory_state[i]
			if slot_data.get("has_item", false) and slot_data.has("item_id"):
				var item_id = slot_data["item_id"]
				for inv_item in spawner.items:
					if inv_item.id == item_id:
						await get_tree().create_timer(0.5).timeout
						player.inv.slots[i].item = inv_item
						print("Restored item to slot ", i, ": ", inv_item.name)
						break
	
	# Refresh UI
	clogged.update_clarity()
	get_tree().call_group("inventory_ui", "update_slots")
	
	# Update crate visuals
	if crates_removed:
		for cell in crate_cells:
			wall.set_cell(cell, -1)
	else:
		for cell in crate_cells:
			wall.set_cell(cell, SOURCE_ID, CRATE_ATLAS, 0)
