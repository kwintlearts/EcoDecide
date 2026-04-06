# results_screen.gd
extends Control

@onready var eco_score_label: Label = $EcoScore
@onready var accuracy_label: Label = $Accuracy
@onready var tier_label: Label = $Tier
@onready var badges_container: VBoxContainer = $BadgesContainer
@onready var continue_button: Button = $ContinueButton

func _ready():
	var tier = GameState.get_ending_tier()
	var accuracy = GameState.get_sorting_accuracy()
	
	eco_score_label.text = str(GameState.eco_score)
	accuracy_label.text = "%.1f%%" % accuracy
	
	match tier:
		"A":
			tier_label.text = "TIER A: Circular Economy"
			tier_label.modulate = Color.GREEN
		"B":
			tier_label.text = "TIER B: Landfill Leak"
			tier_label.modulate = Color.YELLOW
		"C":
			tier_label.text = "TIER C: Mixed Waste"
			tier_label.modulate = Color.RED
	
	# Display badges
	for badge in GameState.unlocked_badges:
		var badge_label = Label.new()
		badge_label.text = "🏆 " + badge
		badges_container.add_child(badge_label)
	
	continue_button.pressed.connect(_on_continue)

func _on_continue():
	GameState.has_completed_scenario_1 = true
	get_tree().change_scene_to_file("res://scenario_2.tscn")
