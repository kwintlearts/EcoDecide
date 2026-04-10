# player.gd
extends CharacterBody2D
# base Speed 50
# base sprint 80 

const BASE_SPEED = 50
const BASE_SPRINT_SPEED = 80
const ENERGY_REGEN_RATE = 2.5

const PLASTIC_SACK = preload("uid://cndy7pcxy0wir")
const WOVEN_SACK = preload("uid://buu65yaotstju")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var actionable_finder: Area2D = $Direction/ActionableFinder
@onready var direction: Marker2D = $Direction
@onready var inv_ui: Control = $Inv_UI

@export var inv: Inv

var speed_multiplier: float = 1.0
var input_vector: Vector2 = Vector2.ZERO
var current_highlight: Area2D = null
var facing_direction: String = "down"
var can_move: bool = true
var is_sprinting: bool = false

# Speed penalties based on bag choice
var SPEED = BASE_SPEED
var SPRINT_SPEED = BASE_SPRINT_SPEED
var movement_lock_timer: Timer

var last_interact_time: float = 0.0
const INTERACT_COOLDOWN: float = 0.5

func _ready():
	add_to_group("player")
	AnimationManager.register_character("Player", animated_sprite)
	
	movement_lock_timer = Timer.new()
	movement_lock_timer.one_shot = true
	movement_lock_timer.timeout.connect(_unlock_movement_safety)
	add_child(movement_lock_timer)
	
	# Apply speed penalty for woven sack (slower due to more capacity)
	if GameState.did_choose("woven_bag"):
		SPEED = BASE_SPEED * 0.7  # 30% slower
		SPRINT_SPEED = BASE_SPRINT_SPEED * 0.7
		print("Woven sack equipped: Speed reduced to ", SPEED)
	else:
		SPEED = BASE_SPEED
		SPRINT_SPEED = BASE_SPRINT_SPEED
		print("Plastic sack or default: Normal speed")
	
	# Register inventory with manager
	if inv:
		InventoryManager.set_player_inv(inv)

func _unlock_movement_safety():
	if not can_move:
		print("Safety: Unlocking player movement")
		can_move = true

func switch_to_plastic_sack():
	inv = PLASTIC_SACK.duplicate()
	InventoryManager.set_player_inv(inv)
	
	# Restore normal speed
	SPEED = BASE_SPEED
	SPRINT_SPEED = BASE_SPRINT_SPEED
	print("Switched to Plastic Sack - Speed restored to ", SPEED)
	
	# Refresh UI
	await get_tree().process_frame
	if inv_ui and inv_ui.has_method("refresh_inventory"):
		inv_ui.refresh_inventory()
	
	print("Switched to Plastic Sack inventory (10 slots)")

func switch_to_woven_sack():
	inv = WOVEN_SACK.duplicate()
	InventoryManager.set_player_inv(inv)
	
	# Apply speed penalty
	SPEED = BASE_SPEED * 0.7
	SPRINT_SPEED = BASE_SPRINT_SPEED * 0.7
	print("Switched to Woven Sack - Speed reduced to ", SPEED)
	
	# Refresh UI
	await get_tree().process_frame
	if inv_ui and inv_ui.has_method("refresh_inventory"):
		inv_ui.refresh_inventory()
	
	print("Switched to Woven Sack inventory (15 slots)")

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_interact_time < INTERACT_COOLDOWN:
			return
		last_interact_time = current_time
		
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action(self)
			get_viewport().set_input_as_handled()
	
	is_sprinting = Input.is_action_pressed("sprint") and GameState.energy > 0


func _physics_process(delta: float) -> void:
	if GameState.scenario_active and GameState.uses_timer and TimerManager.time_remaining <= 0:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if not can_move:
		#velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var previous_position = global_position
	
	if can_move:
		input_vector = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if input_vector.length() > 0:
		var current_speed = (SPRINT_SPEED if is_sprinting and GameState.energy > 0 else SPEED) * speed_multiplier
		velocity = input_vector * current_speed
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
	
	move_and_slide()
	
	var actual_movement = global_position - previous_position
	var is_actually_moving = actual_movement.length() > 0.1
	
	if is_actually_moving and input_vector.length() > 0:
		var drain_rate = 3.5 if is_sprinting else 1.5
		GameState.modify_energy(-drain_rate * delta)
		
		if GameState.energy <= 0 and is_sprinting:
			is_sprinting = false
	elif not is_actually_moving and input_vector.length() > 0:
		GameState.modify_energy(ENERGY_REGEN_RATE * delta )
	else:
		if GameState.energy < 100:
			GameState.modify_energy(ENERGY_REGEN_RATE * delta )
	
	update_animation(is_actually_moving)
	
func update_animation(is_actually_moving: bool = true):
	var is_moving = is_actually_moving and input_vector.length() > 0
	
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
	
	var animation_prefix = "sprint_" if is_sprinting and is_moving else "walk_" if is_moving else "idle_"
	
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
