extends Area2D

var player_near = false

func _on_body_entered(body):

	if body.name == "Player":

		player_near = true

		$Label.visible = true

func _on_body_exited(body):

	if body.name == "Player":

		player_near = false

		$Label.visible = false

func _input(event):

	if player_near and event.is_action_pressed("interact"):

		get_tree().current_scene.start_game()

		queue_free()
