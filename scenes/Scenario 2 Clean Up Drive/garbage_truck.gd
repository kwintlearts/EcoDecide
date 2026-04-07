# garbage_truck.gd
extends StaticBody2D

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
	
	# Check if player is using plastic sacks
	var using_plastic_sacks = GameState.did_choose("plastic_bag")
	
	if using_plastic_sacks:
		print("Plastic sacks detected! -5 environmental penalty")
		GameState.modify_env_health(-5)
	
	# Loop through all slots and clear them
	for slot in inv.slots:
		if slot.item:
			# Check if item is hazardous (correct_bin == 0 for Hazardous)
			if slot.item.correct_bin == 0:
				print("Hazardous item disposed in truck (PENALTY): ", slot.item.name)
				hazardous_items += 1
			else:
				print("Truck collected: ", slot.item.name)
				items_emptied += 1
			
			slot.item = null
	
	var total_items = items_emptied + hazardous_items
	
	if total_items > 0:
		get_tree().call_group("inventory_ui", "update_slots")
		
		# Points: +5 for regular, -20 for hazardous (truck penalty)
		var points_earned = (items_emptied * 5) - (hazardous_items * 20)
		GameState.add_score(points_earned)
		
		# Environmental penalty for hazardous items in truck
		if hazardous_items > 0:
			GameState.modify_env_health(-15 * hazardous_items)
		
		# Update clogged area clarity
		_update_clogged_clarity()
		
		print("Truck emptied ", total_items, " items (", items_emptied, " regular, ", hazardous_items, " hazardous - PENALTY applied)")
		print("Points: ", points_earned)
	else:
		print("Truck: No items to collect")

func _update_clogged_clarity():
	var scene = get_tree().current_scene
	if scene and scene.has_method("update_clogged_clarity"):
		scene.update_clogged_clarity()
