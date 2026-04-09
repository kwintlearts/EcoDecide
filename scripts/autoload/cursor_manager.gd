# cursor_manager.gd (Autoload)
extends Node

var cursor_textures = {}

func _ready():
	# Pre-scale all cursor textures
	var arrow = load("uid://dfqpqbc55r58q")
	var can_drop = load("uid://cgslqmoofgmbw")
	var drag = load("uid://b6rjp6l4tsyeu")
	
	cursor_textures[Input.CURSOR_ARROW] = _scale_texture(arrow, 2.0)
	cursor_textures[Input.CURSOR_CAN_DROP] = _scale_texture(can_drop, 2.0)
	cursor_textures[Input.CURSOR_DRAG] = _scale_texture(drag, 2.0)
	set_cursor(Input.CURSOR_ARROW)
	

func _scale_texture(texture: Texture2D, scale: float) -> Texture2D:
	if not texture:
		return null
	var image = texture.get_image()
	var new_size = Vector2(image.get_width() * scale, image.get_height() * scale)
	image.resize(new_size.x, new_size.y, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(image)

func set_cursor(cursor_type: int):
	if cursor_textures.has(cursor_type):
		Input.set_custom_mouse_cursor(cursor_textures[cursor_type], cursor_type)
