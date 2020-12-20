extends State

func enter():
	owner.get_node("AnimationPlayer").play("CreateWall")
	
func _on_animation_finished(anim_name):
	assert(anim_name == 'CreateWall')
	emit_signal('finished')
