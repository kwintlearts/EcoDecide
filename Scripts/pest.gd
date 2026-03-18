extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_shape: CollisionShape2D = $detection_area/CollisionShape2D

var speed = 50
var health = 100
var damage = 10

var dead = false
var target_sapling: Node2D = null

# Wandering
var spawn_center: Vector2
var wander_radius: float = 150.0
var wander_target: Vector2
var state: String = "wandering"  # "wandering" or "chasing"
var change_target_timer: float = 0.0
const WANDER_INTERVAL: float = 2.0
const SCAN_INTERVAL: float = 1.0
var scan_timer: float = 0.0

func _ready():
	dead = false
	spawn_center = global_position  # Remember where we spawned
	pick_new_wander_target()

func _physics_process(delta: float) -> void:
	if dead:
		detection_shape.disabled = true
		return
	
	detection_shape.disabled = false
	
	# Scan for saplings periodically
	scan_timer += delta
	if scan_timer >= SCAN_INTERVAL:
		scan_timer = 0.0
		check_for_saplings()
	
	# State machine
	match state:
		"wandering":
			wander(delta)
		"chasing":
			chase()

func wander(delta: float) -> void:
	# Move toward wander target
	var direction = (wander_target - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	animated_sprite.play("move")
	
	# Check if reached target
	if global_position.distance_to(wander_target) < 10:
		pick_new_wander_target()
	
	# Or change target after timer
	change_target_timer += delta
	if change_target_timer >= WANDER_INTERVAL:
		change_target_timer = 0.0
		pick_new_wander_target()

func pick_new_wander_target() -> void:
	change_target_timer = 0.0
	# Random point within wander radius of spawn
	var angle = randf() * TAU
	var distance = randf() * wander_radius
	wander_target = spawn_center + Vector2(cos(angle), sin(angle)) * distance

func check_for_saplings() -> void:
	var saplings = get_tree().get_nodes_in_group("sapling")
	var nearest: Node2D = null
	var nearest_dist: float = INF
	
	for sapling in saplings:
		var dist = global_position.distance_to(sapling.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = sapling
	
	# Only chase if sapling is reasonably close (within 2x wander radius)
	if nearest and nearest_dist < wander_radius * 2:
		target_sapling = nearest
		state = "chasing"
		print("Pest switching to chase: ", nearest.name)

func chase() -> void:
	if not target_sapling or not is_instance_valid(target_sapling):
		state = "wandering"
		pick_new_wander_target()
		return
	
	var direction = (target_sapling.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	animated_sprite.play("move")
