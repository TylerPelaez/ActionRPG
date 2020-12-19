extends KinematicBody2D
class_name Boss

signal died()

onready var state_machine: StateMachine = $BossStateMachine 
onready var stats = $Stats
onready var hurtbox = $Hurtbox
onready var lifebar = $BossLifebar


var room
var start_global_position
var target

func initialize(_target, _room):
	target = _target 
	room = _room

func _ready():
	visible = false
	hurtbox.set_invincible(true)
	start_global_position = global_position
	lifebar.initialize(stats)
	
func start():
	lifebar.appear()
	state_machine.start()

func set_invincible(value):
	hurtbox.set_invincible(value)
	$CollisionShape2D.set_deferred("disabled", value)
	$Hitbox/CollisionShape2D.set_deferred("disabled", value)
	$Hitbox.set_deferred("monitorable", not value)

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
