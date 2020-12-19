extends YSort
class_name Room

# warning-ignore:unused_signal
signal room_entered(room)

export var starting_room = false

onready var roomExtents = $RoomExtents
var room_defeated = false
var enemy_count = 0
var enemy_death_count = 0

func _ready():
	enemy_count = 0
	var staticBodies = []
	for child in get_children():
		if child is Enemy:
			enemy_count += 1
			child.connect("on_death", self, "_on_enemy_death")
		
		if child is StaticBody2D && !(child is Door):
			staticBodies.append(child)
	
	roomExtents.initialize(staticBodies)
	if enemy_count == 0:
		room_defeated = true

func get_nav_path(from, to):
	var path = roomExtents.nav.get_simple_path(from, to)
	if !path.empty():
		path.remove(0)
	return path

func close_doors():
	for child in get_children():
		if child is Door:
			child.close()

func open_doors():
	for child in get_children():
		if child is Door:
			child.open()

func exited():
	pass

# warning-ignore:unused_argument
func _on_RoomExtents_body_entered(body):
	call_deferred("emit_signal", "room_entered", self)
	if !room_defeated:
		close_doors()

func _on_enemy_death():
	enemy_death_count += 1
	if enemy_death_count >= enemy_count:
		room_defeated = true
		open_doors()
