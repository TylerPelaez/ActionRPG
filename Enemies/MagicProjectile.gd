extends AnimatedSprite
class_name MagicProjectile


export var MAX_SPEED = 75
export var ACCELERATION = 150

onready var velocity = Vector2.ZERO
onready var area2D = $Area2D
onready var deletionTimer = $DeletionTimer

var _target

func _physics_process(delta):
	if _target != null:
		accelerate_toward_point(_target.global_position, delta)
		
		global_position += (velocity * delta)
		

func accelerate_toward_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)

func launch(target):
	_target = target
	velocity = global_position.direction_to(_target.global_position) * (MAX_SPEED / 2.0)
	speed_scale *= 2
	area2D.monitoring = true
	deletionTimer.start()

func _on_Area2D_area_entered(area):
	delete()


func _on_Hitbox_area_entered(area):
	delete()

func _on_Area2D_body_entered(body):
	delete()

func delete():
	queue_free()

func _on_DeletionTimer_timeout():
	delete()
