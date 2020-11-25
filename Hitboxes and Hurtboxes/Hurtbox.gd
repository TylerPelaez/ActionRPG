extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincible = false setget set_invincible

onready var timer = $Timer
onready var collisionShape = $CollisionShape2D

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")
	

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)

func create_hit_effect():
	var effect = HitEffect.instance()
	var world = get_tree().current_scene
	world.add_child(effect)
	effect.global_position = global_position


func _on_Timer_timeout():
	# This calls the setter defined near setget, because we've indicated self
	self.invincible = false


func _on_Hurtbox_invincibility_started():
	collisionShape.set_deferred("disabled", true)


func _on_Hurtbox_invincibility_ended():
		collisionShape.disabled = false
