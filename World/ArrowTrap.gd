extends Node2D
class_name ArrowTrap

enum DIRECTION {
	DOWN,
	LEFT,
	RIGHT,
	UP
}

const Arrow = preload("res://Enemies/Bosses/Hunter/Arrow.tscn")

export (String) var shutoffEventName
export (float) var fireInterval = 1.0
export (float) var initialFireInterval = 1.0
# So you can do 3 attacks in quick successioni, then wait longer until repeating fast attacks ( modulo 3, with longer modulo interval than regular
export (int) var modulo = 1
export (float) var moduloInterval = 1.0
export (DIRECTION) var facing_direction = DIRECTION.DOWN
export (float) var arrowSpeed = 50.0
export (bool) var spawnInWall = false

onready var fireIntervalTimer = $FireInterval

var fireCount = 0
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
		DIRECTION.UP:
			direction = Vector2.UP
			$Sprite.frame = 0
	
	fireIntervalTimer.wait_time = initialFireInterval
	
	if shutoffEventName != null:
		Events.subscribe(shutoffEventName, funcref(self, "shutoff"))
	
func activate():
	active = true
	fireIntervalTimer.start(initialFireInterval)
	
func deactivate():
	active = false
		
func shutoff():
	firing_enabled = false

func fire():
	var instance = Utils.instance_scene_on_main(Arrow, global_position)
	instance.initialize(direction, spawnInWall, arrowSpeed)
	fireCount += 1

func _on_FireInterval_timeout():
	if active && firing_enabled:
		fire()
		fireIntervalTimer.start(moduloInterval if modulo != 1 && fireCount % modulo == 0 else fireInterval)
