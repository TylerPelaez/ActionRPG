extends ComplexEnemy

const Projectile = preload("res://Enemies/MagicProjectile.tscn")
const CircleShape = preload("res://Enemies/MagicProjectileShape.tres")

const STAND_STILL_AFTER_ATTACK_PERCENTAGE = 50

onready var attackTimer = $AttackTimer
onready var projectileSpawnPosition = $ProjectileSpawnPosition

var spawning_projectile = null
var player_target = null

func wander_state(delta):
	.wander_state(delta)
	
# For the Acolyte, chase means "while aggro'd
func chase_state(delta):
	# Do not call parent function
	
	# Set correct animation 
	if velocity == Vector2.ZERO:
		animationState.travel("Idle")
	else:
		animationState.travel("Run")
	#randi() % 100 + 1
	
	var player = playerDetectionArea.player
	if player != null:
		accelerate_toward_point(player.global_position, delta)
		# We need to be facing the right way
		animationTree.set("parameters/Attack/blend_position", (player.global_position - global_position).normalized())
		
		if can_attack(player.global_position):
			state = ATTACK
			player_target = player
	else:
		state = IDLE

func can_attack(player_position):
	if attackTimer.time_left > 0:
		return false
	
	# LOS Check 
	var space_state = get_world_2d().direct_space_state
	# 1 is a mask for the world
	var result = space_state.intersect_ray(projectileSpawnPosition.global_position, player_position, [self], 1)
	if result:
		return false
	
	# Circle intersection check
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(CircleShape)
	query.set_transform(projectileSpawnPosition.global_transform)
	query.collision_layer = 1
	var shape_result = space_state.intersect_shape(query)
	if shape_result == null || shape_result.size() == 0:
		return true
	else:
		return false
	

func attack_state(delta):
	.attack_state(delta)

func idle_state(delta):
	.idle_state(delta)

func spawn_projectile():
	if spawning_projectile != null:
		print("ERROR: spawning_projectile is not null")
	
	# initialize projectile above head
	spawning_projectile = Projectile.instance()
	get_parent().add_child(spawning_projectile)
	spawning_projectile.global_position = projectileSpawnPosition.global_position
	
	pass

func launch_projectile():
	if player_target == null:
		print("ERROR: player_target is null")
	
	spawning_projectile.launch(player_target)
	spawning_projectile = null
	player_target = null

func finish_attack():
	attackTimer.start()
	state = CHASE

func _on_Stats_no_health():
	._on_Stats_no_health()
	
	if spawning_projectile != null:
		spawning_projectile.queue_free()
