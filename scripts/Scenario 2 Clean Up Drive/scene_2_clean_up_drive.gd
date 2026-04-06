extends Node2D

@onready var wall: TileMapLayer = $TileMapLayers/Market/Wall
@onready var player: CharacterBody2D = $Player

# Store crate positions
var crate_cells: Array[Vector2i] = []

# Keep this for respawning (still needed)
var CRATE_ATLAS := Vector2i(1, 1)
var SOURCE_ID := 0


func _ready():
	remove_crates_on_start()


func _process(delta: float) -> void:
	#check_cell()

	if Input.is_action_just_pressed("ui_accept"):
		spawn_crates()


# 🔹 Remove crates using custom data
func remove_crates_on_start():
	for cell in wall.get_used_cells():
		var tile_data = wall.get_cell_tile_data(cell)

		# IMPORTANT: check if tile exists
		if tile_data and tile_data.get_custom_data("is_crate"):
			crate_cells.append(cell)
			wall.set_cell(cell, -1)


# 🔹 Bring crates back
func spawn_crates():
	for cell in crate_cells:
		wall.set_cell(cell, SOURCE_ID, CRATE_ATLAS, 0)


# 🔹 Debug current tile under this node
func check_cell():
	var local_pos = wall.to_local(player.global_position)
	var cell = wall.local_to_map(local_pos)

	var tile_data = wall.get_cell_tile_data(cell)

	if tile_data:
		if tile_data.get_custom_data("is_crate"):
			print("Standing on a CRATE at:", cell)
