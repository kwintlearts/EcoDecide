# vendor.gd - Timer-based
extends CharacterBody2D

const SPEED = 100.0

var is_leaving: bool = false
var walk_direction: int = 1

@export var teleport_location: Vector2 = Vector2(385, -112.0)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	EventBus.vendor_confronted.connect(_on_vendor_confronted)
	if animated_sprite:
		animated_sprite.play("idle_down")

func _on_vendor_confronted():
	leave()

func leave():
	is_leaving = true
	if collision_shape:
		collision_shape.disabled = true
	
	if animated_sprite:
		animated_sprite.play("walk_left_right")
	
	# Teleport after 3 seconds
	await get_tree().create_timer(3.0).timeout
	global_position = teleport_location
	is_leaving = false
	
	# Switch back to idle animation after teleporting
	if animated_sprite:
		animated_sprite.play("idle_down")
	
	# Optional: Disable physics completely
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	if not is_leaving:
		return
	
	walk_direction = -1 if animated_sprite.flip_h else 1
	velocity.x = walk_direction * SPEED
	move_and_slide()
