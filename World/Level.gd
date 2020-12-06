extends YSort

const total_lerp_time = 0.4
export (Curve) var camera_lerp_curve

onready var camera = $Camera2D
onready var player = $Player

var current_room
var current_lerp_time = 0.0
var lerping_camera = false
var new_top_left
var new_bottom_right
var initial_top_left
var initial_bottom_right

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


func _physics_process(delta):
	if lerping_camera:
		current_lerp_time += delta
		var curve_output = camera_lerp_curve.interpolate(min(current_lerp_time / total_lerp_time, 1.0))
			
		var top_left = lerp(initial_top_left, new_top_left, curve_output)
		var bottom_right = lerp(initial_bottom_right, new_bottom_right, curve_output)
		camera.set_limits(top_left, bottom_right)
		
		if current_lerp_time >= total_lerp_time:
			lerping_camera = false
			camera.reset_smoothing()
			camera.align()

func _on_room_entered(room: Room):
	if current_room == room:
		return
	
	if current_room != null:
		current_room.exited()

	current_room = room
	lerping_camera = true
	current_lerp_time = 0.0
	new_top_left = current_room.roomExtents.topLeft()
	new_bottom_right = current_room.roomExtents.bottomRight()
	initial_top_left = camera.get_camera_screen_center() - (camera.get_viewport_rect().size / 2)
	initial_bottom_right = camera.get_camera_screen_center() + (camera.get_viewport_rect().size / 2)
