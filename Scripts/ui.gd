extends CanvasLayer

@onready var time_label: Label = $HUD/Labels/Top_Left/VBoxContainer/TimeLabel
@onready var day_label: Label = $HUD/Labels/Top_Left/VBoxContainer/DayLabel
@onready var score_label: Label = $HUD/Labels/Top_right/ScoreLabel
@onready var touch_controls: CanvasLayer = $"HUD/Touch Controls"

var player_in_range: bool = false

func _ready():
	Gamestate.time_changed.connect(_on_time_changed)
	Gamestate.day_changed.connect(_on_day_changed)
	
func _process(_delta: float) -> void:
	score_label.text = "Score: " + str(Gamestate.points)
	var dialogue_active = get_tree().get_nodes_in_group("dialogue_balloon").size() > 0
	touch_controls.visible = not dialogue_active



func _on_time_changed(time: float) -> void:
	var hours = int(time * 24)
	var minutes = int((time * 24 * 60)) % 60
	time_label.text = "%02d:%02d" % [hours, minutes]

func _on_day_changed(day: int) -> void:
	day_label.text = "Day " + str(day)
