# vendor.gd
extends CharacterBody2D

const SPEED = 100.0

var is_leaving: bool = false
var walk_direction: int = 1

@export var teleport_location: Vector2 = Vector2(385, -112.0)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label

func _ready():
	label.add_theme_font_size_override("font_size", 16)
	
	if animated_sprite:
		animated_sprite.play("idle_down")
	
	# Initial check
	_update_emoji_from_choice()
	
	# Connect to stats_updated to refresh when choices are made
	GameState.stats_updated.connect(_update_emoji_from_choice)

func _update_emoji_from_choice():
	if GameState.did_choose("educated_vendor"):
		label.text = "😊👍"
		label.show()
	elif GameState.did_choose("confront_vendor"):
		label.text = "😠"
		label.show()
		leave()
	elif GameState.did_choose("ignore_vendor"):
		label.text = "😒"
		label.show()
	else:
		label.hide()

func leave():
	is_leaving = true
	if collision_shape:
		collision_shape.disabled = true
	
	if animated_sprite:
		animated_sprite.play("walk_left_right")
	
	await get_tree().create_timer(3.0).timeout
	global_position = teleport_location
	is_leaving = false
	
	if animated_sprite:
		animated_sprite.play("idle_down")
	
	set_physics_process(false)
	label.hide()

func _physics_process(delta: float) -> void:
	if not is_leaving:
		return
	
	walk_direction = -1 if animated_sprite.flip_h else 1
	velocity.x = walk_direction * SPEED
	move_and_slide()
