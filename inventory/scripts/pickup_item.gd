# pickup_item.gd
@tool
extends StaticBody2D

@export var item: InvItem:
	set(value):
		if item != value:
			item = value
			_update_sprite()
			# Force editor refresh
			if Engine.is_editor_hint():
				notify_property_list_changed()

@export var collision_size_offset: Vector2 = Vector2.ZERO  # Optional offset for fine-tuning
@export var action_size_offset: float = 0.0  # Optional offset for action circle

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var action_shape: CollisionShape2D = $Actionable/CollisionShape2D
@onready var label: Label = $Label

var is_being_collected: bool = false

func _ready() -> void:
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
		label.add_theme_font_size_override("font_size", 8)
		
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.size = Vector2(112, 23)  # Fixed width, auto height
		
		# Position label above the item
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
		
		# Update label text based on item's correct bin
		_update_label_text()
		
	elif sprite:
		sprite.texture = null

func _update_label_text():
	if not label or not item:
		return
	
	var bin_name = _get_bin_name(item.correct_bin)
	var bin_color = _get_bin_color(item.correct_bin)
	
	label.text = "🗑️ " + bin_name
	label.add_theme_color_override("font_color", bin_color)

func _get_bin_name(bin_type: int) -> String:
	match bin_type:
		0:
			return "HAZARDOUS"
		1:
			return "RECYCLABLE"
		2:
			return "BIODEGRADABLE"
		3:
			return "RESIDUAL"
		4:
			return "RINSEABLE"
		_:
			return "UNKNOWN"

func _get_bin_color(bin_type: int) -> Color:
	match bin_type:
		0:
			return Color(1, 0.3, 0.3)  # Red - Hazardous
		1:
			return Color(0.3, 1, 0.3)  # Green - Recyclable
		2:
			return Color(0.3, 0.8, 1)  # Blue - Biodegradable
		3:
			return Color(1, 1, 0.3)    # Yellow - Residual
		4:
			return Color(1, 0.6, 1)    # Purple - Rinseable
		_:
			return Color.WHITE

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

# Add these functions for area enter/exit
func _on_actionable_area_entered(area: Area2D) -> void:
	if not Engine.is_editor_hint():
		if GameState.did_choose("rinsed_bottle") and GameState.current_scenario == 2:
			_show_label()
			

func _on_actionable_area_exited(area: Area2D) -> void:
	if not Engine.is_editor_hint():
		if GameState.did_choose("rinsed_bottle") and GameState.current_scenario == 2:
			_hide_label()

func _show_label():
	if label:
		label.visible = true
		# Optional: Add a little pop animation
		var tween = create_tween()
		tween.tween_property(label, "scale", Vector2(1.1, 1.1), 0.1)
		tween.tween_property(label, "scale", Vector2(1, 1), 0.1)

func _hide_label():
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
	#
	var success = player.collect(item)
	if success:
		print("Collected: ", item.name)
		
		# Notify scene that an item was collected
		var scene = get_tree().current_scene
		if scene and scene.has_method("_on_item_collected"):
			scene._on_item_collected()
		
		queue_free()
	else:
		print("Inventory full! Cannot collect: ", item.name)
		is_being_collected = false  # Reset so player can try again
	
	return success

func get_item_dialogue():
	if item and item.has_dialogue and item.dialogue_resource:
		return {
			"dialogue_resource": item.dialogue_resource,
			"dialogue_start": item.dialogue_start
		}
	return null
