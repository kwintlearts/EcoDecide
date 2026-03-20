extends Area2D

var player_near = false
@onready var dialogue = $Label

func _ready():
	dialogue.visible = false

func _on_area_entered(area):
	if area.name == "Player":
		player_near = true
		dialogue.visible = true

func _on_area_exited(area):
	if area.name == "Player":
		player_near = false
		dialogue.visible = false

func _input(event):
	if player_near and event.is_action_pressed("interact"):
		get_parent().start_game()
		queue_free()
