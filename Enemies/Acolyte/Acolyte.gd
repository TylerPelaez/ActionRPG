extends ComplexEnemy

const Projectile = preload("res://Enemies/Acolyte/MagicProjectile.tscn")
const CircleShape = preload("res://Enemies/Acolyte/MagicProjectileShape.tres")

const max_player_closeness = 100.0
export var PROJECTILE_SPAWN_OFFSET = 16

const STAND_STILL_AFTER_ATTACK_PERCENTAGE = 50

onready var projectileSpawnPosition = $ProjectileSpawnPosition

var spawning_projectile = null
var actual_projectile_spawn_position = Vector2.ZERO

func _process(delta):
	update()

func wander_state(delta):
	.wander_state(delta)
	
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
	
	var direction_array
	# check if player is more rightward or leftward
	if player_position.x > projectileSpawnPosition.global_position.x:
		direction_array = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN]
	else:
		direction_array = [Vector2.UP, Vector2.LEFT, Vector2.DOWN]
	
	
	
	for direction in direction_array:
		# rayscast to direction * PROJECTILE_SPAWN_OFFSET to determine which direction to spawn projectile in
		var projectile_spawn_position = projectileSpawnPosition.global_position + (direction * PROJECTILE_SPAWN_OFFSET)
		var raycast_to_potential_spawn = space_state.intersect_ray(projectileSpawnPosition.global_position, projectile_spawn_position, [self], 1)
		if raycast_to_potential_spawn:
			continue
		
		var shape_cast_result = Utils.shape_cast(CircleShape, projectileSpawnPosition.global_transform.translated(direction * PROJECTILE_SPAWN_OFFSET))
		
		if shape_cast_result:
			actual_projectile_spawn_position = projectile_spawn_position
			return true
	
	return false

func attack_state(delta):
	.attack_state(delta)
	if spawning_projectile != null:
		spawning_projectile.global_position = actual_projectile_spawn_position

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

func update_chase_player_path():
	# get path to player, then move back by the max_closeness value
	chase_player_path = get_parent().get_nav_path(global_position, playerDetectionArea.player.global_position)
	if !chase_player_path.empty():
		var last_point: Vector2 = chase_player_path[chase_player_path.size() - 1]
		chase_player_path.remove(chase_player_path.size() - 1)
		var direction_to_second_to_last_point = (global_position - last_point if chase_player_path.empty() else  chase_player_path[chase_player_path.size() - 1] - last_point).normalized()
		
		var real_final_point = last_point  + (direction_to_second_to_last_point * max_player_closeness)
		chase_player_path = get_parent().get_nav_path(global_position, real_final_point)
