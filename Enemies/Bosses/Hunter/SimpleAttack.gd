extends State

const ProjectileScene = preload("res://Enemies/Bosses/Hunter/Arrow.tscn")
const BearTrapScene = preload("res://Enemies/Bosses/Hunter/BearTrap.tscn")


const FIRE = "Fire"
const PROJECTILE_COUNT = 7
const PROJECTILE_ANGLE = 10

var attack_direction

func enter():
	update_direction()

func update(delta):
	update_direction()
	
func update_direction():
	attack_direction = (owner.target.global_position - owner.global_position).normalized()
	
	var directions = [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]
	
	var max_dot = -100
	var best_direction = Vector2.RIGHT
	
	for direction in directions:
		var dot: float = float(attack_direction.dot(direction))
		if dot > max_dot:
			max_dot = dot
			best_direction = direction
			
	attack_direction = best_direction

	owner.play_animation("SimpleAttack", attack_direction)

func _on_animation_finished(anim_name: String):
	assert(anim_name.begins_with("SimpleAttack"))
	
	owner.lay_trap()
	emit_signal('finished')

func fire(index: int):
	var directions = []
	
	for i in range(PROJECTILE_COUNT):
		var mult = 1
		if i % 2 == 0 && i != 0:
			mult = -1
		
		
		var direction = attack_direction.rotated( mult * deg2rad(PROJECTILE_ANGLE * ((i + 1) / 2)) )
		var instance = Utils.instance_scene_on_main(ProjectileScene, owner.get_node(FIRE + str(index)).global_position)
		instance.initialize(direction, false, owner.PROJECTILE_SPEED, false)
