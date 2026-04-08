# spawner.gd
extends Area2D

signal item_collected

@export var items: Array[InvItem]
@export var total_items_to_spawn: int = 30
@export var random_rotation: bool = true
@export var random_scale: bool = false
@export var scale_range: Vector2 = Vector2(1, 1)

@export var pickup_item_scene: PackedScene

var spawned_items: Array = []

func _ready():
	spawn_items()

func spawn_items():
	clear_items()
	
	var spawn_rect = _get_spawn_area_rect()
	print("Spawn rect (global): ", spawn_rect)
	
	if spawn_rect.size.x == 0 or spawn_rect.size.y == 0:
		print("Error: Spawn area has no size!")
		return
	
	if not pickup_item_scene:
		print("Error: No pickup_item_scene assigned!")
		return
	
	if items.is_empty():
		print("Error: No items assigned to spawner!")
		return
	
	# Separate required items from random pool
	var required_items: Array[InvItem] = []
	var random_items_pool: Array[InvItem] = []
	
	for item in items:
		if item.id == "bottle_juice" or item.id == "battery":
			required_items.append(item)
			print("Required item found: ", item.name)
		else:
			random_items_pool.append(item)
	
	print("Required items to spawn: ", required_items.size())
	print("Random items available: ", random_items_pool.size())
	
	# Calculate how many random items to spawn
	var random_items_to_spawn = total_items_to_spawn - required_items.size()
	
	if random_items_to_spawn > random_items_pool.size():
		random_items_to_spawn = random_items_pool.size()
		print("Not enough random items, spawning only ", random_items_to_spawn)
	
	# Shuffle random items
	random_items_pool.shuffle()
	var selected_random_items = random_items_pool.slice(0, random_items_to_spawn)
	
	# Combine required + selected random items
	var items_to_spawn = required_items + selected_random_items
	items_to_spawn.shuffle()  # Shuffle to mix required items with random ones
	
	print("Spawning ", items_to_spawn.size(), " items (", required_items.size(), " required, ", selected_random_items.size(), " random)")
	
	for item in items_to_spawn:
		var random_global_position = _get_random_position_in_rect(spawn_rect)
		var random_local_position = to_local(random_global_position)
		
		#print("Spawning ", item.name, " at local: ", random_local_position)
		
		var pickup = pickup_item_scene.instantiate()
		pickup.item = item
		pickup.position = random_local_position
		pickup.scale = Vector2(item.ui_scale.x, item.ui_scale.y)
		
		if random_rotation:
			pickup.rotation = randf_range(0, TAU)
		
		add_child(pickup)
		spawned_items.append(pickup)
	
	print("Spawned ", spawned_items.size(), " items")

func _on_item_collected():
	item_collected.emit()
	print("Item collected! Remaining: ", get_remaining_items())

func _get_spawn_area_rect() -> Rect2:
	var collision_shape = $CollisionShape2D
	if not collision_shape:
		return Rect2()
	
	var shape = collision_shape.shape
	if not shape:
		return Rect2()
	
	var extents: Vector2
	
	if shape is RectangleShape2D:
		extents = shape.size / 2
	elif shape is CircleShape2D:
		extents = Vector2(shape.radius, shape.radius)
	else:
		return Rect2()
	
	var shape_global_pos = collision_shape.global_position
	var top_left_global = shape_global_pos - extents
	var size = extents * 2
	
	return Rect2(top_left_global, size)

func _get_random_position_in_rect(rect: Rect2) -> Vector2:
	var x = randf_range(rect.position.x, rect.position.x + rect.size.x)
	var y = randf_range(rect.position.y, rect.position.y + rect.size.y)
	return Vector2(x, y)

func clear_items():
	for item in spawned_items:
		if is_instance_valid(item):
			item.queue_free()
	spawned_items.clear()

func respawn_items():
	clear_items()
	spawn_items()

func get_remaining_items() -> int:
	var count = 0
	for item in spawned_items:
		if is_instance_valid(item):
			count += 1
	return count
