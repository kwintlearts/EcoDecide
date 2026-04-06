extends CharacterBody2D

@export var speed: float = 100.0
@export var player: Node2D
@export var follow_distance := 40
@export var smooth_follow: float = 0.3  # Lower = smoother but slower

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var action_shape: CollisionShape2D = $Actionable/CollisionShape2D

var is_following: bool = false
var last_direction: String = "down"
var current_target: Vector2 = Vector2.ZERO

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

func _physics_process(_delta):
	if is_following and player:
		move_behind_player()

func move_behind_player():
	if not player:
		return
	
	# Calculate the target position behind the player
	var target_offset = Vector2.ZERO
	
	if player.has_method("get_facing_direction"):
		var facing = player.get_facing_direction()
		target_offset = facing * -follow_distance
	else:
		target_offset = Vector2(0, -follow_distance)
	
	var target_position = player.global_position + target_offset
	
	# Smoothly move toward target
	var new_position = global_position.lerp(target_position, 0.3)
	var direction = (new_position - global_position).normalized()
	
	# Only move if far enough
	var distance = global_position.distance_to(target_position)
	var is_moving = distance > 3  # Smaller threshold to prevent micro-movements
	
	if is_moving:
		# Update facing direction for animation
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				last_direction = "right"
			elif direction.x < 0:
				last_direction = "left"
		else:
			if direction.y > 0:
				last_direction = "down"
			elif direction.y < 0:
				last_direction = "up"
		
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	update_animation(is_moving)

func update_animation(is_moving: bool):
	if not animated_sprite:
		return
	
	if is_moving:
		animated_sprite.play("walk_" + last_direction)
	else:
		animated_sprite.play("idle_" + last_direction)
