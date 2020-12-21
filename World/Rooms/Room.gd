extends YSort
class_name Room

# warning-ignore:unused_signal
signal room_entered(room)

export var starting_room = false

onready var roomExtents = $RoomExtents
var room_defeated = false
var enemy_count = 0
var enemy_death_count = 0
var active = false
var player_entrance_position

var current_wave = 0
var max_wave = 0
var wave_spawners = {}

func _ready():
	enemy_count = 0
	var staticBodies = []
	var highest_wave_found = 0
	
	for child in get_children():
		if child is Enemy:
			enemy_count += 1
			child.connect("on_death", self, "_on_enemy_death")
		
		if child is StaticBody2D && !(child is Door):
			staticBodies.append(child)
			
		if child is DelayedSpawn:
			if child.wave > highest_wave_found:
				max_wave = child.wave
			
			if !wave_spawners.has(child.wave):
				wave_spawners[child.wave] = []
			wave_spawners[child.wave].append(child)
	
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

func exited():
	pass

# warning-ignore:unused_argument
func _on_RoomExtents_body_entered(body):
	if !active:
		call_deferred("emit_signal", "room_entered", self)
		if !room_defeated:
			player_entrance_position = body.global_position
			close_doors()
			body.global_position = player_entrance_position

func _on_enemy_death():
	enemy_death_count += 1
	if enemy_death_count >= enemy_count && current_wave == max_wave:
		room_defeated = true
		open_doors()
	elif enemy_death_count >= enemy_count:
		enemy_death_count = 0
		current_wave += 1
		assert(wave_spawners.has(current_wave))
		enemy_count = wave_spawners[current_wave].size()
		for spawner in wave_spawners[current_wave]:
			var instance = spawner.spawnEnemy()
			instance.connect("on_death", self, "_on_enemy_death")
		
