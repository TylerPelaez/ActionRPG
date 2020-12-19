extends State

const ProjectileScene = preload("res://Enemies/Bosses/Hunter/Arrow.tscn")
const BearTrapScene = preload("res://Enemies/Bosses/Hunter/BearTrap.tscn")


const FIRE = "Fire"
const PROJECTILE_COUNT = 36
const PROJECTILE_ANGLE = 10
const INITIAL_OFFSET = 10

func enter():
	owner.get_node("AnimationPlayer").play("AreaAttack")

func _on_animation_finished(anim_name: String):
	assert(anim_name.begins_with("AreaAttack"))
	owner.lay_trap()
	emit_signal('finished')

func fire():
	var directions = []
	
	for i in range(PROJECTILE_COUNT):
		var mult = 1
		if i % 2 == 0 && i != 0:
			mult = -1
		
		
		var direction = Vector2.RIGHT.rotated( mult * deg2rad(PROJECTILE_ANGLE * ((i + 1) / 2)) )
		var instance = Utils.instance_scene_on_main(ProjectileScene, owner.get_node("AreaAttack").global_position + (direction * INITIAL_OFFSET))
		instance.initialize(direction)	
