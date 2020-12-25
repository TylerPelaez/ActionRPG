extends StaticBody2D
class_name Door

export (bool) var locked_on_init = false
export (String) var lockToggleEventName

const door_open_sound = preload("res://Music and Sounds/dooropen.wav")
const door_close_sound = preload("res://Music and Sounds/doorclose.wav")

const closedDoor = preload("res://World/Door.png")
const openDoor = preload("res://World/OpenDoor.png")

var currently_locked

onready var sprite = $Sprite
onready var closedCollider = $ClosedCollider
onready var openCollider1 = $OpenCollider1
onready var openCollider2 = $OpenCollider1
onready var animationPlayer = $AnimationPlayer


func _ready():
	if lockToggleEventName != null:
		Events.subscribe(lockToggleEventName, funcref(self, "toggleLock") )
	
	currently_locked = locked_on_init
	
	if !currently_locked:
		open()
	else:
		close()

func close():	
	closedCollider.set_deferred("disabled", false)
	openCollider1.set_deferred("disabled", true)
	openCollider2.set_deferred("disabled", true)
	animationPlayer.play("Close")
	if !$AudioStreamPlayer.playing && !get_tree().current_scene.just_started():
		$AudioStreamPlayer.stream = door_close_sound
		$AudioStreamPlayer.volume_db = -20.428
		$AudioStreamPlayer.play()

func toggleLock():
	currently_locked = !locked_on_init
	if !currently_locked:
		open()
	else:
		close()

func open():
	if !currently_locked:
		animationPlayer.play("Open")
		if !$AudioStreamPlayer.playing && !get_tree().current_scene.just_started():
			$AudioStreamPlayer.stream = door_open_sound
			$AudioStreamPlayer.volume_db = -18.511
			$AudioStreamPlayer.play()

func _on_finish_open():
	closedCollider.set_deferred("disabled", true)
	openCollider1.set_deferred("disabled", false)
	openCollider2.set_deferred("disabled", false)
