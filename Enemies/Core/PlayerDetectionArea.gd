extends Area2D

# How much should the detection radius expand once the player is inside?
export var PLAYER_STICKINESS_MULTIPLIER = 1.5

var player = null
onready var collider = $CollisionShape2D
var playerInsideRadius
var playerOutsideRadius

func _ready():
	if collider.shape is CircleShape2D:
		playerOutsideRadius = collider.shape.radius
		playerInsideRadius = playerOutsideRadius * PLAYER_STICKINESS_MULTIPLIER

func can_see_player():
	if player == null:
		return false
	
	# LOS check. WE don't care about cones of vision or any of that stuff
	var space_state = get_world_2d().direct_space_state
	# 1 is a mask for the world
	var result = space_state.intersect_ray(global_position, player.global_position, [self], 1)
	
	return result == null || result.empty()

func _on_PlayerDetectionArea_body_entered(body):
	if collider.shape is CircleShape2D:
		collider.shape.set_deferred("radius", playerInsideRadius)
	player = body

# warning-ignore:unused_argument
func _on_PlayerDetectionArea_body_exited(body):
	if collider.shape is CircleShape2D:
		collider.shape.set_deferred("radius", playerOutsideRadius)
	player = null
