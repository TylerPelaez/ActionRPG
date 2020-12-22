extends AnimatedSprite

func _ready():
	# warning-ignore:return_value_discarded
	self.connect("animation_finished", self, "_on_animation_finished")
	frame = 0 # technically not required, but possible to accidentally set in the editor
	play("Animate")
	
func no_sound():
	$AudioStreamPlayer.playing = false

func _on_animation_finished():
	queue_free()
