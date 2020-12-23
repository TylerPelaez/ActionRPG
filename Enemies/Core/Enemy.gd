extends KinematicBody2D
class_name Enemy

signal on_death

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION := 300
export var MAX_SPEED := 50
export var FRICTION := 200
export var PUSH_STRENGTH := 400
export var WANDER_TARGET_DROPOFF_RANGE := 5
export var KNOCKBACK_AMOUNT := 120
export (float) var PLAYER_DETECTION_RADIUS = 100.0 
export (float) var PATHFIND_COLLISION_CHECK_ANGLE_INCREMENT = 10.0
export (int) var PATHFIND_COLLISION_CHECK_ANGLES = 10

export (float) var PATHFIND_NEIGHBOR_AVOIDANCE_RADIUS = 10.0
export (float) var PATHFIND_MAX_NEIGHBOR_AVOIDANCE_ANGLES = 4

enum {
	IDLE,
	WANDER,
	CHASE,
	ATTACK # For enemies with an explicit attack
}

onready var stats = $Stats
onready var playerDetectionArea = $PlayerDetectionArea
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var chasePlayerTimer = $ChasePlayerPathfindTimer
onready var debugLine = $Line2D

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var chase_player_path
var state = CHASE
var activated = false
var neighbor_collision_check_shape

func _ready():
	$PlayerDetectionArea/CollisionShape2D.shape.radius = PLAYER_DETECTION_RADIUS
	state = pick_random_state([IDLE, WANDER])
	neighbor_collision_check_shape = CircleShape2D.new()
	neighbor_collision_check_shape.radius = PATHFIND_NEIGHBOR_AVOIDANCE_RADIUS

func _physics_process(delta):
	if !activated:
		return
	
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			idle_state(delta)
		
		WANDER:
			wander_state(delta)
			
		CHASE:
			chase_state(delta)
		ATTACK:
			attack_state(delta)

	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * PUSH_STRENGTH
	velocity = move_and_slide(velocity)
	
	
	if state == CHASE && chase_player_path != null && !chase_player_path.empty() && global_position.distance_squared_to(chase_player_path[0]) <= 1:
		chase_player_path.remove(0)  

	if Utils.draw_debug:
		if chase_player_path != null:
			var newPoints = [Vector2.ZERO]
			
			for point in chase_player_path:
				newPoints.append(global_transform.xform_inv(point))
			
			debugLine.points = newPoints
		else:
			debugLine.points = PoolVector2Array()


func wander_state(delta):
	chase_player_path = null
	seek_player()
	
	if wanderController.get_time_left() == 0:
		update_wander()
	
	accelerate_toward_point(wanderController.target_position, delta)
	
	if global_position.distance_to(wanderController.target_position) <= WANDER_TARGET_DROPOFF_RANGE:
		update_wander()
			
	
func chase_state(delta):
	var player = playerDetectionArea.player
	if player != null:
		if player.global_position.distance_squared_to(global_position) <= 1 || chase_player_path == null || chase_player_path.empty():
			accelerate_toward_point(player.global_position, delta)	
		else:
			# let's avoid our neighbors, 16 is the  "enemy" mask
			var intersections = Utils.shape_cast_get_result(neighbor_collision_check_shape, $CollisionShape2D.global_transform, 16, [self])
			
			if intersections != null && !intersections.empty():
				var enemy_pos_sum = Vector2.ZERO
			
				for intersection in intersections:
					enemy_pos_sum += intersection.collider.global_position
				
				var average_pos = enemy_pos_sum / intersections.size()
				var away_pos = $CollisionShape2D.global_transform.xform_inv(average_pos).rotated(rad2deg(180))
				
				
				accelerate_toward_point( $CollisionShape2D.global_transform.xform(away_pos), delta)
			else:
				accelerate_toward_point(chase_player_path[0], delta)	
	else:
		state = IDLE
	
func idle_state(delta):
	chase_player_path = null
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	seek_player()
	
	if wanderController.get_time_left() == 0:
		update_wander()

# warning-ignore:unused_argument
func attack_state(delta):
	pass # unimplemented for base / simple enemies

func accelerate_toward_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	update_animation()
	
# A noop in the base class, which has no information regarding animation state
func update_animation():
	pass

func seek_player():
	if playerDetectionArea.can_see_player():
		state = CHASE
		update_chase_player_path()
		chasePlayerTimer.start()
		
func update_chase_player_path():
	chase_player_path = get_parent().get_nav_path(global_position, playerDetectionArea.player.global_position)
	adjust_chase_path_for_collisions()
	
func adjust_chase_path_for_collisions():
	if !chase_player_path.empty():
		var collisionShape = $CollisionShape2D
		var first_position = chase_player_path[0]
		var transformed_position = collisionShape.global_transform.xform_inv(first_position)
		 ## world layer, enemy layer
		var mask = 1 + 16
		

		if Utils.shape_cast_motion_does_not_collide($CollisionShape2D.shape, $CollisionShape2D.global_transform, Vector2.ZERO, transformed_position, mask, [self]):
			# Don't bother messing with the path, we won't hit anything
			return
		
		
		var current_offset = PATHFIND_COLLISION_CHECK_ANGLE_INCREMENT
		for i in range(1, PATHFIND_COLLISION_CHECK_ANGLES):
			# Stop trying to avoid neightbors at such large angles, it just results in really weird choices
			if i > PATHFIND_MAX_NEIGHBOR_AVOIDANCE_ANGLES:
				mask = 1
			
			var first_position_to_check = transformed_position.rotated(deg2rad(current_offset))
			var second_position_to_check = transformed_position.rotated(deg2rad(-current_offset))
			
			if Utils.shape_cast_motion_does_not_collide($CollisionShape2D.shape, $CollisionShape2D.global_transform, Vector2.ZERO, first_position_to_check, mask, [self]):
				chase_player_path[0] = $CollisionShape2D.global_transform.xform(first_position_to_check)
				return
			elif Utils.shape_cast_motion_does_not_collide($CollisionShape2D.shape, $CollisionShape2D.global_transform, Vector2.ZERO, second_position_to_check, mask, [self]):
				chase_player_path[0] = $CollisionShape2D.global_transform.xform(second_position_to_check)
				return
			
			current_offset += PATHFIND_COLLISION_CHECK_ANGLE_INCREMENT
		 
		print("failedall")

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	if area is SwordHitBox:
		knockback = area.knockback_vector * KNOCKBACK_AMOUNT
	hurtbox.start_invincibility(0.4)
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	emit_signal("on_death")
	call_deferred("queue_free")
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position

func _on_ChasePlayerPathfindTimer_timeout():
	if state == CHASE && playerDetectionArea.player != null:
		update_chase_player_path()
	chasePlayerTimer.start()


func activate():
	activated = true
	
func deactivate():
	activated = false
