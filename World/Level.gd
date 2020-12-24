extends YSort
class_name Level

const total_lerp_time = 0.3

onready var camera = $Camera2D
onready var player = $Player
onready var dialogBox = $CanvasLayer/DialogueBox
onready var tween = $Tween

var playerOverlappingRoomsQueue = []
var mostRecentlyExitedRoom 

var eventNameHeldDuringDialogTransition

func _ready():
	player.connect("died", self, "_on_player_death")
# warning-ignore:return_value_discarded
	Events.connect("event_triggered", self, "_on_Events_event_triggered")
	for child in $Rooms.get_children():
		if child is Room:
			child.connect("room_entered", self, "_on_room_entered")
			child.connect("room_exited", self, "_on_room_exited")
			if child.starting_room:
				# Possibly unnecessary, but cant hurt
				camera.set_limits(child.roomExtents.topLeft(), child.roomExtents.bottomRight())
				camera.reset_smoothing()
	
	var cutscenes = get_node("Cutscenes")
	if cutscenes != null:
		for child in cutscenes.get_children():
			assert (child is CutsceneSpawner)
			child.initialize($CanvasLayer, camera, player)
			
	PlayerStats._on_new_scene()

func _on_room_entered(room: Room):
	playerOverlappingRoomsQueue.push_back(room)
	move_camera()

func move_camera():
	var room = get_most_current_room()
	if tween != null:
		tween.interpolate_property(camera, "limit_left",
			camera.limit_left, room.roomExtents.topLeft().x, total_lerp_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(camera, "limit_top",
			camera.limit_top, room.roomExtents.topLeft().y, total_lerp_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(camera, "limit_right",
			camera.limit_right, room.roomExtents.bottomRight().x, total_lerp_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		tween.interpolate_property(camera, "limit_bottom",
			camera.limit_bottom, room.roomExtents.bottomRight().y, total_lerp_time,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)		
		tween.start()


func _on_room_exited(room: Room):
	var most_current_room = get_most_current_room()
		
	if playerOverlappingRoomsQueue.find(room) != -1:
		playerOverlappingRoomsQueue.erase(room)
		
	mostRecentlyExitedRoom = room	
	
	if most_current_room == room:
		move_camera()

func get_most_current_room():
	if !playerOverlappingRoomsQueue.empty():
		return playerOverlappingRoomsQueue.back()
	else:
		return mostRecentlyExitedRoom

func get_most_previous_room():
	if !playerOverlappingRoomsQueue.empty():
		for i in range(0, playerOverlappingRoomsQueue.size()):
			var room = playerOverlappingRoomsQueue[(playerOverlappingRoomsQueue.size() - 1) - i]
			if room != get_most_current_room():
				return room
	
	return mostRecentlyExitedRoom

func _on_player_death():
	player.reset()
	var most_current_room = get_most_current_room()
	var most_previous_room = get_most_previous_room()
	
	var midpoint = most_previous_room.roomExtents.get_midpoint_in_bounds()
	var playerCollisionShape = player.get_node("CollisionShape2D")
	while true:
		if Utils.shape_cast(playerCollisionShape.shape, playerCollisionShape.global_transform.translated(playerCollisionShape.global_transform.xform_inv(midpoint))):
			player.global_position = midpoint
			break
		
		midpoint = most_previous_room.roomExtents.getRandomPointInRoom()
	
	most_current_room.reset()

# For Dialog event triggering
func _on_Events_event_triggered(eventName: String):
	assert(eventNameHeldDuringDialogTransition == null)
	if tween.is_active():
		eventNameHeldDuringDialogTransition = eventName
	else:
		dialogBox.on_Events_event_triggered(eventName)


func _on_DialogueBox_on_play_dialog():
	pass # Replace with function body.


func _on_DialogueBox_on_finish_dialog(dialogName):
	pass # Replace with function body.


func _on_Tween_tween_all_completed():
	get_most_current_room().on_camera_transition_complete()
	if eventNameHeldDuringDialogTransition != null:
		dialogBox.call_deferred("on_Events_event_triggered",eventNameHeldDuringDialogTransition)
		eventNameHeldDuringDialogTransition = null

func _on_Stairs_player_entered():
	Events.clear()
	Utils.load_next_level()
