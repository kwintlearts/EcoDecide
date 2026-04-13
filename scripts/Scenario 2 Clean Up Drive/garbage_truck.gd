# garbage_truck.gd
extends StaticBody2D
@onready var actionable: Area2D = $Actionable
@onready var garbage_shape: CollisionShape2D = $CollisionShape2D

signal items_disposed(count)

@onready var label: Label = $Label
@onready var notification_label: Label = $NotificationLabel
@onready var interaction: AudioStreamPlayer = $Interaction
@onready var error: AudioStreamPlayer = $Error
var is_processing: bool = false


func _ready() -> void:
	add_to_group("garbage_truck")
	label.hide()
	notification_label.hide()

func set_active(active: bool):
	if active:
		show()
		if actionable and garbage_shape:
			garbage_shape.disabled = false
			actionable.monitoring = true
			actionable.monitorable = true
	else:
		hide()
		if actionable and garbage_shape:
			garbage_shape.disabled = true
			actionable.monitoring = false
			actionable.monitorable = false

func empty_inventory():
	if is_processing:
		print("Already processing truck disposal, ignoring...")
		return
	
	is_processing = true
	
	var player = get_tree().get_first_node_in_group("player")
	
	if not player or not player.has_method("collect"):
		print("No player found!")
		is_processing = false
		return
	
	var inv = player.inv
	
	if not inv:
		print("No inventory found!")
		is_processing = false
		return
	
	var items_emptied = 0
	var hazardous_items = 0
	var battery_found = false
	
	# First check if battery is in inventory and should be recycled properly
	for slot in inv.slots:
		if slot.item and slot.item.id == "battery" and GameState.did_choose("battery_recycled"):
			battery_found = true
			print("Battery must go to hazardous bin, not truck!")
	
	if battery_found and GameState.did_choose("battery_recycled"):
		error.play()
		_show_notification("⚠️ Battery must go to HAZARDOUS bin! ⚠️", Color.RED)
		is_processing = false
		return
	
	var using_plastic_sacks = GameState.did_choose("plastic_bag")
	
	# Count items first
	for slot in inv.slots:
		if slot.item:
			if slot.item.correct_bin == 0:
				hazardous_items += 1
			else:
				items_emptied += 1
	
	var total_items = items_emptied + hazardous_items
	
	if total_items == 0:
		print("Truck: No items to collect")
		_show_notification("No items to collect!", Color.ORANGE)
		is_processing = false
		return
	
	# Actually clear the items
	for slot in inv.slots:
		if slot.item:
			if slot.item.correct_bin == 0:
				print("Hazardous item disposed in truck (PENALTY): ", slot.item.name)
			else:
				print("Truck collected: ", slot.item.name)
			
			slot.item = null
			interaction.play()
	
	get_tree().call_group("inventory_ui", "update_slots")
	
	if using_plastic_sacks:
		print("Plastic sacks detected! -5 environmental penalty")
		GameState.modify_env_health(-5)
	
	var points_earned = (items_emptied * 5) - (hazardous_items * 20)
	GameState.add_score(points_earned)
	
	if hazardous_items > 0:
		GameState.modify_env_health(-15 * hazardous_items)
	
	_update_clogged_clarity()
	_show_notification("Truck emptied " + str(total_items) + " items!")	
	
	GameState.record_bulk_disposal(total_items, items_emptied, hazardous_items)
	await get_tree().create_timer(0.3).timeout
	
	items_disposed.emit(total_items)
	
	print("Truck emptied ", total_items, " items")
	print("Points: ", points_earned)
	
	is_processing = false

func _show_notification(message: String, color: Color = Color.GREEN):
	if notification_label:
		notification_label.text = message
		notification_label.modulate = color
		notification_label.show()
		
		await get_tree().create_timer(2.0).timeout
		notification_label.hide()

func _update_clogged_clarity():
	var scene = get_tree().current_scene
	if scene and scene.has_method("update_clogged_clarity"):
		scene.update_clogged_clarity()

func _on_actionable_area_entered(area: Area2D) -> void:
	label.show()

func _on_actionable_area_exited(area: Area2D) -> void:
	label.hide()
