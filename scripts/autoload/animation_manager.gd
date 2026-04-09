# AnimationManager.gd - Add this as an autoload
extends Node

# Dictionary to store references to character nodes
var characters: Dictionary = {}

# Register a character with their AnimatedSprite2D
func register_character(character_name: String, animated_sprite: AnimatedSprite2D):
	characters[character_name] = animated_sprite
	print("Registered character: ", character_name)

# Unregister a character when removed
func unregister_character(character_name: String):
	if characters.has(character_name):
		characters.erase(character_name)

# Play animation on a specific character
func animate(character_name: String, animation_name: String):
	if characters.has(character_name):
		var sprite = characters[character_name]
		if sprite is AnimatedSprite2D:
			if sprite.sprite_frames.has_animation(animation_name):
				sprite.play(animation_name)
				print("Playing '", animation_name, "' on ", character_name)
			else:
				push_warning("Animation '", animation_name, "' not found on ", character_name)
		else:
			push_warning("Character '", character_name, "' doesn't have AnimatedSprite2D")
	else:
		push_warning("Character '", character_name, "' not registered")

# Stop animation on a character
func stop_animation(character_name: String):
	if characters.has(character_name):
		var sprite = characters[character_name]
		if sprite is AnimatedSprite2D:
			sprite.stop()
			print("Stopped animation on ", character_name)

# Play animation and return to idle after completion
func animate_then_idle(character_name: String, animation_name: String, idle_name: String = "idle_down"):
	if characters.has(character_name):
		var sprite = characters[character_name]
		if sprite is AnimatedSprite2D:
			sprite.play(animation_name)
			# Wait for animation to finish
			await sprite.animation_finished
			sprite.play(idle_name)
