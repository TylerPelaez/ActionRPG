extends Node2D

const SPEED = 300

onready var sprite = $Sprite
onready var hitbox = $Hitbox

var velocity = Vector2.ZERO
var starts_in_wall
var knockback_vector


func initialize(direction: Vector2, in_wall: bool = false, _speed: float = SPEED ):
	sprite.rotation = direction.angle()
	hitbox.rotation = direction.angle()
	velocity = direction * _speed
	knockback_vector = direction
	starts_in_wall = in_wall

func _physics_process(delta):
	global_position += velocity * delta

# warning-ignore:unused_argument
func _on_Hitbox_area_entered(area):
	delete()

func delete():
	queue_free()

# warning-ignore:unused_argument
func _on_Hitbox_body_entered(body):
	delete()

# warning-ignore:unused_argument
func _on_Area2D_area_entered(area):
	delete()

# warning-ignore:unused_argument
func _on_Area2D_body_entered(body):
	if starts_in_wall:
		starts_in_wall = false
	else:
		delete()
