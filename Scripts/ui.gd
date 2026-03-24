extends CanvasLayer

@onready var time_label: Label = $HUD/Labels/Top_Left/VBoxContainer/TimeLabel
@onready var day_label: Label = $HUD/Labels/Top_Left/VBoxContainer/DayLabel
@onready var score_label: Label = $HUD/Labels/Top_right/ScoreLabel
@onready var touch_controls: CanvasLayer = $"HUD/Touch Controls"
@onready var happy_ending: Label = $"Game Over/Happy Ending"
@onready var good_ending: Label = $"Game Over/Good Ending"
@onready var bad_ending: Label = $"Game Over/Bad Ending"

var plant_world: Node = null

func _ready():
	# Hide all endings initially
	happy_ending.hide()
	good_ending.hide()
	bad_ending.hide()
	
	Gamestate.day_changed.connect(_on_day_changed)
	Gamestate.score_changed.connect(_on_score_changed)
	Gamestate.game_over.connect(_on_game_over)
	
	call_deferred("_connect_plant_world")

func _connect_plant_world() -> void:
	plant_world = get_tree().get_first_node_in_group("plant_world")
	
	if plant_world:
		plant_world.timer_updated.connect(_on_timer_updated)
		plant_world.transition_started.connect(_on_transition_started)
		plant_world.transition_finished.connect(_on_transition_finished)
		_on_timer_updated(plant_world.day_duration, plant_world.time_paused)

func _on_day_changed(day: int) -> void:
	day_label.text = "Day " + str(day)
	
	if day == 5:
		check_endings()

func check_endings() -> void:
	var fully_grown = Gamestate.fully_grown_trees
	var total = Gamestate.total_saplings
	var dead = Gamestate.dead_saplings
	var alive = total - dead - fully_grown  # Still growing
	
	print("Day 5 - Total: ", total, " Grown: ", fully_grown, " Dead: ", dead, " Alive: ", alive)
	
	# Happy: All trees survived and fully grown
	if fully_grown >= total:
		show_ending("happy")
	# Bad: All trees dead
	elif dead >= total:
		show_ending("bad")
	# Good: Mixed results (at least half survived or still growing)
	elif (fully_grown + alive) >= total / 2.0:
		show_ending("good")
	else:
		# Less than half - still bad ending
		show_ending("bad")

func _on_game_over(won: bool) -> void:
	# Final check if not already decided
	check_endings()

func show_ending(ending_type: String) -> void:
	happy_ending.hide()
	good_ending.hide()
	bad_ending.hide()
	touch_controls.hide()
	
	match ending_type:
		"happy":
			happy_ending.show()
			happy_ending.text = "Perfect Garden!\nAll " + str(Gamestate.fully_grown_trees) + " trees fully grown!"
		"good":
			good_ending.show()
			var grown = Gamestate.fully_grown_trees
			var total = Gamestate.total_saplings
			good_ending.text = "Garden Saved!\n" + str(grown) + "/" + str(total) + " trees survived"
		"bad":
			bad_ending.show()
			bad_ending.text = "Garden Lost...\nAll trees have withered"
	
	get_tree().paused = true

func _on_timer_updated(remaining: float, is_paused: bool) -> void:
	if is_paused:
		time_label.text = "PAUSED"
		time_label.modulate = Color.YELLOW
	else:
		var seconds = int(remaining)
		time_label.modulate = Color.RED if seconds < 10 else Color.WHITE
		time_label.text = str(seconds) + "s"

func _on_transition_started() -> void:
	time_label.text = "NIGHT..."
	time_label.modulate = Color.PURPLE

func _on_transition_finished() -> void:
	time_label.text = "DAY!"
	time_label.modulate = Color.GREEN

func _on_score_changed(score: int) -> void:
	score_label.text = "Score: " + str(score)

func _process(_delta: float) -> void:
	var dialogue_active = get_tree().get_nodes_in_group("dialogue_balloon").size() > 0
	touch_controls.visible = not dialogue_active
