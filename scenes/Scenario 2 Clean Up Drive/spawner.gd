# spawner.gd
extends Area2D

signal item_collected

@export var items: Array[InvItem]
@export var total_items_to_spawn: int = 30
@export var random_rotation: bool = true  # Enable random rotation
@export var random_scale: bool = false
@export var scale_range: Vector2 = Vector2(1, 1)

@export var pickup_item_scene: PackedScene

var spawned_items: Array = []

func _ready():
	spawn_items()

func spawn_items():
	clear_items()
	
	var spawn_rect = _get_spawn_area_rect()
	if spawn_rect.size.x == 0 or spawn_rect.size.y == 0:
		print("Error: Spawn area has no size!")
		return
	
	if not pickup_item_scene:
		print("Error: No pickup_item_scene assigned!")
		return
	
	if items.is_empty():
		print("Error: No items assigned to spawner!")
		return
	
	print("Total items available in array: ", items.size())
	
	var items_to_spawn = items.duplicate()
	items_to_spawn.shuffle()
	
	if items_to_spawn.size() > total_items_to_spawn:
		items_to_spawn = items_to_spawn.slice(0, total_items_to_spawn)
	
	print("Spawning ", items_to_spawn.size(), " unique items")
	
	for item in items_to_spawn:
		print("  - ", item.name)
	
	for item in items_to_spawn:
		var random_position = _get_random_position_in_rect(spawn_rect)
		
		var pickup = pickup_item_scene.instantiate()
		pickup.item = item
		pickup.global_position = random_position
		
		# Apply 0.3 scale to all items
		pickup.scale = Vector2(0.5, 0.5)
		
		# Apply random rotation
		if random_rotation:
			pickup.rotation = randf_range(0, TAU)  # TAU = full circle (360 degrees)
		
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
	var extents: Vector2
	
	if shape is RectangleShape2D:
		extents = shape.size / 2
	elif shape is CircleShape2D:
		extents = Vector2(shape.radius, shape.radius)
	else:
		return Rect2()
	
	var area_position = collision_shape.global_position
	var top_left = area_position - extents
	var size = extents * 2
	
	return Rect2(top_left, size)

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
