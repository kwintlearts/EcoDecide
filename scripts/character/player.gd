# player.gd
extends CharacterBody2D
const SPEED = 100.0
const SPRINT_SPEED = 200.0
const ENERGY_REGEN_RATE = 0.5

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var actionable_finder: Area2D = $Direction/ActionableFinder
@onready var direction: Marker2D = $Direction
@onready var inv_ui: Control = $Inv_UI

@export var inv: Inv

var input_vector: Vector2 = Vector2.ZERO
var current_highlight: Area2D = null
var facing_direction: String = "down"
var can_move: bool = true
var is_sprinting: bool = false

func _ready():
	add_to_group("player")
	AnimationManager.register_character("Player", animated_sprite)
	
	if inv:
		InventoryManager.set_player_inv(inv)

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("action"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action(self)
			get_viewport().set_input_as_handled()
	
	is_sprinting = Input.is_action_pressed("sprint") and GameState.energy > 0
		
	var x_axis: float = Input.get_axis("move_left", "move_right")
	var y_axis: float = Input.get_axis("move_up", "move_down")

	if can_move:
		if x_axis:
			input_vector = x_axis * Vector2.RIGHT
		elif y_axis:
			input_vector = y_axis * Vector2.DOWN
		else:
			input_vector = Vector2.ZERO
	else:
		input_vector = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if GameState.scenario_active and GameState.uses_timer and TimerManager.time_remaining <= 0:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if not can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	# Store previous position to check if actually moving
	var previous_position = global_position
	
	if input_vector.length() > 0:
		var current_speed = SPRINT_SPEED if is_sprinting and GameState.energy > 0 else SPEED
		velocity = input_vector * current_speed
		
		# Energy drain only if actually moving (will check after move_and_slide)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	# Apply movement
	move_and_slide()
	
	# Check if we actually moved (not blocked by wall)
	var actual_movement = global_position - previous_position
	var is_actually_moving = actual_movement.length() > 0.1
	
	# Apply energy drain/regeneration based on actual movement
	if is_actually_moving and input_vector.length() > 0:
		var drain_rate = 3.0 if is_sprinting else 1.5
		GameState.modify_energy(-drain_rate * delta)
		
		# Prevent sprinting when energy is low
		if GameState.energy <= 0 and is_sprinting:
			is_sprinting = false
	elif not is_actually_moving and input_vector.length() > 0:
		# Player is trying to move but blocked by wall
		# Small energy penalty for bumping into wall? (optional)
		pass
	else:
		# Standing still - regenerate energy
		if GameState.energy < 100:
			GameState.modify_energy(ENERGY_REGEN_RATE * delta)
	
	update_animation(is_actually_moving)
	
func update_animation(is_actually_moving: bool = true):
	# Use actual movement for animation, not velocity
	var is_moving = is_actually_moving and input_vector.length() > 0
	
	var animation_prefix = "sprint_" if is_sprinting and is_moving else "walk_" if is_moving else "idle_"
	
	if abs(input_vector.x) > abs(input_vector.y):
		if input_vector.x > 0:
			facing_direction = "right"
			direction.rotation = -PI / 2
		elif input_vector.x < 0:
			facing_direction = "left"
			direction.rotation = PI / 2
	elif abs(input_vector.y) > 0:
		if input_vector.y > 0:
			facing_direction = "down"
			direction.rotation = 0
		elif input_vector.y < 0:
			facing_direction = "up"
			direction.rotation = PI
	
	# Fallback for missing animations
	if not animated_sprite.sprite_frames.has_animation(animation_prefix + facing_direction):
		animation_prefix = "walk_" if is_moving else "idle_"
	
	animated_sprite.play(animation_prefix + facing_direction)

func player():
	pass

func collect(item):
	var success = inv.insert(item)
	if not success:
		print("Cannot collect ", item.name, " - inventory is full!")
		if !inv_ui.is_open:
			inv_ui.open()

		InventoryManager.notify_inventory_full()

		
	return success

func get_facing_direction() -> Vector2:
	match facing_direction:
		"right":
			return Vector2.RIGHT
		"left":
			return Vector2.LEFT
		"up":
			return Vector2.UP
		"down":
			return Vector2.DOWN
		_:
			return Vector2.DOWN
