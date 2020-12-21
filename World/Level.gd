extends YSort

const total_lerp_time = 0.4

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
				camera.reset_smoothing()

func _on_room_entered(room: Room):
	if current_room == room:
		return
	
	if current_room != null:
		current_room.exited()

	current_room = room
	
	var tween = $Tween
	tween.interpolate_property(camera, "limit_left",
		camera.limit_left, current_room.roomExtents.topLeft().x, total_lerp_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(camera, "limit_top",
		camera.limit_top, current_room.roomExtents.topLeft().y, total_lerp_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(camera, "limit_right",
		camera.limit_right, current_room.roomExtents.bottomRight().x, total_lerp_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.interpolate_property(camera, "limit_bottom",
		camera.limit_bottom, current_room.roomExtents.bottomRight().y, total_lerp_time,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)		

	tween.start()
