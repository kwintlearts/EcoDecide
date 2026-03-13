extends Area2D

var showInteractionLabel = false
var sprout_scene = preload("res://Scenes/sprout.tscn")   # Path to your sprout scene
var has_sprout = false
@onready var sprite: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	$Interact.visible = showInteractionLabel
	
	if showInteractionLabel && Input.is_action_just_pressed("interact") and not has_sprout:
		Score.add_points(10)   # Adds 10 points
		
		# Spawn sprout before removing dirt tile
		var sprout = sprout_scene.instantiate()
		sprout.global_position = global_position  # Place sprout where dirt tile is
		get_parent().add_child(sprout)
		
		queue_free()
		
		has_sprout = true 
		showInteractionLabel = false
		set_monitoring(false)
		

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not has_sprout: showInteractionLabel = true
	sprite.modulate = Color("fff706dc")
	


func _on_body_exited(body: Node2D) -> void:
	if body is Player and not has_sprout: showInteractionLabel = false
	sprite.modulate = Color("dfa988")
	
