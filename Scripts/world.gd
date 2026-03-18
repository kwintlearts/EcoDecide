extends Node2D

@onready var light: DirectionalLight2D = $Lighting/light
@onready var tint: CanvasModulate = $Lighting/Tint
@export var spawn_area: Area2D
@export var pest_scene: PackedScene
@export var max_pests_per_day: int = 3

func _ready():
	print("World _ready()")
	print("Spawn area: ", spawn_area)
	print("Pest scene: ", pest_scene)
	Gamestate.time_changed.connect(_on_time_changed)
	Gamestate.day_changed.connect(_on_day_changed)
	_on_time_changed(Gamestate.time)

func _on_time_changed(time: float) -> void:
	var light_intensity = (cos((time - 0.5) * TAU) + 1.0) / 2.0
	light_intensity = clamp(light_intensity, 0.2, 1.0)
	
	light.energy = light_intensity
	
	var day_color = Color(1.0, 0.95, 0.8)
	var night_color = Color(0.2, 0.3, 0.5)
	tint.color = night_color.lerp(day_color, light_intensity)

func _on_day_changed(day: int) -> void:
	print("Day changed to: ", day)
	print("Current pests: ", get_tree().get_nodes_in_group("pest").size())
	spawn_pests_for_day(day)

func spawn_pests_for_day(day: int) -> void:
	var count = mini(day, max_pests_per_day)
	print("Spawning ", count, " pests")
	for i in count:
		print("Spawning pest #", i + 1)
		spawn_pest_in_area()

func spawn_pest_in_area() -> void:
	if not spawn_area:
		push_error("Spawn area is null!")
		return
	if not pest_scene:
		push_error("Pest scene is null!")
		return
	
	print("Spawn area position: ", spawn_area.global_position)
	
	var collision_shape = spawn_area.get_node_or_null("CollisionShape2D")
	if not collision_shape:
		push_error("No CollisionShape2D found in spawn_area!")
		return
	
	print("Collision shape found")
	
	var shape = collision_shape.shape
	if not shape:
		push_error("Shape is null!")
		return
	
	print("Shape type: ", shape.get_class())
	
	if not shape is RectangleShape2D:
		push_error("Shape is not RectangleShape2D, it's: ", shape.get_class())
		return
	
	var rect: RectangleShape2D = shape
	var size = rect.size
	var center = spawn_area.global_position
	
	print("Spawn size: ", size, " center: ", center)
	
	var random_pos = Vector2(
		randf_range(center.x - size.x/2, center.x + size.x/2),
		randf_range(center.y - size.y/2, center.y + size.y/2)
	)
	
	print("Spawning at: ", random_pos)
	
	var pest = pest_scene.instantiate()
	pest.z_index = 10
	pest.global_position = random_pos
	add_child(pest)
	print("Pest spawned! Children count: ", get_child_count())
	print(pest.z_index)
