# pickup_item.gd
@tool
extends StaticBody2D

@export var item: InvItem:
	set(value):
		if item != value:
			item = value
			_update_sprite()
			if Engine.is_editor_hint():
				notify_property_list_changed()

@export var collision_size_offset: Vector2 = Vector2.ZERO
@export var action_size_offset: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var action_shape: CollisionShape2D = $Actionable/CollisionShape2D
@onready var label: Label = $Label

@onready var pick_up: AudioStreamPlayer = $PickUp
@onready var error: AudioStreamPlayer = $Error


var is_being_collected: bool = false

func _ready() -> void:
	
	label.hide()
	if Engine.is_editor_hint():
		await get_tree().process_frame
	_update_sprite()
	_update_collision_shape()
	_setup_label()

func _setup_label():
	if label:
		label.visible = false
		label.add_theme_color_override("font_color", Color.WHITE)
		label.add_theme_color_override("font_shadow_color", Color.BLACK)
		label.add_theme_font_size_override("font_size", 14)
		label.size = Vector2(60,20)
		label.text = "📦 Take?"
		label.position = Vector2(-30, -40)

func _update_sprite():
	if not sprite:
		sprite = $Sprite2D
	
	if sprite and item:
		if item.atlas_texture:
			sprite.texture = item.atlas_texture
		elif item.texture:
			sprite.texture = item.texture
		else:
			sprite.texture = null
		
		_update_collision_shape()
		
	elif sprite:
		sprite.texture = null

func _update_collision_shape():
	if not collision_shape or not action_shape:
		return
	
	if sprite and sprite.texture:
		var texture_size = sprite.texture.get_size()
		
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = texture_size + collision_size_offset
		collision_shape.shape = rect_shape
		collision_shape.position = Vector2.ZERO
		
		var circle_shape = CircleShape2D.new()
		var radius = max(texture_size.x, texture_size.y) / 2
		circle_shape.radius = radius + action_size_offset
		action_shape.shape = circle_shape
		action_shape.position = Vector2.ZERO
	else:
		collision_shape.shape = null
		action_shape.shape = null

func _on_actionable_area_entered(area: Area2D) -> void:
	if not Engine.is_editor_hint():
		# Only react to the player's detector area
		if area.is_in_group("player_detector"):
			if GameState.did_choose("rinsed_bottle") and GameState.scenario_active and GameState.current_scenario == 2 and item and item.correct_bin == 1:
				_show_bonus_label()
			else:
				_show_label()

func _on_actionable_area_exited(area: Area2D) -> void:
	if not Engine.is_editor_hint():
		_hide_label()
		_hide_bonus_label()

func _show_bonus_label():
	if label:
		label.text = "✨ +5 BONUS! ✨"
		label.add_theme_color_override("font_color", Color.YELLOW)
		label.visible = true
		
		var tween = create_tween()
		tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(label, "scale", Vector2(1, 1), 0.1)

func _show_label():
	if label:
		if GameState.scenario_active:
			label.text = "📦 Take?"
		else:
			label.text = "Scenario is not active!"
		label.add_theme_color_override("font_color", Color.WHITE)
		label.visible = true
		
		var tween = create_tween()
		tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(label, "scale", Vector2(1, 1), 0.1)

func _hide_label():
	if label:
		label.visible = false

func _hide_bonus_label():
	if label:
		label.visible = false

func playercollect(player):
	if Engine.is_editor_hint():
		return false
	
	if is_being_collected:
		print("Already collecting this item, ignoring...")
		return false
	
	if not GameState.scenario_active:
		print("No active scenario! Cannot pick up items.")
		return false
	
	var success = player.collect(item)
	if success:
		print("Collected: ", item.name)
		
		# Play pickup sound - simpler approach, don't reparent
		if pick_up:
			pick_up.play()
		
		queue_free()
	else:
		if error:
			error.play()
		print("Inventory full! Cannot collect: ", item.name)
		is_being_collected = false
	
	return success

func get_item_dialogue():
	if item and item.has_dialogue and item.dialogue_resource:
		return {
			"dialogue_resource": item.dialogue_resource,
			"dialogue_start": item.dialogue_start
		}
	return null
