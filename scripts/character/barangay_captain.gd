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
	
	# Animate scale from 0.02 * 1.2 back to 0.02
	var tween = create_tween()
	tween.tween_property(star, "scale", Vector2(0.024, 0.024), 0.1)
	tween.tween_property(star, "scale", Vector2(0.02, 0.02), 0.1)
	
	# Add floating effect
	var float_tween = create_tween().set_loops()
	float_tween.tween_property(star, "position", Vector2(0, -5), 0.5)
	float_tween.tween_property(star, "position", Vector2(0, 0), 0.5)
