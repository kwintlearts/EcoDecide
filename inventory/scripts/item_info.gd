# item_info.gd
extends Control

@onready var item_title: Label = $VBoxContainer/ItemTitle
@onready var item_description: Label = $VBoxContainer/ItemDescription

var current_item: InvItem = null

func update_info(title: String, description: String, item: InvItem = null):
	current_item = item
	
	# Get category icon
	var category_text = _get_category_text(item.category if item else "Other")
	
	if item_title:
		item_title.text = title + " - " + category_text
	if item_description:
		item_description.text = description
	
	# Update title color based on item's correct bin
	_update_title_color()
	
	# Optional: Add a little pop animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func _get_category_text(category: String) -> String:
	match category:
		"Food":
			return "Food"
		"Plastic":
			return "Plastic"
		"Glass":
			return "Glass"
		"Paper":
			return "Paper"
		"Metal":
			return "Metal"
		"Electronic":
			return "Electronic"
		"Organic":
			return "Organic"
		"Ceramic":
			return "Ceramic"
		_:
			return "Other"


func _update_title_color():
	if not current_item:
		return
	
	var color = Color.WHITE
	
	match current_item.correct_bin:
		0:  # HAZARDOUS
			color = Color(1, 0.3, 0.3)  # Red
		1:  # RECYCLABLE
			color = Color(0.2, 0.839, 1.0)  # Blue/cyan
		2:  # BIODEGRADABLE
			color = Color(0.623, 2.223, 0.13)  # Green
		3:  # RESIDUAL
			color = Color(0.282, 0.298, 0.0)  # Dark yellow
		4:  # RINSEABLE
			color = Color(1.0, 0.6, 1.0)  # Purple
	
	#item_title.add_theme_color_override("font_color", color)
	#item_title.add_theme_color_override("font_shadow_color", Color.BLACK)
