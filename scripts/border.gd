# border.gd
extends StaticBody2D

@onready var collision_shape_2d_8: CollisionShape2D = $CollisionShape2D8

func _ready():
	EventBus.scenario_started.connect(_on_scenario_started)
	
	await get_tree().create_timer(0.1).timeout
	if GameState.scenario_active:
		print("Scenario active detected after delay - disabling border")
		disable_border()

func _on_scenario_started(scenario_id):  # Add the argument here
	print("Scenario started signal received! ID: ", scenario_id)
	disable_border()

func disable_border():
	if collision_shape_2d_8:
		collision_shape_2d_8.disabled = true
		print("Border collision disabled")

func enable_border():
	if collision_shape_2d_8:
		collision_shape_2d_8.disabled = false
		print("Border collision enabled")
