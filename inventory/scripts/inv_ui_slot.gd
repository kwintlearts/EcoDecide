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

const _6_PX_NORMAL = preload("uid://vb3qdyxh8m5i")

var slot_data: InvSlot
var is_processing: bool = false
var rinse_item: InvItem = null
var description_timer: Timer

signal item_selected(item_name, item_description, item)  # Add item parameter
const CAN_DROP = preload("uid://cgslqmoofgmbw")
const DRAG = preload("uid://b6rjp6l4tsyeu")
@onready var interaction: AudioStreamPlayer = $Interaction
@onready var error: AudioStreamPlayer = $Error
@onready var pick_up: AudioStreamPlayer = $PickUp
@onready var rinsing: AudioStreamPlayer = $Rinsing
@onready var rinse_complete_label: Label = $RinseCompleteLabel

# Store original cursor to restore
var original_cursor: Texture2D = null

func _ready():
	mouse_default_cursor_shape = Control.CURSOR_MOVE
	set_process_unhandled_input(true)
	
		# Hide rinse complete label initially
	if rinse_complete_label:
		rinse_complete_label.hide()
		rinse_complete_label.add_theme_color_override("font_color", Color.GREEN)
		rinse_complete_label.add_theme_color_override("font_shadow_color", Color.BLACK)
		rinse_complete_label.add_theme_font_size_override("font_size", 14)

	
	description_timer = Timer.new()
	description_timer.one_shot = true
	add_child(description_timer)

func _show_rinse_complete_message():
	if rinse_complete_label:
		rinse_complete_label.text = "✨ Item Cleaned! ✨"
		rinse_complete_label.show()
		rinse_complete_label.scale = Vector2(0.5, 0.5)
		
		# Pop animation
		var tween = create_tween()
		tween.tween_property(rinse_complete_label, "scale", Vector2(1.2, 1.2), 0.1)
		tween.tween_property(rinse_complete_label, "scale", Vector2(1.0, 1.0), 0.1)
		
		# Hide after 2 seconds
		await get_tree().create_timer(2.0).timeout
		rinse_complete_label.hide()


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_show_item_description()
	elif event is InputEventScreenTouch and event.pressed:
		_show_item_description()

func _show_item_description():
	if slot_data and slot_data.item:
		item_selected.emit(slot_data.item.name, slot_data.item.description, slot_data.item)  # Pass item
		
