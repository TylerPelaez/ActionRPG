extends Node2D

signal on_death()

func _on_Hitbox_body_entered(body):
	die()

func die():
	$Hitbox.monitorable = false
	$Hitbox.monitoring = false
	$AnimationPlayer.play("die")
	
func _on_death():
	emit_signal("on_death", self)
	queue_free()

func _on_Hitbox_area_entered(area):
	die()
