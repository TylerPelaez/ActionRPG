extends Node2D

func _ready():
	if !get_tree().current_scene.just_started():
		$SpawnPlayer.play()

func _on_PlayerOverlap_body_entered(body):
	assert (body is Player)
	if PlayerStats.health < PlayerStats.max_health:
		PlayerStats.health += 2 
		body.pickup_health()
		queue_free()
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Spawn":
		$AnimationPlayer.play("Idle")
