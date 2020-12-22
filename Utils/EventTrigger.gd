extends Area2D

export (String) var eventName

var triggered = false

func _ready():
	assert (eventName != null)
	Events.add_event(eventName)
	
	
func _on_EventTrigger_body_entered(body):
	if !triggered:
		Events.trigger(eventName)
		triggered = true
