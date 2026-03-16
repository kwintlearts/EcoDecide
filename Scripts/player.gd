extends CharacterBody2D

const SPEED = 200.0
@onready var actionable_finder: Area2D = $Direction/ActionableFinder
@onready var animation_tree: AnimationTree = $AnimationTree

var input_vector: Vector2 = Vector2.ZERO
var current_highlight: Area2D = null

func _ready() -> void:
	animation_tree.active = true

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
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
	
	if input_vector.length() > 0:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Walk/blend_position", input_vector)
		animation_tree.get("parameters/playback").travel("Walk")
	else:
		animation_tree.get("parameters/playback").travel("Idle")
