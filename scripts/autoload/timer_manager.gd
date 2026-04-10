# timer_manager.gd autoload
extends Node

signal time_updated(remaining: int)
signal time_expired
signal time_warning

var time_remaining: int = 300
var timer_active: bool = false
var timer: Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(_on_timer_tick)

func start_timer(seconds: int = 300):
	time_remaining = seconds
	timer_active = true
	timer.start(1.0)

func stop_timer():
	timer_active = false
	timer.stop()

func _on_timer_tick():
	if timer_active and time_remaining > 0:
		time_remaining -= 1
		time_updated.emit(time_remaining)
		
		if time_remaining == 45:
			time_warning.emit()
		
		if time_remaining <= 0:
			time_expired.emit()
			end_scenario()


# timer_manager.gd
func end_scenario():
	print("TimerManager.end_scenario() called")
	stop_timer()
	GameState.end_scenario()
	

	# Wait a frame to ensure everything is settled
	await get_tree().process_frame

func _show_results_screen():
	print("Showing results screen from TimerManager...")
	
	# Use a CanvasLayer to ensure it appears on top
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().current_scene.add_child(canvas)
	
	# Load results screen - use absolute path
	var results_screen = load("res://scenes/menu/results_screen.tscn")
	if results_screen:
		var instance = results_screen.instantiate()
		canvas.add_child(instance)
		print("Results screen added successfully")
	else:
		print("ERROR: Could not load results screen")
