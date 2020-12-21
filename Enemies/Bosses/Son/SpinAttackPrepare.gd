extends State

func enter():
	owner.get_node("AnimationPlayer").play("SpinPrepare")
	
func _on_animation_finished(anim_name):
	assert(anim_name == 'SpinPrepare')
	emit_signal('finished')
