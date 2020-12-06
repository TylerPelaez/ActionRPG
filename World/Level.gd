extends YSort

onready var camera = $Camera2D
onready var player = $Player

var current_room

func _ready():
	
	for child in get_children():
		if child is Room:
			child.connect("room_entered", self, "_on_room_entered")
			if child.starting_room && current_room != null:
				print("ERROR: multiple rooms tagged as starting room, skipping second")
				continue
			
			if child.starting_room:
				current_room = child
				camera.set_limits(current_room.roomExtents.topLeft(), current_room.roomExtents.bottomRight())

func _on_room_entered(room: Room):
	if current_room == room:
		return
	
	if current_room != null:
		current_room.exited()

	current_room = room
	camera.set_limits(current_room.roomExtents.topLeft(), current_room.roomExtents.bottomRight())
