extends Node2D

onready var navigation = $Navigation2D


func get_nav_path(from, to):
	var path = navigation.get_simple_path(from, to)
	path.remove(0)
	return path