func update(slot: InvSlot):
	if mode == SlotMode.RINSE:
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
		if !rinse_item:
			return null
		
		var preview = TextureRect.new()
		if rinse_item.atlas_texture:
			preview.texture = rinse_item.atlas_texture
		else:
			preview.texture = rinse_item.texture
		
		preview.z_index = 100
		preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		
		var base_size = Vector2(16, 16)
		if rinse_item.ui_scale:
			base_size = base_size * rinse_item.ui_scale
		
		preview.custom_minimum_size = base_size
		set_drag_preview(preview)
		
		return {"item": rinse_item, "is_rinse_item": true, "source_slot": self}
	
	else:
		if !slot_data or !slot_data.item:
			return null
		
		var preview = TextureRect.new()
		if slot_data.item.atlas_texture:
			preview.texture = slot_data.item.atlas_texture
		else:
			preview.texture = slot_data.item.texture
		
		preview.z_index = 100
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
		if typeof(data) == TYPE_DICTIONARY and data.has("is_rinse_item") and data.is_rinse_item:
			if slot_data.item == null:
				slot_data.item = data.item
				var rinse_slot = data.get("source_slot", null)
				if rinse_slot:
					rinse_slot.rinse_item = null
					rinse_slot.update(null)
				print("Moved from rinse station to inventory: ", data.item.name)
				interaction.play()
			else:
				print("Inventory slot not empty!")
			get_tree().call_group("inventory_ui", "update_slots")
			return
		
		if data is InvSlot:
			var temp = slot_data.item
			slot_data.item = data.item
			data.item = temp
			interaction.play()
			get_tree().call_group("inventory_ui", "update_slots")
			return
	
	elif mode == SlotMode.RINSE:
		if data is InvSlot and data.item and data.item.can_rinsed and data.item.rinse_version:
			is_processing = true
			_lock_player_movement(true)
			GameState.modify_energy(-5)
			
			print("Rinsing: ", data.item.name)
			
			rinse_item = data.item
			data.item = null
			
			get_tree().call_group("inventory_ui", "update_slots")
			update(null)
			
			var original_scale = item_visual.scale
			var tween = create_tween()
			tween.set_loops()
			tween.tween_property(item_visual, "scale", original_scale * 1.1, 0.5)
			tween.tween_property(item_visual, "scale", original_scale, 0.5)
			rinsing.play()
			await get_tree().create_timer(5).timeout
			rinsing.stop()
			
			tween.kill()
			item_visual.scale = original_scale
			
			var clean_item = rinse_item.rinse_version
			if clean_item:
				rinse_item = clean_item.duplicate()
				print("Rinsing complete! Item cleaned: ", rinse_item.name)
				
				GameState.add_score(5)
				GameState.modify_energy(-5)
				
				update(null)
				
				_show_rinse_complete_message()
				
				var flash_tween = create_tween()
				flash_tween.tween_property(self, "modulate", Color.GREEN, 0.2)
				flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
				
				pick_up.play()
			else:
				print("Failed to get rinse version!")
				error.play()
				
			
			if not GameState.unlocked_badges.has("Clean Stream"):
				GameState.unlock_badge("Clean Stream")
			
			_lock_player_movement(false)
			is_processing = false
			
		else:
			print("This item cannot be rinsed!")
			var flash_tween = create_tween()
			flash_tween.tween_property(self, "modulate", Color.RED, 0.2)
			flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
			error.play()
			
			return
	
	elif mode == SlotMode.TRASH:
		if data is InvSlot and data.item:
			
			if data.item.id == "bottle_juice" and GameState.did_choose("rinsed_bottle"):
				print("Cannot dispose dirty bottle! Must rinse it first!")
				var flash_tween = create_tween()
				flash_tween.tween_property(self, "modulate", Color.RED, 0.2)
				flash_tween.tween_property(self, "modulate", Color.WHITE, 0.2)
				
				error.play()
				
				return
		
			var is_correct = (data.item.correct_bin == bin_type)
			
			GameState.record_disposal(data.item.name, is_correct, BinType.keys()[bin_type], data.item.category)
			
			if is_correct:
				match bin_type:
					BinType.RECYCLABLE:
						GameState.add_score(10)
						GameState.modify_env_health(3)
						
					BinType.BIODEGRADABLE:
						GameState.add_score(15)
						GameState.modify_env_health(5)
						
					BinType.RESIDUAL:
						GameState.add_score(10)
						GameState.modify_env_health(1)
						
					BinType.HAZARDOUS:
						GameState.add_score(5)
						GameState.modify_env_health(2)
						
					BinType.RINSEABLE:
						GameState.add_score(5)
				
				if bin_type == BinType.RECYCLABLE and (data.item.id.contains("clean") or data.item.id.contains("rinsed")):
					GameState.add_score(5)
				
				data.item = null
				interaction.play()
				
			else:
				match bin_type:
					BinType.RECYCLABLE:
						GameState.add_score(-10)
						GameState.modify_env_health(-10)
						
					BinType.BIODEGRADABLE:
						GameState.add_score(-15)
						GameState.modify_env_health(-8)
						
					BinType.RESIDUAL:
						GameState.add_score(-5)
						GameState.modify_env_health(-3)
						
					BinType.HAZARDOUS:
						GameState.add_score(-25)
						GameState.modify_env_health(-25)
						
				
				data.item = null
				error.play()
				
			
			get_tree().call_group("inventory_ui", "update_slots")

func _lock_player_movement(locked: bool):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = not locked

func can_drag() -> bool:
	if mode == SlotMode.RINSE:
		return not is_processing and rinse_item != null
	return not is_processing and mode != SlotMode.TRASH
