extends CharacterBody2D

var speed = 100

var health = 100
var damage

var dead = false
var Sapling_in_area = false
var Sapling

func _ready():
	dead = false
	
func _physics_process(_delta):
	if !dead:
		$detection_area/CollisionShape2D.disabled = false
		if Sapling_in_area:
			position += (Sapling.position - position) / speed 
			$AnimatedSprite2D.play("move")
		else:
			$AnimatedSprite2D.play("move")
	if dead:
		$detection_area/CollisionShape2D.disabled = true

func _on_detection_area_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.has_method("Sapling"):
		Sapling_in_area = true
		Sapling = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.has_method("Sapling"):
		Sapling_in_area = false
