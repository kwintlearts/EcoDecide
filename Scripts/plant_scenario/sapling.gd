extends StaticBody2D

@export var weed_scene: PackedScene
@export var weed_count: int = 1

@export var growth_time: float = 30.0
@export var max_health: float = 100.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar 
@onready var anim_player: AnimationPlayer = $AnimationPlayer  

var health: float
var growth_progress: float = 0.0
var is_dead: bool = false
var is_fully_grown: bool = false
var weed_count_current: int = 0
const WEED_HINDRANCE: float = 0.5

func _ready() -> void:
	add_to_group("sapling")
	health = max_health
	
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = false
	
	Gamestate.day_changed.connect(_on_day_changed)
	
	# Start growth
	start_growth()

func start_growth() -> void:
	# Play animation at speed 0 (paused) so we can control manually
	anim_player.play("growth", -1, 0.0, false)

func _process(delta: float) -> void:
	if is_queued_for_deletion() or is_dead or is_fully_grown:
		return
	
	# Calculate growth rate
	var growth_rate = 1.0 / growth_time
	if weed_count_current > 0:
		growth_rate *= (1.0 / (1.0 + weed_count_current * WEED_HINDRANCE))
	
	# Grow
	growth_progress += growth_rate * delta
	growth_progress = clamp(growth_progress, 0.0, 1.0)
	
	# Control animation playback position
	var anim_length = anim_player.current_animation_length
	anim_player.seek(growth_progress * anim_length, true)  # true = update physics
	
	# Check fully grown
	if growth_progress >= 1.0:
		become_fully_grown()

func become_fully_grown() -> void:
	is_fully_grown = true
	anim_player.pause()  # Stop at end
	Gamestate.add_fully_grown_tree()

func take_damage(amount: float) -> void:
	if is_dead or is_queued_for_deletion():
		return
		
	health -= amount
	health_bar.value = health
	health_bar.visible = true
	
	# Flash red
	var tween = create_tween()
	sprite.modulate = Color.RED
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	# Shake
	var original_pos = sprite.position
	tween.chain().tween_property(sprite, "position:x", original_pos.x + 3, 0.05)
	tween.tween_property(sprite, "position:x", original_pos.x - 3, 0.05)
	tween.tween_property(sprite, "position:x", original_pos.x, 0.05)
	
	if health <= 0:
		die()

func die() -> void:
	if is_dead:
		return
		
	is_dead = true
	Gamestate.sapling_died()
	set_process(false)
	queue_free()

func add_weed() -> void:
	weed_count_current += 1
	update_weed_indicator()

func remove_weed() -> void:
	weed_count_current = max(0, weed_count_current - 1)
	update_weed_indicator()

func update_weed_indicator() -> void:
	match weed_count_current:
		0: sprite.modulate = Color.WHITE
		1: sprite.modulate = Color(0.8, 0.9, 0.8)  # Slight green
		2: sprite.modulate = Color(0.6, 0.8, 0.6)  # More green
		3: sprite.modulate = Color(0.4, 0.7, 0.4)  # Heavy green

func spawn_weeds() -> void:
	if not weed_scene:
		return
	
	for i in weed_count:
		var weed = weed_scene.instantiate()
		var angle = randf() * TAU
		var distance = randf_range(10, 20)
		var offset = Vector2(cos(angle), sin(angle)) * distance
		
		weed.global_position = global_position + offset
		weed.sapling_parent = self  
		get_parent().add_child(weed)
		add_weed()


func check_weed_spawn(current_day: int) -> void:
	# Called when just grown from sprout
	if current_day >= 2 and not is_fully_grown and not is_dead:
		var current_weeds = get_children().filter(func(c): return c.is_in_group("weed")).size()
		if current_weeds < weed_count:
			spawn_weeds()

func _on_day_changed(day: int) -> void:
	print("Sapling day changed to: ", day, " fully_grown: ", is_fully_grown, " dead: ", is_dead)
	
	if day >= 2 and not is_fully_grown and not is_dead:
		var current_weeds = get_children().filter(func(c): return c.is_in_group("weed")).size()
		print("Current weeds: ", current_weeds, " max: ", weed_count)
		if current_weeds < weed_count:
			spawn_weeds()
