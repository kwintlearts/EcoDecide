extends Node2D

signal timer_updated(remaining: float, is_paused: bool)
signal transition_started
signal transition_finished

@onready var light: DirectionalLight2D = $Lighting/light
@onready var tint: CanvasModulate = $Lighting/Tint

@onready var pest_spawner: Area2D = $"PestSpawner"
@export var pest_scene: PackedScene
@export var base_pest_count: int = 3

@export var day_duration: float = 13.0
@export var transition_duration: float = 2.0

var day_timer: float = 0.0
var is_day_active: bool = false
var time_paused: bool = true
var current_time: float = 0.5
var day_tween: Tween = null


func _ready():
	add_to_group("plant_world")
	Gamestate.planting_finished.connect(_on_planting_finished)
	_start_day()
	pause_timer()
	

func _process(delta: float) -> void:
	if not is_day_active or time_paused:
		timer_updated.emit(day_duration - day_timer, true)
		return
	
	day_timer += delta
	current_time = 0.5
	_update_lighting(current_time)
	
	# Emit timer update
	var remaining = day_duration - day_timer
	timer_updated.emit(remaining, false)
	
	if day_timer >= day_duration:
		_end_day()

func _update_lighting(time: float) -> void:
	var intensity = (cos((time - 0.5) * TAU) + 1.0) / 2.0
	intensity = clamp(intensity, 0.2, 1.0)
	light.energy = intensity
	tint.color = Color(0.2, 0.3, 0.5).lerp(Color(1.0, 0.95, 0.8), intensity)

func _end_day() -> void:
	is_day_active = false
	transition_started.emit()
	_animate_transition()

func _animate_transition() -> void:
	if day_tween and day_tween.is_valid():
		day_tween.kill()
	
	day_tween = create_tween()
	day_tween.set_trans(Tween.TRANS_SINE)
	day_tween.tween_method(_update_lighting, 0.5, 0.0, transition_duration / 2.0)
	day_tween.tween_method(_update_lighting, 0.0, 0.5, transition_duration / 2.0)
	day_tween.finished.connect(_start_next_day)

func _start_next_day() -> void:
	transition_finished.emit()
	
	Gamestate.day += 1
	Gamestate.day_changed.emit(Gamestate.day)
	
		# Check lose condition on day 5
	if Gamestate.day >= 5:
		if not Gamestate.check_win_condition():
			game_over(false)
			return
	
	# Scale difficulty
	day_duration = 15.0 + (Gamestate.day - 1) * 10.0
	day_timer = 0.0
	
	# Spawn pests for new day
	spawn_pests_for_day(Gamestate.day)
	
	is_day_active = true
	_update_lighting(0.5)

func _start_day():
	is_day_active = true
	time_paused = false
	spawn_pests_for_day(Gamestate.day)

func game_over(won: bool) -> void:
	is_day_active = false
	Gamestate.game_over.emit(won)
	print("GAME OVER - Won: ", won)

func spawn_pests_for_day(day: int) -> void:
	var count = base_pest_count + day  # More pests each day
	if day != 1:
		print("Day ", day, ": Spawning ", count, " pests")
		for i in count:
			spawn_pest()

func spawn_pest() -> void:
	if not pest_scene or not pest_spawner:
		push_error("Missing pest scene or spawn area!")
		return
	
	var pest = pest_scene.instantiate()
	pest.global_position = _get_random_spawn_position()
	pest.z_index = 10
	add_child(pest)

func _get_random_spawn_position() -> Vector2:
	var collision_shape = pest_spawner.get_node("CollisionShape2D")
	var rect: RectangleShape2D = collision_shape.shape
	var center = pest_spawner.global_position
	
	return Vector2(
		randf_range(center.x - rect.size.x/2, center.x + rect.size.x/2),
		randf_range(center.y - rect.size.y/2, center.y + rect.size.y/2)
	)

func _on_planting_finished():
	# Optional: speed up day or give bonus time
	pass

func pause_timer():
	time_paused = true

func resume_timer():
	time_paused = false
