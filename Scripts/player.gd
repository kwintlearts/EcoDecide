extends CharacterBody2D

const SPEED = 300.0
@onready var actionable_finder: Area2D = $Direction/ActionableFinder
@onready var animation_tree: AnimationTree = $AnimationTree

var input_vector: Vector2 = Vector2.ZERO
var current_target: Area2D = null

func _ready() -> void:
	animation_tree.active = true

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			var target = actionables[0]  # The Area2D with actionable.gd
			
			# Call interact() on the actionable, it handles the rest
			if target.has_method("interact"):
				target.interact()
				get_viewport().set_input_as_handled()
		
	var x_axis: float = Input.get_axis("ui_left", "ui_right")
	var y_axis: float = Input.get_axis("ui_up", "ui_down")
	if x_axis:
		input_vector = x_axis * Vector2.RIGHT
	elif y_axis:
		input_vector = y_axis * Vector2.DOWN
	else:
		input_vector = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if input_vector.length() > 0:
		velocity = input_vector * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		
	move_and_slide()
	
	if velocity.length() > 0:
		animation_tree.set("parameters/Idle/blend_position", velocity)
		animation_tree.set("parameters/Walk/blend_position", velocity)
		animation_tree.get("parameters/playback").travel("Walk")
	else:
		animation_tree.get("parameters/playback").travel("Idle")
		
	var actionables = actionable_finder.get_overlapping_areas()
	if actionables.size() > 0:
		var target = actionables[0]  # The Area2D with actionable.gd
		if target != current_target:
			if current_target and current_target.get_parent().has_method("set_highlight"):
				current_target.get_parent().set_highlight(false)
				
			if target.get_parent().has_method("set_highlight"):
				target.get_parent().set_highlight(true)
				
				current_target = target
	else:
		if current_target and current_target.get_parent().has_method("set_highlight"):
			current_target.get_parent().set_highlight(false)
		current_target = null
				
