extends StaticBody2D
class_name Door

const closedDoor = preload("res://World/Door.png")
const openDoor = preload("res://World/OpenDoor.png")

onready var sprite = $Sprite
onready var collisionShape = $CollisionShape2D

func _ready():
	open()

func close():
	collisionShape.set_deferred("disabled", false)
	sprite.visible = true
	
func open():
	collisionShape.set_deferred("disabled", true)
	sprite.visible = false
