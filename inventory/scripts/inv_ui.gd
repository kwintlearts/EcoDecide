# inv_ui.gd
extends Control

var inv
@onready var nine_patch: NinePatchRect = $NinePatchRect
@onready var grid: GridContainer = $NinePatchRect/GridContainer
@onready var slot_scene = preload("res://inventory/scene/inv_ui_slot.tscn")

var padding: Vector2 = Vector2(4, 4)

var is_open = false
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready():
	await get_tree().process_frame
	inv = InventoryManager.get_player_inv()
	
	if inv:
		add_to_group("inventory_ui")
		inv.update.connect(update_slots)
		_build_slots()
		_resize_background() 
		update_slots()
		
		# Connect signals
		InventoryManager.item_cleaned.connect(_on_item_cleaned)
		InventoryManager.inventory_full.connect(show_inventory_full_warning)  # Add this line
	else:
		print("ERROR: No inventory found in InventoryManager!")
	
	close()
	mouse_filter = Control.MOUSE_FILTER_STOP

func refresh_inventory():
	print("Refreshing inventory UI...")
	inv = InventoryManager.get_player_inv()
	
	if inv:
		print("New inventory has ", inv.slots.size(), " slots")
		
		# Disconnect old signal if any
		if inv.update.is_connected(update_slots):
			inv.update.disconnect(update_slots)
		
		# Connect new signal
		inv.update.connect(update_slots)
		
		# Rebuild UI
		_build_slots()
		_resize_background()
		update_slots()
	else:
		print("ERROR: No inventory found in InventoryManager!")

func _on_item_cleaned(clean_item: InvItem):
	# Find the slot with the cleaned item and flash it
	for slot in grid.get_children():
		if slot.slot_data and slot.slot_data.item == clean_item:
			var tween = create_tween()
			tween.tween_property(slot, "modulate", Color.GREEN, 0.2)
			tween.tween_property(slot, "modulate", Color.WHITE, 0.2)
			break
			
func show_inventory_full_warning():
	# Flash the inventory UI red
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.2)
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
			
func _resize_background():
	if not inv:
		print("Cannot resize: inv is null")
		return
	
	var slot_count = inv.slots.size()
	
	if slot_count == 3:
		padding = Vector2(4,4)
		nine_patch.size = Vector2(64,24)
		self.position = Vector2(-32.5,-40)
	elif slot_count == 10:
		padding = Vector2(4,6)
		nine_patch.size = Vector2(104, 48)
		self.position = Vector2(-52.5,-65)
	elif slot_count == 15:
		padding = Vector2(5,5)
		nine_patch.size = Vector2(106, 66)
		self.position = Vector2(-52.5,-80)
	else:
		print("Unknown slot count: ", slot_count)
		return
	
	grid.position = padding

func _build_slots():
	if not inv:
		print("Cannot build slots: inv is null")
		return
	
	for child in grid.get_children():
		child.queue_free()
	
	for i in inv.slots.size():
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("inventory"):
		toggle_inventory()


func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
		else:
			dragging = false
		get_viewport().set_input_as_handled()
	
	if event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - drag_offset

func toggle_inventory():
	if is_open: close()
	else: open()

func update_slots():
	if not inv:
		return
	
	var slots = grid.get_children()
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

func open():
	visible = true
	is_open = true

func close():
	visible = false
	is_open = false
