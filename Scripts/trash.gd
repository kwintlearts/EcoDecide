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

func _on_area_entered(area):
	if area.is_in_group("trash"):
		if area.trash_type == bin_type:
			get_node("/root/Game/ScoreManager").add_score()
			area.queue_free()
			get_node("/root/Game/TrashBox").spawn_trash()
