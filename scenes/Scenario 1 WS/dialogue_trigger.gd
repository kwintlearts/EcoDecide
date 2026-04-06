# dialogue_trigger.gd
extends Area2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "locked"  # Configurable start node
@export var required_flag: String = ""  # Optional: only trigger if flag not set
@export var set_flag_on_trigger: String = ""  # Optional: flag to set after trigger

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_triggered: bool = false

func _on_body_entered(body: Node2D) -> void:
	print("entered dialogue trigger area")
	
	if not body.is_in_group("player"):
		return
	
	# Check if scenario is already active - DON'T trigger
	if GameState.scenario_active:
		print("Scenario already active - skipping dialogue trigger")
		return
	
	# Check required flag (if specified)
	if required_flag != "":
		if GameState.get_scenario_flag(required_flag, false):
			print("Required flag already set - skipping")
			return
	
	if is_triggered:
		return
	
	is_triggered = true
	
	# FREEZE PLAYER using can_move
	body.can_move = false
	body.velocity = Vector2.ZERO
	
	# Show dialogue
	if dialogue_resource:
		show_locked_dialogue(body)
	else:
		await get_tree().create_timer(1.0).timeout
		release_player(body)

func show_locked_dialogue(player: CharacterBody2D) -> void:
	var Balloon = preload("res://dialogue/Balloon/balloon.tscn")
	var balloon = Balloon.instantiate()
	get_tree().current_scene.add_child(balloon)
	
	DialogueManager.dialogue_ended.connect(
		func(_r): release_player(player), 
		CONNECT_ONE_SHOT
	)
	
	balloon.start(dialogue_resource, dialogue_start)

func release_player(player: CharacterBody2D) -> void:
	player.can_move = true
	is_triggered = false
	
	# Set flag if specified
	if set_flag_on_trigger != "":
		GameState.record_choice(set_flag_on_trigger, true)
