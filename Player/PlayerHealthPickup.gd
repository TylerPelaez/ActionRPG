extends Node2D

func _on_PlayerOverlap_body_entered(body):
	assert (body is Player)
	if PlayerStats.health < PlayerStats.max_health:
		PlayerStats.health += 2 
		queue_free()
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Spawn":
		$AnimationPlayer.play("Idle")
