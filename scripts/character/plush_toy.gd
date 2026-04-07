# plush_toy.gd - Simpler version
extends CharacterBody2D

@export var player: Node2D
@export var follow_distance := 40
@export var smooth_follow: float = 0.3

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var action_shape: CollisionShape2D = $Actionable/CollisionShape2D

var is_following: bool = false
var last_direction: String = "down"

func _ready():
	AnimationManager.register_character("PlushToy", animated_sprite)
	EventBus.plush_toy_met.connect(_on_plush_toy_met)

	if GameState.has_met_plush_toy:
		enable_following()
	

func _exit_tree():
	AnimationManager.unregister_character("PlushToy")
	if EventBus.plush_toy_met.is_connected(_on_plush_toy_met):
		EventBus.plush_toy_met.disconnect(_on_plush_toy_met)

func _on_plush_toy_met():
	print("Plush toy met signal received!")
	enable_following()

func enable_following():
	is_following = true
	collision_shape.disabled = true
	print("Plush toy is now following!")

func _physics_process(delta):
	if is_following and player:
		move_behind_player(delta)

func move_behind_player(delta):
	if not player:
		return
	
	# Get current speed from player
	var current_speed = _get_player_speed()
	
	# Calculate target position behind player
	var target_offset = Vector2.ZERO
	if player.has_method("get_facing_direction"):
		var facing = player.get_facing_direction()
		target_offset = facing * -follow_distance
	else:
		target_offset = Vector2(0, -follow_distance)
	
	var target_position = player.global_position + target_offset
	
	# Smooth movement
	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	if distance > 3:
		# Update facing direction
		if abs(direction.x) > abs(direction.y):
			last_direction = "right" if direction.x > 0 else "left"
		else:
			last_direction = "down" if direction.y > 0 else "up"
		
		velocity = direction * current_speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	update_animation(distance > 3)

func _get_player_speed() -> float:
	if not player:
		return 100.0
	
	# Check if player has is_sprinting property
	var is_sprinting = false
	if "is_sprinting" in player:
		is_sprinting = player.is_sprinting
	
	# Return appropriate speed
	if is_sprinting:
		return player.SPRINT_SPEED if "SPRINT_SPEED" in player else 200.0
	else:
		return player.SPEED if "SPEED" in player else 100.0

func update_animation(is_moving: bool):
	if not animated_sprite:
		return
	
	if is_moving:
		animated_sprite.play("walk_" + last_direction)
	else:
		animated_sprite.play("idle_" + last_direction)
