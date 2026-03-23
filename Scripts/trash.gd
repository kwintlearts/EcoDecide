extends Area2D

@export var trash_type : String

var dragging = false

func _input_event(viewport, event, shape_idx):

	if event is InputEventMouseButton:
		if event.pressed:
			dragging = true
		else:
			dragging = false

func _process(delta):

	if dragging:
		global_position = get_global_mouse_position()
