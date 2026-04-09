# quest_manager.gd as autoload
extends Node

signal quest_started(quest_id)
signal quest_reached_goal(quest_id)
signal quest_finished(quest_id)
signal quest_chain_unlocked(quest_id)

var active_quests: Dictionary = {}      
var completed_quests: Array = []       
var available_quests: Dictionary = {}  

func _ready():
	auto_register_quests("res://quests/")

func auto_register_quests(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if not dir:
		push_error("Could not open folder: " + folder_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var full_path = folder_path + file_name
			var quest = load(full_path) as Quest
			if quest:
				available_quests[quest.id] = quest
				print("Registered quest: ", quest.id, " from ", file_name)
			else:
				push_error("Failed to load quest: " + full_path)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	print("Total quests loaded: ", available_quests.size())

func start_quest(quest_id: String) -> bool:
	if quest_id in active_quests or quest_id in completed_quests:
		return false
	
	var quest_resource = available_quests.get(quest_id)
	if not quest_resource:
		push_error("Quest not found: " + quest_id)
		return false
	
	# Create instance so we don't modify the original resource
	var quest_instance = quest_resource.duplicate()
	quest_instance.status = Quest.Status.STARTED
	active_quests[quest_id] = quest_instance
	quest_started.emit(quest_id)
	return true

func reach_goal(quest_id: String):
	if not quest_id in active_quests:
		return
	
	var quest = active_quests[quest_id]
	quest.status = Quest.Status.REACHED_GOAL
	quest_reached_goal.emit(quest_id)

func finish_quest(quest_id: String, delay: float = 1.0):
	
	if not quest_id in active_quests:
		return
	
	var quest = active_quests[quest_id]

	# Allow finishing from STARTED or REACHED_GOAL
	if quest.status == Quest.Status.FINISHED:
		return  # Already done
	
	# If still STARTED, auto-reach goal first
	if quest.status == Quest.Status.STARTED:
		quest.status = Quest.Status.REACHED_GOAL
		quest_reached_goal.emit(quest_id)
		
	   # Wait for delay before finishing
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	quest.status = Quest.Status.FINISHED
	completed_quests.append(quest_id)
	active_quests.erase(quest_id)
	quest_finished.emit(quest_id)
	
	# Chain quests...
	for next_id in quest.next_quests:
		if start_quest(next_id):
			quest_chain_unlocked.emit(next_id)
			print("Chain quest started: ", next_id)

func get_quest(quest_id: String) -> Quest:
	return active_quests.get(quest_id)

func is_quest_completed(quest_id: String) -> bool:
	return quest_id in completed_quests
	
func is_quest_active(quest_id: String) -> bool:
	return quest_id in active_quests
