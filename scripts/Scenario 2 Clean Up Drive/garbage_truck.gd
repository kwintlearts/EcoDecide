# garbage_truck.gd
extends StaticBody2D

signal items_disposed(count)

@onready var label: Label = $Label
@onready var notification_label: Label = $NotificationLabel
@onready var interaction: AudioStreamPlayer = $Interaction
@onready var error: AudioStreamPlayer = $Error

func _ready() -> void:
	add_to_group("garbage_truck")
	label.hide()
	notification_label.hide()

func empty_inventory():
	var player = get_tree().get_first_node_in_group("player")
	
	if not player or not player.has_method("collect"):
		print("No player found!")
		return
	
	var inv = player.inv
	
	if not inv:
		print("No inventory found!")
		return
	
	var items_emptied = 0
	var hazardous_items = 0
	var battery_found = false
	
	# First check if battery is in inventory and should be recycled properly
	for slot in inv.slots:
		if slot.item and slot.item.id == "battery" and GameState.did_choose("battery_recycled"):
			battery_found = true
			print("Battery must go to hazardous bin, not truck!")
	
	if battery_found:
		error.play()
		_show_notification("⚠️ Battery must go to HAZARDOUS bin! ⚠️", Color.RED)
		return  # Don't dispose anything if battery is in inventory
	
	# Check if player is using plastic sacks (only apply penalty if we actually empty items)
	var using_plastic_sacks = GameState.did_choose("plastic_bag")
	
	# Loop through all slots and clear them
	for slot in inv.slots:
		if slot.item:
			# RECORD THE DISPOSAL
			var is_hazardous = (slot.item.correct_bin == 0)
			GameState.record_disposal(slot.item.name, false, "TRUCK")
			
			if is_hazardous:
				print("Hazardous item disposed in truck (PENALTY): ", slot.item.name)
				hazardous_items += 1
			else:
				print("Truck collected: ", slot.item.name)
				items_emptied += 1
			
			slot.item = null
			interaction.play()
			
	GameState.is_bulk_disposal = true
	var total_items = items_emptied + hazardous_items
	
	if total_items > 0:
		get_tree().call_group("inventory_ui", "update_slots")
		
		# Apply plastic sack penalty ONLY if items were actually emptied
		if using_plastic_sacks:
			print("Plastic sacks detected! -5 environmental penalty")
			GameState.modify_env_health(-5)
		
		# Points: +5 for regular, -20 for hazardous (truck penalty)
		var points_earned = (items_emptied * 5) - (hazardous_items * 20)
		GameState.add_score(points_earned)
		
		# Environmental penalty for hazardous items in truck
		if hazardous_items > 0:
			GameState.modify_env_health(-15 * hazardous_items)
		
		_update_clogged_clarity()
		_show_notification("Truck emptied " + str(total_items) + " items!")
		GameState.record_bulk_disposal(total_items, items_emptied, hazardous_items)
		print("Truck emptied ", total_items, " items")
		print("Points: ", points_earned)
	else:
		print("Truck: No items to collect")
		_show_notification("No items to collect!", Color.ORANGE)
	
	GameState.is_bulk_disposal = false
	if total_items > 0:
		await get_tree().process_frame
		items_disposed.emit(total_items)

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
