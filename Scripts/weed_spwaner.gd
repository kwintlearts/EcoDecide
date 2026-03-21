extends Area2D

@export var weed_scene: PackedScene   # assign Weed.tscn (StaticBody2D)
@export var spawn_interval: float = 3.0
@export var spawn_radius: float = 100.0

var timer: float = 0.0

func _process(delta: float) -> void:
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_weed()

func spawn_weed() -> void:
	# Get all saplings inside the Area2D
	var saplings = get_overlapping_bodies()
	if saplings.is_empty():
		return
	
	# Pick a random sapling
	var sapling = saplings[randi() % saplings.size()]
	
	# Random offset around sapling
	var angle = randf() * TAU
	var distance = randf() * spawn_radius
	var offset = Vector2(cos(angle), sin(angle)) * distance
	
	# Instance weed
	var weed = weed_scene.instantiate()
	weed.global_position = sapling.global_position + offset
	get_tree().current_scene.add_child(weed)
	
	print("Spawned weed near: ", sapling.name)
