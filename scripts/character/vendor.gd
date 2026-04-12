# vendor.gd
extends CharacterBody2D

const SPEED = 100.0

var is_leaving: bool = false
var walk_direction: int = 1

@export var teleport_location: Vector2 = Vector2(385, -112.0)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var label: Label = $Label
var has_collected_battery: bool = false

func _ready():
	label.add_theme_font_size_override("font_size", 16)
	
	if animated_sprite:
		animated_sprite.play("idle_down")
	
	_update_emoji_from_choice()
	GameState.stats_updated.connect(_on_stats_updated)

func _on_stats_updated():
	_update_emoji_from_choice()
	
	# Check if battery was just ignored and vendor was educated
	if not has_collected_battery and GameState.did_choose("battery_ignored"):
		if GameState.did_choose("educated_vendor"):
			await get_tree().create_timer(7).timeout

			_collect_ignored_battery()

func _collect_ignored_battery():
	if has_collected_battery:
		return
	
	has_collected_battery = true
	
	var spawner = get_tree().get_first_node_in_group("spawner")
	if spawner:
		for item in spawner.spawned_items:
			if is_instance_valid(item) and item.item and item.item.id == "battery":
				item.queue_free()
				print("Vendor collected the ignored battery!")
				
				EventBus.npc_collected_battery.emit("Vendor")
				
				GameState.add_score(10)
				GameState.total_disposals += 1
				GameState.battery_handled_by_npc = true
				
				# Trigger completion check in the scene
				var scene = get_tree().current_scene
				if scene and scene.has_method("check_completion"):
					scene.check_completion()
				
				return


func _update_emoji_from_choice():
	if GameState.did_choose("educated_vendor"):
		label.text = "😊👍"
	elif GameState.did_choose("confront_vendor"):
		label.text = "😠"
		leave()
	elif GameState.did_choose("ignore_vendor"):
		label.text = "😒"
	else:
		label.text = "❗"

	

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
