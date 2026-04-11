# youth_student.gd
extends StaticBody2D

@onready var label: Label = $Label

func _ready() -> void:
	label.add_theme_font_size_override("font_size", 16)
	
	# Initial check
	_update_emoji_from_choice()
	
	# Connect to stats_updated to refresh when choices are made
	GameState.stats_updated.connect(_update_emoji_from_choice)

func _update_emoji_from_choice():
	if GameState.did_choose("youth_joined"):
		label.text = "🧹"

	elif GameState.did_choose("youth_asked"):
		_show_temporary_emoji("🧹", 120)
	elif GameState.did_choose("youth_lectured"):
		label.text = "😤"

	elif GameState.did_choose("grandson_help"):
		label.text = "🧹"

	else:
		label.text = "❗"


func _show_temporary_emoji(emoji: String, duration: float = 2.0):
	label.text = emoji
	label.show()
	await get_tree().create_timer(duration).timeout
