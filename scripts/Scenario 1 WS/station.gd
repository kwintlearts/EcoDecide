# station.gd
@tool
extends StaticBody2D

enum StationType {
	HAZARDOUS,
	RECYCLABLE,
	BIODEGRADABLE,
	RESIDUAL,
	RINSE
}

@export var station_type: StationType = StationType.RECYCLABLE:
	set(value):
		if station_type != value:
			station_type = value
			_update_station_appearance()

@onready var station_ui: Control = $StationUI
@onready var actionable: Area2D = $Actionable
@onready var slot: Panel = $StationUI/NinePatchRect/GridContainer/StationUISlot
@onready var label: Label = $StationUI/Label

var is_animating: bool = false
var current_tween: Tween = null

func _ready() -> void:
	if not Engine.is_editor_hint():
		station_ui.hide()
		station_ui.scale = Vector2(0, 0)
	
	_update_station_appearance()
	
	if slot and not Engine.is_editor_hint():
		match station_type:
			StationType.HAZARDOUS:
				slot.mode = slot.SlotMode.TRASH
				slot.bin_type = slot.BinType.HAZARDOUS
			StationType.RECYCLABLE:
				slot.mode = slot.SlotMode.TRASH
				slot.bin_type = slot.BinType.RECYCLABLE
			StationType.BIODEGRADABLE:
				slot.mode = slot.SlotMode.TRASH
				slot.bin_type = slot.BinType.BIODEGRADABLE
			StationType.RESIDUAL:
				slot.mode = slot.SlotMode.TRASH
				slot.bin_type = slot.BinType.RESIDUAL
			StationType.RINSE:
				slot.mode = slot.SlotMode.RINSE
				slot.bin_type = slot.BinType.RINSEABLE
	
	if actionable and not Engine.is_editor_hint():
		actionable.area_entered.connect(_on_actionable_area_entered)
		actionable.area_exited.connect(_on_actionable_area_exited)

func _update_station_appearance():
	if label:
		match station_type:
			StationType.HAZARDOUS:
				label.text = "HAZARDOUS"
				label.modulate = Color(3.168, 2.965, 0.0)
			StationType.RECYCLABLE:
				label.text = "RECYCLABLE"
				label.modulate = Color(0.2, 0.839, 1.0)
			StationType.BIODEGRADABLE:
				label.text = "BIODEGRADABLE"
				label.modulate = Color(0.623, 2.223, 0.13)
			StationType.RESIDUAL:
				label.text = "RESIDUAL"
				label.modulate = Color(0.282, 0.298, 0.0)  
			StationType.RINSE:
				label.text = "RINSE"
				label.modulate = Color(1.0, 1.0, 1.0, 1.0) 
	
	if slot and Engine.is_editor_hint():
		match station_type:
			StationType.HAZARDOUS:
				slot.mode = slot.SlotMode.TRASH
				slot.bin_type = slot.BinType.HAZARDOUS
			StationType.RECYCLABLE:
				slot.mode = slot.SlotMode.TRASH
				slot.bin_type = slot.BinType.RECYCLABLE
			StationType.BIODEGRADABLE:
				slot.mode = slot.SlotMode.TRASH
				slot.bin_type = slot.BinType.BIODEGRADABLE
			StationType.RESIDUAL:
				slot.mode = slot.SlotMode.TRASH
				slot.bin_type = slot.BinType.RESIDUAL
			StationType.RINSE:
				slot.mode = slot.SlotMode.RINSE
				slot.bin_type = slot.BinType.RINSEABLE

func _on_actionable_area_entered(_area: Area2D) -> void:
	if not Engine.is_editor_hint() and not is_animating and not station_ui.visible:
		show_with_animation()

func _on_actionable_area_exited(_area: Area2D) -> void:
	if not Engine.is_editor_hint():
		# Only hide if not processing and UI is visible
		if slot and not slot.is_processing and station_ui.visible:
			hide_with_animation()

func show_with_animation():
	if is_animating:
		return
	
	# Kill any existing tween
	if current_tween:
		current_tween.kill()
	
	is_animating = true
	station_ui.visible = true
	station_ui.scale = Vector2(0, 0)
	
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_OUT)
	current_tween.set_trans(Tween.TRANS_BACK)
	
	# Pop-up animation: scale from 0 to 1 with bounce
	current_tween.tween_property(station_ui, "scale", Vector2(1.2, 1.2), 0.15)
	current_tween.tween_property(station_ui, "scale", Vector2(0.9, 0.9), 0.1)
	current_tween.tween_property(station_ui, "scale", Vector2(1.0, 1.0), 0.1)
	
	#await current_tween.finished
	is_animating = false
	current_tween = null

func hide_with_animation():
	if is_animating:
		return
	
	# Kill any existing tween
	if current_tween:
		current_tween.kill()
	
	is_animating = true
	
	current_tween = create_tween()
	current_tween.set_ease(Tween.EASE_IN)
	current_tween.set_trans(Tween.TRANS_BACK)
	
	# Shrink animation
	current_tween.tween_property(station_ui, "scale", Vector2(0.9, 0.9), 0.1)
	current_tween.tween_property(station_ui, "scale", Vector2(0, 0), 0.15)
	
	await current_tween.finished
	station_ui.visible = false
	station_ui.scale = Vector2(0, 0)
	is_animating = false
	current_tween = null

func take_back_item():
	if slot and slot.rinse_item:
		var item = slot.rinse_item
		var player = get_tree().get_first_node_in_group("player")
		if player and player.collect(item):
			slot.rinse_item = null
			slot.update(null)
			return true
	return false

func retrieve_item():
	if slot and slot.slot_data and slot.slot_data.item:
		var item = slot.slot_data.item
		var player = get_tree().get_first_node_in_group("player")
		if player and player.collect(item):
			slot.slot_data.item = null
			slot.update(slot.slot_data)
			return true
	return false
