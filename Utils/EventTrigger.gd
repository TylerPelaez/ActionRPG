extends Area2D
class_name EventTrigger

export (String) var eventName
export (bool) var retriggerable = false
export (bool) var disabled = false
export (String) var toggleDisableEventName

var triggered = false
var activated = true

func _ready():
	assert (eventName != null)
	Events.add_event(eventName)
	if toggleDisableEventName != null:
		Events.subscribe(toggleDisableEventName, funcref(self, "toggleDisabled"))

func toggleDisabled():
	disabled = !disabled

func deactivate():
	activated = false
	
func activate():
	activated = true
	
func _on_EventTrigger_body_entered(body):
	if activated && !triggered && !disabled:
		Events.trigger(eventName)
		triggered = true

func _on_EventTrigger_body_exited(body):
	if retriggerable:
		triggered = false
