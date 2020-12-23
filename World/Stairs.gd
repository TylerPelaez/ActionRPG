extends Node2D

signal player_entered

func _on_Area2D_body_entered(body):
	emit_signal("player_entered")
