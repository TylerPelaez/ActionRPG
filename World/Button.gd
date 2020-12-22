extends Node2D
class_name WorldButton

export (String) var event_name

var pressed = false

func _ready():
	Events.add_event(event_name)

func _on_Area2D_body_entered(body):
	assert (body is Player)
	if !pressed:
		$Sprite.frame = 1
		Events.trigger(event_name)
		pressed = true
