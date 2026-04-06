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
	if parent and parent.has_method("get_item_dialogue"):
		var item_dialogue = parent.get_item_dialogue()
		if item_dialogue and item_dialogue.dialogue_resource:
			# Check if inventory is full BEFORE showing dialogue
			if interactor and interactor.has_method("collect"):
				# Try to collect first - if fails, don't show dialogue
				var success = parent.playercollect(interactor)
				if not success:
					# Inventory full - show error message instead of item dialogue
					print("Inventory full! Cannot pick up item.")
					# Optional: Show floating text "Inventory Full!"
					return
			
			# Only show dialogue if collection was successful or no inventory check
			start_dialogue_with_resource(item_dialogue.dialogue_resource, item_dialogue.dialogue_start)
			return
	
	# Fallback to default dialogue
	if use_dialogue and dialogue_resource:
		start_dialogue()
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
		func(_r): dialogue_active = false, 
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
