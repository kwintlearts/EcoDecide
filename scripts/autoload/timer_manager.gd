# timer_manager.gd
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
	stop_timer()
	GameState.end_scenario()
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
	print("Scenario ended!")
	# Show results screen
	#var results_screen = load("res://ui/results_screen.tscn").instantiate()
	#get_tree().current_scene.add_child(results_screen)
