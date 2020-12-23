extends Area2D

signal picked_up

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("picked_up", PlayerStats, "pickupShard")


func _on_GemshardPickup_body_entered(body):
	assert(body is Player)
	emit_signal("picked_up")
	queue_free()



func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Spawn":
		$AnimationPlayer.play("Hover")
