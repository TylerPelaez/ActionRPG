extends YSort

const total_lerp_time = 0.3

onready var camera = $Camera2D
onready var player = $Player
onready var dialogBox = $CanvasLayer/DialogueBox
onready var tween = $Tween

var previous_room
var current_room

var eventNameHeldDuringDialogTransition

func _ready():
	player.connect("died", self, "_on_player_death")
	Events.connect("event_triggered", self, "_on_Events_event_triggered")
	for child in $Rooms.get_children():
		if child is Room:
			child.connect("room_entered", self, "_on_room_entered")
			if child.starting_room && current_room != null:
				print("ERROR: multiple rooms tagged as starting room, skipping second")
				continue
			
			if child.starting_room:
				previous_room = child
				current_room = child
				camera.set_limits(current_room.roomExtents.topLeft(), current_room.roomExtents.bottomRight())
				camera.reset_smoothing()

func _on_room_entered(room: Room):
	if current_room == room:
		return
	
	if current_room != null:
		current_room.exited()

	previous_room = current_room

	current_room = room

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


func _on_player_death():
	player.reset()
	player.global_position = (previous_room.roomExtents.bottomRight() + previous_room.roomExtents.topLeft()) / 2
	current_room.reset()

# For Dialog event triggering
func _on_Events_event_triggered(eventName: String):
	assert(eventNameHeldDuringDialogTransition == null)
	if tween.is_active():
		eventNameHeldDuringDialogTransition = eventName


func _on_DialogueBox_on_play_dialog():
	pass # Replace with function body.


func _on_DialogueBox_on_finish_dialog():
	pass # Replace with function body.


func _on_Tween_tween_all_completed():
	current_room.on_camera_transition_complete()
	if eventNameHeldDuringDialogTransition != null:
		dialogBox.call_deferred("on_Events_event_triggered",eventNameHeldDuringDialogTransition)
		eventNameHeldDuringDialogTransition = null


