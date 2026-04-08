# mobile_controls.gd
extends Control

@onready var a: TouchScreenButton = $MarginContainer2/A
@onready var b: TouchScreenButton = $MarginContainer2/B
@onready var inventory: TouchScreenButton = $MarginContainer3/Inventory

func _process(_delta):
	# Hide controls if there's a dialogue balloon active OR results screen is showing
	var balloons = get_tree().get_nodes_in_group("dialogue_balloon")
	var results_screen = get_tree().get_nodes_in_group("results_screen")
	
	if balloons.size() > 0 or results_screen.size() > 0:
		visible = false
	else:
		visible = true

func _on_a_pressed() -> void:
	a.scale = Vector2(0.240, 0.240)

func _on_a_released() -> void:
	a.scale = Vector2(0.234, 0.234)

func _on_b_pressed() -> void:
	b.scale = Vector2(0.240, 0.240)

func _on_b_released() -> void:
	b.scale = Vector2(0.234, 0.234)

func _on_inventory_pressed() -> void:
	inventory.scale = Vector2(0.14, 0.14)

func _on_inventory_released() -> void:
	inventory.scale = Vector2(0.13, 0.13)
