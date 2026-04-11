# elder_lady.gd
extends StaticBody2D

@onready var label: Label = $Label

func _ready() -> void:
	label.add_theme_font_size_override("font_size", 16)
	
	# Show permanent emoji based on choice
	_update_emoji_from_choice()
	
	GameState.stats_updated.connect(_update_emoji_from_choice)


func _update_emoji_from_choice():
	if GameState.did_choose("grandson_help"):
		label.text = "🧒✨"  # Grandson will help

	elif GameState.did_choose("comforted_lola"):
		label.text = "😊"  # Happy

	elif GameState.did_choose("asked_lola"):
		label.text = "💭"  # Thoughtful

	elif GameState.did_choose("blamed_lola"):
		label.text = "😠"  # Angry

	else:
		label.text = "❗"
