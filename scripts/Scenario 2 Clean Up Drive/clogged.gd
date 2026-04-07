# clogged.gd
extends Area2D

@onready var percent_0_30: Sprite2D = $percent_0_30
@onready var percent_31_70: Sprite2D = $percent_31_70
@onready var percent_71_100: Sprite2D = $percent_71_100
@onready var murky_water: TileMapLayer = $"../MurkyWater"
@onready var in_murky_water: TileMapLayer = $"../InMurkyWater"

var slow_multiplier: float = 0.5
var inside_player: CharacterBody2D = null
var current_clarity: int = 0  # Start at 0% (fully clogged)

func _ready():
	_update_visuals()

func update_clarity():
	# Get total items remaining in the canal from spawner
	var spawner = get_node("../Spawner")
	if not spawner:
		print("Spawner not found!")
		return
	
	var total_items = spawner.get_remaining_items()
	
	# Calculate clarity based on remaining items (30 total)
	# 30 items = 0% clear, 0 items = 100% clear
	var total_max = 30
	var clarity_percent = int((total_max - total_items) / float(total_max) * 100)
	
	current_clarity = clarity_percent
	
	_update_visuals()
	_update_slow_multiplier()
	
	print("Items remaining: ", total_items, " | Clarity: ", current_clarity, "%")

func _update_visuals():
	# Hide all sprites first
	percent_0_30.hide()
	percent_31_70.hide()
	percent_71_100.hide()
	
	# Handle murky water visibility
	if current_clarity >= 100:
		# Fully clear - hide murky water
		murky_water.hide()
		in_murky_water.hide()
		percent_0_30.hide()
		percent_31_70.hide()
		percent_71_100.hide()
		print("Canal: Fully clear!")
	elif current_clarity >= 71:
		murky_water.show()
		in_murky_water.show()
		percent_71_100.show()
		print("Canal: Clear (71-100%)")
	elif current_clarity >= 31:
		murky_water.show()
		in_murky_water.show()
		percent_31_70.show()
		print("Canal: Partially clogged (31-70%)")
	else:
		murky_water.show()
		in_murky_water.show()
		percent_0_30.show()
		print("Canal: Heavily clogged (0-30%)")

func _update_slow_multiplier():
	# Update slow multiplier based on clarity (more clogged = slower)
	if current_clarity >= 100:
		slow_multiplier = 1.0  # No slow
	elif current_clarity >= 71:
		slow_multiplier = 0.2  # Barely slow
	elif current_clarity >= 31:
		slow_multiplier = 0.5  # Medium slow
	else:
		slow_multiplier = 0.8  # Very slow
	
	# Re-apply slow if player is inside
	if inside_player:
		inside_player.speed_multiplier = slow_multiplier
		print("Player speed multiplier updated to: ", slow_multiplier)

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		inside_player = body
		body.speed_multiplier = slow_multiplier
		print("Player slowed to: ", slow_multiplier)

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		inside_player = null
		body.speed_multiplier = 1.0
		print("Player speed restored")
		
