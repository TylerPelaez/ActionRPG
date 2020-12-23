extends YSort
class_name Room

# warning-ignore:unused_signal
signal room_entered(room)

export var starting_room = false
export (PackedScene) var item_drop

onready var roomExtents = $RoomExtents
var room_defeated = false
var enemy_count = 0
var enemy_death_count = 0
var active = false

var current_wave = 0
var max_wave = 0
var wave_spawners = {}
var initial_enemies = []
var traps = []


func _ready():
	enemy_count = 0
	var staticBodies = []
	
	for child in get_children():
		if child is Enemy:
			enemy_count += 1
			child.connect("on_death", self, "_on_enemy_death")
			initial_enemies.append([Utils.get_scene_from_enemy_object(child), child.global_position])
			
		if child is StaticBody2D && !(child is Door):
			staticBodies.append(child)
			
		if child is DelayedSpawn:
			if child.wave > max_wave:
				max_wave = child.wave
			
			
			if !wave_spawners.has(child.wave):
				wave_spawners[child.wave] = []
			wave_spawners[child.wave].append(child)
		
		if child is ArrowTrap:
			traps.append(child)
			
		if child is EventTrigger:
			child.deactivate()
		
		
	roomExtents.initialize(staticBodies)
	if enemy_count == 0:
		room_defeated = true
		
		

func get_nav_path(from, to):
	var path = roomExtents.nav.get_simple_path(from, to)
	if !path.empty():
		path.remove(0)
	return path

func close_doors():
	active = true
	
	for child in get_children():
		if child is Door:
			child.close()
		if child is Enemy:
			child.activate()

func open_doors():
	active = false
	for child in get_children():
		if child is Door:
			child.open()
		if child is Enemy:
			child.deactivate()
		if child is EventTrigger:
			child.activate()

func exited():
	pass

# warning-ignore:unused_argument
func _on_RoomExtents_body_entered(body):
	if !active:
		call_deferred("emit_signal", "room_entered", self)

func on_camera_transition_complete():
	for trap in traps:
		trap.activate()
	if !room_defeated:
		close_doors()

func _on_enemy_death():
	enemy_death_count += 1
	if enemy_death_count >= enemy_count && current_wave == max_wave:
		room_defeated = true
		if item_drop != null:
			Utils.call_deferred("instance_scene_on_main", item_drop, roomExtents.get_midpoint_in_bounds())
		open_doors()
	elif enemy_death_count >= enemy_count:
		enemy_death_count = 0
		current_wave += 1
		assert(wave_spawners.has(current_wave))
		enemy_count = wave_spawners[current_wave].size()
		for spawner in wave_spawners[current_wave]:
			var instance = spawner.spawnEnemy()
			instance.connect("on_death", self, "_on_enemy_death")

# player died, for instance	
func reset():
	open_doors()
	if !room_defeated:
		for child in get_children():
			if child is Enemy:
				child.queue_free()
	
		current_wave = 0
		enemy_count = initial_enemies.size()
		enemy_death_count = 0
		
		for enemy in initial_enemies:
			var EnemyScene = enemy[0]
			var instance = EnemyScene.instance()
			instance.connect("on_death", self, "_on_enemy_death")
			call_deferred("add_child", instance)
			instance.set_deferred("global_position", enemy[1])

func _on_RoomExtents_body_exited(body):
	if active:
		if !roomExtents.is_point_in_room(body.global_position):
			body.global_position = roomExtents.closest_point_in_room(body.global_position)
