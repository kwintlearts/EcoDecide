# plush_toy.gd
extends CharacterBody2D

@export var player: Node2D
@export var follow_distance := 40
@export var smooth_follow: float = 0.3

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var feedback_label: Label = $FeedBackLabel
@onready var actionable: Area2D = $Actionable
@onready var action_shape: CollisionShape2D = $Actionable/CollisionShape2D

var is_following: bool = false
var last_direction: String = "down"
var feedback_timer: Timer
var last_feedback_time: float = 0.0
const FEEDBACK_COOLDOWN: float = 2.0
var is_showing_feedback: bool = false
var last_disposal_timestamp: int = 0
var is_priority_message: bool = false

func _ready():
	AnimationManager.register_character("PlushToy", animated_sprite)
	EventBus.plush_toy_met.connect(_on_plush_toy_met)
	EventBus.npc_collected_battery.connect(_on_npc_collected_battery)  # Add this
	
	GameState.stats_updated.connect(_on_disposal_recorded)
	
	feedback_timer = Timer.new()
	feedback_timer.one_shot = true
	feedback_timer.wait_time = 3.0
	feedback_timer.timeout.connect(_hide_feedback)
	add_child(feedback_timer)
	
	feedback_label.hide()
	
	if GameState.has_met_plush_toy:
		enable_following()
	else:
		# Before meeting, keep actionable area active
		_disable_actionable_area(false)

func _on_npc_collected_battery(npc_name: String):
	print("Plush toy received signal from: ", npc_name)
	
	# Set priority flag
	is_priority_message = true
	
	# Reset cooldown
	last_feedback_time = 0
	
	var message = "🙌 " + npc_name + " took care of the battery!"
	
	# Stop any current feedback
	if feedback_timer.is_inside_tree():
		feedback_timer.stop()
	
	# Clear the label and show new message
	feedback_label.text = message
	feedback_label.show()
	feedback_label.scale = Vector2(1.0, 1.0)
	
	var tween = create_tween()
	tween.tween_property(feedback_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(feedback_label, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Start a longer timer for priority message
	feedback_timer.start(3.0)
	
	# Reset priority flag after timer
	await feedback_timer.timeout
	is_priority_message = false

func _disable_actionable_area(disabled: bool):
	if actionable:
		actionable.monitoring = not disabled
		actionable.monitorable = not disabled
	if action_shape:
		action_shape.disabled = disabled

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
	_disable_actionable_area(true)
	print("Plush toy is now following!")

func _on_disposal_recorded():
	if is_priority_message:
		print("Skipping disposal feedback - priority message showing")
		return
		
	if GameState.disposal_log.is_empty():
		return
	
	var last_disposal = GameState.disposal_log[-1]
	
	#if last_disposal.get("category") == "Bulk":
		#var total = last_disposal.get("total_items", 0)
		#var regular = last_disposal.get("regular_items", 0)
		#var hazardous = last_disposal.get("hazardous_items", 0)
		#
		#var message = "🚛 Truck emptied %d items" % total
		#if hazardous > 0:
			#message += " (⚠️ %d hazardous items penalized)" % hazardous
		#_show_feedback("")
		#return

	if last_disposal.get("bin") == "TRUCK":
		print("Skipping truck disposal feedback")
		return
	
	var timestamp = last_disposal.get("timestamp", 0)
	
	if timestamp == last_disposal_timestamp:
		return
	
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_feedback_time < FEEDBACK_COOLDOWN:
		return
	
	last_disposal_timestamp = timestamp
	last_feedback_time = current_time
	
	var item_name = last_disposal["item"]
	var was_correct = last_disposal["correct"]
	var bin_type = last_disposal["bin"]
	var category = last_disposal.get("category", "Other")
	
	var message = _get_feedback_message(item_name, was_correct, bin_type, category)
	_show_feedback(message)

func _get_feedback_message(item_name: String, was_correct: bool, bin_type: String, category: String) -> String:
	if was_correct:
		match bin_type:
			"RECYCLABLE":
				return "♻️ Nice! That can become something new."
			"BIODEGRADABLE":
				return "🌱 Back to the earth. That's the cycle of life."
			"RESIDUAL":
				return "🗑️ Some things really do belong here."
			"HAZARDOUS":
				return "⚠️ Safely disposed. Good call."
			_:
				return "✅ Correct!"
	else:
		# Category-based educational feedback
		match category:
			"Food":
				return "🌿 Tip: Food waste belongs in the BIODEGRADABLE bin!"
			"Plastic":
				return "♻️ Tip: Clean plastic items go to RECYCLABLE. If dirty, RINSE first!"
			"Glass":
				return "🥤 Tip: Glass is 100% recyclable! Put clean glass in RECYCLABLE."
			"Paper":
				return "📦 Tip: Clean paper and cardboard go to RECYCLABLE. Greasy ones go to RESIDUAL."
			"Metal":
				return "🥫 Tip: Metal cans are recyclable! Put them in RECYCLABLE."
			"Electronic":
				return "🔋 Tip: Electronics and batteries are HAZARDOUS waste!"
			"Organic":
				return "🌱 Tip: Flowers and plants go in the BIODEGRADABLE bin."
			"Ceramic":
				return "🏺 Tip: Ceramics are not recyclable. They go in RESIDUAL bin."
			_:
				# Fallback to item name based tips
				if item_name.contains("bottle") or item_name.contains("milk tea") or item_name.contains("juice"):
					return "💡 Tip: Rinse containers first, then put them in RECYCLABLE."
				elif item_name.contains("battery"):
					return "🔋 Tip: Batteries are HAZARDOUS waste. Special bin needed."
				elif item_name.contains("plate") or item_name.contains("cup"):
					return "♻️ Tip: Clean plastic and glass belong in RECYCLABLE."
				elif item_name.contains("paper") or item_name.contains("cardboard"):
					return "📦 Tip: Clean paper and cardboard go to RECYCLABLE."
				elif item_name.contains("mug") or item_name.contains("ceramic"):
					return "🏺 Tip: Ceramics and dishes go to RESIDUAL."
				else:
					return "💡 Every item has a proper place."

func _show_feedback(message: String):
	is_showing_feedback = true
	
	if feedback_timer.is_inside_tree():
		feedback_timer.stop()
	
	feedback_label.text = message
	feedback_label.show()
	feedback_label.scale = Vector2(1.0, 1.0)
	
	var tween = create_tween()
	tween.tween_property(feedback_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(feedback_label, "scale", Vector2(1.0, 1.0), 0.1)
	
	feedback_timer.start(2.5)

func _hide_feedback():
	if not feedback_label.visible:
		return
	
	print("Hiding feedback now")
	feedback_label.hide()
	is_showing_feedback = false

func _physics_process(delta):
	if is_following and player:
		move_behind_player(delta)

func move_behind_player(delta):
	if not player:
		return
	
	var current_speed = _get_player_speed()
	
	var target_offset = Vector2.ZERO
	if player.has_method("get_facing_direction"):
		var facing = player.get_facing_direction()
		target_offset = facing * -follow_distance
	else:
		target_offset = Vector2(0, -follow_distance)
	
	var target_position = player.global_position + target_offset
	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	if distance > 3:
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
	
	var is_sprinting = false
	if "is_sprinting" in player:
		is_sprinting = player.is_sprinting
	
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
