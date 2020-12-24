extends EventTrigger

func toggleDisabled():
	.toggleDisabled()
	$Sprite.visible = !$Sprite.visible

func _on_EventTrigger_body_entered(body):
	if activated && !triggered && !disabled:
		Events.trigger(eventName)
		triggered = true
		$Sprite.visible = false
