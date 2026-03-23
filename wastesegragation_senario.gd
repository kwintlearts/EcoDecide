extends Node2D

var time_left = 60

@onready var timer = $GameTimer
@onready var label = $timerlabel

func _ready():
	timer.timeout.connect(_on_timer_timeout)

func start_game():

	print("GAME STARTED")

	time_left = 60

	label.text = "Time: 60"

	timer.start()

	$trashbox.spawn_trash()

func _on_timer_timeout():

	time_left -= 1

	label.text = "Time: " + str(time_left)

	if time_left <= 0:

		timer.stop()

		print("Time finished")
