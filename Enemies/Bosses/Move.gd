extends State
class_name Move

const HunterCollisionShape = preload("res://Enemies/Bosses/Hunter/HunterCollisionShape.tres")

export(float) var ACCELERATION := 300
export(float) var MAX_SPEED := 100
export(float) var FRICTION := 200

var start_position = Vector2()
var target_position_path = []
var velocity = Vector2()
var line

func enter():
	start_position = owner.global_position
	var target_position = calculate_new_target_position()
	
	target_position_path = owner.room.get_nav_path(owner.global_position, target_position)
	
	line = owner.get_node("Line2D")
	
	owner.play_animation("Run", (target_position_path[0] - owner.global_position).normalized())
	

func update(delta):
	if target_position_path == null || target_position_path.empty():
		print_debug("ERROR: target_position_path is empty")
		emit_signal("finished")
		return
		
	accelerate_toward_point(target_position_path[0], delta)
	velocity = owner.move_and_slide(velocity)	
	owner.play_animation("Run", velocity.normalized())
	if owner.global_position.distance_squared_to(target_position_path[0]) <= 5:
		velocity = Vector2.ZERO
		target_position_path.remove(0)
		if target_position_path.empty():
			emit_signal("finished")
			
	if Utils.draw_debug:
		if target_position_path != null:
			var newPoints = [Vector2.ZERO]
			
			for point in target_position_path:
				newPoints.append(owner.global_transform.xform_inv(point))
			
			line.points = newPoints
		else:
			line.points = PoolVector2Array()

func calculate_new_target_position():
	pass
	
func accelerate_toward_point(point, delta):
	var direction = owner.global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	owner.play_animation("Run", velocity.normalized())
