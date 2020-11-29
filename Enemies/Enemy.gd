extends KinematicBody2D
class_name Enemy

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

export var ACCELERATION := 300
export var MAX_SPEED := 50
export var FRICTION := 200
export var PUSH_STRENGTH := 400
export var WANDER_TARGET_DROPOFF_RANGE := 5

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

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
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
	
	
	if state == CHASE && chase_player_path != null && !chase_player_path.empty() && global_position.distance_squared_to(chase_player_path[0]) <= 0.0001:
		chase_player_path.remove(0)  

	if Utils.draw_debug:
		if chase_player_path != null:
			var newPoints = [Vector2.ZERO]
			
			for point in chase_player_path:
				newPoints.append(transform.xform_inv(point))
			
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
			accelerate_toward_point(chase_player_path[0], delta)	
	else:
		state = IDLE
	
func idle_state(delta):
	chase_player_path = null
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	seek_player()
	
	if wanderController.get_time_left() == 0:
		update_wander()

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
	chase_player_path = get_tree().current_scene.get_nav_path(global_position, playerDetectionArea.player.global_position)

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * 120
	hurtbox.start_invincibility(0.4)
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	call_deferred("queue_free")
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_ChasePlayerPathfindTimer_timeout():
	if state == CHASE && playerDetectionArea.player != null:
		update_chase_player_path()
	chasePlayerTimer.start()
