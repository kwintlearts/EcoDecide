extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("sapling")  # ← Add to group for easy detection!
	animated_sprite.set_frame_and_progress(0, 0.0)
