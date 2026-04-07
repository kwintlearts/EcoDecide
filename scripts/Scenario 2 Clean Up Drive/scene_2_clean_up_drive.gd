# scene_2_clean_up_drive.gd
extends Node2D

@onready var wall: TileMapLayer = $TileMapLayers/Market/Wall
@onready var player: CharacterBody2D = $Characters/Player
@onready var plush_toy: CharacterBody2D = $"Characters/Plush Toy"
@onready var clogged: Area2D = $TileMapLayers/Canal/Clogged
@onready var spawner: Area2D = $TileMapLayers/Canal/Spawner

const SCENE_2_DIALOGUE = preload("uid://tyjr7142kuca")

var crate_cells: Array[Vector2i] = []
var CRATE_ATLAS := Vector2i(1, 1)
var SOURCE_ID := 0
var scenario_ended: bool = false

var total_items_processed: int = 0
var total_items_to_process: int = 30

func _ready():
	GameState.current_scenario = 2
	print("Current Scenario: ", GameState.current_scenario)
	
	# Remove crates at start (path starts OPEN)
	_remove_crates_at_start()
	
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
	

func _remove_crates_at_start():
	for cell in wall.get_used_cells():
		var tile_data = wall.get_cell_tile_data(cell)
		if tile_data and tile_data.get_custom_data("is_crate"):
			crate_cells.append(cell)
			wall.set_cell(cell, -1)  # Remove the crate
	print("Removed ", crate_cells.size(), " crates at start. Path is OPEN.")

func _on_vendor_confronted():
	print("Vendor confronted - blocking path!")
	spawn_crates()  # Block path by spawning crates

func spawn_crates():
	print("Spawning ", crate_cells.size(), " crates to block path")
	for cell in crate_cells:
		wall.set_cell(cell, SOURCE_ID, CRATE_ATLAS, 0)
	print("Crates spawned - path BLOCKED")

func save_scenario_results():
	var remaining = spawner.get_remaining_items()
	var final_clarity = int((30 - remaining) / 30.0 * 100)
	GameState.scenario_flags["canal_clarity"] = final_clarity
	print("Saved scenario results - Clarity: ", final_clarity, "%")

func _on_scenario_end():
	print("_on_scenario_end called! scenario_ended: ", scenario_ended)
	if not scenario_ended:
		scenario_ended = true
		save_scenario_results()
		print("Calling TimerManager.end_scenario()")
		TimerManager.end_scenario()
		var balloon = preload("res://dialogue/Balloon/balloon.tscn").instantiate()
		add_child(balloon)
		balloon.start(SCENE_2_DIALOGUE, "ending_check")

func _on_item_collected():
	if clogged:
		clogged.update_clarity()
	
	if spawner and spawner.get_remaining_items() <= 0:
		_on_scenario_end()

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
	
	if total_items_processed >= total_items_to_process:
		_on_scenario_end()
