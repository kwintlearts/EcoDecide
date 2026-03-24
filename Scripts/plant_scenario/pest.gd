extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_shape: CollisionShape2D = $detection_area_sapling/CollisionShape2D
@onready var damage_timer: Timer = $DamageTimer  # Add this node

var speed = 50
var health = 100
var damage = 10
var damage_interval: float = 1.0  # Damage every second

var dead = false
var target_sapling: Node2D = null
var current_target: Node2D = null  # What we're currently attacking

# Wandering
var spawn_center: Vector2
var wander_radius: float = 150.0
var wander_target: Vector2
var state: String = "wandering"
var change_target_timer: float = 0.0
const WANDER_INTERVAL: float = 2.0
const SCAN_INTERVAL: float = 1.0
var scan_timer: float = 0.0

func _ready():
	dead = false
	spawn_center = global_position
	pick_new_wander_target()
	
	damage_timer.wait_time = damage_interval
	damage_timer.timeout.connect(_on_damage_timer)

func _physics_process(delta: float) -> void:
	if dead:
		detection_shape.disabled = true
		return
	
	detection_shape.disabled = false
	
	scan_timer += delta
	if scan_timer >= SCAN_INTERVAL:
		scan_timer = 0.0
		check_for_saplings()
	
	match state:
		"wandering":
			wander(delta)
		"chasing":
			chase()
		"attacking":
			attack()

func wander(delta: float) -> void:
	var direction = (wander_target - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	animated_sprite.play("move")
	
	if global_position.distance_to(wander_target) < 10:
		pick_new_wander_target()
	
	change_target_timer += delta
	if change_target_timer >= WANDER_INTERVAL:
		pick_new_wander_target()

func pick_new_wander_target() -> void:
	change_target_timer = 0.0
	var angle = randf() * TAU
	var distance = randf() * wander_radius
	wander_target = spawn_center + Vector2(cos(angle), sin(angle)) * distance

func check_for_saplings() -> void:
	if target_sapling:  # Already have target, don't switch
		return
	
	var saplings = get_tree().get_nodes_in_group("sapling")
	var nearest: Node2D = null
	var nearest_dist: float = INF
	
	for sapling in saplings:
		if sapling.is_dead:
			continue
		var dist = global_position.distance_to(sapling.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = sapling
	
	if nearest and nearest_dist < wander_radius * 2:
		target_sapling = nearest
		state = "chasing"

func chase() -> void:
	if not target_sapling or not is_instance_valid(target_sapling) or target_sapling.is_dead:
		target_sapling = null
		state = "wandering"
		return
	
	var dist = global_position.distance_to(target_sapling.global_position)
	
	# Close enough to attack?
	if dist < 20:  # Attack range
		state = "attacking"
		current_target = target_sapling
		damage_timer.start()
		return
	
	# Chase
	var direction = (target_sapling.global_position - global_position).normalized()
	velocity = direction * speed
	move_and_slide()
	#animated_sprite.play("move")

func attack() -> void:
	velocity = Vector2.ZERO
	#animated_sprite.play("attack")
	
	# Check if target still valid
	if not current_target or not is_instance_valid(current_target) or current_target.is_dead:
		damage_timer.stop()
		state = "wandering"
		target_sapling = null
		current_target = null
		return

func _on_damage_timer() -> void:
	if current_target and current_target.has_method("take_damage"):
		current_target.take_damage(damage)

func remove_pest() -> void:
	Gamestate.points += 15
	queue_free()
