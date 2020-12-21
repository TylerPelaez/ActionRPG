extends Node2D
class_name DelayedSpawn

enum ENEMY {
	BAT,
	ACOLYTE,
	KNIGHT
}

const enemyLookup = {
	ENEMY.BAT: preload("res://Enemies/Bat/Bat.tscn"),
	ENEMY.ACOLYTE: preload("res://Enemies/Acolyte/Acolyte.tscn"),
	ENEMY.KNIGHT: preload("res://Enemies/StatueKnight/StatueKnight.tscn")
}

export (ENEMY) var enemyToSpawn
export (int) var wave =1

func spawnEnemy():
	var instance = enemyLookup[enemyToSpawn].instance()
	get_parent().add_child(instance)
	instance.global_position = global_position
	instance.activate()
	return instance
