# inventory_item.gd
extends Resource
class_name InvItem

@export var id: String = ""
@export var name: String = ""         
@export var description: String = ""
@export var texture: Texture2D
@export var atlas_texture: AtlasTexture
@export var ui_scale: Vector2 = Vector2(1, 1)

@export var has_dialogue: bool = false
@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

# New properties for item states
@export var can_rinsed: bool = false
@export var rinse_version: InvItem
@export_enum("Hazardous", "Recyclable", "Biodegradable", "Residual", "Rinseable") var correct_bin: int = 0

# Category for item classification
@export_enum("Food", "Plastic", "Glass", "Ceramic", "Paper", "Metal", "Electronic", "Organic", "Other") var category: String = "Other"
