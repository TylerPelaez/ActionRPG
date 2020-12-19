extends State

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
	var roomExtents = owner.room.roomExtents
	var point = Vector2.ZERO
	var cnt = 0
	while (true):
		point = roomExtents.getRandomPointInRoom()
		
		if (start_position.distance_to(point) > 25 && 
			owner.target.global_position.distance_to(point) > 25 && 
			Utils.circle_cast(HunterCollisionShape, owner.global_transform.translated(point))):
			break
	
	return point		
	
func accelerate_toward_point(point, delta):
	var direction = owner.global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	owner.play_animation("Run", velocity.normalized())
