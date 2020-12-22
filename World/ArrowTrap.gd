extends Node2D
class_name ArrowTrap

enum DIRECTION {
	DOWN,
	LEFT,
	RIGHT
}

const Arrow = preload("res://Enemies/Bosses/Hunter/Arrow.tscn")

export (String) var shutoffEventName
export (float) var fireInterval = 1.0
export (DIRECTION) var facing_direction = DIRECTION.DOWN
export (float) var arrowSpeed = 50.0

onready var fireIntervalTimer = $FireInterval

var firing_enabled = true
var active = false
var direction = Vector2.DOWN

func _ready():
	match facing_direction:
		DIRECTION.DOWN:
			direction = Vector2.DOWN
			$Sprite.frame = 0
		DIRECTION.LEFT:
			direction = Vector2.LEFT
			$Sprite.frame = 1
			$Sprite.scale = Vector2(-1,1)
			$Sprite.offset = Vector2(0,0)
		DIRECTION.RIGHT:
			direction = Vector2.RIGHT
			$Sprite.frame = 1
			$Sprite.offset = Vector2(-1,0)
	
	fireIntervalTimer.wait_time = fireInterval
	
	if shutoffEventName != null:
		Events.subscribe(shutoffEventName, funcref(self, "shutoff"))
	
func activate():
	active = true
	fireIntervalTimer.start(fireInterval)
	
func deactivate():
	active = false
		
func shutoff():
	firing_enabled = false

func fire():
	var instance = Utils.instance_scene_on_main(Arrow, global_position)
	instance.initialize(direction, true)

func _on_FireInterval_timeout():
	if active && firing_enabled:
		fire()
		fireIntervalTimer.start(fireInterval)
