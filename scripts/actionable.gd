# actionable.gd
@tool
extends Area2D

const Balloon = preload("res://dialogue/Balloon/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

@export var use_dialogue: bool = true:
	set(v):
		use_dialogue = v
		notify_property_list_changed()
		
func _validate_property(property: Dictionary) -> void:
	if !use_dialogue:
		if property.name in ["dialogue_resource", "dialogue_start"]:
			property.usage = PROPERTY_USAGE_NO_EDITOR

var dialogue_active: bool = false

func action(interactor = null) -> void: 
	if dialogue_active:
		return
	
	var parent = get_parent()
	
	# Check if parent is a pickup item
	if parent and parent.has_method("get_item_dialogue") and GameState.scenario_active:
		var item_dialogue = parent.get_item_dialogue()
		if item_dialogue and item_dialogue.dialogue_resource:
			# Lock player movement BEFORE dialogue
			var player = get_tree().get_first_node_in_group("player")
			if player:
				player.can_move = false
			
			# Show dialogue
			start_dialogue_with_resource(item_dialogue.dialogue_resource, item_dialogue.dialogue_start)
			
			# After dialogue, check if should collect
			await DialogueManager.dialogue_ended
			
			# Unlock player movement AFTER dialogue
			if player:
				player.can_move = true
			
			# Only collect if player didn't choose to leave it
			if not GameState.did_choose("battery_ignored"):
				parent.playercollect(interactor)
			
			return
	
	# Fallback to default dialogue
	if use_dialogue and dialogue_resource:
		# Lock player movement BEFORE dialogue
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.can_move = false
		
		start_dialogue()
		
		# Wait for dialogue to end
		await DialogueManager.dialogue_ended
		
		# Unlock player movement AFTER dialogue
		if player:
			player.can_move = true
		
		return
	
	do_parent_action(interactor)

func start_dialogue() -> void:
	start_dialogue_with_resource(dialogue_resource, dialogue_start)

func start_dialogue_with_resource(resource: DialogueResource, start: String) -> void:
	dialogue_active = true
	var balloon = Balloon.instantiate()
	balloon.add_to_group("dialogue_balloon")
	get_tree().current_scene.add_child(balloon)
	DialogueManager.dialogue_ended.connect(
		func(_r): 
			dialogue_active = false,
		CONNECT_ONE_SHOT
	)
	balloon.start(resource, start)

func do_parent_action(interactor = null) -> void:  
	var parent = get_parent()
	if not parent:
		return
	
	if parent.has_method("power_on"):
		parent.power_on()
	
	if parent.has_method("playercollect"):
		parent.playercollect(interactor)
	
	if parent.has_method("empty_inventory"):
		parent.empty_inventory()
