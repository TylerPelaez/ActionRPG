extends "res://Effects/Effect.gd"

const sounds = [preload("res://Music and Sounds/Hit1.wav"), preload("res://Music and Sounds/Hit.wav"), preload("res://Music and Sounds/Hit2.wav")]

func _ready():
	var sound = sounds[randi() % sounds.size()]
	$AudioStreamPlayer.stream = sound
	$AudioStreamPlayer.play()
