extends KinematicBody2D
class_name Player

signal died

const PickupHealthSound = preload("res://Music and Sounds/pickuphealth.wav")
const PickupGemSound = preload("res://Music and Sounds/itempickup.wav")
const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var ACCELERATION = 500
export var MAX_SPEED = 100
export var ROLL_SPEED = 125
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var is_paused = false
var true_pause = false


# initialize as if it was being initialized in _ready
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	stats.connect("no_health", self, "_on_Stats_no_health")
	reset()

func reset():
	state = MOVE
	
	$Light2D.enabled = true
	animationTree.active = true
	
	velocity = Vector2.ZERO
	roll_vector = Vector2.DOWN
	swordHitbox.knockback_vector = roll_vector

	stats.reset()

# Update
func _physics_process(delta):
	if true_pause:
		return
	if is_paused && state == MOVE:
		animationState.travel("Idle")
		return
	
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = roll_vector
		
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("roll"):
		hurtbox.start_invincibility(0.4)
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func attack_animation_finish():
	state = MOVE

func roll_animation_finish():
	velocity = velocity / 2
	state = MOVE

func _on_Stats_no_health():
	emit_signal("died")

func _on_Hurtbox_area_entered(area):
	if area is HitBox && !hurtbox.invincible:
		got_hit(area.damage)

func got_hit(damage):
	stats.health -= damage
	hurtbox.start_invincibility(0.6)
	_invincibility_started()
	hurtbox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)

func _invincibility_started():
	blinkAnimationPlayer.play("Start")

func pickup_health():
	$ItemPickupPlayer.stream = PickupHealthSound
	$ItemPickupPlayer.play()
	
func pickup_shard():
	$ItemPickupPlayer.stream = PickupGemSound
	$ItemPickupPlayer.play()

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")


func _on_Hurtbox_body_entered(body):
	if body is RockWallTileMap && !hurtbox.invincible:
		var result = Utils.shape_cast_get_result(hurtbox.collisionShape.shape, hurtbox.collisionShape.global_transform)
		if result == null || result.empty():
			return
		else:
			for res in result:
				body.delete_cell(res["metadata"][0], res["metadata"][1])
		
		got_hit(body.damage)
	
