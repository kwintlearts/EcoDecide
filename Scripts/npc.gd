extends StaticBody2D

@onready var talk_label: Label = $Talk_Label
var player_in_range: bool = false

func _ready():
	talk_label.hide()

func _on_actionable_area_entered(area: Area2D) -> void:
	if area.name == "ActionableFinder":
			player_in_range = true
			talk_label.show()
		
func _on_actionable_area_exited(area: Area2D) -> void:
	if area.name == "ActionableFinder":
			player_in_range = false
			talk_label.hide()

func _process(_delta: float) -> void:
	# Hide talk if dialogue is active (check by balloon existence)
	var dialogue_active = get_tree().get_nodes_in_group("dialogue_balloon").size() > 0
	if dialogue_active and player_in_range:
		talk_label.hide()
	elif player_in_range:
		talk_label.show()
