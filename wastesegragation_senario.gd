extends Node2D

var time_left = 60
var game_started = false

@onready var timer = $GameTimer
@onready var timer_label = $TimerLabel

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func start_game():
	game_started = true
	time_left = 60
	timer_label.text = "Time: 60"
	timer.start()
	$TrashBox.spawn_trash()

func _on_timer_timeout():
	if not game_started:
		return

	time_left -= 1
	timer_label.text = "Time: " + str(time_left)

	if time_left <= 0:
		timer.stop()
		game_started = false
		print("TIME UP")
