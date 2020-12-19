extends Node2D

const SPEED = 300

onready var sprite = $Sprite
onready var hitbox = $Hitbox

var velocity = Vector2.ZERO

func initialize(direction: Vector2):
	sprite.rotation = direction.angle()
	hitbox.rotation = direction.angle()
	velocity = direction * SPEED

func _physics_process(delta):
	global_position += velocity * delta

# warning-ignore:unused_argument
func _on_Hitbox_area_entered(area):
	delete()

func delete():
	queue_free()

func _on_Hitbox_body_entered(body):
	delete()

func _on_Area2D_area_entered(area):
	delete()

func _on_Area2D_body_entered(body):
	delete()
