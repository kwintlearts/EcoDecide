extends Node

signal day_changed(new_day)
signal time_changed(time_of_day)

var points = 0
var planting = ""
var plantable_count: int = 0
var total_plantables: int = 0

var day: int = 1
var time: float = 0.5  # Start at noon (0.5)
var in_dialogue: bool = false

func _ready():
	Engine.max_fps = 60
	Engine.max_physics_steps_per_frame = 8  # Physics safety cap

func start_planting():
	total_plantables = get_tree().get_nodes_in_group("plantable").size()
	plantable_count = total_plantables
	print("Day ", day, " - Planting started! Trees: ", plantable_count)

func plant_completed():
	plantable_count -= 1
	points += 10
	print("Tree planted! Remaining: ", plantable_count)
	
	if plantable_count <= 0:
		print("All trees planted on day ", day, "!")
		planting = "finished"

func next_day():
	day += 1
	day_changed.emit(day)
	
	# Animate time from night to morning
	var tween = create_tween()
	time = 0.0  # Midnight
	tween.tween_property(self, "time", 0.5, 2.0)  # 2 seconds to noon
	tween.set_trans(Tween.TRANS_SINE)
	
	print("Day ", day, " started!")

func _process(delta: float) -> void:
		time_changed.emit(time)
