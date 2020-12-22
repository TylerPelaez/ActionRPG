extends Node2D

func _on_PlayerOverlap_body_entered(body):
	assert (body is Player)
	if PlayerStats.health < PlayerStats.max_health:
		PlayerStats.health += 2 
		queue_free()
	
