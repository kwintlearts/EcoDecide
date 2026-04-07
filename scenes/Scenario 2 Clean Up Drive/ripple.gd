# ripple.gd
extends Area2D

@onready var panel: Panel = $CollisionShape2D/Panel
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var slow_multiplier: float = 0.5
var inside_player: Node2D = null
var is_glowing: bool = false
var original_style: StyleBoxFlat

func _ready():
	# Setup panel with StyleBoxFlat
	if panel:
		# Create initial transparent style
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.5, 0.8, 1.0, 0)  # Transparent blue
		style.border_width_left = 2
		style.border_width_right = 2
		style.border_width_top = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.3, 0.6, 1.0, 0)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		
		panel.add_theme_stylebox_override("panel", style)
		original_style = style
		
	EventBus.ripple_glow.connect(_on_ripple_glow)

func _on_ripple_glow():
	glow_ripple()

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

# Call this when elder lady gives the hint
func glow_ripple():
	if is_glowing:
		return
	
	is_glowing = true
	
	if panel:
		# Create a new style for glowing effect
		var glow_style = StyleBoxFlat.new()
		glow_style.bg_color = Color(0.3, 0.8, 1.0, 0.6)  # Semi-transparent blue
		glow_style.border_width_left = 3
		glow_style.border_width_right = 3
		glow_style.border_width_top = 3
		glow_style.border_width_bottom = 3
		glow_style.border_color = Color(0.0, 1.0, 1.0, 0.9)  # Cyan border
		glow_style.corner_radius_top_left = 8
		glow_style.corner_radius_top_right = 8
		glow_style.corner_radius_bottom_left = 8
		glow_style.corner_radius_bottom_right = 8
		
		# Pulse animation using tween
		var tween = create_tween()
		tween.set_loops(3)
		
		# Animate between glow and normal
		tween.tween_callback(func(): panel.add_theme_stylebox_override("panel", glow_style))
		tween.tween_interval(0.3)
		tween.tween_callback(func(): panel.add_theme_stylebox_override("panel", original_style))
		tween.tween_interval(0.3)
		
		await tween.finished
		
		# Set to a permanent subtle highlight
		var subtle_style = StyleBoxFlat.new()
		subtle_style.bg_color = Color(0.5, 0.8, 1.0, 0.2)  # Very subtle blue
		subtle_style.border_width_left = 2
		subtle_style.border_width_right = 2
		subtle_style.border_width_top = 2
		subtle_style.border_width_bottom = 2
		subtle_style.border_color = Color(0.3, 0.8, 1.0, 0.4)
		subtle_style.corner_radius_top_left = 8
		subtle_style.corner_radius_top_right = 8
		subtle_style.corner_radius_bottom_left = 8
		subtle_style.corner_radius_bottom_right = 8
		
		panel.add_theme_stylebox_override("panel", subtle_style)
	
	print("Ripple glow effect triggered!")

# Alternative: Simple color animation without StyleBoxFlat switching
func simple_glow():
	if panel:
		var tween = create_tween()
		tween.set_loops(3)
		tween.tween_property(panel, "modulate", Color(0.3, 0.8, 1.0, 0.8), 0.2)
		tween.tween_property(panel, "modulate", Color(1, 1, 1, 0.2), 0.2)
		
		await tween.finished
		panel.modulate = Color(1, 1, 1, 0.3)
