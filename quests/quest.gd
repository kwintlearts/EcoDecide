# quest.gd
class_name Quest
extends Resource

enum Status { AVAILABLE, STARTED, REACHED_GOAL, FINISHED }

@export var id: String
@export var title: String
@export_multiline var description: String
@export_multiline var completion_text: String
@export var next_quests: Array[String] 
@export var is_main_quest: bool = true 

var status: Status = Status.AVAILABLE
