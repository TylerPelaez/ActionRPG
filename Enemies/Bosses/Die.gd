extends State

func enter():
	owner.get_node('AnimationPlayer').play('die')

func _on_animation_finished(anim_name):
	assert(anim_name == 'die')
	emit_signal("finished")
