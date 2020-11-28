extends Enemy

onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var invincibilityAnimationPlayer = $InvincibilityAnimationPlayer

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

func _ready():
	animationTree.active = true

func _physics_process(delta):
	match state:
		IDLE:
			animationState.travel("Idle")
		WANDER:
			animationState.travel("Run")
		CHASE:
			animationState.travel("Run")

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
