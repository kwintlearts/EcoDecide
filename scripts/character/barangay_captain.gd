extends StaticBody2D

@onready var star: Sprite2D = $Star
@onready var actionable: Area2D = $Actionable

func _ready():
	star.visible = false  # Start hidden
	
	EventBus.captain_helped.connect(_on_captain_helped)

func _on_captain_helped():
	show_star()
	
	
func show_star():
	star.visible = true
	# Add animation
	var tween = create_tween()
	tween.tween_property(star, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(star, "scale", Vector2(1.0, 1.0), 0.2)
	
	# Optional: Add floating effect
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(star, "position", Vector2(0, -5), 0.5)
	float_tween.tween_property(star, "position", Vector2(0, 0), 0.5)
