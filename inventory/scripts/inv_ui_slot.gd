# inv_ui_slot.gd
extends Panel

@onready var item_visual: Sprite2D = $CenterContainer/Panel/item_display

enum SlotMode {
	INVENTORY,
	TRASH,
	RINSE,
}

enum BinType {
	HAZARDOUS,
	RECYCLABLE,
	BIODEGRADABLE,
	RESIDUAL,
	RINSEABLE
}

@export var mode: SlotMode = SlotMode.INVENTORY
@export var bin_type: BinType = BinType.RECYCLABLE
@onready var label: Label = $Label

const _6_PX_NORMAL = preload("uid://vb3qdyxh8m5i")

var slot_data: InvSlot
var is_processing: bool = false
var rinse_item: InvItem = null  # Local storage for rinse station

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_MOVE
	set_process_unhandled_input(true)
	
	gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Left click or tap
		_show_item_description()
	elif event is InputEventScreenTouch and event.pressed:
		# Touch screen tap
		_show_item_description()

func _show_item_description():
	if slot_data and slot_data.item and slot_data.item.description:
		# Use the existing label
		label.text = slot_data.item.name+": " + "\n"+ slot_data.item.description
		label.visible = true
		
		# Auto-hide after 2 seconds
		await get_tree().create_timer(2.0).timeout
		label.visible = false


func update(slot: InvSlot):
	label.visible = false
	if mode == SlotMode.RINSE:
		# For rinse station, use local storage
		slot_data = null
		if rinse_item:
			item_visual.visible = true
			if rinse_item.atlas_texture:
				item_visual.texture = rinse_item.atlas_texture
			else:
				item_visual.texture = rinse_item.texture
			if rinse_item.ui_scale:
				item_visual.scale = rinse_item.ui_scale
			else:
				item_visual.scale = Vector2(1, 1)
		else:
			item_visual.visible = false
	else:
		# For inventory/trash, use slot_data
		slot_data = slot
		if !slot or !slot.item:
			item_visual.visible = false
		else:
			item_visual.visible = true
			if slot.item.atlas_texture:
				item_visual.texture = slot.item.atlas_texture
			else:
				item_visual.texture = slot.item.texture
			if slot.item.ui_scale:
				item_visual.scale = slot.item.ui_scale
			else:
				item_visual.scale = Vector2(1, 1)

func _get_drag_data(at_position):
	if mode == SlotMode.TRASH or is_processing:
		return null
	
	if mode == SlotMode.RINSE:
		# For rinse station, drag from local storage
		if !rinse_item:
			return null
		
		var preview = TextureRect.new()
		if rinse_item.atlas_texture:
			preview.texture = rinse_item.atlas_texture
		else:
			preview.texture = rinse_item.texture
		
		preview.z_index = 10
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		var base_size = Vector2(16, 16)
		if rinse_item.ui_scale:
			base_size = base_size * rinse_item.ui_scale
		
		preview.custom_minimum_size = base_size
		set_drag_preview(preview)
		
		# Return a custom object with the item data and source reference
		return {"item": rinse_item, "is_rinse_item": true, "source_slot": self}
	
	else:
		# For inventory slots
		if !slot_data or !slot_data.item:
			return null
		
		var preview = TextureRect.new()
		if slot_data.item.atlas_texture:
			preview.texture = slot_data.item.atlas_texture
		else:
			preview.texture = slot_data.item.texture
		
		preview.z_index = 10
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		var base_size = Vector2(16, 16)
		if slot_data.item.ui_scale:
			base_size = base_size * slot_data.item.ui_scale
		
		preview.custom_minimum_size = base_size
		set_drag_preview(preview)
		
		return slot_data


func _can_drop_data(at_position, data):
	if is_processing:
		return false
	
	if mode == SlotMode.TRASH:
		return data is InvSlot and data.item != null
	
	if mode == SlotMode.RINSE:
		# ONLY allow items that can be rinsed
		return not rinse_item and data is InvSlot and data.item != null and data.item.can_rinsed
	
	if mode == SlotMode.INVENTORY:
		if data is InvSlot and data.item != null:
			return true
		if typeof(data) == TYPE_DICTIONARY and data.has("is_rinse_item") and data.is_rinse_item:
			return true
		return false
	
	return false

