extends Boss

export (float) var PROJECTILE_SPEED = 250

const TrapScene = preload("res://Enemies/Bosses/Hunter/BearTrap.tscn")

const MAX_TRAPS = 4

var traps_laid = []

func _on_beartrap_death(instance):
	traps_laid.erase(instance)

func lay_trap():
	if traps_laid.size() >= MAX_TRAPS:
		traps_laid.pop_front().die()
	
	var instance = Utils.instance_scene_on_main(TrapScene, global_position)
	instance.connect("on_death", self, "_on_beartrap_death")
	traps_laid.push_back(instance)

func reset():
	clear_traps()
	.reset()



func clear_traps():
	for trap in traps_laid:
		trap.queue_free()
		traps_laid = []
	
	for child in get_tree().current_scene.get_children():
		if child is Arrow:
			child.delete()

func set_spawn_shader():
	pass

func set_white_color_shader():
	pass

func _on_Die_finished():
	clear_traps()
	._on_Die_finished()

func disable_traps():
	clear_traps()
