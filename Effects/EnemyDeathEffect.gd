extends "res://Effects/Effect.gd"

func _ready():
	if !get_tree().current_scene.enemyDeathSoundPlaying():
		get_tree().current_scene.enemyDeathSoundPlay()
		$AudioStreamPlayer.play()
		
