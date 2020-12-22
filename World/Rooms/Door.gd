extends StaticBody2D
class_name Door

export (bool) var locked = false
export (String) var openEventName

const closedDoor = preload("res://World/Door.png")
const openDoor = preload("res://World/OpenDoor.png")



onready var sprite = $Sprite
onready var closedCollider = $ClosedCollider
onready var openCollider1 = $OpenCollider1
onready var openCollider2 = $OpenCollider1
onready var animationPlayer = $AnimationPlayer


func _ready():
	if !locked:
		open()
	else:
		assert(openEventName != null)
		Events.subscribe(openEventName, funcref(self, "unlock") )
		close()

func close():	
	closedCollider.set_deferred("disabled", false)
	openCollider1.set_deferred("disabled", true)
	openCollider2.set_deferred("disabled", true)
	animationPlayer.play("Close")

func unlock():
	locked = false
	open()

func open():
	if !locked:
		animationPlayer.play("Open")

func _on_finish_open():
	closedCollider.set_deferred("disabled", true)
	openCollider1.set_deferred("disabled", false)
	openCollider2.set_deferred("disabled", false)
