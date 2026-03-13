extends Area2D

var showInteractionLabel = false
var tree_scene: PackedScene

func _ready() -> void:
	# Preload the tree scene so it’s ready to spawn
	tree_scene = preload("res://Scenes/tree.tscn")

func _process(_delta: float) -> void:
	$Interact.visible = showInteractionLabel
	
	if showInteractionLabel and Input.is_action_just_pressed("interact"):
		_plant_tree()
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		showInteractionLabel = true

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		showInteractionLabel = false

func _plant_tree() -> void:
	var tree_instance = tree_scene.instantiate()
	# Place the tree at the same position as the plantable tile
	tree_instance.position = position
	# Add it to the parent (usually the main scene/world)
	get_parent().add_child(tree_instance)
