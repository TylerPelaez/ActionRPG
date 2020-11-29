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
	return player != null

func _on_PlayerDetectionArea_body_entered(body):
	if collider.shape is CircleShape2D:
		collider.shape.set_deferred("radius", playerInsideRadius)
	player = body

func _on_PlayerDetectionArea_body_exited(body):
	if collider.shape is CircleShape2D:
		collider.shape.set_deferred("radius", playerOutsideRadius)
	player = null
