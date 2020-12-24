extends State

export(float) var ACCELERATION := 300
export(float) var MAX_SPEED := 200
export (float) var TURN_SPEED := 1.0
export (int) var MAX_HITS = 2

const HitboxShape = preload("res://Enemies/Bosses/Son/SonSpinHitbox.tres")

var hitbox
var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var collisionShape
var active = false
var hit_count = 0

func enter():
	owner.get_node("AnimationPlayer").play("SpinAttack")
	hitbox = owner.get_node("Hitbox")
	collisionShape = owner.get_node("Hitbox/CollisionShape2D")
	collisionShape.set_deferred("shape",  load("res://Enemies/Bosses/Son/SonSpinHitbox.tres"))
	collisionShape.set_deferred("disabled", false)
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)

	hitbox.connect("area_entered", self, "_on_Hitbox_area_entered")
	
	owner.get_node("CollisionShape2D").shape = load("res://Enemies/Bosses/Son/SonSpinHitbox.tres")
	owner.get_node("CollisionShape2D").disabled = false
	
	direction = (owner.target.global_position - owner.global_position).normalized()
	velocity = Vector2.ZERO
	$Timer.start()
	active = true
	hit_count = 0
	
func exit():
	if active:
		active = false
		$Timer.stop()
		velocity = Vector2.ZERO
		hitbox.set_deferred("monitoring", false)
		hitbox.set_deferred("monitorable", false)
		collisionShape.set_deferred("shape", null)
		collisionShape.set_deferred("disabled", true)
		owner.get_node("CollisionShape2D").shape = null
		owner.get_node("CollisionShape2D").disabled = true
		hitbox.disconnect("area_entered", self, "_on_Hitbox_area_entered")

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

func _on_Hitbox_area_entered(area):
	assert(active)
	hit_count += 1
	if hit_count >= MAX_HITS:
		$Timer.stop()
		emit_signal("finished")

func _on_Hitbox_body_entered(body):
	assert(active)
	hit_count += 1
	if hit_count >= MAX_HITS:
		$Timer.stop()
		emit_signal("finished")
