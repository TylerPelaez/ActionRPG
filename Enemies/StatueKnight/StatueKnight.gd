extends ComplexEnemy
class_name StatueKnight

onready var swordHitboxPivot = $SwordHitboxPivot
onready var swordHitbox = $SwordHitboxPivot/SwordHitbox
onready var playerWithinRange = $SwordHitboxPivot/PlayerWithinRange

var canHitPlayer = false
var playerClose = false

# warning-ignore:unused_argument
func _physics_process(delta):
	playerWithinRange.position = swordHitbox.position

func chase_state(delta):
	# The player is in "attack range", so we wont try to get any closer
	if playerClose:
		velocity = Vector2.ZERO
		chase_but_dont_move()
		update_animation()
	else:
		.chase_state(delta)

# warning-ignore:unused_argument
func can_attack(player_position):
	if attackTimer.time_left > 0:
		return false
	return canHitPlayer

func attack_state(delta):
	.attack_state(delta)

func idle_state(delta):
	.idle_state(delta)

func pivot(rot):
	swordHitboxPivot.rotation = deg2rad(rot)

func update_animation():
	.update_animation()
	var player = playerDetectionArea.player
	if state == CHASE && playerClose && player != null:
		animationTree.set("parameters/Attack/blend_position", player.global_position - global_position)
		animationTree.set("parameters/Idle/blend_position", player.global_position - global_position)

# warning-ignore:unused_argument
func _on_PlayerClose_area_entered(area):
	playerClose = true


# warning-ignore:unused_argument
func _on_PlayerClose_area_exited(area):
	playerClose = false


# warning-ignore:unused_argument
func _on_PlayerWithinRange_area_entered(area):
	canHitPlayer = true


# warning-ignore:unused_argument
func _on_PlayerWithinRange_area_exited(area):
	canHitPlayer = false
