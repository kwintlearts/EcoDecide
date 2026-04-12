# youth_student.gd
extends StaticBody2D

@onready var label: Label = $Label
var has_collected_battery: bool = false

func _ready() -> void:
	label.add_theme_font_size_override("font_size", 16)
	
	_update_emoji_from_choice()
	GameState.stats_updated.connect(_on_stats_updated)

func _on_stats_updated():
	_update_emoji_from_choice()
	
	# Skip if already collected
	if has_collected_battery:
		return
	
	# Check if battery was just ignored and youth is helping
	if GameState.did_choose("battery_ignored"):
		if GameState.did_choose("youth_joined") or GameState.did_choose("grandson_help"):
			await get_tree().create_timer(4).timeout
			_collect_ignored_battery()

func _update_emoji_from_choice():
	if GameState.did_choose("grandson_help") and GameState.did_choose("youth_joined"):
		label.text = "👩🧹"
	elif GameState.did_choose("youth_asked"):
		_show_temporary_emoji("😒🧹", 120)
	elif GameState.did_choose("youth_lectured"):
		label.text = "😤"
	elif GameState.did_choose("youth_joined"):
		label.text = "🧹"
	else:
		label.text = "❗"

func _show_temporary_emoji(emoji: String, duration: float = 2.0):
	label.text = emoji
	label.show()
	await get_tree().create_timer(duration).timeout
	label.hide()

# In youth_student.gd and vendor.gd
func _collect_ignored_battery():
	if has_collected_battery:
		return
	
	has_collected_battery = true
	
	var spawner = get_tree().get_first_node_in_group("spawner")
	if spawner:
		for item in spawner.spawned_items:
			if is_instance_valid(item) and item.item and item.item.id == "battery":
				item.queue_free()
				print("Youth collected the ignored battery!")
				
				EventBus.npc_collected_battery.emit("Youth")
				
				GameState.add_score(10)
				GameState.total_disposals += 1
				GameState.battery_handled_by_npc = true
				
				# Trigger completion check in the scene
				var scene = get_tree().current_scene
				if scene and scene.has_method("aaaacheck_completion"):
					scene.check_completion()
				
				return
