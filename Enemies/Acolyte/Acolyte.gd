extends ComplexEnemy

const Projectile = preload("res://Enemies/Acolyte/MagicProjectile.tscn")
const CircleShape = preload("res://Enemies/Acolyte/MagicProjectileShape.tres")

export var PROJECTILE_SPAWN_OFFSET = Vector2(-0.5, -15.5)

const STAND_STILL_AFTER_ATTACK_PERCENTAGE = 50

onready var projectileSpawnPosition = $ProjectileSpawnPosition

var spawning_projectile = null

func _process(delta):
	update()

func wander_state(delta):
	.wander_state(delta)
	
#func _draw():
#	if Utils.draw_debug:
#		draw_line(Vector2.ZERO, velocity.normalized() * 10, Color.white, 2.0)	

func chase_state(delta):
	.chase_state(delta)

func can_attack(player_position):
	if attackTimer.time_left > 0:
		return false
	
	# LOS Check 
	var space_state = get_world_2d().direct_space_state
	# 1 is a mask for the world
	var result = space_state.intersect_ray(projectileSpawnPosition.global_position, player_position, [self], 1)
	if result:
		return false
	
	# Verify there's a clear path above the enemy to spawn the projectile
	var second_raycast_result = space_state.intersect_ray(global_position, projectileSpawnPosition.global_position + PROJECTILE_SPAWN_OFFSET, [self], 1);
	if second_raycast_result:
		return false
	
	# Circle intersection check
	var query = Physics2DShapeQueryParameters.new()
	query.collide_with_areas = true
	query.set_shape(CircleShape)
	query.set_transform(projectileSpawnPosition.global_transform.translated(PROJECTILE_SPAWN_OFFSET))
	query.collision_layer = 1
	var shape_result = space_state.intersect_shape(query)
	if shape_result == null || shape_result.size() == 0:
		return true
	else:
		return false
	

func attack_state(delta):
	.attack_state(delta)
	if spawning_projectile != null:
		spawning_projectile.global_position = projectileSpawnPosition.global_position

func idle_state(delta):
	.idle_state(delta)

func spawn_projectile():
	if spawning_projectile != null:
		print("ERROR: spawning_projectile is not null")
	
	# initialize projectile above head
	spawning_projectile = Projectile.instance()
	get_parent().add_child(spawning_projectile)
	spawning_projectile.global_position = projectileSpawnPosition.global_position

func launch_projectile():
	if player_target == null:
		print("ERROR: player_target is null")
	
	if player_target == null || spawning_projectile == null:
		spawning_projectile = null
		player_target = null
		finish_attack()
		return
	
	spawning_projectile.launch(player_target)
	spawning_projectile = null
	player_target = null

func _on_Stats_no_health():
	._on_Stats_no_health()
	
	if spawning_projectile != null:
		spawning_projectile.queue_free()
