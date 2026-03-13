extends CharacterBody2D
class_name Player

const SPEED = 200.0
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(_delta: float) -> void:
	var direction_left_right := Input.get_axis("move_left", "move_right")
	if direction_left_right:
		velocity.x = direction_left_right * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	var direction_up_down := Input.get_axis("move_up", "move_down")
	if direction_up_down:
		velocity.y = direction_up_down * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	# Play animations based on movement
	if velocity.length() > 0:
		if abs(velocity.x) > abs(velocity.y):
			if velocity.x > 0:
				animated_sprite.play("walk_right")
			else:
				animated_sprite.play("walk_left")
		else:
			if velocity.y > 0:
				animated_sprite.play("walk_down")
			else:
				animated_sprite.play("walk_up")
	else:
		# Idle animations (optional)
		animated_sprite.play("idle_down")  # You can change based on last direction

	move_and_slide()
