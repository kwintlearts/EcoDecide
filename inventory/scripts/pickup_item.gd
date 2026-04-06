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

func _ready() -> void:
	if Engine.is_editor_hint():
		# In editor, wait a frame for everything to load
		await get_tree().process_frame
	_update_sprite()
	_update_collision_shape()

func _update_sprite():
	if not sprite:
		sprite = $Sprite2D
	
	if sprite and item:
		# Prioritize atlas_texture over texture
		if item.atlas_texture:
			sprite.texture = item.atlas_texture
		elif item.texture:
			sprite.texture = item.texture
		else:
			sprite.texture = null
		
		# Update collision shape when texture changes
		_update_collision_shape()
	elif sprite:
		sprite.texture = null

func _update_collision_shape():
	if not collision_shape or not action_shape:
		return
	
	if sprite and sprite.texture:
		# Get the texture size (AtlasTexture returns the region size automatically)
		var texture_size = sprite.texture.get_size()
		
		# Create a rectangle shape for physics collision
		var rect_shape = RectangleShape2D.new()
		rect_shape.size = texture_size + collision_size_offset
		collision_shape.shape = rect_shape
		collision_shape.position = Vector2.ZERO
		
		# Create a circle shape for interaction area
		var circle_shape = CircleShape2D.new()
		var radius = max(texture_size.x, texture_size.y) / 2
		circle_shape.radius = radius + action_size_offset
		action_shape.shape = circle_shape
		action_shape.position = Vector2.ZERO
	else:
		collision_shape.shape = null
		action_shape.shape = null

func playercollect(player):
	if Engine.is_editor_hint():
		return false
	
	# Check if scenario is active
	if not GameState.scenario_active:
		print("No active scenario! Cannot pick up items.")
		return false
	
	var success = player.collect(item)
	if success:
		print("Collected: ", item.name)
		queue_free()
	else:
		print("Inventory full! Cannot collect: ", item.name)
	
	return success

func get_item_dialogue():
	if item and item.has_dialogue and item.dialogue_resource:
		return {
			"dialogue_resource": item.dialogue_resource,
			"dialogue_start": item.dialogue_start
		}
	return null
