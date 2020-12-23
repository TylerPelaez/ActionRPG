extends KinematicBody2D
class_name Boss

signal died()

const directionLookup = {
	Vector2.RIGHT: "Right",
	Vector2.UP: "Up",
	Vector2.DOWN: "Down",
	Vector2.LEFT: "Left"
}

onready var state_machine: StateMachine = $BossStateMachine 
onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var lifebar = $BossLifebar

var room
var start_global_position
var target
var last_direction = Vector2.DOWN

func initialize(_target, _room):
	target = _target 
	room = _room
	target.connect("died", self, "_on_target_died")

func _ready():
	visible = false
	hurtbox.set_invincible(true)
	start_global_position = global_position
	lifebar.initialize(stats)
	
func reset():
	target.disconnect("died", self, "_on_target_died")
	visible = false

	global_position = start_global_position
	stats.health = stats.max_health
	lifebar.disappear()
	lifebar.initialize(stats)
	state_machine.active = false
	state_machine.reset()
	
func start():
	lifebar.appear()
	state_machine.start()

func set_invincible(value):
	hurtbox.set_invincible(value)
	$CollisionShape2D.set_deferred("disabled", value)
	$Hitbox/CollisionShape2D.set_deferred("disabled", value)
	$Hitbox.set_deferred("monitorable", not value)

onready var animationPlayer = $AnimationPlayer

func get_direction(input_direction):
	var max_dot = -100
	var best_direction = Vector2.DOWN
	
	for direction in directionLookup.keys():
		var dot: float = float(input_direction.dot(direction))
		if dot > max_dot:
			max_dot = dot
			best_direction = direction
			
	return best_direction


func play_animation(animationName, direction):
	var end_direction = directionLookup[get_direction(direction.normalized())] 
	if animationPlayer.is_playing() && animationPlayer.current_animation.begins_with(animationName):
		var start_time = animationPlayer.current_animation_position
		animationPlayer.play(animationName + end_direction)
		animationPlayer.seek(start_time)
	else:
		animationPlayer.play(animationName + end_direction)
	
	last_direction = get_direction(direction.normalized())


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.4)
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	hurtbox.set_invincible(true)
	lifebar.disappear()

func _on_Die_finished():
	state_machine.set_active(false)
	emit_signal("died")
	queue_free()

func _on_target_died():
	state_machine.idle()
