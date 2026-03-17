extends Area2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite.set_frame_and_progress(0, 0.0)
	# 	animated_sprite.play("growing")
