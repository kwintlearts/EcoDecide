extends Node2D

@onready var light: DirectionalLight2D = $Lighting/light
@onready var tint: CanvasModulate = $Lighting/Tint

func _ready():
	Gamestate.time_changed.connect(_on_time_changed)
	Gamestate.day_changed.connect(_on_day_changed)
	_on_time_changed(Gamestate.time)

func _on_time_changed(time: float) -> void:
	var light_intensity = (cos((time - 0.5) * TAU) + 1.0) / 2.0
	light_intensity = clamp(light_intensity, 0.2, 1.0)
	
	light.energy = light_intensity
	
	var day_color = Color(1.0, 0.95, 0.8)
	var night_color = Color(0.2, 0.3, 0.5)
	tint.color = night_color.lerp(day_color, light_intensity)

func _on_day_changed(day: int) -> void:
	# Flash notification or sound
	print("Sun rises on day ", day)
