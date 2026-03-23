extends Area2D

@export var trash_type: String
var is_dragging = false

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		is_dragging = true

func _input(event):
	if is_dragging and event is InputEventMouseButton and not event.pressed:
		is_dragging = false

func _process(delta):
	if is_dragging:
		global_position = get_global_mouse_position()
