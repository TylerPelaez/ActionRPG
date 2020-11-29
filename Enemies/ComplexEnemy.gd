extends Enemy
class_name ComplexEnemy
# Complex Here refers to animation style, vs simple animation

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var invincibilityAnimationPlayer = $InvincibilityAnimationPlayer

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true

func idle_state(delta):
	.idle_state(delta)
	animationState.travel("Idle")

func wander_state(delta):
	.wander_state(delta)
	
	if velocity == Vector2.ZERO:
		animationState.travel("Idle")
	else:
		animationState.travel("Run")
	
func chase_state(delta):
	.chase_state(delta)
	if velocity == Vector2.ZERO:
		animationState.travel("Idle")
	else:
		animationState.travel("Run")

func attack_state(delta):
	.attack_state(delta)
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func update_animation():
	var facing_direction = velocity.normalized()
	if facing_direction != Vector2.ZERO:
		animationTree.set("parameters/Idle/blend_position", facing_direction)
		animationTree.set("parameters/Run/blend_position", facing_direction)
		animationTree.set("parameters/Attack/blend_position", facing_direction)

func _on_Hurtbox_invincibility_ended():
	invincibilityAnimationPlayer.play("Stop")

func _on_Hurtbox_invincibility_started():
	invincibilityAnimationPlayer.play("Start")
