# mobile_controls.gd
extends Control

@onready var b: TouchScreenButton = $Buttons/B
@onready var a: TouchScreenButton = $Buttons/A
@onready var virtual_joystick: VirtualJoystick = $"Virtual Joystick"

var is_mobile_web = false

func _ready() -> void:
	is_mobile_web = OS.has_feature("web_android") or OS.has_feature("web_ios")
	
	if not is_mobile_web:
		visible = false
		virtual_joystick.visible = false
		hide()
		print("Not mobile web - controls hidden")
	else:
		visible = true
		print("Mobile web - controls visible")

func _process(_delta):
	if not is_mobile_web:
		return
	
	# Hide controls if there's a dialogue balloon active OR results screen is showing
	var balloons = get_tree().get_nodes_in_group("dialogue_balloon")
	var results_screen = get_tree().get_nodes_in_group("results_screen")
	
	if balloons.size() > 0 or results_screen.size() > 0:
		if visible:
			visible = false
	else:
		if not visible:
			visible = true

func _on_a_pressed() -> void:
	a.scale = Vector2(6, 6)

func _on_a_released() -> void:
	a.scale = Vector2(5.6, 5.6)

func _on_b_pressed() -> void:
	b.scale = Vector2(6, 6)

func _on_b_released() -> void:
	b.scale = Vector2(5.6, 5.6)
