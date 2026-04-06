extends Control
@onready var a: TouchScreenButton = $MarginContainer2/A
@onready var b: TouchScreenButton = $MarginContainer2/B
@onready var inventory: TouchScreenButton = $MarginContainer3/Inventory




func _on_a_pressed() -> void:
	a.scale = Vector2(0.205, 0.205)


func _on_a_released() -> void:
	a.scale = Vector2(0.2, 0.2)

func _on_b_pressed() -> void:
	b.scale = Vector2(0.205, 0.205)


func _on_b_released() -> void:
	b.scale = Vector2(0.2, 0.2)


func _on_inventory_pressed() -> void:
	inventory.scale = Vector2(0.105, 0.105)
	


func _on_inventory_released() -> void:
	inventory.scale = Vector2(0.1, 0.1)
