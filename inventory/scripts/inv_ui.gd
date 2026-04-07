# inv_ui.gd
extends Control

var inv
@onready var nine_patch: NinePatchRect = $NinePatchRect
@onready var grid: GridContainer = $NinePatchRect/GridContainer
@onready var slot_scene = preload("res://inventory/scene/inv_ui_slot.tscn")
@onready var item_info: Control = $ItemInfo

var padding: Vector2 = Vector2(4, 4)

var is_open = false
var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

func _ready():
	await get_tree().process_frame
	inv = InventoryManager.get_player_inv()
	if item_info:
		item_info.visible = false
		
	if inv:
		add_to_group("inventory_ui")
		inv.update.connect(update_slots)
		_build_slots()
		_resize_background() 
		update_slots()
		
		InventoryManager.item_cleaned.connect(_on_item_cleaned)
		InventoryManager.inventory_full.connect(show_inventory_full_warning)
	else:
		print("ERROR: No inventory found in InventoryManager!")
	
	close()
	mouse_filter = Control.MOUSE_FILTER_STOP

func show_item_info(item_name: String, item_description: String):
	if item_info:
		item_info.visible = true
		item_info.update_info(item_name, item_description)
		
		# Position item info relative to inventory UI
		_update_item_info_position()
		
		await get_tree().create_timer(3.0).timeout
		item_info.visible = false

func _update_item_info_position():
	if not item_info or not inv:
		return
	
	var slot_count = inv.slots.size()
	var info_width = item_info.size.x
	var info_height = item_info.size.y
	
	match slot_count:
		3:
			# Position above the 3-slot inventory
			item_info.position = Vector2(-info_width/2, -info_height + 25)
		10:
			# Position above the 10-slot inventory
			item_info.position = Vector2(-info_width/2, -info_height + 50)
		15:
			# Position above the 15-slot inventory
			item_info.position = Vector2(-info_width/2, -info_height  + 65)
		_:
			item_info.position = Vector2(-info_width/2, -info_height - 5)

func refresh_inventory():
	print("Refreshing inventory UI...")
	inv = InventoryManager.get_player_inv()
	
	if inv:
		print("New inventory has ", inv.slots.size(), " slots")
		
		if inv.update.is_connected(update_slots):
			inv.update.disconnect(update_slots)
		
		inv.update.connect(update_slots)
		
		_build_slots()
		_resize_background()
		update_slots()
		
		# Update item info position for new capacity
		_update_item_info_position()
	else:
		print("ERROR: No inventory found in InventoryManager!")

func _on_item_cleaned(clean_item: InvItem):
	for slot in grid.get_children():
		if slot.slot_data and slot.slot_data.item == clean_item:
			var tween = create_tween()
			tween.tween_property(slot, "modulate", Color.GREEN, 0.2)
			tween.tween_property(slot, "modulate", Color.WHITE, 0.2)
			break
			
func show_inventory_full_warning():
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
	
	# Update item info position after resize
	_update_item_info_position()

func _build_slots():
	if not inv:
		return
	
	for child in grid.get_children():
		child.queue_free()
	
	for i in inv.slots.size():
		var slot = slot_scene.instantiate()
		slot.item_selected.connect(_on_item_selected)
		grid.add_child(slot)
	
func _on_item_selected(item_name: String, item_description: String):
	show_item_info(item_name, item_description)
	
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
		# Update item info position when dragging inventory
		_update_item_info_position()

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
	_update_item_info_position()

func close():
	visible = false
	is_open = false
