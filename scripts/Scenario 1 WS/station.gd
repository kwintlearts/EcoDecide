# station.gd
@tool  # Add this to enable editor functionality
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

func _ready() -> void:
	if not Engine.is_editor_hint():
		station_ui.hide()
	
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
	# Update label text based on station type
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
	
	# Update slot appearance in editor too
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
	if not Engine.is_editor_hint():
		station_ui.show()

func _on_actionable_area_exited(_area: Area2D) -> void:
	if not Engine.is_editor_hint():
		# Only hide if not processing
		if slot and not slot.is_processing:
			station_ui.hide()

# Method to take item back from rinse station
func take_back_item():
	if slot and slot.rinse_item:  # For rinse station, check rinse_item instead of slot_data
		var item = slot.rinse_item
		var player = get_tree().get_first_node_in_group("player")
		if player and player.collect(item):
			slot.rinse_item = null
			slot.update(null)
			return true
	return false

# For trash stations, check slot_data
func retrieve_item():
	if slot and slot.slot_data and slot.slot_data.item:
		var item = slot.slot_data.item
		var player = get_tree().get_first_node_in_group("player")
		if player and player.collect(item):
			slot.slot_data.item = null
			slot.update(slot.slot_data)
			return true
	return false
