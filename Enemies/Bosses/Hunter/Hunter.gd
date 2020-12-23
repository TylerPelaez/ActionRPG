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
	.reset()
	for trap in traps_laid:
		trap.queue_free()
	traps_laid = []
