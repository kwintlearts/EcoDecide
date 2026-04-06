# status.gd - Fixed for float values
extends Control

@onready var env_health_bar: ProgressBar = $TopLeft/EnvHealth/ProgressBar
@onready var community_trust_bar: ProgressBar = $TopLeft/CommunityTrust/ProgressBar
@onready var eco_score_label: Label = $TopRight/EcoScore
@onready var energy_bar: ProgressBar = $TopRight/Energy/ProgressBar
@onready var timer_label: Label = $Timer
@onready var community_trust_label: Label = $TopLeft/CommunityTrust

func _ready():
	TimerManager.time_updated.connect(_update_timer)
	GameState.stats_updated.connect(_update_stats)
	community_trust_label.hide()
	_update_stats()
	_update_progress_bar_colors()

func _update_timer(seconds: int):
	var minutes = seconds / 60  # Remove .00 - integer division
	var secs = seconds % 60
	timer_label.text = "%02d:%02d" % [minutes, secs]
	
	if seconds <= 45:
		timer_label.modulate = Color.RED
		create_tween().tween_property(timer_label, "scale", Vector2(1.1, 1.1), 0.3).set_loops()
	else:
		timer_label.modulate = Color.WHITE
		timer_label.scale = Vector2(1, 1)

func _update_stats():
	env_health_bar.value = GameState.env_health
	energy_bar.value = GameState.energy  # Float works fine with ProgressBar
	community_trust_bar.value = GameState.community_trust
	eco_score_label.text = "EcoScore: %d" % GameState.eco_score
	
	# Optional: Show energy as integer on label if you have one
	# if energy_bar.get_node_or_null("Label"):
	#     energy_bar.get_node("Label").text = "%d" % round(GameState.energy)
	
	_update_progress_bar_colors()

func _update_progress_bar_colors():
	# Set Environment Health color
	var env_style = StyleBoxFlat.new()
	env_style.bg_color = _get_health_color(GameState.env_health)
	env_health_bar.add_theme_stylebox_override("fill", env_style)
	
	# Set Energy color (pass rounded value)
	var energy_style = StyleBoxFlat.new()
	energy_style.bg_color = _get_energy_color(round(GameState.energy))
	energy_bar.add_theme_stylebox_override("fill", energy_style)
	
	# Set Community Trust color
	var trust_style = StyleBoxFlat.new()
	trust_style.bg_color = _get_health_color(GameState.community_trust)
	community_trust_bar.add_theme_stylebox_override("fill", trust_style)
	
	# Add low energy visual feedback
	if GameState.energy < 20:
		energy_bar.modulate = Color(1, 0.5, 0.5)  # Light red tint
	elif GameState.energy < 50:
		energy_bar.modulate = Color(1, 1, 0.5)   # Light yellow tint
	else:
		energy_bar.modulate = Color.WHITE

func _get_health_color(value: int) -> Color:
	if value >= 70:
		return Color(0.2, 0.8, 0.2)  # Green
	elif value >= 40:
		return Color(0.9, 0.8, 0.2)  # Yellow
	else:
		return Color(0.9, 0.2, 0.2)  # Red

func _get_energy_color(value: int) -> Color:
	if value >= 70:
		return Color(0.2, 0.8, 0.2)  # Green
	elif value >= 40:
		return Color(0.9, 0.5, 0.2)  # Orange
	else:
		return Color(0.9, 0.2, 0.2)  # Red
