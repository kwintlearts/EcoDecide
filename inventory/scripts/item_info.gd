extends Control

@onready var item_title: Label = $ItemTitle
@onready var item_description: Label = $ItemDescription

func update_info(title: String, description: String):
	if item_title:
		item_title.text = title
	if item_description:
		item_description.text = description
	
	# Optional: Add a little pop animation
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
