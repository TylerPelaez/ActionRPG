extends State

export(float) var ACCELERATION := 300
export(float) var MAX_SPEED := 200
export (float) var TURN_SPEED := 1.0

const HitboxShape = preload("res://Enemies/Bosses/Son/SonSpinHitbox.tres")

var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var collisionShape

func enter():
	owner.get_node("AnimationPlayer").play("SpinAttack")
	collisionShape = owner.get_node("Hitbox/CollisionShape2D")
	collisionShape.shape = HitboxShape
	collisionShape.disabled = false
	
	owner.get_node("CollisionShape2D").shape = HitboxShape
	owner.get_node("CollisionShape2D").disabled = false
	
	direction = (owner.target.global_position - owner.global_position).normalized()
	velocity = Vector2.ZERO
	$Timer.start()
	
func exit():
	$Timer.stop()
	velocity = Vector2.ZERO
	collisionShape.shape = null
	collisionShape.disabled = true
	owner.get_node("CollisionShape2D").shape = null
	owner.get_node("CollisionShape2D").disabled = true

func update(delta):
	direction = direction.move_toward((owner.target.global_position - owner.global_position).normalized(), TURN_SPEED * delta).normalized()
	accelerate_toward_direction(delta)
	var collision = owner.move_and_collide(velocity * delta)
	if collision != null:
		handle_collision(collision)
	
func _on_animation_finished(anim_name):
	assert(anim_name == 'SpinAttack')

func _on_Timer_timeout():
	emit_signal('finished')

func accelerate_toward_direction(delta):
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)


func handle_collision(collision: KinematicCollision2D):
	var body_normal = collision.normal
	var new_direction = (direction + (2 * body_normal)).normalized()

	if collision.collider is RockWallTileMap:
		var result = Utils.shape_cast_get_result(HitboxShape, owner.get_node("CollisionShape2D").global_transform)
		for res in result:
			collision.collider.delete_cell(res.metadata[0], res.metadata[1])
	direction = new_direction
	velocity = velocity.length() * direction
