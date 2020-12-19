extends State

func enter():
	owner.play_animation("Idle", owner.last_direction)
	$Timer.start()
	
func update(delta):
	if $Timer.time_left <= 0.0:
		emit_signal("finished")

func exit():
	$Timer.stop()
