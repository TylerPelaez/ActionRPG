extends Node2D

var player

onready var camera = $Camera2D

var current_room

func _ready():
	
	for child in get_children():
		if child is Room:
			child.connect("room_entered", self, "_on_room_entered")
			if player == null:
				for grandchild in child.get_children():
					if grandchild is Player:
						current_room = child
						player = grandchild
						break

func _on_room_entered(room: Room):
	if current_room == room:
		return
	
	if current_room != null:
		current_room.exited()
		current_room.remove_child(player)
		current_room.remove_child(camera)

	current_room = room
	current_room.add_child(player)
	current_room.add_child(camera)
	camera.set_limits(current_room.roomExtents.topLeft(), current_room.roomExtents.bottomRight())
