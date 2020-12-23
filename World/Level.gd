extends YSort
class_name Level

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
	
	var cutscenes = get_node("Cutscenes")
	if cutscenes != null:
		for child in cutscenes.get_children():
			assert (child is CutsceneSpawner)
			child.initialize($CanvasLayer, camera, player)

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

	var midpoint = previous_room.roomExtents.get_midpoint_in_bounds()
	var playerCollisionShape = player.get_node("CollisionShape2D")
	while true:
		if Utils.shape_cast(playerCollisionShape.shape, playerCollisionShape.global_transform.translated(playerCollisionShape.global_transform.xform_inv(midpoint))):
			player.global_position = midpoint
			break
		
		midpoint = previous_room.roomExtents.getRandomPointInRoom()
		
	current_room.reset()

# For Dialog event triggering
func _on_Events_event_triggered(eventName: String):
	assert(eventNameHeldDuringDialogTransition == null)
	if tween.is_active():
		eventNameHeldDuringDialogTransition = eventName
	else:
		dialogBox.on_Events_event_triggered(eventName)


func _on_DialogueBox_on_play_dialog():
	pass # Replace with function body.


func _on_DialogueBox_on_finish_dialog():
	pass # Replace with function body.


func _on_Tween_tween_all_completed():
	current_room.on_camera_transition_complete()
	if eventNameHeldDuringDialogTransition != null:
		dialogBox.call_deferred("on_Events_event_triggered",eventNameHeldDuringDialogTransition)
		eventNameHeldDuringDialogTransition = null

func _on_Stairs_player_entered():
	Events.clear()
	Utils.load_next_level()
