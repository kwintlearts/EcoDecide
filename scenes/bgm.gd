# bgm.gd
extends AudioStreamPlayer

func _ready():
	# Set to loop
	finished.connect(_on_finished)
	play()

func _on_finished():
	# Replay when finished
	play()
