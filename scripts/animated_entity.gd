# animated_entity.gd (extends this for any character that needs dialogue animations)
extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var current_animation_state: String = "idle"
var animation_finished_callback: Callable

# Override this in child classes to define custom animations
func play_animation(animation_name: String):
	match animation_name:
		"idle":
			await play_and_wait("idle_" + current_animation_state)
		_:
			await play_and_wait(animation_name)

# Helper function to play animation and wait for it to finish
func play_and_wait(anim_name: String):
	if not animated_sprite:
		return
	
	# Store current animation to restore later
	var previous_animation = animated_sprite.animation
	
	animated_sprite.play(anim_name)
	await animated_sprite.animation_finished
	
	# Restore previous animation if it was playing
	if previous_animation and previous_animation != anim_name:
		animated_sprite.play(previous_animation)

# For looping animations (doesn't wait)
func play_looping(anim_name: String):
	if animated_sprite:
		animated_sprite.play(anim_name)

# Set facing direction (for 4-directional characters)
func set_facing(direction: String):
	current_animation_state = direction