func _drop_data(at_position, data):
	if is_processing:
		return
		
	if mode == SlotMode.INVENTORY:
		# Handle dropping from rinse station (Dictionary)
		if typeof(data) == TYPE_DICTIONARY and data.has("is_rinse_item") and data.is_rinse_item:
			# Moving from rinse station to inventory
			if slot_data.item == null:
				# Empty slot, just move the item
				slot_data.item = data.item
				# Clear the rinse station
				var rinse_slot = data.get("source_slot", null)
				if rinse_slot:
					rinse_slot.rinse_item = null
					rinse_slot.update(null)
				print("Moved from rinse station to inventory: ", data.item.name)
			else:
				print("Inventory slot not empty!")
			get_tree().call_group("inventory_ui", "update_slots")
			return
		
		# Handle swapping between inventory slots (InvSlot)
		if data is InvSlot:
			var temp = slot_data.item
			slot_data.item = data.item
			data.item = temp
			get_tree().call_group("inventory_ui", "update_slots")
			return
	
	# RINSE SECTION
	elif mode == SlotMode.RINSE:
		# Only allow items that can be rinsed
		if data is InvSlot and data.item and data.item.can_rinsed and data.item.rinse_version:
			# Start rinsing process
			is_processing = true
			
			# Lock player movement
			_lock_player_movement(true)
			
			# Cost energy to rinse
			GameState.modify_energy(-5)
			
			print("Rinsing: ", data.item.name)
			
			# Move item from player inventory to rinse station local storage
			rinse_item = data.item
			data.item = null
			
			# Update both UIs
			get_tree().call_group("inventory_ui", "update_slots")
			update(null)
			
			# Visual feedback - start pulsing
			var original_scale = item_visual.scale
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(item_visual, "scale", original_scale * 1.1, 0.5)
			tween.tween_property(item_visual, "scale", original_scale, 0.5)
			
			# Wait for rinse time
			await get_tree().create_timer(5).timeout
			
			# Stop pulsing animation
			tween.kill()
			item_visual.scale = original_scale
			
			# Use the direct resource reference
			var clean_item = rinse_item.rinse_version
			if clean_item:
				rinse_item = clean_item.duplicate()
				print("Rinsing complete! Item cleaned: ", rinse_item.name)
				
				# Award points for rinsing (bonus when you recycle the clean item)
				GameState.add_score(5)  # Small bonus for rinsing effort
				GameState.modify_energy(-5)  # Energy already spent above
				
				update(null)
				
				# Flash green to show completion
				var flash_tween = create_tween()
				flash_tween.tween_property(self, "modulate", Color.GREEN, 0.2)
				flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
			else:
				print("Failed to get rinse version!")
			
			# Unlock badge for rinsing
			if not GameState.unlocked_badges.has("Clean Stream"):
				GameState.unlock_badge("Clean Stream")
			
			# Unlock player movement
			_lock_player_movement(false)
			is_processing = false
			
		else:
			# Item cannot be rinsed - show error message
			print("This item cannot be rinsed!")
			var flash_tween = create_tween()
			flash_tween.tween_property(self, "modulate", Color.RED, 0.2)
			flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
			return
	
	# TRASH SECTION
	elif mode == SlotMode.TRASH:
		if data is InvSlot and data.item:
			var is_correct = (data.item.correct_bin == bin_type)
			
			# Record the disposal
			GameState.record_disposal(data.item.name, is_correct, BinType.keys()[bin_type])
			
			if is_correct:
				# CORRECT DISPOSAL - Award points based on bin type
				match bin_type:
					BinType.RECYCLABLE:
						GameState.add_score(10)
						GameState.modify_env_health(3)
						print("Correctly recycled: +10 points, +3 env health")
						
					BinType.BIODEGRADABLE:
						GameState.add_score(15)
						GameState.modify_env_health(5)
						print("Correctly composted: +15 points, +5 env health")
						
					BinType.RESIDUAL:
						GameState.add_score(10)
						GameState.modify_env_health(1)
						print("Correctly disposed in residual: +10 points")
						
					BinType.HAZARDOUS:
						GameState.add_score(5)
						GameState.modify_env_health(1)
						
						print("Hazardous waste safely disposed")
						
					BinType.RINSEABLE:
						GameState.add_score(5)
						print("Clean item recycled: +5 points")
				
				# Bonus for clean recyclables (items that were rinsed)
				if bin_type == BinType.RECYCLABLE and (data.item.id.contains("clean") or data.item.id.contains("rinsed")):
					GameState.add_score(5)
					print("Bonus for rinsing before recycling: +5 points")
				
				data.item = null
				
			else:
				# WRONG BIN - Apply penalties based on bin type
				match bin_type:
					BinType.RECYCLABLE:
						GameState.add_score(-20)
	
						GameState.modify_env_health(-10)
						print("Wrong bin! Recyclable contaminated: -20 points,  -10 env health")
						
					BinType.BIODEGRADABLE:
						GameState.add_score(-25)
	
						GameState.modify_env_health(-8)
						print("Wrong bin! Biodegradable misplaced: -25 points,")
						
					BinType.RESIDUAL:
						GameState.add_score(-10)
						GameState.modify_env_health(-3)
						print("Wrong bin! Residual bin misused: -10 points")
						
					BinType.HAZARDOUS:
						GameState.add_score(-50)
						GameState.modify_env_health(-30)
						print("HAZARDOUS MISPLACEMENT! -50 points, -30 env health")
						
					BinType.RINSEABLE:
						GameState.add_score(-15)

						print("Rinseable bin misused: -15 points")
				
				# Special penalty for food waste in wrong bin (smell effect)
				if data.item.id.contains("food") or data.item.id.contains("banana") or data.item.correct_bin == BinType.BIODEGRADABLE:
					GameState.modify_env_health(-5)

					print("Food waste in wrong bin causes smell: -5 env health, ")
				
				data.item = null
			
			get_tree().call_group("inventory_ui", "update_slots")

func _lock_player_movement(locked: bool):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = not locked
		if locked:
			print("Player movement LOCKED during rinsing")
		else:
			print("Player movement UNLOCKED")

func can_drag() -> bool:
	if mode == SlotMode.RINSE:
		return not is_processing and rinse_item != null
	return not is_processing and mode != SlotMode.TRASH
