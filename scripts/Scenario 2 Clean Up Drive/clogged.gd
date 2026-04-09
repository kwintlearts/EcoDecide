# clogged.gd
extends Area2D

@onready var percent_0_30: Sprite2D = $percent_0_30
@onready var percent_31_70: Sprite2D = $percent_31_70
@onready var percent_71_100: Sprite2D = $percent_71_100
@onready var murky_water: TileMapLayer = $"../MurkyWater"
@onready var in_murky_water: TileMapLayer = $"../InMurkyWater"
@onready var litter_sprites: Node2D = $LitterSprites  # Add a node for litter

var slow_multiplier: float = 0.5
var inside_player: CharacterBody2D = null
var current_clarity: int = 0
var is_mid_clean: bool = false  # Flag for mid-clean ending

func _ready():
	_update_visuals()

func update_clarity():
	var spawner = get_node("../Spawner")
	if not spawner:
		print("Spawner not found!")
		return
	
	var total_items = spawner.get_remaining_items()
	var total_max = 30
	var clarity_percent = int((total_max - total_items) / float(total_max) * 100)
	
	current_clarity = clarity_percent
	
	_update_visuals()
	_update_slow_multiplier()
	
	print("Items remaining: ", total_items, " | Clarity: ", current_clarity, "%")

# Call this from your ending dialogue when community trust is low
func set_mid_clean_visuals():
	is_mid_clean = true
	_update_visuals()

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
		
		if is_mid_clean:
			# Show clean water but with litter
			percent_71_100.show()
			murky_water.hide()
			in_murky_water.hide()
			percent_71_100.modulate = Color(0.5, 0.8, 1.0, 0.6)  # Faded/dull blue
			_show_litter()
			print("Canal: Clean but neglected (mid-clean)")
		else:
			# True clean - vibrant
			percent_71_100.show()
			percent_71_100.modulate = Color(0.3, 0.9, 1.0, 1.0)  # Vibrant blue
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

func _show_litter():
	# Add some litter sprites to show neglect
	if litter_sprites:
		litter_sprites.visible = true

func _update_slow_multiplier():
	if current_clarity >= 100:
		slow_multiplier = 1.0
	elif current_clarity >= 71:
		slow_multiplier = 0.2
	elif current_clarity >= 31:
		slow_multiplier = 0.5
	else:
		slow_multiplier = 0.8
	
	if inside_player:
		inside_player.speed_multiplier = slow_multiplier

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		inside_player = body
		body.speed_multiplier = slow_multiplier

func _on_body_exited(body: Node2D):
	if body.is_in_group("player"):
		inside_player = null
		body.speed_multiplier = 1.0
