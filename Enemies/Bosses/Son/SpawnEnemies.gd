extends State

func enter():
	owner.get_node("AnimationPlayer").play("SummonEnemies")

func exit():
	pass

func _on_animation_finished(anim_name):
	assert(anim_name == 'SummonEnemies')
	emit_signal('finished')
